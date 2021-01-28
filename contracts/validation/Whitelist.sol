// SPDX-License-Identifier: MIT;
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelist is Ownable {
 
 // create mapping to store whitelist address for kyc/aml policy
 mapping (address => bool) whitelisted;

 // create modiifer for initial validation
 modifier isWhiteListed(address _beneficiary){
     require(!whitelisted[_beneficiary],"WHITELIST: Beneficiary is not whitelisted!");
     _;
 }
 // add single address to whitelist mapping.
 function addSingleBeneficiary(address _beneficiary) public onlyOwner {
     require(_beneficiary != address(0), "WHITELIST: Invalid Address ?");
     whitelisted[_beneficiary] = true;
 }
 // add many beneficiary into whitelisted mapping.
 function addManyBeneficiary(address[] memory _beneficiares) public onlyOwner {
     require(_beneficiares.length > 0,"WHITELIST: Empty Beneficiares!");
     for(uint256 i=0; i < _beneficiares.length; i++){
         whitelisted[_beneficiares[i]] = true;
     }
 }

 // remove from white list mapping.
 function removeBeneficiary(address _beneficiary) public onlyOwner {
     require(_beneficiary != address(0), "WHITELIST: Invalid Address ?");
     whitelisted[_beneficiary] = false;   
 }   


}
