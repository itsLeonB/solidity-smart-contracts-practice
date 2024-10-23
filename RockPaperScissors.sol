// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title RockPaperScissors
 * @dev Implements the rock paper scissors game
 */
contract RockPaperScissors {
    enum Move {Null, Rock, Paper, Scissor}

    mapping (address => Move) player_moves;
    address[] public players;
    address public winner;

    function register() public {
        require(
            players.length < 2,
            "Maximum players are 2."
        );
        require(
            !exists(msg.sender),
            "Player already registered."
        );
        players.push(msg.sender);
    }

    function makeMove(uint move) public {
        require(
            move > 0 && move < 4,
            "Invalid move."
        );
        require(
            exists(msg.sender),
            "Player is not registered."
        );
        require(
            player_moves[msg.sender] == Move.Null,
            "Player already made move."
        );
        Move selectedMove;
        if (move == 1) {
            selectedMove = Move.Rock;
        } else if (move == 2) {
            selectedMove = Move.Paper;
        } else {
            selectedMove = Move.Scissor;
        }
        player_moves[msg.sender] = selectedMove;

        if (validateMoves()) {
            checkWinner();
        }
    }

    function checkWinner() public returns (address, bool) {
        require(
            players.length == 2,
            "Not enough players."
        );
        require(
            validateMoves(),
            "Players have not made move."
        );
        Move first = player_moves[players[0]];
        Move second = player_moves[players[1]];

        if (first == second) {
            return (winner, false);
        }
        if (
            (first == Move.Rock && second == Move.Scissor)
            || (first == Move.Paper && second == Move.Rock)
            || (first == Move.Scissor && second == Move.Paper)
            ) {
                winner = players[0];
            } else {
                winner = players[1];
            }

        return (winner, true);
    }

    // function printWinner() public {
    //     console.log();
    // }

    function exists(address _wallet) view public returns (bool){
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == _wallet) {
                return true;
            }
        }
        return false;
    }

    function validateMoves() view public returns (bool) {
        for (uint i = 0; i < players.length; i++) {
            if (player_moves[players[i]] == Move.Null) {
                return false;
            }
            return true;
        }
    }
}