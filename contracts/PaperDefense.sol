// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import 'hardhat/console.sol';

contract PaperDefense {
    // Structures ===========================================================================

    struct Tower {
        uint256 damage;
        uint256 range;
        uint256 fire_rate;
        uint256 last_fired;
    }

    struct Mob {
        bool spawned;
        bool reached_goal;
        uint256 cell_id;
        // steps towards next cell
        // this is used to record mob position inside a cell
        // each cell has 100 steps
        // it can be seens as a percentage of distance towards the next cell
        uint256 steps;
        // we keep track of the current cell the mob is moving towards to
        uint256 target_cell_index;
        uint256 life;
        // life cost when the mob reach the goal
        uint256 damage;
        uint256 speed;
        uint256 delay;
    }

    struct Game {
        uint256 wave;
        uint256 life;
        bool wave_started;
        // no more waves
        bool finished;
        uint256 tick;
        // all cells containing a tower
        uint256[] cells_with_towers;
        // cell id to tower
        mapping(uint256 => Tower) towers;
        // mob index to mob (kinda hack to have an array in a mapping)
        mapping(uint256 => Mob) mobs;
        uint256 mob_length;
    }

    // Storage ==============================================================================

    uint256 public constant MAP_WIDTH = 5;
    uint256 public constant MAP_HEIGHT = 5;

    // player to Game
    mapping(address => Game) public s_game;
    // wave index to wave ennemies
    mapping(uint256 => Mob[]) private s_wave_to_ennemies;

    uint256 public immutable i_total_waves;
    uint256[5] private MOB_PATH = [uint256(0), 1, 2, 3, 4];

    // Initialisation =======================================================================
    constructor() {
        Mob memory mob;
        mob.life = 3;
        mob.speed = 1;

        s_wave_to_ennemies[1].push(mob);
        // s_wave_to_ennemies[1].push(mob);
        i_total_waves = 1;
    }

    // Game engine ==========================================================================

    function _spawn_mobs(Game storage _state) private {
        uint256 tick = _state.tick;

        for (uint256 i = 0; i < _state.mob_length; i++) {
            Mob memory mob = _state.mobs[i];
            if (mob.spawned) continue;
            if (tick >= mob.delay) {
                _state.mobs[i].spawned = true;
            }
        }
    }

    function _execute_mobs(Game storage _state) private {
        for (uint256 i = 0; i < _state.mob_length; i++) {
            Mob storage mob = _state.mobs[i];

            if (mob.life == 0) continue;
            mob.steps += mob.speed;

            // if mob is switching cell
            if (mob.steps >= 100) {
                // reset the steps but keep advance
                // if the mob walked 114 steps we set it at 14 steps for the new cell
                mob.steps -= 100;
                mob.cell_id = MOB_PATH[mob.target_cell_index];
                mob.target_cell_index++;

                if (mob.target_cell_index >= MOB_PATH.length) {
                    // mob reached the end of is path
                    mob.reached_goal = true;

                    if (_state.life - mob.damage > 0) {
                        // game over
                        _state.life = 0;
                        return;
                    }

                    _state.life -= mob.damage;
                }
            }
        }
    }

    function _get_position(uint256 id)
        private
        pure
        returns (uint256 x, uint256 y)
    {
        x = id / MAP_WIDTH;
        y = id % MAP_WIDTH;
    }

    function _abs(int256 x) private pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }

    function _manhattan(
        uint256 x1,
        uint256 x2,
        uint256 y1,
        uint256 y2
    ) private pure returns (uint256) {
        return _abs(int256(x2 - x1)) + _abs(int256(y2 - y1));
    }

    function _is_in_range(
        uint256 _mob_cell_id,
        uint256 _tower_cell_id,
        uint256 _range
    ) private pure returns (bool) {
        (uint256 mob_x, uint256 mob_y) = _get_position(_mob_cell_id);
        (uint256 tower_x, uint256 tower_y) = _get_position(_tower_cell_id);
        return _manhattan(mob_x, tower_x, mob_y, tower_y) <= _range;
    }

    function _execute_towers(Game storage _state) private {
        uint256 tick = _state.tick;
        uint256[] memory towers_cells = _state.cells_with_towers;

        for (
            uint256 tower_cell_index = 0;
            tower_cell_index < towers_cells.length;
            tower_cell_index++
        ) {
            uint256 tower_cell_id = towers_cells[tower_cell_index];

            // memory because the loop will rarely need to update it
            Tower memory tower = _state.towers[tower_cell_id];

            for (
                uint256 mob_index = 0;
                mob_index < _state.mob_length;
                mob_index++
            ) {
                Mob storage mob = _state.mobs[mob_index];
                if (
                    !mob.spawned ||
                    mob.reached_goal ||
                    mob.life == 0 ||
                    !_is_in_range(mob.cell_id, tower_cell_id, tower.range)
                ) continue;

                // if the tower couldown is ready
                if (tower.last_fired + tower.fire_rate <= tick) {
                    // taking from storage
                    _state.towers[tower_cell_id].last_fired = tick;

                    // if tower will kill the mob
                    if (mob.life <= tower.damage) {
                        mob.life = 0;
                        // if tower is not going to kill the mob
                    } else {
                        mob.life -= tower.damage;
                    }
                }
            }
        }
    }

    function _playing(Game storage _state) private view returns (bool) {
        if (_state.life == 0) return true;
        for (uint256 i = 0; i < _state.mob_length; i++) {
            Mob memory mob = _state.mobs[i];
            if (mob.life > 0 && !mob.reached_goal) return true;
        }
        return false;
    }

    function _load_wave(Game storage _state) private {
        Mob[] memory next_wave = s_wave_to_ennemies[_state.wave];
        for (uint256 i = 0; i < next_wave.length; i++) {
            _state.mobs[i] = next_wave[i];
            _state.mob_length = next_wave.length;
        }
    }

    // Game calls ===========================================================================

    function new_game() external {
        Game storage game = s_game[msg.sender];
        game.wave = 1;
        _load_wave(game);
    }

    // function _cell_at(Cell[] _cells, uint256 _x, uint256 _y) private pure returns(Cell storage) {
    //     return _cells[_x * MAP_WIDTH] + y;
    // }

    function place_towers(uint256[] calldata _positions) external {
        Game storage game = s_game[msg.sender];
        // Cell[MAP_WIDTH * MAP_HEIGHT] storage cells = s_cells[msg.sender];
        for (uint256 i = 0; i < _positions.length; i++) {
            Tower storage s_tower = game.towers[_positions[i]];

            s_tower.damage = 1;
            s_tower.range = 2;
            s_tower.fire_rate = 1;
        }
    }

    function start_wave() external {
        Game storage game = s_game[msg.sender];

        require(game.wave_started, 'You did not complete the previous wave');

        game.wave_started = true;

        bool playing = _playing(game);

        while (playing) {
            // game tick
            _spawn_mobs(game);
            _execute_towers(game);
            _execute_mobs(game);

            playing = _playing(game);
        }

        // done playing
        game.wave++;

        if (game.wave >= i_total_waves) {
            game.finished = true;
        } else {
            for (uint256 i = 0; i < game.mob_length; i++) {
                delete game.mobs[i];
            }
            _load_wave(game);
        }
    }

    function get_mobs() external view returns (Mob[] memory) {
        uint256 mob_amount = s_game[msg.sender].mob_length;
        Mob[] memory mobs = new Mob[](mob_amount);
        for (uint256 i = 0; i < mob_amount; i++) {
            mobs[i] = s_game[msg.sender].mobs[i];
        }

        return mobs;
    }
}
