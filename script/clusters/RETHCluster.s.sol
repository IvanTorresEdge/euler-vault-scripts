// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {ManageClusterBase} from "evk-periphery-scripts/production/ManageClusterBase.s.sol";
import {OracleVerifier} from "evk-periphery-scripts/utils/SanityCheckOracle.s.sol";
import "./AddressesUnichain.s.sol";

contract RETHCluster is ManageClusterBase, AddressesUnichain {
    function defineCluster() internal override {
        cluster.clusterAddressesPath = "/output/1301/RETHCluster.json";

        // rETH vault for deposits, WETH vault for borrowing
        cluster.assets = [
            rETH,
            WETH
        ];
    }

    function configureCluster() internal override {
        // Set governors to the multisig
        cluster.oracleRoutersGovernor = GOVERNOR;
        cluster.vaultsGovernor = GOVERNOR;

        // Use WETH as unit of account for ETH-pegged assets
        cluster.unitOfAccount = WETH;

        // Fee configuration - 10% interest fee goes to governor
        cluster.feeReceiver = GOVERNOR;
        cluster.interestFee = 0.1e4;

        // Liquidation parameters from requirements
        cluster.maxLiquidationDiscount = 0.10e4; // 10%
        cluster.liquidationCoolOffTime = 3; // 3 seconds (3 blocks)

        // No hooks needed
        cluster.hookTarget = address(0);
        cluster.hookedOps = 0;

        // Socialize bad debt
        cluster.configFlags = 0;

        // Oracle providers
        cluster.oracleProviders[rETH] = vm.toString(RETH_ORACLE_ADAPTER);
        cluster.oracleProviders[WETH] = vm.toString(WETH_ORACLE_ADAPTER);

        // Supply caps: 5000 rETH, unlimited WETH
        cluster.supplyCaps[rETH] = 5_000;
        cluster.supplyCaps[WETH] = type(uint256).max;

        // Borrow caps: no rETH borrowing, unlimited WETH borrowing
        cluster.borrowCaps[rETH] = 0;
        cluster.borrowCaps[WETH] = type(uint256).max;

        // IRM parameters - only WETH needs IRM (rETH not borrowable)
        {
            // Base=0% APY, Slope1=4% APY/util%, Kink=90%, Slope2=100% APY/util%
            uint256[4] memory irmWETH = [uint256(0), uint256(295071094), uint256(71401597), uint256(38654705)];
            cluster.kinkIRMParams[WETH] = irmWETH;
        }

        // LTV configuration
        cluster.rampDuration = 1 days; // 24 hours
        cluster.spreadLTV = 0.01e4; // 1% spread between borrow and liquidation LTV

        // LTV matrix: rETH collateral can borrow WETH at 97% liquidation LTV
        cluster.ltvs = [
            // [WETH vault] [rETH vault]
            [uint16(0.97e4), uint16(0.00e4)],  // rETH collateral can borrow WETH at 97% LTV
            [uint16(0.00e4), uint16(0.00e4)]   // WETH collateral can't borrow anything
        ];
    }

    function postOperations() internal view override {
        // Verify oracle config for each vault
        for (uint256 i = 0; i < cluster.vaults.length; ++i) {
            OracleVerifier.verifyOracleConfig(lensAddresses.oracleLens, cluster.vaults[i], false);
        }
    }
}