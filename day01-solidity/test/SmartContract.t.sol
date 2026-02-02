// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SmartContract.sol";

// Helper contract to test internal functions
contract SmartContractHelper is SmartContract {
    function getMyEthereumContractAddress() public view returns (address) {
        return _getMyEthereumContractAddress();
    }

    function setAreYouABadPerson(bool _value) public {
        _setAreYouABadPerson(_value);
    }

    function getAreYouABadPerson() public view returns (bool) {
        return _areYouABadPerson;
    }

    function getIsActive() public view returns (bool) {
        return _isActive;
    }
}

contract SmartContractTest is Test {
    SmartContract public smartContract;
    SmartContractHelper public helperContract;

    function setUp() public {
        smartContract = new SmartContract();
        helperContract = new SmartContractHelper();
    }

    // Test for getHalfAnswerOfLife()
    function test_GetHalfAnswerOfLife() public {
        uint256 result = smartContract.getHalfAnswerOfLife();
        assertEq(result, 21, "halfAnswerOfLife should be 21");
    }

    // Test for getHalfAnswerOfLife() - alternative assertion
    function test_GetHalfAnswerOfLifeIsCorrect() public {
        assertEq(smartContract.getHalfAnswerOfLife(), smartContract.halfAnswerOfLife(), "getHalfAnswerOfLife should return halfAnswerOfLife");
    }

    // Test for internal variable access via helper
    function test_GetMyEthereumContractAddressViaHelper() public {
        address contractAddress = helperContract.getMyEthereumContractAddress();
        assertEq(contractAddress, address(helperContract), "Should return the contract's own address");
    }

    // Test for internal variable _areYouABadPerson via helper
    function test_GetAreYouABadPersonViaHelper() public {
        bool result = helperContract.getAreYouABadPerson();
        assertEq(result, false, "_areYouABadPerson should be false initially");
    }

    // Test for internal variable _isActive via helper
    function test_GetIsActiveViaHelper() public {
        bool result = helperContract.getIsActive();
        assertEq(result, true, "_isActive should be true initially");
    }

    // Test for setting internal variable via helper
    function test_SetAreYouABadPersonViaHelper() public {
        helperContract.setAreYouABadPerson(true);
        bool result = helperContract.getAreYouABadPerson();
        assertEq(result, true, "_areYouABadPerson should be true after setting");
    }

    // Test for struct data - default values
    function test_StructDataDefaultValues() public {
        (
            string memory firstName,
            string memory lastName,
            uint8 age,
            string memory city,
            SmartContract.roleEnum role
        ) = smartContract.myInformations();

        assertEq(bytes(firstName).length, 0, "firstName should be empty");
        assertEq(bytes(lastName).length, 0, "lastName should be empty");
        assertEq(age, 0, "age should be 0");
        assertEq(bytes(city).length, 0, "city should be empty");
        assertTrue(role == SmartContract.roleEnum.STUDENT, "role should be STUDENT (default)");
    }

    // Additional test for public variables
    function test_PublicVariables() public {
        assertEq(smartContract.myNumber(), 42, "myNumber should be 42");
        assertEq(smartContract.halfAnswerOfLife(), 21, "halfAnswerOfLife should be 21");
        assertEq(smartContract.myEthereumContractAddress(), address(smartContract), "myEthereumContractAddress should be contract address");
        assertEq(smartContract.poCIsWhat(), "PoC is good, PoC is life.", "poCIsWhat should match");
    }

    // Test getPoCIsWhat external function
    function test_GetPoCIsWhat() public {
        string memory result = smartContract.getPoCIsWhat();
        assertEq(result, "PoC is good, PoC is life.", "getPoCIsWhat should return correct string");
    }
}
