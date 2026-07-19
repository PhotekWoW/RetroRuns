-------------------------------------------------------------------------------
-- RetroRuns -- Locales/enUS.lua
-- Localized-string base. English is the source language: any string without
-- a translation in the active locale falls back to its English key. The RR.L
-- lookup itself is created in Core/Core.lua (first file to load) so every
-- later file's file-scope constructors can reference it.
-------------------------------------------------------------------------------

local RR = RetroRuns

--- Selects the active locale and applies its translations into RR.L.
-- Called twice: once from Locales/Apply.lua at load (client locale, so
-- file-scope strings in files that load after the Locales block capture
-- translated text), and again at ADDON_LOADED once SavedVariables exist
-- (the RetroRunsDB.devLocale override, when set, wins over the client
-- locale). Latin American Spanish shares the Spanish table.
function RR:ApplyLocale()
    local localeCode = RR.DEV_FORCE_LOCALE
        or (RetroRunsDB and RetroRunsDB.devLocale)
        or GetLocale()
    if localeCode == "esMX" then localeCode = "esES" end
    RR.activeLocaleCode = localeCode
    local translations = self.LocaleTables[localeCode]
    if not translations then return end
    for englishKey, translatedText in pairs(translations) do
        self.L[englishKey] = translatedText
    end
end
