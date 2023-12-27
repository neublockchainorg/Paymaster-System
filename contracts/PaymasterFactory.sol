pragma solidity ^0.8.0;

import './EcommercePaymaster.sol';

contract PaymasterFactory {
    struct BusinessInfo {
        address paymasterAddress;
        string businessName;
    }

    mapping(address => BusinessInfo) public businessToPaymaster;
    address public owner;

    event PaymasterCreated(address indexed business, address paymaster, string businessName);

    constructor() {
        owner = msg.sender;
    }

    function createPaymaster(string memory businessName) public {
        ECommercePaymaster paymaster = new ECommercePaymaster();
        businessToPaymaster[msg.sender] = BusinessInfo(address(paymaster), businessName);
        emit PaymasterCreated(msg.sender, address(paymaster), businessName);
    }

    function getPaymaster(address business) public view returns (BusinessInfo memory) {
        return businessToPaymaster[business];
    }
}
