# Changelog

All notable changes to RetroRuns are documented here. This file is read
by the CurseForge packager and used as the public release notes.

## [Unreleased]

## [0.6.0] - 2026-04-25

### Added

- **Vault of the Incarnates routing.** All 8 bosses now have full
  walk-along routes, encounter notes, achievement callouts, and
  Iskaara Trader's Ottuk barter mount tracking. Vault is now feature-
  complete alongside Sanctum, Sepulcher, and Castle Nathria.
- **Per-difficulty kill counts in the panel header.** A new pill row
  replaces the trailing "(Heroic)" suffix on the raid name with a
  bracketed strip showing all four difficulties: `[ LFR | N | H | M ]`
  with X/Y kill counts per difficulty. The player's current difficulty
  renders in white; others render in gray. Counts are server-cache
  authoritative, with the active-difficulty count updating instantly
  on ENCOUNTER_END so kills register without lag.
- **Collapsible Boss Encounter section.** The encounter notes line now
  renders as `Boss Encounter: Standard` (gray, not clickable) when the
  boss has no special notes, or `Boss Encounter: view special note`
  (clickable) when it does. Clicking expands to show the full notes.
  A single global toggle controls expand/collapse state across all
  bosses, persisted across `/reload`. Achievements render
  unconditionally below — independent of the encounter toggle.

### Changed

- "Encounter:" panel section renamed to "Boss Encounter:" for clarity.
- Iskaara Trader's Ottuk barter mount wired up for Vault of the
  Incarnates (Terros and Dathea both show it in Special Loot). When
  the mount isn't collected, the entry renders a live "0/N necks in
  bags" progress tally with nested per-ingredient rows, a trade-
  location hint ("Tattukiaka in Iskaara, Azure Span 14, 50"), and an
  explicit caveat that only current bags are scanned (bank contents
  don't count).
- Encounter notes across all 4 raids cleaned up. Pure "Standard Nuke"
  placeholders removed from boss data; bosses with no special notes
  now render as "Standard". Notes that previously embedded "Standard
  Nuke" alongside real custom info had the placeholder phrasing
  stripped, leaving the useful guidance intact.
- The redundant "Progress: X/Y" line in the panel header was removed.
  The same kill count is now visible in the difficulty pills row.

### Fixed

- **Routing now correctly handles same-mapID multi-segment paths.** Vault
  is the first raid where a single boss's route revisits a map (Terros
  and Sennarth both walk through Vault Approach twice with a Primal
  Convergence detour). The previous segment-completion rule could mark
  the wrong segment when the player crossed back through, causing the
  map to draw the wrong polyline. The new rule is route-aware: a segment
  is only marked complete when crossing into the *next* segment's map,
  which defeats backtracks naturally. Boss kills also mark all of that
  step's segments complete as a safety net.
- **Segment progress survives `/reload`.** Walk progress was previously
  in-memory only, so reloading mid-route lost track of which segments
  the player had already walked. Now persisted per-character per-raid
  and restored on raid load.
- **Cross-raid kill state contamination.** Switching raids in the same
  session (e.g. Castle Nathria → Vault) could leave the previous raid's
  kill counts visible in the new raid's pills. State now wipes cleanly
  at every raid context change.
- **Saved-instance cache hiccups no longer cause UI flicker.** The
  panel previously re-rendered briefly with wrong kill state when the
  cache transiently dropped a kill (then immediately restored it),
  visible as a one-frame stutter. Removal-only updates from the cache
  are now rejected; only legitimate kill additions pass through.
- **Sennarth's mid-fight ascent now shows correct travel guidance.** The
  panel previously showed stale text from earlier in the route while
  the player was up top during the fight.
- **Post-Sennarth Gust of Wind guidance.** The "click Gust of Wind to
  return to the bottom of the room" instruction is now shown as
  Kurog's first segment, so the guidance persists past Sennarth's
  kill instead of vanishing instantly.
- **Harmless validator warnings no longer print to chat at addon load.**
  Players previously saw "segment has no points" / "missing routing
  table" messages from intentionally-empty segments and in-progress
  raid stubs. Validator output is still available to developers via
  `/rr debug`.

### Developer

- `/rr record break` — closes the current segment and opens a fresh
  one with the same mapID. For routes with same-mapID sub-zone splits
  (rare; not currently used by any shipped raid).
- `/rr resetsegments` — clears persisted segment-completion state for
  the current raid. Useful when stale state needs a clean baseline.
- `/rr status` now displays live zone and sub-zone strings alongside
  the mapID, for debugging zone-aware features.
- `/rr status` no longer throws a Lua error when run inside a loaded
  raid with an unkilled boss. The step-index formatter was comparing
  against the wrong type.
- `/rr ej` now also prints the live `instanceID` from `GetInstanceInfo()`
  (when zoned into a raid) and the `uiMapID` from `EJ_GetInstanceInfo()`
  (when a raid is selected in the Encounter Journal). One command now
  captures all the top-level IDs needed to stub out a new raid data file,
  instead of requiring manual `/run` probes.
- `/rr tiersets` now recognizes Dragonflight Season 1's gem-encoded tier
  tokens (e.g. "Dreadful Jade Forgestone" -> Dreadful/Legs). Previously
  only Sepulcher-era body-part naming ("Dreadful Leg Module") was
  recognized, so Vault of the Incarnates token discovery silently found
  zero tokens. Added Jade/Amethyst/Garnet/Lapis/Topaz as slot keywords.
- Recorder HUD: a small live readout of zone/sub-zone/mapID that
  appears while `/rr record start` is active, with 1Hz polling to
  catch transitions that don't fire ZONE_CHANGED events.
- Removed unused `ItemStateForActiveDifficulty` helper and the dead
  `RetroRunsUI_Update` backward-compat global from UI.lua.
- Inlined the `HighlightTravelNodes` alias at its three call sites and
  dropped the alias.
- Renamed the two shadowed `EXPANSION_ORDER` locals in UI.lua to
  `EXPANSION_ORDER_ASCENDING` (browser dropdown) and
  `EXPANSION_ORDER_NEWEST_FIRST` (idle-state list) for clarity.
- Removed dead teleporter-icon branch from the map overlay. Teleporters
  are rendered natively by the World Map; the custom draw path was
  vestigial from an early iteration.
- Small internal cleanups across `/rr ejdiff`, `/rr tmogtrace`, and the
  tier-set harvester's early-exit paths.

## [0.5.2] - 2026-04-23

### Changed

- Transmog browser dropdown labels (expansion / raid / boss) now
  reflect the player's current difficulty instead of rolling up all
  four difficulties. A Mythic-mode player browsing Soulrender Dormazain
  now sees a Mythic-slice count; switching difficulty updates the
  numbers. Falls back to the cross-all rollup when no active difficulty
  is known (browsing outside a raid).
- Idle-state list header renamed from "Supported Raids" to
  "Currently supported:" for clearer framing. Rendered in grey to sit
  as a subtle label above the list rather than competing with the
  yellow expansion headings.
- Idle-state "No supported legacy raid detected." and "Travel to a
  supported raid to begin." lines now render at matching font sizes.

### Fixed

- Idle-state list header ("Currently supported:") now renders reliably
  after transitioning from an in-raid state. Previously the header
  could silently disappear due to a layout geometry issue when
  adjacent text fields were empty.

### Infrastructure

- Added CHANGELOG.md and .pkgmeta so CurseForge release notes are
  hand-written going forward instead of being auto-generated from
  git log output.
- Support email (retroruns.support@gmail.com) added to README contact
  list.

## [0.5.1] - 2026-04-23

### Changed

- Transmog summary on the main panel redesigned. Now splits by current
  difficulty vs. other difficulties, with explicit Missing and Shared
  counts per line. Numbers render green when zero, orange otherwise.
  Collapses to "All appearances collected!" when everything is done
  across all four difficulties.

### Fixed

- Main panel no longer resets to its default position on `/reload`
  inside a supported raid. Drag handlers now normalize the frame
  anchor to CENTER/CENTER before saving position, so saved offsets
  correctly round-trip through reload.

### Maintenance

- Data files cleaned up for customer-facing readability. No functional
  changes.

## [0.5.0] - 2026-04-22

### Added

- Castle Nathria (Shadowlands) raid support with weapon-token tracking
  and covenant-aware vendor hints.
- MIT License. Addon is now formally licensed and free to use, modify,
  and redistribute under the MIT terms.

### Changed

- First public release candidate on CurseForge.
