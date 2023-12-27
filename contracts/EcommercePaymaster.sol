pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

struct UserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;
    bytes callData;
    uint256 callGasLimit;
    uint256 verificationGasLimit;
    uint256 preVerificationGas;
    uint256 maxFeePerGas;
    uint256 maxPriorityFeePerGas;
    bytes paymasterAndData;
    bytes signature;
}

contract ECommercePaymaster is Ownable {
    uint256 public minimumOrderAmount;
    mapping(address => uint256) public userBalances;

    event GasFeeSponsored(address user, uint256 gasValue);

    constructor() Ownable(msg.sender) {}

    function setMinimumOrderAmount(uint256 amount) external onlyOwner {
        minimumOrderAmount = amount;
    }

    function deposit() external payable onlyOwner {
        userBalances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        userBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function _validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 requestId,
        uint256 maxCost
    ) external view returns (bytes memory context) {
        uint256 userTransactionAmount;
        (userTransactionAmount) = abi.decode(userOp.callData, (uint256));

        require(
            userTransactionAmount >= minimumOrderAmount,
            "Transaction amount is less than the minimum required"
        );

        // Use abi.encode instead of abi.encodePacked
        return abi.encode(userOp);
    }

    function _postOp(
        bytes calldata context,
        bool success,
        uint256 actualGasCost
    ) external {
        if (success) {
            UserOperation memory userOp = abi.decode(context, (UserOperation));
            address user = userOp.sender;
            userBalances[user] -= actualGasCost;
            emit GasFeeSponsored(user, actualGasCost);
        }
    }
}
