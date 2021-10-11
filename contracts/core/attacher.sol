// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

interface plunder {
    function balanceOf(address) external view returns (uint256);
}

interface attributes {
    function point_buy(uint, uint32, uint32, uint32, uint32, uint32, uint32) external view;
}

contract plunder_attacher {

    address public plunderContractAddress;

    constructor(address _plunderContract) {
        require(plunderContractAddress == address(0x0), "already initialized");
        plunderContractAddress = _plunderContract;
    }

    function length(string calldata str) external pure returns (uint) {
        return bytes(str).length;
    }

    function slice(uint256 begin, uint256 end, string memory str) public pure returns (string memory) {
        bytes memory slicedStr = new bytes(end-begin+1);
        for(uint i=0; i<=end-begin; i++){
            slicedStr[i] = bytes(str)[i+begin-1];
        }
        return string(slicedStr);
    }

    function test(string calldata str) external pure returns (bool) {
        string memory bonus = "+1";
        string memory item = str;
        item = slice(length(str)-1, length(str), str);
        if (keccak256(str) == keccak256(bytes(bonus))) {
            return true;
        }
    }
}
