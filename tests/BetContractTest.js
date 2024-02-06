const BetContract = artifacts.require("BetContract");

contract("BetContract", (accounts) => {
    let betContract;
    const owner = accounts[0];
    const bettor1 = accounts[1];
    const bettor2 = accounts[2];

    beforeEach(async () => {
        betContract = await BetContract.new({ from: owner });
    });

    it("should allow the owner to add a new game", async () => {
        const gameName = "FCB - BVB";
        const betAmount = web3.utils.toWei("0.1", "ether");

        await betContract.addGame(gameName, betAmount, { from: owner });

        const game = await betContract.games(0);
        assert.equal(game.name, gameName);
        assert.equal(game.betAmount, betAmount);
    });

    it("should allow the owner to close bets for a specific game", async () => {
        await betContract.addGame("FCB - BVB", web3.utils.toWei("0.1", "ether"), { from: owner });

        await betContract.closeBets(0, { from: owner });

        const game = await betContract.games(0);
        assert.equal(game.isOver, true);
    });

    it("should allow the owner to set the winner for a specific game", async () => {
        await betContract.addGame("FCB - BVB", web3.utils.toWei("0.1", "ether"), { from: owner });

        await betContract.addGameWinner(0, 1, { from: owner });

        const game = await betContract.games(0);
        assert.equal(game.winner, 1);
    });

    it("should allow users to place bets on a specific game", async () => {
        const betAmount = web3.utils.toWei("0.1", "ether");
        await betContract.addGame("FCB - BVB", betAmount, { from: owner });

        await betContract.addBet(0, 1, { from: bettor1, value: betAmount });

        const bet = await betContract.games(0).bets(bettor1);
        assert.equal(bet.winPrediction, 1);
    });

    it("should allow users to collect winnings after the game has concluded", async () => {
        const betAmount = web3.utils.toWei("0.1", "ether");
        await betContract.addGame("FCB - BVB", betAmount, { from: owner });
        await betContract.addGameWinner(0, 1, { from: owner });

        await betContract.addBet(0, 1, { from: bettor1, value: betAmount });
        await betContract.addBet(0, 2, { from: bettor2, value: betAmount });
        const initialBalance = await web3.eth.getBalance(bettor1);

        await betContract.collectWinnings(0, { from: bettor1 });

        const finalBalance = await web3.eth.getBalance(bettor1);
        assert.isAbove(Number(finalBalance), Number(initialBalance));
    });
});