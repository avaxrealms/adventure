// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface adventure {
    function level(uint) external view returns (uint);
    function class(uint) external view returns (uint);
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
}

interface attributes {
    function character_created(uint) external view returns (bool);
    function ability_scores(uint) external view returns (uint32,uint32,uint32,uint32,uint32,uint32);
}

contract adventure_crafting_materials is AccessControl {
    string public constant name = "Adventure Crafting Materials (I)";
    string public constant symbol = "Craft (I)";
    uint8 public constant decimals = 18;

    bytes32 public constant MINTER_CONTRACT = keccak256("MINTER_CONTRACT");

    uint public totalSupply = 0;

    adventure adv;
    attributes attr;

    mapping(uint => mapping (uint => uint)) public allowance;
    mapping(uint => uint) public balanceOf;

    mapping(uint => uint) public adventurers_log;

    event Transfer(uint indexed from, uint indexed to, uint amount);
    event Approval(uint indexed from, uint indexed to, uint amount);

    constructor (adventure _adv, attributes _attr) {
        adv = _adv;
        attr = _attr;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return adv.getApproved(_summoner) == msg.sender || adv.ownerOf(_summoner) == msg.sender;
    }

    function _mint(uint dst, uint amount) public onlyRole(MINTER_CONTRACT) returns (uint) {
        totalSupply += amount;
        balanceOf[dst] += amount;

        emit Transfer(dst, dst, amount);
        return amount;
    }

    function approve(uint from, uint spender, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(from));
        allowance[from][spender] = amount;

        emit Approval(from, spender, amount);
        return true;
    }

    function transfer(uint from, uint to, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(from));
        _transferTokens(from, to, amount);
        return true;
    }

    function transferFrom(uint executor, uint from, uint to, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(executor));
        uint spender = executor;
        uint spenderAllowance = allowance[from][spender];

        if (spender != from && spenderAllowance != type(uint).max) {
            uint newAllowance = spenderAllowance - amount;
            allowance[from][spender] = newAllowance;

            emit Approval(from, spender, newAllowance);
        }

        _transferTokens(from, to, amount);
        return true;
    }

    function _transferTokens(uint from, uint to, uint amount) internal {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }
}
