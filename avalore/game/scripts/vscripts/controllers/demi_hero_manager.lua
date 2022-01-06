require("constants")
require("references")
require(REQ_UTIL)

if DemiHeroManager == nil then
    DemiHeroManager = {}
end

function DemiHeroManager:AddTeam(team)
    DemiHeroManager[team] = {}
end

-- if unit exists, check to see what level it spawned as last, add 1 to it, and return the level
-- otherwise, insert it and set level to 1
function DemiHeroManager:HireDemiHero(team, unit)
    local demi_hero_level = DemiHeroManager[team][unit:GetName()]
    if demi_hero_level then
        demi_hero_level = demi_hero_level + 1
        DemiHeroManager[team][unit:GetName()] = demi_hero_level
    else
        DemiHeroManager[team][unit:GetName()] = 1
    end

    return DemiHeroManager[team][unit:GetName()]
end

function DemiHeroManager:GetDemiHeroLevel(team, unit)
    local demi_hero_level = DemiHeroManager[team][unit:GetName()]
    if demi_hero_level then
        return demi_hero_level
    else
        return 0
    end
end