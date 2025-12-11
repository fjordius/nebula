--[[
    Black Hole Effect
    Gravitational singularity that consumes particles
]]

local Vector = require("lib.vector")
local Particle = require("lib.particle")

local BlackHole = {}
BlackHole.__index = BlackHole

function BlackHole.new(width, height)
    local self = setmetatable({}, BlackHole)
    
    self.width = width
    self.height = height
    self.center = Vector.new(width / 2, height / 2)
    
    self.particles = {}
    self.maxParticles = 400
    
    self.eventHorizon = 3
    self.gravity = 50
    self.spawnRate = 8
    
    self.accretionDisk = {}
    
    return self
end

function BlackHole:spawnParticle()
    if #self.particles >= self.maxParticles then
        return
    end
    
    -- Spawn from edges
    local side = math.random(4)
    local x, y
    
    if side == 1 then     -- Top
        x = math.random(self.width)
        y = 2
    elseif side == 2 then -- Bottom
        x = math.random(self.width)
        y = self.height - 1
    elseif side == 3 then -- Left
        x = 2
        y = math.random(self.height)
    else                   -- Right
        x = self.width - 1
        y = math.random(self.height)
    end
    
    local toCenter = self.center - Vector.new(x, y)
    local perpendicular = Vector.new(-toCenter.y, toCenter.x):normalize()
    
    local config = {
        palette = "cosmic",
        life = 300,
        trailLength = 6,
        velocity = perpendicular * (1 + math.random() * 2),
        mass = 0.5 + math.random(),
    }
    
    table.insert(self.particles, Particle.new(x, y, config))
end

function BlackHole:update(dt)
    -- Spawn new particles
    for i = 1, self.spawnRate do
        self:spawnParticle()
    end
    
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        
        -- Gravitational attraction
        local toCenter = self.center - p.pos
        local dist = toCenter:magnitude()
        
        if dist > 0.1 then
            -- Inverse square gravity
            local strength = self.gravity / (dist * dist)
            local force = toCenter:normalize() * strength
            p:applyForce(force)
        end
        
        -- Check event horizon
        if dist < self.eventHorizon then
            -- Consumed by black hole!
            table.remove(self.particles, i)
        else
            p:update(dt)
            
            if p:isDead() or 
               p.pos.x < 0 or p.pos.x > self.width or
               p.pos.y < 0 or p.pos.y > self.height then
                table.remove(self.particles, i)
            end
        end
    end
end

function BlackHole:getParticles()
    -- Add black hole visualization
    local all = {}
    
    -- Event horizon
    for angle = 0, math.pi * 2, 0.3 do
        local x = self.center.x + math.cos(angle) * self.eventHorizon
        local y = self.center.y + math.sin(angle) * self.eventHorizon * 0.5
        local p = Particle.new(x, y, {palette = "mono", life = 100})
        p.char = "◦"
        p.currentColor = {50, 50, 60}
        table.insert(all, p)
    end
    
    -- Singularity
    local core = Particle.new(self.center.x, self.center.y, {life = 100})
    core.char = "◉"
    core.currentColor = {20, 20, 30}
    table.insert(all, core)
    
    for _, p in ipairs(self.particles) do
        table.insert(all, p)
    end
    
    return all
end

function BlackHole:getName()
    return "🕳️  BLACK HOLE"
end

return BlackHole