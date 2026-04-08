// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IDaiJoin {
    function wards(address usr) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function vat() external view returns (address);
    function dai() external view returns (address);
    function live() external view returns (uint256);

    function cage() external;
    function join(address usr, uint256 wad) external;
    function exit(address usr, uint256 wad) external;
}
