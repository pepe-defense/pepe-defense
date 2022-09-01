// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {State} from './libraries/LibState.sol';
import {MAX_WAVES} from './Constants.sol';

contract Modifiers {
    State private s;

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
