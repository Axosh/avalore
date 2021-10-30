modifier_avalore_hex = class({})
modifier_avalore_hex.__index = modifier_avalore_hex

function modifier_avalore_hex:IsHidden()		return false end
function modifier_avalore_hex:IsPurgable()	    return false end
function modifier_avalore_hex:IsDebuff()	    return true end

function modifier_avalore_hex:DeclareFunctions()
	return {
                MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
                MODIFIER_PROPERTY_MODEL_CHANGE
            }
end

function modifier_avalore_hex:CheckState()
	return {
                    [MODIFIER_STATE_HEXED]      = true,
                    [MODIFIER_STATE_DISARMED]   = true,
                    [MODIFIER_STATE_SILENCED]   = true,
                    [MODIFIER_STATE_MUTED]      = true
            }
end


function modifier_avalore_hex:GetTexture()
    return self.texture
end

-- ====================================================================
-- required parms:
-- * duration => (float) length of hex
-- * texture => (str) path to texture
-- /////////////////////////////////////////
-- optional params:
-- * model => path to model (otherwise defaults to sheep)
-- * move_speed => (int) forced movepssed (defaults to 100)
-- * sound => (str) sound to use/emit
-- * particle_effect => (str) particle (defaults to lion's voodoo effect)
-- ////////////////////////////////////////
-- Easy reference for common models:
-- models/items/hex/sheep_hex/sheep_hex.vmdl (Default)
-- models/items/hex/sheep_hex/sheep_hex_gold.vmdl
-- models/props_gameplay/frog.vmdl
-- models/props_gameplay/chicken.vmdl
-- models/items/hex/fish_hex/fish_hex.vmdl
-- models/items/hex/fish_hex_retro/fish_hex_retro.vmdl
-- models/props_gameplay/pig.vmdl
-- models/props_gameplay/pig_sfm_low.vmdl
-- models/props_gameplay/pig_blue.vmdl
-- ====================================================================
function modifier_avalore_hex:OnCreated( kv )
    if not IsServer() then return end

    -- instantly destroy illusions and return (no need to process anything else)
    if self:GetParent():IsIllusion() then
        self:GetParent():Kill( self:GetAbility(), self:GetCaster() )
        return
    end

    -- /////////////////////
    -- REQUIRED PARAMS
    -- /////////////////////
    self.duration = kv.duration
    self.texture = kv.texture

    -- /////////////////////
    -- OPTIONAL PARAMS
    -- /////////////////////
    if kv.model then
        self.model = kv.model
    else
        self.model = "models/items/hex/sheep_hex/sheep_hex.vmdl"
    end

    if kv.move_speed then
        self.move_speed = kv.move_speed
    else
        self.move_speed = 100
    end

    if kv.sound then
        self.sound = kv.sound
    else
        self.sound = "Hero_Lion.Hex.Target"
    end

    if kv.particle_effect then
        self.particle_effect = kv.particle_effect
    else
        self.particle_effect = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
    end

    -- /////////////////////
    -- PLAY EFFECTS
    -- /////////////////////
    self:PlayEffects( true )
end

function modifier_avalore_hex:OnDestroy( kv )
	if not IsServer() then return end

    -- play effects
    self:PlayEffects( false )
end

function modifier_avalore_hex:GetModifierMoveSpeedOverride()
	return self.move_speed
end

function modifier_avalore_hex:GetModifierModelChange()
	return self.model
end

function modifier_avalore_hex:PlayEffects( bStart )
	local effect_cast = ParticleManager:CreateParticle( self.particle_effect, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	if bStart then
		EmitSoundOn( self.sound, self:GetParent() )
	end
end