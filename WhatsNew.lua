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

    {
        version  = "1.10.1",
        date     = "2026-05-16",
        sections = {
            {
                heading = "Fixed",
                bullets = {
                    "Fixed an issue with Blackwater Behemoth navigation steps in The Eternal Palace.",
                },
            },
        },
    },
}
