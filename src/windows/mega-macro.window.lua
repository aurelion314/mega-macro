local rendering = {
	MacrosPerRow = 12,
	CharLimitMessageFormat = "%s/%s Characters Used"
}

local SelectedScope = MegaMacroScopeCodes.Global

NUM_ICONS_PER_ROW = 10
NUM_ICON_ROWS = 9
NUM_MACRO_ICONS_SHOWN = NUM_ICONS_PER_ROW * NUM_ICON_ROWS
MACRO_ICON_ROW_HEIGHT = 36

UIPanelWindows["MegaMacro_Frame"] = { area = "left", pushable = 1, whileDead = 1, width = PANEL_DEFAULT_WIDTH + 302 }

StaticPopupDialogs["CONFIRM_DELETE_SELECTED_MACRO"] = {
	text = CONFIRM_DELETE_MACRO,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
        -- delete mega macro here
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1
}

MegaMacroWindow = {
    Show = function()
        ShowUIPanel(MegaMacro_Frame);
	end
}

-- Creates the button frames for the macro slots
local function CreateMacroSlotFrames()
	for i=1, MegaMacroHelper.HighestMaxMacroCount do
		local button = CreateFrame("CheckButton", "MegaMacro_MacroButton" .. i, MegaMacro_ButtonContainer, "MegaMacro_ButtonTemplate")
		button:SetID(i)
		if i == 1 then
			button:SetPoint("TOPLEFT", MegaMacro_ButtonContainer, "TOPLEFT", 6, -6)
		elseif mod(i, rendering.MacrosPerRow) == 1 then
			button:SetPoint("TOP", "MegaMacro_MacroButton"..(i-rendering.MacrosPerRow), "BOTTOM", 0, -10)
		else
			button:SetPoint("LEFT", "MegaMacro_MacroButton"..(i-1), "RIGHT", 13, 0)
		end
	end
end

-- Shows and hides macro slot buttons based on the number of slots available in the scope
local function InitializeMacroSlots()
	local scopeSlotCount = MegaMacroHelper.GetMacroSlotCount(SelectedScope)

	for i=1, scopeSlotCount do
		local buttonFrame = _G["MegaMacro_MacroButton" .. i]

		if buttonFrame == nil then
			break
		end

		buttonFrame:Show()
	end

	for i=scopeSlotCount+1, MegaMacroHelper.HighestMaxMacroCount do
		local buttonFrame = _G["MegaMacro_MacroButton" .. i]

		if buttonFrame == nil then
			break
		end

		buttonFrame:Hide()
	end
end

-- Sets the data for the occupied slots in the macro list
local function SetMacroItems()
	if SelectedScope == MegaMacroScopeCodes.Global then
		SetMacroItems(MegaMacroGlobalData.Macros);
	end
end

local function SetMacroItems()
	local items = nil

	if SelectedScope == MegaMacroScopeCodes.Global then
		items = MegaMacroGlobalData.Macros
	end

	items = items or {}
	table.sort(
		items,
		function(left, right)
			return left.DisplayName < right.DisplayName
		end)

	for i=1, MegaMacroHelper.HighestMaxMacroCount do
		local buttonId = "MegaMacro_MacroButton" .. i
		local buttonFrame = _G[buttonId]
		local buttonName = _G[buttonId .. "Name"]
		local buttonIcon = _G[buttonId .. "Icon"]

		local macro = items[i]

		if macro == nil then
			buttonFrame.MacroId = nil
			buttonFrame:SetChecked(false)
			buttonFrame:Disable()
			buttonName:SetText("")
			buttonIcon:SetTexture("")
		else
			buttonFrame.MacroId = macro.Id
			buttonFrame:Enable()
			buttonName:SetText(macro.DisplayName)
			buttonIcon:SetTexture("")

			-- move this to a dedicated SelectMacro function when implementing macro selection
			-- also call ClearMacroSelection at the top once implemented
			if i == 1 then
				MegaMacro_FrameSelectedMacroButton:SetID(i);
				MegaMacro_FrameSelectedMacroButtonIcon:SetTexture("");
				buttonFrame:SetChecked(true)
			else
				buttonFrame:SetChecked(false)
			end
		end
	end
end

function MegaMacro_Window_OnLoad()
    -- Global, Class, ClassSpec, Character, CharacterSpec
	PanelTemplates_SetNumTabs(MegaMacro_Frame, 5)
	PanelTemplates_SetTab(MegaMacro_Frame, 1)
end

function MegaMacro_Window_OnShow()
end

function MegaMacro_Window_OnHide()
    MegaMacro_PopupFrame:Hide()
end

function MegaMacro_TabChanged(tabId, arg1)
	MegaMacro_ButtonScrollFrame:SetVerticalScroll(0)

	if tabId == 1 then
		SelectedScope = MegaMacroScopeCodes.Global
	elseif tabId == 2 then
		SelectedScope = MegaMacroScopeCodes.Class
	elseif tabId == 3 then
		SelectedScope = MegaMacroScopeCodes.Specialization
	elseif tabId == 4 then
		SelectedScope = MegaMacroScopeCodes.Character
	elseif tabId == 5 then
		SelectedScope = MegaMacroScopeCodes.CharacterSpecialization
	end

	InitializeMacroSlots()
	SetMacroItems()
end

function MegaMacro_ButtonContainer_OnLoad(self)
	CreateMacroSlotFrames()
end

function MegaMacro_ButtonContainer_OnShow(self)
	InitializeMacroSlots()
	SetMacroItems()
end

function MegaMacro_EditButton_OnClick(self, button)
end

function MegaMacro_TextBox_TextChanged(self)
    MegaMacro_Frame.textChanged = 1

    if MegaMacro_PopupFrame.mode == "new" then
        MegaMacro_PopupFrame:Hide()
    end

    MegaMacro_FrameCharLimitText:SetFormattedText(
		rendering.CharLimitMessageFormat,
		MegaMacro_FrameText:GetNumLetters(),
		MegaMacroHelper.MaxMacroSize)

    ScrollingEdit_OnTextChanged(self, self:GetParent())
end

function MegaMacro_CancelButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	MegaMacro_PopupFrame:Hide()
	MegaMacro_FrameText:ClearFocus()
end

function MegaMacro_SaveButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	MegaMacro_PopupFrame:Hide()
	MegaMacro_FrameText:ClearFocus()
end

function MegaMacro_NewButton_OnClick()
	MegaMacro_PopupFrame.mode = "new"
	MegaMacro_PopupFrame:Show()
end

function MegaMacro_EditOkButton_OnClick()
    -- create/update editted macro
	MegaMacro_PopupFrame:Hide()
end

function MegaMacro_EditCancelButton_OnClick()
	MegaMacro_PopupFrame:Hide()
	MegaMacro_PopupFrame.selectedIcon = nil
end