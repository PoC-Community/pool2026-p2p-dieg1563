pragma solidity ^0.8.20;

contract SmartContract {
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

    /**
     * @notice Returns halfAnswerOfLife
     * @dev TODO: Return the value of halfAnswerOfLife
     */
    function getHalfAnswerOfLife() public view returns (uint256) {
        return halfAnswerOfLife;
    }

    /**
     * @notice Returns the contract address (internal)
     * @dev TODO: Return myEthereumContractAddress
     */
    function _getMyEthereumContractAddress() internal view returns (address) {
        return myEthereumContractAddress;
    }

    /**
     * @notice Returns PoCIsWhat (external only)
     * @dev TODO: Return PoCIsWhat with memory keyword for string
     */
    function getPoCIsWhat() external view returns (string memory) {
        return poCIsWhat;
    }

    /**
     * @notice Sets _areYouABadPerson (internal)
     * @dev TODO: Update the internal variable
     */
    function _setAreYouABadPerson(bool _value) internal {
        _areYouABadPerson = _value;
    }
}