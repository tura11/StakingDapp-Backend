// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {StakingDapp} from "../src/Staking.sol";

contract Deploy is Script{
    function run() external returns(StakingDapp){
        vm.startBroadcast();
        StakingDapp stakingDapp = new StakingDapp();
        vm.stopBroadcast();
        return stakingDapp;
    }
    
}
