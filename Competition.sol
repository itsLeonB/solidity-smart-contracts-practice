/**
 *Submitted for verification at Sepolia.Arbiscan.io on 2024-10-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Competition
 */
contract Competition {

    mapping(address => bool) public installed; 
    mapping(address => bool) public inJail;
    mapping(address => string) public names; 
    mapping(address => uint) public points;
    address[] public participants; 

    address public owner;
    bool public started;

    uint latestBlock = 0;
    uint public jailDelay = 720;
    uint public extraPoints = 3000;
    uint public shot = 5000;

    modifier onlyParticipant() {
        require(installed[msg.sender] == true, "Only participants can call this function!");
        require(started, "Must wait for the game to begin!");
        _;
    }

    modifier onlyOwner() { 
        require(msg.sender == owner, "Only owner can install Participants.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Admin can add a participant
    function addParticipant(address _participant, string memory _name) public {
        require(msg.sender == owner, "Only owner can install Participants.");
        participants.push(_participant);
        installed[_participant] = true;
        names[_participant] = _name;
    }

    function register(string memory _name) public {
        require(!started, "You can only register if the game has not yet started.");
        require(!installed[msg.sender], "Participant should not yet be installed.");
        participants.push(msg.sender);
        installed[msg.sender] = true;
        names[msg.sender] = _name;
    }

    function getAllParticipantInfo() public view returns (
        address[] memory currParticipants,
        bool[] memory currInstalled,
        bool[] memory currInJail,
        string[] memory currName,
        uint[] memory currPoints
    ) {
        
        currParticipants = new address[](participants.length);
        currInstalled = new bool[](participants.length);
        currInJail = new bool[](participants.length);
        currName = new string[](participants.length);
        currPoints = new uint[](participants.length);

        for(uint i=0; i<participants.length; ++i) {
            address participant = participants[i];
            currParticipants[i] = participant;
            currInstalled[i] = installed[participant];
            currInJail[i] = inJail[participant];
            currName[i] = names[participant];
            currPoints[i] = points[participant];
        }
    }

    // Only admin can start the game 
    function startGame() public onlyOwner() {
        started = true;
    }

    // Only admin can finish the game 
    function endGame() public onlyOwner() {
        started = false;
    }

    // Reset game, so people can play again. 
    function resetGame() public onlyOwner() {

        for(uint i=0; i<participants.length; i++) {
            address participant = participants[i];
            installed[participant] = false;
            inJail[participant] = false;
            names[participant] = "";
            points[participant] = 0;
        }

        delete participants;
        latestBlock = 0;
        started = false;
    }

    /** 
     * Game functions below. 
     * Your goal is to gain maximum points and be number 1 on the board! 
     */

    function getOutOfJail() public onlyParticipant() {
        inJail[msg.sender] = false;
    }

    function beaconPoints() public onlyParticipant() {
        latestBlock = block.number;
        points[msg.sender] = points[msg.sender] + _beacon(); 
    }

    function slamDunk(address _victim) public onlyParticipant() { 
        _registered(_victim);
        if(points[_victim]>50000) {
            points[_victim] = 0;
        }
    }

    function whack(address _victim) public onlyParticipant() {
        _registered(_victim);
        unchecked {
            points[_victim] = points[_victim] - _beacon();
        }
    }

    function givePoints(address _other) public onlyParticipant() {
        require(msg.sender != _other, "You cannot give points to yourself.");
        _registered(_other);
        points[_other] = points[_other] + extraPoints; 
    }

    function putInJail(address _victim) public onlyParticipant() { 
        require(block.number > latestBlock + jailDelay, "Must wait at least JailDelay blocks before you can put someone in Jail.");
        _registered(_victim);

        inJail[_victim] = true;
        latestBlock = block.number;
    }

    function rapidShoot() public onlyParticipant() {
        uint beacon = _beacon();

        for(uint i=0; i<participants.length; i++) {
            if(msg.sender != participants[i]) {
                uint shoot = uint(keccak256(abi.encode(beacon, i))) % 2;
                if(shoot == 0) {
                    unchecked {
                        points[participants[i]] = points[participants[i]] - shot;
                    }
                }
            }
        }
    }

    function _beacon() internal view returns (uint) { 
        bytes32 hash = blockhash(block.number-1); 
        uint beacon = uint(hash) % 1000; 
        return beacon; 
    }

    function _registered(address _participant) public view {
        require(installed[_participant], "Participant is not registered.");
    }
}