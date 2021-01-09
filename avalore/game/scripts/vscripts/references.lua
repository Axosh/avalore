--[[
    This is effectively another constants file, but for require paths.
    Since I don't know the best structure for a Lua project right now, 
    I anticipate having to refactor a lot, so it'd be easier to keep all the
    reference strings in one place and only have to do one update instead of 
    trudging around files.
]]

-- =========================================
-- REQUIRED FILES
-- =========================================

REQ_CONSTANTS       = "constants"
--REQ_REFERENCES      = "references"
REQ_SCORE           = "score"
REQ_SPAWNERS        = "spawners"
REQ_UTIL            = "utility_functions"
REQ_AI_SHARED       = "ai_shared"

-- Abilites
REQ_ABILITY_AOEDAMAGE = "scripts/vscripts/shared/abilities/aoe_damage"

-- Libraries
REQ_LIB_TIMERS = "scripts/vscripts/libraries/timers"
REQ_LIB_PHYSICS = "scripts/vscripts/libraries/physics"
REQ_LIB_COSMETICS = "scripts/vscripts/libraries/cosmetics"


-- =========================================
-- MODIFIERS
-- =========================================

-- file locations for modifiers to be used in LinkLuaModifier
-- in the event code gets refactored

MODIFIER_CAPTURABLE     = "scripts/vscripts/modifiers/modifier_capturable.lua"
MODIFIER_FLAGBASE       = "scripts/vscripts/modifiers/flags/modifier_flagbase.lua"
MODIFIER_FLAG_MORALE    = "scripts/vscripts/modifiers/flags/modifier_flag_morale.lua"
MODIFIER_FLAG_ARCANE    = "scripts/vscripts/modifiers/flags/modifier_flag_arcane.lua"
MODIFIER_FLAG_REGROWTH    = "scripts/vscripts/modifiers/flags/modifier_flag_regrowth.lua"
MODIFIER_FLAG_AGILITY    = "scripts/vscripts/modifiers/flags/modifier_flag_agility.lua"
MODIFIER_UNSELECTABLE   = "scripts/vscripts/modifiers/modifier_unselectable.lua"
MODIFIER_INVULN_TOWER_BASED = "scripts/vscripts/modifiers/modifier_invuln_tower_based.lua"

REF_MODIFIER_ROUND1_WISP_REGEN = "scripts/vscripts/modifiers/modifier_wisp_regen.lua"


-- INTRINSIC MODIFIERS
-- these are kind of special cases since they are closely
-- related to a particular object 
MODIFIER_ITEM_FLAG_CARRY = "items/item_objective_flag.lua"