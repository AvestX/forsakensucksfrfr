-- Services
local RS      = game:GetService
local RepS    = RS("ReplicatedStorage")
local Players = RS("Players")
local UIS     = RS("UserInputService")
local RService= RS("RunService")
local VIM     = RS("VirtualInputManager")

-- Rayfield init
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local window = Rayfield:CreateWindow({
    Name    = "Pwned By .Vest",
    Icon    = 4483362458,
    LoadingTitle    = ".Vest Hub",
    LoadingSubtitle = "by PlayerMoyares",
    Theme           = "Default",
    ConfigurationSaving = { Enabled = true, FileName = "PwnedPWNEDHEREIMOYARES" },
    KeySystem = true,
    KeySettings = {
        Title    = ".Vest Is Cool",
        Note     = "Key is PWNED",
        FileName = "PWNEDBYMOYARES",
        SaveKey  = true,
        Key      = { "PWNED" },
    },
})
Rayfield:Notify({ Title = "Thanks!", Content = "…one of the safest ways to exploit Forsaken.", Duration = 6.5 })

-- Debounce helper (single definition)
local function debounce(sec)
    local last = 0
    return function()
        local now = tick()
        if now - last >= sec then last = now; return true end
        return false
    end
end

--──────────────────────────────────────────────────────────────────────────────
-- Solve Generator
--──────────────────────────────────────────────────────────────────────────────
local solveGenKey     = "G"
local solveGenDebounce= debounce(2.5)
local solveGenConn

local function solveGenerator()
    local mapIngame = workspace:FindFirstChild("Map") 
                   and workspace.Map:FindFirstChild("Ingame")
                   and workspace.Map.Ingame:FindFirstChild("Map")
    if not mapIngame then
        return Rayfield:Notify({ Title="Error", Content="Map not ready", Duration=1.5 })
    end

    for _, gen in ipairs(mapIngame:GetChildren()) do
        if gen.Name == "Generator" then
            local re = gen:FindFirstChild("Remotes") and gen.Remotes:FindFirstChild("RE")
            if re then
                re:FireServer()
                return Rayfield:Notify({ Title="Generator Solved", Content="Activated", Duration=1.5 })
            end
        end
    end
    Rayfield:Notify({ Title="No Generator Found", Content="Nothing to solve", Duration=1.5 })
end

local function onSolveInput(input, gp)
    if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode.Name == solveGenKey and solveGenDebounce() then
        solveGenerator()
    end
end

local function updateSolveKey(newKey)
    solveGenKey = newKey
    if solveGenConn then solveGenConn:Disconnect() end
    solveGenConn = UIS.InputBegan:Connect(onSolveInput)
end

-- GUI for Solve Generator
local blatantTab = window:CreateTab("Blatant", 4483362458)
blatantTab:CreateInput({
    Name        = "Solve Generator Keybind",
    PlaceholderText = "e.g. G",
    Flag        = "SolveGenKeybind",
    CurrentValue= solveGenKey,
    Callback    = function(txt)
        txt = txt:upper()
        if #txt==1 and txt:match("%a") then
            updateSolveKey(txt)
            Rayfield:Notify({ Title="Key Updated", Content="Now: "..txt, Duration=2 })
        else
            Rayfield:Notify({ Title="Invalid Key", Content="Use A–Z", Duration=2 })
        end
    end,
})
blatantTab:CreateButton({
    Name     = "Solve Generator (Press "..solveGenKey..")",
    Callback = solveGenerator,
})

-- initialize
updateSolveKey(solveGenKey)

--──────────────────────────────────────────────────────────────────────────────
-- Stamina Mods (table‑driven)
--──────────────────────────────────────────────────────────────────────────────
local SprintSys = require(RepS.Systems.Character.Game.Sprinting)
local function applyStamina(cfg)
    SprintSys.MaxStamina  = cfg.maxStamina
    SprintSys.StaminaGain = cfg.staminaGain
    SprintSys.StaminaLoss = cfg.staminaLoss
    SprintSys.SprintSpeed = cfg.sprintSpeed
end

local mainTab = window:CreateTab("Main", 4483362458)
mainTab:CreateSection("Survivor Stamina Mods")

local staminaConfigs = {
    { name="Survivor: Slight Boost", flag="SurvivorSlight", cfg={100,15,9.5,25} },
    { name="Survivor: Basic Boost",  flag="SurvivorBasic",  cfg={110,20,9.3,26.5} },
    { name="Survivor: Extreme Boost",flag="SurvivorExtreme",cfg={115,35,9.5,28.2} },
}
for _, v in ipairs(staminaConfigs) do
    mainTab:CreateToggle({
        Name = v.name,
        Flag = v.flag,
        CurrentValue = false,
        Callback = function(on)
            if on then
                applyStamina({
                    maxStamina   = v.cfg[1],
                    staminaGain  = v.cfg[2],
                    staminaLoss  = v.cfg[3],
                    sprintSpeed  = v.cfg[4],
                })
            else
                -- Reset to default by reloading module (or store original values)
                -- require and store defaults once if needed
            end
        end,
    })
end

-- Killer stamina section
mainTab:CreateSection("Killer Stamina Mods")
local killerConfigs = {
    { "Killer: Moderate Boost", "KillerMod",   {125,35,9.5,28.5} },
    { "Killer: Extreme Boost",  "KillerExtreme",{135,40,9,29.5} },
}
for _, v in ipairs(killerConfigs) do
    mainTab:CreateToggle({
        Name = v[1],
        Flag = v[2],
        CurrentValue = false,
        Callback = function(on)
            if on then
                applyStamina({ maxStamina=v[3][1], staminaGain=v[3][2],
                                staminaLoss=v[3][3], sprintSpeed=v[3][4] })
            end
        end,
    })
end

--──────────────────────────────────────────────────────────────────────────────
-- Auto 1x1x1x1 Popups
--──────────────────────────────────────────────────────────────────────────────
local popupConn
blatantTab:CreateToggle({
    Name         = "Auto 1x1x1x1 Popup",
    Flag         = "AutoPopup",
    CurrentValue = false,
    Callback     = function(on)
        if popupConn then popupConn:Disconnect(); popupConn=nil end
        if on then
            popupConn = RService.Heartbeat:Connect(function()
                local gui = Players.LocalPlayer.PlayerGui.TemporaryUI
                for _, popup in ipairs(gui:GetChildren()) do
                    if popup.Name=="1x1x1x1Popup" then
                        local pos = popup.AbsolutePosition + popup.AbsoluteSize/2
                        VIM:SendMouseButtonEvent(pos.X,pos.Y,1,true,popup,0)
                        VIM:SendMouseButtonEvent(pos.X,pos.Y,1,false,popup,0)
                    end
                end
            end)
        end
    end,
})

--──────────────────────────────────────────────────────────────────────────────
-- Chance Auto‑Aim
--──────────────────────────────────────────────────────────────────────────────
local chanceEnabled = false
UIS.InputBegan:Connect(function(input, gp)
    if gp or not chanceEnabled or input.KeyCode~=Enum.KeyCode.E then return end
    local killer = workspace.Players:FindFirstChild("Killers")
                     and workspace.Players.Killers:FindFirstChildOfClass("Model")
    local char   = Players.LocalPlayer.Character
    if not killer or not char then return end

    Rayfield:Notify({ Title="Chance Ability", Content="Auto‑aim 3s", Duration=2 })
    local start = tick()
    local conn
    conn = RService.Heartbeat:Connect(function()
        if tick() - start >= 1.7 or not chanceEnabled then
            conn:Disconnect()
            return
        end
        local khrp = killer.HumanoidRootPart
        local phrp = char.HumanoidRootPart
        local target = khrp.Position + khrp.Velocity*0.1
        local cam    = workspace.CurrentCamera
        cam.CFrame  = CFrame.new(cam.CFrame.Position, target)
        phrp.CFrame = CFrame.new(phrp.Position, Vector3.new(target.X,phrp.Position.Y,target.Z))
    end)
end)

blatantTab:CreateToggle({
    Name         = "Chance Auto‑Aim",
    Flag         = "ChanceAutoAim",
    CurrentValue = false,
    Callback     = function(on)
        if on and Players.LocalPlayer.Character.Name ~= "Chance" then
            Rayfield:Notify({ Title="Wrong Character", Content="Use Chance only!", Duration=3 })
            return
        end
        chanceEnabled = on
    end,
})

--──────────────────────────────────────────────────────────────────────────────
-- ESP (Players & Generators)
--──────────────────────────────────────────────────────────────────────────────
local espTab = window:CreateTab("ESP", 4483362458)
espTab:CreateSection("Players & Generators")

-- Highlight helper
local function makeHighlight(parent, color)
    local hl = Instance.new("Highlight", parent)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    if color then hl.FillColor = color end
    return hl
end

-- Player ESP
local playerHls = {}
espTab:CreateToggle({
    Name         = "Player ESP",
    Flag         = "PlayerEsp",
    CurrentValue = false,
    Callback     = function(on)
        if on then
            Players.PlayerAdded:Connect(function(pl)
                pl.CharacterAdded:Connect(function(c) playerHls[c]=makeHighlight(c) end)
                pl.CharacterRemoving:Connect(function(c) 
                    if playerHls[c] then playerHls[c]:Destroy() end 
                end)
            end)
            for _,pl in ipairs(Players:GetPlayers()) do
                if pl.Character then playerHls[pl.Character]=makeHighlight(pl.Character) end
            end
        else
            for c,hl in pairs(playerHls) do hl:Destroy() end
            playerHls = {}
        end
    end,
})

-- Generator ESP
local genConns = {}
local function toggleGenESP(on)
    -- cleanup
    for _,c in pairs(genConns) do c:Disconnect() end
    genConns = {}
    for _, gen in ipairs(workspace.Map:GetChildren()) do
        if gen.Name=="Ingame" then
            for _,g in ipairs(gen.Map:GetChildren()) do
                makeHighlight(g)
            end
            table.insert(genConns, gen.Map.ChildAdded:Connect(function(child)
                if child.Name=="Generator" then makeHighlight(child) end
            end))
        end
    end
    if on then
        Rayfield:Notify({ Title="Generator ESP", Content="Tracking…", Duration=2 })
    end
end

espTab:CreateToggle({
    Name         = "Generator ESP",
    Flag         = "GenESP",
    CurrentValue = false,
    Callback     = toggleGenESP,
})

--──────────────────────────────────────────────────────────────────────────────
-- Finalize
--──────────────────────────────────────────────────────────────────────────────
Rayfield:LoadConfiguration()
