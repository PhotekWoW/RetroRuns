-------------------------------------------------------------------------------
-- RetroRuns -- Locales/Apply.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Applies the client locale's translations immediately at load. MUST stay the
-- last file in the Locales block of the TOC: locale tables register above it,
-- and files after it (UI) capture translated text in their file-scope
-- constructors.
-------------------------------------------------------------------------------

-- Developer override: set to a locale code ("esES") to run the addon in that
-- locale regardless of the client language. Applies from first load, so it
-- also covers strings and fonts captured at file scope. Must be nil in
-- anything that ships.
RetroRuns.DEV_FORCE_LOCALE = nil

RetroRuns:ApplyLocale()
