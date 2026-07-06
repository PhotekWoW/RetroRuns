-------------------------------------------------------------------------------
-- RetroRuns -- Locales/enUS.lua
-- Localized-string base. English is the source language: any string without
-- a translation in the active locale falls back to its English key.
-------------------------------------------------------------------------------

local RR = RetroRuns

-- Lookup used by display code: RR.L["Some English text"] returns the active
-- locale's translation, or the English key itself when none exists.
RR.L = setmetatable({}, { __index = function(_, key) return key end })

-- Per-locale translation tables, keyed by locale code. Each locale file
-- registers its table here; ApplyLocale copies the active one into L.
RR.LocaleTables = {}

--- Selects the active locale and applies its translations into RR.L.
-- Runs once at ADDON_LOADED, after SavedVariables are available (the
-- RetroRunsDB.devLocale override, when set, wins over the client locale).
-- Latin American Spanish shares the Spanish table.
function RR:ApplyLocale()
    local localeCode = (RetroRunsDB and RetroRunsDB.devLocale) or GetLocale()
    if localeCode == "esMX" then localeCode = "esES" end
    local translations = self.LocaleTables[localeCode]
    if not translations then return end
    for englishKey, translatedText in pairs(translations) do
        self.L[englishKey] = translatedText
    end
end
