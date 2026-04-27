# Changelog

All notable changes to RetroRuns are documented here.

## [0.7.0] - 2026-04-27

### Added

- **Aberrus, the Shadowed Crucible** is now fully supported — walk-along routes for all 9 bosses, encounter notes, achievement callouts, and Drakewatcher Manuscript tracking for Sarkareth's Highland Drake: Embodiment of the Hellforged.
- **`/rr raidcapture` command** — single-command raid bring-up for new content. Discovers tier set labels and tokens, then harvests all loot tables in one pass. Replaces the older three-step workflow of running `/rr harvest`, `/rr tiersets`, and `/rr harvest` again. Existing commands are preserved as a fallback.
- **Drakewatcher Manuscript auto-detection.** The harvester now recognizes Drakewatcher Manuscripts via their use-spell signature, classifies them as `kind="manuscript"`, and resolves the unlock questID automatically for known manuscripts.
- **Sarkareth Void-Touched Curio note in the transmog browser.** A small footnote on Sarkareth's transmog view calls out that the omnitoken exists but isn't tracked by the addon (it exchanges for any tier slot of the player's choice, which doesn't fit the per-slot tracking model).

### Changed

- **"Show all class tier" checkbox now disables on bosses that don't drop tier tokens.** Previously the checkbox was always clickable; now it greys out on non-tier bosses so the control's reachability matches its effect.
- **Boss Progress / Where to next pill consistency.** When you kill a boss, both the panel header pill and the per-raid pill in the "Where to next" panel now update at the same instant. Previously the per-raid pill could lag behind by a few seconds until the game's saved-instance data refreshed.
- **CurseForge Changelog tab now renders as formatted Markdown** instead of raw text. (Tooling fix in the build pipeline.)

### Fixed

- **`/rr ej` no longer fails on the live build.** The Encounter Journal diagnostic now correctly captures journal IDs even when `EJ_GetSelectedInstance()` returns nothing, by falling back to the per-encounter API.
- **`/rr record stop` automatically opens the export window.** Previously you had to also type `/rr record dump` to see the recording. Now the window pops up as soon as you stop, unless the recording was empty.
- **Sepulcher of the First Ones encounter notes cleaned up.** Five bosses (Skolex, Lords of Dread, Halondrus, Lihuvim, Xy'mox) now read `Boss Encounter: Standard` instead of carrying outdated solo-tip text.
- **Run-complete panel layout tightened.** Dropped the redundant "This lockout is complete." line, replaced the per-boss kill checklist with the more useful "Where to next:" raid pill list, and greyed out the now-unusable Map button.

## [0.6.1] - 2026-04-26

### Added

- **Drakewatcher Manuscript tracking.** Raszageth's Renewed Proto-Drake: Embodiment of the Storm-Eater now appears in Vault of the Incarnates' Special Loot section with a per-character collected/missing indicator. Pattern will extend to future Drakewatcher Manuscripts as new raids ship.
- **Per-raid lockout pills in the supported-raids list.** When the panel is idle (not in a raid), each supported raid now shows a `[ LFR | N | H | M ]` pill row colored by lockout state — green for fully cleared, amber for partial, gray for fresh. Tells you at a glance which raids have farmable lockouts available right now.

### Changed

- **Achievement completion is now visually obvious.** Completed achievements show a green check mark in brackets with grayed-out text; uncompleted achievements keep yellow text with a bracketed X. Matches the Special Loot section's visual language.
- **Iskaara Trader's Ottuk display polished.** The "Trade at Tattukiaka" location hint only appears when both necks are in your bags (when it's actually actionable). Removed the redundant "only current bags are checked" caveat since the per-neck "in bags / not in bags" text already conveys what's being validated.
- **New minimap icon.** Replaces the cropped square logo with a properly circular icon that fits the minimap button cleanly alongside other addons.
- **Idle-state panel polish.** Removed redundant lines (the "RetroRuns v0.6.0" body header and the "No supported legacy raid detected." prompt). Tightened the spacing so the supported-raids list sits directly under "Travel to a supported raid to begin."

### Fixed

- **Walk progress no longer leaks across game sessions.** Previously, route segments marked as walked in one session could persist into a fresh login and cause lines to draw incorrectly. Walk progress now stays within a single WoW session: `/reload` mid-walk preserves where you are, but quitting WoW and coming back starts you cleanly at segment 1 of your current boss.
- **Exiting test mode now restores real raid state.** `/rr real` now properly resyncs kill counts and walk progress from your actual raid lockout, instead of leaving fake test-mode state on the panel until a `/reload`.

## [0.6.0] - 2026-04-25

### Added

- **Vault of the Incarnates** is now fully supported — walk-along routes for all 8 bosses, encounter notes, achievement callouts, and Iskaara Trader's Ottuk mount tracking.
- **Per-difficulty kill counts in the panel header.** New pill row `[ LFR | N | H | M ]` shows X/Y kill counts per difficulty. Your active difficulty renders in white, others in gray. Updates instantly on boss kill.
- **Collapsible Boss Encounter section.** Encounter notes line now reads `Boss Encounter: Standard` for routine fights or `Boss Encounter: view special note` (clickable) for fights with custom guidance. One global toggle expands/collapses across all bosses, persisted across `/reload`.

### Changed

- Iskaara Trader's Ottuk barter mount now tracked in Vault of the Incarnates (Terros and Dathea). Shows live "0/N necks in bags" progress with per-ingredient rows and a trade-location hint. Bank contents aren't scanned — only what's currently in your bags counts.
- Encounter notes across all 4 raids cleaned up. Bosses with no special notes now read simply as "Standard" instead of "Standard Nuke". Bosses with custom guidance keep it intact.
- "Encounter:" panel section renamed to "Boss Encounter:" for clarity.
- Removed redundant "Progress: X/Y" line from the panel header — same count is now in the difficulty pills row.

### Fixed

- **Routes now handle bosses whose path revisits the same area.** Vault is the first raid where this happens (Terros and Sennarth both pass through Vault Approach twice). The map could previously draw the wrong line when you crossed back through; routes now follow your actual progress correctly.
- **Segment progress now survives `/reload`.** Walk progress is saved per-character per-raid and restored on raid load.
- **Switching raids no longer carries over kill counts from the previous raid.** Going from Castle Nathria to Vault in the same session now wipes the pills cleanly.
- **No more brief panel flicker after a kill.** The panel no longer momentarily re-renders with wrong kill counts when the game refreshes its raid lockout data.
- **Sennarth mid-fight travel guidance fixed.** Panel no longer shows stale travel text while you're up top during the fight.
- **Post-Sennarth Gust of Wind guidance now persists.** The "click Gust of Wind to return to the bottom" instruction shows as Kurog's first step, so it's still visible after Sennarth dies.

## [0.5.2] - 2026-04-23

### Added

- Support email added to README: retroruns.support@gmail.com.

### Changed

- Transmog browser dropdown labels (expansion / raid / boss) now reflect your current difficulty instead of rolling up all four. Switching difficulty updates the numbers live. Falls back to the cross-all rollup when browsing outside a raid.
- Idle-state list header renamed from "Supported Raids" to "Currently supported:" for clearer framing.
- Idle-state "No supported legacy raid detected." and "Travel to a supported raid to begin." lines now render at matching font sizes.

### Fixed

- Idle-state list header now reliably reappears after you leave a raid. Previously could silently disappear.

## [0.5.1] - 2026-04-23

### Changed

- **Transmog summary redesigned.** Splits by current difficulty vs. other difficulties, with explicit Missing and Shared counts per line. Numbers go green at zero, orange otherwise. Collapses to "All appearances collected!" when fully complete across all four difficulties.

### Fixed

- Main panel no longer resets to its default position on `/reload` inside a supported raid. Your saved position now sticks.

## [0.5.0] - 2026-04-22

### Added

- **Castle Nathria** (Shadowlands) raid support with weapon-token tracking and covenant-aware vendor hints.
- MIT License. RetroRuns is now formally licensed and free to use, modify, and redistribute under the MIT terms.

### Changed

- First public release candidate on CurseForge.
