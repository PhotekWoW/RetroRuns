-------------------------------------------------------------------------------
-- RetroRuns -- WhatsNew.lua
-- Player-facing release notes for the "What's New?" window.
-------------------------------------------------------------------------------
-- Last-N release entries shown to players when they click the version link
-- in the main panel footer. Hand-maintained at ship time: when CHANGELOG.md
-- gains a new release, prepend a matching entry here and drop the oldest
-- if the list exceeds the display target (currently 2 versions).
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
        version  = "1.11.0b",
        date     = "2026-05-26",
        sections = {
            {
                heading = "Changed",
                bullets = {
                    "**LFR support has been removed from the in-raid panel and from per-difficulty kill pills.** Until now, RetroRuns treated LFR as just another difficulty alongside Normal, Heroic, and Mythic -- same routing, same boss progress, same pill row. That assumption was incorrect. LFR splits each raid into multiple wings, each with its own boss subset and its own path through the instance; the routing data RetroRuns ships is authored for the full N/H/M layout and doesn't match any single wing. Players in LFR were seeing routing directions toward bosses that don't exist in their current wing, and pill counts that summed kills across all wings of the lockout. For now: when you zone into LFR, the in-raid panel shows a single message in place of the routing content, and LFR has been dropped from the pill row everywhere it appeared. Achievements and Transmog browsers continue to track LFR sources unchanged. Restoring full LFR support is a substantial project -- per-wing routing data for nearly every raid, queueing-NPC entrance handoffs for each expansion's LFR access point, and per-wing lockout tracking -- and it will land in a future release as a dedicated effort.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**The \"What's New?\" window no longer overflows past its bottom edge.** Long release-note entries are now contained inside a scrollable viewport; the window itself stays a fixed height and a scrollbar appears on the right when there's more content to read.",
                    "**Castle Nathria weapon-token section: redesigned for clarity.** The \"Main-Hand Weapons\" / \"Off-Hand Weapons\" lines used to carry a bracketed [some collected] / [all collected] / [none collected] label, but \"some\" gave the player no actionable signal about what they still needed. Each line now reads as a section heading naming the slot, the word \"Weapon Token\", and the classes that family covers -- e.g. \"Main-Hand Weapon Token: Hunter / Mage / Druid\". Bosses that drop tokens for every class in a slot (Sire Denathrius) show \"All classes\" instead of listing all 13. The redemption-vendor hint and its travel button now sit directly below the heading rather than below the color legend, so the boss -> redemption -> legend flow reads top-to-bottom in priority order.",
                },
            },
        },
    },

    {
        version  = "1.11.0a",
        date     = "2026-05-26",
        sections = {
            {
                heading = "Fixed",
                bullets = {
                    "**Vault of the Incarnates -- Eranog route on the map.** After landing from the dragon flight, the pink route lines could partially disappear or the end arrow could detach from the rest of the path. Eranog's approach has been redesigned with red destination circles at the dragon platform and at Volcanius, plus a clean arrow line up to Eranog.",
                },
            },
        },
    },

    {
        version  = "1.11.0",
        date     = "2026-05-26",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**Map markers and labels.** Points of interest on the world map can now carry a text label next to the icon -- useful for one-time interactive objects like teleport orbs, consoles, runes, and entrance arches that aren't obvious from a dot alone. Labels position around the icon to avoid colliding with map art, and can pulse gently while a click is pending, then switch to gray with a green check the moment the interaction completes. Red rings now highlight specific named map exits along a route. Star markers call out specific clickable objects. Visual cues like these have been added across several raids where the routing benefits from a more concrete pointer than a path line.",
                    "**Zygor waypoint-arrow detection.** If Zygor is loaded but the waypoint arrow is disabled in your Zygor settings, the entrance legend below the raid list now shows a red \"Waypoint Arrow Disabled -- Click to Enable\" warning. Clicking the warning flips the Zygor setting on for you.",
                    "**Suicide-jump shortcuts.** Several raids include ledge-jump shortcuts that skip a chunk of walking; travel notes now call these out where applicable.",
                },
            },
            {
                heading = "Changed",
                bullets = {
                    "**The travel-route navigation system has been rebuilt from the ground up.** Rolled out across all 17 supported raids. Map lines and travel directions follow you correctly when you backtrack to an earlier step's area instead of getting stuck on the latest step. Same-subZone cross-zone transitions advance cleanly without a transient flicker. Fewer \"Open the map and select a section...\" default-text flashes during zone transitions. Yell-triggered step advances now survive a mid-raid logout or reload -- both the advance memory and your step progress persist alongside the rest of your lockout, so reloading mid-step no longer rewinds your travel directions.",
                    "**Special Loot, Achievements, and Skips brackets are now visually aligned.** The \"not collected / not done / not unlocked\" red X is now a proper texture matching the size of the green check, so the brackets line up cleanly instead of the X reading narrower than the check.",
                    "**Per-difficulty kill-count pills now use the Boss Progress color palette.** Fully cleared difficulties (e.g. M 8/8) render in green, your active difficulty renders in yellow, and the rest render in gray -- matching the green-check / yellow-arrow / gray-pending grammar already used by the in-raid boss checklist below. A player sitting in a fully cleared difficulty sees green (complete trumps active).",
                    "**Uldir achievement soloability ratings refreshed.** Edgelords (Zul) and Existential Crisis (Mythrax) both moved from \"kinda\" to \"yes\" based on recent solo-run reports -- Edgelords needs only that you avoid the central square, and Existential Crisis's \"no other player touches an Existence Fragment\" condition is satisfied for free when you're solo.",
                    "**Solo strategy tips refreshed across several encounters.** Shorter, more direct, dropping mythic-only and class-specific caveats that weren't useful for solo runs.",
                },
            },
            {
                heading = "Fixed",
                bullets = {
                    "**Action buttons no longer occasionally appear with blank labels at game launch.** The Map / Tmog / Achieves / Skips / Settings buttons along the bottom of the panel previously used the addon's pixel font, applied with a direct font call that could fail on a cold startup if the font file wasn't fully cached yet -- leaving one of the buttons blank until a /reload. They now use the standard interface button font and render reliably on every launch.",
                    "**Zygor flight buttons no longer silently do nothing.** When Zygor's waypoint arrow setting was disabled, the addon's entrance click-to-navigate buttons were calling Zygor's waypoint API but Zygor was silently dropping the call. The new detection (above) surfaces this state and offers a one-click fix.",
                },
            },
        },
    },

    {
        version  = "1.10.2",
        date     = "2026-05-17",
        sections = {
            {
                heading = "Added",
                bullets = {
                    "**WaypointUI is now a recognized navigation handoff target.** WaypointUI joins the existing list of supported providers (AzerothWaypoint, Zygor, Mapzeroth, TomTom, and Blizzard's native waypoint) for the raid-entrance click handoff. The entrance-legend below the raid list shows which components are active on your install.",
                    "**The Skips window has been expanded with per-raid skip details.** Each row now has an [ i ] icon next to the raid name; click it to see exactly what unlocks the skip on that raid -- the quest name, the prerequisite kills, the teleporter or shortcut it opens up, and what difficulty levels the skip applies to.",
                    "**\"What's New?\" footer link.** The version number in the bottom-right corner of the panel is now a clickable button that opens a window with recent release notes. A pulsing yellow [!] indicator next to the link draws attention until you've opened the window for the current version.",
                    "**Launch mode setting.** Choose what RetroRuns does on login: open fully expanded, open in compact minimized mode, or stay hidden until you click the minimap icon. Setting lives in the Settings window. Default is minimized so the panel is reachable but not intrusive. Clicking \"Load\" on the in-raid prompt always opens the panel fully regardless of this setting -- you asked for the addon, you get the addon.",
                    "**Body font options.** Three choices for the panel's body text: Friz Quadrata (the default; matches WoW's native UI text), 04B_03 (pixel font; matches the addon's title bar for full retro feel), and VT323 (a clean terminal-style font, retro feel with comfortable readability). Header chrome (title, action buttons, footer) stays consistent across all three. Setting lives in the Settings window.",
                },
            },
        },
    },
}
