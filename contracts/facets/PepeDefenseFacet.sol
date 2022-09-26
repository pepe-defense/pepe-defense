// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
/**
 ⠀⠀⢀⣠⠤⠶⠖⠒⠒⠶⠦⠤⣄⠀⠀⠀⣀⡤⠤⠤⠤⠤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⣦⠞⠁⠀⠀⠀⠀⠀⠀⠉⠳⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡾⠁⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⣘⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⡴⠚⠉⠁⠀⠀⠀⠀⠈⠉⠙⠲⣄⣤⠤⠶⠒⠒⠲⠦⢤⣜⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⡄⠀⠀⠀⠀⠀⠀⠀⠉⠳⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⠹⣆⠀⠀⠀⠀⠀⠀⣀⣀⣀⣹⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⠞⣉⣡⠤⠴⠿⠗⠳⠶⣬⣙⠓⢦⡈⠙⢿⡀⠀⠀⢀⣼⣿⣿⣿⣿⣿⡿⣷⣤⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣾⣡⠞⣁⣀⣀⣀⣠⣤⣤⣤⣄⣭⣷⣦⣽⣦⡀⢻⡄⠰⢟⣥⣾⣿⣏⣉⡙⠓⢦⣻⠃⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠉⠉⠙⠻⢤⣄⣼⣿⣽⣿⠟⠻⣿⠄⠀⠀⢻⡝⢿⡇⣠⣿⣿⣻⣿⠿⣿⡉⠓⠮⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠙⢦⡈⠛⠿⣾⣿⣶⣾⡿⠀⠀⠀⢀⣳⣘⢻⣇⣿⣿⣽⣿⣶⣾⠃⣀⡴⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠙⠲⠤⢄⣈⣉⣙⣓⣒⣒⣚⣉⣥⠟⠀⢯⣉⡉⠉⠉⠛⢉⣉⣡⡾⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣠⣤⡤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⡿⠋⠀⠀⠀⠀⠈⠻⣍⠉⠀⠺⠿⠋⠙⣦⠀⠀⠀⠀⠀⠀⠀
⠀⣀⣥⣤⠴⠆⠀⠀⠀⠀⠀⠀⠀⣀⣠⠤⠖⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⠀⠀⠀⠀⠀⢸⣧⠀⠀⠀⠀⠀⠀
⠸⢫⡟⠙⣛⠲⠤⣄⣀⣀⠀⠈⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠏⣨⠇⠀⠀⠀⠀⠀
⠀⠀⠻⢦⣈⠓⠶⠤⣄⣉⠉⠉⠛⠒⠲⠦⠤⠤⣤⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣠⠴⢋⡴⠋⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠉⠓⠦⣄⡀⠈⠙⠓⠒⠶⠶⠶⠶⠤⣤⣀⣀⣀⣀⣀⣉⣉⣉⣉⣉⣀⣠⠴⠋⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠉⠓⠦⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠙⠛⠒⠒⠒⠒⠒⠤⠤⠤⠒⠒⠒⠒⠒⠒⠚⢉⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠴⠚⠛⠳⣤⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠚⠁⠀⠀⠀⠀⠘⠲⣄⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⠋⠙⢷⡋⢙⡇⢀⡴⢒⡿⢶⣄⡴⠀⠙⠳⣄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢦⡀⠈⠛⢻⠛⢉⡴⣋⡴⠟⠁⠀⠀⠀⠀⠈⢧⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⠀⠘⣶⢋⡞⠁⠀⠀⢀⡴⠂⠀⠀⠀⠀⠹⣄⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠈⠻⢦⡀⠀⣰⠏⠀⠀⢀⡴⠃⢀⡄⠙⣆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡾⢷⡄⠀⠀⠀⠀⠉⠙⠯⠀⠀⡴⠋⠀⢠⠟⠀⠀⢹⡄
 */
import {LibLeaderboard} from '../libraries/LibLeaderboard.sol';
import {LibState, LibState, State, Game, Mob, Tower, Tower, Leaderboard, Position, Position} from '../libraries/LibState.sol';
import {LibMath} from '../libraries/LibMath.sol';
import {LibGame} from '../libraries/LibGame.sol';
import {MOB_BASE_AMOUNT, MOB_AMOUNT_MODIFIER, MAX_WAVES, MAP_WIDTH, MAP_WIDTH} from '../Constants.sol';

contract PepeDefenseFacet {
    using LibState for State;
    using LibState for State;
    using LibLeaderboard for Leaderboard;
    using LibGame for Game;

    State internal s;

    event game_created(address player, uint8 wave, uint8 life);
    event wave_start(
        address player,
        uint8 wave,
        Mob[] mobs,
        Tower[] towers,
        uint8 life,
        uint256 tick
    );
    event wave_end(address player, uint8 wave, bool won);

    /***********************************|
   |         Write Functions        |
   |__________________________________*/

    function new_game() external {
        delete s.games[msg.sender];
        Game storage game = s.games[msg.sender];
        game.wave = 1;
        game.life = 10;
        emit game_created(msg.sender, game.wave, game.life);
    }

    function set_towers(Tower[] calldata _towers)
        external
        game_started
        not_dead
    {
        Game storage game = s.games[msg.sender];
        game.tower_amount = 0;

        for (uint8 i = 0; i < _towers.length; i++) {
            Tower calldata tower = _towers[i];
            require(s.TOWER_CELLS[tower.cell_id], "Can't place a tower here");
            delete game.towers[i];
            game.towers[game.tower_amount++] = tower;
        }
    }

    function start_wave() external game_started not_last_wave not_dead {
        Game storage game = s.games[msg.sender];

        uint256[] memory MOB_PATH = s.MOB_PATH;
        uint8 current_wave = game.wave;
        uint256 mobs_amount = LibMath.curve(
            MOB_BASE_AMOUNT,
            MOB_AMOUNT_MODIFIER,
            current_wave
        );
        uint256 mobs_spawned = 0;
        uint8 life_remaining = game.life;
        uint256 tick = game.total_tick;
        uint256 tower_amount = game.tower_amount;

        Mob[] memory mobs = new Mob[](mobs_amount);
        Tower[] memory towers = new Tower[](tower_amount);

        emit wave_start(
            msg.sender,
            current_wave,
            mobs,
            towers,
            life_remaining,
            tick
        );

        // initialize towers in memory
        for (uint256 i = 0; i < tower_amount; ) {
            towers[i] = game.towers[i];
            unchecked {
                i++;
            }
        }

        do {
            if (mobs_spawned < mobs_amount) {
                mobs[mobs_spawned] = LibGame.generate_mob(current_wave);
                unchecked {
                    mobs_spawned++;
                }
            }
            LibGame.compute_towers(towers, mobs, mobs_spawned, tick);
            life_remaining = LibGame.compute_mobs(
                mobs,
                mobs_spawned,
                MOB_PATH,
                life_remaining
            );
            unchecked {
                tick++;
            }
        } while (
            LibGame.wave_in_progress(
                mobs,
                mobs_spawned,
                mobs_amount,
                life_remaining
            )
        );

        // done playing
        bool won_the_wave = life_remaining > 0;

        if (won_the_wave) {
            // increase score
            uint256 wave_score = LibGame.compute_score(
                towers,
                life_remaining,
                current_wave,
                tick
            );

            unchecked {
                game.score += wave_score;
            }

            s.leaderboard().save(msg.sender, game.score);

            // increase wave
            unchecked {
                game.wave++;
            }
        }

        if (game.wave >= MAX_WAVES) {
            game.finished = true;
        }

        game.life = life_remaining;
        game.total_tick = tick;

        game.life = life_remaining;
        game.total_tick = tick;

        emit wave_end(msg.sender, current_wave, won_the_wave);
    }

    /***********************************|
   |            Modifiers           |
   |__________________________________*/

    modifier game_started() {
        require(s.games[msg.sender].wave > 0, 'The game must be started');
        _;
    }

    modifier not_dead() {
        require(s.games[msg.sender].life > 0, 'The game is over');
        _;
    }

    modifier not_last_wave() {
        require(s.games[msg.sender].wave < MAX_WAVES, 'There is no more waves');
        _;
    }
}
