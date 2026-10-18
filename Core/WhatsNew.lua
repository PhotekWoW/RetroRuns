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
{
    version  = "3.3.3",
    date     = "2026-10-01",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Four more Cataclysm dungeons.** Lost City of the Tol'vir, Halls of Origination, The Stonecore and Shadowfang Keep.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**Optional bosses the route skips as fully collected now read \"(ignored: fully collected)\" in Boss Progress, and the run-complete screen lists them under their own heading.**",
                "**The current boss's arrow in Boss Progress pulses.**",
                "**Transmog browser: single-checkbox rows and difficulty-strip rows now align on their own**, so a lone checkbox row no longer sits far from its name.",
            },
        },
    },
},
{
    version  = "3.3.2",
    date     = "2026-09-28",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**The Vortex Pinnacle is guided.** The route follows each Slipstream flight to the next platform.",
            },
        },
    },
},
}
