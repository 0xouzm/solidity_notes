// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

import {IVat} from "../interfaces/sky/IVat.sol";
import {IJug} from "../interfaces/sky/IJug.sol";
import {VAT, JUG} from "../Constants.sol";

uint256 constant WAD = 10 ** 18;
uint256 constant RAY = 10 ** 27;
uint256 constant RAD = 10 ** 45;

library Math {
    IVat constant vat = IVat(VAT);
    IJug constant jug = IJug(JUG);

    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x >= y ? x : y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x <= y ? x : y;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y / RAY;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * RAY / y;
    }

    // Calculate min and max borrowable DAI for a CDP
    function getMinMaxDai(bytes32 i, address cdpOwner)
        internal
        view
        returns (uint256 min, uint256 max, uint256 cur)
    {
        IVat.Urn memory urn = vat.urns(i, cdpOwner);
        IVat.Ilk memory ilk = vat.ilks(i);

        min = ilk.dust;
        // max debt [rad] = collateral [wad] * liquidation price [ray]
        max = urn.ink * ilk.spot;
        uint256 total = ilk.rate * ilk.Art;
        if (total + max >= ilk.line) {
            max = ilk.line > total ? ilk.line - total : 0;
        }
        // current debt [rad] = stability fee accumulator [ray] * normalized debt [wad]
        cur = ilk.rate * urn.art;
    }

    // DssProxyActions._getDrawDart
    // Calculate normalized debt to borrow
    function calcDebtToBorrow(
        // Destination to send DAI
        address dst,
        bytes32 ilk,
        // Amount of DAI to borrow
        uint256 wad
    )
        internal
        returns (int256 deltaDebt)
    {
        // [ray]
        uint256 rate = jug.drip(ilk);
        // [rad]
        uint256 dai = vat.dai(dst);

        // If there was already enough DAI in the vat balance,
        // just exits it without adding more debt
        if (dai < wad * RAY) {
            // [wad]
            deltaDebt = int256((wad * RAY - dai) / rate);
            deltaDebt = uint256(deltaDebt) * rate < wad * RAY
                ? deltaDebt + 1
                : deltaDebt;
        }
    }

    // DssProxyActions._getWipeDart
    // Calculate normalized debt to repay
    // dai [rad]
    function calcDebtToRepay(uint256 dai, address cdpOwner, bytes32 ilk)
        internal
        view
        returns (int256 deltaDebt)
    {
        IVat.Ilk memory i = vat.ilks(ilk);
        IVat.Urn memory u = vat.urns(ilk, cdpOwner);

        // [wad]
        deltaDebt = int256(dai / i.rate);
        deltaDebt = uint256(deltaDebt) <= u.art ? -deltaDebt : -int256(u.art);
    }

    // DssProxyActions._getWipeAllWad
    // Calculate DAI to repay all debt
    // dai [rad]
    function calcDaiToRepayAll(address src, address cdpOwner, bytes32 ilk)
        internal
        view
        returns (uint256 wad)
    {
        IVat.Ilk memory i = vat.ilks(ilk);
        IVat.Urn memory u = vat.urns(ilk, cdpOwner);
        // Source address to repay DAI from
        uint256 dai = vat.dai(src);

        uint256 rad = u.art * i.rate - dai;
        wad = rad / RAY;

        wad = wad * RAY < rad ? wad + 1 : wad;
    }
}
