local function getCasting()
    local cached = tick()
    
    local success, err = pcall(function()
        while true do
            local pressed = false
            local current = tick()
            local players = findfirstchild(Game, "Players")
            if not players then wait() continue end
            
            local localplayer = getlocalplayer()
            if not localplayer then wait() continue end
            
            local Character = getcharacter(localplayer)
            if Character then
                local Tools = findfirstchildofclass(Character, "Tool")
                if Tools and string.match(getname(Tools), "Rod") then
                    local RluaCharacter = game.Players.localPlayer.Character
                    if RluaCharacter and type(RluaCharacter) == "table" then
                        local RLuaTool = RluaCharacter:FindFirstChildOfClass("Tool")
                        if RLuaTool and string.match(RLuaTool.Name, "Rod") then
                            local RLuaValues = RLuaTool:FindFirstChild("values")
                            if RLuaValues and type(RLuaValues) == "table" then
                                local RluaCast = RLuaValues:FindFirstChild("casted")
                                if RluaCast and type(RluaCast) == "table" then
                                    _G.CastedValue = RluaCast.Value
                                end
                            end
                            if _G.CastedValue ~= true then
                                if not pressed then
                                    mouse1press()
                                    pressed = true
                                    cached = tick()
                                end
                                
                                local humanoidRootPart = findfirstchild(Character, "HumanoidRootPart")
                                if humanoidRootPart then
                                    local power = findfirstchild(humanoidRootPart, "power")
                                    if power then
                                        local powerbar = findfirstchild(power, "powerbar")
                                        if powerbar then
                                            local bar = findfirstchild(powerbar, "bar")
                                            if bar then
                                                local success, perfect_value = pcall(function()
                                                    return getmemoryvalue(bar, 0x308, "float")
                                                end)
                                                
                                                if success and perfect_value then
                                                    current = tick()
                                                    
                                                    if perfect_value >= 0.98 and perfect_value <= 1 then
                                                        if pressed then
                                                            mouse1release()
                                                            pressed = false
                                                            cached = current
                                                        end
                                                    elseif pressed then
                                                        local holdTime = current - cached
                                                        if holdTime >= 5 then
                                                            mouse1release()
                                                            pressed = false
                                                            cached = current
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if current - cached > 5 then
                        if pressed then
                            mouse1press()
                            wait(0.5)
                            mouse1release()
                            pressed = false
                            cached = current
                        end
                    end
                end
            end
            wait()
        end
    end)
    
    if not success then
        warn("Casting Error:", err)
        if pressed then
            mouse1release()
        end
    end
end

local function Shake()
    local backslashpressed = false
    local success, err = pcall(function()
        while true do
            local PlayerGui = game.Players.localPlayer:FindFirstChild("PlayerGui")
            if PlayerGui and type(PlayerGui) == "table" then
                local shakeui = PlayerGui:FindFirstChild("shakeui")
                if shakeui and type(shakeui) == "table" then
                    if not backslashpressed then
                        keypress(0xDC)
                        backslashpressed = true
                    end
                    
                    keypress(0x53)    
                    keyrelease(0x53)
                    
                    keypress(0x0D)    
                    keyrelease(0x0D)
                else
                    if backslashpressed then
                        keyrelease(0xDC)
                        backslashpressed = false
                    end
                end
            end
            wait(0.5)
        end
    end)
            
    if not success then
        warn("Shake Error:", err)
        wait(1)
    end
    wait(0.01)
end

local function Reeling()
    local cached = tick() 
    
    local success, err = pcall(function()
        while true do            
            local localplayer = getlocalplayer()
            if not localplayer then wait() continue end
            
            local playerGui = findfirstchild(localplayer, "PlayerGui")
            if not playerGui then wait() continue end
            
            local current = tick()
            local reel = findfirstchild(playerGui, "reel")
            if not reel then 
                cached = current
                wait() 
                continue 
            end
            
            local bar = findfirstchild(reel, "bar")
            if not bar then 
                cached = current
                wait() 
                continue 
            end
            
            if current - cached > 3 then
                local playerbar = findfirstchild(bar, "playerbar")
                local fish = findfirstchild(bar, "fish")
                
                if playerbar and fish then
                    local success, fishX = pcall(function()
                        return getmemoryvalue(fish, 0x2f0, "float")
                    end)
                    
                    if success and fishX then
                        local clampedX = math.clamp(fishX, 0.15, 0.9)
                        pcall(function()
                            setmemoryvalue(playerbar, 0x2f0, "float", clampedX)
                        end)
                    end
                end
            end
            wait()
        end
    end)
        
    if not success then
        warn("Reeling Error:", err)
    end
end


local function startScript()
    local functions = {
        {name = "Casting", func = getCasting},
        {name = "Shake", func = Shake},
        {name = "Reeling", func = Reeling}
    }
    
    for _, funcData in ipairs(functions) do
        spawn(function()
            local success, err = pcall(function()
                funcData.func()
            end)
            
            if not success then
                warn(funcData.name, "crashed with error [This shit never happening ong fr]:", err)
                wait(2)
            end
        end)
    end
end


pcall(startScript)
