local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


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

local Tab = Window:CreateTab("Main", 4483362458) -- Title, Image
local Section = Tab:CreateSection("Survivor Stamina Config")
local Divider1 = Tab:CreateDivider()
local Section = Tab:CreateSection("Killer Stamina Config")
local Divider2 = Tab:CreateDivider()

local Tab = Window:CreateTab("Blatant", 4483362458) -- Title, Image
local Section = Tab:CreateSection("CoolStuff")

local Tab = Window:CreateTab("ESP", 4483362458) -- Title, Image
local Section = Tab:CreateSection("1x4's stable eye")


Rayfield:LoadConfiguration()
