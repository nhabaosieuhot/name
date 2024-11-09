local success, err = pcall(function()
    --Blackout
    local Players = game:GetService("Players")
    local LocalPlayer = Players.localPlayer
    local Camera = game:GetService("Workspace").CurrentCamera
    local NPCs = game:GetService("Workspace"):FindFirstChild("NPCs")

    local Table = {
        ["Model"] = {}
    }

    local NPCTable = {
        ["Model"] = {}
    }

    local cachedChildren = {}
    local cachedNPC = {}
    
    local function cachedthread()
        while true do
            local success, err = pcall(function()
                local currentTime = tick()

                -- Cache Players
                if not cachedChildren.lastUpdate or currentTime - cachedChildren.lastUpdate > 1 then
                    cachedChildren.items = {}
                    for _, Player in ipairs(Players:GetChildren()) do
                        if Player ~= LocalPlayer then
                            table.insert(cachedChildren.items, Player)
                        end
                    end
                    cachedChildren.lastUpdate = currentTime
                end

                -- Cache NPCs
                if not cachedNPC.lastUpdate or currentTime - cachedNPC.lastUpdate > 1 then
                    cachedNPC.items = {}
                    if NPCs and NPCs:FindFirstChild("Hostile") then
                        for _, NPC in ipairs(NPCs.Hostile:GetChildren()) do
                            if NPC.ClassName == "Model" and NPC:FindFirstChild("Humanoid") then
                                table.insert(cachedNPC.items, NPC)
                            end
                        end
                    end
                    cachedNPC.lastUpdate = currentTime
                end

                -- Process Players
                for _, Player in ipairs(cachedChildren.items) do
                    local success2, err2 = pcall(function()
                        local Character = Player.Character
                        if Character then
                            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                            if HumanoidRootPart then
                                if not Table["Model"][Player] then
                                    Table["Model"][Player] = {
                                        ["PrimaryPart"] = HumanoidRootPart,
                                        ["Gears"] = {},
                                        ["GearsDrawing"] = Drawing.new("Text"),
                                        ["Drawing"] = Drawing.new("Text"),
                                        ["WeaponDrawing"] = Drawing.new("Text")
                                    }
                                end

                                local CurrentGear = Character:FindFirstChild("CurrentGear")
                                if CurrentGear then
                                    Table["Model"][Player]["Gears"] = {}
                                    local Gears = CurrentGear:GetChildren()
                                    if #Gears > 0 then
                                        local GearNames = {}
                                        for i, Gear in ipairs(Gears) do
                                            table.insert(GearNames, Gear.Name)
                                            if i % 2 == 0 and i < #Gears then
                                                table.insert(GearNames, "]\n[")
                                            elseif i < #Gears then
                                                table.insert(GearNames, " + ")
                                            end
                                        end
                                        Table["Model"][Player]["GearsDrawing"].Text = "[" .. table.concat(GearNames) .. "]"
                                    else
                                        Table["Model"][Player]["GearsDrawing"].Text = "[]"
                                    end
                                else
                                    Table["Model"][Player]["GearsDrawing"].Text = "[]"
                                end

                                local CurrentWeapon = Character:FindFirstChildOfClass("RayValue")
                                if CurrentWeapon then
                                    Table["Model"][Player]["WeaponDrawing"].Text = CurrentWeapon.Name or "[]"
                                else
                                    Table["Model"][Player]["WeaponDrawing"].Text = "[]"
                                end
                            end
                        end
                    end)
                    if not success2 then warn("Player processing error: " .. tostring(err2)) end
                end

                -- Process NPCs
                for _, NPC in ipairs(cachedNPC.items) do
                    local success2, err2 = pcall(function()
                        if NPC and NPC.Parent then
                            local Humanoid = NPC:FindFirstChild("Humanoid")
                            local HumanoidRootPart = NPC:FindFirstChild("HumanoidRootPart")
                            if Humanoid and HumanoidRootPart and not NPCTable["Model"][NPC] then
                                NPCTable["Model"][NPC] = {
                                    ["PrimaryPart"] = HumanoidRootPart,
                                    ["Humanoid"] = Humanoid,
                                    ["Drawing"] = Drawing.new("Text"),
                                    ["HealthBar"] = Drawing.new("Square"),
                                    ["HealthBarOutline"] = Drawing.new("Square")
                                }
                                
                                local HealthBar = NPCTable["Model"][NPC]["HealthBar"]
                                local HealthBarOutline = NPCTable["Model"][NPC]["HealthBarOutline"]
                                HealthBar.Filled = true
                                HealthBar.Thickness = 1
                                HealthBarOutline.Filled = false
                                HealthBarOutline.Thickness = 1
                                HealthBarOutline.Color = {0, 0, 0}
                            end
                        end
                    end)
                    if not success2 then warn("NPC processing error: " .. tostring(err2)) end
                end
            end)
            if not success then warn("Cache thread error: " .. tostring(err)) end
            wait(0.1)
        end
    end

    local function RenderThread()
        while true do
            local success, err = pcall(function()
                -- Render Players
                for PlayerInstance, PlayerData in pairs(Table["Model"]) do
                    local success2, err2 = pcall(function()
                        local Drawing = PlayerData["Drawing"]
                        local PrimaryPart = PlayerData["PrimaryPart"]
                        local GearsDrawing = PlayerData["GearsDrawing"]
                        local WeaponDrawing = PlayerData["WeaponDrawing"]
                        if PrimaryPart and PrimaryPart.Parent then
                            local Pos3D = PrimaryPart.CFrame.Position
                            local Pos2D, OnScreen = worldtoscreenpoint({Pos3D.x, Pos3D.y, Pos3D.z})
                            local CameraPos = Camera.CFrame.Position
                            local MousePos = getmouseposition()
                            local Distance = math.floor(math.sqrt((CameraPos.x - Pos3D.x)^2 + (CameraPos.y - Pos3D.y)^2 + (CameraPos.z - Pos3D.z)^2))
                            local Mousefov = math.floor(math.sqrt((MousePos.x - Pos2D.x)^2 + (MousePos.y - Pos2D.y)^2))
                            
                            if Distance then
                                Drawing.Text = string.format("[%s][%d]", PrimaryPart.Parent.Name, Distance)
                                Drawing.Position = {Pos2D.x, Pos2D.y}
                                Drawing.Visible = OnScreen
                                Drawing.Color = {255, 255, 255}
                                Drawing.Size = 12
                                Drawing.Center = true
                                Drawing.Outline = true
                                Drawing.Font = 2
                                Drawing.OutlineColor = {0, 0, 0}

                                GearsDrawing.Position = {Pos2D.x, Pos2D.y + 20}
                                GearsDrawing.Color = {255, 255, 255}
                                GearsDrawing.Size = 12
                                GearsDrawing.Center = true
                                GearsDrawing.Outline = true
                                GearsDrawing.Font = 2
                                GearsDrawing.OutlineColor = {0, 0, 0}
                                GearsDrawing.Visible = Mousefov < 50 and OnScreen

                                WeaponDrawing.Position = {Pos2D.x, Pos2D.y - 20}
                                WeaponDrawing.Color = {0, 255, 0}
                                WeaponDrawing.Size = 12
                                WeaponDrawing.Center = true
                                WeaponDrawing.Outline = true
                                WeaponDrawing.Font = 2
                                WeaponDrawing.OutlineColor = {0, 0, 0}
                                WeaponDrawing.Visible = Mousefov < 50 and OnScreen
                            end
                        else
                            Drawing:Remove()
                            GearsDrawing:Remove()
                            Table["Model"][PlayerInstance] = nil
                        end
                    end)
                    if not success2 then warn("Player rendering error: " .. tostring(err2)) end
                end

                -- Render NPCs
                for NPCInstance, NPCData in pairs(NPCTable["Model"]) do
                    local success2, err2 = pcall(function()
                        if NPCInstance and NPCInstance.Parent then
                            local Drawing = NPCData["Drawing"]
                            local PrimaryPart = NPCData["PrimaryPart"]
                            local Humanoid = NPCData["Humanoid"]
                            local HealthBar = NPCData["HealthBar"]
                            local HealthBarOutline = NPCData["HealthBarOutline"]
                            
                            if PrimaryPart and Humanoid then
                                local Pos3D = PrimaryPart.CFrame.Position
                                local Pos2D, OnScreen = worldtoscreenpoint({Pos3D.x, Pos3D.y, Pos3D.z})
                                local CameraPos = Camera.CFrame.Position
                                local Distance = math.floor(math.sqrt((CameraPos.x - Pos3D.x)^2 + (CameraPos.y - Pos3D.y)^2 + (CameraPos.z - Pos3D.z)^2))
                                
                                if Distance < 130 and OnScreen then
                                    local HealthPercent = Humanoid.Health / Humanoid.MaxHealth
                                    
                                    Drawing.Text = string.format("[%s][%d]", NPCInstance.Name, Distance)
                                    Drawing.Position = {Pos2D.x, Pos2D.y - 20}
                                    Drawing.Visible = true
                                    Drawing.Color = {255, 0, 0}
                                    Drawing.Size = 12
                                    Drawing.Center = true
                                    Drawing.Outline = true
                                    Drawing.OutlineColor = {0, 0, 0}

                                    local TextLength = #Drawing.Text
                                    
                                    local BarWidth = 50
                                    local BarHeight = 5
                                    
                                    HealthBarOutline.Size = {BarWidth, BarHeight}
                                    HealthBarOutline.Position = {Pos2D.x - BarWidth/2 - TextLength * 0.5, Pos2D.y - 10}
                                    HealthBarOutline.Visible = true
                                    
                                    HealthBar.Size = {BarWidth * HealthPercent, BarHeight}
                                    HealthBar.Position = {Pos2D.x - BarWidth/2 - TextLength * 0.5, Pos2D.y - 10}
                                    HealthBar.Visible = true
                                    
                                    if HealthPercent > 0.5 then
                                        HealthBar.Color = {0, 255, 0}
                                    elseif HealthPercent > 0.2 then
                                        HealthBar.Color = {255, 255, 0}
                                    else
                                        HealthBar.Color = {255, 0, 0}
                                    end
                                else
                                    Drawing.Visible = false
                                    HealthBar.Visible = false
                                    HealthBarOutline.Visible = false
                                end
                            end
                        else
                            pcall(function()
                                if NPCData["Drawing"] and type(NPCData["Drawing"].Remove) == "function" then
                                    NPCData["Drawing"]:Remove()
                                end
                                if NPCData["HealthBar"] and type(NPCData["HealthBar"].Remove) == "function" then
                                    NPCData["HealthBar"]:Remove()
                                end
                                if NPCData["HealthBarOutline"] and type(NPCData["HealthBarOutline"].Remove) == "function" then
                                    NPCData["HealthBarOutline"]:Remove()
                                end
                            end)
                            NPCTable["Model"][NPCInstance] = nil
                        end
                    end)
                    if not success2 then 
                        warn("NPC rendering error: " .. tostring(err2))
                        pcall(function()
                            if NPCData["Drawing"] and type(NPCData["Drawing"].Remove) == "function" then
                                NPCData["Drawing"]:Remove()
                            end
                            if NPCData["HealthBar"] and type(NPCData["HealthBar"].Remove) == "function" then
                                NPCData["HealthBar"]:Remove()
                            end
                            if NPCData["HealthBarOutline"] and type(NPCData["HealthBarOutline"].Remove) == "function" then
                                NPCData["HealthBarOutline"]:Remove()
                            end
                        end)
                        NPCTable["Model"][NPCInstance] = nil
                    end
                end
            end)
            if not success then warn("Render thread error: " .. tostring(err)) end
            wait()
        end
    end

    spawn(cachedthread)
    spawn(RenderThread)
end)

if not success then
    warn("Script initialization error: " .. tostring(err))
end
