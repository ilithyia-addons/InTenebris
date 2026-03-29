# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

InTenebris is a World of Warcraft 1.12 (Vanilla) addon for the TurtleWoW private server. It displays guild loot wishlist and attribution data in item tooltips during raids. The addon shows which raid members have wishlisted an item and who has priority (attribution rank) for loot distribution.

## Development Environment

- **Lua target**: Lua 5.0 semantics (WoW 1.12 client) — no `#` length operator, use `table.getn()`; no vararg `...` syntax in some contexts; `pairs`/`ipairs` only
- **Formatter**: StyLua 2.3 (`stylua .` to format; config in `.stylua.toml`, Libs/ excluded via `.styluaignore`). Always run `stylua .` after making changes to Lua files.
- **Tool versions**: managed via `mise.toml`
- **Line endings**: LF
- **Indentation**: 4 spaces

## Architecture

Built on the Ace2 framework (AceAddon-2.0, AceEvent-2.0, AceHook-2.1). New files must be registered in `InTenebris.toc` to be loaded by the WoW client.

**Data flow**:
1. Wishlist/attribution data is maintained in a Google Sheet
2. `GenerateWishlist.appscript` (Google Apps Script) exports the sheet data as a Lua table literal
3. The exported table is written to `WishlistData.lua` as `InTenebris_WishlistData` (between `-- WISHLIST_DATA_START` and `-- WISHLIST_DATA_END` delimiters)
4. On addon load, `BuildLookupTables()` creates reverse-index maps for fast item ID lookups
5. Tooltip hooks inject wishlist/attribution info when hovering items

**Key data structures**:
- `wishlistData.wishlist` — player name -> list of item IDs they want
- `wishlistData.attributions` — item ID -> ranked list of players with priority
- `wishlistLookup` / `attributionLookup` — runtime reverse-index tables built from the above
- `raidRosterCache` — current raid/party roster, updated on roster change events

**Tooltip behavior**:
- By default, only shows data for players currently in the raid/party
- Hold Shift to show all players (including those not in the group)
- Hooks GameTooltip, ItemRefTooltip, and AtlasLootTooltip (if loaded)

## WoW 1.12 API Constraints

- No `C_` namespace APIs — use classic functions like `GetRaidRosterInfo`, `GetContainerItemLink`, `GetLootSlotLink`
- Tooltip manipulation via `frame:AddLine()` and `frame:Show()`
- Item links use the format `item:ITEMID:...`
- Color codes use `|cffRRGGBB...|r` escape sequences
