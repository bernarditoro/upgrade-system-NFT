// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/UpgradeSystemNFT.sol";

contract UpgradeSystemNFTTest is Test {
    UpgradeSystemNFT private upgradeSystemNFT;
    address private owner;
    address private user;

    function setUp() public {
        owner = address(this);
        user = address(0x1234);
        upgradeSystemNFT = new UpgradeSystemNFT(owner);
    }

    function testMint() public {
        upgradeSystemNFT.mint(user);
        assertEq(upgradeSystemNFT.ownerOf(0), user);
        assertEq(upgradeSystemNFT.getLevel(0), 0);
    }

    function testUpgrade() public {
        upgradeSystemNFT.mint(user);
        upgradeSystemNFT.setUpgradeCost(1, 1 ether);

        vm.deal(user, 1 ether);

        vm.prank(user);
        upgradeSystemNFT.upgrade{value: 1 ether}(0);

        assertEq(upgradeSystemNFT.getLevel(0), 1);
    }

    function testUpgradeInsufficientFunds() public {
        upgradeSystemNFT.mint(user);
        upgradeSystemNFT.setUpgradeCost(1, 1 ether);

        vm.deal(user, 0.5 ether);

        vm.prank(user);
        vm.expectRevert(UpgradeSystemNFT.UpgradeSystemNFT__INSUFFICIENT_FUNDS_FOR_UPGRADE.selector);
        upgradeSystemNFT.upgrade{value: 0.5 ether}(0);
    }

    function testUpgradeNotOwner() public {
        upgradeSystemNFT.mint(user);
        upgradeSystemNFT.setUpgradeCost(1, 1 ether);

        vm.deal(address(0x5678), 1 ether);

        vm.prank(address(0x5678));
        vm.expectRevert(UpgradeSystemNFT.UpgradeSystemNFT__ONLY_OWNER_CAN_UPGRADE.selector);
        upgradeSystemNFT.upgrade{value: 1 ether}(0);
    }

    function testTokenURI() public {
        upgradeSystemNFT.mint(user);
        string memory expectedURI = "https://api.upgradesystemnft.com/metadata_0.json";
        assertEq(upgradeSystemNFT.tokenURI(0), expectedURI);
    }
}
