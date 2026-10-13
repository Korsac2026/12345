--!nocheck
-- Local loader for catvape source (fully offline, fully editable)
-- Usage: put this file + the catsix/ folder in your executor workspace, then:
--   loadstring(readfile("init_local.lua"))()
-- or just execute this file directly.

if shared.vapedeveloper ~= nil then
    shared.VapeDeveloper = shared.vapedeveloper
end
local Directory: string = shared.VapeDeveloper and "catprivate" or "catsix"

local Licence = { }
Licence.Key = script_key or "_key"

local cloneref = cloneref or function(r) return r end
local isfile = isfile or function(p)
    local s, r = pcall(readfile, p)
    return s and r ~= nil and r ~= ""
end
local loadstring = loadstring or function(...) return load(...) end

local Players = cloneref(game:GetService("Players"))
local HttpService = cloneref(game:GetService("HttpService"))

if not game:IsLoaded() then
    game.Loaded:Wait()
end
if shared.vapeloading and coroutine.status(shared.vapeloading) ~= "dead" then
    return
end
shared.vapeloading = coroutine.running()
if shared.vape then
    shared.vape:Uninject()
end

local Executor = identifyexecutor ~= nil and ({identifyexecutor()})[1] or ""
local IsMadium = Executor == "Madium"
local CanHook = not table.find({"Madium", "Solara", "Xeno"}, Executor)

for _, Folder in {Directory, `{Directory}/games`, `{Directory}/profiles`, `{Directory}/assets`, `{Directory}/libraries`, `{Directory}/guis`} do
    if not isfolder(Folder) then
        makefolder(Folder)
    end
end

if IsMadium and game.GameId == 2619619496 and not Players.LocalPlayer:GetAttribute("PlayerConnected") then
    local LogService = cloneref(game:GetService("LogService"))
    local SetupLine = "[SETUP] Set up Flamework Client"
    local SetupDone = false
    local SetupConnection = LogService.MessageOut:Connect(function(Message)
        if string.find(Message, SetupLine, 1, true) then
            SetupDone = true
        end
    end)
    for _, Entry in LogService:GetLogHistory() do
        if string.find(Entry.message, SetupLine, 1, true) then
            SetupDone = true
            break
        end
    end
    local WaitStarted = os.clock()
    repeat
        task.wait(0.25)
    until SetupDone or os.clock() - WaitStarted > 20
    SetupConnection:Disconnect()
end

local function ReadLocal(FilePath)
    return readfile(FilePath)
end

local function FinishLoading(vape)
    vape.Init = nil
    vape:Load()
    shared.vapeloading = nil

    local TeleportedServers = false
    vape:Clean(Players.LocalPlayer.OnTeleport:Connect(function()
        if not TeleportedServers then
            TeleportedServers = true
            -- reload from local files after teleport
            queue_on_teleport(`loadstring(readfile("{Directory}/init_local.lua"), "init_local")()`)
        end
    end))

    if not shared.vapereload then
        vape:CreateNotification("Finished Loading", (vape.VapeButton and "Press the button in the top right" or `Press {table.concat(vape.GUIBind and vape.GUIBind.Keys or {"RightShift"}, " + "):upper()} to open GUI`, 5)
    end
end

if not isfile(`{Directory}/profiles/gui.txt`) then
    writefile(`{Directory}/profiles/gui.txt`, "new")
end
local Gui = "new"

local vape, RunPremium = loadstring(ReadLocal(`{Directory}/guis/{Gui}.lua`), "gui")(Licence)
shared.vape = vape
shared.vapesmooth = false
_G.vape = vape
getgenv().used_init = true

if hookmetamethod and not getgenv().run and CanHook then
    getgenv().run = true
    local Old
    Old = hookmetamethod(game, "__namecall", newcclosure(function(self, Remote, ...)
        if not checkcaller() and getnamecallmethod() == "FireServer" then
            if typeof(Remote) == "Instance" and Remote.Name == "TabFreezeAnticheat_ClientToServerReport" and shared.vapeloading then
                return
            end
        end
        return Old(self, Remote, ...)
    end))
end

if not shared.VapeIndependent then
    loadstring(ReadLocal(`{Directory}/games/universal.lua`), "universal")(Licence)
    if isfile(`{Directory}/games/{game.PlaceId}.lua`) then
        loadstring(readfile(`{Directory}/games/{game.PlaceId}.lua`), tostring(game.PlaceId))(Licence)
    end
    loadstring(ReadLocal(`{Directory}/libraries/main.lua`), "main")(Licence)
    FinishLoading(vape)
else
    vape.Init = function() FinishLoading(vape) end
    return vape
end