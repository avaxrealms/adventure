// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface plunder {
    function balanceOf(address) external view returns (uint256);
    function getChest(uint256) external view returns (string memory);
    function getHead(uint256) external view returns (string memory);
    function getFoot(uint256) external view returns (string memory);
    function getHand(uint256) external view returns (string memory);
    function getWeapon(uint256) external view returns (string memory);
}

interface attributes {
    function point_buy(uint, uint32, uint32, uint32, uint32, uint32, uint32) external view;
    function apply_plunder_bonus(uint, uint32, uint32, uint32) external;

}

contract plunder_attacher {

    address public plunderContractAddress;

    constructor(address _plunderContract) {
        require(plunderContractAddress == address(0x0), "already initialized");
        plunderContractAddress = _plunderContract;
    }

    function attach(uint256 tokenId) public {
        require(msg.sender == IERC721(plunderContractAddress).ownerOf(tokenId), "!owner");

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

    function contains (string memory what, string memory where) internal pure returns (bool found) {
        bytes memory whatBytes = bytes (what);
        bytes memory whereBytes = bytes (where);

        found = false;
        for (uint i = 0; i < whereBytes.length - whatBytes.length; i++) {
            bool flag = true;
            for (uint j = 0; j < whatBytes.length; j++)
                if (whereBytes [i + j] != whatBytes [j]) {
                    flag = false;
                    break;
                }
            if (flag) {
                found = true;
                break;
            }
        }
        require (found);
    }

    function containssuffix (string memory _str) external returns (bool) {
        contains(" of ", _str);
    }

    function test(string calldata str) external pure returns (bool) {
        string memory bonus = "+1";
        string memory item = str;
        uint len = bytes(item).length;
        item = slice(len-1, len, str);
        if (keccak256(abi.encodePacked(str)) == keccak256(bytes(bonus))) {
            return true;
        }
        else {
            return false;
        }
    }
}
