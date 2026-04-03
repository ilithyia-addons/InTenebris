-- MainFrame.lua
-- Main configuration frame with side-tab navigation for InTenebris

-- Layout constants
local FRAME_WIDTH = 680
local FRAME_HEIGHT = 500
local SIDE_PANEL_WIDTH = 130
local HEADER_HEIGHT = 50

-- Tab registry
local tabs = {} -- { [id] = { id, label, order, button, content, headerText } }
local tabOrder = {} -- sorted list of tab ids
local activeTabId = nil

-- ============================================================
-- Main Frame
-- ============================================================

local mainFrame = CreateFrame("Frame", "InTenebrisMainFrame", UIParent)
mainFrame:SetWidth(FRAME_WIDTH)
mainFrame:SetHeight(FRAME_HEIGHT)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
mainFrame:SetFrameStrata("HIGH")
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:SetClampedToScreen(true)
mainFrame:Hide()

-- Backdrop: standard WoW dialog frame
mainFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
mainFrame:SetBackdropColor(0.15, 0.13, 0.10, 1)

-- Title header ornament (decorative tab at top)
local headerTexture = mainFrame:CreateTexture(nil, "ARTWORK")
headerTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
headerTexture:SetWidth(280)
headerTexture:SetHeight(64)
headerTexture:SetPoint("TOP", mainFrame, "TOP", 0, 12)

-- Title text (anchored to header ornament center)
local titleText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("TOP", headerTexture, "TOP", 0, -14)
titleText:SetText("In Tenebris")

-- Close button (standard WoW template)
local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function()
	InTenebrisMainFrame:Hide()
end)

-- Make title area draggable
local dragFrame = CreateFrame("Frame", nil, mainFrame)
dragFrame:SetHeight(HEADER_HEIGHT)
dragFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
dragFrame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
dragFrame:EnableMouse(true)
dragFrame:SetScript("OnMouseDown", function()
	if arg1 == "LeftButton" then
		mainFrame:StartMoving()
	end
end)
dragFrame:SetScript("OnMouseUp", function()
	mainFrame:StopMovingOrSizing()
end)

-- Close on Escape
table.insert(UISpecialFrames, "InTenebrisMainFrame")

-- ============================================================
-- Side Tab Panel
-- ============================================================

local sidePanel = CreateFrame("Frame", nil, mainFrame)
sidePanel:SetWidth(SIDE_PANEL_WIDTH)
sidePanel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 14, -(HEADER_HEIGHT + 4))
sidePanel:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 14, 14)
sidePanel:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
sidePanel:SetBackdropColor(0.08, 0.07, 0.06, 0.9)
sidePanel:SetBackdropBorderColor(0.4, 0.35, 0.2, 0.6)

-- ============================================================
-- Content Area
-- ============================================================

local contentArea = CreateFrame("Frame", nil, mainFrame)
contentArea:SetPoint("TOPLEFT", sidePanel, "TOPRIGHT", 6, 0)
contentArea:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -14, 14)
contentArea:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
contentArea:SetBackdropColor(0.10, 0.09, 0.07, 0.9)
contentArea:SetBackdropBorderColor(0.4, 0.35, 0.2, 0.6)

-- Content header label (shows active tab name)
local contentHeaderText = contentArea:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
contentHeaderText:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 14, -12)
contentHeaderText:SetTextColor(1.0, 0.85, 0.30, 1)

-- Content header separator
local contentHeaderSep = contentArea:CreateTexture(nil, "ARTWORK")
contentHeaderSep:SetHeight(1)
contentHeaderSep:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 10, -32)
contentHeaderSep:SetPoint("TOPRIGHT", contentArea, "TOPRIGHT", -10, -32)
contentHeaderSep:SetTexture(0.6, 0.5, 0.15, 0.5)

-- Inner content frame (below header, where tab content goes)
local contentInner = CreateFrame("Frame", nil, contentArea)
contentInner:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 8, -40)
contentInner:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -8, 8)

-- ============================================================
-- Tab System
-- ============================================================

local function SortTabs()
	tabOrder = {}
	for id, _ in pairs(tabs) do
		table.insert(tabOrder, id)
	end
	table.sort(tabOrder, function(a, b)
		return tabs[a].order < tabs[b].order
	end)
end

local function RepositionTabButtons()
	for i, id in ipairs(tabOrder) do
		local tab = tabs[id]
		tab.button:ClearAllPoints()
		tab.button:SetPoint("TOPLEFT", sidePanel, "TOPLEFT", 6, -((i - 1) * 28 + 8))
		tab.button:SetPoint("TOPRIGHT", sidePanel, "TOPRIGHT", -6, -((i - 1) * 28 + 8))
	end
end

local function UpdateTabAppearance()
	for id, tab in pairs(tabs) do
		if id == activeTabId then
			-- Active tab
			tab.bg:SetTexture(0.6, 0.5, 0.15, 0.25)
			tab.label:SetTextColor(1.0, 0.85, 0.30, 1)
			tab.indicator:Show()
			tab.content:Show()
			contentHeaderText:SetText(tab.headerText)
		else
			-- Inactive tab
			tab.bg:SetTexture(0, 0, 0, 0)
			tab.label:SetTextColor(0.55, 0.47, 0.25, 1)
			tab.indicator:Hide()
			tab.content:Hide()
		end
	end
end

function InTenebris:RegisterTab(id, label, order)
	-- Create tab button
	local tabButton = CreateFrame("Button", nil, sidePanel)
	tabButton:SetHeight(24)

	-- Tab background (shown when active)
	local bg = tabButton:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(0, 0, 0, 0)

	-- Active indicator (gold bar on left edge)
	local indicator = tabButton:CreateTexture(nil, "ARTWORK")
	indicator:SetWidth(2)
	indicator:SetPoint("TOPLEFT", tabButton, "TOPLEFT", 0, 0)
	indicator:SetPoint("BOTTOMLEFT", tabButton, "BOTTOMLEFT", 0, 0)
	indicator:SetTexture(1.0, 0.85, 0.30, 1)
	indicator:Hide()

	-- Tab label
	local tabLabel = tabButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	tabLabel:SetPoint("LEFT", tabButton, "LEFT", 10, 0)
	tabLabel:SetText(label)
	tabLabel:SetTextColor(0.55, 0.47, 0.25, 1)

	-- Hover highlight
	local highlight = tabButton:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetTexture(1, 1, 1, 0.05)

	-- Content frame for this tab
	local content = CreateFrame("Frame", nil, contentInner)
	content:SetAllPoints(contentInner)
	content:Hide()

	-- Click handler
	tabButton:SetScript("OnClick", function()
		InTenebris:SelectTab(id)
	end)

	tabs[id] = {
		id = id,
		headerText = label,
		order = order,
		button = tabButton,
		bg = bg,
		indicator = indicator,
		label = tabLabel,
		content = content,
	}

	SortTabs()
	RepositionTabButtons()

	-- Auto-select first tab (lowest order) if none selected
	if not activeTabId then
		activeTabId = tabOrder[1]
		UpdateTabAppearance()
	end

	return content
end

function InTenebris:SelectTab(id)
	if not tabs[id] then
		return
	end
	activeTabId = id
	UpdateTabAppearance()
end

function InTenebris:ToggleMainFrame()
	if mainFrame:IsVisible() then
		mainFrame:Hide()
	else
		mainFrame:Show()
	end
end

-- ============================================================
-- Register Tabs
-- ============================================================

-- Loot Attributions tab (placeholder)
local lootTab = InTenebris:RegisterTab("loot", "Loot Attributions", 1)
local lootPlaceholder = lootTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lootPlaceholder:SetPoint("CENTER", lootTab, "CENTER", 0, 0)
lootPlaceholder:SetText("|cff666666Coming soon.|r")

-- ============================================================
-- Strategies tab
-- ============================================================

local strategiesTab = InTenebris:RegisterTab("strategies", "Strategies", 2)

-- Image dimensions (fill content width, 16:9 aspect ratio)
local STRATEGY_IMAGE_WIDTH = FRAME_WIDTH - SIDE_PANEL_WIDTH - 84
local STRATEGY_IMAGE_HEIGHT = math.floor(STRATEGY_IMAGE_WIDTH * 9 / 16)

-- Strategy data per raid
local RAID_STRATEGIES = {
	{
		id = "bwl",
		name = "Blackwing Lair",
		bosses = {
			{
				name = "Razorgore the Untamed",
				image = "Interface\\AddOns\\InTenebris\\Textures\\Strategies\\Blackwing Lair\\Razorgore",
			},
			{
				name = "Vaelastrasz the Corrupt",
				image = "Interface\\AddOns\\InTenebris\\Textures\\Strategies\\Blackwing Lair\\Vaelastrasz",
			},
			{
				name = "Broodlord Lashlayer",
				image = "Interface\\AddOns\\InTenebris\\Textures\\Strategies\\Blackwing Lair\\Lashlayer",
			},
			{
				name = "Firemaw",
				image = "Interface\\AddOns\\InTenebris\\Textures\\Strategies\\Blackwing Lair\\Firemaw",
			},
			{
				name = "Ebonroc / Flamegor",
				image = "Interface\\AddOns\\InTenebris\\Textures\\Strategies\\Blackwing Lair\\Ebonroc-Flamegor",
			},
			{
				name = "Chromaggus",
				image = "Interface\\AddOns\\InTenebris\\Textures\\Strategies\\Blackwing Lair\\Chromaggus",
				text = "1er  SOUFFLE => HEAL 1 & 3\n2\195\168me SOUFFLE => HEAL 2 & 4\n3\195\168me SOUFFLE => HEAL 5 & 7\n4\195\168me SOUFFLE => HEAL 6 & 8\n\nOrdre de soak du souffle de bronze => Les heals cit\195\169s restent \195\160 port\195\169e du tank et utilisent leur sable pour sortir du stun.",
			},
		},
	},
}

-- Raid dropdown
local raidDropdownLabel = strategiesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
raidDropdownLabel:SetPoint("TOPLEFT", strategiesTab, "TOPLEFT", 4, 2)
raidDropdownLabel:SetText("Raid:")

local raidDropdown = CreateFrame("Frame", "InTenebrisRaidDropdown", strategiesTab, "UIDropDownMenuTemplate")
raidDropdown:SetPoint("LEFT", raidDropdownLabel, "RIGHT", -8, -2)

-- Scroll frame for strategy content (below dropdown)
local strategiesScroll =
	CreateFrame("ScrollFrame", "InTenebrisStrategiesScroll", strategiesTab, "UIPanelScrollFrameTemplate")
strategiesScroll:SetPoint("TOPLEFT", strategiesTab, "TOPLEFT", 0, -26)
strategiesScroll:SetPoint("BOTTOMRIGHT", strategiesTab, "BOTTOMRIGHT", -26, 0)

local strategiesScrollChild = CreateFrame("Frame", nil, strategiesScroll)
strategiesScrollChild:SetWidth(STRATEGY_IMAGE_WIDTH)
strategiesScrollChild:SetHeight(1)
strategiesScroll:SetScrollChild(strategiesScrollChild)

-- Build UI for a raid's strategy content
local raidContentFrames = {} -- id -> { frame, height }

local function BuildRaidStrategyContent(raidData)
	local frame = CreateFrame("Frame", nil, strategiesScrollChild)
	frame:SetPoint("TOPLEFT", strategiesScrollChild, "TOPLEFT", 0, 0)
	frame:SetPoint("TOPRIGHT", strategiesScrollChild, "TOPRIGHT", 0, 0)
	frame:Hide()

	local yOffset = 0

	for _, boss in ipairs(raidData.bosses) do
		-- Boss title
		local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -yOffset)
		title:SetText(boss.name)
		title:SetTextColor(1.0, 0.85, 0.30, 1)
		yOffset = yOffset + 22

		-- Boss image
		if boss.image then
			local img = frame:CreateTexture(nil, "ARTWORK")
			img:SetWidth(STRATEGY_IMAGE_WIDTH)
			img:SetHeight(STRATEGY_IMAGE_HEIGHT)
			img:SetTexture(boss.image)
			img:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -yOffset)
			yOffset = yOffset + STRATEGY_IMAGE_HEIGHT + 8
		end

		-- Boss text
		if boss.text then
			local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			text:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -yOffset)
			text:SetWidth(STRATEGY_IMAGE_WIDTH)
			text:SetJustifyH("LEFT")
			text:SetText(boss.text)
			yOffset = yOffset + (text:GetHeight() or 80) + 8
		end

		-- Spacing between bosses
		yOffset = yOffset + 20
	end

	frame:SetHeight(yOffset)
	raidContentFrames[raidData.id] = { frame = frame, height = yOffset }
end

-- Build content for all raids
for _, raidData in ipairs(RAID_STRATEGIES) do
	BuildRaidStrategyContent(raidData)
end

-- Select a raid to display
local function SelectRaid(raidId)
	for id, data in pairs(raidContentFrames) do
		if id == raidId then
			data.frame:Show()
			strategiesScrollChild:SetHeight(data.height)
		else
			data.frame:Hide()
		end
	end
	strategiesScroll:SetVerticalScroll(0)
end

-- Initialize raid dropdown
local function RaidDropdown_Initialize()
	for _, raidData in ipairs(RAID_STRATEGIES) do
		local raidId = raidData.id
		local raidName = raidData.name
		local info = {}
		info.text = raidName
		info.value = raidId
		info.func = function()
			UIDropDownMenu_SetSelectedValue(raidDropdown, raidId)
			SelectRaid(raidId)
		end
		info.checked = nil
		UIDropDownMenu_AddButton(info)
	end
end

UIDropDownMenu_Initialize(raidDropdown, RaidDropdown_Initialize)
UIDropDownMenu_SetWidth(180, raidDropdown)

-- Default to first raid
UIDropDownMenu_SetSelectedValue(raidDropdown, RAID_STRATEGIES[1].id)
UIDropDownMenu_SetText(RAID_STRATEGIES[1].name, raidDropdown)
SelectRaid(RAID_STRATEGIES[1].id)

-- Crafting tab (placeholder)
local craftingTab = InTenebris:RegisterTab("crafting", "Crafting", 3)
local craftingPlaceholder = craftingTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
craftingPlaceholder:SetPoint("CENTER", craftingTab, "CENTER", 0, 0)
craftingPlaceholder:SetText("|cff666666Coming soon.|r")

-- Options tab
local optionsTab = InTenebris:RegisterTab("options", "Options", 4)

-- Scroll frame for options content
local optionsScroll = CreateFrame("ScrollFrame", "InTenebrisOptionsScroll", optionsTab, "UIPanelScrollFrameTemplate")
optionsScroll:SetPoint("TOPLEFT", optionsTab, "TOPLEFT", 0, 0)
optionsScroll:SetPoint("BOTTOMRIGHT", optionsTab, "BOTTOMRIGHT", -26, 0)

-- Scroll child (all options go here)
local optionsContent = CreateFrame("Frame", nil, optionsScroll)
optionsContent:SetWidth(optionsScroll:GetWidth() or 350)
optionsContent:SetHeight(1) -- will be updated after all options are laid out
optionsScroll:SetScrollChild(optionsContent)

-- ============================================================
-- Options: Item Tooltip section
-- ============================================================

-- Section header
local tooltipSectionHeader = optionsContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
tooltipSectionHeader:SetPoint("TOPLEFT", optionsContent, "TOPLEFT", 4, -4)
tooltipSectionHeader:SetText("Item Tooltip")
tooltipSectionHeader:SetTextColor(1.0, 0.85, 0.30, 1)

-- Section separator
local tooltipSectionSep = optionsContent:CreateTexture(nil, "ARTWORK")
tooltipSectionSep:SetHeight(1)
tooltipSectionSep:SetPoint("TOPLEFT", tooltipSectionHeader, "BOTTOMLEFT", 0, -4)
tooltipSectionSep:SetPoint("RIGHT", optionsContent, "RIGHT", -4, 0)
tooltipSectionSep:SetTexture(0.6, 0.5, 0.15, 0.4)

-- Forward declarations for cross-referencing between dropdowns
local attribDropdown, outOfGroupDropdown
local UpdateOutOfGroupDropdownState

-- "Show loot attributions:" label + dropdown
local showAttribLabel = optionsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
showAttribLabel:SetPoint("TOPLEFT", tooltipSectionSep, "BOTTOMLEFT", 0, -12)
showAttribLabel:SetText("Show loot attributions:")

attribDropdown = CreateFrame("Frame", "InTenebrisShowAttributionsDropdown", optionsContent, "UIDropDownMenuTemplate")
attribDropdown:SetPoint("LEFT", showAttribLabel, "RIGHT", -8, -2)

local ATTRIB_OPTIONS = {
	{ text = "When in a party or raid", value = "group" },
	{ text = "Always", value = "always" },
}

local function ShowAttributionsDropdown_Initialize()
	for _, option in ipairs(ATTRIB_OPTIONS) do
		local optionValue = option.value
		local optionText = option.text
		local info = {}
		info.text = optionText
		info.value = optionValue
		info.func = function()
			InTenebris.db.profile.showAttributions = optionValue
			UIDropDownMenu_SetSelectedValue(attribDropdown, optionValue)
			UpdateOutOfGroupDropdownState()
		end
		info.checked = nil
		UIDropDownMenu_AddButton(info)
	end
end

UIDropDownMenu_Initialize(attribDropdown, ShowAttributionsDropdown_Initialize)
UIDropDownMenu_SetWidth(180, attribDropdown)

-- "Show characters out of group/raid:" label + dropdown
local outOfGroupLabel = optionsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
outOfGroupLabel:SetPoint("TOPLEFT", showAttribLabel, "BOTTOMLEFT", 0, -16)
outOfGroupLabel:SetText("Show characters out of group/raid:")

outOfGroupDropdown = CreateFrame("Frame", "InTenebrisShowOutOfGroupDropdown", optionsContent, "UIDropDownMenuTemplate")
outOfGroupDropdown:SetPoint("LEFT", outOfGroupLabel, "RIGHT", -8, -2)

local OUT_OF_GROUP_OPTIONS = {
	{ text = "No", value = "no" },
	{ text = "Yes", value = "yes" },
}

local function ShowOutOfGroupDropdown_Initialize()
	for _, option in ipairs(OUT_OF_GROUP_OPTIONS) do
		local optionValue = option.value
		local optionText = option.text
		local info = {}
		info.text = optionText
		info.value = optionValue
		info.func = function()
			InTenebris.db.profile.showOutOfGroup = optionValue
			UIDropDownMenu_SetSelectedValue(outOfGroupDropdown, optionValue)
		end
		info.checked = nil
		UIDropDownMenu_AddButton(info)
	end
end

UIDropDownMenu_Initialize(outOfGroupDropdown, ShowOutOfGroupDropdown_Initialize)
UIDropDownMenu_SetWidth(80, outOfGroupDropdown)

-- Enable/disable a dropdown (no built-in function in WoW 1.12)
local function SetDropdownEnabled(frame, enabled)
	local button = getglobal(frame:GetName() .. "Button")
	if enabled then
		button:Enable()
		UIDropDownMenu_SetText(UIDropDownMenu_GetText(frame), frame)
	else
		button:Disable()
	end
	-- Dim the text when disabled
	local text = getglobal(frame:GetName() .. "Text")
	if text then
		if enabled then
			text:SetTextColor(1, 1, 1)
		else
			text:SetTextColor(0.5, 0.5, 0.5)
		end
	end
end

-- Sync the out-of-group dropdown state based on the attributions setting
UpdateOutOfGroupDropdownState = function()
	local isAlways = InTenebris.db.profile.showAttributions == "always"
	if isAlways then
		UIDropDownMenu_SetSelectedValue(outOfGroupDropdown, "yes")
		UIDropDownMenu_SetText("Yes", outOfGroupDropdown)
		SetDropdownEnabled(outOfGroupDropdown, false)
	else
		local currentValue = InTenebris.db.profile.showOutOfGroup
		UIDropDownMenu_SetSelectedValue(outOfGroupDropdown, currentValue)
		for _, option in ipairs(OUT_OF_GROUP_OPTIONS) do
			if option.value == currentValue then
				UIDropDownMenu_SetText(option.text, outOfGroupDropdown)
				break
			end
		end
		SetDropdownEnabled(outOfGroupDropdown, true)
	end
end

-- Set initial values from saved profile on show
local originalOnShow = optionsTab:GetScript("OnShow")
optionsTab:SetScript("OnShow", function()
	if originalOnShow then
		originalOnShow()
	end
	-- Update attributions dropdown
	local attribValue = InTenebris.db.profile.showAttributions
	UIDropDownMenu_SetSelectedValue(attribDropdown, attribValue)
	for _, option in ipairs(ATTRIB_OPTIONS) do
		if option.value == attribValue then
			UIDropDownMenu_SetText(option.text, attribDropdown)
			break
		end
	end
	-- Update out-of-group dropdown (handles disable state)
	UpdateOutOfGroupDropdownState()

	-- Update scroll child height to fit content (expand as more options are added)
	optionsContent:SetHeight(100)
end)
