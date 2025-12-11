--[[
    Galaxy Effect
    Simulates a spinning spiral galaxy formation
]]

local Vector = require("lib.vector")
local Particle = require("lib.particle")
local Emitter = require("lib.emitter")

local Galaxy = {}
Galaxy.__index = Galaxy

function Galaxy.new(width, height)
    local self = setmetatable({}, Galaxy)
    
    self.width = width
    self.height = height
    self.center = Vector.new(width / 2, height / 2)
    
    self.particles = {}
    self.maxParticles = 350
    self.rotation = 0
    self.armCount = 3
    
    -- Initialize with some particles
    self:populate()
    
    return self
end

function Galaxy:populate()
    for i = 1, self.maxParticles do
        self:spawnParticle()
    end
end

function Galaxy:spawnParticle()
    if #self.particles >= self.maxParticles then
        return
    end
    
    -- Spiral arm placement
    local arm = math.random(0, self.armCount - 1)
    local armAngle = (arm / self.armCount) * math.pi * 2
    
    local distance = math.random() * (self.width / 3)
    local spread = (math.random() - 0.5) * 0.5
    local angle = armAngle + (distance * 0.1) + spread + self.rotation
    
    local x = self.center.x + math.cos(angle) * distance
    local y = self.center.y + math.sin(angle) * distance * 0.5  -- Flatten for perspective
    
    local config = {
        palette = "cosmic",
        life = 200 + math.random(100),
        trailLength = 3,
        velocity = Vector.new(0, 0),
        mass = 0.5 + math.random() * 0.5,
    }
    
    local p = Particle.new(x, y, config)
    p.orbitRadius = distance
    p.orbitAngle = angle
    p.orbitSpeed = 0.02 + (1 / (distance + 1)) * 0.1
    
    table.insert(self.particles, p)
end

function Galaxy:update(dt)
    self.rotation = self.rotation + 0.001 * dt
    
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        
        -- Orbital motion
        p.orbitAngle = p.orbitAngle + p.orbitSpeed * dt
        
        local targetX = self.center.x + math.cos(p.orbitAngle) * p.orbitRadius
        local targetY = self.center.y + math.sin(p.orbitAngle) * p.orbitRadius * 0.5
        
        -- Smooth movement toward orbital position
        p.pos.x = p.pos.x + (targetX - p.pos.x) * 0.1
        p.pos.y = p.pos.y + (targetY - p.pos.y) * 0.1
        
        p:update(dt * 0.5)
        
        if p:isDead() then
            table.remove(self.particles, i)
            self:spawnParticle()
        end
    end
end

function Galaxy:getParticles()
    return self.particles
end

function Galaxy:getName()
    return "🌀 GALAXY"
end

return Galaxy