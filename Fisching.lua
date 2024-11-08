local function getCasting()
    while true do
        local Character = game.Players.localPlayer.Character
        if Character then
            local Tool = Character:FindFirstChildOfClass("Tool")
            if Tool and Tool:FindFirstChild("values") then
                local casted = Tool.values:FindFirstChild("casted")
                if casted and string.match(Tool.Name, "Rod") and casted.Value ~= true then
                    mouse1press()
                    wait(1)
                    mouse1release()
                end
            end
        end
        wait()
    end
end

local function Shake()
    while true do
        local PlayerGui = game.Players.localPlayer:FindFirstChild("PlayerGui")
        if PlayerGui then
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            local backslashpressed = false
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
            end
        end
        wait()
    end
end

local function Reeling()
    local cached = tick() 
    
    while true do
        local playerGui = game.Players.localPlayer:FindFirstChild("PlayerGui")
        local current = tick()
        
        if playerGui then
            local reel = playerGui:FindFirstChild("reel")
            if reel and reel:FindFirstChild("bar") then
                if current - cached > 3 then
                    local playerbar = reel.bar:FindFirstChild("playerbar")
                    local fish = reel.bar:FindFirstChild("fish")
                    
                    if playerbar and fish then
                        local fishX = fish:GetMemoryValue(0x2f0, "float")
                        if fishX then
                            local clampedX = math.clamp(fishX, 0.15, 0.9)
                            playerbar:SetMemoryValue(0x2f0, "float", clampedX)
                        end
                    end
                end
            else
                cached = current
            end
        else
            cached = current
        end
        wait()
    end
end


local success, error = pcall(function() 
    spawn(getCasting)
end)
if not success then
    print("Casting Error:", error)
end

success, error = pcall(function()
    spawn(Shake)
end)
if not success then
    print("Shake Error:", error)
end

success, error = pcall(function()
    spawn(Reeling)
end)
if not success then
    print("Reeling Error:", error)
end
