// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IDaiUsds {
    function daiJoin() external view returns (address);
    function usdsJoin() external view returns (address);
    function dai() external view returns (address);
    function usds() external view returns (address);

    function daiToUsds(address usr, uint256 wad) external;
    function usdsToDai(address usr, uint256 wad) external;

    event DaiToUsds(address indexed caller, address indexed usr, uint256 wad);
    event UsdsToDai(address indexed caller, address indexed usr, uint256 wad);
}
