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
    {
        version  = "2.3.0",
        date     = "2026-08-04",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**The Wrath of the Lich King raids join RetroRuns.** All nine raids now have full routing and transmog tracking: Naxxramas, The Eye of Eternity, The Obsidian Sanctum, Onyxia's Lair, Vault of Archavon, Ulduar, Trial of the Crusader, Icecrown Citadel, and The Ruby Sanctum. Every raid carries step-by-step routing, boss progress, tier sets, special drops, achievements, and exit directions at every difficulty the raid offers. Icecrown Citadel is guided end to end across all twelve bosses for both factions, with the gunship and Deathbringer Saurfang approaches routed separately for Alliance and Horde. Valithria Dreamwalker is optional, and the guide follows players who run past her, picking up at Sindragosa; turn back for her and the route follows you back, and the run reads as complete once the Lich King falls either way. Ulduar offers guidance through each hard-mode available, along with hard-mode loot tracking in the transmog browser. Trial of the Crusader and Icecrown Citadel field a different encounter depending on your faction, and the boss list, route, and notes follow the one you actually fight.",
                    "**Simplified Chinese (zhCN) localization.** The full interface, route notes, tips, and What's New now display in Simplified Chinese on Chinese clients.",
                    "**The transmog browser tracks the other faction's drops.** Faction-locked items were hidden entirely, but the game grants the opposite faction's appearance when its counterpart drops for you, so they are collectible. They appear in their own block at the bottom of each boss's list, tagged with the faction they belong to, and light up as you collect them. The needed counts still cover only what your character can loot.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The Volcanius marker in Vault of the Incarnates is a plain point of interest.** It was a pulsing ring of the kind that turns gray and ticks itself off once you pass it, but that kill cannot be detected, so the ring never resolved.",
                    "**Expansion names display in the client's language.** The expansion headers and dropdowns follow what the game's own journal shows, which localizes them on some clients.",
                    "**The Achievements section now appears for every boss.** Bosses with no tracked achievements show the section with \"None\" rather than hiding it; the row opens the Achievements window.",
                    "**The Achievements window no longer changes width when switching raids.** It keeps the widest size it has needed so far and only its bottom edge moves, matching the transmog popup's behavior.",
                    "**The Toaster settings click legend now reads \"Left-Click: Collections\"** (was \"Left-Click: Open in Collections\"), in all languages.",
                    "**The Sun King's Salvation tip in Castle Nathria was removed.**",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Raids that share one lockout across two difficulties now recognize the week's progress from either side.** Entering the other difficulty of a lockout you had already progressed showed a fresh run and asked you to pick a route again; the addon now resumes your route, counts the kills you already have, and shows the run as complete when the lockout is finished.",
                    "**On translated clients, the word above the SKIP button could overlap the \"Select Route\" prompt.** Hovering FULL or SKIP shows that button's word in your language above it, and on a longer word it ran into the prompt line. The dialog now leaves room for it.",
                    "**The skip route's target boss showed in English on translated clients.** The route picker's SKIP button names the boss the shortcut skips ahead to, and that name was printed from the addon's own English text rather than the game's. It now shows the name your client uses, on every raid with a skip route.",
                    "**On non-English clients, the route-selection popup could show rows of empty squares with no raid name.** The popup could appear before its text was filled in, rendering its prompt in a font that lacks the client language's characters; it now stays hidden until fully populated and always uses a font that covers the client's language. If a font fails to load, which can happen with replaced game fonts, the addon falls back to the game's own font instead of leaving text unreadable.",
                    "**The transmog browser could open filtered to another class.** A class chosen in the browser's dropdown, or reached by clicking a drop toast for gear your character cannot wear, was remembered permanently, so later visits kept showing that class, on that character and on every other one that shared its class. The choice now lasts only as long as the browser is open; opening it again shows the class you are playing.",
                    "**Left-clicking a loot toast for gear your class cannot wear now shows the appearance.** The appearances browser opened to an empty page because its view is filtered to classes that can equip the item; it now switches the class filter to one that can view the drop, and switches it back when you close the window.",
                    "**Clicking a loot toast could open the appearances window on an unrelated page.** Every drop now opens to its own page, including shields, bows, guns, and wands your class cannot use -- the browser switches to a class that can see them and switches back when you close it. Appearances locked to the other faction say so and point at the preview instead of opening.",
                    "**The Firelands Glory reward rendered as plain text until the item cache primed.** The reward now resolves through the mount's spell link like every other Glory, so it links immediately.",
                    "**The selected On/Off choice under \"Hide Blizzard Boss Banner:\" showed no underline.** The row's wide label pushed its buttons to a fractional pixel position where the hairline could vanish; positions now round to whole pixels and the underline uses the same pixel-grid handling as the dividers.",
                    "**The divider above the routing legend crowded the lines above and below it.** With several expansions listed, the supported-raids list grew into the space reserved for the legend, leaving the divider and its gem overlapping the last raid row and the legend text.",
                    "**Two boss names were spelled differently than the game spells them.** Tomb of Sargeras travel notes read \"Kil'Jaeden\" (the game uses \"Kil'jaeden\") and a Sanctum of Domination note read \"the Tarragrue\" mid-sentence where the boss is \"The Tarragrue\".",
                },
            },
        },
    },

    {
        version  = "2.2.1",
        date     = "2026-07-21",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**RetroRuns now speaks German, French, and Russian.** Full localization on deDE, frFR, and ruRU clients: the interface, every travel note and solo tip, boss and place names, achievement notes, sub-zone routing, dialog triggers, and the What's New window. Route tracking works the same as it does in English, including the steps that advance when you enter a specific part of a raid or when a boss speaks; quest, achievement, and place names carry Blizzard's official localized titles. English and Spanish clients are unchanged.",
                    "**Loot toasts respond to clicks.** Right-click a toast to dismiss it. Ctrl-click to preview the item in the dressing room, whether it is an appearance, a mount, or a pet. Left-click opens the drop where it lives in your collection: appearances in the Appearances tab, mounts in the Mount Journal, pets in the Pet Journal, toys in the Toy Box. Opening a collection window is not possible during combat, so left-click waits until the fight is over; dismissing and previewing work at any time. The three gestures are listed in the toaster settings under Toaster Preview.",
                    "**Loot toasts now hold while you hover them.** Hovering a toast brings it back to full opacity and keeps it on screen for as long as the cursor stays on it, so there is time to read what dropped. Moving away resumes the fade from where it left off.",
                    "**The minimized bar shows the way out when a run is complete.** Finishing a raid in minimized mode used to leave the bar showing only the RetroRuns wordmark. It now reads \"Raid Complete!\" — or the skip and Raid Finder equivalents — with an abbreviated exit tip beneath it.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Toaster settings page layout holds up in every language.** The header wraps inside the frame instead of running past it, and the explainer text, click-gesture legend, and loot-summary preview no longer overlap the sample toasts.",
                    "**The notification preview's Play button no longer runs into the notes beside it.** The button sizes to its own label and moves to its own line when the pair would reach the right-hand column.",
                    "**Localization fixes for Spanish clients.** Two Emerald Nightmare travel notes and twenty-one highlighted place names now render fully in Spanish, the Merithra and Vol'jin dialog triggers fire again, and the loot summary's chat rows (the \"From that kill\" heading, the \"New!\" tag, and the Mount, Pet, and Toy labels) are translated.",
                },
            },
        },
    },



}
