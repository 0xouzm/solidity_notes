// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IChief {
    event Launch();
    event Lock(address indexed usr, uint256 wad);
    event Free(address indexed usr, uint256 wad);
    event Etch(bytes32 indexed slate, address[] yays);
    event Vote(address indexed usr, bytes32 indexed slate);
    event Lift(address indexed whom);

    function live() external view returns (uint256);
    function hat() external view returns (address);
    function slates(bytes32 slate, uint256 index)
        external
        view
        returns (address);
    function votes(address usr) external view returns (bytes32);
    function approvals(address yay) external view returns (uint256);
    function deposits(address usr) external view returns (uint256);
    function last() external view returns (uint256);

    function gov() external view returns (address);
    function maxYays() external view returns (uint256);
    function launchThreshold() external view returns (uint256);
    function liftCooldown() external view returns (uint256);
    function EMPTY_SLATE() external view returns (bytes32);

    function length(bytes32 slate) external view returns (uint256);
    function canCall(address caller, address, bytes4)
        external
        view
        returns (bool);
    function launch() external;
    function lock(uint256 wad) external;
    function free(uint256 wad) external;
    function etch(address[] calldata yays) external returns (bytes32 slate);
    function vote(address[] calldata yays) external returns (bytes32 slate);
    function vote(bytes32 slate) external;
    function lift(address whom) external;

    // Compatibility
    function GOV() external view returns (address);
    function MAX_YAYS() external view returns (uint256);
}
