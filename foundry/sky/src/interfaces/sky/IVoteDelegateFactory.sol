// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IVoteDelegateFactory {
    event CreateVoteDelegate(address indexed usr, address indexed voteDelegate);

    function chief() external view returns (address);
    function polling() external view returns (address);
    function delegates(address usr) external view returns (address);
    function created(address voteDelegate) external view returns (uint256);
    function isDelegate(address usr) external view returns (bool);
    function create() external returns (address voteDelegate);
}
