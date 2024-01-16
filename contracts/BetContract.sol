// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//atm supports only 2 bettors betting against each other for the same amount of money (no sanity checks)
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

    //Oracles durchsuchen / API zum Ergebnisse abfragen (-> ChainLink DataFeed) => Niklas/Kujtim

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    //add a new game using a name (only by owner)
    function addGame(string memory _name, uint _betAmount) public onlyOwner {
        uint gameId = games.length;
        Game storage newGame = games.push();
        newGame.id = gameId;
        newGame.name = _name;
        newGame.betAmount = _betAmount;
    }

    //close existing game when it begins (only by owner)
    function closeBets(uint8 _gameId) public onlyOwner {
        games[_gameId].isOver = true;
    }

    //add winner to existing game (only by owner)
    function addGameWinner(uint8 _gameId, uint8 _winner) public onlyOwner {
        games[_gameId].winner = _winner;
    }

    //remove game (only owner) -> no good to delete items from map as keys are incremented with array length
    //function removeGame(uint8 _gameId) public onlyOwner {
    //    delete games[_gameId];
    //}

    //Todo: Make this function be only usable when not owner of contract
    function addBet(uint8 _gameId, uint8 _winPrediction) public payable {
        require(!games[_gameId].isOver, "Game is over - no bets allowed anymore");
        require(games[_gameId].bets[msg.sender].winPrediction == 0, "You already bet - no bets allowed anymore");
        require(msg.value == games[_gameId].betAmount, "Bet does not equal the specified bet amount for this game");

        // möglicherweise prüfen, ob Spieler = echter Spieler oder SC => nur echte Spieler 
        
        //add the bet to the game
        games[_gameId].bets[msg.sender] = Bet(msg.sender, _gameId, _winPrediction);
        games[_gameId].betCount++;
        if (_winPrediction == 1)  games[_gameId].counterTeamOne++;
        else if (_winPrediction == 2)  games[_gameId].counterTeamTwo++;
        else if (_winPrediction == 3)  games[_gameId].counterDraw++;
    }

    function collectWinnings(uint _gameId) public {
        require(games[_gameId].isOver, "Game is not yet over - Bets are still pending");
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

        //transfer money to the sender
        payable(msg.sender).transfer(winAmount);

        //what happens with the money on the contract if nobody wins or collects winnings ?
    }

}