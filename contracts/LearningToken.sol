//SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

import "./ERC20Interface.sol";

contract LearningToken is ERC20Interface {
  string public name = "LearningToken";
  string public symbol = "LRNT";
  uint public decimals = 18;
  uint public override totalSupply;

  address public founder;
  mapping(address => uint) public balances; // used to store the number of tokens of each address

  // this mapping includes accounts approved to withdraw from a given account, together with the
  // withdraw amount allowed to each of them.
  mapping(address => mapping(address => uint)) allowed;

  constructor() {
    totalSupply = 1000000;
    founder = msg.sender;
    balances[founder] = totalSupply;
  }

  function balanceOf(address tokenOwner) public view override returns (uint balance) {
    return balances[tokenOwner];
  }

  function transfer(address to, uint tokens) public virtual override returns (bool success) {
    require(balances[msg.sender] >= tokens);

    balances[to] += tokens;
    balances[msg.sender] -= tokens;
    emit Transfer(msg.sender, to, tokens);

    return true;
  }

  function allowance(address tokenOwner, address spender) public view override returns (uint) {
    return allowed[tokenOwner][spender];
  }

  function approve(address spender, uint tokens) public override returns (bool success) {
    require(balances[msg.sender] >= tokens);
    require(tokens > 0);

    allowed[msg.sender][spender] = tokens;

    emit Approval(msg.sender, spender, tokens);
    return true;
  }

  function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success) {
    require(allowed[from][msg.sender] >= tokens);
    require(balances[from] >= tokens);

    balances[from] -= tokens;
    balances[to] += tokens;
    allowed[from][msg.sender] -= tokens;

    emit Transfer(from, to, tokens);

    return true;
  }
}