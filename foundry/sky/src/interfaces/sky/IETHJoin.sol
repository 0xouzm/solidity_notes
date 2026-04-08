// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IETHJoin {
    // --- Auth ---
    function wards(address usr) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    // --- Data ---
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function live() external view returns (uint256);

    // --- Admin ---
    function cage() external;

    // --- User ---
    function join(address usr) external payable;
    function exit(address payable usr, uint256 wad) external;
}
