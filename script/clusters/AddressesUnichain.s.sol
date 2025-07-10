// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

abstract contract AddressesUnichain {
    address internal constant WETH = 0x4200000000000000000000000000000000000006;
    address internal constant rETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;
    address internal constant FACTORY = 0x8Ff1C814719096b61aBf00Bb46EAd0c9A529Dd7D;
    address internal constant GOVERNOR = 0x4f894Bfc9481110278C356adE1473eBe2127Fd3C;
    
    // Oracle adapters
    address internal constant WETH_ORACLE_ADAPTER = 0xF5C2DfD1740D18aD7cf23FBA76cc11d877802937;
    address internal constant RETH_ORACLE_ADAPTER = address(0); // TODO: Update once RedStone creates adapter
}