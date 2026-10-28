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
{
    version  = "3.3.6",
    date     = "2026-10-18",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Zul'Aman is routed**, with its hostage rescue chests in the transmog browser and the prisoners and Forest Frogs marked on the map.",
                "**Dire Maul's Tribute run is routed.** Zoning into Gordok Commons asks whether you want the FULL run or the TRIBUTE run. The Tribute run guides you step-by-step to maximize rewards. When choosing the route, we show how many appearances remain with each option.",
                "**Enhanced Boss Icons.** Hover a boss's icon on the map inside an instance to see what it still drops for you: missing, shared and collected appearances, and special loot.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**A new, cleaner look for the loot toasts**: a neon frame, a larger item name, and mounts, pets, toys and decor named by kind in their own color, with a sparkle.",
                "**The settings pages share one look.**",
                "**\"Hide fully collected rares from map\" is now \"Hide fully collected POIs\"** and now hides POI map markers in addition to rares when their rewards are fully collected.",
                "**Achievements that name several bosses show under each of them** (Earth, Wind & Fire on Archavon, Emalon and Koralon; Bear-ly Made It on Zul'Aman's four prisoner bosses), and instance-wide achievements such as The Dedicated Few show on every boss.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**A loot toast shows the drop's real quality color** when its new appearance registers before the loot itself; a blue legacy drop no longer toasts purple.",
                "**Picking a Dire Maul wing from the search no longer flashes Capital Gardens first.**",
            },
        },
    },
},
{
    version  = "3.3.5",
    date     = "2026-10-14",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Two more Cataclysm dungeons.** Deadmines and Zul'Gurub. Zul'Gurub's Cache of Madness is on the route only if you have Archaeology, and its recipe vendor is marked on the map.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**Optional bosses now skip themselves once you've collected everything they drop**: Valithria Dreamwalker, Viscidus, Phalanx, Urok Doomhowl, Yor, Grubbis and Cho'Rush the Observer.",
                "**Boss Progress groups bosses where only one of the set appears under one heading.** Trial of the Champion's Eadric and Paletress sit under \"Argent Champion\", and Zul'Gurub's four Cache of Madness bosses under theirs. Once the fight shows which one you got, the others are marked unavailable.",
                "**Grim Batol no longer lists the \"Umbrage for Umbriss\" achievement**, which Blizzard moved to Legacy.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**The travel note no longer stays on a boss you've already killed** when the game never reports the fight ending.",
                "**Jumping to a dungeon from search now clears its expansion's NEW tag.**",
                "**The Deadmines entrance marker now points at the portal inside the Moonbrook mine.**",
            },
        },
    },
},
{
    version  = "3.3.4",
    date     = "2026-10-12",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Two more Cataclysm dungeons.** Grim Batol and Blackrock Caverns. Blackrock Caverns auto-skips Beauty once every appearance she drops is collected.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**Transmog Needed now counts every class's pieces in Baradin Hold and Vault of Archavon**, Vault of Archavon's tier pieces included. Looting gear your class can't wear still unlocks its appearance, so those looks count too. The transmog browser's class filter works as before.",
                "**Items that no longer drop are gone from fourteen dungeons.** Season-only reprints and Mythic Keystone-only drops no longer show in Siege of Boralus, Grim Batol, Atal'Dazar, The Underrot, Skyreach, Seat of the Triumvirate, Algeth'ar Academy, Tazavesh (So'leah), Black Rook Hold, Court of Stars, Darkheart Thicket, Halls of Valor, Neltharion's Lair and The Everbloom, and Skyreach no longer lists the same item twice.",
                "**Standardized the way the brackets are drawn on each panel.**",
                "**The transmog browser's gold check is the same size as the green one.** It is now the same check mark, tinted gold.",
                "**Every pulse and fade animates smoothly instead of rapidly stepping.**",
                "**The Timewalking hourglass is easier to read at small sizes.**",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**Siege of Boralus: Sergeant Bainbridge's Horde-only drops now sit under \"Horde Appearances\" for Alliance characters**, instead of in the main list under Chopper Redhook, and no longer count toward their Normal totals.",
                "**Clicking a New Appearance toast for a class-locked piece that shares its look with another item now opens the wardrobe on the right class's page**, instead of an empty page for the wrong class.",
                "**New Appearance toasts no longer show the same look twice** when two items that share it drop in one loot.",
                "**Transmog Needed no longer says \"Complete\" while another difficulty still has a look you're missing.**",
                "**Layout fixes for the 04B_03 and VT323 fonts and for large font sizes.**",
                "**Minimizing the panel no longer leaves a NEW tag floating below the bar.**",
                "**Map markers from an instance you've left no longer show their popup in the next one.**",
                "**Toast headers in French, Portuguese and other accented languages no longer come out in mixed case.**",
                "**Long search results stay inside the search box's popup**, ending in \"...\" instead of running past its edge.",
            },
        },
    },
},
}
