// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface plunder {
    function balanceOf(address) external view returns (uint256);
    function getChest(uint256) external view returns (string memory);
    function getHead(uint256) external view returns (string memory);
    function getFoot(uint256) external view returns (string memory);
    function getHand(uint256) external view returns (string memory);
    function getNeck(uint256) external view returns (string memory);
    function getWeapon(uint256) external view returns (string memory);
    function ownerOf(uint256) external view returns (address);
    function transferFrom(address, address, uint256) external;
    function getApproved(uint256) external view returns (address);
}

interface attributes {
    function point_buy(uint, uint32, uint32, uint32, uint32, uint32, uint32) external view;
    function attribute_increment(uint, uint32, uint32, uint32, uint32, uint32, uint32) external;
    function attribute_decrement(uint, uint32, uint32, uint32, uint32, uint32, uint32) external;
}

interface adventure {
    function ownerOf(uint256) external view returns (address);
}

contract plunder_attacher is AccessControl, Pausable {

    address public plunderContractAddress;
    mapping(uint256 => sAttached) public attachedPlunders;
    mapping(uint => bool) public summonerAttached;
    mapping(uint => uint256) public summonerAttachedTo;

    plunder plunderContract;
    attributes attributesContract;
    adventure adventureContract;

    struct sAttached {
        address owner;
        uint summonerId;
        bool attached;
    }

    bytes32 public constant MANAGER = keccak256("MANAGER");

    constructor(plunder _plunderContract, adventure _adventureContract, attributes _attributesContract) {
        plunderContract = _plunderContract;
        adventureContract = _adventureContract;
        attributesContract = _attributesContract;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function slice(uint256 begin, uint256 end, string memory str) public pure returns (string memory) {
        bytes memory slicedStr = new bytes(end-begin+1);
        for(uint i=0; i<=end-begin; i++){
            slicedStr[i] = bytes(str)[i+begin-1];
        }
        return string(slicedStr);
    }

    function attachPlunder(uint256 tokenId, uint _summoner) public whenNotPaused() {
        require(
            msg.sender == plunderContract.ownerOf(tokenId) ||
            msg.sender == plunderContract.getApproved(tokenId),
            "!ownerPlunder"
        );
        require(msg.sender == adventureContract.ownerOf(_summoner), "!ownerSummoner");
        require(attachedPlunders[tokenId].attached != true, "!attached");
        require(summonerAttached[_summoner] != true, "!attached");

        attachedPlunders[tokenId].summonerId = _summoner;
        attachedPlunders[tokenId].owner = msg.sender;
        summonerAttachedTo[_summoner] = tokenId;
        summonerAttached[_summoner] = true;

        plunderContract.transferFrom(msg.sender, address(this), tokenId);

        modifyAttributes(_summoner, tokenId, 1, true);
    }

    function detachPlunder(uint256 tokenId) public whenNotPaused() {
        require(attachedPlunders[tokenId].owner == msg.sender, "!owner");

        plunderContract.transferFrom(address(this), msg.sender, tokenId);
        summonerAttached[attachedPlunders[tokenId].summonerId] = false;
        attachedPlunders[tokenId].attached = false;

        summonerAttachedTo[_summoner] = 10001;
        modifyAttributes(attachedPlunders[tokenId].summonerId, tokenId, 1, false);
    }

    function isAttached(uint256 tokenId) external view returns (bool) {
        return summonerAttached[tokenId];
    }

    function modifyAttributes(uint _summoner, uint256 tokenId, uint32 _base_bonus, bool increase) internal returns (bool bIncrease) {
        uint32 str_bonus = 0;
        uint32 dex_bonus = 0;

        dex_bonus += bonus(plunderContract.getHead(tokenId));
        dex_bonus += bonus(plunderContract.getNeck(tokenId));
        dex_bonus += bonus(plunderContract.getChest(tokenId));
        dex_bonus += bonus(plunderContract.getHand(tokenId));
        dex_bonus += bonus(plunderContract.getFoot(tokenId));
        str_bonus += bonus(plunderContract.getWeapon(tokenId));

        if (increase) {
            attributesContract.attribute_increment(_summoner, str_bonus+1, dex_bonus+1, _base_bonus, _base_bonus, _base_bonus, _base_bonus);
            return increase;
        }
        attributesContract.attribute_decrement(_summoner, str_bonus+1, dex_bonus+1, _base_bonus, _base_bonus, _base_bonus, _base_bonus);
    }

    function bonus(string memory _str) public pure returns (uint32) {
        string memory modifier_string = "+1";
        string memory prefix_string = "\"";
        string memory item = _str;
        uint len = bytes(item).length;
        uint32 total_bonus = 0;

        // Check if item contains " of " and add +1 bonus
        if (contains(" of ", item)) {
            total_bonus += 1;
        }

        // Check if item contains "+1" and add +4 bonus
        item = slice(len-1, len, _str);
        if (keccak256(abi.encodePacked(item)) == keccak256(abi.encodePacked(modifier_string))) {
            total_bonus  += 4;
        }

        // Check if item has prefix "\"" and add +2 bonus
        item = slice(1, 1, _str);
        if (keccak256(abi.encodePacked(item)) == keccak256(abi.encodePacked(prefix_string))) {
            total_bonus  += 2;
        }

        return total_bonus;
    }

    function length(string calldata str) external pure returns (uint) {
        return bytes(str).length;
    }

    function contains(string memory what, string memory where) internal pure returns (bool) {
        bytes memory whatBytes = bytes (what);
        bytes memory whereBytes = bytes (where);

        for (uint i = 0; i < whereBytes.length - whatBytes.length; i++) {
            bool flag = true;
            for (uint j = 0; j < whatBytes.length; j++)
                if (whereBytes [i + j] != whatBytes [j]) {
                    flag = false;
                    break;
                }
            if (flag) {
                return true;
            }
        }
        return false;
    }

    function pause() external onlyRole(MANAGER) {
        _pause();
    }

    function unpause() external onlyRole(MANAGER) {
        _unpause();
    }

    function _unpause() internal override {
        super._unpause();
    }

    function _pause() internal override {
        super._pause();
    }
}
