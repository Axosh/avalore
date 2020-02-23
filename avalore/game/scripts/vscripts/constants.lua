if Constants == nil then
    Constants = {}
end

--[[ 
    Definitions for a bunch of keys used throughout so the values
    can be controlled from one central location and updated (or 
    modified for debugging) with ease.
--]]


-- ==================================
-- ROUND START TIMES (IN SECONDS)
-- ==================================

Constants.TIME_ROUND_1_START = 0     --00 min
Constants.TIME_ROUND_2_START = 60--600   --10 min
Constants.TIME_ROUND_3_START = 1200  --20 min
Constants.TIME_ROUND_4_START = 1800  --30 min

-- ==================================
-- SPAWNER KEY NAMES
-- ==================================

Constants.KEY_RADIANT_TOP       = "Radiant_Top"
Constants.KEY_RADIANT_MIDA      = "Radiant_MidA"
Constants.KEY_RADIANT_MIDB      = "Radiant_MidB"
Constants.KEY_RADIANT_BOT       = "Radiant_Bot"
Constants.KEY_RADIANT_SHELFTOP  = "Radiant_ShelfTop"
Constants.KEY_RADIANT_SHELFBOT  = "Radiant_ShelfBot"

Constants.KEY_DIRE_TOP          = "Dire_Top"
Constants.KEY_DIRE_MIDA         = "Dire_MidA"
Constants.KEY_DIRE_MIDB         = "Dire_MidB"
Constants.KEY_DIRE_BOT          = "Dire_Bot"
Constants.KEY_DIRE_SHELFTOP     = "Dire_ShelfTop"
Constants.KEY_DIRE_SHELFBOT     = "Dire_ShelfBot"

--[[
    RADIANT BASE ENTITIES
    rax_ranged_radiant_mid
    rax_melee_radiant_mid

    rax_ranged_radiant_top
    rax_melee_radiant_top

    rax_ranged_radiant_bot
    rax_melee_radiant_bot

    ancient_radiant
    fountain_radiant

    RADIANT TOWER ENTITIES

    tower_radiant_top_1
    tower_radiant_top_2
    tower_radiant_top_3
    tower_radiant_top_4

    tower_radiant_bot_1
    tower_radiant_bot_2
    tower_radiant_bot_3
    tower_radiant_bot_4

    tower_radiant_mid_1
    tower_radiant_mid_2
    tower_radiant_mid_3
--]]

--[[
    DIRE BASE ENTITIES

    rax_ranged_dire_mid
    rax_melee_dire_mid

    rax_ranged_dire_bot
    rax_melee_dire_bot

    rax_ranged_dire_top
    rax_melee_dire_top

    ancient_dire
    fountain_dire

    DIRE TOWER ENTITIES

    tower_dire_top_2
    tower_dire_top_1
    tower_dire_top_3
    tower_dire_top_4

    tower_dire_bot_1
    tower_dire_bot_2
    tower_dire_bot_3
    tower_dire_bot_4

    tower_dire_mid_1
    tower_dire_mid_2
    tower_dire_mid_3
--]]

--[[
    OBJECTIVE ENTITIES
    radiant_outpost // radiant_outpost_trigger
]]