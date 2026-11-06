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
{
    version  = "3.4.0",
    date     = "2026-10-28",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Every Warlords of Draenor dungeon is routed:** Auchindoun, Bloodmaul Slag Mines, Grimrail Depot, Iron Docks, Shadowmoon Burial Grounds, Skyreach, The Everbloom and Upper Blackrock Spire.",
                "**The Picker: Difficulties, lockouts and missing appearances at every entrance.** Walk up to a dungeon or raid entrance and a bar shows each difficulty with the appearances you still need there and whether you're saved. Hover for reset times. Move it, scale it and lock it in place from its settings page.",
                "**Instance Limit list.** Click Instance Limit in the panel footer for a shortcut to the new Picker settings, which also displays a list of your existing lockouts contributing to the hourly limit.",
                "**Reset Here and Reset All** in settings, reset one page or reset every setting back to its default.",
                "**Hover a dungeon's difficulty pill** to see which difficulties you're saved to, how far along you are, and when each resets.",
                "**Three more illusions are tracked:** Mark of Shadowmoon from Ner'zhul in Shadowmoon Burial Grounds, and Mongoose and Sunfire from Moroes and the Shade of Medivh in Return to Karazhan.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**Clicking an achievement opens the Achievements window at that achievement** instead of the small link popup, on the main panel, in the RetroRuns Achievements window and in the skip details. Shift-click still links it in chat.",
                "**The transmog browser, Achievements and Skips windows open on the left of the main panel when there is no room on the right**, so a panel parked at the right edge of the screen no longer gets covered. A window you drag stays where you put it.",
                "**Class-locked special loot is tagged with its class**, such as \"(Shaman)\" on Illusion: Flametongue.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**Dungeons that never save a lockout on Heroic, like Skyreach and Pit of Saron, no longer show a Heroic pill in the dungeon list.**",
                "**Illusion: Colossus in Mogu'shan Vaults now tracks the right illusion.**",
                "**Clicking a mount or item in Special Loot no longer throws an error.** Hover it for its tooltip; shift-click links it in chat.",
                "**Garrisons no longer count toward the Instance Limit.**",
            },
        },
    },
},
{
    version  = "3.3.7",
    date     = "2026-10-21",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Cataclysm dungeons are completed.** Well of Eternity, Hour of Twilight and End Time round out the roster.",
                "**Holiday bosses are in the transmog browser.** The Headless Horseman, Coren Direbrew, the Crown Chemical Co. and Ahune each exist on their dungeon's Boss list, tagged with their holiday.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**\"Talk to\" markers on the map are a chat bubble with a pink glow** instead of a star, in every routed raid and dungeon, and a marker dims once you're past it.",
                "**Queuing for a holiday boss no longer loads the dungeon's route.** The panel shows the holiday boss instead: his Transmog Needed and Special Loot, and one Boss Progress row for his kill.",
                "**The TW pill in the transmog browser now marks only looks you can get nowhere else in the raid.** Black Temple's Normal loot no longer carries one.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**Missing achievements and appearances are in.** 32 dungeon achievements across 18 dungeons, Black Temple's Horde versions of the Demon Hunter Timewalking pieces, and the Timewalking-only looks in Ulduar (the Demon Hunter and Monk sets) and Firelands (tier pieces whose look only Timewalking drops).",
                "**A new appearance no longer occasionally prints twice in the loot summary.** The summary waits for an appearance still on its way, so the item is listed once, tagged [New!].",
                "**Route steps that wait for an NPC's line now advance in every language.** On non-English clients, eleven dungeons held the previous step until the boss died, among them Zul'Aman, Stratholme, Dire Maul and Halls of Origination.",
            },
        },
    },
},
}
