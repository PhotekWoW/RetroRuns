-------------------------------------------------------------------------------
-- RetroRuns -- WhatsNew.lua
-- Player-facing release notes for the "What's New?" window.
-------------------------------------------------------------------------------
-- Last-N release entries shown to players when they click the version link
-- in the main panel footer. Hand-maintained at ship time: when CHANGELOG.md
-- gains a new release, prepend a matching entry here and drop the oldest
-- if the list exceeds the display target (currently 3 versions; the
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
}
