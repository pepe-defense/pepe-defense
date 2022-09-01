// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library LibDistance {
    function _get_position(uint256 _id, uint256 _width)
        private
        pure
        returns (uint256 x, uint256 y)
    {
        x = _id / _width;
        y = _id % _width;
    }

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

    function is_in_range(
        uint256 _mob_cell_id,
        uint256 _tower_cell_id,
        uint256 _range,
        uint256 _width
    ) internal pure returns (bool) {
        (uint256 mob_x, uint256 mob_y) = _get_position(_mob_cell_id, _width);
        (uint256 tower_x, uint256 tower_y) = _get_position(
            _tower_cell_id,
            _width
        );
        return _manhattan(mob_x, tower_x, mob_y, tower_y) <= _range;
    }
}
