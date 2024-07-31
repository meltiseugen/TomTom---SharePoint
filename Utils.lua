



function SetIcon()
    TomTom.profile.minimap.default_icon = Configs.icon
    TomTom.profile.worldmap.default_icon = Configs.icon

    TomTom.profile.minimap.default_iconsize = Configs.iconSize
    TomTom.profile.worldmap.default_iconsize = Configs.iconSize
end






function ResetIcon()
    TomTom.profile.minimap.default_icon = Configs.defaultIcon
    TomTom.profile.worldmap.default_icon = Configs.defaultIcon

    TomTom.profile.minimap.default_iconsize = Configs.defaultIconSize
    TomTom.profile.worldmap.default_iconsize = Configs.defaultIconSize
end