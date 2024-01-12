// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//atm supports only 2 bettors betting against each other for the same amount of money (no sanity checks)
contract BetContract {
    address public owner;
    uint allBets = 0; //store all bets combined 

    //represents the sports match bet on
    struct Game {   
        string name;    // e.g. "FCB - BVB"
        uint8 winner;    // 0 = Pending, 1 = Hometeam win, 2 = Guestteam win, 3 = Draw
    }

    //TODO: make this an array to store more games
    Game public game;   //represents the game

    //represents 1 bet
    struct Bet {
        address user;
        // Game game;
        uint8 winPrediction;
        uint amount;
    }

    Bet[] public bets;     //represents all bets

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    //add a game using a name (only by owner)
    function addGame(string memory _name) public onlyOwner {
        game = Game(_name, 0);
    }

    //add winner to existing game (only by owner)
    function addGameWinner(uint8 _winner) public onlyOwner {
        game.winner = _winner;
    }

    //make this functional ????
    function removeGame() public onlyOwner {
        delete game;
    }

    //Todo: Make this function be only usable when not owner of contract
    function addBet(uint8 _winPrediction) public payable {
        require(game.winner == 0, "Winner is already stated");
        //sanity checks (bettor already bet?, has different WinCondition?)

        allBets += msg.value;

        bets.push(Bet(msg.sender, _winPrediction, msg.value));
    }

    //Todo: Pay the SC Value to the Winner
    function declareWinner() public payable onlyOwner {
        require(game.winner != 0, "Winner is not yet stated");

        // transfer money to the 1 winner of the bet
        for (uint i = 0; i < bets.length; i++) {
            Bet memory bet = bets[i];
            if (bet.winPrediction == game.winner) {
                payable(bet.user).transfer(allBets);
            }
        }
    }

}