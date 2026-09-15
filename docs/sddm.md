# The login screen (SDDM)

SDDM is the one surface theme-apply.sh cannot reach: it runs as its own user
and reads `/usr/share/sddm/themes`, not `~/.config`. So the greeter is themed
by a separate, root-requiring step you run once per theme (not on every
switch):

```
sudo ~/.config/hypr/scripts/sddm-apply.sh
```

That copies `themes/current/sddm/` plus the theme's wallpaper into
`/usr/share/sddm/themes/hypr-<name>` and points SDDM at it via a drop-in in
`/etc/sddm.conf.d/` — `/etc/sddm.conf` itself is never touched. Preview it
without logging out:

```
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-cyberpunk
```

The greeter mirrors hyprlock — same wallpaper (dimmed the same amount), same
input-field geometry and colors, pink frame / cyan content / red only on
failure — so boot → login → lock reads as one design. It is plain Qt Quick,
no Qt5Compat/GraphicalEffects dependency. One caveat: Qt decodes the `.webp`
wallpaper only with `qt6-imageformats` installed (the script warns if it's
missing). A theme without an `sddm/` dir simply leaves the login screen alone.

---

[← docs index](README.md) · [repo root](../README.md)
