// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identidier: MIT

pragma solidity ^0.8.19;

contract Raffle {

    error Raffle__SendMoreToEnterRaffle();
    error Raffle__TransferFailed();

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint256 immutable i_entranceFee;
    address payable[] private s_players;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed player);

    constructor(
        uint256 entranceFee
    ){
        i_entranceFee = entranceFee;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        if(s_raffleState != RaffleState.OPEN) {
            revert();
        }
        s_players.push(payable(msg.sender));

        emit RaffleEnter(msg.sender);
    }

    function pickWinner(uint256 index) external {
        address payable recentWinner = s_players[index];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        emit WinnerPicked(recentWinner);

        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }
    }


}