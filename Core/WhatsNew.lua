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
        version  = "2.1.0",
        date     = "2026-07-06",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**The Cataclysm raids join RetroRuns.** All six now have full routing and transmog tracking: Baradin Hold, Blackwing Descent, The Bastion of Twilight, Throne of the Four Winds, Firelands, and Dragon Soul. Dragon Soul includes both Raid Finder wings, The Siege of Wyrmrest Temple and Fall of Deathwing, with per-wing routing and loot.",
                    "**The transmog browser can filter by class.** A class dropdown replaces the old show-all-tier toggle: pick any class to see only the gear it can collect, or choose \"All classes\" to see everything. It defaults to your own class, and shows as unavailable on bosses that drop no class-restricted gear.",
                    "**Hovering a raid in the supported-raids list shows how its lockout works.** A tooltip explains whether the raid uses a shared Normal/Heroic lockout, separate lockouts per difficulty, a standalone Raid Finder lockout, or a single difficulty.",
                    "**A new minimap button icon**, the neon mirrored-RR mark on a dark disc.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The load dialog was refreshed.** The prompt now reads \"Select Route,\" the route name is larger, and the route buttons are styled neon FULL and SKIP graphics, centered as a pair. The old Cancel button is replaced by a close button in the top-right corner matching the rest of the UI.",
                    "**The transmog browser dropdowns are relabeled and resized.** Each dropdown now carries a label (Exp, Raid, Boss, Class), the bars are sized to fit their contents instead of leaving empty space, and they cascade in a slight left-to-right stagger.",
                    "**The route line in the footer reads \"Route: Full\"** for the full-clear route (previously \"Standard\").",
                    "**Choosing a route is no longer locked in until you kill a boss.** If you reload or step out and back in before your first kill, the route picker reappears so you can still switch between Full and Skip, with a \"Continue?\" hint marking the route you'd picked. Once you've killed a boss, reloading quietly resumes that route and prints a one-line reminder of which route you're on and your progress.",
                    "**The minimap button and the /rr command both always open the full panel**, regardless of your \"On Login Show RetroRuns\" preference. That setting now applies only to how the panel appears when you log in outside a raid.",
                    "**Removed the \"What's New?\" label from the footer.** The version number stays, and the \"!\" still appears beside it when there's an update you haven't viewed.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**The SKIP button on the load dialog now stays locked until the specific shortcut its route uses is unlocked.** On raids with more than one skip (like Hellfire Citadel), it could previously light up as soon as any shortcut was unlocked, even one leading to a different boss.",
                    "**Picking FULL after previously choosing SKIP now correctly loads the full route.** If you'd selected SKIP earlier in a lockout, then reloaded and chose FULL, the addon could keep running the skip route. Your latest choice is now always honored.",
                    "**Corrected the portal marker on the Hellfire Citadel Mannoroth skip** so the waypoint sits on the Destructor's Rise portal.",
                    "**The transmog summary and browser now agree on collected items.** An appearance you owned through one difficulty could be tallied as still-needed in the main-panel summary while the browser correctly showed it collected; the two now count it the same way.",
                },
            },
        },
    },
    {
        version  = "2.0.1",
        date     = "2026-06-26",
        sections = {
            {
                heading = "Changed",
                bullets = {
                    "**The load dialog was refreshed.** The prompt now reads \"Select Route,\" the route name is larger, and the route buttons are styled neon FULL and SKIP graphics, centered as a pair. The old Cancel button is replaced by a close [X] in the corner matching the rest of the UI.",
                    "**The route line in the footer reads \"Route: Full\"** for the full-clear route (previously \"Standard\").",
                    "**Choosing a route is no longer locked in until you kill a boss.** If you reload or step out and back in before your first kill, the route picker reappears so you can still switch between Full and Skip -- with a \"Continue?\" hint marking the route you'd picked. Once you've killed a boss, reloading quietly resumes that route and prints a one-line reminder of which route you're on and your progress, instead of re-asking.",
                    "**The minimap button and the /rr command both always open the full panel**, regardless of your \"On Login Show RetroRuns\" preference. That setting now applies only to how the panel appears when you log in outside a raid.",
                    "**Removed the \"What's New?\" label from the footer.** The version number stays, and the \"!\" still appears beside it when there's an update you haven't viewed.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**The SKIP button on the load dialog now stays locked until the specific shortcut its route uses is unlocked.** On raids with more than one skip (like Hellfire Citadel), it could previously light up as soon as any shortcut was unlocked, even one leading to a different boss.",
                    "**Picking FULL after previously choosing SKIP now correctly loads the full route.** If you'd selected SKIP earlier in a lockout, then reloaded and chose FULL, the addon could keep running the skip route. Your latest choice is now always honored.",
                    "**Corrected the portal marker on the Hellfire Citadel Mannoroth skip** so the waypoint sits on the Destructor's Rise portal.",
                },
            },
        },
    },

    {
        version  = "2.0.0",
        date     = "2026-06-21",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Looking For Raid routing.** Queue into any LFR wing and RetroRuns lays out the path through that wing -- only the bosses you'll face, in the order you reach them, with the same walk-along directions, map lines, and waypoints as the full-raid routes. Wing progress and the per-difficulty pills track each wing on its own, so running a second wing of the same raid keeps its counts straight. This covers more than 80 wings across two dozen raids, spanning every expansion from Mists of Pandaria through Dragonflight. Expand any raid in the supported list to see its wings and per-wing progress at a glance.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**New travel icon, with a destination choice.** The travel icon beside each raid has a fresh look, and clicking it now lets you pick where to go: the raid entrance, or the Looking For Raid queue NPC.",
                    "**Skip-availability stars no longer appear next to the raid name while you're on an active route.** They stay in the supported-raids list and the Skips window, where they help you choose a route; once you're running one, the choice is already made.",
                    "**The Skips window difficulty columns read Normal, Heroic, Mythic from left to right** -- the traditional progression order, with Mythic on the right.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Continued refinement of routes and travel notes across raids** -- smoother paths and clearer directions in a number of places.",
                },
            },
        },
    },

    {
        version  = "1.14.0a",
        date     = "2026-06-19",
        sections = {
            {
                heading = "Fixed",
                bullets = {
                    "**Clicking on the world map no longer causes an error.** A hotfix for a problem where opening the world map to your location could trigger a Lua error in some situations.",
                },
            },
        },
    },

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

}
