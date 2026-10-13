--=======================================================================
-- URANIUM HUB
-- Hub principal — todo bajo la marca Uranium
-- GUI: Vitality (default) o alternativas de uibin.orqan.xyz via Settings
-- Ejecutar: loadstring(game:HttpGet("<tu-repo>/Uranium.lua"))()
--=======================================================================

local Uranium = {}
Uranium.Name = "Uranium"
Uranium.Version = "1.0"
Uranium.Directory = "uranium"

-- configuración persistente
Uranium.Config = {
    Gui = "vitality",
    Bind = "RightShift",
}

local isfile = isfile or function(p)
    local s, r = pcall(readfile, p)
    return s and r ~= nil and r ~= ""
end
local cloneref = cloneref or function(r) return r end

if not isfolder(Uranium.Directory) then makefolder(Uranium.Directory) end

local function LoadConfig()
    if isfile(`{Uranium.Directory}/gui.txt`) then
        local s, r = pcall(readfile, `{Uranium.Directory}/gui.txt`)
        if s then Uranium.Config.Gui = r end
    end
    if isfile(`{Uranium.Directory}/bind.txt`) then
        local s, r = pcall(readfile, `{Uranium.Directory}/bind.txt`)
        if s and r ~= "" then Uranium.Config.Bind = r end
    end
end
LoadConfig()

--=======================================================================
-- GUI LIBRARIES disponibles
-- el hub intenta cargar la elegida; si falla, cae a Vitality
--=======================================================================
Uranium.Libraries = {
    vitality = {
        Name = "Vitality (default)",
        Url = "https://raw.githubusercontent.com/cueshut/vitremake/main/vitality.lua",
        -- adapter: devuelve {Window, Watermark, MakeSection...}
        Load = function(self)
            local Lib = loadstring(game:HttpGet(self.Url))()
            local Window = Lib:Window({ Name = "Uranium" })
            local Watermark = Lib.WatermarkObject or Lib:Watermark({ Name = "Uranium", SubName = "v" .. Uranium.Version })
            return {
                Library = Lib,
                Window = Window,
                Watermark = Watermark,
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
    },
    sussy = {
        Name = "Sussy (uibin)",
        Url = "https://uibin.orqan.xyz/sussy",
        Load = function(self)
            local Lib = loadstring(game:HttpGet(self.Url))()
            -- sussy usa interface similar a Vitality (fork)
            local Window = Lib:Window({ Name = "Uranium" })
            return {
                Library = Lib, Window = Window,
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
    },
    novus = {
        Name = "Novus (uibin)",
        Url = "https://uibin.orqan.xyz/novus",
        Load = function(self)
            local Lib = loadstring(game:HttpGet(self.Url))()
            local Window = Lib:Window({ Name = "Uranium" })
            return {
                Library = Lib, Window = Window,
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
    },
    legacy = {
        Name = "Legacy (uibin)",
        Url = "https://uibin.orqan.xyz/legacy",
        Load = function(self)
            local Lib = loadstring(game:HttpGet(self.Url))()
            local Window = Lib:Window({ Name = "Uranium" })
            return {
                Library = Lib, Window = Window,
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
    },
}

-- cargar GUI elegida con fallback a vitality
Uranium.Gui = nil
local LibraryKey = Uranium.Config.Gui
if Uranium.Libraries[LibraryKey] then
    local ok, result = pcall(Uranium.Libraries[LibraryKey].Load, Uranium.Libraries[LibraryKey])
    if ok and result then
        Uranium.Gui = result
    end
end
if not Uranium.Gui then
    Uranium.Config.Gui = "vitality"
    Uranium.Gui = Uranium.Libraries.vitality:Load()
end

local Gui = Uranium.Gui

--=======================================================================
-- SOURCES — los módulos deobfuscados van aquí
-- cada uno: Uranium.RegisterSource(nombre, placeIds, funcion)
-- la funcion recibe el Uranium y arma sus propias páginas
--=======================================================================
Uranium.Sources = {}

function Uranium.RegisterSource(Name, PlaceIds, Func)
    table.insert(Uranium.Sources, { Name = Name, PlaceIds = PlaceIds, Func = Func, Supported = false })
end

function Uranium.Notify(Title, Desc, Time)
    if Gui.Library and Gui.Library.Notification then
        Gui.Library:Notification({ Name = Title, Description = Desc, Time = Time or 5 })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = Title, Text = Desc or "", Duration = Time or 5 })
    end
end

--=======================================================================
-- PÁGINA SETTINGS (común a todos los juegos)
--=======================================================================
local SettingsPage = Gui.Page("Settings")
local SettingsSection = Gui.Section(SettingsPage, "GUI", 1)

Gui.Label(SettingsSection, "Cambiar la interfaz del hub.\nSe aplica al reiniciar el script.")

local GuiNames = {}
for key, lib in pairs(Uranium.Libraries) do
    table.insert(GuiNames, lib.Name)
end
table.sort(GuiNames)

local function KeyFromName(name)
    for k, l in pairs(Uranium.Libraries) do
        if l.Name == name then return k end
    end
end

Gui.Dropdown(SettingsSection, "Interfaz", GuiNames, Uranium.Libraries[Uranium.Config.Gui].Name, "uranium_gui_select", function(Value)
    local key = KeyFromName(Value)
    if key then
        writefile(`{Uranium.Directory}/gui.txt`, key)
        Uranium.Notify("Uranium", `GUI cambiada a {Value}.\nRe-ejecuta el script para aplicarla.`, 5)
    end
end)

Gui.Button(SettingsSection, "Re-Ejecutar Uranium", function()
    if queue_on_teleport then queue_on_teleport(`loadstring(readfile("{Uranium.Directory}/Uranium.lua"))()`) end
    if shared.UraniumReload and hookmetamethod then
        -- cheat-style: recargar via namecall no es seguro; usar getgenv flag
    end
    getgenv().UraniumReloading = true
    Uranium.Notify("Uranium", "Re-ejecuta el loader del hub para aplicar cambios.", 4)
end)

--=======================================================================
-- EJECUCIÓN DE SOURCES
--=======================================================================
local PlaceId = game.PlaceId
for _, Source in ipairs(Uranium.Sources) do
    if table.find(Source.PlaceIds, PlaceId) then
        Source.Supported = true
        local ok, err = pcall(Source.Func, Uranium)
        if not ok then
            warn(`[Uranium] source {Source.Name} failed: {err}`)
            Uranium.Notify("Uranium", `El módulo {Source.Name} falló al cargar.`, 8)
        end
    end
end

if not next(Uranium.Sources) then
    local MainPage = Gui.Page("Main")
    local Sec = Gui.Section(MainPage, "Uranium", 1)
    Gui.Label(Sec, "Uranium Hub v" .. Uranium.Version .. "\n\nNo hay módulos para este juego todavía.\nLos sources deobfuscados se registran aquí a medida que se consiguen.")
end

Uranium.Notify("Uranium", "Hub cargado. v" .. Uranium.Version, 4)
shared.Uranium = Uranium
getgenv().Uranium = Uranium

return Uranium