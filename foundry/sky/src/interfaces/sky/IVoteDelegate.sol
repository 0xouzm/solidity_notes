// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IVoteDelegate {
    event Lock(address indexed usr, uint256 wad);
    event Free(address indexed usr, uint256 wad);

    function delegate() external view returns (address);
    function gov() external view returns (address);
    function chief() external view returns (address);
    function polling() external view returns (address);
    function stake(address) external view returns (uint256);

    function lock(uint256 wad) external;
    function free(uint256 wad) external;
    function vote(address[] calldata yays) external returns (bytes32 result);
    function vote(bytes32 slate) external;
    function votePoll(uint256 pollId, uint256 optionId) external;
    function votePoll(uint256[] calldata pollIds, uint256[] calldata optionIds)
        external;
}
