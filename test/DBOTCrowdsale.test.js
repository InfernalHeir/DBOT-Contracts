const DBOTCrowdsale = artifacts.require("../contracts/DBOTCrowdsale.sol");
const DBOT = artifacts.require("../contracts/DBOT.sol");
const { should, use } = require("chai");
const { expectRevert } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");

use(require("chai-bignumber"));

contract("DBOTCrowdsale", ([admin, investor]) => {
  let instance;
  let dbot;
  beforeEach(async () => {
    // let fill the some information in contructor of DBOTCrowdsale.
    const rate = 1500;
    const totalSupply = web3.utils.toWei("11000000");

    // set the soft cap
    const softCap = web3.utils.toWei("250");
    // set the hard cap
    const hardCap = web3.utils.toWei("500");
    // set the maximum InvestorCap
    const investorCap = web3.utils.toWei("10");
    dbot = await DBOT.new("DBOT Token", "DBOT", totalSupply);
    instance = await DBOTCrowdsale.new(
      rate,
      admin,
      dbot.address,
      softCap,
      hardCap,
      investorCap,
      { from: admin }
    );
  });
  it("should be reverted if not whitelist", async () => {
    await expectRevert(
      instance.buyTokens(investor, {
        from: investor,
        value: web3.utils.toWei("1"),
      }),
      "Investor do not whitlist yet."
    );
  });
});
