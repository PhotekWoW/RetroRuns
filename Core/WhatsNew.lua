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
{
    version  = "3.3.1",
    date     = "2026-09-28",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Throne of the Tides is guided.** The first Cataclysm dungeon with a route.",
                "**Trash drops for every Cataclysm dungeon.**",
                "**Pets, mounts and toys that drop from trash show in Trash Drops**, such as the Deviate Hatchling in Wailing Caverns, the Filthy Bucket in Tol Dagor and the Qiraji Resonating Crystals in Ahn'Qiraj, tagged with the difficulty they need.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**The trash loot summary works alongside faster auto-loot addons**, which could empty the loot window before the summary started listening.",
                "**The Mount Indicator matches your mount button.** Where the game refuses a mount but still calls the mount spell usable, as in parts of Throne of the Tides, the horse no longer shows.",
            },
        },
    },
},
{
    version  = "3.3.0",
    date     = "2026-09-25",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Wrath of the Lich King dungeons are complete.** All sixteen are guided, from Utgarde Keep to Halls of Reflection.",
                "**Reputation Summary.** Inside a dungeon or raid, the \"Reputation with X increased\" lines from each pull collapse into one \"Reputation Gains\" line with a [view] expander, largest gain first. The line waits for combat to end, so a long pull prints once. Toggle it under Toaster settings.",
                "**Collapsed loot sections pulse when they hide something in your bags.** In the transmog browser, a collapsed section such as Trash Drops breathes its arrow while it holds a BoE piece you are carrying but have not learned.",
                "**Trash drops for every WotLK dungeon.** 65 confirmed rows across eleven dungeons.",
                "**Music rolls and drake manuscripts show under Special Loot.** Bosses that drop a Music Roll or a Dragonflight drake manuscript list it on the main panel, marked once you've learned it.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**Timewalking runs show no route.** Timewalking is queued group content, so inside a Timewalking dungeon or raid the panel reads \"Routing disabled for Timewalking\". Panel stays open for transmog and boss progress.",
                "**Transmog Needed keeps Timewalking on its own line.** The standard tmog counts no longer include Timewalking drops; a separate \"Timewalking\" line counts TW-only drops, dimmed while the event is off. Inside a Timewalking run those looks count as current.",
                "**An optional boss is only skipped as collected when you own every item he drops.** A shared look no longer counts, so Amanitar, Eck and the Infinite Corruptor stay on the route until each piece is fully collected.",
                "**Heroic-only bosses show one Transmog Needed line** instead of a second \"Other difficulties: Complete\" line.",
                "**Newly-added dungeons have a new color-cycling animation.**",
                "**The Mount Indicator stays quiet in combat and while you ride a vehicle.**",
                "**Toaster settings are tidier.** The four sub-rows' On/Off choices are indented under the Toaster row, the selected-choice underlines match on every row, and the subline reads \"Quiet the Spam from Blizzard's Native Notifications\".",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**The Timewalking hourglass tints right after login** instead of staying white until the list is redrawn, and keeps its color inside an instance.",
                "**A Heroic-only boss on a Normal run is no longer reported as skipped for being collected.**",
            },
        },
    },
},
}
