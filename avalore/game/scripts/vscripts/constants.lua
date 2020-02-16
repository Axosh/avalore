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
Constants.TIME_ROUND_2_START = 600   --10 min
Constants.TIME_ROUND_3_START = 1200  --20 min
Constants.TIME_ROUND_4_START = 1800  --30 min

-- ==================================
-- SPAWNER KEY NAMES
-- ==================================

Constants.KEY_RADIANT_TOP   = "Radiant_Top"
Constants.KEY_RADIANT_MIDA  = "Radiant_MidA"
Constants.KEY_RADIANT_MIDB  = "Radiant_MidB"
Constants.KEY_RADIANT_BOT   = "Radiant_Bot"

Constants.KEY_DIRE_TOP      = "Dire_Top"
Constants.KEY_DIRE_MIDA     = "Dire_MidA"
Constants.KEY_DIRE_MIDB     = "Dire_MidB"
Constants.KEY_DIRE_BOT      = "Dire_Bot"