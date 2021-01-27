// SPDX-License-Identifier: MIT;
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DBOT is ERC20,Ownable{

  // call the DBOT Contructor
  constructor( string memory _tokenName, string memory _tokenSymbol,uint256 _supply)
  ERC20(_tokenName,_tokenSymbol) {
      // set the mint function for total supply
      _mint(msg.sender,_supply);
  }  

}  