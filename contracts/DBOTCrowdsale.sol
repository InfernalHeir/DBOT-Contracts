// SPDX-License-Identifier: MIT;
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./cap/CappedCrowdsale.sol";
import "./validation/Whitelist.sol";
import "./interfaces/IUniswapRouter02.sol";
import "./DBOT.sol";

contract DBOTCrowdsale is CappedCrowdsale,Whitelist {

 // set library are you using.
 using SafeERC20 for DBOT;      
 using SafeMath for uint256;

 // set Contract Instance
 DBOT public dbot;

 // address where funds collected
 address payable public wallet;

 // set rate 1 ETH = 1500 dbot
 uint256 public rate;

 // weiRaised in Crowdsale
 uint256 public weiRaised;

 // investorMaxCap for maximum contribution
 uint256 public investorMaxCap;

 // mapping for contributors
 mapping (address => uint256) contributors;   

 // called when hardCap got reached.
 bool public hasClosed;

 // market address
 address public marketAddress;

 // event for TokenPurchase
 event TokenPurchase(
     address indexed _purchaseHodl,
     address indexed _beneficiary,
     uint256 _ethValue,
     uint256 _tokens
 );

 // call the constructor for initial crowdsale

 constructor(
    uint256 _rate,
    address payable _wallet,
    address _dbot,
    uint256 _softCap,
    uint256 _hardCap,
    uint256 _investorMaxCap,
    address _marketAddress
 ) CappedCrowdsale(_softCap,_hardCap) {
     // set the state of rate 
     rate = _rate;

     // set the instance of dbot token
     dbot = DBOT(_dbot);

     // set Address for collecting ETH.
     wallet = _wallet;

     // set maximum cap giving by the investor.
     investorMaxCap = _investorMaxCap;

     // set market address state
     marketAddress = _marketAddress;
 }

 // dont forget to receive ethers;
 receive() external payable {}
 
 // get current rate from the ico.
 function getCurrentRate() public view returns(uint256) {
     return rate;
 } 

 // get Converted token 1 ETH = 1500 DBOT;    
 function getTokenAmount(uint256 _weiValue) internal view returns(uint256 expectedTokens) {
     // get expected tokens for _weiValue;
     expectedTokens = _weiValue.mul(rate);
 } 

 // buyTokens with ETH/ 1500     
 function buyTokens(address _beneficiary) external payable  {
    
    // validate the post behaviour of crowdsale
    _preValidatePurchase(msg.sender,_beneficiary,msg.value);

    // calcaulate token should be created.
    uint256 _expectedTokens = getTokenAmount(msg.value);

    // update the weiRaised
    weiRaised.add(_expectedTokens);

    // process the purchase
    _processPurchase(_beneficiary,_expectedTokens);

    // emit the event after transfer the tokens
    emit TokenPurchase(
        msg.sender,
        _beneficiary,
        msg.value,
        _expectedTokens
        );
    // forward the fund to the multisig wallet
    wallet.transfer(msg.value);

 }

 // check if cap get reach the goal.
 function capReached() internal view returns(bool){
     return (weiRaised >= hardCap); 
 }
 
 // pre-validation for checking
 function _preValidatePurchase(address payable _purchaseHodl,address _beneficiary,uint256 _investorAmount) internal isWhiteListed(_beneficiary) {
     // validate the pre-request
     require(_beneficiary != address(0),"PREVALIDATION: Invalid beneficiary address.");
     require(_investorAmount != 0,"PREVALIDATION: Invalid WEI?");
     require(investorMaxCap > _investorAmount, "PREVALIDATION: Invalid Amount");
     // check if has achive the cap it will refunds the ETH fund.
     if(capReached()){
     // refund the eth back to the user when hard cap met;
     _purchaseHodl.transfer(_investorAmount);    
     // revert the transaction refund ethereum to the investor. 
     revert("PREVALIDATION: Hard cap gets reached!");
     }
 }

 // process the purchase init.   
 function _processPurchase(address _beneficiary, uint256 _tokenValue) internal {
     // add candidate to the contributors mapping.
     contributors[_beneficiary] = contributors[_beneficiary].add(_tokenValue);
     // transfer the tokens investor owned. but the DBOT contract owner must be crowdsale Contract.
     dbot.safeTransfer(_beneficiary, _tokenValue);
 }

 // function for get Contribution.
 function getContributions(address _beneficiary) public view returns(uint256){
   return contributors[_beneficiary];  
 }

 // last function that will be called after the crowdsale has been done.
 // 
 function finishlized(address _router, uint256 _deadline) external payable onlyOwner returns(uint256 amountToken,uint256 amountETH, uint256 liquidity) {
    // first check require the  condition that it will between softcap and hardcap.
    require(weiRaised >= softCap && weiRaised <= hardCap, "CROWDSALE: Finzation Error Cant' Achive SoftCap.");
    // if condition will true. that gather 40% eth.
    uint256 amountETHDesired = msg.value;
    // now you can add liquidity into the pool.
    IUniswapRouter02 router = IUniswapRouter02(_router);
    
    // tokenNomics of DBOT.
    /*
    11,000,00 totalSupply.
    750,000 presale supply.
    300,000 uniswap liduidity tokens.
    50,000 marketing supply tokens.
     */

    // distribute market tokens.
    uint256 marketTokens = 50000 ether;
    
    // approve router to access tokens
    uint256 liquidityTokens = 300000 ether;
    
    //distribute the market tokens on that address.
    dbot.safeTransfer(marketAddress, marketTokens);
    
    // give allowance to expand this tokens
    dbot.approve(_router,liquidityTokens);

    // add liquidity into token pool.
    (amountToken,amountETH,liquidity) = router.addLiquidityETH{value: amountETHDesired}(
        address(dbot), 
        liquidityTokens,
        1, 
        1, 
        address(this),
        _deadline
        );

    // now deal with remaining tokens that will be burned.
    // burn dust tokens.
    
    uint256 newSupply = weiRaised.sub(liquidityTokens).sub(marketTokens);
    _burnDustTokens(newSupply);

    // finally update the state of hasClosed.
    hasClosed = true;
    // make owner to the owner of that contract
    dbot.transferOwnership(dbot.owner());

 }

 function _burnDustTokens(uint256 _newSupply) internal {
     // here is the logic of burn tokens
     uint256 burnedTokens = _newSupply.sub(weiRaised);
     // transfer that token into address(0)
     dbot.burn(dbot.owner(), burnedTokens);
 }    

}