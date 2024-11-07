// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/StorageSlot.sol";

contract UUPSProxy {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    
    bytes32 internal constant _OWNER_SLOT = 
        bytes32(uint256(keccak256("eip1967.proxy.owner")) - 1);

    event Upgraded(address indexed implementation);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    error NotOwner();
    error InvalidImplementation();
    error InvalidOwner();

    constructor(address implementation) {
        _setImplementation(implementation);
        _setOwner(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    fallback() external payable {
        _delegate(_getImplementation());
    }

    receive() external payable {
        _delegate(_getImplementation());
    }

    function _getImplementation() public view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address implementation) internal {
        if(implementation.code.length == 0) revert InvalidImplementation();
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = implementation;
        emit Upgraded(implementation);
    }

    function getOwner() external view returns (address) {
        return StorageSlot.getAddressSlot(_OWNER_SLOT).value;
    }

    function _setOwner(address newOwner) internal {
        if(newOwner == address(0)) revert InvalidOwner();
        StorageSlot.getAddressSlot(_OWNER_SLOT).value = newOwner;
    }

    function upgradeTo(address newImplementation) external {
        if(msg.sender != StorageSlot.getAddressSlot(_OWNER_SLOT).value) revert NotOwner();
        _setImplementation(newImplementation);
    }
}