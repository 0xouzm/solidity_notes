// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IVat {
    struct Ilk {
        uint256 Art; // Total Normalised Debt     [wad]
        uint256 rate; // Accumulated Rates         [ray]
        uint256 spot; // Price with Safety Margin  [ray]
        uint256 line; // Debt Ceiling              [rad]
        uint256 dust; // Urn Debt Floor            [rad]
    }

    struct Urn {
        uint256 ink; // Locked Collateral  [wad]
        uint256 art; // Normalised Debt    [wad]
    }

    // --- Auth ---
    function wards(address usr) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    // --- Approvals ---
    function can(address owner, address spender) external view returns (uint256);
    function hope(address usr) external;
    function nope(address usr) external;

    // --- Data ---
    function ilks(bytes32 ilk) external view returns (Ilk memory);

    function urns(bytes32 ilk, address usr) external view returns (Urn memory);

    function gem(bytes32 ilk, address usr) external view returns (uint256); // [wad]
    function dai(address usr) external view returns (uint256); // [rad]
    function sin(address usr) external view returns (uint256); // [rad]

    function debt() external view returns (uint256); // Total Dai Issued    [rad]
    function vice() external view returns (uint256); // Total Unbacked Dai  [rad]
    function Line() external view returns (uint256); // Total Debt Ceiling  [rad]
    function live() external view returns (uint256); // Access Flag

    // --- Administration ---
    function init(bytes32 ilk) external;
    function file(bytes32 what, uint256 data) external;
    function file(bytes32 ilk, bytes32 what, uint256 data) external;
    function cage() external;

    // --- Fungibility ---
    function slip(bytes32 ilk, address usr, int256 wad) external;
    function flux(bytes32 ilk, address src, address dst, uint256 wad) external;
    function move(address src, address dst, uint256 rad) external;

    // --- CDP Manipulation ---
    // frob(i, u, v, w, dink, dart)
    // - modify position of user u
    // - using gem i from user v
    // - and creating coin for user w
    // dink: change in amount of collateral
    // dart: change in amount of debt
    function frob(
        // ilk
        bytes32 i,
        // Urn owner
        address u,
        // gem owner
        address v,
        // dai receiver
        address w,
        // delta collateral
        int256 dink,
        // delta normalized debt
        int256 dart
    ) external;

    // --- CDP Fungibility ---
    function fork(
        bytes32 ilk,
        address src,
        address dst,
        int256 dink,
        int256 dart
    ) external;

    // --- CDP Confiscation ---
    function grab(
        bytes32 i,
        address u,
        address v,
        address w,
        int256 dink,
        int256 dart
    ) external;

    // --- Settlement ---
    function heal(uint256 rad) external;
    function suck(address u, address v, uint256 rad) external;

    // --- Rates ---
    function fold(bytes32 i, address u, int256 rate) external;
}
