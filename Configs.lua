
Configs = {}

Configs.prefixCmd = "TTPP_CMD"
Configs.prefixUpdate = "TTPP_UPDATE"

Configs.CMD_CLEAR = "CLEAR"
Configs.CMD_CHANGE_ICON = "CHANGE_ICON"
Configs.CMD_REVERT_ICON = "REVERT_ICON"

Configs.sharedWaypointTitle = "Shared Waypoint"
Configs.icon = "Interface\\AddOns\\TomTomShare\\Images\\diamond.tga"
Configs.iconSize = 24

Configs.defaultIcon = TomTom.profile.worldmap.default_icon
Configs.defaultIconSize = TomTom.profile.worldmap.default_iconsize

Configs.playerName, _ = UnitName("player")
Configs.realmName = GetRealmName()
Configs.fullPlayerName = string.format("%s-%s", Configs.playerName, Configs.realmName)
Configs.sharedWaypoint = nil
