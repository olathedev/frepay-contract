// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract FrePay {
    enum JobStatus { Unassigned, Assigned, Completed }

    struct Job {
        string jobDescription;
        address employer;
        address freelancer;
        uint256 paymentAmount;
        uint256 deadline;
        JobStatus status;
        uint256[] milestones;
        uint256 currentMilestoneIndex;
    }

    uint256 jobCounter;

    mapping(uint256 => Job) public jobs;

    function createJob(
        string memory _description,
        uint256 _paymentAmount,
        uint256 _deadlineDurationInDays,
        uint8 _numOfMilestones
    ) external payable {
        require(_paymentAmount > 0, "Payment amount must be greater than 0");
        require(
            _deadlineDurationInDays > 0,
            "Deadline at least a day i future"
        );
        require(
            msg.value == _paymentAmount,
            "Payment amount must be equal to the value sent"
        );

        jobCounter = jobCounter + 1;
        uint256 deadline = block.timestamp * (_deadlineDurationInDays * 1 days);

        uint256[] memory milestones = new uint256[] (_numOfMilestones);
        uint256 amountPerMileStone = _paymentAmount / _numOfMilestones;

        for(uint256 i = 0; i < _numOfMilestones; i++) {
            milestones[i] = amountPerMileStone;
        }

        jobs[jobCounter] = Job({
            jobDescription: _description,
            employer: msg.sender,
            freelancer: address(0),
            paymentAmount: _paymentAmount,
            deadline: deadline,
            status: JobStatus.Unassigned,
            milestones: milestones, 
            currentMilestoneIndex: 0
        });
    }


    function getMilestones(uint256 jobId) external view returns (uint256[] memory) {
        return jobs[jobId].milestones;
    }
}
