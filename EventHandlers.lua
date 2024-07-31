--[[--------------------------------------------------------------------------
--  TomTom - EventHandler
--  This file is responsible for processing events and updates received from the other party members
--  e.g What to do when someone else has added a shared waypoint
--
----------------------------------------------------------------------------]]

EventHandler = {}

local globalFrame = CreateFrame("Frame")


--[[--------------------------------------------------------------------------
--  This function handles commands prefix received from other party members
--  * Removes the saved shared waypoint if exists
--  * Switch back and forth between icon styles
----------------------------------------------------------------------------]]
function globalFrame:TTPP_CMD(command)
    if command == Configs.CMD_CLEAR then
        if Configs.sharedWaypoint then
            TomTom:RemoveWaypoint(Configs.sharedWaypoint)
        end
    end

    if command == Configs.CMD_CHANGE_ICON then
        SetIcon()
    end

    if command == Configs.CMD_REVERT_ICON then
        ResetIcon()
    end
end


--[[--------------------------------------------------------------------------
--  This function handles update prefix received from other party members
--  * Updates the local sharedWaypoint to match the one from the sender
----------------------------------------------------------------------------]]
function globalFrame:TTPP_UPDATE(update_data)
    local m, x, y, title = string.split(":", update_data)

    m = tonumber(m)
    x = tonumber(x)
    y = tonumber(y)

    local exists = TomTom:WaypointExists(m, x, y, title)
    if exists then
        local key = TomTom:GetKeyArgs(m, x, y, title)
        local waypoint = TomTom.waypoints[m][key]
        Configs.sharedWaypoint = waypoint
    end
end


--[[--------------------------------------------------------------------------
--  This function handles the addon specific prefixes and calls the
--  responsible handlers
----------------------------------------------------------------------------]]
function globalFrame:CHAT_MSG_ADDON(received_prefix, data, channel, sender)
    if sender == Configs.fullPlayerName then return end

    if received_prefix == Configs.prefixCmd then
        globalFrame:TTPP_CMD(data)
    end

    if received_prefix == Configs.prefixUpdate then
        globalFrame:TTPP_UPDATE(data)
    end
end


--[[--------------------------------------------------------------------------
--  This function is responsible for setting up a global frame on when to
--  receive addon specific events
----------------------------------------------------------------------------]]
function SetupGlobalEventHandler()
    globalFrame:RegisterEvent("CHAT_MSG_ADDON")
    globalFrame:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)

end


EventHandler.SetupGlobalEventHandler = SetupGlobalEventHandler
