from manim import *

DEPTH = 3
ZERO = "0"


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
            return val
            # mc = MAX_CHARS[min(level, len(MAX_CHARS) - 1)]
            # return val if len(val) <= mc else val[: mc - 1] + "…"

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


class Insert(Scene):
    def construct(self):
        # ── colors and styles ──
        NODE_COLOR = BLUE_C
        EDGE_COLOR = GRAY_C
        HIGHLIGHT = YELLOW
        ZEROS_COLOR = GREEN
        RIGHTMOST_COLOR = GREEN
        FONT_SIZE = 11

        num_leaves = 2**DEPTH
        Y_STEP = 1.55
        y_bottom = -3.1
        TREE_LEFT, TREE_RIGHT = -5.5, 3.0
        X_OFFSET = (TREE_LEFT + TREE_RIGHT) / 2
        NODE_DIMS = {0: 0.55, 1: 1.3, 2: 1.55, 3: 3.2}

        # ── node positions ──
        def leaf_x(idx):
            leaf_w = NODE_DIMS[0]
            LEAF_SEP = (TREE_RIGHT - TREE_LEFT - leaf_w) / (num_leaves - 1)
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

        # ── precompute zero hashes ──
        zero_hashes = ["0"]
        for l in range(1, DEPTH + 1):
            zero_hashes.append(hash_str(zero_hashes[l - 1], zero_hashes[l - 1]))

        # ── build nodes ──
        node_mobs = {}
        node_vals = {}
        for level in range(DEPTH + 1):
            width = 2 ** (DEPTH - level)
            for i in range(width):
                pos = node_pos(level, i)
                nw = NODE_DIMS.get(level, 1.5)
                rect = RoundedRectangle(
                    width=nw,
                    height=0.35,
                    corner_radius=0.07,
                    fill_opacity=0,
                    stroke_color=NODE_COLOR,
                    stroke_width=2,
                ).move_to(pos)
                txt = Text(
                    zero_hashes[level], font_size=FONT_SIZE, color=NODE_COLOR
                ).move_to(pos)
                node_mobs[(level, i)] = VGroup(rect, txt)
                node_vals[(level, i)] = zero_hashes[level]

        # ── edges ──
        def edge_between(lc, ic, lp, ip):
            rect_child, _ = node_mobs[(lc, ic)]
            rect_parent, _ = node_mobs[(lp, ip)]
            return Line(
                rect_child.get_top(),
                rect_parent.get_bottom(),
                stroke_width=2,
                color=EDGE_COLOR,
            )

        edges = []
        for level in range(1, DEPTH + 1):
            width = 2 ** (DEPTH - level)
            for i in range(width):
                edges.append(edge_between(level - 1, 2 * i, level, i))
                edges.append(edge_between(level - 1, 2 * i + 1, level, i))

        self.play(
            LaggedStart(*[FadeIn(m) for m in node_mobs.values()], lag_ratio=0.05),
            LaggedStart(*[Create(e) for e in edges], lag_ratio=0.02),
            run_time=2,
        )

        # ── rightmost-left array ──
        arr_x = 5.6
        cell_w, cell_h = 1.7, 0.50
        zeros_title = Text("nodes[ ]", font_size=22, color=ZEROS_COLOR)
        zeros_title.move_to(np.array([arr_x, y_bottom + DEPTH * Y_STEP + 0.65, 0]))

        arr_cells = []
        arr_texts = []
        for i in range(DEPTH):
            y = y_bottom + i * Y_STEP
            rect = RoundedRectangle(
                width=cell_w,
                height=cell_h,
                corner_radius=0.08,
                fill_opacity=0,
                stroke_color=GRAY,
                stroke_width=2,
            ).move_to(np.array([arr_x, y, 0]))
            idx_lbl = Text(f"[{i}]", font_size=15, color=GRAY).next_to(
                rect, LEFT, buff=0.1
            )
            placeholder = Text(zero_hashes[i], font_size=14, color=DARK_GRAY).move_to(
                rect.get_center()
            )
            arr_cells.append(VGroup(rect, idx_lbl))
            arr_texts.append(placeholder)

        self.play(
            Write(zeros_title),
            *[FadeIn(c) for c in arr_cells],
            *[Write(t) for t in arr_texts],
            run_time=1,
        )

        # ── track states ──
        current_green = [None] * (DEPTH + 1)
        active_insert = [None] * (DEPTH + 1)

        # ── helper: update node ──
        def update_node(
            level, idx, new_val, highlight_color=HIGHLIGHT, keep_color=False
        ):
            rect, txt = node_mobs[(level, idx)]
            new_txt = Text(new_val, font_size=FONT_SIZE, color=highlight_color).move_to(
                rect.get_center()
            )
            self.play(
                rect.animate.set_stroke(color=highlight_color, width=4),
                Transform(txt, new_txt),
                run_time=0.5,
            )
            if not keep_color:
                self.play(
                    rect.animate.set_stroke(color=NODE_COLOR, width=2), run_time=0.2
                )
            node_vals[(level, idx)] = new_val

        # ── animate insert ──
        def animate_insert(val, leaf_idx):
            h = str(val)

            # ── undo previous leaf insert highlight ──
            if active_insert[0] is not None:
                prev_idx = active_insert[0]
                rect, _ = node_mobs[(0, prev_idx)]
                rect.set_stroke(color=NODE_COLOR, width=2)

            # highlight new leaf
            update_node(0, leaf_idx, h, keep_color=True)
            active_insert[0] = leaf_idx

            i = leaf_idx
            for level in range(DEPTH):
                parent = i // 2

                left = (
                    node_vals.get((level, i - 1), zero_hashes[level])
                    if i % 2 == 1
                    else h
                )
                right = (
                    node_vals.get((level, i + 1), zero_hashes[level])
                    if i % 2 == 0
                    else h
                )
                node_text = left if i % 2 == 1 else left

                # highlight pair nodes temporarily
                left_idx = i if i % 2 == 0 else i - 1
                right_idx = i if i % 2 == 1 else i + 1
                pair_nodes = []
                for idx_h in [left_idx, right_idx]:
                    if idx_h < 2**DEPTH:
                        rect, _ = node_mobs[(level, idx_h)]
                        pair_nodes.append((idx_h, rect))
                self.play(
                    *[
                        rect.animate.set_stroke(color=HIGHLIGHT, width=4)
                        for _, rect in pair_nodes
                    ],
                    run_time=0.2,
                )

                # floating hash slightly above children
                new_h = hash_str(left, right)
                start_pos = (
                    node_pos(level, left_idx) + node_pos(level, right_idx)
                ) / 2 + np.array([0, 0.3, 0])
                floating_hash = Text(
                    new_h, font_size=FONT_SIZE, color=HIGHLIGHT
                ).move_to(start_pos)
                self.play(Create(floating_hash))

                # move hash to parent and morph simultaneously
                end_pos = node_pos(level + 1, parent)
                parent_rect, parent_txt = node_mobs[(level + 1, parent)]
                new_parent_txt = Text(
                    new_h, font_size=FONT_SIZE, color=NODE_COLOR
                ).move_to(parent_rect.get_center())
                self.play(
                    MoveAlongPath(
                        floating_hash, ArcBetweenPoints(start_pos, end_pos, angle=0.5)
                    ),
                    Transform(floating_hash, new_parent_txt),
                    run_time=0.6,
                )

                node_vals[(level + 1, parent)] = new_h
                update_node(level + 1, parent, new_h)

                # restore pair node highlights
                for idx_h, rect in pair_nodes:
                    if idx_h == active_insert[level]:
                        rect.set_stroke(color=HIGHLIGHT, width=4)
                    elif idx_h == current_green[level]:
                        rect.set_stroke(color=RIGHTMOST_COLOR, width=4)
                    else:
                        rect.set_stroke(color=NODE_COLOR, width=2)

                self.remove(floating_hash)

                # rightmost-left green node
                if i % 2 == 0:
                    if current_green[level] is not None and current_green[level] != i:
                        prev = current_green[level]
                        rect, _ = node_mobs[(level, prev)]
                        rect.set_stroke(color=NODE_COLOR, width=2)

                    update_node(
                        level,
                        i,
                        node_vals[(level, i)],
                        highlight_color=RIGHTMOST_COLOR,
                        keep_color=True,
                    )
                    current_green[level] = i

                    arr_text = Text(node_text, font_size=14, color=ZEROS_COLOR).move_to(
                        arr_cells[level][0].get_center()
                    )
                    self.play(Transform(arr_texts[level], arr_text), run_time=0.4)

                active_insert[level + 1] = parent
                h = new_h
                i = parent

        # ── run inserts ──
        for idx, val in enumerate([1, 2, 3, 4, 5, 6, 7, 8]):
            label = Text(f"insert({val})", font_size=28).to_edge(UP)
            self.play(Write(label), run_time=0.4)
            animate_insert(val, idx)
            self.play(FadeOut(label), run_time=0.3)
            self.wait(0.3)

        self.wait(2)
