// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ethereum/node_modules/@openzeppelin/contracts/access/Ownable.sol";

struct User {
    uint256 balance;
    uint256 wins;
    uint256 losses;
    uint256 totalAmountWon;
}

enum CoinSide { Heads, Tails }

contract CoinFlip is Ownable {
    mapping(address => User) public users;

    uint256 public minGameCost;
    uint256 public coefficient;
    uint256 public contractBalance;

    constructor(uint256 _minGameCost, uint256 _coefficient) Ownable(msg.sender) {
        minGameCost = _minGameCost;
        coefficient = _coefficient;
    }

    function transfer(address payable _to, uint256 _amount) internal returns (bool) {
        (bool sent, ) = _to.call{
            value: _amount
        }();
        require(sent, "");
    }

    function getRandomCoinSide() internal view returns (CoinSide) {
        uint256 rand = uint256(keccak256(
            abi.encodePacked(block.timestamp, block.difficulty, block.number)
        ));
        return CoinSide(rand % 2);
    }

    function play(CoinSide coinSide) external payable {
        require(msg.value >= minGameCost, 
            ""
        );
        User storage user = users[msg.sender];

        bool isUserWins = coinSide == getRandomCoinSide();
        if (isUserWins) {
            user.wins += 1;
            user.balance += msg.value;
            user.totalAmountWon += msg.value;
        } else {
            user.losses += 1;
            contractBalance += msg.value;
        }
        return isUserWins;
    }

    function withdrawContractBalance() onlyOwner() {
        transfer(payable(msg.sender), contractBalance);
        contractBalance = 0;
    }

    function withdrawUserBalance() {
        uint256 balance = users[msg.sender].balance;
        require(balance > 0, "");
        transfer(payable(msg.sender), balance);
        balance = 0;
    }

    function setMinGameCost(uint256 _minGameCost) onlyOwner() public {
        minGameCost = _minGameCost;
    }

    function getUserInfo(address _addr) view public {
        //User memory user = users[_addr];
        //require(user.losses > 0 || user.wins > 0, "no info bout this user");
        // return user;
        return users[_addr];
    }
}