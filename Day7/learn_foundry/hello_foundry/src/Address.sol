// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * Important: 
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account (EOA)
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and accounts where contracts lived but were destroyed.
        
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
