// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface ISUsds {
    // --- Events ---
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event File(bytes32 indexed what, uint256 data);
    event Approval(
        address indexed owner, address indexed spender, uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Deposit(
        address indexed sender,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    event Referral(
        uint16 indexed referral,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    event Drip(uint256 chi, uint256 diff);

    // --- Admin ---
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function file(bytes32 what, uint256 data) external;

    // --- ERC20 Constants ---
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function version() external view returns (string memory);
    function decimals() external view returns (uint8);

    // --- ERC20 State ---
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function nonces(address) external view returns (uint256);

    // --- ERC20 Mutations ---
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool);
    function approve(address spender, uint256 value) external returns (bool);

    // --- Savings Yield State ---
    function chi() external view returns (uint192);
    function rho() external view returns (uint64);
    function ssr() external view returns (uint256);

    // --- Savings Yield ---
    function drip() external returns (uint256 nChi);

    // --- Immutables ---
    function usdsJoin() external view returns (address);
    function vat() external view returns (address);
    function usds() external view returns (address);
    function vow() external view returns (address);

    // --- ERC4626 ---
    function asset() external view returns (address);
    function totalAssets() external view returns (uint256);
    function convertToShares(uint256 assets) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function maxDeposit(address) external pure returns (uint256);
    function previewDeposit(uint256 assets) external view returns (uint256);
    function deposit(uint256 assets, address receiver)
        external
        returns (uint256 shares);
    function deposit(uint256 assets, address receiver, uint16 referral)
        external
        returns (uint256 shares);
    function maxMint(address) external pure returns (uint256);
    function previewMint(uint256 shares) external view returns (uint256);
    function mint(uint256 shares, address receiver)
        external
        returns (uint256 assets);
    function mint(uint256 shares, address receiver, uint16 referral)
        external
        returns (uint256 assets);
    function maxWithdraw(address owner) external view returns (uint256);
    function previewWithdraw(uint256 assets) external view returns (uint256);
    function withdraw(uint256 assets, address receiver, address owner)
        external
        returns (uint256 shares);
    function maxRedeem(address owner) external view returns (uint256);
    function previewRedeem(uint256 shares) external view returns (uint256);
    function redeem(uint256 shares, address receiver, address owner)
        external
        returns (uint256 assets);

    // --- EIP712 / Permit ---
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) external;
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    // --- Upgradeable ---
    function getImplementation() external view returns (address);
    function initialize() external;
}
