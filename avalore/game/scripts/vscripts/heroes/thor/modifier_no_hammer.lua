-- Created by Elfansoer
--------------------------------------------------------------------------------
modifier_no_hammer = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_no_hammer:IsHidden() return true end
function modifier_no_hammer:IsDebuff() return false end
function modifier_no_hammer:IsPurgable() return false end

--------------------------------------------------------------------------------
-- Initializations
function modifier_no_hammer:OnCreated( kv )
	if not IsServer() then return end
    print("got no_hammer")
	self:IncrementStackCount()
end

function modifier_no_hammer:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_no_hammer:OnRemoved()
end

function modifier_no_hammer:OnDestroy()
    print("Removed no_hammer")
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Other
function modifier_no_hammer:Decrement()
	self:DecrementStackCount()
	if self:GetStackCount()<1 then
		self:Destroy()
	end
end
