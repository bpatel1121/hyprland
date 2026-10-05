import QtQuick
import Quickshell
import "../config"
import "../components"

// The clock, and the only thing in the center island — `#clock`:
//
//     color: <readout>; background: none; font-weight: bold;
//     text-shadow: 0 0 12px rgba(<readout>, 0.8);     the brightest glow on the bar
//     padding: 0 16px; margin: 3px 2px;
//
// Text only: "HH:mm", or the date when clicked. The old bar led with a Nerd
// Font glyph; that was dropped on request, so the chip is just the readout.
// No fill: a lit tube, not a chip. Font stays at the bar's 13px; the CSS gives
// the clock weight and glow, not size.
//
// SystemClock ticks this — no Timer, and it wakes only at the precision asked
// for, so a minute-resolution clock is not spinning once a second.
//
// Click swaps to the date, matching waybar's format-alt. The tooltip is the
// month calendar waybar rendered from `<tt>{calendar}</tt>`.
Chip {
    id: root

    property bool showingAlt: false

    readonly property string fmt: root.showingAlt
        ? Config.get("clock", "altFormat", "ddd dd MMM")
        : Config.get("clock", "format", "HH:mm")

    label: Qt.formatDateTime(clock.date, root.fmt)

    accent: Theme.readout
    bold: true
    tintOpacity: 0
    glowOpacity: 0.8
    glowRadius: 12
    leftPadding: 16
    rightPadding: 16

    tooltip: root.calendar(clock.date)
    tooltipFormat: Text.StyledText

    onActivated: root.showingAlt = !root.showingAlt

    SystemClock {
        id: clock
        // Minutes is all either format shows; seconds would wake the shell 60x
        // more often for pixels that never change.
        precision: SystemClock.Minutes
    }

    // The month grid, in the shape waybar's {calendar} drew it: a centred
    // "Month Year" title, two-letter day names, weeks as rows of right-aligned
    // day numbers, today in bold readout color. Monospace alignment comes from
    // the bar font itself; <pre> keeps the spacing.
    function calendar(now) {
        const loc = Qt.locale();
        const y = now.getFullYear();
        const m = now.getMonth();
        const first = new Date(y, m, 1);
        const days = new Date(y, m + 1, 0).getDate();
        // Qt days run Monday=1..Sunday=7; JS getDay() runs Sunday=0..Saturday=6.
        const startDow = loc.firstDayOfWeek;
        const firstDow = first.getDay() === 0 ? 7 : first.getDay();
        const lead = (firstDow - startDow + 7) % 7;

        const width = 7 * 3 - 1;
        const title = Qt.formatDate(first, "MMMM yyyy");
        const padLeft = Math.max(0, Math.floor((width - title.length) / 2));
        let out = " ".repeat(padLeft) + title + "\n";

        const names = [];
        for (let i = 0; i < 7; i++) {
            const dow = ((startDow - 1 + i) % 7) + 1;
            names.push(loc.dayName(dow, Locale.ShortFormat).substring(0, 2));
        }
        out += names.join(" ") + "\n";

        let col = lead;
        let line = "   ".repeat(lead);
        const todayColor = "" + Theme.readout;
        for (let d = 1; d <= days; d++) {
            const cell = (d < 10 ? " " : "") + d;
            line += d === now.getDate()
                ? "<b><font color=\"" + todayColor + "\">" + cell + "</font></b>"
                : cell;
            col++;
            if (col === 7 || d === days) {
                out += line + (d === days ? "" : "\n");
                line = "";
                col = 0;
            } else {
                line += " ";
            }
        }
        return "<pre>" + out + "</pre>";
    }
}
