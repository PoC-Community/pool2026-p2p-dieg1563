// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ISmartContract {
    enum roleEnum {
        STUDENT,
        TEACHER
    }

    struct Information {
        string firstName;
        string lastName;
        uint8 age;
        string city;
        roleEnum role;
    }

    event BalanceUpdated(address indexed user, uint256 newBalance);

    error InsufficientBalance(uint256 available, uint256 requested);

    function myNumber() external view returns (uint256);
    function halfAnswerOfLife() external view returns (uint256);
    function myEthereumContractAddress() external view returns (address);
    function myEthereumAddress() external view returns (address);
    function poCIsWhat() external view returns (string memory);

    function myGrades(string calldata key) external view returns (uint256);
    function myPhoneNumber(uint256 index) external view returns (string memory);
    function myInformations()
        external
        view
        returns (string memory, string memory, uint8, string memory, roleEnum);

    function getHalfAnswerOfLife() external view returns (uint256);
    function getPoCIsWhat() external view returns (string memory);
    function completeHalfAnswerOfLife() external;
    function hashMyMessage(string calldata _message) external pure returns (bytes32);
    function editMyCity(string calldata _newCity) external;
    function getMyFullName() external view returns (string memory);

    function balances(address user) external view returns (uint256);
    function getMyBalance() external view returns (uint256);
    function addToBalance() external payable;
    function withdrawFromBalance(uint256 _amount) external;
}
