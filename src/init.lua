--!nocheck
-- init.lua modificado: descarga desde github.com/Korsac2026/12345 en vez de api.catvape.dev
-- Ejecutar con: loadstring(game:HttpGet('https://raw.githubusercontent.com/Korsac2026/12345/main/src/init.lua'))()

local RepoRaw = "https://raw.githubusercontent.com/Korsac2026/12345/main/src"

if shared.vapedeveloper ~= nil then
    shared.VapeDeveloper = shared.vapedeveloper
end
local Directory: string = shared.VapeDeveloper and "catprivate" or "catsix"

local Licence = { }
Licence.Key = script_key or "_key"

local cloneref:(<T>(T) -> T) | (<a>(a) -> a) = cloneref or function(Reference: any) return Reference end
local isfile: (string) -> boolean = isfile or function(File: string): boolean
    local Success: boolean, Result = pcall(function()
        return readfile(File)
    end)

    return Success and Result
end

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local EncodingService: EncodingService = cloneref(game:GetService("EncodingService"))

local function Fetch(Path: string): string
    return game:HttpGet(`{RepoRaw}/{Path}`, true)
end

local function DownloadAsset(RemotePath: string): ()
    local FilePath: string = `{Directory}/{RemotePath:gsub("^src/", "")}`
    local Success: boolean, Content: string = pcall(Fetch, RemotePath)
    if Success and Content ~= "404: Not Found" then
        if not isfile(FilePath) or readfile(FilePath) ~= Content then
            local Dir: string = FilePath:match(`^(.+)/[^/]+$`)
            if Dir and not isfolder(Dir) then
                makefolder(Dir)
            end
            writefile(FilePath, Content)
        end
    else
        warn(`[init] failed to download {RemotePath}`)
    end
end

local AssetList: {string} = {
    "main.lua",
    "features.json",
    "packages.json",
    "guis/new.lua",
    "games/universal.lua",
    "libraries/assistant.lua",
    "libraries/cheatengine.lua",
    "libraries/communication.lua",
    "libraries/drawing.lua",
    "libraries/entity.lua",
    "libraries/hash.lua",
    "libraries/main.lua",
    "libraries/navigation.lua",
    "libraries/prediction.lua",
    "libraries/render.lua",
    "libraries/replayvisuals.lua",
    "libraries/swordtiming.lua",
    "libraries/vm.lua",
    "assets/new/bahnschrift.json",
    "assets/new/bahnschrift.ttf",
    "assets/new/proxima.json",
    "assets/new/proxima.ttf",
    "assets/new/proximabd.ttf"
}

local GameFile: string = `games/{game.PlaceId}.lua`
pcall(Fetch, GameFile)
if pcall(function() return Fetch(GameFile) end) then
    table.insert(AssetList, GameFile)
end

for _, Folder: string in {Directory, `{Directory}/games`, `{Directory}/profiles`, `{Directory}/assets`, `{Directory}/libraries`, `{Directory}/guis`} do
    if not isfolder(Folder) then
        makefolder(Folder)
    end
end

for _, AssetPath: string in AssetList do
    task.spawn(DownloadAsset, AssetPath)
end
-- esperar descargas esenciales antes de correr
repeat task.wait() until isfile(`{Directory}/main.lua`) and isfile(`{Directory}/guis/new.lua`) and isfile(`{Directory}/libraries/main.lua`)

return loadstring(readfile(`{Directory}/main.lua`), 'main')(Licence)