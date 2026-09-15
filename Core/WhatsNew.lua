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
    {
        version  = "3.1.1",
        date     = "2026-09-12",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**The three Coilfang dungeons are added in TBC.** The Slave Pens, The Underbog and The Steamvault, with the Steamvault's two access panels tracked on the map.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**Timewalking pills mean Timewalking-only looks.** A drop whose Timewalking version is the same look as the walk-in version no longer shows a TW pill; inside a Timewalking run the boss counts still include it.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**The transmog browser opens faster.** Every open was recounting collection state for every item in the tree before drawing anything.",
                    "**Opening the browser in combat could throw errors.** Now we hold the request until combat ends.",
                    "**A re-issued drop reads as collected.** Blizzard has re-issued hundreds of legacy items under new item numbers (Gauntlets of the Bold in The Steamvault, most of Vault of Archavon and Naxxramas). Looting one used to show gold, as if the look came from some other item; it now shows green.",
                    "**Translations match the game.** Around 290 boss names in Spanish, French and Russian now read exactly as the Encounter Journal spells them, which also keeps their kills across a reload; Italian and Portuguese gain the names of every Classic dungeon rare; every highlighted name in the guides is translated in all nine languages.",
                    "**New drops from the current journal**: Grim Batol, Skyreach, Siege of Boralus, Atal'Dazar, The Underrot and Tazavesh gained rows the browser did not list.",
                    "**The addon uses about 20 MB less memory.** The nine translation tables for other languages are released once yours is loaded.",
                },
            },
        },
    },
    {
        version  = "3.1.0",
        date     = "2026-09-11",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**All MoP Dungeons are in.** Temple of the Jade Serpent, Mogu'shan Palace, Gate of the Setting Sun, Stormstout Brewery, Siege of Niuzao Temple, Shado-Pan Monastery and Scholomance join the two Scarlet halls, which makes 27 guided dungeons so far.",
                    "**Every expansion has its own custom art behind the main panel.** Open an expansion on the list, or load one of its instances, and a faded picture sits behind the content.",
                    "**Legacy of Scholomance is in the transmog browser.** The original Scholomance's appearances are listed under every Scholomance boss, with a note on how the attunement starts. The rare who drops the toy that starts it, Doctor Theolen Krastinov, is marked on the map.",
                    "**RetroRuns stays deactivated on M+ Dungeons.** When zoning into Heroic or Mythic difficulty on a seasonal M+ dungeon, the addon stays down. The minimap button or /rr still opens it by hand.",
                    "**The instance-limit counter counts difficulty changes.** Switching a dungeon between Normal, Heroic and Mythic spawns a new instance each time, and the counter now reflects that.",
                    "**Polyformic Acid Science.** This achievement now shows on each of its six bosses across the Mists dungeons, with a solo grade.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The addon download is a third smaller.** Media art moved to the game's native compressed format.",
                    "**The Timewalking and Mythic+ tags on the instance list are text now**, sitting after the instance name on both tabs. They used to draw inconsistently from one row to the next.",
                    "**Dungeon rows on the list line up with raid rows**: the plane icons share one column across both tabs.",
                    "**One gray on the main panel.** Several different tints of gray were being used in various places on the main panel. Now they match.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Deadmines lists its six bosses.** Seven bosses from the pre-Cataclysm Deadmines that only appear in the Classic Timewalking event were showing in the list and the browser.",
                    "**Scholomance, Deadmines and Shadowfang Keep show one row per item with a Normal and a Heroic pill.** The Heroic version of each drop was listed as a second row with no pills.",
                    "**Mogu'shan Palace's entrance waypoint** pointed at the old Vale of Eternal Blossoms map; it now lands on the current one.",
                },
            },
        },
    },
    {
        version  = "3.0.0",
        date     = "2026-09-04",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Dungeons!** Initially shipping with 20 dungeons which includes every Classic dungeon plus a couple from MoP. More dungeons will continue to be added! While the routes/guides are being developed for more dungeons, feel free to utilize the transmog browser for ALL dungeons, as well as pink plane navigation to every entrance.",
                    "**Search, everywhere.** The transmog browser, the main panel and the achievements window all have a new magnifying glass. Search by expansion, instance, boss, loot, POI, etc. Whatever you find, one click takes you right to it.",
                    "**Progress persists in dungeons with no lockout.** Normal dungeons keep no lockout, so the game gives an addon nothing to know whether the previous run is still there or if it reset. RetroRuns works it out anyway: log in, reload or walk back in and an active run comes back with every kill in place, while a reset instance starts you at step one on the spot.",
                    "**Map markers show more.** Rare spawns and certain treasures now show their locations on the map along with a mouseover hint to give a quick status on tracked appearances.",
                    "**Raid maps mark the NPCs worth knowing about.** Blackrock Foundry's skip-quest NPC and vendor, Icecrown Citadel's tier vendors, Blackwing Lair's alchemy workbenches and the like, each with a hover saying what it is for.",
                    "**RetroRuns has a button on the world map.** It sits in the icon column at the top-right corner alongside other addons' map buttons. Its menu has several map options to toggle, such as hiding POIs you've fully collected or disabling RetroRuns POIs altogether.",
                    "**Rare, trash and object drops are in the transmog browser.** Rares get a gold \"Rare:\" tag, trash drops get their own section, and Dungeon Set pieces show up on the bosses that drop them. Items that have been removed from the game or have become unobtainable are excluded.",
                    "**Timewalking drops get their own \"TW\" pill.** Looks that only drop during Timewalking used to be hidden. Now they show with a TW pill.",
                    "**The list knows when Timewalking is running.** An hourglass marks the live Timewalking expansion and every instance that offers a run. The hourglass color indicates how much time remains on the event.",
                    "**Dungeons in the current Mythic+ season are marked.** A \"M+\" tag beside the name, and it follows the rotation on its own with no update needed. This serves as a heads up to avoid Mythic runs that are on seasonal rotation.",
                    "**The idle footer counts your instances.** \"Instance Limit: 3/10 (42m)\" shows how many you've entered against the hourly cap and when the oldest slot frees. Only shows when outside of an instance.",
                    "**The achievements window covers dungeons.** A Raids / Dungeons switch sits above the instance list, an instance with nothing to track says so, and a Report button in the footer allows users to flag a solo grade that has gone stale.",
                    "**The transmog browser can open on All classes.** A \"Default Transmog Filter\" setting under General picks whether the browser opens on your class or on every class. The dropdown inside the browser still narrows it per visit.",
                    "**Faction-only bosses are marked.** Uldaman's Lost Dwarves are Horde only, so on Alliance the row shows a lock and the boss count skips them.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**Tier upgrade chains read one way everywhere.** Firelands uses the same two-dot chain as every other raid, and the Icecrown Citadel legend explains the dots. Dragon Soul no longer lists every Raid Finder token under every boss.",
                    "**The nav plane sits beside the raid's name**, instead of beside the difficulty pills.",
                    "**Loot lists are tidier.** Normal and Heroic drops collapse to one row, trash groups by source, shared notes appear once, and token lines lead the list.",
                    "**The panel header is tidier.** Centered wordmark, a magenta underline that survives small UI scales, and \"Run complete!\" on the minimized bar. Text that previously said \"raid\" now says \"instance\".",
                    "**The menu dropdowns are rebuilt.** The Transmog, Achievements and Settings dropdowns use the game's current menu system, with a slimmer bar, a magenta arrow and no hover popups.",
                    "**Every window closes the same way.** The Achievements, Transmog and Skips windows use the same styled close box as the main panel.",
                    "**A boss with nothing to collect says so**, in one line.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Looks that can no longer be collected are gone from the browser.** Dungeon Set 1 pieces with no boss drops, the Tier 0.5 summons, and season-only rows in modern dungeons. Anything still collectable elsewhere is still listed there.",
                    "**Looks that were missing are back.** Several pieces the Encounter Journal never listed are back, including End Time's Bindings of the End Times and Roogug's Swinesteel Girdle.",
                    "**The panel stays where you put it.** No more creeping up the screen after quitting minimized, and no more collapsing on reload.",
                    "**Boss kills register in every dungeon.** When the game doesn't report a kill, the addon reads the instance's own objectives and picks it up within seconds.",
                    "**Siege of Orgrimmar and newer raids have their lockout tooltip back.**",
                    "**Browsing another instance no longer highlights \"current difficulty\".** The white \"needed-now\" color only appears for the instance you are standing in.",
                    "**Bosses you cannot reach no longer hold the count open.** Sinestra outside Heroic and Ra-den in Throne of Thunder now carry a lock.",
                    "**The transmog totals count each appearance once**, even when it drops from more than one place.",
                    "**Smaller fixes.** The Skips window updates on quest turn-in, a finished skip run in a dungeon reads right, the map button closes the map on a second click, loot toasts say \"Browse locked in combat\" instead of erroring, The MOTHERLODE!! travel plane knows both faction entrances, and zoning into a dungeon paints the panel right away.",
                },
            },
        },
    },
    {
        version  = "2.5.0",
        date     = "2026-08-18",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**The Classic raids are in, and that completes the roster.** Molten Core, Blackwing Lair, Ruins of Ahn'Qiraj and Temple of Ahn'Qiraj each come with full routing, loot, tier sets and trash drops. With them, every legacy raid in the game is now covered -- Classic through Dragonflight, all 51, every one of them walked and routed.",
                    "**The transmog browser now covers dungeons.** A new Type selector switches between Raids and Dungeons, and every legacy dungeon from Classic through Dragonflight is there to browse boss by boss -- 123 dungeons in all, with appearances tracked per difficulty where the game varies them. Dungeons are browsing only for now; full guided routing, like the raids have, is coming soon. Probably.",
                    "**Tokens now tell you where to take them.** Tier tokens that cannot simply be right-clicked, and the omnitokens some bosses drop in place of a fixed piece, show a hint under the boss that drops them: the NPC to visit, what the turn-in costs, and a travel button where one can be reached. Icecrown Citadel's map marker points at the quartermaster who serves your own class.",
                    "**Optional bosses can be skipped.** A boss the route can bypass is marked as optional on the panel and in the Boss Progress list, and its encounter row offers a Skip Boss button. Skipping asks for confirmation first, because routing stays down for the rest of that lockout, and then sends you on to the next boss. The run finishes with a reminder that you can still go back and kill anything you skipped.",
                    "**Tier rows tell you more.** They show which specializations a piece can be handed to, the full upgrade chain where one exists, and any appearance a piece can be traded up to. The explanation beneath a tier list now folds away when you do not want it.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The transmog browser reads more clearly.** Item names follow the same color key as their difficulty markers, tier is set apart from ordinary loot and always leads the list, legendaries sit in their own block, and gear only one class can wear says so.",
                    "**Each faction's tier piece and its twin share one row** in the raids where every piece has a counterpart, with your own faction first and a marker for each version, so you can tell which of the two you still need.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Several raids were missing appearances entirely.** Trash and shared boss drops across Siege of Orgrimmar, Naxxramas and Throne of Thunder never appeared in the browser, so they read as uncollectable however many times you cleared the raid. All of them now show.",
                    "**Loot rows could show the wrong name color**, most often in the Wrath raids, where a row whose markers said collected still rendered its name gray.",
                    "**Assorted browser display fixes.** Loot lines up in proper columns, tier lists no longer sit double-spaced, a boss's ordinary loot no longer sorts above its tier list, rows that looked identical are told apart, and gear several classes can wear names the one you are looking at.",
                    "**Redemption hints point at the right place.** Trial of the Crusader names the pieces your Trophies actually buy, and Siege of Orgrimmar no longer sends Alliance players to the Horde vendor's spot.",
                    "**Route notes advance promptly after fights the game reports oddly**, instead of waiting until you walk somewhere.",
                    "**Smaller fixes.** Travel buttons say \"Zone out first\" rather than placing a waypoint that cannot be routed to, loot toasts respond to clicks during combat and open the right class's page, the Encounter Journal no longer redraws over itself, and row dividers no longer vanish at some window scales.",
                },
            },
        },
    },
}
