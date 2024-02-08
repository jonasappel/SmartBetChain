// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BetContract {
    address public owner;
    Game[] public games;   //represents the games

    //represents 1 bet
    struct Bet {
        address user;
        uint gameId;
        uint8 winPrediction;
    }
    
    //represents the sports match bet on
    struct Game {
        uint id;   
        string name;    // e.g. "FCB - BVB"
        uint8 winner;    // 0 = Initial, 1 = Hometeam win, 2 = Guestteam win, 3 = Draw
        bool isOver;            //represents if bets can be placed
        uint betAmount;         //?Wetteinsatz festlegen
        uint counterTeamOne;    //counter for bets placed on team 1
        uint counterTeamTwo;    //counter for bets placed on team 2
        uint counterDraw;       //counter for bets placed on draw
        mapping(address => Bet) bets;     // Use a mapping for bets with userAddress => Bet
        uint betCount; // Track the number of bets for iteration
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    //Getter for count of games
    function getGamesCount() external view returns (uint) {
        return games.length;
    }

    //Getter for a single game using a gameId
    function getGame(uint _id) external view returns (uint, string memory, uint8, bool, uint, uint, uint, uint) {
        Game storage game = games[_id];
        return (game.id, game.name, game.winner, game.isOver, game.betAmount, game.counterTeamOne, game.counterTeamTwo, game.counterDraw);
    }

    //Getter for count of bets using a gameId
    function getBetCount(uint gameId) external view returns (uint) {
        return games[gameId].betCount;
    }

    //Getter for a single bet using a gameId and a bettorAdress
    function getBet(uint gameId, address bettorAdress) external view returns (Bet memory) {
        return games[gameId].bets[bettorAdress];
    }


    //add a new game using a name and the betAmount (only by owner)
    function addGame(string memory _name, uint _betAmount) public onlyOwner {
        uint gameId = games.length;
        Game storage newGame = games.push();
        newGame.id = gameId;
        newGame.name = _name;
        newGame.betAmount = _betAmount*1000000000000000000;
    }

    //add a bet for a game using a gameId and winPrediction
    function addBet(uint8 _gameId, uint8 _winPrediction) public payable {
        require(!games[_gameId].isOver, "Game is over - no bets allowed anymore");
        require(games[_gameId].bets[msg.sender].winPrediction == 0, "You already bet - no bets allowed anymore");
        require(msg.value == games[_gameId].betAmount, "Bet does not equal the specified bet amount for this game");
        
        //add the bet to the game
        games[_gameId].bets[msg.sender] = Bet(msg.sender, _gameId, _winPrediction);
        games[_gameId].betCount++;
        if (_winPrediction == 1)  games[_gameId].counterTeamOne++;
        if (_winPrediction == 2)  games[_gameId].counterTeamTwo++;
        if (_winPrediction == 3)  games[_gameId].counterDraw++;
    }

    //close existing game when it begins (only by owner)
    function closeBets(uint8 _gameId) public onlyOwner {
        games[_gameId].isOver = true;
    }

    //add winner to existing closed game (only by owner)
    function addGameWinner(uint8 _gameId, uint8 _winner) public onlyOwner {
        require(games[_gameId].isOver, "Game is not yet over - Bets are still pending");

        games[_gameId].winner = _winner;
    }

    //collect the winnings using a gameId
    function collectWinnings(uint _gameId) public payable {
        require(games[_gameId].winner != 0, "Winner not yet stated by contract owner");
        require(games[_gameId].bets[msg.sender].winPrediction == games[_gameId].winner, "Sorry - you lost the bet");

        uint winAmount;

        if(games[_gameId].winner == 1) {
            winAmount = (games[_gameId].betCount*games[_gameId].betAmount)/games[_gameId].counterTeamOne;
        }
        else if(games[_gameId].winner == 2) {
            winAmount = (games[_gameId].betCount*games[_gameId].betAmount)/games[_gameId].counterTeamTwo;
        }
        else if(games[_gameId].winner == 3) {
            winAmount = (games[_gameId].betCount*games[_gameId].betAmount)/games[_gameId].counterDraw;
        }

        //transfer money to the calling sender 
        payable(msg.sender).transfer(winAmount);
    }

}
