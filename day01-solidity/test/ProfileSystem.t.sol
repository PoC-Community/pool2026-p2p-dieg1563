// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ProfileSystem.sol";

contract ProfileTest is Test {
    ProfileSystem public system;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        system = new ProfileSystem();
    }

    // ========== testCreateProfile ==========
    /**
     * @notice Verify that a user can create a profile with correct name and level
     */
    function testCreateProfile() public {
        vm.startPrank(user1);
        system.createProfile("Alice");

        // Read from public mapping
        (string memory name, uint256 level, , ) = system.profiles(user1);

        assertEq(name, "Alice");
        assertEq(level, 1);
        vm.stopPrank();
    }

    // ========== testCannotCreateEmptyProfile ==========
    /**
     * @notice Expect revert when trying to create profile with empty username
     */
    function testCannotCreateEmptyProfile() public {
        vm.startPrank(user1);
        vm.expectRevert(ProfileSystem.EmptyUsername.selector);
        system.createProfile("");
        vm.stopPrank();
    }

    // ========== testCannotCreateDuplicateProfile ==========
    /**
     * @notice Expect revert when trying to create profile if one already exists
     */
    function testCannotCreateDuplicateProfile() public {
        vm.startPrank(user1);
        system.createProfile("Alice");

        // Try to create another profile for same user
        vm.expectRevert(ProfileSystem.UserAlreadyExists.selector);
        system.createProfile("Bob");
        vm.stopPrank();
    }

    // ========== testLevelUp ==========
    /**
     * @notice Verify that a registered user can level up
     */
    function testLevelUp() public {
        vm.startPrank(user1);
        system.createProfile("Alice");

        // Verify initial level is 1
        (, uint256 initialLevel, , ) = system.profiles(user1);
        assertEq(initialLevel, 1);

        // Level up
        system.levelUp();

        // Verify level is now 2
        (, uint256 newLevel, , ) = system.profiles(user1);
        assertEq(newLevel, 2);

        // Level up again
        system.levelUp();

        // Verify level is now 3
        (, uint256 finalLevel, , ) = system.profiles(user1);
        assertEq(finalLevel, 3);
        vm.stopPrank();
    }

    // ========== testCannotLevelUpIfNotRegistered ==========
    /**
     * @notice Expect revert when trying to level up without a profile
     */
    function testCannotLevelUpIfNotRegistered() public {
        vm.startPrank(user1);
        vm.expectRevert(ProfileSystem.UserNotRegistered.selector);
        system.levelUp();
        vm.stopPrank();
    }

    // ========== Bonus: Test Event Emission ==========
    /**
     * @notice Verify that ProfileCreated event is emitted
     */
    function testProfileCreatedEventEmission() public {
        vm.startPrank(user1);

        vm.expectEmit(true, false, false, true);
        emit ProfileSystem.ProfileCreated(user1, "Alice");
        system.createProfile("Alice");

        vm.stopPrank();
    }

    /**
     * @notice Verify that LevelUp event is emitted
     */
    function testLevelUpEventEmission() public {
        vm.startPrank(user1);
        system.createProfile("Alice");

        vm.expectEmit(true, false, false, true);
        emit ProfileSystem.LevelUp(user1, 2);
        system.levelUp();

        vm.stopPrank();
    }

    // ========== Additional Tests ==========
    /**
     * @notice Verify that role is set to USER on creation
     */
    function testProfileRoleIsUser() public {
        vm.startPrank(user1);
        system.createProfile("Alice");

        (, , ProfileSystem.Role role, ) = system.profiles(user1);
        assertEq(uint256(role), uint256(ProfileSystem.Role.USER));
        vm.stopPrank();
    }

    /**
     * @notice Verify that lastUpdated is set to block.timestamp
     */
    function testProfileLastUpdatedTimestamp() public {
        vm.startPrank(user1);
        uint256 expectedTime = block.timestamp;
        system.createProfile("Alice");

        (, , , uint256 lastUpdated) = system.profiles(user1);
        assertEq(lastUpdated, expectedTime);
        vm.stopPrank();
    }

    /**
     * @notice Verify that lastUpdated is updated on levelUp
     */
    function testLastUpdatedOnLevelUp() public {
        vm.startPrank(user1);
        system.createProfile("Alice");

        (, , , uint256 createdTime) = system.profiles(user1);

        // Warp time forward
        vm.warp(block.timestamp + 1000);

        system.levelUp();

        (, , , uint256 updatedTime) = system.profiles(user1);
        assertEq(updatedTime, block.timestamp);
        assertNotEq(createdTime, updatedTime);
        vm.stopPrank();
    }

    /**
     * @notice Verify multiple users can have profiles independently
     */
    function testMultipleUsersIndependentProfiles() public {
        vm.startPrank(user1);
        system.createProfile("Alice");
        vm.stopPrank();

        vm.startPrank(user2);
        system.createProfile("Bob");
        vm.stopPrank();

        // Verify user1's profile
        (string memory name1, uint256 level1, , ) = system.profiles(user1);
        assertEq(name1, "Alice");
        assertEq(level1, 1);

        // Verify user2's profile
        (string memory name2, uint256 level2, , ) = system.profiles(user2);
        assertEq(name2, "Bob");
        assertEq(level2, 1);
    }
}
