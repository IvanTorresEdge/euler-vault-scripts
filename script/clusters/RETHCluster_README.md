# rETH Cluster Deployment Guide

This guide covers testing and deploying the RETHCluster.s.sol script for Unichain.

## Overview

The rETH cluster creates two vaults:
- **rETH vault**: Users deposit rETH and receive erETH shares
- **WETH vault**: Users can borrow WETH using erETH shares as collateral

## Prerequisites

1. **Environment Setup**:
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Add Unichain RPC URL to .env
   echo "RPC_1301=https://mainnet.unichain.org" >> .env
   ```

2. **Install Dependencies**:
   ```bash
   ./install.sh
   ```

## Deployment Steps

### 1. Build and Compile

```bash
forge clean && forge compile
```

### 2. Calculate IRM Parameters (Already Done)

The WETH vault uses these pre-calculated IRM parameters:
- Base=0% APY, Slope1=3.29% APY/util%, Kink=90%, Slope2=100% APY/util%
- At 90% utilization: 2.96% APY (matches ETH staking rate)
- Values: `[0, 242621753, 71877928, 38654705]`

### 3. Testing Phase

**Dry run the cluster deployment**:
```bash
./script/ExecuteSolidityScript.sh script/clusters/RETHCluster.s.sol --dry-run --rpc-url $RPC_1301
```

This will:
- Verify all parameters are correct
- Check that IRM deployment succeeds
- Ensure oracle addresses resolve properly
- Simulate the full deployment without executing

### 4. Deployment Phase

**Deploy via Safe multisig** (recommended for production):
```bash
./script/ExecuteSolidityScript.sh script/clusters/RETHCluster.s.sol --batch-via-safe 0x4f894Bfc9481110278C356adE1473eBe2127Fd3C --rpc-url $RPC_1301
```

This will:
- Create a Safe transaction batch
- Propose the transaction to the multisig
- Require 3-of-5 signers to approve and execute

Alternative deployment options for testing:
```bash
# Using personal account (testing only)
./script/ExecuteSolidityScript.sh script/clusters/RETHCluster.s.sol --account <DEPLOYER> --rpc-url $RPC_1301

# Using ledger wallet
./script/ExecuteSolidityScript.sh script/clusters/RETHCluster.s.sol --ledger --rpc-url $RPC_1301
```

The deployment will:
- Deploy IRM contract for WETH vault
- Deploy both vaults (rETH and WETH)
- Configure all parameters per requirements
- Set up cross-vault collateral relationships

### 5. Verify Deployment

1. **Check deployment file**:
   ```bash
   cat output/1301/RETHCluster.json
   ```

2. **Verify contracts on Uniscan**:
   - Visit https://uniscan.xyz/
   - Check deployed vault addresses
   - Verify contract source code

3. **Test basic operations**:
   - Test rETH deposits
   - Test WETH borrowing against rETH collateral
   - Verify interest rate calculations

### 6. Post-deployment (Optional)

**Transfer governance** (if deployer is not final governor):
```bash
# This would require a separate governance transfer script
# Execute governance transfer to 3-of-5 multisig when ready
```

## Configuration Summary

### Vault Parameters
- **rETH Supply Cap**: 5,000 rETH (~$15M)
- **WETH Supply Cap**: Unlimited
- **rETH Borrow Cap**: 0 (no borrowing)
- **WETH Borrow Cap**: Unlimited

### Risk Parameters
- **Max Liquidation Discount**: 10%
- **Liquidation Cool-off**: 3 seconds (3 blocks)
- **Cross-vault LTV**: 98% borrow, 97% liquidation
- **Ramp Duration**: 24 hours

### Contract Addresses
- **Factory**: 0xbAd8b5BDFB2bcbcd78Cc9f1573D3Aad6E865e752
- **rETH Token**: address(0) - TODO: Update once rETH is deployed on Unichain
- **WETH Token**: 0x4200000000000000000000000000000000000006

### Governance
- **Governor**: 0x4f894Bfc9481110278C356adE1473eBe2127Fd3C
- **Fee Receiver**: Same as governor
- **Interest Fee**: 10%

### Oracle Configuration
- **WETH Oracle**: 0xF5C2DfD1740D18aD7cf23FBA76cc11d877802937 (RedStone)
- **rETH Oracle**: address(0) - TODO: Update once RedStone creates adapter

## Troubleshooting

### Common Issues

1. **Oracle Error**: If rETH oracle is address(0), the deployment may fail oracle verification
   - Solution: Update RETH_ORACLE_ADAPTER in AddressesUnichain.s.sol when available

2. **Insufficient Gas**: Large deployments may need higher gas limits
   - Solution: Add `--gas-limit 10000000` to deployment command

3. **RPC Issues**: Network connectivity problems
   - Solution: Try alternative RPC endpoints or check network status

### Getting Help

- Check deployment logs for specific error messages
- Verify all addresses are correct for Unichain network
- Ensure account has sufficient ETH for deployment gas costs

## Important Notes

- Always run `--dry-run` first to validate configuration
- The rETH oracle is currently set to address(0) - update when RedStone provides adapter
- This deployment is for Unichain mainnet (chain ID 1301)
- Keep the generated output/1301/RETHCluster.json file for future reference