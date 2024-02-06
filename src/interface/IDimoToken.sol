// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IDimoToken {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}