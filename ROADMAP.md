# RetroRuns — Roadmap

This is a forward-looking document: what's coming next, what's planned, and what's still in idea form. For what's already shipped and historical context, see [CHANGELOG.md](CHANGELOG.md).

## Current Version: 1.8.0

---

## 🚀 Upcoming

Work targeted for the next release.

### Raid Support
- **Legion: Tomb of Sargeras** — 9 bosses, Pantheon trinkets, the Sisters / Mistress / Avatar of Sargeras / Kil'jaeden chain.
- **Legion: Antorus, the Burning Throne** — 11 bosses, the final Legion raid, Argus the Unmaker.

---

## 📋 Planned

Committed for a future release, not yet started.

### Boss Progress section collapse
Add `+` / `-` collapse treatment to the Boss Progress section in the main panel, mirroring the existing Boss Encounter section's collapse behavior. Persist state across `/reload`. Pairs with a tightening pass on the blank space between the last boss row and the action button row (`UI.lua`'s `AutoSize` has a hardcoded 50px cushion that should shrink or scale to content).

### Collapsible sections in main panel
Broader version of the Boss Progress collapse: travel pane, encounter section, achievements summary, and transmog summary each get individual `+` / `-` controls so the user can dial in their preferred density. Focus on Boss Progress first (above) before expanding.

### Compact view / smaller-footprint mode during a raid run
An alternate panel layout with reduced vertical real estate while in an active raid run. Open design questions to elicit before building: what must stay visible (multi-select among current step + travel note, travel pane, boss section, kill pills, transmog button), how the toggle fires (setting, button, both), and form factor (horizontal strip, vertical column, icon-driven).

### "What's New" surface on the idle panel
Present recent-version highlights or changelog-summary content on the main panel during idle state (out of raid) so version updates surface organically. Design questions to settle before building: where on the panel does it live, what triggers dismiss, what's the data source (hand-authored per-version blurbs, auto-generated from CHANGELOG, or a separate file), and how long an entry stays "new."

---

## 💭 Thinking About

Ideas worth keeping but no commitment yet.

### Boss Skip Paths
Modern raids ship with skip quests that unlock teleporters inside the raid. The addon already detects whether a skip is unlocked on the current character (per-character quest-flag check) and surfaces this in the Skips window and as the leading-star indicator on each raid row. The open question is whether to make the route engine *skip-aware* — re-routing the recommended next-boss target through the teleporter when the player has the skip unlocked, with a "Skipped" third-state in the Boss Progress list and loot-tracking implications for bosses the player walked past. Value-vs-effort is the open question: the teleport saves maybe 60 seconds of walking on a legacy raid, so the information about "you have this unlocked" may be more valuable than the actual reroute.

### Recovery Paths
After a death or extended logout, navigate the user back to where they were in the raid via raid-specific recovery waypoints. Useful when WoW drops the player at the graveyard or instance entrance and they have to retrace their steps. Requires per-raid authoring of "from entrance, how do you get back to <last-killed-boss>'s position" routes, plus engine support for "you're behind your kill progress, here's how to catch up."

### Running raid timer
Display a stopwatch for the active raid run — elapsed time since zoning in, persists across `/reload` until the run ends (either all-bosses-killed or zoning out). Whole-raid timer only, not per-boss.

### Mouseover-boost panel opacity
Snap backdrop alpha to full opacity when the mouse enters any of the four backdrop windows (main, transmog, raid skips, settings), optionally with a fade animation. Lets the user set a low ambient opacity without losing legibility when they actually look at the panel.

### Color theme options
Alternate color palettes for the panel and map overlay (the current pink/cyan brand is fixed). Would need to define which surfaces are themed (logo + map lines + headers + accents) vs which stay neutral.

---

## See also

- **[CHANGELOG.md](CHANGELOG.md)** — what's shipped, version by version, in customer-facing voice
- **[README.md](README.md)** — what RetroRuns does today, installation, getting started, supported raids
