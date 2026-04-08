// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IDog {
    // --- Auth ---
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    // --- Data ---
    struct Ilk {
        address clip; // Liquidator
        uint256 chop; // Liquidation Penalty  [wad]
        uint256 hole; // Max DAI needed to cover debt+fees of active auctions per ilk [rad]
        uint256 dirt; // Amt DAI needed to cover debt+fees of active auctions per ilk [rad]
    }

    // --- Immutables ---
    function vat() external view returns (address);

    // --- State ---
    function ilks(bytes32) external view returns (Ilk memory);
    function vow() external view returns (address);
    function live() external view returns (uint256);
    function Hole() external view returns (uint256);
    function Dirt() external view returns (uint256);

    // --- Admin ---
    function file(bytes32 what, address data) external;
    function file(bytes32 what, uint256 data) external;
    function file(bytes32 ilk, bytes32 what, uint256 data) external;
    function file(bytes32 ilk, bytes32 what, address clip) external;

    // --- View ---
    function chop(bytes32 ilk) external view returns (uint256);

    // --- Liquidation ---
    function bark(bytes32 ilk, address urn, address kpr)
        external
        returns (uint256 id);
    function digs(bytes32 ilk, uint256 rad) external;

    // --- Shutdown ---
    function cage() external;
}
