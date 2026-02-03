pragma solidity ^0.8.20;

import "./interfaces/ISmartContract.sol";

contract SmartContract is ISmartContract {
    uint256 public myNumber = 42;
    uint256 public halfAnswerOfLife = 21;
    address public myEthereumContractAddress = address(this);
    address public myEthereumAddress = msg.sender;
    string public poCIsWhat = "PoC is good, PoC is life.";

    address private owner;

    bool internal _isActive = true;
    bool internal _areYouABadPerson = false;

    address private _secretAddress;
    int256 private _youAreACheater = -42;

    bytes32 whoIsTheBest;
    mapping(string => uint256) public myGrades;
    string[5] public myPhoneNumber;

    mapping(address => uint256) public balances;

    Information public myInformations;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

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

    /**
     * @notice Completes halfAnswerOfLife by adding 21
     */
    function completeHalfAnswerOfLife() public onlyOwner {
        halfAnswerOfLife += 21;
    }

    /**
     * @notice Hashes a message using keccak256
     */
    function hashMyMessage(string calldata _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    /**
     * @notice Updates myInformations.city
     */
    function editMyCity(string calldata _newCity) public {
        myInformations.city = _newCity;
    }

    /**
     * @notice Returns full name: firstName + " " + lastName
     */
    function getMyFullName() public view returns (string memory) {
        return string(
            abi.encodePacked(myInformations.firstName, " ", myInformations.lastName)
        );
    }

    /**
     * @notice Returns the caller's balance
     */
    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    /**
     * @notice Adds ETH to the caller's balance
     */
    function addToBalance() public payable {
        balances[msg.sender] += msg.value;
        emit BalanceUpdated(msg.sender, balances[msg.sender]);
    }

    /**
     * @notice Withdraws ETH from the caller's balance
     */
    function withdrawFromBalance(uint256 _amount) public {
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance(balances[msg.sender], _amount);
        }

        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");

        emit BalanceUpdated(msg.sender, balances[msg.sender]);
    }
}