// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { EmbraceProfile } from "../src/EmbraceProfile.sol";

// forge script script/DeployProfile.s.sol:DeployScript --rpc-url $RPC_URL_MUMBAI --broadcast --verify -vvvv

contract DeployScript is Script {
    address internal deployer;
    EmbraceProfile internal embraceProfile;

    function setUp() public virtual {
        string memory mnemonic = vm.envString("MNEMONIC");
        (deployer,) = deriveRememberKey(mnemonic, 0);
    }

    function run() public {
        vm.startBroadcast(deployer);

        embraceProfile = new EmbraceProfile("EmbraceProfile", "EMBRACE_PROFILE");

        console.log("CONTRACT_ADDRESS_PROFILE=\"%s\"", address(embraceProfile));

        vm.stopBroadcast();
    }
}
