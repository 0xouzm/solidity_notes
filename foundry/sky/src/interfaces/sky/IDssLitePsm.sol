// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

/// @title IDssLitePsm - Interface for MakerDAO Lite Peg Stability Module
/// @notice Swaps DAI for gem (e.g., USDC) at 1:1 exchange rate with optional fees
interface IDssLitePsm {
    // --- Constants ---
    function HALTED() external view returns (uint256);

    // --- Immutables ---
    function ilk() external view returns (bytes32);
    function vat() external view returns (address);
    function daiJoin() external view returns (address);
    function dai() external view returns (address);
    function gem() external view returns (address);
    function to18ConversionFactor() external view returns (uint256);
    function pocket() external view returns (address);

    // --- Auth ---
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    // --- Whitelist (no-fee swappers) ---
    function bud(address) external view returns (uint256);
    function kiss(address usr) external;
    function diss(address usr) external;

    // --- Admin Parameters ---
    function vow() external view returns (address);
    function tin() external view returns (uint256); // sell gem fee
    function tout() external view returns (uint256); // buy gem fee
    function buf() external view returns (uint256); // pre-mint buffer

    function file(bytes32 what, address data) external;
    function file(bytes32 what, uint256 data) external;

    // --- Swapping ---
    function sellGem(address usr, uint256 gemAmt)
        external
        returns (uint256 daiOutWad);
    function sellGemNoFee(address usr, uint256 gemAmt)
        external
        returns (uint256 daiOutWad);
    function buyGem(address usr, uint256 gemAmt)
        external
        returns (uint256 daiInWad);
    function buyGemNoFee(address usr, uint256 gemAmt)
        external
        returns (uint256 daiInWad);

    // --- Bookkeeping ---
    function fill() external returns (uint256 wad); // mint Dai into contract
    function trim() external returns (uint256 wad); // burn excess Dai
    function chug() external returns (uint256 wad); // send fees to vow

    // --- Getters ---
    function rush() external view returns (uint256 wad); // Dai that can be filled
    function gush() external view returns (uint256 wad); // Dai that can be trimmed
    function cut() external view returns (uint256 wad); // fees that can be chugged

    // --- Compatibility ---
    function gemJoin() external view returns (address);
    function dec() external view returns (uint256);
    function live() external view returns (uint256);

    // --- Events ---
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Kiss(address indexed usr);
    event Diss(address indexed usr);
    event File(bytes32 indexed what, address data);
    event File(bytes32 indexed what, uint256 data);
    event SellGem(address indexed owner, uint256 value, uint256 fee);
    event BuyGem(address indexed owner, uint256 value, uint256 fee);
    event Fill(uint256 wad);
    event Trim(uint256 wad);
    event Chug(uint256 wad);
}
