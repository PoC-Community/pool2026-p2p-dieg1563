# 🚀 Quick Start - Deployment Commands

## Before You Deploy

1. **Run all tests:**
```bash
forge test -vv
```

2. **Get Sepolia ETH** from faucet:
   - https://www.alchemy.com/faucets/ethereum-sepolia
   - https://sepolia-faucet.pk910.de/

3. **Setup .env:**
```bash
cp .env.example .env
nano .env  # Add your PRIVATE_KEY and RPC_URL
source .env
```

## Deploy

### Easy way (recommended):
```bash
./deploy.sh
```

### Manual way:
```bash
# With Etherscan verification
forge create src/SmartContract.sol:SmartContract \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY

# Without verification
forge create src/SmartContract.sol:SmartContract \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## After Deployment

### View on Etherscan:
```
https://sepolia.etherscan.io/address/<YOUR_CONTRACT_ADDRESS>
```

### Verify manually (if needed):
```bash
forge flatten src/SmartContract.sol > SmartContract.flat.sol
# Then paste contents on Etherscan verification page
```

## The Storage Hack 🔍

### Find the "private" variable:
```bash
./read-storage.sh <YOUR_CONTRACT_ADDRESS>
```

### Or manually:
```bash
# Read slot 8 (where _youAreACheater = -42 is stored)
cast storage <CONTRACT_ADDRESS> 8 --rpc-url $RPC_URL

# Expected result: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6
# This is -42 in two's complement hex!
```

## 🔐 Key Security Lesson

**`private` in Solidity does NOT mean hidden!**

All blockchain data is public and readable by anyone using tools like `cast storage`.

Never store sensitive data on-chain:
- ❌ Passwords
- ❌ API keys
- ❌ Private keys
- ❌ Personal information

## 📚 Full Documentation

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions and troubleshooting.

---

**Questions?** Check the troubleshooting section in DEPLOYMENT.md
