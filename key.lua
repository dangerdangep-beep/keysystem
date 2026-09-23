--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]
local Config = {
    -- [1] PlatoBoost Settings
    ServiceId       = 32730, -- Your PlatoBoost Service ID
    PlatoSecret     = "d9fcd891-cfa4-44cd-9e03-1ea56f7e4690", -- Your PlatoBoost Secret Key

    -- [2] Anti-Bypass / Global Secret Variable
    Secret          = "sdflkjfdslks@!#dlfjouqljsxnmcbxvx983274$#@dsflksjdf", -- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key, they won't be able to!
    
    -- [3] Scripts & Links
    MainScriptURL   = "https://raw.githubusercontent.com/dangerdangep-beep/keysystem/refs/heads/main/script.lua", -- The raw URL of your main script
    
    -- [4] Social Media Settings (Set to true to show, false to hide)
    ShowDiscord     = true,
    DiscordURL      = "https://discord.gg/dQmMtvRTCc",
    
    ShowInstagram   = false,
    InstagramURL    = "https://www.instagram.com/oyb0i/",
    
    ShowYoutube     = false,
    YoutubeURL      = "https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ",

    -- [5] File System
    KeyFileName     = "Mykey.txt", -- The name of the file where the valid key will be saved for auto-login

    -- [6] GUI Management
    OldGuiName      = "script", -- Name of the old GUI to destroy if it's already open
    MainGuiName     = "script", -- Name of the main script's GUI to check if it's already executing

    -- [7] Hub Information & UI Text
    HubName         = "OpleoniHaters", -- The main title shown at the top of the GUI
    HubDescription  = "OpleoniHaters" -- The text shown below the title
}
