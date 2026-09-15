# Notifications, control center, OSD

Notifications are `swaync`: themed floating toasts plus a pull-down control
center (`SUPER+SHIFT+N`) with history, a do-not-disturb switch, and a media
player card. Behavior lives in `swaync/config.json` (shared); looks live in
each theme's `swaync/style.css`.

Volume and brightness keys route through `swayosd`, so every press answers
with a themed on-screen pill (neon in cyberpunk, indicator-lamp in gruvbox);
without swayosd installed the binds fall back to bare wpctl/brightnessctl —
same action, just silent. Both are in `extra`: `swaync swayosd`, provisioned
by linux-setup.

---

[← docs index](README.md) · [repo root](../README.md)
