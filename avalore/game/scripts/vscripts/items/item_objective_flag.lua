-----------------------------------------------------------------------------------------------------------
--	Item Definition
-----------------------------------------------------------------------------------------------------------
item_objective_flag = item_objective_flag or class({})
item_avalore_flag_morale_radi = item_avalore_flag_morale_radi or class({})

LinkLuaModifier( "modifier_item_flag_carry", "items/item_objective_flag.lua", LUA_MODIFIER_MOTION_NONE )

function item_objective_flag:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end

function item_avalore_flag_morale_radi:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end


-----------------------------------------------------------------------------------------------------------
--	Intrinsic modifier definition
-----------------------------------------------------------------------------------------------------------

if modifier_item_flag_carry == nil then modifier_item_flag_carry = class({}) end

function modifier_item_flag_carry:OnCreated(keys)
    if IsServer() then
        local ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "maps/journey_assets/props/teams/banner_journey_dire_small.vmdl"})

        ent_flag:FollowEntity(self:GetParent(), false)
        self.entFollow = ent_flag
        
        if self.particle == nil then
            self.particle = ParticleManager:CreateParticle("particles/customgames/capturepoints/cp_wood.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(self.particle, 0, Vector(0, 0, 0))
        end
    end
end

function modifier_item_flag_carry:OnDestroy(keys)
    if self.particle ~= nil then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
		self.particle = nil
    end
    if self.entFollow ~= nil then
        self.entFollow:RemoveSelf()
        self.entFollow = nil
    end
end