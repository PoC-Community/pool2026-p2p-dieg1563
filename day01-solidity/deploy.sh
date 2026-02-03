#!/bin/bash

# Deployment script for SmartContract on Sepolia
# Usage: ./deploy.sh

set -e  # Exit on error

echo "🚀 SmartContract Deployment Script"
echo "=================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "📝 Please create .env file with your credentials:"
    echo "   1. Copy .env.example to .env"
    echo "   2. Add your PRIVATE_KEY and RPC_URL"
    echo ""
    echo "   cp .env.example .env"
    echo "   nano .env  # or use your favorite editor"
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
if [ -z "$PRIVATE_KEY" ] || [ "$PRIVATE_KEY" == "your_private_key_here_without_0x_prefix" ]; then
    echo "❌ Error: PRIVATE_KEY not set in .env"
    echo "📝 Get your private key from MetaMask:"
    echo "   Menu → Account details → Show private key"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    echo "❌ Error: RPC_URL not set in .env"
    exit 1
fi

echo "✅ Environment variables loaded"
echo ""

# Check if we have Etherscan API key for verification
if [ -z "$ETHERSCAN_API_KEY" ] || [ "$ETHERSCAN_API_KEY" == "your_etherscan_api_key_here" ]; then
    echo "⚠️  No Etherscan API key found - deploying without verification"
    echo "   You can verify manually later using: forge flatten"
    echo ""
    
    # Deploy without verification
    echo "🔨 Compiling and deploying SmartContract..."
    forge create src/SmartContract.sol:SmartContract \
      --rpc-url $RPC_URL \
      --private-key $PRIVATE_KEY \
      --broadcast
else
    echo "✅ Etherscan API key found - will verify after deployment"
    echo ""
    
    # Deploy with verification
    echo "🔨 Compiling and deploying SmartContract..."
    forge create src/SmartContract.sol:SmartContract \
      --rpc-url $RPC_URL \
      --private-key $PRIVATE_KEY \
      --broadcast \
      --verify \
      --etherscan-api-key $ETHERSCAN_API_KEY
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Copy the deployed contract address from above"
echo "   2. Visit: https://sepolia.etherscan.io/address/<YOUR_ADDRESS>"
echo "   3. If not verified, run: forge flatten src/SmartContract.sol > SmartContract.flat.sol"
echo "   4. Try the storage hack to find the private variable!"
echo ""
