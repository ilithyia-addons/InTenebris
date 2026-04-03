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

-- Content header subtitle (right-aligned, for contextual info like dates)
local contentHeaderSubtitle = contentArea:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
contentHeaderSubtitle:SetPoint("RIGHT", contentArea, "RIGHT", -14, 0)
contentHeaderSubtitle:SetPoint("TOP", contentArea, "TOP", 0, -15)
contentHeaderSubtitle:SetTextColor(0.6, 0.6, 0.6, 1)

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
			if tab.subtitle then
				contentHeaderSubtitle:SetText(tab.subtitle)
				contentHeaderSubtitle:Show()
			else
				contentHeaderSubtitle:Hide()
			end
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

-- ============================================================
-- Loot Attributions tab
-- ============================================================

local lootTab = InTenebris:RegisterTab("loot", "Loot Attributions", 1)

-- Item quality color codes
local QUALITY_COLORS = {
	[0] = "ff9d9d9d", -- Poor
	[1] = "ffffffff", -- Common
	[2] = "ff1eff00", -- Uncommon
	[3] = "ff0070dd", -- Rare
	[4] = "ffa335ee", -- Epic
	[5] = "ffff8000", -- Legendary
}

-- Hidden tooltip for forcing item cache
local scanTooltip = CreateFrame("GameTooltip", "InTenebrisScanTooltip", UIParent, "GameTooltipTemplate")
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

-- Item info cache: [itemID] = { name = "raw", colored = "|c...|r", quality = N }
local itemInfoCache = {}

local function CacheItemInfo(itemID)
	if itemInfoCache[itemID] then
		return itemInfoCache[itemID]
	end
	local name, _, quality = GetItemInfo(itemID)
	if not name then
		scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
		scanTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0")
		scanTooltip:Hide()
		name, _, quality = GetItemInfo(itemID)
	end
	if name then
		local colorCode = QUALITY_COLORS[quality] or "ffffffff"
		itemInfoCache[itemID] = {
			name = name,
			colored = "|c" .. colorCode .. name .. "|r",
			quality = quality or 1,
		}
	else
		itemInfoCache[itemID] = {
			name = "Item #" .. itemID,
			colored = "|cff999999Item #" .. itemID .. "|r",
			quality = 0,
		}
	end
	return itemInfoCache[itemID]
end

-- View state
local lootCurrentView = "byItem"
local lootSearchText = ""

-- Content dimensions
local LOOT_CONTENT_WIDTH = FRAME_WIDTH - SIDE_PANEL_WIDTH - 110

-- View toggle buttons
local function CreateViewToggleButton(parent, text, x)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetWidth(80)
	btn:SetHeight(22)
	btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, 2)

	local bg = btn:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(0, 0, 0, 0)
	btn.bg = bg

	local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("CENTER", btn, "CENTER", 0, 0)
	label:SetText(text)
	btn.label = label

	local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetTexture(1, 1, 1, 0.05)

	return btn
end

local byItemButton = CreateViewToggleButton(lootTab, "By Item", 4)
local byPlayerButton = CreateViewToggleButton(lootTab, "By Player", 88)

local function UpdateViewToggleAppearance()
	if lootCurrentView == "byItem" then
		byItemButton.bg:SetTexture(0.6, 0.5, 0.15, 0.25)
		byItemButton.label:SetTextColor(1.0, 0.85, 0.30, 1)
		byPlayerButton.bg:SetTexture(0, 0, 0, 0)
		byPlayerButton.label:SetTextColor(0.55, 0.47, 0.25, 1)
	else
		byPlayerButton.bg:SetTexture(0.6, 0.5, 0.15, 0.25)
		byPlayerButton.label:SetTextColor(1.0, 0.85, 0.30, 1)
		byItemButton.bg:SetTexture(0, 0, 0, 0)
		byItemButton.label:SetTextColor(0.55, 0.47, 0.25, 1)
	end
end

-- Search box
local searchBox = CreateFrame("EditBox", "InTenebrisLootSearch", lootTab)
searchBox:SetFontObject(GameFontNormalSmall)
searchBox:SetAutoFocus(false)
searchBox:SetWidth(160)
searchBox:SetHeight(20)
searchBox:SetPoint("TOPRIGHT", lootTab, "TOPRIGHT", -4, 0)
searchBox:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 12,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
searchBox:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
searchBox:SetBackdropBorderColor(0.4, 0.35, 0.2, 0.6)
searchBox:SetTextInsets(4, 4, 0, 0)
searchBox:SetMaxLetters(50)

local searchPlaceholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
searchPlaceholder:SetPoint("LEFT", searchBox, "LEFT", 6, 0)
searchPlaceholder:SetText("|cff666666Search...|r")

searchBox:SetScript("OnEscapePressed", function()
	this:ClearFocus()
end)

searchBox:SetScript("OnEditFocusGained", function()
	searchPlaceholder:Hide()
end)

searchBox:SetScript("OnEditFocusLost", function()
	if this:GetText() == "" then
		searchPlaceholder:Show()
	end
end)

-- Scroll frame for loot content
local lootScroll = CreateFrame("ScrollFrame", "InTenebrisLootScroll", lootTab, "UIPanelScrollFrameTemplate")
lootScroll:SetPoint("TOPLEFT", lootTab, "TOPLEFT", 0, -28)
lootScroll:SetPoint("BOTTOMRIGHT", lootTab, "BOTTOMRIGHT", -26, 0)

local lootScrollChild = CreateFrame("Frame", nil, lootScroll)
lootScrollChild:SetWidth(LOOT_CONTENT_WIDTH)
lootScrollChild:SetHeight(1)
lootScroll:SetScrollChild(lootScrollChild)

-- FontString pool for reusable text lines
local lootFontPool = {}
local lootFontPoolUsed = 0

local function AcquireFontString(fontObject)
	lootFontPoolUsed = lootFontPoolUsed + 1
	if not lootFontPool[lootFontPoolUsed] then
		lootFontPool[lootFontPoolUsed] = lootScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	end
	local fs = lootFontPool[lootFontPoolUsed]
	fs:SetFontObject(fontObject or GameFontNormalSmall)
	fs:SetTextColor(1, 1, 1, 1)
	fs:SetJustifyH("LEFT")
	fs:SetWidth(LOOT_CONTENT_WIDTH)
	fs:Show()
	return fs
end

local function ResetFontPool()
	for i = 1, lootFontPoolUsed do
		lootFontPool[i]:Hide()
		lootFontPool[i]:ClearAllPoints()
	end
	lootFontPoolUsed = 0
end

-- Forward declaration
local RenderLootAttributions

-- Render the loot attributions list
RenderLootAttributions = function()
	ResetFontPool()

	local yOffset = 0
	local searchLower = string.lower(lootSearchText)
	local hasSearch = searchLower ~= ""

	if lootCurrentView == "byItem" then
		-- Collect and sort items by name
		local items = {}
		if InTenebris.wishlistData and InTenebris.wishlistData.attributions then
			for itemID, attributions in pairs(InTenebris.wishlistData.attributions) do
				local info = CacheItemInfo(itemID)
				table.insert(items, {
					itemID = itemID,
					info = info,
					attributions = attributions,
				})
			end
		end
		table.sort(items, function(a, b)
			return a.info.name < b.info.name
		end)

		for _, item in ipairs(items) do
			-- Check search filter: match item name or any player name
			local matchesSearch = true
			if hasSearch then
				matchesSearch = string.find(string.lower(item.info.name), searchLower, 1, true)
				if not matchesSearch then
					for _, attr in ipairs(item.attributions) do
						if string.find(string.lower(attr.player), searchLower, 1, true) then
							matchesSearch = true
							break
						end
					end
				end
			end

			if matchesSearch then
				-- Item header
				local header = AcquireFontString(GameFontNormal)
				header:SetPoint("TOPLEFT", lootScrollChild, "TOPLEFT", 0, -yOffset)
				header:SetText(item.info.colored)
				yOffset = yOffset + 16

				-- Attribution entries
				for _, attr in ipairs(item.attributions) do
					local entry = AcquireFontString(GameFontNormalSmall)
					entry:SetPoint("TOPLEFT", lootScrollChild, "TOPLEFT", 16, -yOffset)
					entry:SetText(attr.rank .. ". " .. attr.player)
					yOffset = yOffset + 14
				end

				yOffset = yOffset + 8
			end
		end
	else
		-- By Player view: invert attributions to player -> items
		local playerItems = {}
		local playerList = {}

		if InTenebris.wishlistData and InTenebris.wishlistData.attributions then
			for itemID, attributions in pairs(InTenebris.wishlistData.attributions) do
				for _, attr in ipairs(attributions) do
					local player = attr.player
					if not playerItems[player] then
						playerItems[player] = {}
						table.insert(playerList, player)
					end
					table.insert(playerItems[player], {
						itemID = itemID,
						rank = attr.rank,
					})
				end
			end
		end

		table.sort(playerList)

		-- Sort each player's items by rank
		for _, player in ipairs(playerList) do
			table.sort(playerItems[player], function(a, b)
				return a.rank < b.rank
			end)
		end

		for _, player in ipairs(playerList) do
			local items = playerItems[player]

			-- Check search filter: match player name or any item name
			local matchesSearch = true
			if hasSearch then
				matchesSearch = string.find(string.lower(player), searchLower, 1, true)
				if not matchesSearch then
					for _, item in ipairs(items) do
						local info = CacheItemInfo(item.itemID)
						if string.find(string.lower(info.name), searchLower, 1, true) then
							matchesSearch = true
							break
						end
					end
				end
			end

			if matchesSearch then
				-- Player header
				local header = AcquireFontString(GameFontNormal)
				header:SetPoint("TOPLEFT", lootScrollChild, "TOPLEFT", 0, -yOffset)
				header:SetText("|cffffd94d" .. player .. "|r")
				yOffset = yOffset + 16

				-- Item entries
				for _, item in ipairs(items) do
					local info = CacheItemInfo(item.itemID)
					local entry = AcquireFontString(GameFontNormalSmall)
					entry:SetPoint("TOPLEFT", lootScrollChild, "TOPLEFT", 16, -yOffset)
					entry:SetText("Rank " .. item.rank .. ": " .. info.colored)
					yOffset = yOffset + 14
				end

				yOffset = yOffset + 8
			end
		end
	end

	if yOffset == 0 then
		local noResults = AcquireFontString(GameFontNormal)
		noResults:SetPoint("CENTER", lootScrollChild, "TOP", 0, -60)
		noResults:SetJustifyH("CENTER")
		noResults:SetText("|cff666666No results found.|r")
		yOffset = 120
	end

	lootScrollChild:SetHeight(yOffset)
	lootScroll:SetVerticalScroll(0)

	UpdateViewToggleAppearance()
end

-- Wire up view toggle buttons
byItemButton:SetScript("OnClick", function()
	lootCurrentView = "byItem"
	RenderLootAttributions()
end)

byPlayerButton:SetScript("OnClick", function()
	lootCurrentView = "byPlayer"
	RenderLootAttributions()
end)

-- Wire up search
searchBox:SetScript("OnTextChanged", function()
	lootSearchText = this:GetText()
	if lootSearchText == "" then
		searchPlaceholder:Show()
	else
		searchPlaceholder:Hide()
	end
	RenderLootAttributions()
end)

-- Render on tab show
local originalLootOnShow = lootTab:GetScript("OnShow")
lootTab:SetScript("OnShow", function()
	if originalLootOnShow then
		originalLootOnShow()
	end
	-- Update subtitle with generation date
	if InTenebris.wishlistData and InTenebris.wishlistData.generatedDate then
		tabs["loot"].subtitle = "Data from " .. InTenebris.wishlistData.generatedDate
		contentHeaderSubtitle:SetText(tabs["loot"].subtitle)
		contentHeaderSubtitle:Show()
	end
	RenderLootAttributions()
end)

-- ============================================================
-- Strategies tab
-- ============================================================

local strategiesTab = InTenebris:RegisterTab("strategies", "Strategies", 2)

-- Image dimensions (fill content width, 2:1 aspect ratio matching 1024x512 textures)
local STRATEGY_IMAGE_WIDTH = FRAME_WIDTH - SIDE_PANEL_WIDTH - 84
local STRATEGY_IMAGE_HEIGHT = math.floor(STRATEGY_IMAGE_WIDTH / 2)

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
