# RetroRuns

A solo legacy raid navigator for World of Warcraft retail.

Zone into an old raid and RetroRuns lays out a styled panel with the next boss, turn-by-turn routing to reach it, solo-focused encounter notes, and transmog collection status for every drop. Kill a boss and the guide advances automatically.

Currently supports all three Shadowlands raids and the first Dragonflight raid:

* Castle Nathria (9.0)
* Sanctum of Domination (9.1)
* Sepulcher of the First Ones (9.2)
* Vault of the Incarnates (10.0)

## Installation

1. Download the latest `RetroRuns.zip`.
2. Extract it into `World of Warcraft/_retail_/Interface/AddOns/`. You should end up with a folder at `Interface/AddOns/RetroRuns/` containing `RetroRuns.toc` and a handful of `.lua` files.
3. Launch WoW (or `/reload` if already logged in). You'll see a chat banner announcing the RetroRuns version on login.

## Getting started

Zone into any supported raid. You'll get a prompt asking whether to load navigation. Click "Load" and the main panel appears with:

* The next boss to kill (yellow)
* Turn-by-turn travel directions to reach them
* Per-boss solo-play tips
* Achievement callouts with green/red state
* Per-item transmog collection state

The minimap button (a small icon on the edge of your minimap) toggles the panel. Right-click it for settings. Drag it to reposition around the minimap edge.

Click any boss name in the panel to open the transmog collection browser for that boss — shows every loot item with per-difficulty collection state (green = collected, gold = have the appearance via another item, gray = not collected).

## Features

* **Optimal solo-clear routes** drawn directly on the World Map, segment by segment. Handles multi-floor transitions and teleporter hops. Auto-advances as you arrive at each checkpoint.
* **Boss progress at a glance.** 3-state indicator (killed / current target / pending) keeps you focused on one objective at a time.
* **Hand-written solo tips** focused on what matters for solo play — what mechanics to worry about, what to skip, Mythic-only gotchas. Not generic Encounter Journal text.
* **Transmog collection tracker.** Per-item, per-difficulty state with cross-source awareness (detects appearances you own via sibling items).
* **Weapon-token vendor hints.** For raids with token-based weapons (Castle Nathria's Anima Spherules), points you to your Covenant Sanctum vendor in your covenant's theme color.
* **Special-loot detection.** Mount, pet, and toy drops are surfaced per boss with collection state and clickable links. Housing decor support is in place under the hood and will be populated for raids that drop decor as Blizzard expands the Midnight housing catalog.
* **Achievement callouts.** Per-boss list with completed state and clickable in-game links.
* **Automatic kill detection.** Listens for `ENCOUNTER_END` and syncs with Blizzard's lockout API, so progression state is correct across reloads, disconnects, and character swaps within the same lockout.
* **Configurable.** Font size, window scale, panel position — all persisted per character.

## Commands

Main commands — type in chat:

| Command | What it does |
|---|---|
| `/rr` | Toggle the main panel |
| `/rr help` | Show the command list |
| `/rr tmog` | Open the standalone transmog browser |
| `/rr status` | Print current raid, step, and kill state to chat |
| `/rr test` | Enter test mode (cycle bosses without actually killing them) |
| `/rr next` | In test mode, advance to the next boss |
| `/rr real` | Exit test mode |

## Status

Version **0.6.1** — release candidate for v1.0.

All three Shadowlands raids and Vault of the Incarnates (Dragonflight Season 1) are feature-complete with full routing, encounter notes, armor transmog tracking, weapon-token indicators, and achievement callouts. Data integrity has been verified via the addon's own `/rr tmogverify` command: zero errors across 413 items and 39 bosses.

## Reporting bugs / requesting features

A few ways to reach me, in rough order of preference:

* **GitHub issues** — [github.com/PhotekWoW/RetroRuns/issues](https://github.com/PhotekWoW/RetroRuns/issues). Best for bug reports and feature requests; keeps everything searchable.
* **CurseForge comments** — the comments section on the addon's CurseForge page.
* **Email** — [retroruns.support@gmail.com](mailto:retroruns.support@gmail.com). Good for private reports, or anything that doesn't fit a public forum.
* **Discord** — if we're in the same server, feel free to ping me directly.

When reporting a bug, the following info helps:

* Addon version (`/rr status` prints it, or check `RetroRuns.toc`)
* Your class, covenant (if applicable), and the raid + difficulty you were in
* What you expected vs what actually happened
* Screenshot if visual

## Suggesting a raid

Additional raid support is planned. Suggestions are welcome via the CurseForge comments or a GitHub issue, with preference given to raids that have complex layouts or optional kill orders — those are where the addon earns its keep.

## Credits

Author: Photek.

Built with reference to these addons — none are runtime dependencies, but they were invaluable during development:

* **CanIMogIt** — for the transmog-collection API patterns.
* **TokenTransmogTooltips** — for the weapon-token seed data and tooltip-rendering patterns.
* **AllTheThings** — cross-referenced for loot-table ground truth.

## License

MIT. See [LICENSE](LICENSE).
