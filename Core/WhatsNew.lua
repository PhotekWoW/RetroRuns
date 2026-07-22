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

    {
        version  = "2.2.0",
        date     = "2026-07-18",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Localization support, starting with Spanish.** The groundwork is in place for RetroRuns to run in languages other than English: player-facing text now goes through a translation layer, and raid, wing, boss, and place names follow your game client's language. Spanish is the first language built on it, covering the interface and all route content on esES and esMX clients. More languages can now be added without further engine work. English clients are unchanged.",
                    "**Minimized mode comes to life.** Collapse the main panel to enable minimized mode. The main panel is replaced with a much smaller bar that shows an abbreviated version of every step-by-step travel note, along with a quick snapshot of current boss progress. Supported on all raids, all routes; Full, Skip, and LFR.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**The panel now keeps one position across all characters.** The window's position has always been saved account-wide, but the game's own per-character frame memory was re-applying each character's last position over it, so every character ended up with the panel somewhere different. The saved position now wins everywhere: move it once and it stays there for the whole account.",
                    "**Boss progress now tracks correctly on non-English clients in Mists of Pandaria raids.** On a client running in a non-English language, killing a boss in Mogu'shan Vaults, Heart of Fear, Terrace of Endless Spring, Throne of Thunder, or Siege of Orgrimmar did not register the kill or advance the route: the boss progress list, travel note, and map line stayed on the first boss no matter how far you had cleared. The Encounter Journal lookup used to match kills was reading at a difficulty those raids do not offer. English clients were unaffected and remain unchanged.",
                    "**The loot summary no longer misses drops when loot arrives a moment after the loot window closes.** On higher-latency pulls the summary could appear empty; it now waits briefly for the last items.",
                    "**The transmog window no longer shows a scrollbar when a boss's loot list fits.** A scrollbar, and a clipped travel button, appeared on bosses with a weapon-token footnote even when the list fit.",
                    "**The vendor travel button in the transmog window uses the correct plane icon and no longer sits under the scrollbar.**",
                    "**The Dragon Soul routing hint before Ultraxion now appears.** The step telling you to talk to Thrall to begin the encounter could never display.",
                },
            },
        },
    },

    {
        version  = "2.1.0",
        date     = "2026-07-06",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**The Cataclysm raids join RetroRuns.** All six now have full routing and transmog tracking: Baradin Hold, Blackwing Descent, The Bastion of Twilight, Throne of the Four Winds, Firelands, and Dragon Soul. Dragon Soul includes both Raid Finder wings, The Siege of Wyrmrest Temple and Fall of Deathwing, with per-wing routing and loot.",
                    "**The transmog browser can filter by class.** A class dropdown replaces the old show-all-tier toggle: pick any class to see only the gear it can collect, or choose \"All classes\" to see everything. It defaults to your own class, and shows as unavailable on bosses that drop no class-restricted gear.",
                    "**Hovering a raid in the supported-raids list shows how its lockout works.** A tooltip explains whether the raid uses a shared Normal/Heroic lockout, separate lockouts per difficulty, a standalone Raid Finder lockout, or a single difficulty.",
                    "**A new minimap button icon**, the neon mirrored-RR mark on a dark disc.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The load dialog was refreshed.** The prompt now reads \"Select Route,\" the route name is larger, and the route buttons are styled neon FULL and SKIP graphics, centered as a pair. The old Cancel button is replaced by a close button in the top-right corner matching the rest of the UI.",
                    "**The transmog browser dropdowns are relabeled and resized.** Each dropdown now carries a label (Exp, Raid, Boss, Class), the bars are sized to fit their contents instead of leaving empty space, and they cascade in a slight left-to-right stagger.",
                    "**The route line in the footer reads \"Route: Full\"** for the full-clear route (previously \"Standard\").",
                    "**Choosing a route is no longer locked in until you kill a boss.** If you reload or step out and back in before your first kill, the route picker reappears so you can still switch between Full and Skip, with a \"Continue?\" hint marking the route you'd picked. Once you've killed a boss, reloading quietly resumes that route and prints a one-line reminder of which route you're on and your progress.",
                    "**The minimap button and the /rr command both always open the full panel**, regardless of your \"On Login Show RetroRuns\" preference. That setting now applies only to how the panel appears when you log in outside a raid.",
                    "**Removed the \"What's New?\" label from the footer.** The version number stays, and the \"!\" still appears beside it when there's an update you haven't viewed.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**The SKIP button on the load dialog now stays locked until the specific shortcut its route uses is unlocked.** On raids with more than one skip (like Hellfire Citadel), it could previously light up as soon as any shortcut was unlocked, even one leading to a different boss.",
                    "**Picking FULL after previously choosing SKIP now correctly loads the full route.** If you'd selected SKIP earlier in a lockout, then reloaded and chose FULL, the addon could keep running the skip route. Your latest choice is now always honored.",
                    "**Corrected the portal marker on the Hellfire Citadel Mannoroth skip** so the waypoint sits on the Destructor's Rise portal.",
                    "**The transmog summary and browser now agree on collected items.** An appearance you owned through one difficulty could be tallied as still-needed in the main-panel summary while the browser correctly showed it collected; the two now count it the same way.",
                },
            },
        },
    },
    {
        version  = "2.0.1",
        date     = "2026-06-26",
        sections = {
            {
                heading = "Changed",
                bullets = {
                    "**The load dialog was refreshed.** The prompt now reads \"Select Route,\" the route name is larger, and the route buttons are styled neon FULL and SKIP graphics, centered as a pair. The old Cancel button is replaced by a close [X] in the corner matching the rest of the UI.",
                    "**The route line in the footer reads \"Route: Full\"** for the full-clear route (previously \"Standard\").",
                    "**Choosing a route is no longer locked in until you kill a boss.** If you reload or step out and back in before your first kill, the route picker reappears so you can still switch between Full and Skip -- with a \"Continue?\" hint marking the route you'd picked. Once you've killed a boss, reloading quietly resumes that route and prints a one-line reminder of which route you're on and your progress, instead of re-asking.",
                    "**The minimap button and the /rr command both always open the full panel**, regardless of your \"On Login Show RetroRuns\" preference. That setting now applies only to how the panel appears when you log in outside a raid.",
                    "**Removed the \"What's New?\" label from the footer.** The version number stays, and the \"!\" still appears beside it when there's an update you haven't viewed.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**The SKIP button on the load dialog now stays locked until the specific shortcut its route uses is unlocked.** On raids with more than one skip (like Hellfire Citadel), it could previously light up as soon as any shortcut was unlocked, even one leading to a different boss.",
                    "**Picking FULL after previously choosing SKIP now correctly loads the full route.** If you'd selected SKIP earlier in a lockout, then reloaded and chose FULL, the addon could keep running the skip route. Your latest choice is now always honored.",
                    "**Corrected the portal marker on the Hellfire Citadel Mannoroth skip** so the waypoint sits on the Destructor's Rise portal.",
                },
            },
        },
    },

    {
        version  = "2.0.0",
        date     = "2026-06-21",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Looking For Raid routing.** Queue into any LFR wing and RetroRuns lays out the path through that wing -- only the bosses you'll face, in the order you reach them, with the same walk-along directions, map lines, and waypoints as the full-raid routes. Wing progress and the per-difficulty pills track each wing on its own, so running a second wing of the same raid keeps its counts straight. This covers more than 80 wings across two dozen raids, spanning every expansion from Mists of Pandaria through Dragonflight. Expand any raid in the supported list to see its wings and per-wing progress at a glance.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**New travel icon, with a destination choice.** The travel icon beside each raid has a fresh look, and clicking it now lets you pick where to go: the raid entrance, or the Looking For Raid queue NPC.",
                    "**Skip-availability stars no longer appear next to the raid name while you're on an active route.** They stay in the supported-raids list and the Skips window, where they help you choose a route; once you're running one, the choice is already made.",
                    "**The Skips window difficulty columns read Normal, Heroic, Mythic from left to right** -- the traditional progression order, with Mythic on the right.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Continued refinement of routes and travel notes across raids** -- smoother paths and clearer directions in a number of places.",
                },
            },
        },
    },

}
