// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// Custom Errors
error ZeroAmount();
error InsufficientShares();
error ZeroShares();
error NoStakers();

contract Vault is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable asset;
    uint256 public totalShares;
    mapping(address => uint256) public sharesOf;

    // Events
    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Withdraw(address indexed user, uint256 assets, uint256 shares);
    event RewardAdded(uint256 amount);

    constructor(address _asset) Ownable(msg.sender) {
        asset = IERC20(_asset);
    }

    function _convertToShares(uint256 assets) internal view returns (uint256) {
        uint256 total = asset.balanceOf(address(this));
        
        // Edge case: first deposit (vault is empty)
        if (totalShares == 0) {
            return assets;
        }
        
        // Formula: shares = (assets × totalShares) / total
        // Multiply before dividing to preserve precision
        return (assets * totalShares) / total;
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        uint256 total = asset.balanceOf(address(this));
        
        // Edge case: no shares exist
        if (totalShares == 0) {
            return 0;
        }
        
        // Formula: assets = (shares × total) / totalShares
        // Multiply before dividing to preserve precision
        return (shares * total) / totalShares;
    }

    function deposit(uint256 assets) external nonReentrant returns (uint256 shares) {
        // C - CHECKS
        if (assets == 0) revert ZeroAmount();
        
        shares = _convertToShares(assets);
        if (shares == 0) revert ZeroShares();

        // E - EFFECTS
        sharesOf[msg.sender] += shares;
        totalShares += shares;

        // I - INTERACTIONS
        asset.safeTransferFrom(msg.sender, address(this), assets);

        emit Deposit(msg.sender, assets, shares);
    }

    function withdraw(uint256 shares) public nonReentrant returns (uint256 assets) {
        // C - CHECKS
        if (shares == 0) revert ZeroAmount();
        if (sharesOf[msg.sender] < shares) revert InsufficientShares();

        // E - EFFECTS
        assets = _convertToAssets(shares);
        sharesOf[msg.sender] -= shares;
        totalShares -= shares;

        // I - INTERACTIONS
        asset.safeTransfer(msg.sender, assets);

        emit Withdraw(msg.sender, assets, shares);
    }

    function withdrawAll() public returns (uint256 assets) {
        assets = withdraw(sharesOf[msg.sender]);
    }

    function previewDeposit(uint256 assets) external view returns (uint256) {
        return _convertToShares(assets);
    }

    function previewWithdraw(uint256 shares) external view returns (uint256) {
        return _convertToAssets(shares);
    }

    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function currentRatio() external view returns (uint256) {
        uint256 total = totalAssets();
        
        // If no shares exist, return default 1:1 ratio
        if (totalShares == 0) {
            return 1e18;
        }
        
        // Ratio = total assets / total shares, scaled by 1e18
        return (total * 1e18) / totalShares;
    }

    function assetsOf(address user) external view returns (uint256) {
        return _convertToAssets(sharesOf[user]);
    }

    function addReward(uint256 amount) external onlyOwner nonReentrant {
        // CHECKS
        if (amount == 0) revert ZeroAmount();
        if (totalShares == 0) revert NoStakers();

        // INTERACTIONS
        asset.safeTransferFrom(msg.sender, address(this), amount);

        // EFFECTS
        emit RewardAdded(amount);
    }
}
