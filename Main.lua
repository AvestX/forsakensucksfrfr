--DO NOT SKID.

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local highlightInstances = {}
local staminaLoops = {}
local Do1x1PopupsLoop = false
local isCorruptNatureEspActive = false
local isGeneratorEspActive = false


local chanceaim = false
local chanceaimbotLoop
local chanceaimbotsounds = {
    "Shoot",      -- replace with your actual sound names
    "GunShot",
    "Pew"
}


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

blatantTab:CreateButton({
    Name = "Solve Generator",
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
        if game.Players.LocalPlayer.Character.Name ~= "Chance" and state then
            Rayfield:Notify{
                Title = "Wrong Character",
                Content = "Oops, your current character isn't Chance, this POSSIBLY can bug out, so untoggle unless you're on Chance!",
                Duration = 5
            }
            return 
        end

        if state then
            chanceaimbotLoop = game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not chanceaim then return end
                for _, v in pairs(chanceaimbotsounds) do
                    if child.Name == v then
                        local killer = game.Workspace.Players:FindFirstChild("Killers"):FindFirstChildOfClass("Model")
                        if killer and killer:FindFirstChild("HumanoidRootPart") then
                            local killerHRP = killer.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local direction = (killerHRP.Position - playerHRP.Position).Unit
                                local num = 1
                                local maxIterations = 100

                                while num <= maxIterations do
                                    task.wait(0.01)
                                    num = num + 1
                                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, killerHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, killerHRP.Position)
                                end
                            end
                        end
                    end
                end
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

    local function applyGeneratorHighlight(generator)
        if generator.Name == "Generator" then
            local existingHighlight = generator:FindFirstChild("GeneratorHighlight")
            local progress = generator:FindFirstChild("Progress")

            if isGeneratorEspActive then
                if not existingHighlight then
                    createHighlight(generator, "GeneratorHighlight")
                end
            else
                if existingHighlight then
                    existingHighlight:Destroy()
                end
                return
            end

            if progress then
                if progress.Value == 100 then
                    local highlight = generator:FindFirstChild("GeneratorHighlight")
                    if highlight then
                        highlight:Destroy()
                    end
                    return
                end

                progress:GetPropertyChangedSignal("Value"):Connect(function()
                    if progress.Value == 100 then
                        local highlight = generator:FindFirstChild("GeneratorHighlight")
                        if highlight then
                            highlight:Destroy()
                        end
                    elseif isGeneratorEspActive and not generator:FindFirstChild("GeneratorHighlight") then
                        createHighlight(generator, "GeneratorHighlight")
                    end
                end)
            end
        end
    end

    for _, v in pairs(workspace.Map.Ingame.Map:GetChildren()) do
        applyGeneratorHighlight(v)
    end

    workspace.Map.Ingame.Map.ChildAdded:Connect(function(child)
        applyGeneratorHighlight(child)
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
        toggleHighlightGen(value)
    end,
})

-- Toggle the Coolkidd ESP
local function corruptnatureesp(state)
    isCorruptNatureEspActive = state
    for i, v in pairs(game.Workspace.Map.Ingame:GetChildren()) do
        if v:IsA("Model") then
            local existingHighlight = v:FindFirstChild("CorruptNatureHighlight")
            if isCorruptNatureEspActive then
                if not existingHighlight then
                    if v.Name == "HumanoidRootProjectile" or v.Name == "PizzaDeliveryRig" or v.Name == "Bunny" or v.Name == "Mafiaso1" or v.Name == "Mafiaso2" or v.Name == "Mafiaso3" then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "CorruptNatureHighlight"
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = v
                    end
                end
            else
                if existingHighlight then
                    existingHighlight:Destroy()
                end
            end
        end
    end
end

espTab:CreateToggle({
    Name = "Coolkidd ESP",
    Flag = "CoolkiddEsp",
    CurrentValue = false,
    Callback = function(value)
        corruptnatureesp(value)
    end,
})
