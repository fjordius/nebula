--[[
    Particle Emitter
    Spawns and manages collections of particles
]]

local Vector = require("lib.vector")
local Particle = require("lib.particle")

local Emitter = {}
Emitter.__index = Emitter

function Emitter.new(x, y, config)
    config = config or {}
    
    local self = setmetatable({}, Emitter)
    
    self.pos = Vector.new(x, y)
    self.particles = {}
    self.maxParticles = config.maxParticles or 400
    
    self.emitRate = config.emitRate or 5
    self.emitAccum = 0
    
    self.particleConfig = {
        palette = config.palette or "cosmic",
        life = config.particleLife or 100,
        trailLength = config.trailLength or 4,
    }
    
    self.spread = config.spread or math.pi * 2
    self.direction = config.direction or 0
    self.speed = config.speed or 2
    self.speedVariance = config.speedVariance or 1
    
    return self
end

function Emitter:emit(count, customConfig)
    count = count or 1
    
    for i = 1, count do
        if #self.particles >= self.maxParticles then
            break
        end
        
        local config = customConfig or self.particleConfig
        local angle = self.direction + (math.random() - 0.5) * self.spread
        local speed = self.speed + (math.random() - 0.5) * self.speedVariance
        
        config.velocity = Vector.fromAngle(angle, speed)
        
        local p = Particle.new(self.pos.x, self.pos.y, config)
        table.insert(self.particles, p)
    end
end

function Emitter:update(dt)
    -- Auto emit
    self.emitAccum = self.emitAccum + self.emitRate * dt
    while self.emitAccum >= 1 do
        self:emit(1)
        self.emitAccum = self.emitAccum - 1
    end
    
    -- Update all particles
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p:update(dt)
        
        if p:isDead() then
            table.remove(self.particles, i)
        end
    end
end

function Emitter:applyForce(force)
    for _, p in ipairs(self.particles) do
        p:applyForce(force)
    end
end

function Emitter:applyAttractor(point, strength)
    for _, p in ipairs(self.particles) do
        local dir = point - p.pos
        local dist = dir:magnitude()
        if dist > 0.1 then
            local force = dir:normalize() * (strength / (dist * dist))
            p:applyForce(force)
        end
    end
end

function Emitter:applyRepulsor(point, strength)
    self:applyAttractor(point, -strength)
end

function Emitter:getParticles()
    return self.particles
end

function Emitter:clear()
    self.particles = {}
end

function Emitter:count()
    return #self.particles
end

return Emitter