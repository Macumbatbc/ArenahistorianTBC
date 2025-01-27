--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local addonName = "ArenaHistorianTBC"
local ArenaHistorianTBC = LibStub("AceAddon-3.0"):GetAddon("ArenaHistorianTBC")
local name, addonTitle, addonNotes = GetAddOnInfo(addonName)
local Config = ArenaHistorianTBC:NewModule("Config")
local AceConfig = LibStub("AceConfig-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaHistorianTBC")
Config.OnInitialize = function()
    SLASH_ARENAHISTORIANTBC1 = "/ahh"
    SlashCmdList.ARENAHISTORIANTBC = function(msg)
        msg = string.lower(msg or "")
        if msg == "history" or msg == "ui" or msg == "h" then
            ArenaHistorianTBC:Show()
        elseif msg == "config" then
            InterfaceOptionsFrame_OpenToCategory(addonName)
            InterfaceOptionsFrame_OpenToCategory(addonName)
        else
            DEFAULT_CHAT_FRAME:AddMessage(L["ArenaHistorianTBC slash commands"])
            DEFAULT_CHAT_FRAME:AddMessage(L[" - h or history - Shows the arena history panel"])
            DEFAULT_CHAT_FRAME:AddMessage(L[" - config - Opens the OptionHouse configuration panel"])
            DEFAULT_CHAT_FRAME:AddMessage(L[" - clean - Forces a history check to be ran, will remove anything that doesn't match the options set in the configuration."])
        end
    end
end
ArenaHistorianTBC.RegisterOptionsTable = function(self)
    AceConfig:RegisterOptionsTable(
        addonName,
        {
            name = addonName,
            descStyle = "inline",
            handler = ArenaHistorianTBC,
            type = "group",
            args = {
                Toggle = {
                    order = 0,
                    type = "execute",
                    name = L.Toggle,
                    desc = L["Opens or closes the main window"],
                    func = function() return self:Toggle() end
                },
                General = {
                    order = 1,
                    type = "group",
                    name = L.Options,
                    args = {
                        intro = {order = 0, type = "description", name = addonNotes},
                        group1 = {
                            order = 10,
                            type = "group",
                            name = L["Database Settings"],
                            inline = true,
                            args = {
                                maxHistory = {
                                    order = 11,
                                    type = "range",
                                    name = L["Maximum history records"],
                                    desc = L["Arena records can impact memory usage (0 means unlimited)"],
                                    min = 0,
                                    max = 1000,
                                    step = 10,
                                    get = function()
                                        return self.db.profile.maxHistory
                                    end,
                                    set = function(_, val)
                                        self.db.profile.maxHistory = val
                                    end
                                },
                                purge = {
                                    order = 19,
                                    type = "execute",
                                    name = L["Purge database"],
                                    desc = L["Delete all collected data"],
                                    confirm = true,
                                    func = function()
                                        self:ResetDatabase()
                                    end
                                }
                            }
                        },
                        group2 = {
                            order = 20,
                            type = "group",
                            name = L["Minimap Button Settings"],
                            inline = true,
                            args = {minimapButton = {
                                order = 21,
                                type = "toggle",
                                name = L["Show minimap button"],
                                get = function()
                                    return not self.db.profile.minimapButton.hide
                                end,
                                set = "ToggleMinimapButton"
                            }}
                        }
                    }
                },
                Profiles = AceDBOptions:GetOptionsTable(ArenaHistorianTBC.db)
            }
        },
        {"arenahistoriantbc"}
    )
    AceConfigDialog:AddToBlizOptions(addonName, nil, nil, "General")
    AceConfigDialog:AddToBlizOptions(addonName, "Profiles", addonName, "Profiles")
end
return ____exports
