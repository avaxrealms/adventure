// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Plunder is ERC721Enumerable, ReentrancyGuard, Ownable {

    using SafeMath for uint256;

    uint256 public constant MAX_NFT_SUPPLY = 10000;
    uint256 public constant RESERVED_SUPPLY = 100;
    uint public constant MAX_PURCHASABLE = 30;
    uint256 public PLUNDER_PRICE = 1000000000000000000; // 3 AVAX

    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function retrievePrice() public view returns (uint256) {
        return PLUNDER_PRICE;
    }

    string[] private weapons = [
        "Short Sword",
        "Long Sword",
        "FRAXium Sword",
        "SushiChef Cleaver",
        "Climbing Pick",
        "Staff",
        "MIM Spell Wand",
        "Shortbow",
        "Longbow",
        "Sling",
        "Crossbow",
        "Dagger",
        "Pangolin Claws",
        "Protofire Whip"
    ];

    string[] private chestArmor = [
        "Chainlink Mail",
        "Plate Armor",
        "Dragonscale Armor",
        "Sergey's Blue Flannel",
        "SushiChef Apron",
        "Manathread Robe",
        "Arcane Armor",
        "Pangolin Armor",
        "Leather Armor",
        "Dragonhide Vest",
        "Wonderland Clown Coat",
        "Joe's Overalls",
        "Frontiersman Coat",
        "Sherpa Outfit",
        "Qi Robes"
    ];

    string[] private headArmor = [
        "Hood",
        "Bull's Head",
        "Full Helm",
        "Yak Helmet",
        "Markr's Spectacles",
        "Crown",
        "Workman's Hardhat",
        "Ser Dexalot's Helm",
        "AvaApe Mask",
        "Wonderland Clown Mask",
        "Manathread Hat",
        "Nordcourt Viking Helm",
        "Dragonhide Cap",
        "Sherpa Hat",
        "Professor's Glasses"
    ];
    string[] private waistArmor = [
        "Sash",
        "Leather Belt",
        "Silk Belt",
        "Studded Belt",
        "Heavy Belt",
        "Alchemist Belt",
        "Wicker Belt",
        "Wool Belt",
        "Chainlink Belt",
        "Drake's Tail",
        "Spiked Belt",
        "Manathread Belt",
        "Feather Belt",
        "Dragonskin Belt",
        "Bullhide Belt"
    ];

    string[] private footArmor = [
        "Wool Shoes",
        "Silk Shoes",
        "Leather Boots",
        "Ringmail Boots",
        "Iron Greaves",
        "Sandals",
        "Sergey's Shoes",
        "Avalaunch Boots",
        "Snow Boots",
        "Arcane Boots",
        "Joe's Boots",
        "Manathread Boots",
        "Thief's Treads",
        "Dragonhide Boots",
        "Chainlink Boots"
    ];

    string[] private handArmor = [
        "Manathread Gloves",
        "Steel Gauntlets",
        "Dragonscale Gauntlets",
        "Spiked Gauntlets",
        "Dragonskin Gloves",
        "Leather Gloves",
        "Arcane Gloves",
        "Silk Gloves",
        "Wool Gloves",
        "Linen Gloves",
        "Chainlink Gloves",
        "Iron Gauntlets"
    ];

    string[] private necklaces = [
        "Necklace",
        "Amulet",
        "Pendant",
        "Chain",
        "Scarf",
        "Spiked Collar"
    ];

    string[] private rings = [
        "Wooden Ring",
        "Iron Ring",
        "Gold Ring",
        "Spike Ring",
        "Rose Stalk"
    ];

    string[] private suffixes = [
        "of Power",
        "of Gods",
        "of Titans",
        "of Skill",
        "of Perfection",
        "of Brilliance",
        "of Protection",
        "of Shadow",
        "of Rage",
        "of the Wolf",
        "of Stealth",
        "of the Fox",
        "of Defence",
        "of Reflection",
        "of the Tower"
    ];

    string[] private namePrefixes = [
        "Beast",
        "Blood",
        "Coin",
        "Death",
        "Doge",
        "Doom",
        "Nhazar'Ov",
        "Miracle",
        "Morbid",
        "Punk",
        "Soul",
        "Sushi",
        "Trade",
        "Whas-Sie"
    ];

    string[] private nameSuffixes = [
        "Bane",
        "Bite",
        "Roar",
        "Grasp",
        "Bender",
        "Shadow",
        "Growl",
        "Tear",
        "Sun",
        "Moon"
    ];

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getWeapon(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "WEAPON", weapons);
    }

    function getChest(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "CHEST", chestArmor);
    }

    function getHead(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "HEAD", headArmor);
    }

    function getWaist(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "WAIST", waistArmor);
    }

    function getFoot(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "FOOT", footArmor);
    }

    function getHand(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "HAND", handArmor);
    }

    function getNeck(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "NECK", necklaces);
    }

    function getRing(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "RING", rings);
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 101;
        if (greatness > 79) {
            output = string(abi.encodePacked(output, " ", suffixes[rand % suffixes.length]));
        }
        if (greatness >= 89) {
            string[2] memory name;
            name[0] = namePrefixes[rand % namePrefixes.length];
            name[1] = nameSuffixes[rand % nameSuffixes.length];
            if (greatness == 97) {
                output = string(abi.encodePacked('"', name[0], ' ', name[1], '" ', output, " +1"));
            } else if (greatness >= 95){
                output = string(abi.encodePacked('"', name[0], ' ', name[1], '" ', output));
            }
        }
        return output;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[19] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base, .title, .id {fill: #16140a; font-family: nocturne-serif, "Nocturne Serif", serif; font-size: 9.7px; font-weight: 500;} .title{font-size:16px;} .id{font-size:12px; fill: #ba3e4a;}</style><style>@import url("https://use.typekit.net/nln0qsp.css");</style><rect width="100%" height="100%" fill="#bfb67f" /><text x="25" y="70" class="base">';

        parts[1] = getWeapon(tokenId);

        parts[2] = '</text><text x="25" y="90" class="base">';

        parts[3] = getChest(tokenId);

        parts[4] = '</text><text x="25" y="110" class="base">';

        parts[5] = getHead(tokenId);

        parts[6] = '</text><text x="25" y="130" class="base">';

        parts[7] = getWaist(tokenId);

        parts[8] = '</text><text x="25" y="150" class="base">';

        parts[9] = getFoot(tokenId);

        parts[10] = '</text><text x="25" y="170" class="base">';

        parts[11] = getHand(tokenId);

        parts[12] = '</text><text x="25" y="190" class="base">';

        parts[13] = getNeck(tokenId);

        parts[14] = '</text><text x="25" y="210" class="base">';

        parts[15] = getRing(tokenId);

        parts[16] = '</text><text x="280" y="50" class="id">#';

        parts[17] = toString(tokenId);

        parts[18] = '</text><text x="250" y="300" class="title">Plunder</text><line x1="175" y1="305" x2="310" y2="305" style="stroke:#ba3e4a;stroke-width:1"/></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15]));
        output = string(abi.encodePacked(output, parts[16], parts[17], parts[18]));

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Plunder #', toString(tokenId), '", "description": "Plunder", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

 function mint(uint256 amountToMint) public payable {
        require(totalSupply() < MAX_NFT_SUPPLY.sub(RESERVED_SUPPLY));
        require(amountToMint > 0);
        require(amountToMint <= MAX_PURCHASABLE);
        require(totalSupply() + amountToMint <= MAX_NFT_SUPPLY.sub(RESERVED_SUPPLY));

        require(PLUNDER_PRICE * amountToMint == msg.value);

        for (uint256 i = 0; i < amountToMint; i++) {
            uint256 mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
        }
   }

    function ownerClaim(uint256 tokenId) public nonReentrant onlyOwner {
        require(tokenId >= MAX_NFT_SUPPLY.sub(RESERVED_SUPPLY) && tokenId < MAX_NFT_SUPPLY);
        _safeMint(owner(), tokenId);
    }

    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    constructor() ERC721("Plunder", "PLDR") Ownable() {}
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
