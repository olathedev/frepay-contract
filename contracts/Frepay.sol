// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./lib/Events.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract FrePay {
    enum JobStatus {
        Unassigned,
        Assigned,
        Completed
    }

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

        uint256[] memory milestones = new uint256[](_numOfMilestones);
        uint256 amountPerMileStone = _paymentAmount / _numOfMilestones;

        for (uint256 i = 0; i < _numOfMilestones; i++) {
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

        emit Events.JobCreated(
            jobCounter,
            msg.sender,
            _description,
            _paymentAmount
        );
    }

    function acceptJob(uint256 _jobId) external {
        Job storage job = jobs[_jobId];
        require(job.employer != address(0), "Job does not exist");
        require(
            job.freelancer == address(0) && job.status == JobStatus.Unassigned,
            "Job already assigned by another freelancer"
        );
        require(block.timestamp < job.deadline, "Job deadline has passed");

        job.freelancer = msg.sender;
        job.status = JobStatus.Assigned;

        emit Events.JobAccepted(_jobId, msg.sender);
    }

    function confirmMileStoneCompletion(uint256 _jobId) external {
        Job storage job = jobs[_jobId];
        require(
            job.freelancer == msg.sender,
            "Only the freelancer can complete milestones"
        );
        require(job.status == JobStatus.Completed, "Job is already completed");

        require(
            job.currentMilestoneIndex < job.milestones.length - 1 ||
                job.milestones.length > 1,
            "Cannot process the final milestone; client must confirm completion to release final payment"
        );

        uint256 milestoneAmount = job.milestones[job.currentMilestoneIndex];
        payable(job.freelancer).transfer(milestoneAmount);
        job.currentMilestoneIndex += 1;

        emit Events.MilestoneReached(_jobId, job.currentMilestoneIndex - 1);
        emit Events.PaymentReleased(_jobId, job.freelancer, milestoneAmount);
    }

    function employerConfirmsCompletetion(uint256 _jobId) external {
        Job storage job = jobs[_jobId];
        require(
            job.employer == msg.sender,
            "Only the Employer can confirm completion"
        );
        require(
            job.freelancer != address(0),
            "No freelancer accepted this job yet"
        );
        require(job.status == JobStatus.Completed, "Job is already completed");
        require(
            job.milestones.length == 1,
            "Only one milestone is allowed for this operation"
        );

        uint256 finalPayment = job.milestones[0];

        payable(job.freelancer).transfer(finalPayment);

        emit Events.PaymentReleased(_jobId, job.freelancer, finalPayment);

        job.status = JobStatus.Completed;

        emit Events.JobCompleted(_jobId);
    }

    function getMilestones(
        uint256 jobId
    ) external view returns (uint256[] memory) {
        return jobs[jobId].milestones;
    }
}
