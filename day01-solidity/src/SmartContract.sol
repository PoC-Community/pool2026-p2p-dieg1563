// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SmartContract {
    // Public - auto-generates a getter function
    uint256 public myNumber = 42;
    uint256 public halfAnswerOfLife = 21;
    address public myEthereumContractAddress = address(this);
    address public myEthereumAddress = msg.sender;
    string public poCIsWhat = "PoC is good, PoC is life.";

    bool internal _isActive = true;
    bool internal _areYouABadPerson = false;

    address private _secretAddress;
    int256 private _youAreACheater = -42;

    bytes32 whoIsTheBest;
    mapping(string => uint256) public myGrades;
    string[5] public myPhoneNumber;

    enum roleEnum { STUDENT,TEACHER }

    struct Information {
        string firstName;
        string lastName;
        uint8 age;
        string city;
        roleEnum role;
    }

    Information public myInformations;
}