const DBOTCrowdsale = artifacts.require("../contracts/DBOTCrowdsale.sol");
const DBOT = artifacts.require("../contracts/DBOT.sol");
const { should, use } = require("chai");
const { expectRevert, expectEvent } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");

use(require("chai-bignumber")());

contract("DBOTCrowdsale", ([admin, investor, market, alice]) => {
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
      market,
      { from: admin }
    );
  });

  // whitelist checking.
  it("should be reverted if not whitelist", async () => {
    await expectRevert(
      instance.buyTokens(investor, {
        from: investor,
        value: web3.utils.toWei("1"),
      }),
      "WHITELIST: Beneficiary is not whitelisted!"
    );
  });

  //it should add into whitelist
  it("adding whitelist", async () => {
    // set into this investor whitelist mapping
    const whitelist = await instance.addSingleBeneficiary(alice, {
      from: admin,
    });
    //console.log(whitelist);
  });

  // check if user send maximum of 10 ETH.
  it("should be whitelist now and sent above than 10 ETH", async () => {
    // sent 10 ETH max.
    await expectRevert(
      instance.buyTokens(alice, {
        from: alice,
        value: web3.utils.toWei("11"),
      }),
      "PREVALIDATION: Invalid Amount"
    );
  });

  // now buy the tokens
  it("should be buy now", async () => {
    await expectEvent(
      instance.buyTokens(alice, {
        from: alice,
        value: web3.utils.toWei("1"),
      }),
      "TokenPurchase",
      {
        from: alice,
        to: instance.address,
        value: web3.utils.toWei("1"),
      }
    );
  });
});
