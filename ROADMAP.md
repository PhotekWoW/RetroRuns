# RetroRuns — Roadmap & Feature Tracker

## Current Version: 1.7.1

---

## ✅ Implemented

- Minimize / maximize on the main panel — small `-` button left of the
  close X collapses the panel to its title bar (logo + RETRO RUNS text +
  close + minimize buttons), hiding all body content and the action-
  button row. Click the `+` to expand back. Top edge stays put across
  the resize. State persists across `/reload` via the `minimized`
  setting.
- Route drawing on the World Map (path lines, nav icons)
- Multi-floor routing with teleporter segment awareness
- Automatic teleport-arrival detection (segment auto-advance)
- Boss kill detection via ENCOUNTER_END
- Lockout sync from WoW saved instance API
- Per-boss solo tips (encounter notes)
- Per-boss achievement callouts with collected/uncollected state
- Boss progress checklist with check / [>] / [ ] markers
- Walk-along route recorder with teleport-aware segment breaks
  - `/rr record tp <destination>` — closes segment, auto-detects arrival map
  - `/rr record note <text>` — annotates current segment
  - `/rr record dump` — exports complete pasteable routing entry
- Map-click point insertion (for precise teleporter endpoints)
- Yell-trigger route advancement — segments can declare an `advanceOn`
  block listening for an NPC voiceline (CHAT_MSG_MONSTER_YELL / SAY /
  RAID_BOSS_EMOTE). Used for boss approaches gated on interactions
  that don't fire any directly-observable event (e.g. Eternal Palace's
  two Font of Power orbs that gate Radiance and Ashvane). Pre-
  engagement yells only; mid-encounter chat payloads are skipped due
  to secret-tainted-value handling on the WoW 12.0 client.
- Sub-zone-aware route gating — segments can declare a
  `requiresSubZone` field that defers seg-display until the player's
  `GetSubZoneText()` matches. Handles parent-zone-fallback transit
  areas (unnamed corridor/swim segments that share a mapID with a
  named sub-zone interior) so the travel pane doesn't surface the
  destination's instruction prematurely. Eternal Palace's underwater
  corridor between Sivara/Radiance and Halls of the Chosen is the
  canonical use case.
- Predecessor-gated segment reveal — segments can declare a
  `revealAfter = N` (or `revealAfter = { N1, N2, ... }`) field that
  hides them from both the World Map renderer and the travel-pane
  note picker until the listed predecessor segs are marked complete.
  Pairs naturally with `advanceOn` (yell trigger): the yell marks
  the predecessor seg complete, then the gated seg becomes visible.
  First used on Vault of the Incarnates' Eranog approach to switch
  between a pre-flight dragon-platform stub and the post-landing
  Volcanius/Eranog walk on Raszageth's "skies are mine to control"
  yell.
- Numbered map waypoints — for steps using `renderAllSegments=true`,
  the World Map overlay labels each rendered segment endpoint with
  a numeral (1, 2, 3...) for player self-pacing through routes that
  can't be auto-advanced. Eternal Palace's Orgozoa teleport-pad room
  and Vault of the Incarnates' post-landing Volcanius/Eranog approach
  both use the pattern. The numbering reflects render-order on the
  current map, so it stays contiguous from 1 even when the step
  contains instruction-only, cross-map, or `revealAfter`-gated
  segments that aren't currently drawn. When only one segment is
  visible (typically because `revealAfter` is gating the rest) the
  numeric labels are suppressed entirely so a lone "(1)" doesn't
  appear without context.
- Test mode (`/rr test` / `/rr next` / `/rr real`)
- Manual kill overrides (`/rr kill` / `/rr unkill`)
- Data validation on load (debug mode)
- Saved panel position (persists across sessions)
- Font/scale settings panel (sliders display current values live:
  "Font Size: 14" / "Window Scale: 1.00x")
- Panel opacity slider (Settings) — backdrop alpha 20%–100%, applies
  uniformly to all four backdrop windows (main panel, transmog browser,
  raid skips, settings). Per-character. Content stays full-opacity for
  readability; only the dark backdrop fades.
- Styled title font (04B_03) on main panel and load popup
- Clickable minimap button (left-click toggle, right-click settings,
  drag to reposition around minimap edge)
- Loot harvester (dev tool) — full-raid harvest with per-difficulty
  `itemModifiedAppearanceID` capture via `GetAllAppearanceSources`, plus
  per-class tier loot enumeration via `EJ_SetLootFilter`
- Special Loot tracking — mount/pet/toy/decor items detected and rendered
  per boss with collected/uncollected state, kind tag, and clickable
  itemLink. Harvester auto-detects via `C_MountJournal` / `C_PetJournal` /
  `C_ToyBox` / `C_HousingCatalog` with per-boss Mythic sweep for
  difficulty-restricted drops
- `/rr status` — print current raid, step, kill state, and mapID to chat
- `/rr tmogverify [raid-name]` — full-raid data-integrity audit.
  Validates each sourceID against API (GetSourceInfo non-nil, itemID
  matches, visualID resolves), then classifies loot shape (binary /
  perdiff / partial) per item. Catches mis-assigned sourceIDs, stale
  data, swapped difficulty buckets. Flags data-shape bugs that
  `/rr tmogaudit` (state-logic audit) doesn't catch.
- Idle-state "Detected:" acknowledgement when zoned into a supported
  raid but popup dismissed
- Help split: user-facing `/rr help` (8 clean commands); diagnostic
  commands hidden behind unadvertised `/rr help dev`
- Login banner on PLAYER_LOGIN announcing version
- Centralized settings access via `RR:GetSetting(key, default)` /
  `RR:SetSetting(key, value)` — all 33 actionable call sites migrated,
  single audit point for addon-tracked settings
- Reset to Default preserves `showPanel` and `debug` state (only
  resets appearance/positioning settings, not transient toggles)
- Weapon-token collection indicator (3-state: none / some / all
  collected) for bosses that drop weapon tokens, rendered in the
  transmog popup below the per-difficulty armor rows. Shows whether
  you have none, some, or all of the slot appearances from that
  boss's weapon token pool.
- Covenant-aware vendor hint beneath the weapon-token indicator,
  naming the player's covenant and sanctum zone in covenant theme
  color (Kyrian blue, Venthyr red, Night Fae purple, Necrolord
  green). Falls back to a covenant-agnostic nudge if the player
  hasn't chosen a covenant.
- `/rr weaponharvest` (dev tool) — harvests CN weapon-token
  appearance pools from a seeded itemID list. Emits ready-to-paste
  `weaponTokenPools = {...}` block for the raid data file.
- `/rr vendorscan` (dev tool) — scans the currently-open merchant
  frame for offered items and their cost currencies, grouped by
  cost. Captures NPC name + player covenant for context. Useful
  for investigating token-system accessibility questions.
- Achievements standalone window — standalone "Achieves" button opens
  a per-raid table showing every Glory-meta achievement with status
  indicator (earned or not), boss attribution, soloable difficulty
  star (green = any class, orange = class-specific kit needed, red =
  confirmed not soloable), and a Wowhead `?` copy button. Each raid
  with a Glory meta shows a header with the current completion count
  and mount reward link. Updates live as you earn achievements. A
  blue highlight marks the boss the route is currently on. Mutex
  with the Tmog, Skips, and Settings windows.
- One-click entrance navigation — every supported raid carries entrance
  coords (zone mapID + xy) on its data table. The supported-raids list
  in the idle panel renders a flight-master icon next to each raid;
  clicking it routes the player to that raid's entrance via a four-tier
  dispatch order: Zygor (premium routing addon) → Mapzeroth (free
  routing addon) → TomTom (single waypoint) → Blizzard native pin.
  Tier-aware visual treatment: full-color icon when a routing addon is
  loaded ("routing" tier), muted when only single-waypoint providers
  are available ("waypoint" tier). Footer legend names the active
  routing addon (or, in waypoint tier, prompts the user to install
  Zygor or Mapzeroth). On the silent dispatch tiers (Blizzard, TomTom),
  a brief "Waypoint set" toast fades in next to the click for
  spatial confirmation.

---

## ✅ Implemented (idle-panel polish, v1.5)

- Three-state skip-status leading glyph on every raid row (filled
  yellow star = skip unlocked on this account; dim star = raid has a
  skip system but you haven't earned it yet; transparent placeholder
  = raid has no skip mechanic). Replaces the previous `* ` bullet,
  reading as both bullet and skip-status indicator in one glyph.
  Per-difficulty skip granularity moved to the dedicated Skips
  window — the supported-raids list shows binary "exists / not yet
  unlocked" only.
- Single-expand accordion behavior on the supported-raids list.
  Opening one expansion now collapses any other that's currently
  open. Click an already-open expansion to collapse it. Keeps the
  panel compact regardless of how many expansions ship.
- Legend block (skip key + entrance key) repositioned: pinned just
  above the action button row at the panel bottom rather than
  chained after the last raid line, so the keys read as a key
  block above the action row regardless of raid-list length.
  Smaller font (10pt fixed) makes the keys read as metadata, not
  content. Mirrors the achievements window's bottom-strip
  soloable legend pattern.
- Routing-addon legend pill bar. Replaces the prior "Navigation
  powered by X" plain-text line with a `[ Zygor | Mapzeroth ]`
  pill bar matching the difficulty pill grammar. Active routing
  addon renders in its brand color (Zygor: orange-gold #ff8800;
  Mapzeroth: teal #5fcde4); the inactive one dims to gray
  (#555555). Both routing options visible at a glance; the active
  one called out. Waypoint tier (neither installed) keeps the
  install-pitch text line.
- In-Settings shortcut buttons next to the Defaults button. Two
  custom 22x22 icon buttons: a pink beetle (RETRO pink #F259C7
  via vertex-tinted white-source TGA) opens a Wowhead-style copy
  popup with the GitHub Issues URL; a cyan chat-bubble (RETRO
  cyan #4DCCFF via the same recipe) opens a parallel copy popup
  with the CurseForge comments URL. Wowhead pattern was chosen
  over a multi-line copy window so each button does one thing
  cleanly. Custom TGAs in `Media/BugIcon.tga` and
  `Media/ChatIcon.tga` after several Blizzard-stock icon attempts
  failed to render or read poorly at 22x22.

---

## 🔲 Active Development

### Transmog Tracker
- Basic per-boss loot popup — **done**
- Single-difficulty collected/uncollected summary — **done**
- Per-difficulty `[LFR | N | H | M]` dot row per item with three-state
  coloring (collected green / uncollected active-difficulty white /
  uncollected other-difficulty gray) — **done**
- Tier item marker and per-class filtering (show only the player's
  class's tier set pieces, tagged visually with `(<Class> Tier)`) —
  **done** (verified working in tmog UI for Sepulcher)
- "Show all class tier" toggle in the tmog popup for multi-class
  players — **done** (persisted to RetroRunsDB.showAllTierClasses)
- Tmog browser persists last-browsed (expansion, raid, boss) selection
  across sessions — **done**
- Sepulcher data file rewritten from harvester output — **done**
  (ATT cross-reference removed; harvester is now canonical)

### Additional Raid Support
- Each new raid gets its own `Data/<RaidName>.lua` file
- Target raids (rough priority order):
  - Shadowlands: Sanctum of Domination — **DONE.** Full skeleton +
    98 items + 6 collectibles + 10/10 routes shipped.
  - Castle Nathria — **DONE.** Skeleton + 10 bosses + armor-shape
    loot + 10 routes + achievements + specialLoot detection +
    weapon-token 3-state indicator + covenant-aware vendor hint.
    Shipped in v0.4.9.
  - Dragonflight: Vault of the Incarnates — **DONE.** Full skeleton
    + 8 bosses + 55 non-tier loot + 65 class tier pieces + 20 tier-
    set token sources + Iskaara Trader's Ottuk barter mount + 8
    routes + soloTips + achievements. Shipped in v0.6.0. First raid
    exercising the barter-mount specialLoot schema and DF-era gem-
    encoded tier token naming (Jade/Amethyst/Garnet/Lapis/Topaz =
    Legs/Chest/Hands/Shoulders/Head), and the first raid where a
    boss's route revisits a mapID -- which surfaced the route-aware
    segment-completion architecture (HandleLocationChange's
    successor-mapID rule + ENCOUNTER_END safety net) that's now the
    foundation for any future raid with similar topology.
  - Dragonflight: Aberrus, the Shadowed Crucible — **DONE.** 9
    bosses, 133 loot items, 65 tier rows, 20 tier tokens, 16 routing
    segments, achievement callouts, soloTips on Echo of Neltharion
    and Sarkareth, Drakewatcher Manuscript tracking, Void-Touched
    Curio footnote, and Nasz'uro the Unbound Legacy (Evoker legendary).
    Shipped in v0.7.0 / v1.0.0.
  - Dragonflight: Amirdrassil, the Dream's Hope — **DONE.** 9
    bosses, full routing with priority branching (Volcoross and
    Council of Dreams in either order), POI markers, encounter-
    freeze travel pane, Drakewatcher Manuscript tracking, Flame-
    Warped Curio footnote, Fyr'alath the Dreamrender (legendary).
    Shipped in v1.0.0.
  - BFA: Ny'alotha, The Waking City — **DONE.** 12 bosses, 89 loot
    items + 6 special-loot collectibles (Allseer mount + 5 raid pets),
    full DAG routing across three parallel mid-raid wings, encounter
    notes (multi-phase magenta-numbered cues on Carapace and N'Zoth),
    achievement callouts including Glory of the Ny'alotha Raider meta,
    account-wide MOTHER's Guidance skip detection. First raid to ship
    with the per-segment `poiSize` field for proportional star sizing
    on smaller sub-zone maps. Shipped in v1.1.0.
  - BFA: The Eternal Palace — **DONE.** 8 bosses, 94 loot items + 4
    Storm's Wake pets (Mindlost Bloodfrenzy, Lightless Ambusher,
    Nameless Octopode, Zanj'ir Poker), full linear DAG routing, two
    yell-gated boss approaches (Radiance and Ashvane via the Font of
    Power orbs), numbered-waypoint rendering on Orgozoa's teleport-
    pad room (The Traverse). First raid to ship with the yell-trigger
    framework and the `requiresSubZone` field for parent-zone-fallback
    transit handling. Shipped in v1.2.0.
  - BFA: Crucible of Storms — **DONE.** 2 bosses (The Restless Cabal,
    Uu'nat, Harbinger of the Void), 14 loot items, linear two-segment
    routing, two per-boss feat achievements (Gotta Bounce, A Good
    Eye-dea -- both standalone, no Glory meta exists for this raid).
    First raid to ship a housing decor specialLoot item (Crucible
    Votive Rack), exercising the `decorID` schema field and the
    `C_HousingCatalog.GetCatalogEntryInfoByRecordID` collection-
    state probe. Shipped in v1.3.0.
  - BFA: Uldir — **DONE.** 8 bosses across three wings (Halls of
    Containment: Taloc, MOTHER; Crimson Descent: Fetid Devourer,
    Vectis, Zek'voz, parallel-three; Heart of Corruption: Zul,
    Mythrax, G'huun), 74 loot items, 18 routing segments with
    parallel-three middle gated on all three branches, eight per-boss
    Glory of the Uldir Raider feat callouts (Elevator Music, Parental
    Controls, Thrash Mouth - All Stars, What's in the Box?, Now We
    Got Bad Blood, Edgelords, Existential Crisis, Double Dribble),
    POI star marker on MOTHER's Titan Console for the Mythrax
    approach. First raid to ship the yell-gated text-only segment
    shape (`advanceOn` with empty `points = {}`), used on MOTHER's
    kill-the-adds pause segment between Brann's "get these doors
    open" voiceline and MOTHER's "decontamination chamber" voiceline.
    Shipped in v1.3.0.
  - BFA: Battle of Dazar'alor — **DONE.** 9 bosses, 95 loot items,
    full faction-asymmetric routing (different entrances, different
    bosses 1-3 names + journalEncounterIDs, different routing paths
    through the same nine boss rooms; Alliance and Horde fight bosses
    2 and 3 in opposite orders against different NPCs). Faction-shared
    achievements (Glory of the Dazar'alor Raider meta + 9 boss criteria),
    mostly-faction-shared loot (Jadefire encounter has 4 swapped items
    named per faction's NPCs), faction-aware specialLoot detection on
    Glacial Tidestorm + G.M.O.D. + 3 Conclave pets. First raid using
    the new `RetroRuns_DataHorde[instanceID]` parallel-table architecture
    for faction-asymmetric data (single global for the 10 symmetric
    raids; parallel global for BfD). First raid using the achievement-
    gated skip mechanism (`skipAchievement` field) for "Bigger Stick
    than Bwonsamdi's" Mythic skip-to-Jaina detection. First raid
    using the strict-activeSeg picker model (Data/BfDPicker.lua,
    dispatch-isolated by instanceID 2070) which replaces the
    layered-gate picker for this raid only -- a single integer
    activeSeg per step, advances on next-expected-mapID match, never
    retreats. Faction-scoped persistent state in
    `RetroRunsDB.bfdActiveSeg[instanceID][faction]`. Heartbeat poll
    closes Blizzard event-timing gaps where ZONE_CHANGED fires before
    `C_Map.GetBestMapForUnit` reflects the new mapID (Loa's Sanctum
    elevator, intra-instance flights). Faction marker `[A]`/`[H]` in
    Alliance blue / Horde red appended to the panel's Raid: line.
    Shipped in v1.6.0.
  - Legion: The Emerald Nightmare — **DONE.** 7 bosses, 57 loot
    items + 1 weapon-enchant illusion (Illusion: Nightmare from
    Xavius), 18 routing segments with hub-and-spoke physical
    structure (mapID 778 Core of the Nightmare as central hub
    between every boss). Four-way parallel middle (Ursoc, Dragons
    of Nightmare, Elerethe, Il'gynoth all gated only by Nythendra)
    plus a multi-prereq AND-clause unblocking Cenarius
    (`requires { 2, 3, 4, 5 }`) -- both a first for the routing
    engine. Account-wide quest-flag skip detection on "The Emerald
    Nightmare: Piercing the Veil" (Shadowlands-style backport
    onto a Legion raid). First raid to use the new `kind = "illusion"`
    specialLoot type with `sourceID` field for transmog API
    validation via `C_TransmogCollection.GetIllusionInfo`. First
    non-BfD raid to use the strict-activeSeg picker -- this
    session generalized the picker dispatch from instanceID-based
    (BfD-only) to flag-based (any raid with
    `useStrictActiveSegPicker = true`), so future linear or
    hub-and-spoke raids can opt in without picker changes.
    Shipped in v1.7.0.
  - Legion: Trial of Valor — **DONE.** 3 bosses (Odyn → Guarm →
    Helya), 27 loot items, 5 routing segments across 3 strict-
    linear boss steps. The 7.1.0 mini-raid bridging Emerald
    Nightmare and Nighthold. Uses the strict-activeSeg picker
    via `useStrictActiveSegPicker = true`. Linear topology with
    mid-instance teleport: Odyn's post-kill dialog drops the
    player into Helheim where Guarm is, then a short walk through
    The Eternal Battlefield reaches Helya. Tier-less data shape
    per Legion artifact-relic-era convention (same as EN). Three
    boss-feat achievements (You Runed Everything!, Boneafide Tri
    Tip, Patient Zero); none are Glory contributors since the
    Glory of the Legion Raider meta covers only EN + Nighthold.
    Shipped in v1.7.1.
  - Legion: Antorus, the Burning Throne
  - Legion: Tomb of Sargeras
  - + others as time allows

---

## 🔲 Planned — Future Milestones

### Settings Expansion
- Mouseover-boost for the panel opacity slider — snap backdrop to
  full opacity when the mouse enters any of the four backdrop windows,
  optionally with a fade animation. Builds on the v1.2 opacity
  slider; would let users set a low ambient opacity without losing
  legibility when they actually look at the panel.
- Separate opacity slider for map-overlay polyline/marker alpha
  (different code path in `MapOverlay.lua`, doesn't share the
  backdrop-color machinery the v1.2 slider uses).
- Toggle for load-raid popup (option to always auto-load)
- Keybind support for panel toggle
- Colour theme options

### UI Polish
- Boss name clickable in progress list (sets as manual target)
- Collapsible sections in the main panel (travel / encounter / achievements / transmog)
- Estimated run time per boss / full raid (based on recorded data)

### Achievement UI (shipped v1.4)

Standalone achievements window with Glory meta headers, per-achievement soloable difficulty indicators, live status refresh, and current-boss highlight. See the Implemented section for details.

### Boss Skip Paths

Modern raids ship with skip quests that, once completed on a character,
unlock teleporters or shortcuts inside the raid that fast-travel past
some bosses. Each is per-character, persists across resets, and is
gated on a quest flag (`IsQuestFlaggedCompleted(<questID>)`).

This breaks into three staged scopes that should ship independently
rather than as one big feature, both because the value-vs-cost ratio
drops sharply between them and because each scope unblocks the next.

**Scope A — Surface existence of skips (cheapest, highest ratio).**
A new boss-level `skipUnlock` field describes the skip in player-facing
terms: which quest unlocks it, what it unlocks, where it drops you.
Renders as a footnote-style block on the relevant boss's view (anchored
to the boss the teleporter exits at, or the boss that drops the gating
item). No quest-flag detection yet, just "this raid has a skip; here's
how to get it." Schema sketch:

    skipUnlock = {
        questID    = 76183,
        questName  = "Forbidden Knowledge",
        unlocks    = "Spark of Dreams teleporter past four bosses",
        from       = "Forgotten Experiments",
        to         = "Sarkareth",
    },

Authoring cost: per-raid Wowhead research to identify quest IDs and
skip mechanics. Engine cost: small renderer addition that surfaces a
footnote when `skipUnlock` is present.

**Scope B — Per-character skip status indicator.** Adds a quest-flag
check at render time and shows ✓ Unlocked / ✗ Not yet on the skip
footnote. Cheap (`IsQuestFlaggedCompleted` is a fresh-query API, no
event hooks needed) and turns the footnote from informational into
functional progress info. Could pair with a yellow `[*]` marker next
to the boss name in the Boss Progress list (same pattern as the `[!]`
marker for special notes), so the player sees skip status at a glance
without opening the boss view.

**Scope C — Re-route around skipped bosses (heavyweight).**
The route engine becomes skip-aware: when a player has the skip quest
completed, the recommended next-boss target shifts and the travel pane
points at the teleporter device instead of walking through the bypassed
bosses. Schema sketch:

    {
        title = "Sarkareth",
        segments = { ... },                    -- existing no-skip route
        skipRoute = {
            requiresQuest = 76183,
            segments = { ... },                -- entrance → teleporter → pull
        },
    },

The route picker checks `IsQuestFlaggedCompleted(skipRoute.requiresQuest)`
and uses `skipRoute.segments` instead of `segments` when truthy.

Knock-on design questions Scope C surfaces:
- Skipped-boss display state: "Skipped" vs "Not killed" — needs a
  visual third state in the Boss Progress list.
- Loot tracking implications: skipped boss is also missed loot.
  Transmog browser still shows it; Boss Progress should communicate
  "you walked past this; come back for loot if you want it."
- Route recovery: if the player teleports past a boss but doubles back,
  does the engine resume the no-skip path mid-way? Probably yes, but
  it interacts with the segment-completion model.
- Authoring cost is real: each skip-affected raid needs the alternate-
  route segments captured via recorder pass through the teleport-active
  path, not just metadata.

A simpler intermediate option that punts on Scope C entirely: add a
`recommendsSkipFor` annotation on relevant boss encounter notes
("You've unlocked the skip; consider teleporting from <X> instead of
walking"). Player gets the prompt at the right moment without changing
the route data structure or engine.

**Recommendation:** ship Scope A+B together as a v1.1 (or v1.2)
feature. Defer Scope C to v1.5 / v2 unless there's clear signal that
walking past skippable bosses is real friction. RetroRuns is a legacy-
raid navigator at level cap; the teleport saves maybe 60 seconds of
walking. The information about "you have this unlocked" is more
valuable than the actual reroute in most cases.

**Known skips to model (research pass needed for quest IDs):**

Modern raids:
- **Aberrus, the Shadowed Crucible**: "We're Doomed" quest chain
  unlocks the Spark of Dreams device that teleports past most of the
  raid.
- **Amirdrassil, the Dream's Hope**: quest chain ending with "Stoking
  the Flames" unlocks a portal in the entrance area to skip past
  Smolderon.
- **Vault of the Incarnates**: "Break a Few Eggs" requires Shard of
  the Greatstaff x3 from Broodkeeper (already noted in Vault's
  Broodkeeper data) and unlocks a teleport to Raszageth.
- **Sepulcher of the First Ones**: skip quest exists with different
  quest IDs for Normal / Heroic / Mythic difficulty. Needs investigation
  to identify quest IDs and which bosses are skippable. Originally
  flagged 2026-04-20.

Older raids:
- **Castle Nathria**: "Getting A Head" — 4 Sludgefist kills on any
  difficulty unlocks a skip that goes directly to Sludgefist via
  General Draven at the raid entrance. Sub-quests for each difficulty
  tier may exist; needs in-game investigation. Originally flagged
  2026-04-21 during CN Phase 3 route recording.
- **Sanctum of Domination**: post-Tarragrue Ebon Blade Acolyte portal
  jumps the left wing (bosses 2-6) and goes directly to the Kel'Thuzad
  wing. Modelable in Scope C via `requires = { 1 }` entries for
  bosses 7/8/9 with lower priority than the linear path.

### Loot Rendering Redesign (Architecture)

**2026-04-21 UPDATE: "Sanctum is single-variant" was wrong. Corrected.**
Previous ROADMAP analysis assumed Sanctum's 98 loot items had one
sourceID cloned across 4 difficulty buckets. In reality, 96 of 98
items have 4 distinct per-difficulty sourceIDs (one per LFR/N/H/M),
each under its own appearanceID. Sanctum and Sepulcher are both
per-difficulty, but differ in API shape: Sepulcher's 4 sources share
one appearanceID; Sanctum's 4 sources each have their own. `ItemShape`
in UI.lua (detects per-item by counting unique non-nil sourceIDs)
correctly handles both.

Current state: every item renders as either a binary `[ ✓ | ~ | X ]`
strip (1 unique source) or a 4-dot `[ LFR | N | H | M ]` strip (2+
unique sources). Shape detection is per-item. This is Variant 5 from
the options below and it's live as of v0.3.0.

**Outstanding architectural questions for post-Nathria:**
- Shared-appearance tagging (Variant 4) not yet implemented. Many
  Sanctum items share appearances across bosses (e.g. Colossus
  Slayer's Hauberk Tarragrue LFR shares appearance 43103 with
  Conjunction-Forged Chainmail Fatescribe LFR). This creates visual
  noise: collecting ONE appearance cascades "shared" (amber) state
  to every sibling item and difficulty pair, producing the so-called
  "amber wall" in Sanctum audit output. **User decision 2026-04-21
  (Photek):** amber wall is fine if it reflects reality (which it
  does). A "treat shared as collected" toggle was considered as a
  way to reduce visual clutter but moves to "won't-do unless user
  demand changes." Shared-appearance information is API-honest; the
  amber state accurately represents "this appearance is collected
  via another item, and you don't need to re-collect it."
- Pre-4.3 raid difficulty scaling: LFR bucket `[17]` didn't exist
  before Dragon Soul. Current clone-across-4 convention papers over
  this. Fine for alpha; revisit when we integrate pre-4.3 content.

**Axes of diversity to cover (not just "LFR/N/H/M vs not"):**
- Difficulty count per era: 4 (SL/BFA/Legion/WoD), 4-with-Flex (WoD),
  3 (Cata/MoP post-4.3), 2 (pre-4.3 Cata, WotLK, but WotLK also has
  10/25 variants per difficulty), 1 (TBC/Vanilla, but 10/25 are
  separate instances in TBC).
- Appearance granularity per item: per-difficulty distinct sources
  (Sanctum, Sepulcher, Legion tier), cross-item shared appearances
  (Sanctum armor sets spread across multiple bosses), single-source
  (pre-MoP, some legendaries like Edge of Night).
- Tier/set system: 4-token class tier sets (Sepulcher-era), no tier
  (Sanctum, WoD), Legion artifact traits, classic tokens (MoP/Cata),
  direct-drop set pieces (Vanilla Tier 1/2/3).
- Special loot API: mounts (C_MountJournal), pets (C_PetJournal),
  toys (C_ToyBox), ensembles (transmog), quest-tracked legendaries,
  achievement-tracked items.
- Wings / modes / skip paths: mostly routing concerns but sometimes
  loot-relevant (Dragon Soul Raid Finder wings).

**Render variants (Variant 5 is live; others preserved for future):**
- (1) Dot count matches source count. `[ • ]` for single-variant,
  `[ • • • • ]` for per-difficulty. Honest, compact, teaches the
  player what the game is actually tracking.
- (2) Label + single dot per difficulty row. Verbose but semantic.
- (3) `[ ✓ ]` or `[ — ]` collection-state indicator with a subscript
  showing difficulty range. Most words on screen.
- (4) Shared-appearance link indicator (flag items whose appearance
  is also owned via another sourceID). Orthogonal to 1/2/3/5;
  composes. NOT YET IMPLEMENTED.
- (5) **CURRENT IMPLEMENTATION.** Single-source items render as
  `[ ✓ ]` / `[ ~ ]` / `[ X ]` bracketed indicator (matching Special
  Loot's visual language); 2+ unique-source items render as
  `[ LFR | N | H | M ]` 4-dot strip. Shape detection per-item via
  `CountUniqueSources`. Items grouped by shape within each boss
  pane (binary first, separator, per-difficulty last, alphabetical
  within each group).

**Out-of-scope but related:** a "collection bestiary" view per raid
that aggregates all appearances into set groupings (the 4 Sanctum
armor-type sets, the 8 Sepulcher tier pieces per class, etc.) instead
of per-item rows. Different view, same underlying data. Worth
considering whether the bestiary view is the primary UX and the
per-item list is secondary.

### Quality of Life
- Auto-open map to correct floor on raid load
- "Copy export" button in recorder output (copies to clipboard)

---

## Version Milestones (Rough)

| Version | Target State                                              |
|---------|-----------------------------------------------------------|
| 0.1.x   | Bug fixes, stability, Sepulcher working end-to-end        |
| 0.2.0   | Per-difficulty transmog tracker with tier support         |
| 0.3.0   | Second raid added (Sanctum of Domination)                 |
| 0.4.0   | Sanctum data-validated end-to-end; AutoSize rendering bug fixed; RetroRunsDB centralization refactor; `/rr tmogverify` diagnostic tool |
| 0.5.0   | Third raid (Castle Nathria) + any broad UX/settings expansion |
| 0.6.0   | Fourth raid (Vault of the Incarnates) + difficulty pills + collapsible Boss Encounter section + route-aware segment completion |
| 1.0.0   | Polished, publicly releasable, 4+ raids with full data    |
| 1.1.0   | Seventh raid (Ny'alotha, the Waking City -- first BfA-era raid) + per-segment POI sizing |
| 1.2.0   | Eighth raid (The Eternal Palace) + yell-trigger framework + sub-zone-aware route gating + panel opacity slider |
| 1.3.0   | Two new raids — ninth (Crucible of Storms, BfA mini-raid) and tenth (Uldir, the BfA opener with the parallel-three middle) + first shipped housing decor item with collection state via `C_HousingCatalog.GetCatalogEntryInfoByRecordID` + `decorID` schema field on specialLoot rows + gray-on-collected rendering for specialLoot rows (matches achievement renderer's de-emphasis precedent) + footer reserve fix to give the Boss Progress list breathing room above the action button row + first use of yell-gated text-only segment shape (`advanceOn` with empty `points = {}`) for MOTHER's add-killing pause |
| 1.4.0   | Achievements standalone window with Glory meta headers, mount reward links, soloable difficulty indicators, live-refresh, current-boss highlight, and mutex auxiliary window behavior + new `revealAfter` per-segment gating field paired with the existing `advanceOn` (yell trigger) and `requiresSubZone` mechanisms + numbered-waypoint label suppression when only one seg renders + Eranog routing converted from three-way `renderAllSegments` numbered mode to a two-phase yell-gated route (pre-flight dragon stub alone, post-landing two numbered lines on Raszageth's "skies are mine to control" yell) + panel-position fix at non-default Window Scale (corrected `fscale`-vs-`pscale` divisor in `SetPoint("CENTER", ...)` offset math eliminates drag-jump-on-release and BfA-toggle leftward drift) + idle-panel BfA-expansion downward-growth fix |
| 1.5.0   | One-click entrance navigation — per-raid entrance coords across all 10 supported raids, four-tier dispatch (Zygor → Mapzeroth → TomTom → Blizzard) with tier-aware button alpha and adaptive footer legend, plus a "Waypoint set" toast on the silent fallback tiers. Routing-addon legend renders as a `[ Zygor \| Mapzeroth ]` pill bar with the active router lit in its brand color and the inactive dimmed to gray. Redesigned route lines on the World Map: pink polylines now carry directional cyan chevrons at fixed pixel stride, with a cyan-fill / pink-border end-triangle replacing the prior generic destination icon. New in-Settings shortcut buttons next to Defaults: pink beetle icon → GitHub Issues copy popup; cyan chat-bubble icon → CurseForge comments copy popup. Both pop a Wowhead-style single-line EditBox for Ctrl+C → paste-into-browser flow. EJ encounter-info cache fix (`EJ_SelectInstance` precondition + don't-cache-empty-results) resolves the v1.4.0 difficulty-pill regression where every raid showed `[ LFR - \| N - \| H - \| M - ]` instead of kill counts. Idle-panel polish pass: three-state filled/dim/invisible skip-status leading star replacing the `* ` bullet, single-expand accordion behavior on expansion toggles, and legend block repositioned to a fixed bottom-of-panel anchor above the action row at a smaller fixed font. |
| 1.6.0   | Eleventh raid: Battle of Dazar'alor with full faction-asymmetric handling (parallel `RetroRuns_DataHorde[instanceID]` table dispatched by `UnitFactionGroup`, separate Alliance and Horde routing through the same nine boss rooms, faction-shared achievements + mostly-faction-shared loot with 4 swapped Jadefire items, faction marker `[A]`/`[H]` in faction colors on the Raid: line). New `skipAchievement` schema field for achievement-gated raid skips ("Bigger Stick than Bwonsamdi's" Mythic skip-to-Jaina, the first such skip the addon recognizes). New strict-activeSeg picker (`Data/BfDPicker.lua`) dispatch-isolated to instanceID 2070 — replaces the layered-gate picker (requiresSubZone / gateBySubZone / revealAfter / revealAfterMapVisit / useStrictSegOrdering) for BfD only; single integer activeSeg per step, advances one seg at a time on next-expected-mapID match, never retreats. Faction-scoped persistent state (`RetroRunsDB.bfdActiveSeg[instanceID][faction]`) with auto-migration from a pre-faction-scoped legacy shape. Heartbeat poll closes Blizzard event-timing gaps where `ZONE_CHANGED_INDOORS` fires before `C_Map.GetBestMapForUnit` reflects the new mapID (Loa's Sanctum elevator, intra-instance pterrordax/gryphon flights). AzerothWaypoint integration on the entrance buttons: AWP detected → routes via `_G.AzerothWaypointNS.RequestManualRoute` (hands off to AWP's backend planner — Zygor / Mapzeroth / Farstrider — for full step-by-step), AWP without backend behaves like a single TomTom waypoint; footer pill bar extended to `[ AWP \| Zygor \| Mapzeroth ]` with brand-colored multi-pill activation. Auto-stamp recorder feature (`Recorder.lua` listens for ENCOUNTER_END / PLAYER_CONTROL_LOST/GAINED to capture player physical mapID instead of visible-map mapID; pending-event queue persists across reloads via `RetroRunsDB.recorderPendingEvent`; `LogRecorderSession` writes to `RetroRunsDB.recorderSessionLog` capped at 2000 entries; Mark Destination + Session Log buttons on DevTools panel for cases where the auto-stamp doesn't fire e.g. scripted in-instance flights). Em-dash byte-sequence fix (Lua 5.1 doesn't support `\xNN` hex escapes; in-game render produced literal `xE2x80x94` glyphs instead of the em-dash on BfD's Mythic-only difficulty cells in the Skips window — only path that emitted that constant; rebuilt via `string.char(0xE2, 0x80, 0x94)`). Faction-aware browser dispatch (Tmog + Achievements via `GetRaidByInstanceID` resolves to the faction-correct table). Subtle brightness pulse on the `[!]` view-special-note marker (16-step cosine breathing curve over 1.6s, full-bright down to ~70% RGB and back, only pulses while the encounter section is collapsed and the boss has a custom soloTip). |
| 1.7.0   | Twelfth raid: The Emerald Nightmare (first Legion raid). 7 bosses, 57 loot items, 18 routing segments. Hub-and-spoke physical structure (mapID 778 Core of the Nightmare central between every boss). Four-way parallel middle (Ursoc, Dragons, Elerethe, Il'gynoth all gated only by Nythendra) plus a multi-prereq AND-clause unblocking Cenarius (`requires { 2, 3, 4, 5 }`) — both routing-engine firsts. New `kind = "illusion"` specialLoot type for weapon-enchant illusions (Illusion: Nightmare from Xavius), with `sourceID` field for transmog API validation via `C_TransmogCollection.GetIllusionInfo`. Picker generalization: the strict-activeSeg picker dispatch (formerly BfD-only via `instanceID == 2070`) is now flag-based (`useStrictActiveSegPicker = true` on the raid data table); EN opted in, future linear or hub-and-spoke raids can opt in without picker changes. Identifier rename pass: `bfdActiveSeg` → `strictActiveSeg` across `state` and `RetroRunsDB`, `Get/Set/Advance/Seed/RestorePersisted/Pick BfDActiveSeg/NoteSeg/LineSegs` → `*StrictActiveSeg/*StrictNoteSeg/*StrictLineSegs`, `/rr bfdstate` → `/rr pickerstate`. Recorder stops emitting `gateBySubZone = true` on auto-stamped segs for strict-picker raids (the strict picker fixes the same transit-flash bug class by design, so the field would be dead data). Three picker bug fixes: (1) lockoutId nil-degeneracy — the picker was reading `self.state.lockoutId` which nothing ever wrote, causing the lockout-reset comparison to silently pass on `nil == nil` and stale activeSeg state to leak across sessions; replaced with direct `GetCurrentLockoutId()` API calls plus a defensive nil-lockout-clear on restore for self-healing on already-corrupted persistence. (2) Missing `kind = "illusion"` branch in `SpecialCollectionStateForItem` — adding a new specialLoot kind requires updating three coupled sites (`VALID_SPECIAL_KINDS` allowlist, tmogverify dispatch, AND collection-state lookup); first-pass missed the third. (3) Il'gynoth ENCOUNTER_END kill-name alias — Blizzard fires the event with `"Il'gynoth, The Heart of Corruption"` (with "The") but the journal title omits "The"; without the variant aliased, the kill never registered in `bossesKilled` and Cenarius never surfaced. Minimize / maximize on the main panel — `-` button left of the close X collapses the panel to its title bar (logo + RETRO RUNS text + close + minimize buttons), hiding all body content (raid info, route note, supported-raids list) and the action-button row (Map, Tmog, Achieves, Skips, Settings); click the `+` to expand back. Top edge stays put across the resize via the same TOP-PIN math `UI.AutoSize` uses (panel grows downward from the title bar rather than shifting up). State persists across `/reload` via the `minimized` setting in `RetroRunsDB`, parallel to `panelX`/`panelY`/etc. (unlike `showPanel` which is force-reset to `false` on init). Implementation: new `UI.IsMinimized` / `UI.SetMinimized(value)` / `UI.ApplyMinimizedState` triplet in `UI.lua`, with `UI.AutoSize` early-returning when minimized so subsequent `UI.Update` calls don't override the fixed minimized height (`MINIMIZED_PANEL_H = 44`). Body-element inventory walks both static (`panel.raid`, `panel.pills`, footer action buttons, etc.) AND dynamic (`panel.idleListLines`, `panel.idleListLegendLines`, `panel.expansionToggleButtons`, `panel.entranceButtons`) FontString/Button arrays so newly-acquired items from `RefreshIdleList` correctly inherit the minimized visibility — the `ApplyMinimizedState` call is at the END of `UI.Update` (replacing the trailing `AutoSize` call, which it delegates to when expanded) so it runs after `RefreshIdleList` has populated the dynamic arrays. `SetMinimized` triggers a full `UI.Update` so body-content visibility state (e.g. `encounter`/`transmog` explicitly `Hide()`'d in idle state) is re-asserted correctly when maximizing — without this, those elements would briefly un-hide and flicker until the next heartbeat tick. Test-mode label moved from `TOPRIGHT -34,-14` to `TOPRIGHT -64,-14` to clear the new minimize button's hit area at `TOPRIGHT -38,-8` (close button's `UIPanelCloseButton` template occupies `TOPRIGHT -4,-4` through `right-36`). Custom button rather than a Blizzard template (no stock minimize template exists; `UIPanelCloseButton` is the only built-in title-bar control glyph). ASCII `-`/`+` glyphs only — WoW's bundled fonts have spotty Unicode coverage and a tofu box on a title-bar control would look broken. |
| 1.7.1   | Thirteenth raid: Trial of Valor (second Legion raid; the 7.1.0 mini-raid bridging Emerald Nightmare and Nighthold). 3 bosses (Odyn → Guarm → Helya), 27 loot items, 5 routing segments across 3 strict-linear boss steps. Uses the strict-activeSeg picker via `useStrictActiveSegPicker = true` (introduced in v1.6.0, generalized in v1.7.0). Linear topology with mid-instance teleport: Odyn's post-kill dialog drops the player into Helheim where the Guarm fight is, then a short walk through The Eternal Battlefield reaches Helya. World-map dropdown serves three entries (two "Trial of Valor" entries for the Odyn and Guarm wings, one "Helheim" entry covering the Guarm room and Helya wing); both Odyn and Guarm wings share the "Trial of Valor" label and disambiguate by mapID (807 Odyn / 806 Guarm-approach / 808 Helheim). Tier-less data shape per Legion artifact-relic-era convention (`tierSets = { labels = {}, tokenSources = {} }` matches every other tier-less raid); ATT cross-reference (`inst(861, ...)`) confirmed 27 armor s()-items exact match with shipped data, 14 artifact-relic weapon i()-items correctly skipped (no sourceID = no transmog appearance), zero mounts/pets/toys. Three boss-feat achievements (You Runed Everything!, Boneafide Tri Tip, Patient Zero) — none Glory contributors (Glory of the Legion Raider meta covers only EN + Nighthold, not ToV). Bug fix: the "+" expansion-toggle buttons on the supported-raids list (idle and run-complete states) now respond consistently to clicks. Root cause: the UI heartbeat's 1-second `RefreshIdleList` rebuild was tearing down and re-creating toggle Buttons via `ReleaseExpansionToggleButtons` → `btn:Hide()` on every tick, regardless of whether the rendered state had actually changed. Clicks whose `OnMouseDown` landed before a heartbeat but `OnMouseUp` would have landed after got eaten — the Button vanished mid-click and `OnClick` never fired. Symptom: spam-clicking a "+" only registered intermittently, more often the closer the click rate matched the 1Hz tick. Fix: fingerprint-gate `RefreshIdleList`. Build the row list first (pure data, cheap), serialize a stable string fingerprint, compare against last render. If unchanged, short-circuit the entire Release+rebuild — on-screen widgets are still correct. New `UI.InvalidateIdleListCache()` hook called only from font/scale slider OnValueChanged handlers (settings changes affect render but not row data, so fingerprint alone wouldn't catch them). Heartbeats with no state change now become no-ops for the idle list. Two false-fix iterations along the way: (1) `panel.transmog:EnableMouse(false)` parity in run-complete branch (defensible parity with idle but not actually the cause), (2) the same `InvalidateIdleListCache` initially wired into `UI.ApplySettings` which runs at the top of every `UI.Update` — completely defeating the cache by invalidating every heartbeat. The mistake was added as defensive belt-and-suspenders; instead it broke the actual mechanism. |
