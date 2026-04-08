// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IDSProxy {
    // DSNote
    event LogNote(
        // msg.sig
        bytes4 indexed sig,
        // msg.sender
        address indexed guy,
        // First 32 bytes input
        bytes32 indexed foo,
        // Second 32 bytes input
        bytes32 indexed bar,
        // msg.value
        uint256 wad,
        // msg.data
        bytes fax
    ) anonymous;

    // DSAuth
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);

    function owner() external view returns (address);
    function authority() external view returns (address);
    function setOwner(address owner) external;
    function setAuthority(address authority) external;

    // DSProxy
    function cache() external view returns (address);
    function execute(bytes calldata code, bytes calldata data)
        external
        payable
        returns (address target, bytes32 response);
    function execute(address target, bytes calldata data)
        external
        payable
        returns (bytes32 response);
    function setCache(address cacheAddr) external returns (bool);
}
