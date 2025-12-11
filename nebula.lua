#!/usr/bin/env lua
--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║   ███╗   ██╗███████╗██████╗ ██╗   ██╗██╗      █████╗      ║
    ║   ████╗  ██║██╔════╝██╔══██╗██║   ██║██║     ██╔══██╗     ║
    ║   ██╔██╗ ██║█████╗  ██████╔╝██║   ██║██║     ███████║     ║
    ║   ██║╚██╗██║██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║     ║
    ║   ██║ ╚████║███████╗██████╔╝╚██████╔╝███████╗██║  ██║     ║
    ║   ╚═╝  ╚═══╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝     ║
    ║                                                           ║
    ║         A Terminal Particle Universe Simulation           ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
    
    Author: Fjord
    License: MIT
    Version: 1.0.0
]]


package.path = package.path .. ";./lib/?.lua;./effects/?.lua"


local Renderer = require("lib.renderer")
local Vector = require("lib.vector")


local Galaxy = require("effects.galaxy")
local BlackHole = require("effects.blackhole")
local Supernova = require("effects.supernova")
local Matrix = require("effects.matrix")

-- Configuration
local config = {
    width = 80,
    height = 24,
    fps = 60,
}


pcall(function()
    local userConfig = require("config")
    for k, v in pairs(userConfig) do
        config[k] = v
    end
end)


local renderer
local currentEffect
local effects = {}
local effectIndex = 1
local paused = false
local running = true


local lastTime = os.clock()
local targetDelta = 1 / config.fps


local function setupInput()
    os.execute("stty -echo raw")
end

local function restoreInput()
    os.execute("stty echo cooked")
end

local function checkInput()
 
    return nil
end

local function handleInput(key)
    if key == "q" or key == "\27" then
        running = false
    elseif key == " " then
        paused = not paused
    elseif key == "1" then
        effectIndex = 1
        currentEffect = effects[1]
    elseif key == "2" then
        effectIndex = 2
        currentEffect = effects[2]
    elseif key == "3" then
        effectIndex = 3
        currentEffect = effects[3]
    elseif key == "4" then
        effectIndex = 4
        currentEffect = effects[4]
    elseif key == "n" then
        effectIndex = (effectIndex % #effects) + 1
        currentEffect = effects[effectIndex]
    end
end

local function init()
    renderer = Renderer.new(config.width, config.height)
    
    -- Initialize effects
    local w, h = config.width - 2, config.height - 3
    effects = {
        Galaxy.new(w, h),
        BlackHole.new(w, h),
        Supernova.new(w, h),
        Matrix.new(w, h),
    }
    
    currentEffect = effects[1]
    
    renderer:init()
end

local function update(dt)
    if not paused then
        currentEffect:update(dt)
    end
end

local function draw()
    renderer:clear()
    

    renderer:drawBorder("double")
    

    local particles = currentEffect:getParticles()
    for _, p in ipairs(particles) do
        renderer:setPixel(p.pos.x + 1, p.pos.y + 1, p.char, p:getColor())
    end
    
  
    local title = " " .. currentEffect:getName() .. " "
    renderer:drawText(
        math.floor(config.width / 2 - #title / 2),
        1,
        title,
        {200, 200, 255}
    )
    
    local status = string.format(
        " FPS: %d │ Particles: %d │ [1-4] Effects │ [Space] Pause │ [Q] Quit ",
        renderer:getFps(),
        #particles
    )
    renderer:drawText(2, config.height, status, {100, 100, 120})
    
    if paused then
        local pauseText = "║ PAUSED ║"
        renderer:drawText(
            math.floor(config.width / 2 - #pauseText / 2),
            math.floor(config.height / 2),
            pauseText,
            {255, 255, 100}
        )
    end
    
    renderer:render()
end

local function shutdown()
    renderer:shutdown()
    restoreInput()
    
    print("\n")
    print("  ✨ Thanks for exploring the universe with NEBULA! ✨")
    print("")
end

-- Main loop
local function main()
    init()
    

    local inputSetup = pcall(setupInput)
    
    while running do
        local currentTime = os.clock()
        local dt = currentTime - lastTime
        
        if dt >= targetDelta then
        
            local key = checkInput()
            if key then
                handleInput(key)
            end
            
            update(dt * 60)  
            draw()
            
            lastTime = currentTime
        end
        
      
    end
    
    shutdown()
end


local success, err = xpcall(main, function(err)
    restoreInput()
    return debug.traceback(err)
end)

if not success then
    print("Error: " .. err)
    os.exit(1)
end