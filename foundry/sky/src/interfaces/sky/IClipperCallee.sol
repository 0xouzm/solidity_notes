// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IClipperCallee {
    // owe [rad] - amount of dai owed to Clipper
    // slice [wad] - amount of collateral to receive
    // data - callback data
    function clipperCall(
        address caller,
        uint256 owe,
        uint256 slice,
        bytes calldata data
    ) external;
}
