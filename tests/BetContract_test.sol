// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol";
import "../contracts/BetContract.sol";

/**
 * @title ContractName
 * @dev ContractDescription
 * @custom:dev-run-script scripts/deploy_with_ethers.ts
 */
contract BetContractTest {
    BetContract public betContract;
    BetContract.Game public game;
    BetContract.Bet public bet;

    string testGameName = "TestGame";
    uint256 testBetAmount = 10;

    constructor() payable {}

    function beforeAll() public {
        betContract = new BetContract();
    }

    function checkOwner() public {
        address contractOwner = betContract.owner();
        address expectedOwner = address(this);

        Assert.equal(contractOwner, expectedOwner, "Owner should be the deployer of the contract");
    }

    function checkAddGame() public {
        betContract.addGame(testGameName, testBetAmount);

        Assert.equal(betContract.getGamesCount(), 1, "Game size should be 1");

        (uint256 id, string memory name, uint8 winner, bool isOver, uint256 betAmount, uint256 counterTeamOne, uint256 counterTeamTwo, uint256 counterDraw) = betContract.getGame(0);

        Assert.equal(id, 0, "Game ID should be 0");
        Assert.equal(name, testGameName, "Game name should match");
        Assert.equal(betAmount, testBetAmount, "Bet amount should match");
    }

    function checkAddBet() public payable {
        betContract.addBet{value: testBetAmount}(0, 1);

        (uint256 id, string memory name, uint8 winner, bool isOver, uint256 betAmount, uint256 counterTeamOne, uint256 counterTeamTwo, uint256 counterDraw) = betContract.getGame(0);

        Assert.equal(betContract.getBetCount(0), 1, "betCount should be 1");
        Assert.equal(counterTeamOne, 1, "counterTeamOne should be 1");
    }

    function checkCloseBets() public {
        betContract.closeBets(0);

        (uint256 id, string memory name, uint8 winner, bool isOver, uint256 betAmount, uint256 counterTeamOne, uint256 counterTeamTwo, uint256 counterDraw) = betContract.getGame(0);

        Assert.equal(isOver, true, "Game should be closed");
    }

    function checkAddGameWinner() public {
        betContract.addGameWinner(0, 1);

        (uint256 id, string memory name, uint8 winner, bool isOver, uint256 betAmount, uint256 counterTeamOne, uint256 counterTeamTwo, uint256 counterDraw) = betContract.getGame(0);

        Assert.equal(winner, 1, "Winner should be set to 1");
    }

    function checkCollectWinnings() public payable {
        uint balanceBefore = address(this).balance;

        betContract.collectWinnings(0);

        Assert.greaterThan(address(this).balance, balanceBefore, "Balance should be greater than before");
    }
}
