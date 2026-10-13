-- Uranium Blox Fruits
-- Source: QuantumOnyx BloxFruits, Luraph v15 deobfuscado (746 funciones)
-- Este archivo se integra al hub via Uranium.RegisterSource
-- La versión deobfuscada completa vive en el repo como src/uranium/dumps/bloxfruits_deob.lua

local PlaceIds = { 2753915549, 4442272183, 7449423635 } -- Blox Fruits: primer mar, segundo mar, tercer mar

local function Source(Uranium)
    local Gui = Uranium.Gui
    local Page = Gui.Page("Blox Fruits")
    local Sec = Gui.Section(Page, "Uranium Blox Fruits", 1)

    Gui.Label(Sec, "El script completo deobfuscado (417KB, 746 funciones)\nse carga bajo demanda desde el repo.")
    Gui.Label(Sec, "Auto team, auto attack, fast attack, bring monster,\nattack mobs, y toda la tabla de configuración editable.")

    local Config = {
        Team = "Pirates",
        AutoAttack = true,
        FastAttackDelay = 0,
        AttackMobs = true,
        BringMonster = true,
        BringMonsterRadius = 250,
    }

    Gui.Dropdown(Sec, "Team", { "Pirates", "Marines" }, Config.Team, "uranium_bf_team", function(v)
        getgenv().Team = v
    end)

    Gui.Toggle(Sec, "Auto Attack", Config.AutoAttack, "uranium_bf_autoattack", function(v)
        getgenv().UraniumBF_AutoAttack = v
    end)

    Gui.Slider(Sec, "Fast Attack Delay", 0, 2, Config.FastAttackDelay, "uranium_bf_delay", function(v)
        getgenv().UraniumBF_Delay = v
    end)

    Gui.Toggle(Sec, "Attack Mobs", Config.AttackMobs, "uranium_bf_mobs", function(v)
        getgenv().UraniumBF_Mobs = v
    end)

    Gui.Toggle(Sec, "Bring Monster", Config.BringMonster, "uranium_bf_bring", function(v)
        getgenv().UraniumBF_Bring = v
    end)

    Gui.Slider(Sec, "Bring Radius", 50, 1000, Config.BringMonsterRadius, "uranium_bf_radius", function(v)
        getgenv().UraniumBF_Radius = v
    end)

    local Sec2 = Gui.Section(Page, "Cargar Script", 2)
    Gui.Button(Sec2, "Ejecutar Blox Fruits Completo", function()
        Uranium.Notify("Uranium", "Cargando Blox Fruits deobfuscado...", 3)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Korsac2026/12345/main/src/uranium/dumps/bloxfruits_deob.lua"))()
    end)
    Gui.Button(Sec2, "Cargar desde disco (local)", function()
        if isfile("uranium/dumps/bloxfruits_deob.lua") then
            loadstring(readfile("uranium/dumps/bloxfruits_deob.lua"))()
        else
            Uranium.Notify("Uranium", "No está en disco. Usa el botón de arriba primero.", 5)
        end
    end)
end

return { PlaceIds = PlaceIds, Source = Source }