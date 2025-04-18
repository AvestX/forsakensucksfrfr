-- Main2.lua (Tool ESP removed, rest unchanged)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local isHighlightActive = false
local connections = {}

local Window = Rayfield:CreateWindow({
    Name = "Pwned by .Vest",
    Icon = 0,
    LoadingTitle = ".Vest Basic Pwning Tools",
    LoadingSubtitle = "by P-Moyares",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "PwnedByVest"
    },
    Discord = {
        Enabled = true,
        Invite = "6bk36TfBUT",
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = ".Vest",
        Subtitle = "Give me your time",
        Note = "You can get a key through https://lootdest.org/s?8zmmY42A or through special contacts with the owner themselves.",
        FileName = "PwnedByKeySystemVest",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"ownership"}
    }
})

Rayfield:Notify({
    Title = "Thanks for using .Vest's Utilities",
    Content = "While there are better options for forsaken: ex fartsaken,feversaken I wanted to make my own keyless script hub [keysys is a 1time only] So thank's for trying out my script",
    Duration = 6.5,
    Image = 4483362458,
})

local function cleanupConnections()
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    table.clear(connections)
end

local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateSection("Survivor Stamina Config")
MainTab:CreateDivider()
MainTab:CreateSection("Killer Stamina Config")
MainTab:CreateDivider()

local BlatantTab = Window:CreateTab("Blatant", 4483362458)
BlatantTab:CreateSection("CoolStuff")

-- Auto Solve Generator logic (no keybind, runs automatically with random interval)
local autoSolveGenEnabled = true
task.spawn(function()
    while autoSolveGenEnabled do
        -- Random interval between 2 and 3.5 seconds
        local t = math.random(200, 350) / 100
        task.wait(t)
        -- Solve all generators
        pcall(function()
            if game.Workspace:FindFirstChild("Map")
                and game.Workspace.Map:FindFirstChild("Ingame")
                and game.Workspace.Map.Ingame:FindFirstChild("Map") then
                for _, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
                    if v.Name == "Generator" then
                        local remotes = v:FindFirstChild("Remotes")
                        local re = remotes and remotes:FindFirstChild("RE")
                        if re then
                            re:FireServer()
                        end
                    end
                end
            end
        end)
    end
end)

BlatantTab:CreateLabel("Auto Solve Gen: Progresses generator automatically every 2 ~ 3.5 seconds, No need to click solve gen anymore")

local ESPTAB = Window:CreateTab("ESP", 4483362458)
ESPTAB:CreateSection("1x4's stable eye")

-- Generator ESP: highlight loop logic
local genHighlightLoopRunning = false
local genHighlightLoopThread = nil

local function removeGeneratorHighlights()
    if game.Workspace:FindFirstChild("Map")
        and game.Workspace.Map:FindFirstChild("Ingame")
        and game.Workspace.Map.Ingame:FindFirstChild("Map")
    then
        for _, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
            if v.Name == "Generator" then
                local highlight = v:FindFirstChild("GeneratorHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

local function addGeneratorHighlights()
    if game.Workspace:FindFirstChild("Map")
        and game.Workspace.Map:FindFirstChild("Ingame")
        and game.Workspace.Map.Ingame:FindFirstChild("Map")
    then
        for _, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
            if v.Name == "Generator" then
                local progress = v:FindFirstChild("Progress")
                if progress and progress.Value < 100 and not v:FindFirstChild("GeneratorHighlight") then
                    local genHighlight = Instance.new("Highlight")
                    genHighlight.Parent = v
                    genHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    genHighlight.Name = "GeneratorHighlight"
                end
            end
        end
    end
end

local function startGenHighlightLoop()
    if genHighlightLoopThread then
        genHighlightLoopRunning = false
        task.wait(0.2)
    end
    genHighlightLoopRunning = true
    genHighlightLoopThread = task.spawn(function()
        while genHighlightLoopRunning and isHighlightActive do
            addGeneratorHighlights()
            task.wait(5)
            removeGeneratorHighlights()
            task.wait(1)
        end
        removeGeneratorHighlights()
    end)
end

local function stopGenHighlightLoop()
    genHighlightLoopRunning = false
    removeGeneratorHighlights()
end

local GenESPToggle = ESPTAB:CreateToggle({
    Name = "Generator ESP",
    CurrentValue = false,
    Flag = "GenESPToggle",
    Callback = function(state)
        isHighlightActive = state
        cleanupConnections()
        if state then
            startGenHighlightLoop()
            -- Re-apply highlights on map changes
            if game.Workspace:FindFirstChild("Map") and
               game.Workspace.Map:FindFirstChild("Ingame") and
               game.Workspace.Map.Ingame:FindFirstChild("Map") then
                local mapConnection = game.Workspace.Map.Ingame.Map.ChildAdded:Connect(function(child)
                    if isHighlightActive and child.Name == "Generator" then
                        task.wait(0.5)
                        addGeneratorHighlights()
                    end
                end)
                table.insert(connections, mapConnection)
            end
            -- Listen for Map reloads
            local workspaceConnection = game.Workspace.ChildAdded:Connect(function(child)
                if isHighlightActive and child.Name == "Map" then
                    task.wait(1)
                    addGeneratorHighlights()
                end
            end)
            table.insert(connections, workspaceConnection)
        else
            stopGenHighlightLoop()
        end
    end
})

Rayfield:LoadConfiguration()
