# Changelog

All notable changes to RetroRuns are documented here.

## [1.0.1] - 2026-04-30

### Added

- **Account-wide raid skip detection** — RetroRuns now knows which raid skips your account has unlocked across all your characters. A new `Skips` button in the panel footer opens a dedicated window showing each supported raid in a Mythic / Heroic / Normal table with checkmarks for unlocked difficulties. The cascade is downward-only: completing the Mythic skip quest unlocks Mythic + Heroic + Normal; completing Heroic unlocks Heroic + Normal; completing Normal unlocks Normal alone.
- **Skip-status indicators in the supported-raids list.** When a raid's skip is unlocked at all difficulties (Mythic ceiling), a yellow star appears next to the raid name. When only some difficulties are unlocked (Heroic or Normal ceiling), the star appears next to each affected difficulty pill (e.g. `N★`, `H★`). LFR pills are never marked since the in-game raid skip system doesn't apply to LFR.
- **Skip-status indicator in the active-raid header.** When you zone into a supported raid, a yellow star appears next to the raid name if your current difficulty is at or below your account's cascade ceiling — meaning the in-game skip NPC will actually let you use the skip on this run.
- **Action button row at the bottom of the panel** — Map / Tmog / Skips / Settings, all four equally accessible. Replaces the previous slash-command reference text. Map and Tmog were previously in the panel header; they now live in the bottom row alongside the new Skips button and a Settings shortcut.

### Changed

- **Expansion-section toggles in the supported-raids list now use the standard Blizzard plus/minus button graphic** instead of the ASCII `[+]` / `[-]` markers. Same click behavior, same per-session collapsed state — just a more polished look that matches collapsible lists in the default game UI.
- **Tmog button defaults to the current raid when zoned into a supported raid.** Previously the Tmog browser would open to whatever raid you last browsed. Now if you're in Aberrus and click Tmog, it opens to Aberrus directly. The dropdown is still right there for switching to a different raid.
- **The "Designed for max-level characters running legacy content" tagline** has been removed from the panel — the same information appears in the addon's CurseForge description and the panel itself feels more action-oriented now with the new button row.

### Fixed

- **Tier transmog rows in Aberrus, Vault of the Incarnates, and Amirdrassil now show the correct collected-state for Mythic and LFR.** Tier pieces you'd Mythic-collected were showing as LFR-collected and Mythic-uncollected in the transmog browser. The data has been re-verified against the live game for all three affected raids. Sepulcher of the First Ones was unaffected.
- **Expansion-toggle buttons in the supported-raids list now stay aligned with their labels at any font size.** Previously the second/third expansion's button could drift off-position relative to its text, requiring multiple clicks to expand. Now click the `+` or `-` once and it works.
- **Footer at high font sizes no longer wraps the byline or truncates the version.** At larger font-size settings the "Created by Photek" line could wrap onto two lines and the version string in the bottom-right could clip mid-text (rendering as `v1....`). Both elements now resize to fit their content correctly at any font scale.
- **Color key now appears at the bottom of the transmog browser even when you're not in a supported raid.** The legend explaining the dot colors was previously suppressed outside supported raids, leaving people browsing past raids from the world without a way to decode the markers. The "Current difficulty" header above the loot still hides when no raid is active (there's no current difficulty to show), but the key itself is now always visible.

## [1.0.0] - 2026-04-29

### Added

- **Amirdrassil, the Dream's Hope** is now fully supported — walk-along routes for all 9 bosses, encounter notes, achievement callouts, and Drakewatcher Manuscript tracking for Fyrakk's Highland Drake: Embodiment of the Blazing. The raid introduces two new routing patterns: branching priority routes (Volcoross and Council of Dreams can be cleared in either order after Igira) and POI markers (a map pin marks the fire portal on Fyrakk's platform).
- **Tmog browser button on the main panel.** A dedicated "Tmog" button sits in the panel header and opens the transmog browser for the current raid at any time, regardless of whether you're actively in a boss encounter.
- **Collapsible expansion sections in the supported-raids list.** Each expansion header on the idle panel now has a `[+]` / `[-]` toggle that expands or collapses the raids beneath it. All expansions start collapsed at login or reload, so the panel boots compact and you expand only what you want to see. Clicking the toggle resizes the panel automatically.
- **Encounter notes disclaimer.** Hovering over the Boss Encounter section now surfaces a tooltip noting that encounter notes assume Mythic difficulty. Mechanics that no longer apply (or apply differently) on lower difficulties won't be flagged separately.

### Changed

- **Yellow `[!]` marker on bosses with custom encounter notes.** When a boss has a hand-written solo tip, the "view special note" affordance under the Boss Encounter line is now prefixed with a yellow `[!]` so it's easier to spot at a glance. Bosses with the default Mythic note (most of them) continue to read "Standard" with no marker.
- **Supported raid list now sorted newest-first by patch.** When the panel is idle, raids appear in descending patch order (10.2 → 10.1 → 10.0 → 9.2 → 9.1 → 9.0) with the patch number shown next to each name.
- **Transmog browser dropdowns sorted newest-first to match the idle panel.** The expansion dropdown now leads with the most recent expansion, and within each expansion the raids appear newest-patch-first. Boss order within a raid is unchanged (still encounter order).
- **Per-row counts removed from the browser dropdowns.** The expansion, raid, and boss dropdowns no longer show `(collected/total)` suffixes after each entry — those numbers had a tendency to misread as "missing/total" or otherwise confuse, and the per-difficulty dot rows already convey the same information more clearly when you actually look at a boss.
- **Boss encounter section starts collapsed each session.** The section resets to collapsed on each login or reload, keeping the panel tidy. Your toggle during a run still works as before — it just won't carry over to the next session.
- **Travel pane stays stable during boss fights.** Route directions no longer update mid-encounter when the game transitions between sub-zones (relevant to multi-platform encounters like Tindral Sageswift). The pre-fight directions hold until the kill, then snap to the next step.

### Fixed

- **Tier resolver now correctly attributes class-restricted tier tokens.** The harvester previously used the first available source for each tier token regardless of class restriction. It now matches each token to the correct class by reading the in-game tooltip, preventing silent misattribution when a boss's tier pieces span multiple armor types.
- **Legendary item orange no longer requires two reloads to appear.** Item appearances for legendary drops (Rae'shalare, Nasz'uro, Fyr'alath) are now pre-fetched when you zone into a raid. The first render after zoning in shows the orange correctly without a second reload.
- **Browser items resolve correctly on first open.** The transmog browser previously needed a second open to render some items in their correct color and name (a side effect of the game's asynchronous item-info cache). The browser now warms the cache when you open it and refreshes itself as items resolve, so the first view is the correct one.

## [0.7.0] - 2026-04-27

### Added

- **Aberrus, the Shadowed Crucible** is now fully supported — walk-along routes for all 9 bosses, encounter notes, achievement callouts, and Drakewatcher Manuscript tracking for Sarkareth's Highland Drake: Embodiment of the Hellforged.
- **Sarkareth Void-Touched Curio note in the transmog browser.** A small footnote on Sarkareth's transmog view calls out that the omnitoken exists but isn't tracked by the addon (it exchanges for any tier slot of the player's choice, which doesn't fit the per-slot tracking model).

### Changed

- **"Show all class tier" checkbox now disables on bosses that don't drop tier tokens.** Previously the checkbox was always clickable; now it greys out on non-tier bosses so the control's reachability matches its effect.
- **Boss Progress / Where to next pill consistency.** When you kill a boss, both the panel header pill and the per-raid pill in the "Where to next" panel now update at the same instant. Previously the per-raid pill could lag behind by a few seconds until the game's saved-instance data refreshed.

### Fixed

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
