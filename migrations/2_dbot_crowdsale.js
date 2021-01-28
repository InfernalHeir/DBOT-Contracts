const DBOTCrowdsale = artifacts.require("DBOTCrowdsale.sol");
const DBOT = artifacts.require("DBOT");

module.exports = async (deployer, network, [owner, multisig]) => {
  // deploy dbot first
  const name = "DBOT Token";
  const symbol = "DBOT";
  const totalSupply = web3.utils.toWei("1100000");
  // deploy dbot here
  const dbot = await DBOT.new(name, symbol, totalSupply, {
    from: owner,
  });
  const rate = web3.utils.toWei("1500");

  // softcap and hardcap
  const softcap = web3.utils.toWei("250");
  const hardcap = web3.utils.toWei("500");

  // investor max cap
  const investorCap = web3.utils.toWei("10");
  //console.log(multisig);
  await deployer.deploy(
    DBOTCrowdsale,
    rate,
    multisig,
    dbot.address,
    softcap,
    hardcap,
    investorCap,
    owner,
    { from: owner }
  );
  // migration will exit here
};
