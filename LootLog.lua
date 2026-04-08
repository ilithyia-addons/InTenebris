-- LootLog.lua
-- Loot logging: capture, persistence, and UI for InTenebris

local LOOT_LOG_FILENAME = "InTenebris_LootLog.lua"

-- ============================================================
-- Serialization
-- ============================================================

-- Escape a string for safe embedding in a Lua literal
local function EscapeString(s)
	s = string.gsub(s, "\\", "\\\\")
	s = string.gsub(s, '"', '\\"')
	s = string.gsub(s, "\n", "\\n")
	s = string.gsub(s, "\r", "\\r")
	return s
end

-- Serialize the loot log table to a valid Lua assignment string
local function SerializeLootLog(entries)
	local parts = { "InTenebris.lootLog = {\n" }
	for i = 1, table.getn(entries) do
		local e = entries[i]
		table.insert(
			parts,
			"    { "
				.. "timestamp = "
				.. e.timestamp
				.. ", "
				.. 'date = "'
				.. EscapeString(e.date)
				.. '", '
				.. 'zone = "'
				.. EscapeString(e.zone)
				.. '", '
				.. 'player = "'
				.. EscapeString(e.player)
				.. '", '
				.. 'class = "'
				.. EscapeString(e.class)
				.. '", '
				.. "itemId = "
				.. e.itemId
				.. ", "
				.. 'itemName = "'
				.. EscapeString(e.itemName)
				.. '", '
				.. "itemQuality = "
				.. e.itemQuality
				.. ", "
				.. "itemQuantity = "
				.. e.itemQuantity
				.. " },\n"
		)
	end
	table.insert(parts, "}\n")
	return table.concat(parts)
end

-- ============================================================
-- Persistence
-- ============================================================

local function PrintError(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[InTenebris] " .. msg .. "|r")
end

function InTenebris:LoadLootLog()
	self.lootLog = {}
	self.lootLogWriteError = false
	self.lootLogCorruptError = false

	-- ReadCustomFile + RunScript instead of ExecuteCustomLuaFile, which sandboxes
	-- globals and prevents the assignment to InTenebris.lootLog from persisting.
	if not CustomFileExists(LOOT_LOG_FILENAME) then
		return
	end
	local content = ReadCustomFile(LOOT_LOG_FILENAME)
	local ok, err = true, nil
	if content and content ~= "" then
		ok, err = pcall(RunScript, content)
	end
	if not ok then
		PrintError("Loot log file was corrupt and has been reset. Data was lost.")
		self.lootLogCorruptError = true
		self.lootLog = {}
		-- Wipe the corrupt file
		local wipeOk, wipeErr = pcall(WriteCustomFile, LOOT_LOG_FILENAME, "InTenebris.lootLog = {}\n", "w")
		if not wipeOk then
			PrintError("Failed to reset loot log file: " .. tostring(wipeErr))
		end
		return
	end

	-- Validate that lootLog is a table after loading
	if type(self.lootLog) ~= "table" then
		self.lootLog = {}
	end
end

function InTenebris:SaveLootLog()
	local maxEntries = self.db.profile.lootLogMaxEntries
	-- Trim oldest entries if over the limit
	local len = table.getn(self.lootLog)
	while len > maxEntries do
		table.remove(self.lootLog)
		len = len - 1
	end

	local serialized = SerializeLootLog(self.lootLog)
	local ok, err = pcall(WriteCustomFile, LOOT_LOG_FILENAME, serialized, "w")
	if not ok then
		self.lootLogWriteError = true
		PrintError("Failed to save loot log: " .. tostring(err))
	end
end

-- ============================================================
-- Loot Event Capture
-- ============================================================

function InTenebris:OnLootMessage()
	-- Early return if feature disabled or not in a raid
	if self.db.profile.lootLogEnabled ~= "yes" then
		return
	end
	if GetNumRaidMembers() == 0 then
		return
	end

	-- arg1 is the loot message text in CHAT_MSG_LOOT
	local msg = arg1
	if not msg then
		return
	end

	-- Parse player name and item link from the loot message
	-- Formats:
	--   "PlayerName receives loot: [item]" / "You receive loot: [item]"  (master loot / direct)
	--   "PlayerName won: [item]" / "You won: [item]"                    (group loot roll)
	local player, itemLink = nil, nil

	-- Try "PlayerName receives loot: [item]" or "PlayerName won: [item]"
	local _, _, pName, link = string.find(msg, "^(.+) receives loot: (.+)")
	if not pName then
		_, _, pName, link = string.find(msg, "^(.+) won: (.+)")
	end
	if pName and link then
		player = pName
		itemLink = link
	end

	-- Try "You receive loot: [item]" or "You won: [item]" (local player)
	if not player then
		local _, _, link2 = string.find(msg, "^You receive loot: (.+)")
		if not link2 then
			_, _, link2 = string.find(msg, "^You won: (.+)")
		end
		if link2 then
			player = UnitName("player")
			itemLink = link2
		end
	end

	if not player or not itemLink then
		return
	end

	-- Extract item ID and optional quantity from the link
	-- Quantity suffix appears after the color terminator: "|rx2"
	local _, _, itemIdStr = string.find(itemLink, "item:(%d+)")
	if not itemIdStr then
		return
	end
	local itemId = tonumber(itemIdStr)
	local _, _, qtyStr = string.find(itemLink, "|rx(%d+)")
	local itemQuantity = qtyStr and tonumber(qtyStr) or 1

	-- Check item quality against threshold
	local quality, itemName
	if GetItemStatsField then
		quality = GetItemStatsField(itemId, "quality")
		itemName = GetItemStatsField(itemId, "displayName")
	end
	if not quality then
		local name, _, q = GetItemInfo(itemId)
		quality = q
		itemName = itemName or name
	end
	if not quality or quality < self.db.profile.lootLogMinQuality then
		return
	end
	if not itemName then
		itemName = "Item #" .. itemId
	end

	-- Get player class from raid roster cache
	local playerLower = string.lower(player)
	local class = self:GetPlayerClass(playerLower) or "Unknown"

	-- Build the log entry
	local entry = {
		timestamp = time(),
		date = date("%Y-%m-%d %H:%M:%S"),
		zone = GetRealZoneText() or "Unknown",
		player = player,
		class = class,
		itemId = itemId,
		itemName = itemName,
		itemQuality = quality,
		itemQuantity = itemQuantity,
	}

	-- Prepend (newest first)
	table.insert(self.lootLog, 1, entry)

	-- Save to file
	self:SaveLootLog()
end

-- ============================================================
-- Loot Logs Tab UI
-- ============================================================

local QUALITY_COLORS = InTenebris.QUALITY_COLORS

local lootLogTab = InTenebris:RegisterTab("lootlog", "Loot Logs", 2)

-- State message (centered, used for no-nampower / disabled / empty / corruption states)
local stateMessage = lootLogTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
stateMessage:SetPoint("CENTER", lootLogTab, "CENTER", 0, 0)
stateMessage:SetJustifyH("CENTER")
stateMessage:SetWidth(400)
stateMessage:Hide()

-- Write error warning banner (top of tab, non-blocking)
local writeErrorBanner = lootLogTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
writeErrorBanner:SetPoint("TOPLEFT", lootLogTab, "TOPLEFT", 4, 2)
writeErrorBanner:SetTextColor(1, 0.3, 0.3, 1)
writeErrorBanner:Hide()

-- Search box
local logSearchBox = CreateFrame("EditBox", "InTenebrisLootLogSearch", lootLogTab)
logSearchBox:SetFontObject(GameFontNormalSmall)
logSearchBox:SetAutoFocus(false)
logSearchBox:SetWidth(160)
logSearchBox:SetHeight(20)
logSearchBox:SetPoint("TOPRIGHT", lootLogTab, "TOPRIGHT", -4, 0)
logSearchBox:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 12,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
logSearchBox:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
logSearchBox:SetBackdropBorderColor(0.4, 0.35, 0.2, 0.6)
logSearchBox:SetTextInsets(4, 4, 0, 0)
logSearchBox:SetMaxLetters(50)

local logSearchPlaceholder = logSearchBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
logSearchPlaceholder:SetPoint("LEFT", logSearchBox, "LEFT", 6, 0)
logSearchPlaceholder:SetText("|cff666666Search...|r")

logSearchBox:SetScript("OnEscapePressed", function()
	this:ClearFocus()
end)

logSearchBox:SetScript("OnEditFocusGained", function()
	logSearchPlaceholder:Hide()
end)

logSearchBox:SetScript("OnEditFocusLost", function()
	if this:GetText() == "" then
		logSearchPlaceholder:Show()
	end
end)

-- Scroll frame
local logScroll = CreateFrame("ScrollFrame", "InTenebrisLootLogScroll", lootLogTab, "UIPanelScrollFrameTemplate")
logScroll:SetPoint("TOPLEFT", lootLogTab, "TOPLEFT", 0, -28)
logScroll:SetPoint("BOTTOMRIGHT", lootLogTab, "BOTTOMRIGHT", -26, 0)

local LOOT_LOG_FRAME_WIDTH = 680
local LOOT_LOG_SIDE_PANEL_WIDTH = 130
local LOG_CONTENT_WIDTH = LOOT_LOG_FRAME_WIDTH - LOOT_LOG_SIDE_PANEL_WIDTH - 110

local logScrollChild = CreateFrame("Frame", nil, logScroll)
logScrollChild:SetWidth(LOG_CONTENT_WIDTH)
logScrollChild:SetHeight(1)
logScroll:SetScrollChild(logScrollChild)

-- Font pool for log entries
local logFontPool = {}
local logFontPoolUsed = 0

local function AcquireLogFontString()
	logFontPoolUsed = logFontPoolUsed + 1
	if not logFontPool[logFontPoolUsed] then
		logFontPool[logFontPoolUsed] = logScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	end
	local fs = logFontPool[logFontPoolUsed]
	fs:SetFontObject(GameFontNormalSmall)
	fs:SetTextColor(1, 1, 1, 1)
	fs:SetJustifyH("LEFT")
	fs:SetWidth(LOG_CONTENT_WIDTH)
	fs:Show()
	return fs
end

local function ResetLogPool()
	for i = 1, logFontPoolUsed do
		logFontPool[i]:Hide()
		logFontPool[i]:ClearAllPoints()
	end
	logFontPoolUsed = 0
end

-- Search state
local logSearchText = ""

-- Render the loot log list
local function RenderLootLog()
	ResetLogPool()

	-- Hide all UI elements first
	stateMessage:Hide()
	writeErrorBanner:Hide()
	logSearchBox:Hide()
	logScroll:Hide()

	-- State 1: No nampower
	if not InTenebris.hasNampower then
		stateMessage:SetText(
			"|cff999999Loot Logs requires nampower, which can be\nenabled in the TurtleWoW launcher.|r"
		)
		stateMessage:Show()
		return
	end

	-- State 2: Feature disabled
	if InTenebris.db.profile.lootLogEnabled ~= "yes" then
		stateMessage:SetText("|cff999999Loot logging is disabled.\nYou can enable it in the Options tab.|r")
		stateMessage:Show()
		return
	end

	-- State 3: Corruption error
	if InTenebris.lootLogCorruptError then
		stateMessage:SetText("|cffff3333Loot log file was corrupt and has been reset.\nAll previous data was lost.|r")
		stateMessage:Show()
		return
	end

	-- Show write error banner if applicable
	if InTenebris.lootLogWriteError then
		writeErrorBanner:SetText("Warning: Failed to save loot log to disk. Data may be lost on disconnect.")
		writeErrorBanner:Show()
	end

	-- State 4: Empty log
	local entries = InTenebris.lootLog or {}
	if table.getn(entries) == 0 then
		stateMessage:SetText(
			"|cff999999Loot dropped in raids will be recorded here\nautomatically. Join a raid group to start logging.|r"
		)
		stateMessage:Show()
		return
	end

	-- State 5: Has entries — show search + list
	logSearchBox:Show()
	logScroll:Show()

	local searchLower = string.lower(logSearchText)
	local hasSearch = searchLower ~= ""
	local yOffset = 0

	for i = 1, table.getn(entries) do
		local e = entries[i]

		-- Apply search filter
		local matchesSearch = true
		if hasSearch then
			matchesSearch = string.find(string.lower(e.player), searchLower, 1, true)
				or string.find(string.lower(e.itemName), searchLower, 1, true)
				or string.find(string.lower(e.zone), searchLower, 1, true)
		end

		if matchesSearch then
			-- Build the display line
			local qualityColor = QUALITY_COLORS[e.itemQuality] or "ffffffff"
			local classColor = InTenebris:GetClassColorCode(e.class)

			local quantityText = ""
			if e.itemQuantity > 1 then
				quantityText = " x" .. e.itemQuantity
			end

			local line = "|cff999999"
				.. e.date
				.. "|r"
				.. "  |cffcccccc"
				.. e.zone
				.. "|r"
				.. " - |c"
				.. qualityColor
				.. e.itemName
				.. "|r"
				.. quantityText
				.. " - "
				.. classColor
				.. e.player
				.. "|r"

			local fs = AcquireLogFontString()
			fs:SetPoint("TOPLEFT", logScrollChild, "TOPLEFT", 0, -yOffset)
			fs:SetText(line)
			yOffset = yOffset + 14
		end
	end

	if yOffset == 0 then
		local noResults = AcquireLogFontString()
		noResults:SetPoint("CENTER", logScrollChild, "TOP", 0, -60)
		noResults:SetJustifyH("CENTER")
		noResults:SetText("|cff666666No results found.|r")
		yOffset = 120
	end

	logScrollChild:SetHeight(yOffset)
	logScroll:SetVerticalScroll(0)
end

-- Wire up search
logSearchBox:SetScript("OnTextChanged", function()
	logSearchText = this:GetText()
	if logSearchText == "" then
		logSearchPlaceholder:Show()
	else
		logSearchPlaceholder:Hide()
	end
	RenderLootLog()
end)

-- Render on tab show
local originalLogOnShow = lootLogTab:GetScript("OnShow")
lootLogTab:SetScript("OnShow", function()
	if originalLogOnShow then
		originalLogOnShow()
	end
	RenderLootLog()
end)
