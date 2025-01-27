--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ArenaHistorianTBC = LibStub("AceAddon-3.0"):NewAddon("ArenaHistorianTBC", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaHistorianTBC")
local GetBattlefieldInstanceRunTime, GetBattlefieldScore, GetBattlefieldStatus, GetBattlefieldTeamInfo, GetBattlefieldWinner, GetNumBattlefieldScores, IsActiveBattlefieldArena = _G.GetBattlefieldInstanceRunTime, _G.GetBattlefieldScore, _G.GetBattlefieldStatus, _G.GetBattlefieldTeamInfo, _G.GetBattlefieldWinner, _G.GetNumBattlefieldScores, _G.IsActiveBattlefieldArena
local UnitAura, UnitCastingInfo, UnitChannelInfo, UnitClass, UnitFactionGroup, UnitGUID, UnitIsPlayer, UnitName, UnitRace, UnitSex = _G.UnitAura, _G.UnitCastingInfo, _G.UnitChannelInfo, _G.UnitClass, _G.UnitFactionGroup, _G.UnitGUID, _G.UnitIsPlayer, _G.UnitName, _G.UnitRace, _G.UnitSex
local CombatLogGetCurrentEventInfo, GetRealmName, IsInGroup, GetServerTime = _G.CombatLogGetCurrentEventInfo, _G.GetRealmName, _G.IsInGroup, _G.GetServerTime
local strformat, strgsub, strmatch, strupper = string.format, string.gsub, string.match, string.upper
local tconcat, tinsert, tremove = table.concat, table.insert, table.remove
local genderMap = {[1] = "FEMALE", [2] = "MALE", [3] = "FEMALE"}
ArenaHistorianTBC.Constants = {}
ArenaHistorianTBC.OnInitialize = function(self)
    self.db = LibStub("AceDB-3.0"):New("ArenaHistorianTBC", self.Constants.DB_DEFAULTS)
    if not ArenaHistoryTBCData then
        ArenaHistoryTBCData = {[2] = {}, [3] = {}, [5] = {}}
    end
    if not ArenaHistoryTBCCustomData then
        ArenaHistoryTBCCustomData = {}
    end
    self:DrawMinimapIcon()
    self:RegisterOptionsTable()
    self:Print("Tracking ready!")
    self:Reset()
end
ArenaHistorianTBC.Reset = function(self)
    self.status = self.Constants.Status.NONE
    self.stats = {playerTeamData = {}, enemyTeamData = {}}
    self.units = {}
    self.unitGuids = {}
end
ArenaHistorianTBC.OnEnable = function(self)
    self:RegisterEvent(self.Constants.BlizzardEvent.UPDATE_BATTLEFIELD_STATUS)
    self:RegisterEvent(self.Constants.BlizzardEvent.PLAYER_ENTERING_WORLD)
end
ArenaHistorianTBC.UPDATE_BATTLEFIELD_STATUS = function(self, _, index)
    local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, isRankedArena, suspendedQueue, bool, queueType = GetBattlefieldStatus(index)
    local isActiveArena, isRankedMatch = IsActiveBattlefieldArena()
    if status == self.Constants.Status.ACTIVE and teamSize > 0 and isActiveArena then
        self.status = status
        self.stats.isRanked = isRankedMatch
        self.bracket = teamSize
        self.map = self.GetZoneAbbr(mapName)
        self:JoinedArena()
    end
end
ArenaHistorianTBC.JoinedArena = function(self)
    self:RegisterEvent(self.Constants.BlizzardEvent.UPDATE_BATTLEFIELD_SCORE)
    self:RegisterEvent(self.Constants.BlizzardEvent.ARENA_OPPONENT_UPDATE)
    self:RegisterEvent(self.Constants.BlizzardEvent.COMBAT_LOG_EVENT_UNFILTERED)
    self:RegisterEvent(self.Constants.BlizzardEvent.UNIT_AURA)
    self:RegisterEvent(self.Constants.BlizzardEvent.UNIT_SPELLCAST_START)
    self:RegisterEvent(self.Constants.BlizzardEvent.UNIT_SPELLCAST_CHANNEL_START)
    self:RegisterEvent(self.Constants.BlizzardEvent.UNIT_SPELLCAST_SUCCEEDED)
    if not self.stats.startTime then
        self.stats.startTime = GetServerTime() * 1000
        self.Log("Start time: %d", self.stats.startTime)
    end
    if not self.units.player then
        self.unitGuids[UnitGUID("player")] = "player"
        self.units.player = {
            class = select(
                2,
                UnitClass("player")
            ),
            faction = select(
                2,
                UnitFactionGroup("player")
            ),
            gender = genderMap[UnitSex("player")],
            name = select(
                1,
                UnitName("player")
            ),
            race = select(
                2,
                UnitRace("player")
            ),
            spec = "",
            stats = {},
            team = -1
        }
    end
    self:SetPartyData()
end
ArenaHistorianTBC.SetPartyData = function(self)
    if IsInGroup() then
        if self.units.player and self.IsStringEmpty(self.units.player.spec) then
            self:ScanUnitAuras("player")
        end
        for i = 1, self.bracket - 1 do
            local unitId = "party" .. tostring(i)
            local unitGuid = UnitGUID(unitId)
            if unitGuid then
                self.unitGuids[unitGuid] = unitId
                if not self.units[unitId] then
                    self.units[unitId] = {
                        class = select(
                            2,
                            UnitClass(unitId)
                        ),
                        faction = select(
                            2,
                            UnitFactionGroup(unitId)
                        ),
                        gender = genderMap[UnitSex(unitId)],
                        name = "",
                        race = select(
                            2,
                            UnitRace(unitId)
                        ),
                        spec = "",
                        stats = {},
                        team = -1
                    }
                end
                local unit = self.units[unitId]
                if self.IsStringEmpty(unit.spec) then
                    self:ScanUnitAuras(unitId)
                end
                local unitName, server = UnitName(unitId)
                if not self.IsStringEmpty(unitName) and unitName ~= "Unknown" then
                    if not self.IsStringEmpty(server) and server ~= GetRealmName() then
                        unitName = strformat("%s-%s", unitName, server)
                    end
                    unit.name = unitName
                end
            end
        end
    end
end
ArenaHistorianTBC.SetLastArenaRankingData = function(self)
    for i = 1, GetNumBattlefieldScores() do
        local name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, className, classToken, damageDone, healingDone = GetBattlefieldScore(i)
        for unitId, unitInfo in pairs(self.units) do
            local nameNoRealm = unitInfo.name
            local match = strmatch(unitInfo.name, "-")
            if match then
                nameNoRealm = strmatch(unitInfo.name, "(.-)%-(.*)$")
            end
            if unitInfo.name == name or nameNoRealm == name then
                unitInfo.team = faction
                unitInfo.stats.damageDone = damageDone
                unitInfo.stats.healingDone = healingDone
                break
            end
        end
    end
    for unitId, unitInfo in pairs(self.units) do
        local nameNoRealm = unitInfo.name
        local server = GetRealmName()
        local match = strmatch(unitInfo.name, "-")
        if match then
            nameNoRealm, server = strmatch(unitInfo.name, "(.-)%-(.*)$")
        end
        if self.IsStringEmpty(unitInfo.spec) then
            local defaultSpec = self.defaultSpecs[unitInfo.class]
            self.Log("No spec detected. Using default spec. Name: %s, Class: %s, DefaultSpec: %s", unitInfo.name, unitInfo.class, defaultSpec)
            unitInfo.spec = defaultSpec
        end
        local data = strformat(
            "%s,%s,%s,%s,%s,%s",
            nameNoRealm,
            unitInfo.spec,
            unitInfo.class,
            strformat(
                "%s_%s",
                strupper(unitInfo.race),
                unitInfo.gender
            ),
            unitInfo.stats.healingDone or 0,
            unitInfo.stats.damageDone or 0
        )
        if unitInfo.team == self.units.player.team then
            tinsert(self.stats.playerTeamData, data)
        else
            if self.IsStringEmpty(self.stats.enemyServer) then
                self.stats.enemyServer = server
            end
            tinsert(self.stats.enemyTeamData, data)
        end
    end
    local winningTeam = GetBattlefieldWinner()
    if winningTeam == 255 then
        self.stats.playerWon = 0
    elseif winningTeam == self.units.player.team then
        self.stats.playerWon = 1
    else
        self.stats.playerWon = -1
    end
    for i = 0, 1 do
        local teamName, oldTeamRating, newTeamRating, teamMMR = GetBattlefieldTeamInfo(i)
        if teamMMR > 0 then
            if i == self.units.player.team then
                self.stats.teamName = teamName
                self.stats.oldTeamRating = oldTeamRating
                self.stats.newTeamRating = newTeamRating
                self.stats.diffRating = newTeamRating - oldTeamRating
                self.stats.mmr = teamMMR
            else
                self.stats.enemyTeamName = teamName
                self.stats.enemyOldTeamRating = oldTeamRating
                self.stats.enemyNewTeamRating = newTeamRating
                self.stats.enemyDiffRating = newTeamRating - oldTeamRating
                self.stats.enemyMmr = teamMMR
            end
        else
            self.stats.teamName = "SkirmishPlayerTeam"
            self.stats.oldTeamRating = 0
            self.stats.newTeamRating = 0
            self.stats.diffRating = 0
            self.stats.mmr = 0
            self.stats.enemyTeamName = "SkirmishEnemyTeam"
            self.stats.enemyOldTeamRating = 0
            self.stats.enemyNewTeamRating = 0
            self.stats.enemyDiffRating = 0
            self.stats.enemyMmr = 0
        end
    end
end
ArenaHistorianTBC.DetectSpec = function(self, unitId, spec)
    local unit = self.units[unitId]
    if not unit or self.IsStringEmpty(spec) or not self.IsStringEmpty(unit.spec) then
        return
    end
    if not self.possibleSpecs[unit.class][spec] then
        self.Log("Attempting to set impossible spec, unitName: %s, spec: %s, class: %s", unit.name, spec, unit.class)
        return
    end
    unit.spec = spec
end
ArenaHistorianTBC.SpotEnemy = function(self, unitId, scanAuras)
    local unit = self.units[unitId]
    if not unitId or not unit then
        return
    end
    local unitName, server = UnitName(unitId)
    if not self.IsStringEmpty(unitName) and unitName ~= "Unknown" then
        if self.IsStringEmpty(server) then
            server = GetRealmName()
        end
        unitName = strformat("%s-%s", unitName, server)
        unit.name = unitName
    end
    unit.class = select(
        2,
        UnitClass(unitId)
    )
    unit.faction = select(
        2,
        UnitFactionGroup(unitId)
    )
    unit.race = select(
        2,
        UnitRace(unitId)
    )
    unit.gender = genderMap[UnitSex(unitId)]
    self.unitGuids[UnitGUID(unitId)] = unitId
    if scanAuras then
        self:ScanUnitAuras(unitId)
    end
end
ArenaHistorianTBC.ScanUnitAuras = function(self, unitId)
    local unit = self.units[unitId]
    if not unit then
        return
    end
    if self.IsStringEmpty(unit.spec) then
        for n = 1, 30 do
            local spellName, texture, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitAura(unitId, n, "HELPFUL")
            if not spellID then
                break
            end
            local spec = self.specBuffs[spellName]
            if spec then
                local unitPet = strgsub(unitId, "%d$", "pet%1")
                if not self.IsStringEmpty(unitCaster) and (UnitIsUnit(unitId, unitCaster) or UnitIsUnit(unitPet, unitCaster)) then
                    self:DetectSpec(unitId, spec)
                end
            end
        end
    end
end
ArenaHistorianTBC.RecordArena = function(self)
    local index = strformat(
        "%d::%s::%s",
        time(),
        self.stats.teamName or "",
        self.stats.enemyTeamName or ""
    )
    local data = strformat(
        "%s:%d:%d:%s:%d:%s:%d:%d:%d:%d:%s:%s;%s;%s",
        self.map,
        self.bracket,
        self.stats.runTime,
        self.stats.playerWon,
        self.stats.mmr,
        self.stats.newTeamRating,
        self.stats.diffRating,
        self.stats.enemyMmr,
        self.stats.enemyNewTeamRating,
        self.stats.enemyDiffRating,
        self.stats.enemyServer or "",
        GetRealmName(),
        tconcat(self.stats.playerTeamData, ":"),
        tconcat(self.stats.enemyTeamData, ":")
    )
    ArenaHistoryTBCData[self.bracket][index] = data
    self:Print("Arena match recorded")
    self:Reset()
end
ArenaHistorianTBC.UPDATE_BATTLEFIELD_SCORE = function(self)
    local battlefieldWinner = GetBattlefieldWinner()
    if battlefieldWinner == nil then
        return
    end
    if self.status ~= self.Constants.Status.NONE then
        local arenaRunTime = GetBattlefieldInstanceRunTime()
        self.stats.endTime = GetServerTime() * 1000
        if arenaRunTime and arenaRunTime > 0 then
            self.stats.runTime = arenaRunTime
        elseif self.stats.startTime and self.stats.endTime and self.stats.startTime > 0 and self.stats.endTime > 0 then
            self.stats.runTime = self.stats.endTime - self.stats.startTime
        else
            self.stats.runTime = 0
        end
        self:SetLastArenaRankingData()
        self:RecordArena()
    end
end
ArenaHistorianTBC.ARENA_OPPONENT_UPDATE = function(self, _, unitId, updateReason)
    if updateReason == self.Constants.ArenaOpponentUpdateReason.SEEN and UnitIsPlayer(unitId) then
        self:SetPartyData()
        if not self.units[unitId] then
            self.units[unitId] = {
                class = "",
                faction = "",
                gender = "",
                name = "",
                race = "",
                spec = "",
                stats = {},
                team = -1
            }
        end
        if self.IsStringEmpty(self.units[unitId].name) then
            self:SpotEnemy(unitId, true)
        end
    end
end
ArenaHistorianTBC.COMBAT_LOG_EVENT_UNFILTERED = function(self)
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()
    local srcUnit = self.unitGuids[sourceGUID]
    local destUnit = self.unitGuids[destGUID]
    if destUnit then
        if self.IsStringEmpty(self.units[destUnit].name) then
            self:SpotEnemy(destUnit, true)
        end
    end
    if srcUnit then
        if self.IsStringEmpty(self.units[srcUnit].name) then
            self:SpotEnemy(srcUnit, true)
        end
        local spec = self.specSpells[spellName]
        if spec and self.IsStringEmpty(self.units[srcUnit].spec) then
            self:DetectSpec(srcUnit, spec)
        end
    end
end
ArenaHistorianTBC.PLAYER_ENTERING_WORLD = function(self)
    self:Reset()
end
ArenaHistorianTBC.UNIT_AURA = function(self, unitId)
    local unit = self.units[unitId]
    if not unit then
        return
    end
    if self.IsStringEmpty(unit.name) then
        self:SpotEnemy(unitId, false)
    end
    if self.IsStringEmpty(unit.spec) then
        for i = 1, 2 do
            local filter = i == 1 and "HELPFUL" or "HARMFUL"
            for n = 1, 30 do
                local spellName, texture, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitAura(unitId, n, filter)
                if not spellID then
                    break
                end
                local spec = self.specBuffs[spellName]
                if spec then
                    local unitPet = strgsub(unitId, "%d$", "pet%1")
                    if not self.IsStringEmpty(unitCaster) and (UnitIsUnit(unitId, unitCaster) or UnitIsUnit(unitPet, unitCaster)) then
                        self:DetectSpec(unitId, spec)
                    end
                end
            end
        end
    end
end
ArenaHistorianTBC.UNIT_SPELLCAST_START = function(self, unitId)
    local unit = self.units[unitId]
    if not unit then
        return
    end
    local spellName = UnitCastingInfo(unitId)
    local spec = self.specSpells[spellName]
    if spec and self.IsStringEmpty(unit.spec) then
        self:DetectSpec(unitId, spec)
    end
end
ArenaHistorianTBC.UNIT_SPELLCAST_CHANNEL_START = function(self, unitId)
    local unit = self.units[unitId]
    if not unit then
        return
    end
    local spellName = UnitChannelInfo(unitId)
    local spec = self.specSpells[spellName]
    if spec and self.IsStringEmpty(unit.spec) then
        self:DetectSpec(unitId, spec)
    end
end
ArenaHistorianTBC.UNIT_SPELLCAST_SUCCEEDED = function(self, unitId)
    local unit = self.units[unitId]
    if not unit then
        return
    end
    local spellName = UnitCastingInfo(unitId)
    local spec = self.specSpells[spellName]
    if spec and self.IsStringEmpty(unit.spec) then
        self:DetectSpec(unitId, spec)
    end
end
ArenaHistorianTBC.AddEntryToHistory = function(self, stats)
    tinsert(self.db.char.history, stats)
    if self.db.profile.maxHistory > 0 then
        while #self.db.char.history > self.db.profile.maxHistory do
            tremove(self.db.char.history, 1)
        end
    end
end
ArenaHistorianTBC.IsStringEmpty = function(str)
    return str == nil or str == ""
end
ArenaHistorianTBC.GetZoneAbbr = function(mapName)
    local zoneText = ""
    if mapName == L["Blade's Edge Arena"] then
        zoneText = "BEA"
    elseif mapName == L["Nagrand Arena"] then
        zoneText = "NA"
    elseif mapName == L["Ruins of Lordaeron"] then
        zoneText = "RoL"
    end
    return zoneText
end
ArenaHistorianTBC.Log = function(...)
    if DLAPI then
        DLAPI.DebugLog("ArenaHistorianTBC", ...)
    end
end
return ____exports
