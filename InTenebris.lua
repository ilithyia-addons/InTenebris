InTenebris = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceHook-2.1")

-- Class colors for tooltip display
local CLASS_COLORS = {
	["Warrior"] = { r = 0.78, g = 0.61, b = 0.43 },
	["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43 },
	["Paladin"] = { r = 0.96, g = 0.55, b = 0.73 },
	["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73 },
	["Hunter"] = { r = 0.67, g = 0.83, b = 0.45 },
	["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45 },
	["Rogue"] = { r = 1.00, g = 0.96, b = 0.41 },
	["ROGUE"] = { r = 1.00, g = 0.96, b = 0.41 },
	["Priest"] = { r = 1.00, g = 1.00, b = 1.00 },
	["PRIEST"] = { r = 1.00, g = 1.00, b = 1.00 },
	["Shaman"] = { r = 0.14, g = 0.35, b = 1.00 },
	["SHAMAN"] = { r = 0.14, g = 0.35, b = 1.00 },
	["Mage"] = { r = 0.41, g = 0.80, b = 0.94 },
	["MAGE"] = { r = 0.41, g = 0.80, b = 0.94 },
	["Warlock"] = { r = 0.58, g = 0.51, b = 0.79 },
	["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79 },
	["Druid"] = { r = 1.00, g = 0.49, b = 0.04 },
	["DRUID"] = { r = 1.00, g = 0.49, b = 0.04 },
}

-- Database structure
-- You can manually edit this table to track wishlists and attributions
-- local wishlistData = {
--     wishlist = {
--         ["PlayerName"] = {itemID1, itemID2, itemID3},
--     },
--     attributions = {
--         [itemID] = {
--             {rank = 1, player = "PlayerName"},
--             {rank = 2, player = "PlayerName"},
--         },
--     },
-- }
local wishlistData = {
	wishlist = {
		["DARNOM"] = { 17063, 58211, 58211, 58211, 58211, 58211, 58211, 58211 },
		["LYENN"] = { 17063 },
		["XENTRIS"] = { 19137, 17063, 18821 },
		["CYNDA"] = { 18820, 16833, 16836, 18842, 18423, 16901, 16900 },
		["MIQUETANERE"] = { 19140, 18875, 16900, 16831, 18814 },
		["YAKHAI"] = { 17063 },
		["COVAS"] = { 18810, 19140, 18814 },
		["FUMBLEBEE"] = { 18814 },
		["YSARIO"] = { 19137, 16853 },
		["DOUWI"] = { 17204, 16859 },
		["DEASP"] = { 19140, 16955 },
		["KANZEON"] = { 19140, 17103, 16955, 16855 },
		["CAILLOU"] = { 19140, 16853 },
		["NONOEIL"] = { 17063 },
		["MCKEE"] = { 19361, 19377, 19003, 16942, 16937, 16940 },
		["DAZAA"] = { 17063 },
		["RADIATEK"] = { 58244, 58213, 18814, 19136, 16800 },
		["ETHYNE"] = { 16921, 18814, 18811, 19140, 16811 },
		["HEYLARI"] = { 18814 },
		["ERINDRA"] = { 16922, 16921, 58205 },
		["ZOHOMBRE"] = { 19147, 18808, 19145 },
		["ILITHYIA"] = { 19147, 16929 },
		["PEDROLITO"] = { 16841, 17063 },
		["POKPOK"] = { 19140, 17064 },
		["KARGLASS"] = { 18814 },
		["MUNDUK"] = { 16946, 16947, 18814, 19138 },
	},
	attributions = {
		[17204] = {
			{ rank = 1, player = "DOUWI" },
		},
		[17104] = {
			{ rank = 1, player = "ZEO" },
		},
		[17103] = {
			{ rank = 1, player = "KANZEON" },
		},
		[58205] = {
			{ rank = 1, player = "ERINDRA" },
		},
		[58213] = {
			{ rank = 1, player = "RADIATEK" },
		},
		[17063] = {
			{ rank = 1, player = "DAZAA" },
			{ rank = 2, player = "NONOEIL" },
		},
		[18814] = {
			{ rank = 1, player = "HEYLARI" },
			{ rank = 2, player = "FUMBLEBEE" },
		},
		[19138] = {
			{ rank = 1, player = "FUMBLEBEE" },
		},
		[18821] = {
			{ rank = 1, player = "EIDSON" },
			{ rank = 2, player = "XENTRIS" },
		},
		[19140] = {
			{ rank = 1, player = "CAILLOU" },
			{ rank = 2, player = "ETHYNE" },
			{ rank = 3, player = "POKPOK" },
		},
		[19147] = {
			{ rank = 1, player = "ILITHYIA" },
			{ rank = 2, player = "EPWOK" },
			{ rank = 3, player = "ZOHOMBRE" },
		},
		[17064] = {
			{ rank = 1, player = "POKPOK" },
		},
		[19137] = {
			{ rank = 1, player = "XENTRIS" },
			{ rank = 2, player = "YSARIO" },
		},
		[18875] = {
			{ rank = 1, player = "MIQUETANERE" },
		},
		[19136] = {
			{ rank = 1, player = "RADIATEK" },
		},
		[17102] = {
			{ rank = 1, player = "ROKAROGUE" },
			{ rank = 2, player = "KALIUR" },
			{ rank = 3, player = "YAKHAI" },
		},
		[18810] = {
			{ rank = 1, player = "COVAS" },
		},
		[16839] = {
			{ rank = 1, player = "MUNDUK" },
		},
		[18808] = {
			{ rank = 1, player = "ZOHOMBRE" },
		},
		[16900] = {
			{ rank = 1, player = "YAKHAI" },
			{ rank = 2, player = "MIQUETANERE" },
		},
		[16955] = {
			{ rank = 1, player = "KANZEON" },
		},
		[16954] = {
			{ rank = 1, player = "GUURU" },
		},
		[16915] = {
			{ rank = 1, player = "JELLOPY" },
			{ rank = 2, player = "PIMKINWATATA" },
		},
		[16921] = {
			{ rank = 1, player = "ERINDRA" },
		},
		[16922] = {
			{ rank = 1, player = "ERINDRA" },
			{ rank = 2, player = "ETHYNE" },
			{ rank = 3, player = "BOYNIC" },
		},
		[16929] = {
			{ rank = 1, player = "ILITHYIA" },
		},
		[16947] = {
			{ rank = 1, player = "YEAHMAN" },
		},
		[16946] = {
			{ rank = 1, player = "EIDSON" },
		},
		[16854] = {
			{ rank = 1, player = "BELLISARIA" },
		},
		[16853] = {
			{ rank = 1, player = "YSARIO" },
			{ rank = 2, player = "SCARI" },
		},
		[16860] = {
			{ rank = 1, player = "DEASP" },
		},
		[16855] = {
			{ rank = 1, player = "KANZEON" },
		},
		[16859] = {
			{ rank = 1, player = "DOUWI" },
		},
		[16866] = {
			{ rank = 1, player = "LYENN" },
		},
		[16844] = {
			{ rank = 1, player = "KARGLASS" },
			{ rank = 2, player = "ZIQHOO" },
		},
		[16841] = {
			{ rank = 1, player = "PEDROLITO" },
			{ rank = 2, player = "FLOWSHAM" },
			{ rank = 3, player = "KARGLASS" },
		},
		[16843] = {
			{ rank = 1, player = "ZIQHOO" },
		},
		[16837] = {
			{ rank = 1, player = "ZIQHOO" },
			{ rank = 2, player = "PEDROLITO" },
		},
		[16811] = {
			{ rank = 1, player = "ETHYNE" },
		},
		[16829] = {
			{ rank = 1, player = "FUMBLEBEE" },
		},
		[16831] = {
			{ rank = 1, player = "MIQUETANERE" },
		},
		[16800] = {
			{ rank = 1, player = "RADIATEK" },
		},
	},
}

-- Lookup tables (built at runtime from wishlistData)
local wishlistLookup = {} -- [itemID] = {player1_lower, player2_lower, ...}
local attributionLookup = {} -- [itemID] = {{rank = 1, playerLower = "name"}, ...}
local nameCaseMap = {} -- Maps lowercase names to original case for display

-- Raid roster cache (updated on RAID_ROSTER_UPDATE and PARTY_MEMBERS_CHANGED)
local raidRosterCache = {} -- [playerNameLower] = {name = "OriginalCase", class = "CLASS"}

-- Build lookup tables from player-centric data
function InTenebris:BuildLookupTables()
	-- Clear existing lookup tables
	wishlistLookup = {}
	attributionLookup = {}
	nameCaseMap = {}

	-- Build wishlist lookup: itemID -> {player1_lower, player2_lower, ...}
	-- Store lowercase names for case-insensitive matching
	if wishlistData.wishlist then
		for playerName, items in pairs(wishlistData.wishlist) do
			local playerLower = string.lower(playerName)
			nameCaseMap[playerLower] = playerName -- Map lowercase to original case

			for _, itemID in ipairs(items) do
				if not wishlistLookup[itemID] then
					wishlistLookup[itemID] = {}
				end
				table.insert(wishlistLookup[itemID], playerLower)
			end
		end
	end

	-- Build attribution lookup: itemID -> {rank = X, playerLower = "name", ...}
	if wishlistData.attributions then
		for itemID, attributions in pairs(wishlistData.attributions) do
			if not attributionLookup[itemID] then
				attributionLookup[itemID] = {}
			end
			for _, attribution in ipairs(attributions) do
				local playerLower = string.lower(attribution.player)
				nameCaseMap[playerLower] = attribution.player -- Map lowercase to original case
				table.insert(attributionLookup[itemID], {
					rank = attribution.rank,
					playerLower = playerLower,
				})
			end
		end
	end
end

-- Update raid roster cache from current raid/party members
function InTenebris:UpdateRaidRosterCache()
	-- Clear cache
	raidRosterCache = {}

	-- Add raid members
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local name, _, _, _, class = GetRaidRosterInfo(i)
			if name and class then
				local nameLower = string.lower(name)
				raidRosterCache[nameLower] = {
					name = name,
					class = class,
				}
			end
		end
	else
		-- Add party members
		for i = 1, GetNumPartyMembers() do
			local name = UnitName("party" .. i)
			local _, class = UnitClass("party" .. i)
			if name and class then
				local nameLower = string.lower(name)
				raidRosterCache[nameLower] = {
					name = name,
					class = class,
				}
			end
		end

		-- Add player
		local playerName = UnitName("player")
		local _, playerClass = UnitClass("player")
		if playerName and playerClass then
			local nameLower = string.lower(playerName)
			raidRosterCache[nameLower] = {
				name = playerName,
				class = playerClass,
			}
		end
	end
end

function InTenebris:OnInitialize()
	-- Initialize saved variables if they don't exist
	if not wishlistData then
		wishlistData = {
			wishlist = {},
			attributions = {},
		}
	end

	-- Ensure both tables exist
	if not wishlistData.wishlist then
		wishlistData.wishlist = {}
	end
	if not wishlistData.attributions then
		wishlistData.attributions = {}
	end

	-- Build lookup tables for quick item->players queries
	self:BuildLookupTables()

	-- Build initial raid roster cache
	self:UpdateRaidRosterCache()
end

function InTenebris:OnEnable()
	-- Hook Tooltips
	InTenebris:HookTooltips()

	-- Register events to update raid roster cache
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateRaidRosterCache")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "UpdateRaidRosterCache")
end

-- Get player class by name from cache
-- playerNameLower should be lowercase for case-insensitive matching
function InTenebris:GetPlayerClass(playerNameLower)
	local cached = raidRosterCache[playerNameLower]
	if cached then
		return cached.class
	end
	return nil
end

-- Get player name by name from cache
-- playerNameLower should be lowercase for case-insensitive matching
function InTenebris:GetPlayerName(playerNameLower)
	local cached = raidRosterCache[playerNameLower]
	if cached then
		return cached.name
	end
	return nil
end

-- Check if player is in current raid using cache
-- playerNameLower should be lowercase for case-insensitive matching
function InTenebris:IsPlayerInRaid(playerNameLower)
	return raidRosterCache[playerNameLower] ~= nil
end

-- Get color code for class
function InTenebris:GetClassColorCode(class)
	if class and CLASS_COLORS[class] then
		local color = CLASS_COLORS[class]
		return string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
	end
	return "|cff999999" -- Gray for unknown class
end

local function AddHeaderToTooltip(frame)
	-- Add header
	frame:AddLine(" ")
	frame:AddLine("|cffffd94dIn Tenebris|r")
end

local function AddInTenebrisDataToTooltip(frame, itemID)
	local wishlistPlayersLower = wishlistLookup[itemID]
	local itemAttributions = attributionLookup[itemID]
	local shiftKeyPressed = IsShiftKeyDown()
	local headerAdded = false

	-- If no data, don't add anything
	if
		(not wishlistPlayersLower or table.getn(wishlistPlayersLower) == 0)
		and (not itemAttributions or table.getn(itemAttributions) == 0)
	then
		return
	end

	-- Add attribution info
	if itemAttributions and table.getn(itemAttributions) > 0 then
		local raidAttributions = {}
		local allAttributions = {}

		-- Process attributions
		for _, attribution in ipairs(itemAttributions) do
			local isInRaid = InTenebris:IsPlayerInRaid(attribution.playerLower)
			local class = InTenebris:GetPlayerClass(attribution.playerLower)
			local displayName = InTenebris:GetPlayerName(attribution.playerLower)
				or nameCaseMap[attribution.playerLower]
				or attribution.playerLower
			local data = { rank = attribution.rank, name = displayName, class = class }

			table.insert(allAttributions, data)
			if isInRaid then
				table.insert(raidAttributions, data)
			end
		end

		-- Show attributions (raid members only, unless ALT is pressed)
		local attributionsToShow = shiftKeyPressed and allAttributions or raidAttributions
		if table.getn(attributionsToShow) > 0 then
			if headerAdded == false then
				AddHeaderToTooltip(frame)
				headerAdded = true
			end
			frame:AddLine("|cffffd94dAttributions:|r")

			for _, data in ipairs(attributionsToShow) do
				local colorCode = InTenebris:GetClassColorCode(data.class)
				frame:AddLine("  " .. data.rank .. ". " .. colorCode .. data.name .. "|r")
			end
		end
	end

	-- Add wishlist info
	if wishlistPlayersLower and table.getn(wishlistPlayersLower) > 0 then
		local raidWishlisters = {}
		local allWishlisters = {}

		for _, playerNameLower in ipairs(wishlistPlayersLower) do
			local class = InTenebris:GetPlayerClass(playerNameLower)
			local displayName = InTenebris:GetPlayerName(playerNameLower)
				or nameCaseMap[playerNameLower]
				or playerNameLower
			local data = { name = displayName, class = class }

			table.insert(allWishlisters, data)
			if InTenebris:IsPlayerInRaid(playerNameLower) then
				table.insert(raidWishlisters, data)
			end
		end

		-- Show wishlisted by (raid members only, unless SHIFT is pressed)
		local wishlisters = shiftKeyPressed and allWishlisters or raidWishlisters
		if table.getn(wishlisters) > 0 then
			if headerAdded == false then
				AddHeaderToTooltip(frame)
				headerAdded = true
			end

			local wishlistLine = "|cffffd94dWishlisted by: |r"
			for i, data in ipairs(wishlisters) do
				local colorCode = InTenebris:GetClassColorCode(data.class)
				wishlistLine = wishlistLine .. colorCode .. data.name .. "|r"
				if i < table.getn(wishlisters) then
					wishlistLine = wishlistLine .. ", "
				end
			end

			frame:AddLine(wishlistLine)
		end
	end

	frame:Show()
end

local gameTooltipHooks = {}

function InTenebris:HookTooltips()
	for name, f in gameTooltipHooks do
		local name, f = name, f

		InTenebris:SecureHook(GameTooltip, name, f)
	end

	InTenebris:SecureHook("SetItemRef", function(itemLink)
		-- Extract item ID from link
		local _, _, itemID = string.find(itemLink, "item:(%d+)")
		itemID = tonumber(itemID)

		if not itemID then
			return
		end

		AddInTenebrisDataToTooltip(ItemRefTooltip, itemID)
	end)

	-- Hook AtlasLootTooltip
	if IsAddOnLoaded("AtlasLoot") then
		InTenebris:SecureHook(AtlasLootTooltip, "SetHyperlink", function(self, itemLink)
			-- Extract item ID from link
			local _, _, itemID = string.find(itemLink, "item:(%d+)")
			itemID = tonumber(itemID)

			if not itemID then
				return
			end

			AddInTenebrisDataToTooltip(AtlasLootTooltip, itemID)
		end)
	end
end

function gameTooltipHooks:SetHyperlink(itemstring)
	-- Extract item ID from link
	local _, _, itemID = string.find(itemstring, "item:(%d+)")
	itemID = tonumber(itemID)

	if not itemID then
		return
	end

	AddInTenebrisDataToTooltip(GameTooltip, itemID)
end

function gameTooltipHooks:SetLootItem(slot)
	local link = GetLootSlotLink(slot)
	if link then
		-- Extract item ID from link
		local _, _, itemID = string.find(link, "item:(%d+)")
		itemID = tonumber(itemID)

		if not itemID then
			return
		end

		AddInTenebrisDataToTooltip(GameTooltip, itemID)
	end
end

function gameTooltipHooks:SetBagItem(bag, slot)
	local link = GetContainerItemLink(bag, slot)
	if link then
		-- Extract item ID from link
		local _, _, itemID = string.find(link, "item:(%d+)")
		itemID = tonumber(itemID)

		if not itemID then
			return
		end

		AddInTenebrisDataToTooltip(GameTooltip, itemID)
	end
end

function gameTooltipHooks:SetInventoryItem(unit, slot)
	local link = GetInventoryItemLink(unit, slot)
	if link then
		-- Extract item ID from link
		local _, _, itemID = string.find(link, "item:(%d+)")
		itemID = tonumber(itemID)

		if not itemID then
			return
		end

		AddInTenebrisDataToTooltip(GameTooltip, itemID)
	end
end
