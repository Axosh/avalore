modifier_inventory_manager = class({})

function modifier_inventory_manager:IsHidden() return true end
function modifier_inventory_manager:IsDebuff() return false end
function modifier_inventory_manager:IsPurgable() return false end
function modifier_inventory_manager:RemoveOnDeath() return false end
function modifier_inventory_manager:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_inventory_manager:OnCreated()
	if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_inventory_manager:OnIntervalThink()
    local hero = self:GetParent()
    if hero == nil then return end

    -- loop through actual backpack (not the Avalore one)
    for slot=DOTA_ITEM_SLOT_6,DOTA_ITEM_SLOT_8 do
        local item = hero:GetItemInSlot(slot)
        if item then
            local intr_mod = item:GetIntrinsicModifierName()
            if intr_mod and not hero:FindModifierByName(intr_mod) then
                hero:AddNewModifier(item, nil, intr_mod, {})
            end
        end
    end
end