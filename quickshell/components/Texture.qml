import QtQuick
import "../config"

// The panel texture — each theme's structural signature, the way glow is
// cyberpunk's. One overlay, drawn on every panel fill (islands, the launcher
// window, the OSD pill, the power-menu tiles) and clipped to the panel's own
// rounded rectangle, so it sits INSIDE the frame exactly as the old
// `background-image` did.
//
// palette.json `effects.texture` picks the kind; `effects.textureAlpha`
// overrides that kind's resting strength when a theme wants it louder or
// quieter. A theme with `"none"` (cyberpunk — glow is its signature) renders
// nothing and never paints. Drop it inside any Rectangle, after the fill and
// before the content:
//
//     Rectangle { radius: 4; Texture { radius: parent.radius } ... }
//
//   scanlines  gruvbox   1px of black every 3px — the CRT raster, the old
//                        `repeating-linear-gradient`.
//   hatch      graphite  45° pencil hatching in `frame` (the ink), one line
//                        every 5px — a sketch's shading on paper.
//   grain      inkwash   a seeded speckle of `text` (the ink) — paper tooth.
//                        Seeded, so a repaint never shimmers.
//   sheen      glacier   a bright catch light along the top edge and a white
//                        wash under it, gone by mid-height — light on a pane
//                        of ice.
//   horizon    harbor    `frame` (lamplight) rising from the bottom edge,
//                        gone by mid-height — lit pavement under a dark sky.
//   vignette   verdigris black closing in from the corners, clear at the
//                        centre — a stone panel lit from the middle.
//   rim        vesper    `frame` catching the right edge of every panel and
//                        fading in, with a hairline of it on the edge — the
//                        picture's rim light, from the sun behind her.
//   halftone   manga     a grid of ink dots, one every 4px — screentone, the
//                        shading of a printed manga page.
//   chrome     mercury   light along the top half, a hard horizon at the
//                        middle, dark along the bottom — polished metal.
Canvas {
    id: root

    property real radius: 0

    readonly property string kind: Theme.texture
    // The strength each kind was tuned at; the palette may override.
    readonly property real alpha: Theme.textureAlpha >= 0 ? Theme.textureAlpha : root.restingAlpha(root.kind)
    // Repaint when the theme's inks move (SUPER+T), not only on resize.
    readonly property color ink: root.kind === "grain" ? Theme.text : Theme.frame

    anchors.fill: parent
    visible: root.kind !== "none"

    onWidthChanged: root.requestPaint()
    onHeightChanged: root.requestPaint()
    onRadiusChanged: root.requestPaint()
    onKindChanged: root.requestPaint()
    onAlphaChanged: root.requestPaint()
    onInkChanged: root.requestPaint()
    onVisibleChanged: if (root.visible) root.requestPaint()

    function restingAlpha(kind) {
        switch (kind) {
        case "scanlines": return 0.14;
        case "hatch":     return 0.07;
        case "grain":     return 0.10;
        case "sheen":     return 0.12;
        case "horizon":   return 0.18;
        case "vignette":  return 0.35;
        case "rim":       return 0.30;
        case "halftone":  return 0.10;
        case "chrome":    return 0.16;
        default:          return 0;
        }
    }

    // Canvas wants CSS color strings; `color` properties stringify as #aarrggbb,
    // which it also reads, but spelling the alpha out keeps it obvious.
    function css(c, a) {
        return "rgba(" + Math.round(c.r * 255) + "," + Math.round(c.g * 255) + ","
            + Math.round(c.b * 255) + "," + a + ")";
    }

    onPaint: {
        const ctx = root.getContext("2d");
        const w = root.width, h = root.height;
        ctx.clearRect(0, 0, w, h);
        if (!root.visible || w <= 0 || h <= 0 || root.alpha <= 0)
            return;
        ctx.save();
        ctx.beginPath();
        ctx.roundedRect(0, 0, w, h, root.radius, root.radius);
        ctx.clip();

        switch (root.kind) {
        case "scanlines": {
            ctx.fillStyle = Qt.rgba(0, 0, 0, root.alpha);
            for (let y = 0; y < h; y += 3)
                ctx.fillRect(0, y, w, 1);
            break;
        }
        case "hatch": {
            ctx.strokeStyle = root.css(root.ink, root.alpha);
            ctx.lineWidth = 1;
            ctx.beginPath();
            // Lines run top-right to bottom-left, like right-handed shading.
            for (let x = -h; x < w + h; x += 5) {
                ctx.moveTo(x + h, 0);
                ctx.lineTo(x, h);
            }
            ctx.stroke();
            break;
        }
        case "grain": {
            // A fixed-seed LCG: the same panel always gets the same speckle, so
            // a repaint (hover, resize, theme reload) never looks like noise
            // crawling. ~5% of the pixels carry a fleck.
            let seed = 0x9e3779b1;
            const next = () => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return seed / 4294967296; };
            ctx.fillStyle = root.css(root.ink, root.alpha);
            const n = Math.floor(w * h * 0.05);
            for (let i = 0; i < n; i++)
                ctx.fillRect(Math.floor(next() * w), Math.floor(next() * h), 1, 1);
            break;
        }
        case "sheen": {
            const g = ctx.createLinearGradient(0, 0, 0, h * 0.55);
            g.addColorStop(0, "rgba(255,255,255," + root.alpha + ")");
            g.addColorStop(1, "rgba(255,255,255,0)");
            ctx.fillStyle = g;
            ctx.fillRect(0, 0, w, h);
            // The catch light: one bright line along the top edge, where a
            // pane of glass actually shows its light. The wash alone is too
            // soft to read over a blurred wallpaper at 1.5x.
            ctx.fillStyle = "rgba(255,255,255," + Math.min(1, root.alpha * 3) + ")";
            ctx.fillRect(0, 0, w, 1);
            break;
        }
        case "horizon": {
            const g = ctx.createLinearGradient(0, h, 0, h * 0.5);
            g.addColorStop(0, root.css(root.ink, root.alpha));
            g.addColorStop(1, root.css(root.ink, 0));
            ctx.fillStyle = g;
            ctx.fillRect(0, 0, w, h);
            break;
        }
        case "rim": {
            // Lit from the right: a band of `frame` fading in over the last
            // 18% of the width, and one bright pixel on the edge itself.
            const g = ctx.createLinearGradient(w * 0.82, 0, w, 0);
            g.addColorStop(0, root.css(root.ink, 0));
            g.addColorStop(1, root.css(root.ink, root.alpha));
            ctx.fillStyle = g;
            ctx.fillRect(0, 0, w, h);
            ctx.fillStyle = root.css(root.ink, Math.min(1, root.alpha * 2.5));
            ctx.fillRect(w - 1, 0, 1, h);
            break;
        }
        case "halftone": {
            // Screentone: a dot every 4px on a square grid, offset every
            // other row so it reads as tone, not as a lattice.
            ctx.fillStyle = root.css(root.ink, root.alpha);
            let row = 0;
            for (let y = 2; y < h; y += 4, row++) {
                for (let x = (row % 2) * 2 + 1; x < w; x += 4) {
                    ctx.beginPath();
                    ctx.arc(x, y, 0.9, 0, 2 * Math.PI);
                    ctx.fill();
                }
            }
            break;
        }
        case "chrome": {
            // The classic chrome split: a white sheen from the top fading to
            // nothing just above the middle, a hard horizon, then shadow
            // deepening to the bottom. Alpha is the sheen; the shadow is
            // 1.5x it, so the bar reads as lit from above.
            const top = ctx.createLinearGradient(0, 0, 0, h * 0.48);
            top.addColorStop(0, "rgba(255,255,255," + root.alpha + ")");
            top.addColorStop(1, "rgba(255,255,255," + (root.alpha * 0.25) + ")");
            ctx.fillStyle = top;
            ctx.fillRect(0, 0, w, h * 0.48);
            const bottom = ctx.createLinearGradient(0, h * 0.48, 0, h);
            bottom.addColorStop(0, "rgba(0,0,0," + (root.alpha * 0.6) + ")");
            bottom.addColorStop(1, "rgba(0,0,0," + Math.min(1, root.alpha * 1.5) + ")");
            ctx.fillStyle = bottom;
            ctx.fillRect(0, h * 0.48, w, h - h * 0.48);
            break;
        }
        case "vignette": {
            // Radial, from clear at 45% of the way out to the corners' black:
            // an ellipse on wide panels, so an island darkens at its ends and
            // a tall window at its corners alike.
            const r = Math.sqrt(w * w + h * h) / 2;
            const g = ctx.createRadialGradient(w / 2, h / 2, r * 0.45, w / 2, h / 2, r);
            g.addColorStop(0, "rgba(0,0,0,0)");
            g.addColorStop(1, "rgba(0,0,0," + root.alpha + ")");
            ctx.fillStyle = g;
            ctx.fillRect(0, 0, w, h);
            break;
        }
        }
        ctx.restore();
    }
}
