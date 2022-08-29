// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Leaderboard {
    uint8 public immutable LENGTH;

    // address leaderboard
    mapping(uint8 => address) private _users;

    // address  to score
    mapping(address => uint256) private _scores;
    mapping(address => string) private _usernames;

    struct User {
        address user;
        uint256 score;
        string username;
    }

    constructor(uint8 _length) {
        LENGTH = _length;
    }

    function _score_of(uint8 _index) private view returns (uint256) {
        require(_index < LENGTH, 'requested leaderboard index is too high');
        return _scores[_users[_index]];
    }

    function set_username(string calldata _username) external {
        _usernames[msg.sender] = _username;
    }

    function get_leaderboard() external view returns (User[] memory) {
        User[] memory users = new User[](LENGTH);
        for (uint8 i = 0; i < LENGTH; i++) {
            address user_address = _users[i];
            users[i] = User(
                user_address,
                _scores[user_address],
                _usernames[user_address]
            );
        }
        return users;
    }

    function _leaderboard_push(address _user, uint256 _score) internal {
        // if user already has a biggest score
        if (_scores[_user] >= _score) return;
        // if the score is too low, don't update
        if (_score_of(LENGTH - 1) >= _score) return;
        // loop through the leaderboard
        for (uint8 i = 0; i < LENGTH; i++) {
            // find where to insert the new score
            if (_score_of(i) < _score) {
                // shift leaderboard
                address current_user = _users[i];
                if (current_user != _user) {
                    for (uint8 j = i + 1; j < LENGTH + 1; j++) {
                        address next_user = _users[j];
                        _users[j] = current_user;
                        if (next_user == _user) {
                            break;
                        }
                        current_user = next_user;
                    }
                }

                // insert
                _users[i] = _user;
                _scores[_user] = _score;

                // delete last from list
                address to_delete = _users[LENGTH];
                delete _scores[to_delete];
                delete _users[LENGTH];
                return;
            }
        }
    }
}
