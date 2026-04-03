InTenebris = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceHook-2.1", "AceDB-2.0")

-- Register saved variables database
InTenebris:RegisterDB("InTenebrisDB", "InTenebrisCharDB")
InTenebris:RegisterDefaults("char", {
	minimapAngle = 220,
})
InTenebris:RegisterDefaults("profile", {
	showAttributions = "group", -- "group" = when in party/raid, "always" = always
	showOutOfGroup = "no", -- "yes" = show players not in your group, "no" = only group members
})

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

-- Utility namespaces
InTenebris.Utils = {}
InTenebris.Utils.String = {}

function InTenebris.Utils.String.trim(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

-- Wishlist data is loaded from WishlistData.lua (stored in InTenebris.wishlistData)
local wishlistData

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
			playerName = InTenebris.Utils.String.trim(playerName)
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
				local playerTrimmed = InTenebris.Utils.String.trim(attribution.player)
				local playerLower = string.lower(playerTrimmed)
				nameCaseMap[playerLower] = playerTrimmed -- Map lowercase to original case
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
	-- Load wishlist data from WishlistData.lua (assigned to InTenebris.wishlistData)
	wishlistData = self.wishlistData or {
		wishlist = {},
		attributions = {},
	}

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

	-- Load saved minimap button position
	if self.LoadMinimapButtonPosition then
		self:LoadMinimapButtonPosition()
	end
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

-- Pre-computed class color codes (avoids string.format on every tooltip hover)
local CLASS_COLOR_CODES = {}
for class, color in pairs(CLASS_COLORS) do
	CLASS_COLOR_CODES[class] = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end

function InTenebris:GetClassColorCode(class)
	return CLASS_COLOR_CODES[class] or "|cff999999"
end

local function ExtractItemID(link)
	if not link then
		return nil
	end
	local _, _, id = string.find(link, "item:(%d+)")
	return tonumber(id)
end

-- Secondary tooltip for displaying InTenebris data
local secondaryTooltip = CreateFrame("GameTooltip", "InTenebrisTooltip", UIParent, "GameTooltipTemplate")
secondaryTooltip:SetFrameStrata("TOOLTIP")

-- Hide secondary tooltip when parent tooltip hides
local function HookParentTooltipHide(parentTooltip)
	if not parentTooltip.InTenebrisHideHooked then
		local originalOnHide = parentTooltip:GetScript("OnHide")
		parentTooltip:SetScript("OnHide", function()
			secondaryTooltip:Hide()
			if originalOnHide then
				originalOnHide()
			end
		end)
		parentTooltip.InTenebrisHideHooked = true
	end
end

local function AddInTenebrisDataToTooltip(parentFrame, itemID)
	local wishlistPlayersLower = wishlistLookup[itemID]
	local itemAttributions = attributionLookup[itemID]
	local shiftKeyPressed = IsShiftKeyDown()
	local alwaysShow = InTenebris.db.profile.showAttributions == "always"
	local inGroup = GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0
	local showOutOfGroup = InTenebris.db.profile.showOutOfGroup == "yes"
	local showAllPlayers = alwaysShow or shiftKeyPressed or (inGroup and showOutOfGroup)

	-- If no data, don't show anything
	if
		(not wishlistPlayersLower or table.getn(wishlistPlayersLower) == 0)
		and (not itemAttributions or table.getn(itemAttributions) == 0)
	then
		return
	end

	-- Set up secondary tooltip anchored to the parent
	secondaryTooltip:SetOwner(parentFrame, "ANCHOR_NONE")
	secondaryTooltip:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 0, 0)
	secondaryTooltip:AddLine("|cffffd94dIn Tenebris|r")

	-- Add attribution info
	if itemAttributions and table.getn(itemAttributions) > 0 then
		local raidAttributions = {}
		local allAttributions = {}

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

		local attributionsToShow = showAllPlayers and allAttributions or raidAttributions
		if table.getn(attributionsToShow) > 0 then
			secondaryTooltip:AddLine("|cffffd94dAttributions:|r")
			for _, data in ipairs(attributionsToShow) do
				local colorCode = InTenebris:GetClassColorCode(data.class)
				secondaryTooltip:AddLine("  " .. data.rank .. ". " .. colorCode .. data.name .. "|r")
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

		local wishlisters = showAllPlayers and allWishlisters or raidWishlisters
		if table.getn(wishlisters) > 0 then
			local wishlistLine = "|cffffd94dWishlisted by: |r"
			for i, data in ipairs(wishlisters) do
				local colorCode = InTenebris:GetClassColorCode(data.class)
				wishlistLine = wishlistLine .. colorCode .. data.name .. "|r"
				if i < table.getn(wishlisters) then
					wishlistLine = wishlistLine .. ", "
				end
			end
			secondaryTooltip:AddLine(wishlistLine)
		end
	end

	secondaryTooltip:Show()
	HookParentTooltipHide(parentFrame)
end

local gameTooltipHooks = {}

function InTenebris:HookTooltips()
	for name, f in gameTooltipHooks do
		local name, f = name, f

		InTenebris:SecureHook(GameTooltip, name, f)
	end

	InTenebris:SecureHook("SetItemRef", function(itemLink)
		local itemID = ExtractItemID(itemLink)
		if itemID then
			AddInTenebrisDataToTooltip(ItemRefTooltip, itemID)
		end
	end)

	-- Hook AtlasLootTooltip
	if IsAddOnLoaded("AtlasLoot") then
		InTenebris:SecureHook(AtlasLootTooltip, "SetHyperlink", function(self, itemLink)
			local itemID = ExtractItemID(itemLink)
			if itemID then
				AddInTenebrisDataToTooltip(AtlasLootTooltip, itemID)
			end
		end)
	end
end

function gameTooltipHooks:SetHyperlink(itemstring)
	local itemID = ExtractItemID(itemstring)
	if itemID then
		AddInTenebrisDataToTooltip(GameTooltip, itemID)
	end
end

function gameTooltipHooks:SetLootItem(slot)
	local itemID = ExtractItemID(GetLootSlotLink(slot))
	if itemID then
		AddInTenebrisDataToTooltip(GameTooltip, itemID)
	end
end

function gameTooltipHooks:SetBagItem(bag, slot)
	local itemID = ExtractItemID(GetContainerItemLink(bag, slot))
	if itemID then
		AddInTenebrisDataToTooltip(GameTooltip, itemID)
	end
end

function gameTooltipHooks:SetInventoryItem(unit, slot)
	local itemID = ExtractItemID(GetInventoryItemLink(unit, slot))
	if itemID then
		AddInTenebrisDataToTooltip(GameTooltip, itemID)
	end
end
