--=======================================================================
-- URANIUM HUB v2.5
-- - GUI base Vitality con cambio de estilos
-- - Tabs con scripts deobfuscados: Catvape, Operation One, Blox Fruits
-- - Auto-deteccion de juego con popup de confirmacion
-- - Rebrand post-carga: labels "Vape" -> "Uranium"
-- Ejecutar: loadstring(game:HttpGet("https://raw.githubusercontent.com/Korsac2026/12345/main/Uranium.lua"))()
--=======================================================================

local Uranium = {}
Uranium.Name = "Uranium"
Uranium.Version = "2.5"
Uranium.Directory = "uranium"
Uranium.Sources = {}
Uranium.Ran = {}

local REPO = "https://raw.githubusercontent.com/Korsac2026/12345/main"
local REPO_SRC = REPO .. "/src"

local isfile = isfile or function(p)
    local s, r = pcall(readfile, p)
    return s and r ~= nil and r ~= ""
end

if not isfolder(Uranium.Directory) then makefolder(Uranium.Directory) end

-- CONFIG ---------------------------------------------------------------
Uranium.Config = { Gui = "vitality", AutoRun = {} }

local function LoadConfig()
    if isfile(Uranium.Directory .. "/config.json") then
        local s, r = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(Uranium.Directory .. "/config.json"))
        end)
        if s and type(r) == "table" then
            for k, v in pairs(r) do Uranium.Config[k] = v end
        end
    end
end
LoadConfig()

local function SaveConfig()
    pcall(function()
        writefile(Uranium.Directory .. "/config.json", game:GetService("HttpService"):JSONEncode(Uranium.Config))
    end)
end

-- LIBRARIES ------------------------------------------------------------
Uranium.Libraries = {
    vitality = {
        Name = "Vitality",
        Accent = Color3.fromRGB(120, 200, 120),
        Bg = Color3.fromRGB(25, 25, 30),
        Url = "https://raw.githubusercontent.com/cueshut/vitremake/main/vitality.lua",
    },
    sussy = {
        Name = "Sussy",
        Accent = Color3.fromRGB(255, 105, 180),
        Bg = Color3.fromRGB(30, 20, 30),
        Url = "https://uibin.orqan.xyz/sussy",
    },
    novus = {
        Name = "Novus",
        Accent = Color3.fromRGB(90, 160, 255),
        Bg = Color3.fromRGB(20, 25, 35),
        Url = "https://uibin.orqan.xyz/novus",
    },
    legacy = {
        Name = "Legacy",
        Accent = Color3.fromRGB(255, 180, 60),
        Bg = Color3.fromRGB(30, 28, 20),
        Url = "https://uibin.orqan.xyz/legacy",
    },
}

function Uranium.LoadLibrary(key)
    local lib = Uranium.Libraries[key]
    if not lib then return nil end
    local ok, Lib = pcall(function()
        return loadstring(game:HttpGet(lib.Url))()
    end)
    if not ok or not Lib then
        return nil, lib.Name .. " failed to load (URL down or blocked)"
    end
    local okw, Window = pcall(function()
        return Lib:Window({ Name = "Uranium" })
    end)
    if not okw or not Window then
        return nil, lib.Name .. " failed to create window"
    end
    local Watermark
    pcall(function()
        Watermark = Lib.WatermarkObject or Lib:Watermark({ Name = "Uranium", SubName = "v" .. Uranium.Version })
    end)
    return {
        Library = Lib,
        Window = Window,
        Watermark = Watermark,
        Key = key,
        Page = function(name) return Window:Page({ Name = name }) end,
        Section = function(page, name, side) return page:Section({ Name = name, Side = side or 1 }) end,
        Toggle = function(sec, name, def, flag, cb) return sec:Toggle({ Name = name, Flag = flag, Default = def, Callback = cb }) end,
        Slider = function(sec, name, min, max, def, flag, cb) return sec:Slider({ Name = name, Flag = flag, Min = min, Max = max, Default = def, Callback = cb }) end,
        Dropdown = function(sec, name, items, def, flag, cb) return sec:Dropdown({ Name = name, Flag = flag, Items = items, Default = def, Callback = cb }) end,
        Button = function(sec, name, cb) return sec:Button({ Name = name, Callback = cb }) end,
        Label = function(sec, text) return sec:Label({ Name = text }) end,
        Keybind = function(sec, name, flag, cb) return sec:Keybind({ Name = name, Flag = flag, Callback = cb }) end,
        Colorpicker = function(sec, flag, def, cb) return sec:Colorpicker({ Flag = flag, Default = def, Callback = cb }) end,
    }
end

-- POPUP ----------------------------------------------------------------
function Uranium.ConfirmPopup(title, description, callback)
    local lib = Uranium.Libraries[Uranium.Config.Gui] or Uranium.Libraries.vitality
    local CoreGui = gethui and gethui() or game:GetService("CoreGui")

    local old = CoreGui:FindFirstChild("UraniumConfirm")
    if old then old:Destroy() end

    local SG = Instance.new("ScreenGui")
    SG.Name = "UraniumConfirm"
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true
    pcall(function() SG.Parent = CoreGui end)

    local Dim = Instance.new("Frame")
    Dim.Size = UDim2.new(1, 0, 1, 0)
    Dim.BackgroundColor3 = Color3.new(0, 0, 0)
    Dim.BackgroundTransparency = 0.45
    Dim.BorderSizePixel = 0
    Dim.Parent = SG

    local Frame = Instance.new("Frame")
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.Size = UDim2.new(0, 340, 0, 200)
    Frame.BackgroundColor3 = lib.Bg
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = SG

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = lib.Accent
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.2
    Stroke.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 16, 0, 12)
    Title.Size = UDim2.new(1, -32, 0, 24)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = lib.Accent
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local Desc = Instance.new("TextLabel")
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 16, 0, 40)
    Desc.Size = UDim2.new(1, -32, 0, 70)
    Desc.Font = Enum.Font.Gotham
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(220, 220, 230)
    Desc.TextSize = 13
    Desc.TextWrapped = true
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextYAlignment = Enum.TextYAlignment.Top
    Desc.Parent = Frame

    local function mkBtn(text, x, w, color, cb)
        local b = Instance.new("TextButton")
        b.Position = UDim2.new(0, x, 1, -50)
        b.Size = UDim2.new(0, w, 0, 34)
        b.BackgroundColor3 = color
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.Text = text
        b.TextSize = 12
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Parent = Frame
        local cnr = Instance.new("UICorner")
        cnr.CornerRadius = UDim.new(0, 8)
        cnr.Parent = b
        b.MouseButton1Click:Connect(function()
            SG:Destroy()
            cb()
        end)
        return b
    end

    local darkBg = lib.Bg:Lerp(Color3.new(0, 0, 0), 0.45)

    mkBtn("Yes, load it", 16, 130, lib.Accent, function() callback("yes") end)
    mkBtn("No", 154, 60, darkBg, function() callback("no") end)
    mkBtn("Always", 220, 104, lib.Accent:Lerp(Color3.new(1, 1, 1), 0.25), function() callback("always") end)

    local Hint = Instance.new("TextLabel")
    Hint.BackgroundTransparency = 1
    Hint.Position = UDim2.new(0, 16, 1, -26)
    Hint.Size = UDim2.new(1, -32, 0, 20)
    Hint.Font = Enum.Font.Gotham
    Hint.Text = "Always = auto-load in this game without asking again"
    Hint.TextColor3 = Color3.fromRGB(140, 140, 150)
    Hint.TextSize = 10
    Hint.TextXAlignment = Enum.TextXAlignment.Left
    Hint.Parent = Frame

    task.delay(30, function()
        if SG and SG.Parent then
            SG:Destroy()
            callback("no")
        end
    end)
end

-- NOTIFY + REBRAND -----------------------------------------------------
function Uranium.Notify(Title, Desc, Time)
    if Uranium.Gui and Uranium.Gui.Library and Uranium.Gui.Library.Notification then
        pcall(function()
            Uranium.Gui.Library:Notification({ Name = Title, Description = Desc, Time = Time or 5 })
        end)
    else
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = Title, Text = Desc or "", Duration = Time or 5 })
        end)
    end
end

function Uranium.RebrandUI()
    local function sweep()
        local renamed = 0
        pcall(function()
            local cg = gethui and gethui() or game:GetService("CoreGui")
            for _, root in ipairs(cg:GetChildren()) do
                for _, v in ipairs(root:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Text and v.Text:match("Vape") then
                        v.Text = v.Text:gsub("Vape", "Uranium"):gsub("vape", "Uranium")
                        renamed = renamed + 1
                    end
                    if v:IsA("TextButton") and v.Text and v.Text:match("Vape") then
                        v.Text = v.Text:gsub("Vape", "Uranium")
                        renamed = renamed + 1
                    end
                end
            end
        end)
        return renamed
    end
    task.delay(2, function()
        local n = sweep()
        if n > 0 then Uranium.Notify("Uranium", "Rebranded " .. n .. " labels to Uranium.", 3) end
    end)
    task.delay(6, function() sweep() end)
    task.delay(12, function() sweep() end)
end

-- SOURCES + DETECCION --------------------------------------------------
function Uranium.RegisterSource(name, placeIds, func)
    table.insert(Uranium.Sources, { Name = name, PlaceIds = placeIds, Func = func })
end

function Uranium.GetSupported(placeId)
    local found = {}
    for _, src in ipairs(Uranium.Sources) do
        if table.find(src.PlaceIds, placeId) then table.insert(found, src) end
    end
    return found
end

function Uranium.RunSource(src)
    if Uranium.Ran[src.Name] then return end
    Uranium.Ran[src.Name] = true
    local ok, err = pcall(src.Func, Uranium)
    if not ok then
        warn("[Uranium] " .. src.Name .. " error: " .. tostring(err))
        Uranium.Notify("Uranium", src.Name .. " error: " .. tostring(err), 7)
    end
    return ok
end

function Uranium.AutoDetect()
    local placeId = game.PlaceId
    local supported = Uranium.GetSupported(placeId)

    if #supported == 0 then
        Uranium.Notify("Uranium", "Game not supported yet - universal mode.", 6)
        return
    end

    if Uranium.Config.AutoRun[tostring(placeId)] == true then
        for _, src in ipairs(supported) do Uranium.RunSource(src) end
        Uranium.Notify("Uranium", "Auto-loaded: " .. supported[1].Name, 4)
        return
    end

    local names = {}
    for _, s in ipairs(supported) do table.insert(names, s.Name) end

    Uranium.ConfirmPopup(
        "Game Detected",
        "This game is supported by Uranium:\n" .. table.concat(names, ", ") .. "\n\nDo you want to load the script?",
        function(answer)
            if answer == "always" then
                Uranium.Config.AutoRun[tostring(placeId)] = true
                SaveConfig()
            end
            if answer == "yes" or answer == "always" then
                for _, src in ipairs(supported) do Uranium.RunSource(src) end
            else
                Uranium.Notify("Uranium", "Skipped. Load it manually from its tab.", 5)
            end
        end
    )
end

-- HUB ------------------------------------------------------------------
local Building = false

function Uranium.SetGui(key)
    if Building then return end
    if not Uranium.Libraries[key] then return end
    Building = true

    pcall(function() writefile(Uranium.Directory .. "/gui.txt", key) end)
    Uranium.Config.Gui = key
    SaveConfig()

    if Uranium.Gui then
        pcall(function()
            if Uranium.Gui.Watermark and Uranium.Gui.Watermark.Remove then Uranium.Gui.Watermark:Remove() end
        end)
        pcall(function()
            if Uranium.Gui.Window and Uranium.Gui.Window.Remove then Uranium.Gui.Window:Remove() end
        end)
        local CoreGui = gethui and gethui() or game:GetService("CoreGui")
        for _, v in ipairs(CoreGui:GetChildren()) do
            if v.Name:find("Uranium") or v.Name == "Vitality" or v.Name == "Watermark" then
                pcall(function() v:Destroy() end)
            end
        end
    end

    local gui, err = Uranium.LoadLibrary(key)
    if not gui then
        Building = false
        Uranium.Notify("Uranium", tostring(err) .. "\nFalling back to Vitality.", 7)
        pcall(function() writefile(Uranium.Directory .. "/gui.txt", "vitality") end)
        gui = Uranium.LoadLibrary("vitality")
        if not gui then return end
    end

    Uranium.Gui = gui
    Building = false
    Uranium.Build()
    Uranium.Notify("Uranium", "Interface applied: " .. Uranium.Libraries[key].Name, 4)
end

function Uranium.PreviewGui(key)
    local lib = Uranium.Libraries[key]
    if not lib then return end
    local CoreGui = gethui and gethui() or game:GetService("CoreGui")
    local old = CoreGui:FindFirstChild("UraniumPreview")
    if old then old:Destroy() end

    local SG = Instance.new("ScreenGui")
    SG.Name = "UraniumPreview"
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true
    pcall(function() SG.Parent = CoreGui end)

    local Frame = Instance.new("Frame")
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.Size = UDim2.new(0, 260, 0, 180)
    Frame.BackgroundColor3 = lib.Bg
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = SG

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = lib.Accent
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.2
    Stroke.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.Size = UDim2.new(1, -24, 0, 24)
    Title.Font = Enum.Font.GothamBold
    Title.Text = lib.Name .. " - Uranium"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local tog = Instance.new("TextButton")
    tog.Position = UDim2.new(0, 12, 0, 44)
    tog.Size = UDim2.new(1, -24, 0, 28)
    tog.BackgroundColor3 = lib.Accent
    tog.BorderSizePixel = 0
    tog.Text = "  Uranium Blox Fruits"
    tog.Font = Enum.Font.Gotham
    tog.TextSize = 12
    tog.TextXAlignment = Enum.TextXAlignment.Left
    tog.TextColor3 = Color3.new(1, 1, 1)
    tog.Parent = Frame
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 6)
    c2.Parent = tog
    local on = true
    tog.MouseButton1Click:Connect(function()
        on = not on
        tog.BackgroundColor3 = on and lib.Accent or lib.Bg:Lerp(Color3.new(0, 0, 0), 0.3)
    end)

    local slid = Instance.new("Frame")
    slid.Position = UDim2.new(0, 12, 0, 82)
    slid.Size = UDim2.new(1, -24, 0, 20)
    slid.BackgroundColor3 = lib.Bg:Lerp(Color3.new(0, 0, 0), 0.4)
    slid.BorderSizePixel = 0
    slid.Parent = Frame
    local c3 = Instance.new("UICorner")
    c3.CornerRadius = UDim.new(0, 6)
    c3.Parent = slid
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.55, 0, 1, 0)
    fill.BackgroundColor3 = lib.Accent
    fill.BorderSizePixel = 0
    fill.Parent = slid
    local c4 = Instance.new("UICorner")
    c4.CornerRadius = UDim.new(0, 6)
    c4.Parent = fill
    local sTxt = Instance.new("TextLabel")
    sTxt.BackgroundTransparency = 1
    sTxt.Size = UDim2.new(1, 0, 1, 0)
    sTxt.Font = Enum.Font.Gotham
    sTxt.TextSize = 11
    sTxt.Text = "  Bring Radius: 550 studs"
    sTxt.TextColor3 = Color3.new(1, 1, 1)
    sTxt.TextXAlignment = Enum.TextXAlignment.Left
    sTxt.Parent = slid

    local apply = Instance.new("TextButton")
    apply.Position = UDim2.new(0, 12, 0, 112)
    apply.Size = UDim2.new(0.5, -15, 0, 26)
    apply.BackgroundColor3 = lib.Accent
    apply.BorderSizePixel = 0
    apply.Font = Enum.Font.GothamBold
    apply.Text = "Apply"
    apply.TextSize = 12
    apply.TextColor3 = Color3.new(1, 1, 1)
    apply.Parent = Frame
    local c5 = Instance.new("UICorner")
    c5.CornerRadius = UDim.new(0, 6)
    c5.Parent = apply
    apply.MouseButton1Click:Connect(function()
        SG:Destroy()
        Uranium.SetGui(key)
    end)

    local close = Instance.new("TextButton")
    close.Position = UDim2.new(0.5, 3, 0, 112)
    close.Size = UDim2.new(0.5, -15, 0, 26)
    close.BackgroundColor3 = lib.Bg:Lerp(Color3.new(0, 0, 0), 0.5)
    close.BorderSizePixel = 0
    close.Font = Enum.Font.GothamBold
    close.Text = "Close"
    close.TextSize = 12
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Parent = Frame
    local c6 = Instance.new("UICorner")
    c6.CornerRadius = UDim.new(0, 6)
    c6.Parent = close
    close.MouseButton1Click:Connect(function() SG:Destroy() end)

    local note = Instance.new("TextLabel")
    note.BackgroundTransparency = 1
    note.Position = UDim2.new(0, 12, 0, 144)
    note.Size = UDim2.new(1, -24, 0, 28)
    note.Font = Enum.Font.Gotham
    note.TextSize = 10
    note.Text = "Preview of " .. lib.Name .. " style.\nApply rebuilds the hub with this interface."
    note.TextColor3 = Color3.fromRGB(180, 180, 190)
    note.TextWrapped = true
    note.Parent = Frame

    task.delay(30, function()
        if SG and SG.Parent then SG:Destroy() end
    end)
end

function Uranium.Build()
    local Gui = Uranium.Gui
    if not Gui then return end

    -- SETTINGS
    local SettingsPage = Gui.Page("Settings")
    local Sec = Gui.Section(SettingsPage, "Interface", 1)
    Gui.Label(Sec, "Available styles. Preview shows how it looks before applying.")

    local names, keyOf = {}, {}
    for k, l in pairs(Uranium.Libraries) do
        table.insert(names, l.Name)
        keyOf[l.Name] = k
    end
    table.sort(names)

    local current = Uranium.Libraries[Uranium.Config.Gui] and Uranium.Libraries[Uranium.Config.Gui].Name or "Vitality"
    Gui.Dropdown(Sec, "Current style", names, current, "uranium_style", function(v) end)

    for _, name in ipairs(names) do
        local k = keyOf[name]
        Gui.Button(Sec, "Preview: " .. name, function()
            Uranium.PreviewGui(k)
        end)
    end

    local SecD = Gui.Section(SettingsPage, "Detection", 1)
    Gui.Button(SecD, "Re-detect current game", function()
        Uranium.AutoDetect()
    end)
    Gui.Button(SecD, "Clear saved answers", function()
        Uranium.Config.AutoRun = {}
        SaveConfig()
        Uranium.Notify("Uranium", "Saved answers cleared.", 4)
    end)

    local SecR = Gui.Section(SettingsPage, "Uranium", 2)
    Gui.Label(SecR, "Uranium Hub v" .. Uranium.Version .. "\nRepo: Korsac2026/12345\nSources: Catvape (rebranded), Operation One, Blox Fruits.")
    Gui.Button(SecR, "Reload hub (same GUI)", function()
        Uranium.SetGui(Uranium.Config.Gui)
    end)

    -- SCRIPTS TAB
    local ScriptsPage = Gui.Page("Scripts")
    local AllSec = Gui.Section(ScriptsPage, "Deobfuscated Scripts", 1)
    Gui.Label(AllSec, "All scripts work in any supported game.\nScripts with their own GUI will open their own window.")
    Gui.Button(AllSec, "Uranium Catvape (full hub, all games)", function()
        Uranium.ExecuteCatvape()
    end)
    Gui.Button(AllSec, "Uranium Operation One (Astro)", function()
        Uranium.ExecuteOperationOne()
    end)
    Gui.Button(AllSec, "Uranium Blox Fruits", function()
        Uranium.ExecuteBloxfruits()
    end)

    -- paginas por juego detectado
    local PlaceId = game.PlaceId
    local supported = Uranium.GetSupported(PlaceId)
    local any = false
    for _, Source in ipairs(supported) do
        any = true
        local ok = pcall(Source.Func, Uranium)
        if not ok then warn("[Uranium] source build failed: " .. Source.Name) end
    end

    if not any then
        local MainPage = Gui.Page("Main")
        local MSec = Gui.Section(MainPage, "Uranium", 1)
        local gname = "Unknown"
        pcall(function()
            gname = game:GetService("MarketplaceService"):GetProductInfo(PlaceId).Name
        end)
        Gui.Label(MSec, "Uranium Hub v" .. Uranium.Version .. "\n\nGame: " .. gname .. "\nPlaceId: " .. PlaceId .. "\n\nThis game has no dedicated script yet.\nSupported: Catvape games, Operation One, Blox Fruits.")
    end
end

-- EXECUTORS ------------------------------------------------------------
function Uranium.ExecuteCatvape()
    Uranium.Notify("Uranium", "Loading Uranium Catvape...", 4)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO_SRC .. "/init.lua"))()
    end)
    Uranium.RebrandUI()
    if not ok then
        Uranium.Notify("Uranium", "Catvape error: " .. tostring(err), 8)
    end
end

function Uranium.ExecuteOperationOne()
    Uranium.Notify("Uranium", "Loading Uranium Operation One...", 4)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO_SRC .. "/uranium/dumps/operationone_dump.lua"))()
    end)
    if ok then
        Uranium.RebrandUI()
    else
        Uranium.Notify("Uranium", "Operation One error: " .. tostring(err), 8)
        if isfile("uranium/dumps/operationone_dump.lua") then
            local ok2, err2 = pcall(function()
                loadstring(readfile("uranium/dumps/operationone_dump.lua"))()
            end)
            if ok2 then
                Uranium.RebrandUI()
            else
                Uranium.Notify("Uranium", "Disk error: " .. tostring(err2), 8)
            end
        end
    end
end

function Uranium.ExecuteBloxfruits()
    Uranium.Notify("Uranium", "Loading Uranium Blox Fruits...", 4)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO_SRC .. "/uranium/dumps/bloxfruits_deob.lua"))()
    end)
    if ok then
        Uranium.Notify("Uranium", "Uranium Blox Fruits loaded.", 4)
    else
        Uranium.Notify("Uranium", "Blox Fruits error: " .. tostring(err), 8)
    end
end

-- SOURCES REGISTRADOS --------------------------------------------------

Uranium.RegisterSource("Uranium Catvape", {
    16483433878, 115875349872417, 122425529900803, 126987974021910,
    132768098780837, 139566161526375, 155615604, 1962086868, 4468711919,
    5938036553, 606849621, 6872265039, 6872274481, 8768229691, 893973440,
}, function(Uranium)
    local Gui = Uranium.Gui
    local Page = Gui.Page("Catvape")
    local Sec = Gui.Section(Page, "Uranium Catvape", 1)
    Gui.Label(Sec, "Full Catvape hub (deobfuscated) - opens its own window with all modules for this game.")
    Gui.Button(Sec, "Execute Uranium Catvape", function()
        Uranium.ExecuteCatvape()
    end)
    local Sec2 = Gui.Section(Page, "Info", 2)
    Gui.Label(Sec2, "Catvape is a full hub: Combat, Blatant, Render, Utility tabs. Rebranded to Uranium on load.")
end)

Uranium.RegisterSource("Uranium Operation One", { 253832, 6229116934 }, function(Uranium)
    local Gui = Uranium.Gui
    local Page = Gui.Page("Operation One")
    local Sec = Gui.Section(Page, "Uranium Operation One", 1)
    Gui.Label(Sec, "Astro/Operation One payload (deobfuscated ZSTD dump).\nNo key system, no anti-tamper, no rejoin kick.\nRuns with its own GUI (Obsidian).")
    Gui.Button(Sec, "Execute Uranium Operation One", function()
        Uranium.ExecuteOperationOne()
    end)
    local Sec2 = Gui.Section(Page, "Disk", 2)
    Gui.Button(Sec2, "Download to disk", function()
        local ok, res = pcall(function()
            return game:HttpGet(REPO_SRC .. "/uranium/dumps/operationone_dump.lua", true)
        end)
        if ok and res and #res > 10000 then
            if not isfolder("uranium/dumps") then makefolder("uranium/dumps") end
            writefile("uranium/dumps/operationone_dump.lua", res)
            Uranium.Notify("Uranium", "Saved (" .. #res .. " bytes).", 5)
        else
            Uranium.Notify("Uranium", "Download failed.", 5)
        end
    end)
end)

Uranium.RegisterSource("Uranium Blox Fruits", { 2753915549, 4442272183, 7449423635 }, function(Uranium)
    local Gui = Uranium.Gui
    local Page = Gui.Page("Blox Fruits")
    local Sec = Gui.Section(Page, "Uranium Blox Fruits", 1)
    Gui.Dropdown(Sec, "Team", { "Pirates", "Marines" }, "Pirates", "uranium_bf_team", function(v)
        getgenv().Team = v
    end)
    Gui.Toggle(Sec, "Auto Attack", true, "uranium_bf_autoattack", function(v)
        getgenv().UraniumBF_AutoAttack = v
    end)
    Gui.Slider(Sec, "Fast Attack Delay", 0, 2, 0, "uranium_bf_delay", function(v)
        getgenv().UraniumBF_Delay = v
    end)
    Gui.Toggle(Sec, "Attack Mobs", true, "uranium_bf_mobs", function(v)
        getgenv().UraniumBF_Mobs = v
    end)
    Gui.Button(Sec, "Execute full script", function()
        Uranium.ExecuteBloxfruits()
    end)
    local Sec2 = Gui.Section(Page, "Disk", 2)
    Gui.Button(Sec2, "Download to disk", function()
        local ok, res = pcall(function()
            return game:HttpGet(REPO_SRC .. "/uranium/dumps/bloxfruits_deob.lua", true)
        end)
        if ok and res and #res > 1000 then
            if not isfolder("uranium/dumps") then makefolder("uranium/dumps") end
            writefile("uranium/dumps/bloxfruits_deob.lua", res)
            Uranium.Notify("Uranium", "Saved (" .. #res .. " bytes).", 5)
        else
            Uranium.Notify("Uranium", "Download failed.", 5)
        end
    end)
end)

-- ARRANQUE -------------------------------------------------------------
local gui, err = Uranium.LoadLibrary(Uranium.Config.Gui)
if not gui then
    Uranium.Notify("Uranium", (err or "GUI failed") .. " - using Vitality.", 7)
    gui = Uranium.LoadLibrary("vitality")
end
Uranium.Gui = gui
Uranium.Build()

task.delay(0.5, function()
    Uranium.AutoDetect()
end)

Uranium.Notify("Uranium", "Hub loaded - v" .. Uranium.Version, 4)
shared.Uranium = Uranium
getgenv().Uranium = Uranium

return Uranium