//SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

import "./LearningToken.sol";

contract LearningTokenICO is LearningToken {
  address public admin;
  address payable public depositAddress;
  uint tokenPrice = 0.001 ether;
  uint public hardCap = 300 ether;
  uint public raisedAmount;
  uint public saleStart = block.timestamp;
  uint public saleEnd = block.timestamp + 604800; // ICO ends in a week
  uint public tokenTradeStart = saleEnd + 604800; // Tokens won't be available for transfer until one week after the ICO has ended
  uint public minInvesment = 0.1 ether;
  uint public maxInvesment = 5 ether;
  
  enum State {BeforeStart, Running, AfterEnd, Halted}
  State public icoState;

  event Invest(address investor, uint value, uint tokens);

  constructor(address payable _depositAddress) {
    depositAddress = _depositAddress;
    admin = msg.sender;
    icoState = State.BeforeStart;
  }

  receive() payable external {
    invest();
  }

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  function halt() public onlyAdmin {
    icoState = State.Halted;
  }

  function resume() public onlyAdmin {
    icoState = State.Running;
  }

  function setDepositAddress(address payable _newDepositAddress) public onlyAdmin {
    depositAddress = _newDepositAddress;
  }

  function getCurrentState() public view returns (State) {
    if (icoState == State.Halted) {
      return State.Halted;
    } else if (block.timestamp < saleStart) {
      return State.BeforeStart;
    } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
      return State.Running;
    } else {
      return State.AfterEnd;
    }
  }

  function invest() public payable returns (bool) {
    require(getCurrentState() == State.Running);
    require(msg.value >= minInvesment && msg.value <= maxInvesment);
    raisedAmount += msg.value;
    require(raisedAmount <= hardCap);

    uint tokens = msg.value / tokenPrice;

    balances[msg.sender] += tokens;
    balances[founder] -= tokens;

    depositAddress.transfer(msg.value);
    emit Invest(msg.sender, msg.value, tokens);

    return true;
  }

  function transfer(address to, uint tokens) public override returns (bool success) {
    require(block.timestamp >= tokenTradeStart);
    LearningToken.transfer(to, tokens);
    return true;
  }

  function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
    require(block.timestamp >= tokenTradeStart);
    LearningToken.transferFrom(from, to, tokens);
    return true;
  }

  function burn() public returns (bool) {
    require(getCurrentState() == State.AfterEnd);
    balances[founder] = 0;
    return true;
  }
}