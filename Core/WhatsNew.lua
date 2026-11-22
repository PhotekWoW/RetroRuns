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
{
    version  = "3.5.0",
    date     = "2026-11-02",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Five Legion dungeons are routed:** Vault of the Wardens, Neltharion's Lair, the Arcway, Maw of Souls and Halls of Valor. We auto-detect the randomized route in each Arcway lockout.",
                "**Sunwell Plateau's Sunmote upgrades are tracked.** Similar to Firelands, we show a second dot for the upgraded look, and each boss's loot names the Isle of Quel'Danas vendors: Theremis for tier tokens, Yrma for a Sunwell drop plus a Sunmote.",
                "**Resize any RetroRuns window by dragging one of its corners.** The main panel and the transmog browser, Achievements and Skips windows scale from 50% to 200%, and Window Scale in settings covers the same range. Each window can be sized on its own, and a window you move stays where you put it, across logins and characters.",
                "**Switching difficulty on the Picker plays a short retro select sound.** It follows your Sound Effects volume. Disable in settings.",
                "**An End of Run Summary replaces \"Where to next\" when you finish a run.** It shows how long the run took, how many times you've run the instance across all your characters, the reputation you gained (Warband or character), the appearances and special loot you unlocked, and what's left to collect.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**The Picker has a new look with custom art.**",
                "**The Picker's count covers everything left to collect:** special loot, rare and trash drops and event loot join the appearances, and an instance with nothing left reads \"Nothing Left to Collect\".",
                "**The Instance Limit list numbers its lockouts, oldest first, and shows each character's name in their class color.**",
                "**Locked difficulties on the Picker can be selected,** marked with a small lock beside the lockout count.",
                "**The Picker shrinks slightly where two entrances stack,** like Utgarde Keep and Utgarde Pinnacle.",
                "**The Toaster prints a single reputation gain or a single vendor drop as one short line** instead of a summary.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**Clicking a search glass clears its \"Search\" hint**, so it no longer sits over the search bar.",
                "**The travel note no longer briefly shows an earlier note as you walk into the next area.**",
                "**Missing pets, mounts and decor are in Special Loot:** the Raiding with Leashes pets in Molten Core, Blackwing Lair and Temple of Ahn'Qiraj, Drafty from the Conclave of Wind, Felsteel Annihilator from Mythic Archimonde, G.M.O.D. from Raid Finder Jaina, and the Everbloom Forest Floor from Yalnu.",
                "**Twelve Legion dungeon weapons and shields are back in the transmog browser,** in Halls of Valor, Court of Stars, Neltharion's Lair, Black Rook Hold and Darkheart Thicket.",
            },
        },
    },
},
}
