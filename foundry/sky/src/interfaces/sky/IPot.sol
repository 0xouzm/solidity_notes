// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IPot {
    // --- Auth ---
    function wards(address) external view returns (uint256);
    function rely(address guy) external;
    function deny(address guy) external;

    // --- Data ---
    function pie(address) external view returns (uint256); // user Savings Dai balance
    function Pie() external view returns (uint256); // total Savings Dai
    function dsr() external view returns (uint256); // Dai Savings Rate
    function chi() external view returns (uint256); // Rate Accumulator
    function vat() external view returns (address); // CDP engine
    function vow() external view returns (address); // debt engine
    function rho() external view returns (uint256); // time of last drip
    function live() external view returns (uint256); // Access Flag

    // --- Administration ---
    function file(bytes32 what, uint256 data) external;
    function file(bytes32 what, address addr) external;
    function cage() external;

    // --- Savings Rate Accumulation ---
    function drip() external returns (uint256 tmp);

    // --- Savings Dai Management ---
    function join(uint256 wad) external;
    function exit(uint256 wad) external;
}
