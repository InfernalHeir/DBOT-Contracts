// SPDX-License-Identifier: MIT;
pragma solidity ^0.7.0;

contract CappedCrowdsale {

  // state variable for min capped
  uint256 public softCap;
  // state variable for max capped
  uint256 public hardCap;

  // call the constructor   
  constructor(uint256 _softCap, uint _hardCap) {
     
     // validation of hardCap and SoftCap
     require(_softCap > 0 && _hardCap > 0, 
     "CappedCrowdale: Invalid Cap?"
     );
     
     // set the softCap state variable
     softCap = _softCap;

     // set the hardCap state variable
     hardCap = _hardCap;
  }
  
}