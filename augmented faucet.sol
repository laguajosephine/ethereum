// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Faucet {
    uint public constant MAX_AMOUNT = 0.05 ether;
    uint public constant MAX_USERS = 4;

    address public owner;
    
    // remembering the users that withdraw
    uint public userCount = 0;
    mapping(address => bool) public hasWithdrawn;
    address[] public userList;

    // events
    event Withdraw(address indexed _to, uint _amount);
    event Deposit(address indexed _from, uint _amount);
    event ResetUsers();


    // constructor sets the contract owner as the deployer
    constructor() {
        owner = msg.sender;
    }

    // deposit function
    function deposit() public payable {
        require(msg.value > 0, "Send ETH to pay");
        emit Deposit(msg.sender, msg.value);
    }

    // withdraw function
    function withdraw(uint _amount) public {
        require(_amount <= MAX_AMOUNT, "The amount you want to withdraw is too high");
        require(address(this).balance >= _amount, "Insufficient balance in faucet");

        // check if user is new and if MAX_USERS has been reached
        if (!hasWithdrawn[msg.sender]) {
            require(userCount < MAX_USERS, "Maximum number of unique users reached");
            hasWithdrawn[msg.sender] = true;
            userList.push(msg.sender);
            userCount++;
        }

        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    // modifier that restricts access only to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // owner-only function to reset the list of unique users
    function resetUsers() public onlyOwner {
        for (uint i = 0; i < userList.length; i++) {
            hasWithdrawn[userList[i]] = false;
        }
        delete userList;
        userCount = 0;
        emit ResetUsers();
    }

    // get the faucet's current balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
