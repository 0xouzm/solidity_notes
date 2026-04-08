// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IClipper {
    // --- Auth ---
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    // --- Immutables ---
    function ilk() external view returns (bytes32);
    function vat() external view returns (address);

    // --- Admin addresses ---
    function dog() external view returns (address);
    function vow() external view returns (address);
    function spotter() external view returns (address);
    function calc() external view returns (address);

    // --- Params ---
    function buf() external view returns (uint256);
    function tail() external view returns (uint256);
    function cusp() external view returns (uint256);
    function chip() external view returns (uint64);
    function tip() external view returns (uint192);
    function chost() external view returns (uint256);
    function stopped() external view returns (uint256);

    // --- Auction state ---
    function kicks() external view returns (uint256);
    function active(uint256) external view returns (uint256);

    struct Sale {
        uint256 pos; // Index in active array
        uint256 tab; // Dai to raise       [rad]
        uint256 lot; // collateral to sell [wad]
        address usr; // Liquidated CDP
        uint96 tic; // Auction start time
        uint256 top; // Starting price     [ray]
    }

    function sales(uint256) external view returns (Sale memory);

    // --- Admin ---
    function file(bytes32 what, uint256 data) external;
    function file(bytes32 what, address data) external;

    // --- Auction lifecycle ---
    function kick(uint256 tab, uint256 lot, address usr, address kpr)
        external
        returns (uint256 id);

    function redo(uint256 id, address kpr) external;

    function take(
        uint256 id,
        uint256 amt,
        uint256 max,
        address who,
        bytes calldata data
    ) external;

    function yank(uint256 id) external;

    // --- View ---
    function count() external view returns (uint256);
    function list() external view returns (uint256[] memory);
    function getStatus(uint256 id)
        external
        view
        returns (bool needsRedo, uint256 price, uint256 lot, uint256 tab);

    // --- Dust update ---
    function upchost() external;
}
