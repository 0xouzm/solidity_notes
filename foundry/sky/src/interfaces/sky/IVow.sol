// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IVow {
    // --- Auth ---
    function wards(address usr) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    // --- Data ---
    function vat() external view returns (address);
    function flapper() external view returns (address);
    function flopper() external view returns (address);

    function sin(uint256 era) external view returns (uint256); // debt queue [rad]
    function Sin() external view returns (uint256); // queued debt [rad]
    function Ash() external view returns (uint256); // on-auction debt [rad]

    function wait() external view returns (uint256); // flop delay
    function dump() external view returns (uint256); // flop initial lot size [wad]
    function sump() external view returns (uint256); // flop fixed bid size [rad]

    function bump() external view returns (uint256); // flap fixed lot size [rad]
    function hump() external view returns (uint256); // surplus buffer [rad]

    function live() external view returns (uint256);

    // --- Administration ---
    function file(bytes32 what, uint256 data) external;
    function file(bytes32 what, address data) external;

    // --- Debt Queue ---
    function fess(uint256 tab) external; // push to debt-queue
    function flog(uint256 era) external; // pop from debt-queue

    // --- Settlement ---
    function heal(uint256 rad) external;
    function kiss(uint256 rad) external;

    // --- Auctions ---
    function flop() external returns (uint256 id); // debt auction
    function flap() external returns (uint256 id); // surplus auction

    // --- Shutdown ---
    function cage() external;
}
