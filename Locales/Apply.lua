-------------------------------------------------------------------------------
-- RetroRuns -- Locales/Apply.lua
-- Applies the client locale's translations immediately at load. MUST stay the
-- last file in the Locales block of the TOC: locale tables register above it,
-- and files after it (UI) capture translated text in their file-scope
-- constructors. A second ApplyLocale runs at ADDON_LOADED for the devLocale
-- SavedVariables override.
-------------------------------------------------------------------------------

-- Developer override: set to a locale code ("esES") to run the addon in that
-- locale regardless of the client language. Applies from first load, so it
-- also covers strings and fonts captured at file scope, unlike the
-- RetroRunsDB.devLocale override (which arrives with SavedVariables, after
-- those are already built). Must be nil in anything that ships.
RetroRuns.DEV_FORCE_LOCALE = nil

RetroRuns:ApplyLocale()
