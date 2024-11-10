local function getCasting()
    while true do
        wait()
        
        local success, error = pcall(function()
            local Character = game.Players.localPlayer.Character
            if not Character then return end
            
            local Tool = Character:FindFirstChildOfClass("Tool")
            if not Tool or not Tool:FindFirstChild("values") then return end
            
            local casted = Tool.values:FindFirstChild("casted")
            if not casted or not string.match(Tool.Name, "Rod") or casted.Value == true then return end
            
            mouse1press()
            
            local power = Character.HumanoidRootPart:FindFirstChild("power")
            if not power then return end
            
            local powerbar = power:FindFirstChild("powerbar")
            if not powerbar then return end
            
            local bar = powerbar:FindFirstChild("bar")
            if not bar then return end
            
            local success2, perfect_value = pcall(function()
                return bar:GetMemoryValue(0x308, "float")
            end)
            
            if success2 and perfect_value >= 0.98 and perfect_value <= 1 then
                mouse1release()
            end
        end)
        
        if not success then
            warn("Error in getCasting function:", error)
        end
    end
end

local function Shake()
    local backslashpressed = false
    
    while true do
        wait()
        
        local success, error = pcall(function()
            local PlayerGui = game.Players.localPlayer:FindFirstChild("PlayerGui")
            if not PlayerGui then return end
            
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if shakeui then
                if not backslashpressed then
                    keypress(0xDC)
                    backslashpressed = true
                end
                
                keypress(0x53)    
                keyrelease(0x53)
                
                keypress(0x0D)    
                keyrelease(0x0D)
                
                wait(0.01)
            else
                keyrelease(0xDC)
                backslashpressed = false
            end
        end)
        
        if not success then
            warn("Error in Shake function:", error)
        end
    end
end

local function Reeling()
    local success, error = pcall(function()
        local cached = tick()
        
        while true do
            wait()
            
            local playerGui = game.Players.localPlayer:FindFirstChild("PlayerGui")
            if not playerGui then
                cached = tick()
                continue
            end
            
            local reel = playerGui:FindFirstChild("reel")
            if not reel then
                cached = tick()
                continue
            end
            
            local bar = reel:FindFirstChild("bar")
            if not bar then
                cached = tick()
                continue
            end
            
            local current = tick()
            if current - cached <= 2 then
                continue
            end
            
            local playerbar = bar:FindFirstChild("playerbar")
            local fish = bar:FindFirstChild("fish")
            
            if not playerbar or not fish then
                warn("[Reeling Debug] Can't retrieve playerbar, fishbar")
                continue
            end
            
            local fishX
            local success2, getError = pcall(function()
                fishX = fish:GetMemoryValue(0x2f0, "float")
            end)
            
            if not success2 then
                warn("[Reeling Debug] Failed to get fishbar value:", getError)
                continue
            end
            
            if not fishX then
                warn("[Reeling Debug] Failed to get fishbar value")
                continue
            end
            
            local success3, setError = pcall(function()
                local clampedX = math.clamp(fishX, 0.15, 0.9)
                playerbar:SetMemoryValue(0x2f0, "float", clampedX)
            end)
            
            if not success3 then
                warn("[Reeling Debug] Failed to get playerbar value", setError)
                continue
            end
        end
    end)
    
    if not success then
        warn("[Reeling Debug] Main loop error:", error)
        wait(1)
        Reeling()
    end
end

local success, error = pcall(function() 
    spawn(getCasting)
end)
if not success then
    print("Casting Spawn Error:", error)
end

success, error = pcall(function()
    spawn(Shake)
end)
if not success then
    print("Shake Spawn Error:", error)
end

success, error = pcall(function()
    spawn(Reeling)
end)
if not success then
    print("Reeling Spawn Error:", error)
end 
