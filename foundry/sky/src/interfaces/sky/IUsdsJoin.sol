// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IUsdsJoin {
    function vat() external view returns (address);
    function usds() external view returns (address);
    function dai() external view returns (address);

    function join(address usr, uint256 wad) external;
    function exit(address usr, uint256 wad) external;

    event Join(address indexed caller, address indexed usr, uint256 wad);
    event Exit(address indexed caller, address indexed usr, uint256 wad);
}
