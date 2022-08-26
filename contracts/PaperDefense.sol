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
        uint256 mobs_length;
    }

    event wave_end(address player, uint256 wave, bool won);

    // Storage ==============================================================================

    uint256 public constant MAP_WIDTH = 5;
    uint256 public constant MAP_HEIGHT = 5;

    // player to Game
    mapping(address => Game) public s_game;
    // wave index to wave ennemies
    mapping(uint256 => Mob[]) private s_wave_to_ennemies;

    uint256 public immutable i_total_waves;
    // cell ids representing the path for the mobs
    uint256[35] private MOB_PATH = [
        uint256(0),
        1,
        2,
        3,
        13,
        23,
        33,
        43,
        42,
        41,
        51,
        61,
        71,
        81,
        82,
        83,
        84,
        85,
        86,
        76,
        66,
        56,
        46,
        36,
        26,
        27,
        28,
        38,
        48,
        58,
        68,
        78,
        88,
        89,
        99
    ];

    // Initialisation =======================================================================
    constructor() {
        Mob memory mob;
        mob.life = 3;
        mob.speed = 20;

        s_wave_to_ennemies[1].push(mob);
        // s_wave_to_ennemies[1].push(mob);
        i_total_waves = 1;
    }

    // Game engine ==========================================================================

    function _spawn_mobs(Game storage _state) private {
        uint256 tick = _state.tick;

        for (uint256 i = 0; i < _state.mobs_length; i++) {
            Mob memory mob = _state.mobs[i];
            if (mob.spawned) continue;
            if (tick >= mob.delay) {
                _state.mobs[i].spawned = true;
            }
        }
    }

    function _execute_mobs(Game storage _state) private {
        for (uint256 i = 0; i < _state.mobs_length; i++) {
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

    // function _abs(uint256 x) private pure returns (uint256) {
    //     return uint256(x >= 0 ? x : int256(-x));
    // }

    function _abs(int256 x) private pure returns (int256) {
        return x >= 0 ? x : -x;
    }

    function _manhattan(
        uint256 x1,
        uint256 x2,
        uint256 y1,
        uint256 y2
    ) private pure returns (uint256) {
        return
            uint256(_abs(int256(x2) - int256(x1))) +
            uint256(_abs(int256(y2) - int256(y1)));
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
        console.log('----[ Towers Tick ]----');
        for (
            uint256 tower_cell_index = 0;
            tower_cell_index < towers_cells.length;
            tower_cell_index++
        ) {
            uint256 tower_cell_id = towers_cells[tower_cell_index];
            console.log('==> Tower (%s)', tower_cell_id);
            // memory because the loop will rarely need to update it
            Tower memory tower = _state.towers[tower_cell_id];

            for (
                uint256 mob_index = 0;
                mob_index < _state.mobs_length;
                mob_index++
            ) {
                Mob storage mob = _state.mobs[mob_index];
                console.log(
                    '======> Found mob %s (%s%)',
                    mob.cell_id,
                    mob.steps
                );
                if (
                    !mob.spawned ||
                    mob.reached_goal ||
                    mob.life == 0 ||
                    !_is_in_range(mob.cell_id, tower_cell_id, tower.range)
                ) continue;
                console.log('======> mob alive and in range!');
                // if the tower couldown is ready
                if (tower.last_fired + tower.fire_rate <= tick) {
                    // taking from storage
                    _state.towers[tower_cell_id].last_fired = tick;
                    console.log('===> Tower firing!');
                    // if tower will kill the mob
                    if (mob.life <= tower.damage) {
                        console.log('======> Mob is dead');
                        mob.life = 0;
                        // if tower is not going to kill the mob
                    } else {
                        console.log('======> Mob is now %s/%s', mob.life, 3);
                        mob.life -= tower.damage;
                    }
                } else {
                    console.log('tower is reloading..');
                }
            }
        }
    }

    function _playing(Game storage _state) private view returns (bool) {
        // player lost
        if (_state.life == 0) return false;
        // for each mob
        for (uint256 i = 0; i < _state.mobs_length; i++) {
            Mob memory mob = _state.mobs[i];
            // if the mob isn't spawned
            // or if the mob is alive and didn't reached the goal
            if (!mob.spawned || (mob.life > 0 && !mob.reached_goal))
                return true;
        }
        return false;
    }

    function _load_wave(Game storage _state) private {
        Mob[] memory next_wave = s_wave_to_ennemies[_state.wave];
        for (uint256 i = 0; i < next_wave.length; i++) {
            _state.mobs[i] = next_wave[i];
            _state.mobs_length = next_wave.length;
        }
    }

    function _is_on_mob_path(uint256 _cell_id) private view returns (bool) {
        for (uint256 i = 0; i < MOB_PATH.length; i++) {
            if (MOB_PATH[i] == _cell_id) return true;
        }
        return false;
    }

    // Game calls ===========================================================================

    function new_game() external {
        Game storage game = s_game[msg.sender];
        game.wave = 1;
        game.life = 20;
        _load_wave(game);
    }

    function place_towers(uint256[] calldata _cell_ids) external {
        Game storage game = s_game[msg.sender];

        require(game.wave > 0, 'The game must be started');
        require(
            !game.wave_started,
            "Towers can't be placed after a wave is launched"
        );

        // TODO: introduce tower cost
        for (uint256 i = 0; i < _cell_ids.length; i++) {
            uint256 cell_id = _cell_ids[i];

            if (_is_on_mob_path(cell_id))
                revert("You can't place a tower on the ennemies path");

            Tower storage s_tower = game.towers[cell_id];

            s_tower.damage = 5;
            s_tower.range = 2;
            s_tower.fire_rate = 3;
            game.cells_with_towers.push(cell_id);
        }
    }

    function start_wave() external {
        Game storage game = s_game[msg.sender];

        require(!game.wave_started, 'You did not complete the previous wave');

        game.wave_started = true;

        bool playing = _playing(game);

        while (playing) {
            _spawn_mobs(game);
            _execute_towers(game);
            _execute_mobs(game);

            playing = _playing(game);
            game.tick++;
        }

        console.log(
            '================================\nTotal ticks: %s',
            game.tick
        );

        // done playing
        game.wave++;

        if (game.wave >= i_total_waves) {
            game.finished = true;
        } else {
            for (uint256 i = 0; i < game.mobs_length; i++) {
                delete game.mobs[i];
            }
            _load_wave(game);
        }

        emit wave_end(msg.sender, game.wave - 1, game.life > 0);
    }

    function get_mobs() external view returns (Mob[] memory) {
        uint256 mob_amount = s_game[msg.sender].mobs_length;
        Mob[] memory mobs = new Mob[](mob_amount);
        for (uint256 i = 0; i < mob_amount; i++) {
            mobs[i] = s_game[msg.sender].mobs[i];
        }

        return mobs;
    }

    function get_towers() external view returns (Tower[] memory) {
        Game storage state = s_game[msg.sender];
        uint256[] memory cells_ids = state.cells_with_towers;
        Tower[] memory towers = new Tower[](cells_ids.length);
        for (uint256 i = 0; i < cells_ids.length; i++) {
            towers[i] = state.towers[cells_ids[i]];
        }
        return towers;
    }
}
