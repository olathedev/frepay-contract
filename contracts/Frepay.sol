// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract FrePay {
    struct Job {
        string jobDescription;
        address employer;
        address freelancer;
        uint256 paymentAmount;
        uint256 deadline;
        bool completed;
        bool paid;
        uint256[] milestones; 
        uint256 currentMilestoneIndex;
    }

    mapping (uint256 => Job) Jobs;
    


}
