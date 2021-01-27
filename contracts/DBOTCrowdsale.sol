// SPDX-License-Identifier: MIT;
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./cap/CappedCrowdsale.sol";
import "./validation/Whitelist.sol";

contract DBOTCrowdsale is CappedCrowdsale,ReentrancyGuard,Whitelist {

 // set library are you using.
 using SafeERC20 for IERC20;      
 using SafeMath for uint256;

 // set Contract Instance
 IERC20 public dbot;

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
    uint256 _investorMaxCap
 ) CappedCrowdsale(_softCap,_hardCap) {
     // set the state of rate 
     rate = _rate;

     // set the instance of dbot token
     dbot = IERC20(_dbot);

     // set Address for collecting ETH.
     wallet = _wallet;

     // set maximum cap giving by the investor.
     investorMaxCap = _investorMaxCap;
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
 function buyTokens(address _beneficiary) external payable nonReentrant() {
    
    // validate the post behaviour of crowdsale
    _preValidatePurchase(msg.sender,_beneficiary,msg.value);

    // calcaulate token should be created.
    uint256 _expectedTokens = getTokenAmount(msg.value);

    // update the weiRaised
    weiRaised.add(_expectedTokens);

    // process the purchase
    _processPurchase(_beneficiary,_expectedTokens);

    // forward the fund to the multisig wallet
    wallet.transfer(msg.value);

 }

 // check if cap get reach the goal.
 function capReached() internal view returns(bool){
     return (weiRaised >= hardCap); 
 }
 
 // pre-validation for checking
 function _preValidatePurchase(address payable _purchaseHodl,address _beneficiary,uint256 _investorAmount) internal isWhiteListed(_beneficiary) nonReentrant() {
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

}