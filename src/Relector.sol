// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Reflector {
    address public owner;
    // 0.01 gwei expressed in wei
    uint256 public constant FEE_AMOUNT = 1e7; 
    // 1 gwei threshold
    uint256 public constant MIN_THRESHOLD = 1e9; 

    event RefundProcessed(address indexed user, uint256 refunded, uint256 feeKept);
    event Withdrawal(address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal {
        require(msg.sender == owner, "Not the owner");
    }

    receive() external payable {
        _handleRefund();
    }

    fallback() external payable {
        _handleRefund();
    }

    function _handleRefund() internal {
        uint256 incoming = msg.value;

        // Check if sent amount > 1 gwei
        if (incoming > MIN_THRESHOLD) {
            uint256 refundAmount = incoming - FEE_AMOUNT;

            // Send the refund (minus the 0.01 gwei fee)
            (bool success, ) = msg.sender.call{value: refundAmount}("");
            require(success, "Refund failed");

            emit RefundProcessed(msg.sender, refundAmount, FEE_AMOUNT);
        } else {
            // If less than 1 gwei, you can choose to revert or just keep it.
            // Reverting returns the ETH to the user but they still pay gas.
            revert("Amount below 1 gwei threshold");
        }
    }

    // Withdraw function for owner
    function withdraw(address _to) external onlyOwner {
        require(_to != address(0), "Cannot withdraw to zero address");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = _to.call{value: balance}("");
        require(success, "Withdrawal failed");

        emit Withdrawal(_to, balance);
    }

    // Getter for contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
