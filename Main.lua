local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualBallsManager = game:GetService('VirtualInputManager')

local highlightInstances = {}
local staminaLoops = {}
local Do1x1PopupsLoop = false
local isCorruptNatureEspActive = false
local isGeneratorEspActive = false

-- Utility function for debounce
local function debounce(duration)
    local lastCall = 0
    return function()
        local now = tick()
        if now - lastCall >= duration then
            lastCall = now
            return true
        end
        return false
    end
end

--Solve Gen Thingy
local UserInputService = game:GetService("UserInputService")
local solveGenKeybind = "G"  -- Default keybind
local solveGenConnection
local solveGenDebounce = debounce(2.5)

local chanceaim = false
local chanceaimbotLoop
local gameStateConnection

local function setupSolveGenKeybind()
    if solveGenConnection then
        solveGenConnection:Disconnect()
        solveGenConnection = nil
    end

    solveGenConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[solveGenKeybind] then
            if not solveGenDebounce() then return end
            
            -- Add error handling for missing map
            if not workspace:FindFirstChild("Map") or 
               not workspace.Map:FindFirstChild("Ingame") or 
               not workspace.Map.Ingame:FindFirstChild("Map") then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Map not loaded or round not started",
                    Duration = 1.5
                })
                return
            end
            
            local found = false
            for _, v in ipairs(workspace.Map.Ingame.Map:GetChildren()) do
                if v.Name == "Generator" then
                    local re = v:FindFirstChild("Remotes") and v.Remotes:FindFirstChild("RE")
                    if re then 
                        re:FireServer()
                        found = true
                    end
                end
            end
            
            if found then
                Rayfield:Notify({
                    Title = "Generator Solved",
                    Content = "Successfully activated generator",
                    Duration = 1.5
                })
            else
                Rayfield:Notify({
                    Title = "No Generator Found",
                    Content = "No available generator to solve",
                    Duration = 1.5
                })
            end
        end
    end)
end

local function setupGameStateHandling()
    if gameStateConnection then
        gameStateConnection:Disconnect()
    end
    
    gameStateConnection = task.spawn(function()
        while task.wait(4) do  -- Check every 4 seconds
            -- Reinitialize Generator ESP if active
            if isGeneratorEspActive then
                toggleHighlightGen(false)
                toggleHighlightGen(true)
            end
            
            -- Reinitialize Chance aimbot if active
            if chanceaim then
                if chanceaimbotLoop then
                    chanceaimbotLoop:Disconnect()
                end
                local toggle = Rayfield.Flags.ChanceAutoAim
                if toggle then
                    toggle:Set(true)
                end
            end
            
            -- Reinitialize solve generator keybind
            setupSolveGenKeybind()
        end
    end)
end


-- Re-usable function to apply stamina boost
local function infStaminaLogic(config)
    local Sprinting = ReplicatedStorage.Systems.Character.Game.Sprinting
    local m = require(Sprinting)

    m.MaxStamina   = config.maxStamina   or m.MaxStamina
    m.StaminaGain  = config.staminaGain  or m.StaminaGain
    m.StaminaLoss  = config.staminaLoss  or m.StaminaLoss
    m.SprintSpeed  = config.sprintSpeed  or m.SprintSpeed
end

-- Utility function for debounce
local function debounce(duration)
    local lastCall = 0
    return function()
        local now = tick()
        if now - lastCall >= duration then
            lastCall = now
            return true
        end
        return false
    end
end

-- Create GUI window
local window = Rayfield:CreateWindow({
    Name = "Pwned By .Vest",
    Icon = 0,
    LoadingTitle = ".Vest Hub",
    LoadingSubtitle = "by PlayerMoyares",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "PwnedPWNEDHEREIMOYARES",
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true,
    },
    KeySystem = true,
    KeySettings = {
        Title = ".Vest Is Cool",
        Subtitle = "Key System",
        Note = "Key is PWNED",
        FileName = "PWNEDBYMOYARES",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = { "PWNED" },
    },
})

Rayfield:Notify({
    Title = "Thanks!",
    Content = "Whether I upload this script or not, thank you for using it. I know it's not much, but it's one of the safest ways to exploit Forsaken.",
    Duration = 6.5,
    Image = 4483362458,
})

local mainTab = window:CreateTab("Main", 4483362458)
mainTab:CreateSection("Survivor Stamina Mods")

-- Stamina toggles with centralized loop control
local function setupStaminaToggle(name, flag, config)
    mainTab:CreateToggle({
        Name = name,
        Flag = flag,
        CurrentValue = false,
        Callback = function(enabled)
            staminaLoops[flag] = enabled
            if enabled then
                task.spawn(function()
                    while staminaLoops[flag] do
                        infStaminaLogic(config)
                        task.wait(10)
                    end
                end)
            end
        end,
    })
end

setupStaminaToggle("Survivor: Slight Boost", "SurvivorSlightBoost", {
    maxStamina  = 100,
    staminaGain = 15,
    staminaLoss = 9.5,
    sprintSpeed = 25,
})

setupStaminaToggle("Survivor: Basic Boost", "SurvivorBasicBoost", {
    maxStamina  = 110,
    staminaGain = 20,
    staminaLoss = 9.3,
    sprintSpeed = 26.5,
})

setupStaminaToggle("Survivor: Extreme Boost (Risky)", "SurvivorExtremeBoost", {
    maxStamina  = 115,
    staminaGain = 35,
    staminaLoss = 9.5,
    sprintSpeed = 28.2,
})

mainTab:CreateSection("Killer Stamina Mods")

setupStaminaToggle("Killer: Moderate Boost", "KillerModerateBoost", {
    maxStamina  = 125,
    staminaGain = 35,
    staminaLoss = 9.5,
    sprintSpeed = 28.5,
})

setupStaminaToggle("Killer: Extreme Boost (Risky)", "KillerExtremeBoost", {
    maxStamina  = 135,
    staminaGain = 40,
    staminaLoss = 9,
    sprintSpeed = 29.5,
})

mainTab:CreateSection("Custom Stamina Configuration")
mainTab:CreateSection("Third‑Party Scripts")

-- Blatant tab
local blatantTab = window:CreateTab("Blatant", 4483362458)

local solveGenDebounce = debounce(2.5)


-- Add these to your blatant tab section
blatantTab:CreateInput({
    Name = "Solve Generator Keybind",
    PlaceholderText = "Enter key (e.g., G, F, T)",
    RemoveTextAfterFocusLost = false,
    Flag = "SolveGenKeybind",
    CurrentValue = solveGenKeybind,
    Callback = function(Text)
        -- Convert input to uppercase and validate
        Text = Text:upper()
        if #Text == 1 and Text:match("%a") then
            solveGenKeybind = Text
            setupSolveGenKeybind()
            
            Rayfield:Notify({
                Title = "Keybind Updated",
                Content = "Solve Generator keybind set to: " .. Text,
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Invalid Keybind",
                Content = "Please enter a single letter (A-Z)",
                Duration = 3
            })
        end
    end,
})

-- Keep your existing button but modify it
blatantTab:CreateButton({
    Name = "Solve Generator (Press " .. solveGenKeybind .. ")",
    Callback = function()
        if not solveGenDebounce() then return end
        for _, v in ipairs(workspace.Map.Ingame.Map:GetChildren()) do
            if v.Name == "Generator" then
                local re = v:FindFirstChild("Remotes") and v.Remotes:FindFirstChild("RE")
                if re then re:FireServer() end
            end
        end
    end
})

-- 1x1x1x1 popup auto clicker
local function Do1x1x1x1Popups()
    spawn(function()
        while Do1x1PopupsLoop do
            local player = Players.LocalPlayer
            local popups = player.PlayerGui.TemporaryUI:GetChildren()

            for _, i in ipairs(popups) do
                if i.Name == "1x1x1x1Popup" then
                    local centerX = i.AbsolutePosition.X + (i.AbsoluteSize.X / 2)
                    local centerY = i.AbsolutePosition.Y + (i.AbsoluteSize.Y / 2)

                    VirtualBallsManager:SendMouseButtonEvent(centerX, centerY, Enum.UserInputType.MouseButton1.Value, true, player.PlayerGui, 1)
                    VirtualBallsManager:SendMouseButtonEvent(centerX, centerY, Enum.UserInputType.MouseButton1.Value, false, player.PlayerGui, 1)
                end
            end

            task.wait(0.1)
        end
    end)
end

blatantTab:CreateToggle({
    Name = "Auto 1x1x1x1 Popup",
    CurrentValue = false,
    Flag = "AutoPopup",
    Callback = function(value)
        Do1x1PopupsLoop = value
        if value then
            Do1x1x1x1Popups()
        end
    end,
})

blatantTab:CreateToggle({
    Name = "Chance Auto-Aim",
    CurrentValue = false,
    Flag = "ChanceAutoAim",
    Callback = function(state)
        chanceaim = state
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Name ~= "Chance" and state then
            Rayfield:Notify{
                Title = "Wrong Character",
                Content = "You need to be using Chance for this feature to work properly!",
                Duration = 5
            }
            return 
        end

        if state then
            -- Listen for the E ability activation
            chanceaimbotLoop = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if not chanceaim then return end
                if gameProcessed then return end
                if input.KeyCode ~= Enum.KeyCode.E then return end

                -- Find the killer
                local killer = game.Workspace.Players:FindFirstChild("Killers"):FindFirstChildOfClass("Model")
                if not killer or not killer:FindFirstChild("HumanoidRootPart") then return end
                
                local killerHRP = killer.HumanoidRootPart
                local player = game.Players.LocalPlayer.Character
                if not player or not player:FindFirstChild("HumanoidRootPart") then return end
                
                local playerHRP = player.HumanoidRootPart
                local startTime = tick()
                local duration = 3 -- Exactly 3 seconds

                -- Create a temporary loop for the 3-second duration
                task.spawn(function()
                    while tick() - startTime < duration and chanceaim do
                        -- Update target position with slight prediction
                        local targetPosition = killerHRP.Position + killerHRP.Velocity * 0.1
                        
                        -- Update camera and character orientation
                        workspace.CurrentCamera.CFrame = CFrame.new(
                            workspace.CurrentCamera.CFrame.Position, 
                            targetPosition
                        )
                        
                        playerHRP.CFrame = CFrame.new(
                            playerHRP.Position, 
                            Vector3.new(targetPosition.X, playerHRP.Position.Y, targetPosition.Z)
                        )
                        
                        task.wait()
                    end
                end)

                -- Notification for activation
                Rayfield:Notify({
                    Title = "Chance Ability",
                    Content = "Auto-aim active for 3 seconds",
                    Duration = 2
                })
            end)
        else
            if chanceaimbotLoop then
                chanceaimbotLoop:Disconnect()
                chanceaimbotLoop = nil
            end
        end
    end,
})
blatantTab:CreateSection("Nothing extra to add here; still learning to script.")
blatantTab:CreateDivider()

-- ESP tab
local espTab = window:CreateTab("ESP", 4483362458)
espTab:CreateSection("Items, Generators & Players")

local isHighlightActive = false

local function createHighlight(parent, name, color)
    local hl = Instance.new("Highlight")
    hl.Name = name
    hl.FillColor = color or Color3.new(1, 1, 1)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = parent
    return hl
end

local function toggleHighlightGen(state)
    isGeneratorEspActive = state
    local mapConnection
    local generatorConnections = {} -- Store individual generator connections

    local function cleanupHighlights()
        -- Cleanup existing highlights and connections
        for _, connection in pairs(generatorConnections) do
            connection:Disconnect()
        end
        generatorConnections = {}

        -- Remove existing highlights
        if workspace.Map.Ingame and workspace.Map.Ingame.Map then
            for _, v in pairs(workspace.Map.Ingame.Map:GetChildren()) do
                if v.Name == "Generator" then
                    local highlight = v:FindFirstChild("GeneratorHighlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end

    local function applyGeneratorHighlight(generator)
        if generator.Name ~= "Generator" then return end
        
        -- Clean up existing highlight
        local existingHighlight = generator:FindFirstChild("GeneratorHighlight")
        if existingHighlight then existingHighlight:Destroy() end

        if not isGeneratorEspActive then return end

        -- Create new highlight
        local highlight = createHighlight(generator, "GeneratorHighlight")
        local progress = generator:FindFirstChild("Progress")

        if progress then
            -- Remove highlight if generator is complete
            if progress.Value == 100 then
                highlight:Destroy()
                return
            end

            -- Store connection for cleanup
            generatorConnections[generator] = progress:GetPropertyChangedSignal("Value"):Connect(function()
                if progress.Value == 100 then
                    highlight:Destroy()
                elseif not generator:FindFirstChild("GeneratorHighlight") and isGeneratorEspActive then
                    createHighlight(generator, "GeneratorHighlight")
                end
            end)
        end
    end

    -- Clean up existing highlights first
    cleanupHighlights()

    if state then
        -- Watch for map changes
        mapConnection = workspace.Map.ChildAdded:Connect(function(child)
            if child.Name == "Ingame" then
                -- Clean up old connections and highlights
                cleanupHighlights()

                -- Setup new map monitoring
                task.wait(1) -- Wait for map to load
                if child:FindFirstChild("Map") then
                    -- Apply to existing generators
                    for _, v in pairs(child.Map:GetChildren()) do
                        applyGeneratorHighlight(v)
                    end

                    -- Monitor for new generators
                    generatorConnections["MapWatch"] = child.Map.ChildAdded:Connect(function(newChild)
                        applyGeneratorHighlight(newChild)
                    end)
                end
            end
        end)

        -- Apply to current map if it exists
        if workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map") then
            for _, v in pairs(workspace.Map.Ingame.Map:GetChildren()) do
                applyGeneratorHighlight(v)
            end

            generatorConnections["MapWatch"] = workspace.Map.Ingame.Map.ChildAdded:Connect(function(child)
                applyGeneratorHighlight(child)
            end)
        end
    else
        -- Cleanup when disabled
        if mapConnection then
            mapConnection:Disconnect()
            mapConnection = nil
        end
        cleanupHighlights()
    end

    -- Cleanup when character resets or leaves
    game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
        if mapConnection then
            mapConnection:Disconnect()
            mapConnection = nil
        end
        cleanupHighlights()
    end)
end

espTab:CreateToggle({
    Name = "Player ESP",
    Flag = "PlayerEsp",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            local function addHighlight(char)
                local hl = createHighlight(char, "PlayerHighlight", Color3.fromRGB(0, 0, 255))
                highlightInstances[char] = hl
            end

            local function removeHighlight(char)
                if highlightInstances[char] then
                    highlightInstances[char]:Destroy()
                    highlightInstances[char] = nil
                end
            end

            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(addHighlight)
                player.CharacterRemoving:Connect(removeHighlight)
            end)

            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    addHighlight(player.Character)
                end
                player.CharacterAdded:Connect(addHighlight)
                player.CharacterRemoving:Connect(removeHighlight)
            end
        else
            for _, hl in pairs(highlightInstances) do
                hl:Destroy()
            end
            highlightInstances = {}
        end
    end,
})

espTab:CreateToggle({
    Name = "Generator ESP",
    CurrentValue = false,
    Flag = "GenESP",
    Callback = function(value)
        if value then
            -- Force refresh when enabling
            toggleHighlightGen(false)
            task.wait(0.1)
        end
        toggleHighlightGen(value)
        if value then
            Rayfield:Notify({
                Title = "Generator ESP",
                Content = "Now tracking generators",
                Duration = 2
            })
        end
    end,
})
-- Add these near the top with other variables
local CorruptNatureEspConnection = nil
local targetColors = {
    HumanoidRootProjectile = Color3.fromRGB(255, 0, 0),   -- Red
    PizzaDeliveryRig = Color3.fromRGB(255, 165, 0),       -- Orange
    Bunny = Color3.fromRGB(255, 192, 203),                -- Pink
    Mafiaso1 = Color3.fromRGB(0, 0, 255),                 -- Blue
    Mafiaso2 = Color3.fromRGB(0, 255, 0),                 -- Green
    Mafiaso3 = Color3.fromRGB(148, 0, 211)                -- Purple
}

-- Replace the existing corruptnatureesp function with this improved version
local function corruptnatureesp(state)
    isCorruptNatureEspActive = state
    
    -- Disconnect existing connection if there is one
    if CorruptNatureEspConnection then
        CorruptNatureEspConnection:Disconnect()
        CorruptNatureEspConnection = nil
    end
    
    -- Function to apply highlight to an object
    local function applyHighlight(object)
        if not object:IsA("Model") then return end
        
        -- List of models to highlight
        local targetNames = {
            "HumanoidRootProjectile",
            "PizzaDeliveryRig",
            "Bunny",
            "Mafiaso1",
            "Mafiaso2",
            "Mafiaso3"
        }
        
        -- Check if the object should be highlighted
        if table.find(targetNames, object.Name) then
            -- Only create highlight if it doesn't exist
            if not object:FindFirstChild("CorruptNatureHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "CorruptNatureHighlight"
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = targetColors[object.Name] or Color3.new(1, 1, 1)
                highlight.Parent = object
                
                -- Add distance label
                local distanceLabel = Instance.new("BillboardGui")
                distanceLabel.Name = "DistanceLabel"
                distanceLabel.Size = UDim2.new(0, 200, 0, 50)
                distanceLabel.StudsOffset = Vector3.new(0, 2, 0)
                distanceLabel.AlwaysOnTop = true
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.new(1, 1, 1)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = 14
                textLabel.Parent = distanceLabel
                
                distanceLabel.Parent = object
                
                -- Update distance
                spawn(function()
                    while object and object.Parent and isCorruptNatureEspActive do
                        if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (object:GetPivot().Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            textLabel.Text = string.format("[%s]\n%.1f studs", object.Name, distance)
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    end
    
    -- Function to remove highlight from an object
    local function removeHighlight(object)
        local highlight = object:FindFirstChild("CorruptNatureHighlight")
        local distanceLabel = object:FindFirstChild("DistanceLabel")
        if highlight then
            highlight:Destroy()
        end
        if distanceLabel then
            distanceLabel:Destroy()
        end
    end
    
    if state then
        -- Initial check for existing objects
        for _, v in pairs(game.Workspace.Map.Ingame:GetChildren()) do
            applyHighlight(v)
        end
        
        -- Set up continuous monitoring
        CorruptNatureEspConnection = game.Workspace.Map.Ingame.ChildAdded:Connect(function(newObject)
            if isCorruptNatureEspActive then
                applyHighlight(newObject)
            end
        end)
    else
        -- Remove all existing highlights
        for _, v in pairs(game.Workspace.Map.Ingame:GetChildren()) do
            removeHighlight(v)
        end
    end
end

-- Add these configuration toggles above the main Coolkidd ESP toggle
espTab:CreateSection("Coolkidd ESP Settings")

-- Replace the existing Coolkidd ESP toggle with this updated version
espTab:CreateToggle({
    Name = "Coolkidd ESP",
    Flag = "CoolkiddEsp",
    CurrentValue = false,
    Callback = function(value)
        corruptnatureesp(value)
        
        if value then
            Rayfield:Notify({
                Title = "Coolkidd ESP Enabled",
                Content = "Now monitoring for summoned entities",
                Duration = 3,
            })
        end
    end,
})

-- Set up cleanup handlers
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if solveGenConnection then
        solveGenConnection:Disconnect()
    end
    if chanceaimbotLoop then
        chanceaimbotLoop:Disconnect()
    end
    if CorruptNatureEspConnection then
        CorruptNatureEspConnection:Disconnect()
    end
end)

-- Load saved configurations
Rayfield:LoadConfiguration()

-- Initialize the game state handling
setupGameStateHandling()
