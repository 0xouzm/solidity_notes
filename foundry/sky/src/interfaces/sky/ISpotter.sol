// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface ISpotter {
    struct Ilk {
        address pip; // price feed
        uint256 mat; // liquidation ratio [ray]
    }

    // --- Auth ---
    function wards(address usr) external view returns (uint256);
    function rely(address guy) external;
    function deny(address guy) external;

    // --- Data ---
    function ilks(bytes32 ilk) external view returns (Ilk memory);
    function vat() external view returns (address);
    function par() external view returns (uint256); // ref per dai [ray]
    function live() external view returns (uint256);

    // --- Administration ---
    function file(bytes32 ilk, bytes32 what, address pip_) external;
    function file(bytes32 what, uint256 data) external;
    function file(bytes32 ilk, bytes32 what, uint256 data) external;

    // --- Update ---
    function poke(bytes32 ilk) external;

    // --- Shutdown ---
    function cage() external;

    // --- Events ---
    event Poke(bytes32 ilk, bytes32 val, uint256 spot);
}
