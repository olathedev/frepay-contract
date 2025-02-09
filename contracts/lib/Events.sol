// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

library Events {
    event JobCreated(
        uint256 indexed jobId,
        address indexed client,
        string jobDescription,
        uint256 paymentAmount
    );
    event JobAccepted(uint256 indexed jobId, address indexed freelancer);
    event MilestoneReached(uint256 indexed jobId, uint256 milestoneIndex);
    event PaymentReleased(
        uint256 indexed jobId,
        address indexed freelancer,
        uint256 amount
    );
    event DisputeInitiated(uint256 indexed jobId, address indexed initiator);
    event DisputeResolved(
        uint256 indexed jobId,
        address indexed winner,
        uint256 amount
    );
}
