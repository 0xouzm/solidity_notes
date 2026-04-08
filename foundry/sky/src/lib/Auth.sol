// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

contract Auth {
    address public owner;

    modifier auth() {
        require(msg.sender == owner, "auth");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}
