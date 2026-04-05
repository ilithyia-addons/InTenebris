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
		table.insert(parts, "    { ")
		table.insert(parts, "timestamp = " .. e.timestamp .. ", ")
		table.insert(parts, 'date = "' .. EscapeString(e.date) .. '", ')
		table.insert(parts, 'zone = "' .. EscapeString(e.zone) .. '", ')
		table.insert(parts, 'player = "' .. EscapeString(e.player) .. '", ')
		table.insert(parts, 'class = "' .. EscapeString(e.class) .. '", ')
		table.insert(parts, "itemId = " .. e.itemId .. ", ")
		table.insert(parts, 'itemName = "' .. EscapeString(e.itemName) .. '", ')
		table.insert(parts, "itemQuality = " .. e.itemQuality)
		table.insert(parts, " },\n")
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

	if not CustomFileExists(LOOT_LOG_FILENAME) then
		return
	end

	local ok, err = pcall(ExecuteCustomLuaFile, LOOT_LOG_FILENAME)
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
	while table.getn(self.lootLog) > maxEntries do
		table.remove(self.lootLog, table.getn(self.lootLog))
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
	if not self.db.profile.lootLogEnabled then
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
	-- Pattern: "PlayerName receives loot: |c...|Hitem:ID:...|h[Name]|h|r."
	-- Also handles "You receive loot: ..." for the local player
	local player, itemLink = nil, nil

	-- Try "PlayerName receives loot: [item]"
	local _, _, pName, link = string.find(msg, "^(.+) receives loot: (.+)")
	if pName and link then
		player = pName
		itemLink = link
	end

	-- Try "You receive loot: [item]" (local player)
	if not player then
		local _, _, link2 = string.find(msg, "^You receive loot: (.+)")
		if link2 then
			player = UnitName("player")
			itemLink = link2
		end
	end

	if not player or not itemLink then
		return
	end

	-- Extract item ID from the link
	local _, _, itemIdStr = string.find(itemLink, "item:(%d+)")
	if not itemIdStr then
		return
	end
	local itemId = tonumber(itemIdStr)

	-- Check item quality against threshold
	local quality = GetItemStatsField(itemId, "quality")
	if not quality or quality < self.db.profile.lootLogMinQuality then
		return
	end

	-- Get item name
	local itemName = GetItemStatsField(itemId, "displayName")
	if not itemName then
		-- Fallback to GetItemInfo
		itemName = GetItemInfo(itemId)
	end
	if not itemName then
		itemName = "Item #" .. itemId
	end

	-- Get player class from raid roster cache
	local playerLower = string.lower(player)
	local classInfo = self:GetPlayerClass(playerLower)
	local class = classInfo or "Unknown"

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
	}

	-- Prepend (newest first)
	table.insert(self.lootLog, 1, entry)

	-- Save to file
	self:SaveLootLog()
end
