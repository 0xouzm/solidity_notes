// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IDssCdpManager {
    // State variables (auto-generated getters)
    function vat() external view returns (address);
    function cdpi() external view returns (uint256);
    function urns(uint256 cdp) external view returns (address);
    function owns(uint256 cdp) external view returns (address);
    function ilks(uint256 cdp) external view returns (bytes32);
    function first(address owner) external view returns (uint256);
    function last(address owner) external view returns (uint256);
    function count(address owner) external view returns (uint256);
    function list(uint256 cdp)
        external
        view
        returns (uint256 prev, uint256 next);
    function cdpCan(address owner, uint256 cdp, address usr)
        external
        view
        returns (uint256);
    function urnCan(address urn, address usr) external view returns (uint256);

    // CDP permission management
    function cdpAllow(uint256 cdp, address usr, uint256 ok) external;
    function urnAllow(address usr, uint256 ok) external;

    // CDP lifecycle
    function open(bytes32 ilk, address usr) external returns (uint256 cdp);
    function give(uint256 cdp, address dst) external;

    // CDP operations
    function frob(uint256 cdp, int256 dink, int256 dart) external;
    function flux(uint256 cdp, address dst, uint256 wad) external;
    function flux(bytes32 ilk, uint256 cdp, address dst, uint256 wad) external;
    function move(uint256 cdp, address dst, uint256 rad) external;

    // CDP migration
    function quit(uint256 cdp, address dst) external;
    function enter(address src, uint256 cdp) external;
    function shift(uint256 cdpSrc, uint256 cdpDst) external;

    // Events
    event NewCdp(address indexed usr, address indexed own, uint256 indexed cdp);
}
