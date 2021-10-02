modifier_maenad = class({})

function modifier_maenad:IsHidden() return false end
function modifier_maenad:IsPurgable() return false end
function modifier_maenad:IsDebuff() return false end

function modifier_maenad:GetTexture()
    return "modifier_maenad"
end

function modifier_maenad:OnCreated( kv )
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()

		-- set controllable
		parent:SetTeam( caster:GetTeamNumber() )
		parent:SetOwner( caster )
		parent:SetControllableByPlayer( caster:GetPlayerOwnerID(), true )
	end
end

function modifier_maenad:OnDestroy( kv )
	if IsServer() then
		self:GetParent():ForceKill( false )
	end
end

function modifier_maenad:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true,
	}

	return state
end