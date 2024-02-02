const Bets = artifacts.require("Bets")

contract("Bets", (accounts) => {

    it("creates a new bet", async () => {
        const bets = await Bets.deployed()
        const betTitle = "BTC will be 100k usd by the end of 2024"
        await bets.createBet(betTitle, { value: web3.utils.toWei("0.1", "ether") })
        const count = await bets.betsCount()
        assert.equal(count, 1)

        const createdBet = await bets.bets(1)
        assert.equal(createdBet.title, betTitle)
        assert.equal(createdBet.creator, accounts[0])
        assert.equal(createdBet.bettor, address(0))
    })

    it("try to join a bet with status PENDING_OPEN_VALIDATION", async () => {
        const bets = await Bets.deployed()
        await bets.createBet("BTC will be 100k usd by the end of 2024", { from: accounts[0], value: web3.utils.toWei("0.1", "ether") })
        try{
            await bets.joinBet(1, { from: accounts[1]})
            assert.fail("Transaction should have reverted");
        }catch (error) {
            assert.include(
                error.message,
                "Bet is not open for joining"
            );
        }
    })

    it("try to join their own bet", async () => {
        const bets = await Bets.deployed()
        await bets.createBet("BTC will be 100k usd by the end of 2024", { from: accounts[0], value: web3.utils.toWei("0.1", "ether") })
        try{
            await bets.joinBet(1, { from: accounts[0]})
            assert.fail("Transaction should have reverted");
        }catch (error) {
            assert.include(
                error.message,
                "Bet creator can't use this function"
            );
        }
    })
})
