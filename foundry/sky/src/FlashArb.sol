// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

import {console} from "forge-std/Test.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IDssFlash, IERC3156FlashBorrower} from "./interfaces/sky/IDssFlash.sol";
import {IDssLitePsm} from "./interfaces/sky/IDssLitePsm.sol";
import {IDaiUsds} from "./interfaces/sky/IDaiUsds.sol";
import {IUniswapV3Pool} from "./interfaces/uni-v3/IUniswapV3Pool.sol";
import {WAD} from "./lib/Math.sol";
import {
    DAI,
    USDC,
    USDS,
    FLASH,
    LITE_PSM_DAI_USDC,
    DAI_USDS
} from "./Constants.sol";

uint160 constant MIN_SQRT_RATIO = 4295128739;
uint160 constant MAX_SQRT_RATIO =
    1461446703485210103287273052203988822378723970342;

contract FlashArb is IERC3156FlashBorrower {
    IERC20 public constant dai = IERC20(DAI);
    IERC20 public constant usds = IERC20(USDS);
    IERC20 public constant usdc = IERC20(USDC);
    IDssFlash public constant flash = IDssFlash(FLASH);
    IDssLitePsm public constant psm = IDssLitePsm(LITE_PSM_DAI_USDC);
    IDaiUsds public constant daiUsds = IDaiUsds(DAI_USDS);

    bytes32 public constant FLASH_CALLBACK_SUCCESS =
        keccak256("ERC3156FlashBorrower.onFlashLoan");

    constructor() {
        dai.approve(address(psm), type(uint256).max);
        dai.approve(address(flash), type(uint256).max);
        dai.approve(address(daiUsds), type(uint256).max);
        usdc.approve(address(psm), type(uint256).max);
        usdc.approve(address(daiUsds), type(uint256).max);
    }

    // inv = false -> price of X in terms of Y
    //       true  -> price of Y in terms of X
    // Normalized with 18 decimals
    function getPrice(address pool, uint256 dec0, uint256 dec1, bool inv)
        public
        view
        returns (uint256)
    {
        IUniswapV3Pool.Slot0 memory slot0 = IUniswapV3Pool(pool).slot0();
        // p = Y / X = price of token X in terms of token Y
        uint256 s = uint256(slot0.sqrtPriceX96);
        uint256 p = (((s * s) >> 96) * 1e18) >> 96;
        p *= dec0;
        p /= dec1;
        if (inv) {
            p = 1e36 / p;
        }
        return p;
    }

    function start(address pool, uint256 amt, uint256 delta, bool up) external {
        address token0 = IUniswapV3Pool(pool).token0();
        address token1 = IUniswapV3Pool(pool).token1();
        require(token0 == USDC || token1 == USDC, "not USDC pool");

        (uint256 dec0, uint256 dec1, bool inv) = token0 == USDC
            ? (uint256(1e6), uint256(1e18), false)
            : (uint256(1e18), uint256(1e6), true);
        // Price of USDC in terms of DAI or USDS
        uint256 p = getPrice(pool, dec0, dec1, inv);
        require(p < 1e18 - delta || 1e18 + delta < p, "no arb");

        // if DAI < USDC -> buy DAI
        // if DAI > USDC -> sell DAI
        if (up) {
            require(p > 1e18, "p <= 1");
        } else {
            require(p < 1e18, "p >= 1");
        }

        flash.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(dai),
            amt,
            abi.encode(msg.sender, pool, token0, token1, up)
        );
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amt,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        (
            address caller,
            address pool,
            address token0,
            address token1,
            bool up
        ) = abi.decode(data, (address, address, address, address, bool));

        if (up) {
            buy(pool, token0, token1, amt);
        } else {
            sell(pool, token0, token1, amt);
        }

        uint256 bal = dai.balanceOf(address(this));
        require(bal > amt + fee, "no profit");
        dai.transfer(caller, bal - (amt + fee));

        return FLASH_CALLBACK_SUCCESS;
    }

    // DAI / USDS < USDC
    // flash loan DAI -> PSM DAI -> USDC -> swap USDC -> DAI or USDS -> repay flash loan + fee
    //                                                            |
    //                                                            +-> convert USDS -> DAI -> replay flash loan + fee
    function buy(address pool, address token0, address token1, uint256 daiAmt)
        private
    {
        // DAI amt = USDC amt * (1 + fee) * 1e12
        uint256 usdcAmt = daiAmt * WAD / (WAD + psm.tout()) / 1e12;
        psm.buyGem(address(this), usdcAmt);

        // Swap USDC -> DAI or USDS
        (address tokenOut, uint256 amtOut) =
            swap(pool, token0, token1, USDC, usdcAmt);
        if (tokenOut == USDS) {
            // Convert USDS -> DAI
            daiUsds.usdsToDai(address(this), amtOut);
        }
    }

    // DAI / USDS > USDC
    // flash loan DAI + --------> swap DAI or USDS +-> USDC -> PSM USDC -> DAI -> repay flash loan + fee
    //                |                    |
    //                +-> convert DAI -> USDS
    function sell(address pool, address token0, address token1, uint256 daiAmt)
        private
    {
        address tokenIn = token0 == DAI || token1 == DAI ? DAI : USDS;
        if (tokenIn == USDS) {
            // Convert DAI -> USDS
            daiUsds.daiToUsds(address(this), daiAmt);
        }

        // Swap DAI or USDS -> USDC
        // uint256 usdcAmt = swap();
        (, uint256 usdcAmt) = swap(pool, token0, token1, tokenIn, daiAmt);
        psm.sellGem(address(this), usdcAmt);
    }

    function swap(
        address pool,
        address token0,
        address token1,
        address tokenIn,
        uint256 amtIn
    ) public returns (address tokenOut, uint256 amtOut) {
        bool zeroForOne = tokenIn == token0;
        (int256 amt0, int256 amt1) = IUniswapV3Pool(pool)
            .swap({
                recipient: address(this),
                zeroForOne: zeroForOne,
                amountSpecified: int256(amtIn),
                sqrtPriceLimitX96: zeroForOne
                    ? MIN_SQRT_RATIO + 1
                    : MAX_SQRT_RATIO - 1,
                data: abi.encode(token0, token1, zeroForOne)
            });

        if (zeroForOne) {
            require(amt1 <= 0, "amt1 > 0");
            return (token1, uint256(-amt1));
        } else {
            require(amt0 <= 0, "amt0 > 0");
            return (token0, uint256(-amt0));
        }
    }

    function uniswapV3SwapCallback(
        int256 amt0,
        int256 amt1,
        bytes calldata data
    ) external {
        // amt0, amt1 < 0 -> transferred out from the pool
        (address token0, address token1, bool zeroForOne) =
            abi.decode(data, (address, address, bool));
        if (zeroForOne) {
            IERC20(token0).transfer(msg.sender, uint256(amt0));
        } else {
            IERC20(token1).transfer(msg.sender, uint256(amt1));
        }
    }

    function sweep(address token) external {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, "bal = 0");
        IERC20(token).transfer(msg.sender, bal);
    }
}
