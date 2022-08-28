// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract Paper_defense {
    // Structures ===========================================================================

    struct Tower {
        uint256 damage;
        uint256 range;
        uint256 fire_rate;
        uint256 last_fired;
    }

    struct Mob {
        bool exists;
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
        // no more waves
        bool finished;
        uint256 tick;
        // all cells containing a tower
        uint256[] cells_with_towers;
        // cell id to tower
        mapping(uint256 => Tower) towers;
        // mob index to mob (kinda hack to have an array in a mapping)
        mapping(uint256 => Mob) mobs;
    }

    event wave_end(address player, uint256 wave, bool won);

    // Storage ==============================================================================

    uint256 public constant MAP_WIDTH = 10;
    uint256 public constant MAP_HEIGHT = 10;
    uint256 public constant MAX_WAVES = 20;

    uint256 public constant MOB_BASE_LIFE = 3;
    uint256 public constant MOB_BASE_SPEED = 15;
    uint256 public constant MOB_BASE_AMOUNT = 10;
    uint256 public constant MOB_BASE_DAMAGE = 1;

    uint256 public constant MOB_LIFE_MODIFIER = 161;
    uint256 public constant MOB_AMOUNT_MODIFIER = 119;
    uint256 public constant MOB_SPEED_MODIFIER = 116;

    uint256 public immutable DEPLOY_TIMESTAMP;

    // player to Game
    mapping(address => Game) public s_game;
    // player to highscore
    mapping(address => uint256) public s_score;
    uint256 public total_score;

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
        DEPLOY_TIMESTAMP = block.timestamp;
    }

    // Game engine ==========================================================================

    function _curve(
        uint256 base,
        uint256 mod,
        uint256 wave
    ) private pure returns (uint256) {
        return (base * 100 * mod**wave) / 100**(wave + 1);
    }

    function _create_mob(uint256 wave) private pure returns (Mob memory mob) {
        mob.life = _curve(MOB_BASE_LIFE, MOB_LIFE_MODIFIER, wave);
        mob.speed = _curve(MOB_BASE_SPEED, MOB_SPEED_MODIFIER, wave);
        mob.damage = MOB_BASE_DAMAGE;
        mob.target_cell_index = 1;
    }

    function _create_tower(
        uint256 _tower_damage,
        uint256 _range,
        uint256 _fire_rate
    ) private pure returns (Tower memory tower) {
        tower.damage = _tower_damage;
        tower.range = _range;
        tower.fire_rate = _fire_rate;
    }

    function _execute_mobs(Game storage _state, uint256 _mobs_amount) private {
        for (uint256 i = 0; i < _mobs_amount; i++) {
            Mob storage mob = _state.mobs[i];

            if (mob.life == 0 || mob.reached_goal) continue;
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

                    if (_state.life - mob.damage <= 0) {
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

    function _abs(int256 x) private pure returns (int256) {
        return x >= 0 ? x : -x;
    }

    // will later be a call to the NFT contract
    // this represent a deterministic value
    // because USD value can be manipulated and change over time
    function _tower_value() private pure returns (uint256) {
        return 100;
    }

    function _compute_score() private view returns (uint256) {
        uint256 tower_amount = s_game[msg.sender].cells_with_towers.length;
        // define the cost of each tower later
        // (with type and upgrades)
        uint256 total_tower_cost = tower_amount * _tower_value();
        uint256 days_spent = (block.timestamp - DEPLOY_TIMESTAMP) / 1 days;
        uint256 score = total_tower_cost *
            s_game[msg.sender].life *
            s_game[msg.sender].wave;

        if (score < days_spent) return 0;
        return score - days_spent;
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

    function _execute_towers(Game storage _state, uint256 _mobs_count) private {
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

            for (uint256 mob_index = 0; mob_index < _mobs_count; mob_index++) {
                Mob storage mob = _state.mobs[mob_index];
                if (
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
                    } else {
                        // if tower is not going to kill the mob
                        mob.life -= tower.damage;
                    }
                }
            }
        }
    }

    function _playing(Game storage _state, uint256 _mobs_amount)
        private
        view
        returns (bool)
    {
        // player lost
        if (_state.life == 0) return false;
        // for each mob
        for (uint256 i = 0; i < _mobs_amount; i++) {
            Mob memory mob = _state.mobs[i];
            // if the mob is alive and didn't reached the goal
            if (mob.life > 0 && !mob.reached_goal) return true;
        }
        return false;
    }

    function _is_on_mob_path(uint256 _cell_id) private view returns (bool) {
        for (uint256 i = 0; i < MOB_PATH.length; i++) {
            if (MOB_PATH[i] == _cell_id) return true;
        }
        return false;
    }

    // Game calls ===========================================================================

    function new_game() external {
        delete s_game[msg.sender];
        Game storage game = s_game[msg.sender];
        game.wave = 1;
        game.life = 20;
    }

    function place_towers(
        uint256[] calldata _cell_ids,
        uint256 _damage,
        uint256 _range,
        uint256 _fire_rate
    ) external {
        Game storage game = s_game[msg.sender];

        require(game.wave > 0, 'The game must be started');

        for (uint256 i = 0; i < _cell_ids.length; i++) {
            uint256 cell_id = _cell_ids[i];

            if (_is_on_mob_path(cell_id))
                revert("You can't place a tower on the ennemies path");

            game.towers[cell_id] = _create_tower(_damage, _range, _fire_rate);
            game.cells_with_towers.push(cell_id);
        }
    }

    function start_wave() external {
        Game storage game = s_game[msg.sender];

        require(!game.finished, 'There is no more waves');

        uint256 current_wave = game.wave;
        uint256 mobs_amount = _curve(
            MOB_BASE_AMOUNT,
            MOB_AMOUNT_MODIFIER,
            game.wave
        );
        uint256 mobs_spawned = 0;
        bool playing;
        
        while (playing || mobs_spawned < mobs_amount) {
            if (mobs_spawned < mobs_amount) {
                game.mobs[mobs_spawned++] = _create_mob(current_wave);
            }
            _execute_towers(game, mobs_spawned);
            _execute_mobs(game, mobs_spawned);

            playing = _playing(game, mobs_spawned);
            game.tick++;
        }

        // console.log(
        //     string.concat(
        //         'wave: ',
        //         Strings.toString(game.wave),
        //         ', ticks: ',
        //         Strings.toString(game.tick),
        //         ' | count: %s, life: %s, speed: %s'
        //     ),
        //     mobs_amount,
        //     _curve(MOB_BASE_LIFE, MOB_LIFE_MODIFIER, current_wave),
        //     _curve(MOB_BASE_SPEED, MOB_SPEED_MODIFIER, current_wave)
        // );

        // done playing
        bool won_the_wave = game.life > 0;

        if (won_the_wave) {
            // increase score
            uint256 wave_score = _compute_score();
            s_score[msg.sender] += wave_score;
            total_score += wave_score;

            // increase wave
            game.wave++;
        }

        if (game.wave > MAX_WAVES) {
            game.finished = true;
        }

        emit wave_end(msg.sender, current_wave, won_the_wave);
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
