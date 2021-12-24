-- require("references")
-- require("events")
-- if IsServer() then
--     require(REQ_LIB_COSMETICS)
-- end

ability_shen_wai_shen_fa = class({})

--LinkLuaModifier( "modifier_wearable", "scripts/vscripts/modifiers/modifier_wearable", LUA_MODIFIER_MOTION_NONE )

function ability_shen_wai_shen_fa:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():EmitSound("Hero_Terrorblade.ConjureImage")

    local illusions = CreateIllusions(  
                    self:GetCaster(), --owner
                    self:GetCaster(), --hero to copy
                    {
                        outgoing_damage = self:GetSpecialValueFor("illusion_outgoing_damage"),
                        incoming_damage	= self:GetSpecialValueFor("illusion_incoming_damage"),
                        bounty_base		= 5, --self:GetCaster():GetIllusionBounty(), -- Custom function but it should just be caster level * 2
                        bounty_growth	= nil,
                        outgoing_damage_structure	= nil,
                        outgoing_damage_roshan		= nil,
                        duration		= self:GetSpecialValueFor("illusion_duration")
                    },
                    1, -- num illusions
                    108, --padding?
                    false, --scramble position
                    true) --find clear space

	if illusions then
		for _, illusion in pairs(illusions) do
			-- Vanilla modifier to give the illusions that Terrorblade illusion texture
			--illusion:AddNewModifier(self:GetCaster(), self, "modifier_terrorblade_conjureimage", {})
            CAvaloreGameMode:RemoveAll( illusion )
            CAvaloreGameMode:InitSunWukong(illusion, nil)

			illusion:StartGesture(ACT_DOTA_CAST_ABILITY_3_END)
            --illusion:AddNewModifier(nil, nil, "modifier_illusion", {}) -- built-in modifier to dota
		end
	end
end