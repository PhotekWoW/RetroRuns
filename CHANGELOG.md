# Changelog

All notable changes to RetroRuns are documented here.

## [1.9.0] - 2026-05-13

### Added

- **Tomb of Sargeras** is now fully supported — walk-along routes for all 9 bosses across the Broken Shore raid. Per-difficulty transmog tracking with full Tier 20 coverage (6-piece sets, the second six-piece tier in WoW history after Black Temple's T6), with achievement callouts and soloability ratings. Notable routing: the Maiden-of-Vigilance step's canonical suicide-jump-respawn shortcut that drops you back to Chamber of the Moon. Special loot: Mistress Sassz'ine's Abyss Worm mount.

### Fixed

- **Boss kill detection now works on non-English clients.** Kills register in the Boss Progress column in real time on all locales, not just English.

## [1.8.0] - 2026-05-11

### Added

- **The Nighthold** is now fully supported — walk-along routes for all 10 bosses through Suramar's most opulent palace. Per-difficulty transmog tracking with full Legion-tier coverage, with achievement callouts and soloability ratings. Notable routing: Suramar Portal teleport segments to The Nightspire (Elisande) and The Font of Night (Gul'dan).
- **Illusion: Chronos tracking on Chronomatic Anomaly.** The weapon-enchant illusion that drops from the time-warping arcane fight now appears in his encounter card with a collected/missing indicator pulled from your transmog collection — same treatment Xavius's Illusion: Nightmare got in v1.7.0.
- **Toy and decor tracking on Gul'dan and Spellblade Aluriel.** Two toys drop from Gul'dan and aren't surfaced in the in-game Adventure Guide — Golden Hearthstone Card: Lord Jaraxxus (all difficulties, all classes) and Skull of Corruption (Demon Hunter only). Both now appear in Gul'dan's Special Loot section with collection state. The Nighthold also drops Magistrix's Garden Fountain from Spellblade Aluriel — a housing decor item added in the 11.2.7 patch — and that's now surfaced too.

### Fixed

- **Wowhead `?` buttons on the Achievements window now respond consistently to clicks.** Same dispatch race that affected the `+` expansion toggles in v1.7.1, on a different surface. The Achievements window was rebuilding every row on the once-per-second UI tick — clicks that straddled a rebuild got eaten as the button vanished mid-click. The window now skips the rebuild when nothing has changed.
- **Special Loot items you've already collected stay clickable.** Previously, collecting a mount, pet, toy, illusion, or decor would gray out its name in the Special Loot section and remove the click-to-tooltip behavior. The item link is now preserved — collected items render in their quality color (same as uncollected) and stay clickable, so you can still preview the appearance, link it to chat, or check stats. The `[check]` glyph on the left is now the sole visual signal that the item is collected.
- **Weapon-enchant illusions in the Special Loot section now show with a proper "Illusion" label and a distinct color.** Previously rendered as lowercase `(illusion)` in a neutral fallback gray; now reads as `(Illusion)` in a pale violet, matching the color-coded conventions for mounts, pets, toys, decor, and manuscripts.

## [1.7.1] - 2026-05-10

### Added

- **Trial of Valor** is now fully supported — walk-along routes for Legion's 3-boss mini-raid bridging Emerald Nightmare and Nighthold. Per-difficulty transmog tracking, with achievement callouts and soloability ratings. Notable routing: the canonical post-Odyn dialog teleport into Helheim.

### Fixed

- The "+" expansion toggles on the supported-raids list now respond consistently to clicks. Previously, spam-clicking a toggle would only expand the list intermittently due to a UI refresh race; the refresh now skips redundant rebuilds.

## [1.7.0] - 2026-05-10

### Added

- **The Emerald Nightmare** is now fully supported — walk-along routes for all 7 bosses, with achievement callouts and soloability ratings. Per-difficulty transmog tracking.
- **Illusion: Nightmare tracking on Xavius.** The weapon-enchant illusion that drops from Xavius now appears in his encounter card with a collected/missing indicator pulled from your transmog collection — same treatment mounts, pets, and toys get on other bosses. Reflects whether you've personally collected the illusion (account-wide).
- **Minimize button on the main panel.** A small `-` button just left of the close X collapses the panel down to its title bar — logo, RETRO RUNS text, and the close + minimize buttons. The body content (raid info, route note, supported-raids list) and the action-button row (Map, Tmog, Achieves, Skips, Settings) hide when minimized; click the `+` button to expand back. The panel's top edge stays put across the resize, so it grows downward from the title bar rather than shifting up. Minimized state persists across `/reload` — if you logged out minimized, the panel comes back up minimized next session.
- **Flight to the Castle Nathria covenant weapon vendor.** When viewing the transmog details for a Castle Nathria boss that drops weapon tokens, a small flight-master button appears next to the "Redeem at..." vendor hint. Click it to drop a waypoint directly on the Mythic Nathrian Weaponsmith for your active covenant (Battlemaster Endios in Elysian Hold for Kyrian, Vorpalia in Sinfall for Venthyr, Sulanoom in Heart of the Forest for Night Fae, or Odious Gwor in Seat of the Primus for Necrolord). Uses the same waypoint cascade as the raid-entrance buttons — AzerothWaypoint, Zygor, Mapzeroth, TomTom, or the Blizzard map pin — picking the routing-capable one you have installed. Hover for a tooltip showing which vendor you're being sent to. The button doesn't appear if you haven't picked a covenant yet.

### Fixed

- **Stale route notes after `/reload` mid-raid.** A timing issue in how the route picker stored lockout state could cause it to surface a later seg's note after a `/reload` mid-raid, instead of the seg matching your actual current location. Affected Battle of Dazar'alor on the live build; the fix lands in time to also cover The Emerald Nightmare. The picker now reads the lockout ID directly from Blizzard's API at every check, and self-heals corrupted persisted state from prior sessions on the next `/reload`.

## [1.6.0] - 2026-05-09

### Added

- **Battle of Dazar'alor** is now fully supported — walk-along routes for all 9 bosses with full faction-asymmetric handling. Alliance and Horde have different entrances, different boss orders, and different paths through the same nine rooms; the addon detects your faction and serves the right route, with a small `[A]` or `[H]` faction marker in the panel. Per-difficulty transmog tracking, with achievement callouts and soloability ratings. Special loot: Jaina's Glacial Tidestorm mount and the Conclave-of-the-Chosen pets.
- **AzerothWaypoint integration on the entrance buttons.** If you have AWP installed, clicking a raid entrance routes through AWP's planner, which gives you full step-by-step routing if you also have Zygor, Mapzeroth, or Farstrider installed alongside it. Without a backend, AWP behaves like a single TomTom waypoint. The footer pill bar now reads `[ AWP | Zygor | Mapzeroth ]` with each pill lit in its brand color when that addon is loaded and dimmed to gray otherwise.

### Changed

- **The yellow `[!]` next to "view special note" now pulses subtly.** A gentle brightness-breathing effect — full-bright down to about 70% and back over a 1.6-second cycle — to draw the eye to bosses that have custom solo-play notes. The link text itself stays static and fully readable; only the leading `[!]` glyph pulses. Stops automatically once you expand the note.

## [1.5.0] - 2026-05-07

### Added

- **One-click navigation to raid entrances.** Each raid in the supported-raids list now has a flight-master icon next to its name. Clicking it routes you to that raid's entrance. With Zygor or Mapzeroth installed, you get full step-by-step turn directions through portals, flight paths, hearthstones, mage teleports, class abilities, toys, and items — whatever the routing addon's travel graph covers. Without either of those installed, a single waypoint is set at the entrance via TomTom (if loaded) or Blizzard's native pin. The icon is full color when a routing addon is loaded and muted when only single-waypoint providers are available, so you can tell at a glance whether you're getting the full experience. A footer pill bar shows `[ Zygor | Mapzeroth ]` with the active routing addon lit in its brand color and the inactive one dimmed to gray, or — if neither is installed — a prompt to install one for full routing. Cancel an active route at any time with `/rr cancelnav`.
- **"Waypoint set" toast.** When you click the entrance icon and the route falls through to TomTom or Blizzard's native pin (the silent paths), a brief gold "Waypoint set" notice fades in next to the icon for spatial confirmation that the click did something.
- **Redesigned route lines on the World Map.** The pink route polylines now carry direction-of-travel cyan chevrons placed at a fixed pixel stride along each segment, so you can tell at a glance which way the path runs. The destination marker at the end of each route is a cyan-fill / pink-border triangle pointing at the boss, replacing the prior generic icon. Same routing behavior — just a clearer read on direction and destination.
- **Skip-status indicator on every raid row.** Each raid in the supported-raids list now leads with a yellow star whose state tells you whether the raid's skip is unlocked on this account: filled for unlocked, dim for "raid has a skip system but you haven't earned it yet," and invisible (column-aligned blank) for raids with no skip mechanic. Per-difficulty granularity (which difficulties the skip applies to) lives in the dedicated Skips window — the supported-raids list shows the binary state only.
- **Single-expand accordion behavior on the supported-raids list.** Click an expansion to expand it; opening one collapses any other that's currently open. Click an already-open section to collapse it. Keeps the panel compact regardless of how many expansions are supported.
- **Submit-a-bug and feedback buttons in Settings.** A pair of icon buttons next to the Defaults button. The pink beetle opens a copyable popup with the GitHub Issues URL for filing tracked bug reports. The cyan chat-bubble opens a copyable popup with the CurseForge comments URL for general feedback, questions, and suggestions. Ctrl+C, paste into your browser, talk at me.

### Fixed

- **Difficulty pill kill counts now display correctly.** A regression in v1.4.0 caused every raid's `[ LFR | N | H | M ]` pill row to render as gray dashes instead of `0/8` style kill counts, even on raids and difficulties where bosses had been killed. The cause was a Blizzard API behavior change in how raid encounter data is queried; the lookup now correctly populates and pill rows reflect actual lockout state again. If you were seeing `[ LFR - | N - | H - | M - ]` on every raid, this is fixed.

## [1.4.0] - 2026-05-06

### Added

- **Achievements window.** A new "Achieves" button in the action row opens a standalone achievements window with Expansion and Raid dropdowns and a row-table layout showing every achievement for the selected raid: status indicator (earned or not), achievement name with click-through to the in-game tooltip, the boss it drops from, and a `?` button that opens a copyable Wowhead URL for the achievement. Each raid that has a Glory meta-achievement shows the Glory header at top with its current completion count and the mount reward link. A blue highlight marks the boss the route is currently on so you can see at a glance which row matters right now. The window updates live as you progress: earning an achievement flips its status indicator within a fraction of a second, the Glory count ticks up per criterion, and the highlight follows the route as you kill bosses. Achievements you've already earned render in gray to de-emphasize them.
- **Soloable indicators on each achievement.** A colored star next to each achievement name tells you whether it's soloable: green for "yes, any class can solo this", orange for "kinda — you'll need specific class abilities", red for "no, confirmed not soloable".

### Changed

- **Eranog (Vault of the Incarnates) routing reworked.** Pre-flight, the panel now shows just the dragon-platform instruction and a single map line, instead of three numbered legs all drawn at once with a dense combined instruction. Once the dragon ride ends and you land, the dragon stub disappears and two color-coded numbered lines for Volcanius and Eranog appear with a matching "kill (1) Volcanius, then (2) Eranog" instruction. Same coordinates and same kill detection — just a less crowded view at each phase of the encounter.
- **Hover behavior removed from the in-panel boss encounter line.** Earlier the encounter widget would gold-tint its label and show a "Notes assume Mythic difficulty" tooltip when you hovered. The widget is now click-only — click to expand, click an achievement link to see its tooltip, no hover behavior.

### Fixed

- **Idle UI panel no longer "jumps" when you expand the Battle for Azeroth section.** The panel grows downward as content expands instead of growing upward and downward equally — so the `+` toggle button stays under your cursor when you click it.
- **Panel position now stable when Window Scale is set to anything other than 1.00x.** Two related symptoms went away: dragging the panel no longer makes it snap to a wrong spot when you release the mouse, and clicking an expansion `+`/`-` toggle no longer drifts the panel toward the upper-left of the screen with each click. Affects the main panel and the Settings window's drag handler.

## [1.3.0] - 2026-05-04

### Added

- **Crucible of Storms** is now fully supported — walk-along routes for both bosses (The Restless Cabal in the Shrine of Shadows, Uu'nat in the Tendril of Corruption), with achievement callouts. Special loot: Restless Cabal's Crucible Votive Rack, the first housing decor item to ship in Special Loot.
- **Uldir** is now fully supported — walk-along routes for all 8 bosses across the three wings, with achievement callouts and soloability ratings. Notable routing: Brann Bronzebeard's and MOTHER's voicelines advance the travel pane through the Titan Console sequence so on-screen instructions track in-fight action.

### Changed

- **Special Loot rows now show the item name in gray when you've collected it**, matching the visual treatment that completed achievements have always used. Uncollected rows keep their item-quality color. Affects every collected mount / pet / toy / decor across every supported raid.

### Fixed

- **Boss Progress list no longer crowds against the Map / Tmog / Skips / Settings button row.** The list now has visible breathing room above the action buttons.

## [1.2.0] - 2026-05-03

### Added

- **The Eternal Palace** is now fully supported — walk-along routes for all 8 bosses across the underwater Nazjatar palace, with achievement callouts and soloability ratings. Notable routing: the two Font of Power orb gates between Behemoth and Ashvane detect First Arcanist Thalyssra's voicelines so the route advances correctly after each orb click; Orgozoa's teleport-pad room uses numbered-waypoint rendering instead of polylines. Special loot: four Storm's Wake pets.
- **Panel opacity slider in Settings.** Drag the new "Panel Opacity" slider to dim the dark backdrop on every RetroRuns window — main panel, transmog browser, raid skips, and settings itself — anywhere from 100% (default, fully opaque) down to 20%. Text and icons stay fully readable; only the background tint changes. Useful if you want the panel less visually intrusive while you've got it parked over your raid frames or world map.

### Changed

- **Settings panel cleaned up.** The header now matches the styled "RETRORUNS" treatment used on the Tmog and Raid Skips windows. The Minimap button toggle moved from its old top-left spot to the bottom-right corner, alongside the (now shorter) "Defaults" reset button — gives the new opacity slider room to breathe and tightens the bottom row.
- **Main panel no longer prefixes the next boss with a number.** The "Boss #2: Sun King's Salvation" line now just reads "Sun King's Salvation". The number was a leftover from earlier development and was misleading on raids where the recorded route doesn't follow the in-game encounter ordering.

### Fixed

- **Raid Skips window now lists expansions newest-first** (Dragonflight, Shadowlands, Battle for Azeroth, etc.) instead of alphabetically. Matches the ordering used in the supported-raids list on the main panel.
- **Boss Progress checklist no longer flickers when adjusting Settings sliders mid-run.** Dragging the font, scale, or new opacity slider while the panel was showing your in-raid Boss Progress checklist would briefly flash idle-state expansion headers on top of the list every frame the mouse moved. Both views now stay put while you're tuning settings.

## [1.1.0] - 2026-05-01

### Added

- **Ny'alotha, the Waking City** is now fully supported — walk-along routes for all 12 bosses across the three mid-raid wings, with achievement callouts and soloability ratings (including multi-phase callouts on Carapace of N'Zoth and N'Zoth the Corruptor). Special loot: the Ny'alotha Allseer mount and all five raid pets.

### Changed

- **POI star icons now sized appropriately for older raids' smaller sub-zone maps.** The map markers used for things like Re-origination Anchor interaction points (Ny'alotha) and the fire portal on Fyrakk's platform (Amirdrassil) are now sized per-segment rather than a fixed value across the whole addon. Existing POIs in newer raids look the same as before; Ny'alotha's three Re-origination Anchor stars and the N'Zoth boss-location pin render at a smaller, more proportional size for the BfA-era map scale.

### Fixed

- **Travel pane no longer pops back to the wrong segment's directions during multi-segment route transitions.** When walking through a route step that spans multiple sub-zones (like Xanesh's three-segment approach in Ny'alotha), briefly crossing through an in-between map area no longer caused the pane to re-display the very first segment's stale text. The pane now tracks which segments you've completed and surfaces the next incomplete one. Affects any raid with multi-segment routing steps.

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

- **Amirdrassil, the Dream's Hope** is now fully supported — walk-along routes for all 9 bosses, with achievement callouts and soloability ratings. Notable routing: branching priority routes (Volcoross and Council of Dreams can be cleared in either order after Igira) and POI markers (a map pin marks the fire portal on Fyrakk's platform). Special loot: Drakewatcher Manuscript tracking for Fyrakk's Highland Drake: Embodiment of the Blazing.
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

- **Aberrus, the Shadowed Crucible** is now fully supported — walk-along routes for all 9 bosses, with achievement callouts and soloability ratings. Special loot: Drakewatcher Manuscript tracking for Sarkareth's Highland Drake: Embodiment of the Hellforged.
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

- **Vault of the Incarnates** is now fully supported — walk-along routes for all 8 bosses, with achievement callouts. Special loot: Iskaara Trader's Ottuk barter-mount tracking.
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

- **Castle Nathria** is now fully supported — Shadowlands' first raid with weapon-token tracking and covenant-aware vendor hints.
- MIT License. RetroRuns is now formally licensed and free to use, modify, and redistribute under the MIT terms.

### Changed

- First public release candidate on CurseForge.
