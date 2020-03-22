--[[
    This is effectively another constants file, but for require paths.
    Since I don't know the best structure for a Lua project right now, 
    I anticipate having to refactor a lot, so it'd be easier to keep all the
    reference strings in one place and only have to do one update instead of 
    trudging around files.
]]

-- REQUR

-- =========================================
-- MODIFIERS
-- =========================================

-- file locations for modifiers to be used in LinkLuaModifier
-- in the event code gets refactored

MODIFIER_CAPTURABLE     = "scripts/vscripts/modifiers/modifier_capturable.lua"
MODIFIER_FLAGBASE       = "scripts/vscripts/modifiers/flags/modifier_flagbase.lua"
MODIFIER_FLAG_MORALE    = "scripts/vscripts/modifiers/flags/modifier_flag_morale.lua"
MODIFIER_UNSELECTABLE   = "scripts/vscripts/modifiers/modifier_unselectable.lua"


-- INTRINSIC MODIFIERS
-- these are kind of special cases since they are closely
-- related to a particular object 
MODIFIER_ITEM_FLAG_CARRY = "items/item_objective_flag.lua"