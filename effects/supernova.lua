--[[
    Supernova Effect
    Explosive stellar death with expanding shockwave
]]

local Vector = require("lib.vector")
local Particle = require("lib.particle")

local Supernova = {}
Supernova.__index = Supernova

function Supernova.new(width, height)
    local self = setmetatable({}, Supernova)
    
    self.width = width
    self.height = height
    self.center = Vector.new(width / 2, height / 2)
    
    self.particles = {}
    self.maxParticles = 500
    
    self.phase = "collapse"  -- collapse, explosion, aftermath
    self.timer = 0
    self.explosionForce = 0
    
    self:startCollapse()
    
    return self
end

function Supernova:startCollapse()
    self.phase = "collapse"
    self.timer = 0
    self.particles = {}
    
    -- Create initial star particles
    for i = 1, 200 do
        local angle = math.random() * math.pi * 2
        local dist = math.random() * (self.width / 4)
        
        local x = self.center.x + math.cos(angle) * dist
        local y = self.center.y + math.sin(angle) * dist * 0.6
        
        local config = {
            palette = "fire",
            life = 500,
            trailLength = 2,
            velocity = Vector.new(0, 0),
        }
        
        local p = Particle.new(x, y, config)
        p.originalDist = dist
        table.insert(self.particles, p)
    end
end

function Supernova:explode()
    self.phase = "explosion"
    self.timer = 0
    
    -- Burst particles outward
    for _, p in ipairs(self.particles) do
        local fromCenter = p.pos - self.center
        local dist = fromCenter:magnitude()
        if dist < 1 then dist = 1 end
        
        local dir = fromCenter:normalize()
        local force = 15 + math.random() * 10
        p.vel = dir * force
        
        p.life = 150 + math.random(100)
        p.maxLife = p.life
    end
    
    -- Add extra explosion particles
    for i = 1, 200 do
        local angle = math.random() * math.pi * 2
        local speed = 5 + math.random() * 15
        
        local config = {
            palette = math.random() > 0.5 and "fire" or "cosmic",
            life = 100 + math.random(150),
            trailLength = 5,
            velocity = Vector.fromAngle(angle, speed),
        }
        
        local p = Particle.new(self.center.x, self.center.y, config)
        table.insert(self.particles, p)
    end
end

function Supernova:update(dt)
    self.timer = self.timer + dt
    
    if self.phase == "collapse" then
        -- Pull particles toward center
        for _, p in ipairs(self.particles) do
            local toCenter = self.center - p.pos
            local dist = toCenter:magnitude()
            
            if dist > 2 then
                local force = toCenter:normalize() * (0.5 + self.timer * 0.1)
                p:applyForce(force)
            end
            
            p:update(dt)
        end
        
        -- Trigger explosion
        if self.timer > 80 then
            self:explode()
        end
        
    elseif self.phase == "explosion" then
        for i = #self.particles, 1, -1 do
            local p = self.particles[i]
            
            -- Add some drag
            p.vel = p.vel * 0.99
            
            p:update(dt)
            
            if p:isDead() or
               p.pos.x < 0 or p.pos.x > self.width or
               p.pos.y < 0 or p.pos.y > self.height then
                table.remove(self.particles, i)
            end
        end
        
        -- Reset after explosion finishes
        if #self.particles < 20 or self.timer > 200 then
            self:startCollapse()
        end
    end
end

function Supernova:getParticles()
    local all = {}
    
    -- Core glow during collapse
    if self.phase == "collapse" then
        local intensity = math.min(255, 100 + self.timer * 2)
        local core = Particle.new(self.center.x, self.center.y, {life = 100})
        core.char = self.timer > 60 and "✸" or "●"
        core.currentColor = {intensity, intensity * 0.7, intensity * 0.3}
        table.insert(all, core)
    end
    
    for _, p in ipairs(self.particles) do
        table.insert(all, p)
    end
    
    return all
end

function Supernova:getName()
    return "💥 SUPERNOVA"
end

return Supernova