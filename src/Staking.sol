// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StakingDapp is ReentrancyGuard {
    address public owner;
    mapping(address => uint256) public s_stakes;
    mapping(address => uint256) public s_stakesTimeStamps;

    uint256 public minStakeTime = 30 days;
    uint256 public constant MIN_VALUE = 1 ether;
    uint256 public constant EARLY_WITHDRAW_PENALTY = 50;
    bool public paused = false;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);
    event Paused(bool isPaused);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event RewardWithdrawn(address indexed user, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier notPaused() {
        require(!paused, "Staking is paused");
        _;
    }

    modifier hasStaked() {
        require(s_stakes[msg.sender] > 0, "No staked funds");
        _;
    }

    modifier hasEnoughETH(uint256 _amount) {
        require(msg.value >= _amount, "Not enough ETH");
        _;
    }

    constructor() payable {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function pauseStaking() public onlyOwner {
        paused = !paused;
        emit Paused(paused);
    }

    function stake() public payable notPaused hasEnoughETH(MIN_VALUE) {
        s_stakes[msg.sender] += msg.value;
        s_stakesTimeStamps[msg.sender] = block.timestamp;
        emit Staked(msg.sender, msg.value);
    }

    function addStake() public payable notPaused hasEnoughETH(MIN_VALUE) hasStaked {
        s_stakes[msg.sender] += msg.value;
        s_stakesTimeStamps[msg.sender] = block.timestamp;
        emit Staked(msg.sender, msg.value);
    }

    function getReward(address _user) public view returns (uint256) {
        uint256 stakedAmount = s_stakes[_user];
        if (stakedAmount == 0) return 0;
        uint256 stakingDuration = block.timestamp - s_stakesTimeStamps[_user];
        return calculateReward(stakedAmount, stakingDuration);
    }

    function unstake() public hasStaked nonReentrant {
        require(block.timestamp >= s_stakesTimeStamps[msg.sender] + minStakeTime, "Staking duration is too short");
        uint256 stakedAmount = s_stakes[msg.sender];
        uint256 stakingDuration = block.timestamp - s_stakesTimeStamps[msg.sender];

        uint256 reward = calculateReward(stakedAmount, stakingDuration);
        if (stakingDuration < minStakeTime) {
            uint256 penalty = (reward * EARLY_WITHDRAW_PENALTY) / 100;
            reward -= penalty;
        }

        uint256 totalAmount = stakedAmount + reward;
        s_stakes[msg.sender] = 0;
        s_stakesTimeStamps[msg.sender] = 0;

        require(address(this).balance >= totalAmount, "Not enough contract balance");
        payable(msg.sender).transfer(totalAmount);

        emit Unstaked(msg.sender, stakedAmount, reward);
    }

    function calculateReward(uint256 _amount, uint256 _duration) public pure returns (uint256) {
        uint256 yearlyReward;

        if (_duration <= 30 days) {
            yearlyReward = (_amount * 2) / 100; // 2% rocznie
        } else if (_duration <= 90 days) {
            yearlyReward = (_amount * 5) / 100; // 5% rocznie
        } else if (_duration <= 180 days) {
            yearlyReward = (_amount * 10) / 100; // 10% rocznie
        } else if (_duration <= 365 days) {
            yearlyReward = (_amount * 12) / 100; // 12% rocznie
        } else if (_duration <= 730 days) {
            yearlyReward = (_amount * 15) / 100; // 15% rocznie
        } else {
            yearlyReward = (_amount * 20) / 100; // 20% rocznie
        }

        uint256 reward = (yearlyReward * _duration) / 365 days;
        return reward;
    }

    function setMinStakeTime(uint256 _time) public onlyOwner {
        require(_time >= 7 days, "Minimum stake time too low");
        minStakeTime = _time;
    }

    function userGetStakeInfo(address _user)
        external
        view
        returns (uint256 stakedAmount, uint256 reward, uint256 stakingTime)
    {
        return (s_stakes[_user], getReward(_user), s_stakesTimeStamps[_user]);
    }

    function depositRewards() external payable onlyOwner {}

    function getOwner() public view returns (address) {
        return owner;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
