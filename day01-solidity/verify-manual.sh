#!/bin/bash

# Manual Verification Helper Script
# Usage: ./verify-manual.sh <CONTRACT_ADDRESS>

set -e

if [ -z "$1" ]; then
    echo "❌ Usage: ./verify-manual.sh <CONTRACT_ADDRESS>"
    echo "   Example: ./verify-manual.sh 0x1234567890abcdef..."
    exit 1
fi

CONTRACT_ADDRESS=$1

echo "📝 Manual Verification Helper"
echo "============================="
echo ""
echo "Contract Address: $CONTRACT_ADDRESS"
echo ""

# Step 1: Flatten the contract
echo "Step 1: Flattening contract..."
forge flatten src/SmartContract.sol > SmartContract.flat.sol

if [ -f SmartContract.flat.sol ]; then
    echo "✅ Contract flattened to: SmartContract.flat.sol"
    echo ""
else
    echo "❌ Failed to flatten contract"
    exit 1
fi

# Step 2: Show Etherscan URL
echo "Step 2: Open Etherscan verification page:"
echo "🔗 https://sepolia.etherscan.io/address/$CONTRACT_ADDRESS#code"
echo ""

# Step 3: Show verification settings
echo "Step 3: Use these settings on Etherscan:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Compiler Type:      Solidity (Single file)"
echo "Compiler Version:   v0.8.20+commit.a1b79de6"
echo "Open Source License: MIT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Optimization Settings:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Optimization:       Yes"
echo "Runs:               200"
echo "EVM Version:        paris"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 4: Inform about the file
echo "Step 4: Paste the contents of SmartContract.flat.sol"
echo ""
echo "You can:"
echo "  1. Open SmartContract.flat.sol in your editor"
echo "  2. Copy all contents"
echo "  3. Paste into the Etherscan verification form"
echo ""
echo "Or use this command to copy to clipboard:"
echo "  cat SmartContract.flat.sol | xclip -selection clipboard"
echo "  (requires xclip: sudo apt install xclip)"
echo ""

# Step 5: Show file location
echo "✅ Flattened file ready at:"
echo "   $(pwd)/SmartContract.flat.sol"
echo ""
echo "📋 Next: Open the Etherscan link above and paste the file contents!"
echo ""
