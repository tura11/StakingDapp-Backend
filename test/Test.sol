// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StakingDapp} from "../src/Staking.sol";

contract StakingDappTest is Test {
    StakingDapp public stakingDapp;
    address newOwner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address user = address(0x976EA74026E726554dB657fA54763abd0C3a0aa9);
    function setUp() public {
        stakingDapp = new StakingDapp();
        
        
    }

    function testOwnerIsMsgSender() public {
        assertEq(stakingDapp.getOwner(), address(this));
    }
    function testMinUSDToStake() public {
        uint256 minVal= stakingDapp.MIN_VALUE();
        assertEq(minVal, 1 ether );
    }
    function testMinStakeTime() public {
        uint256 minStake = stakingDapp.minStakeTime();
        assertEq(minStake, 30 days);
    }
    function testTransferOwnership() public {
        //assertEq(stakingDapp.getOwner(), address(this));
        vm.startPrank(address(this));
        stakingDapp.transferOwnership(newOwner);
        assertEq(stakingDapp.getOwner(), newOwner); 
        vm.stopPrank();
    }
    function testUserCanStake() public {
        //assertEq(stakingDapp.s_stakes(user), 0);
        vm.deal(user, 1 ether);        
        vm.startPrank(user);
        stakingDapp.stake{value: 1 ether}();
        vm.stopPrank();
        assertEq(stakingDapp.s_stakes(user), 1 ether);


        
    }



}
