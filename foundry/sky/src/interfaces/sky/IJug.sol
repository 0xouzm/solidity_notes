// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IJug {
    function wards(address usr) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    struct Ilk {
        // duty [ray] - Collateral-specific, per-second stability fee contribution
        uint256 duty;
        // Last updated timestamp
        uint256 rho;
    }

    function ilks(bytes32) external view returns (Ilk memory);
    function vat() external view returns (address);
    function vow() external view returns (address);
    // base [ray] - Global per-second stability fee
    function base() external view returns (uint256);

    function init(bytes32 ilk) external;
    function file(bytes32 ilk, bytes32 what, uint256 data) external;
    function file(bytes32 what, uint256 data) external;
    function file(bytes32 what, address data) external;

    // Collect stability fee
    function drip(bytes32 ilk) external returns (uint256 rate);
}
