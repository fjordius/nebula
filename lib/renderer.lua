--[[
    Terminal Renderer
    High-performance terminal graphics with true color support
]]

local Renderer = {}
Renderer.__index = Renderer

-- ANSI escape sequences
local ESC = "\27["
local CLEAR = ESC .. "2J"
local HOME = ESC .. "H"
local HIDE_CURSOR = ESC .. "?25l"
local SHOW_CURSOR = ESC .. "?25h"
local RESET = ESC .. "0m"

function Renderer.new(width, height)
    local self = setmetatable({}, Renderer)
    
    self.width = width or 80
    self.height = height or 24
    
    -- Double buffering
    self.buffer = {}
    self.colorBuffer = {}
    self.prevBuffer = {}
    
    self:clear()
    
    -- Performance tracking
    self.frameCount = 0
    self.lastFpsTime = os.clock()
    self.fps = 0
    
    return self
end

function Renderer:clear()
    for y = 1, self.height do
        self.buffer[y] = {}
        self.colorBuffer[y] = {}
        for x = 1, self.width do
            self.buffer[y][x] = " "
            self.colorBuffer[y][x] = nil
        end
    end
end

function Renderer:setPixel(x, y, char, color)
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    
    if x >= 1 and x <= self.width and y >= 1 and y <= self.height then
        self.buffer[y][x] = char
        self.colorBuffer[y][x] = color
    end
end

function Renderer:rgbToAnsi(r, g, b)
    return string.format("%s38;2;%d;%d;%dm", ESC, r, g, b)
end

function Renderer:render()
    local output = {HOME}
    
    for y = 1, self.height do
        local line = {}
        local lastColor = nil
        
        for x = 1, self.width do
            local color = self.colorBuffer[y][x]
            local char = self.buffer[y][x]
            
            if color then
                if color ~= lastColor then
                    table.insert(line, self:rgbToAnsi(color[1], color[2], color[3]))
                    lastColor = color
                end
            else
                if lastColor then
                    table.insert(line, RESET)
                    lastColor = nil
                end
            end
            
            table.insert(line, char)
        end
        
        if lastColor then
            table.insert(line, RESET)
        end
        
        table.insert(output, table.concat(line))
        if y < self.height then
            table.insert(output, "\n")
        end
    end
    
    io.write(table.concat(output))
    io.flush()
    
    -- FPS calculation
    self.frameCount = self.frameCount + 1
    local now = os.clock()
    if now - self.lastFpsTime >= 1 then
        self.fps = self.frameCount
        self.frameCount = 0
        self.lastFpsTime = now
    end
end

function Renderer:drawBorder(style)
    style = style or "double"
    
    local borders = {
        double = {"╔", "╗", "╚", "╝", "═", "║"},
        single = {"┌", "┐", "└", "┘", "─", "│"},
        heavy  = {"┏", "┓", "┗", "┛", "━", "┃"},
        round  = {"╭", "╮", "╰", "╯", "─", "│"},
    }
    
    local b = borders[style]
    local color = {100, 100, 120}
    
    -- Corners
    self:setPixel(1, 1, b[1], color)
    self:setPixel(self.width, 1, b[2], color)
    self:setPixel(1, self.height, b[3], color)
    self:setPixel(self.width, self.height, b[4], color)
    
    -- Horizontal
    for x = 2, self.width - 1 do
        self:setPixel(x, 1, b[5], color)
        self:setPixel(x, self.height, b[5], color)
    end
    
    -- Vertical
    for y = 2, self.height - 1 do
        self:setPixel(1, y, b[6], color)
        self:setPixel(self.width, y, b[6], color)
    end
end

function Renderer:drawText(x, y, text, color)
    for i = 1, #text do
        self:setPixel(x + i - 1, y, text:sub(i, i), color)
    end
end

function Renderer:drawParticles(particles)
    for _, p in ipairs(particles) do
        -- Draw trail
        for i, trailPos in ipairs(p.trail) do
            local trailColor = p:getTrailColor(i)
            local char = "·"
            self:setPixel(trailPos.x, trailPos.y, char, trailColor)
        end
        
        -- Draw particle
        self:setPixel(p.pos.x, p.pos.y, p.char, p:getColor())
    end
end

function Renderer:getFps()
    return self.fps
end

function Renderer:init()
    io.write(HIDE_CURSOR)
    io.write(CLEAR)
    io.flush()
end

function Renderer:shutdown()
    io.write(SHOW_CURSOR)
    io.write(RESET)
    io.write(CLEAR)
    io.write(HOME)
    io.flush()
end

return Renderer