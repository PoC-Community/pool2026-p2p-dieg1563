#!/bin/bash

# 🚀 All-in-One Deployment Demo Script
# This script demonstrates the complete deployment workflow
# Note: This is for demonstration - you'll need to add your actual private key to .env

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║   🚀 SmartContract Deployment & Transparency Demo             ║"
echo "║                                                                ║"
echo "║   Exercise 03: Deployment & Blockchain Transparency           ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Function to print section headers
print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Check prerequisites
print_header "📋 Step 1: Prerequisites Check"

echo "Checking Foundry installation..."
if ! command -v forge &> /dev/null; then
    echo "❌ Foundry not found! Please install: https://getfoundry.sh"
    exit 1
fi
echo "✅ Foundry installed: $(forge --version | head -n1)"
echo ""

echo "Checking if tests pass..."
forge test -vv
if [ $? -eq 0 ]; then
    echo "✅ All tests pass!"
else
    echo "❌ Tests failed! Fix errors before deploying."
    exit 1
fi

# Check .env
print_header "⚙️  Step 2: Environment Configuration"

if [ ! -f .env ]; then
    echo "⚠️  No .env file found!"
    echo ""
    echo "📝 Creating .env from template..."
    cp .env.example .env
    echo ""
    echo "❗ IMPORTANT: Edit .env and add your:"
    echo "   1. PRIVATE_KEY (from MetaMask)"
    echo "   2. Optionally: ETHERSCAN_API_KEY"
    echo ""
    echo "   nano .env  # or use your favorite editor"
    echo ""
    echo "Then run this script again!"
    exit 0
else
    echo "✅ .env file exists"
    source .env
    
    if [ -z "$PRIVATE_KEY" ] || [ "$PRIVATE_KEY" == "your_private_key_here_without_0x_prefix" ]; then
        echo "❌ PRIVATE_KEY not configured in .env"
        echo "   Edit .env and add your private key"
        exit 1
    fi
    
    echo "✅ PRIVATE_KEY configured"
    echo "✅ RPC_URL: $RPC_URL"
    
    if [ ! -z "$ETHERSCAN_API_KEY" ] && [ "$ETHERSCAN_API_KEY" != "your_etherscan_api_key_here" ]; then
        echo "✅ ETHERSCAN_API_KEY configured (will auto-verify)"
        VERIFY_FLAG="--verify --etherscan-api-key $ETHERSCAN_API_KEY"
    else
        echo "⚠️  No Etherscan API key (will need manual verification)"
        VERIFY_FLAG=""
    fi
fi

# Show what will be deployed
print_header "📄 Step 3: Contract Overview"

echo "Contract: SmartContract.sol"
echo "Location: src/SmartContract.sol"
echo ""
echo "Key variables we'll verify on-chain:"
echo "  • myNumber = 42 (public)"
echo "  • halfAnswerOfLife = 21 (public)"
echo "  • _youAreACheater = -42 (private 🔒 but readable!)"
echo ""

# Confirm deployment
print_header "🚀 Step 4: Deployment"

read -p "Deploy to Sepolia testnet? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "🔨 Compiling and deploying..."
echo ""

# Deploy
DEPLOY_OUTPUT=$(forge create src/SmartContract.sol:SmartContract \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  $VERIFY_FLAG 2>&1)

echo "$DEPLOY_OUTPUT"

# Extract contract address
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep "Deployed to:" | awk '{print $3}')

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo "❌ Failed to extract contract address"
    exit 1
fi

echo ""
echo "✅ Deployment successful!"
echo ""
echo "📝 Contract Address: $CONTRACT_ADDRESS"

# Save to file
echo $CONTRACT_ADDRESS > .deployed-address
echo "   (Saved to .deployed-address)"
echo ""

# Show Etherscan link
print_header "🔍 Step 5: View on Etherscan"

ETHERSCAN_URL="https://sepolia.etherscan.io/address/$CONTRACT_ADDRESS"
echo "🔗 Etherscan: $ETHERSCAN_URL"
echo ""

# Verification
if [ -z "$VERIFY_FLAG" ]; then
    print_header "📝 Step 6: Manual Verification"
    echo "Contract needs to be verified manually."
    echo ""
    echo "Run: ./verify-manual.sh $CONTRACT_ADDRESS"
    echo ""
else
    echo "✅ Contract should be auto-verified (check Etherscan)"
    echo ""
fi

# The hack!
print_header "🔓 Step 7: The Transparency Hack"

echo "Now let's prove that 'private' doesn't mean hidden!"
echo ""
echo "We'll read the storage slots to find _youAreACheater = -42"
echo ""

read -p "Read storage slots now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔍 Reading storage..."
    echo ""
    ./read-storage.sh $CONTRACT_ADDRESS
fi

# Summary
print_header "🎓 Summary"

echo "✅ Contract deployed: $CONTRACT_ADDRESS"
echo "🔗 Etherscan: $ETHERSCAN_URL"
echo ""
echo "📚 Key Learnings:"
echo "  1. ✅ Deployed to Sepolia testnet"
echo "  2. ✅ Verified on Etherscan (or ready to verify)"
echo "  3. ✅ Read 'private' variables using storage slots"
echo "  4. ✅ Understand: private ≠ hidden!"
echo ""
echo "🔐 Security Lesson:"
echo "  ALL blockchain data is public and readable!"
echo "  Never store secrets on-chain!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🏆 Achievement Unlocked: Blockchain Transparency Master +200 XP"
echo ""
echo "➡️  Next: Exercise 04 - Gas Optimization"
echo ""
