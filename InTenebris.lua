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
		["MWC"] = { 17204, 17104 },
		["CYNDA"] = { 18820, 18842, 16900 },
		["MIQUETANERE"] = { 19140, 18875, 16900, 16831, 18814 },
		["YAKHAI"] = { 17063 },
		["COVAS"] = { 18810, 19140, 18814 },
		["DEASP"] = { 19140 },
		["CAILLOU"] = { 19140, 16853 },
		["NONOEIL"] = { 17063 },
		["MCKEE"] = { 19361, 19377, 16942, 16937, 16940 },
		["SOUFFRANCE"] = { 18820, 58205, 16922 },
	},
	attributions = {
		[19336] = {
			{ rank = 1, player = "RAND" },
		},
		[19337] = {
			{ rank = 1, player = "RAND" },
		},
		[19369] = {
			{ rank = 1, player = "RAND" },
		},
		[19370] = {
			{ rank = 1, player = "SOUFFRANCE" },
		},
		[16904] = {
			{ rank = 1, player = "COVAS" },
			{ rank = 2, player = "MIQUETAMERE" },
		},
		[16911] = {
			{ rank = 1, player = "RAND" },
		},
		[16918] = {
			{ rank = 1, player = "RAND" },
		},
		[16926] = {
			{ rank = 1, player = "TERREN" },
		},
		[16934] = {
			{ rank = 1, player = "CERNED" },
		},
		[16935] = {
			{ rank = 1, player = "MCKEE" },
		},
		[16943] = {
			{ rank = 1, player = "POKPOK" },
			{ rank = 2, player = "BOSEIJU" },
			{ rank = 3, player = "MUNDUK" },
		},
		[16951] = {
			{ rank = 1, player = "DEASP" },
			{ rank = 2, player = "KALEN" },
		},
		[16959] = {
			{ rank = 1, player = "HODVIDAR" },
			{ rank = 2, player = "BULDOZER" },
			{ rank = 3, player = "JENAIMARRE" },
		},
		[19334] = {
			{ rank = 1, player = "DOUWI" },
			{ rank = 2, player = "MWC" },
		},
		[19335] = {
			{ rank = 1, player = "RAND" },
		},
		[19339] = {
			{ rank = 1, player = "SALOPIOT" },
		},
		[19340] = {
			{ rank = 1, player = "RAND" },
		},
		[19371] = {
			{ rank = 1, player = "RAND" },
		},
		[19372] = {
			{ rank = 1, player = "BULDOZER" },
			{ rank = 2, player = "NAHEULL" },
			{ rank = 3, player = "JENAIMARRE" },
		},
		[16818] = {
			{ rank = 1, player = "RAND" },
		},
		[16903] = {
			{ rank = 1, player = "SHARIVARY" },
		},
		[16910] = {
			{ rank = 1, player = "DAZZA" },
		},
		[16925] = {
			{ rank = 1, player = "TERREN" },
		},
		[16933] = {
			{ rank = 1, player = "CERNED" },
		},
		[16936] = {
			{ rank = 1, player = "RAND" },
		},
		[16944] = {
			{ rank = 1, player = "RAND" },
		},
		[16952] = {
			{ rank = 1, player = "KARANIR" },
			{ rank = 2, player = "KALEN" },
			{ rank = 3, player = "DOUWI" },
		},
		[16960] = {
			{ rank = 1, player = "RAND" },
		},
		[19346] = {
			{ rank = 1, player = "WORLDE" },
		},
		[19348] = {
			{ rank = 1, player = "KARANIR" },
			{ rank = 2, player = "CAILLOU" },
		},
		[19341] = {
			{ rank = 1, player = "RAND" },
		},
		[19342] = {
			{ rank = 1, player = "RAND" },
		},
		[19373] = {
			{ rank = 1, player = "RAND" },
		},
		[19374] = {
			{ rank = 1, player = "SOUFFRANCE " },
			{ rank = 2, player = "SELVIA" },
			{ rank = 3, player = "HEYLARI" },
		},
		[16898] = {
			{ rank = 1, player = "SHARIVARY" },
		},
		[16906] = {
			{ rank = 1, player = "WORLDE" },
		},
		[16912] = {
			{ rank = 1, player = "RAND" },
		},
		[16919] = {
			{ rank = 1, player = "TERREN" },
		},
		[16927] = {
			{ rank = 1, player = "CERNED" },
		},
		[16941] = {
			{ rank = 1, player = "MCKEE" },
		},
		[16949] = {
			{ rank = 1, player = "LEHOOF" },
			{ rank = 2, player = "PEDRO" },
		},
		[16957] = {
			{ rank = 1, player = "DOUWI" },
			{ rank = 2, player = "KALEN" },
		},
		[16965] = {
			{ rank = 1, player = "NAHEULL" },
			{ rank = 2, player = "HODVIDAR" },
			{ rank = 3, player = "MWC" },
		},
		[19350] = {
			{ rank = 1, player = "RAND" },
		},
		[19351] = {
			{ rank = 1, player = "WORLDE" },
		},
		[19343] = {
			{ rank = 1, player = "DOUWI" },
		},
		[19344] = {
			{ rank = 1, player = "LEHOOF" },
		},
		[19365] = {
			{ rank = 1, player = "RAND" },
		},
		[19398] = {
			{ rank = 1, player = "RAND" },
		},
		[19399] = {
			{ rank = 1, player = "RAND" },
		},
		[19400] = {
			{ rank = 1, player = "RAND" },
		},
		[19401] = {
			{ rank = 1, player = "RAND" },
		},
		[19402] = {
			{ rank = 1, player = "JENAIMARRE" },
		},
		[16899] = {
			{ rank = 1, player = "SHARIVARY" },
		},
		[16907] = {
			{ rank = 1, player = "WORLDE" },
		},
		[16913] = {
			{ rank = 1, player = "RAND" },
		},
		[16920] = {
			{ rank = 1, player = "TERREN" },
		},
		[16940] = {
			{ rank = 1, player = "MCKEE" },
		},
		[16948] = {
			{ rank = 1, player = "POKPOK" },
			{ rank = 2, player = "PEDRO" },
			{ rank = 3, player = "MUNDUK" },
		},
		[16956] = {
			{ rank = 1, player = "KALEN" },
			{ rank = 2, player = "KARANIR" },
			{ rank = 3, player = "DOUWI" },
		},
		[16964] = {
			{ rank = 1, player = "HODVIDAR" },
			{ rank = 2, player = "MWC" },
			{ rank = 3, player = "JENAIMARRE" },
		},
		[19353] = {
			{ rank = 1, player = "SHREK" },
			{ rank = 2, player = "HODVIDAR" },
		},
		[19355] = {
			{ rank = 1, player = "SALOPIOT" },
		},
		[19394] = {
			{ rank = 1, player = "RAND" },
		},
		[19395] = {
			{ rank = 1, player = "CAILLOU" },
			{ rank = 2, player = "DEASP" },
		},
		[19396] = {
			{ rank = 1, player = "RAND" },
		},
		[19397] = {
			{ rank = 1, player = "POKPOK" },
		},
		[19345] = {
			{ rank = 1, player = "RAND" },
		},
		[19368] = {
			{ rank = 1, player = "RAND" },
		},
		[19403] = {
			{ rank = 1, player = "SEVILIA" },
			{ rank = 2, player = "HEYLARI" },
			{ rank = 3, player = "SOUFFRANCE" },
		},
		[19405] = {
			{ rank = 1, player = "RAND" },
		},
		[19406] = {
			{ rank = 1, player = "JEANIAMARRE" },
		},
		[19407] = {
			{ rank = 1, player = "CERNED" },
		},
		[16899] = {
			{ rank = 1, player = "SHARIVARY" },
		},
		[16907] = {
			{ rank = 1, player = "WORLDE" },
		},
		[16913] = {
			{ rank = 1, player = "RAND" },
		},
		[16920] = {
			{ rank = 1, player = "TERREN" },
		},
		[16928] = {
			{ rank = 1, player = "RAND" },
		},
		[16940] = {
			{ rank = 1, player = "MCKEE" },
		},
		[16948] = {
			{ rank = 1, player = "POKPOK" },
			{ rank = 2, player = "PEDRO" },
			{ rank = 3, player = "MUNDUK" },
		},
		[16956] = {
			{ rank = 1, player = "KALEN" },
			{ rank = 2, player = "DOUWI" },
			{ rank = 3, player = "KARANIR" },
		},
		[16964] = {
			{ rank = 1, player = "HODVIDAR" },
			{ rank = 2, player = "MWC" },
			{ rank = 3, player = "JENAIMARRE" },
		},
		[19353] = {
			{ rank = 1, player = "SHREK" },
			{ rank = 2, player = "HODVIDAR" },
		},
		[19355] = {
			{ rank = 1, player = "SALOPIOT" },
		},
		[19394] = {
			{ rank = 1, player = "RAND" },
		},
		[19395] = {
			{ rank = 1, player = "CAILLOU" },
			{ rank = 2, player = "DEASP" },
		},
		[19396] = {
			{ rank = 1, player = "RAND" },
		},
		[19397] = {
			{ rank = 1, player = "POKPOK" },
		},
		[19357] = {
			{ rank = 1, player = "ELENELOR" },
		},
		[19367] = {
			{ rank = 1, player = "SEVILIA" },
			{ rank = 2, player = "SALOPIOT" },
		},
		[19430] = {
			{ rank = 1, player = "POKPOK" },
			{ rank = 2, player = "TERREN" },
		},
		[19431] = {
			{ rank = 1, player = "DARNOM" },
		},
		[19432] = {
			{ rank = 1, player = "MWC" },
			{ rank = 2, player = "JEANAIMARRE" },
			{ rank = 3, player = "ELENELOR" },
		},
		[19433] = {
			{ rank = 1, player = "RAND" },
		},
		[16899] = {
			{ rank = 1, player = "SHARIVARY" },
		},
		[16907] = {
			{ rank = 1, player = "WORLDE" },
		},
		[16913] = {
			{ rank = 1, player = "RAND" },
		},
		[16920] = {
			{ rank = 1, player = "TERREN" },
		},
		[16928] = {
			{ rank = 1, player = "RAND" },
		},
		[16940] = {
			{ rank = 1, player = "MCKEE" },
		},
		[16948] = {
			{ rank = 1, player = "POKPOK" },
			{ rank = 2, player = "PEDRO" },
			{ rank = 3, player = "MUNDUK" },
		},
		[16956] = {
			{ rank = 1, player = "KALEN" },
			{ rank = 2, player = "DOUWI" },
			{ rank = 3, player = "KARANIR" },
		},
		[16964] = {
			{ rank = 1, player = "HODVIDAR" },
			{ rank = 2, player = "MWC" },
			{ rank = 3, player = "JENAIMARRE" },
		},
		[19353] = {
			{ rank = 1, player = "SHREK" },
			{ rank = 2, player = "HODVIDAR" },
		},
		[19355] = {
			{ rank = 1, player = "SALOPIOT" },
		},
		[19394] = {
			{ rank = 1, player = "RAND" },
		},
		[19395] = {
			{ rank = 1, player = "CAILLOU" },
			{ rank = 2, player = "DEASP" },
		},
		[19396] = {
			{ rank = 1, player = "RAND" },
		},
		[19397] = {
			{ rank = 1, player = "POKPOK" },
		},
		[19385] = {
			{ rank = 1, player = "DEASP" },
			{ rank = 2, player = "CAILLOU" },
			{ rank = 3, player = "COVAS" },
		},
		[19387] = {
			{ rank = 1, player = "DARNOM" },
			{ rank = 2, player = "BULLDO" },
		},
		[19388] = {
			{ rank = 1, player = "LEHOOF" },
		},
		[19389] = {
			{ rank = 1, player = "RAND" },
		},
		[19386] = {
			{ rank = 1, player = "RAND" },
		},
		[19390] = {
			{ rank = 1, player = "RAND" },
		},
		[19391] = {
			{ rank = 1, player = "BOSEIJU" },
		},
		[19392] = {
			{ rank = 1, player = "RAND" },
		},
		[19393] = {
			{ rank = 1, player = "RAND" },
		},
		[16832] = {
			{ rank = 1, player = "WORLDE" },
		},
		[16902] = {
			{ rank = 1, player = "SHARIVARY" },
		},
		[16917] = {
			{ rank = 1, player = "RAND" },
		},
		[16924] = {
			{ rank = 1, player = "TERREN" },
		},
		[16932] = {
			{ rank = 1, player = "ILLITHYA" },
			{ rank = 2, player = "CERNED" },
		},
		[16937] = {
			{ rank = 1, player = "MCKEE" },
			{ rank = 2, player = "SHREK" },
		},
		[16945] = {
			{ rank = 1, player = "PEDROLITO" },
		},
		[16953] = {
			{ rank = 1, player = "DOUWI" },
			{ rank = 2, player = "KALEN" },
		},
		[16961] = {
			{ rank = 1, player = "MWC" },
			{ rank = 2, player = "JEANAIMARRE" },
			{ rank = 3, player = "BULDOZER" },
		},
		[19349] = {
			{ rank = 1, player = "DARNOM" },
		},
		[19352] = {
			{ rank = 1, player = "DAZZA" },
		},
		[19347] = {
			{ rank = 1, player = "CERNED" },
		},
		[19361] = {
			{ rank = 1, player = "MCKEE" },
		},
		[19002] = {
			{ rank = 1, player = "RAND" },
		},
		[19003] = {
			{ rank = 1, player = "HEYLARI" },
			{ rank = 2, player = "DAZZA" },
		},
		[19375] = {
			{ rank = 1, player = "SOUFFRANCE" },
			{ rank = 2, player = "HEYLARI" },
		},
		[19376] = {
			{ rank = 1, player = "RAND" },
		},
		[19377] = {
			{ rank = 1, player = "SHREK" },
			{ rank = 2, player = "MCKEE" },
			{ rank = 3, player = "DAZZA" },
		},
		[19378] = {
			{ rank = 1, player = "MUNDUK" },
			{ rank = 2, player = "LEHOOF" },
			{ rank = 3, player = "SEVILIA" },
		},
		[19379] = {
			{ rank = 1, player = "HEYLARI" },
			{ rank = 2, player = "SOUFFRANCE" },
		},
		[19380] = {
			{ rank = 1, player = "PEDRO" },
			{ rank = 2, player = "SHREK" },
		},
		[19381] = {
			{ rank = 1, player = "RAND" },
		},
		[19382] = {
			{ rank = 1, player = "POKPOK" },
			{ rank = 2, player = "DEASP" },
		},
		[16897] = {
			{ rank = 1, player = "SHARIVARY" },
			{ rank = 2, player = "MIQUETAMERE" },
		},
		[16905] = {
			{ rank = 1, player = "WORLDE" },
			{ rank = 2, player = "DAZZA" },
		},
		[16916] = {
			{ rank = 1, player = "RAND" },
		},
		[16923] = {
			{ rank = 1, player = "TERREN" },
		},
		[16931] = {
			{ rank = 1, player = "CERNED" },
			{ rank = 2, player = "ILLITHYA" },
		},
		[16942] = {
			{ rank = 1, player = "SHREK" },
			{ rank = 2, player = "MCKEE" },
		},
		[16950] = {
			{ rank = 1, player = "PEDROLITO" },
			{ rank = 2, player = "BOSEIJU" },
			{ rank = 3, player = "LEHOOF" },
		},
		[16958] = {
			{ rank = 1, player = "CAILLOU" },
			{ rank = 2, player = "DOUWI" },
			{ rank = 3, player = "KALEN" },
		},
		[16966] = {
			{ rank = 1, player = "BULDOZER" },
			{ rank = 2, player = "JEANAIMARRE" },
			{ rank = 3, player = "MWC" },
		},
		[19360] = {
			{ rank = 1, player = "MUNDUK" },
			{ rank = 2, player = "HEYLARI" },
		},
		[19363] = {
			{ rank = 1, player = "NAHEULL" },
			{ rank = 2, player = "MCKEE" },
		},
		[19356] = {
			{ rank = 1, player = "SOUFFRANCE" },
			{ rank = 2, player = "SEVILLIA" },
		},
		[19364] = {
			{ rank = 1, player = "BULLDOZER" },
			{ rank = 2, player = "MWC" },
		},
		[19358] = {
			{ rank = 1, player = "RAND" },
		},
		[19436] = {
			{ rank = 1, player = "BULLDOER" },
		},
		[19437] = {
			{ rank = 1, player = "CAILLOU" },
			{ rank = 2, player = "DEASP" },
			{ rank = 3, player = "COVAS " },
		},
		[19354] = {
			{ rank = 1, player = "RAND" },
		},
		[19438] = {
			{ rank = 1, player = "RAND" },
		},
		[19439] = {
			{ rank = 1, player = "RAND" },
		},
		[19362] = {
			{ rank = 1, player = "RAND" },
		},
		[19434] = {
			{ rank = 1, player = "RAND" },
		},
		[19435] = {
			{ rank = 1, player = "RAND" },
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
