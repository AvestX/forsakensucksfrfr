local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local isHighlightActive = false
local toolhighlightactive = false
local connections = {} -- Store connections for cleanup

local Window = Rayfield:CreateWindow({
   Name = "Pwned by .Vest",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = ".Vest Basic Pwning Tools",
   LoadingSubtitle = "by P-Moyares",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "PwnedByVest"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "6bk36TfBUT", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = ".Vest",
      Subtitle = "Give me your time",
      Note = "You can get a key through https://lootdest.org/s?8zmmY42A or through special contacts with the owner themselves.", -- Use this to tell the user how to get a key
      FileName = "PwnedByKeySystemVest", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"ownership"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

Rayfield:Notify({
   Title = "Thanks for using .Vest's Utilities",
   Content = "While there are better options for forsaken: ex fartsaken,feversaken I wanted to make my own keyless script hub [keysys is a 1time only] So thank's for trying out my script",
   Duration = 6.5,
   Image = 4483362458,
})


-- Function to clean up existing connections
local function cleanupConnections()
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    table.clear(connections)
end


local MainTab = Window:CreateTab("Main", 4483362458) -- Title, Image
local Section = MainTab:CreateSection("Survivor Stamina Config")
local Divider1 = MainTab:CreateDivider()
local Section = MainTab:CreateSection("Killer Stamina Config")
local Divider2 = MainTab:CreateDivider()

local BlatantTab = Window:CreateTab("Blatant", 4483362458) -- Title, Image
local Section = BlatantTab:CreateSection("CoolStuff")

local lastGenSolveTime = 0
local COOLDOWN_TIME = 2.5 -- 2.5 seconds cooldown
-- Function to check if enough time has passed
local function canSolveGenerator()
    local currentTime = os.time()
    if currentTime - lastGenSolveTime >= COOLDOWN_TIME then
        lastGenSolveTime = currentTime
        return true
    end
    return false
end

-- Modified Solve Generator Button + Keybind
local SolveGenKeybind = BlatantTab:CreateKeybind({
    Name = "Solve Generator",
    CurrentKeybind = "H",
    HoldToInteract = false,
    Flag = "SolveGenKeybind",
    Callback = function()
        if not canSolveGenerator() then
            Rayfield:Notify({
                Title = "Cooldown Active",
                Content = "Please wait " .. COOLDOWN_TIME .. " seconds between solves",
                Duration = 2.5,
            })
            return
        end

        local function solvegen()
            for i, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
                if v.Name == "Generator" then
                    v:WaitForChild("Remotes"):WaitForChild("RE"):FireServer()
                end
            end
        end
        solvegen()
    end,
})


BlatantTab:CreateLabel("Solve Gen: Press once to progress generator")
BlatantTab:CreateLabel("Default Keybind: H")



local ESPTAB = Window:CreateTab("ESP", 4483362458) -- Title, Image
local Section = ESPTAB:CreateSection("1x4's stable eye")
local GenESPToggle = ESPTAB:CreateToggle({
    Name = "Generator ESP",
    CurrentValue = false,
    Flag = "GenESPToggle",
    Callback = function(state)
        local function toggleHighlightGen(state)
            isHighlightActive = state 
            cleanupConnections() -- Cleanup existing connections
        
            local function applyGeneratorHighlight(generator)
                if generator.Name == "Generator" then
                    local existingHighlight = generator:FindFirstChild("GeneratorHighlight")
                    local progress = generator:FindFirstChild("Progress")
                    
                    if isHighlightActive then
                        if not existingHighlight then
                            local genhighlight = Instance.new("Highlight")
                            genhighlight.Parent = generator
                            genhighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            genhighlight.Name = "GeneratorHighlight"
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
        
                        local progressConnection = progress:GetPropertyChangedSignal("Value"):Connect(function()
                            if progress.Value == 100 then
                                local highlight = generator:FindFirstChild("GeneratorHighlight")
                                if highlight then
                                    highlight:Destroy()
                                end
                            elseif isHighlightActive and not generator:FindFirstChild("GeneratorHighlight") then
                                local genhighlight = Instance.new("Highlight")
                                genhighlight.Parent = generator
                                genhighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                genhighlight.Name = "GeneratorHighlight"
                            end
                        end)
                        table.insert(connections, progressConnection)
                    end
                end
            end

            -- Function to initialize ESP for new map
            local function initializeMapESP()
                if game.Workspace:FindFirstChild("Map") and 
                   game.Workspace.Map:FindFirstChild("Ingame") and 
                   game.Workspace.Map.Ingame:FindFirstChild("Map") then
                    for _, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
                        applyGeneratorHighlight(v)
                    end
                    
                    local mapConnection = game.Workspace.Map.Ingame.Map.ChildAdded:Connect(function(child)
                        applyGeneratorHighlight(child)
                    end)
                    table.insert(connections, mapConnection)
                end
            end

            -- Watch for map changes
            local function watchForMapChanges()
                local mapConnection = game.Workspace.ChildAdded:Connect(function(child)
                    if child.Name == "Map" then
                        wait(1) -- Wait for map to fully load
                        initializeMapESP()
                    end
                end)
                table.insert(connections, mapConnection)
            end

            initializeMapESP() -- Initial setup
            watchForMapChanges() -- Watch for future map changes
        end

        toggleHighlightGen(state)
    end
})

-- Tool ESP with map change handling
local ToolESPToggle = ESPTAB:CreateToggle({
    Name = "Tool ESP",
    CurrentValue = false,
    Flag = "ToolESPToggle",
    Callback = function(state)
        local function highlighttools(state)
            toolhighlightactive = state
            cleanupConnections() -- Cleanup existing connections
            
            local function applyHighlight(tool)
                if toolhighlightactive and tool:IsA("Tool") then
                    local existinghighlight = tool:FindFirstChild("ToolHighlight")
                    if not existinghighlight then
                        local toolhighlight = Instance.new("Highlight")
                        toolhighlight.Name = "ToolHighlight"
                        toolhighlight.Parent = tool
                        toolhighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
                        if tool.Name == "Medkit" then
                            toolhighlight.FillColor = Color3.fromRGB(0, 255, 0)
                        elseif tool.Name == "BloxyCola" then
                            toolhighlight.FillColor = Color3.fromRGB(88, 57, 39)
                        end
                    end
                else
                    local existinghighlight = tool:FindFirstChild("ToolHighlight")
                    if existinghighlight then
                        existinghighlight:Destroy()
                    end
                end
            end
            
            -- Function to initialize Tool ESP for new map
            local function initializeToolESP()
                if game.Workspace:FindFirstChild("Map") and 
                   game.Workspace.Map:FindFirstChild("Ingame") then
                    for _, v in pairs(game.Workspace.Map.Ingame:GetChildren()) do
                        if v:IsA("Tool") then
                            applyHighlight(v)
                        end
                    end
                    
                    local toolConnection = game.Workspace.Map.Ingame.ChildAdded:Connect(function(child)
                        if child:IsA("Tool") then
                            applyHighlight(child)
                        end
                    end)
                    table.insert(connections, toolConnection)
                end
            end

            -- Watch for map changes
            local function watchForMapChanges()
                local mapConnection = game.Workspace.ChildAdded:Connect(function(child)
                    if child.Name == "Map" then
                        wait(1) -- Wait for map to fully load
                        initializeToolESP()
                    end
                end)
                table.insert(connections, mapConnection)
            end

            initializeToolESP() -- Initial setup
            watchForMapChanges() -- Watch for future map changes
        end

        highlighttools(state)
    end
})


Rayfield:LoadConfiguration()
