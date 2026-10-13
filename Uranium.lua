--=======================================================================
-- URANIUM HUB v2.6
-- - Auto-detection: popup "Yes" actually EXECUTES the script and closes hub
-- - Popup styled to match active GUI library
-- - All English. Watermark "Uranium".
-- Ejecutar: loadstring(game:HttpGet("https://raw.githubusercontent.com/Korsac2026/12345/main/Uranium.lua"))()
--=======================================================================

local Uranium = {}
Uranium.Name = "Uranium"
Uranium.Version = "2.6"
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

-- close main hub window (used after script execution) ------------------
function Uranium.CloseHub()
    pcall(function()
        if Uranium.Gui and Uranium.Gui.Watermark and Uranium.Gui.Watermark.Remove then
            Uranium.Gui.Watermark:Remove()
        end
    end)
    pcall(function()
        if Uranium.Gui and Uranium.Gui.Window and Uranium.Gui.Window.Remove then
            Uranium.Gui.Window:Remove()
        end
    end)
    pcall(function()
        local cg = gethui and gethui() or game:GetService("CoreGui")
        for _, v in ipairs(cg:GetChildren()) do
            if v.Name == "Vitality" or v.Name == "Watermark" then
                v:Destroy()
            end
        end
    end)
end

-- POPUP (styled like the active GUI library) ---------------------------
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
    Frame.Size = UDim2.new(0, 360, 0, 210)
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

    -- header bar like the main window
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = lib.Bg:Lerp(Color3.new(0, 0, 0), 0.2)
    Header.BorderSizePixel = 0
    Header.Parent = Frame
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 10)
    hCorner.Parent = Header
    local hCover = Instance.new("Frame")
    hCover.Position = UDim2.new(0, 0, 1, -10)
    hCover.Size = UDim2.new(1, 0, 0, 10)
    hCover.BackgroundColor3 = Header.BackgroundColor3
    hCover.BorderSizePixel = 0
    hCover.Parent = Header

    local LogoDot = Instance.new("Frame")
    LogoDot.Position = UDim2.new(0, 14, 0.5, 0)
    LogoDot.AnchorPoint = Vector2.new(0, 0.5)
    LogoDot.Size = UDim2.new(0, 22, 0, 22)
    LogoDot.BackgroundColor3 = lib.Accent
    LogoDot.BorderSizePixel = 0
    LogoDot.Parent = Header
    local lCorner = Instance.new("UICorner")
    lCorner.CornerRadius = UDim.new(0, 6)
    lCorner.Parent = LogoDot

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 44, 0, 0)
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = lib.Accent
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local Desc = Instance.new("TextLabel")
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 16, 0, 52)
    Desc.Size = UDim2.new(1, -32, 0, 80)
    Desc.Font = Enum.Font.Gotham
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(225, 225, 235)
    Desc.TextSize = 13
    Desc.TextWrapped = true
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextYAlignment = Enum.TextYAlignment.Top
    Desc.Parent = Frame

    local function mkBtn(text, x, w, isPrimary, cb)
        local b = Instance.new("TextButton")
        b.Position = UDim2.new(0, x, 1, -52)
        b.Size = UDim2.new(0, w, 0, 36)
        b.BackgroundColor3 = isPrimary and lib.Accent or lib.Bg:Lerp(Color3.new(0, 0, 0), 0.45)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.Text = text
        b.TextSize = 12
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Parent = Frame
        local cnr = Instance.new("UICorner")
        cnr.CornerRadius = UDim.new(0, 8)
        cnr.Parent = b
        b.MouseEnter:Connect(function()
            if isPrimary then
                b.BackgroundColor3 = lib.Accent:Lerp(Color3.new(1, 1, 1), 0.12)
            else
                b.BackgroundColor3 = lib.Bg:Lerp(Color3.new(1, 1, 1), 0.05)
            end
        end)
        b.MouseLeave:Connect(function()
            b.BackgroundColor3 = isPrimary and lib.Accent or lib.Bg:Lerp(Color3.new(0, 0, 0), 0.45)
        end)
        b.MouseButton1Click:Connect(function()
            SG:Destroy()
            cb()
        end)
        return b
    end

    mkBtn("Yes, load it", 16, 150, true, function() callback("yes") end)
    mkBtn("No", 174, 80, false, function() callback("no") end)
    mkBtn("Always", 260, 84, false, function() callback("always") end)

    local Hint = Instance.new("TextLabel")
    Hint.BackgroundTransparency = 1
    Hint.Position = UDim2.new(0, 16, 1, -24)
    Hint.Size = UDim2.new(1, -32, 0, 18)
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

-- NOTIFY ---------------------------------------------------------------
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

-- REBRAND sweeps (post-load: text labels AND logo images) ----------------
function Uranium.RebrandUI()
    local LOGO_ASSETS = {
        "126205920310261", -- vapelogo.png
        "109041903452149", -- vapelogomini.png
        "102549752760489", -- v4.png
        "115213099001611", -- v4mini.png
    }
    local function isLogoImage(img)
        if not img then return false end
        for _, id in ipairs(LOGO_ASSETS) do
            if img:find(id) then return true end
        end
        return false
    end
    local function replaceWithText(obj)
        -- reemplaza ImageLabel del logo por TextLabel "URANIUM"
        local parent = obj.Parent
        if not parent then return end
        local pos, size = obj.Position, obj.Size
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.Position = pos
        txt.Size = size
        txt.Font = Enum.Font.GothamBlack
        txt.Text = "URANIUM"
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextScaled = true
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Name = "UraniumLogoText"
        txt.Parent = parent
        obj:Destroy()
    end
    local function sweep()
        local renamed = 0
        pcall(function()
            local cg = gethui and gethui() or game:GetService("CoreGui")
            for _, root in ipairs(cg:GetChildren()) do
                for _, v in ipairs(root:GetDescendants()) do
                    -- logo images -> text
                    if v:IsA("ImageLabel") and isLogoImage(v.Image) then
                        replaceWithText(v)
                        renamed = renamed + 1
                    end
                    -- text labels
                    if v:IsA("TextLabel") and v.Text then
                        local t = v.Text
                        if t:match("Vape") or t:match("vape") or t:match("VAPE") or t:match("catvape") or t:match("CatVape") or t:match("Catvape") then
                            v.Text = t:gsub("VAPE", "Uranium"):gsub("Vape", "Uranium"):gsub("catvape", "Uranium"):gsub("CatVape", "Uranium"):gsub("Catvape", "Uranium"):gsub("vape", "Uranium")
                            renamed = renamed + 1
                        end
                    end
                    if v:IsA("TextButton") and v.Text then
                        local t = v.Text
                        if t:match("Vape") or t:match("vape") or t:match("VAPE") or t:match("catvape") or t:match("CatVape") or t:match("Catvape") then
                            v.Text = t:gsub("VAPE", "Uranium"):gsub("Vape", "Uranium"):gsub("catvape", "Uranium"):gsub("CatVape", "Uranium"):gsub("Catvape", "Uranium"):gsub("vape", "Uranium")
                            renamed = renamed + 1
                        end
                    end
                end
            end
        end)
        return renamed
    end
    task.delay(2, function()
        local n = sweep()
        if n > 0 then Uranium.Notify("Uranium", "Rebranded " .. n .. " elements to Uranium.", 3) end
    end)
    task.delay(5, function() sweep() end)
    task.delay(10, function() sweep() end)
    task.delay(20, function() sweep() end)
end

-- SOURCES + DETECCION --------------------------------------------------
-- ahora cada Source tiene: BuildFunc (construye la pestaña) y Exec (ejecuta el script real)
function Uranium.RegisterSource(name, placeIds, buildFunc, execFunc)
    table.insert(Uranium.Sources, {
        Name = name,
        PlaceIds = placeIds,
        Build = buildFunc,
        Exec = execFunc,
    })
end

function Uranium.GetSupported(placeId)
    local found = {}
    for _, src in ipairs(Uranium.Sources) do
        if table.find(src.PlaceIds, placeId) then table.insert(found, src) end
    end
    return found
end

function Uranium.AutoDetect()
    local placeId = game.PlaceId
    local supported = Uranium.GetSupported(placeId)

    if #supported == 0 then
        Uranium.Notify("Uranium", "Game not supported yet - universal mode.", 6)
        return
    end

    local names = {}
    for _, s in ipairs(supported) do table.insert(names, s.Name) end

    if Uranium.Config.AutoRun[tostring(placeId)] == true then
        -- auto-ejecutar sin preguntar
        for _, src in ipairs(supported) do
            task.spawn(function()
                src.Exec()
            end)
        end
        Uranium.Notify("Uranium", "Auto-loaded: " .. table.concat(names, ", "), 4)
        return
    end

    Uranium.ConfirmPopup(
        "Uranium - Game Detected",
        "This game is supported by Uranium:\n" .. table.concat(names, ", ") .. "\n\nDo you want to load the script?",
        function(answer)
            if answer == "always" then
                Uranium.Config.AutoRun[tostring(placeId)] = true
                SaveConfig()
            end
            if answer == "yes" or answer == "always" then
                Uranium.Notify("Uranium", "Loading " .. table.concat(names, ", ") .. "...", 4)
                Uranium.CloseHub()
                for _, src in ipairs(supported) do
                    task.spawn(function()
                        src.Exec()
                    end)
                end
            else
                Uranium.Notify("Uranium", "Skipped. Load it manually from the Scripts tab.", 5)
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

    Uranium.CloseHub()

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
    Gui.Label(SecR, "Uranium Hub v" .. Uranium.Version .. "\nRepo: Korsac2026/12345\nSources: Catvape, Operation One, Blox Fruits.")
    Gui.Button(SecR, "Reload hub (same GUI)", function()
        Uranium.SetGui(Uranium.Config.Gui)
    end)

    -- SCRIPTS TAB (always visible, manual execution)
    local ScriptsPage = Gui.Page("Scripts")
    local AllSec = Gui.Section(ScriptsPage, "Deobfuscated Scripts", 1)
    Gui.Label(AllSec, "Execute any script manually. The hub closes and the script opens its own GUI.")
    Gui.Button(AllSec, "Uranium Catvape (full hub)", function()
        Uranium.CloseHub()
        task.spawn(function() Uranium.ExecCatvape() end)
    end)
    Gui.Button(AllSec, "Uranium Operation One (Astro)", function()
        Uranium.CloseHub()
        task.spawn(function() Uranium.ExecOperationOne() end)
    end)
    Gui.Button(AllSec, "Uranium Blox Fruits", function()
        Uranium.CloseHub()
        task.spawn(function() Uranium.ExecBloxfruits() end)
    end)

    -- per-game tabs (only for the current game if supported)
    local PlaceId = game.PlaceId
    local supported = Uranium.GetSupported(PlaceId)
    local any = false
    for _, Source in ipairs(supported) do
        any = true
        local ok, err = pcall(Source.Build, Uranium)
        if not ok then warn("[Uranium] tab build failed: " .. tostring(err)) end
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

-- EXECUTORS (the real script loaders) -----------------------------------
-- these use StarterGui notifications since the hub window may be closed

function Uranium.ExecCatvape()
    local function note(t, d, ti)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = t, Text = d or "", Duration = ti or 5 })
        end)
    end
    note("Uranium", "Loading Uranium Catvape...", 4)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO_SRC .. "/init.lua"))()
    end)
    Uranium.RebrandUI()
    if not ok then
        note("Uranium", "Catvape error: " .. tostring(err), 8)
    end
end

function Uranium.ExecOperationOne()
    local function note(t, d, ti)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = t, Text = d or "", Duration = ti or 5 })
        end)
    end
    note("Uranium", "Loading Uranium Operation One...", 4)

    -- 1) repo dump
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO_SRC .. "/uranium/dumps/operationone_dump.lua"))()
    end)
    if ok then
        Uranium.RebrandUI()
        return
    end

    -- 2) disk copy
    if isfile("uranium/dumps/operationone_dump.lua") then
        local ok2, err2 = pcall(function()
            loadstring(readfile("uranium/dumps/operationone_dump.lua"))()
        end)
        if ok2 then
            Uranium.RebrandUI()
            return
        end
        note("Uranium", "Disk copy error: " .. tostring(err2), 8)
    end

    -- 3) original loader as last resort
    local ok3, err3 = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
    end)
    if ok3 then
        Uranium.RebrandUI()
    else
        note("Uranium", "Operation One failed all methods:\n" .. tostring(err), 10)
    end
end

function Uranium.ExecBloxfruits()
    local function note(t, d, ti)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = t, Text = d or "", Duration = ti or 5 })
        end)
    end
    note("Uranium", "Loading Uranium Blox Fruits...", 4)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO_SRC .. "/uranium/dumps/bloxfruits_deob.lua"))()
    end)
    if ok then
        Uranium.RebrandUI()
    else
        note("Uranium", "Blox Fruits error: " .. tostring(err), 8)
    end
end

-- SOURCES REGISTRADOS --------------------------------------------------

Uranium.RegisterSource(
    "Uranium Catvape",
    {
        16483433878, 115875349872417, 122425529900803, 126987974021910,
        132768098780837, 139566161526375, 155615604, 1962086868, 4468711919,
        5938036553, 606849621, 6872265039, 6872274481, 8768229691, 893973440,
    },
    -- Build (tab de la GUI)
    function(Uranium)
        local Gui = Uranium.Gui
        local Page = Gui.Page("Catvape")
        local Sec = Gui.Section(Page, "Uranium Catvape", 1)
        Gui.Label(Sec, "Full Catvape hub (deobfuscated). Opens its own window with all modules for this game.")
        Gui.Button(Sec, "Execute Uranium Catvape", function()
            Uranium.CloseHub()
            task.spawn(function() Uranium.ExecCatvape() end)
        end)
    end,
    -- Exec (ejecucion real)
    Uranium.ExecCatvape
)

Uranium.RegisterSource(
    "Uranium Operation One",
    { 253832, 6229116934 },
    function(Uranium)
        local Gui = Uranium.Gui
        local Page = Gui.Page("Operation One")
        local Sec = Gui.Section(Page, "Uranium Operation One", 1)
        Gui.Label(Sec, "Astro/Operation One payload (deobfuscated).\nNo key system, no anti-tamper.\nRuns with its own GUI.")
        Gui.Button(Sec, "Execute Uranium Operation One", function()
            Uranium.CloseHub()
            task.spawn(function() Uranium.ExecOperationOne() end)
        end)
    end,
    Uranium.ExecOperationOne
)

Uranium.RegisterSource(
    "Uranium Blox Fruits",
    { 2753915549, 4442272183, 7449423635 },
    function(Uranium)
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
            Uranium.CloseHub()
            task.spawn(function() Uranium.ExecBloxfruits() end)
        end)
    end,
    Uranium.ExecBloxfruits
)

-- ARRANQUE -------------------------------------------------------------
local gui, err = Uranium.LoadLibrary(Uranium.Config.Gui)
if not gui then
    Uranium.Notify("Uranium", (err or "GUI failed") .. " - using Vitality.", 7)
    gui = Uranium.LoadLibrary("vitality")
end
Uranium.Gui = gui
Uranium.Build()

task.delay(0.75, function()
    Uranium.AutoDetect()
end)

Uranium.Notify("Uranium", "Hub loaded - v" .. Uranium.Version, 4)
shared.Uranium = Uranium
getgenv().Uranium = Uranium

return Uranium