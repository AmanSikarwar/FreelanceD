// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FreelanceMarketplace {

    enum ProjectStatus { Open, InProgress, Completed, Disputed }
    enum UserRole { Client, Freelancer }

    struct User {
        UserRole role;
        string name;
        uint256 reputationScore;
        address payable ethAddress;
    }

    struct Project {
        address client;
        string title;
        string description;
        uint256 budget;
        uint256 deadline;
        ProjectStatus status;
        address payable freelancer;
    }

    struct Application {
        address freelancer;
        string proposal;
        uint256 bid;
        bool isAccepted;
    }

    struct Dispute {
        uint256 projectId;
        address partyA;
        address partyB;
        uint256 votesForA;
        uint256 votesForB;
        bool resolved;
    }

    event ProjectCreated(uint256 projectId, address client, string title);
    event ProjectAwarded(uint256 projectId, address client, address freelancer);
    event ApplicationRejected(uint256 projectId, address freelancer, string reason);
    event MilestoneCompleted(uint256 projectId, uint256 milestoneIndex);
    event ProjectCompleted(uint256 projectId);
    event DisputeRaised(uint256 projectId);
    event DisputeResolved(uint256 projectId, address winner);
    event VoteCast(uint256 disputeId, address voter, bool voteForA);

    mapping(address => User) public users; 
    mapping(address => uint256) public userReputation;
    Project[] public projects;
    mapping (uint256 => uint256) public projectEscrow; 
    mapping(uint256 => mapping(uint256 => string)) public projectMilestones;
    mapping(uint256 => Application[]) public projectApplications;
    mapping(uint256 => Dispute) public disputes;
    uint256 public disputeCount;
    mapping(address => uint256) public votingPower;
    mapping(uint256 => mapping(address => bool)) public voted;
    mapping(uint256 => uint256) public disputeDeadlines;

    uint256 public minimumVotingPower;
    uint256 public votingDeadline;

    constructor(uint256 _minimumVotingPower, uint256 _votingDeadline) {
        minimumVotingPower = _minimumVotingPower;
        votingDeadline = _votingDeadline;
    }

    modifier onlyClient(uint256 _projectId) {
        require(msg.sender == projects[_projectId].client, "Only the client can perform this action.");
        _;
    }

    modifier onlyFreelancer(uint256 _projectId) {
        require(msg.sender == projects[_projectId].freelancer, "Only the assigned freelancer can perform this action.");
        _;
    }

    modifier projectExists(uint256 _projectId) {
        require(_projectId < projects.length, "Project does not exist.");
        _;
    }

    modifier hasVotingPower() {
        require(userReputation[msg.sender] > 0, "You have no voting power.");
        _;
    }

    function registerUser(UserRole _role, string memory _name) public {
        require(users[msg.sender].ethAddress == address(0), "User already exists."); 

        users[msg.sender] = User({
            role: _role,
            name: _name,
            reputationScore: 0,
            ethAddress: payable(msg.sender) 
        });
    }

    function createProject(
        string memory _title,
        string memory _description,
        uint256 _budget,
        uint256 _deadline
    ) public payable {
        require(msg.value == _budget, "Sent value must match the project budget.");
        projects.push(Project({
            client: msg.sender,
            title: _title,
            description: _description,
            budget: _budget,
            deadline: _deadline,
            status: ProjectStatus.Open,
            freelancer: payable(address(0))
        }));

        uint256 projectId = projects.length - 1;
        projectEscrow[projectId] = _budget;

        emit ProjectCreated(projectId, msg.sender, _title);
    }

    function _hasApplied(address _freelancer, uint256 _projectId) internal view returns (bool) {
        Application[] memory applications = projectApplications[_projectId];

        for (uint i = 0; i < applications.length; i++) {
            if (applications[i].freelancer == _freelancer) 
                return true;
        }
        return false;
     }

    function _hasAccepted(uint256 _projectId) internal view returns (bool) {
        for (uint i = 0; i < projectApplications[_projectId].length; i++) 
            if (projectApplications[_projectId][i].isAccepted) 
                return true;
        return false; 
    }

    function _canDispute(uint256 _projectId) internal view returns (bool) {
        return  _hasApplied(msg.sender, _projectId) && _hasAccepted(_projectId); 
     }

    function _canComplete(uint256 _projectId) internal view returns (bool) {
        return  _hasApplied(msg.sender, _projectId) && !_hasAccepted(_projectId); 

    }
    
    function applyForProject(
        uint256 _projectId,
        string memory _proposal,
        uint256 _bid
    ) public projectExists(_projectId)
    {
        Project storage project = projects[_projectId];
        require(project.status == ProjectStatus.Open, "Project is not open for applications.");
        require(!_hasApplied(msg.sender, _projectId), "You already applied for this project.");

        projectApplications[_projectId].push(
            Application({
                freelancer: msg.sender,
                proposal: _proposal, 
                bid: _bid,
                isAccepted: false
            })
        );
    }

    function acceptApplication(
        uint256 _projectId,
        uint256 _applicationIndex
    ) public onlyClient(_projectId) projectExists(_projectId)
    {
        Project storage project = projects[_projectId];
        require(project.status == ProjectStatus.Open, "Project is not open for Application.");
        Application[] storage applications = projectApplications[_projectId];
        require(_applicationIndex < applications.length, "Invalid application index.");
        require(!applications[_applicationIndex].isAccepted, "You already accepted this application."); 

        applications[_applicationIndex].isAccepted = true;
        project.freelancer = payable(applications[_applicationIndex].freelancer);
        project.status = ProjectStatus.InProgress;

        emit ProjectAwarded(_projectId, msg.sender, project.freelancer);
    }

    function rejectApplication(
        uint256 _projectId,
        uint256 _applicationIndex,
        string memory _rejectionReason
     ) public onlyClient(_projectId) projectExists(_projectId)
     {
        Project storage project = projects[_projectId];
        require(project.status == ProjectStatus.Open, "Project is not open for Application.");
        Application[] storage applications = projectApplications[_projectId];
        require(_applicationIndex < applications.length, "Invalid application index."); 

        address freelancer = applications[_applicationIndex].freelancer;

        applications[_applicationIndex] = applications[applications.length - 1];
        applications.pop();

        emit ApplicationRejected(_projectId, freelancer, _rejectionReason);
     }
    
    

    function submitMilestone(
        uint256 _projectId,
        uint256 _milestoneId,
        string memory _milestoneData
    ) 
        public 
        onlyFreelancer(_projectId) 
        projectExists(_projectId)
    {
        Project storage project = projects[_projectId];
        require(project.status == ProjectStatus.InProgress, "Project is not in progress.");

        projectMilestones[_projectId][_milestoneId] = _milestoneData;
        emit MilestoneCompleted(_projectId, _milestoneId);
    }

    function approveMilestone(uint256 _projectId, uint256 _milestoneId) 
        public 
        onlyClient(_projectId) 
        projectExists(_projectId)
    {
        Project storage project = projects[_projectId];
        require(project.status == ProjectStatus.InProgress, "Project is not in progress.");

        uint256 milestonePayment = project.budget * 10 / 100;
        projectEscrow[_projectId] -= milestonePayment;
        payable(project.freelancer).transfer(milestonePayment);

        emit MilestoneCompleted(_projectId, _milestoneId); 
    }

    function updateUserReputation(address _user, int256 _reputationChange) internal  {
        require(msg.sender == address(this), "Only the contract can update reputation.");

        userReputation[_user] = userReputation[_user] + uint256(_reputationChange); 
    }

    function completeProject(uint256 _projectId)
        public
        onlyClient(_projectId)
        projectExists(_projectId)
    {
        Project storage project = projects[_projectId];
        require(
            project.status == ProjectStatus.InProgress,
            "Project is not in progress."
        );

        project.status = ProjectStatus.Completed;

        uint256 remainingEscrow = projectEscrow[_projectId];
        projectEscrow[_projectId] = 0; 
        payable(project.freelancer).transfer(remainingEscrow);

        updateUserReputation(project.freelancer, 10); 

        emit ProjectCompleted(_projectId);
    }

    function raiseDispute(uint256 _projectId) public projectExists(_projectId) {
        Project storage project = projects[_projectId];

        require(
            msg.sender == project.client || msg.sender == project.freelancer,
            "Only involved parties can raise a dispute."
        );
        require(
            project.status == ProjectStatus.InProgress,
            "Disputes can only be raised during an active project."
        );

        project.status = ProjectStatus.Disputed;

        disputeCount++;
        disputes[disputeCount] = Dispute({
            projectId: _projectId,
            partyA: msg.sender,
            partyB: msg.sender == project.client
                ? project.freelancer
                : project.client,
            votesForA: 0,
            votesForB: 0,
            resolved: false
        });

        disputeDeadlines[disputeCount] = block.timestamp + votingDeadline;

        emit DisputeRaised(_projectId);
    }

    function voteOnDispute(uint256 _disputeId, bool _voteForA)
        public
        hasVotingPower
    {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Dispute already resolved.");

        require(block.timestamp <= disputeDeadlines[_disputeId], "Voting deadline has passed.");

        require(!voted[_disputeId][msg.sender], "You have already voted in this dispute.");
        voted[_disputeId][msg.sender] = true;

        uint256 voterReputation = userReputation[msg.sender];
        if (_voteForA) {
            dispute.votesForA += voterReputation;
        } else {
            dispute.votesForB += voterReputation;
        }

        emit VoteCast(_disputeId, msg.sender, _voteForA);
    }

    function resolveDispute(uint256 _disputeId) public {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Dispute already resolved.");
        require(block.timestamp > disputeDeadlines[_disputeId], "Voting period is not over yet.");

        address payable winner;
        if (dispute.votesForA > dispute.votesForB) {
            winner = payable(dispute.partyA);
        } else if (dispute.votesForB > dispute.votesForA) {
            winner = payable(dispute.partyB);
        } else {
            // Tiebreaker logic (e.g., favor the client or split the funds)
            // ... (Implement your preferred tiebreaker logic here) ...
        }

        uint256 disputedAmount = projectEscrow[dispute.projectId];
        projectEscrow[dispute.projectId] = 0;

        if (winner != address(0)) { // Make sure there's a winner
            payable(winner).transfer(disputedAmount);
        } // ... (Handle the case of a tie/no winner - maybe return funds to the client)

        dispute.resolved = true;
        projects[dispute.projectId].status = ProjectStatus.Completed; 
        emit DisputeResolved(dispute.projectId, winner);
    }

    function withdrawClientFunds(uint256 _projectId) public onlyClient(_projectId) {
        Project storage project = projects[_projectId];
        require(
            project.status == ProjectStatus.Completed || 
            project.status == ProjectStatus.Open, // Allow withdrawal if the project hasn't started yet
            "Funds can only be withdrawn from completed or open projects."
        );

        uint256 amountToWithdraw = projectEscrow[_projectId];
        require(amountToWithdraw > 0, "No funds to withdraw.");

        projectEscrow[_projectId] = 0; 
        payable(msg.sender).transfer(amountToWithdraw);
    }
}