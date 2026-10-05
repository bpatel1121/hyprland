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
        }
        ctx.restore();
    }
}
