--=======================================================================
-- URANIUM HUB v2.0
-- - auto-detección de juegos soportados por PlaceId
-- - popup de confirmación: "¿Ejecutar X?" con Sí / No / Siempre
-- - cambios de GUI (vitality/sussy/novus/legacy) con preview y rebuild
-- - ejecución desde repo o disco, con descarga cacheada
-- Ejecutar: loadstring(game:HttpGet("https://raw.githubusercontent.com/Korsac2026/12345/main/Uranium.lua"))()
--=======================================================================

local Uranium = {}
Uranium.Name = "Uranium"
Uranium.Version = "2.0"
Uranium.Directory = "uranium"
Uranium.Sources = {}
Uranium.AutoDetected = false

local REPO = "https://raw.githubusercontent.com/Korsac2026/12345/main"

local isfile = isfile or function(p)
    local s, r = pcall(readfile, p)
    return s and r ~= nil and r ~= ""
end

if not isfolder(Uranium.Directory) then makefolder(Uranium.Directory) end
if not isfolder(Uranium.Directory .. "/dumps") then makefolder(Uranium.Directory .. "/dumps") end

local function LoadConfig()
    Uranium.Config = { Gui = "vitality" }
    if isfile(Uranium.Directory .. "/gui.txt") then
        local s, r = pcall(readfile, Uranium.Directory .. "/gui.txt")
        if s and r ~= "" then Uranium.Config.Gui = r end
    end
end
LoadConfig()

-- respuestas "siempre" del usuario: archivo placeId=yes|no
local function LoadAnswers()
    Uranium.Answers = {}
    if isfile(Uranium.Directory .. "/answers.txt") then
        local s, r = pcall(readfile, Uranium.Directory .. "/answers.txt")
        if s and r then
            for line in r:gmatch("[^\r\n]+") do
                local id, ans = line:match("^(%d+)=(%a+)$")
                if id and ans then Uranium.Answers[tonumber(id)] = ans end
            end
        end
    end
end
LoadAnswers()

local function SaveAnswer(placeId, answer)
    Uranium.Answers[placeId] = answer
    local out = {}
    for id, ans in pairs(Uranium.Answers) do
        table.insert(out, tostring(id) .. "=" .. ans)
    end
    table.sort(out)
    writefile(Uranium.Directory .. "/answers.txt", table.concat(out, "\n"))
end

--=======================================================================
-- LIBRARIES
--=======================================================================
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
        return nil, lib.Name .. " no cargó (URL caída o bloqueada)"
    end
    local okw, Window = pcall(function()
        return Lib:Window({ Name = "Uranium" })
    end)
    if not okw or not Window then
        return nil, lib.Name .. " no creó ventana (API incompatible)"
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

--=======================================================================
-- POPUP DE CONFIRMACIÓN (auto-detección)
-- estilizado con los colores de la GUI activa
--=======================================================================
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

    -- dim background
    local Dim = Instance.new("Frame")
    Dim.Size = UDim2.new(1, 0, 1, 0)
    Dim.BackgroundColor3 = Color3.new(0, 0, 0)
    Dim.BackgroundTransparency = 0.4
    Dim.BorderSizePixel = 0
    Dim.Parent = SG

    local Frame = Instance.new("Frame")
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.Size = UDim2.new(0, 340, 0, 220)
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
    Desc.Size = UDim2.new(1, -32, 0, 60)
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
        b.Position = UDim2.new(0, x, 1, -56)
        b.Size = UDim2.new(0, w, 0, 40)
        b.BackgroundColor3 = color
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.Text = text
        b.TextSize = 13
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Parent = Frame
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = b
        b.MouseButton1Click:Connect(function()
            SG:Destroy()
            if cb then cb() end
        end)
        return b
    end

    local darkBg = lib.Bg:Lerp(Color3.new(0, 0, 0), 0.45)

    mkBtn("Ejecutar", 16, 150, lib.Accent, function() callback("yes") end)
    mkBtn("No", 174, 70, darkBg, function() callback("no") end)
    mkBtn("Siempre", 250, 74, lib.Accent:Lerp(Color3.new(1,1,1), 0.25), function() callback("always") end)

    local Hint = Instance.new("TextLabel")
    Hint.BackgroundTransparency = 1
    Hint.Position = UDim2.new(0, 16, 1, -30)
    Hint.Size = UDim2.new(1, -32, 0, 22)
    Hint.Font = Enum.Font.Gotham
    Hint.Text = "Siempre = no volver a preguntar en este juego"
    Hint.TextColor3 = Color3.fromRGB(140, 140, 150)
    Hint.TextSize = 10
    Hint.TextXAlignment = Enum.TextXAlignment.Left
    Hint.Parent = Frame

    -- auto-cerrar en 25s como "no"
    task.delay(25, function()
        if SG and SG.Parent then
            SG:Destroy()
            callback("no")
        end
    end)
end

--=======================================================================
-- PREVIEW de estilos
--=======================================================================
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
    Title.Text = lib.Name .. " — Uranium"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    tog.TextColor3 = Color3.fromRGB(255, 255, 255)
    tog.Parent = Frame
    local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 6) c2.Parent = tog
    local on = true
    tog.MouseButton1Click:Connect(function()
        on = not on
        tog.BackgroundColor3 = on and lib.Accent or lib.Bg:Lerp(Color3.new(0,0,0), 0.3)
    end)

    local slid = Instance.new("Frame")
    slid.Position = UDim2.new(0, 12, 0, 82)
    slid.Size = UDim2.new(1, -24, 0, 20)
    slid.BackgroundColor3 = lib.Bg:Lerp(Color3.new(0,0,0), 0.4)
    slid.BorderSizePixel = 0
    slid.Parent = Frame
    local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 6) c3.Parent = slid
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.55, 0, 1, 0)
    fill.BackgroundColor3 = lib.Accent
    fill.BorderSizePixel = 0
    fill.Parent = slid
    local c4 = Instance.new("UICorner") c4.CornerRadius = UDim.new(0, 6) c4.Parent = fill
    local sTxt = Instance.new("TextLabel")
    sTxt.BackgroundTransparency = 1
    sTxt.Size = UDim2.new(1, 0, 1, 0)
    sTxt.Font = Enum.Font.Gotham
    sTxt.TextSize = 11
    sTxt.Text = "  Bring Radius: 550 studs"
    sTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    sTxt.TextXAlignment = Enum.TextXAlignment.Left
    sTxt.Parent = slid

    local apply = Instance.new("TextButton")
    apply.Position = UDim2.new(0, 12, 0, 112)
    apply.Size = UDim2.new(0.5, -15, 0, 26)
    apply.BackgroundColor3 = lib.Accent
    apply.BorderSizePixel = 0
    apply.Font = Enum.Font.GothamBold
    apply.Text = "Aplicar"
    apply.TextSize = 12
    apply.TextColor3 = Color3.fromRGB(255, 255, 255)
    apply.Parent = Frame
    local c5 = Instance.new("UICorner") c5.CornerRadius = UDim.new(0, 6) c5.Parent = apply
    apply.MouseButton1Click:Connect(function()
        SG:Destroy()
        Uranium.SetGui(key)
    end)

    local close = Instance.new("TextButton")
    close.Position = UDim2.new(0.5, 3, 0, 112)
    close.Size = UDim2.new(0.5, -15, 0, 26)
    close.BackgroundColor3 = lib.Bg:Lerp(Color3.new(0,0,0), 0.5)
    close.BorderSizePixel = 0
    close.Font = Enum.Font.GothamBold
    close.Text = "Cerrar"
    close.TextSize = 12
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Parent = Frame
    local c6 = Instance.new("UICorner") c6.CornerRadius = UDim.new(0, 6) c6.Parent = close
    close.MouseButton1Click:Connect(function() SG:Destroy() end)

    local note = Instance.new("TextLabel")
    note.BackgroundTransparency = 1
    note.Position = UDim2.new(0, 12, 0, 144)
    note.Size = UDim2.new(1, -24, 0, 28)
    note.Font = Enum.Font.Gotham
    note.TextSize = 10
    note.Text = "Preview del estilo " .. lib.Name .. ".\nAplicar reconstruye el hub con esta interfaz."
    note.TextColor3 = Color3.fromRGB(180, 180, 190)
    note.TextWrapped = true
    note.Parent = Frame

    task.delay(30, function()
        if SG and SG.Parent then SG:Destroy() end
    end)
end

--=======================================================================
-- REGISTRO DE SOURCES
--=======================================================================
function Uranium.RegisterSource(Name, PlaceIds, Func)
    table.insert(Uranium.Sources, { Name = Name, PlaceIds = PlaceIds, Func = Func })
end

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

--=======================================================================
-- AUTO-DETECCIÓN
--=======================================================================
function Uranium.GetSupported(placeId)
    local found = {}
    for _, Source in ipairs(Uranium.Sources) do
        if table.find(Source.PlaceIds, placeId) then
            table.insert(found, Source)
        end
    end
    return found
end

function Uranium.RunSource(Source)
    local ok, err = pcall(Source.Func, Uranium)
    if not ok then
        warn("[Uranium] source " .. Source.Name .. " failed: " .. tostring(err))
        Uranium.Notify("Uranium", "Error en " .. Source.Name .. ": " .. tostring(err), 7)
    else
        Uranium.AutoDetected = true
    end
end

function Uranium.AutoDetect()
    local placeId = game.PlaceId
    local supported = Uranium.GetSupported(placeId)

    if #supported == 0 then
        Uranium.Notify("Uranium", "Juego no soportado aún.\nHub cargado en modo universal.", 6)
        return
    end

    -- si el usuario ya respondió "always" o "no" para este placeId, respetar
    local saved = Uranium.Answers[placeId]
    if saved == "yes" or saved == "always" then
        for _, Source in ipairs(supported) do
            Uranium.RunSource(Source)
        end
        Uranium.Notify("Uranium", "Auto-ejecutando " .. supported[1].Name .. " (recordado).", 4)
        return
    elseif saved == "no" then
        Uranium.Notify("Uranium", "Marcaste No para este juego. Puedes ejecutarlo manualmente en su página.", 5)
        -- igual construir la página para que pueda ejecutarlo manual
        for _, Source in ipairs(supported) do
            Uranium.RunSource(Source)
        end
        return
    end

    -- preguntar
    local names = {}
    for _, s in ipairs(supported) do table.insert(names, s.Name) end
    Uranium.ConfirmPopup(
        "Juego detectado",
        "Este juego tiene soporte en Uranium:\n" .. table.concat(names, ", ") .. "\n\n¿Quieres ejecutar el script?",
        function(answer)
            if answer == "always" then
                SaveAnswer(placeId, "always")
            elseif answer == "no" then
                SaveAnswer(placeId, "no")
            end
            if answer == "yes" or answer == "always" then
                for _, Source in ipairs(supported) do
                    Uranium.RunSource(Source)
                end
                Uranium.Notify("Uranium", "Ejecutando " .. table.concat(names, ", ") .. ".", 4)
            else
                Uranium.Notify("Uranium", "No ejecutado. Disponible manualmente en su página.", 5)
                -- construir páginas manualmente igual para acceso posterior
                for _, Source in ipairs(supported) do
                    Uranium.RunSource(Source)
                end
            end
        end
    )
end

--=======================================================================
-- CONSTRUCCIÓN DEL HUB (reconstruible en runtime)
--=======================================================================
local Building = false

function Uranium.SetGui(key)
    if Building then return end
    if not Uranium.Libraries[key] then return end
    Building = true

    writefile(Uranium.Directory .. "/gui.txt", key)
    Uranium.Config.Gui = key

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
        Uranium.Notify("Uranium", tostring(err) .. ".\nVolviendo a Vitality.", 7)
        writefile(Uranium.Directory .. "/gui.txt", "vitality")
        gui = Uranium.LoadLibrary("vitality")
        if not gui then return end
    end

    Uranium.Gui = gui
    Building = false
    Uranium.Build()
    Uranium.Notify("Uranium", "Interfaz aplicada: " .. Uranium.Libraries[key].Name, 4)
end

function Uranium.Build()
    local Gui = Uranium.Gui
    if not Gui then return end

    -- SETTINGS (siempre presentes)
    local SettingsPage = Gui.Page("Settings")
    local Sec = Gui.Section(SettingsPage, "Interfaz", 1)

    Gui.Label(Sec, "Estilos disponibles. Preview muestra cómo se ve antes de aplicar.")

    local names, keyOf = {}, {}
    for k, l in pairs(Uranium.Libraries) do
        table.insert(names, l.Name)
        keyOf[l.Name] = k
    end
    table.sort(names)

    local current = Uranium.Libraries[Uranium.Config.Gui] and Uranium.Libraries[Uranium.Config.Gui].Name or "Vitality"

    Gui.Dropdown(Sec, "Estilo actual", names, current, "uranium_style", function(v)
        -- solo informativo; aplicar es con preview o botón
    end)

    for _, name in ipairs(names) do
        local k = keyOf[name]
        Gui.Button(Sec, "Preview: " .. name, function()
            Uranium.PreviewGui(k)
        end)
    end

    local SecD = Gui.Section(SettingsPage, "Detección", 1)
    Gui.Button(SecD, "Re-detectar juego actual", function()
        Uranium.AutoDetect()
    end)
    Gui.Button(SecD, "Resetear respuestas guardadas", function()
        Uranium.Answers = {}
        if isfile(Uranium.Directory .. "/answers.txt") then
            delfile(Uranium.Directory .. "/answers.txt")
        end
        Uranium.Notify("Uranium", "Respuestas reseteadas. Se volverá a preguntar.", 4)
    end)

    local SecR = Gui.Section(SettingsPage, "Uranium", 2)
    Gui.Label(SecR, "Uranium Hub v" .. Uranium.Version .. "\nRepo: Korsac2026/12345\nAuto-detección activa.")
    Gui.Button(SecR, "Recargar Hub (misma GUI)", function()
        Uranium.Notify("Uranium", "Reconstruyendo...", 3)
        Uranium.SetGui(Uranium.Config.Gui)
    end)

    -- SOURCES: construir páginas para todos los juegos soportados del actual
    local PlaceId = game.PlaceId
    local supported = Uranium.GetSupported(PlaceId)
    local any = false
    for _, Source in ipairs(supported) do
        any = true
        -- solo ejecutar automáticamente si ya fue auto-detectado antes;
        -- si no, la página se construye igual para acceso manual
        if Uranium.AutoDetected then
            -- ya corrió, no duplicar
        else
            -- Build se llama antes de AutoDetect en el arranque,
            -- así que aquí solo construimos la página (la ejecución
            -- del Func construye la página, se llama una sola vez)
        end
        local ok, err = pcall(Source.Func, Uranium)
        if not ok then
            warn("[Uranium] source " .. Source.Name .. " failed: " .. tostring(err))
        end
    end

    -- siempre mostrar lista de juegos soportados en el hub
    if not any then
        local MainPage = Gui.Page("Main")
        local MSec = Gui.Section(MainPage, "Uranium", 1)
        Gui.Label(MSec, "Uranium Hub v" .. Uranium.Version .. "\n\nEste juego no tiene módulos aún.\nSoportados:\n- Blox Fruits\n- Operation One\n\nConsigue más sources y se agregan.")
    end
end

--=======================================================================
-- SOURCES REGISTRADOS
--=======================================================================

-- Blox Fruits
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
    Gui.Toggle(Sec, "Bring Monster", true, "uranium_bf_bring", function(v)
        getgenv().UraniumBF_Bring = v
    end)
    Gui.Slider(Sec, "Bring Radius", 50, 1000, 250, "uranium_bf_radius", function(v)
        getgenv().UraniumBF_Radius = v
    end)

    local Sec2 = Gui.Section(Page, "Script Completo", 2)
    Gui.Button(Sec2, "Cargar desde Repo", function()
        local url = REPO .. "/src/uranium/dumps/bloxfruits_deob.lua"
        local ok, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if ok then
            Uranium.Notify("Uranium", "Blox Fruits deobfuscado cargado.", 4)
        else
            Uranium.Notify("Uranium", "Error cargando: " .. tostring(err), 7)
        end
    end)
    Gui.Button(Sec2, "Cargar desde Disco", function()
        if isfile("uranium/dumps/bloxfruits_deob.lua") then
            local ok, err = pcall(function()
                loadstring(readfile("uranium/dumps/bloxfruits_deob.lua"))()
            end)
            if ok then
                Uranium.Notify("Uranium", "Cargado desde disco.", 4)
            else
                Uranium.Notify("Uranium", "Error: " .. tostring(err), 7)
            end
        else
            Uranium.Notify("Uranium", "No está en disco.\nPrimero baja el archivo (botón de la izquierda o desde el repo).", 6)
        end
    end)
    Gui.Button(Sec2, "Descargar a Disco", function()
        local url = REPO .. "/src/uranium/dumps/bloxfruits_deob.lua"
        local ok, res = pcall(function()
            return game:HttpGet(url, true)
        end)
        if ok and res and #res > 1000 then
            writefile("uranium/dumps/bloxfruits_deob.lua", res)
            Uranium.Notify("Uranium", "Descargado a uranium/dumps/ (" .. #res .. " bytes).", 5)
        else
            Uranium.Notify("Uranium", "Descarga fallida.", 5)
        end
    end)
end)

-- Operation One (Astro)
Uranium.RegisterSource("Uranium Operation One", { 253832, 6229116934 }, function(Uranium)
    local Gui = Uranium.Gui
    local Page = Gui.Page("Operation One")
    local Sec = Gui.Section(Page, "Uranium Operation One", 1)

    Gui.Label(Sec, "Payload dumpeado del loader de Operation One (Astro).\nSin key system, sin anti-tamper, sin rejoin kick.\nEl script original corre completo con su propia GUI (Obsidian).")

    local Sec2 = Gui.Section(Page, "Cargar", 2)
    Gui.Button(Sec2, "Ejecutar desde Repo", function()
        local url = REPO .. "/src/uranium/dumps/operationone_dump.lua"
        local ok, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if ok then
            Uranium.Notify("Uranium", "Operation One cargado.", 4)
        else
            Uranium.Notify("Uranium", "Error: " .. tostring(err), 7)
        end
    end)
    Gui.Button(Sec2, "Descargar a Disco", function()
        local url = REPO .. "/src/uranium/dumps/operationone_dump.lua"
        local ok, res = pcall(function()
            return game:HttpGet(url, true)
        end)
        if ok and res and #res > 10000 then
            writefile("uranium/dumps/operationone_dump.lua", res)
            Uranium.Notify("Uranium", "Guardado a disco (" .. #res .. " bytes).", 5)
        else
            Uranium.Notify("Uranium", "Descarga fallida.", 5)
        end
    end)
    Gui.Button(Sec2, "Ejecutar desde Disco", function()
        if isfile("uranium/dumps/operationone_dump.lua") then
            local ok, err = pcall(function()
                loadstring(readfile("uranium/dumps/operationone_dump.lua"))()
            end)
            if ok then
                Uranium.Notify("Uranium", "Cargado desde disco.", 4)
            else
                Uranium.Notify("Uranium", "Error: " .. tostring(err), 7)
            end
        else
            Uranium.Notify("Uranium", "No está en disco todavía.", 5)
        end
    end)
end)

--=======================================================================
-- ARRANQUE
--=======================================================================
local gui, err = Uranium.LoadLibrary(Uranium.Config.Gui)
if not gui then
    Uranium.Notify("Uranium", (err or "GUI falló") .. " — usando Vitality.", 7)
    gui = Uranium.LoadLibrary("vitality")
end
Uranium.Gui = gui
Uranium.Build()

-- auto-detección tras construir el hub
task.delay(0.5, function()
    Uranium.AutoDetect()
end)

Uranium.Notify("Uranium", "Hub cargado — v" .. Uranium.Version, 4)
shared.Uranium = Uranium
getgenv().Uranium = Uranium

return Uranium