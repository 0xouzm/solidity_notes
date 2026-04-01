from manim import *

DEPTH = 3


def hash_str(a, b):
    return f"h({a},{b})"


def build_tree(depth):
    num_leaves = 2**depth
    tree = {}
    for i in range(num_leaves):
        tree[(0, i)] = "0"
    for level in range(1, depth + 1):
        width = num_leaves >> level
        for i in range(width):
            l = tree[(level - 1, 2 * i)]
            r = tree[(level - 1, 2 * i + 1)]
            tree[(level, i)] = hash_str(l, r)
    return tree


class Init(Scene):
    def construct(self):
        num_leaves = 2**DEPTH
        tree = build_tree(DEPTH)

        NODE_COLOR = BLUE_C
        EDGE_COLOR = GRAY_C
        HIGHLIGHT = YELLOW
        ZEROS_COLOR = WHITE

        FONT_SIZE = 11

        # Per-level node dimensions: (width, height)
        NODE_DIMS = {
            0: (0.55, 0.35),  # leaves: small
            1: (1.30, 0.38),
            2: (1.55, 0.40),
            3: (3.2, 0.42),  # root: wider to fit full hash
        }

        # Max chars per level before truncating
        MAX_CHARS = [3, 7, 13, 25]

        def node_dims(level):
            return NODE_DIMS.get(level, NODE_DIMS[DEPTH])

        def display_val(level, idx):
            val = tree[(level, idx)]
            mc = MAX_CHARS[min(level, len(MAX_CHARS) - 1)]
            return val if len(val) <= mc else val[: mc - 1] + "…"

        # Layout: leaves span TREE_LEFT..TREE_RIGHT
        TREE_LEFT = -5.5
        TREE_RIGHT = 3.0
        leaf_w = node_dims(0)[0]
        LEAF_SEP = (TREE_RIGHT - TREE_LEFT - leaf_w) / (num_leaves - 1)
        Y_STEP = 1.55
        y_bottom = -3.1
        X_OFFSET = (TREE_LEFT + TREE_RIGHT) / 2

        def leaf_x(idx):
            return idx * LEAF_SEP - (num_leaves - 1) * LEAF_SEP / 2

        def node_pos(level, idx):
            if level == 0:
                x = leaf_x(idx)
            else:
                left_leaf = idx * (2**level)
                right_leaf = left_leaf + (2**level) - 1
                x = (leaf_x(left_leaf) + leaf_x(right_leaf)) / 2
            y = y_bottom + level * Y_STEP
            return np.array([x + X_OFFSET, y, 0])

        def make_node(level, idx):
            pos = node_pos(level, idx)
            disp = display_val(level, idx)
            nw, nh = node_dims(level)
            rect = RoundedRectangle(
                width=nw,
                height=nh,
                corner_radius=0.07,
                fill_color=BLACK,
                fill_opacity=1,
                stroke_color=NODE_COLOR,
                stroke_width=2.2,
            )
            rect.move_to(pos)
            txt = Text(disp, font_size=FONT_SIZE, color=NODE_COLOR)
            txt.move_to(pos)
            return VGroup(rect, txt)

        def edge_between(level_a, idx_a, level_b, idx_b):
            pa = node_pos(level_a, idx_a)
            pb = node_pos(level_b, idx_b)
            _, ha = node_dims(level_a)
            _, hb = node_dims(level_b)
            start = pa + np.array([0, -ha / 2, 0])
            end = pb + np.array([0, hb / 2, 0])
            return Line(start, end, stroke_color=EDGE_COLOR, stroke_width=1.8)

        # ── zeros array ───────────────────────────────────────────────
        arr_x = 5.6
        cell_w = 1.7
        cell_h = 0.50

        zeros_title = Text("zeros[ ]", font_size=22, color=ZEROS_COLOR)
        zeros_title.move_to(np.array([arr_x, y_bottom + DEPTH * Y_STEP, 0]))

        arr_cells = []
        arr_texts = []
        for i in range(DEPTH):
            y = y_bottom + i * Y_STEP
            rect = RoundedRectangle(
                width=cell_w,
                height=cell_h,
                corner_radius=0.08,
                fill_color=BLACK,
                fill_opacity=1,
                stroke_color=ZEROS_COLOR,
                stroke_width=2,
            )
            rect.move_to(np.array([arr_x, y, 0]))
            idx_lbl = Text(f"[{i}]", font_size=15, color=GRAY)
            idx_lbl.next_to(rect, LEFT, buff=0.1)
            placeholder = Text("?", font_size=14, color=DARK_GRAY)
            placeholder.move_to(rect.get_center())
            arr_cells.append(VGroup(rect, idx_lbl))
            arr_texts.append(placeholder)

        self.play(
            Write(zeros_title),
            *[FadeIn(c) for c in arr_cells],
            *[Write(t) for t in arr_texts],
        )
        self.wait(0.3)

        # ── phase 1: build tree bottom-up ─────────────────────────────
        node_mobs = {}

        leaf_mobs = [make_node(0, i) for i in range(num_leaves)]
        for i, m in enumerate(leaf_mobs):
            node_mobs[(0, i)] = m
        self.play(
            LaggedStart(*[FadeIn(m) for m in leaf_mobs], lag_ratio=0.12), run_time=1.5
        )

        for level in range(1, DEPTH + 1):
            width = num_leaves >> level

            edges = []
            for i in range(width):
                edges.append(edge_between(level, i, level - 1, 2 * i))
                edges.append(edge_between(level, i, level - 1, 2 * i + 1))
            self.play(
                LaggedStart(*[Create(e) for e in edges], lag_ratio=0.06), run_time=0.8
            )

            for i in range(width):
                lc = node_mobs[(level - 1, 2 * i)]
                rc = node_mobs[(level - 1, 2 * i + 1)]

                self.play(
                    lc[0].animate.set_stroke(color=HIGHLIGHT, width=4),
                    rc[0].animate.set_stroke(color=HIGHLIGHT, width=4),
                    run_time=0.35,
                )

                lv = display_val(level - 1, 2 * i)
                rv = display_val(level - 1, 2 * i + 1)
                mid = (node_pos(level - 1, 2 * i) + node_pos(level - 1, 2 * i + 1)) / 2
                hash_lbl = Text(f"h({lv},{rv})", font_size=9, color=HIGHLIGHT)
                hash_lbl.move_to(mid + UP * 0.3)
                if hash_lbl.width > 2.8:
                    hash_lbl.scale(2.8 / hash_lbl.width)
                self.play(FadeIn(hash_lbl, shift=UP * 0.15), run_time=0.28)

                m = make_node(level, i)
                node_mobs[(level, i)] = m

                self.play(hash_lbl.animate.move_to(m.get_center()), run_time=0.3)
                self.play(
                    FadeIn(m),
                    FadeOut(hash_lbl),
                    lc[0].animate.set_stroke(color=NODE_COLOR, width=2.2),
                    rc[0].animate.set_stroke(color=NODE_COLOR, width=2.2),
                    run_time=0.5,
                )

        self.wait(0.5)

        # ── phase 2: highlight each level → fill zeros[] ──────────────
        for level in range(DEPTH):
            width = num_leaves >> level
            level_nodes = [node_mobs[(level, i)] for i in range(width)]

            self.play(
                *[
                    m[0].animate.set_stroke(color=HIGHLIGHT, width=4)
                    for m in level_nodes
                ],
                run_time=0.4,
            )

            val = display_val(level, 0)
            new_t = Text(val, font_size=FONT_SIZE, color=ZEROS_COLOR)
            new_t.move_to(level_nodes[-1].get_center())
            self.play(new_t.animate.move_to(arr_cells[level][0].get_center()))

            if new_t.width > cell_w - 0.12:
                new_t.scale((cell_w - 0.12) / new_t.width)
            self.play(Transform(arr_texts[level], new_t), run_time=0.6)
            self.play(
                arr_cells[level][0].animate.set_stroke(color=HIGHLIGHT, width=2.2),
                run_time=0.3,
            )
            self.wait(0.3)

            if width > 1:
                self.play(
                    *[
                        m[0].animate.set_stroke(color=NODE_COLOR, width=2.2)
                        for m in level_nodes[:]
                    ],
                    run_time=0.3,
                )

        self.wait(2.0)
