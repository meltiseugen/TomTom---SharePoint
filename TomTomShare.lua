--[[--------------------------------------------------------------------------
--  TomTom - Auto Shared Party Point
--  This addon works as an extension for the classic TomTom Addon without changing its functionality
--
--  It adds the capability to create a new waypoint (using a key+mouse combination) that will be automatically shared
--  and visible by all the party members as an individual waypoint with a different style

--  * It is tracked independently from the rest of the TomTom waypoints.
--  * Everytime you create a new shared waypoint, the old one is removed. This applies to all party members.
--  * Adding a shared waypoint is done by LShift + LeftMouse click on the world map
--  * Removing a shared waypoint can be done either classically using TomTom RightClick on one and then selecting "Remove"
--  or by LShift + RightMouse click on it (this is only valid for the shared waypoint)
--  * Added a different icon for the shared waypoint to be distinguished from the normal ones
--
----------------------------------------------------------------------------]]



local AddonName, TomTomShare = ...




--[[--------------------------------------------------------------------------
--  Originally TomTom - _world_on_click
--
--  This function is a callback for when a waypoint is clicked on the world map
--  The click must be a RIGHT CLICK as that is how it is registered by the TomTom calling function
--  If the shift modifier is active, then the waypoint will be removed
--  Else, it will behave just like normal TomTom
----------------------------------------------------------------------------]]
local function overridden_world_on_click(event, uid, self, button)
    local shift = IsShiftKeyDown()
    if shift then
        TomTom:RemoveWaypoint(uid)
    else
        if TomTom.db.profile.worldmap.menu then
            TomTom.dropdown_uid = uid
            TomTom.worlddropdown:SetAnchor("TOPRIGHT", self, "BOTTOMLEFT", -25, -25)
            TomTom.worlddropdown:Toggle()
        end
    end
end




--[[--------------------------------------------------------------------------
--  Created the worldmap overlay and is responsible for handling events related to adding a shared waypoint
----------------------------------------------------------------------------]]
function TomTomShare:CreateWorldMapFrame()

    -- Create a new map overlay frame based on the original map frame
    -- Allow Right Clicks to be passed to the underlying component frame
    local handler = CreateFrame("Frame", AddonName .. "WorldMapClickHandler", WorldMapFrame.ScrollContainer)
    handler:SetPassThroughButtons("RightButton")

    -- When a LEFT MOUSE click is released call the function AddSharedWaypoint to add a new special waypoint
    handler:SetAllPoints()
    handler:SetScript("OnMouseUp", function(frame, button)
        SetIcon()
        -- TODO check for left mouse click
        TomTomShare:AddSharedWaypoint()
        ResetIcon()

    end)

    -- Only show this new frame when the LEFT SHIFT button is pressed
    -- This is to not interfere with the underlying frames and allow for normal interaction
    handler:RegisterEvent("MODIFIER_STATE_CHANGED")
    handler:SetScript("OnEvent", function(self, event, key, down)
        if key == "LSHIFT" and down == 1 then
            self:Show()
        else
            self:Hide()
        end
    end)

    -- By default, HIDE the new frame until the LEFT SHIFT is pressed
    handler:Hide()
end




--[[--------------------------------------------------------------------------
--  Responsible for cleaning the state, adding a new shared waypoint to the local player,
--  and sending the necessary change commands to other party members
----------------------------------------------------------------------------]]
function TomTomShare:AddSharedWaypoint()

    local m = WorldMapFrame.mapID
    local x,y = WorldMapFrame:GetNormalizedCursorPosition()

    if not m or m == 0 then return end

    local shift = IsShiftKeyDown()
    if shift then

        -- Set the default configuration of the shared waypoint
        opts = {}
        opts.title = Configs.sharedWaypointTitle
        opts.callbacks = TomTom:DefaultCallbacks(opts)
        -- add a overridden on click callback when RIGHT CLICK on waypoints
        opts.callbacks.world.onclick = overridden_world_on_click


        -- Remove the old saved shared waypoint
        TomTom:RemoveWaypoint(Configs.sharedWaypoint)

        -- Normalize the waypoint coords to have 5 decimal points
        -- This is needed to remove unwanted precision when sending the coords to party members
        -- in order to have their Configs.sharedWaypoint updated with the new one
        x = tonumber(string.format("%.5f", x))
        y = tonumber(string.format("%.5f", y))

        -- Add the new point and store it in a global variable
        Configs.sharedWaypoint = TomTom:AddWaypoint(m, x, y, opts)

        -- Send a command to party members that will remove their saved Configs.sharedWaypoint
        C_ChatInfo.SendAddonMessage(Configs.prefixCmd, Configs.CMD_CLEAR, "PARTY", Configs.fullPlayerName)

        -- Send a command to party members to switch to the icon style used by this addon
        C_ChatInfo.SendAddonMessage(Configs.prefixCmd, Configs.CMD_CHANGE_ICON, "PARTY", Configs.fullPlayerName)

        -- Using TomTom API, send the newly added waypoint to the party members
        TomTom:SendWaypoint(Configs.sharedWaypoint, "PARTY")

        -- Send a command to party members to switch back to the icon style used by TomTom
        C_ChatInfo.SendAddonMessage(Configs.prefixCmd, Configs.CMD_REVERT_ICON, "PARTY", Configs.fullPlayerName)

        -- In order for party members to have their Configs.sharedWaypoint updated, send the new waypoint's data
        local msg = string.format("%d:%f:%f:%s", m, x, y, Configs.sharedWaypointTitle)
        C_ChatInfo.SendAddonMessage(Configs.prefixUpdate, msg, "PARTY", Configs.fullPlayerName)
    end

end



--[[--------------------------------------------------------------------------
--                                 Main
----------------------------------------------------------------------------]]

C_ChatInfo.RegisterAddonMessagePrefix(Configs.prefixCmd)
C_ChatInfo.RegisterAddonMessagePrefix(Configs.prefixUpdate)

TomTomShare:CreateWorldMapFrame()
EventHandler.SetupGlobalEventHandler()
