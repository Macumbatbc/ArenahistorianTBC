--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaHistorianTBC", true)
local ArenaHistorianTBC = LibStub("AceAddon-3.0"):GetAddon("ArenaHistorianTBC")
local Status = Status or ({})
Status.ACTIVE = "active"
Status.NONE = "none"
local BlizzardEvent = BlizzardEvent or ({})
BlizzardEvent.ARENA_OPPONENT_UPDATE = "ARENA_OPPONENT_UPDATE"
BlizzardEvent.COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG_EVENT_UNFILTERED"
BlizzardEvent.PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD"
BlizzardEvent.UNIT_AURA = "UNIT_AURA"
BlizzardEvent.UNIT_SPELLCAST_START = "UNIT_SPELLCAST_START"
BlizzardEvent.UNIT_SPELLCAST_CHANNEL_START = "UNIT_SPELLCAST_CHANNEL_START"
BlizzardEvent.UNIT_SPELLCAST_SUCCEEDED = "UNIT_SPELLCAST_SUCCEEDED"
BlizzardEvent.UPDATE_BATTLEFIELD_SCORE = "UPDATE_BATTLEFIELD_SCORE"
BlizzardEvent.UPDATE_BATTLEFIELD_STATUS = "UPDATE_BATTLEFIELD_STATUS"
local ArenaOpponentUpdateReason = ArenaOpponentUpdateReason or ({})
ArenaOpponentUpdateReason.SEEN = "seen"
ArenaOpponentUpdateReason.DESTROYED = "destroyed"
ArenaOpponentUpdateReason.UNSEEN = "unseen"
ArenaOpponentUpdateReason.CLEARED = "cleared"
local DB_DEFAULTS = {char = {
    enableMax = false,
    maxRecords = 0,
    enableWeek = false,
    maxWeeks = 0,
    arenaPoints = 0,
    lastBracket = 2,
    lastType = "history",
    history = {}
}, profile = {maxHistory = 0, minimapButton = {hide = false}}}
ArenaHistorianTBC.Constants.BlizzardEvent = BlizzardEvent
ArenaHistorianTBC.Constants.Status = Status
ArenaHistorianTBC.Constants.ArenaOpponentUpdateReason = ArenaOpponentUpdateReason
ArenaHistorianTBC.Constants.DB_DEFAULTS = DB_DEFAULTS
local specBuffs = {
    [GetSpellInfo(45283)] = L.Restoration,
    [GetSpellInfo(16880)] = L.Restoration,
    [GetSpellInfo(24858)] = L.Restoration,
    [GetSpellInfo(17007)] = L.Feral,
    [GetSpellInfo(16188)] = L.Restoration,
    [GetSpellInfo(34692)] = L["Beast Mastery"],
    [GetSpellInfo(20895)] = L["Beast Mastery"],
    [GetSpellInfo(34455)] = L["Beast Mastery"],
    [GetSpellInfo(27066)] = L.Marksmanship,
    [GetSpellInfo(33405)] = L.Frost,
    [GetSpellInfo(11129)] = L.Fire,
    [GetSpellInfo(12042)] = L.Arcane,
    [GetSpellInfo(12043)] = L.Arcane,
    [GetSpellInfo(12472)] = L.Frost,
    [GetSpellInfo(31836)] = L.Holy,
    [GetSpellInfo(31842)] = L.Holy,
    [GetSpellInfo(20216)] = L.Holy,
    [GetSpellInfo(20375)] = L.Retribution,
    [GetSpellInfo(20049)] = L.Retribution,
    [GetSpellInfo(20218)] = L.Retribution,
    [GetSpellInfo(15473)] = L.Shadow,
    [GetSpellInfo(45234)] = L.Discipline,
    [GetSpellInfo(27811)] = L.Discipline,
    [GetSpellInfo(33142)] = L.Holy,
    [GetSpellInfo(14752)] = L.Discipline,
    [GetSpellInfo(27681)] = L.Discipline,
    [GetSpellInfo(10060)] = L.Discipline,
    [GetSpellInfo(33206)] = L.Discipline,
    [GetSpellInfo(14893)] = L.Discipline,
    [GetSpellInfo(36554)] = L.Subtlety,
    [GetSpellInfo(44373)] = L.Subtlety,
    [GetSpellInfo(36563)] = L.Subtlety,
    [GetSpellInfo(14278)] = L.Subtlety,
    [GetSpellInfo(31233)] = L.Assassination,
    [GetSpellInfo(16190)] = L.Restoration,
    [GetSpellInfo(32594)] = L.Restoration,
    [GetSpellInfo(30823)] = L.Enhancement,
    [GetSpellInfo(19028)] = L.Demonology,
    [GetSpellInfo(23759)] = L.Demonology,
    [GetSpellInfo(30302)] = L.Destruction,
    [GetSpellInfo(34935)] = L.Destruction,
    [GetSpellInfo(29838)] = L.Arms,
    [GetSpellInfo(12292)] = L.Arms
}
local specSpells = {
    [GetSpellInfo(33831)] = L.Balance,
    [GetSpellInfo(33983)] = L.Feral,
    [GetSpellInfo(33987)] = L.Feral,
    [GetSpellInfo(18562)] = L.Restoration,
    [GetSpellInfo(16188)] = L.Restoration,
    [GetSpellInfo(19577)] = L["Beast Mastery"],
    [GetSpellInfo(34490)] = L.Marksmanship,
    [GetSpellInfo(27068)] = L.Survival,
    [GetSpellInfo(19306)] = L.Survival,
    [GetSpellInfo(27066)] = L.Marksmanship,
    [GetSpellInfo(12042)] = L.Arcane,
    [GetSpellInfo(33043)] = L.Fire,
    [GetSpellInfo(33933)] = L.Fire,
    [GetSpellInfo(33405)] = L.Frost,
    [GetSpellInfo(31687)] = L.Frost,
    [GetSpellInfo(12472)] = L.Frost,
    [GetSpellInfo(11958)] = L.Frost,
    [GetSpellInfo(33072)] = L.Holy,
    [GetSpellInfo(20216)] = L.Holy,
    [GetSpellInfo(31842)] = L.Holy,
    [GetSpellInfo(32700)] = L.Protection,
    [GetSpellInfo(27170)] = L.Retribution,
    [GetSpellInfo(35395)] = L.Retribution,
    [GetSpellInfo(20066)] = L.Retribution,
    [GetSpellInfo(20218)] = L.Retribution,
    [GetSpellInfo(10060)] = L.Discipline,
    [GetSpellInfo(33206)] = L.Discipline,
    [GetSpellInfo(14752)] = L.Discipline,
    [GetSpellInfo(33143)] = L.Holy,
    [GetSpellInfo(34861)] = L.Holy,
    [GetSpellInfo(15473)] = L.Shadow,
    [GetSpellInfo(34917)] = L.Shadow,
    [GetSpellInfo(34413)] = L.Assassination,
    [GetSpellInfo(14177)] = L.Assassination,
    [GetSpellInfo(13750)] = L.Combat,
    [GetSpellInfo(14185)] = L.Subtlety,
    [GetSpellInfo(16511)] = L.Subtlety,
    [GetSpellInfo(36554)] = L.Subtlety,
    [GetSpellInfo(14278)] = L.Subtlety,
    [GetSpellInfo(14183)] = L.Subtlety,
    [GetSpellInfo(16166)] = L.Elemental,
    [GetSpellInfo(30823)] = L.Enhancement,
    [GetSpellInfo(17364)] = L.Enhancement,
    [GetSpellInfo(16190)] = L.Restoration,
    [GetSpellInfo(32594)] = L.Restoration,
    [GetSpellInfo(30405)] = L.Affliction,
    [GetSpellInfo(30414)] = L.Destruction,
    [GetSpellInfo(30330)] = L.Arms,
    [GetSpellInfo(12292)] = L.Arms,
    [GetSpellInfo(30335)] = L.Fury,
    [GetSpellInfo(12809)] = L.Protection,
    [GetSpellInfo(30022)] = L.Protection
}
local possibleSpecs = {
    DRUID = {[L.Balance] = true, [L.Feral] = true, [L.Restoration] = true},
    HUNTER = {[L["Beast Mastery"]] = true, [L.Marksmanship] = true, [L.Survival] = true},
    MAGE = {[L.Arcane] = true, [L.Fire] = true, [L.Frost] = true},
    PALADIN = {[L.Holy] = true, [L.Protection] = true, [L.Retribution] = true},
    PRIEST = {[L.Discipline] = true, [L.Holy] = true, [L.Shadow] = true},
    ROGUE = {[L.Assassination] = true, [L.Combat] = true, [L.Subtlety] = true},
    SHAMAN = {[L.Elemental] = true, [L.Enhancement] = true, [L.Restoration] = true},
    WARLOCK = {[L.Affliction] = true, [L.Demonology] = true, [L.Destruction] = true},
    WARRIOR = {[L.Arms] = true, [L.Fury] = true, [L.Protection] = true}
}
local defaultSpecs = {
    DRUID = L.Restoration,
    HUNTER = L.Marksmanship,
    MAGE = L.Frost,
    PALADIN = L.Retribution,
    PRIEST = L.Discipline,
    ROGUE = L.Subtlety,
    SHAMAN = L.Enhancement,
    WARLOCK = L.Demonology,
    WARRIOR = L.Arms
}
ArenaHistorianTBC.specBuffs = specBuffs
ArenaHistorianTBC.specSpells = specSpells
ArenaHistorianTBC.defaultSpecs = defaultSpecs
ArenaHistorianTBC.possibleSpecs = possibleSpecs
return ____exports
