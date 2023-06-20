# FABAMSSA-E-VOTING-DAPP
FABAMSSA-E-VOTING-DAPP is a decentralized voting system for a faculty election in a university
The given Solidity smart contract is for conducting a faculty election. Let's go through the contract and understand its different components.

The contract is named `FacultyElection` and starts with the SPDX license identifier and Solidity version pragma.

### Data Structures

The contract defines two main data structures:

1. `Candidate`: It represents a candidate in the election and contains the following fields:
   - `name`: The name of the candidate.
   - `matriculationNumber`: The matriculation number of the candidate.
   - `department`: The department of the candidate.
   - `position`: The position of the candidate.
   - `voteCount`: The number of votes received by the candidate.

2. `Voter`: It represents a voter and contains the following fields:
   - `hasVoted`: A boolean indicating whether the voter has already voted.
   - `department`: The department of the voter.
   - `matriculationNumber`: The matriculation number of the voter.

### State Variables

The contract declares several state variables:
- `admin`: An address representing the administrator or owner of the contract.
- `voters`: A mapping that maps an address to a `Voter` struct.
- `candidates`: A mapping that maps a candidate ID to a `Candidate` struct.
- `candidateCount`: An integer indicating the total number of registered candidates.
- `isElectionOpen`: A boolean indicating whether the election is open for voting.
- `electionEndTime`: A timestamp indicating the end time of the election.

### Events

The contract defines one event:
- `VoteCasted`: It is emitted when a vote is casted and contains the candidate ID and the updated vote count.

### Modifiers

The contract defines three modifiers:
1. `onlyAdmin`: It restricts a function to be called only by the admin.
2. `onlyVoter`: It restricts a function to be called only by a voter who hasn't voted yet.
3. `onlyDuringElection`: It restricts a function to be called only during the open election period.

### Constructor

The constructor function accepts the `_electionDuration` parameter, which represents the duration of the election in seconds. It sets the `admin` variable to the address of the contract deployer and calculates the `electionEndTime` based on the current block timestamp and the provided duration.

### Functions

The contract provides several functions:

- `registerCandidate`: Allows the admin to register a candidate by providing their name, matriculation number, department, and position.
- `getCandidate`: Retrieves the details of a candidate based on the candidate ID.
- `getCandidateCount`: Retrieves the total number of registered candidates.
- `startElection`: Starts the election process, but only if there are registered candidates and the election is not already open.
- `castVote`: Allows a voter to cast a vote for a candidate by providing the candidate ID, department, and matriculation number.
- `isValidVoterDepartment`: Checks if the given voter department and matriculation number are valid based on predefined ranges for each department.
- `isValidMatriculationNumber`: Checks if a matriculation number is valid based on a list of valid ranges.
- `endElection`: Ends the election and determines the winner(s) based on the candidate with the highest vote count.
- `getRemainingTime`: Retrieves the remaining time (in seconds) until the end of the election.
- `hasVotingEnded`: Checks if the voting period has ended.
- `hasVoted`: Checks if a voter has already voted based on their address.
- `compareStrings`: Compares two strings and checks if they are equal.
- `startsWith`: Checks if a string starts with a specific prefix.

