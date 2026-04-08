-- CoreEntityModule.lua
local EntityController = {}
EntityController.__index = EntityController

-- Konstanta Terenkripsi (Opsional: buat pengalihan logika)
local CONFIG = {
    DEFAULT_SPEED = 16,
    MAX_HEALTH = 100,
    VERSION = "1.0.4_BETA"
}

-- Constructor: Membuat object baru
function EntityController.new(playerName, userId)
    local self = setmetatable({}, EntityController)
    
    -- Properties (Private-ish)
    self.Data = {
        Name = playerName,
        ID = userId,
        IsActive = true,
        Stats = {
            WalkSpeed = CONFIG.DEFAULT_SPEED,
            Health = CONFIG.MAX_HEALTH
        }
    }
    
    return self
end

-- Method: Logic Pergerakan yang kompleks
function EntityController:CalculateVelocity(inputVector, multiplier)
    if not self.Data.IsActive then return Vector3.new(0,0,0) end
    
    -- Logic: Normalisasi vector agar diagonal tidak lebih cepat
    local direction = inputVector.Unit
    if inputVector.Magnitude == 0 then direction = Vector3.new(0,0,0) end
    
    -- Penerapan multiplier terenkripsi
    local finalSpeed = self.Data.Stats.WalkSpeed * (multiplier or 1)
    return direction * finalSpeed
end

-- Method: Sistem Damage dengan Validation
function EntityController:ApplyDamage(amount)
    local currentHealth = self.Data.Stats.Health
    local newHealth = math.clamp(currentHealth - amount, 0, CONFIG.MAX_HEALTH)
    
    self.Data.Stats.Health = newHealth
    
    -- Callback ke Engine
    if newHealth <= 0 then
        self:OnEntityDeath()
    end
    return newHealth
end

function EntityController:OnEntityDeath()
    self.Data.IsActive = false
    warn("ENTITY_LOG: Object " .. self.Data.ID .. " has been neutralized.")
end

return EntityController
