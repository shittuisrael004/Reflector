// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Script} from "forge-std/Script.sol";
import {Reflector} from "../src/Reflector.sol";

contract DeployScript is Script {
    Reflector public reflector;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        reflector = new Reflector();

        vm.stopBroadcast();
    }
}
