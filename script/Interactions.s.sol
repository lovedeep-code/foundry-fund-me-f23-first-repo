//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script,console} from "forge-std/Script.sol";
import{DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import{FundMe} from "../src/FundMe.sol";

uint256 constant SEND_VALUE = 0.01 ether;

contract FundFundMe is Script {

    function fundFundMe (address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value:SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run () external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

}

contract WithdrawFundMe is Script {
     function withdrawFundMe (address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        //console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run () external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }

}
