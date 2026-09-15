# Plugins (built by hand, on purpose)

Two pieces build out-of-tree via `hyprpm`, which needs a superuser prompt, so
they are deliberate manual steps:

```
hyprpm update
hyprpm add https://github.com/VirtCode/hypr-dynamic-cursors
hyprpm enable dynamic-cursors                             # cursor tilt/stretch
hyprpm reload
```

`hyprpm` needs `cmake` and `cpio` (in linux-setup's pacman.txt) on top of
base-devel. Plugins compile against one exact Hyprland version and break on
every Hyprland upgrade until `hyprpm update` is re-run — the binds and
defaults here stay inert rather than erroring when a plugin is absent.

---

[← docs index](README.md) · [repo root](../README.md)
