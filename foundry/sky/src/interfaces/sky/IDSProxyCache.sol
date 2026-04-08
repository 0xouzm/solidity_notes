// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IDSProxyCache {
    function read(bytes calldata code) external view returns (address);
    function write(bytes calldata code) external returns (address target);
}
