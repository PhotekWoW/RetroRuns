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
    {
        version  = "2.4.0",
        date     = "2026-08-11",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**The Burning Crusade raids join RetroRuns.** All eight raids now have full routing and transmog tracking: Karazhan, Gruul's Lair, Magtheridon's Lair, Serpentshrine Cavern, The Eye, The Battle for Mount Hyjal, Black Temple, and Sunwell Plateau. Every raid carries step-by-step routing, boss progress, tier tokens resolved to each class's pieces, battle pets, and exit directions. Everything is translated in all nine supported languages.",
                    "**Trash drops in the transmog browser.** Appearances that come off a raid's trash rather than a boss now have their own section, shown below whichever raid is selected. The section collapses to a single \"Trash Drops (collected/total)\" heading you can expand when you want it. Each row is tagged with how the item binds (BoP vs. BoE), and a BoE piece sitting in your bags is flagged as such so you don't miss it. Summary collection counter displays yellow until every appearance is collected, and green at 100%.",
                    "**Global POIs.** Useful fixtures such as repair vendors, quartermasters, etc. can now show on the raid map at all times, not only while a particular boss is your next objective. Vendors in Black Temple and Karazhan added to start, but more to come with the tooling now built.",
                    "**Direct routes to a raid's final boss.** Some legacy raids allow the player to bypass the raid, and walk directly to the final boss. Examples include Kael'thas Sunstrider in The Eye and Lady Vashj in Serpentshrine Cavern. Unlike modern raid skips, these aren't tied to quest completion. Where one exists, the load window offers it alongside the full clear, and your choice is remembered for the week.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**Collected items are dimmed in the transmog browser.** An item you have finished with now shows its name in gray rather than white, so the rows still worth your time stand out. An item counts as finished when every difficulty it drops at is collected.",
                    "**Section labels are now cyan.** The green and yellow section headings (Traveling, Achievements, Boss Encounter, Special Loot, Transmog Needed, Boss Progress, Trash Drops) now use the branded cyan instead.",
                    "**Hard-mode and opposite-faction drops fold into their own sections.** In the transmog browser, hard-mode-only drops (Ulduar) and the other faction's appearances (Trial of the Crusader) no longer run inline with the boss's loot list. Each now sits in its own collapsible section -- \"Hard Mode\", and \"Horde Appearances\" or \"Alliance Appearances\" depending on your character -- below the main list, collapsed until you expand it.",
                    "**The Transmog Needed summary takes up less space.** The [click to browse] hint now sits next to the heading instead of at the end of the counts, and the current difficulty shows as shorthand -- \"25H\" rather than \"25 Player (Heroic)\".",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Loot-toast clicks could leave the Appearances window drawing the wrong models.** Clicking a toast for an item your class cannot wear switches the wardrobe to a class that can; the window then kept the previous class's models under the new list until it was closed and reopened. It now redraws correctly.",
                    "**Icecrown Citadel's route could stall at The Spire on translated clients.** The step's location check only matched the English area name, so German, Spanish, French, Russian, and Simplified Chinese clients never saw it advance. It now matches each client's own name.",
                    "**The transmog window could grow upward after being moved.** Once dragged, expanding a section or switching bosses resized it from the center instead of downward from a fixed top edge.",
                },
            },
        },
    },
    {
        version  = "2.3.1",
        date     = "2026-08-05",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Brazilian Portuguese (ptBR), Traditional Chinese (zhTW), Korean (koKR), and Italian (itIT) localization.** The full interface, route notes, tips, achievements, and What's New now display in each of these languages on the matching client. With Spanish, German, French, Russian, and Simplified Chinese already supported, RetroRuns now speaks every language the game client offers.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Boss kills could vanish from Boss Progress after a reload.** Kills of certain bosses -- Blood Prince Council, Oregorger, Kromog, the Northrend Beasts, and a few dozen more -- unchecked themselves on the next login, sending the route back to a boss already dead for the week. Those kills now stay counted.",
                    "**Sample toasts on the settings pages could show boxes instead of text, or no title at all.** They now always use the game's standard typeface.",
                    "**Teleporter destinations in the Skips details read in English on translated clients.** They now show the game's own names for those places.",
                    "**Item names in the transmog browser could flash in English before switching to your language.** They now render in your client's language right away.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**\"Toaster\" stays in English in every language.** It is the feature's name, like RetroRuns itself.",
                },
            },
        },
    },
}
