-------------------------------------------------------------------------------
-- RetroRuns -- WhatsNew.lua
-- Player-facing release notes for the "What's New?" window.
-------------------------------------------------------------------------------
-- Last-N release entries shown to players when they click the version link
-- in the main panel footer. Hand-maintained at ship time: when CHANGELOG.md
-- gains a new release, prepend a matching entry here and drop the oldest
-- if the list exceeds the display target (currently 5 versions; the
-- window is scrollable so longer note sets fit).
--
-- Voice matches CHANGELOG.md (player-facing, no internal jargon, no
-- developer-facing implementation detail). Most entries are direct lifts
-- from the corresponding CHANGELOG block; the structured form here is
-- what the WhatsNew window's renderer consumes.
--
-- Schema per entry:
--   version  - the version string, no leading "v"
--   date     - ISO date string (YYYY-MM-DD), matches the CHANGELOG date
--   sections - ordered array of sections. Each section is:
--                { heading = "Added"|"Fixed"|..., bullets = { "text", ... } }
--              "heading" matches the H3 used in CHANGELOG ("### Added" etc.).
--              Bullet text may contain WoW color codes; **markdown bold** is
--              rendered as bright white inline via the renderer.

local RR = RetroRuns
RR.WhatsNew = {
    {
        version  = "1.14.0",
        date     = "2026-06-13",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Skip routes for every raid that has a skip shortcut.** All sixteen raids with an in-raid skip now have a full route, guiding you from the entry boss through the shortcut straight to the end bosses, with map markers and circles for the NPCs, portals, and runestones that open each one. Where a raid has more than one skip destination, the route covers the furthest, and the Skips window notes which one is built. When you open a raid with a skip available, the load dialog's SKIP option names the destination boss; raids with no skip read \"N/A,\" and skips that exist only on Mythic read \"Mythic only.\"",
                    "**An exit note now appears after the final boss** for raids that have one, with an exit icon, telling you how to get back out: a teleport NPC, a portal, or a jump that sends you to the exit.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The action buttons are now neon icons** (Map, Tmog, Achieves, Skips, Settings) instead of text, brightening on hover with the button's name shown above it.",
                    "**The window's title bar and control buttons were restyled** with the neon theme, and the close and minimize buttons are now matched in size. The minimized bar's spacing was tightened.",
                    "**The Map button now works anywhere**, opening the world map to your current location when you're not on an active route step, instead of being greyed out.",
                    "**Smaller completion stars on the idle panel.**",
                    "**Mounts, pets, toys, and housing decor now show as Special** in the loot summary line when you loot them, alongside appearances and vendor-grade, instead of being miscounted as vendor-grade.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Loot toasts cascade consistently** from top to bottom when several appear at once, instead of occasionally stacking out of order.",
                    "**A duplicate pet or mount you already own no longer pops a \"new collection\" toast** when you learn it.",
                    "**The \"Run complete!\" screen now opens with all expansions collapsed**, instead of leaving an expansion open from earlier.",
                },
            },
        },
    },

    {
        version  = "1.13.0",
        date     = "2026-06-09",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**All five Mists of Pandaria raids are now fully supported: Mogu'shan Vaults, Heart of Fear, Terrace of Endless Spring, Throne of Thunder, and Siege of Orgrimmar.** Each has complete routing through every encounter with travel notes and map lines for every leg, including the portals, teleports, and tower and door transitions between sub-zones. Per-boss loot is tracked alongside tier set tokens and other unique drops, and each raid's Glory meta-achievement sub-achievements are rated for solo difficulty. Where a raid has skip paths, those are tracked too.",
                    "**Mists of Pandaria raids show a lockout indicator on their difficulty pills.** Mogu'shan Vaults, Heart of Fear, Terrace of Endless Spring, and Throne of Thunder share a single lockout between their Normal and Heroic difficulties for the week -- clearing a boss on one locks the other until reset. When one difficulty is committed, its sibling now shows a small lock glyph; hovering it explains that the other difficulty is unavailable until the weekly reset.",
                    "**New feature: Toaster.** A loot notification system built for solo legacy-raid running. When you loot a boss, Toaster pops a clean on-screen toast for the things that matter -- new transmog appearances and special loot like mounts, pets, and toys -- while everything else (gear you'll vendor, crafting mats, tier tokens) is rolled into a single tidy summary line in chat with a clickable option to expand the full list. It replaces Blizzard's scattered loot spam with one consolidated line per kill. Its own settings page lets you toggle the toasts and the loot summary independently, adjust the toast scale, and drag the toasts wherever you want them.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The main window has a new look.** The panel and its minimized title bar now use a custom themed frame with ornate corners and a glowing trim, replacing the plain default border, and section dividers match the new style.",
                    "**Settings have moved into the standard interface options.** RetroRuns' settings now live in the game's own Settings window under the AddOns section, alongside every other addon, instead of a separate standalone panel.",
                    "**Tier set pieces now sort to the top of the transmog browser** and are grouped by class rather than listed alphabetically, so your set pieces are together and easy to find.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Archimonde's loot in Hellfire Citadel** is no longer shown as Normal-only in the transmog browser; its difficulty availability now displays correctly.",
                    "**Hellfire Citadel no longer shows special loot in the transmog browser** where it doesn't belong.",
                    "**The transmog browser sizes itself correctly to its contents** when opened.",
                    "**Removed an empty gap at the bottom of the main window.**",
                },
            },
        },
    },

    {
        version  = "1.12.0",
        date     = "2026-05-29",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Three Warlords of Draenor raids are now fully supported: Highmaul, Blackrock Foundry, and Hellfire Citadel.** Each has complete routing through every encounter with travel notes and map lines for every leg, including the portal and teleport transitions between sub-zones. Per-boss loot is tracked alongside the special weapon-enchant illusions and other unique drops, and each raid's Glory meta-achievement sub-achievements are rated for solo difficulty. Where a raid has skip paths, those are tracked too.",
                    "**The Skips window is now collapsible by expansion.** Each expansion is a header you can expand or collapse with the +/- button beside its name, matching how the supported-raids list on the main panel works. When you're inside a raid, that raid's expansion opens automatically so its skip status is visible right away; everything else stays collapsed until you open it.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**Boss Progress list order.** The in-raid Boss Progress checklist now lists bosses in the order RetroRuns routes you to them, rather than the Encounter Journal's default order. For most raids these match, but where the recommended kill order differs from the Journal, the list now lines up with the travel directions. This is adjustable in Settings if you prefer the Encounter Journal order.",
                    "**Double-skip raids show two skip indicators.** Raids with two independent skip paths (Antorus the Burning Throne and Hellfire Citadel) now show one diamond per path next to the raid name, each lit or dimmed based on whether that specific skip is unlocked, instead of a single combined indicator.",
                    "**Skips window close button and layout.** The window now closes with an X button in the top-right corner instead of an OK button, and the skip-detail popout no longer wraps its text awkwardly.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Transmog browser scaling on open.** The window now respects your saved window-scale setting from the moment it opens, instead of briefly rendering at 100% and then snapping to the correct size.",
                    "**Transmog browser \"missing\" indicator.** Items you've collected the appearance for but don't own are now marked with a red X that matches the size of the green check, so the status indicators line up cleanly down the column.",
                    "**Transmog browser bottom spacing.** The window's auto-sizing was leaving a sliver of empty space at the bottom; that gap is now reclaimed so the window fits its content.",
                    "**Settings panel height on first open.** The settings window could open far too tall on the first login of a session, correcting itself only after being moved. It now sizes correctly the first time it opens.",
                    "**Boss Progress checklist alignment.** The brackets next to each boss name (current, killed, upcoming) now line up consistently regardless of font size.",
                },
            },
        },
    },

    {
        version  = "1.11.0b",
        date     = "2026-05-26",
        sections = {
            {
                heading = "Changed",
                bullets = {
                    "**LFR support has been removed from the in-raid panel and from per-difficulty kill pills.** Until now, RetroRuns treated LFR as just another difficulty alongside Normal, Heroic, and Mythic -- same routing, same boss progress, same pill row. That assumption was incorrect. LFR splits each raid into multiple wings, each with its own boss subset and its own path through the instance; the routing data RetroRuns ships is authored for the full N/H/M layout and doesn't match any single wing. Players in LFR were seeing routing directions toward bosses that don't exist in their current wing, and pill counts that summed kills across all wings of the lockout. For now: when you zone into LFR, the in-raid panel shows a single message in place of the routing content, and LFR has been dropped from the pill row everywhere it appeared. Achievements and Transmog browsers continue to track LFR sources unchanged. Restoring full LFR support is a substantial project -- per-wing routing data for nearly every raid, queueing-NPC entrance handoffs for each expansion's LFR access point, and per-wing lockout tracking -- and it will land in a future release as a dedicated effort.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**The \"What's New?\" window no longer overflows past its bottom edge.** Long release-note entries are now contained inside a scrollable viewport; the window itself stays a fixed height and a scrollbar appears on the right when there's more content to read.",
                    "**Castle Nathria weapon-token section: redesigned for clarity.** The \"Main-Hand Weapons\" / \"Off-Hand Weapons\" lines used to carry a bracketed [some collected] / [all collected] / [none collected] label, but \"some\" gave the player no actionable signal about what they still needed. Each line now reads as a section heading naming the slot, the word \"Weapon Token\", and the classes that family covers -- e.g. \"Main-Hand Weapon Token: Hunter / Mage / Druid\". Bosses that drop tokens for every class in a slot (Sire Denathrius) show \"All classes\" instead of listing all 13. The redemption-vendor hint and its travel button now sit directly below the heading rather than below the color legend, so the boss -> redemption -> legend flow reads top-to-bottom in priority order.",
                },
            },
        },
    },

    {
        version  = "1.11.0a",
        date     = "2026-05-26",
        sections = {
            {
                heading = "Fixed",
                bullets = {
                    "**Vault of the Incarnates -- Eranog route on the map.** After landing from the dragon flight, the pink route lines could partially disappear or the end arrow could detach from the rest of the path. Eranog's approach has been redesigned with red destination circles at the dragon platform and at Volcanius, plus a clean arrow line up to Eranog.",
                },
            },
        },
    },

    {
        version  = "1.11.0",
        date     = "2026-05-26",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Map markers and labels.** Points of interest on the world map can now carry a text label next to the icon -- useful for one-time interactive objects like teleport orbs, consoles, runes, and entrance arches that aren't obvious from a dot alone. Labels position around the icon to avoid colliding with map art, and can pulse gently while a click is pending, then switch to gray with a green check the moment the interaction completes. Red rings now highlight specific named map exits along a route. Star markers call out specific clickable objects. Visual cues like these have been added across several raids where the routing benefits from a more concrete pointer than a path line.",
                    "**Zygor waypoint-arrow detection.** If Zygor is loaded but the waypoint arrow is disabled in your Zygor settings, the entrance legend below the raid list now shows a red \"Waypoint Arrow Disabled -- Click to Enable\" warning. Clicking the warning flips the Zygor setting on for you.",
                    "**Suicide-jump shortcuts.** Several raids include ledge-jump shortcuts that skip a chunk of walking; travel notes now call these out where applicable.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The travel-route navigation system has been rebuilt from the ground up.** Rolled out across all 17 supported raids. Map lines and travel directions follow you correctly when you backtrack to an earlier step's area instead of getting stuck on the latest step. Same-subZone cross-zone transitions advance cleanly without a transient flicker. Fewer \"Open the map and select a section...\" default-text flashes during zone transitions. Yell-triggered step advances now survive a mid-raid logout or reload -- both the advance memory and your step progress persist alongside the rest of your lockout, so reloading mid-step no longer rewinds your travel directions.",
                    "**Special Loot, Achievements, and Skips brackets are now visually aligned.** The \"not collected / not done / not unlocked\" red X is now a proper texture matching the size of the green check, so the brackets line up cleanly instead of the X reading narrower than the check.",
                    "**Per-difficulty kill-count pills now use the Boss Progress color palette.** Fully cleared difficulties (e.g. `M 8/8`) render in green, your active difficulty renders in yellow, and the rest render in gray -- matching the green-check / yellow-arrow / gray-pending grammar already used by the in-raid boss checklist below. A player sitting in a fully cleared difficulty sees green (complete trumps active).",
                    "**Uldir achievement soloability ratings refreshed.** Edgelords (Zul) and Existential Crisis (Mythrax) both moved from \"kinda\" to \"yes\" based on recent solo-run reports -- Edgelords needs only that you avoid the central square, and Existential Crisis's \"no other player touches an Existence Fragment\" condition is satisfied for free when you're solo.",
                    "**Solo strategy tips refreshed across several encounters.** Shorter, more direct, dropping mythic-only and class-specific caveats that weren't useful for solo runs.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Action buttons no longer occasionally appear with blank labels at game launch.** The Map / Tmog / Achieves / Skips / Settings buttons along the bottom of the panel previously used the addon's pixel font, applied with a direct font call that could fail on a cold startup if the font file wasn't fully cached yet -- leaving one of the buttons blank until a `/reload`. They now use the standard interface button font and render reliably on every launch.",
                    "**Zygor flight buttons no longer silently do nothing.** When Zygor's waypoint arrow setting was disabled, the addon's entrance click-to-navigate buttons were calling Zygor's waypoint API but Zygor was silently dropping the call. The new detection (above) surfaces this state and offers a one-click fix.",
                },
            },
        },
    },
}
