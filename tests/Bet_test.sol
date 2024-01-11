// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "hardhat/console.sol";
import "../contracts/3_Bet.sol";

contract BetTest {

    bytes32[] proposalNames;

    Bet betToTest;
    function beforeAll () public {
        proposalNames.push(bytes32("candidate1"));
        betToTest = new Bet(proposalNames);
    }

    function checkWinningProposal () public {
        console.log("Running checkWinningProposal");
        betToTest.vote(0);
        Assert.equal(betToTest.winningProposal(), uint(0), "proposal at index 0 should be the winning proposal");
        Assert.equal(betToTest.winnerName(), bytes32("candidate1"), "candidate1 should be the winner name");
    }

    function checkWinninProposalWithReturnValue () public view returns (bool) {
        return betToTest.winningProposal() == 0;
    }
}