// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IPip {
    // --- Auth ---
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    // --- Stop ---
    function stopped() external view returns (uint256);
    function stop() external;
    function start() external;

    // --- Config ---
    function src() external view returns (address);
    function hop() external view returns (uint16);
    function zzz() external view returns (uint64);
    function change(address src_) external;
    function step(uint16 ts) external;
    function void() external;

    // --- Price ---
    function pass() external view returns (bool ok);
    function poke() external;
    function peek() external view returns (bytes32, bool);
    function peep() external view returns (bytes32, bool);
    function read() external view returns (bytes32);

    // --- Whitelist ---
    function bud(address) external view returns (uint256);
    function kiss(address a) external;
    function diss(address a) external;
    function kiss(address[] calldata a) external;
    function diss(address[] calldata a) external;

    // --- Events ---
    event LogValue(bytes32 val);
}
