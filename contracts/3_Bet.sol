// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/Strings.sol";

/** 
 * @title Bet
 * @dev Implements betting process including calculation of winnings
 */
contract Bet {
    string sportsMatch; // sportsMatch represents the sports match bet on
    uint vote;    // vote represents the prediction on the match (1 = win hometeam, 2 = loose hometeam, 3 = draw) 
    uint stake;   // stake represents the amount of coins bet

    // Commented - no use?
    // struct Betting {
    //    // If you can limit the length to a certain number of bytes, 
    //    // always use one of bytes1 to bytes32 because they are much cheaper
    //    bytes32 name;   // short name (up to 32 bytes)
    //    uint scenario; // number of accumulated votes
    // }

    event BetPlaced(address indexed better, uint choice, uint256 amount, string sportsMatch);
    event WinnerDeclared(address indexed winner, uint256 amount);
    event LoserDeclared(uint test);

    address public owner;
    uint public value;

    // Proposal[] public proposals;

    /** 
     * von ChatGPT
     */
    constructor() payable {
        owner = msg.sender;
        value = msg.value;
    }

    /** 
     * von ChatGPT
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function placeBet(uint game, uint choice) external payable {
        require(game != 0, "Game cannot be empty");
        require(value > 0, "Bet amount should be greater than 0");
        require(choice >= 0 || choice <= 2, "Invalid choice");

        sportsMatch = Strings.toString(game);
        vote = choice;

        emit BetPlaced(owner, choice, value, sportsMatch);

        // Geld an Wettplattform überweisen
    }

    function declareWinner() external onlyOwner {
        require(vote >= 0 || vote <= 2, "Invalid result");

        // has to come from API or something
        uint winningChoice = 2;
        //check if game is over
        require(winningChoice >= 0 || winningChoice <= 2, "Game is not over yet");

        
        stake = 2; //has to come from API
      

        // winning condition
        if (vote == winningChoice) {
            //multiply stake with betting amount
            uint256 totalAmount = value * stake;
            emit WinnerDeclared(owner, totalAmount);

            //paying the betting amount + stake(win) from betting plattform to the winner
            
        } 
        
        // loosing condition
        else {
            // "Sorry, you lost, better luck next time";
            emit LoserDeclared(0);
        }
    }

    // ChatGPT → keine Ahnung 
    // function random() internal view returns (uint256) {
    //     return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, blockhash(block.number - 1))));
    // }
   
    // Wette zurückziehen
    // function withdraw() external {
    //    uint256 amount = balances[msg.sender];
    //    require(amount > 0, "No winnings to withdraw");

    //    balances[msg.sender] = 0;
    //    payable(msg.sender).transfer(amount);
    //}
}