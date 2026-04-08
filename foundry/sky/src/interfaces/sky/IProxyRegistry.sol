// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IProxyRegistry {
    function proxies(address owner) external view returns (address);
    function build() external returns (address);
    function build(address owner) external returns (address);
}
