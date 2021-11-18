// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

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
    function bonus_ability_scores(uint) external view returns (uint32,uint32,uint32,uint32,uint32,uint32);
}

interface base_crafting_materials {
    function _mint(uint, uint) external;
}

contract adventure_dungeon_snowbridge is AccessControl, Pausable {
    string public constant name = "The Snow Bridge";

    int public constant dungeon_health = 10;
    int public constant dungeon_damage = 2;
    int public constant dungeon_to_hit = 3;
    int public constant dungeon_armor_class = 2;
    uint constant DAY = 1 days;

    adventure adv;
    attributes attr;
    base_crafting_materials craft_m;

    bytes32 public constant MANAGER = keccak256("MANAGER");

    constructor(adventure _adv, attributes _attr, base_crafting_materials _craft_m) {
        adv = _adv;
        attr = _attr;
        craft_m = _craft_m;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function health_by_class(uint _class) public pure returns (uint health) {
        if (_class == 1) {
            health = 12;
        } else if (_class == 2) {
            health = 6;
        } else if (_class == 3) {
            health = 8;
        } else if (_class == 4) {
            health = 8;
        } else if (_class == 5) {
            health = 10;
        } else if (_class == 6) {
            health = 8;
        } else if (_class == 7) {
            health = 10;
        } else if (_class == 8) {
            health = 8;
        } else if (_class == 9) {
            health = 6;
        } else if (_class == 10) {
            health = 4;
        } else if (_class == 11) {
            health = 4;
        }
    }

    function health_by_class_and_level(uint _class, uint _level, uint32 _const) public pure returns (uint health) {
        int _mod = modifier_for_attribute(_const);
        int _base_health = int(health_by_class(_class)) + _mod;
        if (_base_health <= 0) {
            _base_health = 1;
        }
        health = uint(_base_health) * _level;
    }

    function base_attack_bonus_by_class(uint _class) public pure returns (uint attack) {
        if (_class == 1) {
            attack = 4;
        } else if (_class == 2) {
            attack = 3;
        } else if (_class == 3) {
            attack = 3;
        } else if (_class == 4) {
            attack = 3;
        } else if (_class == 5) {
            attack = 4;
        } else if (_class == 6) {
            attack = 3;
        } else if (_class == 7) {
            attack = 4;
        } else if (_class == 8) {
            attack = 4;
        } else if (_class == 9) {
            attack = 3;
        } else if (_class == 10) {
            attack = 2;
        } else if (_class == 11) {
            attack = 2;
        }
    }

    function base_attack_bonus_by_class_and_level(uint _class, uint _level) public pure returns (uint) {
        return _level * base_attack_bonus_by_class(_class) / 4;
    }

    function modifier_for_attribute(uint _attribute) public pure returns (int _modifier) {
        if (_attribute == 9) {
            return -1;
        }
        return (int(_attribute) - 10) / 2;
    }

    function attack_bonus(uint _class, uint _str, uint _level) public pure returns (int) {
        return  int(base_attack_bonus_by_class_and_level(_class, _level)) + modifier_for_attribute(_str);
    }

    function to_hit_ac(int _attack_bonus) public pure returns (bool) {
        return (_attack_bonus > dungeon_armor_class);
    }

    function damage(uint _str) public pure returns (uint) {
        int _mod = modifier_for_attribute(_str);
        if (_mod <= 1) {
            return 1;
        } else {
            return uint(_mod);
        }
    }

    function armor_class(uint _dex) public pure returns (int) {
        return modifier_for_attribute(_dex);
    }

    function scout(uint _summoner) public view returns (uint reward) {
        uint _level = adv.level(_summoner);
        uint _class = adv.class(_summoner);
        (uint32 _str, uint32 _dex, uint32 _const,,,) = attr.ability_scores(_summoner);
        (uint32 _bstr, uint32 _bdex, uint32 _bconst,,,) = attr.bonus_ability_scores(_summoner);
        _str += _bstr;
        _dex += _bdex;
        _const += _bconst;
        int _health = int(health_by_class_and_level(_class, _level, _const));
        int _dungeon_health = dungeon_health;
        int _damage = int(damage(_str));
        int _attack_bonus = attack_bonus(_class, _str, _level);
        bool _to_hit_ac = to_hit_ac(_attack_bonus);
        bool _hit_ac = armor_class(_dex) < dungeon_to_hit;
        if (_to_hit_ac) {
            for (reward = 10; reward >= 0; reward--) {
                _dungeon_health -= _damage;
                if (_dungeon_health <= 0) {break;}
                if (_hit_ac) {_health -= dungeon_damage;}
                if (_health <= 0) {return 0;}
            }
        }
    }

    function adventure(uint _summoner) external whenNotPaused() returns (uint reward) {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(block.timestamp > adv.retrieveAdventurerLog(_summoner), "!log");
        adv.setAdventurerLog(_summoner, block.timestamp + DAY);
        reward = scout(_summoner);
        craft_m._mint(_summoner, reward);
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
