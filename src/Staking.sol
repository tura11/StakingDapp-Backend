// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract StakingDapp{

    mapping(address => uint256) public s_stakes;
    mapping(address => uint256) public s_stakesTimeStamps;

    uint256 public constant MIN_VALUE = 1 ether;
    uint256 public constant REWARD_RATE = 10;
    uint256 public constant MIN_STAKE_TIME = 30 days;
    uint256 public constant EARLY_WITHDRAW_PENALTY = 50;
    bool public paused = false;


    modifier notPaused(){
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

    function pauseStaking() public {
        paused = !paused; 
    }


    function stake() public payable notPaused hasEnoughETH(MIN_VALUE) {
        require(msg.value >= MIN_VALUE,"Not enough ETH");
        s_stakes[msg.sender] += msg.value;
        s_stakesTimeStamps[msg.sender] = block.timestamp;
    }

    function unstake() public hasStaked(){
        uint256 stakedAmount = s_stakes[msg.sender];
        require(stakedAmount > 0, "No funds to unstake");
        uint256 stakingDuration = block.timestamp - s_stakesTimeStamps[msg.sender];
        require(stakingDuration >= MIN_STAKE_TIME, "Cannot unstake before 30 days");
        
        uint256 reward = calculateReward(stakedAmount, stakingDuration);
         if(stakingDuration < MIN_STAKE_TIME){
            uint256 penalty = (reward * EARLY_WITHDRAW_PENALTY) / 100;
            reward -= penalty;
            
        }


        uint256 totalAmount = stakedAmount + reward;
        s_stakes[msg.sender] = 0;

        payable(msg.sender).transfer(totalAmount);
        
        s_stakesTimeStamps[msg.sender] = 0;
    }

   function calculateReward(uint256 _amount, uint256 _duration) internal pure returns (uint256) {
    uint256 yearlyReward;
    
    if (_duration <= 30 days) {
                yearlyReward = (_amount * 2) / 100; // 5% rocznie
            } else if (_duration <= 90 days) {
                yearlyReward = (_amount * 5) / 100; // 7% rocznie
            } else if (_duration <= 180 days) {
                yearlyReward = (_amount * 10) / 100; // 10% rocznie
            } else if (_duration <= 365 days) {
                yearlyReward = (_amount * 12) / 100; // 12% rocznie
            } else if(_duration <= 730 days){
                yearlyReward = (_amount * 15) / 100; // 15% rocznie
            }else{
                yearlyReward = (_amount * 20) /100;
            }
            uint256 reward = (yearlyReward * _duration) / (365 days);
        return reward;
    }


}


