#!/bin/bash

# Storage Reading Script - Find the "private" variable!
# Usage: ./read-storage.sh <CONTRACT_ADDRESS>

set -e

if [ -z "$1" ]; then
    echo "❌ Usage: ./read-storage.sh <CONTRACT_ADDRESS>"
    echo "   Example: ./read-storage.sh 0x1234567890abcdef..."
    exit 1
fi

CONTRACT_ADDRESS=$1

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

source .env

echo "🔍 Reading storage slots from contract: $CONTRACT_ADDRESS"
echo "================================================================"
echo ""
echo "💡 Understanding Storage Layout:"
echo "   - Each variable is stored in a 32-byte slot"
echo "   - Variables are packed in order of declaration"
echo "   - We're looking for _youAreACheater = -42"
echo "   - In hex, -42 is: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6"
echo ""

# Read first 10 storage slots
for i in {0..9}; do
    echo "📦 Slot $i:"
    VALUE=$(cast storage $CONTRACT_ADDRESS $i --rpc-url $RPC_URL)
    echo "   Raw: $VALUE"
    
    # Try to decode as int256
    if [ "$VALUE" != "0x0000000000000000000000000000000000000000000000000000000000000000" ]; then
        # Convert to decimal (signed)
        DECIMAL=$(cast --to-dec $VALUE 2>/dev/null || echo "N/A")
        echo "   Decimal (unsigned): $DECIMAL"
        
        # Check if it's -42
        if [ "$VALUE" == "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6" ]; then
            echo "   🎯 FOUND IT! This is -42 (the 'private' _youAreACheater variable!)"
            echo ""
            echo "   🔐 Security Lesson:"
            echo "      'private' in Solidity doesn't mean hidden!"
            echo "      All blockchain data is public and readable!"
            echo "      NEVER store secrets on-chain!"
        fi
    fi
    echo ""
done

echo "================================================================"
echo "✅ Storage reading complete!"
echo ""
echo "📚 Storage Layout of SmartContract:"
echo "   Slot 0: myNumber (42)"
echo "   Slot 1: halfAnswerOfLife (21)"
echo "   Slot 2: myEthereumContractAddress"
echo "   Slot 3: myEthereumAddress"
echo "   Slot 4: poCIsWhat (string - stores length + data)"
echo "   Slot 5: owner (private!)"
echo "   Slot 6: _isActive + _areYouABadPerson (bool, packed)"
echo "   Slot 7: _secretAddress (private!)"
echo "   Slot 8: _youAreACheater = -42 (private! 🎯)"
echo "   ... and so on"
echo ""
