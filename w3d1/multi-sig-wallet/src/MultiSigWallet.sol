// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    address[] public owners;
    uint public signatureThreshold;

    struct TransactionProposal {
        address destination;
        uint value;
        bool executed;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    uint public proposalCount;
    mapping(uint => TransactionProposal) public proposals;

    event ProposalSubmitted(uint indexed proposalId, address indexed destination, uint value);
    event ProposalApproved(uint indexed proposalId, address indexed approver);
    event ProposalExecuted(uint indexed proposalId);

    modifier onlyOwners() {
        require(isOwner(msg.sender), "Not an owner");
        _;
    }

    modifier proposalExists(uint _proposalId) {
        require(_proposalId < proposalCount, "Proposal does not exist");
        _;
    }

    modifier notExecuted(uint _proposalId) {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        _;
    }

    modifier notApproved(uint _proposalId) {
        require(!proposals[_proposalId].approvals[msg.sender], "Already approved");
        _;
    }

    constructor(address[] memory _owners) {
        require(_owners.length > 0, "Owners required");
        owners = _owners;
        signatureThreshold = _owners.length / 2 + 1;
    }

    function isOwner(address _addr) public view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    function propose(address _destination, uint _value) public onlyOwners {
        TransactionProposal storage newProposal = proposals[proposalCount];
        newProposal.destination = _destination;
        newProposal.value = _value;
        newProposal.executed = false;
        newProposal.approvalCount = 1;  // Automatically count proposer as approver
        newProposal.approvals[msg.sender] = true;

        emit ProposalSubmitted(proposalCount, _destination, _value);
        emit ProposalApproved(proposalCount, msg.sender);
        proposalCount++;
    }

    function approve(uint _proposalId)
        public
        onlyOwners
        proposalExists(_proposalId)
        notExecuted(_proposalId)
        notApproved(_proposalId)
    {
        TransactionProposal storage proposal = proposals[_proposalId];
        proposal.approvals[msg.sender] = true;
        proposal.approvalCount++;

        emit ProposalApproved(_proposalId, msg.sender);

        if (proposal.approvalCount >= signatureThreshold) {
            execute(_proposalId);
        }
    }

    function execute(uint _proposalId)
        public
        proposalExists(_proposalId)
        notExecuted(_proposalId)
    {
        TransactionProposal storage proposal = proposals[_proposalId];
        require(proposal.approvalCount >= signatureThreshold, "Not enough approvals");

        proposal.executed = true;
        (bool success, ) = proposal.destination.call{value: proposal.value}("");
        require(success, "Transaction failed");

        emit ProposalExecuted(_proposalId);
    }

    receive() external payable {}
}
