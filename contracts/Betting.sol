// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Betting {
    uint256 public minimumBet;
    uint256 public totalBetOne;
    uint256 public totalBetTwo;
    uint256 public numberOfBets;

    address payable[] public players;

    struct Player {
        uint256 amountBet;
        uint16 teamSelected;
    }

    // Address of the player and => the user info   
    mapping(address => Player) public playerInfo;

    constructor() {
        minimumBet = 1; //represents 1 Won
    }

    //Check if Player has already bet
    function checkPlayerExists(address player) public view returns(bool){
        for(uint256 i = 0; i < players.length; i++){
            if(players[i] == player) return true;
        }
        return false;
    }

    function bet(uint8 _teamSelected) public payable {
        //check if the player already exist
        require(!checkPlayerExists(msg.sender));
        //check if minimumBetSizeReached
        require(msg.value >= minimumBet);
      
        //set the player information: amount of the bet and selected team
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].teamSelected = _teamSelected;
      
        //add the player to the players array
        // players.push(msg.sender);
      
        //increment the stakes of the team selected with the player bet
        if ( _teamSelected == 1){
            totalBetOne += msg.value;
        }
        else {
            totalBetTwo += msg.value;
        }
   }

}