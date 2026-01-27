-- DropWorldMarker Options Panel

local addonName, addon = ...

-- Create the options panel after PLAYER_LOGIN to ensure saved variables are loaded
local function CreateOptionsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "DropWorldMarker"

    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("DropWorldMarker")

    -- Description
    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetText("Set the order of markers to cycle through. Set a slot to 'None' to skip it.")
    desc:SetJustifyH("LEFT")

    -- Sequence label
    local seqLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    seqLabel:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    seqLabel:SetText("Marker Sequence:")

    -- Dropdown options with icons (using TargetingFrame path)
    local markerIcons = {
        [1] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6", -- Square (blue)
        [2] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4", -- Triangle (green)
        [3] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3", -- Diamond (purple)
        [4] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7", -- Cross (red)
        [5] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1", -- Star (yellow)
        [6] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", -- Circle (orange)
        [7] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5", -- Moon (silver)
        [8] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8", -- Skull
    }

    local function GetMarkerText(index, name)
        if index == 0 then return "None" end
        return "|T" .. markerIcons[index] .. ":14:14:0:0|t"
    end

    local markerOptions = {
        { value = 0, text = "None", name = "None" },
        { value = 1, text = GetMarkerText(1, "Square"), name = "Square" },
        { value = 2, text = GetMarkerText(2, "Triangle"), name = "Triangle" },
        { value = 3, text = GetMarkerText(3, "Diamond"), name = "Diamond" },
        { value = 4, text = GetMarkerText(4, "Cross"), name = "Cross" },
        { value = 5, text = GetMarkerText(5, "Star"), name = "Star" },
        { value = 6, text = GetMarkerText(6, "Circle"), name = "Circle" },
        { value = 7, text = GetMarkerText(7, "Moon"), name = "Moon" },
        { value = 8, text = GetMarkerText(8, "Skull"), name = "Skull" },
    }

    local dropdowns = {}
    local labels = {}
    local NUM_SLOTS = 8

    -- Function to rebuild sequence from dropdowns
    local function RebuildSequence()
        local newSequence = {}
        for i = 1, NUM_SLOTS do
            local value = dropdowns[i].selectedValue
            if value and value > 0 then
                table.insert(newSequence, value)
            end
        end
        DropWorldMarkerDB.markerSequence = newSequence
        addon:SyncSequenceToButton()
    end

    -- Function to clear all slots
    local function ClearAllSlots()
        for i = 1, NUM_SLOTS do
            dropdowns[i].selectedValue = 0
            UIDropDownMenu_SetText(dropdowns[i], "None")
        end
        RebuildSequence()
    end

    -- Create dropdowns for each slot
    local col1X = 16
    local col2X = 220
    local startY = -100
    local rowHeight = 30

    for i = 1, NUM_SLOTS do
        local col = (i <= 4) and 1 or 2
        local row = (i <= 4) and i or (i - 4)
        local xPos = (col == 1) and col1X or col2X
        local yPos = startY - ((row - 1) * rowHeight)

        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", panel, "TOPLEFT", xPos, yPos)
        label:SetText("Slot " .. i .. ":")
        labels[i] = label

        local dropdown = CreateFrame("Frame", "DropWorldMarkerSlot" .. i .. "Dropdown", panel, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", xPos + 40, yPos + 5)
        dropdown.selectedValue = 0

        local function InitDropdown(self, level)
            for _, option in ipairs(markerOptions) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = option.text
                info.value = option.value
                info.func = function()
                    dropdown.selectedValue = option.value
                    UIDropDownMenu_SetText(dropdown, option.text)
                    RebuildSequence()
                end
                info.checked = (dropdown.selectedValue == option.value)
                UIDropDownMenu_AddButton(info, level)
            end
        end

        UIDropDownMenu_SetWidth(dropdown, 100)
        UIDropDownMenu_Initialize(dropdown, InitDropdown)
        UIDropDownMenu_SetText(dropdown, "None")

        dropdowns[i] = dropdown
    end

    -- Clear All button
    local clearAllBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearAllBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", col1X, startY - (4 * rowHeight) - 10)
    clearAllBtn:SetSize(100, 24)
    clearAllBtn:SetText("Clear All")
    clearAllBtn:SetScript("OnClick", function()
        ClearAllSlots()
        print("|cFF00FF00DropWorldMarker:|r All slots cleared")
    end)

    -- Keybindings Section
    local keybindLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    keybindLabel:SetPoint("TOPLEFT", clearAllBtn, "BOTTOMLEFT", 0, -25)
    keybindLabel:SetText("Keybindings:")

    -- Helper function to get key name for display
    local function GetKeyText(key)
        if not key or key == "" then
            return "Not Set"
        end
        return key
    end

    -- Create keybind button (returns label for proper anchoring)
    local function CreateKeybindButton(parent, labelText, settingKey, buttonName, yOffset)
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, yOffset)
        label:SetText(labelText .. ":")

        local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        btn:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 130, yOffset + 3) -- Fixed X position for alignment
        btn:SetSize(120, 22)
        btn:SetText(GetKeyText(DropWorldMarkerDB[settingKey]))
        btn.label = label -- Store reference to label
        btn:SetPropagateKeyboardInput(true) -- Don't capture keys by default
        btn.waitingForKey = false

        local function StopWaiting(self)
            self.waitingForKey = false
            self:SetPropagateKeyboardInput(true)
            self:SetText(GetKeyText(DropWorldMarkerDB[settingKey]))
        end

        btn:SetScript("OnClick", function(self)
            if self.waitingForKey then
                StopWaiting(self)
                return
            end

            self.waitingForKey = true
            self:SetText("Press a key...")
            self:SetPropagateKeyboardInput(false) -- Capture keys now
        end)

        btn:SetScript("OnKeyDown", function(self, key)
            if not self.waitingForKey then return end

            -- Ignore modifier keys alone
            if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then
                return
            end

            -- Stop waiting first
            self.waitingForKey = false
            self:SetPropagateKeyboardInput(true)

            -- Handle escape to clear
            if key == "ESCAPE" then
                if DropWorldMarkerDB[settingKey] then
                    SetBinding(DropWorldMarkerDB[settingKey], nil)
                    SaveBindings(GetCurrentBindingSet())
                end
                DropWorldMarkerDB[settingKey] = nil
                self:SetText("Not Set")
                print("|cFF00FF00DropWorldMarker:|r " .. labelText .. " keybind cleared")
                return
            end

            -- Build the key string with modifiers
            local keyString = ""
            if IsShiftKeyDown() then keyString = "SHIFT-" end
            if IsControlKeyDown() then keyString = keyString .. "CTRL-" end
            if IsAltKeyDown() then keyString = keyString .. "ALT-" end
            keyString = keyString .. key

            -- Clear old binding if exists
            if DropWorldMarkerDB[settingKey] then
                SetBinding(DropWorldMarkerDB[settingKey], nil)
            end

            -- Set new binding
            SetBindingClick(keyString, buttonName, "LeftButton")
            SaveBindings(GetCurrentBindingSet())

            DropWorldMarkerDB[settingKey] = keyString
            self:SetText(keyString)
            print("|cFF00FF00DropWorldMarker:|r " .. labelText .. " bound to " .. keyString)
        end)

        btn:SetScript("OnHide", function(self)
            StopWaiting(self)
        end)

        return btn
    end

    local placeKeybindBtn = CreateKeybindButton(keybindLabel, "Place Next Marker", "placeKey", "DWMPlaceBtn", -10)
    local clearKeybindBtn = CreateKeybindButton(placeKeybindBtn.label, "Clear All Markers", "clearKey", "DWMClearBtn", -8)

    -- Show chat messages checkbox
    local chatCheckbox = CreateFrame("CheckButton", "DropWorldMarkerChatCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    chatCheckbox:SetPoint("TOPLEFT", clearKeybindBtn.label, "BOTTOMLEFT", 0, -15)
    chatCheckbox.Text:SetText("Show chat messages when placing/clearing markers")
    chatCheckbox:SetScript("OnClick", function(self)
        DropWorldMarkerDB.showChatMessage = self:GetChecked() and true or false
    end)

    -- Slash command info
    local slashInfo = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    slashInfo:SetPoint("TOPLEFT", chatCheckbox, "BOTTOMLEFT", 0, -20)
    slashInfo:SetText("|cFFFFFF00Commands:|r /dwm, /dwm clear, /dwm reset, /dwm config")
    slashInfo:SetJustifyH("LEFT")

    -- Refresh function to update UI from saved variables
    panel.refresh = function()
        local sequence = DropWorldMarkerDB.markerSequence or {}

        -- Reset all dropdowns to None first
        for i = 1, NUM_SLOTS do
            dropdowns[i].selectedValue = 0
            UIDropDownMenu_SetText(dropdowns[i], "None")
        end

        -- Set dropdowns based on saved sequence
        for slot, markerIndex in ipairs(sequence) do
            if slot <= NUM_SLOTS and markerIndex >= 1 and markerIndex <= 8 then
                dropdowns[slot].selectedValue = markerIndex
                local option = markerOptions[markerIndex + 1]
                UIDropDownMenu_SetText(dropdowns[slot], option.text)
            end
        end

        chatCheckbox:SetChecked(DropWorldMarkerDB.showChatMessage)

        -- Update keybind button texts
        placeKeybindBtn:SetText(GetKeyText(DropWorldMarkerDB.placeKey))
        clearKeybindBtn:SetText(GetKeyText(DropWorldMarkerDB.clearKey))
    end

    -- Register with the new Settings API (Dragonflight+)
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    category.ID = panel.name
    Settings.RegisterAddOnCategory(category)

    -- Call refresh when panel is shown
    panel:SetScript("OnShow", panel.refresh)
end

-- Wait for saved variables to be loaded
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(0.1, CreateOptionsPanel)
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)
