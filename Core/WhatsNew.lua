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
{
    version  = "3.2.0",
    date     = "2026-09-20",
    sections = {
        {
            heading = "Added",
            bullets = {
                "**Burning Crusade dungeons are complete.** Also, The Violet Hold and The Culling of Stratholme in WotLK.",
                "**Burning Crusade dungeon sets are called out.** A boss that drops a piece of one of the eleven Dungeon Set 3 sets shows it in a \"Dungeon Set 3\" block above its other loot, each piece tagged with its set.",
                "**Mount Indicator.** If you're in a spot where you can mount up, a small pink horse icon pulses in the title bar to remind you.",
            },
        },
        {
            heading = "Changed",
            bullets = {
                "**Identical difficulties share one line in Transmog Needed.** When a boss drops identical appearances across difficulties, the section collapses to a single \"Any difficulty\" line instead of two redundant ones.",
                "**Heroic-only drops are called out.** Similar to Mythic-only items in raids. Kael's mount/toy/pet in Magisters' Terrace, for example.",
            },
        },
        {
            heading = "Fixed",
            bullets = {
                "**Logging in no longer temporarily drops your frame rate.** The addon was loading Encounter Journal data for every instance it knows in the background after each login.",
                "**The Instance Limit counter counts correctly.** It was previously adding a new instance every time you walked into another room of the same dungeon, and timing each one from your last step inside instead of from when you entered.",
                "**A new appearance from a legacy dungeon's Normal drop no longer toasts as the Heroic epic.** The toast names and colors the item you looted rather than the base item behind it.",
                "**Buying from a vendor no longer goes silent with the Toaster on.** Purchases, quest rewards and mail reach chat as they always did; only loot-window lines are summarized.",
                "**Finishing a dungeon on Normal no longer reads \"Skip Run Complete\" when its only optional boss is Heroic-only.** A boss that difficulty never offered was not skipped.",
                "**Transmog Needed collapses to \"Any difficulty\" in Timewalking dungeons too.** A Timewalking reprint of the same look no longer keeps the two-line form.",
            },
        },
    },
},
    {
        version  = "3.1.2",
        date     = "2026-09-14",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**The three Tempest Keep dungeons are added in TBC.** The Arcatraz, The Mechanar and The Botanica.",
                    "**New dungeons announce themselves.** Useful while releasing dungeons in a phased manner. The first time you open an expansion on the dungeon list after an update adds guided dungeons to it, the header carries a NEW tag and the new dungeons brighten from gray to white.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Expanding an expansion on the instance list no longer stalls the first time.** The boss data every expansion needs is loaded quietly in the background after login instead of on the click.",
                    "**Green rows no longer start out gold on a fresh login.** Drops you own through Blizzard's re-issued copy of the same item could paint gold for a moment after logging in, then correct to green. They now paint green from the start.",
                    "**Map marker loot no longer shows as plain text on the first hover.** Items the game had not loaded yet appeared as white names instead of colored item links until the next hover.",
                },
            },
        },
    },
}
