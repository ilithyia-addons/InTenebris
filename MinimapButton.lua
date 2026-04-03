-- MinimapButton.lua
-- Minimap button that toggles the InTenebris main frame

local minimapButtonAngle = 220
local isMinimapButtonDragging = false

-- Create the button
local button = CreateFrame("Button", "InTenebrisMinimapButton", Minimap)
button:SetWidth(33)
button:SetHeight(33)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:RegisterForClicks("LeftButtonUp")
button:RegisterForDrag("LeftButton")
button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Icon texture (custom or fallback)
local icon = button:CreateTexture(nil, "BACKGROUND")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)

-- Try custom texture, fall back to built-in icon
local customTexturePath = "Interface\\AddOns\\InTenebris\\Textures\\MinimapIcon"
icon:SetTexture(customTexturePath)
if not icon:GetTexture() then
	icon:SetTexture("Interface\\Icons\\Spell_Shadow_EvilEye")
end

-- Border overlay (round frame)
local border = button:CreateTexture(nil, "OVERLAY")
border:SetWidth(52)
border:SetHeight(52)
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

-- Position the button around the minimap
local function UpdateMinimapButtonPosition()
	button:ClearAllPoints()
	local rad = math.rad(minimapButtonAngle)
	local x = math.cos(rad) * 80
	local y = math.sin(rad) * 80
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Tooltip
button:SetScript("OnEnter", function()
	GameTooltip:SetOwner(this, "ANCHOR_LEFT")
	GameTooltip:AddLine("|cffffd94dIn Tenebris|r")
	GameTooltip:AddLine("Left-click to open settings", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("Drag to move this button", 0.8, 0.8, 0.8)
	GameTooltip:Show()
end)

button:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

-- Click handler
button:SetScript("OnClick", function()
	InTenebris:ToggleMainFrame()
end)

-- Drag handlers
button:SetScript("OnDragStart", function()
	isMinimapButtonDragging = true
end)

button:SetScript("OnDragStop", function()
	isMinimapButtonDragging = false
	-- Save angle to character DB
	InTenebris.db.char.minimapAngle = minimapButtonAngle
end)

button:SetScript("OnUpdate", function()
	if not isMinimapButtonDragging then
		return
	end
	local cx, cy = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	cx = cx / scale
	cy = cy / scale
	local mx, my = Minimap:GetCenter()
	minimapButtonAngle = math.deg(math.atan2(cy - my, cx - mx))
	UpdateMinimapButtonPosition()
end)

-- Load saved position from AceDB (called from OnInitialize)
function InTenebris:LoadMinimapButtonPosition()
	minimapButtonAngle = self.db.char.minimapAngle
	UpdateMinimapButtonPosition()
end

-- Set initial position (default, will be overridden by OnInitialize if saved data exists)
UpdateMinimapButtonPosition()
