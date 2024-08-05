// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external{
    //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    DeployFundMe deployFundMe = new DeployFundMe();
    //deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(USER,STARTING_VALUE);
    }

    function testMinimumDollarIsFive() public view {
        uint256 expectedMinimumUSD = 5 * 10 ** 18;
        assertEq(fundMe.MINIMUM_USD(), expectedMinimumUSD, "Minimum USD should be 5 ether equivalent");
    } //assertEq(fundMe.MINIMUM_USD, 5 * 10 ** 18);

    function testOwnerIsMsgSender() public view {
        //console.log(fundMe.i_owner());
        //console.log(msg.sender);
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        //uint256 cat = 1;
        fundMe.fund();
    }

     modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded{
        //vm.prank(USER);
        //fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public funded {
        //vm.prank(USER);
        //fundMe.fund{value:SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        //vm.prank(USER);
        //fundMe.fund{value: SEND_VALUE}();

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        //arrange 
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.prank (fundMe.getOwner());
        fundMe.withdraw();

        //assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++){
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
         uint256 startingOwnerBalance = fundMe.getOwner().balance;
         uint256 startingFundMeBalance = address(fundMe).balance;

         uint256 gasStart = gasleft();
         vm.txGasPrice(GAS_PRICE);
         vm.startPrank(fundMe.getOwner());
         fundMe.withdraw();
         vm.stopPrank();
         uint256 gasEnd = gasleft();
         uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
         console.log (gasUsed);

         assertEq(address(fundMe).balance, 0);
         assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++){
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
         uint256 startingOwnerBalance = fundMe.getOwner().balance;
         uint256 startingFundMeBalance = address(fundMe).balance;

         uint256 gasStart = gasleft();
         vm.txGasPrice(GAS_PRICE);
         vm.startPrank(fundMe.getOwner());
         fundMe.cheaperWithdraw();
         vm.stopPrank();
         uint256 gasEnd = gasleft();
         uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
         console.log (gasUsed);

         assertEq(address(fundMe).balance, 0);
         assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }
}