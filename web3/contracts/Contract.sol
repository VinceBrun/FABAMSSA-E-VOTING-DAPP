// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title FacultyElection
 * @dev A smart contract for conducting a faculty election.
 */
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
    
    mapping(address => uint) private voteTimestamps;  // Stores the timestamp of when a voter casts a vote
    
    event VoteCasted(uint candidateId, uint voteCount);  // Event to indicate that a vote has been casted
    
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
    
    /**
     * @dev Constructor function.
     * @param _electionDuration The duration of the election in seconds.
     */
    constructor(uint _electionDuration) {
        admin = msg.sender;
        electionEndTime = block.timestamp + _electionDuration;
    }
    
    /**
     * @dev Registers a candidate for the election.
     * @param _name The name of the candidate.
     * @param _matriculationNumber The matriculation number of the candidate.
     * @param _department The department of the candidate.
     * @param _position The position of the candidate.
     */
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
    
    /**
     * @dev Retrieves the details of a candidate.
     * @param _candidateId The ID of the candidate.
     * @return name The name of the candidate.
     * @return matriculationNumber The matriculation number of the candidate.
     * @return department The department of the candidate.
     * @return position The position of the candidate.
     * @return voteCount The number of votes received by the candidate.
     */
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
    
    /**
     * @dev Allows a voter to login using their department and matriculation number.
     * @param _department The department of the voter.
     * @param _matriculationNumber The matriculation number of the voter.
     */
    function loginVoter(string memory _department, string memory _matriculationNumber) public {
        require(bytes(_department).length > 0, "Invalid department name");
        require(isValidMatriculationNumber(_department, _matriculationNumber), "Invalid matriculation number");
        
        voters[msg.sender] = Voter(false, _department);
    }
    
    /**
     * @dev Allows a voter to cast their vote for a candidate.
     * @param _candidateId The ID of the candidate.
     */
    function vote(uint _candidateId) public onlyVoter onlyDuringElection {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        
        Candidate storage candidate = candidates[_candidateId];
        candidate.voteCount++;
        
        voters[msg.sender].hasVoted = true;
        
        // Record the timestamp of the vote
        voteTimestamps[msg.sender] = block.timestamp;
        
        emit VoteCasted(_candidateId, candidate.voteCount);
    }
    
    /**
     * @dev Retrieves the status of the election.
     * @return isOpen True if the election is open, false otherwise.
     * @return endTime The end time of the election.
     */
    function getElectionStatus() public view returns (bool isOpen, uint endTime) {
        return (isElectionOpen, electionEndTime);
    }
    
    /**
     * @dev Opens the election for voting.
     */
    function openElection() public onlyAdmin {
        require(!isElectionOpen, "Election is already open");
        
        isElectionOpen = true;
    }
    
    /**
     * @dev Closes the election for voting.
     */
    function closeElection() public onlyAdmin {
        require(isElectionOpen, "Election is not open");
        
        isElectionOpen = false;
    }
    
    /**
     * @dev Updates the end time of the election.
     * @param _newEndTime The new end time of the election.
     */
    function updateElectionEndTime(uint _newEndTime) public onlyAdmin {
        require(_newEndTime > block.timestamp, "Invalid end time");
        require(_newEndTime > electionEndTime, "New end time must be later than current end time");
        
        electionEndTime = _newEndTime;
    }
    
    /**
     * @dev Sets the vote count for multiple candidates at once.
     * @param _candidateIds The IDs of the candidates.
     * @param _voteCounts The corresponding vote counts for the candidates.
     */
    function setVoteCountForCandidates(uint[] memory _candidateIds, uint[] memory _voteCounts) public onlyAdmin {
        require(_candidateIds.length == _voteCounts.length, "Invalid input lengths");
        
        for (uint i = 0; i < _candidateIds.length; i++) {
            uint candidateId = _candidateIds[i];
            require(candidateId > 0 && candidateId <= candidateCount, "Invalid candidate ID");
            
            candidates[candidateId].voteCount = _voteCounts[i];
        }
    }
    
    /**
     * @dev Checks if a matriculation number is valid.
     * @param _department The department associated with the matriculation number.
     * @param _matriculationNumber The matriculation number to validate.
     * @return True if the matriculation number is valid, false otherwise.
     */
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
