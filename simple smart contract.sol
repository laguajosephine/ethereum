// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Faucet {
    // max withdrawal amount
    uint public constant MAX_AMOUNT = 0.05 ether;

    // events
    event Withdraw(address indexed _to, uint _amount);
    event Deposit(address indexed _from, uint _amount);

    // anyone can pay the contract
    function deposit() public payable {
        require(msg.value > 0, "Send ETH to pay");
        emit Deposit(msg.sender, msg.value);
    }

    // anyone can withdraw (up to MAX_AMOUNT)
    function withdraw(uint _amount) public {
        require(_amount <= MAX_AMOUNT, "The amount you want to withdraw is too high");
        require(address(this).balance >= _amount, "Insufficient balance in faucet");

        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    // get the current balance of the faucet
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
