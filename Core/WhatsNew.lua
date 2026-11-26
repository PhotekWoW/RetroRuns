-------------------------------------------------------------------------------
-- RetroRuns -- WhatsNew.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
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
    version  = "3.5.5",
    date     = "2026-11-26",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Court of Stars is routed**, finishing the Legion dungeons. During the spy hunt, the panel builds the spy's profile from each Chatty Rumormonger's clue, so you know exactly which Suspicious Noble to accuse.",
                "**Karazhan's Opera Hall loot is tagged to each boss in the tmog browser.**",
                "**Return to Karazhan's Soul Fragments are tracked under Nightbane in Boss Progress.** The fragment you're heading for pulses, and if you pass one, the route note tells you to go back for it before Medivh's Echo runs out.",
                "**A mount, pet or toy you haven't learned, or can still sell, gets its own toast when it drops**, instead of only counting toward \"Special\" in the loot summary.",
                "**Updated TOC for patch 12.1.7.**",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**Patch 12.1.7 gives the \"added to your appearance collection\" chat line its own chat type.** RetroRuns hides it there too, so with Loot Summary on, new appearances still show only in the summary.",
                "**The Nightbane question asks whether you want to kill him and shows how many collectibles he has left for you.**",
                "**Skipping Nightbane keeps his summon clock on his row**, in case you change your mind.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**Learning a new mount shows its Special Loot toast.**",
            },
        },
    },
},
{
    version  = "3.5.4",
    date     = "2026-11-22",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Return to Karazhan is routed**, including the Opera Hall play of the week.",
                "**Nightbane on Mythic Return to Karazhan:** Want to farm the mount but don't want to hassle with learning how to spawn Nightbane? We've got step by step routing to get you there without thinking.",
                "**Shift-click an item on the End of Run Summary to link it in chat, or ctrl-click to preview it.**",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**Entering a dungeon or raid no longer flashes the panel you had open outside.** It opens with the route.",
                "**The Skip prompt's question uses the font you picked in Settings.**",
                "**Special Loot on the End of Run Summary shows each item in its own quality color and icon**, and trash and event drops will say where they drop.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**A mount you already own no longer shows as \"Unlocked This Run\"** after a login or reload.",
                "**Brazilian Portuguese route notes read properly.** 532 notes and labels, mostly in the older raids, had English words left in them or broken grammar.",
                "**German text uses the formal \"Ihr\" throughout**, as the rest of RetroRuns does; 60 lines, mostly route notes in the Classic raids, used \"du\".",
            },
        },
    },
},
{
    version  = "3.5.3",
    date     = "2026-11-13",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Black Rook Hold is routed.**",
                "**Vixx the Collector has a rare marker on Seat of the Triumvirate's map.** He drops two toys on Heroic.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**No more chat line at login when nothing changed.** The line only appears when a login records new reputation data for that character.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**The Blizzard Journal Order setting names the Adventure Guide the way the game does** in Spanish, French, Portuguese and Russian.",
            },
        },
    },
},
{
    version  = "3.5.2",
    date     = "2026-11-05",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Darkheart Thicket is routed.**",
                "**Castle Nathria's weapon-token lines show how many appearances are left to collect**, with normal and Mythic counted separately.",
                "**New setting, \"Auto-skip optional bosses with nothing left to collect\":** Previously, we auto-skipped optional bosses with nothing left to collect. Now, we give you the choice.",
                "**The Skip prompt matches the rest of RetroRuns:** a new popup with SKIP and KILL buttons, plus a cog that opens Settings.",
                "**Every setting on the General page has a hint**, with each choice named in white on its own line.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**The exit note comes first after a run finishes**, above any skipped bosses and the boss list.",
                "**The load dialog's buttons are live text**, so FULL, SKIP and TRIBUTE read in your own language with no hover needed.",
                "**The Navigate popup has new neon buttons.**",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**The Emerald Nightmare's entrance marker sits on the real entrance**, about 33 yards from where it was.",
                "**Text in translated clients stays inside its window:** the load dialog, the Settings pages, the transmog browser and the Achievements window no longer overlap or run out of their frames, and the transmog dropdowns size to their menus.",
            },
        },
    },
},
{
    version  = "3.5.1",
    date     = "2026-11-04",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Four more Legion dungeons are routed:** Seat of the Triumvirate, Cathedral of Eternal Night, Assault on Violet Hold and Eye of Azshara.",
                "**The End of Run Summary remembers your characters' reputations.** Each login records reputations tied to dungeons/raids. This information is used to show you which of your characters has the highest reputation for a given instance, in case grinding reputation is your goal.",
                "**The End of Run Summary shows your best time and the gold you looted.**",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**The End of Run Summary no longer shows how many times you've cleared an instance.** The data offered through Statistics was flimsy at best, and completely wrong in many cases. May revisit in the future if Blizzard ever cleans up Statistics!",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**Chat lines show their own colors after the RR: prefix** instead of picking up its cyan, so the Toaster's \"Loot:\" reads green again.",
                "**Short map marker tooltips fit their text** instead of stretching it across a wide blank gap.",
            },
        },
    },
},
}
