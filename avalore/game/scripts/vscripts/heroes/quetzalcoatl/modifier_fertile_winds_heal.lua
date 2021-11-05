modifier_fertile_winds_heal = modifier_fertile_winds_heal or class({})

function modifier_fertile_winds_heal:OnCreated(kv)
    if not self:GetAbility() then self:Destroy() return end

    self.heal_interval	    = self:GetAbility():GetSpecialValueFor("heal_interval")
    self.heal_per_sec       = self:GetAbility():GetSpecialValueFor("heal_per_second")
    self.radius				= self:GetAbility():GetSpecialValueFor("heal_radius")
	self.projectile_speed	= self:GetAbility():GetSpecialValueFor("projectile_speed")

    if not IsServer() then return end

    self:OnIntervalThink()
	self:StartIntervalThink(self.heal_interval)
end

function modifier_fertile_winds_heal:OnIntervalThink()
    self:GetParent():EmitSound("Hero_Treant.LeechSeed.Tick")

    -- NOTE: this projectile is handled by the Ability's "OnProjectileHit" function
    --for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
        ProjectileManager:CreateTrackingProjectile({
            EffectName			= "particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf",
            Ability				= self:GetAbility(),
            -- Source				= self:GetCaster(),
            Source				= self:GetParent(),
            vSourceLoc			= self:GetParent():GetAbsOrigin(),
            --Source              = unit,
            --vSourceLoc          = unit:GetAbsOrigin(),
            Target				= unit, --self:GetCaster(),
            iMoveSpeed			= self.projectile_speed,
            flExpireTime		= nil,
            bDodgeable			= false,
            bIsAttack			= false,
            bReplaceExisting	= false,
            iSourceAttachment	= nil,
            bDrawsOnMinimap		= nil,
            bVisibleToEnemies	= true,
            bProvidesVision		= false,
            iVisionRadius		= nil,
            iVisionTeamNumber	= nil,
            ExtraData			= {}
        })
    end
end

-- since this modifier goes on dummy units, clean them up
function modifier_fertile_winds_heal:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveSelf()
end