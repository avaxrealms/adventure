// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface adventure {
    function level(uint) external view returns (uint);
    function class(uint) external view returns (uint);
    function xp(uint) external view returns (uint);
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
    function retrieveAdventurerLog(uint) external returns (uint);
    function setAdventurerLog(uint, uint) external returns (uint);
    function setAdventurerStats(uint _summoner, uint _xp, uint _class, uint _level) external;
}

interface attributes {
    function character_created(uint) external view returns (bool);
    function ability_scores(uint) external view returns (uint32,uint32,uint32,uint32,uint32,uint32);
    function bonus_ability_scores(uint) external view returns (uint32,uint32,uint32,uint32,uint32,uint32);
    function penalty_ability_scores(uint) external view returns (uint32,uint32,uint32,uint32,uint32,uint32);
}

interface gold {
    function managingContractGameMint(uint dst, uint amount) external returns (uint, uint);
}

contract adventure_dungeon_snowbridge is AccessControl, Pausable {
    string public constant name = "The Snow Bridge";

    int public constant dungeon_health = 10;
    int public constant dungeon_damage = 2;
    int public constant dungeon_to_hit = 3;
    int public constant dungeon_armor_class = 2;
    uint constant DAY = 30 minutes;

    adventure adv;
    attributes attr;
    gold realmgold;

    bytes32 public constant MANAGER = keccak256("MANAGER");

    constructor(adventure _adv, attributes _attr, gold _realmgold) {
        adv = _adv;
        attr = _attr;
        realmgold = _realmgold;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function scout(uint _summoner) public view returns (string memory reward) {
        reward = "75 XP and 75 RG";
    }

    function _scout(uint _summoner) internal view returns (uint reward) {
        reward = 1;
    }

    function adventure(uint _summoner) external whenNotPaused() returns (uint reward) {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(block.timestamp > adv.retrieveAdventurerLog(_summoner), "!log");
        adv.setAdventurerLog(_summoner, block.timestamp + DAY);
        reward = _scout(_summoner);

        if (reward >= 1) {
            realmgold.managingContractGameMint(_summoner, 75e18);
            adv.setAdventurerStats(_summoner, adv.xp(_summoner)+75e18, adv.class(_summoner), adv.level(_summoner));
            return reward;
        }
    }

    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return adv.getApproved(_summoner) == msg.sender || adv.ownerOf(_summoner) == msg.sender;
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
