// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface adventure {
    function level(uint) external view returns (uint);
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
}

contract RealmGold {
    string public constant name = "Realm Gold";
    string public constant symbol = "RGold";
    uint8 public constant decimals = 18;

    uint public totalSupply = 0;

    adventure adv;

    mapping(address => mapping (address => uint)) public allowance;
    mapping(uint => mapping (uint => uint)) public summonerAllowance;
    mapping(address => uint) public balanceOf;
    mapping(uint => uint) public summonerBalance;

    mapping(uint => uint) public claimed;

    event gameTransferE(uint indexed from, uint indexed to, uint amount);
    event gameApproval(uint indexed from, uint indexed to, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);

    constructor(adventure _adv) {
        adv = _adv;
        // test
            _mint(msg.sender, 100000000000000000000);
    }

    function wealth_by_level(uint level) public pure returns (uint wealth) {
        for (uint i = 1; i < level; i++) {
            wealth += i * 1000e18;
        }
    }

    function summoner_wealth(uint _summoner) external view returns (uint) {
        return summonerBalance[_summoner];
    }

    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return adv.getApproved(_summoner) == msg.sender || adv.ownerOf(_summoner) == msg.sender;
    }

    function claimable(uint summoner) external view returns (uint amount) {
        require(_isApprovedOrOwner(summoner));
        uint _current_level = adv.level(summoner);
        uint _claimed_for = claimed[summoner]+1;
        for (uint i = _claimed_for; i <= _current_level; i++) {
            amount += wealth_by_level(i);
        }
    }

    function claim(uint summoner) external {
        require(_isApprovedOrOwner(summoner));
        uint _current_level = adv.level(summoner);
        uint _claimed_for = claimed[summoner]+1;
        for (uint i = _claimed_for; i <= _current_level; i++) {
            _gameMint(summoner, wealth_by_level(i));
        }
        claimed[summoner] = _current_level;
    }

    function _gameMint(uint dst, uint amount) internal {
        totalSupply += amount;
        summonerBalance[dst] += amount;
        emit gameTransferE(dst, dst, amount);
    }

    function gameApprove(uint from, uint spender, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(from));
        summonerAllowance[from][spender] = amount;

        emit gameApproval(from, spender, amount);
        return true;
    }

    function gameTransfer(uint from, uint to, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(from));
        _gameTransferTokens(from, to, amount);
        return true;
    }

    function gameTransferFrom(uint executor, uint from, uint to, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(executor));
        uint spender = executor;
        uint spenderAllowance = summonerAllowance[from][spender];

        if (spender != from && spenderAllowance != type(uint).max) {
            uint newAllowance = spenderAllowance - amount;
            summonerAllowance[from][spender] = newAllowance;

            emit gameApproval(from, spender, newAllowance);
        }

        _gameTransferTokens(from, to, amount);
        return true;
    }

    function _gameTransferTokens(uint from, uint to, uint amount) internal {
        summonerBalance[from] -= amount;
        summonerBalance[to] += amount;

        emit gameTransferE(from, to, amount);
    }

    // --

    function deposit(uint _summoner, uint amount) external {
        require(_isApprovedOrOwner(_summoner));
        _burn(msg.sender, amount);
        summonerBalance[_summoner] += amount;
    }

    function withdraw(uint _summoner, uint amount) external {
        require(_isApprovedOrOwner(_summoner));
        _mint(msg.sender, amount);
        summonerBalance[_summoner] -= amount;
    }

    function _mint(address to, uint amount) internal {
        // mint the amount
        totalSupply += amount;
        // transfer the amount to the recipient
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint amount) internal {
        // burn the amount
        totalSupply -= amount;
        // transfer the amount from the recipient
        balanceOf[from] -= amount;
        emit Transfer(from, address(0), amount);
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address dst, uint amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint amount) external returns (bool) {
        address spender = msg.sender;
        uint spenderAllowance = allowance[src][spender];

        if (spender != src && spenderAllowance != type(uint).max) {
            uint newAllowance = spenderAllowance - amount;
            allowance[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(address src, address dst, uint amount) internal {
        balanceOf[src] -= amount;
        balanceOf[dst] += amount;

        emit Transfer(src, dst, amount);
    }
}
