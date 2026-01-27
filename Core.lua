-- DropWorldMarker: Place world markers at cursor with keybind, cycling through selected markers

local addonName, addon = ...
DropWorldMarker = addon

-- Marker data: index, name
addon.MARKERS = {
    { index = 1, name = "Square" },
    { index = 2, name = "Triangle" },
    { index = 3, name = "Diamond" },
    { index = 4, name = "Cross" },
    { index = 5, name = "Star" },
    { index = 6, name = "Circle" },
    { index = 7, name = "Moon" },
    { index = 8, name = "Skull" },
}

-- Default settings
local defaults = {
    markerSequence = { 1, 2, 3, 4, 5, 6, 7, 8 },
    showChatMessage = true,
}

-- Create the main secure button using secure handler for combat support
local mainButton = CreateFrame("Button", "DWMPlaceBtn", UIParent, "SecureActionButtonTemplate")
mainButton:SetAttribute("type", "macro")
mainButton:SetAttribute("macrotext", "/wm [@cursor] 1")
mainButton:SetAttribute("sequencePos", 1)
mainButton:SetAttribute("sequenceLen", 8)
mainButton:RegisterForClicks("AnyUp")
mainButton:Hide()

-- Secure pre-click handler - this runs in secure environment BEFORE the action
SecureHandlerWrapScript(mainButton, "PreClick", mainButton, [[
    local pos = self:GetAttribute("sequencePos") or 1
    local len = self:GetAttribute("sequenceLen") or 0

    if len > 0 then
        -- Get the marker at current position
        local marker = self:GetAttribute("marker" .. pos)
        if marker then
            self:SetAttribute("macrotext", "/wm [@cursor] " .. marker)
        end

        -- Advance to next position for next click
        pos = pos + 1
        if pos > len then
            pos = 1
        end
        self:SetAttribute("sequencePos", pos)
    end
]])

-- PostClick for chat feedback (this is insecure, just for messages)
mainButton:SetScript("PostClick", function(self)
    if DropWorldMarkerDB.showChatMessage then
        local macrotext = self:GetAttribute("macrotext")
        local markerIndex = tonumber(macrotext:match("%d+$"))
        if markerIndex then
            local markerInfo = addon.MARKERS[markerIndex]
            if markerInfo then
                print("|cFF00FF00DropWorldMarker:|r Placed " .. markerInfo.name)
            end
        end
    end
end)

-- Create the clear button
local clearButton = CreateFrame("Button", "DWMClearBtn", UIParent, "SecureActionButtonTemplate")
clearButton:SetAttribute("type", "macro")
clearButton:SetAttribute("macrotext", "/cwm all")
clearButton:RegisterForClicks("AnyUp")
clearButton:Hide()

clearButton:SetScript("PostClick", function(self)
    -- Reset sequence position (only works out of combat)
    if not InCombatLockdown() then
        mainButton:SetAttribute("sequencePos", 1)
    end

    if DropWorldMarkerDB.showChatMessage then
        print("|cFF00FF00DropWorldMarker:|r Cleared all markers")
    end
end)

-- Function to sync sequence from saved variables to button attributes
-- Must be called out of combat
function addon:SyncSequenceToButton()
    if InCombatLockdown() then
        print("|cFFFF6600DropWorldMarker:|r Cannot update sequence during combat")
        return
    end

    local sequence = DropWorldMarkerDB.markerSequence or {}

    -- Clear old marker attributes
    for i = 1, 8 do
        mainButton:SetAttribute("marker" .. i, nil)
    end

    -- Set new marker attributes
    for i, markerIndex in ipairs(sequence) do
        mainButton:SetAttribute("marker" .. i, markerIndex)
    end

    mainButton:SetAttribute("sequenceLen", #sequence)
    mainButton:SetAttribute("sequencePos", 1)

    -- Set initial macrotext
    if #sequence > 0 then
        mainButton:SetAttribute("macrotext", "/wm [@cursor] " .. sequence[1])
    end
end

-- Reset the sequence to start from the beginning
function addon:ResetCycle()
    if not InCombatLockdown() then
        mainButton:SetAttribute("sequencePos", 1)
        local sequence = DropWorldMarkerDB.markerSequence or {}
        if #sequence > 0 then
            mainButton:SetAttribute("macrotext", "/wm [@cursor] " .. sequence[1])
        end
    end
end

-- Slash commands
SLASH_DROPWORLDMARKER1 = "/dwm"
SLASH_DROPWORLDMARKER2 = "/dropworldmarker"
SlashCmdList["DROPWORLDMARKER"] = function(msg)
    msg = msg:lower():trim()

    if msg == "place" or msg == "" then
        if not InCombatLockdown() then
            mainButton:Click("LeftButton")
        else
            print("|cFFFF6600DropWorldMarker:|r Cannot use slash command during combat - use keybind")
        end
    elseif msg == "clear" then
        if not InCombatLockdown() then
            clearButton:Click("LeftButton")
        else
            print("|cFFFF6600DropWorldMarker:|r Cannot use slash command during combat - use keybind")
        end
    elseif msg == "reset" then
        addon:ResetCycle()
        print("|cFF00FF00DropWorldMarker:|r Sequence reset to beginning")
    elseif msg == "config" or msg == "options" then
        Settings.OpenToCategory("DropWorldMarker")
    elseif msg == "sync" then
        addon:SyncSequenceToButton()
        print("|cFF00FF00DropWorldMarker:|r Sequence synced to button")
    else
        print("|cFF00FF00DropWorldMarker Commands:|r")
        print("  /dwm - Place next marker")
        print("  /dwm clear - Clear all markers")
        print("  /dwm reset - Reset sequence to beginning")
        print("  /dwm config - Open options panel")
        print("  /dwm sync - Sync sequence after changes")
    end
end

-- Event handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize saved variables with defaults
        if not DropWorldMarkerDB then
            DropWorldMarkerDB = {}
        end
        for k, v in pairs(defaults) do
            if DropWorldMarkerDB[k] == nil then
                DropWorldMarkerDB[k] = v
            end
        end

        -- Convert old enabledMarkers format to new sequence format
        if DropWorldMarkerDB.enabledMarkers and not DropWorldMarkerDB.markerSequence then
            local sequence = {}
            for i, enabled in ipairs(DropWorldMarkerDB.enabledMarkers) do
                if enabled then
                    table.insert(sequence, i)
                end
            end
            DropWorldMarkerDB.markerSequence = sequence
            DropWorldMarkerDB.enabledMarkers = nil
        end

    elseif event == "PLAYER_LOGIN" then
        -- Sync sequence to button on login
        addon:SyncSequenceToButton()

        -- Restore keybindings
        if DropWorldMarkerDB.placeKey then
            SetBindingClick(DropWorldMarkerDB.placeKey, "DWMPlaceBtn", "LeftButton")
        end
        if DropWorldMarkerDB.clearKey then
            SetBindingClick(DropWorldMarkerDB.clearKey, "DWMClearBtn", "LeftButton")
        end

        print("|cFF00FF00DropWorldMarker|r loaded. Use /dwm config to set keybinds.")

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Sync sequence when leaving combat (in case it was changed)
        addon:SyncSequenceToButton()
    end
end)
