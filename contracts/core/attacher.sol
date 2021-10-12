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
    function ownerOf(uint256) external view returns (address);
}

interface attributes {
    function point_buy(uint, uint32, uint32, uint32, uint32, uint32, uint32) external view;
    function apply_plunder_bonus(uint, uint32, uint32) external;

}

contract plunder_attacher {

    address public plunderContractAddress;
    mapping(uint256 => address) public attached;

    plunder plunderContract;
    attributes attributesContract;

    constructor(plunder _plunderContract, attributes _attributesContract) {
        require(plunderContractAddress == address(0x0), "already initialized");
        plunderContract = _plunderContract;
        attributesContract = _attributesContract;
    }

    function attachPlunder(uint256 tokenId, uint _summoner) public {
        require(msg.sender == plunderContract.ownerOf(tokenId), "!owner");
        require(attached[tokenId] == address(0x0), "!attached");
        if (bonus(plunderContract.getHead(tokenId))) {
            attributesContract.apply_plunder_bonus(_summoner, 1, 0);
        }
    }

    function bonus(string memory _str) public pure returns (bool) {
        string memory item_bonus = "+1";
        string memory item = _str;
        uint len = bytes(item).length;
        item = slice(len-1, len, _str);
        if (keccak256(abi.encodePacked(item)) == keccak256(abi.encodePacked(item_bonus))) {
            return true;
        }
        else {
            return false;
        }
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

    function contains(string memory what, string memory where) internal pure returns (bool found) {
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

    function containsSuffix(string memory _str) external pure {
        contains(" of ", _str);
    }

}
