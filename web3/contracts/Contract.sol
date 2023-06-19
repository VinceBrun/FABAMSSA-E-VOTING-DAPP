// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract FacultyElection {
    struct Candidate {
        string name;
        string matriculationNumber;
        string department;
        string position;
        uint voteCount;
    }
    
    struct Voter {
        bool hasVoted;
        string department;
    }
    
    address private admin;
    mapping(address => Voter) private voters;
    mapping(uint => Candidate) private candidates;
    uint private candidateCount;
    bool private isElectionOpen;
    uint private electionEndTime;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this operation");
        _;
    }
    
    modifier onlyVoter() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }
    
    modifier onlyDuringElection() {
        require(isElectionOpen && block.timestamp <= electionEndTime, "Voting is closed");
        _;
    }
    
    constructor(uint _electionDuration) {
        admin = msg.sender;
        electionEndTime = block.timestamp + _electionDuration;
    }
    
    function registerCandidate(
        string memory _name,
        string memory _matriculationNumber,
        string memory _department,
        string memory _position
    ) public onlyAdmin {
        require(bytes(_name).length > 0, "Invalid candidate name");
        require(bytes(_matriculationNumber).length > 0, "Invalid matriculation number");
        require(bytes(_department).length > 0, "Invalid department name");
        require(bytes(_position).length > 0, "Invalid position name");
        
        candidateCount++;
        candidates[candidateCount] = Candidate(_name, _matriculationNumber, _department, _position, 0);
    }
    
    function getCandidate(uint _candidateId) public view returns (
        string memory name,
        string memory matriculationNumber,
        string memory department,
        string memory position,
        uint voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        
        Candidate memory candidate = candidates[_candidateId];
        return (
            candidate.name,
            candidate.matriculationNumber,
            candidate.department,
            candidate.position,
            candidate.voteCount
        );
    }
    
    function loginVoter(string memory _department, string memory _matriculationNumber) public {
        require(bytes(_department).length > 0, "Invalid department name");
        require(isValidMatriculationNumber(_department, _matriculationNumber), "Invalid matriculation number");
        
        voters[msg.sender] = Voter(false, _department);
    }
    
    function vote(uint _candidateId) public onlyVoter onlyDuringElection {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        
        Candidate storage candidate = candidates[_candidateId];
        candidate.voteCount++;
        
        voters[msg.sender].hasVoted = true;
    }
    
    function getElectionStatus() public view returns (bool isOpen, uint endTime) {
        return (isElectionOpen, electionEndTime);
    }
    
    function openElection() public onlyAdmin {
        require(!isElectionOpen, "Election is already open");
        
        isElectionOpen = true;
    }
    
    function closeElection() public onlyAdmin {
        require(isElectionOpen, "Election is not open");
        
        isElectionOpen = false;
    }
    
    function updateElectionEndTime(uint _newEndTime) public onlyAdmin {
        require(_newEndTime > block.timestamp, "Invalid end time");
        require(_newEndTime > electionEndTime, "New end time must be later than current end time");
        
        electionEndTime = _newEndTime;
    }
    
    function setVoteCountForCandidates(uint[] memory _candidateIds, uint[] memory _voteCounts) public onlyAdmin {
        require(_candidateIds.length == _voteCounts.length, "Invalid input lengths");
        
        for (uint i = 0; i < _candidateIds.length; i++) {
            uint candidateId = _candidateIds[i];
            require(candidateId > 0 && candidateId <= candidateCount, "Invalid candidate ID");
            
            candidates[candidateId].voteCount = _voteCounts[i];
        }
    }
    
    function isValidMatriculationNumber(string memory _department, string memory _matriculationNumber) private pure returns (bool) {
        bytes memory departmentBytes = bytes(_department);
        bytes memory matriculationBytes = bytes(_matriculationNumber);

        if (departmentBytes.length < 2 || matriculationBytes.length != 8) {
            return false;
        }

        bytes2 departmentPrefix = bytes2(uint16(uint8(departmentBytes[0])) << 8 | uint16(uint8(departmentBytes[1])));
        bytes2 allowedDepartmentPrefix1 = bytes2(0x5F2F); // Department A
        bytes2 allowedDepartmentPrefix2 = bytes2(0x5442); // Department B
        bytes2 allowedDepartmentPrefix3 = bytes2(0x5853); // Department C
        bytes2 allowedDepartmentPrefix4 = bytes2(0x5844); // Department D
        bytes2 allowedDepartmentPrefix5 = bytes2(0x5345); // Department E
        bytes2 allowedDepartmentPrefix6 = bytes2(0x4142); // Department F

        if (
            departmentPrefix != allowedDepartmentPrefix1 &&
            departmentPrefix != allowedDepartmentPrefix2 &&
            departmentPrefix != allowedDepartmentPrefix3 &&
            departmentPrefix != allowedDepartmentPrefix4 &&
            departmentPrefix != allowedDepartmentPrefix5 &&
            departmentPrefix != allowedDepartmentPrefix6
        ) {
            return false;
        }

        bytes2 academicYearBytes = bytes2(uint16(uint8(departmentBytes[3])) << 8 | uint16(uint8(departmentBytes[4])));
        bytes2 allowedAcademicYearPrefix = bytes2(0x3039); // Academic years 0-9

        if (academicYearBytes < allowedAcademicYearPrefix) {
            return false;
        }

        if (
            departmentPrefix == allowedDepartmentPrefix6 &&
            !(academicYearBytes == bytes2(0x4141)) // Department F only allows academic year A
        ) {
            return false;
        }

        if (
            !(matriculationBytes[0] >= 0x30 && matriculationBytes[0] <= 0x39) ||
            !(matriculationBytes[1] >= 0x30 && matriculationBytes[1] <= 0x39) ||
            !(matriculationBytes[2] >= 0x30 && matriculationBytes[2] <= 0x33) ||
            !(matriculationBytes[3] >= 0x30 && matriculationBytes[3] <= 0x39)
        ) {
            return false;
        }

        return true;
    }
}
