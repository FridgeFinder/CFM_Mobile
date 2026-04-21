#!/usr/bin/env python3
"""Simplify Protomaps v4 theme JSON for vector_tile_renderer v6 compatibility.

Targeted fixes:
  2a: Replace complex text-field expressions with simple fallback
  2b: Fix pois filter — v4 `in` to v3 `in` syntax
  2c: Fix pois paint — same v4→v3 `in` conversion
  2d: Normalize text-font expressions to simple arrays
  2e: Simplify places_region text-field (step expression)
  Remove icon-image references (no sprites available)
"""

import json
import sys
from pathlib import Path

SIMPLE_TEXT_FIELD = ["coalesce", ["get", "name:en"], ["get", "name"]]

ITALIC_LAYERS = {"water_waterway_label", "water_label_ocean", "water_label_lakes"}

ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets" / "map_themes"


def is_complex_text_field(val):
    """Return True if the text-field value is a complex expression (not simple)."""
    if not isinstance(val, list):
        return False
    # Simple: ["get", "name"] or ["coalesce", ["get", ...], ...]
    # Complex: starts with "case", "step", "concat", or deeply nested
    op = val[0] if val else None
    if op in ("case", "step", "concat", "format"):
        return True
    # A coalesce of just ["get", ...] items is fine
    if op == "coalesce":
        return any(
            isinstance(v, list) and v[0] not in ("get",) for v in val[1:]
        )
    return False


def fix_pois_filter(layer):
    """Fix pois filter: convert v4 `in` and strip unsupported `[zoom]` conditions."""
    filt = layer.get("filter")
    if filt is None:
        return
    filt = _fix_in_expr_recursive(filt)
    # Strip unsupported [zoom] sub-expressions from ["all", ...] compounds
    filt = _strip_zoom_conditions(filt)
    layer["filter"] = filt


def _strip_zoom_conditions(expr):
    """Remove sub-expressions that reference [zoom] (unsupported by renderer)."""
    if not isinstance(expr, list) or len(expr) == 0:
        return expr
    op = expr[0]
    if op in ("all", "any"):
        kept = [sub for sub in expr[1:] if not _uses_zoom(sub)]
        if len(kept) == 0:
            return True  # no conditions left → always match
        if len(kept) == 1:
            return kept[0]  # unwrap single-item compound
        return [op] + kept
    return expr


def _uses_zoom(expr):
    """Return True if the expression references [zoom] anywhere."""
    if not isinstance(expr, list):
        return False
    if expr == ["zoom"]:
        return True
    return any(_uses_zoom(item) for item in expr)


def _fix_in_expr_recursive(expr):
    """Walk an expression tree and convert v4 in-expressions to v3."""
    if not isinstance(expr, list) or len(expr) == 0:
        return expr

    op = expr[0]

    # v4: ["in", ["get", "kind"], ["beach", ...]]
    if (
        op == "in"
        and len(expr) == 3
        and isinstance(expr[1], list)
        and expr[1][0] == "get"
        and isinstance(expr[2], list)
        and len(expr[2]) > 0
        and isinstance(expr[2][0], str)
        and expr[2][0] not in (
            "get", "literal", "in", "all", "any", "case",
            "coalesce", "concat", "step", "interpolate",
        )
    ):
        # Convert: ["in", ["get", "kind"], ["a","b"]] -> ["in", "kind", "a", "b"]
        prop = expr[1][1]
        values = expr[2]
        return ["in", prop] + values

    # Recurse for compound filters
    if op in ("all", "any"):
        return [op] + [_fix_in_expr_recursive(sub) for sub in expr[1:]]

    return expr


def fix_pois_paint(layer):
    """Fix v4 in-expressions in paint properties."""
    paint = layer.get("paint", {})
    for key, val in paint.items():
        paint[key] = _fix_in_paint_recursive(val)


def _fix_in_paint_recursive(expr):
    """Walk paint expression and fix v4 in-expressions."""
    if not isinstance(expr, list) or len(expr) == 0:
        return expr

    op = expr[0]

    # v4: ["in", ["get","kind"], ["beach",...]] inside case
    if (
        op == "in"
        and len(expr) == 3
        and isinstance(expr[1], list)
        and expr[1][0] == "get"
        and isinstance(expr[2], list)
        and len(expr[2]) > 0
        and isinstance(expr[2][0], str)
        and expr[2][0] not in (
            "get", "literal", "in", "all", "any", "case",
        )
    ):
        prop = expr[1][1]
        values = expr[2]
        return ["in", prop] + values

    # Recurse into sub-expressions
    return [_fix_in_paint_recursive(item) if isinstance(item, list) else item for item in expr]


def simplify_layer(layer):
    """Apply all simplifications to a single layer."""
    layer_id = layer.get("id", "")
    layer_type = layer.get("type", "")
    layout = layer.get("layout", {})

    if layer_type != "symbol":
        return

    # --- 2a + 2e: Simplify text-field ---
    if "text-field" in layout:
        val = layout["text-field"]
        if is_complex_text_field(val):
            layout["text-field"] = SIMPLE_TEXT_FIELD

    # --- 2d: Normalize text-font to simple array ---
    if "text-font" in layout:
        font_val = layout["text-font"]
        if isinstance(font_val, list) and len(font_val) > 0:
            # If it's an expression (first element is an operator string like "case")
            if isinstance(font_val[0], str) and font_val[0] in (
                "case", "step", "match", "coalesce", "literal",
            ):
                if layer_id in ITALIC_LAYERS:
                    layout["text-font"] = ["Noto Sans Italic"]
                else:
                    layout["text-font"] = ["Noto Sans Regular"]

    # --- Remove icon-image (no sprites available) ---
    if "icon-image" in layout:
        del layout["icon-image"]
    if "icon-size" in layout:
        del layout["icon-size"]
    if "icon-padding" in layout:
        del layout["icon-padding"]

    # --- Fix pois layer specifically ---
    if layer_id == "pois":
        fix_pois_filter(layer)
        fix_pois_paint(layer)


def simplify_theme(input_path, output_path):
    """Read, simplify, and write a theme JSON file."""
    with open(input_path, "r") as f:
        theme = json.load(f)

    layers = theme.get("layers", [])
    for layer in layers:
        simplify_layer(layer)

    with open(output_path, "w") as f:
        json.dump(theme, f, ensure_ascii=False)

    # Report
    symbol_layers = [l for l in layers if l.get("type") == "symbol"]
    print(f"  {len(layers)} total layers, {len(symbol_layers)} symbol layers simplified")


def main():
    for flavor in ("light", "dark"):
        path = ASSETS_DIR / f"protomaps_{flavor}.json"
        if not path.exists():
            print(f"SKIP: {path} not found")
            continue
        print(f"Simplifying {flavor} theme: {path}")
        simplify_theme(path, path)
    print("Done.")


if __name__ == "__main__":
    main()
