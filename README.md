# RetroRuns

A solo legacy raid navigator for World of Warcraft retail.

Zone into an old raid and RetroRuns lays out a styled panel with the next boss, turn-by-turn routing to reach it, solo-focused encounter notes, and transmog collection status for every drop. Kill a boss and the guide advances automatically.

Currently supports:

**Dragonflight**
* Amirdrassil, the Dream's Hope (10.2)
* Aberrus, the Shadowed Crucible (10.1)
* Vault of the Incarnates (10.0)

**Shadowlands**
* Sepulcher of the First Ones (9.2)
* Sanctum of Domination (9.1)
* Castle Nathria (9.0)

**Battle for Azeroth**
* Ny'alotha, the Waking City (8.3)
* The Eternal Palace (8.2)
* Crucible of Storms (8.1.5)
* Battle of Dazar'alor (8.1)
* Uldir (8.0)

**Legion**
* Antorus, the Burning Throne (7.3)
* Tomb of Sargeras (7.2)
* The Nighthold (7.1.5)
* Trial of Valor (7.1)
* The Emerald Nightmare (7.0.3)

**Warlords of Draenor**
* Hellfire Citadel (6.2)
* Blackrock Foundry (6.1)
* Highmaul (6.0)

**Mists of Pandaria**
* Siege of Orgrimmar (5.4)
* Throne of Thunder (5.2)
* Terrace of Endless Spring (5.0)
* Heart of Fear (5.0)
* Mogu'shan Vaults (5.0)

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

## Features

* **Optimal solo-clear routes** drawn directly on the World Map, segment by segment. Handles multi-floor transitions and teleporter hops. Auto-advances as you arrive at each checkpoint.
* **Boss progress at a glance.** 3-state indicator (killed / current target / pending) keeps you focused on one objective at a time.
* **Hand-written solo tips** focused on what matters for solo play: what mechanics to worry about, what to skip, Mythic-only gotchas. Not generic Encounter Journal text.
* **Transmog collection tracker.** Per-item, per-difficulty state with cross-source awareness (detects appearances you own via sibling items).
* **Weapon-token vendor hints.** For raids with token-based weapons (Castle Nathria's Anima Spherules), points you to your Covenant Sanctum vendor in your covenant's theme color.
* **Special-loot detection.** Mount, pet, toy, and housing decor drops are surfaced per boss with collection state and clickable links.
* **Achievement callouts.** Per-boss list with completed state and clickable in-game links.
* **Automatic kill detection.** Listens for `ENCOUNTER_END` and syncs with Blizzard's lockout API, so progression state is correct across reloads, disconnects, and character swaps within the same lockout.
* **Configurable.** Font size, window scale, panel position, all persisted per character.
* **Body font choice.** Three options for panel body text: WoW's native Friz Quadrata for max readability, 04B_03 for full pixel-retro feel, or VT323 for a clean terminal style in between. Chrome (title, buttons, footer) stays consistent across all three.
* **Launch mode.** Choose what RetroRuns does on login: open fully expanded, open in compact minimized mode, or stay hidden until you click the minimap icon. Zoning into a supported raid and clicking "Load" always opens the panel fully regardless.
* **Collapsible supported-raids list.** When the panel is idle, the list of supported raids groups by expansion with click-to-expand toggles, so the panel stays compact and you only open the expansion you're working through.
* **Skip detail popups.** The Skips window includes an info button on every raid row that opens the unlock requirements for that raid's skip: what quest, what prerequisite kills, and where the resulting teleporter or shortcut takes you.
* **One-click navigation to raid entrances.** Each supported raid has a flight-master icon next to its name; click it to be routed to the raid's entrance. RetroRuns hands off to whatever navigation addons you have installed; see [Navigation handoff](#navigation-handoff) below for details. Works out of the box with no addons installed (Blizzard's native waypoint), and progressively enhances with TomTom, Zygor, Mapzeroth, AzerothWaypoint, and Waypoint UI as you add them.

## Navigation handoff

The flight-master icon next to each supported raid hands off to whatever navigation addons you have installed. RetroRuns recognizes three different navigation roles and fires the appropriate provider for each:

**Routing**: multi-leg route planning across portals, flight paths, and zones. Supported planners (one fires per click, in this order):
* **AzerothWaypoint with Zygor or Mapzeroth as backend**: AzerothWaypoint orchestrates the backend's route through its own queue UI.
* **Zygor alone**: uses Zygor's LibRover pathfinding and its own arrow.
* **Mapzeroth alone**: uses Mapzeroth's GPS frame with full multi-leg directions.

When a planner is active, it provides its own arrow and destination indicator. No additional waypoint is set.

**Waypoint**: the destination arrow that points you toward the raid entrance. Fires only when no planner is handling the route. Supported sources (one wins per click):
* **TomTom**: drops a crazy arrow waypoint.
* **Blizzard native**: falls back to the in-game super-tracker if TomTom isn't installed.

**3D Overlay**: in-world visual marker at the destination. Fires alongside the planner or waypoint, independently. Either or both can be active at once:
* **AzerothWaypoint**: its 3D queue overlay. When AWP is also handling routing (above), the overlay is part of that dispatch; otherwise it fires standalone.
* **Waypoint UI**: its in-world destination marker and close-range navigator.

The legend at the bottom of the main panel shows which providers are active for your install. None of these addons are required. Blizzard's native super-tracker is the universal fallback when nothing else is installed.

## Commands

Main commands, type in chat:

| Command | What it does |
|---|---|
| `/rr` | Toggle the main panel |
| `/rr status` | Print current raid, step, and kill state to chat |
| `/rr tmog` | Open the transmog browser |
| `/rr skips` | Print account-wide raid skip status |
| `/rr settings` | Open the settings window |
| `/rr help` | Show the command list |

## Status

Version **1.13.0**

## Reporting bugs / requesting features

A few ways to reach me, in rough order of preference:

* **GitHub issues**: [github.com/PhotekWoW/RetroRuns/issues](https://github.com/PhotekWoW/RetroRuns/issues). Best for bug reports and feature requests; keeps everything searchable.
* **CurseForge comments**: the comments section on the addon's CurseForge page.
* **Email**: [retroruns.support@gmail.com](mailto:retroruns.support@gmail.com). Good for private reports, or anything that doesn't fit a public forum.
* **Discord**: if we're in the same server, feel free to ping me directly.

The Settings panel has a beetle icon (GitHub Issues) and a chat-bubble icon (CurseForge comments) next to the Defaults button as in-game shortcuts to the first two URLs above. Ctrl+C copies the link, paste into your browser.

When reporting a bug, the following info helps:

* Addon version (`/rr status` prints it, or check `RetroRuns.toc`)
* Your class, covenant (if applicable), and the raid + difficulty you were in
* What you expected vs what actually happened
* Screenshot if visual

## Credits

Author: Photek.

Built with reference to these addons; none are runtime dependencies, but they were invaluable during development:

* **CanIMogIt**: for the transmog-collection API patterns.
* **TokenTransmogTooltips**: for the weapon-token seed data and tooltip-rendering patterns.
* **AllTheThings**: cross-referenced for loot-table ground truth.

## License

MIT. See [LICENSE](LICENSE).
