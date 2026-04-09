// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IUniswapV3Pool} from "../src/interfaces/uni-v3/IUniswapV3Pool.sol";
import {FlashSwap} from "../src/FlashSwap.sol";
import {DAI, USDS, USDC} from "../src/Constants.sol";

address constant UNI_V3_DAI_USDC_100 =
    0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168;
address constant UNI_V3_USDC_WETH_500 =
    0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;

contract FlashSwapTest is Test {
    IERC20 constant dai = IERC20(DAI);
    IERC20 constant usds = IERC20(USDS);
    IERC20 constant usdc = IERC20(USDC);

    FlashSwap flash;
    // address constant POOL = UNI_V3_USDC_WETH_500;
    address constant POOL = UNI_V3_DAI_USDC_100;
    IUniswapV3Pool constant pool = IUniswapV3Pool(POOL);

    function setUp() public {
        flash = new FlashSwap();

        deal(DAI, address(this), 1e6 * 1e18);
        deal(USDS, address(this), 1e6 * 1e18);
        deal(USDC, address(this), 1e6 * 1e6);
    }

    function test_buy() public {
        dai.transfer(address(flash), 1e6 * 1e18);
        flash.swap(address(pool), DAI, USDC, DAI, 1e6 * 1e18);

        uint256 p = flash.getPrice(address(pool), 1e18, 1e6, true);
        console.log("p %e", p);

        uint256 bal0 = dai.balanceOf(address(this));
        flash.start({pool: address(pool), amt: 1e3 * 1e18, delta: 1, up: true});
        uint256 bal1 = dai.balanceOf(address(this));

        console.log("diff %e", bal1 - bal0);
    }
}
