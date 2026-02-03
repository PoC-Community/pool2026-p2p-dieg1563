// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProfileSystem {
    // ========== ENUMS ==========
    enum Role {
        GUEST,
        USER,
        ADMIN
    }

    // ========== STRUCTS ==========
    struct UserProfile {
        string username;
        uint256 level;
        Role role;
        uint256 lastUpdated;
    }

    // ========== MAPPINGS ==========
    mapping(address => UserProfile) public profiles;

    // ========== CUSTOM ERRORS ==========
    error UserAlreadyExists();
    error EmptyUsername();
    error UserNotRegistered();

    // ========== EVENTS ==========
    event ProfileCreated(address indexed user, string username);
    event LevelUp(address indexed user, uint256 newLevel);

    // ========== MODIFIERS ==========
    /**
     * @notice Modifier that checks if user has a profile
     * @dev Revert with UserNotRegistered if profiles[msg.sender].level == 0
     */
    modifier onlyRegistered() {
        if (profiles[msg.sender].level == 0) {
            revert UserNotRegistered();
        }
        _;
    }

    // ========== FUNCTIONS ==========
    /**
     * @notice Create a new user profile
     * @param _name The username (cannot be empty)
     * @dev Creates a profile with:
     *   - username: _name
     *   - level: 1
     *   - role: Role.USER
     *   - lastUpdated: block.timestamp
     */
    function createProfile(string calldata _name) external {
        // Check for empty username
        if (bytes(_name).length == 0) {
            revert EmptyUsername();
        }

        // Check if user already has a profile
        if (profiles[msg.sender].level != 0) {
            revert UserAlreadyExists();
        }

        // Create new profile
        profiles[msg.sender] = UserProfile({
            username: _name,
            level: 1,
            role: Role.USER,
            lastUpdated: block.timestamp
        });

        // Emit event
        emit ProfileCreated(msg.sender, _name);
    }

    /**
     * @notice Increase user level by 1
     * @dev Must be called by a registered user
     *   - Increments profiles[msg.sender].level by 1
     *   - Updates lastUpdated to block.timestamp
     */
    function levelUp() external onlyRegistered {
        profiles[msg.sender].level += 1;
        profiles[msg.sender].lastUpdated = block.timestamp;

        emit LevelUp(msg.sender, profiles[msg.sender].level);
    }
}
