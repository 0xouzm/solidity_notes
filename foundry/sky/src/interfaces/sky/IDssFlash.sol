// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IERC3156FlashBorrower {
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IERC3156FlashLender {
    /**
     * @dev The amount of currency available to be lent.
     * @param token The loan currency.
     * @return The amount of `token` that can be borrowed.
     */
    function maxFlashLoan(address token) external view returns (uint256);

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(address token, uint256 amount)
        external
        view
        returns (uint256);

    /**
     * @dev Initiate a flash loan.
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

interface IVatDaiFlashBorrower {
    function onVatDaiFlashLoan(
        address initiator,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

/// @title IDssFlash - Interface for MakerDAO Flash Mint Module
/// @notice Provides zero-fee flash loans in DAI or internal vat dai
interface IDssFlash is IERC3156FlashLender {
    // --- Auth ---
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;

    // --- Immutables ---
    function vat() external view returns (address);
    function daiJoin() external view returns (address);
    function dai() external view returns (address);

    // --- Data ---
    function max() external view returns (uint256); // max borrowable [wad]

    // --- Constants ---
    function CALLBACK_SUCCESS() external view returns (bytes32);
    function CALLBACK_SUCCESS_VAT_DAI() external view returns (bytes32);

    // --- Administration ---
    function file(bytes32 what, uint256 data) external;

    // --- ERC-3156 (inherited) ---
    // function maxFlashLoan(address token) external view returns (uint256);
    // function flashFee(address token, uint256 amount) external view returns (uint256);
    // function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data) external returns (bool);

    // --- Vat Dai Flash Loan ---
    function vatDaiFlashLoan(
        IVatDaiFlashBorrower receiver,
        uint256 amount, // [rad]
        bytes calldata data
    ) external returns (bool);

    // --- Events ---
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event File(bytes32 indexed what, uint256 data);
    event FlashLoan(
        address indexed receiver, address token, uint256 amount, uint256 fee
    );
    event VatDaiFlashLoan(
        address indexed receiver, uint256 amount, uint256 fee
    );
}
