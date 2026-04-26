# RetroRuns — Roadmap & Feature Tracker

## Current Version: 0.6.1 (Beta — v1.0 release candidate)

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
- Test mode (`/rr test` / `/rr next` / `/rr real`)
- Manual kill overrides (`/rr kill` / `/rr unkill`)
- Data validation on load (debug mode)
- Saved panel position (persists across sessions)
- Font/scale settings panel (sliders display current values live:
  "Font Size: 14" / "Window Scale: 1.00x")
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
  transmog popup below the per-difficulty armor rows. Does NOT
  claim a denominator — see HANDOFF 2026-04-22 session summary
  for the covenant-partitioning investigation that ruled out
  ratio-based display.
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
- Setup workflow:
  1. Recorder: walk routes → `/rr record dump` → paste
  2. Tier discovery: `/rr tiersets` → paste
  3. Loot harvest: `/rr harvest` → paste
  (Order between tiersets and harvest is immaterial; both run against the
  skeleton data file.)
- Target raids (rough priority order):
  - Shadowlands: Sanctum of Domination — **DONE.** Full skeleton +
    98 items + 6 collectibles + 10/10 routes shipped. `tierSets`
    intentionally empty (9.1 predates proper class tier sets). Open
    follow-ups in HANDOFF (Sylvanas mapID unverified, Tarragrue
    travel-note nit, optional re-harvest validation).
  - Castle Nathria — **DONE.** Skeleton + 10 bosses + armor-shape
    loot + 10 routes + achievements + specialLoot detection +
    weapon-token 3-state indicator + covenant-aware vendor hint.
    Weapon-token data modeling intentionally scoped to 3-state
    (none/some/all collected) rather than X/N ratio after vendor-
    scan investigation revealed the pool is covenant-partitioned
    in a way our harvested TTT-derived data doesn't capture. See
    HANDOFF's 2026-04-22 session summary for the full investigation
    trail and why per-covenant data is deferred indefinitely.
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
  - BFA: Ny'alotha, The Waking City
  - BFA: Eternal Palace
  - Legion: Antorus, the Burning Throne
  - Legion: Tomb of Sargeras
  - + others as time allows

---

## 🔲 Planned — Future Milestones

### Settings Expansion
- Toggle for load-raid popup (option to always auto-load)
- Keybind support for panel toggle
- Colour theme options

### UI Polish
- Boss name clickable in progress list (sets as manual target)
- Collapsible sections in the main panel (travel / encounter / achievements / transmog)
- Estimated run time per boss / full raid (based on recorded data)

### Boss Skip Paths (Architecture)

Several raids have alternate routing: "complete quest X and you can
skip bosses Y-Z via portal/teleporter." Current `routing[]` schema
supports this via multiple entries per bossIndex with different
`requires` and `priority` values, but we haven't exercised it yet.

Known skips to model:
- **Castle Nathria**: "Getting A Head" — 4 Sludgefist kills on any
  difficulty unlocks a skip that goes directly to Sludgefist via
  General Draven at the raid entrance. Sub-quests for each difficulty
  tier may exist; needs in-game investigation. Flagged by Photek on
  2026-04-21 during CN Phase 3 route recording.
- **Sepulcher of the First Ones**: skip quest exists with different
  quest IDs for Normal / Heroic / Mythic difficulty. Needs investigation
  to identify quest IDs and which bosses are skippable. Flagged by
  Photek on 2026-04-20.
- **Sanctum of Domination**: post-Tarragrue Ebon Blade Acolyte portal
  jumps the left wing (bosses 2-6) and goes directly to the Kel'Thuzad
  wing. Modeled by adding `requires = { 1 }` entries for bosses 7/8/9
  with lower priority than the linear path.

Unblocks when: routing-skip user story lands as a concrete request
(e.g. Photek wants to skip bosses on a specific run and asks "why is
it still sending me to boss 3?"). Not blocking for Sanctum alpha.

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
