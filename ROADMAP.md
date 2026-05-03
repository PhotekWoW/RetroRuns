# RetroRuns — Roadmap & Feature Tracker

## Current Version: 1.2.0

---

## ✅ Implemented

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
- Numbered map waypoints — for steps using `renderAllSegments=true`,
  the World Map overlay labels each rendered segment endpoint with
  a numeral (1, 2, 3...) for player self-pacing through routes that
  can't be auto-advanced (e.g. Vault of the Incarnates' Eranog mini-
  boss walk-past, Eternal Palace's Orgozoa teleport-pad room). The
  numbering reflects render-order on the current map, so it stays
  contiguous from 1 even when the step contains instruction-only or
  cross-map segments that don't render.
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

### Achievement UI (target: v1.3)

Today, achievements render as a flat list under the Boss Encounter
section with collected/uncollected state and the achievement name.
There's no per-achievement detail surface and no soloing-difficulty
information. Many older raid achievements have known solo gotchas
(can't be soloed at all, requires a specific difficulty, requires a
specific class/spec, requires a non-obvious sequence) that the current
flat list can't communicate.

Planned shape:

- **New standalone window**, similar style to the Tmog and Raid Skips
  windows. Per-achievement detail panel with `soloAchievement` tip text
  authored verbatim by the player who's actually soloed each one,
  rendered alongside the achievement name + collected state.
- **Per-achievement flags** in the data file: `cannotBeSoloed = true`
  for achievements that genuinely require a group, `requiresDifficulty
  = "Mythic"` (or LFR/Normal/Heroic) for achievements that only credit
  on a specific difficulty.
- **Main UI integration**: a yellow `[?]` clickable affordance next to
  achievement names that have soloing notes, opening the relevant
  detail in the new window. A 5th button in the panel's action-bar row
  (currently Map / Tmog / Skips / Settings) opens the achievement
  window directly.
- **Tip text authoring**: same verbatim-only rule as soloTips. The
  framework / window / data fields ship first; tip text is filled in
  per-achievement as the project owner solos each one and dictates
  notes.

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
