// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// interfaces
import "../_ERCs/IERC1271.sol";
import "../_ERCs/IERC725X.sol";

// modules
import "../../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

// libraries
import "../../node_modules/@openzeppelin/contracts/cryptography/ECDSA.sol";

contract SimpleKeyManager is ERC165, IERC1271 {

    bytes4 internal constant _INTERFACE_ID_ERC1271 = 0x1626ba7e;
    bytes4 internal constant _ERC1271FAILVALUE = 0xffffffff;

    address public owner;
    IERC725X public Profile;
    mapping(address => bool) public allowedExecutor;

    event Executed(uint256 _operationType, address _to, uint256 _value, bytes _data);


    constructor(address _account, address _owner)
    public
    payable {
        owner = _owner;
        // make owner an executor
        allowedExecutor[owner] = true;

        // allow self execution
        allowedExecutor[_account] = true;
        Profile = IERC725X(_account);

        _registerInterface(_INTERFACE_ID_ERC1271);
    }

    function addExecutor(address exec, bool allowed)
    external
    onlyOwner
    {
        allowedExecutor[exec] = allowed;
    }

    function execute(uint256 _operationType, address _to, uint256 _value, bytes calldata _data)
    external
    onlyExecutor
    {
        Profile.execute(_operationType, _to, _value, _data);
        emit Executed(_operationType, _to, _value, _data);
    }

    /**
    * @notice Checks if an owner signed `_data`.
    * ERC1271 interface.
    *
    * @param _hash hash of the data signed//Arbitrary length data signed on the behalf of address(this)
    * @param _signature owner's signature(s) of the data
    */
    function isValidSignature(bytes32 _hash, bytes memory _signature)
    override
    public
    view
    returns (bytes4 magicValue)
    {
        address recoveredAddress = ECDSA.recover(_hash, _signature);

        return (allowedExecutor[recoveredAddress] || recoveredAddress == owner)
            ? _INTERFACE_ID_ERC1271
            : _ERC1271FAILVALUE;
    }

    /* Modifiers */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this method");
        _;
    }
    modifier onlyExecutor() {
        require(allowedExecutor[msg.sender], "Only a valid executor can call this method");
        _;
    }
}
