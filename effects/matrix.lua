--[[
    Matrix Digital Rain Effect
    Classic falling code visualization
]]

local Vector = require("lib.vector")
local Particle = require("lib.particle")

local Matrix = {}
Matrix.__index = Matrix

-- Matrix characters
local MATRIX_CHARS = {
    "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
    "@", "#", "$", "%", "&", "*", "+", "=", "<", ">",
}

function Matrix.new(width, height)
    local self = setmetatable({}, Matrix)
    
    self.width = width
    self.height = height
    
    self.streams = {}
    self.maxStreams = math.floor(width / 2)
    
    -- Initialize streams
    for i = 1, self.maxStreams do
        self:createStream()
    end
    
    return self
end

function Matrix:createStream()
    local stream = {
        x = math.random(2, self.width - 1),
        y = math.random(-20, 0),
        speed = 0.3 + math.random() * 0.5,
        length = 5 + math.random(15),
        chars = {},
    }
    
    -- Generate characters for this stream
    for i = 1, stream.length do
        stream.chars[i] = {
            char = MATRIX_CHARS[math.random(#MATRIX_CHARS)],
            changeTimer = math.random(10, 50),
        }
    end
    
    table.insert(self.streams, stream)
end

function Matrix:update(dt)
    for i = #self.streams, 1, -1 do
        local stream = self.streams[i]
        
        stream.y = stream.y + stream.speed * dt
        
        -- Randomly change characters
        for j, charData in ipairs(stream.chars) do
            charData.changeTimer = charData.changeTimer - dt
            if charData.changeTimer <= 0 then
                charData.char = MATRIX_CHARS[math.random(#MATRIX_CHARS)]
                charData.changeTimer = math.random(10, 50)
            end
        end
        
        -- Reset stream if off screen
        if stream.y - stream.length > self.height then
            table.remove(self.streams, i)
            self:createStream()
        end
    end
    
    -- Maintain stream count
    while #self.streams < self.maxStreams do
        self:createStream()
    end
end

function Matrix:getParticles()
    local particles = {}
    
    for _, stream in ipairs(self.streams) do
        for i, charData in ipairs(stream.chars) do
            local y = stream.y - i + 1
            
            if y >= 1 and y <= self.height then
                local p = Particle.new(stream.x, y, {life = 100})
                p.char = charData.char
                
                -- Color gradient: bright head, fading tail
                local brightness
                if i == 1 then
                    brightness = 255
                    p.currentColor = {200, 255, 200}  -- White-green head
                else
                    brightness = math.max(0, 255 - (i * 15))
                    p.currentColor = {0, brightness, 0}
                end
                
                table.insert(particles, p)
            end
        end
    end
    
    return particles
end

function Matrix:getName()
    return "💚 MATRIX"
end

return Matrix