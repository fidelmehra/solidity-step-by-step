// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title HelloWorld - Step 1: Basic Solidity Contract
/// @author Fidel Mehra
/// @notice Demonstrates state variables, constructor, getter/setter
contract HelloWorld {
    // State variable stored on-chain
    string private message;
    address public owner;

    // Emitted whenever message changes
    event MessageUpdated(address indexed by, string newMessage);

    /// @notice Deploy with an initial message
    constructor(string memory _message) {
        message = _message;
        owner = msg.sender;
    }

    /// @notice Update the stored message (anyone can call)
    function setMessage(string memory _newMessage) external {
        message = _newMessage;
        emit MessageUpdated(msg.sender, _newMessage);
    }

    /// @notice Read the current message
    function getMessage() external view returns (string memory) {
        return message;
    }

    /// @notice Returns contract balance (always 0 here - no payable)
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
