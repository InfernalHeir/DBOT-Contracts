# Dbots Contracts

> DBOT Contrcats are set of Crowdsale with core. based on Hard Capped.

# Whitelist Contarct

### Whitelist contract will check the investor has been verified or not.

```solidity
modifier isWhiteList(address _beneficiary) {
  require(whitelist[_beneficiary],"WHITELIST: Beneficiary is not whitelisted!");
  _;
}
```
