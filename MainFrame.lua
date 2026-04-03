-- MainFrame.lua
-- Main configuration frame with side-tab navigation for InTenebris

-- Layout constants
local FRAME_WIDTH = 560
local FRAME_HEIGHT = 420
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

-- Strategies tab (placeholder)
local strategiesTab = InTenebris:RegisterTab("strategies", "Strategies", 2)
local strategiesPlaceholder = strategiesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
strategiesPlaceholder:SetPoint("CENTER", strategiesTab, "CENTER", 0, 0)
strategiesPlaceholder:SetText("|cff666666Coming soon.|r")

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
optionsContent:SetHeight(600)
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

-- "Show loot attributions:" label
local showAttribLabel = optionsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
showAttribLabel:SetPoint("TOPLEFT", tooltipSectionSep, "BOTTOMLEFT", 0, -12)
showAttribLabel:SetText("Show loot attributions:")

-- Dropdown for attribution display mode
local dropdownName = "InTenebrisShowAttributionsDropdown"
local dropdown = CreateFrame("Frame", dropdownName, optionsContent, "UIDropDownMenuTemplate")
dropdown:SetPoint("LEFT", showAttribLabel, "RIGHT", -8, -2)

local ATTRIB_OPTIONS = {
	{ text = "When in a party or raid", value = "group" },
	{ text = "Always", value = "always" },
}

local function ShowAttributionsDropdown_Initialize()
	for _, option in ipairs(ATTRIB_OPTIONS) do
		local optionValue = option.value
		local info = {}
		info.text = option.text
		info.value = optionValue
		info.func = function()
			InTenebris.db.profile.showAttributions = optionValue
			UIDropDownMenu_SetSelectedValue(dropdown, optionValue)
		end
		info.checked = nil
		UIDropDownMenu_AddButton(info)
	end
end

UIDropDownMenu_Initialize(dropdown, ShowAttributionsDropdown_Initialize)
UIDropDownMenu_SetWidth(180, dropdown)

-- Set initial value from saved profile on show
local originalOnShow = optionsTab:GetScript("OnShow")
optionsTab:SetScript("OnShow", function()
	if originalOnShow then
		originalOnShow()
	end
	local currentValue = InTenebris.db.profile.showAttributions
	UIDropDownMenu_SetSelectedValue(dropdown, currentValue)
	for _, option in ipairs(ATTRIB_OPTIONS) do
		if option.value == currentValue then
			UIDropDownMenu_SetText(option.text, dropdown)
			break
		end
	end
end)
