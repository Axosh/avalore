require("references")
require(REQ_CONSTANTS)


item_summoning_gem_class = class({})

function item_summoning_gem_class:OnOwnerDied(params)
    local hOwner = self:GetOwner()

    if hOwner:IsRealHero() then
		hOwner:DropItemAtPositionImmediate(self, self:GetOwner():GetOrigin())
		return
    end
    
    --check reincarnating?
    -- if not hOwner:IsReincarnating() then
	-- 	hOwner:DropItemAtPositionImmediate(self, self:GetOwner():GetOrigin())
	-- end
end