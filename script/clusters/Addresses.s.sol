// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

abstract contract Addresses {
    address internal constant WETH = 0x4200000000000000000000000000000000000006;
    address internal constant rETH = 0x94Cac393f3444cEf63a651FfC18497E7e8bd036a;
    address internal constant FACTORY = 0xbAd8b5BDFB2bcbcd78Cc9f1573D3Aad6E865e752;

    address internal constant GOVERNOR = 0x4f894Bfc9481110278C356adE1473eBe2127Fd3C;
    
    // Oracle adapters
    address internal constant WETH_ORACLE_ADAPTER = 0xF5C2DfD1740D18aD7cf23FBA76cc11d877802937;
    address internal constant RETH_ORACLE_ADAPTER = 0x48b2f620a0D9768f510DaB4347355b89F3C60886;
}