// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract IDOContract {
    address public owner;
    IERC20 public token; // The ERC20 Token for presale
    uint256 public presalePrice; // Presale price (ETH per Token)
    uint256 public goal; // Fundraising goal (ETH)
    uint256 public maxCap; // Hard cap (ETH)
    uint256 public endTime; // End time of the presale
    uint256 public totalEthRaised; // Total ETH raised so far
    bool public presaleActive; // Status of the presale

    mapping(address => uint256) public ethContributions; // ETH contributions by each user
    mapping(address => bool) public claimed; // Track if users have claimed their tokens

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier presaleOngoing() {
        require(presaleActive, "Presale not active");
        require(block.timestamp < endTime, "Presale has ended");
        _;
    }

    modifier presaleEnded() {
        require(block.timestamp >= endTime, "Presale has not ended yet");
        _;
    }

    // Start the presale
    function startPresale(
        IERC20 _token,
        uint256 _presalePrice,
        uint256 _goal,
        uint256 _maxCap,
        uint256 _duration
    ) external onlyOwner {
        require(!presaleActive, "Presale already active");
        require(_goal > 0 && _maxCap >= _goal, "Invalid goal or maxCap");
        require(_duration > 0, "Invalid duration");

        token = _token;
        presalePrice = _presalePrice;
        goal = _goal;
        maxCap = _maxCap;
        endTime = block.timestamp + _duration;
        presaleActive = true;
    }

    // Participate in the presale by sending ETH
    function participate() external payable presaleOngoing {
        require(msg.value > 0, "Cannot contribute zero ETH");
        require(totalEthRaised + msg.value <= maxCap, "Exceeds maxCap");

        ethContributions[msg.sender] += msg.value;
        totalEthRaised += msg.value;
    }

    // Claim tokens after presale ends if it succeeded
    function claimTokens() external presaleEnded {
        require(totalEthRaised >= goal, "Presale failed");
        require(!claimed[msg.sender], "Already claimed");

        uint256 contribution = ethContributions[msg.sender];
        require(contribution > 0, "No contribution");

        uint256 tokenAmount = (contribution * 1e18) / presalePrice; // Number of tokens based on presale price (assuming 18 decimals for token)
        require(token.balanceOf(address(this)) >= tokenAmount, "Not enough tokens");

        claimed[msg.sender] = true;
        token.transfer(msg.sender, tokenAmount);
    }

    // Claim refund after presale ends if it failed
    function claimRefund() external presaleEnded {
        require(totalEthRaised < goal, "Presale succeeded");
        
        uint256 contribution = ethContributions[msg.sender];
        require(contribution > 0, "No contribution");

        ethContributions[msg.sender] = 0;
        // Use `call` to transfer ETH and handle possible failure gracefully
        (bool success, ) = payable(msg.sender).call{value: contribution}("");
        require(success, "ETH transfer failed");
    }

    // Withdraw raised ETH if the presale succeeded
    function withdraw() external onlyOwner presaleEnded {
        require(totalEthRaised >= goal, "Presale failed");

        // Get the contract's current balance
        uint256 balance = address(this).balance;
        
        // Use call to send the balance to the owner
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "ETH transfer failed");
    }

    // End the presale manually in case of emergencies
    function endPresale() external onlyOwner {
        presaleActive = false;
        endTime = block.timestamp;
    }
}
