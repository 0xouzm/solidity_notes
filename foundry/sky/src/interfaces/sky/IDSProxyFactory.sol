// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IDSProxyFactory {
    event Created(
        address indexed sender,
        address indexed owner,
        address proxy,
        address cache
    );

    function cache() external view returns (address);
    function isProxy(address proxy) external view returns (bool);
    function build() external returns (address proxy);
    function build(address owner) external returns (address proxy);
}
