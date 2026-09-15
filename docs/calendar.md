# The calendar

Standard-format calendaring with this desktop's alert layer on top. Storage
is [khal](https://khal.readthedocs.io): every event an iCalendar `.ics` file
in `~/.local/share/khal/calendars/` — portable to any calendar app, and
two-way syncable to Google Calendar or any CalDAV via `vdirsyncer`
(installed but deliberately unconfigured until you want your phone in the
loop; khal's config ships from linux-setup's `config/khal/`).

```
khal new tomorrow 14:00 "Advisor meeting"      # quick add
khal new mon 10:00 "C191A lecture [15m]"       # [Nm] = per-event alert lead
SUPER+A                                        # ikhal: the month grid, floating
```

`calendar-notify.sh` (autostarted) reads khal through `calendar-lib.sh` and
fires two themed notifications per event — "in N minutes" at the lead (10 by
default, `[Nm]` in the title overrides) and "now" at start — deduped across
restarts. The right island grows a next-event chip only when something is
within 8 hours; click it for the calendar. Recurrence, end
dates ("until finals"), durations, and multi-day events are all khal-native
— real RRULEs, not a homegrown format.

Todos live in the same vdir, as standard VTODOs, through
[todoman](https://todoman.readthedocs.io) (config ships from linux-setup's
`config/todoman/`):

```
todo new "grade problem sets" --due "fri 17:00"
todo done 3
SUPER+SHIFT+A                                  # the list, floating
```

A second bar chip counts tasks due within 24 hours — hidden at zero, red
the moment anything is overdue. Because events and todos share one storage
layer, a single future `vdirsyncer` pairing syncs both.

The line between them: **events happen, todos get done.** A lecture or
meeting has an hour you show up for — khal. Homework, grading, an email you
owe — todoman, with a `--due`. If it can be checked off, it is not an event.
The bar reflects the split: the calendar chip names the next event and when
it starts; the todo chip just counts what you owe.

---

[← docs index](README.md) · [repo root](../README.md)
