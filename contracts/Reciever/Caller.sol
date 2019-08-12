pragma solidity 0.5.10;

import "./BareReciever/UniversalReciever.sol";
import "./TypedReciever/Reciever.sol";

contract Caller {

    event Trace(bytes da);
    function callBareTokenReciever(address _to) external {
        UniversalReciever ur = UniversalReciever(_to);
        bytes memory data = abi.encodePacked(address(msg.sender), address(_to), uint(100));
        bytes32 hash = keccak256(abi.encodePacked("Token"));
        emit Trace(data);
        ur.recieve(hash, data);
    }

    function callTypedTokenReciever(address _to) external {
        UniversalReciever ur = UniversalReciever(_to);
        bytes memory data = abi.encodePacked(address(msg.sender), address(_to), uint(100));
        bytes32 hash = keccak256(abi.encodePacked(uint(1)));
        emit Trace(data);
        ur.recieve(hash, data);
    }
}