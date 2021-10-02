/**
 *Submitted for verification at FtmScan.com on 2021-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface adventure {
    function level(uint) external view returns (uint);
    function class(uint) external view returns (uint);
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
    function retrieveAdventurerLog(uint) external returns (uint);
    function setAdventurerLog(uint, uint) external returns (uint);
}

interface attributes {
    function character_created(uint) external view returns (bool);
    function ability_scores(uint) external view returns (uint32,uint32,uint32,uint32,uint32,uint32);
}

interface base_crafting_materials {
    function attack_bonus(uint, uint, uint) external pure returns (int);
    function to_hit_ac(int) external pure returns (bool);
    function armor_class(uint) external pure returns (int);
    function damage(uint) external pure returns (uint);
    function health_by_class(uint) external pure returns(uint);
    function health_by_class_and_level(uint, uint, uint32) external pure returns (uint);
    function _mint(uint, uint) external returns (bool);
}

contract adventure_dungeon_snowbridge {
    string public constant name = "The Snow Bridge";

    int public constant dungeon_health = 10;
    int public constant dungeon_damage = 2;
    int public constant dungeon_to_hit = 3;
    int public constant dungeon_armor_class = 2;
    uint constant DAY = 1 days;

    adventure adv;
    attributes attr;
    base_crafting_materials craft_m;

    constructor(adventure _adv, attributes _attr, base_crafting_materials _craft_m) {
        adv = _adv;
        attr = _attr;
        craft_m = _craft_m;
    }

    function scout(uint _summoner) public view returns (uint reward) {
        uint _level = adv.level(_summoner);
        uint _class = adv.class(_summoner);
        (uint32 _str, uint32 _dex, uint32 _const,,,) = attr.ability_scores(_summoner);
        int _health = int(craft_m.health_by_class_and_level(_class, _level, _const));
        int _dungeon_health = dungeon_health;
        int _damage = int(craft_m.damage(_str));
        int _attack_bonus = craft_m.attack_bonus(_class, _str, _level);
        bool _to_hit_ac = craft_m.to_hit_ac(_attack_bonus);
        bool _hit_ac = craft_m.armor_class(_dex) < dungeon_to_hit;
        if (_to_hit_ac) {
            for (reward = 10; reward >= 0; reward--) {
                _dungeon_health -= _damage;
                if (_dungeon_health <= 0) {break;}
                if (_hit_ac) {_health -= dungeon_damage;}
                if (_health <= 0) {return 0;}
            }
        }
    }

    function adventure(uint _summoner) external returns (uint reward) {
        require(_isApprovedOrOwner(_summoner));
        require(block.timestamp > adv.retrieveAdventurerLog(_summoner));
        adv.setAdventurerLog(_summoner, block.timestamp + DAY);
        reward = scout(_summoner);
        craft_m._mint(_summoner, reward);
    }


    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return adv.getApproved(_summoner) == msg.sender || adv.ownerOf(_summoner) == msg.sender;
    }
}
