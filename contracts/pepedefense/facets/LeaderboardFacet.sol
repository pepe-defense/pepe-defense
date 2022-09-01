// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {State, Leaderboard} from '../libraries/LibState.sol';

contract LeaderboardFacet {
    State private state;

    struct LadderUser {
        address user;
        uint256 score;
        string username;
    }

    function leaderboard_set_username(string calldata _username) public {
        state.leaderboard.usernames[msg.sender] = _username;
    }

    function leaderboard_view() internal view returns (LadderUser[] memory) {
        Leaderboard storage leaderboard = state.leaderboard;
        LadderUser[] memory users = new LadderUser[](leaderboard.LENGTH);
        for (uint8 i = 0; i < leaderboard.LENGTH; i++) {
            address user_address = leaderboard.users[i];
            users[i] = LadderUser(
                user_address,
                leaderboard.high_scores[user_address],
                leaderboard.usernames[user_address]
            );
        }
        return users;
    }
}
