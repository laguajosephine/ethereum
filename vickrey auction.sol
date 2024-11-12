// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VickreyAuction {
    uint public constant MAX_USERS = 5;
    uint public userCount = 0;
    uint public highestBid;
    uint public secondHighestBid;

    address public owner;
    address public winner;
    
    mapping(address => bool) public hasBid;
    mapping(address => uint) public bids;
    address[] public userList;

    // events
    event Withdraw(address indexed _to, uint _amount);
    event Bid(address indexed _from, uint _amount);
    event ResetAuction();
    event Winner(address indexed _from, uint _amount);

    // constructor sets the contract owner as the deployer
    constructor() {
        owner = msg.sender;
    }

    // anyone can bid any amount, until MAX_USERS is reached
    function bid() public payable {
        require(msg.value > 0, "Send any amount of ETH to bid");

        // check if user is new and if MAX_USERS has been reached
        if (!hasBid[msg.sender]) {
            require(userCount < MAX_USERS, "Maximum number of bidders reached");
            hasBid[msg.sender] = true;
            userList.push(msg.sender);
            userCount++;
        }

        bids[msg.sender] += msg.value;

        emit Bid(msg.sender, msg.value);
    }

    // modifier that restricts access only to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // only-owner function that decides the winner and second-highest bid
    function decideWinner() public onlyOwner {
        require(userCount == MAX_USERS, "The auction is still ongoing");

        uint maxBid = 0;
        uint secondMaxBid = 0;
        address maxBidder;

        // Find the highest and second-highest bids
        for (uint i = 0; i < userList.length; i++) {
            address user = userList[i];
            uint bidAmount = bids[user];

            if (bidAmount > maxBid) {
                secondMaxBid = maxBid;
                maxBid = bidAmount;
                maxBidder = user;
            } else if (bidAmount > secondMaxBid) {
                secondMaxBid = bidAmount;
            }
        }

        winner = maxBidder;
        highestBid = maxBid;
        secondHighestBid = secondMaxBid;

        emit Winner(winner, secondHighestBid);
    }

    // only-owner function that reimburses losers and refunds the winner the difference
    function reimburse() public onlyOwner {
        require(winner != address(0), "Winner has not been decided");

        // Refund all losing bidders
        for (uint i = 0; i < userList.length; i++) {
            address user = userList[i];

            if (user != winner) {
                uint bidAmount = bids[user];
                if (bidAmount > 0) {
                    payable(user).transfer(bidAmount);
                    bids[user] = 0;
                }
            }
        }

        // Refund the difference to the winner
        uint refundAmount = highestBid - secondHighestBid;
        if (refundAmount > 0) {
            payable(winner).transfer(refundAmount);
            bids[winner] = secondHighestBid;
        }
    }

    // only-owner function to withdraw remaining funds from the contract
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
        emit Withdraw(owner, balance);
    }

    // only-owner function that resets the auction
    function resetAuction() public onlyOwner {
        for (uint i = 0; i < userList.length; i++) {
            hasBid[userList[i]] = false;
            bids[userList[i]] = 0;
        }
        delete userList;
        userCount = 0;
        winner = address(0);
        highestBid = 0;
        secondHighestBid = 0;

        emit ResetAuction();
    }
}
