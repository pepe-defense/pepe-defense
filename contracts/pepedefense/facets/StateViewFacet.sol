// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {State, Game, Tower} from '../libraries/LibState.sol';

contract StateViewFacet {
    State private s;

    /***********************************|
   |         Read Functions         |
   |__________________________________*/

    function get_towers()
        external
        view
        returns (uint8[] memory, Tower[] memory)
    {
        Game storage game = s.games[msg.sender];
        uint8[] memory towers_cells = game.cells_with_towers;
        Tower[] memory towers = new Tower[](towers_cells.length);
        for (uint8 i = 0; i < towers_cells.length; i++) {
            towers[i] = game.towers[towers_cells[i]];
        }
        return (towers_cells, towers);
    }
}
