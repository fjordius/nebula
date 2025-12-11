--[[
    Particle System Core
    Individual particle behavior and rendering
]]

local Vector = require("lib.vector")

local Particle = {}
Particle.__index = Particle

-- Particle characters for different states
local CHARS = {
    birth    = {"✦", "✧", "⋆"},
    alive    = {"●", "◉", "○", "◌", "✸", "✹"},
    dying    = {"·", "∙", "."},
    trail    = {"╎", "│", "┊", "┆"},
}

-- Color palettes
local PALETTES = {
    cosmic = {
        {255, 100, 200},  -- Pink
        {100, 200, 255},  -- Cyan
        {200, 150, 255},  -- Purple
        {255, 200, 100},  -- Gold
        {100, 255, 200},  -- Mint
    },
    fire = {
        {255, 50, 0},
        {255, 100, 0},
        {255, 150, 0},
        {255, 200, 50},
        {255, 255, 100},
    },
    rainbow = {
        {255, 0, 0},
        {255, 127, 0},
        {255, 255, 0},
        {0, 255, 0},
        {0, 0, 255},
        {75, 0, 130},
        {148, 0, 211},
    },
    mono = {
        {200, 200, 200},
        {150, 150, 150},
        {100, 100, 100},
    },
    matrix = {
        {0, 255, 0},
        {0, 200, 0},
        {0, 150, 0},
        {0, 100, 0},
    }
}

function Particle.new(x, y, config)
    config = config or {}
    
    local self = setmetatable({}, Particle)
    
    self.pos = Vector.new(x, y)
    self.vel = config.velocity or Vector.new(0, 0)
    self.acc = Vector.new(0, 0)
    
    self.life = config.life or 100
    self.maxLife = self.life
    self.mass = config.mass or 1
    self.size = config.size or 1
    
    self.palette = PALETTES[config.palette or "cosmic"]
    self.color = self.palette[math.random(#self.palette)]
    
    self.trail = {}
    self.trailLength = config.trailLength or 4
    
    self.char = CHARS.birth[math.random(#CHARS.birth)]
    
    return self
end

function Particle:applyForce(force)
    -- F = ma, so a = F/m
    self.acc = self.acc + (force / self.mass)
end

function Particle:update(dt)
    
    if #self.trail >= self.trailLength then
        table.remove(self.trail, 1)
    end
    table.insert(self.trail, self.pos:clone())
    

    self.vel = self.vel + self.acc * dt
    self.pos = self.pos + self.vel * dt
    self.acc = Vector.new(0, 0)
    
 
    self.life = self.life - dt
    
    
    local lifeRatio = self.life / self.maxLife
    if lifeRatio > 0.8 then
        self.char = CHARS.birth[math.random(#CHARS.birth)]
    elseif lifeRatio > 0.2 then
        self.char = CHARS.alive[math.random(#CHARS.alive)]
    else
        self.char = CHARS.dying[math.random(#CHARS.dying)]
    end
    
    
    self.currentColor = {
        math.floor(self.color[1] * lifeRatio),
        math.floor(self.color[2] * lifeRatio),
        math.floor(self.color[3] * lifeRatio),
    }
end

function Particle:isDead()
    return self.life <= 0
end

function Particle:getColor()
    return self.currentColor or self.color
end

function Particle:getTrailColor(index)
    local ratio = index / #self.trail * 0.5
    local c = self.color
    return {
        math.floor(c[1] * ratio),
        math.floor(c[2] * ratio),
        math.floor(c[3] * ratio),
    }
end

Particle.PALETTES = PALETTES
Particle.CHARS = CHARS

return Particle