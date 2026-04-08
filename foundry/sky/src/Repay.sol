// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

import {console} from "forge-std/Test.sol";
import {IGemJoin} from "./interfaces/sky/IGemJoin.sol";
import {IDaiJoin} from "./interfaces/sky/IDaiJoin.sol";
import {IVat} from "./interfaces/sky/IVat.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {SafeTransfer} from "./lib/SafeTransfer.sol";
import {Math, WAD, RAY, RAD} from "./lib/Math.sol";
import {Auth} from "./lib/Auth.sol";
import {VAT} from "./Constants.sol";

contract Repay is Auth {
    using SafeTransfer for IERC20;

    IVat public constant vat = IVat(VAT);
    IGemJoin public immutable gemJoin;
    IDaiJoin public immutable daiJoin;
    IERC20 public immutable gem;
    IERC20 public immutable dai;
    // Decimals of gem
    uint256 public immutable dec;
    bytes32 public immutable ilk;

    constructor(address _gemJoin, address _daiJoin) {
        gemJoin = IGemJoin(_gemJoin);
        daiJoin = IDaiJoin(_daiJoin);

        gem = IERC20(gemJoin.gem());
        dai = IERC20(daiJoin.dai());

        dec = gemJoin.dec();
        require(dec <= 18, "decimals > 18");
        ilk = gemJoin.ilk();
    }

    function lock(uint256 amt) external auth {
        gem.safeTransferFrom(msg.sender, address(this), amt);
        gem.approve(address(gemJoin), amt);
        gemJoin.join(address(this), amt);

        uint256 wad = amt * 10 ** (18 - dec);

        vat.frob({
            i: ilk,
            u: address(this),
            v: address(this),
            w: address(this),
            dink: int256(wad),
            dart: 0
        });
    }

    function borrow(uint256 amt) external auth {
        int256 dart = Math.calcDebtToBorrow(address(this), ilk, amt);
        vat.frob({
            i: ilk,
            u: address(this),
            v: address(this),
            w: address(this),
            dink: 0,
            dart: dart
        });

        if (vat.can(address(this), address(daiJoin)) == 0) {
            vat.hope(address(daiJoin));
        }

        daiJoin.exit(msg.sender, amt);
    }

    function repay(uint256 amt) external auth {
        dai.safeTransferFrom(msg.sender, address(this), amt);
        dai.approve(address(daiJoin), amt);
        daiJoin.join(address(this), amt);

        int256 dart = Math.calcDebtToRepay(amt * RAY, address(this), ilk);
        vat.frob({
            i: ilk,
            u: address(this),
            v: address(this),
            w: address(this),
            dink: 0,
            dart: dart
        });

        // Refund excess
        uint256 rem = vat.dai(address(this));
        if (rem / RAY > 0) {
            vat.hope(address(daiJoin));
            daiJoin.exit(msg.sender, rem / RAY);
        }
    }

    function repayAll() external auth {
        uint256 amt = Math.calcDaiToRepayAll(address(this), address(this), ilk);

        dai.safeTransferFrom(msg.sender, address(this), amt);
        dai.approve(address(daiJoin), amt);
        daiJoin.join(address(this), amt);

        IVat.Urn memory urn = vat.urns(ilk, address(this));
        vat.frob({
            i: ilk,
            u: address(this),
            v: address(this),
            w: address(this),
            dink: 0,
            dart: -int256(urn.art)
        });
    }
}
