// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    IERC20 public immutable asset;
    uint256 public totalShares;
    mapping(address => uint256) public sharesOf;

    constructor(address _asset) {
        asset = IERC20(_asset);
    }

    function _convertToShares(uint256 assets) internal view returns (uint256) {
        uint256 totalAssets = asset.balanceOf(address(this));
        
        // Edge case: first deposit (vault is empty)
        if (totalShares == 0) {
            return assets;
        }
        
        // Formula: shares = (assets × totalShares) / totalAssets
        // Multiply before dividing to preserve precision
        return (assets * totalShares) / totalAssets;
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        uint256 totalAssets = asset.balanceOf(address(this));
        
        // Edge case: no shares exist
        if (totalShares == 0) {
            return 0;
        }
        
        // Formula: assets = (shares × totalAssets) / totalShares
        // Multiply before dividing to preserve precision
        return (shares * totalAssets) / totalShares;
    }
}
