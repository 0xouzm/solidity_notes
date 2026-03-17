"""
Manim animation: MakerDAO Stability Fee & Rate Accumulator
Run with: manim -pql stability_fee.py StabilityFeeAnimation
For high quality: manim -pqh stability_fee.py StabilityFeeAnimation
"""

from manim import *

# ── Palette ───────────────────────────────────────────────────────────────────
BG = "#111827"
CHALK = "#F0EDE6"
ORANGE = "#F97316"
TEAL = "#2DD4BF"
RED_H = "#F87171"
GREEN_B = "#4ADE80"
PURPLE_B = "#A78BFA"


def ct(text, size=32, color=CHALK, **kwargs):
    """Chalk text — color defaults to CHALK but is overridable."""
    return Text(text, font_size=size, color=color, **kwargs)


def mt(tex, size=30, color=WHITE):
    """Single MathTex with explicit keyword args (avoids positional-arg trap)."""
    return MathTex(tex, font_size=size, color=color)


def section_title(label):
    t = ct(label, size=40, weight=BOLD)
    ul = Line(t.get_left(), t.get_right(), color=CHALK).next_to(t, DOWN, buff=0.08)
    return VGroup(t, ul)


def boxed(mob, color=GREEN_B):
    return SurroundingRectangle(mob, color=color, buff=0.22, corner_radius=0.06)


# ═════════════════════════════════════════════════════════════════════════════
class StabilityFeeAnimation(Scene):

    def setup(self):
        self.camera.background_color = BG

    # ── ACT 1 ─────────────────────────────────────────────────────────────────
    def act1_stability_fee(self):
        hdr = section_title("Stability Fee").to_edge(UP, buff=0.4)
        self.play(Write(hdr[0]), Create(hdr[1]))
        self.wait(0.2)

        bullets = VGroup(
            ct("Fee for borrowing USDS or DAI", size=28),
            ct("Fee compounds every second", size=28),
            ct("Stability fee rate may change every second", size=28),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.28)
        bullets.next_to(hdr, DOWN, buff=0.5).to_edge(LEFT, buff=0.6)

        for b in bullets:
            self.play(FadeIn(b, shift=RIGHT * 0.15), run_time=0.5)
        self.wait(0.3)

        sub = section_title("How to calculate debt")
        sub.scale(0.75).next_to(bullets, DOWN, buff=0.5).to_edge(LEFT, buff=0.6)
        self.play(Write(sub[0]), Create(sub[1]))

        line1 = VGroup(
            ct("Mint ", size=26),
            mt("d", size=26, color=ORANGE),
            ct(" amount of USDS at time ", size=26),
            mt("k", size=26, color=TEAL),
        ).arrange(RIGHT, buff=0.05)

        line2 = VGroup(
            ct("What is the debt after ", size=26),
            mt("j", size=26, color=TEAL),
            ct(" seconds?", size=26),
        ).arrange(RIGHT, buff=0.05)

        line3 = VGroup(
            mt(r"r_t", size=28, color=RED_H),
            ct(" = stability fee rate at time ", size=26),
            mt("t", size=28, color=TEAL),
        ).arrange(RIGHT, buff=0.08)

        info = VGroup(line1, line2, line3).arrange(DOWN, aligned_edge=LEFT, buff=0.22)
        info.next_to(sub, DOWN, buff=0.35).to_edge(LEFT, buff=0.9)
        for row in info:
            self.play(FadeIn(row), run_time=0.45)
        self.wait(0.2)

        debt_lbl = VGroup(
            ct("Debt after ", size=26),
            mt("j", size=26, color=TEAL),
            ct(" seconds", size=26),
        ).arrange(RIGHT, buff=0.05)

        formula = MathTex(
            r"d\,(1+r_k)(1+r_{k+1})(1+r_{k+2})\ldots(1+r_{k+j-1})",
            font_size=28,
        )
        formula[0][0].set_color(ORANGE)
        box = boxed(formula)
        grp = VGroup(debt_lbl, VGroup(formula, box)).arrange(
            DOWN, aligned_edge=LEFT, buff=0.18
        )
        grp.next_to(info, DOWN, buff=0.4).to_edge(LEFT, buff=0.6)

        self.play(FadeIn(debt_lbl))
        self.play(Write(formula), Create(box))
        self.wait(2)

    # ── ACT 2 ─────────────────────────────────────────────────────────────────
    def act2_rate_accumulator(self):
        hdr = section_title("Rate Accumulator").to_edge(UP, buff=0.4)
        self.play(Write(hdr[0]), Create(hdr[1]))

        define = ct("Define rate accumulator", size=30)
        define.next_to(hdr, DOWN, buff=0.4).to_edge(LEFT, buff=0.6)
        self.play(FadeIn(define))

        rt = MathTex(
            r"R(t) = (1+r_0)(1+r_1)(1+r_2)\ldots(1+r_t)",
            font_size=30,
        )
        rt_box = boxed(rt, color=PURPLE_B)
        rt_grp = VGroup(rt, rt_box)
        rt_grp.next_to(define, DOWN, buff=0.3).to_edge(LEFT, buff=0.6)
        self.play(Write(rt), Create(rt_box))
        self.wait(0.4)

        debt_lbl = VGroup(
            ct("Debt after ", size=26),
            mt("j", size=26, color=TEAL),
            ct(" seconds", size=26),
        ).arrange(RIGHT, buff=0.05)
        debt_lbl.next_to(rt_grp, DOWN, buff=0.4).to_edge(LEFT, buff=0.6)
        self.play(FadeIn(debt_lbl))

        step1 = MathTex(
            r"d\,(1+r_k)(1+r_{k+1})\ldots(1+r_{k+j-1})",
            font_size=26,
        )
        step1[0][0].set_color(ORANGE)
        step1.next_to(debt_lbl, DOWN, buff=0.18).to_edge(LEFT, buff=0.9)
        self.play(Write(step1))

        # Show the telescoping fraction (no \cancel — draws two stacked rows instead)
        step2_num = MathTex(
            r"(1+r_0)(1+r_1)\cdots(1+r_{k-1})\cdots(1+r_{k+j-1})",
            font_size=20,
            color=CHALK,
        )
        step2_den = MathTex(
            r"(1+r_0)(1+r_1)\cdots(1+r_{k-1})",
            font_size=20,
            color=CHALK,
        )
        frac_line = Line(LEFT * 2.6, RIGHT * 2.6, color=CHALK, stroke_width=1.5)

        # Layout: = d  [fraction]
        eq_d = MathTex(r"= \; d", font_size=26)
        eq_d[0][2].set_color(ORANGE)

        step2_num.next_to(frac_line, UP, buff=0.08)
        step2_den.next_to(frac_line, DOWN, buff=0.08)
        frac_grp = VGroup(step2_num, frac_line, step2_den)
        step2_full = VGroup(eq_d, frac_grp).arrange(RIGHT, buff=0.15)
        step2_full.next_to(step1, DOWN, buff=0.28).to_edge(LEFT, buff=0.6)

        self.play(Write(step2_full))
        self.wait(0.3)

        # Cross out denominator terms that cancel
        cancel_top = Cross(step2_num[0][:17], stroke_color=RED_H, stroke_width=1.8)
        cancel_bot = Cross(step2_den, stroke_color=RED_H, stroke_width=1.8)
        self.play(Create(cancel_top), Create(cancel_bot))
        self.wait(0.3)

        final = MathTex(r"= \; d\;\frac{R(k+j-1)}{R(k-1)}", font_size=36)
        final[0][2].set_color(ORANGE)
        final_box = boxed(final)
        final_grp = VGroup(final, final_box)
        final_grp.next_to(step2_full, DOWN, buff=0.35).to_edge(LEFT, buff=0.6)

        self.play(TransformFromCopy(step1, final), run_time=1.1)
        self.play(Create(final_box))
        self.wait(2)

    # ── ACT 3 ─────────────────────────────────────────────────────────────────
    def act3_changing_d(self):
        title = (
            VGroup(
                ct("How to calculate debt when ", size=30),
                mt("d", size=30, color=ORANGE),
                ct(" changes?", size=30),
            )
            .arrange(RIGHT, buff=0.06)
            .to_edge(UP, buff=0.4)
        )
        self.play(Write(title))

        b1 = VGroup(
            ct("Mint ", size=26),
            mt("d", size=26, color=ORANGE),
            ct(" amount of USDS at time ", size=26),
            mt("k", size=26, color=TEAL),
        ).arrange(RIGHT, buff=0.05)
        b2 = VGroup(
            ct("Mint ", size=26),
            mt(r"\Delta d", size=26, color=RED_H),
            ct(" amount of USDS at time ", size=26),
            mt("k+j", size=26, color=TEAL),
        ).arrange(RIGHT, buff=0.05)
        b3 = VGroup(
            ct("What is the debt after ", size=26),
            mt("n", size=26, color=TEAL),
            ct(" seconds from ", size=26),
            mt("k", size=26, color=TEAL),
            ct("?", size=26),
        ).arrange(RIGHT, buff=0.05)

        bullets = VGroup(b1, b2, b3).arrange(DOWN, aligned_edge=LEFT, buff=0.2)
        bullets.next_to(title, DOWN, buff=0.3).to_edge(LEFT, buff=0.6)
        for b in bullets:
            self.play(FadeIn(b), run_time=0.4)

        # ── Staircase graph ──────────────────────────────────────────────────
        ax = Axes(
            x_range=[0, 4, 1],
            y_range=[0, 2.8, 1],
            x_length=4.6,
            y_length=2.4,
            axis_config={"color": CHALK, "stroke_width": 2, "include_ticks": False},
        )
        ax.next_to(bullets, DOWN, buff=0.25).to_edge(LEFT, buff=0.8)
        self.play(Create(ax))

        def albl(tex, pt, direction, col=CHALK, sz=20):
            return MathTex(tex, font_size=sz, color=col).next_to(
                ax.c2p(*pt), direction, buff=0.1
            )

        lbl_k = albl("k", [0, 0], DOWN)
        lbl_kj = albl("k{+}j", [1.8, 0], DOWN)
        lbl_kn = albl("k{+}n", [3.5, 0], DOWN)
        lbl_d = albl("d", [0, 0.85], LEFT, col=ORANGE)
        # Place text labels relative to the axis labels (mobjects), not raw points
        mint_d = ct("mint d", size=16, color=ORANGE).next_to(lbl_k, DOWN, buff=0.05)
        mint_dd = (
            VGroup(ct("mint ", size=16), mt(r"\Delta d", size=16, color=RED_H))
            .arrange(RIGHT, buff=0.03)
            .next_to(lbl_kj, DOWN, buff=0.05)
        )

        self.play(FadeIn(VGroup(lbl_k, lbl_kj, lbl_kn, lbl_d, mint_d, mint_dd)))

        def stairs(x_start, x_end, y_start, slope, n_steps):
            pts, x, y = [], x_start, y_start
            step_w = (x_end - x_start) / n_steps
            for _ in range(n_steps):
                pts += [ax.c2p(x, y), ax.c2p(x + step_w, y)]
                y += slope
                x += step_w
            m = VMobject(color=ORANGE, stroke_width=2.5)
            m.set_points_as_corners(pts)
            return m, y

        seg1, y1 = stairs(0.0, 1.8, 0.85, 0.022, 10)
        self.play(Create(seg1))

        jump = DashedLine(
            ax.c2p(1.8, y1), ax.c2p(1.8, y1 + 0.55), color=RED_H, stroke_width=2
        )
        dd_label = mt(r"+\Delta d", size=20, color=RED_H).next_to(
            ax.c2p(1.8, y1 + 0.28), RIGHT, buff=0.1
        )
        self.play(Create(jump), FadeIn(dd_label))

        seg2, y2 = stairs(1.8, 3.5, y1 + 0.55, 0.032, 10)
        vert = DashedLine(
            ax.c2p(3.5, 0), ax.c2p(3.5, y2), color=CHALK, stroke_width=1.5
        )
        self.play(Create(seg2), Create(vert))
        self.wait(0.3)

        # ── Debt at k+j ─────────────────────────────────────────────────────
        at_kj = VGroup(ct("at ", size=24), mt("k{+}j", size=24, color=TEAL)).arrange(
            RIGHT, buff=0.05
        )
        debt_kj = MathTex(
            r"\mathrm{debt} = d\,\frac{R(k{+}j{-}1)}{R(k{-}1)} + \Delta d",
            font_size=24,
            color=RED_H,
        )
        g_kj = VGroup(at_kj, debt_kj).arrange(DOWN, aligned_edge=LEFT, buff=0.15)
        g_kj.to_edge(RIGHT, buff=0.45).shift(UP * 0.6)
        self.play(FadeIn(at_kj), Write(debt_kj))
        self.wait(0.3)

        # ── Debt at k+n ─────────────────────────────────────────────────────
        at_kn = VGroup(ct("at ", size=24), mt("k{+}n", size=24, color=TEAL)).arrange(
            RIGHT, buff=0.05
        )
        debt_kn = MathTex(
            r"\mathrm{debt} = \!\left(d\,\frac{R(k{+}j{-}1)}{R(k{-}1)}+\Delta d\right)"
            r"\frac{R(k{+}n{-}1)}{R(k{+}j{-}1)}",
            font_size=18,
            color=RED_H,
        )
        g_kn = VGroup(at_kn, debt_kn).arrange(DOWN, aligned_edge=LEFT, buff=0.15)
        g_kn.next_to(g_kj, DOWN, buff=0.3)
        self.play(FadeIn(at_kn), Write(debt_kn))
        self.wait(0.4)

        # ── Final boxed formula ──────────────────────────────────────────────
        final_f = MathTex(
            r"= \left(\frac{d}{R(k{-}1)} + \frac{\Delta d}{R(k{+}j{-}1)}\right) R(k{+}n{-}1)",
            font_size=20,
        )
        final_box = boxed(final_f)
        final_grp = VGroup(final_f, final_box).next_to(g_kn, DOWN, buff=0.3)
        self.play(TransformFromCopy(debt_kn, final_f), run_time=1.0)
        self.play(Create(final_box))
        self.wait(0.3)

        # ── urn.art × ilk.rate annotation ───────────────────────────────────
        urn_art = ct("urn.art", size=17, color=ORANGE)
        ilk_rate = ct("ilk.rate", size=17, color=TEAL)
        row = VGroup(urn_art, mt(r"\times", size=17), ilk_rate).arrange(
            RIGHT, buff=0.35
        )
        row.next_to(final_grp, DOWN, buff=0.14)

        norm = ct("normalized debt", size=13, color=GRAY)
        norm.next_to(urn_art, DOWN, buff=0.3)
        arrow = Arrow(
            norm.get_top(),
            urn_art.get_bottom(),
            buff=0.05,
            stroke_width=1.5,
            color=GRAY,
            max_tip_length_to_length_ratio=0.25,
        )

        self.play(FadeIn(row))
        self.play(GrowArrow(arrow), FadeIn(norm))
        self.wait(2.5)

    # ── Main ──────────────────────────────────────────────────────────────────
    def construct(self):
        acts = [
            self.act1_stability_fee,
            self.act2_rate_accumulator,
            self.act3_changing_d,
        ]
        for i, act in enumerate(acts):
            act()
            if i < len(acts) - 1:
                self.play(*[FadeOut(m) for m in self.mobjects], run_time=0.6)
                self.wait(0.15)
