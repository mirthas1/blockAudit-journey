// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureVaultAuditDemo {
    // State variables (storage)
    address public owner;
    mapping(address => uint) public balances;        // user -> available balance
    mapping(address => Deposit[]) private deposits; // user -> list of deposits
    mapping(address => Commit) private commits;     // for commit-reveal
    bool private locked;                             // simple reentrancy guard

    // Structs
    struct Deposit {
        uint amount;
        uint timestamp;
        uint index;
    }

    struct Commit {
        uint stake;
        bytes32 hash;    // commitment
        uint timestamp;
        bool revealed;
    }

    // Events
    event DepositMade(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event OwnerWithdrew(address indexed to, uint amount);
    event Committed(address indexed user, bytes32 hash);
    event Revealed(address indexed user, uint value);

    // Constructor: sets owner
    constructor() {
        owner = msg.sender;
        locked = false;
    }

    // Modifier: only owner can run
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Modifier: non-reentrant (checks + effect + interaction pattern enforced by locked flag)
    modifier noReentrant() {
        require(!locked, "Reentrant");
        locked = true;
        _;
        locked = false;
    }

    // -----------------------
    // Ether receiving functions
    // -----------------------

    // fallback receives plain calls with data if payable
    fallback() external payable {
        // Accept funds when a call does not match any function signature
        balances[msg.sender] += msg.value;
        deposits[msg.sender].push(Deposit(msg.value, block.timestamp, deposits[msg.sender].length));
        emit DepositMade(msg.sender, msg.value);
    }

    // receive receives plain ETH sent without data
    receive() external payable {
        balances[msg.sender] += msg.value;
        deposits[msg.sender].push(Deposit(msg.value, block.timestamp, deposits[msg.sender].length));
        emit DepositMade(msg.sender, msg.value);
    }

    // Explicit deposit function (payable)
    function deposit() external payable {
        require(msg.value > 0, "Zero deposit");
        balances[msg.sender] += msg.value;
        deposits[msg.sender].push(Deposit(msg.value, block.timestamp, deposits[msg.sender].length));
        emit DepositMade(msg.sender, msg.value);
    }

    // Withdraw pattern: checks -> effects -> interactions and non-reentrant
    function withdraw(uint amount) external noReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Effects
        balances[msg.sender] -= amount;

        // Interaction
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // Owner-level withdrawal (example of privileged function)
    function ownerWithdraw(address payable to, uint amount) external onlyOwner noReentrant {
        require(address(this).balance >= amount, "Contract low");
        // Effects (none needed on balances for owner withdraw)
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "Owner transfer failed");
        emit OwnerWithdrew(to, amount);
    }

    // -----------------------
    // Read helpers (view)
    // -----------------------

    function getDepositCount(address user) external view returns (uint) {
        return deposits[user].length;
    }

    function getDeposit(address user, uint idx) external view returns (uint amount, uint timestamp, uint index) {
        Deposit memory d = deposits[user][idx]; // copy to memory for safe read
        return (d.amount, d.timestamp, d.index);
    }

    function contractBalance() external view returns (uint) {
        return address(this).balance;
    }

    // -----------------------
    // Commit-Reveal (mitigate front-running)
    // -----------------------

    // Commit: user sends stake and a hash(commit)
    function commit(bytes32 hash) external payable {
        require(msg.value > 0, "Must stake");
        commits[msg.sender] = Commit(msg.value, hash, block.timestamp, false);
        emit Committed(msg.sender, hash);
    }

    // Reveal: user reveals plaintext that hashes to the committed value
    function reveal(uint value, string calldata nonce) external {
        Commit storage c = commits[msg.sender];
        require(c.stake > 0, "No commit");
        require(!c.revealed, "Already revealed");
        bytes32 expected = keccak256(abi.encodePacked(value, nonce, msg.sender));
        require(expected == c.hash, "Hash mismatch");

        c.revealed = true; // mark revealed (effect)
        // Example outcome: credit value to user's balance
        balances[msg.sender] += c.stake + value;
        emit Revealed(msg.sender, value);

        // delete commit to free storage (gas refund potential)
        delete commits[msg.sender];
    }

    // -----------------------
    // Example showing unchecked (possible overflow risks pre-0.8) and assert usage
    // -----------------------

    // Multiply with unchecked (illustrates how overflow would be allowed inside unchecked)
    function unsafeMultiply(uint a, uint b) external pure returns (uint) {
        unchecked {
            return a * b;
        }
    }

    // Function demonstrating assert (should be used for invariants)
    function invariantCheck() external view {
        // example invariant: total contract balance >= sum of user balances
        // Here we can't compute sum cheaply on-chain, but imagine we had a tracking variable. Use assert for developer errors.
        // assert(someInvariantCondition);
    }

    // -----------------------
    // Admin: change owner (example of access control)
    // -----------------------
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}
