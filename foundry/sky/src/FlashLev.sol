// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

import {console} from "forge-std/Test.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IDssFlash, IERC3156FlashBorrower} from "./interfaces/sky/IDssFlash.sol";
import {WAD} from "./lib/Math.sol";
import {DAI, FLASH} from "./Constants.sol";

contract Flash is IERC3156FlashBorrower {
    IERC20 public constant dai = IERC20(DAI);
    IDssFlash public constant flash = IDssFlash(FLASH);
    bytes32 public constant FLASH_CALLBACK_SUCCESS =
        keccak256("ERC3156FlashBorrower.onFlashLoan");

    function start(uint256 amt) external {
        flash.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(dai),
            amt,
            abi.encode(msg.sender)
        );
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amt,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        require(msg.sender == FLASH, "not authorized");
        require(initiator == address(this), "initiator != address(this)");

        address caller = abi.decode(data, (address));
        dai.transferFrom(caller, address(this), fee);

        dai.approve(FLASH, amt + fee);

        return FLASH_CALLBACK_SUCCESS;
    }
}
