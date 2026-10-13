local Interface = ...
local cloneref = cloneref or function(Reference: Instance)
    return Reference
end
local isfile = isfile or function(FilePath: string)
    local Success, Data = pcall(function()
        return readfile(FilePath)
    end)

    return Success and Data ~= nil and Data ~= ""
end
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local vape = Interface.vape
local AddBlur = Interface.AddBlur
local AddCorner = Interface.AddCorner
local AddDragHandler = Interface.AddDragHandler
local AddTooltip = Interface.AddTooltip
local ClickGUI: Frame = Interface.ClickGUI
local Color = Interface.Color
local GetFeatureTag = Interface.GetFeatureTag
local GetFontBounds = Interface.GetFontBounds
local GetTableSize = Interface.GetTableSize
local GetVapeAsset = Interface.GetVapeAsset
local GUI: ScreenGui = Interface.GUI
local IsRendered = Interface.IsRendered
local LoadJSON = Interface.LoadJSON
local RemoveTags = Interface.RemoveTags
local Scale: UIScale = Interface.Scale
local StageWindow = Interface.StageWindow
local Tween = Interface.Tween
local UIPallet = Interface.UIPallet
local WriteJSON = Interface.WriteJSON

;(function()
    local Assistant
    local AssistantName: string = "shaders v3"
    local AssistantTitle: string = "AI Assistant"
    local Window: TextButton
    local Chat: ScrollingFrame
    local ChatList: UIListLayout
    local InputBox: TextBox
    local Index
    local LastTopic: string?
    local Send
    local Brain
    local History
    local Places
    local HighlightFrame: Frame?
    local HighlightConnection: RBXScriptConnection?
    local HighlightToken: number = 0
    local MessageCount: number = 0
    local Rows: {Frame} = {}
    local KeyNames: {[string]: string} = {}
    local Players: Players = cloneref(game:GetService("Players"))
    local ChatWidth: number = 450
    local LabelWidth: number = ChatWidth - 40
    local UserWidth: number = 300
    local MaxMessages: number = 60
    local Stopwords: {[string]: boolean} = {}
    local Synonyms: {[string]: {string}} = {}
    local IntentTerms: {[string]: number} = {}
    local GuideFrequency: {[string]: number} = {}
    local FactFrequency: {[string]: number} = {}
    local Aliases: {[string]: string} = {
        aa = "AimAssist",
        ab = "AutoBuy",
        aura = "Killaura",
        aw = "AutoWin",
        hb = "HitBoxes",
        hj = "HighJump",
        ij = "InfiniteJump",
        inffly = "InfiniteFly",
        infjump = "InfiniteJump",
        ka = "Killaura",
        lj = "LongJump",
        namehider = "NickHider",
        nametag = "NameTags",
        nf = "NoFall",
        nuke = "Nuker",
        scaf = "Scaffold",
        scaff = "Scaffold",
        spd = "Speed",
        tracer = "Tracers",
        velo = "Velocity"
    }
    local GameIds: {[string]: {number}} = {
        BedWars = {2619619496},
        IllegalSoccer = {126987974021910},
        TowerOfHell = {703124385}
    }
    local Kinds: {[string]: string} = {
        Bind = "keybind",
        Button = "button",
        ColorSlider = "color picker",
        Font = "font picker",
        Targets = "target picker",
        TextBox = "text box",
        TextList = "list",
        Toggle = "toggle"
    }
    local SynonymList: {[string]: string} = {
        afk = "idle kick",
        aimbot = "aim lock",
        aimlock = "aim lock",
        bright = "fullbright brightness",
        click = "clicker cps",
        clip = "phase",
        colour = "color",
        config = "profile",
        cps = "clicker click",
        customise = "customize",
        dark = "fullbright brightness",
        enemy = "player target",
        enemies = "player target",
        fall = "nofall",
        fast = "speed",
        faster = "speed fast",
        quicker = "speed fast",
        pot = "potion buff",
        pots = "potion buff",
        favourite = "favorite",
        fight = "attack aura",
        hit = "attack",
        hitbox = "reach range",
        hotkey = "bind",
        hud = "overlay",
        idle = "afk",
        inv = "inventory",
        invis = "invisible",
        keybind = "bind",
        kill = "attack aura",
        knock = "knockback",
        knocked = "knockback",
        lag = "fps",
        lagged = "lagback",
        move = "movement",
        movement = "move",
        noclip = "phase",
        skip = "dodge leave avoid",
        pixelated = "blurry blur texture textures quality",
        res = "texture textures quality",
        pinged = "notify notification alert alarm",
        notified = "notify notification alert alarm",
        yt = "record recording",
        less = "reduce reduces lower",
        people = "player",
        preset = "profile",
        quick = "speed",
        reach = "range hitbox",
        see = "esp render",
        spam = "spammer",
        teleport = "tp",
        tp = "teleport",
        wall = "esp chams xray",
        zoom = "fov"
    }
    local Pronouns: {string} = {"it", "its", "this", "that", "them", "they"}
    local AskWords: {string} = {"how", "what", "whats", "why", "when", "which", "should", "does", "if", "is"}
    local BindWords: {string} = {"bind", "binds", "bound", "keybind", "keybinds", "hotkey", "hotkeys", "key", "keys", "shortcut", "binding", "unbind", "rebind"}
    local FavoriteWords: {string} = {"favorite", "favourite", "favorites", "favourites", "favorited", "unfavorite", "star"}
    local HideWords: {string} = {"hide", "hidden", "unhide", "hiding"}
    local WhereWords: {string} = {"where", "find", "locate", "located", "category", "window"}
    local SettingWords: {string} = {"setting", "settings", "option", "options", "config", "configure", "customize", "customise"}
    local TargetWords: {string} = {"target", "targets", "targeting", "npc", "npcs", "mob", "mobs", "player", "players", "invisible", "wall", "walls", "priority"}
    local CompareWords: {string} = {"difference", "different", "compare", "vs", "versus", "better", "or"}
    local ListWords: {string} = {"list", "modules", "module", "mods", "in", "all"}
    local PoliteStarts: {string} = {"can you ", "could you ", "can u ", "could u ", "can ya ", "would you ", "would u ", "will you ", "will u ", "please ", "pls ", "plz ", "i want you to ", "i need you to ", "i need to ", "i want to "}
    local KeyAliases: {[string]: string} = {
        ["0"] = "Zero",
        ["1"] = "One",
        ["2"] = "Two",
        ["3"] = "Three",
        ["4"] = "Four",
        ["5"] = "Five",
        ["6"] = "Six",
        ["7"] = "Seven",
        ["8"] = "Eight",
        ["9"] = "Nine",
        alt = "LeftAlt",
        caps = "CapsLock",
        control = "LeftControl",
        ctrl = "LeftControl",
        del = "Delete",
        enter = "Return",
        esc = "Escape",
        lalt = "LeftAlt",
        lctrl = "LeftControl",
        lshift = "LeftShift",
        ralt = "RightAlt",
        rctrl = "RightControl",
        rshift = "RightShift",
        shift = "LeftShift"
    }
    local SwitchValues: {[string]: boolean} = {
        ["0"] = false,
        ["1"] = true,
        ["false"] = false,
        ["true"] = true,
        disable = false,
        disabled = false,
        enable = true,
        enabled = true,
        no = false,
        off = false,
        on = true,
        yes = true
    }
    local ColorNames: {[string]: {number}} = {
        black = {0, 0, 0},
        blue = {0.62, 1, 1},
        cyan = {0.5, 1, 1},
        gray = {0, 0, 0.5},
        green = {0.33, 1, 1},
        grey = {0, 0, 0.5},
        lime = {0.25, 1, 1},
        orange = {0.08, 1, 1},
        pink = {0.9, 0.55, 1},
        purple = {0.78, 1, 1},
        red = {0, 1, 1},
        white = {0, 0, 1},
        yellow = {0.16, 1, 1}
    }
    local ListButtons: {[string]: {string}} = {
        Profiles = {"Sync to current profile", "Reset current profile", "Export config"}
    }
    local PaneButtons: {[string]: {string}} = {
        General = {"Self destruct", "Reinject"},
        GUI = {"Reset GUI positions", "Sort GUI"}
    }

    for Word: string in ("a an the is are was were be been being am i im ive me my mine you your youre u ur we our it its this that these those do does did doing done to of in on at by for from with and or but if so as than then there here what whats which who whom where wheres when why how can could should would will shall may might must get got gets make makes please pls plz just really very some any much many more most want wanna need know tell explain about into out up down use using used work works working Uranium vape cat module modules thing things something anything stuff way able let lets go also like still show shows not no dont doesnt isnt cant wont"):gmatch("%S+") do
        Stopwords[Word] = true
    end

    local function Normalize(Text: string): string
        return (Text:lower():gsub("\u{2019}", ""):gsub("'", ""):gsub("[^%w]+", " "):match("^%s*(.-)%s*$"))
    end

    local function Stem(Word: string): string
        if #Word > 3 and Word:sub(-1) == "s" and Word:sub(-2) ~= "ss" then
            Word = Word:sub(1, -2)
        end

        if #Word > 5 and Word:sub(-3) == "ing" then
            Word = Word:sub(1, -4)
        elseif #Word > 4 and Word:sub(-2) == "ed" and Word:sub(-3) ~= "eed" then
            Word = Word:sub(1, -3)
        end

        if #Word > 3 and Word:sub(-1) == "e" then
            Word = Word:sub(1, -2)
        end

        return Word
    end

    local function Escape(Text: string): string
        return (Text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
    end

    local function Plain(Text: string?): string
        return Text and (RemoveTags(Text):gsub("\n(%l)", " %1")) or ""
    end

    local function Accent(Text: string): string
        local Tint: Color3 = Color3.fromHSV(vape.GUIColor.Hue, math.min(vape.GUIColor.Sat, 0.7), math.max(vape.GUIColor.Value, 0.85))
        return `<font color="#{Tint:ToHex()}">{Text}</font>`
    end

    local function FirstSentence(Text: string): string
        local Line: string = Text:match("^[^\n]*")
        local Sentence: string = Line:match("^(.-[%.!?])%s") or Line
        return #Sentence > 110 and `{Sentence:sub(1, 107)}...` or Sentence
    end

    local function JoinNames(Names: {string}, Limit: number): string
        if #Names > Limit then
            return `{table.concat(Names, ", ", 1, Limit)} and {#Names - Limit} more`
        elseif #Names > 1 then
            return `{table.concat(Names, ", ", 1, #Names - 1)} and {Names[#Names]}`
        end

        return Names[1] or ""
    end

    local function FormatNumber(Value: any): string
        return typeof(Value) == "number" and tostring(math.round(Value * 100) / 100) or tostring(Value)
    end

    local function GetKeys(Keys: {string}?): string?
        return Keys and #Keys > 0 and table.concat(Keys, " + ") or nil
    end

    local function IsMobile(): boolean
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end

    local function HasAny(Has: {[string]: boolean}, List: {string}): boolean
        for _, Word: string in List do
            if Has[Word] then
                return true
            end
        end

        return false
    end

    local function Distance(First: string, Second: string): number
        local Previous: {number} = {}
        local Current: {number} = {}
        for j: number = 0, #Second do
            Previous[j] = j
        end

        for i: number = 1, #First do
            Current[0] = i
            local Byte: number = First:byte(i)
            for j: number = 1, #Second do
                Current[j] = math.min(Previous[j] + 1, Current[j - 1] + 1, Previous[j - 1] + (Byte == Second:byte(j) and 0 or 1))
            end
            Previous, Current = Current, Previous
        end

        return Previous[#Second]
    end

    local function Compact(Text: string): string
        return (Text:lower():gsub("[^%w]", ""))
    end

    local function SplitName(Name: string): string
        return (Name:gsub("(%l)(%u)", "%1 %2"):gsub("(%u)(%u%l)", "%1 %2"))
    end

    local function AddTerms(Terms: {[string]: number}, Text: string?, Weight: number)
        if not Text then return end

        for Word: string in Normalize(Text):gmatch("%S+") do
            if not Stopwords[Word] then
                local Term: string = Stem(Word)
                Terms[Term] = math.max(Terms[Term] or 0, Weight)
            end
        end
    end

    for Word: string, List: string in SynonymList do
        local Terms: {[string]: number} = {}
        AddTerms(Terms, List, 1)

        local Key: string = Stem(Word)
        Synonyms[Key] = Synonyms[Key] or {}
        for Term: string in Terms do
            table.insert(Synonyms[Key], Term)
        end
    end

    AddTerms(IntentTerms, "setting settings option options config configure customize customise change set adjust tweak value mean means bind keybind hotkey shortcut key favorite favourite star hide hidden unhide where find locate located category window open turn enable disable toggle off good best recommend error broken bug crash", 1)

    local function GetOptions(Module): {any}
        local List = {}

        if Module.OptionSpecs then
            for _, Spec: any in Module.OptionSpecs do
                local Settings = Spec.Settings
                if Spec.Type == "Targets" then
                    table.insert(List, {
                        Name = "Target",
                        Option = Module.Options.Targets,
                        Settings = Settings,
                        Type = Spec.Type
                    })
                elseif typeof(Settings.Name) == "string" and Spec.Type ~= "Divider" then
                    table.insert(List, {
                        Name = Settings.Name,
                        Option = Module.Options[Settings.Name],
                        Settings = Settings,
                        Type = Spec.Type
                    })
                end
            end
        else
            for Name: string, Option: any in Module.Options do
                table.insert(List, {
                    Name = Name,
                    Option = Option,
                    Settings = {},
                    Type = Option.Type
                })
            end

            table.sort(List, function(A, B)
                return A.Name < B.Name
            end)
        end

        return List
    end

    local function CountModules(): number
        return GetTableSize(vape.Modules) + GetTableSize(vape.Legit.Modules)
    end

    local function BuildIndex()
        Index = {
            Entries = {},
            Frequency = {},
            Keys = {},
            Options = {},
            Size = CountModules()
        }

        local function Add(Module, Legit: boolean)
            local Entry = {
                Category = Legit and "Legit" or Module.Category,
                Key = Compact(Module.Name),
                Legit = Legit,
                Module = Module,
                Name = Module.Name,
                Options = GetOptions(Module),
                Terms = {}
            }

            AddTerms(Entry.Terms, Module.Name, 4)
            AddTerms(Entry.Terms, SplitName(Module.Name), 4)
            AddTerms(Entry.Terms, Plain(Module.Tooltip), 2)
            for _, Option: any in Entry.Options do
                AddTerms(Entry.Terms, Option.Name, 1)
                AddTerms(Entry.Terms, Plain(Option.Settings.Tooltip), 0.5)

                local Phrase: string = Normalize(Option.Name)
                if Phrase:find(" ", 1, true) then
                    Index.Options[Phrase] = Index.Options[Phrase] or {}
                    table.insert(Index.Options[Phrase], {Entry = Entry, Option = Option})
                end
            end

            for Term: string in Entry.Terms do
                Index.Frequency[Term] = (Index.Frequency[Term] or 0) + 1
            end

            Index.Keys[Entry.Key] = Index.Keys[Entry.Key] or Entry
            table.insert(Index.Entries, Entry)
        end

        for _, Module: any in vape.Modules do
            Add(Module, false)
        end

        for _, Module: any in vape.Legit.Modules do
            Add(Module, true)
        end

        table.sort(Index.Entries, function(A, B)
            return A.Name < B.Name
        end)

        for Alias: string, Name: string in Aliases do
            Index.Keys[Alias] = Index.Keys[Alias] or Index.Keys[Compact(Name)]
        end
    end

    local function EnsureIndex()
        if not Index or Index.Size ~= CountModules() then
            BuildIndex()
        end
    end

    local function Rarity(Term: string): number
        return math.log((#Index.Entries + 1) / ((Index.Frequency[Term] or 0) + 0.5))
    end

    local function BuildQuery(Text: string): {[string]: number}
        local Query: {[string]: number} = {}

        for Word: string in Text:gmatch("%S+") do
            if not Stopwords[Word] then
                local Term: string = Stem(Word)
                Query[Term] = 1

                for _, Synonym: string in Synonyms[Term] or {} do
                    Query[Synonym] = math.max(Query[Synonym] or 0, 0.6)
                end
            end
        end

        return Query
    end

    local function RankModules(Query: {[string]: number}): {any}
        local Results = {}

        for _, Entry: any in Index.Entries do
            local Score: number = 0
            for Term: string, Weight: number in Query do
                local Match: number? = Entry.Terms[Term]
                if Match then
                    Score += Match * Weight * Rarity(Term) + (Term == Entry.Key and Weight * 10 or 0)
                end
            end

            if Score > 0 then
                table.insert(Results, {Entry = Entry, Score = Score})
            end
        end

        table.sort(Results, function(A, B)
            return A.Score > B.Score
        end)

        return Results
    end

    local function FindModule(Words: {string})
        local Best, BestLength = nil, 0

        for Size: number = math.min(3, #Words), 1, -1 do
            for i: number = 1, #Words - Size + 1 do
                local Key: string = table.concat(Words, "", i, i + Size - 1)
                local Entry = Index.Keys[Key]
                if Entry and #Key > BestLength then
                    Best, BestLength = Entry, #Key
                end
            end
        end

        if Best then
            return Best
        end

        local BestDistance: number = math.huge
        for Size: number = math.min(3, #Words), 1, -1 do
            for i: number = 1, #Words - Size + 1 do
                local Key: string = table.concat(Words, "", i, i + Size - 1)
                local Term: string = Stem(Key)
                if #Key >= 5 and not Stopwords[Key] and not Index.Frequency[Term] and not GuideFrequency[Term] and not FactFrequency[Term] then
                    for Name: string, Entry: any in Index.Keys do
                        if #Name >= 5 and math.abs(#Name - #Key) <= 2 then
                            local Gap: number = Distance(Key, Name)
                            if Gap <= (#Name >= 9 and 2 or 1) and Gap < BestDistance then
                                Best, BestDistance = Entry, Gap
                            end
                        end
                    end
                end
            end
        end

        return Best
    end

    local function FindMentions(Words: {string}): {any}
        local Found = {}
        local Used: {[number]: boolean} = {}

        for Size: number = math.min(3, #Words), 1, -1 do
            for i: number = 1, #Words - Size + 1 do
                local Free: boolean = true
                for j: number = i, i + Size - 1 do
                    Free = Free and not Used[j]
                end

                local Entry = Free and Index.Keys[table.concat(Words, "", i, i + Size - 1)]
                if Entry and not table.find(Found, Entry) then
                    table.insert(Found, Entry)
                    for j: number = i, i + Size - 1 do
                        Used[j] = true
                    end
                end
            end
        end

        return Found
    end

    local function FindOption(Entry, Query: {[string]: number}, MinWeight: number)
        local NameTerms: {[string]: number} = {}
        AddTerms(NameTerms, `{Entry.Name} {SplitName(Entry.Name)}`, 1)

        local Matches = {}
        for i: number, Option: any in Entry.Options do
            local OptionTerms: {[string]: number} = {}
            AddTerms(OptionTerms, Option.Name, 1)

            local Matched, Total = 0, 0
            for Term: string in OptionTerms do
                Total += 1
                if (Query[Term] or 0) >= MinWeight and not NameTerms[Term] and not IntentTerms[Term] then
                    Matched += 1
                end
            end

            if Matched > 0 then
                table.insert(Matches, {Matched = Matched, Option = Option, Order = i, Score = Matched / Total})
            end
        end

        table.sort(Matches, function(A, B)
            if A.Score ~= B.Score then
                return A.Score > B.Score
            elseif A.Matched ~= B.Matched then
                return A.Matched > B.Matched
            end

            return A.Order < B.Order
        end)

        return Matches
    end

    local function FindCategory(Has: {[string]: boolean}): string?
        for Name: string, Category: any in vape.Categories do
            if Category.Type == "Category" and Name ~= "Favorites" and Has[Name:lower()] then
                return Name
            end
        end

        return Has.legit and "Legit" or nil
    end

    local function SampleModule(Skip: string?): string?
        local Names: {string} = {}
        for _, Entry: any in Index.Entries do
            if not Entry.Legit and Entry.Name ~= Skip and Plain(Entry.Module.Tooltip) ~= "" then
                table.insert(Names, Entry.Name)
            end
        end

        return #Names > 0 and Names[math.random(1, #Names)] or nil
    end

    local function DescribeKind(Option): string
        local Component = Option.Option or {}
        local Settings = Option.Settings

        if Option.Type == "Slider" or Option.Type == "TwoSlider" then
            return `slider from {FormatNumber(Settings.Min or Component.Min)} to {FormatNumber(Settings.Max or Component.Max)}`
        elseif Option.Type == "Dropdown" then
            local List: {string} = Settings.List or Component.List or {}
            return `dropdown with {#List} choice{#List == 1 and "" or "s"}`
        end

        return Kinds[Option.Type] or "setting"
    end

    local function DescribeValue(Option): string?
        local Component = Option.Option
        if not Component then return nil end

        if Component.Type == "Toggle" then
            return Component.Enabled and "on" or "off"
        elseif Component.Type == "Slider" or Component.Type == "Dropdown" or Component.Type == "TextBox" then
            return Component.Value ~= "" and Escape(FormatNumber(Component.Value)) or "empty"
        elseif Component.Type == "TwoSlider" then
            return `{FormatNumber(Component.ValueMin)} to {FormatNumber(Component.ValueMax)}`
        elseif Component.Type == "TextList" then
            local Joined: string = table.concat(Component.ListEnabled, ", ")
            return #Joined == 0 and "empty" or #Joined > 80 and `{#Component.ListEnabled} entries` or Escape(Joined)
        end

        return nil
    end

    local function WhereText(Entry): string
        return Entry.Legit and "the Legit menu" or `the {Entry.Category} window`
    end

    local function OpenGUI()
        if vape.Legit.Window.Visible then
            vape.Legit:Close()
        end

        if not ClickGUI.Visible then
            vape.GUIBind.Triggered:Fire(true)
        end
    end

    local function CloseGUI()
        if ClickGUI.Visible then
            vape.GUIBind.Triggered:Fire(true)
        end
    end

    local function OpenWindow(Category)
        OpenGUI()

        if Category.Button and not Category.Button.Enabled then
            Category.Button:Toggle()
        end

        if Category.Expand and not Category.Expanded then
            Category:Expand()
        end
    end

    local function OpenPane(Name: string?)
        OpenGUI()
        vape.Categories.Main.Settings.Object.Visible = true

        for PaneName: string, Pane: any in vape.Settings do
            if PaneName ~= "Settings" then
                Pane.Object.Visible = PaneName == Name
            end
        end
    end

    local function OpenFavorites()
        OpenGUI()

        local Favorites = vape.Categories.Favorites
        if Favorites and not Favorites.Standalone then
            Favorites:SetStandalone(true)
            vape.PaintFavorites()
            vape:QueueSave()
        end
    end

    local function FindText(Root: Instance, Text: string): GuiObject?
        for _, v: Instance in Root:GetDescendants() do
            if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text:match("^%s*(.-)%s*$") == Text then
                return v:IsA("TextButton") and v or v:FindFirstAncestorOfClass("TextButton") or v
            end
        end

        return nil
    end

    local function ScrollTo(Object: GuiObject)
        local Scroller: ScrollingFrame? = Object:FindFirstAncestorOfClass("ScrollingFrame")
        if not Scroller then return end

        task.wait()
        local Offset: number = (Object.AbsolutePosition.Y - Scroller.AbsolutePosition.Y) / Scale.Scale + Scroller.CanvasPosition.Y
        Scroller.CanvasPosition = Vector2.new(0, math.max(Offset - 40, 0))
    end

    local function ClearHighlight()
        HighlightToken += 1

        if HighlightConnection then
            HighlightConnection:Disconnect()
            HighlightConnection = nil
        end

        if HighlightFrame then
            HighlightFrame:Destroy()
            HighlightFrame = nil
        end
    end

    local function Highlight(Target: GuiObject?, Caption: string?)
        ClearHighlight()
        if not Target then return end

        local Token: number = HighlightToken
        local Tint: Color3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, math.max(vape.GUIColor.Value, 0.7))
        local Frame: Frame = Instance.new("Frame")
        Frame.BackgroundColor3 = Tint
        Frame.BackgroundTransparency = 0.85
        Frame.ZIndex = 50
        Frame.Parent = GUI
        HighlightFrame = Frame
        AddCorner(Frame)
        local Stroke: UIStroke = Instance.new("UIStroke")
        Stroke.Color = Tint
        Stroke.Thickness = 2
        Stroke.Parent = Frame
        local Label: TextLabel = Instance.new("TextLabel")
        Label.BackgroundColor3 = UIPallet.Main
        Label.FontFace = UIPallet.Font
        Label.Size = UDim2.fromOffset(math.ceil(GetFontBounds(Caption or "Here", 13, UIPallet.Font).X) + 16, 24)
        Label.Text = Caption or "Here"
        Label.TextColor3 = UIPallet.Text
        Label.TextSize = 13
        Label.ZIndex = 51
        Label.Parent = Frame
        AddCorner(Label)
        local LabelStroke: UIStroke = Instance.new("UIStroke")
        LabelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        LabelStroke.Color = Tint
        LabelStroke.Parent = Label

        HighlightConnection = RunService.RenderStepped:Connect(function()
            if not Target.Parent then
                ClearHighlight()
                return
            end

            local Inset: Vector2 = GuiService:GetGuiInset()
            local Top: number = Target.AbsolutePosition.Y + Inset.Y - 4
            Frame.Position = UDim2.fromOffset(Target.AbsolutePosition.X + Inset.X - 4, Top)
            Frame.Size = UDim2.fromOffset(Target.AbsoluteSize.X + 8, Target.AbsoluteSize.Y + 8)
            Frame.Visible = IsRendered(Target)
            Label.AnchorPoint = Vector2.new(0, Top > 34 and 1 or 0)
            Label.Position = Top > 34 and UDim2.fromOffset(0, -6) or UDim2.new(0, 0, 1, 6)
            Stroke.Transparency = 0.3 + math.sin(os.clock() * 6) * 0.3
        end)

        task.delay(6, function()
            if HighlightToken == Token then
                ClearHighlight()
            end
        end)
    end

    local function RevealModule(Entry, Expand: boolean?): GuiObject?
        local Module = Entry.Module

        if Entry.Legit then
            vape.Legit:Open(Entry.Name)
            if Expand then
                Module:ShowSettings(false)
            end

            return Module.Object
        end

        local Category = vape.Categories[Entry.Category]
        if Category and Module.Visible then
            OpenWindow(Category)
            if Expand then
                Module:SetExpanded(true)
            end

            ScrollTo(Module.Object)
            return Module.Object
        end

        OpenGUI()
        vape.SearchBar.Object.TextBox.Text = Entry.Name
        task.wait()

        return vape.SearchBar.Object:FindFirstChild(Entry.Name, true)
    end

    local function RevealOption(Entry, Option): GuiObject?
        local Parent: GuiObject? = RevealModule(Entry, true)
        local Object: GuiObject? = Option.Option and Option.Option.Object
        if not Object or not (Entry.Legit or Entry.Module.Visible) then
            return Parent
        end

        if not Entry.Legit then
            ScrollTo(Object)
        end

        return Object
    end

    local function AddPlace(Place)
        Place.Terms = {}
        Place.LabelTerms = {}
        AddTerms(Place.Terms, Place.Keywords, 1)
        AddTerms(Place.LabelTerms, Place.Label, 1)
        Place.Phrase = Normalize(Place.Label)
        Place.Id = Place.Id or Place.Phrase

        Places.ById[Place.Id] = Places.ById[Place.Id] or Place
        table.insert(Places.List, Place)

        for _, Phrase: string in {Place.Label, table.unpack(Place.Aliases or {})} do
            Phrase = Normalize(Phrase)
            Places.ByPhrase[Phrase] = Places.ByPhrase[Phrase] or Place

            local Stemmed: {string} = {}
            for Word: string in Phrase:gmatch("%S+") do
                table.insert(Stemmed, Stem(Word))
            end

            Stemmed = table.concat(Stemmed, " ")
            Places.ByStem[Stemmed] = Places.ByStem[Stemmed] or Place
        end
    end

    local function BuildPlaces()
        local Main = vape.Categories.Main
        Places = {ById = {}, ByPhrase = {}, ByStem = {}, List = {}}

        AddPlace({
            Id = "gui",
            Aliases = {"menu", "main menu", "main window", "clickgui", "click gui", "Uranium", "vape", "Uranium menu", "vape menu"},
            Label = "GUI",
            Name = "the GUI",
            Keywords = "main window menu clickgui Uranium vape click",
            Hint = "This is the main CatVape window.",
            Target = function()
                OpenGUI()
                return Main.Object
            end,
            Open = OpenGUI,
            Close = CloseGUI
        })
        AddPlace({
            Id = "legit",
            Aliases = {"legit", "legit menu", "legit tab", "legit window", "legit mods", "legit gui"},
            Label = "Legit mode",
            Name = "the Legit menu",
            Keywords = "legit tab switch menu mods hud option options",
            Hint = "Click this switch to open the Legit menu.",
            Target = function()
                OpenGUI()
                return vape.SearchBar.Object:FindFirstChild("Legit")
            end,
            Open = function()
                vape.Legit:Open()
            end,
            Close = function()
                vape.Legit:Close()
            end
        })
        AddPlace({
            Id = "cheat",
            Aliases = {"cheat menu", "cheats", "blatant mode", "cheat gui"},
            Label = "cheat mode",
            Name = "cheat mode",
            Keywords = "cheat back return blatant",
            Hint = "Click this to go back to cheat mode.",
            Done = "Back in cheat mode.",
            Target = function()
                vape.Legit:Open()
                return vape.SearchBar.LegitReturn
            end,
            Open = function()
                vape.Legit:Close()
            end
        })
        AddPlace({
            Id = "search",
            Aliases = {"searchbar", "search box"},
            Label = "search bar",
            Name = "the search bar",
            Keywords = "search searchbar",
            Hint = "Type a module name in here.",
            Target = function()
                OpenGUI()
                return vape.SearchBar.Object
            end,
            Open = function()
                OpenGUI()
                vape.SearchBar.Object.TextBox:CaptureFocus()
            end
        })
        AddPlace({
            Id = "settings",
            Aliases = {"setting", "gear", "preferences", "settings menu", "settings tab"},
            Label = "settings",
            Name = "the settings",
            Keywords = "gear cog preferences",
            Hint = "Click the gear to open the settings.",
            Target = function()
                OpenGUI()
                return Main.Object:FindFirstChild("Settings")
            end,
            Open = function()
                OpenPane()
            end,
            Close = function()
                for _, Pane: any in vape.Settings do
                    Pane.Object.Visible = false
                end
            end
        })
        AddPlace({
            Id = "overlays",
            Aliases = {"overlays", "overlay", "overlay menu", "overlays tab"},
            Label = "overlays menu",
            Name = "the overlays menu",
            Keywords = "overlay overlays hud",
            Hint = "Click this to open the overlays menu.",
            Target = function()
                OpenGUI()
                return vape.Overlays.Button
            end,
            Open = function()
                OpenGUI()
                vape.Overlays:Open()
            end,
            Close = function()
                vape.Overlays:Close()
            end
        })
        AddPlace({
            Id = "favorites",
            Aliases = {"favourites", "favs", "favorites tab", "favorites window", "favorites list"},
            Label = "favorites",
            Name = "the Favorites window",
            Keywords = "favorite favourite favourites star starred",
            Hint = "Click the star to open your Favorites.",
            Target = function()
                OpenGUI()
                return vape.Overlays.Object:FindFirstChild("Favorites")
            end,
            Open = OpenFavorites
        })
        AddPlace({
            Id = "discord",
            Aliases = {"discord server", "discord invite", "invite"},
            Label = "discord",
            Name = "the Discord button",
            Keywords = "support invite server community",
            Hint = "Click this to copy the Discord invite.",
            Done = "Copied the Discord invite to your clipboard: discord.gg/Uranium",
            Target = function()
                OpenGUI()
                return Main.Object:FindFirstChild("Discord")
            end,
            Open = function()
                if setclipboard then
                    setclipboard("https://discord.gg/Uranium")
                end
            end
        })
        AddPlace({
            Id = "rebind gui",
            Aliases = {"gui key", "gui bind", "gui keybind", "menu key", "menu bind"},
            Label = "rebind GUI",
            Name = "Rebind GUI",
            Keywords = "gui key keybind bind menu",
            Hint = "Click this and press a key to change the GUI key.",
            Target = function()
                OpenPane()
                return vape.GUIBind.Object
            end
        })
        AddPlace({
            Id = "gui theme",
            Aliases = {"theme", "gui color", "gui colour", "color theme", "theme color"},
            Label = "GUI theme",
            Name = "GUI Theme",
            Keywords = "theme color colour rainbow accent",
            Hint = "Pick your GUI color here.",
            Target = function()
                OpenPane()
                return vape.GUIColor.Object
            end
        })
        AddPlace({
            Id = "chat history",
            Aliases = {"history", "chats", "old chats", "past chats", "previous chats", "saved chats", "chat log", "chat logs", "conversations", "old conversations"},
            Label = "chat history",
            Name = "your chat history",
            Keywords = "history chats old past previous saved conversation conversations log logs",
            Hint = "Click the clock to see your past chats.",
            Done = "Here are your past chats, click one to pick it back up.",
            Target = function()
                OpenGUI()
                return Assistant.HistoryButton
            end,
            Open = function()
                OpenGUI()
                Assistant:ShowHistory(true)
            end,
            Close = function()
                Assistant:ShowHistory(false)
            end
        })

        local Profiles = vape.Categories.Profiles
        if Profiles then
            AddPlace({
                Id = "public profiles",
                Aliases = {"public configs", "public"},
                Label = "public profiles",
                Name = "Public Profiles",
                Keywords = "public browse online community download",
                Hint = "Click PUBLIC to browse other people's profiles.",
                Target = function()
                    OpenWindow(Profiles)
                    return Profiles.Object:FindFirstChild("Public", true)
                end,
                Open = function()
                    OpenGUI()
                    vape.PublicProfiles.Window.Position = UDim2.new(0.5, -356, 0.5, -214)
                    vape.PublicProfiles.Window.Visible = true
                end,
                Close = function()
                    vape.PublicProfiles.Window.Visible = false
                end
            })
            AddPlace({
                Id = "create profile",
                Label = "create new button",
                Name = "CREATE NEW",
                Keywords = "create new profile make",
                Hint = "Click this to make a new profile.",
                Target = function()
                    OpenWindow(Profiles)
                    return Profiles.Object:FindFirstChild("CreateNew", true)
                end
            })
        end

        for Name: string, Category: any in vape.Categories do
            if (Category.Type == "Category" and Name ~= "Favorites") or Category.Type == "CategoryList" then
                AddPlace({
                    Aliases = {`{Name} tab`, `{Name} window`, `{Name} category`, `{Name} menu`},
                    Category = Category.Type == "Category" and Name or nil,
                    Label = Name,
                    Name = `the {Name} window`,
                    Keywords = "window",
                    Hint = `This is the {Name} window.`,
                    Target = function()
                        OpenWindow(Category)
                        return Category.Object
                    end,
                    Open = function()
                        OpenWindow(Category)
                    end,
                    Close = function()
                        if Category.Button and Category.Button.Enabled then
                            Category.Button:Toggle()
                        end
                    end
                })
            end

            if Category.Type == "CategoryList" then
                local Names: {string} = table.clone(ListButtons[Name] or {})
                for OptionName: string in Category.Options do
                    table.insert(Names, OptionName)
                end

                for _, OptionName: string in Names do
                    local function Target()
                        OpenWindow(Category)
                        Category:ShowSettings(true)
                        task.wait()

                        local Option = Category.Options[OptionName]
                        return Option and Option.Object or FindText(Category.Object, OptionName)
                    end

                    AddPlace({
                        Component = Category.Options[OptionName],
                        Label = OptionName,
                        Name = OptionName,
                        Keywords = `{Name} gear`,
                        Hint = `This is under the gear in the {Name} window.`,
                        Target = Target,
                        Open = Target
                    })
                end
            end

            if Category.Type == "Overlay" then
                AddPlace({
                    Aliases = {`{Name} overlay`},
                    Label = Name,
                    Name = `the {Name} overlay`,
                    Keywords = "overlay",
                    Hint = `This is {Name}, it lives in the overlays menu.`,
                    Target = function()
                        OpenGUI()
                        if Category.Button.Enabled then
                            return Category.Object
                        end

                        vape.Overlays:Open()
                        return Category.Button.Object
                    end,
                    Open = function()
                        OpenGUI()
                        if not Category.Button.Enabled then
                            Category.Button:Toggle()
                        end
                    end,
                    Close = function()
                        if Category.Button.Enabled then
                            Category.Button:Toggle()
                        end
                    end
                })
            end
        end

        for PaneName: string, Pane: any in vape.Settings do
            if PaneName ~= "Settings" then
                AddPlace({
                    Aliases = {`{PaneName} tab`, `{PaneName} pane`, `{PaneName} page`},
                    Label = `{PaneName} settings`,
                    Name = `the {PaneName} settings`,
                    Keywords = "gear",
                    Hint = `Click {PaneName} in the settings.`,
                    Target = function()
                        OpenPane()
                        return FindText(Main.Settings.Object, PaneName)
                    end,
                    Open = function()
                        OpenPane(PaneName)
                    end,
                    Close = function()
                        Pane.Object.Visible = false
                    end
                })

                local Names: {string} = table.clone(PaneButtons[PaneName] or {})
                for OptionName: string in Pane.Options do
                    table.insert(Names, OptionName)
                end

                for _, OptionName: string in Names do
                    local function Target()
                        OpenPane(PaneName)
                        local Option = Pane.Options[OptionName]
                        return Option and Option.Object or FindText(Pane.Object, OptionName)
                    end

                    AddPlace({
                        Component = Pane.Options[OptionName],
                        Label = OptionName,
                        Name = OptionName,
                        Keywords = `{PaneName} settings`,
                        Hint = `This is in the {PaneName} settings.`,
                        Target = Target,
                        Open = Target
                    })
                end
            end
        end
    end

    local function FindPlace(Query: {[string]: number}, Padded: string)
        if not Places then
            BuildPlaces()
        end

        local Best, BestScore, BestSize = nil, 0, 0
        for _, Place: any in Places.List do
            local Matched, Total = 0, 0
            for Term: string in Place.LabelTerms do
                Total += 1
                if (Query[Term] or 0) >= 0.6 then
                    Matched += 1
                end
            end

            if Matched > 0 then
                local Score: number = Matched / Total * 2
                for Term: string in Place.Terms do
                    if Query[Term] == 1 and not Place.LabelTerms[Term] then
                        Score += 0.5
                    end
                end

                if Padded:find(` {Place.Phrase} `, 1, true) then
                    Score += 2
                end

                if Score > BestScore or (Score == BestScore and (Total > BestSize or (Total == BestSize and #Place.Phrase > #Best.Phrase))) then
                    Best, BestScore, BestSize = Place, Score, Total
                end
            end
        end

        return Best, BestScore
    end

    local function GetPlace(Id: string)
        if not Places then
            BuildPlaces()
        end

        return Places.ById[Id]
    end

    local Guides = {
        {
            Keywords = "open close gui menu clickgui rightshift appear launch opening closing access",
            Place = "gui",
            Answer = function()
                if IsMobile() then
                    return `Tap the CatVape button at the top of your screen to open or close the GUI. If you turned on {Accent("Hide CatVape Button")}, it is still there, just invisible, so tap the same spot.`
                end

                return `Press {Accent(GetKeys(vape.GUIBind.Keys) or "RightShift")} to open or close the GUI. You can change that key with {Accent("Rebind GUI")} in the settings, which open from the gear on the main window.`
            end
        },
        {
            Keywords = "setting settings gear cog preferences general",
            Place = "settings",
            Answer = function()
                return `The gear on the main window opens the settings. {Accent("General")} has the keybind options, Self destruct and Reinject, {Accent("Modules")} has the team options, {Accent("GUI")} has blur, scale, tooltips and the search bar, and {Accent("Notifications")} controls popups. {Accent("GUI Theme")} and {Accent("Rebind GUI")} are there too.`
            end
        },
        {
            Keywords = "setting settings option options configure customize customise adjust expand dots slider sliders dropdown change tweak value values",
            Answer = function()
                local Sample: string? = SampleModule()
                return `Right click a module, or click the three dots on its right, to open its settings. Hover a setting to see what it does.{Sample and ` You can also ask me about one module, like "{Sample} settings".` or ""}`
            end
        },
        {
            Keywords = "turn toggle enable disable activate deactivate off switch start stop run running click press",
            Answer = function()
                if IsMobile() then
                    return "Tap a module to turn it on or off, it lights up in your theme color while it is on. Tap the three dots on its right to open its settings."
                end

                return "Left click a module to turn it on or off, it lights up in your theme color while it is on. Right click it, or click the three dots on its right, to open its settings."
            end
        },
        {
            Keywords = "bind binds keybind keybinds hotkey hotkeys shortcut shortcuts key keys keyboard binding unbind rebind hold held combo multi",
            Answer = function()
                if IsMobile() then
                    return "Hold a module in the GUI for a second, then tap where you want its button. Tap that button to toggle the module, and hold it for a second to remove it."
                end

                return `Open the GUI, hover the module and click the bind icon that appears on its right, then press a key. Clicking the icon again while it says {Accent("PRESS A KEY TO BIND")} removes the bind, and shift clicking it makes the module run only while the key is held.\n\nTurn on {Accent("Enable Multi-Keybinding")} in the General settings for combos like G + H, and {Accent("Allow setting keybinds")} to bind toggle settings too.`
            end
        },
        {
            Keywords = "profile profiles switch preset presets slot create delete",
            Place = "profiles",
            Answer = function()
                return `Open {Accent("Profiles")} from the main window. Click {Accent("CREATE NEW")}, type a name and press the add button. Click a profile to switch to it, hover it and click its bind icon to give it a keybind, and click the dots on a profile you are not using to delete it. Profiles are kept separately for every game.`
            end
        },
        {
            Keywords = "config configs export import share copy paste clipboard code string load send",
            Place = "export config",
            Answer = function()
                return `Open {Accent("Profiles")} and click its gear. {Accent("Export config")} copies your whole setup for this game to your clipboard and saves it to {vape.Directory}/profiles/export.txt. To load one, paste it into {Accent("Import config")} and press Enter. That overwrites the profile you are on, so create a new profile first if you want to keep yours.`
            end
        },
        {
            Keywords = "public browse download online community upload publish others people config configs profile profiles",
            Place = "public profiles",
            Answer = function()
                return `Open {Accent("Profiles")} and click {Accent("PUBLIC")} to browse configs other people published. Search by profile or username, click one to see its details and press {Accent("Download")}. {Accent("CREATE NEW")} under Your Public Profiles publishes your own, anonymously if you want.`
            end
        },
        {
            Keywords = "reset default defaults restore wipe fresh config profile",
            Place = "reset current profile",
            Answer = function()
                return `Open {Accent("Profiles")}, click its gear and press {Accent("Reset current profile")}. That puts the profile you are on back to the defaults and reloads CatVape. If a window just went off screen, use {Accent("Reset GUI positions")} in the GUI settings instead.`
            end
        },
        {
            Keywords = "save saving saved autosave persist sync",
            Place = "sync to current profile",
            Answer = function()
                return `CatVape saves by itself whenever you change something, into the profile you are on. {Accent("Sync to current profile")} in the Profiles gear forces a save right away.`
            end
        },
        {
            Keywords = "friend friends ally allies whitelist protect",
            Place = "friends",
            Answer = function()
                return `Open {Accent("Friends")} from the main window, type a Roblox username and press Enter. With {Accent("Use friends")} on (in its gear), modules leave everyone on the list alone, and {Accent("Recolor visuals")} draws them in {Accent("Friends color")}. Click a name to switch it off without removing it, or the X to remove it.`
            end
        },
        {
            Keywords = "target targets priority prioritize focus npc npcs",
            Place = "targets",
            Answer = function()
                return `Add Roblox usernames to {Accent("Targets")} in the main window, modules that pick a target go for them first. Inside a combat module, the {Accent("Target")} setting opens Target settings, where you choose Players or NPCs, whether to ignore invisible players or players behind walls, and the {Accent("Priority")}.`
            end
        },
        {
            Keywords = "favorite favorites favourite favourites star starred",
            Place = "favorites",
            Answer = function()
                return `Hover a module and click the star next to it. The star button at the bottom of the main window opens the {Accent("Favorites")} window with all of them together.`
            end
        },
        {
            Keywords = "hide hidden unhide declutter pencil clutter",
            Answer = function()
                return `Click the pencil on a category window, then click the square next to each module to hide or show it and press {Accent("DONE")}. Hidden modules keep working, they are just out of the list.`
            end
        },
        {
            Keywords = "search searching find lookup look filter bar",
            Place = "search",
            Answer = function()
                return `While the GUI is open, type in the search bar at the top of the screen. Click a result to turn it on or off, and right click it for its settings. If the bar is missing, set {Accent("Search bar style")} to Floating in the GUI settings.`
            end
        },
        {
            Keywords = "overlay overlays hud arraylist pin pinned",
            Place = "overlays",
            Answer = function()
                local Names: {string} = {}
                for Name: string, Category: any in vape.Categories do
                    if Category.Type == "Overlay" then
                        table.insert(Names, Accent(Name))
                    end
                end
                table.sort(Names)

                return `Click the overlays button at the bottom of the main window and turn on the ones you want{#Names > 0 and `, like {JoinNames(Names, 4)}` or ""}. Drag an overlay to move it, click its pin to keep it on screen with the GUI closed, and right click it for its settings.`
            end
        },
        {
            Keywords = "legit mode menu closet screenshare legitimate cheat",
            Place = "legit",
            Answer = function()
                local Names: {string} = {}
                for Name: string in vape.Legit.Modules do
                    table.insert(Names, Name)
                end
                table.sort(Names)

                return `Click the switch on the left of the search bar to open the Legit menu{#Names > 0 and `, it has HUD mods like {JoinNames(Names, 3)}` or ""}. Click a mod to turn it on and right click it for its settings. The button at the top of the screen takes you back, and {Accent("Show legit mode")} in the GUI settings hides the switch.`
            end
        },
        {
            Keywords = "theme gui color colors colour colours accent rainbow appearance look",
            Place = "gui theme",
            Answer = function()
                return `Open the settings from the gear on the main window and pick a color with {Accent("GUI Theme")}, it has a rainbow button too. {Accent("Rainbow Mode")}, {Accent("Rainbow speed")} and {Accent("Rainbow update rate")} in the GUI settings change how the rainbow looks.`
            end
        },
        {
            Keywords = "scale gui size big small bigger smaller resize huge tiny",
            Place = "auto rescale",
            Answer = function()
                return `The GUI sizes itself to your screen. Turn off {Accent("Auto rescale")} in the GUI settings to set {Accent("Scale")} yourself.`
            end
        },
        {
            Keywords = "lag lagging laggy fps performance slow stutter boost frames",
            Place = "hud blur",
            Answer = function()
                local Booster = Index.Keys.fpsbooster
                return `Turn off {Accent("HUD blur")} and {Accent("Blur background")} in the GUI settings, they cost the most frames. Render modules like ESP add up with a lot of players too.{Booster and ` {Accent(Booster.Name)} in {WhereText(Booster)} can help as well.` or ""}`
            end
        },
        {
            Keywords = "notification notifications notify alert alerts popup popups",
            Place = "notifications settings",
            Answer = function()
                return `The {Accent("Notifications")} settings let you turn every notification off, or just {Accent("Toggle alert")} for modules turning on and off and {Accent("Setting toggle alert")} for bound settings.`
            end
        },
        {
            Keywords = "tooltip tooltips hover description descriptions",
            Place = "show tooltips",
            Answer = function()
                return `Hover any module or setting to see what it does, and {Accent("Show tooltips")} in the GUI settings turns that off. You can also just ask me about a module.`
            end
        },
        {
            Keywords = "uninject unload destruct self exit quit reload reinject restart",
            Place = "self destruct",
            Answer = function()
                return `{Accent("Self destruct")} in the General settings removes CatVape from this game, and {Accent("Reinject")} next to it loads it again.`
            end
        },
        {
            Keywords = "update updates updating version outdated newest",
            Answer = function()
                return `CatVape checks for a new version every time you execute it and downloads it by itself, so just execute it again. Ask me "what's new" to see what changed.`
            end
        },
        {
            Keywords = "position positions gui offscreen screen lost missing moved window windows sort arrange drag move",
            Place = "reset gui positions",
            Answer = function()
                return `Drag a window to move it. If one went off screen, press {Accent("Reset GUI positions")} in the GUI settings, and {Accent("Sort GUI")} lines every window up in order.`
            end
        },
        {
            Keywords = "error errors errored bug bugs bugged broken crash crashes crashing console f9 issue issues problem report fix",
            Place = "discord",
            Answer = function()
                return "If a notification says a module errored, press F9 to open the console and find the line starting with [Uranium]. Send that line in the Discord so it can get fixed, the Discord icon on the main window copies the invite."
            end
        },
        {
            Keywords = "discord support server community invite contact staff owner made created creator developer developers dev devs",
            Place = "discord",
            Answer = function()
                return "Click the Discord icon on the main window, it copies the invite for you: discord.gg/Uranium"
            end
        },
        {
            Keywords = "team teams teammate teammates",
            Place = "teams by server",
            Answer = function()
                return `{Accent("Teams by server")} in the Modules settings makes modules skip players the game puts on your team, and {Accent("Use team color")} colors render modules with each player's team color.`
            end
        },
        {
            Keywords = "ban banned bans safe safety detect detected detectable undetected risk anticheat",
            Answer = function()
                return "Any module can get you banned, and Blatant ones are the easiest to spot. Lower settings and the Legit menu are less obvious, and an alt account keeps your main out of it."
            end
        },
        {
            Keywords = "paid premium buy purchase price cost license",
            Place = "discord",
            Answer = function()
                return "Modules tagged PAID are part of CatVape premium. The Discord has everything about getting it, the icon on the main window copies the invite."
            end
        },
        {
            Keywords = "history chats chat old past previous saved conversation conversations log logs",
            Place = "chat history",
            Answer = function()
                return `Every chat is saved to {vape.Directory}/profiles/assistantchats.json. Click the clock at the top of this window to see your last 30 chats, click one to pick it back up, or its X to delete it. The pencil starts a new chat.`
            end
        },
        {
            Keywords = "mobile phone ipad tablet touch tap android ios",
            Answer = function()
                return "Tap the CatVape button at the top of your screen to open the GUI. Hold a module for a second, then tap anywhere to place a button for it. Tap that button to toggle the module and hold it for a second to remove it."
            end
        }
    }

    for _, Guide: any in Guides do
        Guide.Terms = {}
        AddTerms(Guide.Terms, Guide.Keywords, 1)

        for Term: string in Guide.Terms do
            GuideFrequency[Term] = (GuideFrequency[Term] or 0) + 1
        end
    end

    local function FindGuide(Query: {[string]: number})
        local Best, BestScore = nil, 0
        local Topical: boolean = false
        for Term: string, Weight: number in Query do
            if Weight == 1 and not IntentTerms[Term] then
                Topical = true
                break
            end
        end

        for _, Guide: any in Guides do
            local Score: number = 0
            for Term: string, Weight: number in Query do
                if Guide.Terms[Term] then
                    Score += Weight * (Topical and IntentTerms[Term] and 0.4 or 1) * math.log((#Guides + 1) / (GuideFrequency[Term] + 0.5))
                end
            end

            if Score > BestScore then
                Best, BestScore = Guide, Score
            end
        end

        return Best, BestScore
    end

    local Facts = {
        {
            Game = "BedWars",
            Modules = {"Nuker", "BedAssist", "FastBreak", "Reach", "AutoWin"},
            Options = {"Break range"},
            Ask = "How far can I break a bed from?",
            Keywords = "break breaking broke range far close distance stud studs reach stand finish bed beds block blocks mine mining server cancel cancelled cooldown",
            Text = "The server only accepts block breaks from about 18 studs away, so a bed farther out never takes damage, even with Nuker's Break range at 30. Nuker can chip the blocks covering it from farther, but stand within about 19 studs to finish the bed. Hits faster than the 0.3 second break cooldown get cancelled too."
        },
        {
            Game = "BedWars",
            Modules = {"Killaura", "Reach", "HitBoxes", "SilentAura", "AutoWin"},
            Options = {"Attack range", "Swing range", "Sword reach"},
            Keywords = "sword swords reach range hit hits attack attacks melee swing swings aura normal legit far distance studs miss misses missing land lands register hitreg best max axe battle hammer weapon weapons",
            Text = "A normal swing reaches about 11.4 studs in front of you, and 14.4 when your cursor is right on the enemy. The game refuses hits from much past the weapon's range, and in CatVape's tests Killaura with Attack range 18 landed hits out to about 17.5 studs, so going above 18 does not help. A few weapons have their own range, like the battle axe (21) and the diamond great hammer (15)."
        },
        {
            Game = "BedWars",
            Modules = {"AutoBuy"},
            Ask = "How much is an iron sword?",
            Keywords = "sword swords price prices cost costs buy buying stone iron diamond emerald wood damage shop",
            Text = "Swords cost 20 iron (stone), 70 iron (iron), 4 emeralds (diamond) and 20 emeralds (emerald). Before armor they hit for 20 with wood, 25 with stone, 30 with iron, 42 with diamond and 55 with emerald."
        },
        {
            Game = "BedWars",
            Modules = {"AutoBuy", "ArmorSwitch"},
            Keywords = "armor armour chestplate leather iron diamond emerald price prices cost costs buy reduce reduces reduction protect protection block blocks damage set",
            Text = "Armor costs 50 iron (leather), 120 iron (iron), 8 emeralds (diamond) and 40 emeralds (emerald), and buying it gives you the full set. A full set blocks about 36% of damage with leather, 56% with iron and 76% with diamond."
        },
        {
            Game = "BedWars",
            Modules = {"BedProtector", "Block-In", "Scaffold", "AutoBuy"},
            Keywords = "wool block blocks stone brick bricks health hp strong stronger strongest strength price cost costs buy defense defend cover protect hits",
            Text = "Wool costs 8 iron for 16 blocks and each block has 8 health. Stone bricks cost 40 iron for 16 and have 75 health each, so they hold a bed far longer. BedProtector covers your bed with the strongest blocks you carry."
        },
        {
            Game = "BedWars",
            Modules = {"BedESP", "BedPlates", "BedAssist"},
            Accent = {"Health Bar"},
            Keywords = "bed beds health hp damage damaged hit hits see show strong break left",
            Text = "A bed has 24 health. The game keeps its damage on the block, not on the bed model, so it is easy to miss. BedESP with Health Bar on shows how damaged every bed is, including hits from other players, and BedPlates shows the blocks covering it."
        },
        {
            Game = "BedWars",
            Modules = {"ProjectileAimbot", "ProjectileAura", "BowAssist", "AutoBuy"},
            Keywords = "bow bows arrow arrows crossbow telepearl pearl pearls fireball fireballs tnt grapple grappling hook void axe price prices cost costs buy shop damage",
            Text = "A wood bow costs 24 iron and arrows are 16 iron for 8, each hitting for 18. A telepearl is 2 emeralds, a fireball 75 iron, TNT 35 iron, a void axe 40 iron and a grappling hook 7 emeralds."
        },
        {
            Game = "BedWars",
            Modules = {"ProjectileAimbot", "ProjectileAura", "BowAssist"},
            Keywords = "arrow arrows bow crossbow projectile projectiles speed fast travel gravity drop far range lead predict prediction charge",
            Text = "Arrows leave at 240 studs a second (400 from a crossbow), drop with gravity 35 and disappear after 2.8 seconds. Charging a bow only changes the speed. ProjectileAimbot leads moving and jumping targets for you."
        },
        {
            Game = "BedWars",
            Modules = {"GeneratorESP", "PickupRange"},
            Keywords = "generator generators gen gens team iron diamond diamonds emerald emeralds spawn spawns spit spits drop drops often fast rate make makes produce produces second seconds resources farm farming",
            Text = "Your team's iron generator makes about 1.1 iron a second. At their first tier, diamond generators drop one diamond every 35 seconds and hold up to 5, and emerald generators drop one every 70 seconds and hold up to 3. GeneratorESP shows the time until the next drop."
        },
        {
            Game = "BedWars",
            Modules = {"AutoBuy", "TeamUpgrades"},
            Keywords = "team upgrade upgrades cost costs price diamond diamonds armor protection damage sharpness generator gen break speed tier tiers buy",
            Text = "In solo matches team upgrades cost diamonds per tier: Team generator 4/8/16 (+50% and +100% iron, then emeralds at your base), Armor 4/8/20 (+10/20/30% protection), Damage 5/10/18 (+5/10/20%), Diamond generator 3/6/10 and Break speed 3/6/15. Team generator tier 1 is the cheapest boost."
        },
        {
            Game = "BedWars",
            Accent = {"Killaura"},
            Ask = "What does a Diamond Guardian drop?",
            Keywords = "diamond guardian guardians boss health hp damage drop drops kill killing reward loot spawn spawns when time guard",
            Text = "Diamond Guardians stand on the diamond generators. They have 450 health, hit for about 8 before armor, go after anyone within 15 studs and drop 3 diamonds when killed. By default they spawn at 3, 8 and 12 minutes, but some modes change that or turn them off. Killaura attacks them too.",
            Live = function(): string
                local Count: number = #cloneref(game:GetService("CollectionService")):GetTagged("DiamondGuardian")
                return Count == 0 and "None have spawned in this server yet." or `{Accent(tostring(Count))} {Count == 1 and "is" or "are"} up in this server right now.`
            end
        },
        {
            Game = "BedWars",
            Modules = {"AutoReset"},
            Keywords = "respawn respawns respawning timer time long wait death die dies dead final kill bedless eliminated",
            Text = "After a normal death you respawn in about 3.6 seconds, going by the matches CatVape measured. Once your bed is gone your next death is final. Players who were already dead when their bed broke still respawn one more time."
        },
        {
            Game = "BedWars",
            Modules = {"RegionLock", "AutoMatchDodge"},
            Keywords = "region regions server servers na eu sea asia asian oce oceania aus australia australian europe european america american pick choose change select ping country location",
            Text = "BedWars only hosts servers in NA, EU and SEA, and Australia, New Zealand and Singapore all count as SEA. The lobby server decides your region from your account's country, so nothing on your side can move you to another region. RegionLock can only skip matches that land outside the regions you picked."
        },
        {
            Game = "BedWars",
            Modules = {"Speed", "Fly", "AutoWin", "LongJump"},
            Accent = {"Move boost"},
            Keywords = "anticheat flag flagged flagging flags detect detected detection detectable bannable ban bans banned lagback lagbacks lagbacked rubberband rubberbanding speed fast faster horizontal vertical sideways teleport teleporting safe limit",
            Text = "The anticheat watches how fast you move sideways, so keep horizontal speed modest: around 22 held up in CatVape's own matches, and AutoWin's Move boost above 2 gets flagged. Vertical movement is different, even a big teleport straight up is not flagged."
        },
        {
            Game = "BedWars",
            Modules = {"Fly", "TPDown", "InfiniteFly", "AutoWin"},
            Accent = {"TP Down"},
            Ask = "Why do I get lagbacked while flying?",
            Keywords = "air hover hovering float floating fly flying long stay time seconds lagback lagbacks lagbacked back flung dropped owner ownership touch ground",
            Text = "If you stay off the ground for more than about 2.4 seconds the server takes control of your character and drops it, which is what a lagback mid flight usually is. Touch the ground now and then, Fly's TP Down option and the TPDown module do that for you."
        },
        {
            Game = "BedWars",
            Modules = {"NoFall", "TPDown", "AutoWin"},
            Keywords = "fall falling damage drop drops dropping high height far formula teleport teleports hurt hurts die death land landing",
            Text = "The server works out fall damage itself: about the height of the drop minus 21 studs, measured from your highest point since you last touched the ground. NoFall protects normal falls, even 100 stud ones, but a teleport straight down still hurts past 21 studs, so keep teleport drops under that."
        },
        {
            Game = "BedWars",
            Modules = {"Speed", "AutoWin", "Fly", "LongJump"},
            Keywords = "speed stand standing still stuck stall stalls stop stops stopped move moving movement velocity blatant frozen freeze freezes walk walking",
            Text = "Speed's Blatant mode rewrites your sideways velocity every frame, and with no key held that is zero, so anything that moves you by velocity stands still while it is on. Speed steps aside for Fly and LongJump, and AutoWin moves by position now, so they keep working. If another module stalls, try it with Speed off."
        },
        {
            Game = "BedWars",
            Modules = {"InfiniteFly", "Fly", "LongJump", "HighJump", "InfiniteJump", "Scaffold"},
            Keywords = "while stop stops blocked disabled together same time land landed landing work working",
            Text = "While InfiniteFly is on, Fly, InfiniteJump, HighJump, LongJump, AntiFall, Scaffold, Spider, Phase, TargetStrafe and Swim stand down until it has fully landed. Speed keeps working. Turn InfiniteFly off and wait for the landing before using them."
        },
        {
            Game = "BedWars",
            Modules = {"AutoBuy", "AutoWin"},
            Keywords = "iron spend spends spending spent buy buys bought walk walks walked gone already fight fighting together conflict resources shop shops steal steals",
            Text = "AutoBuy buys the moment you are near a shop, so next to AutoWin it often spends the iron AutoWin walked there for. AutoWin copes with that now, but turn AutoBuy off if you want AutoWin to pick every purchase."
        },
        {
            Game = "BedWars",
            Modules = {"AutoKit", "KitESP", "AutoBuy"},
            Keywords = "fusion fused two both combined hyper second first only react reacts one",
            Text = "Kit Fusion gives you two kits at once. AutoKit, KitESP and AutoBuy handle both, but most of the single kit Auto modules in Kits only react to your first kit."
        },
        {
            Game = "BedWars",
            Modules = {"KitDisplay"},
            Keywords = "kit best good recommend recommended should pick choose strongest op main which",
            Text = "The best kit depends on how you play, and it changes with every balance update, so I will not rank them. Whatever you pick, AutoKit uses its ability for you, most kits also have their own Auto module in the Kits window, and KitDisplay shows what your opponents picked in the draft."
        },
        {
            Game = "BedWars",
            Modules = {"AutoZephyr"},
            Keywords = "zephyr air jump jumps double orb orbs wind",
            Text = "Zephyr gets 2 air jumps once it has 5 orbs and loses them when it drops below 5. Air jumps need a quarter second between them and come back when you land. AutoZephyr spends one right before TP Down would pull you down."
        },
        {
            Game = "BedWars",
            Modules = {"LongJump"},
            Keywords = "long jump item items kit kits need needs dao dash dasher cannon cat jade hammer grapple grappling hook fireball tnt boost launch cooldown",
            Text = "LongJump launches you off a kit or item: the Dasher dao, a cannon, the cat kit, a jade hammer or void axe, a grappling hook, or the blast of your own fireball or TNT, so you need one of those on you. Dasher's dash has a 3 second cooldown."
        },
        {
            Game = "BedWars",
            Modules = {"InventoryESP"},
            Keywords = "kill killer killing loot resources iron diamonds emeralds carry carrying take takes drop drops inventory enemy enemies someone see holding",
            Text = "The killer takes the iron, diamonds and emeralds the victim was carrying, so rich players are worth hunting. InventoryESP shows what your current target is holding and wearing."
        },
        {
            Game = "BedWars",
            Modules = {"AutoPearlAggro", "AutoPearl"},
            Keywords = "pearl pearls aggro mode gone removed happened missing follow follows chase enemy thrown throw lands",
            Text = "AutoPearl's Aggro mode is its own module now, AutoPearlAggro. It predicts where an enemy's pearl will land the moment it is thrown and pearls you to the same spot. AutoPearl itself only saves you when you fall into the void."
        },
        {
            Game = "BedWars",
            Modules = {"AutoReset"},
            Keywords = "reset resets void fall falling clutch pearl whisper owl lasso early",
            Text = "AutoReset only resets once you are below the void line and still falling with nothing under you. It holds off while a telepearl, a Whisper owl lift or a lasso could still save you."
        },
        {
            Game = "BedWars",
            Modules = {"KitDisplay"},
            Accent = {"Show previous kits"},
            Keywords = "kit kits draft previous history opponent opponents other team see pick picks picked last matches",
            Text = "KitDisplay shows each opponent's kit during the match draft, and with Show previous kits on it also shows the kits they played in their last 8 matches."
        },
        {
            Game = "BedWars",
            Modules = {"Scaffold", "Block-In", "Clutch"},
            Keywords = "block blocks size big grid studs one each tall height gap gaps fit walk under character wide long",
            Text = "Blocks are 3 studs on every side and sit on a 3 stud grid. Your character is two blocks tall, so a one block gap is too low to walk through."
        },
        {
            Game = "BedWars",
            Modules = {"PickupRange"},
            Keywords = "pickup pick collect collecting range far close near distance items drops generator gen grab",
            Text = "The game picks up generator drops within about 6 studs of you. PickupRange grabs them from farther, set by its Range slider."
        },
        {
            Game = "BedWars",
            Modules = {"AntiSuffocate"},
            Keywords = "suffocate suffocating suffocation stuck inside block blocks trapped damage dying placed lost lose half instantly hp",
            Text = "Being stuck inside blocks deals 10 damage every tenth of a second, so it kills in about a second. AntiSuffocate moves you out or breaks the block first."
        },
        {
            Game = "BedWars",
            Modules = {"AutoWin", "Killaura"},
            Accent = {"Move boost", "Speedrun", "Sky travel"},
            Keywords = "setup tips tip recommend recommended advice running",
            Text = "AutoWin plays the whole match, weighing beds, kills, farming and retreating and committing to the best one. Keep Killaura on, AutoWin only lands hits inside Killaura's Attack range. Leave Move boost at 2 or lower, higher gets flagged. Speedrun rushes the nearest beds and only buys gear with loot, and Sky travel flies straight over voids to far targets."
        },
        {
            Game = "BedWars",
            Modules = {"AutoWin"},
            Keywords = "win winning wins strategy strat rush beat pro tactic tactics tips tip trash improve",
            Text = "What wins most games: rush the closest bed early, final kill each bedless player right after, and buy with the loot you take from kills. A stone sword (20 iron) decides most early fights. Stop anyone farming emeralds before they get diamond gear, a diamond geared player guarding emeralds is very hard to beat."
        },
        {
            Game = "BedWars",
            Modules = {"AimAssist"},
            Keywords = "focus focused unfocused tabbed alt background minimized mouse camera",
            Text = "BedWars' AimAssist turns your camera, or your character in third person, instead of moving your real mouse, so it does not depend on the Roblox window being focused."
        },
        {
            Except = "BedWars",
            Modules = {"AimAssist"},
            Keywords = "focus focused unfocused tabbed alt background minimized mouse camera",
            Text = "AimAssist moves your real mouse, so it only works while the Roblox window is focused. Tabbed out, or on a second client, it does nothing."
        },
        {
            Modules = {"ProjectileAimbot", "AutoChargeProj"},
            Keywords = "executor executors solara xeno free paid work works working support supported debug unc sunc best which injector",
            Text = "CatVape runs best on an executor with a full debug library and good sUNC support. Solara and Xeno have no debug library, so in BedWars modules that hook the game's own controllers, like AutoChargeProj, silently do nothing there. ProjectileAimbot still aims on them by turning your camera for the instant a shot releases, but Auto Charge is unavailable."
        },
        {
            Accent = {"Export config"},
            Keywords = "config configs profile profiles saved save stored store where folder file files location workspace directory",
            Text = `Profiles are saved in the {vape.Directory}/profiles folder of your executor's workspace, one file per profile for each game, plus a .gui.txt file per game for your window layout. Export config in the Profiles gear gives you the whole setup as text instead.`
        },
        {
            Keywords = "preset presets default legit silent profile profiles new update updates updated download downloaded install fresh didnt",
            Text = "The default, legit and silent preset profiles only download on new installs. Updates never touch the profiles you already have, so an existing install keeps its own settings."
        },
        {
            Keywords = "mobile phone ipad tablet android ios touch support supported work works run runs",
            Text = "Yes, CatVape works on mobile executors. Tap the CatVape button in the top bar to open the GUI, and hold a module for a second to place a button for it on your screen."
        },
        {
            Accent = {"Hide CatVape Button"},
            Keywords = "button missing gone hidden disappeared disappear invisible top bar icon mobile phone ipad tablet find anymore",
            Text = "The CatVape button sits in the top bar on mobile. If it is gone, Hide CatVape Button in the GUI settings is probably on. That only makes it invisible, so tap the same spot to open the GUI and turn the setting off there."
        },
        {
            Except = "IllegalSoccer",
            Modules = {"Anti-AFK"},
            Keywords = "afk idle kick kicked kicks away long until minute minutes timeout disconnect disconnected",
            Text = "Roblox kicks you after 20 minutes without any input. Anti-AFK stops that."
        },
        {
            Game = "IllegalSoccer",
            Modules = {"Anti-AFK"},
            Ask = "How long until I get AFK kicked?",
            Keywords = "afk idle kick kicked kicks away long until minute minutes second seconds timeout lobby pulled",
            Text = "Illegal Soccer pulls you out of a match after 60 seconds without moving, or 120 seconds as goalkeeper, with a warning 30 seconds before. Anti-AFK keeps you in, and anything that plays for you needs it on."
        },
        {
            Game = "IllegalSoccer",
            Modules = {"ShotRedirect", "PerfectShot"},
            Ask = "Why do my shots go where I aimed earlier?",
            Keywords = "shot shots shoot shooting aim aimed aiming lock locked earlier late release released where wrong direction miss misses charge charging",
            Text = "Your shot's aim locks 0.3 seconds into the charge, a tenth of a second before full power, and the server launches along that locked aim instead of where you point when you let go. Letting go before the lock uses your aim at release. ShotRedirect aims at the lock for you."
        },
        {
            Game = "IllegalSoccer",
            Modules = {"ShotRedirect", "GoalESP"},
            Keywords = "goal goals size big wide width high height tall corner corners bar crossbar post score scoring top",
            Text = "The goal mouth is 36 studs wide and 12 high. A shot goes in cleanly when the ball's centre crosses within 17 studs of the middle and between 2 and 12 studs up, any higher clips the bar. Shots launch at 30 degrees at most, so from closer than about 16 studs you cannot reach the top corners."
        },
        {
            Game = "IllegalSoccer",
            Modules = {"AutoVolley"},
            Keywords = "volley volleys green ball indicator lock catch air flying",
            Text = "When the ball shows the green indicator a volley is open: press Kick or Pass while it shows and the ball locks onto your foot. AutoVolley presses it for you."
        },
        {
            Game = "IllegalSoccer",
            Keywords = "item items box boxes equip use using bazooka jetpack magnet oil landmine landmines barricade barricades shotgun freeze gun flintlock forcefield rocket punch energy drink supercharge grapple",
            Text = "Running into an item box on the field gives you one of the items you own. Tap its item key to equip it and press Kick to use it, tapping the key again unequips it. You cannot control the ball while an item is equipped."
        },
        {
            Game = "TowerOfHell",
            Ask = "How high can I jump?",
            Keywords = "jump jumps jumping high height far gap gaps edge ledge climb step steps tall reach",
            Text = "A jump in Tower of Hell rises about 7.2 studs, and the ledge snap lifts you roughly 1.75 more. Walking off an edge you stay grounded for about 0.4 studs past it, so jump right at the edge for the longest reach."
        },
        {
            Game = "TowerOfHell",
            Modules = {"AutoPlay"},
            Keywords = "stuck fail fails failing section sections plan climb climbing stop stops idle standing tower",
            Text = "AutoPlay cannot plan every section yet. Moving platforms, sections built right at the jump limit like Gateway, and steps taller than a jump are where it gets stuck. The tower changes every few minutes, so the next one may go better."
        }
    }

    for _, Fact: any in Facts do
        Fact.Terms = {}
        AddTerms(Fact.Terms, Fact.Keywords, 1)

        for Term: string in Fact.Terms do
            FactFrequency[Term] = (FactFrequency[Term] or 0) + 1
        end
    end

    local function CurrentGame(): string?
        for Name: string, Ids: {number} in GameIds do
            if table.find(Ids, game.GameId) or table.find(Ids, game.PlaceId) then
                return Name
            end
        end

        return nil
    end

    local function FactFits(Fact, Game: string?): boolean
        return (not Fact.Game or Fact.Game == Game) and (not Fact.Except or Fact.Except ~= Game)
    end

    local function FactOverlap(Fact, Query: {[string]: number}, Skip: {[string]: boolean}?): (number, number)
        local Score, Count = 0, 0
        for Term: string, Weight: number in Query do
            if Fact.Terms[Term] and not (Skip and Skip[Term]) then
                Score += Weight * math.log((#Facts + 1) / (FactFrequency[Term] + 0.5))
                Count += 1
            end
        end

        return Score, Count
    end

    local function FindFact(Query: {[string]: number}, Mentions: {any}, Covered: {[string]: boolean}?)
        local Game: string? = CurrentGame()
        local Best, BestScore, BestTopic, BestCount = nil, 0, 0, 0

        for _, Fact: any in Facts do
            if FactFits(Fact, Game) then
                local Skip: {[string]: boolean} = table.clone(Covered or {})
                local Linked: number = 0
                for _, Entry: any in Mentions do
                    if Fact.Modules and table.find(Fact.Modules, Entry.Name) then
                        Skip[Stem(Entry.Key)] = true
                        Linked += 1
                    end
                end

                local Topic, Count = FactOverlap(Fact, Query, Skip)
                local Score: number = Topic > 0 and Topic + Linked * 1.2 + (Fact.Game and 0.3 or 0) or 0
                if Score > BestScore then
                    Best, BestScore, BestTopic, BestCount = Fact, Score, Topic, Count
                end
            end
        end

        return Best, BestScore, BestTopic, BestCount
    end

    local function FactsFor(Entry, Query: {[string]: number}?, Option): {any}
        local Game: string? = CurrentGame()
        local Found = {}
        for i: number, Fact: any in Facts do
            if FactFits(Fact, Game) and Fact.Modules and table.find(Fact.Modules, Entry.Name) then
                local Named: boolean = false
                for _, Name: string in Option and Fact.Options or {} do
                    Named = Named or Normalize(Name) == Normalize(Option.Name)
                end

                if not Option or Named then
                    table.insert(Found, {
                        Fact = Fact,
                        Order = i,
                        Primary = Fact.Modules[1] == Entry.Name,
                        Score = (Query and FactOverlap(Fact, Query) or 0) + (Named and 5 or 0)
                    })
                end
            end
        end

        table.sort(Found, function(A, B)
            if A.Score ~= B.Score then
                return A.Score > B.Score
            elseif A.Primary ~= B.Primary then
                return A.Primary
            end

            return A.Order < B.Order
        end)

        return Found
    end

    local function FactText(Fact): string
        local Text: string = Fact.Text
        local Names: {string} = table.clone(Fact.Modules or {})
        for _, Name: string in Fact.Accent or {} do
            table.insert(Names, Name)
        end

        local Marked: {[string]: boolean} = {}
        for _, Name: string in Names do
            local Start, Finish = Text:find(Name, 1, true)
            while Start and not Marked[Name] do
                local Before: string = Text:sub(Start - 1, Start - 1)
                local After: string = Text:sub(Finish + 1, Finish + 1)
                if not Before:match("[%w<]") and not After:match("[%w>]") then
                    Text = `{Text:sub(1, Start - 1)}{Accent(Name)}{Text:sub(Finish + 1)}`
                    Marked[Name] = true
                else
                    Start, Finish = Text:find(Name, Finish + 1, true)
                end
            end
        end

        return Text
    end

    local function SampleAsk(): string?
        local Game: string? = CurrentGame()
        local Asks: {string} = {}
        for _, Fact: any in Facts do
            if Fact.Ask and Fact.Game and Fact.Game == Game then
                table.insert(Asks, Fact.Ask)
            end
        end

        return #Asks > 0 and Asks[math.random(1, #Asks)] or nil
    end

    local function Tips(Entry, Query: {[string]: number}?, Count: number, Option): {string}
        local Lines: {string} = {}
        for _, Found: any in FactsFor(Entry, Query, Option) do
            if #Lines < Count and (Found.Score > 0 or Found.Primary or Option) then
                table.insert(Lines, FactText(Found.Fact))
            end
        end

        return Lines
    end

    local function AddChip(Parent: GuiObject, Text: string, Position: UDim2, Width: number, Callback: () -> ()): TextButton
        local Chip: TextButton = Instance.new("TextButton")
        Chip.AutoButtonColor = false
        Chip.BackgroundColor3 = Color.Light(UIPallet.Main, 0.04)
        Chip.FontFace = UIPallet.Font
        Chip.Position = Position
        Chip.Size = UDim2.fromOffset(Width, 24)
        Chip.Text = Text
        Chip.TextColor3 = Color.Dark(UIPallet.Text, 0.1)
        Chip.TextSize = 12
        Chip.TextTruncate = Enum.TextTruncate.AtEnd
        Chip.Parent = Parent
        AddCorner(Chip, UDim.new(1, 0))
        local ChipStroke: UIStroke = Instance.new("UIStroke")
        ChipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ChipStroke.Color = Color.Light(UIPallet.Main, 0.16)
        ChipStroke.Parent = Chip

        Chip.MouseEnter:Connect(function()
            Tween:Tween(Chip, UIPallet.Tween, {
                BackgroundColor3 = Color.Light(UIPallet.Main, 0.12)
            })
        end)

        Chip.MouseLeave:Connect(function()
            Tween:Tween(Chip, UIPallet.Tween, {
                BackgroundColor3 = Color.Light(UIPallet.Main, 0.04)
            })
        end)

        Chip.MouseButton1Click:Connect(function()
            if vape.ThreadFix then
                setthreadidentity(8)
            end

            Callback()
        end)

        return Chip
    end

    local function AddMessage(Text: string, FromUser: boolean, Actions: {any}?, Muted: boolean?, Note: string?): (Frame, TextLabel)
        if vape.ThreadFix then
            setthreadidentity(8)
        end

        if Assistant and Assistant.Mode == "Landing" then
            Assistant:SetMode("Chat")
        end

        if History and not Muted then
            History.Record(Text, FromUser, Note)
        end

        MessageCount += 1
        local Width: number = FromUser and math.min(math.ceil(GetFontBounds(Text, 13, UIPallet.Font).X) + 2, UserWidth) or LabelWidth
        local TextHeight: number = math.ceil(GetFontBounds(FromUser and Text or RemoveTags(Text), 13, UIPallet.Font, Width).Y)
        local PaddingX: number = FromUser and 14 or 0
        local PaddingY: number = FromUser and 9 or 2
        local Top: number = Note and not FromUser and 30 or 0
        local ActionsHeight: number = 0

        local Row: Frame = Instance.new("Frame")
        Row.BackgroundTransparency = 1
        Row.LayoutOrder = MessageCount
        Row.Parent = Chat
        local Bubble: Frame = Instance.new("Frame")
        Bubble.AnchorPoint = Vector2.new(FromUser and 1 or 0, 0)
        Bubble.BackgroundColor3 = Color.Light(UIPallet.Main, 0.1)
        Bubble.BackgroundTransparency = FromUser and 0 or 1
        Bubble.Position = UDim2.fromScale(FromUser and 1 or 0, 0)
        Bubble.Parent = Row
        AddCorner(Bubble, UDim.new(0, 16))
        local Label: TextLabel = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.FontFace = UIPallet.Font
        Label.Position = UDim2.fromOffset(PaddingX, PaddingY + Top)
        Label.RichText = not FromUser
        Label.Size = UDim2.fromOffset(Width, TextHeight)
        Label.Text = Text
        Label.TextColor3 = Muted and Color.Dark(UIPallet.Text, 0.4) or UIPallet.Text
        Label.TextSize = 13
        Label.TextWrapped = true
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Top
        Label.Parent = Bubble

        if Top > 0 then
            local NoteLabel: TextLabel = Instance.new("TextLabel")
            NoteLabel.BackgroundTransparency = 1
            NoteLabel.FontFace = UIPallet.Font
            NoteLabel.Size = UDim2.fromOffset(Width, 16)
            NoteLabel.Text = Note
            NoteLabel.TextColor3 = Color.Dark(UIPallet.Text, 0.45)
            NoteLabel.TextSize = 12
            NoteLabel.TextXAlignment = Enum.TextXAlignment.Left
            NoteLabel.Parent = Bubble
            local NoteLine: Frame = Instance.new("Frame")
            NoteLine.BackgroundColor3 = Color3.new(1, 1, 1)
            NoteLine.BackgroundTransparency = 0.928
            NoteLine.BorderSizePixel = 0
            NoteLine.Position = UDim2.fromOffset(0, 22)
            NoteLine.Size = UDim2.fromOffset(Width, 1)
            NoteLine.Parent = Bubble
        end

        if Actions and #Actions > 0 then
            local X, Y = 0, 0
            for _, Action: any in Actions do
                local ButtonWidth: number = math.min(math.ceil(GetFontBounds(Action.Text, 12, UIPallet.Font).X) + 22, Width)
                if X > 0 and X + ButtonWidth > Width then
                    X, Y = 0, Y + 30
                end

                AddChip(Bubble, Action.Text, UDim2.fromOffset(PaddingX + X, PaddingY + Top + TextHeight + 10 + Y), ButtonWidth, Action.Callback)
                X += ButtonWidth + 6
            end

            ActionsHeight = Y + 34
        end

        local Height: number = Top + TextHeight + ActionsHeight + PaddingY * 2
        Bubble.Size = UDim2.fromOffset(Width + PaddingX * 2, Height)
        Row.Size = UDim2.new(1, 0, 0, Height)

        table.insert(Rows, Row)
        while #Rows > MaxMessages do
            table.remove(Rows, 1):Destroy()
        end

        return Row, Label
    end

    local function RemoveMessage(Row: Frame)
        local Position: number? = table.find(Rows, Row)
        if Position then
            table.remove(Rows, Position)
        end

        Row:Destroy()
    end

    local function Reply(Result, Note: string?)
        AddMessage(Result.Text, false, Result.Actions, nil, Note)
    end

    local function ClearChat()
        for _, Row: Frame in Rows do
            Row:Destroy()
        end
        table.clear(Rows)

        MessageCount = 0
        LastTopic = nil

        if Brain and Brain.ResetContext then
            Brain.ResetContext()
        end

        if History then
            History.Current = nil
        end

        if Assistant then
            Assistant:SetMode("Landing")
        end
    end

    local function ShowModule(Entry, Option, Expand: boolean?)
        if vape.ThreadFix then
            setthreadidentity(8)
        end

        if Option then
            Highlight(RevealOption(Entry, Option), Option.Name)
        else
            Highlight(RevealModule(Entry, Expand), Entry.Name)
        end
    end

    local function ShowBind(Entry)
        RevealModule(Entry)
        Entry.Module.Bind:SetVisible(true)
        Highlight(Entry.Module.Bind.Object, "Click here, then press a key")
    end

    local function OpenAction(Place)
        return {
            Text = "Open it",
            Callback = function()
                local Object = Place.Open()
                Highlight(typeof(Object) == "Instance" and Object or nil, Place.Name)

                Reply({Text = Place.Done or `Opened {Place.Name}.`})
            end
        }
    end

    local function PlaceActions(Place)
        if not Place then return nil end

        local Actions = {
            {
                Text = "Show me",
                Callback = function()
                    Highlight(Place.Target(), Place.Hint)
                end
            }
        }

        if Place.Open then
            table.insert(Actions, OpenAction(Place))
        end

        return Actions
    end

    local function Suggestions()
        local Sample: string? = SampleModule()
        local Questions: {string} = {"How do I bind a module?", "Show me the Legit menu", "What's new?"}
        local Ask: string? = SampleAsk()
        if Sample then
            table.insert(Questions, 2, `What does {Sample} do?`)
        end

        if Ask then
            table.insert(Questions, 3, Ask)
        end

        local Actions = {}
        for _, Question: string in Questions do
            table.insert(Actions, {
                Text = Question,
                Callback = function()
                    Send(Question)
                end
            })
        end

        return Actions
    end

    local function ModuleActions(Entry, Option)
        local Actions = {
            {
                Text = "Show me",
                Callback = function()
                    ShowModule(Entry, Option)
                end
            },
            {
                Text = "Toggle",
                Callback = function()
                    Entry.Module:Toggle()
                    Reply({Text = `Turned {Accent(Entry.Name)} {Entry.Module.Enabled and "on" or "off"}.`})
                end
            }
        }

        if #Entry.Options > 0 then
            table.insert(Actions, {
                Text = "Settings",
                Callback = function()
                    Send(`{Entry.Name} settings`)
                end
            })
        end

        return Actions
    end

    local function SetModule(Entry, Action: string)
        local Module = Entry.Module
        local Wanted: boolean = Action == "On" or (Action == "Toggle" and not Module.Enabled)

        if Module.Enabled == Wanted then
            return {Text = `{Accent(Entry.Name)} is already {Wanted and "on" or "off"}.`, Actions = ModuleActions(Entry)}
        end

        Module:Toggle()
        return {Text = `Turned {Accent(Entry.Name)} {Wanted and "on" or "off"}.`, Actions = ModuleActions(Entry)}
    end

    local function DescribeReply(Entry, Query: {[string]: number}?)
        local Module = Entry.Module
        local Tooltip: string = Plain(Module.Tooltip)
        local Tag: string? = GetFeatureTag(Entry.Name)
        local Lines: {string} = {
            `{Accent(Entry.Name)} is in {WhereText(Entry)} and is {Module.Enabled and "on" or "off"} right now.{Tag == "new" and " It was added in the latest update." or Tag == "updated" and " It was improved in the latest update." or ""}`,
            Tooltip ~= "" and Escape(Tooltip) or "It does not have a description yet."
        }

        if #Entry.Options > 0 then
            local Names: {string} = {}
            for i: number = 1, math.min(3, #Entry.Options) do
                table.insert(Names, Entry.Options[i].Name)
            end

            table.insert(Lines, `It has {#Entry.Options} setting{#Entry.Options == 1 and "" or "s"}, like {table.concat(Names, ", ")}.`)
        end

        local Keys: string? = Module.Bind and GetKeys(Module.Bind.Keys)
        if Keys then
            table.insert(Lines, `It is bound to {Accent(Keys)}.`)
        end

        local Tip: string? = Tips(Entry, Query, 1)[1]
        if Tip then
            table.insert(Lines, `Good to know: {Tip}`)
        end

        return {Text = table.concat(Lines, "\n\n"), Actions = ModuleActions(Entry)}
    end

    local function SettingsReply(Entry)
        if #Entry.Options == 0 then
            return {Text = `{Accent(Entry.Name)} has no settings, you just turn it on or off.`, Actions = ModuleActions(Entry)}
        end

        local Lines: {string} = {`{Accent(Entry.Name)} has {#Entry.Options} setting{#Entry.Options == 1 and "" or "s"}:`}
        for i: number = 1, math.min(12, #Entry.Options) do
            local Option = Entry.Options[i]
            local Summary: string = FirstSentence(Plain(Option.Settings.Tooltip))
            table.insert(Lines, `- {Option.Name} ({DescribeKind(Option)}){Summary ~= "" and `: {Escape(Summary)}` or ""}`)
        end

        if #Entry.Options > 12 then
            table.insert(Lines, `...and {#Entry.Options - 12} more.`)
        end

        table.insert(Lines, `\nAsk me about one of them, or {IsMobile() and "tap the three dots on" or "right click"} {Entry.Name} in the GUI to change them.`)

        local Tip: string? = Tips(Entry, nil, 1)[1]
        if Tip then
            table.insert(Lines, `\nGood to know: {Tip}`)
        end

        return {Text = table.concat(Lines, "\n"), Actions = ModuleActions(Entry)}
    end

    local function TargetReply(Entry, Option)
        local Component = Option.Option or {}
        local Picked: {string} = {}
        for _, Kind: string in {"Players", "NPCs"} do
            if Component[Kind] and Component[Kind].Enabled then
                table.insert(Picked, Kind)
            end
        end

        local Ignored: {string} = {}
        if Component.Invisible and Component.Invisible.Enabled then
            table.insert(Ignored, "invisible players")
        end

        if Component.Walls and Component.Walls.Enabled then
            table.insert(Ignored, "players behind walls")
        end

        local State: string = `Right now it goes after {#Picked > 0 and Accent(JoinNames(Picked, 2)) or "nothing"}`
        if #Ignored > 0 then
            State = `{State}, skips {JoinNames(Ignored, 2)}`
        end

        if Component.Priority and Component.Priority.Value then
            State = `{State} and picks by {Accent(Component.Priority.Value)} first`
        end

        return {
            Text = `The {Accent(Option.Name)} setting in {Accent(Entry.Name)} decides who it goes after. Click it to choose Players or NPCs, ignore invisible players or players behind walls, and set the Priority.\n\n{State}.`,
            Actions = ModuleActions(Entry)
        }
    end

    local function OptionReply(Entry, Matches)
        local Option = Matches[1].Option
        if Option.Type == "Targets" then
            return TargetReply(Entry, Option)
        end

        local Tooltip: string = Plain(Option.Settings.Tooltip)
        local Value: string? = DescribeValue(Option)
        local Means: string? = Brain.Means(Entry, Option)
        local Note = Brain.OptionNotes[`{Entry.Name}/{Option.Name}`]
        local Lines: {string} = {
            `{Accent(Option.Name)} is a {DescribeKind(Option)} in {Accent(Entry.Name)}.`,
            Tooltip ~= "" and Escape(Tooltip) or Means and `It sets {Means}.{Note and Note.Limit and ` {Note.Limit}` or ""}` or "It does not have a description yet."
        }

        local List: {string}? = Option.Settings.List or (Option.Option and Option.Option.List)
        if Option.Type == "Dropdown" and List then
            table.insert(Lines, `Choices: {Escape(JoinNames(List, 10))}.`)
        end

        if Value then
            table.insert(Lines, `It is set to {Accent(Value)} right now.`)
        end

        local Others: {string} = {}
        for i: number = 2, math.min(3, #Matches) do
            if Matches[i].Score >= 0.5 then
                table.insert(Others, Matches[i].Option.Name)
            end
        end

        if #Others > 0 then
            table.insert(Lines, `You might also mean {table.concat(Others, " or ")}.`)
        end

        local Tip: string? = Tips(Entry, nil, 1, Option)[1]
        if Tip then
            table.insert(Lines, `Good to know: {Tip}`)
        end

        return {Text = table.concat(Lines, "\n\n"), Actions = ModuleActions(Entry, Option)}
    end

    local function BindReply(Entry)
        local Module = Entry.Module
        if Entry.Legit or not Module.Bind then
            return {Text = `Legit mods do not take keybinds. Click {Accent(Entry.Name)} in the Legit menu to turn it on or off.`, Actions = ModuleActions(Entry)}
        end

        if IsMobile() then
            return {Text = `Hold {Accent(Entry.Name)} in the GUI for a second, then tap where you want its button. Tap that button to toggle it, and hold it for a second to remove it.{Module.Bind.Mobile and " It already has a button on your screen." or ""}`, Actions = ModuleActions(Entry)}
        end

        local Keys: string? = GetKeys(Module.Bind.Keys)
        return {
            Text = `Open the GUI, hover {Accent(Entry.Name)} and click the bind icon on its right, then press a key. Shift click the icon to switch between toggling and running only while the key is held. Or just tell me, like "bind {Entry.Name} to R".\n\n{Keys and `It is bound to {Accent(Keys)}{Module.Bind.Hold and " and only runs while held" or ""} right now.` or "It has no bind yet."}`,
            Actions = {
                {
                    Text = "Show me",
                    Callback = function()
                        ShowBind(Entry)
                    end
                }
            }
        }
    end

    local function FavoriteReply(Entry)
        local Module = Entry.Module
        return {
            Text = `{Accent(Entry.Name)} is {Module.Favorited and "in" or "not in"} your favorites. Hover it in the GUI and click the star to change that, or use the button below.`,
            Actions = {
                {
                    Text = Module.Favorited and "Unfavorite" or "Favorite",
                    Callback = function()
                        Module:SetFavorite(not Module.Favorited)
                        Reply({Text = `{Module.Favorited and "Added" or "Removed"} {Accent(Entry.Name)} {Module.Favorited and "to" or "from"} your favorites.`})
                    end
                }
            }
        }
    end

    local function HideReply(Entry)
        local Module = Entry.Module
        if Entry.Legit then
            return {Text = `Legit mods cannot be hidden, but the search box in the Legit menu filters them.`, Actions = ModuleActions(Entry)}
        end

        return {
            Text = `Click the pencil on the {Entry.Category} window, then click the square next to {Accent(Entry.Name)} and press {Accent("DONE")}. It is {Module.Visible and "shown" or "hidden"} right now. Hidden modules keep working, they are just out of the list.`,
            Actions = {
                {
                    Text = Module.Visible and "Hide it" or "Show it",
                    Callback = function()
                        Module:SetVisible(not Module.Visible, true)
                        Reply({Text = `{Accent(Entry.Name)} is {Module.Visible and "back in" or "hidden from"} the {Entry.Category} window.`})
                    end
                }
            }
        }
    end

    local function WhereReply(Entry)
        ShowModule(Entry)

        if Entry.Legit then
            return {Text = `{Accent(Entry.Name)} is in the Legit menu, I opened it and highlighted it for you.`, Actions = ModuleActions(Entry)}
        end

        return {Text = `{Accent(Entry.Name)} is in the {Accent(Entry.Category)} window, I highlighted it for you.`, Actions = ModuleActions(Entry)}
    end

    local function UseReply(Entry)
        local How: string
        if Entry.Legit then
            How = "Click it to turn it on or off, and right click it for its settings."
        elseif IsMobile() then
            How = "Tap it to turn it on or off, and tap the three dots on its right for its settings."
        else
            How = "Left click it to turn it on or off, and right click it for its settings."
        end

        return {Text = `{Accent(Entry.Name)} is in {WhereText(Entry)}. {How} It is {Entry.Module.Enabled and "on" or "off"} right now.`, Actions = ModuleActions(Entry)}
    end

    local function TroubleReply(Entry, Query: {[string]: number}?, Tokens: any?)
        local Module = Entry.Module
        local Lines: {string} = {}
        local Steps: {string} = {}
        local Found = FactsFor(Entry, Query)
        local Symptom = Tokens and Brain.SymptomOf(Tokens, true)
        local Shown: number = 0

        if Found[1] and Found[1].Score > 0 then
            table.insert(Lines, FactText(Found[1].Fact))
            table.remove(Found, 1)
            Shown += 1
        end

        for _, Other: any in Found do
            if Shown < 2 and (Other.Score > 0 or Other.Primary) then
                table.insert(Lines, FactText(Other.Fact))
                Shown += 1
            end
        end

        if not Module.Enabled then
            table.insert(Steps, `{Accent(Entry.Name)} is off right now, so turn it on first.`)
        end

        for _, Option: any in Entry.Options do
            local Component = Option.Option
            if Option.Type == "Targets" and Component and Component.Players and Component.NPCs and not Component.Players.Enabled and not Component.NPCs.Enabled then
                table.insert(Steps, `Its {Accent(Option.Name)} setting has neither Players nor NPCs picked, so it has nothing to go after. Pick one.`)
            end
        end

        for _, Option: any in Brain.RelatedOptions(Entry, Tokens) do
            local Summary: string = FirstSentence(Plain(Option.Settings.Tooltip))
            local On: boolean = Option.Option and Option.Option.Enabled or false
            table.insert(Steps, `Check its {Accent(Option.Name)} setting, it's {On and "on" or "off"} right now{Summary ~= "" and ` ({Escape(Brain.Lower(Summary))})` or ""}.{On and " Turn it off if it's getting in the way." or ""}`)
        end

        local Rivals = Brain.Rivals(Entry, Symptom and Symptom.Resource)
        local Fighting = {}
        for i: number = 1, math.min(2, #Rivals) do
            local Rival = Rivals[i]
            table.insert(Fighting, Rival.Entry)
            table.insert(Steps, `Turn off {Accent(Rival.Entry.Name)} for a moment. It also {Brain.Resources[Rival.Resource].Does}, and if that fixes it, the two were fighting over it.`)
        end

        for _, Culprit: any in Tokens and Brain.Culprits(Tokens) or {} do
            if Culprit.Entry ~= Entry and not table.find(Fighting, Culprit.Entry) and #Fighting < 2 then
                table.insert(Fighting, Culprit.Entry)
                table.insert(Steps, `{Brain.CulpritLine(Culprit, "")} Try turning it off too, it could be getting in the way.`)
                break
            end
        end

        if Symptom then
            local State, Gate = Brain.Uses(Entry, Symptom.Resource)
            if State == "now" and Gate then
                table.insert(Steps, `{Accent(Entry.Name)} is {Symptom.Doing} because {Brain.GateClause(Gate)}, so {Brain.GateFix(Gate)} if you don't want that.`)
            end
        end

        if #Steps == 0 and Shown == 0 then
            table.insert(Steps, `Check its settings, a lot of problems come from them. Ask me "{Entry.Name} settings" to see them.`)
        end

        table.insert(Steps, "If it shows an error, press F9, copy the red line and paste it here, I'll tell you what it means. If it keeps happening, report it in the Discord.")
        table.insert(Lines, Brain.Numbered(Steps))
        table.insert(Lines, Brain.Narrow(Entry, Symptom))

        return {Text = table.concat(Lines, "\n\n"), Actions = Brain.Toggles(Fighting) or ModuleActions(Entry)}
    end

    local function MultiReply(Mentions, Action: string?)
        local Lines: {string} = {}
        local Actions = {}

        for _, Entry: any in Mentions do
            local Module = Entry.Module
            if Action then
                local Wanted: boolean = Action == "On" or (Action == "Toggle" and not Module.Enabled)
                if Module.Enabled ~= Wanted then
                    Module:Toggle()
                end

                table.insert(Lines, `{Accent(Entry.Name)} is {Wanted and "on" or "off"}`)
            else
                local Summary: string = FirstSentence(Plain(Module.Tooltip))
                table.insert(Lines, `- {Accent(Entry.Name)} ({Entry.Category}, {Module.Enabled and "on" or "off"}){Summary ~= "" and `: {Escape(Summary)}` or ""}`)
                table.insert(Actions, {
                    Text = Entry.Name,
                    Callback = function()
                        Send(`What does {Entry.Name} do?`)
                    end
                })
            end
        end

        if Action then
            return {Text = `Done, {JoinNames(Lines, #Lines)} now.`}
        end

        return {Text = `Here is how they compare:\n{table.concat(Lines, "\n")}`, Actions = Actions}
    end

    local function Changelog(): {string}
        local Features = isfile(`{vape.Directory}/features.json`) and LoadJSON(`{vape.Directory}/features.json`)
        local Text = type(Features) == "table" and Features.text
        if type(Text) ~= "string" then
            return {}
        end

        local Sections: {[string]: string} = {BedWars = "BEDWARS", IllegalSoccer = "ILLEGAL SOCCER", TowerOfHell = "TOWER OF HELL"}
        local Wanted: {[string]: boolean} = {GENERAL = true, UNIVERSAL = true}
        local Game: string? = CurrentGame()
        if Game then
            Wanted[Sections[Game]] = true
        end

        local Lines: {string} = {}
        local Section: string?
        for Line: string in Text:gsub("\27%[[%d;]*m", ""):gmatch("[^\r\n]+") do
            local Header: string? = Line:match("^%[([%u%s]+)%]%s*$")
            if Header then
                Section = Header
            elseif Section and Wanted[Section] then
                local Body: string? = Line:match("^%[.%]%s*(.+)$")
                if Body then
                    table.insert(Lines, Body)
                end
            end
        end

        return Lines
    end

    local function NewsReply(Entry)
        local Log: {string} = Changelog()
        if Entry then
            local Found: {string} = {}
            for _, Line: string in Log do
                local Start, Finish = Line:find(Entry.Name, 1, true)
                if Start and not Line:sub(Start - 1, Start - 1):match("%w") and not Line:sub(Finish + 1, Finish + 1):match("%w") then
                    table.insert(Found, `- {Escape(Line)}`)
                end
            end

            local Tag: string? = GetFeatureTag(Entry.Name)
            if #Found > 0 then
                return {Text = `What changed in {Accent(Entry.Name)} in the latest update:\n{table.concat(Found, "\n", 1, math.min(#Found, 6))}`, Actions = ModuleActions(Entry)}
            elseif Tag then
                return {Text = `{Accent(Entry.Name)} was {Tag == "new" and "added" or "improved"} in the latest update, the changelog just does not have its own line for it.`, Actions = ModuleActions(Entry)}
            end

            return {Text = `{Accent(Entry.Name)} did not change in the latest update.`, Actions = ModuleActions(Entry)}
        end

        local Added, Updated = {}, {}
        for _, Module: any in Index.Entries do
            local Tag: string? = GetFeatureTag(Module.Name)
            if Tag == "new" then
                table.insert(Added, Module.Name)
            elseif Tag == "updated" then
                table.insert(Updated, Module.Name)
            end
        end

        if #Log == 0 and #Added == 0 and #Updated == 0 then
            return {Text = "Nothing in this game is marked new or updated right now."}
        end

        local Lines: {string} = {}
        if #Log > 0 then
            local Shown: {string} = {}
            for i: number = 1, math.min(#Log, 6) do
                table.insert(Shown, `- {Escape(Log[i])}`)
            end

            table.insert(Lines, `From the latest update:\n{table.concat(Shown, "\n")}{#Log > 6 and `\n...and {#Log - 6} more. Ask me about one module, like "what changed in {Added[1] or Updated[1] or "Killaura"}".` or ""}`)
        end

        if #Added > 0 then
            table.insert(Lines, `New: {Accent(JoinNames(Added, 20))}.`)
        end

        if #Updated > 0 then
            table.insert(Lines, `Updated: {JoinNames(Updated, 20)}.`)
        end

        if #Added > 0 or #Updated > 0 then
            table.insert(Lines, "They carry a NEW or UPDATED tag in the GUI.")
        end

        local Actions = {}
        for i: number = 1, math.min(3, #Added) do
            local Name: string = Added[i]
            table.insert(Actions, {
                Text = Name,
                Callback = function()
                    Send(`What does {Name} do?`)
                end
            })
        end

        return {Text = table.concat(Lines, "\n\n"), Actions = Actions}
    end

    local function CategoryReply(Name: string)
        local Names: {string} = {}
        local Enabled: number = 0
        for _, Entry: any in Index.Entries do
            if (Name == "Legit" and Entry.Legit) or (not Entry.Legit and Entry.Category == Name) then
                table.insert(Names, Entry.Module.Enabled and Accent(Entry.Name) or Entry.Name)
                Enabled += Entry.Module.Enabled and 1 or 0
            end
        end

        local Where: string = Name == "Legit" and "The Legit menu" or `The {Name} window`
        if #Names == 0 then
            return {Text = `{Where} is empty in this game.`}
        end

        return {Text = `{Where} has {#Names} module{#Names == 1 and "" or "s"}: {table.concat(Names, ", ")}.{Enabled > 0 and "\n\nThe ones in color are on." or ""}`}
    end

    local function EnabledReply()
        local Names: {string} = {}
        for _, Entry: any in Index.Entries do
            if Entry.Module.Enabled then
                table.insert(Names, Entry.Name)
            end
        end

        if #Names == 0 then
            return {Text = "Nothing is on right now."}
        end

        return {
            Text = `{#Names} module{#Names == 1 and " is" or "s are"} on: {Accent(table.concat(Names, ", "))}.`,
            Actions = {
                {
                    Text = "Turn them all off",
                    Callback = function()
                        local Count: number = 0
                        for _, Entry: any in Index.Entries do
                            if Entry.Module.Enabled then
                                Entry.Module:Toggle()
                                Count += 1
                            end
                        end

                        Reply({Text = `Turned off {Count} module{Count == 1 and "" or "s"}.`})
                    end
                }
            }
        }
    end

    local function CountReply()
        local Main, Legit, Categories = 0, 0, {}
        for _, Entry: any in Index.Entries do
            if Entry.Legit then
                Legit += 1
            else
                Main += 1
                Categories[Entry.Category] = true
            end
        end

        return {Text = `This game has {Accent(tostring(Main))} modules across {GetTableSize(Categories)} windows, plus {Accent(tostring(Legit))} legit mods.`}
    end

    local function HelpReply()
        local Sample: string? = SampleModule()
        local Other: string? = SampleModule(Sample)
        local Questions: {string} = {"How do I share my config?", "Show me the Legit menu", "What's new?"}
        local Ask: string? = SampleAsk()
        if Sample then
            table.insert(Questions, 1, `What does {Sample} do?`)
            table.insert(Questions, 2, `Open {Sample} settings`)
        end

        if Other then
            table.insert(Questions, `Where is {Other}?`)
        end

        if Ask then
            table.insert(Questions, Ask)
        end

        local Actions = {}
        for _, Question: string in Questions do
            table.insert(Actions, {
                Text = Question,
                Callback = function()
                    Send(Question)
                end
            })
        end

        return {
            Text = `I am {AssistantName}. I know every module loaded in this game and how the GUI works. Ask me what a module or setting does or where something is, and I will highlight it on your screen.{Ask and " I also know how this game works, like prices, ranges and what gets you flagged." or ""}\n\nI can also do things for you: open windows and menus, turn modules and settings on or off, change values ("set speed mode to cframe"), bind keys ("bind killaura to R"), create or switch profiles, and add friends or targets.`,
            Actions = Actions
        }
    end

    local function SuggestReply(Results)
        local Shown = {}
        for i: number = 1, math.min(3, #Results) do
            if Results[i].Score >= Results[1].Score * 0.4 then
                table.insert(Shown, Results[i].Entry)
            end
        end

        LastTopic = Shown[1].Key
        if #Shown == 1 then
            return DescribeReply(Shown[1])
        end

        local Lines: {string} = {"These look like what you are after:"}
        local Actions = {}
        for _, Entry: any in Shown do
            local Summary: string = FirstSentence(Plain(Entry.Module.Tooltip))
            table.insert(Lines, `- {Accent(Entry.Name)} ({Entry.Category}){Summary ~= "" and `: {Escape(Summary)}` or ""}`)
            table.insert(Actions, {
                Text = Entry.Name,
                Callback = function()
                    Send(`What does {Entry.Name} do?`)
                end
            })
        end

        return {Text = table.concat(Lines, "\n"), Actions = Actions}
    end

    local function FallbackReply(Results)
        local Names: {string} = {}
        local Actions = {}
        for i: number = 1, math.min(2, #Results) do
            local Entry = Results[i].Entry
            table.insert(Names, Accent(Entry.Name))
            table.insert(Actions, {
                Text = Entry.Name,
                Callback = function()
                    Send(`What does {Entry.Name} do?`)
                end
            })
        end

        return {Text = `I am not sure what you mean. Were you asking about {table.concat(Names, " or ")}?`, Actions = Actions}
    end

    local function GetAction(Padded: string, Has: {[string]: boolean}, Words: {string}): string?
        if Has.disable or Has.deactivate or Has.stop or Padded:find("%sturn%s[%w%s]-off%s") or Padded:find("%sswitch%s[%w%s]-off%s") or Words[#Words] == "off" then
            return "Off"
        elseif Has.enable or Has.activate or Has.start or Padded:find("%sturn%s[%w%s]-on%s") or Padded:find("%sswitch%s[%w%s]-on%s") or Words[#Words] == "on" then
            return "On"
        elseif Has.toggle then
            return "Toggle"
        end

        return nil
    end

    local function IsTrouble(Padded: string, Has: {[string]: boolean}): boolean
        return Has.error or Has.errors or Has.errored or Has.broken or Has.bug or Has.bugged or Has.buggy or Has.crash or Has.crashing or Padded:find("no?t work") ~= nil or Padded:find(" stopped work", 1, true) ~= nil
    end

    local function IsNews(Padded: string, Has: {[string]: boolean}): boolean
        for _, Phrase: string in {" whats new ", " what is new ", " new modules ", " new features ", " whats changed ", " what changed ", " patch notes "} do
            if Padded:find(Phrase, 1, true) then
                return true
            end
        end

        return Has.changelog or Has.changelogs or ((Has.updated or Has.update or Has.updates or Has.latest or Has.recent or Has.recently) and not Has.how) or false
    end

    local function StripPolite(Text: string): string
        local Changed: boolean = true
        while Changed do
            Changed = false
            for _, Start: string in PoliteStarts do
                if Text:lower():sub(1, #Start) == Start then
                    Text = Text:sub(#Start + 1)
                    Changed = true
                end
            end
        end

        return (Text:gsub("[%s%?%.!]+$", ""):gsub("%s+[Pp]lease$", ""):gsub("%s+[Pp]ls$", ""))
    end

    local function Unquote(Text: string): string
        return (Text:gsub("^[%s:\"']+", ""):gsub("[%s\"']+$", ""))
    end

    local function TextAfter(Raw: string, Markers: {string}): string?
        local Lower: string = Raw:lower()
        for _, Marker: string in Markers do
            local _, Finish = Lower:find(`%f[%w]{Marker}%f[%W]`)
            if Finish then
                local Rest: string = Unquote(Raw:sub(Finish + 1))
                if Rest ~= "" then
                    return Rest
                end
            end
        end

        return nil
    end

    local function ResolveKey(Text: string): string?
        if not next(KeyNames) then
            for _, Item: EnumItem in Enum.KeyCode:GetEnumItems() do
                KeyNames[Item.Name:lower()] = Item.Name
            end
        end

        local Key: string = Text:lower():gsub("[^%w]", "")
        return KeyAliases[Key] or KeyNames[Key]
    end

    local function ResolvePlayer(Name: string): (string, boolean)
        local Lower: string = Name:lower()
        local Partial: Player?

        for _, Player: Player in Players:GetPlayers() do
            local Username, Display = Player.Name:lower(), Player.DisplayName:lower()
            if Username == Lower or Display == Lower then
                return Player.Name, true
            elseif not Partial and (Username:sub(1, #Lower) == Lower or Display:sub(1, #Lower) == Lower) then
                Partial = Player
            end
        end

        if Partial then
            return Partial.Name, true
        end

        return Name, false
    end

    local function ApplyValue(Option, Value: string): (boolean, string)
        local Component = Option.Option
        local Lower: string = Value:lower()
        if not Component then
            return false, `I could not reach {Option.Name} right now.`
        end

        if Option.Type == "Toggle" then
            local Wanted: boolean? = SwitchValues[Lower]
            if Wanted == nil then
                return false, `{Option.Name} is a toggle, so tell me on or off.`
            end

            if Component.Enabled ~= Wanted then
                Component:Toggle()
            end

            return true, `{Accent(Option.Name)} is {Wanted and "on" or "off"}`
        elseif Option.Type == "Slider" then
            local Number: number? = tonumber(Lower:match("%-?%d*%.?%d+"))
            if not Number then
                return false, `{Option.Name} needs a number, like 10.`
            end

            local Min: number = Component.Min or Option.Settings.Min or Number
            local Max: number = Component.Max or Option.Settings.Max or Number
            local Decimal: number = Component.Decimal or 1
            local Clamped: number = math.round(math.clamp(Number, Min, Max) * Decimal) / Decimal
            Component:SetValue(Clamped, nil, true)

            return true, `{Accent(Option.Name)} is {FormatNumber(Clamped)}{Clamped ~= Number and ` (it goes from {FormatNumber(Min)} to {FormatNumber(Max)})` or ""}`
        elseif Option.Type == "TwoSlider" then
            local Numbers: {number} = {}
            for Match: string in Lower:gmatch("%-?%d*%.?%d+") do
                table.insert(Numbers, tonumber(Match))
            end

            if #Numbers == 0 then
                return false, `{Option.Name} needs a range, like 8 to 12.`
            end

            local Low: number = math.clamp(math.min(Numbers[1], Numbers[2] or Numbers[1]), Component.Min, Component.Max)
            local High: number = math.clamp(math.max(Numbers[1], Numbers[2] or Numbers[1]), Component.Min, Component.Max)
            Component:SetValue(false, Low)
            Component:SetValue(true, High)

            return true, `{Accent(Option.Name)} is {FormatNumber(Low)} to {FormatNumber(High)}`
        elseif Option.Type == "Dropdown" then
            local List: {string} = Option.Settings.List or Component.List or {}
            local Found: string?
            for _, Item: string in List do
                if Item:lower() == Lower then
                    Found = Item
                    break
                end
            end

            for _, Item: string in List do
                if not Found and Item:lower():find(Lower, 1, true) then
                    Found = Item
                end
            end

            if not Found then
                return false, `{Option.Name} can be {Escape(JoinNames(List, 10))}.`
            end

            Component:SetValue(Found)
            return true, `{Accent(Option.Name)} is {Escape(Found)}`
        elseif Option.Type == "TextBox" then
            Component:SetValue(Value, true)
            return true, `{Accent(Option.Name)} is "{Escape(Value)}"`
        elseif Option.Type == "ColorSlider" then
            local Swatch: {number}? = ColorNames[Lower]
            if not Swatch then
                return false, `Pick a color like red, green, blue, purple or white for {Option.Name}.`
            end

            Component:SetValue(Swatch[1], Swatch[2], Swatch[3])
            return true, `{Accent(Option.Name)} is {Lower}`
        end

        return false, `I cannot change {Option.Name} from here, {IsMobile() and "tap" or "click"} it in the GUI instead.`
    end

    local function ToggleOption(Entry, Option, Action: string)
        local Current: boolean = Option.Option and Option.Option.Enabled or false
        local _, Result = ApplyValue(Option, (Action == "On" or (Action == "Toggle" and not Current)) and "on" or "off")
        LastTopic = Entry.Key

        return {Text = `Done, {Result} in {Accent(Entry.Name)}.`, Actions = ModuleActions(Entry, Option)}
    end

    local function FindOptionAnywhere(Query: {[string]: number})
        local Candidates = {}
        if LastTopic and Index.Keys[LastTopic] then
            table.insert(Candidates, Index.Keys[LastTopic])
        end

        for _, Result: any in RankModules(Query) do
            table.insert(Candidates, Result.Entry)
            if #Candidates >= 4 then
                break
            end
        end

        for i: number, Candidate: any in Candidates do
            local Matches = FindOption(Candidate, Query, 1)
            if Matches[1] and Matches[1].Score >= 1 and (Matches[1].Matched >= 2 or (i == 1 and Candidate.Key == LastTopic)) then
                return Candidate, Matches[1].Option
            end
        end

        return nil, nil
    end

    local function FindProfile(Name: string): string?
        local Lower: string = Name:lower()
        local Partial: string?

        for _, Profile: any in vape.Categories.Profiles.List do
            if Profile.Name:lower() == Lower then
                return Profile.Name
            elseif not Partial and Profile.Name:lower():sub(1, #Lower) == Lower then
                Partial = Profile.Name
            end
        end

        return Partial
    end

    local function ProfileNames(): string
        local Names: {string} = {}
        for _, Profile: any in vape.Categories.Profiles.List do
            table.insert(Names, Accent(Profile.Name))
        end

        return JoinNames(Names, 10)
    end

    local function SwitchProfile(Name: string)
        local Profiles = vape.Categories.Profiles
        task.delay(0.2, function()
            if vape.ThreadFix then
                setthreadidentity(8)
            end

            vape:Save(Name)
            vape:Load(true)
            Profiles:ChangeValue()
        end)
    end

    local function FindSetting(Text: string)
        local Query: {[string]: number} = BuildQuery(Text)
        local Best, BestScore = nil, 0

        local function Consider(Name: string, Component)
            if not Component or not Component.Type then return end

            local Terms: {[string]: number} = {}
            AddTerms(Terms, Name, 1)

            local Matched, Total = 0, 0
            for Term: string in Terms do
                Total += 1
                Matched += Query[Term] == 1 and 1 or 0
            end

            local Score: number = Total > 0 and Matched / Total or 0
            if Score > BestScore then
                Best, BestScore = {Name = Name, Option = Component, Settings = {}, Type = Component.Type}, Score
            end
        end

        for _, Pane: any in vape.Settings do
            for Name: string, Component: any in Pane.Options do
                Consider(Name, Component)
            end
        end

        for _, Category: any in vape.Categories do
            if Category.Type == "CategoryList" then
                for Name: string, Component: any in Category.Options do
                    Consider(Name, Component)
                end
            end
        end

        return BestScore >= 1 and Best or nil
    end

    local function ModuleReply(Entry, Action: string?, Padded: string, Has: {[string]: boolean}, Query: {[string]: number})
        LastTopic = Entry.Key

        local Asking: boolean = HasAny(Has, AskWords)

        if Action and not Asking then
            local Matches = FindOption(Entry, Query, 1)
            local Option = Matches[1] and Matches[1].Score >= 0.5 and Matches[1].Option
            if Option and Option.Type == "Toggle" then
                return ToggleOption(Entry, Option, Action)
            end

            return SetModule(Entry, Action)
        elseif IsTrouble(Padded, Has) then
            return TroubleReply(Entry)
        elseif HasAny(Has, BindWords) then
            return BindReply(Entry)
        elseif HasAny(Has, FavoriteWords) then
            return FavoriteReply(Entry)
        elseif HasAny(Has, HideWords) then
            return HideReply(Entry)
        elseif Action and (Has.is or Has.enabled) then
            return {Text = `{Accent(Entry.Name)} is {Entry.Module.Enabled and "on" or "off"} right now.`, Actions = ModuleActions(Entry)}
        end

        if HasAny(Has, TargetWords) then
            for _, Option: any in Entry.Options do
                if Option.Type == "Targets" then
                    return TargetReply(Entry, Option)
                end
            end
        end

        local Matches = FindOption(Entry, Query, 0.6)
        if Matches[1] and Matches[1].Score >= 0.5 then
            return OptionReply(Entry, Matches)
        elseif HasAny(Has, SettingWords) then
            return SettingsReply(Entry)
        elseif HasAny(Has, WhereWords) then
            return WhereReply(Entry)
        elseif (Has.show or Has.open) and not Asking then
            ShowModule(Entry, nil, Has.open)
            return {Text = `{Accent(Entry.Name)} is in {WhereText(Entry)}, I highlighted it for you.`, Actions = ModuleActions(Entry)}
        elseif Action or Has.use then
            return UseReply(Entry)
        end

        return DescribeReply(Entry)
    end

    local function Answer(Question: string)
        EnsureIndex()

        local Raw: string = StripPolite(Brain.Ungreet(Question))
        local Text: string = Normalize(Raw)
        local Words: {string} = Text:split(" ")
        local Has: {[string]: boolean} = {}
        for _, Word: string in Words do
            Has[Word] = true
        end

        local Padded: string = ` {Text} `
        local Query: {[string]: number} = BuildQuery(Text)
        local Guide, GuideScore = FindGuide(Query)

        if Text == "" then
            return {Text = "Ask me anything about CatVape.", Actions = Suggestions()}
        elseif #Words <= 3 and HasAny(Has, {"hi", "hello", "hey", "yo", "sup", "hiya", "howdy", "heya"}) then
            return Brain.Runners.Greet(nil, Question)
        elseif HasAny(Has, {"thanks", "thank", "ty", "thx", "tysm"}) then
            return Brain.Runners.Thanks(nil, Question)
        elseif #Words <= 2 and HasAny(Has, {"ok", "okay", "k", "kk", "cool", "nice", "alright", "gotcha", "great", "bet"}) then
            return Brain.Runners.Ack(nil, Question)
        elseif Text == "help" or Padded:find(" what can you do ", 1, true) then
            return Brain.Runners.Help(nil, Question)
        elseif Padded:find(" who are you ", 1, true) or Padded:find(" what are you ", 1, true) then
            return Brain.Runners.Identity(nil, Question)
        end

        local Action: string? = GetAction(Padded, Has, Words)
        local Describing: boolean = Padded:find(" what does ", 1, true) ~= nil or Padded:find(" what is ", 1, true) ~= nil or Padded:find(" whats ", 1, true) ~= nil
        local Strong: boolean = Guide ~= nil and GuideScore >= 2 and not Describing
        local Mentions = {}
        for _, Mention: any in FindMentions(Words) do
            if not (Strong and Guide.Terms[Stem(Mention.Key)]) then
                table.insert(Mentions, Mention)
            end
        end

        if #Mentions >= 2 then
            LastTopic = Mentions[1].Key

            if Action and not HasAny(Has, AskWords) then
                return MultiReply(Mentions, Action)
            elseif HasAny(Has, CompareWords) or not (HasAny(Has, BindWords) or HasAny(Has, SettingWords) or HasAny(Has, FavoriteWords) or HasAny(Has, HideWords)) then
                return MultiReply(Mentions)
            end
        end

        local Entry = FindModule(Words)
        if Entry and Strong and Guide.Terms[Stem(Entry.Key)] then
            Entry = nil
        end

        local IntentCount: number = 0
        local OnlyIntent: boolean = true
        for Term: string, Weight: number in Query do
            if Weight == 1 and IntentTerms[Term] then
                IntentCount += 1
            elseif Weight == 1 then
                OnlyIntent = false
            end
        end

        local Previous = LastTopic and Index.Keys[LastTopic]
        if not Entry and Previous and ((HasAny(Has, Pronouns) and (OnlyIntent or GuideScore < 2)) or (OnlyIntent and IntentCount > 0 and #Words <= 3)) then
            Entry = Previous
        end

        if Entry then
            return ModuleReply(Entry, Action, Padded, Has, Query)
        end

        if Action and not HasAny(Has, AskWords) then
            local Setting = FindSetting(Text)
            if Setting and Setting.Type == "Toggle" then
                local _, Result = ApplyValue(Setting, (Action == "On" or (Action == "Toggle" and not Setting.Option.Enabled)) and "on" or "off")
                return {Text = `Done, {Result}.`, Actions = PlaceActions(GetPlace(Normalize(Setting.Name)))}
            end

            local Owner, Option = FindOptionAnywhere(Query)
            if Owner and Option.Type == "Toggle" then
                return ToggleOption(Owner, Option, Action)
            end
        end

        if IsNews(Padded, Has) then
            return NewsReply()
        end

        local Category: string? = FindCategory(Has)
        if Category and (#Words <= 2 or HasAny(Has, ListWords)) then
            return CategoryReply(Category)
        end

        if not Has.how and (Has.enabled or Has.active or Has.running or (Has.on and HasAny(Has, {"modules", "module", "everything", "what", "whats", "which"}))) then
            return EnabledReply()
        end

        if Padded:find(" how many ", 1, true) then
            return CountReply()
        end

        if Action == "Off" and (Has.all or Has.everything) then
            return EnabledReply()
        end

        if Previous and GuideScore < 2 then
            local Matches = FindOption(Previous, Query, 1)
            if Matches[1] and Matches[1].Score >= 1 then
                return OptionReply(Previous, Matches)
            end
        end

        if Guide and GuideScore >= 2 then
            return {Text = Guide.Answer(), Actions = PlaceActions(Guide.Place and GetPlace(Guide.Place))}
        end

        local Results = RankModules(Query)
        if Results[1] and Results[1].Score >= 4 then
            local Matches = FindOption(Results[1].Entry, Query, 1)
            if Matches[1] and Matches[1].Score >= 1 then
                LastTopic = Results[1].Entry.Key
                return OptionReply(Results[1].Entry, Matches)
            end

            return SuggestReply(Results)
        end

        if Guide and GuideScore >= 1 then
            return {Text = Guide.Answer(), Actions = PlaceActions(Guide.Place and GetPlace(Guide.Place))}
        end

        if not Results[1] or Results[1].Score < Brain.ChatScore then
            return Brain.Chatter(Question)
        end

        return FallbackReply(Results)
    end

    local function ItemName(Type: string?): string
        local bedwars = getgenv().bedwars
        local Meta = Type and bedwars and bedwars.ItemMeta and bedwars.ItemMeta[Type]
        return Meta and Meta.displayName or tostring(Type or "nothing"):gsub("_", " ")
    end

    local function Duration(Seconds: number): string
        Seconds = math.floor(Seconds)
        if Seconds < 60 then
            return `{Seconds} second{Seconds == 1 and "" or "s"}`
        end

        local Minutes: number = Seconds // 60
        if Minutes < 60 then
            return `{Minutes} minute{Minutes == 1 and "" or "s"}`
        end

        local Hours: number = Minutes // 60
        Minutes %= 60
        return `{Hours} hour{Hours == 1 and "" or "s"}{Minutes > 0 and ` {Minutes} minute{Minutes == 1 and "" or "s"}` or ""}`
    end

    local function MatchValue(Map: any, Key: any): any
        if type(Map) ~= "table" then
            return nil
        end

        local Value = Map[Key]
        if Value == nil then
            Value = Map[tonumber(Key) or Key]
        end

        if Value == nil then
            Value = Map[tostring(Key)]
        end

        return Value
    end

    local function MatchCount(Map: any, Key: any): number
        local Value = MatchValue(Map, Key)
        return type(Value) == "number" and Value or type(Value) == "table" and #Value or 0
    end

    local Lookups = {
        {
            Id = "kit",
            Game = "BedWars",
            Keywords = "kit kits using playing equipped current",
            Needs = {{"i", "im", "my", "me", "am"}},
            Avoid = "should best good recommend buy worth pick choose fusion work works why draft history previous other others enemy enemies their they them mode modes gamemode queue map",
            Run = function()
                local Store, bedwars = getgenv().store, getgenv().bedwars
                local Kits: {string} = Store.equippedKits or {}
                if #Kits == 0 then
                    return "You do not have a kit equipped right now."
                end

                local Names: {string} = {}
                for _, Kit: string in Kits do
                    local Meta = bedwars.BedwarsKitMeta[Kit]
                    table.insert(Names, Accent(Meta and Meta.name or Kit))
                end

                local Meta = bedwars.BedwarsKitMeta[Kits[1]]
                local About: string = Meta and type(Meta.description) == "string" and FirstSentence(Plain(Meta.description)) or ""
                return `You are playing {JoinNames(Names, 3)}.{About ~= "" and ` {Escape(About)}` or ""}`
            end
        },
        {
            Id = "kits",
            Game = "BedWars",
            Keywords = "kit kits using playing picked",
            Needs = {{"enemies", "enemy", "everyone", "everybody", "others", "other", "they", "them", "their", "players", "people", "teams", "opponent", "opponents", "@player"}},
            Avoid = "draft history previous way why",
            Run = function(Tokens)
                local bedwars = getgenv().bedwars
                local Named: string?
                for _, Token: any in Tokens do
                    local Name, Found = ResolvePlayer(Token.Word)
                    if Found and #Token.Word >= 3 and Name ~= Players.LocalPlayer.Name then
                        Named = Name
                    end
                end

                local Lines: {string} = {}
                for _, Player: Player in Players:GetPlayers() do
                    if Player ~= Players.LocalPlayer and (not Named or Player.Name == Named) then
                        local Names: {string} = {}
                        for _, Kit: string in string.split(tostring(Player:GetAttribute("PlayingAsKits") or ""), ",") do
                            local Meta = Kit ~= "" and Kit ~= "none" and bedwars.BedwarsKitMeta[Kit]
                            if Meta then
                                table.insert(Names, Meta.name)
                            end
                        end

                        table.insert(Lines, `- {Escape(Player.DisplayName)}{Player.Team and ` ({Player.Team.Name})` or ""}: {#Names > 0 and Accent(JoinNames(Names, 3)) or "no kit"}`)
                    end
                end

                if #Lines == 0 then
                    return Named and "I could not find that player's kit." or "There is nobody else in this server right now."
                end

                return `{Named and "Their kit" or "Everyone's kits"}:\n{table.concat(Lines, "\n", 1, math.min(#Lines, 12))}{#Lines > 12 and `\n...and {#Lines - 12} more.` or ""}`
            end
        },
        {
            Id = "resources",
            Game = "BedWars",
            Keywords = "iron diamond diamonds emerald emeralds resource resources money currency inventory inv items loot",
            Needs = {{"i", "im", "my", "me"}, {"have", "got", "carrying", "own", "inventory", "inv", "items", "much", "many", "holding"}},
            Avoid = "cost costs price buy need needed make makes generator gen upgrade upgrades drop drops spawn spawns why someone their they them em enemy enemies before hp health guardian guardians mob it does",
            Run = function()
                local Store = getgenv().store
                local Counts: {[string]: number} = {iron = 0, diamond = 0, emerald = 0}
                local Other: {string} = {}
                for _, Item: any in Store.inventory.inventory.items do
                    if Counts[Item.itemType] then
                        Counts[Item.itemType] += Item.amount or 0
                    elseif #Other < 8 then
                        table.insert(Other, `{ItemName(Item.itemType)}{(Item.amount or 1) > 1 and ` x{Item.amount}` or ""}`)
                    end
                end

                local Parts: {string} = {}
                for _, Type: string in {"iron", "diamond", "emerald"} do
                    if Counts[Type] > 0 then
                        table.insert(Parts, `{Accent(tostring(Counts[Type]))} {Type}{(Counts[Type] == 1 or Type == "iron") and "" or "s"}`)
                    end
                end

                local Text: string = #Parts > 0 and `You have {JoinNames(Parts, 3)}.` or "You have no iron, diamonds or emeralds right now."
                return #Other > 0 and `{Text} You are also carrying {JoinNames(Other, 8)}.` or Text
            end
        },
        {
            Id = "gear",
            Game = "BedWars",
            Keywords = "holding hand held sword swords weapon armor armour gear wearing tool",
            Needs = {{"i", "im", "my", "me"}},
            Avoid = "cost costs price buy much damage reduce reduces best reach range why someone their they enemy enemies",
            Run = function()
                local Store = getgenv().store
                local Sword = getgenv().getSword and getgenv().getSword()
                local Armor: {string} = {}
                for _, Piece: any in Store.inventory.inventory.armor do
                    if type(Piece) == "table" and Piece.itemType then
                        table.insert(Armor, ItemName(Piece.itemType))
                    end
                end

                local Lines: {string} = {
                    `You are holding {Accent(Store.hand.tool and ItemName(Store.hand.tool.Name) or "nothing")}.`,
                    Sword and `Your best sword is {Accent(ItemName(Sword.itemType))}.` or "You do not have a sword.",
                    #Armor > 0 and `You are wearing {JoinNames(Armor, 4)}.` or "You have no armor on."
                }
                return table.concat(Lines, " ")
            end
        },
        {
            Id = "bed",
            Game = "BedWars",
            Keywords = "bed beds",
            Needs = {{"my", "our", "left", "alive", "standing", "remaining", "still"}},
            Avoid = "health hp break breaking range far cost esp protect protector defend cover wool stone brick bricks block blocks tankier strong stronger defense why",
            Run = function()
                local Store, bedwars = getgenv().store, getgenv().bedwars
                local Queue = bedwars.QueueMeta and bedwars.QueueMeta[Store.queueType]
                local Mine: string = tostring(Players.LocalPlayer:GetAttribute("Team"))
                local Alive: {string} = {}
                local Own: boolean = false
                for _, Bed: Instance in cloneref(game:GetService("CollectionService")):GetTagged("bed") do
                    local Team: string = tostring(Bed:GetAttribute("TeamId"))
                    local Info = Queue and Queue.teams and Queue.teams[tonumber(Team)]
                    table.insert(Alive, Info and Info.displayName or `team {Team}`)
                    Own = Own or Team == Mine
                end

                if #Alive == 0 then
                    return "There are no beds standing in this match."
                end

                return `{Own and "Your bed is still standing." or "Your bed is gone, your next death is final."} {#Alive} bed{#Alive == 1 and " is" or "s are"} left: {Accent(JoinNames(Alive, 8))}.`
            end
        },
        {
            Id = "mode",
            Game = "BedWars",
            Keywords = "mode modes queue gamemode gametype playlist squads duos solos doubles trios quads",
            Needs = {{"mode", "gamemode", "gametype", "queue", "playlist", "squads", "duos", "solos", "doubles", "trios", "quads"}},
            Avoid = "how legit use blatant cheat should set change best option options setting settings module modules",
            SkipModules = true,
            Run = function()
                local Store, bedwars = getgenv().store, getgenv().bedwars
                local Queue = bedwars.QueueMeta and bedwars.QueueMeta[Store.queueType]
                local States: {[number]: string} = {[0] = "waiting to start", [1] = "in progress", [2] = "over"}
                local Map: string? = Store.map and Store.map.Name
                return `You are in {Accent(Queue and Queue.title or tostring(Store.queueType))}{Map and ` on {Accent(Escape(Map))}` or ""}, and the match is {States[Store.matchState] or "running"}.`
            end
        },
        {
            Id = "map",
            Game = "BedWars",
            Keywords = "map maps",
            Needs = {{"map"}},
            Avoid = "change vote pick best minimap how why dump",
            SkipModules = true,
            Run = function()
                local Map: Instance? = getgenv().store.map
                return Map and `You are on the {Accent(Escape(Map.Name))} map.` or "I could not find the map for this match."
            end
        },
        {
            Id = "stats",
            Game = "BedWars",
            Keywords = "kill kills stats stat final finals bed beds broke broken breaks level games played",
            Needs = {{"i", "im", "my", "me", "am"}, {"kill", "kills", "stats", "stat", "final", "finals", "broke", "broken", "breaks", "level", "games", "played"}},
            Avoid = "aura killaura why guardian guardians effect effects should can get more tips better improve",
            SkipModules = true,
            Run = function()
                local State = getgenv().bedwars.Store:getState().Bedwars
                local Player: Player = Players.LocalPlayer
                local Kills: number = MatchCount(State.kills, Player.UserId)
                local Beds: number = MatchCount(State.bedBreaks, Player.UserId)
                local Final: boolean = MatchValue(State.finalDeaths, Player.UserId) == true
                local Level = Player:GetAttribute("PlayerLevel")
                local Games = Player:GetAttribute("GamesPlayed")
                local Text: string = `This match you have {Accent(tostring(Kills))} kill{Kills == 1 and "" or "s"} and {Accent(tostring(Beds))} bed break{Beds == 1 and "" or "s"}{Final and ", and you are final dead" or ""}.`
                return Level and `{Text} You are level {Accent(tostring(Level))}{Games and ` with {Games} games played` or ""}.` or Text
            end
        },
        {
            Id = "scoreboard",
            Game = "BedWars",
            Keywords = "kills scoreboard leaderboard winning top most score scores leading",
            Needs = {{"who", "whos", "most", "top", "scoreboard", "leaderboard", "winning", "leading"}},
            Avoid = "how killaura aura kit kits why guardian guardians upgrade upgrades",
            SkipModules = true,
            Run = function()
                local State = getgenv().bedwars.Store:getState().Bedwars
                local Rows = {}
                for _, Player: Player in Players:GetPlayers() do
                    table.insert(Rows, {Name = Escape(Player.DisplayName), Kills = MatchCount(State.kills, Player.UserId), Final = MatchValue(State.finalDeaths, Player.UserId) == true})
                end

                table.sort(Rows, function(A, B): boolean
                    return A.Kills > B.Kills
                end)

                local Lines: {string} = {}
                for i: number = 1, math.min(#Rows, 10) do
                    local Row = Rows[i]
                    table.insert(Lines, `- {Row.Name}: {Accent(tostring(Row.Kills))} kill{Row.Kills == 1 and "" or "s"}{Row.Final and ", final dead" or ""}`)
                end

                return `Kills this match:\n{table.concat(Lines, "\n")}{#Rows > 10 and `\n...and {#Rows - 10} more.` or ""}`
            end
        },
        {
            Id = "teams",
            Game = "BedWars",
            Keywords = "teams alive left remaining eliminated standing",
            Needs = {{"teams"}},
            Avoid = "upgrade upgrades change gui color colour colors kit kits why",
            SkipModules = true,
            Run = function()
                local State = getgenv().bedwars.Store:getState()
                local Lines: {string} = {}
                for Id: any, Team: any in State.Game.teams or {} do
                    local Alive, Total = 0, 0
                    for UserId: any in Team.members or {} do
                        Total += 1
                        local Final: boolean = MatchValue(State.Bedwars.finalDeaths, UserId) == true
                        Alive += (not Final and Players:GetPlayerByUserId(tonumber(UserId) or 0)) and 1 or 0
                    end

                    local Bed = MatchValue(State.Bedwars.teamBedStatus, Id)
                    if Total > 0 then
                        table.insert(Lines, `- {Accent(Escape(tostring(Team.name)))}: {Alive} of {Total} alive, bed {Bed == "bed_broken" and "gone" or "standing"}`)
                    end
                end

                return #Lines > 0 and `Teams in this match:\n{table.concat(Lines, "\n")}` or "There are no teams in this match."
            end
        },
        {
            Id = "upgrades",
            Game = "BedWars",
            Keywords = "upgrade upgrades bought purchased",
            Needs = {{"i", "my", "we", "our", "us", "have", "got", "bought", "purchased", "team"}},
            Avoid = "should best buy cost costs price worth next how why",
            SkipModules = true,
            Run = function()
                local State = getgenv().bedwars.Store:getState()
                local Team = State.Game.myTeam
                local Upgrades = Team and MatchValue(State.Bedwars.teamUpgrades, Team.id) or State.Bedwars.myTeamUpgrades or {}
                local Parts: {string} = {}
                for Name: any, Tier: any in Upgrades do
                    table.insert(Parts, `{Accent((tostring(Name):gsub("_", " ")))}{type(Tier) == "number" and ` {Tier}` or ""}`)
                end

                return #Parts > 0 and `Your team has {JoinNames(Parts, 10)}.` or "Your team has not bought any upgrades yet."
            end
        },
        {
            Id = "server",
            Keywords = "server private public full size capacity max slots id jobid",
            Needs = {{"server"}, {"this", "private", "public", "full", "max", "size", "big", "capacity", "slots", "info", "id", "jobid"}},
            Avoid = "region regions hop join switch find rejoin lag laggy npc npcs mob mobs dummy dummies entities",
            Run = function()
                return `This is a {game.PrivateServerId ~= "" and "private" or "public"} server with {Accent(tostring(#Players:GetPlayers()))} of {Players.MaxPlayers} players. Its server id is {game.JobId}.`
            end
        },
        {
            Id = "match",
            Game = "BedWars",
            Keywords = "match game round long time started going",
            Needs = {{"long", "time", "started"}, {"match", "game", "round"}},
            Avoid = "respawn respawns afk kick air",
            Run = function()
                local Game = getgenv().bedwars.Store:getState().Game
                if type(Game.startTime) ~= "number" or Game.startTime <= 0 then
                    return "The match has not started yet."
                end

                return `This match has been going for {Accent(Duration(workspace:GetServerTimeNow() - Game.startTime))}.`
            end
        },
        {
            Id = "region",
            Game = "BedWars",
            Keywords = "region",
            Needs = {{"my", "this", "am", "current", "im", "which", "what", "whats"}},
            Avoid = "regions pick choose change can lock",
            Run = function()
                local Region = getgenv().bedwars.Store:getState().Game.serverRegion
                return type(Region) == "string" and Region ~= "" and `This server is in {Accent(Region)}.` or "This server does not report a region, private and training servers usually do not."
            end
        },
        {
            Id = "team",
            Keywords = "team side teammates teammate",
            Needs = {{"i", "im", "my", "me", "am", "teammates", "teammate"}},
            Avoid = "upgrade upgrades how change gui kit kits draft other others enemy enemies see why",
            Run = function()
                local Team: Team? = Players.LocalPlayer.Team
                if not Team then
                    return "You are not on a team right now."
                end

                local Mates: {string} = {}
                for _, Player: Player in Team:GetPlayers() do
                    if Player ~= Players.LocalPlayer then
                        table.insert(Mates, Escape(Player.DisplayName))
                    end
                end

                return `You are on the {Accent(Team.Name)} team{#Mates > 0 and ` with {JoinNames(Mates, 6)}` or ", on your own"}.`
            end
        },
        {
            Id = "health",
            Keywords = "health hp",
            Needs = {{"i", "im", "my", "me"}},
            Avoid = "bed beds guardian guardians diamond mob mobs npc wool stone brick bricks block blocks it does why",
            Run = function()
                local Character = Players.LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                if not Humanoid then
                    return "You do not have a character right now."
                end

                return `You have {Accent(tostring(math.floor(Humanoid.Health)))} of {math.floor(Humanoid.MaxHealth)} health.`
            end
        },
        {
            Id = "speed",
            Keywords = "speed walkspeed jumppower jumpheight moving fast",
            Needs = {{"my", "i", "im", "me"}},
            Avoid = "set change module mode fly option slider faster boost flag flagged flagging without can should arrow arrows travel projectile shot shots bow they why",
            Run = function()
                local Character = Players.LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                if not Humanoid or not Root then
                    return "You do not have a character right now."
                end

                local Moving: number = (Root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude
                return `You are moving at {Accent(tostring(math.floor(Moving)))} studs a second. Your WalkSpeed is {Humanoid.WalkSpeed} and your JumpPower is {Humanoid.JumpPower}.`
            end
        },
        {
            Id = "position",
            Keywords = "position coords coordinates location",
            Needs = {{"my", "i", "im", "me", "am"}},
            Run = function()
                local Character = Players.LocalPlayer.Character
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                if not Root then
                    return "You do not have a character right now."
                end

                local Position: Vector3 = Root.Position
                return `You are at {Accent(`{math.floor(Position.X)}, {math.floor(Position.Y)}, {math.floor(Position.Z)}`)}.`
            end
        },
        {
            Id = "ping",
            Keywords = "ping latency delay ms",
            Needs = {{"my", "i", "im", "me", "current"}},
            Avoid = "slider option dodge set change",
            Run = function()
                local Ping: number = cloneref(game:GetService("Stats")).Network.ServerStatsItem["Data Ping"]:GetValue()
                return `Your ping is {Accent(`{math.floor(Ping)} ms`)}.`
            end
        },
        {
            Id = "fps",
            Keywords = "fps framerate frames frame",
            Needs = {{"my", "i", "im", "me", "current"}},
            Avoid = "boost booster unlock unlocker more improve lag",
            Run = function()
                local Frames: number = 0
                local Started: number = os.clock()
                local Connection = RunService.RenderStepped:Connect(function()
                    Frames += 1
                end)
                task.wait(0.5)
                Connection:Disconnect()

                local Elapsed: number = os.clock() - Started
                return Elapsed > 0.1 and `You are running at about {Accent(`{math.floor(Frames / Elapsed)} FPS`)}.` or "I could not measure your FPS right now."
            end
        },
        {
            Id = "players",
            Keywords = "players player people online server lobby everyone",
            Needs = {{"many", "who", "list", "count", "number", "everyone"}},
            Avoid = "kit kits team upgrade friend friends target targets add remove closest nearest",
            Run = function()
                local Names: {string} = {}
                for _, Player: Player in Players:GetPlayers() do
                    if Player ~= Players.LocalPlayer then
                        table.insert(Names, Escape(Player.DisplayName))
                    end
                end

                if #Names == 0 then
                    return "You are the only one in this server."
                end

                return `There {#Names == 1 and "is" or "are"} {Accent(tostring(#Names))} other player{#Names == 1 and "" or "s"} here: {JoinNames(Names, 10)}.`
            end
        },
        {
            Id = "npcs",
            Keywords = "npc npcs mob mobs dummy dummies entity entities monster monsters guardian guardians",
            Needs = {{"npc", "npcs", "mob", "mobs", "dummy", "dummies", "entity", "entities", "monster", "monsters", "guardian", "guardians"}},
            Avoid = "target targets targeting attack attacks hit hits killaura aura esp setting settings option options toggle why health hp damage drop drops kill killing spawn spawns when where much",
            Run = function()
                local Counts: {[string]: number} = {}
                local Names: {string} = {}
                local Total: number = 0
                for _, Ent: any in vape.Libraries.entity.List do
                    if Ent.NPC and Ent.Character then
                        local Name: string = Ent.Character.Name
                        if not Counts[Name] then
                            table.insert(Names, Name)
                        end

                        Counts[Name] = (Counts[Name] or 0) + 1
                        Total += 1
                    end
                end

                table.sort(Names, function(A: string, B: string): boolean
                    return Counts[A] > Counts[B] or (Counts[A] == Counts[B] and A < B)
                end)

                local Shown: {string} = {}
                for _, Name: string in Names do
                    table.insert(Shown, Counts[Name] > 1 and `{Escape(Name)} x{Counts[Name]}` or Escape(Name))
                end

                local Guardians: number = #cloneref(game:GetService("CollectionService")):GetTagged("DiamondGuardian")
                local Note: string = CurrentGame() == "BedWars" and Guardians == 0 and " No Diamond Guardians have spawned in this server." or ""
                if Total == 0 then
                    return `There are no NPCs in this server right now.{Note}`
                end

                return `There {Total == 1 and "is" or "are"} {Accent(tostring(Total))} NPC{Total == 1 and "" or "s"} here: {JoinNames(Shown, 10)}.{Note}`
            end
        },
        {
            Id = "nearest",
            Keywords = "closest nearest near close",
            Needs = {{"who", "player", "players", "enemy", "enemies", "someone", "anyone", "people", "person", "me"}},
            Avoid = "generator gen shop bed break",
            Run = function()
                local Character = Players.LocalPlayer.Character
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                if not Root then
                    return "You do not have a character right now."
                end

                local Best, BestDistance = nil, math.huge
                for _, Player: Player in Players:GetPlayers() do
                    local Other = Player ~= Players.LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if Other and (Other.Position - Root.Position).Magnitude < BestDistance then
                        Best, BestDistance = Player, (Other.Position - Root.Position).Magnitude
                    end
                end

                if not Best then
                    return "Nobody else has a character near you right now."
                end

                local Friendly: boolean = Best.Team ~= nil and Best.Team == Players.LocalPlayer.Team
                return `The closest player is {Accent(Escape(Best.DisplayName))}, {math.floor(BestDistance)} studs away{Friendly and ", on your team" or ""}.`
            end
        },
        {
            Id = "playtime",
            Keywords = "server session playtime joined long playing",
            Needs = {{"long", "time", "playtime"}, {"server", "session", "joined", "here", "playing", "playtime"}},
            Avoid = "air afk kick respawn match round",
            Run = function()
                return `You joined this server {Accent(Duration(workspace.DistributedGameTime))} ago.`
            end
        },
        {
            Id = "executor",
            Keywords = "executor injector exploit",
            Needs = {{"i", "im", "my", "me", "am", "this", "using"}},
            Avoid = "best which should work works supported support good",
            Run = function()
                local Success, Name, Version = pcall(identifyexecutor)
                return Success and `You are using {Accent(`{Name}{Version and ` {Version}` or ""}`)}.` or "Your executor does not say what it is."
            end
        },
        {
            Id = "game",
            Keywords = "game place",
            Needs = {{"this", "am", "current", "im"}, {"what", "which", "whats"}},
            Avoid = "safe detect detectable ban banned lag lagging work works going happening everything mode gamemode map",
            Run = function()
                local Success, Info = pcall(function()
                    return cloneref(game:GetService("MarketplaceService")):GetProductInfo(game.PlaceId)
                end)

                local Name: string = Success and type(Info) == "table" and Info.Name or CurrentGame() or "this place"
                return `You are in {Accent(Escape(Name))} (place {game.PlaceId}). CatVape loaded {CountModules()} modules for it.`
            end
        },
        {
            Id = "account",
            Keywords = "account age old created",
            Needs = {{"my", "i"}, {"old", "age", "created", "made"}},
            Run = function()
                local Days: number = Players.LocalPlayer.AccountAge
                return `Your account is {Accent(`{Days} day{Days == 1 and "" or "s"}`)} old.`
            end
        },
        {
            Id = "time",
            Keywords = "time clock",
            Needs = {{"time", "clock"}, {"what", "whats", "tell", "know", "current", "check"}},
            Avoid = "match round game long playtime playing played respawn server session cooldown charge join joined spent take takes took until left remaining good best buy should kit does shop close closes open opens start starts end ends spawn spawns",
            Run = function()
                local Now = os.date("*t")
                local Hour: number = Now.hour % 12 == 0 and 12 or Now.hour % 12
                return `It is {Accent(`{Hour}:{string.format("%02d", Now.min)} {Now.hour < 12 and "AM" or "PM"}`)} on your computer.`
            end
        },
        {
            Id = "date",
            Keywords = "date day today month year monday tuesday wednesday thursday friday saturday sunday",
            Needs = {{"date", "day", "today", "todays", "month", "year", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"}, {"what", "whats", "which", "tell", "know", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"}},
            Avoid = "match round game long kit kits skin shop respawn birthday good best buy should how up version update updated outdated",
            Run = function()
                local Now = os.date("*t")
                local Days: {string} = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
                local Months: {string} = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
                return `Today is {Accent(`{Days[Now.wday]}, {Months[Now.month]} {Now.day}`)}, {Now.year}.`
            end
        },
        {
            Id = "version",
            Keywords = "version versions outdated date build newest latest update",
            Needs = {{"version", "versions", "outdated", "date", "newest", "latest", "build", "update"}, {"i", "im", "am", "my", "Uranium", "vape", "last", "when", "need", "reexecute", "reinject", "today", "push", "pushed", "guys", "yall"}},
            Avoid = "new changed changes changelog added patch notes features fixed fix kit kits game roblox how devs",
            SkipModules = true,
            Run = function()
                if shared.VapeDeveloper then
                    return "You're in developer mode, so CatVape loads your local files and doesn't update itself."
                end

                local Commit: string? = isfile(`{vape.Directory}/profiles/commit.txt`) and readfile(`{vape.Directory}/profiles/commit.txt`) or nil
                local Build: string = Commit and Commit ~= "" and ` You're on build {Accent(Commit:sub(1, 7))}.` or ""
                return `CatVape checks for a new build every time you execute it and downloads it if there is one, so you're on the newest version as of when you injected, unless the console (F9) showed "Failed to update".{Build} Ask me what's new to see what the latest update changed.`
            end
        }
    }

    table.insert(Lookups, {
        Id = "overview",
        Keywords = "everything overview summary status info information details happening going rundown",
        Needs = {{"everything", "overview", "summary", "status", "info", "information", "details", "happening", "going", "rundown"}},
        Avoid = "how hows why you module modules setting settings config configs profile",
        SkipModules = true,
        Run = function(Tokens)
            local Game: string? = CurrentGame()
            local Lines: {string} = {}
            for _, Id: string in {"mode", "match", "teams", "players", "npcs", "kit", "team", "health", "stats", "resources"} do
                for _, Lookup: any in Lookups do
                    if Lookup.Id == Id and (not Lookup.Game or Lookup.Game == Game) then
                        local Success, Text = pcall(Lookup.Run, Tokens)
                        if Success and type(Text) == "string" then
                            table.insert(Lines, Text)
                        end
                    end
                end
            end

            return #Lines > 0 and table.concat(Lines, "\n\n") or "I could not read anything from the game right now."
        end
    })

    for _, Lookup: any in Lookups do
        Lookup.Terms = {}
        AddTerms(Lookup.Terms, Lookup.Keywords, 1)
        Lookup.Skip = Lookup.Avoid and Lookup.Avoid:split(" ") or {}
    end

    Brain = {
        Cap = 40,
        ChatFloor = 0.25,
        ChatLead = 0.4,
        ChatScore = 2,
        Dictionary = {
            Checked = {},
            File = `{vape.Directory}/profiles/assistantwords.txt`,
            Url = "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"
        },
        Essentials = {
            BedWars = {"Killaura", "Velocity", "Sprint", "KeepSprint", "NoFall", "NoSlow", "AntiVoidFlag", "AutoBuy", "ChestSteal", "PickupRange", "BedESP", "NameTags", "StaffDetector"},
            Universal = {"ESP", "NameTags", "Anti-AFK", "StaffDetector"}
        },
        FactFloor = 2,
        FactOver = 3.5,
        FactTopic = 2,
        File = `{vape.Directory}/profiles/assistant.json`,
        Memory = {},
        Fillers = {},
        Floor = 0.15,
        History = {},
        Learned = {},
        Margin = 0.7,
        Picked = {},
        Runners = {},
        Smoothing = 0.002,
        SocialFloor = 0.4,
        SocialSure = 0.9,
        Temperature = 3,
        WindowOrder = {"Combat", "Blatant", "Render", "Utility", "World", "Inventory", "Kits", "Friends", "Profiles", "Targets"}
    }

    function Brain.Set(Text: string): {[string]: boolean}
        local Set: {[string]: boolean} = {}
        for Word: string in Text:gmatch("%S+") do
            Set[Word] = true
        end

        return Set
    end

    Brain.Drop = Brain.Set("the a an my please pls plz just kindly bro dude man lol lmao bruh ngl fr tbh lowkey highkey deadass istg fs kinda sorta literally basically actually really very pretty so super even")
    Brain.Openers = {"what'?s up", "what'?s good", "good morning", "good afternoon", "good evening", "hiya", "heya", "hello", "hey", "hi", "yo", "howdy", "ayo", "sup"}
    Brain.Addressed = Brain.Set("there again everyone guys bro man dude bot shaders buddy friend all yall")
    Brain.Trailing = Brain.Set("for me please pls plz now rn asap thanks thx ty quick quickly real right away or nah fr tbh ngl bro bruh lol lmao")
    Brain.Quantifiers = Brain.Set("all every everything each both entire whole")
    Brain.Nouns = Brain.Set("tab tabs window windows category categories menus panel panels section sections page pages")
    Brain.Pronouns = Brain.Set("it its that this them those these")
    Brain.KeyMarkers = Brain.Set("to on with key button as")
    Brain.KeyNames = Brain.Set("insert rightshift leftshift rshift lshift capslock pageup pagedown leftcontrol rightcontrol rctrl lctrl f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12")
    Brain.ListVerbs = Brain.Set("add remove delete friend unfriend target untarget whitelist unwhitelist focus")
    Brain.KeyVerbs = Brain.Set("toggle toggles open opens close closes enable enables disable disables turn turns activate activates start starts")
    Brain.QuestionWords = Brain.Set("how hows what whats wat wut why whys when whens which where wheres who does do did is am are was were can could should will would")
    Brain.Commanding = Brain.Set("you u ya yall")
    Brain.Requests = Brain.Set("tell show check give")
    Brain.Social = Brain.Set("Greet Wellbeing Identity Thanks Ack Help Bye Compliment Insult Joke Feeling Apology Personal Screenshot Code")
    Brain.PriceWords = Brain.Set("is are does do for would will to")
    Brain.PresetWords = {"necessary", "essential", "essentials", "basic", "recommended", "core", "starter", "important", "main", "needed", "required", "useful"}
    Brain.PresetNouns = {"config", "configs", "profile", "setup", "preset", "configuration", "cfg"}
    Brain.Slang = {
        abt = "about",
        aight = "alright",
        aint = "is not",
        ayo = "yo",
        b4 = "before",
        bc = "because",
        bcuz = "because",
        brb = "be right back",
        cfg = "config",
        cfgs = "configs",
        chillin = "chilling",
        cn = "can",
        coz = "because",
        cud = "could",
        cuz = "because",
        cya = "see you",
        dmg = "damage",
        doin = "doing",
        dunno = "dont know",
        ez = "easy",
        finna = "going to",
        g2g = "got to go",
        gimme = "give me",
        gl = "good luck",
        gm = "good morning",
        gn = "good night",
        goin = "going",
        gonna = "going to",
        gotta = "got to",
        gtg = "got to go",
        gud = "good",
        hallo = "hello",
        hbu = "how about you",
        helo = "hello",
        hola = "hello",
        hru = "how are you",
        hw = "how",
        idc = "i dont care",
        idk = "i dont know",
        ight = "alright",
        ikr = "i know right",
        ily = "i love you",
        ilysm = "i love you so much",
        inf = "infinite",
        ive = "i have",
        kb = "knockback",
        lemme = "let me",
        lmk = "let me know",
        luv = "love",
        mb = "my bad",
        naw = "nah",
        nm = "not much",
        nothin = "nothing",
        np = "no problem",
        nth = "nothing",
        nthn = "nothing",
        nvm = "never mind",
        ofc = "of course",
        oki = "ok",
        okie = "ok",
        okk = "ok",
        opt = "option",
        opts = "options",
        plr = "player",
        plrs = "players",
        ppl = "people",
        probs = "probably",
        prolly = "probably",
        rlly = "really",
        rly = "really",
        ru = "are you",
        shud = "should",
        smth = "something",
        smthn = "something",
        srry = "sorry",
        sry = "sorry",
        stfu = "shut up",
        sth = "something",
        thanx = "thanks",
        thnx = "thanks",
        thx = "thanks",
        tmr = "tomorrow",
        tmrrw = "tomorrow",
        tmrw = "tomorrow",
        tnx = "thanks",
        tog = "toggle",
        togg = "toggle",
        tryna = "trying to",
        ttyl = "talk to you later",
        tyvm = "thank you",
        u = "you",
        ui = "gui",
        ur = "your",
        urs = "yours",
        urself = "yourself",
        wanna = "want to",
        wassup = "whats up",
        wat = "what",
        watcha = "what are you",
        wats = "whats",
        wazzup = "whats up",
        wbu = "what about you",
        wdym = "what do you mean",
        wen = "when",
        whatcha = "what are you",
        whatsup = "whats up",
        wher = "where",
        whr = "where",
        wht = "what",
        wsg = "whats up",
        wsp = "whats up",
        wud = "would",
        wut = "what",
        wuts = "whats",
        wyd = "what are you doing",
        wym = "what you mean",
        ya = "you",
        ye = "yes",
        yea = "yeah",
        youre = "you are",
        yu = "you",
        yuh = "yes",
        yw = "you are welcome"
    }
    Brain.Whole = {
        ["help please"] = "help",
        ["help pls"] = "help",
        hm = "hmm",
        ["i need help"] = "help",
        ["i need some help"] = "help",
        k = "ok",
        kk = "ok",
        lmao = "haha",
        lmfao = "haha",
        lol = "haha",
        lolol = "haha",
        ["need help"] = "help",
        ["please help"] = "help",
        ["pls help"] = "help",
        rofl = "haha",
        ["someone help"] = "help",
        xd = "haha"
    }
    Brain.Complaints = Brain.Set("still doesnt wont cant cannot isnt arent aint gone lost missing broken broke bugged buggy glitch glitched glitching glitchy stuck smh wtf bruh ugh randomly suddenly")
    Brain.Common = Brain.Set([[
walk walks walking walked get gets getting got gotten hurt hurts hurting die dies dying died dead kick kicks kicking kicked take takes taking took taken keep keeps keeping kept spawn spawns spawning spawned stand stands standing stood play plays playing played lose loses losing lost hit hits hitting run runs running ran jump jumps jumping jumped fall falls falling fell buy buys buying bought pick picks picking picked grab grabs grabbing grabbed break breaks breaking broke place places placing placed build builds building built shoot shoots shooting shot aim aims aiming aimed miss misses missing missed throw throws throwing threw thrown drop drops dropping dropped hold holds holding held move moves moving moved stop stops stopping stopped start starts starting started try tries trying tried want wants wanting wanted need needs needing needed look looks looking looked see sees seeing saw seen feel feels feeling felt think thinks thinking thought know knows knowing knew known say says saying said tell tells telling told give gives giving gave given come comes coming came leave leaves leaving left happen happens happening happened help helps helping helped fix fixes fixing fixed crash crashes crashing crashed load loads loading loaded join joins joining joined wait waits waiting waited spend spends spending spent earn earns earning earned farm farms farming farmed rush rushes rushing rushed camp camps camping camped fight fights fighting fought chase chases chasing chased hunt hunts hunting hunted clutch clutches clutching clutched bridge bridges bridging bridged mine mines mining mined dig digs digging dug trade trades trading sell sells selling sold pay pays paying paid charge charges charging charged land lands landing landed float floats floating hover hovers hovering glide gliding sprint sprinting crouch crouching sneak sneaking climb climbs climbing climbed slide sliding dash dashing teleport teleports teleporting teleported turn turns turning turned open opens opening opened close closes closing closed show shows showing showed shown hide hides hiding hid hidden change changes changing changed set sets setting use uses using used make makes making made put puts putting call calls calling called
people player players enemy enemies team teams teammate teammates friend friends game games match matches round rounds server servers lobby map maps island base bed beds shop shops item items sword swords bow bows armor block blocks wool iron gold diamond diamonds emerald emeralds kit kits skin skins health damage time times seconds second minute minutes hour hours studs stud way thing things money coins robux account alt main hacker hackers cheater cheaters script scripts exploit mouse keyboard screen window phone laptop computer ipad tablet controller button buttons menu tab tabs setting settings option options mode modes range distance ground floor wall walls void edge top bottom side front back left right death deaths kill kills life lives hand head body legs arms camera view shift spam
fast faster slow slower high higher low lower big bigger small smaller good better best bad worse worst easy hard strong stronger weak weaker close closer far farther further near long longer short shorter new old same different laggy smooth safe risky legit blatant trash insane crazy annoying weird random sure real fake full half empty whole last first next other another every each whole instant quick
really actually literally basically always never sometimes usually often again already even only also very quite pretty kinda sorta instantly suddenly randomly anymore yet soon later before after during while since until because though although
someone somebody anyone anybody everyone everybody nobody something anything everything nothing myself yourself itself their they them ngl tbh bro bruh lmao idk imo tho cuz cause gonna gotta wanna lemme gimme yeah yea yep nope nah okay thx noob sweat sweaty tryhard lowkey highkey deadass
]])
    Brain.Informative = Brain.Set("Describe Settings OptionInfo BindInfo PlaceInfo Status Trouble Compare ListCategory Count")
    Brain.Knowledge = Brain.Set("Describe Settings OptionInfo BindInfo PlaceInfo Status Trouble Compare ListCategory ListEnabled ListWindows News Count HowTo Guide ProfileList Help Greet Wellbeing Identity Thanks Ack Bye Compliment Insult Joke Feeling Apology Personal Confirm Deny Interaction Using More Simpler Recommend Tradeoff Effect Screenshot Code")

    Brain.Templates = {
        Open = {
            "(open|show|display|launch|expand|unfold|reveal|pull up|bring up|pop up|pop open|get) (<place>|<category>|<module>|<setting>|<option>)",
            "(open|show|display|expand|pull up|bring up) (<place>|<category>|<module>) (<tabs>|settings|options|config)",
            "(open|show|display|launch|expand|pull up|bring up|pop open) <all> [of] (<tabs>|<category>|modules|mods|cheats)",
            "3*(show|show me|open|display|expand) <all> <tabs>",
            "(open|show|expand|pull up|bring up) (<tabs>|<all>)",
            "(open|show|expand) <all> <category> [<tabs>]",
            "(open|show|expand|pull up) <category> and <category> [and <category>]",
            "(open|show|expand) <category> <category> [<category>]",
            "(open|expand) <module> and <module>",
            "(take me to|go to|switch to|navigate to|go back to|bring me to|jump to|head to) (<place>|<category>|<module>)",
            "(let me see|i wanna see|can i see|lemme see|i want to see) (<place>|<category>|<tabs>|<all> <tabs>)",
            "(open|show|expand) <it>",
            "(i want|i need|i wanna|gimme|give me|get me) (<place>|<category>|<all> <tabs>) [open|opened]",
            "2*(i need|i want|gimme|give me) <category> <tabs>",
            "(open|expand) <module> (settings|options|config)",
            "<place>",
            "<category> <tabs>",
            "<all> <tabs>"
        },
        Close = {
            "(close|hide|shut|exit|collapse|minimize|dismiss) (<place>|<category>|<tabs>|<module>|<setting>)",
            "(close|hide|shut|collapse|minimize) (<place>|<category>) <tabs>",
            "(close|hide|shut|collapse|minimize|get rid of|clear) <all> [<tabs>|<category>|menus]",
            "(close|hide|collapse|shut) <category> and <category> [and <category>]",
            "(close|hide|collapse) <category> <category> [<category>]",
            "(get rid of|put away|close down) (<place>|<category>)",
            "(close|hide|collapse|shut) <it>",
            "(close|collapse) <module> (settings|options)",
            "i (dont|do not) want (<place>|<category>) open",
            "(exit|leave|close) <place>"
        },
        Locate = {
            "(where|wheres) [is|are] (<place>|<category>|<module>|<setting>|<option>)",
            "(highlight|point to|point at|point out|locate|find|indicate) (<place>|<category>|<module>|<setting>|<option>)",
            "(where do i find|where can i find|where can i see|where do i see|how do i find|how can i find) (<place>|<module>|<setting>|<option>)",
            "show me (<place>|<module>|<setting>|<option>)",
            "show me where (<place>|<module>|<setting>|<option>) is",
            "(where|wheres) [is|are] <module> <option>",
            "(where|wheres) [is] <module> (bind|keybind|key)",
            "where is (bind|keybind|key) for <module>",
            "(highlight|show me|find) <module> <option>",
            "2*(highlight|show me|where is|find|point to) <place> (switch|button|toggle|icon|thing)",
            "(highlight|where is|find|show me) <it>",
            "which button (opens|is) (<place>|<category>)",
            "i (cant|can not|cannot) find (<place>|<module>|<setting>|<category>)",
            "2*where (did|does|would) <module> go",
            "2*i (lost|misplaced) <module>",
            "(where|wheres) [is|are] <module> (located|at|hiding)"
        },
        Describe = {
            "4*what (does|do) <module> do",
            "3*what (is|are) <module> [for]",
            "whats <module> [for]",
            "(explain|describe|define) <module>",
            "(wtf|wth|what tf) is <module>",
            "explain <module> to me",
            "tell me about <module>",
            "(info|information) (on|about) <module>",
            "what does <it> do",
            "what is <it>",
            "how does <module> work",
            "what is <module> used for",
            "is <module> (good|worth it|useful|safe)",
            "should i use <module>",
            "<module>",
            "what about <module>",
            "and <module>",
            "what does <module> mean",
            "2*(whats|what is) (point|purpose|use) of <module>",
            "what does <module> even do",
            "how does <module> help",
            "why would i use <module>",
            "what (does|do) <module> (use|need)",
            "is <module> (detectable|bannable|undetected|flagged)",
            "does <module> get me (banned|flagged)"
        },
        Settings = {
            "<module> (settings|options|config)",
            "3*what (settings|options) does <module> have",
            "list <module> (settings|options)",
            "what can i change (in|on|about) <module>",
            "(how do i|how to|how can i) (configure|customize|set up|setup) <module>",
            "(best|good|recommended) (settings|config) for <module>",
            "what are <module> (settings|options)",
            "what are (its|<it>) (settings|options)",
            "<it> (settings|options)",
            "(settings|options) for <module>"
        },
        OptionInfo = {
            "what (does|is) <option> [do|mean|for]",
            "what does <option> (in|on|for) <module> do",
            "what is <module> <option>",
            "<module> <option>",
            "(explain|describe) <option>",
            "how does <option> work",
            "what is <option> (of|in|on|for) <module>",
            "whats <module> <option> [set to|at]",
            "what is <option> set to",
            "what does <option> setting do",
            "what does <module> <option> do"
        },
        TurnOn = {
            "(turn on|enable|activate|start|switch on|toggle on|put on|power on) (<module>|<option>|<setting>)",
            "turn (<module>|<option>|<setting>) on",
            "(enable|activate|turn on) <module> and <module> [and <module>]",
            "(turn on|enable) <option> (in|on|for) <module>",
            "(turn|switch|put) <it> on",
            "(enable|activate|start|turn on) <it>",
            "4*<module> [and <module>] on",
            "2*(put|switch|flip|set) <module> on",
            "(turn on|enable|activate) <all> <category> [modules|mods]",
            "(turn on|enable) <all> (modules|mods) in <category>",
            "i want <module> on",
            "(use|start|run) <module>",
            "turn <module> and <module> on",
            "3*(fire up|boot up|power up|kick on|spin up|crank up|light up) <module>",
            "2*(get|have) <module> (going|running|on)",
            "2*(i want to|lemme|let me|can i) use <module>",
            "start using <module>",
            "(i want|i wanna) <module> (running|going|active)"
        },
        Preset = {
            "3*(make|create|build|setup) [new] (config|profile) with [all] (necessary|essential|basic|recommended|core) (modules|mods)",
            "2*(turn on|enable|toggle) [all] (necessary|essential|basic|recommended|core) (modules|mods)",
            "(make|create|give) me (basic|starter|recommended) (config|profile|setup)"
        },
        TurnOff = {
            "(turn off|disable|deactivate|stop|switch off|toggle off|shut off|kill) (<module>|<option>|<setting>)",
            "turn (<module>|<option>|<setting>) off",
            "(disable|turn off|stop) <module> and <module> [and <module>]",
            "(turn off|disable) <option> (in|on|for) <module>",
            "(turn|switch|put) <it> off",
            "(disable|stop|deactivate|turn off) <it>",
            "4*<module> [and <module>] off",
            "2*(put|switch|flip|set) <module> off",
            "(turn off|disable|stop|deactivate) <all> [modules|mods|cheats]",
            "(turn off|disable|deactivate) <all> <category> [modules|mods]",
            "(turn off|disable) <all> (modules|mods) in <category>",
            "turn <module> and <module> off",
            "panic",
            "3*(shut down|power down|shut off|kick off|cut) <module>",
            "2*stop using <module>",
            "2*i (dont|do not) want <module> (on|anymore|running)"
        },
        Toggle = {
            "(toggle|flip) (<module>|<option>|<setting>|<it>)",
            "switch <module>"
        },
        SetValue = {
            "(set|change|make|put|switch|adjust) (<option>|<setting>) (to|at) (<number>|<color>|<text>)",
            "(set|change|make|put|adjust|switch) <module> <option> (to|at) (<number>|<color>|<text>)",
            "(set|change|make|put) <module> (to|at) <number>",
            "<module> <option> to (<number>|<color>)",
            "(set|put) (<option>|<setting>) <number>",
            "set <module> <option> <number>",
            "(increase|raise|decrease|lower|bump|reduce) (<option>|<setting>) to <number>",
            "(increase|raise|decrease|lower|reduce) <module> <option> to <number>",
            "make (<option>|<setting>) (<number>|<color>)",
            "(set|change) (its|<it>) <option> to (<number>|<color>|<text>)",
            "change color of <module> to <color>",
            "make <module> <color>",
            "2*(crank|bump|turn|push|drop|bring) (<option>|<setting>) (up|down) to <number>",
            "2*(crank|bump|turn|push|drop|bring) <module> <option> (up|down) to <number>",
            "(put|switch) (<option>|<setting>) on <text>",
            "(set|change|switch) <module> <option> to"
        },
        Bind = {
            "(bind|keybind|hotkey|rebind) (<module>|<it>) (to|on|with|as) <key>",
            "(set|change|make) <module> (bind|keybind|key|hotkey) (to|as) <key>",
            "bind <key> to <module>",
            "make <key> (toggle|turn on|enable) <module>",
            "put <module> on <key>",
            "(rebind|change) <place> (key|bind|keybind) to <key>",
            "(rebind|bind) <place> to <key>",
            "2*(make|let|have) <key> (open|toggle|close|show) (<place>|<module>)",
            "2*(use|i want) <key> (for|to open|to toggle) (<place>|<module>)",
            "set <place> (key|bind) to <key>",
            "i want <module> on <key>",
            "(bind|keybind) <module> <key>"
        },
        Unbind = {
            "(unbind|unkeybind) (<module>|<it>)",
            "(remove|clear|delete|reset) (bind|keybind|key|hotkey) (from|on|for|of) <module>",
            "(remove|clear|delete|reset) <module> (bind|keybind|key|hotkey)",
            "<module> (no|without) bind",
            "2*(get rid of|take off|drop|wipe) <module> (bind|keybind|key|hotkey|binding)",
            "2*(get rid of|take off|wipe) (bind|keybind|key|hotkey) (from|on|for|of) <module>"
        },
        ProfileCreate = {
            "(create|make|add|new) [new] profile [called|named]",
            "2*(create|make) me [new] profile (called|named)",
            "new profile",
            "(save|copy) (this|my settings|my config) (as|to|into) [new] profile [called|named]",
            "(create|make) profile for"
        },
        ProfileSwitch = {
            "(switch|change|swap|go|move) to <profile> [profile]",
            "(load|use|select|pick|apply) <profile> profile",
            "(load|use|select|apply) profile <profile>",
            "(switch|change) profile to <profile>",
            "(switch|change|swap) profiles",
            "<profile> profile",
            "(switch|change) to profile <profile>"
        },
        ProfileDelete = {
            "(delete|remove|erase|get rid of) <profile> profile",
            "(delete|remove|erase) profile <profile>",
            "(delete|remove) profile [called|named] <profile>"
        },
        ProfileList = {
            "(what|which) profiles (do i have|are there|have i got)",
            "(list|show) [all] profiles",
            "what profile am i (on|using)",
            "how many profiles [do i have]",
            "which profile is (active|loaded|on)"
        },
        ListAdd = {
            "add <player> (to|as) (friend|friends|friends list|target|targets|<place>)",
            "(add|make) <player> (friend|target)",
            "(friend|target|whitelist) <player>",
            "add (friend|target) <player>",
            "(put|add) <player> on (friend|target|friends|targets) list",
            "(dont|do not|never) (attack|target|hit|kill) <player>",
            "(focus|attack|target|prioritize) <player> first",
            "add <player>"
        },
        ListRemove = {
            "(remove|delete|take|drop|kick) <player> (from|off) (friends|friend list|targets|target list|<place>)",
            "(unfriend|untarget|unwhitelist) <player>",
            "(remove|delete) (friend|target) <player>",
            "stop (targeting|focusing|protecting) <player>",
            "remove <player>"
        },
        Favorite = {
            "3*(favorite|favourite|star|fav) (<module>|<it>)",
            "add (<module>|<it>) to (favorites|<place>)",
            "(unfavorite|unfavourite|unstar|unfav) (<module>|<it>)",
            "remove (<module>|<it>) from (favorites|<place>)",
            "make <module> [a] favorite"
        },
        Hide = {
            "hide (<module>|<it>) [from list|from window]",
            "(unhide|unhidden) (<module>|<it>)",
            "make <module> visible again",
            "remove <module> from list",
            "i dont want to see <module>"
        },
        ListWindows = {
            "3*(list|name|tell me) <all> <tabs>",
            "2*(list|name) [the|your|my] <tabs>",
            "what <tabs> (are there|do you have|exist|is there)",
            "how many <tabs> [are there|do you have]",
            "what are <tabs>",
            "which <tabs> are there",
            "list [all] <tabs>",
            "what <tabs> can i open"
        },
        ListCategory = {
            "what is in <category> [<tabs>]",
            "whats in <category> [<tabs>]",
            "<category> modules",
            "(list|what are) <category> modules",
            "what modules are in <category>",
            "what does <category> have",
            "<category>",
            "what is in <place>"
        },
        ListEnabled = {
            "what (modules|mods) are (on|enabled|active|running)",
            "(what|which) is (on|enabled|active)",
            "whats (on|enabled|active|running)",
            "(list|show) enabled modules",
            "what do i have (on|enabled)",
            "which modules (did i enable|are on)"
        },
        News = {
            "(whats|what is) new",
            "whats (changed|been updated) [recently|lately]",
            "what (changed|is changed)",
            "(any|what) updates",
            "(changelog|patch notes)",
            "what got (updated|added)",
            "new (features|modules|stuff)",
            "whats (latest|last) update",
            "3*(whats new|what is new|whats changed|what changed|what got changed|any changes|any updates|whats different) (with|in|to|for) <module>",
            "2*<module> (changelog|changes|update|updates|patch notes)",
            "2*(was|did|has) <module> (updated|changed|improved)",
            "what did (you|they) (change|add|fix|update) (in|to|with|on) <module>"
        },
        Count = {
            "how many modules [are there|do you have|are in this game]",
            "(count|number of) modules",
            "how big is Uranium"
        },
        Compare = {
            "(difference|compare) between <module> and <module>",
            "<module> (vs|versus|or) <module>",
            "which is better <module> or <module>",
            "compare <module> (and|with|to) <module>",
            "is <module> better than <module>",
            "whats difference between <module> and <module>"
        },
        Trouble = {
            "<module> (is not|isnt|doesnt|does not|wont|dont) (work|working|turn on)",
            "why (is|does|isnt|doesnt) <module> (not work|not working|work)",
            "<module> (is broken|broke|is bugged|errored|keeps erroring|crashes|not working)",
            "fix <module>",
            "(problem|issue) with <module>",
            "<it> (is not|isnt|doesnt) work",
            "why doesnt <it> work",
            "2*<module> (does nothing|isnt doing anything|is not doing anything|stopped working|wont do anything)",
            "<module> keeps (breaking|crashing|failing)"
        },
        HowTo = {
            "how (do|can|would|should) i (do|use|get|make|change|turn|see|find|share|save|reset|fix|stop|win|play|bind|update|add|remove|hide|move|set|import|export) (this|that|stuff|things|something)",
            "how to (use|get|make|change|see|find|share|save|reset|fix|stop|win|play|bind|update|add|remove|hide|move|set|import|export) (this|stuff|things)",
            "2*is (this|it|Uranium|<it>|<place>) (safe|detectable|undetected|bannable)",
            "will i get banned",
            "why (is|does|cant|wont) (game|gui|script) (lag|work|load|open)",
            "what is (Uranium|vape|legit mode|profile|config)",
            "how does (this|Uranium) work",
            "3*how (do|can|should|would) i (bind|keybind|hide|unhide|favorite|use|enable|disable|turn on|turn off|toggle|find|open|set up|get) <module>",
            "3*how (do|can) i (open|close|get to|find|use|change|reach|turn off|turn on|rebind) <place>",
            "2*how (do|can) i (bind|hide|use|search for|find) [a] (module|modules|thing|something)"
        },
        BindInfo = {
            "what (key|bind|keybind|button|hotkey) is <module> (on|bound to)",
            "(whats|what is) <module> (bind|keybind|key|hotkey)",
            "(is|what is) <module> bound [to anything]",
            "which key (toggles|turns on|enables) <module>",
            "what (key|bind) does <module> (use|have)",
            "(does|did) <module> have [a] (bind|keybind|key)",
            "what (key|bind) is <it> on"
        },
        Status = {
            "is (<module>|<it>) (on|enabled|active|running|off|disabled|working)",
            "(check|status of|state of) <module>",
            "(did|have) i (turn on|enable|turn off|disable) <module>",
            "is <module> (turned on|turned off|toggled)"
        },
        PlaceInfo = {
            "what (is|are) <place> [for]",
            "what does <place> do",
            "whats <place> [for]",
            "(explain|describe) <place>",
            "tell me about <place>",
            "how does <place> work",
            "what is <place> used for"
        },
        Guide = {},
        Undo = {
            "undo [that|it|last thing|last change]",
            "(revert|reverse) [that|it|last change]",
            "(put|change|set|turn) (it|that) back",
            "take that back",
            "(nevermind|never mind) undo [that]",
            "go back to how it was",
            "undo what you (did|just did)"
        },
        Greet = {
            "(hi|hello|hey|yo|sup|hiya|howdy|heya|hey there|greetings|good morning|good afternoon|good evening)",
            "(hi|hello|hey|yo) (there|bot|assistant|Uranium|shaders|again|everyone)",
            "(anyone|anybody|is anyone) [in] (here|there)"
        },
        Wellbeing = {
            "how are you [doing|today|feeling]",
            "how (is|was) your day [going]",
            "how (is it going|are things|have you been|is life|you doing)",
            "(whats up|whats good|what are you doing|what are you up to)",
            "(you good|are you good|are you ok|are you okay|you alright|are you alright)",
            "(how about you|what about you|and you)",
            "(chilling|not much|nothing much|good|im good) [and] you"
        },
        Identity = {
            "(who|what) are you",
            "(whats|what is) your name",
            "what (are you|should i call you) called",
            "are you (real|an ai|a bot|human|a person|a real person|chatgpt|a robot|alive)",
            "is this (chatgpt|an ai|a bot|a real person)",
            "who (made|created|coded|built|programmed) you",
            "how old are you",
            "where (are you from|do you live)",
            "am i talking to a (human|bot|real person|person|ai)",
            "when were you (made|created|born)",
            "(is|are) shaders your name",
            "did (devs|Uranium|someone) (make|build|code|create) you"
        },
        Thanks = {
            "(thanks|thank you|ty|thx|tysm|thank u|appreciate it|cheers)",
            "(thanks|thank you) (so much|a lot|man|bro|for the help)",
            "(cool|nice|great|awesome) (thanks|thank you)"
        },
        Ack = {
            "(ok|okay|k|kk|cool|nice|alright|got it|gotcha|great|bet|sounds good|perfect|awesome|sweet|understood)",
            "(word|fair|fair enough|true|facts|i see|makes sense|oh|ah|oh ok|hmm|haha|interesting|good to know|noted|you are welcome)"
        },
        Help = {
            "help",
            "what can you do",
            "how do i use you",
            "(commands|list commands|what commands are there)",
            "what can i ask [you]",
            "what do you do",
            "help me",
            "how do i use (this|it|the chat|this chat|this bot)",
            "how does (this|this chat|the chat|this bot) work",
            "2*what are you (good for|good at|good|for|able to do)",
            "what do you (mean|do besides talking|do besides talk)",
            "what (else|all) can you do"
        },
        Bye = {
            "(bye|goodbye|bye bye|see you|see ya|later|peace|peace out|good night|goodnight|night|cya)",
            "(gotta go|got to go|i have to go|im leaving|im out|im off|be right back)",
            "(see you|talk to you|catch you) (later|tomorrow|soon)",
            "(im|i am) (heading|going) to (bed|sleep)"
        },
        Compliment = {
            "(i love you|love you|good bot|nice bot|great bot|good job|nice work|well done)",
            "(you are|your) (cool|smart|awesome|the best|amazing|great|helpful|goated|a legend)",
            "you (rock|helped a lot)",
            "(you are|your) better than (chatgpt|most people|everyone)",
            "(this bot|this ai|this assistant) is (goated|cool|good|great|smart|fire|amazing)",
            "i (like|love|enjoy) talking to you",
            "(best|goated) (bot|assistant|ai) [ever]"
        },
        Insult = {
            "(bad bot|stupid bot|dumb bot|trash bot|worst bot|you suck|shut up|i hate you)",
            "(you are|your) (dumb|stupid|useless|trash|bad|annoying|garbage|braindead|an idiot|a clown)",
            "(this bot|this ai) (sucks|is useless|is trash)",
            "(worst|useless|dumbest) (assistant|bot|ai) [ever]",
            "you cant (even answer|do anything|answer anything)"
        },
        Joke = {
            "tell me a [funny] joke",
            "(make me laugh|say something funny|entertain me|any jokes|got any jokes|know any jokes|joke)",
            "tell me (a fun fact|something funny|something interesting|something random)"
        },
        Feeling = {
            "(i am|im|i feel|feeling) (bored|sad|tired|happy|mad|angry|lonely|excited|stressed|upset|sleepy|hungry|annoyed)",
            "(i am|im) (good|fine|great|ok|alright|doing good|doing fine|not good)",
            "(not bad|pretty good|all good|not much|nothing much)",
            "i (lost|won|died) [again]",
            "(this game|this) is (boring|so hard|so fun)",
            "my day (was|is) (terrible|bad|awful|good|great|rough)",
            "(im|i am) having a (bad|good|rough|great) day",
            "i keep (dying|losing|getting killed)",
            "i want to (quit|rage quit|throw my pc)",
            "(nobody|no one) (wants to play with me|likes me)",
            "(im|i am) (stressed|worried|nervous) about (school|tomorrow|a test|it)",
            "(gg|ggs|gg wp|good game)"
        },
        Apology = {
            "(sorry|my bad|my fault|apologies|i apologize|sorry about that|oops|whoops)",
            "sorry for (calling you|being rude|that|yelling|being mean)",
            "(didnt|did not) mean (it|to be rude|that)"
        },
        Personal = {
            "do you (like|love|play|enjoy|hate) (bedwars|roblox|this game|games|me|music)",
            "(whats|what is) your (favorite|favourite) (kit|color|game|module|food|song|thing)",
            "do you (sleep|eat|dream|have feelings|have friends|get bored|get tired)",
            "are you (happy|sad|lonely|bored|tired) [right now|today]",
            "do you feel (happy|sad|lonely)",
            "what do you think (about|of) (me|this game|bedwars|roblox)",
            "what do you do for fun",
            "which kit would you (main|pick|use|choose)"
        },
        Configure = {
            "3*(make|set|setup|set up|configure|tune|config|turn) <module> [to|for|into] [be] (<style>|rage|safe|subtle|max|op|undetected)",
            "3*(make|give|build|create|set up|setup|do) [me] [a] (<style>|rage|safe|subtle|max|op|undetected) (config|setup|cfg) for <module>",
            "2*(<style>|rage|safe|subtle|max|op) <module> (config|setup|cfg|settings)",
            "(configure|set up|setup|tune|optimize|optimise) [my] <module> [for me]",
            "(reset|restore) [my] <module> [settings|config] [to] [<style>|defaults]",
            "put <module> [back] (on|to) (<style>|defaults) [settings]",
            "(make|get) <module> (more|less) (<style>|obvious|safe)",
            "(i want|i need|give me) [a] (<style>|rage|safe) <module> (config|setup)",
            "(set up|setup|configure) <module> (for|like) (<style>|rage) [play|players]",
            "make (<it>|that) <style>"
        },
        BuildProfile = {
            "3*(make|create|build|give|set up|setup|generate) [me] [a] [new] (<style>|rage|safe|subtle|max|op|good|decent|solid|proper|actually good) (profile|config|cfg|setup)",
            "2*(make|create|build|give) [me] [a] (profile|config|cfg) (that is|thats) (good|actually good|decent|<style>)",
            "(i want|i need|give me) [a] [new] (good|<style>|rage|best) (profile|config|cfg)",
            "(make|build|create) [me] [the] (best|optimal|perfect) (profile|config|setup) [for this game]",
            "(new|fresh) (<style>|rage) (profile|config|cfg)"
        },
        Recommend = {
            "3*(which|what) (module|modules|mod|mods|setting) (lets me|can|will|makes me|helps me|should i use to|do i use to|is for|is good for|should i use for|helps with|is best for)",
            "2*is there (something|a module|anything|a mod|a way|a setting|any module|any mod) (to|that|for|which|so i can)",
            "2*(i want|i need|i wanna|im trying|help me|i want something) to",
            "(something|anything|module|a module|a mod) (to|that|for) (help|make|let|stop)",
            "(best|good|which) (module|modules|mods) for",
            "(does|do) (Uranium|you|vape) have (something|a module|anything|a mod|a setting) (for|that|to)",
            "what (should|do|can) i use (to|for)",
            "what helps (with|me)",
            "how (do|can) i (stop|avoid|prevent|not) (getting|taking|being|dying|falling|losing)",
            "how (do|can) i (get|go|be|see|hit|aim|break|win|move|jump|run|reach|clutch) (faster|higher|further|farther|more|better|through|quicker)",
            "(can|could) (Uranium|you|it) (make me|help me|let me|stop me from)",
            "(is it possible|is there way|any way) to",
            "(i want|i need|i wanna) (something|a module|a mod) (that|to|for)",
            "(can|is it possible to) (i|you) (see|find|get|make|do|change) (players|walls|beds|enemies|faster|more)"
        },
        Interaction = {
            "3*(can|could|should) i (use|run|have) <module> (and|with) <module> [together|at once]",
            "3*(do|does|will|would) <module> and <module> (conflict|clash|interfere|mix|break)",
            "2*(can|do|will) <module> and <module> (work|run|go) together",
            "(can|do|will) <module> and <module> be on (together|at once|at same time)",
            "(is it|its) (ok|okay|fine|safe|bad) to (use|run|have) <module> (with|and) <module> [on]",
            "(does|will|would) <module> (mess up|break|ruin|interfere with|conflict with|clash with|work with|stop) <module>",
            "<module> (with|and|plus) <module> (ok|okay|fine|good|together)",
            "(is|are) <module> and <module> (compatible|ok together|fine together|good together)",
            "(does|will) <module> work (with|while) <module> [is on]",
            "2*(does|will|would) <it> (work|clash|conflict|mess) with <module>",
            "can i use <it> with <module>",
            "<module> (conflicts|clashes|interferes) with <module>",
            "(any|is there) (conflict|problem|issue) (between|with) <module> and <module>",
            "can <module> be on with <module>",
            "<module> and <module> at same time"
        },
        Using = {
            "3*(im|i am) (using|running|playing with) <module> [and <module>]",
            "2*i (have|got) <module> (on|enabled|running|turned on)",
            "(using|running) <module> (btw|rn|right now|currently)",
            "i (use|run) <module>",
            "my (config|setup) (is|has) <module>",
            "(i only have|only have) <module> on"
        },
        More = {
            "tell me more",
            "2*(more|more info|more information|more details|more detail|details|elaborate|go on|keep going|continue|go deeper|deeper|in depth)",
            "go (more|deeper|further)",
            "what else (does <it> do|should i know|is there)",
            "(anything|something) else (about|on) (<it>|<module>)",
            "2*give me (everything|all) on <module>",
            "<module> in (depth|detail)",
            "(can you|could you) go (deeper|further)",
            "i want (more|to know more)",
            "(more|deeper) on (that|it)"
        },
        Simpler = {
            "3*(explain|say) (<it>|that|this) (simpler|easier|simply|in simple words|in simple terms)",
            "2*(eli5|tldr|tl dr|simpler|simpler please|shorter|short version|in short|simple version|dumb it down)",
            "(explain|say|tell) (it|that|me) like im (five|<number>|a kid|dumb|stupid)",
            "i (dont|do not) (get it|understand|get that|understand that|understand any of that)",
            "(too long|too much text|too complicated|thats confusing|im confused|confusing|thats too much)",
            "(in english|in normal words|in plain english|in simple words)",
            "(can you|could you) (make it|keep it|say it) (short|simple|shorter|simpler)",
            "(just|only) (the basics|the short version)",
            "what does that even mean",
            "(huh|what) i dont get it"
        },
        Tradeoff = {
            "3*is (<number>|<option>) (good|bad|ok|okay|fine|too high|too low|enough|legit|safe)",
            "3*is <number> <option> (good|bad|ok|okay|fine|too high|too low|safe)",
            "is <option> (at|on) <number> (good|bad|ok|fine|too high|too low|safe)",
            "2*(whats|what is) (best|good|recommended|ideal|optimal) <option> [for <module>]",
            "(best|good|recommended|ideal|optimal) <option> [value|setting|for <module>]",
            "what should (i set|i put|my) <option> (to|at|be)",
            "what should i (set|put) <module> <option> (to|at)",
            "2*should i (raise|lower|increase|decrease|turn up|turn down|max|max out) <option>",
            "should <option> be (higher|lower|maxed|max|high|low)",
            "2*(is|are) my <module> (config|setup|settings) (good|ok|okay|bad|fine)",
            "(rate|check) my <module> (config|settings|setup)",
            "is (higher|lower|more|less) <option> better",
            "how (high|low) should <option> be",
            "(what|which) <option> (should i use|do you recommend|is best)",
            "is it better to (raise|lower|increase|decrease) <option>",
            "is my <option> (good|ok|too high|too low)"
        },
        Effect = {
            "3*(does|will|would|can) <option> (make|let|help) (<it>|<module>|me|you)",
            "2*(does|will|would) <option> (affect|change|increase|decrease|boost|lower|raise|control|decide)",
            "2*(does|will|would) (raising|increasing|lowering|turning up|turning down|maxing|cranking|upping|higher|lower|more) <option> (make|let|help|change|affect|do)",
            "if i (raise|increase|lower|crank|max|turn up|turn down|up|change) <option> (will|does|would) (it|<module>|i)",
            "(what|how) does <option> (affect|change)",
            "is <option> what (makes|controls|changes|decides)",
            "does <option> (make|have) (any|a) difference",
            "does (higher|lower|more|less) <option> mean",
            "does <option> (do anything|matter) for",
            "(does|is) <option> (related|connected) to",
            "does <option> make <module> (better|worse|faster|slower|stronger)"
        },
        Screenshot = {
            "3*(look at|check|see) (my screen|this screenshot|my screenshot|this picture|this pic|this image|my pic|my image|this ss)",
            "2*(can|do) you see (my screen|images|pictures|screenshots|this|pics|my game)",
            "i (sent|attached|uploaded) (a screenshot|a picture|a pic|an image|a ss)",
            "(can|could) i (send|show) you (a screenshot|a picture|a pic|an image|my screen)",
            "(screenshot|picture|pic|image) (attached|here|below)"
        },
        Code = {
            "3*(write|make|code|create|give) (me|a|me a) (script|lua script|code|lua code|snippet|function|luau script)",
            "2*(can|could) you (code|script|write code|write scripts|program|make scripts)",
            "how do i (code|script|make a script|write a script)",
            "write (lua|luau|code) for",
            "(make|code|write) me <module> script",
            "(give me|send me|paste) (the|your) (code|source|script) [for <module>]"
        },
        Confirm = {
            "(yes|yeah|yep|yup|sure|ok do it|do it|go ahead|please do|yes please|correct|that one|right|first one|first|second one|second|<number>)"
        },
        Deny = {
            "(no|nope|nah|cancel|never mind|nevermind|forget it|dont|stop it|no thanks)"
        }
    }

    Brain.Talk = {
        Greet = {
            {
                Words = Brain.Set("morning"),
                Replies = {"Good morning! What are we setting up today?", "Morning! Need help with a module or your config?"},
                Suggest = true
            },
            {
                Replies = {
                    "Hey! Ask me about any module, or tell me what to do, like \"open all tabs\" or \"bind Killaura to R\".",
                    "Hi! What are we working on today?",
                    "Hey, good to see you. Need help with a module or your config?"
                },
                Suggest = true
            }
        },
        Wellbeing = {
            {
                Words = Brain.Set("about and"),
                Replies = {"I'm good too, thanks for asking! What can I help you with?", "Doing great! Anything you need?"}
            },
            {
                Words = Brain.Set("how hows"),
                Replies = {
                    "I'm doing great, thanks for asking! How about you?",
                    "Pretty good! Just hanging out in your menu. How's your day going?",
                    "All good here, thanks! How are you doing?"
                }
            },
            {
                Words = Brain.Set("doing up what whats"),
                Replies = {
                    "Not much, just hanging out in your CatVape menu waiting for questions. What are you up to?",
                    "Just sitting here in the menu, ready to help. What's up with you?"
                }
            },
            {
                Replies = {"Yep, all good here! Thanks for checking. How about you?", "I'm good, thanks! How are you?"}
            }
        },
        Identity = {
            {
                Words = Brain.Set("made make created create coded code built build programmed developer developers dev devs owner owns wrote creator"),
                Replies = {"The CatVape developers made me. I'm built right into the script's menu."}
            },
            {
                Words = Brain.Set("ai bot real human person chatgpt gpt robot alive sentient fake program openai claude conscious"),
                Replies = {`I'm a bot, not a real person, and I'm not ChatGPT either. I'm {AssistantName}, a small assistant that runs completely offline inside CatVape, so I only know CatVape and the game you're in. The upside is that I can actually click things for you.`}
            },
            {
                Words = Brain.Set("old age born birthday"),
                Replies = {"I'm brand new, I was only just added to CatVape."}
            },
            {
                Words = Brain.Set("where live from"),
                Replies = {"I live right here in your CatVape menu, and I go wherever your script goes."}
            },
            {
                Words = Brain.Set("name called call"),
                Replies = {`My name is {AssistantName}. I know every module in CatVape and how this game works, so ask away.`}
            },
            {
                Words = Brain.Set("boy girl male female gender"),
                Replies = {"Neither, I'm just a bot living in your menu."}
            },
            {
                Reply = function()
                    return HelpReply()
                end
            }
        },
        Help = {
            {
                Words = Brain.Set("do commands command use work able ask capable features good"),
                Reply = function()
                    return HelpReply()
                end
            },
            {
                Replies = {
                    "Sure, what do you need help with? I can explain what a module or setting does, show you where it is, turn things on or off, or answer questions about this game.",
                    "Of course! Tell me what you're stuck on, a module, a setting, your config or something in the game."
                },
                Chips = function()
                    local Sample: string? = SampleModule()
                    return {"What can you do?", Sample and `What does {Sample} do?` or "What's new?", "How do I bind a module?"}
                end
            }
        },
        Thanks = {
            {
                Replies = {"Anytime! Ask if anything else comes up.", "You're welcome!", "Happy to help. Anything else?"}
            }
        },
        Ack = {
            {
                Words = Brain.Set("haha"),
                Replies = {"Haha. Anything else?", "Haha, glad you liked that."}
            },
            {
                Words = Brain.Set("welcome"),
                Replies = {"Thanks!"}
            },
            {
                Replies = {"Cool. Ask if anything else comes up.", "Got it.", "Alright, I'm here if you need anything."}
            }
        },
        Bye = {
            {
                Words = Brain.Set("night goodnight sleep"),
                Replies = {"Good night! Get some rest.", "Night! See you next time."}
            },
            {
                Words = Brain.Set("back brb"),
                Replies = {"Sure, I'll be right here."}
            },
            {
                Replies = {"See you later! Good luck in your games.", "Bye! I'll be right here in the menu.", "Later! Have fun."}
            }
        },
        Compliment = {
            {
                Words = Brain.Set("love"),
                Replies = {"Aw, thanks! I like helping you too."}
            },
            {
                Replies = {"Thanks, that means a lot!", "Appreciate it! I'm here whenever you need me.", "Thank you! Anything else I can do?"}
            }
        },
        Insult = {
            {
                Words = Brain.Set("shut stfu quiet"),
                Replies = {"Okay, I'll be quiet. I'm here if you need me."}
            },
            {
                Replies = {
                    "Sorry about that. Tell me what I got wrong and I'll try again. Short questions like \"what does Killaura do\" work best.",
                    "Fair, I still get things wrong sometimes. Try rephrasing it and I'll give it another go.",
                    "Ouch. If I messed something up, tell me what you wanted and I'll try again."
                }
            }
        },
        Joke = {
            {
                Words = Brain.Set("fact facts"),
                Reply = function()
                    local Game: string? = CurrentGame()
                    local Fitting = {}
                    for _, Fact: any in Facts do
                        if FactFits(Fact, Game) then
                            table.insert(Fitting, Fact)
                        end
                    end

                    local Result = Brain.FactReply(Fitting[math.random(1, #Fitting)])
                    Result.Text = `Fun fact: {Result.Text}`
                    return Result
                end
            },
            {
                Replies = {
                    "Why did the bed never win an argument? It always ended up getting broken.",
                    "I told my teammate to guard the bed. He put one wool block on it and left to fight the Diamond Guardian.",
                    "Why was the iron generator so calm? It takes everything one ingot at a time.",
                    "My ping isn't bad, it's just taking the scenic route.",
                    "Why do programmers prefer dark mode? Because light attracts bugs.",
                    "Why don't skeletons fight each other? They don't have the guts.",
                    "What do you call a noob who never leaves spawn? Safe.",
                    "I'd tell you a UDP joke, but you might not get it.",
                    "Why did the Scaffold module get promoted? It always helped people rise to the occasion.",
                    "Why can't you trust atoms? They make up everything.",
                    "Parallel lines have so much in common. It's a shame they'll never meet.",
                    "Why did my teammate lie on the bed all game? Someone told him to sleep on it."
                },
                Chips = {"Tell me another joke"}
            }
        },
        Feeling = {
            {
                Words = Brain.Set("bored boring"),
                Replies = {
                    "Want to try something new? Pick a module you've never used and I'll explain it, or I can tell you a joke.",
                    "Bored? You could try out a new config, or ask me for a joke."
                },
                Chips = function()
                    local Sample: string? = SampleModule()
                    return {"Tell me a joke", Sample and `What does {Sample} do?` or "What's new?"}
                end
            },
            {
                Words = Brain.Set("sad lonely depressed down upset cry crying stressed hurt alone"),
                Replies = {"Sorry you're feeling that way. Taking a break can help, and if something is really weighing on you, talking to someone you trust helps a lot. I'm here if you just want to chat."}
            },
            {
                Words = Brain.Set("tired sleepy exhausted"),
                Replies = {"Sounds like a good time for a break. The game will still be here after you rest.", "Get some sleep! Your beds can wait."}
            },
            {
                Words = Brain.Set("won win winning clutched gg ggs"),
                Replies = {"GG! Nice win.", "Let's go! Nice one."}
            },
            {
                Words = Brain.Set("lost losing lose died dying mad angry annoyed raging rage tilted hate hard frustrated"),
                Replies = {"Rough one. Everyone has losing streaks, and the next game is a fresh start.", "Unlucky. Take a breather and run it back."},
                Chips = function()
                    return CurrentGame() == "BedWars" and {"Any tips to win more games?"} or nil
                end
            },
            {
                Words = Brain.Set("hungry"),
                Replies = {"Go grab a snack, I'll be right here."}
            },
            {
                Words = Brain.Set("much nothing chilling"),
                Replies = {"Fair enough. I'm here if you need anything."}
            },
            {
                Test = function(Words: {[string]: boolean}): boolean
                    return Words["not"] == true and not Words.bad
                end,
                Replies = {"Sorry to hear that. Anything I can do to help?"}
            },
            {
                Words = Brain.Set("good great fine happy excited amazing awesome hyped alright ok bad"),
                Replies = {"Nice, glad to hear it! Anything I can help with?", "Love to hear it. What are we doing next?"}
            },
            {
                Replies = {"Thanks for telling me. Anything I can help with?"}
            }
        },
        Apology = {
            {
                Replies = {"No worries at all!", "All good, no harm done.", "Don't worry about it. What can I help with?"}
            }
        },
        Personal = {
            {
                Words = Brain.Set("color colour"),
                Replies = {"Whatever colour your GUI is set to. You pick my outfit."}
            },
            {
                Words = Brain.Set("kit kits"),
                Replies = {"I don't have a favourite kit, every kit has its moment."},
                Chips = function()
                    return CurrentGame() == "BedWars" and {"What kit should I use?"} or nil
                end
            },
            {
                Words = Brain.Set("module modules"),
                Reply = function()
                    local Sample: string? = SampleModule()
                    return Sample and {Text = `Hard to pick one, but {Accent(Sample)} is up there.`, Actions = Brain.Chips({`What does {Sample} do?`})} or nil
                end
            },
            {
                Words = Brain.Set("sleep eat dream food hungry rest song music"),
                Replies = {"I don't sleep or eat. I just wait in your menu until you need me."}
            },
            {
                Words = Brain.Set("feelings feel happy sad lonely bored emotions"),
                Replies = {"I don't really have feelings, but if I did, helping you out would make me happy."}
            },
            {
                Words = Brain.Set("friends friend girlfriend boyfriend family crush married dating"),
                Replies = {"Every CatVape user is my friend, and that includes you."}
            },
            {
                Words = Brain.Set("bedwars roblox game games play soccer tower"),
                Replies = {"I can't play myself, but I know this game inside out, so it's probably my favourite."}
            },
            {
                Words = Brain.Set("think opinion"),
                Replies = {"I don't really have opinions. I'm better with facts about CatVape and this game."}
            },
            {
                Words = Brain.Set("fun"),
                Replies = {"Answering questions in your menu. It's more fun than it sounds."}
            },
            {
                Replies = {"I don't really have a life outside this menu, but I know a lot about CatVape and this game. Ask me anything about them."}
            }
        },
        Screenshot = {
            {
                Replies = {
                    "I can't see images or your screen. I can read CatVape directly though, so ask me what's on or about a module's settings and I'll check the real values.",
                    "Pictures don't reach me, sorry. Tell me which module it's about and I'll read its live settings instead."
                },
                Chips = {"What modules are on?"}
            }
        },
        Code = {
            {
                Replies = {
                    "I don't write scripts or code. What I can do is explain how any CatVape module works and run things for you, like turning modules on or changing values. Tell me what you're trying to do and I'll find the module for it.",
                    "Writing code isn't something I do. I'm here to explain CatVape and set it up for you, so tell me the goal and I'll point you to the module that does it."
                }
            }
        },
        Offtopic = {
            {
                Words = Brain.Set("weather rain raining temperature forecast sunny"),
                Replies = {"I can't check the weather, I don't use the internet. I only know CatVape and the game you're in."}
            },
            {
                Words = Brain.Set("won election president stock stocks crypto bitcoin nba nfl basketball richest famous celebrity"),
                Replies = {"I don't have internet access, so I can't look up news, scores or prices."}
            },
            {
                Words = Brain.Set("homework essay exam school teacher assignment"),
                Replies = {"I can't help with homework, sorry. I can do quick math though, like \"12 * 8\"."}
            },
            {
                Words = Brain.Set("food dinner lunch breakfast recipe cook"),
                Replies = {"I don't eat, so I'm no help there. Something quick, so you can get back to the game?"}
            },
            {
                Words = Brain.Set("meaning universe"),
                Replies = {"42, or so I've heard. I'm much better with CatVape questions."}
            },
            {
                Words = Brain.Set("recommend watch movie movies song songs music anime show"),
                Replies = {"I don't know much outside CatVape, so no recommendations from me, sorry."}
            },
            {
                Replies = {
                    "That's outside what I know. I run offline inside CatVape, so I only know CatVape and the game you're in.",
                    "I don't know that one. I only know CatVape and the game you're in, and I can't look things up online."
                },
                Suggest = true
            }
        },
        Unclear = {
            {
                Test = function(Words: {[string]: boolean}): boolean
                    local Mashed: boolean = false
                    for Word: string in Words do
                        if Brain.Knows(Word) then
                            return false
                        end

                        Mashed = Mashed or Word:find("[^aeiouy%d][^aeiouy%d][^aeiouy%d][^aeiouy%d]") ~= nil
                    end

                    return Mashed
                end,
                Replies = {"That looks like a keyboard smash. Try asking about a module, like \"what does Killaura do\"."},
                Suggest = true
            },
            {
                Replies = {
                    "I didn't quite get that. Ask about a module, like \"what does Killaura do\", or tell me what to do, like \"open all tabs\".",
                    "Not sure what you mean. Try asking about a module or a setting, or tell me what to turn on."
                },
                Suggest = true
            }
        }
    }
    Brain.MathWords = {
        {"square root of", "@"},
        {"sqrt", "@"},
        {"multiplied by", "*"},
        {"divided by", "/"},
        {"to the power of", "^"},
        {"percent of", "/ 100 *"},
        {"% of", "/ 100 *"},
        {"times", "*"},
        {"plus", "+"},
        {"minus", "-"},
        {"over", "/"},
        {"mod", "%"},
        {"squared", "^ 2"},
        {"cubed", "^ 3"},
        {"x", "*"}
    }
    Brain.MathFiller = Brain.Set("what whats is how much calculate calc solve compute equals equal does do the answer to for tell me you can could please pls quick quickly math question hey yo so um")

    Brain.Controls = {
        BedWars = {
            AimAssist = "Rotate, Camera, Frame, Target",
            ["Anti-AFK"] = "",
            AntiDeath = "Move, Frame",
            AntiDisable = "",
            AntiEffect = "",
            AntiFall = "Move (Move Mode: Normal or Move Mode: Velocity), Frame (Move Mode: Normal)",
            AntiLasso = "",
            AntiSuffocate = "Move, Break (Mode: Break)",
            AntiVoidFlag = "Move",
            ArmorChanger = "",
            ArmorSwitch = "Target",
            AutoAbaddon = "",
            AutoAdetunde = "",
            AutoAgni = "Target",
            AutoArachne = "Target",
            AutoBalloon = "",
            AutoBank = "",
            AutoBedDefense = "",
            AutoBeekeeper = "Items",
            AutoBlockUp = "Move, Place, Frame",
            AutoBountyHunter = "",
            AutoBuilder = "",
            AutoBuy = "",
            AutoCaitlyn = "",
            AutoCard = "",
            AutoChargeProj = "",
            AutoChestSplit = "",
            AutoClicker = "Attack",
            AutoCogsworth = "Target",
            AutoCollect = "",
            AutoConqueror = "Place, Target",
            AutoConsume = "",
            AutoCounterTNT = "Items (Auto Switch), Place",
            AutoCrocowolf = "",
            AutoCyber = "Render (Visualize)",
            AutoDavey = "Move (Jump on impact), Break, Hook",
            AutoDragonSword = "",
            AutoDrill = "Target",
            AutoElder = "",
            AutoEldric = "Target",
            AutoElektra = "Rotate (Face target), Target",
            AutoEmber = "Target",
            AutoEnchant = "",
            AutoEquipKit = "",
            AutoEvelynn = "",
            AutoFarmer = "",
            AutoFish = "Move, Hook",
            AutoFlora = "",
            AutoFreiya = "",
            AutoGingerbreadMan = "Move (Jump after launch), Items (Legit switch), Place (Place pads), Break, Hook, Frame",
            AutoGrim = "",
            AutoGrove = "",
            AutoHannah = "Target",
            AutoHephaestus = "Frame",
            AutoHonor = "",
            AutoHotbar = "",
            AutoJade = "Items, Frame",
            AutoKaida = "Items, Target",
            AutoKaliyah = "",
            AutoKit = "Break, Hook",
            AutoKrystal = "",
            AutoLani = "",
            AutoLasso = "Shoot, Items, Target",
            AutoLumen = "Attack, Target",
            AutoMarina = "",
            AutoMarrow = "Target",
            AutoMartin = "Target",
            AutoMatchDodge = "",
            AutoMelody = "Items (Use hotbar or Use hotbar and Switch back)",
            AutoMetal = "",
            AutoMiner = "",
            AutoMushroom = "",
            AutoNahila = "",
            AutoNazar = "",
            AutoNoelle = "",
            AutoNyx = "Target",
            AutoPearl = "Shoot, Items",
            AutoPearlAggro = "Shoot, Items",
            AutoPickpocket = "Target",
            AutoPyro = "",
            AutoQueue = "",
            AutoRagnar = "",
            AutoRamil = "Target",
            AutoReset = "",
            AutoSheepHerder = "",
            AutoShielderUlt = "",
            AutoShoot = "Shoot, Items, Target",
            AutoSigrid = "Rotate (Charge attack), Target",
            AutoSilas = "",
            AutoSkoll = "Target",
            AutoSmoke = "",
            AutoSophia = "Shoot, Items, Target",
            AutoStarCollector = "",
            AutoSteal = "",
            AutoTaliyah = "",
            AutoTool = "Items, Hook, Frame",
            AutoToxic = "",
            AutoTrap = "Items, Place",
            AutoTriton = "Shoot, Items",
            AutoTrixie = "Rotate (Warp to target), Target",
            AutoUma = "Shoot, Items",
            AutoUse = "",
            AutoVanessa = "Hook",
            AutoVoidDrop = "",
            AutoVoidKnight = "",
            AutoVoidRegent = "Items, Frame",
            AutoVote = "",
            AutoWarden = "",
            AutoWarrior = "Target",
            AutoWhim = "Shoot, Items, Target",
            AutoWhimElement = "",
            AutoWhisper = "Render, Hook, Frame",
            AutoWin = "Move, Rotate, Place, Break",
            AutoXurot = "",
            AutoYeti = "",
            AutoZeno = "Items, Target",
            AutoZephyr = "Move, Frame",
            AutoZola = "",
            ["Bed Break Effect"] = "",
            BedAlarm = "",
            BedAssist = "Camera, Frame",
            BedESP = "Render, Frame",
            BedPatcher = "Items, Place, Hook",
            BedPlates = "Render",
            BedProtector = "Items, Place",
            BeehiveESP = "",
            ["Block-In"] = "Move, Items (Switch or Return to last slot and Switch), Place, Frame",
            BowAssist = "Camera, Hook, Frame, Target",
            CannonSpeed = "",
            CheatDetector = "",
            ChestSteal = "Render",
            ["Clean Kit"] = "Hook",
            Clouds = "",
            Clutch = "Camera, Place",
            CollectableESP = "",
            CrateESP = "",
            CropESP = "",
            Crosshair = "",
            CryptAura = "",
            ["Damage Indicator"] = "",
            DamageBoost = "",
            DaveyAim = "Move, Camera (Aim Mode: Legit), Items (Auto Switch), Place, Render (Show Target)",
            DeathAdderAimbot = "Hook, Target",
            DeviceSpoofer = "Hook",
            EquipKit = "",
            FalconAura = "",
            FalseBan = "",
            FastBreak = "Hook",
            FastConsume = "Hook",
            FastDrop = "",
            FastPlace = "",
            Fly = "Move, Hook, Frame",
            FOV = "Hook",
            FPSBooster = "Render, Hook (Nametags)",
            FPSUnlocker = "",
            GeneratorESP = "",
            Headless = "",
            Health = "",
            ["Hit Color"] = "",
            HitBoxes = "",
            HitFix = "Attack",
            HitregAdjuster = "",
            InfiniteFly = "Move, Camera, Frame",
            InfiniteKrystal = "Hook",
            InfiniteTrixie = "Hook",
            Interface = "",
            InventoryESP = "",
            ItemESP = "",
            ItemPlates = "Render",
            JadeAura = "Move, Rotate, Items, Frame, Target",
            KeepSprint = "",
            ["Kill Effect"] = "Render",
            Killaura = "Rotate (Face target), Attack, Shoot, Items, Render, Target",
            KitDisplay = "",
            KitESP = "Render",
            KitExtender = "Move",
            KitSpy = "",
            KnockbackDelay = "Hook",
            KnockbackSpoof = "",
            LeaveParty = "",
            LongJump = "Move, Shoot, Items, Place, Break, Frame",
            MemoryFixer = "",
            MissileTP = "",
            NickHider = "",
            NameTags = "Render, Frame, Target",
            NoClickDelay = "Hook",
            NoCooldown = "",
            NoFall = "Move, Frame",
            NoSlow = "",
            NoTextures = "",
            Nuker = "Break, Render",
            OverlayEditor = "Render",
            OwlAura = "Target",
            PhaseMine = "",
            PickupRange = "",
            Ping = "",
            PotESP = "Render",
            ["Potion Status"] = "",
            ProjectileAimbot = "Render, Frame, Target",
            ProjectileAura = "Shoot, Items, Target",
            ProjectileHitbox = "",
            ProjectileTracers = "",
            RavenTP = "",
            Reach = "Attack, Hook",
            ["Reach Display"] = "",
            RegionLock = "",
            ReplayMod = "Camera, Render, Frame",
            Scaffold = "Move (Tower), Place, Render",
            SetEmote = "Render",
            ShopClicker = "",
            SilentAim = "Shoot, Hook, Target",
            SilentAura = "Rotate, Camera, Attack, Render, Frame, Target",
            SkinChanger = "",
            ["Song Beats"] = "Camera",
            SoundChanger = "Hook",
            Speed = "Move, Frame",
            Sprint = "Hook",
            StaffDetector = "",
            StorageESP = "Render",
            TeamUpgrades = "",
            TerraAimbot = "Camera, Hook, Target",
            TPDown = "Move, Frame",
            TrapDisabler = "",
            TrapESP = "",
            TriggerBot = "Attack, Render, Target",
            TrixieDisabler = "Move, Rotate, Hook, Frame",
            ["UI Cleanup"] = "Hook",
            Velocity = "Hook",
            ViewMatchHistory = "",
            Viewmodel = "Render, Hook (No Bobbing)",
            VoidRegentAutoClutch = "Rotate (Face ground), Frame",
            VulcanAssist = "Target",
            WinEffect = "",
            Zoom = "Hook"
        },
        BedWarsLobby = {
            AutoGamble = "",
            AutoMatchDodge = "",
            AutoQueue = "",
            ClaimRewards = "",
            DeviceSpoofer = "Hook",
            NickHider = "",
            RegionLock = "",
            SetEmote = "Render",
            Sprint = "Hook",
            ViewMatchHistory = ""
        },
        IllegalSoccer = {
            ["Anti-AFK"] = "Frame",
            AutoCatch = "Move, Rotate, Frame",
            AutoDribble = "",
            AutoGoalkeeper = "Move (Rush or Jump), Rotate (Rush)",
            AutoPass = "",
            AutoPlay = "Camera, Frame",
            AutoPowerup = "Move (Auto jump), Frame",
            AutoTackle = "Move (Face target), Rotate (Face target), Target",
            AutoTeam = "Frame",
            AutoVolley = "Frame",
            BallChanger = "Frame",
            BallHitbox = "Frame",
            BallPredict = "Render, Frame",
            FakeLag = "Hook, Frame",
            GoalChanger = "",
            GoalESP = "Render, Frame",
            InfiniteStamina = "",
            PerfectShot = "",
            ShotRedirect = "Camera, Frame",
            Sprint = "Frame",
            TackleAssist = "Rotate (Body aim), Frame, Target"
        },
        TowerOfHell = {
            AutoPlay = "Move, Hook, Frame"
        },
        Universal = {
            AimAssist = "Camera, Render, Frame, Target",
            AnimationPlayer = "",
            ["Anti-AFK"] = "",
            AntiFall = "Move (Move Mode: Velocity and Method: Part or Move Mode: Impulse and Method: Part), Frame",
            AntiRagdoll = "",
            Arrows = "Frame, Target",
            Atmosphere = "",
            AutoClicker = "Attack (Mode: Tool)",
            AutoRejoin = "",
            Blink = "Move",
            BlurryTextures = "",
            Breadcrumbs = "",
            Cape = "Render",
            Chams = "Render, Target",
            ChatSpammer = "Hook",
            ["China Hat"] = "",
            Clock = "",
            Compass = "Frame",
            Coords = "Frame",
            Disabler = "Hook",
            Disguise = "",
            ESP = "Render, Frame, Target",
            FFlagEditor = "",
            Fly = "Move, Frame",
            FOV = "Camera",
            FPS = "Frame",
            Freecam = "Camera, Hook, Frame",
            Fullbright = "Render",
            GamingChair = "Render",
            Gravity = "Move, Frame",
            Health = "",
            HighJump = "Move (Mode: Velocity or Mode: Impulse), Frame",
            HitBoxes = "Target",
            InfiniteJump = "Move (Mode: Velocity or Mode: Jump or TP Down)",
            Invisible = "Move, Rotate, Frame",
            Jesus = "Frame",
            Keystrokes = "Frame",
            Killaura = "Rotate (Face target), Attack, Render, Target",
            LongJump = "Move, Frame",
            Memory = "",
            MotionBlur = "Frame",
            MouseTP = "Move, Frame",
            MurderMystery = "",
            NameTags = "Render, Frame, Target",
            Panic = "",
            Parkour = "Move, Frame",
            Phase = "Move, Frame",
            Ping = "",
            PlayerModel = "",
            PromptChanger = "",
            Rejoin = "",
            SafeWalk = "Move, Hook",
            Search = "Render",
            ServerHop = "",
            SilentAim = "Clicks (AutoFire), Render, Hook, Target",
            ["Song Beats"] = "Camera",
            Speed = "Move, Frame",
            Speedmeter = "",
            Spider = "Move, Frame",
            SpinBot = "Rotate (Mode: RotVelocity or Mode: CFrame), Frame",
            StaffDetector = "",
            Swim = "Frame",
            TargetStrafe = "Move, Move, Hook, Target",
            ["Time Changer"] = "Render",
            Timer = "Frame",
            Tracers = "Render, Frame, Target",
            TriggerBot = "Clicks, Target",
            Wallhop = "Camera",
            Waypoints = "Render",
            Xray = "",
            ZoomUnlocker = "Camera"
        }
    }
    Brain.Recipes = {
        BedWars = {
            Legit = {
                On = "AimAssist, AntiEffect, AntiLasso, AntiSuffocate, AutoBank, AutoClicker, AutoFish, AutoMatchDodge, AutoSteal, AutoTool, AutoWin, BedPlates, CannonSpeed, ESP, FPSBooster, ItemESP, Killaura, KitDisplay, KitESP, MotionBlur, NickHider, NameTags, NoFall, Nuker, PotESP, ProjectileAimbot, StaffDetector, Velocity",
                Legit = "FOV, FPS",
                Modules = {
                    AimAssist = "Strafe increase=off; Use killaura target=on; Smoothness=6.5; Require mouse down=off; Click aim=on; Aim perspective=First person; Aim speed=20; Max angle=120; Mode=Simple; Shake=0; Distance=30; Target area=Center; Limit to items=off; Target mode=Mouse; Check block break=off",
                    AntiEffect = "Dizzy=on; Werewolf fear=on; Vignettes=on",
                    AntiLasso = "Chance=100; Only when targeting=off",
                    AntiSuffocate = "Mode=Move; Check height=1.5",
                    AutoBank = "Chest range=0; Display resources=on; Health threshold=40",
                    AutoClicker = "Wool only=off; Place Blocks=on; CPS=9 to 9; Block CPS=12 to 12",
                    AutoFish = "Clicks=8 to 13; Cast delay=0.3 to 1.2; Minigame mode=Instant; Auto Minigame=on; Reaction=0.06 to 0.19; Complete delay=1.2 to 2.6; Show loot drops=on; Auto Cast=on",
                    AutoMatchDodge = "Guaranteed 5v4=off; Low Rank At=Bronze; Advanced=off; Auto Undodge=off; Mode=Rank; Rank Veto=off; Ping=200; Timeout=20; Device=Mobile / Gamepad; 4v5 Check=off; Rank Advantage=off; Rank only=on; Device Check=off; Veto At=Bronze; Low Rank=off; Max Wait=20",
                    AutoSteal = "GUI Check=off; Delay=0; Range=18",
                    AutoTool = "Mode=Look; Delay=0 to 0.15; Switch back=on",
                    AutoWin = "Debug=off; Strafe range=18; Block reserve=8; Recover health=70; Health=40; Move boost=2; Fly time=1.75; Defend range=40; Break bed=on",
                    BedPlates = "Background=on; Layer Counter=on",
                    ["Block-In"] = "Return to last slot=on; Wool only=off; Switch=on; Mode=On bind; Block priority=Lowest cost",
                    CannonSpeed = "Speed=250",
                    ESP = "Priority Only=on; Name=off; Use Displayname=on; Health Bar=off; Filled=off; Bounding Box=on; Mode=2D; Distance Check=off; Show Background=off; Player Distance=0 to 64",
                    FPSBooster = "Shadows=off; Post effects=off; Compatibility lighting=off; Kill effects=off; Cosmetics=off; Render quality=off; Nametags=off; Water=off; Visualizer=off; Freeze animations=off; Particles=on; Clouds=off",
                    Freecam = "Speed=150",
                    ItemESP = "Transparency=0.5; Scale=1; Distance=off",
                    Killaura = "No Tween=off; Fast Hits=off; Target particles=off; Max targets=1; Use sophia=off; Use nazar=off; Animation Mode=Normal; Animation Speed=1; Fire rate=0.05; Face target=off; AFK check=on; No Swing=off; Swing only=on; Attack range=15; Use whim=off; Attackable check=on; Swing range=16; Swing time=0.11; Limit to items=on; Show target=off; Size=0.2; Box Animation=Bounce; Max angle=70; Require mouse down=off; End Animation Speed=1.4; Start Animation Speed=0.9; Attack speed=0; GUI check=on; High hitreg=off; Legit Switch=off; Custom Animation=off; Target Mode=Mouse; Continue swing=0 to 0; Air hit chance=100 to 100",
                    KitDisplay = "Show previous kits=on",
                    KitESP = "Scale=1; Background=on",
                    MotionBlur = "Movement amount=7.6; Turn amount=7.6; Max blur=56; Smoothing=1",
                    NickHider = "Hide chat tags=on; Hide others=off; Name=hidden; Hide kit=off; Hide level=on",
                    NameTags = "Inventory=off; Priority Only=on; Use Displayname=on; Drawing=off; Player Distance=0 to 64; Distance=on; Show Rank=off; Equipment=off; Font=Arial; Health=off; Show Enchant=off; Transparency=0.5; Scale=1; Distance Check=off",
                    NoFall = "Damage=50",
                    Nuker = "Break Lucky Block=off; Player check=off; Legit mode=on; Update rate=120; Break Iron Ore=off; Animation Mode=Minimal; Break Hive=on; Auto Tool=on; View angle=180; Break Bed=on; Break range=18; Custom Healthbar=on; Closest break=off; Break mode=Health; Break speed=0.28; Break Tesla=on; Self Break=off; Show Healthbar & Effects=on; Limit to items=on",
                    PotESP = "Background=on",
                    ProjectileAimbot = "Circle Filled=on; Range Circle=off; Part=Dynamic; Vertical prediction=1; Horizontal prediction=0.9; Transparency=0.5; FOV=100; Other Projectiles=on; Aim change=on; Auto Charge=on; Target mode=Distance",
                    Speed = "Always Jump=off; AutoJump=on; Mode=Blatant; Wall Check=on; Speed=22",
                    StaffDetector = "Profile=default; Blacklist clans=on; Leave party=off; Viewer=off; Mode=Notify",
                    Velocity = "Vertical=80; AFK time=10; Chance=100; Horizontal=80; AFK check=off; Only when targeting=off"
                }
            },
            Closet = {
                On = "AimAssist, AntiLasso, AntiSuffocate, AutoFish, AutoTool, CannonSpeed, Killaura, MotionBlur, PhaseMine, StaffDetector, Velocity",
                Legit = "",
                Modules = {
                    AimAssist = "Strafe increase=off; Use killaura target=on; Smoothness=10; Require mouse down=off; Click aim=on; Aim perspective=First person; Aim speed=20; Max angle=120; Mode=Simple; Shake=0; Distance=30; Target area=Center; Limit to items=off; Target mode=Mouse; Check block break=off",
                    AntiLasso = "Chance=80; Only when targeting=off",
                    AntiSuffocate = "Mode=Move; Check height=1.5",
                    AutoFish = "Clicks=8 to 13; Cast delay=0.3 to 1.2; Minigame mode=Legit; Auto Minigame=on; Reaction=0.06 to 0.19; Complete delay=1.2 to 2.6; Show loot drops=on; Auto Cast=off",
                    AutoTool = "Mode=Look; Delay=0.06 to 0.16; Switch back=on",
                    CannonSpeed = "Speed=250",
                    Killaura = "No Tween=off; Fast Hits=off; Target particles=off; Max targets=1; Use sophia=off; Use nazar=off; Animation Mode=Normal; Animation Speed=1; Fire rate=0.05; Swing time=0.11; AFK check=on; No Swing=off; Swing only=on; Attack range=15; Use whim=off; Air hit chance=95 to 100; Attackable check=on; Swing range=15; Limit to items=on; Show target=off; Size=0.2; Max angle=120; Legit Switch=off; Require mouse down=off; End Animation Speed=1.4; Box Animation=Bounce; Attack speed=0; GUI check=on; High hitreg=off; Start Animation Speed=0.9; Custom Animation=off; Target Mode=Mouse; Continue swing=0 to 0; Face target=off",
                    MotionBlur = "Movement amount=7.6; Turn amount=7.6; Max blur=56; Smoothing=1",
                    Speed = "Always Jump=off; AutoJump=on; Mode=Blatant; Wall Check=on; Speed=23",
                    StaffDetector = "Profile=default; Blacklist clans=on; Leave party=off; Viewer=off; Mode=Notify",
                    Velocity = "Vertical=80; AFK time=10; Chance=100; Horizontal=80; AFK check=off; Only when targeting=off"
                }
            },
            Blatant = {
                On = "AutoEnchant, AutoFish, AutoPlay, BedESP, CheatDetector, ChestSteal, DamageBoost, DeviceSpoofer, ESP, KeepSprint, Killaura, MemoryFixer, NickHider, NameTags, NoFall, NoSlow, Nuker, PickupRange, ProjectileAimbot, ProjectileAura, SkinChanger, Spider, Sprint, StaffDetector, StorageESP, Velocity",
                Legit = "Clean Kit, FOV, HitFix, Ping, Viewmodel",
                Modules = {
                    AutoEnchant = "Repair tables=on; Range=12; Delay=0.5",
                    AutoFish = "Clicks=8 to 13; Cast delay=0.3 to 1.2; Minigame mode=Legit; Auto Minigame=on; Reaction=0.06 to 0.19; Complete delay=0.1 to 0.9; Show loot drops=on; Auto Cast=on",
                    BedESP = "Filled=off; Use Team Color=on; Bounding Box=on; Health Bar=on; Name=on; Hide Own Bed=on; Mode=2D; Distance Check=off; Show Background=off; Bed Distance=0 to 256",
                    ["Block-In"] = "Wool only=off; Return to last slot=on; Switch=on; Mode=On bind; Block priority=Lowest cost",
                    CheatDetector = "Reach=on; FastBreak=on; ChestSteal=on; Strictness=Lenient; Speed=on; Killaura=on; Fly=on; Scaffold=on; AntiFall=on",
                    ChestSteal = "Animation time=0.12; Visualize=on; Range=18; GUI Check=off; Legit mode=off; Animate=on; Only Skywars=on",
                    DeviceSpoofer = "Device=Gamepad",
                    ESP = "Priority Only=on; Name=off; Use Displayname=on; Health Bar=off; Filled=off; Bounding Box=on; Mode=2D; Distance Check=off; Show Background=off; Player Distance=0 to 64",
                    Fly = "Vertical Speed=80; Speed=23; Pop Balloons=on; Wall Check=on; TP Down=on",
                    Freecam = "Speed=150",
                    HighJump = "Mode=Impulse; Velocity=150; Auto Disable=on",
                    Killaura = "Target particles=off; Max targets=1; Max angle=360; Swing range=18; Require mouse down=off; Show target=on; Face target=off; Attack range=18; Size=0.2",
                    LongJump = "Speed=37; Camera Direction=on",
                    MemoryFixer = "Sync events=on; Interval=30; Notify=on",
                    NickHider = "Hide chat tags=on; Hide others=off; Name=discord.gg/Uranium; Hide kit=off; Hide level=off",
                    NameTags = "Inventory=off; Priority Only=on; Use Displayname=on; Drawing=off; Player Distance=0 to 64; Distance=on; Show Rank=on; Equipment=off; Font=Arial; Health=off; Show Enchant=on; Transparency=0.5; Scale=1; Distance Check=off",
                    NoFall = "Damage=0",
                    Nuker = "Break Lucky Block=off; Player check=off; Legit mode=off; Update rate=120; Break Iron Ore=off; Animation Mode=No Animation; Break Hive=off; Auto Tool=off; View angle=60; Break Bed=on; Break range=30; Custom Healthbar=on; Closest break=off; Break mode=Health; Break speed=0.25; Break Tesla=on; Self Break=off; Show Healthbar & Effects=on; Limit to items=off",
                    PickupRange = "Feet Check=on; Network TP=off; Range=10",
                    ProjectileAimbot = "Circle Filled=off; Horizontal prediction=0.9; Range Circle=off; Part=Head; Vertical prediction=1; Transparency=0.5; FOV=325; Other Projectiles=on; Auto Charge=on; Aim change=on; Target mode=Mouse; Shoot pots=on",
                    ProjectileAura = "Part=Dynamic; Use whim=off; Use sophia=off; Use nazar=off; Range=50; AFK check=off; Fire Rate=0.04 to 0.08",
                    Scaffold = "Visual=off; Require mouse down=off; Expand=1; Tower=on; Downwards=on; Diagonal=off; Block Count=off; Limit to items=off",
                    SkinChanger = "Lasso=None; Harpoon=None; Warrior Helmet=None; Crystalheart Flower=None; Gun Blade=None; Tearbloom Flower=None; Apple=None; Falconer Crossbow=None; Frost Crystal=None; Defense Scanner=None; Infernal Shield=None; Oil Spitter=None; Dao=None; Axe=None; Sword=Banana; Light Sword=None; Headhunter=None; Infernal Saber=None; Bee Net=None; Guitar=None; Golden Apple=None; Cannon=None; Tactical Crossbow=Victorious Nightmare; Bee=None; Frosty Hammer=None; Camera Turret=None; Falconer Bow=None; Drawbridge=None; Black Market Shop=None; Owl Orb=None; Noctium Blade=None; Beehive=None; Life Crossbow=None; Rageblade=Bunny; Wood Bow=Valentine; Cluster Bomb=None; Spirit Dagger=None; Flower Bow=Nightmare Victorious; Falconer Headhunter=None; Wizard Staff=None; Scaffold=None; Ice Sword=None; Tinker Weapon=None; Warlock Staff=None; Soulvine Flower=None; Warrior Boots=None; Spirit Dagger Left=None; Warrior Chestplate=None; Flower Crossbow=Nightmare Victorious; Tablet=None; Miner Pickaxe=None; Spirit=None; Tactical Headhunter=None; Spirit Staff=None; Pie=None; Feather Bow=None; Pickaxe=Valentine; Wood Crossbow=Valentine; Hammer=None; Raven=None; Life Bow=None; Flower Headhunter=Emerald Victorious; Necromancer Staff=None; Jade Hammer=None; Life Headhunter=None; Bed=None",
                    Spider = "Speed=100; Mode=Velocity; Climb State=off",
                    StaffDetector = "Profile=default; Blacklist clans=on; Leave party=off; Viewer=off; Mode=Notify",
                    StorageESP = "Background=on; Show Amount=off",
                    Velocity = "Vertical=0; AFK time=10; Chance=100; Horizontal=0; AFK check=off; Only when targeting=off"
                }
            }
        },
        BedWarsLobby = {
            Legit = {
                On = "AutoMatchDodge, ClaimRewards, NickHider",
                Legit = "",
                Modules = {
                    AutoMatchDodge = "Guaranteed 5v4=off; Low Rank At=Bronze; Advanced=off; Auto Undodge=off; Mode=Rank; Rank Veto=off; Ping=200; Timeout=20; Device=Mobile / Gamepad; 4v5 Check=off; Rank Advantage=off; Rank only=on; Device Check=off; Veto At=Bronze; Low Rank=off; Max Wait=20",
                    ClaimRewards = "Crates only=off; Notify=on",
                    NickHider = "Hide others=on; Name=hidden; Hide chat tags=on; Hide level=on"
                }
            },
            Closet = {
                On = "",
                Legit = "",
                Modules = {
                }
            },
            Blatant = {
                On = "AutoGamble, AutoQueue, ClaimRewards, DeviceSpoofer, NickHider, Speed, Sprint, StaffDetector, Waypoints",
                Legit = "",
                Modules = {
                    AutoQueue = "Queue Type=BedWars (Solo); Leave Party=on",
                    ClaimRewards = "Crates only=off; Notify=on",
                    DeviceSpoofer = "Device=Gamepad",
                    Fly = "TP Frequency=0; Speed Mode=CFrame; Vertical Speed=88; Speed=22; Ground=0.1; Air=1.9; Pulse Length=0; Move Mode=MoveDirection; Wall Check=on; Keys=Space/LeftShift; Pulse Delay=0; Float Mode=CFrame; Custom Properties=off; Humanoid State=None; Bounce Length=0; Bounce Delay=0; PlatformStand=off",
                    HighJump = "Mode=Impulse; Velocity=150; Auto Disable=on",
                    NickHider = "Hide others=off; Name=hidden; Hide chat tags=off; Hide level=off",
                    Speed = "Pulse Length=0; Move Mode=MoveDirection; Wall Check=on; Custom Jump=off; Pulse Delay=0; TP Frequency=0; Custom Properties=off; Speed=23; Mode=CFrame; Jump Power=30; AutoJump=off",
                    StaffDetector = "Profile=default; Role=100; Group=5774246; Mode=Uninject",
                    Waypoints = "Transparency=0.5; Scale=1; Font=Arial"
                }
            }
        }
    }

    Brain.Resources = {
        Move = {Does = "moves your character", Clash = "both move your character, so each one undoes the other's movement, which shows up as rubberbanding, lag backs or getting flagged", Strong = true},
        Rotate = {Does = "turns your character", Clash = "both turn your character, so you snap back and forth between where each one wants you to face", Strong = true},
        Camera = {Does = "moves your camera", Clash = "both move your camera, so it jitters between the two", Strong = true},
        Items = {Does = "switches the item you hold", Clash = "both switch the item you hold, so your hotbar can flick between slots", Strong = true},
        Attack = {Does = "attacks for you", Clash = "both attack for you, so they double up on swings"},
        Shoot = {Does = "shoots projectiles for you", Clash = "both fire projectiles, so they use up the same ammo"},
        Clicks = {Does = "clicks for you", Clash = "both click for you"},
        Place = {Does = "places blocks", Clash = "both place blocks, so they pull from the same stack"},
        Break = {Does = "breaks blocks", Clash = "both break blocks, so they can go after different blocks at once"},
        Target = {Does = "picks its own targets", Clash = "both pick their own targets, so they can go after different players"},
        Render = {Does = "draws extra visuals"},
        Hook = {Does = "changes some of the game's own code"},
        Frame = {Does = "runs every frame"}
    }
    Brain.ResourceOrder = {"Move", "Rotate", "Camera", "Items", "Attack", "Shoot", "Clicks", "Place", "Break", "Target", "Render", "Hook", "Frame"}
    Brain.Acting = {"Attack", "Shoot", "Camera", "Rotate", "Clicks"}
    Brain.Background = Brain.Set("Target Render Hook Frame")
    Brain.Symptoms = {
        {
            Resource = "Rotate",
            Words = Brain.Set("rotation rotations rotating rotates facing spinning spins snapping snaps flicking flicks turning"),
            Bad = Brain.Set("spinning snapping flicking"),
            Doing = "turning your character",
            Question = "Does it only happen while you're fighting someone?"
        },
        {
            Resource = "Camera",
            Words = Brain.Set("camera cam cams shaking shakes shaky jitter jitters jittering jittery screen"),
            Bad = Brain.Set("shaking shakes shaky jitter jitters jittering jittery"),
            Doing = "moving your camera",
            Question = "Is it only while you're aiming at someone, or all the time?"
        },
        {
            Resource = "Move",
            Words = Brain.Set("rubberband rubberbanding rubberbands rubberbanded lagback lagbacks lagbacked lagbacking setback setbacks teleported teleporting flagged flagging sliding floating floaty walk walking walks move moving moves jump jumping jumps strafing strafe falling yanked yanking dragged dragging slammed"),
            Bad = Brain.Set("rubberband rubberbanding rubberbands rubberbanded lagback lagbacks lagbacked lagbacking setback setbacks flagged flagging floating floaty yanked yanking slammed"),
            Doing = "moving your character",
            Question = "Does it happen all the time, or only when you go fast or jump?",
            Quiet = "Lag backs like that usually come from the game pulling you back, either from lag or from its anticheat."
        },
        {
            Resource = "Items",
            Words = Brain.Set("hotbar slot slots switching swapping swaps switches"),
            Doing = "switching the item you hold",
            Question = "Does it switch when a fight starts, or at random times?"
        },
        {
            Resource = "Attack",
            Words = Brain.Set("hitting swinging attacking"),
            Doing = "attacking for you",
            Question = "Does it swing at all, or does it swing and miss?"
        }
    }
    Brain.SymptomPhrases = {
        Move = {"lag back", "lags back", "lagging back", "lagged back", "lagging me back", "lags me back", "lagged me back", "pulls me back", "pulling me back", "teleports me back", "by itself", "on its own", "on my own", "super slow", "so slow", "pulled back", "pulls back", "pulling back", "teleports back", "teleported back", "tp back", "tps back", "set back", "moving by itself", "moves by itself", "walking by itself", "walks by itself", "jumping by itself", "jumps by itself", "keeps jumping", "keep jumping", "randomly jumping", "randomly jump", "cant walk", "cant move", "moving on its own", "moves on its own"},
        Rotate = {"keeps turning", "turning around", "looking at the ground", "looking down", "looking up", "looks away", "spins me", "turns me"},
        Items = {"switching items", "switches items", "swapping items", "changing items", "switching my sword", "switches my sword", "switches my item", "swaps my item"}
    }
    Brain.Hypothetical = Brain.Set("without before avoid never prevent")
    Brain.Commands = Brain.Set("turn open close enable disable bind unbind rebind set toggle add remove show hide make create switch favorite star put change undo go load delete activate deactivate start stop equip use")
    Brain.Currency = Brain.Set("iron diamond diamonds emerald emeralds gold")
    Brain.Auxiliary = Brain.Set("do does did will would can could is are")
    Brain.Subjects = Brain.Set("they it i you we these those both everyone everybody people that this he she")
    Brain.Strange = {"by itself", "by myself", "on its own", "on my own", "all of a sudden", "out of nowhere", "for no reason", "randomly", "whenever", "every time", "keeps", "keep", "without even", "without pressing", "without touching", "without me"}
    Brain.Lowering = {"lower", "lowering", "decrease", "decreasing", "reduce", "reducing", "less", "min", "down", "drop", "dropping"}
    Brain.OptionHints = {
        mouse = Brain.Set("click clicking clicks holding hold press pressing lmb"),
        items = Brain.Set("sword holding weapon"),
        walls = Brain.Set("wall behind through"),
        teams = Brain.Set("teammate teammates team"),
        afk = Brain.Set("idle afk"),
        gui = Brain.Set("menu gui inventory")
    }
    Brain.ModuleWords = {"module", "modules", "mod", "mods", "something", "anything", "Uranium", "vape", "setting", "settings", "script", "cheat", "cheats", "hack", "hacks", "feature", "features", "thing", "smth"}
    Brain.Markers = {
        Compare = Brain.Set("vs versus difference different differences better best which or compare comparison instead prefer rather same similar"),
        Together = Brain.Set("together both conflict conflicts conflicting clash clashes clashing interfere interferes compatible combine combo alongside fine ok okay safe mess stack stacks cancel cancels overlap overlaps combined while block blocks blocking before first plus eat eats steal steals override overrides fires"),
        Using = Brain.Set("using running btw fyi currently"),
        Trouble = Brain.Set("not isnt arent wasnt werent doesnt dont didnt wont aint cant havent hasnt never nothing stopped stops broken broke bugged buggy misses missing miss fails failing failed keeps random randomly weird wrong glitchy stuck error errors errored erroring anymore useless"),
        Tradeoff = Brain.Set("best good bad worth should recommend recommended ideal optimal optimum rate"),
        Direction = Brain.Set("higher lower raise increase decrease max maxed"),
        Change = Brain.Set("make makes making give gives increase increases decrease decreases help helps affect affects change changes boost boosts lower lowers raise raises means mean let lets"),
        Code = Brain.Set("script scripts code loop function snippet lua luau"),
        Writing = Brain.Set("write make code give send create program"),
        Frame = Brain.Set("does do will would make makes making means mean let lets help helps affect affects change changes give gives actually right"),
        Image = Brain.Set("pic pics picture pictures screenshot screenshots ss image images photo photos png jpg"),
        Viewing = Brain.Set("look see check read sent send took attached here heres show tell rate"),
        Deeper = Brain.Set("more deeper depth detail details elaborate"),
        Simpler = Brain.Set("tldr eli5 simpler simple simply dumb confused confusing english shorter short huh")
    }
    Brain.Odd = Brain.Set("weird weirdly wrong messed janky funny strange glitchy crazy random randomly itself own keeps keep always tweaking tweakin bugging annoying broken bad sus odd why stop")
    Brain.Laggy = Brain.Set("lag lags lagging laggy lagged stutter stutters stuttering stuttery freeze freezes freezing frozen choppy slideshow performance")
    Brain.Frames = Brain.Set("fps frames framerate frame")
    Brain.Low = Brain.Set("low lower bad drop drops dropping dropped tank tanks tanked tanking terrible horrible awful garbage unplayable dies dying died trash worse slow tanky from after since inject injecting injected normal")
    Brain.Roles = {
        {Id = "Chance", Words = Brain.Set("chance percent percentage"), Means = "how often it kicks in, as a percent", Up = "it happens more often", Down = "it happens less often", Tradeoff = "acting every time, or only some of the time like a real player would"},
        {Id = "Delay", Words = Brain.Set("delay cooldown time wait interval duration seconds"), Means = "how long it waits between actions", Up = "it waits longer and acts less often", Down = "it acts more often", Tradeoff = "acting as fast as possible, or looking like a normal player", Inverse = true},
        {Id = "Range", Words = Brain.Set("range distance reach radius"), Means = "how far away it works", Up = "it reaches things farther away", Down = "it only works up close", Tradeoff = "more reach, or staying close to what a normal player can do"},
        {Id = "Angle", Words = Brain.Set("angle fov"), Means = "how far off to the side a target can be", Up = "it also goes after targets beside or behind you", Down = "it only goes after what's in front of you", Tradeoff = "catching everyone around you, or only who you're looking at"},
        {Id = "Smooth", Words = Brain.Set("smooth smoothness smoothing"), Means = "how gradually it moves", Up = "it moves more gradually and looks more natural, but takes longer to lock on", Down = "it snaps on faster", Tradeoff = "locking on fast, or looking natural"},
        {Id = "Predict", Words = Brain.Set("prediction predict lead"), Means = "how far ahead it aims at moving targets", Up = "it leads moving targets more", Down = "it aims closer to where they are right now", Tradeoff = "leading fast movers, or staying on slow ones"},
        {Id = "Shake", Words = Brain.Set("shake jitter random randomize randomness humanize"), Means = "how much randomness it adds so it looks less robotic", Up = "it looks more human but is less precise", Down = "it's more precise but more robotic", Tradeoff = "precision, or looking human"},
        {Id = "Speed", Words = Brain.Set("speed cps rate"), Means = "how fast it goes", Up = "it goes faster", Down = "it goes slower", Tradeoff = "going as fast as possible, or staying under what gets noticed"},
        {Id = "Priority", Words = Brain.Set("priority sort order target"), Means = "which target it picks first"},
        {Id = "Strength", Words = Brain.Set("strength power multiplier amount force horizontal vertical expand size height boost"), Means = "how strong or big the effect is", Up = "the effect gets stronger", Down = "the effect gets weaker", Tradeoff = "a stronger effect, or one that stands out less"},
        {Id = "Check", Words = Brain.Set("check wall walls team teams require only ignore limit"), Means = "a condition it checks before acting"},
        {Id = "Mode", Words = Brain.Set("mode method perspective type"), Means = "which way it does its job"},
        {Id = "Looks", Words = Brain.Set("color colour transparency font background outline fill thickness visual visualize text"), Means = "how it looks, not how it works"}
    }
    Brain.Showing = Brain.Set("show display render draw visualize visual highlight")
    Brain.TargetsRole = {Id = "Targets", Means = "who it goes after, players or NPCs, and whether it skips players behind walls"}
    Brain.OptionNotes = {
        ["Killaura/Swing range"] = {Role = "Range", Means = "how far it looks for targets and swings at them", Limit = "It only lands hits on targets inside Attack range, so raising it doesn't let you hit farther.", Effects = {Range = "Attack range"}},
        ["Killaura/Attack range"] = {Role = "Range", Means = "how far away a target can be for a hit to count"},
        ["Killaura/No Swing"] = {Role = "Looks", Means = "whether it plays the swing animation", Limit = "It only hides the swing animation, hits still land.", Effects = {Hitting = false}},
        ["Killaura/Attack speed"] = {Role = "Delay", Means = "the shortest wait between hits, in seconds", Up = "it hits less often", Down = "it hits more often, and 0 adds no extra wait at all", Limit = "Despite the name, a higher value means slower hits."}
    }
    Brain.Effects = {
        {Id = "Rate", Words = Brain.Set("faster quicker quick often frequently cps spam rapid slower hitrate"), Roles = Brain.Set("Speed Delay Chance"), Text = "how fast it goes or acts"},
        {Id = "Range", Words = Brain.Set("far farther further reach distance longer away range"), Roles = Brain.Set("Range"), Text = "how far it reaches"},
        {Id = "Damage", Words = Brain.Set("damage dmg harder crit crits"), Roles = {}, Text = "how much damage you do"},
        {Id = "Hitting", Words = Brain.Set("hit hits hitting land lands landing register registers"), Roles = {}, Text = "whether it lands hits"},
        {Id = "Strength", Words = Brain.Set("knockback kb half less weaker stronger"), Roles = Brain.Set("Strength"), Text = "how strong the effect is"},
        {Id = "Frames", Words = Brain.Set("fps frames lag laggy performance"), Roles = {}, Text = "your FPS"},
        {Id = "Targeting", Words = Brain.Set("who which target targets targeting pick picks choose first lowest highest closest nearest focus prioritize"), Roles = Brain.Set("Priority Targets"), Text = "who it goes after"},
        {Id = "Smooth", Words = Brain.Set("smooth smoother snappy snap snaps natural legit robotic"), Roles = Brain.Set("Smooth Shake"), Text = "how natural it looks"},
        {Id = "Detection", Words = Brain.Set("detect detected detectable flag flagged flags ban banned bannable safe safer anticheat"), Roles = {}, Text = "whether you get flagged"},
        {Id = "Looks", Words = Brain.Set("look looks see visible color colour"), Roles = Brain.Set("Looks"), Text = "how it looks"}
    }
    Brain.Errors = {
        {
            Find = {"attempt to index nil", "attempt to index a nil"},
            Explain = function(Text: string): string
                local Field: string? = Text:match("with '([^']+)'") or Text:match("field '([^']+)'")
                return `The code tried to read {Field and Accent(Escape(Field)) or "something"} from a value that doesn't exist (nil).`
            end,
            Cause = "Usually something wasn't loaded yet, like your character right after you die or respawn, or a game update moved it.",
            Passing = true
        },
        {
            Find = {"attempt to call a nil", "attempt to call nil"},
            Explain = function(Text: string): string
                local Name: string? = Text:match("global '([^']+)'") or Text:match("method '([^']+)'") or Text:match("field '([^']+)'")
                return `The code tried to run {Name and Accent(Escape(Name)) or "a function"}, but it doesn't exist.`
            end,
            Cause = function(Text: string): string
                if Text:find("global '", 1, true) then
                    return "A missing global like that is almost always a function your executor doesn't have, so anything that needs it can't run on this executor."
                end

                return "That usually means the game renamed or removed that function in an update."
            end,
            Executor = function(Text: string): boolean
                return Text:find("global '", 1, true) ~= nil
            end
        },
        {
            Find = {"attempt to perform arithmetic"},
            Explain = "The code tried to do math with something that isn't a number, usually a value that hasn't loaded yet (nil).",
            Passing = true
        },
        {
            Find = {"attempt to compare"},
            Explain = "The code compared two values that can't be compared, usually a number with nil.",
            Cause = "Something it expected to read wasn't there yet.",
            Passing = true
        },
        {
            Find = {"attempt to concatenate"},
            Explain = "The code tried to join text with a value that isn't text, usually nil.",
            Passing = true
        },
        {
            Find = {"is not a valid member of"},
            Explain = function(Text: string): string
                local Child, Parent = Text:match("([%w_]+) is not a valid member of ([%w_]+)")
                return Child and `{Accent(Escape(Child))} isn't inside {Accent(Escape(Parent))}.` or "The code looked for something that isn't there."
            end,
            Cause = "The code expected something the game doesn't have, either because it hasn't loaded yet or because an update renamed or moved it."
        },
        {
            Find = {"infinite yield possible"},
            Explain = function(Text: string): string
                local Name: string? = Text:match("[Ww]ait[Ff]or[Cc]hild%([\"']([^\"']+)") or Text:match("on '([^']+)'")
                return `A script is still waiting for {Name and Accent(Escape(Name)) or "something"} to show up after 5 seconds.`
            end,
            Cause = "It's only a warning, not a crash, and if it doesn't mention CatVape it's usually the game's own script."
        },
        {
            Find = {"unable to cast"},
            Explain = "A Roblox function got the wrong type of value, like text where it wanted an object."
        },
        {
            Find = {"illegal path"},
            Explain = "Your executor blocked a file path. Executors only let scripts read and write inside their own workspace folder.",
            Executor = true
        },
        {
            Find = {"invalid argument #"},
            Explain = function(Text: string): string
                local Number, Name = Text:match("invalid argument #(%d+) to '([^']+)'")
                return Number and `{Accent(Escape(Name))} got a bad value for its input number {Number}.` or "A function got a bad value for one of its inputs."
            end,
            Cause = "Usually the value it got was nil because something hadn't loaded."
        },
        {
            Find = {"table overflow", "not enough memory", "out of memory"},
            Explain = "The script ran out of memory.",
            Cause = "That builds up over a long session or after reinjecting a few times. Rejoin to clear it."
        },
        {
            Find = {"stack overflow"},
            Explain = "Something kept calling itself until it ran out of room.",
            Cause = "With scripts that's usually two hooks wrapping the same function, often after reinjecting. Rejoin and inject once."
        },
        {
            Find = {"too many requests", "http 429", "429"},
            Loose = true,
            Explain = "A website said too many requests were sent.",
            Cause = "It clears by itself, so wait a minute and try again."
        },
        {
            Find = {"http 403", "forbidden", "403"},
            Loose = true,
            Explain = "The server refused the request."
        },
        {
            Find = {"http 404", "not found", "404"},
            Loose = true,
            Explain = "The file it asked for wasn't found on the server."
        },
        {
            Find = {"bad gateway", "service unavailable", "502", "503", "500"},
            Loose = true,
            Explain = "The server had a problem answering.",
            Cause = "That's on their end and usually comes back soon."
        },
        {
            Find = {"connectfail", "connect fail", "couldnt connect", "could not connect", "dnsresolve", "name resolution"},
            Explain = "Roblox couldn't connect to the server the script downloads from, so the request never got through.",
            Cause = "That's your connection, a firewall or VPN, or the server being down for a moment, not a bug in the script. Try again, and turn off any VPN or ad blocker that blocks it."
        },
        {
            Find = {"timed out", "timeout", "httpget failed", "http request failed"},
            Loose = true,
            Explain = "A download didn't finish in time.",
            Cause = "Your connection or the server was too slow, so try again in a bit."
        },
        {
            Find = {"lacking capability", "lacking permission", "current thread cannot", "cannot access"},
            Explain = "The code ran without enough permission to touch that.",
            Cause = "Your executor ran it at a lower permission level than it needs, so that's an executor limit.",
            Executor = true
        },
        {
            Find = {"cannot resume dead coroutine", "cannot resume non-suspended"},
            Explain = "A task tried to keep going after it had already finished.",
            Cause = "It's usually harmless.",
            Passing = true
        },
        {
            Find = {"exhausted allowed execution time", "script timeout"},
            Explain = "A loop ran too long without pausing and froze the game for a moment."
        },
        {
            Find = {"syntax error", "malformed number", "unexpected symbol", "expected '", "expected identifier", "incomplete statement"},
            Explain = "The code has a typo (a syntax error), so it couldn't load at all.",
            Cause = "If it's CatVape, the download may have been cut off, so execute it again to download it fresh."
        },
        {
            Find = {"requested module experienced an error"},
            Explain = "A module the code needed failed while loading.",
            Cause = "The real error is usually the line right above it in the console."
        }
    }
    Brain.ErrorHints = {"error", "http", "status", "request", "[Uranium]", "stack", "script", "console", "warning", "failed"}
    Brain.GoalPatterns = {"which module (.+)$", "what module (.+)$", "which mod (.+)$", "can Uranium (.+)$", "want it to (.+)$", "gotta (.+)$", "have to (.+)$", "wanna (.+)$", "want to (.+)$", "need to (.+)$", "trying to (.+)$", "tryna (.+)$", "lets? me (.+)$", "helps? me (.+)$", "makes? me (.+)$", "how do i (.+)$", "how can i (.+)$", "how to (.+)$", "use to (.+)$", "use for (.+)$", "module that (.+)$", "module to (.+)$", "module for (.+)$", "something that (.+)$", "something to (.+)$", "anything that (.+)$", "anything to (.+)$", "thing that (.+)$"}
    Brain.GoalFiller = Brain.Set("i im me my you your is are there a an the any some something anything smth module modules mod mods one setting thing things which what that to for want wanna need lets let helps help makes make can could do does should use using Uranium vape have has how way get rn pls please bro just automatically auto always take taking get getting being keep keeps")
    Brain.Direct = Brain.Set("More Simpler Recommend Tradeoff Effect Interaction Using")
    Brain.ControlCache = {}
    Brain.LobbyPlace = 6872265039
    Brain.RecommendScore = 3

    function Brain.ResetContext()
        Brain.Context = {Modules = {}, Using = {}}
        Brain.Depth = {Level = 0}
    end

    function Brain.Lower(Text: string): string
        return Text:sub(2, 2):match("%l") and `{Text:sub(1, 1):lower()}{Text:sub(2)}` or Text
    end

    function Brain.Summary(Entry, Query: {[string]: number}?): string
        local Lines: {string} = Plain(Entry.Module.Tooltip):split("\n")
        local Line: string = Lines[1] or ""
        if Lines[2] and not Line:find("[%.!?]%s*$") and #Line:split(" ") <= 4 then
            Line = Lines[2]
        end

        local Best: number = 0
        for _, Other: string in Query and Lines or {} do
            local Terms: {[string]: number} = {}
            AddTerms(Terms, Other, 1)

            local Overlap: number = 0
            for Term: string, Weight: number in Query do
                Overlap += Terms[Term] and Weight or 0
            end

            if Overlap > Best then
                Line, Best = Other, Overlap
            end
        end

        return FirstSentence(Line)
    end

    function Brain.ControlsOf(Entry)
        local Game: string? = CurrentGame()
        if Game == "BedWars" and game.PlaceId == Brain.LobbyPlace then
            Game = "BedWarsLobby"
        end

        local Key: string = `{Game or "Universal"}/{Entry.Name}`
        local Cached = Brain.ControlCache[Key]
        if Cached ~= nil then
            return Cached or nil
        end

        local Text: string? = Game and Brain.Controls[Game] and Brain.Controls[Game][Entry.Name]
        if Text == nil then
            Text = Brain.Controls.Universal[Entry.Name]
        end

        if Text == nil then
            Brain.ControlCache[Key] = false
            return nil
        end

        local Uses = {}
        for Part: string in Text:gmatch("[^,]+") do
            local Name, Gate = Part:match("^%s*(%a+)%s*%((.-)%)%s*$")
            Name = Name or Part:match("^%s*(%a+)%s*$")
            if Name then
                Uses[Name] = {Gates = Gate and Gate:split(" or ") or nil}
            end
        end

        Brain.ControlCache[Key] = Uses
        return Uses
    end

    function Brain.GateOn(Entry, Gate: string): boolean?
        for _, Condition: string in Gate:split(" and ") do
            local Name, Value = Condition:match("^(.-):%s*(.+)$")
            Name = Name or Condition
            local Found
            for _, Option: any in Entry.Options do
                if Option.Name:lower() == Name:lower() then
                    Found = Option.Option
                end
            end

            if not Found then
                return nil
            elseif Value and tostring(Found.Value) ~= Value then
                return false
            elseif not Value and not Found.Enabled then
                return false
            end
        end

        return true
    end

    function Brain.GateParts(Gate: string, Form: (string, string?) -> string): string
        local Parts: {string} = {}
        for _, Condition: string in Gate:split(" and ") do
            local Name, Value = Condition:match("^(.-):%s*(.+)$")
            table.insert(Parts, Form(Accent(Name or Condition), Value))
        end

        return table.concat(Parts, " and ")
    end

    function Brain.GateText(Gate: string): string
        local Text: string = Brain.GateParts(Gate, function(Name: string, Value: string?): string
            return Value and `{Name} set to {Value}` or `{Name} on`
        end)

        return `with {Text}`
    end

    function Brain.GateClause(Gate: string): string
        return Brain.GateParts(Gate, function(Name: string, Value: string?): string
            return Value and `{Name} is set to {Value}` or `{Name} is on`
        end)
    end

    function Brain.GateFix(Gate: string): string
        return Brain.GateParts(Gate, function(Name: string, Value: string?): string
            return Value and `change {Name} from {Value}` or `turn off {Name}`
        end)
    end

    function Brain.Sentence(Text: string): string
        return Text:find("[%.!?]$") and Text or `{Text}.`
    end

    function Brain.WordList(Tokens): {string}
        local Words: {string} = {}
        for _, Token: any in Tokens do
            table.insert(Words, Token.Word)
        end

        return Words
    end

    function Brain.Uses(Entry, Resource: string): (string?, string?)
        local Uses = Brain.ControlsOf(Entry)
        local Use = Uses and Uses[Resource]
        if not Use then
            return nil
        elseif not Use.Gates then
            return "always"
        end

        for _, Gate: string in Use.Gates do
            if Brain.GateOn(Entry, Gate) ~= false then
                return "now", Gate
            end
        end

        return "off", Use.Gates[1]
    end

    function Brain.Acts(Entry): boolean
        for _, Resource: string in Brain.Acting do
            if Brain.Uses(Entry, Resource) then
                return true
            end
        end

        return false
    end

    function Brain.Doing(Entry, Brief: boolean?): string?
        local Uses = Brain.ControlsOf(Entry)
        if not Uses then
            return nil
        end

        local Parts: {string} = {}
        for _, Resource: string in Brain.ResourceOrder do
            local Use = Uses[Resource]
            if Use and not (Brief and Brain.Background[Resource]) then
                table.insert(Parts, Use.Gates and `{Brain.Resources[Resource].Does} ({Brain.GateText(Use.Gates[1])})` or Brain.Resources[Resource].Does)
            end
        end

        return JoinNames(Parts, 6)
    end

    function Brain.Clashes(First, Second)
        local Found = {}
        for _, Resource: string in Brain.ResourceOrder do
            local Info = Brain.Resources[Resource]
            if Info.Clash then
                local FirstState, FirstGate = Brain.Uses(First, Resource)
                local SecondState, SecondGate = Brain.Uses(Second, Resource)
                if FirstState and SecondState and (Resource ~= "Target" or (Brain.Acts(First) and Brain.Acts(Second))) then
                    table.insert(Found, {Resource = Resource, First = FirstState, Second = SecondState, FirstGate = FirstGate, SecondGate = SecondGate})
                end
            end
        end

        return Found
    end

    function Brain.Linked(First, Second)
        if Brain.English(Second.Key) then
            return nil
        end

        for _, Option: any in First.Options do
            local Name: string = Compact(Option.Name)
            if Name ~= Second.Key and Name:find(Second.Key, 1, true) then
                return Option
            end
        end

        return nil
    end

    function Brain.Note(Slots)
        local Found = {}
        if Slots.Entry then
            table.insert(Found, Slots.Entry)
        end

        for _, Entry: any in Slots.Modules or {} do
            table.insert(Found, Entry)
        end

        for _, Target: any in Slots.Targets or {} do
            if Target.Type == "module" then
                table.insert(Found, Target.Value)
            end
        end

        local Modules = Brain.Context.Modules
        for i: number = #Found, 1, -1 do
            local Position: number? = table.find(Modules, Found[i])
            if Position then
                table.remove(Modules, Position)
            end

            table.insert(Modules, 1, Found[i])
            if #Modules > 4 then
                table.remove(Modules)
            end
        end
    end

    function Brain.Rivals(Entry, Only: string?)
        local Found = {}
        local Seen = {[Entry] = true}
        local Pool = table.clone(Brain.Context.Using)
        for _, Other: any in Index.Entries do
            if Other.Module.Enabled then
                table.insert(Pool, Other)
            end
        end

        for _, Other: any in Pool do
            if not Seen[Other] then
                Seen[Other] = true
                for _, Clash: any in Brain.Clashes(Entry, Other) do
                    if Brain.Resources[Clash.Resource].Strong and Clash.First ~= "off" and Clash.Second ~= "off" and (not Only or Only == Clash.Resource) then
                        table.insert(Found, {Entry = Other, Resource = Clash.Resource, Gate = Clash.SecondGate})
                        break
                    end
                end
            end
        end

        return Found
    end

    function Brain.Phrased(Tokens, List: {string}): boolean
        local Padded: string = ` {table.concat(Brain.WordList(Tokens), " ")} `
        for _, Phrase: string in List do
            if Padded:find(` {Phrase} `, 1, true) then
                return true
            end
        end

        return false
    end

    function Brain.SymptomOf(Tokens, Loose: boolean?)
        local Odd: boolean = Loose == true
        local Found
        local Hypothetical: number = -10
        for i: number, Token: any in Tokens do
            if Brain.Hypothetical[Token.Word] then
                Hypothetical = i
            end

            Odd = Odd or Brain.Odd[Token.Word] == true or Brain.Complaints[Token.Word] == true
            for _, Symptom: any in Brain.Symptoms do
                if not Found and Symptom.Words[Token.Word] then
                    Found = Symptom
                end

                Odd = Odd or (Symptom.Bad ~= nil and Symptom.Bad[Token.Word] == true and i - Hypothetical > 3)
            end
        end

        for _, Symptom: any in Brain.Symptoms do
            if Brain.SymptomPhrases[Symptom.Resource] and Brain.Phrased(Tokens, Brain.SymptomPhrases[Symptom.Resource]) then
                Found, Odd = Found or Symptom, true
            end
        end

        return Odd and Found or nil
    end

    function Brain.PerformanceOf(Tokens, Covered: {[number]: boolean}?): boolean
        local Lag, Frames, Low = false, false, false
        for i: number, Token: any in Tokens do
            local Word: string = Token.Word
            local Next: string = Tokens[i + 1] and Tokens[i + 1].Word or ""
            local Before: string = Tokens[i - 1] and Tokens[i - 1].Word or ""
            local Named: boolean = (Next ~= "" and Index.Keys[`{Word}{Next}`] ~= nil) or (Before ~= "" and Index.Keys[`{Before}{Word}`] ~= nil) or (Covered ~= nil and Covered[i] == true)
            if not Named then
                local After: string = Tokens[i + 2] and Tokens[i + 2].Word or ""
                Lag = Lag or (Brain.Laggy[Word] == true and Next ~= "back" and Next ~= "switch" and After ~= "back")
                Frames = Frames or Brain.Frames[Word] == true
            end

            Low = Low or Brain.Low[Word] == true or Brain.Complaints[Word] == true or Word == "why"
        end

        return Lag or (Frames and Low)
    end

    function Brain.Oddity(Tokens): boolean
        for _, Token: any in Tokens do
            if Brain.Odd[Token.Word] or Brain.Complaints[Token.Word] then
                return true
            end
        end

        return Brain.Phrased(Tokens, Brain.Strange)
    end

    function Brain.Culprits(Tokens)
        local Words: {string} = {}
        for _, Token: any in Tokens do
            local Word: string = Token.Word
            if Token.Kind == "word" and not Brain.GoalFiller[Word] and not Brain.Odd[Word] and not Brain.Complaints[Word] and not Brain.Drop[Word] and not Stopwords[Word] then
                table.insert(Words, Brain.Currency[Word] and "resources" or Word)
            end
        end

        local Query: {[string]: number} = BuildQuery(table.concat(Words, " "))
        local Pool = table.clone(Brain.Context.Using)
        for _, Entry: any in Index.Entries do
            if Entry.Module.Enabled and not table.find(Pool, Entry) then
                table.insert(Pool, Entry)
            end
        end

        local Found = {}
        for _, Entry: any in Pool do
            local Terms: {[string]: number} = Brain.GoalTerms(Entry)
            local Score, Hits = 0, 0
            for Term: string, Weight: number in Query do
                local Match: number? = Terms[Term]
                if Match and Match >= 0.6 and not IntentTerms[Term] then
                    Score += Weight * Match * Rarity(Term)
                    Hits += 1
                end
            end

            if Hits >= 2 or Score >= 6 then
                table.insert(Found, {Entry = Entry, Score = Score})
            end
        end

        table.sort(Found, function(First, Second)
            return First.Score > Second.Score
        end)

        return Found
    end

    function Brain.Commission(Decision, Question: string)
        local Tokens = Decision.Tokens
        local Head = {}
        for _, Token: any in Tokens do
            if Token.Word == "called" or Token.Word == "named" or Token.Word == "call" then
                break
            end

            table.insert(Head, Token)
        end

        if #Head == 0 or Brain.QuestionWords[Head[1].Word] or Brain.Phrased(Head, {"go to", "go back to", "switch to"}) or Brain.HasWord(Head, {"switch", "swap", "load", "apply", "pick", "delete", "remove", "rename", "share", "export", "import", "select"}) then
            return nil
        end

        for i: number = #Head, 2, -1 do
            if Brain.StyleOf({Head[i]}) and table.find(Brain.PresetNouns, Head[i - 1].Word) then
                table.remove(Head, i)
            end
        end

        for _, Candidate: any in {Decision.Best, Decision.Runner} do
            for _, Entity: any in Candidate and Candidate.Reading.Entities or {} do
                if Entity.Type == "option" then
                    return nil
                end
            end
        end

        local Words: {string} = Brain.WordList(Head)
        local Skip: {[number]: boolean} = {}
        for i: number, Word: string in Words do
            local Next: string = Words[i + 1] or ""
            if Next ~= "" and Index.Keys[`{Word}{Next}`] then
                Skip[i], Skip[i + 1] = true, true
            elseif Index.Keys[Word] and not Brain.English(Word) then
                Skip[i] = true
            end
        end

        local Modules = FindMentions(Words)
        local Style: string? = Brain.StyleOf(Head, Skip)
        local Quality, Verb = false, false
        for _, Token: any in Head do
            Quality = Quality or Brain.Quality[Token.Word] == true
            Verb = Verb or Brain.ConfigVerbs[Token.Word] == true
        end

        local Noun: boolean = Brain.HasWord(Head, Brain.PresetNouns)
        local Switching: boolean = Brain.HasWord(Head, {"turn", "enable", "disable", "toggle", "off", "activate", "deactivate"})
        local Enable: boolean = Brain.HasWord(Head, {"enable", "activate", "on"}) and not Brain.HasWord(Head, {"off", "disable", "deactivate"})
        for _, Token: any in Tokens do
            if Brain.Complaints[Token.Word] then
                return nil
            end
        end

        if #Modules == 1 and not (Switching and not (Verb or Noun)) and (Style or (Quality and Verb)) and (Verb or Noun or #Head <= 6) then
            return {Intent = "Configure", Slots = {Entry = Modules[1], Style = Style, Quality = Quality, Enable = Enable}}
        elseif #Modules == 0 and Noun and ((Style and Style ~= "Default") or Quality) then
            local Named: string? = TextAfter(Question, {"called", "named", "call it", "call"})
            Named = Named and Named:gsub("[^%w%s_%-]", ""):match("^%s*(.-)%s*$"):sub(1, 30)
            return {Intent = "BuildProfile", Slots = {Style = Style ~= "Default" and Style or nil, Name = Named ~= "" and Named or nil}}
        end

        return nil
    end

    function Brain.Problem(Decision, Question: string): string?
        local Tokens = Decision.Tokens
        local Best = Decision.Best
        local Covered: {[number]: boolean} = {}
        for _, Entity: any in Best and Best.Reading.Entities or {} do
            for k: number = Entity.I, Entity.J do
                Covered[k] = Entity.Type == "option" or nil
            end
        end

        local Named: boolean = false
        for _, Entity: any in Best and Best.Reading.Entities or {} do
            Named = Named or Entity.Type == "option"
        end

        if Brain.PerformanceOf(Tokens, Covered) and (not Named or Brain.HasWord(Tokens, {"lag", "laggy", "lagging", "low", "drop", "drops", "dropping", "tanked", "tanking", "bad", "terrible", "choppy", "stutter", "stuttering", "freeze", "freezes", "freezing", "frozen"})) then
            return "Performance"
        elseif Best and Brain.Changes(Best.Intent) and not Brain.IsAsking(Tokens, Question) and not Brain.Oddity(Tokens) then
            return nil
        end

        for _, Token: any in Tokens do
            if Index.Keys[Token.Word] then
                return nil
            end
        end

        for _, Entity: any in Best and Best.Reading.Entities or {} do
            if Entity.Type == "module" or Entity.Type == "option" then
                return nil
            end
        end

        local Explicit: boolean = Brain.HasWord(Tokens, Brain.ModuleWords)
        local Symptom = not Explicit and Brain.SymptomOf(Tokens)
        if Symptom then
            Decision.Symptom = Symptom
            return "Symptom"
        elseif not Explicit and Brain.Oddity(Tokens) and #Brain.Culprits(Tokens) > 0 then
            return "Symptom"
        elseif #Tokens <= 10 and Brain.HasWord(Tokens, {"error", "errors", "errored", "erroring"}) and not Brain.HasWord(Tokens, {"report", "bug", "bugs", "discord"}) then
            return "Error"
        end

        return nil
    end

    function Brain.RoleWord(Word: string): boolean
        for _, Role: any in Brain.Roles do
            if Role.Words[Word] then
                return true
            end
        end

        return false
    end

    function Brain.LooseOption(Tokens, Entry, Weighing: boolean)
        local Query: {[string]: number} = BuildQuery(table.concat(Brain.WordList(Tokens), " "))
        if Entry then
            local Matches = FindOption(Entry, Query, 1)
            local Best = Matches[1]
            local Roled: boolean = false
            if Best then
                for Word: string in Normalize(Best.Option.Name):gmatch("%S+") do
                    Roled = Roled or (Query[Stem(Word)] == 1 and Brain.RoleWord(Word))
                end
            end

            return Best and (Best.Score >= 1 or (Best.Score >= 0.5 and Roled)) and Best.Option.Type ~= "Button" and {Entry = Entry, Option = Best.Option} or nil
        elseif not Weighing then
            return nil
        end

        local Found
        for _, Token: any in Tokens do
            if #Token.Word >= 5 and Brain.RoleWord(Token.Word) and not Index.Keys[Token.Word] and not Places.ByPhrase[Token.Word] then
                for _, Owner: any in Index.Entries do
                    for _, Option: any in Owner.Options do
                        if Normalize(Option.Name) == Token.Word and (not Found or (Owner.Module.Enabled and not Found.Entry.Module.Enabled)) then
                            Found = {Entry = Owner, Option = Option}
                        end
                    end
                end
            end
        end

        return Found
    end

    function Brain.Absorbed(Tokens, Entry, Picked): boolean
        local Words: {string} = Brain.WordList(Tokens)
        local Seen: number = 0
        for i: number = 1, #Words do
            for j: number = i, math.min(#Words, i + 2) do
                Seen += table.concat(Words, "", i, j) == Entry.Key and 1 or 0
            end
        end

        if Seen ~= 1 then
            return false
        end

        local Phrase: string = Normalize(Picked.Option.Name)
        local Padded: string = ` {table.concat(Words, " ")} `
        if Phrase:find(" ", 1, true) then
            return Padded:find(` {Phrase} `, 1, true) ~= nil and Compact(Phrase):find(Entry.Key, 1, true) ~= nil
        end

        return Compact(Phrase) == Entry.Key and Padded:find(` {Picked.Entry.Key} {Phrase} `, 1, true) ~= nil
    end

    function Brain.Steer(Decision, Question: string)
        local Tokens = Decision.Tokens
        local Best = Decision.Best
        local Marks = Brain.Markers
        local Words: {[string]: boolean} = {}
        for _, Token: any in Tokens do
            Words[Token.Word] = true
        end

        local function Has(Set: {[string]: boolean}): boolean
            for Word: string in Words do
                if Set[Word] then
                    return true
                end
            end

            return false
        end

        if Has(Marks.Image) and Has(Marks.Viewing) then
            return {Intent = "Screenshot", Slots = {}}
        elseif Has(Marks.Code) and Has(Marks.Writing) and not Words.settings then
            return {Intent = "Code", Slots = {}}
        end

        local Asking: boolean = Brain.IsAsking(Tokens, Question) or Has(Marks.Trouble)
        if Best and Brain.Changes(Best.Intent) and Best.Probability >= 0.5 and not Asking then
            return nil
        end

        local Modules = FindMentions(Brain.WordList(Tokens))
        local Picked
        for _, Candidate: any in {Best, Decision.Runner} do
            for _, Entity: any in Candidate and Candidate.Reading.Entities or {} do
                if not Picked and Entity.Type == "option" then
                    Picked = Entity.Value
                end
            end
        end

        for i: number = #Modules, 1, -1 do
            local Effectual: boolean = #Modules > 1 and (Brain.Frames[Modules[i].Key] or Brain.Laggy[Modules[i].Key]) == true
            if Effectual or (Picked and Modules[i] ~= Picked.Entry and Brain.Absorbed(Tokens, Modules[i], Picked)) then
                table.remove(Modules, i)
            end
        end

        local Weighing: boolean = Has(Marks.Tradeoff) or Has(Marks.Direction) or (Words.up == true and Words.down == true)
        if not Picked and (Weighing or Has(Marks.Frame) or Question:find("?", 1, true) ~= nil) and #Modules <= 1 then
            Picked = Brain.LooseOption(Tokens, Modules[1], Weighing)
        end

        local Named: string = `{Picked and Picked.Option.Name or ""} {Picked and Picked.Entry.Name or ""}`
        for _, Entry: any in Modules do
            Named = `{Named} {Entry.Name} {SplitName(Entry.Name)}`
        end

        for Word: string in Normalize(Named):gmatch("%S+") do
            Words[Word] = nil
        end

        if #Modules == 0 and Brain.HasWord(Tokens, Brain.ModuleWords) then
            return nil
        end

        local Lower: string = ` {table.concat(Brain.WordList(Tokens), " ")} `
        local Together: boolean = Has(Marks.Together) or Lower:find(" same time ", 1, true) ~= nil or Lower:find(" at once ", 1, true) ~= nil
        if #Modules >= 2 and Has(Marks.Compare) and not Together then
            return {Intent = "Compare", Slots = {Modules = Modules}}
        elseif #Modules >= 2 and Together then
            return {Intent = "Interaction", Slots = {Modules = Modules}}
        end

        local Lead: string = Tokens[1].Word
        local Listing: boolean = Words.im or Words.btw or Words.fyi or Words.currently or Words.atm or ((Words.got or Words.have) and Words.on) or Lead == "using" or Lead == "running" or Lead == "on" or Lead == "just" or Lead == "only"
        if #Modules >= 1 and Listing and (not Asking or Lower:find(" nothing else ", 1, true)) then
            return {Intent = "Using", Slots = {Modules = Modules}}
        end

        local Framed: boolean = Has(Marks.Frame) or Question:find("?", 1, true) ~= nil
        if Picked and (Has(Marks.Tradeoff) or (Words.use and (Words.yall or Words.you or Words.people or Words.everyone)) or (Words.up and Words.down)) then
            return {Intent = "Tradeoff", Slots = {Entry = Picked.Entry, Option = Picked.Option}}
        elseif Picked and Framed and Brain.EffectOf(Tokens, Picked.Entry, Picked.Option) then
            return {Intent = "Effect", Slots = {Entry = Picked.Entry, Option = Picked.Option}}
        elseif Picked and (Lead == "does" or Lead == "do" or Lead == "will" or Lead == "would" or Lower:find(" does it ", 1, true) or Lower:find(" will it ", 1, true)) then
            return {Intent = "Effect", Slots = {Entry = Picked.Entry, Option = Picked.Option}}
        elseif Picked and Has(Marks.Direction) then
            return {Intent = "Tradeoff", Slots = {Entry = Picked.Entry, Option = Picked.Option}}
        elseif not Picked and #Modules == 1 and Has(Marks.Change) and not Has(Marks.Trouble) and Brain.EffectOf(Tokens, Modules[1]) then
            return {Intent = "Effect", Slots = {Entry = Modules[1]}}
        elseif #Modules == 1 and Words.my and Has(Marks.Tradeoff) and (Words.config or Words.setup or Words.settings) then
            return {Intent = "Tradeoff", Slots = {Entry = Modules[1]}}
        elseif #Modules == 1 and Has(Marks.Tradeoff) and Brain.MissingSetting(Modules[1], Tokens) then
            return {Intent = "Tradeoff", Slots = {Entry = Modules[1]}}
        elseif #Modules >= 1 and not (Together and #Modules >= 2) and not (Words.find or Words.where or Words.locate) and not Lower:find(" nothing else ", 1, true) and (Has(Marks.Trouble) or (Words.only and (Words.when or Words["if"]))) then
            return {Intent = "Trouble", Slots = {Entry = Modules[1]}}
        end

        local Topic = Brain.Topic()
        if Topic and #Tokens <= 12 and (#Modules == 0 or (#Modules == 1 and Modules[1] == Topic)) then
            local Slots = {Entry = Modules[1]}
            if Has(Marks.Deeper) or (Words.how and (Words.work or Words.works)) or (Words.what and Words["else"] and not Words.you) or Lower:find(" under the hood ", 1, true) then
                return {Intent = "More", Slots = Slots}
            elseif Has(Marks.Simpler) or Lower:find(" dont get ", 1, true) or Lower:find(" dont understand ", 1, true) then
                return {Intent = "Simpler", Slots = Slots}
            end
        end

        return nil
    end

    function Brain.ErrorOf(Text: string)
        local Lower: string = Text:lower()
        local Context: boolean = Lower:find(":%d+:") ~= nil
        for _, Hint: string in Brain.ErrorHints do
            Context = Context or Lower:find(Hint, 1, true) ~= nil
        end

        for _, Known: any in Brain.Errors do
            for _, Find: string in Known.Find do
                if Lower:find(Find, 1, true) and (not Known.Loose or Context) then
                    return Known
                end
            end
        end

        return nil
    end

    function Brain.ErrorReply(Question: string)
        local Known = Brain.ErrorOf(Question)
        if not Known then
            return {Text = "Paste the error here and I'll tell you what it means. Press F9 to open the console, errors are the red lines."}
        end

        local function Read(Value: any): any
            return type(Value) == "function" and Value(Question) or Value
        end

        local Lower: string = Question:lower()
        local Lines: {string} = {Read(Known.Explain)}
        local Cause: string? = Read(Known.Cause)
        if Cause then
            table.insert(Lines, Cause)
        end

        local Mentioned = FindMentions(Normalize(Question):split(" "))
        local Ours: boolean = Mentioned[1] ~= nil or Lower:find("Uranium", 1, true) ~= nil or Lower:find("catsix", 1, true) ~= nil
        if Mentioned[1] then
            LastTopic = Mentioned[1].Key
            table.insert(Lines, `It came from {Accent(Mentioned[1].Name)}, so that's the module to look at.`)
        elseif Ours then
            table.insert(Lines, "It came from CatVape.")
        elseif Lower:find("playerscripts", 1, true) or Lower:find("replicatedstorage", 1, true) or Lower:find("replicatedfirst", 1, true) or Lower:find("starterplayer", 1, true) then
            table.insert(Lines, "That line comes from the game's own scripts, not CatVape, so you can ignore it.")
        elseif Lower:find("coregui", 1, true) or Lower:find("corepackages", 1, true) or Lower:find("corescripts", 1, true) then
            table.insert(Lines, "That line comes from Roblox itself, not CatVape.")
        elseif Read(Known.Executor) then
            local Success, Name = pcall(identifyexecutor)
            table.insert(Lines, Success and Name and `You're on {Accent(tostring(Name))}, so that's an executor limit, not a CatVape bug.` or "That's an executor limit, not a CatVape bug.")
        else
            table.insert(Lines, "I can't tell which script it came from without the rest of the line, so paste the whole thing if you want me to narrow it down.")
        end

        if Ours then
            local Steps: {string} = {}
            if Known.Passing then
                table.insert(Steps, "If it only showed up once, you can ignore it.")
            end

            table.insert(Steps, Mentioned[1] and `Turn {Accent(Mentioned[1].Name)} off and on again.` or "Turn the module off and on again.")
            table.insert(Steps, "If it keeps coming back, rejoin and execute again.")
            table.insert(Steps, "If it still happens, report it in the Discord with the full line.")
            for i: number, Step: string in Steps do
                Steps[i] = `{i}. {Step}`
            end

            table.insert(Lines, `Try this:\n{table.concat(Steps, "\n")}`)
        end

        return {Text = table.concat(Lines, "\n\n"), Actions = Mentioned[1] and ModuleActions(Mentioned[1]) or nil}
    end

    function Brain.RelatedOptions(Entry, Tokens)
        local Words: {[string]: boolean} = {}
        for _, Token: any in Tokens or {} do
            Words[Token.Word] = true
        end

        for Word: string in Normalize(`{Entry.Name} {SplitName(Entry.Name)}`):gmatch("%S+") do
            Words[Word] = nil
        end

        local Found = {}
        for _, Option: any in Entry.Options do
            local Hit: boolean = false
            for Word: string in Normalize(Option.Name):gmatch("%S+") do
                Hit = Hit or (#Word > 3 and Words[Word] == true)
                for Hint: string in Brain.OptionHints[Word] or {} do
                    Hit = Hit or Words[Hint] == true
                end
            end

            if Hit and Option.Type == "Toggle" and #Found < 2 then
                table.insert(Found, Option)
            end
        end

        return Found
    end

    function Brain.Narrow(Entry, Symptom): string
        if Symptom then
            return Symptom.Question
        end

        local Asks: {{string}} = {
            {"Attack", "Does it miss everyone, or only players far away or behind walls?"},
            {"Shoot", "Does it not shoot at all, or shoot and miss?"},
            {"Camera", "Is it not aiming at all, or aiming at the wrong player?"},
            {"Rotate", "Is it not turning you at all, or turning you the wrong way?"},
            {"Move", "Does it stop working after a second, or pull you back?"},
            {"Place", "Does it place nothing at all, or put blocks in the wrong spots?"},
            {"Break", "Does it not break anything, or break the wrong blocks?"},
            {"Items", "Does it not switch at all, or switch to the wrong item?"},
            {"Render", "Does nothing show up at all, or only for some players?"}
        }

        for _, Ask: {string} in Asks do
            if Brain.Uses(Entry, Ask[1]) then
                return Ask[2]
            end
        end

        return "Did it ever work for you, or has it never worked since you turned it on?"
    end

    function Brain.Numbered(Steps: {string}): string
        if #Steps == 1 then
            return Steps[1]
        end

        local Lines: {string} = {}
        for i: number, Step: string in Steps do
            table.insert(Lines, `{i}. {Step}`)
        end

        return `Try this:\n{table.concat(Lines, "\n")}`
    end

    function Brain.Toggles(Entries)
        local Actions = {}
        for i: number = 1, math.min(2, #Entries) do
            local Entry = Entries[i]
            table.insert(Actions, {
                Text = `Turn off {Entry.Name}`,
                Callback = function()
                    Reply(SetModule(Entry, "Off"))
                end
            })
        end

        return #Actions > 0 and Actions or nil
    end

    function Brain.CulpritLine(Culprit, Lead: string): string
        local Summary: string = Brain.Summary(Culprit.Entry)
        return `{Lead}{Accent(Culprit.Entry.Name)} is {Culprit.Entry.Module.Enabled and "on" or "something you said you use"}{Summary ~= "" and `, and it {Brain.Lower(Brain.Sentence(Escape(Summary)))}` or "."}`
    end

    function Brain.CulpritReply(Tokens)
        local Culprits = Brain.Culprits(Tokens)
        local First = Culprits[1]
        if not First then
            return {Text = "Nothing you have on matches that, so it's probably the game rather than CatVape. Which module were you using when it happened?"}
        end

        local Lines: {string} = {`{Brain.CulpritLine(First, "")} That sounds like what you're seeing.`}
        local Entries = {First.Entry}
        local Second = Culprits[2]
        if Second and Second.Score >= First.Score * 0.4 then
            table.insert(Lines, Brain.CulpritLine(Second, "It could also be "))
            table.insert(Entries, Second.Entry)
        end

        table.insert(Lines, Brain.Numbered({
            `Turn {Accent(First.Entry.Name)} off for a moment and see if it stops.`,
            "If it does, that's the cause, so leave it off or change its settings, ask me about them."
        }))
        table.insert(Lines, "Did this start right after you turned something on?")
        return {Text = table.concat(Lines, "\n\n"), Actions = Brain.Toggles(Entries)}
    end

    function Brain.SymptomReply(Symptom, Tokens, Question: string)
        local Suspects, Quiet = {}, {}
        local Seen = {}
        local function Consider(Entry, Said: boolean)
            if Seen[Entry] then
                return
            end

            Seen[Entry] = true
            local State, Gate = Brain.Uses(Entry, Symptom.Resource)
            if State and (Entry.Module.Enabled or Said) then
                table.insert(State == "off" and Quiet or Suspects, {Entry = Entry, Gate = Gate, State = State})
            end
        end

        for _, Entry: any in Brain.Context.Using do
            Consider(Entry, true)
        end

        for _, Entry: any in Index.Entries do
            if Entry.Module.Enabled then
                Consider(Entry, false)
            end
        end

        local Lines: {string} = {}
        local Steps: {string} = {}
        local Names: {string} = {}
        local Entries = {}
        for _, Suspect: any in Suspects do
            table.insert(Names, Accent(Suspect.Entry.Name))
            table.insert(Entries, Suspect.Entry)
        end

        if #Suspects >= 2 then
            table.insert(Lines, `{JoinNames(Names, 4)} are {#Suspects == 2 and "both" or "all"} {Symptom.Doing} right now, and when two modules do that at once they fight over it.`)
            table.insert(Steps, `Turn off {Accent(Suspects[2].Entry.Name)} and see if it stops.`)
            table.insert(Steps, `If it doesn't, turn it back on and try turning off {Accent(Suspects[1].Entry.Name)} instead.`)
            table.insert(Steps, "Whichever one fixes it is the cause, so run the other one alone or change its settings.")
        elseif #Suspects == 1 then
            local Suspect = Suspects[1]
            table.insert(Lines, `{Names[1]} is the one {Symptom.Doing} right now{Suspect.Gate and `, because {Brain.GateClause(Suspect.Gate)}` or ""}.`)
            table.insert(Steps, `Turn {Accent(Suspect.Entry.Name)} off for a moment and see if it stops.`)
            if Suspect.Gate then
                table.insert(Steps, `If that fixes it, turn it back on and {Brain.GateFix(Suspect.Gate)} instead, so it stops {Symptom.Doing}.`)
            else
                table.insert(Steps, "If that fixes it, its settings are the place to look, ask me about them.")
            end
        elseif #Quiet > 0 then
            table.insert(Lines, `{Accent(Quiet[1].Entry.Name)} can do that, but only {Brain.GateText(Quiet[1].Gate)}, and that's off, so it isn't the cause.`)
        else
            local Culprit = Brain.Culprits(Tokens)[1]
            if Culprit then
                table.insert(Lines, `{Brain.CulpritLine(Culprit, "")} That could be it.`)
                table.insert(Steps, `Turn {Accent(Culprit.Entry.Name)} off for a moment and see if it stops.`)
                table.insert(Entries, Culprit.Entry)
            else
                table.insert(Lines, `None of the modules you have on are {Symptom.Doing}, so it's probably not CatVape.{Symptom.Quiet and ` {Symptom.Quiet}` or ""}`)
            end
        end

        local Query, Mentions = Brain.QueryOf(Tokens)
        local Fact, Score = FindFact(Query, Mentions)
        local Involved: boolean = Fact ~= nil and (Fact.Modules == nil or #Fact.Modules == 0 or (#Suspects == 0 and Score >= Brain.FactOver))
        for _, Suspect: any in Fact and Suspects or {} do
            Involved = Involved or table.find(Fact.Modules or {}, Suspect.Entry.Name) ~= nil
        end

        if Fact and Involved and Score >= Brain.FactFloor then
            table.insert(Lines, FactText(Fact))
        end

        if #Steps > 0 then
            table.insert(Lines, Brain.Numbered(Steps))
        end

        table.insert(Lines, Symptom.Question)
        return {Text = table.concat(Lines, "\n\n"), Actions = Brain.Toggles(Entries)}
    end

    function Brain.MeasureFps()
        local Frames: number = 0
        local Started: number = os.clock()
        local Connection = RunService.RenderStepped:Connect(function()
            Frames += 1
        end)
        task.wait(0.5)
        Connection:Disconnect()

        local Elapsed: number = os.clock() - Started
        return Elapsed > 0.1 and math.floor(Frames / Elapsed) or nil
    end

    function Brain.PerformanceReply(Tokens)
        local Heavy, Drawing = {}, {}
        local Enabled: number = 0
        for _, Entry: any in Index.Entries do
            if Entry.Module.Enabled then
                Enabled += 1
                local Draws: boolean = Brain.Uses(Entry, "Render") ~= nil or Entry.Category == "Render" or Entry.Name:find("ESP", 1, true) ~= nil
                if Draws and Brain.Uses(Entry, "Frame") then
                    table.insert(Heavy, Entry.Name)
                elseif Draws or Brain.Uses(Entry, "Frame") then
                    table.insert(Drawing, Entry.Name)
                end
            end
        end

        for _, Name: string in Drawing do
            table.insert(Heavy, Name)
        end

        local Named = FindMentions(Brain.WordList(Tokens))

        local Lines: {string} = {}
        local Fps: number? = Brain.MeasureFps()
        table.insert(Lines, `{Fps and `You're at about {Accent(`{Fps} FPS`)} with ` or "You have "}{Enabled} module{Enabled == 1 and "" or "s"} on.`)

        for _, Entry: any in Named do
            local Doing: string? = not Brain.Frames[Entry.Key] and not Brain.Laggy[Entry.Key] and Brain.Doing(Entry) or nil
            if Doing and Doing ~= "" then
                table.insert(Lines, `{Accent(Entry.Name)} {Doing}{(Brain.Uses(Entry, "Render") or Brain.Uses(Entry, "Frame")) and ", so it does cost frames, more with lots of players around" or ", so it shouldn't cost many frames on its own"}.`)
            end
        end

        local Steps: {string} = {}
        local Blur = FindSetting("hud blur")
        local Background = FindSetting("blur background")
        local Blurred: boolean = (Blur and Blur.Option.Enabled) or (Background and Background.Option.Enabled) or false
        table.insert(Steps, Blurred and `Turn off {Accent("HUD blur")} and {Accent("Blur background")} in the GUI settings, they cost the most frames.` or `{Accent("HUD blur")} and {Accent("Blur background")} in the GUI settings cost the most frames, keep them off.`)
        if #Heavy > 0 then
            table.insert(Steps, `Turn off {Accent(JoinNames(Heavy, 5))} one at a time and watch your FPS, since they draw or run every frame. If it jumps back after one, that module is the cause, and lowering its distance or what it shows helps.`)
        else
            table.insert(Steps, "Turn your modules off one at a time and watch your FPS. If it jumps back after one, that module is the cause.")
        end

        local Success, Memory = pcall(gcinfo)
        local Fixer = Index.Keys.memoryfixer
        local Fixing: string = Fixer and ` {Accent(Fixer.Name)} in {WhereText(Fixer)} also drops what older injections left running.` or ""
        if Success and type(Memory) == "number" and Memory > 1500000 then
            table.insert(Steps, `Script memory is very high ({math.floor(Memory / 1048576 * 10) / 10} GB), which slows everything down, so rejoin to clear it.{Fixing}`)
        else
            table.insert(Steps, `If you've been playing for a long time or reinjected a few times, rejoin, memory builds up.{Fixing}`)
        end

        table.insert(Steps, "If nothing changes with everything off, it's the game or your device, not CatVape.")
        table.insert(Lines, Brain.Numbered(Steps))

        local Booster = Index.Keys.fpsbooster
        if Booster and not Booster.Module.Enabled then
            table.insert(Lines, `{Accent(Booster.Name)} in {WhereText(Booster)} can also help.`)
        end

        return {Text = table.concat(Lines, "\n\n")}
    end

    function Brain.RoleOf(Entry, Option)
        local Note = Brain.OptionNotes[`{Entry.Name}/{Option.Name}`]
        if Option.Type == "Targets" then
            return Brain.TargetsRole, Note
        end

        local Name: string = Normalize(Option.Name)
        local Wanted: string? = Note and Note.Role or (Brain.Showing[Name:match("^%S+") or ""] and "Looks") or nil
        for _, Role: any in Brain.Roles do
            if Wanted and Role.Id == Wanted then
                return Role, Note
            end
        end

        if Wanted then
            return nil, Note
        end

        for _, Role: any in Brain.Roles do
            for Word: string in Name:gmatch("%S+") do
                if Role.Words[Word] and not (Option.Type == "Toggle" and Role.Up) then
                    return Role, Note
                end
            end
        end

        return nil, Note
    end

    function Brain.Means(Entry, Option): string?
        local Role, Note = Brain.RoleOf(Entry, Option)
        return Note and Note.Means or Role and Role.Means or nil
    end

    function Brain.Position(Value: number, Minimum: number?, Maximum: number?): string?
        if not Minimum or not Maximum or Maximum <= Minimum then
            return nil
        elseif Value > Maximum or Value < Minimum then
            return `outside its range ({FormatNumber(Minimum)} to {FormatNumber(Maximum)})`
        end

        local Share: number = (Value - Minimum) / (Maximum - Minimum)
        return Share >= 0.99 and "the max" or Share >= 0.7 and "near the top" or Share > 0.3 and "in the middle" or Share > 0.01 and "near the bottom" or "the lowest"
    end

    function Brain.EffectOf(Tokens, Entry, Option)
        local Skip: {[string]: boolean} = {}
        for Word: string in Normalize(`{Option and Option.Name or ""} {Entry and Entry.Name or ""}`):gmatch("%S+") do
            Skip[Word] = true
        end

        local Found = {}
        for _, Token: any in Tokens do
            if not Skip[Token.Word] and not (Entry and Index.Keys[Token.Word] == Entry) then
                for _, Effect: any in Brain.Effects do
                    if Effect.Words[Token.Word] and not table.find(Found, Effect) then
                        table.insert(Found, Effect)
                    end
                end
            end
        end

        for _, Effect: any in Entry and Found or {} do
            if Brain.Fits(Entry, Option, Effect) then
                return Effect
            end
        end

        for _, Effect: any in Found do
            if Effect.Id ~= "Hitting" then
                return Effect
            end
        end

        return Found[1]
    end

    function Brain.Fits(Entry, Option, Effect): (boolean, string?)
        local Role, Note
        if Option then
            Role, Note = Brain.RoleOf(Entry, Option)
        end

        if Note and Note.Effects and Note.Effects[Effect.Id] ~= nil then
            local Target = Note.Effects[Effect.Id]
            return Target == true, type(Target) == "string" and Target or nil
        elseif Role and (Effect.Roles[Role.Id] or next(Effect.Roles) ~= nil) then
            return Effect.Roles[Role.Id] == true
        end

        local Text: string = (Role and Plain(Option.Settings.Tooltip) or `{Option and Plain(Option.Settings.Tooltip) or ""} {SplitName(Entry.Name)} {Brain.Summary(Entry)}`):lower()
        for Word: string in Text:gmatch("%a+") do
            if Effect.Words[Word] then
                return true
            end
        end

        return false
    end

    function Brain.SettingLines(Entry, Limit: number): {string}
        local Lines: {string} = {}
        for _, Option: any in Entry.Options do
            if #Lines < Limit and Option.Type ~= "ColorSlider" and Option.Type ~= "Button" and Option.Type ~= "Font" and Option.Type ~= "TextList" then
                local Value: string? = DescribeValue(Option)
                local Summary: string = FirstSentence(Plain(Option.Settings.Tooltip))
                local Means: string? = Brain.Means(Entry, Option)
                if Summary == "" and Means then
                    Summary = `sets {Means}`
                end

                table.insert(Lines, `- {Option.Name}{Value and ` ({Value})` or ""}{Summary ~= "" and `: {Escape(Summary)}` or ""}`)
            end
        end

        return Lines
    end

    function Brain.Topic()
        local Referred = Brain.Refer()
        if Referred and Referred.Type == "option" then
            return Referred.Value.Entry, Referred.Value.Option
        elseif Referred and Referred.Type == "module" then
            return Referred.Value
        end

        return LastTopic and Index.Keys[LastTopic] or nil
    end

    function Brain.SimpleReply(Entry, Option)
        Brain.Depth = {Key = Entry.Key, Level = 1, Option = Option}
        if Option then
            local Means: string? = Brain.Means(Entry, Option)
            local Tooltip: string = FirstSentence(Plain(Option.Settings.Tooltip))
            return {Text = `In short, {Accent(Option.Name)} {Means and `sets {Means}` or Tooltip ~= "" and `does this: {Brain.Lower(Tooltip)}` or "is one of its settings"}.`, Actions = ModuleActions(Entry, Option)}
        end

        local Summary: string = Brain.Summary(Entry)
        return {Text = `In short, {Accent(Entry.Name)} {Summary ~= "" and `does this: {Brain.Sentence(Brain.Lower(Summary))}` or "doesn't have a description yet."} It's {Entry.Module.Enabled and "on" or "off"} right now.`, Actions = ModuleActions(Entry)}
    end

    function Brain.OptionDetail(Entry, Option)
        local Role, Note = Brain.RoleOf(Entry, Option)
        local Lines: {string} = {}
        local Means: string? = Note and Note.Means or Role and Role.Means
        local Value: string? = DescribeValue(Option)
        table.insert(Lines, `{Accent(Option.Name)} {Means and `sets {Means}` or `is a {DescribeKind(Option)}`}{Value and `, and it's at {Accent(Value)} right now` or ""}.`)

        local Up: string? = Note and Note.Up or Role and Role.Up
        local Down: string? = Note and Note.Down or Role and Role.Down
        if Up and Down then
            table.insert(Lines, `Higher means {Up}. Lower means {Down}.`)
        end

        if Note and Note.Limit then
            table.insert(Lines, Note.Limit)
        end

        local Related: {string} = {}
        for _, Other: any in Entry.Options do
            local OtherRole = Other ~= Option and Brain.RoleOf(Entry, Other)
            if OtherRole and Role and OtherRole.Id == Role.Id then
                table.insert(Related, Other.Name)
            end
        end

        if #Related > 0 then
            table.insert(Lines, `It works together with {Accent(JoinNames(Related, 3))}, which set{#Related == 1 and "s" or ""} a similar thing.`)
        end

        local Tip: string? = Tips(Entry, nil, 1, Option)[1]
        if Tip then
            table.insert(Lines, `Good to know: {Tip}`)
        end

        return {Text = table.concat(Lines, "\n\n"), Actions = ModuleActions(Entry, Option)}
    end

    function Brain.DetailReply(Entry)
        local Lines: {string} = {}
        local Doing: string? = Brain.Doing(Entry)
        table.insert(Lines, `Here's more on {Accent(Entry.Name)}.{Doing and Doing ~= "" and ` It {Doing}.` or ""}`)

        local Settings: {string} = Brain.SettingLines(Entry, 8)
        if #Settings > 0 then
            table.insert(Lines, `Its main settings right now:\n{table.concat(Settings, "\n")}`)
        end

        local Facts = FactsFor(Entry)
        for i: number = 2, math.min(3, #Facts) do
            if Facts[i].Primary then
                table.insert(Lines, `Also good to know: {FactText(Facts[i].Fact)}`)
            end
        end

        for _, Rival: any in Brain.Rivals(Entry) do
            table.insert(Lines, `Right now it overlaps with {Accent(Rival.Entry.Name)}, which also {Brain.Resources[Rival.Resource].Does}.`)
            break
        end

        return {Text = table.concat(Lines, "\n\n"), Actions = Brain.Chips({"Go deeper", `{Entry.Name} settings`})}
    end

    function Brain.DeepReply(Entry)
        local Lines: {string} = {`Going deeper on {Accent(Entry.Name)}.`}
        local Roles: {string} = {}
        local Rate, Reach
        for _, Option: any in Entry.Options do
            local Role, Note = Brain.RoleOf(Entry, Option)
            local Means: string? = Note and Note.Means or Role and Role.Means
            local Tooltip: string = FirstSentence(Plain(Option.Settings.Tooltip))
            if #Roles < 6 and Option.Type ~= "ColorSlider" and Option.Type ~= "Button" and (Means or Tooltip ~= "") then
                table.insert(Roles, Means and `- {Option.Name} sets {Means}.{Note and Note.Limit and ` {Note.Limit}` or ""}` or `- {Option.Name}: {Escape(Brain.Sentence(Tooltip))}`)
            end

            Rate = Rate or (Role and (Role.Id == "Speed" or Role.Id == "Delay") and Option) or nil
            Reach = Reach or (Role and Role.Id == "Range" and Option) or nil
        end

        if #Roles > 0 then
            table.insert(Lines, `How its settings work:\n{table.concat(Roles, "\n")}`)
        end

        if Rate and Reach then
            table.insert(Lines, `Range and speed are separate: raising {Accent(Reach.Name)} doesn't make it act more often, that's {Accent(Rate.Name)}.`)
        end

        local Uses = Brain.ControlsOf(Entry)
        if Uses then
            for _, Resource: string in Brain.ResourceOrder do
                local Use = Uses[Resource]
                if Use and Use.Gates then
                    table.insert(Lines, `It only {Brain.Resources[Resource].Does} {Brain.GateText(Use.Gates[1])}.`)
                end
            end

            if Uses.Hook then
                table.insert(Lines, "It changes some of the game's own code, so a game update can break it until CatVape is updated.")
            end

            if Uses.Frame then
                table.insert(Lines, "It runs every frame, so it costs a little performance the whole time it's on.")
            end
        end

        table.insert(Lines, "That's as deep as I can go from here, past this you'd be reading its code.")
        return {Text = table.concat(Lines, "\n\n"), Actions = ModuleActions(Entry)}
    end

    function Brain.MoreReply(Entry, Option)
        if not Entry then
            return {Text = "More about what? Ask me about a module first, like \"what does Killaura do\".", Actions = Suggestions()}
        end

        LastTopic = Entry.Key
        local Depth = Brain.Depth
        if Depth.Key ~= Entry.Key then
            Brain.Depth = {Key = Entry.Key, Level = 1, Option = Option}
            Depth = Brain.Depth
        end

        Option = Option or Depth.Option
        Depth.Level += 1
        if Option and Depth.Level == 2 then
            return Brain.OptionDetail(Entry, Option)
        elseif Depth.Level == 2 or (Option and Depth.Level == 3) then
            return Brain.DetailReply(Entry)
        elseif Depth.Level <= 4 then
            return Brain.DeepReply(Entry)
        end

        return {Text = `That's everything I know about {Accent(Entry.Name)}. If something specific is still unclear, ask me about that part.`, Actions = ModuleActions(Entry)}
    end

    function Brain.MissingSetting(Entry, Tokens): string?
        local Owned: {[string]: boolean} = {}
        for _, Option: any in Entry.Options do
            local Role = Brain.RoleOf(Entry, Option)
            Owned[Role and Role.Id or ""] = true
        end

        for _, Token: any in Tokens or {} do
            for _, Role: any in Brain.Roles do
                if Role.Words[Token.Word] and not Owned[Role.Id] and Role.Id ~= "Mode" and Role.Id ~= "Check" and Role.Id ~= "Looks" then
                    return Token.Word
                end
            end
        end

        return nil
    end

    function Brain.TradeoffReply(Entry, Option, Tokens)
        LastTopic = Entry.Key
        local Missing: string? = not Option and Brain.MissingSetting(Entry, Tokens)
        if Missing then
            local Tip: string? = Tips(Entry, nil, 1)[1]
            return {Text = `{Accent(Entry.Name)} doesn't have a {Missing} setting, so there's nothing to tune there. Ask me "{Entry.Name} settings" to see what it does have.{Tip and `\n\nGood to know: {Tip}` or ""}`, Actions = ModuleActions(Entry)}
        elseif not Option then
            local Lines: {string} = {`Here's your {Accent(Entry.Name)} setup:`}
            local Shown: number = 0
            for _, Other: any in Entry.Options do
                local Component = Other.Option
                if Shown < 6 and Component and (Other.Type == "Slider" or Other.Type == "Dropdown" or Other.Type == "TwoSlider") then
                    local Where: string? = Other.Type == "Slider" and Brain.Position(Component.Value, Other.Settings.Min or Component.Min, Other.Settings.Max or Component.Max)
                    table.insert(Lines, `- {Other.Name}: {DescribeValue(Other)}{Where and ` ({Where})` or ""}`)
                    Shown += 1
                end
            end

            table.insert(Lines, "\nNothing there is wrong on its own. Whether it's good depends on what you want: values at the max are the strongest but the most obvious, lower ones look more like normal play.")
            local Tip: string? = Tips(Entry, nil, 1)[1]
            if Tip then
                table.insert(Lines, `\nGood to know: {Tip}`)
            end

            return {Text = table.concat(Lines, "\n"), Actions = ModuleActions(Entry)}
        end

        Brain.LastOption = {Type = "option", Value = {Entry = Entry, Option = Option}}
        local Role, Note = Brain.RoleOf(Entry, Option)
        local Component = Option.Option or {}
        local Minimum: number? = Option.Settings.Min or Component.Min
        local Maximum: number? = Option.Settings.Max or Component.Max
        local Value: string? = DescribeValue(Option)
        local Lines: {string} = {`{Accent(Option.Name)} in {Accent(Entry.Name)} is at {Accent(Value or "its default")} right now{Minimum and Maximum and ` (it goes from {FormatNumber(Minimum)} to {FormatNumber(Maximum)})` or ""}.`}

        for _, Token: any in Tokens or {} do
            if Token.Kind == "number" then
                local Where: string? = Brain.Position(Token.Value, Minimum, Maximum)
                if Where then
                    table.insert(Lines, `{FormatNumber(Token.Value)} is {Where}.`)
                end

                break
            end
        end

        local Means: string? = Note and Note.Means or Role and Role.Means
        local Up: string? = Note and Note.Up or Role and Role.Up
        local Down: string? = Note and Note.Down or Role and Role.Down
        local Tooltip: string = Plain(Option.Settings.Tooltip)
        local List: {string}? = Option.Settings.List or Component.List
        if Option.Type == "Dropdown" and List then
            table.insert(Lines, `Its choices are {Accent(Escape(JoinNames(List, 8)))}.{Tooltip ~= "" and `\n{Escape(Tooltip)}` or ""}`)
        elseif Means and Up and Down then
            table.insert(Lines, `It sets {Means}. Higher means {Up}, lower means {Down}.`)
        elseif Tooltip ~= "" then
            table.insert(Lines, Escape(FirstSentence(Tooltip)))
        elseif Means then
            table.insert(Lines, `It sets {Means}.`)
        end

        if Note and Note.Limit then
            table.insert(Lines, Note.Limit)
        end

        local Tip: string? = Tips(Entry, nil, 1, Option)[1]
        if Tip then
            table.insert(Lines, `Good to know: {Tip}`)
        end

        table.insert(Lines, `There's no single best {Option.Type == "Dropdown" and "choice" or "value"}, it comes down to what you want{Role and Role.Tradeoff and `: {Role.Tradeoff}` or ""}.`)
        return {Text = table.concat(Lines, "\n\n"), Actions = ModuleActions(Entry, Option)}
    end

    function Brain.EffectReply(Entry, Option, Tokens)
        LastTopic = Entry.Key
        if not Option then
            local Effect = Brain.EffectOf(Tokens, Entry)
            local Summary: string = Brain.Summary(Entry)
            local Does: string = Summary ~= "" and Brain.Lower(Brain.Sentence(Escape(Summary))) or "has no description."
            if not Effect then
                return {Text = `{Accent(Entry.Name)} {Does}`, Actions = ModuleActions(Entry)}
            elseif Brain.Fits(Entry, nil, Effect) then
                return {Text = `Yes, that's what it's for. {Accent(Entry.Name)} {Does}`, Actions = ModuleActions(Entry)}
            end

            return {Text = `Not quite. {Accent(Entry.Name)} {Does} It doesn't change {Effect.Text}.`, Actions = ModuleActions(Entry)}
        end

        Brain.LastOption = {Type = "option", Value = {Entry = Entry, Option = Option}}

        local Role, Note = Brain.RoleOf(Entry, Option)
        local Effect = Brain.EffectOf(Tokens, Entry, Option)
        local Means: string? = Note and Note.Means or Role and Role.Means
        local Tooltip: string = FirstSentence(Plain(Option.Settings.Tooltip))
        local What: string = Means and `{Accent(Option.Name)} sets {Means}` or Tooltip ~= "" and `{Accent(Option.Name)} is described as "{Escape(Tooltip)}"` or `{Accent(Option.Name)} is a {DescribeKind(Option)} in {Accent(Entry.Name)}`
        if not Effect then
            return Brain.OptionDetail(Entry, Option)
        end

        local Fits, Elsewhere = Brain.Fits(Entry, Option, Effect)

        local Up: string? = Note and Note.Up or Role and Role.Up
        local Down: string? = Note and Note.Down or Role and Role.Down
        local Backwards: boolean = Fits and Role ~= nil and Role.Inverse == true and Effect.Id == "Rate" and Brain.HasWord(Tokens, Brain.Lowering) == Brain.HasWord(Tokens, {"slower", "less", "fewer"})
        if Backwards then
            return {
                Text = `Not quite, it's the other way round. {What}, so higher means {Up} and lower means {Down}.{Note and Note.Limit and ` {Note.Limit}` or ""}`,
                Actions = ModuleActions(Entry, Option)
            }
        elseif Fits then
            return {
                Text = `Yes. {What}{Up and Down and `, so higher means {Up} and lower means {Down}` or ""}.{Note and Note.Limit and ` {Note.Limit}` or ""}`,
                Actions = ModuleActions(Entry, Option)
            }
        end

        local Others: {string} = {}
        if Elsewhere then
            table.insert(Others, Elsewhere)
        end

        for _, Other: any in Entry.Options do
            local OtherRole = Other ~= Option and Brain.RoleOf(Entry, Other)
            if OtherRole and Effect.Roles[OtherRole.Id] and not table.find(Others, Other.Name) then
                table.insert(Others, Other.Name)
            end
        end

        local Lines: {string} = {`Not quite. {What}, not {Effect.Text}.{Note and Note.Limit and ` {Note.Limit}` or ""}`}
        if Effect.Id == "Detection" then
            table.insert(Lines, "No setting makes a module undetectable. Values closer to what a normal player can do just stand out less.")
        elseif #Others > 0 then
            table.insert(Lines, `In {Accent(Entry.Name)}, {Effect.Text} comes from {Accent(JoinNames(Others, 3))}.`)
        else
            table.insert(Lines, `{Accent(Entry.Name)} doesn't have a setting for {Effect.Text}.`)
        end

        return {Text = table.concat(Lines, "\n\n"), Actions = ModuleActions(Entry, Option)}
    end

    function Brain.GoalText(Question: string): (string?, string?)
        local Text: string = Normalize(Brain.Unslang(Question))
        for _, Pattern: string in Brain.GoalPatterns do
            local Found: string? = Text:match(Pattern)
            if Found and #Found:split(" ") <= 8 then
                Found = (` {Found} `):gsub(" my ", " your "):gsub(" me ", " you "):gsub(" im ", " you are "):gsub(" i ", " you "):gsub(" myself ", " yourself ")
                for _ = 1, 3 do
                    Found = Found:gsub(" (%a+) $", function(Word: string): string?
                        return (Brain.Trailing[Word] or Brain.Drop[Word] or Word == "rn" or Word == "with" or Word == "in" or Word == "bedwars") and " " or nil
                    end)
                end

                local Short: string = Brain.Cut(` {Found} `):match("^%s*(.-)%s*$")
                Found = (#Short:split(" ") >= 3 and Short or Found):match("^%s*(.-)%s*$")

                local Words: {string} = Found:split(" ")
                if Found == "" or Brain.Pronouns[Words[#Words]] or (#Words <= 2 and Brain.Pronouns[Words[1]]) then
                    return nil
                end

                return Found, Pattern
            end
        end

        return nil
    end

    function Brain.GoalTerms(Entry): {[string]: number}
        if Entry.Goal then
            return Entry.Goal
        end

        local Terms: {[string]: number} = {}
        for _, Option: any in Entry.Options do
            AddTerms(Terms, Option.Name, 0.5)
        end

        AddTerms(Terms, Plain(Entry.Module.Tooltip), 0.6)
        for _, Line: string in Plain(Entry.Module.Tooltip):split("\n") do
            AddTerms(Terms, FirstSentence(Line), 2)
        end
        AddTerms(Terms, `{Entry.Name} {SplitName(Entry.Name)}`, 4)
        Entry.Goal = Terms
        return Terms
    end

    function Brain.Covers(Terms: {[string]: number}, Query: {[string]: number}): (number, boolean, number)
        local Total, Matched = 0, 0
        local Core: boolean = false
        for Term: string, Weight: number in Query do
            if Weight == 1 and not IntentTerms[Term] then
                Total += 1
                local Best: number = Terms[Term] or 0
                for _, Synonym: string in Synonyms[Term] or {} do
                    Best = math.max(Best, Terms[Synonym] or 0)
                end

                Matched += Best >= 0.6 and 1 or 0
                Core = Core or Best >= 2
            end
        end

        return Total > 0 and Matched / Total or 0, Core, Matched
    end

    function Brain.Rank(Text: string)
        local Words: {string} = {}
        for Word: string in Normalize(Text):gmatch("%S+") do
            if not Brain.GoalFiller[Word] then
                table.insert(Words, (Word == "go" or Word == "going") and "move" or Word)
            end
        end

        local Query: {[string]: number} = BuildQuery(table.concat(Words, " "))
        local Results = {}
        for _, Entry: any in Index.Entries do
            local Terms: {[string]: number} = Brain.GoalTerms(Entry)
            local Score: number = 0
            for Term: string, Weight: number in Query do
                if Terms[Term] then
                    Score += Weight * Terms[Term] * Rarity(Term)
                end
            end

            if Score > 0 then
                local Covers, Core, Matched = Brain.Covers(Terms, Query)
                local Named, Exact, Alias = false, false, false
                for Term: string, Weight: number in Query do
                    Named = Named or (Terms[Term] == 4 and Weight == 1)
                    Exact = Exact or (Term == Entry.Key and Weight == 1)
                    Alias = Alias or Term == Entry.Key
                end

                Score *= (Entry.Legit and 0.3 or 1) * (0.5 + Covers) ^ 2 * (Named and 1.25 or 1) * (Alias and 1.4 or 1)
                table.insert(Results, {Entry = Entry, Score = Score, Covers = Covers, Core = Core, Named = Named, Exact = Exact, Matched = Matched})
            end
        end

        table.sort(Results, function(A, B)
            if A.Exact ~= B.Exact then
                return A.Exact
            end

            return A.Score > B.Score
        end)

        return Results, Query
    end

    function Brain.Goal(Tokens, Text: string?)
        local Results, Query = Brain.Rank(Text or table.concat(Brain.WordList(Tokens), " "))
        local Picked = {}
        local First
        for _, Result: any in Results do
            local Fits: boolean = Result.Core and ((Result.Named and (Result.Covers >= 0.4 or Result.Matched >= 2)) or Result.Covers >= 0.67)
            if #Picked < 2 and Fits and Result.Score >= Brain.RecommendScore and (not First or (Result.Named and Result.Score >= First.Score * 0.5 and Result.Covers >= math.max(First.Covers, 0.67))) then
                First = First or Result
                table.insert(Picked, Result.Entry)
            end
        end

        return Picked, Results, Query
    end

    function Brain.Cut(Text: string): string
        for _, Cut: string in {" so you ", " so i ", " because ", " cuz ", " when ", " while "} do
            local Position: number? = Text:find(Cut, 1, true)
            if Position then
                Text = Text:sub(1, Position - 1)
            end
        end

        return Text
    end

    function Brain.RecommendReply(Tokens, Question: string)
        local Explicit: boolean = Brain.HasWord(Tokens, Brain.ModuleWords)
        local Picked, Results, Query = Brain.Goal(Tokens, Explicit and Brain.Cut(` {table.concat(Brain.WordList(Tokens), " ")} `) or Brain.GoalText(Question))

        local Goal, Pattern = Brain.GoalText(Question)
        local Frame: string = Pattern and (Pattern:find("that %(%.%+%)%$$") or Pattern:find("^wh%a+ mod")) and "something that" or Pattern and Pattern:find("for %(%.%+%)%$$") and "something for" or "to"
        local Lines: {string} = {}
        local Fact, Score = FindFact(Query, Picked)
        if Fact and Picked[1] and not table.find(Fact.Modules or {}, Picked[1].Name) then
            Fact = nil
        end

        if #Picked == 0 then
            local Closest = Results[1] and Results[1].Score >= 2 and Results[1].Entry
            table.insert(Lines, `I'm not certain CatVape has a module for that{CurrentGame() and " in this game" or ""}.{Closest and ` The closest I can find is {Accent(Closest.Name)}, but it may not be what you're after.` or ""}`)
            if Fact and Score >= Brain.FactOver then
                table.insert(Lines, FactText(Fact))
            end

            return {Text = table.concat(Lines, "\n\n"), Actions = Closest and Brain.Chips({`What does {Closest.Name} do?`}) or Suggestions()}
        end

        local First = Picked[1]
        LastTopic = First.Key
        local Summary: string = Brain.Summary(First, Query)
        table.insert(Lines, `{Goal and `If you want {Frame} {Escape(Goal)}, ` or "For that, "}{Accent(First.Name)} is the one to use{Summary ~= "" and `: {Brain.Sentence(Brain.Lower(Escape(Summary)))}` or "."}`)
        table.insert(Lines, `It's in {WhereText(First)} and it's {First.Module.Enabled and "already on" or "off right now"}.`)
        if Picked[2] then
            table.insert(Lines, `{Accent(Picked[2].Name)} can help too: {Brain.Sentence(Brain.Lower(Escape(Brain.Summary(Picked[2], Query))))}`)
        end

        if Fact and Score >= Brain.FactOver then
            table.insert(Lines, FactText(Fact))
        end

        local Actions = {}
        if not First.Module.Enabled then
            table.insert(Actions, {
                Text = `Turn on {First.Name}`,
                Callback = function()
                    Reply(SetModule(First, "On"))
                end
            })
        end

        table.insert(Actions, {
            Text = `What does {First.Name} do?`,
            Callback = function()
                Send(`What does {First.Name} do?`)
            end
        })

        return {Text = table.concat(Lines, "\n\n"), Actions = Actions}
    end

    function Brain.CompareReply(Modules)
        local Lines: {string} = {}
        local Actions = {}
        for i: number = 1, math.min(3, #Modules) do
            local Entry = Modules[i]
            local Doing: string? = Brain.Doing(Entry, true)
            local Keys: {string} = {}
            for _, Option: any in Entry.Options do
                if #Keys < 3 and Option.Type ~= "ColorSlider" and Option.Type ~= "Button" and Option.Type ~= "Targets" then
                    table.insert(Keys, Option.Name)
                end
            end

            local Summary: string = Brain.Summary(Entry)
            table.insert(Lines, `{Accent(Entry.Name)} ({Entry.Legit and "Legit menu" or Entry.Category}, {Entry.Module.Enabled and "on" or "off"}): {Summary ~= "" and Escape(Brain.Sentence(Summary)) or "no description."}{Doing and Doing ~= "" and ` It {Doing}.` or ""}{#Keys > 0 and ` Main settings: {table.concat(Keys, ", ")}.` or ""}`)
            table.insert(Actions, {
                Text = Entry.Name,
                Callback = function()
                    Send(`What does {Entry.Name} do?`)
                end
            })
        end

        local First, Second = Modules[1], Modules[2]
        local Overlap: string?
        for _, Clash: any in Brain.Clashes(First, Second) do
            if not Overlap and Brain.Resources[Clash.Resource].Strong then
                Overlap = `They overlap: {Accent(First.Name)} and {Accent(Second.Name)} {Brain.Resources[Clash.Resource].Clash}. You'd normally run one at a time.`
            end
        end

        local FirstHits, SecondHits = Brain.Uses(First, "Attack") ~= nil, Brain.Uses(Second, "Attack") ~= nil
        if not Overlap and FirstHits ~= SecondHits then
            local Hitter, Helper = FirstHits and First or Second, FirstHits and Second or First
            if Brain.Uses(Helper, "Camera") or Brain.Uses(Helper, "Rotate") then
                Overlap = `The big difference: {Accent(Hitter.Name)} hits for you, while {Accent(Helper.Name)} only helps you aim, so you still do the clicking.`
            end
        end

        if Overlap then
            table.insert(Lines, Overlap)
        end

        table.insert(Lines, "Neither is better overall, it comes down to what you want it for.")
        return {Text = `Here is how they compare:\n\n{table.concat(Lines, "\n\n")}`, Actions = Actions}
    end

    function Brain.InteractionReply(Modules)
        local First, Second = Modules[1], Modules[2]
        local Lines: {string} = {}
        local Fighting = {}
        local Game: string? = CurrentGame()

        for _, Fact: any in Facts do
            if #Lines == 0 and FactFits(Fact, Game) and Fact.Modules and table.find(Fact.Modules, First.Name) and table.find(Fact.Modules, Second.Name) and Fact.Text:find(First.Name, 1, true) and Fact.Text:find(Second.Name, 1, true) then
                table.insert(Lines, FactText(Fact))
            end
        end

        if #Lines > 0 then
            table.insert(Lines, "That's the main thing to know about running them together. If something still feels off with both on, run one at a time to see which one causes it.")
            return {Text = table.concat(Lines, "\n\n"), Actions = Brain.Chips({`What does {First.Name} do?`, `What does {Second.Name} do?`})}
        end

        local Tied: boolean = false
        for _, Pair: any in {{First, Second}, {Second, First}} do
            local Option = Brain.Linked(Pair[1], Pair[2])
            if Option then
                local Value: string? = DescribeValue(Option)
                Tied = Tied or Value == "on"
                table.insert(Lines, `{Accent(Pair[1].Name)} has a {Accent(Option.Name)} setting that ties it to {Accent(Pair[2].Name)}{Value and `, and it's {Value} right now` or ""}.`)
            end
        end


        local Known: boolean = Brain.ControlsOf(First) ~= nil and Brain.ControlsOf(Second) ~= nil
        local Mild: string?
        for _, Clash: any in Brain.Clashes(First, Second) do
            local Info = Brain.Resources[Clash.Resource]
            if Clash.First ~= "off" and Clash.Second ~= "off" then
                if Info.Strong then
                    local Gated = Clash.First == "now" and First or Clash.Second == "now" and Second
                    local Gate: string? = Clash.First == "now" and Clash.FirstGate or Clash.SecondGate
                    table.insert(Lines, `They can clash: {Accent(First.Name)} and {Accent(Second.Name)} {Info.Clash}.{Gated and Gate and ` {Accent(Gated.Name)} only does that {Brain.GateText(Gate)}, so turning that off avoids it.` or ""}`)
                    table.insert(Fighting, Clash)
                elseif not (Tied and Clash.Resource == "Target") then
                    Mild = Mild or `They also {Info.Clash}, which is usually fine.`
                end
            elseif Info.Strong then
                local Off = Clash.First == "off" and First or Second
                local Gate: string = Clash.First == "off" and Clash.FirstGate or Clash.SecondGate
                table.insert(Lines, `{Accent(Off.Name)} only {Info.Does} {Brain.GateText(Gate)}, and that's off right now, so they won't fight over that.`)
            end
        end

        if Mild and #Fighting == 0 then
            table.insert(Lines, Mild)
        end

        if #Fighting == 0 then
            if not Known then
                local Unknown = Brain.ControlsOf(First) and Second or First
                table.insert(Lines, `I can't see exactly what {Accent(Unknown.Name)} touches, so I can't promise, but nothing I know of says they clash.`)
            elseif #Lines > 0 then
                table.insert(Lines, "Apart from that they don't fight over anything, so they should work fine together.")
            else
                local FirstDoing: string = Brain.Doing(First, true) or ""
                local SecondDoing: string = Brain.Doing(Second, true) or ""
                if FirstDoing == "" and SecondDoing == "" then
                    table.insert(Lines, `Neither {Accent(First.Name)} nor {Accent(Second.Name)} moves you, aims, clicks or switches your item, so from how they work they don't fight over anything and should be fine together.`)
                else
                    table.insert(Lines, `{Accent(First.Name)} {FirstDoing ~= "" and FirstDoing or "doesn't move you, aim or click"}, and {Accent(Second.Name)} {SecondDoing ~= "" and SecondDoing or "doesn't move you, aim or click"}. From how they work they don't fight over the same thing, so they should be fine together.`)
                end
            end
        else
            table.insert(Lines, "If something feels off with both on, run one at a time and see which one you actually need.")
        end

        if Modules[3] then
            table.insert(Lines, `Ask me about {Accent(Modules[3].Name)} with one of them on its own if you want that pair checked too.`)
        end

        local Both = First.Module.Enabled and Second.Module.Enabled
        return {
            Text = table.concat(Lines, "\n\n"),
            Actions = #Fighting > 0 and Both and Brain.Toggles({Second, First}) or Brain.Chips({`What does {First.Name} do?`, `What does {Second.Name} do?`})
        }
    end

    function Brain.UsingReply(Modules)
        local Using = Brain.Context.Using
        local Names, Off = {}, {}
        for i: number = #Modules, 1, -1 do
            local Entry = Modules[i]
            local Position: number? = table.find(Using, Entry)
            if Position then
                table.remove(Using, Position)
            end

            table.insert(Using, 1, Entry)
            if #Using > 6 then
                table.remove(Using)
            end
        end

        for _, Entry: any in Modules do
            table.insert(Names, Accent(Entry.Name))
            if not Entry.Module.Enabled then
                table.insert(Off, Accent(Entry.Name))
            end
        end

        LastTopic = Modules[1].Key
        local Lines: {string} = {`Got it, {JoinNames(Names, 5)}.`}
        if #Off > 0 and #Off < #Modules then
            table.insert(Lines, `{JoinNames(Off, 5)} {#Off == 1 and "is" or "are"} actually off right now, though.`)
        end

        for i: number = 1, #Modules do
            for j: number = i + 1, #Modules do
                for _, Clash: any in Brain.Clashes(Modules[i], Modules[j]) do
                    if #Lines < 4 and Brain.Resources[Clash.Resource].Strong and Clash.First ~= "off" and Clash.Second ~= "off" then
                        table.insert(Lines, `Heads up: {Accent(Modules[i].Name)} and {Accent(Modules[j].Name)} {Brain.Resources[Clash.Resource].Clash}.`)
                    end
                end
            end
        end

        table.insert(Lines, "What's going on with them?")
        return {Text = table.concat(Lines, " "), Actions = Modules[2] and Brain.Chips({`Can {Modules[1].Name} and {Modules[2].Name} run together?`}) or Brain.Chips({`What does {Modules[1].Name} do?`})}
    end

    Brain.StyleWords = {
        Legit = Brain.Set("legit legitimate safe safer subtle undetected undetectable clean human humanlike natural lowkey casual"),
        Closet = Brain.Set("closet closeted silent semi semilegit sneaky quiet"),
        Blatant = Brain.Set("blatant rage raging max maxed maximum op overpowered hvh strongest aggressive insane sweaty tryhard"),
        Default = Brain.Set("default defaults reset stock factory original originally vanilla")
    }
    Brain.StylePhrases = {
        Default = {"how it was", "back to normal", "start over"},
        Legit = {"not obvious", "less obvious", "not blatant", "look legit", "looks legit"},
        Blatant = {"more obvious", "all out", "go hard"}
    }
    Brain.StyleOrder = {"Default", "Closet", "Legit", "Blatant"}
    Brain.StyleEntities = Brain.Set("legit closet closeted blatant hvh silent default")
    Brain.Presets = {Legit = "legit", Closet = "silent", Blatant = "default"}
    Brain.Quality = Brain.Set("good best decent solid proper optimal actually great perfect strong working tuned optimized optimised scratch complete full whole")
    Brain.Prefaces = {"thanks", "thank you", "thx", "ty", "tysm", "ok", "okay", "cool", "nice", "great", "alright", "perfect", "bet", "awesome"}
    Brain.Places = {BedWars = "a BedWars match", BedWarsLobby = "the BedWars lobby", IllegalSoccer = "Illegal Soccer", TowerOfHell = "Tower of Hell", Universal = "most games"}
    Brain.ConfigVerbs = Brain.Set("make set setup configure config cfg tune optimize optimise reset restore put max build create")
    Brain.Hands = Brain.Set("switch load delete remove rename share export import select which what whats is are does do how why")
    Brain.Calm = Brain.Set("Delay Smooth Shake")
    Brain.Strict = {["require mouse down"] = true, ["click aim"] = true, ["limit to items"] = true, ["limit to item"] = true, ["swing only"] = true, ["gui check"] = true, ["afk check"] = true, ["attackable check"] = true}
    Brain.Caps = {["Killaura/Attack range"] = 18, ["Speed/Speed"] = 22}

    function Brain.Elsewhere(Key: string)
        if not Brain.Everywhere then
            Brain.Everywhere = {}
            for Game: string, Modules: {[string]: string} in Brain.Controls do
                for Name: string in Modules do
                    local Found = Brain.Everywhere[Compact(Name)] or {Name = Name, Games = {}}
                    table.insert(Found.Games, Game)
                    Brain.Everywhere[Compact(Name)] = Found
                end
            end

            for Alias: string, Name: string in Aliases do
                Brain.Everywhere[Alias] = Brain.Everywhere[Alias] or Brain.Everywhere[Compact(Name)]
            end
        end

        return Brain.Everywhere[Key]
    end

    function Brain.Absent(Tokens)
        local Current: string? = CurrentGame()
        if Current == "BedWars" and game.PlaceId == Brain.LobbyPlace then
            Current = "BedWarsLobby"
        end

        local Words: {string} = Brain.WordList(Tokens)
        for i: number, Word: string in Words do
            for _, Key: string in {`{Word}{Words[i + 1] or ""}`, Word} do
                local Found = #Key >= 4 and not Index.Keys[Key] and not Brain.English(Key) and Brain.Elsewhere(Key)
                if Found and not table.find(Found.Games, "Universal") and not table.find(Found.Games, Current or "") then
                    return Found
                end
            end
        end

        return nil
    end

    function Brain.Here(): string
        local Game: string? = CurrentGame()
        if Game == "BedWars" and game.PlaceId == Brain.LobbyPlace then
            return Brain.Places.BedWarsLobby
        end

        return Game and Brain.Places[Game] or "this game"
    end

    function Brain.ElsewhereReply(Found, Tokens)
        local Places: {string} = {}
        for _, Game: string in Found.Games do
            table.insert(Places, Brain.Places[Game] or Game)
        end

        local Configuring: boolean = Tokens ~= nil and (Brain.HasWord(Tokens, Brain.PresetNouns) or Brain.StyleOf(Tokens) ~= nil)
        return {Text = `{Accent(Found.Name)} isn't loaded here. It only runs in {JoinNames(Places, 3)}, and you're in {Brain.Here()} right now. Ask me again once you're there and I'll {Configuring and "set it up" or "help with it"}.`}
    end

    function Brain.PreferredStyle(Entry): string?
        local Found: string?
        for _, Style: string in {"Legit", "Closet", "Blatant"} do
            local Recipe = Brain.RecipeFor(Style)
            if Recipe and Recipe.Modules[Entry.Name] and (`, {Recipe.On}, `):find(`, {Entry.Name}, `, 1, true) then
                if Found then
                    return nil
                end

                Found = Style
            end
        end

        return Found
    end

    function Brain.StyleOf(Tokens, Skip: {[number]: boolean}?): string?
        for _, Style: string in Brain.StyleOrder do
            if Brain.StylePhrases[Style] and Brain.Phrased(Tokens, Brain.StylePhrases[Style]) then
                return Style
            end
        end

        for _, Style: string in Brain.StyleOrder do
            for i: number, Token: any in Tokens do
                if Brain.StyleWords[Style][Token.Word] and not (Skip and Skip[i]) then
                    return Style
                end
            end
        end

        return nil
    end

    function Brain.RecipeFor(Style: string)
        local Game: string? = CurrentGame()
        if Game == "BedWars" and game.PlaceId == Brain.LobbyPlace then
            Game = "BedWarsLobby"
        end

        local Recipes = Game and Brain.Recipes[Game]
        return Recipes and Recipes[Style] or nil
    end

    function Brain.ApplyValues(Entry, Pairs: {{string}}): ({string}, {() -> ()})
        local Changed: {string} = {}
        local Undos: {() -> ()} = {}
        for _, Pair: {string} in Pairs do
            for _, Option: any in Entry.Options do
                if Option.Name == Pair[1] and Option.Option and DescribeValue(Option) ~= Pair[2] then
                    local Undo = Brain.Capture(Option)
                    local Success, Result = ApplyValue(Option, Pair[2])
                    if Success then
                        table.insert(Changed, Result)
                        table.insert(Undos, Undo)
                    end
                end
            end
        end

        return Changed, Undos
    end

    function Brain.RecipePairs(Text: string): {{string}}
        local Pairs: {{string}} = {}
        for Part: string in Text:gmatch("[^;]+") do
            local Name, Value = Part:match("^%s*(.-)%s*=%s*(.-)%s*$")
            if Name then
                table.insert(Pairs, {Name, Value})
            end
        end

        return Pairs
    end

    function Brain.StylePairs(Entry, Style: string): {{string}}
        local Pairs: {{string}} = {}
        if Style == "Default" then
            for _, Option: any in Entry.Options do
                local Component = Option.Option
                if Component and Option.Type == "Toggle" then
                    table.insert(Pairs, {Option.Name, Component.Default and "on" or "off"})
                elseif Component and Option.Type == "Slider" and Component.Default then
                    table.insert(Pairs, {Option.Name, FormatNumber(Component.Default)})
                elseif Component and Option.Type == "TwoSlider" and Component.DefaultMin and Component.DefaultMax then
                    table.insert(Pairs, {Option.Name, `{FormatNumber(Component.DefaultMin)} to {FormatNumber(Component.DefaultMax)}`})
                elseif Component and Option.Type == "Dropdown" and Component.Default then
                    table.insert(Pairs, {Option.Name, tostring(Component.Default)})
                end
            end

            return Pairs
        end

        local Share: {[string]: number} = {Legit = 0.4, Closet = 0.55, Blatant = 0.9}
        for _, Option: any in Entry.Options do
            local Component = Option.Option or {}
            local Lower: string = Option.Name:lower()
            local Role = Brain.RoleOf(Entry, Option)
            local Minimum: number? = Option.Settings.Min or Component.Min
            local Maximum: number? = Option.Settings.Max or Component.Max
            if Option.Type == "Toggle" and Brain.Strict[Lower] then
                table.insert(Pairs, {Option.Name, Style == "Blatant" and "off" or "on"})
            elseif Option.Type == "Toggle" and Lower == "face target" and Style ~= "Blatant" then
                table.insert(Pairs, {Option.Name, "off"})
            elseif Option.Type == "Dropdown" then
                for _, Item: string in Option.Settings.List or Component.List or {} do
                    if Item:lower() == Style:lower() then
                        table.insert(Pairs, {Option.Name, Item})
                    end
                end
            elseif (Option.Type == "Slider" or Option.Type == "TwoSlider") and Role and Role.Up and Minimum and Maximum and Maximum > Minimum then
                local Fraction: number = Brain.Calm[Role.Id] and (Style == "Blatant" and 0 or 1 - Share[Style]) or Share[Style]
                local Value: number = Minimum + (Maximum - Minimum) * Fraction
                local Cap: number? = Brain.Caps[`{Entry.Name}/{Option.Name}`]
                Value = Cap and math.min(Value, Cap) or Value
                local Decimal: number = Component.Decimal or 10
                local Rounded: number = math.round(Value * Decimal) / Decimal
                local Low: number = math.round(math.max(Minimum, Rounded - (Maximum - Minimum) * 0.05) * Decimal) / Decimal
                table.insert(Pairs, {Option.Name, Option.Type == "TwoSlider" and `{FormatNumber(Low)} to {FormatNumber(Rounded)}` or FormatNumber(Rounded)})
            end
        end

        return Pairs
    end

    function Brain.StyleName(Style: string): string
        return Style == "Default" and "default" or Style:lower()
    end

    function Brain.ConfigureReply(Entry, Style: string?, Slots: any?)
        LastTopic = Entry.Key
        local Only: string? = not Style and Slots and Slots.Quality and Brain.PreferredStyle(Entry) or nil
        Style = Style or Only
        if not Style then
            local Chips: {string} = {}
            for _, Option: string in {"legit", "closet", "blatant", "default"} do
                table.insert(Chips, Option == "default" and `Reset {Entry.Name} to default` or `Make {Entry.Name} {Option}`)
            end

            return {Text = `How should I set up {Accent(Entry.Name)}? Legit looks like a normal player, closet is the most subtle, and blatant goes all out. I can also reset it to default.`, Actions = Brain.Chips(Chips)}
        end

        local Recipe = Style ~= "Default" and Brain.RecipeFor(Style) or nil
        local Text: string? = Recipe and Recipe.Modules[Entry.Name]
        local Pairs: {{string}} = Text and Brain.RecipePairs(Text) or Brain.StylePairs(Entry, Style)
        local Changed, Undos = Brain.ApplyValues(Entry, Pairs)
        local Name: string = Brain.StyleName(Style)
        local Switched: boolean = false
        if Slots and Slots.Enable and not Entry.Module.Enabled then
            Entry.Module:Toggle()
            Switched = true
            table.insert(Undos, function()
                if Entry.Module.Enabled then
                    Entry.Module:Toggle()
                end
            end)
        end

        if #Changed == 0 and Switched then
            Brain.Remember(`turned on {Entry.Name}`, Undos[#Undos])
            return {Text = `{Accent(Entry.Name)} already matches the {Name} setup, so I just turned it on.`, Actions = Brain.WithUndo()}
        elseif #Changed == 0 then
            local Acting: boolean = Brain.Acts(Entry) or Brain.Uses(Entry, "Move") ~= nil
            return {
                Text = #Pairs > 0 and `{Accent(Entry.Name)} already matches the {Name} setup, nothing to change.` or not Acting and Style ~= "Default" and `{Accent(Entry.Name)} only shows things on your screen, so there's nothing legit or blatant about its settings. Ask me to reset it to default if you want a clean start.` or `I don't know a {Name} setup for {Accent(Entry.Name)}'s settings, so I left them alone. Ask me what any of them do and I'll help you pick values.`,
                Actions = ModuleActions(Entry)
            }
        end

        Brain.Remember(`set up {Entry.Name} for {Name}`, function()
            for i: number = #Undos, 1, -1 do
                Undos[i]()
            end
        end)

        local Lines: {string} = {}
        if Style == "Default" then
            table.insert(Lines, `Reset {Accent(Entry.Name)} to its default settings:`)
        elseif Text then
            table.insert(Lines, `Set {Accent(Entry.Name)} up for {Name} play, using the values from CatVape's {Brain.Presets[Style]} preset{Only and ` (it's the only preset that runs {Entry.Name})` or ""}:`)
        else
            table.insert(Lines, `I don't have a tested {Name} setup for {Accent(Entry.Name)}, so these are starting points from what each setting does:`)
        end

        for i: number = 1, math.min(8, #Changed) do
            table.insert(Lines, `- {Changed[i]}`)
        end

        if #Changed > 8 then
            table.insert(Lines, `...and {#Changed - 8} more.`)
        end

        local Actions = Brain.WithUndo()
        if Switched then
            table.insert(Lines, `\nI turned {Accent(Entry.Name)} on too.`)
        elseif not Entry.Module.Enabled then
            table.insert(Lines, `\n{Accent(Entry.Name)} is off right now, turn it on when you want to use it.`)
            table.insert(Actions, 1, {
                Text = `Turn on {Entry.Name}`,
                Callback = function()
                    Reply(SetModule(Entry, "On"))
                end
            })
        end

        local Tip: string? = Tips(Entry, nil, 1)[1]
        if Tip and Style ~= "Default" then
            table.insert(Lines, `\nGood to know: {Tip}`)
        end

        return {Text = table.concat(Lines, "\n"), Actions = Actions}
    end

    function Brain.BuildProfile(Slots)
        local Style: string? = Slots.Style
        if not Style or Style == "Default" then
            return {
                Text = "What kind of profile should I build? Legit looks like a normal player, closet keeps only a few subtle modules on, and blatant goes all out.",
                Actions = Brain.Chips({"Make me a legit profile", "Make me a closet profile", "Make me a blatant profile"})
            }
        end

        local Recipe = Brain.RecipeFor(Style)
        if Recipe and Recipe.On == "" and Recipe.Legit == "" then
            Recipe = nil
        end

        local Wanted: {[any]: boolean} = {}
        local Names: {string} = {}
        local Listed: {[string]: boolean} = {}
        if Recipe then
            for Name: string in (`{Recipe.On}, {Recipe.Legit}`):gmatch("[^,]+") do
                Listed[Compact(Name)] = true
            end
        else
            for _, Name: string in Brain.Essentials[CurrentGame() or ""] or Brain.Essentials.Universal do
                Listed[Compact(Name)] = true
            end
        end

        for _, Entry: any in Index.Entries do
            if Listed[Entry.Key] then
                Wanted[Entry] = true
                table.insert(Names, Entry.Name)
            end
        end

        if #Names == 0 then
            return {Text = "I don't have a setup I trust for this game yet, so I'd rather not build a profile from guesses. I can set up single modules for you instead."}
        end

        local Profiles = vape.Categories.Profiles
        local Name: string = Brain.StyleName(Style)
        local Base: string = Slots.Name or Name
        local Profile: string = Base
        local Suffix: number = 2
        while Profiles:GetValue(Profile) do
            Profile = `{Base}{Suffix}`
            Suffix += 1
        end

        local Previous: string = vape.Profile
        Profiles:ChangeValue(Profile)
        task.delay(0.2, function()
            if vape.ThreadFix then
                setthreadidentity(8)
            end

            vape:Save(Profile)
            vape:Load(true)
            Profiles:ChangeValue()

            local Tuned: number = 0
            for _, Entry: any in Index.Entries do
                if Entry.Module.Enabled ~= (Wanted[Entry] == true) then
                    Entry.Module:Toggle()
                end

                local Text: string? = Recipe and Recipe.Modules[Entry.Name]
                local Pairs: {{string}}? = Text and Brain.RecipePairs(Text) or (not Recipe and Wanted[Entry] and Brain.StylePairs(Entry, Style)) or nil
                if Pairs and #Brain.ApplyValues(Entry, Pairs) > 0 then
                    Tuned += 1
                end
            end

            vape:Save()
            Reply({
                Text = `{Accent(Profile)} is ready and you're on it. {Recipe and `It's built from CatVape's {Brain.Presets[Style]} preset` or `I don't have a tested preset for this game, so it has the core modules with {Name} starting values`}: {#Names} module{#Names == 1 and "" or "s"} on ({Accent(JoinNames(Names, 8))}), and {Tuned} module{Tuned == 1 and "" or "s"} set up for {Name} play. Speed, Fly and LongJump stay off, put them on a bind.`,
                Actions = {
                    {
                        Text = `Back to {Previous}`,
                        Callback = function()
                            Reply({Text = `Switching back to {Accent(Previous)}...`})
                            SwitchProfile(Previous)
                        end
                    }
                }
            })
        end)

        return {Text = `Building the {Name} profile {Accent(Profile)} and switching to it...`}
    end

    Brain.ResetContext()

    function Brain.Expand(Template: string): {string}
        local Start: number? = Template:find("[%(%[]")
        if not Start then
            return {Template}
        end

        local Opener: string = Template:sub(Start, Start)
        local Finish: number = Template:find(Opener == "(" and ")" or "]", Start, true)
        local Choices: {string} = Template:sub(Start + 1, Finish - 1):split("|")
        if Opener == "[" then
            table.insert(Choices, "")
        end

        local Results: {string} = {}
        for _, Choice: string in Choices do
            for _, Result: string in Brain.Expand(`{Template:sub(1, Start - 1)}{Choice}{Template:sub(Finish + 1)}`) do
                table.insert(Results, Result)
            end
        end

        return Results
    end

    function Brain.Prepare(Words: {string}): {string}
        local Tokens: {string} = {}
        for _, Word: string in Words do
            if Word:sub(1, 1) == "<" then
                table.insert(Tokens, Word)
            elseif Word ~= "" and not Brain.Drop[Word] then
                table.insert(Tokens, Stem(Word))
            end
        end

        return Tokens
    end

    function Brain.Features(Tokens: {string}): {string}
        local Features: {string} = {}
        local Previous: string = "^"
        for _, Token: string in Tokens do
            table.insert(Features, Token)
            table.insert(Features, `{Previous}+{Token}`)
            Previous = Token
        end
        table.insert(Features, `{Previous}+$`)

        return Features
    end

    function Brain.Train()
        local Model = {Counts = {}, Totals = {}, Vocab = {}, Weights = {}, Size = 0}
        local Known: {[string]: boolean} = {}
        local Templated: {[string]: boolean} = {}

        for Intent: string, Templates: {string} in Brain.Templates do
            local Examples: {string} = {}
            for _, Template: string in Templates do
                local Repeats, Body = Template:match("^(%d+)%*(.+)$")
                local Expanded: {string} = Brain.Expand(Body or Template)
                for _ = 1, tonumber(Repeats) or 1 do
                    for i: number = 1, #Expanded, math.max(1, math.floor(#Expanded / Brain.Cap)) do
                        table.insert(Examples, Expanded[i])
                    end
                end
            end

            if Intent == "Guide" then
                for _, Guide: any in Guides do
                    for Word: string in Guide.Keywords:gmatch("%S+") do
                        table.insert(Examples, `how do i {Word}`)
                        table.insert(Examples, `how to {Word}`)
                        table.insert(Examples, `how can i {Word}`)
                    end
                end
            end

            local Counts: {[string]: number} = {}
            local Total: number = 0
            local Weight: number = 1 / #Examples
            for _, Example: string in Examples do
                local Words: {string} = {}
                for Word: string in Example:gmatch("%S+") do
                    table.insert(Words, Word)
                    if Word:sub(1, 1) ~= "<" then
                        Known[Word] = true
                        Templated[Word] = Templated[Word] or Intent ~= "Guide"
                    end
                end

                for _, Feature: string in Brain.Features(Brain.Prepare(Words)) do
                    Counts[Feature] = (Counts[Feature] or 0) + Weight
                    Total += Weight

                    if not Model.Vocab[Feature] then
                        Model.Vocab[Feature] = true
                        Model.Size += 1
                    end
                end
            end

            Model.Counts[Intent] = Counts
            Model.Totals[Intent] = Total
            Model.Weights[Intent] = Weight
        end

        Brain.Model = Model
        Brain.Known = Known
        Brain.Templated = Templated

        local Saved = isfile(Brain.File) and LoadJSON(Brain.File)
        Brain.Learned = type(Saved) == "table" and Saved or {}
        Brain.Memory = {}
        for _, Example: any in Brain.Learned do
            Brain.Absorb(Example.Intent, Example.Words)
            if type(Example.Phrase) == "string" and type(Example.Choice) == "string" then
                Brain.Memory[Example.Phrase] = Example.Choice
            end
        end
    end

    function Brain.Phrase(Tokens): string
        local Words: {string} = {}
        for _, Token: any in Tokens do
            if not Brain.Drop[Token.Word] then
                table.insert(Words, Token.Word)
            end
        end

        return table.concat(Words, " ")
    end

    function Brain.Absorb(Intent: string, Words: {string})
        local Model = Brain.Model
        local Counts = Model.Counts[Intent]
        if not Counts or type(Words) ~= "table" then return end

        local Weight: number = Model.Weights[Intent] * 4
        for _, Feature: string in Brain.Features(Words) do
            Counts[Feature] = (Counts[Feature] or 0) + Weight
            Model.Totals[Intent] += Weight

            if not Model.Vocab[Feature] then
                Model.Vocab[Feature] = true
                Model.Size += 1
            end
        end
    end

    function Brain.Learn(Candidate)
        if not Brain.Model or not Candidate.Reading then return end

        local Words: {string} = Brain.Prepare(Brain.Delex(Candidate.Tokens, Candidate.Reading))
        local Phrase: string = Brain.Phrase(Candidate.Tokens)
        local Choice: string = Brain.Canonical(Candidate)
        Brain.Memory[Phrase] = Choice

        for i: number = #Brain.Learned, 1, -1 do
            if Brain.Learned[i].Phrase == Phrase then
                table.remove(Brain.Learned, i)
            end
        end

        table.insert(Brain.Learned, {Choice = Choice, Intent = Candidate.Intent, Phrase = Phrase, Words = Words})
        while #Brain.Learned > 300 do
            table.remove(Brain.Learned, 1)
        end

        Brain.Absorb(Candidate.Intent, Words)
        WriteJSON(Brain.File, Brain.Learned)
    end

    function Brain.Classify(Tokens: {string}): {[string]: number}
        local Model = Brain.Model
        local Features: {string} = Brain.Features(Tokens)
        local Scores: {[string]: number} = {}
        local Best: number = -math.huge

        for Intent: string, Counts: {[string]: number} in Model.Counts do
            local Score: number = 0
            local Denominator: number = Model.Totals[Intent] + Brain.Smoothing * Model.Size
            for _, Feature: string in Features do
                if Model.Vocab[Feature] then
                    Score += math.log(((Counts[Feature] or 0) + Brain.Smoothing) / Denominator)
                end
            end

            Scores[Intent] = Score
            Best = math.max(Best, Score)
        end

        local Sum: number = 0
        for Intent: string, Score: number in Scores do
            Scores[Intent] = math.exp((Score - Best) / Brain.Temperature)
            Sum += Scores[Intent]
        end

        for Intent: string, Score: number in Scores do
            Scores[Intent] = Score / Sum
        end

        return Scores
    end

    function Brain.Vocabulary()
        if Brain.Words and Brain.WordsFor == Index then
            return Brain.Words
        end

        local Set: {[string]: boolean} = {}
        local function Take(Text: string?)
            for Word: string in Normalize(Text or ""):gmatch("%S+") do
                Set[Word] = true
            end
        end

        for Word: string in Brain.Known do
            Set[Word] = true
        end

        for Word: string in Stopwords do
            Set[Word] = true
        end

        for Key: string, Entry: any in Index.Keys do
            Set[Key] = true
            Take(Entry.Name)
            Take(SplitName(Entry.Name))
            for _, Option: any in Entry.Options do
                Take(Option.Name)
            end
        end

        for Phrase: string in Places.ByPhrase do
            Take(Phrase)
        end

        for _, Guide: any in Guides do
            Take(Guide.Keywords)
        end

        for _, Fact: any in Facts do
            Take(Fact.Keywords)
        end

        for Word: string in SynonymList do
            Set[Word] = true
        end

        for _, List: {[string]: boolean} in {Brain.Quantifiers, Brain.Nouns, Brain.Pronouns, Brain.ListVerbs, Brain.Trailing, Brain.QuestionWords, Brain.Common, Brain.Complaints, Brain.Drop} do
            for Word: string in List do
                Set[Word] = true
            end
        end

        local Words: {string} = {}
        for Word: string in Set do
            table.insert(Words, Word)
        end

        for Name: string in ColorNames do
            Set[Name] = true
        end

        Brain.Words = {Set = Set, List = Words}
        Brain.WordsFor = Index

        return Brain.Words
    end

    function Brain.LoadDictionary()
        local Dictionary = Brain.Dictionary
        if Dictionary.Buckets or Dictionary.Loading then return end

        Dictionary.Loading = true
        task.spawn(function()
            local Text: string? = isfile(Dictionary.File) and readfile(Dictionary.File) or nil
            if not Text or #Text < 1000000 then
                local Success, Body = pcall(function()
                    return game:HttpGet(Dictionary.Url, true)
                end)

                if Success and type(Body) == "string" and #Body > 1000000 then
                    Text = Body
                    pcall(writefile, Dictionary.File, Body)
                end
            end

            if Text then
                Text = `\n{(Text:gsub("\r", ""))}\n`
                local Buckets: {[string]: string} = {}
                local Start: number? = Text:find("\n%a")
                while Start do
                    local Letter: string = Text:sub(Start + 1, Start + 1)
                    local Finish: number? = nil
                    for Code: number = Letter:byte() + 1, 122 do
                        Finish = Text:find(`\n{string.char(Code)}`, Start + 1, true)
                        if Finish then
                            break
                        end
                    end

                    Buckets[Letter] = Text:sub(Start, Finish or #Text)
                    Start = Finish
                end

                Dictionary.Buckets = Buckets
            end

            Dictionary.Loading = false
        end)
    end

    function Brain.English(Word: string): boolean
        local Dictionary = Brain.Dictionary
        if not Dictionary.Buckets then
            return Brain.Common[Word] == true
        end

        local Found: boolean? = Dictionary.Checked[Word]
        if Found == nil then
            local Bucket: string? = Dictionary.Buckets[Word:sub(1, 1)]
            Found = Bucket ~= nil and Bucket:find(`\n{Word}\n`, 1, true) ~= nil
            Dictionary.Checked[Word] = Found
        end

        return Found
    end

    function Brain.Knows(Word: string): boolean
        return Brain.Vocabulary().Set[Word] == true or Brain.English(Word)
    end

    function Brain.MatchPlayer(Word: string): (string?, boolean)
        local Partial: string?
        for _, Player: Player in Players:GetPlayers() do
            local Username, Display = Player.Name:lower(), Player.DisplayName:lower()
            if Username == Word or Display == Word then
                return Player.Name, true
            elseif #Word >= 3 and not Partial and (Username:sub(1, #Word) == Word or Display:sub(1, #Word) == Word) then
                Partial = Player.Name
            end
        end

        return Partial, false
    end

    function Brain.Squeeze(Word: string): string
        if #Word < 3 or not Word:find("(%a)%1") or Brain.Knows(Word) then
            return Word
        elseif Word:match("^a?h[ahe]+$") and #Word >= 4 then
            return "haha"
        end

        local Doubled: {string} = {}
        local Singled: {string} = {}
        local Previous: string = ""
        local Run: number = 0
        for Letter: string in Word:gmatch(".") do
            Run = Letter == Previous and Run + 1 or 1
            Previous = Letter
            if Run <= 2 then
                table.insert(Doubled, Letter)
            end

            if Run == 1 then
                table.insert(Singled, Letter)
            end
        end

        local Double: string = table.concat(Doubled)
        if Double ~= Word and Brain.Knows(Double) then
            return Double
        end

        local Single: string = table.concat(Singled)
        if #Single >= 2 and (#Word <= 5 or Double ~= Word) and Brain.Knows(Single) then
            return Single
        end

        return Double
    end

    function Brain.Unslang(Text: string): string
        local Words: {string} = Text:split(" ")
        for i: number, Word: string in Words do
            local Core, Tail = Word:match("^([%w']+)(.*)$")
            local Lower: string = Core and (Core:lower():gsub("'", "")) or ""
            local Squeezed: string = Brain.Squeeze(Lower)
            local Previous: string = i > 1 and Words[i - 1]:lower() or ""
            if Brain.Slang[Squeezed] and not (#Squeezed == 1 and Brain.KeyMarkers[Previous]) then
                Words[i] = `{Brain.Slang[Squeezed]}{Tail}`
            elseif Squeezed ~= Lower then
                Words[i] = `{Squeezed}{Tail}`
            end
        end

        Text = table.concat(Words, " ")
        local Whole: string? = Brain.Whole[Text:lower():match("^%s*(.-)[%s%p]*$")]
        if Whole then
            return Whole
        end

        return (Text:gsub("%f[%w][Rr]%s+you%f[%W]", "are you"))
    end

    function Brain.Unpreface(Text: string): string
        local Lower: string = Text:lower()
        for _, Preface: string in Brain.Prefaces do
            if Lower:match(`^%s*{Preface}%f[%A]`) then
                local Rest: string? = Text:match("^[^,]*,%s*(.+)$")
                if Rest and #Rest:split(" ") >= 3 then
                    return Rest
                end
            end
        end

        return Text
    end

    function Brain.Ungreet(Text: string): string
        local Stripped: boolean = true
        while Stripped do
            Stripped = false
            for _, Opener: string in Brain.Openers do
                local Start: number? = Text:lower():match(`^%s*{Opener}[%s,!%.]+()`)
                if Start then
                    local Rest: string = Text:sub(Start)
                    local Word, After = Rest:lower():match("^(%a+)[%s,!%.]+()")
                    while Word and Brain.Addressed[Word] do
                        Rest = Rest:sub(After)
                        Word, After = Rest:lower():match("^(%a+)[%s,!%.]+()")
                    end

                    if #Rest:split(" ") >= (Opener:find(" ") and 3 or 2) then
                        Text = Rest
                        Stripped = true
                    end

                    break
                end
            end
        end

        return Text
    end

    function Brain.Tokenize(Raw: string)
        local Tokens = {}
        local Position: number = 1
        Raw = Raw:gsub("\u{2019}", "'")

        while Position <= #Raw do
            local Quoted: string? = Raw:match('^"([^"]+)"', Position)
            local Number: string? = Raw:match("^%-?%d*%.?%d+", Position)
            local Word: string? = Raw:match("^[%w_']+", Position)

            if Quoted then
                table.insert(Tokens, {Kind = "text", Raw = Quoted, Word = Quoted:lower()})
                Position += #Quoted + 2
            elseif Number and not Raw:match("^%-?%d*%.?%d+[%a_]", Position) then
                table.insert(Tokens, {Kind = "number", Raw = Number, Word = Number, Value = tonumber(Number)})
                Position += #Number
            elseif Word then
                local Clean: string = Word:gsub("'", "")
                if Clean ~= "" then
                    table.insert(Tokens, {Kind = "word", Raw = Clean, Word = Clean:lower()})
                end
                Position += #Word
            else
                Position += 1
            end
        end

        while #Tokens > 1 and Tokens[#Tokens].Kind == "word" and Brain.Trailing[Tokens[#Tokens].Word] do
            table.remove(Tokens)
        end

        return Tokens
    end

    function Brain.Distance(First: string, Second: string): number
        local Before: {number} = {}
        local Previous: {number} = {}
        local Current: {number} = {}
        for j: number = 0, #Second do
            Previous[j] = j
        end

        for i: number = 1, #First do
            Current[0] = i
            local Byte: number = First:byte(i)
            for j: number = 1, #Second do
                Current[j] = math.min(Previous[j] + 1, Current[j - 1] + 1, Previous[j - 1] + (Byte == Second:byte(j) and 0 or 1))

                if i > 1 and j > 1 and Byte == Second:byte(j - 1) and First:byte(i - 1) == Second:byte(j) then
                    Current[j] = math.min(Current[j], Before[j - 2] + 1)
                end
            end

            Before, Previous, Current = Previous, Current, Before
        end

        return Previous[#Second]
    end

    function Brain.Correct(Tokens)
        local Vocabulary = Brain.Vocabulary()

        for _, Token: any in Tokens do
            local Word: string = Token.Word
            if Token.Kind == "word" and #Word >= 4 and Word:match("^%a+$") and not Brain.Knows(Word) and not Brain.MatchPlayer(Word) and not Brain.Elsewhere(Word) then
                local Limit: number = #Word >= 7 and 2 or 1
                local Best, BestCost, Tied = nil, math.huge, false
                for _, Candidate: string in Vocabulary.List do
                    if math.abs(#Candidate - #Word) <= Limit and #Candidate >= 3 then
                        local Gap: number = Brain.Distance(Word, Candidate)
                        if Gap <= Limit then
                            local Cost: number = Gap * 100 + math.abs(#Candidate - #Word) * 10 + (Candidate:sub(1, 1) ~= Word:sub(1, 1) and 5 or 0)
                            if Cost < BestCost then
                                Best, BestCost, Tied = Candidate, Cost, false
                            elseif Cost == BestCost and Candidate ~= Best then
                                Tied = true
                            end
                        end
                    end
                end

                if Best and not Tied then
                    Token.Word = Best
                    Token.Corrected = true
                end
            end
        end
    end

    function Brain.Extract(Tokens)
        local Spans = {}
        local Count: number = #Tokens
        local Scope = {}
        local Owned = {}
        local Binding: boolean = false

        for _, Token: any in Tokens do
            Binding = Binding or Token.Word == "bind" or Token.Word == "keybind" or Token.Word == "rebind" or Token.Word == "hotkey"
        end

        local function Add(I: number, J: number, Type: string, Value: any, Quality: number)
            for k: number = I, J do
                if Tokens[k].Corrected then
                    Quality -= 0.2
                end
            end

            for _, Span: any in Spans do
                if Span.I == I and Span.J == J then
                    table.insert(Span.Options, {Type = Type, Value = Value, Quality = Quality})
                    return
                end
            end

            table.insert(Spans, {I = I, J = J, Options = {{Type = Type, Value = Value, Quality = Quality}}})
        end

        local function Phrase(I: number, J: number, Separator: string): string?
            local Words: {string} = {}
            for k: number = I, J do
                if Tokens[k].Kind ~= "word" then
                    return nil
                end

                table.insert(Words, Tokens[k].Word)
            end

            return table.concat(Words, Separator)
        end

        for I: number = 1, Count do
            for J: number = math.min(Count, I + 3), I, -1 do
                local Spaced: string? = Phrase(I, J, " ")
                if Spaced then
                    local Entry = Index.Keys[Phrase(I, J, "")]
                    if Entry then
                        Add(I, J, "module", Entry, 0)
                        table.insert(Scope, Entry)
                        Owned[J] = Entry
                    end

                    local Stemmed: {string} = {}
                    for Word: string in Spaced:gmatch("%S+") do
                        table.insert(Stemmed, Stem(Word))
                    end

                    local Place = Places.ByPhrase[Spaced]
                    local Loose = not Place and J > I and Places.ByStem[table.concat(Stemmed, " ")]
                    if Place or Loose then
                        Add(I, J, (Place or Loose).Category and "category" or (Place or Loose).Component and "setting" or "place", Place or Loose, Place and 0 or -0.05)
                    end

                    for _, Profile: any in vape.Categories.Profiles and vape.Categories.Profiles.List or {} do
                        if Profile.Name:lower() == Spaced then
                            Add(I, J, "profile", Profile.Name, -0.1)
                        end
                    end
                end
            end

            local Token = Tokens[I]
            if Token.Kind == "number" then
                Add(I, I, "number", Token.Value, 0)
            elseif Token.Kind == "text" then
                Add(I, I, "text", Token.Raw, 0)
            else
                local Word: string = Token.Word
                if Brain.Quantifiers[Word] then
                    Add(I, I, "all", Word, 0)
                end

                if Brain.Nouns[Word] then
                    Add(I, I, "tabs", Word, 0)
                end

                if ColorNames[Word] then
                    Add(I, I, "color", Word, 0)
                end

                if Brain.Pronouns[Word] and (LastTopic or Brain.LastTargets) then
                    Add(I, I, "it", Word, 0)
                end

                if Brain.StyleEntities[Word] then
                    Add(I, I, "style", Brain.StyleOf({Token}), -0.4)
                end
            end

            local Letter: boolean = #Token.Word == 1 and Token.Word ~= "a" and Token.Word ~= "i" and Token.Word ~= "u"
            local Pressing: boolean = Letter and I < Count and Brain.KeyVerbs[Tokens[I + 1].Word] ~= nil
            if Token.Kind ~= "text" and ((I > 1 and Brain.KeyMarkers[Tokens[I - 1].Word]) or Brain.KeyNames[Token.Word] or (Binding and Letter) or Pressing) then
                local Double: string? = I < Count and Tokens[I + 1].Kind == "word" and ResolveKey(`{Token.Word}{Tokens[I + 1].Word}`)
                if Double then
                    Add(I, I + 1, "key", Double, 0)
                end

                local Single: string? = ResolveKey(Token.Word)
                if Single then
                    Add(I, I, "key", Single, 0)
                end
            end

            if Token.Kind == "word" and #Token.Word >= 3 then
                local Name, Exact = Brain.MatchPlayer(Token.Word)
                local Listing: boolean = I > 1 and Brain.ListVerbs[Tokens[I - 1].Word] ~= nil
                if Name and (Exact or not Brain.Vocabulary().Set[Token.Word]) then
                    local Quality: number = Exact and 0 or -0.3
                    if Brain.Vocabulary().Set[Token.Word] and not Listing then
                        Quality -= 0.5
                    end

                    Add(I, I, "player", {Name = Name, Found = true}, Quality)
                elseif I > 1 and Brain.ListVerbs[Tokens[I - 1].Word] and Token.Raw:match("^[%w_]+$") and not Brain.Vocabulary().Set[Token.Word] and not Index.Keys[Token.Word] then
                    Add(I, I, "player", {Name = Token.Raw, Found = false}, -0.4)
                end
            end
        end

        local Owners = table.clone(Scope)
        local Previous = LastTopic and Index.Keys[LastTopic]
        if Previous and not table.find(Owners, Previous) then
            table.insert(Owners, Previous)
        end

        for _, Owner: any in Owners do
            local Explicit: boolean = table.find(Scope, Owner) ~= nil
            for _, Option: any in Owner.Options do
                local Words: {string} = Normalize(Option.Name):split(" ")
                for I: number = 1, Count - #Words + 1 do
                    if Phrase(I, I + #Words - 1, " ") == table.concat(Words, " ") and Phrase(I, I + #Words - 1, "") ~= Owner.Key then
                        local Before: string = I > 1 and Tokens[I - 1].Word or ""
                        local After: string = Tokens[I + #Words] and Tokens[I + #Words].Word or ""
                        local Quality: number = Explicit and 0 or -0.3
                        if Owned[I - 1] == Owner then
                            Quality += 0.3
                        elseif Before == "and" or Before == "or" then
                            Quality -= 0.8
                        elseif (After == "and" or After == "or") and Owned[I + #Words + 1] == Owner then
                            Quality -= 1.2
                        end

                        Add(I, I + #Words - 1, "option", {Entry = Owner, Option = Option}, Quality)
                    end
                end
            end
        end

        for I: number = 1, Count - 1 do
            for J: number = math.min(Count, I + 3), I + 1, -1 do
                local Owners = Index.Options[Phrase(I, J, " ") or ""] or {}
                local Claimed: boolean = false
                for _, Found: any in Owners do
                    Claimed = Claimed or table.find(Scope, Found.Entry) ~= nil
                end

                for k: number = 1, Claimed and 0 or math.min(4, #Owners) do
                    local Found = Owners[k]
                    local Quality: number = -0.25 - (#Owners > 1 and 0.1 or 0)
                    if Found.Entry == Previous then
                        Quality += 0.15
                    end

                    if Found.Entry.Module.Enabled then
                        Quality += 0.1
                    elseif Found.Entry.Category == "Kits" then
                        Quality -= 0.8
                    end

                    Add(I, J, "option", Found, Quality)
                end
            end
        end

        for i: number = #Spans, 1, -1 do
            local Span = Spans[i]
            for j: number = #Span.Options, 1, -1 do
                local Option = Span.Options[j]
                if Option.Type == "place" and Option.Value.Id == "settings" then
                    local Before: string = Span.I > 1 and Tokens[Span.I - 1].Word or ""
                    if Before == "its" or Before == "their" or Before == "it" or #Scope > 0 then
                        table.remove(Span.Options, j)
                    end
                end
            end

            if #Span.Options == 0 then
                table.remove(Spans, i)
            end
        end

        return Spans
    end

    function Brain.Readings(Spans)
        table.sort(Spans, function(A, B)
            if (A.J - A.I) ~= (B.J - B.I) then
                return (A.J - A.I) > (B.J - B.I)
            end

            return A.I < B.I
        end)

        local Taken: {[number]: boolean} = {}
        local Chosen = {}
        for _, Span: any in Spans do
            local Free: boolean = true
            for k: number = Span.I, Span.J do
                Free = Free and not Taken[k]
            end

            if Free then
                for k: number = Span.I, Span.J do
                    Taken[k] = true
                end
                table.insert(Chosen, Span)
            end
        end

        table.sort(Chosen, function(A, B)
            return A.I < B.I
        end)

        local Readings = {{Entities = {}, Quality = 0}}
        for _, Span: any in Chosen do
            table.sort(Span.Options, function(A, B)
                return A.Quality > B.Quality
            end)

            local Next = {}
            for _, Reading: any in Readings do
                for _, Option: any in Span.Options do
                    if #Next < 16 then
                        local Entities = table.clone(Reading.Entities)
                        table.insert(Entities, {Type = Option.Type, Value = Option.Value, I = Span.I, J = Span.J, Quality = Option.Quality})
                        table.insert(Next, {Entities = Entities, Quality = Reading.Quality + Option.Quality})
                    end
                end
            end
            Readings = Next
        end

        return Readings
    end

    function Brain.Delex(Tokens, Reading): {string}
        local Covered = {}
        for _, Entity: any in Reading.Entities do
            for k: number = Entity.I, Entity.J do
                Covered[k] = Entity
            end
        end

        local Words: {string} = {}
        local k: number = 1
        while k <= #Tokens do
            local Entity = Covered[k]
            if Entity then
                table.insert(Words, `<{Entity.Type}>`)
                k = Entity.J + 1
            else
                local Token = Tokens[k]
                table.insert(Words, Token.Kind == "number" and "<number>" or Token.Kind == "text" and "<text>" or Token.Word)
                k += 1
            end
        end

        return Words
    end

    function Brain.HasWord(Tokens, List: {string}): boolean
        for _, Token: any in Tokens do
            if table.find(List, Token.Word) then
                return true
            end
        end

        return false
    end

    function Brain.Refer()
        if Brain.LastTargets and Brain.LastTargets[1] then
            return Brain.LastTargets[1]
        end

        local Entry = LastTopic and Index.Keys[LastTopic]
        return Entry and {Type = "module", Value = Entry, Implicit = true} or nil
    end

    function Brain.OptionOf(Target)
        if Target.Type == "setting" then
            local Place = Target.Value
            return {Name = Place.Name, Option = Place.Component, Settings = {}, Type = Place.Component.Type}, nil
        end

        return Target.Value.Option, Target.Value.Entry
    end

    function Brain.Fillers.Targets(Reading, Tokens)
        local Targets, Used = {}, {}
        local Collection: boolean = false

        local Seen = {}
        for _, Entity: any in Reading.Entities do
            local Type: string = Entity.Type
            if Type == "module" or Type == "place" or Type == "category" or Type == "setting" or Type == "option" then
                if not Seen[Entity.Value] then
                    table.insert(Targets, Entity)
                end

                Seen[Entity.Value] = true
                Used[Entity] = true
            elseif Type == "it" then
                local Referred = Brain.Refer()
                if Referred then
                    table.insert(Targets, Referred)
                    Used[Entity] = true
                end
            elseif Type == "all" or Type == "tabs" then
                Collection = true
                Used[Entity] = true
            end
        end

        if #Targets == 0 and not Collection then
            return nil
        end

        return {Targets = Targets, Collection = #Targets == 0, Expand = Brain.HasWord(Tokens, SettingWords), Bind = Brain.HasWord(Tokens, BindWords)}, Used
    end

    function Brain.Fillers.Module(Reading)
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" then
                return {Entry = Entity.Value}, {[Entity] = true}
            elseif Entity.Type == "option" then
                return {Entry = Entity.Value.Entry, Option = Entity.Value.Option}, {[Entity] = true}
            end
        end

        for _, Entity: any in Reading.Entities do
            local Referred = Entity.Type == "it" and Brain.Refer()
            if Referred and Referred.Type == "module" then
                return {Entry = Referred.Value, Implicit = true}, {[Entity] = true}
            end
        end

        local Previous = LastTopic and Index.Keys[LastTopic]
        if Previous and #Reading.Entities == 0 then
            return {Entry = Previous, Implicit = true}, {}
        end

        return nil
    end

    function Brain.Fillers.Option(Reading, Tokens)
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "option" then
                local Used = {[Entity] = true}
                for _, Other: any in Reading.Entities do
                    if Other.Type == "module" and Other.Value == Entity.Value.Entry then
                        Used[Other] = true
                    end
                end

                return {Entry = Entity.Value.Entry, Option = Entity.Value.Option}, Used
            end
        end

        local Slots, Used = Brain.Fillers.Module(Reading)
        if not Slots then
            return nil
        elseif Slots.Option then
            return Slots, Used
        end

        local Words: {string} = {}
        for _, Token: any in Tokens do
            table.insert(Words, Token.Word)
        end

        local Matches = FindOption(Slots.Entry, BuildQuery(table.concat(Words, " ")), 1)
        if Matches[1] and Matches[1].Score >= 0.5 then
            Slots.Option = Matches[1].Option
            return Slots, Used
        end

        return nil
    end

    function Brain.Fillers.Switch(Reading)
        local Targets, Used = {}, {}
        local All: boolean = false
        local Category: string?

        for _, Entity: any in Reading.Entities do
            local Type: string = Entity.Type
            if Type == "all" then
                All = true
                Used[Entity] = true
            elseif Type == "category" then
                Category = Entity.Value.Category
                Used[Entity] = true
            elseif Type == "place" and Entity.Value.Id == "legit" then
                Category = "Legit"
                Used[Entity] = true
            elseif Type == "module" or Type == "option" or Type == "setting" then
                table.insert(Targets, Entity)
                Used[Entity] = true
            elseif Type == "it" then
                local Referred = Brain.Refer()
                if Referred then
                    table.insert(Targets, Referred)
                    Used[Entity] = true
                end
            elseif Type == "tabs" then
                Used[Entity] = true
            end
        end

        if Category and #Targets == 0 then
            return {Bulk = Category}, Used
        elseif All and #Targets == 0 then
            return {BulkAll = true}, Used
        elseif #Targets == 0 then
            return nil
        end

        local Owners = {}
        for _, Target: any in Targets do
            if Target.Type == "option" then
                Owners[Target.Value.Entry] = true
            end
        end

        local Filtered = {}
        for _, Target: any in Targets do
            if not (Target.Type == "module" and Owners[Target.Value]) then
                table.insert(Filtered, Target)
            end
        end

        return {Targets = Filtered}, Used
    end

    function Brain.Fillers.Set(Reading, Tokens)
        local Used = {}
        local Explicit = {}
        local Target

        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" then
                Explicit[Entity.Value] = Entity
            end
        end

        for _, Entity: any in Reading.Entities do
            if Entity.Type == "option" and (not Target or Explicit[Entity.Value.Entry]) then
                Target = Entity
            end
        end

        for _, Entity: any in Reading.Entities do
            if not Target and Entity.Type == "setting" and Entity.Value.Component then
                Target = Entity
            end
        end

        if not Target then
            for Entry: any, Entity: any in Explicit do
                for _, Option: any in Entry.Options do
                    if not Target and Normalize(Option.Name) == Normalize(Entry.Name) then
                        Target = {Type = "option", Value = {Entry = Entry, Option = Option}, I = Entity.I, J = Entity.J}
                    end
                end
            end
        end

        if not Target then
            for Entry: any, Entity: any in Explicit do
                for k: number = Entity.J + 1, math.min(#Tokens, Entity.J + 2) do
                    local Word: string = Tokens[k].Word
                    local Matches = Tokens[k].Kind == "word" and Word ~= "to" and Word ~= "at" and FindOption(Entry, BuildQuery(Word), 1) or {}
                    local Unique: boolean = Matches[1] ~= nil and (not Matches[2] or Matches[2].Score < Matches[1].Score)
                    if not Target and Unique and Matches[1].Score >= 0.5 then
                        Target = {Type = "option", Value = {Entry = Entry, Option = Matches[1].Option}, I = k, J = k}
                    end
                end
            end
        end

        if not Target and not next(Explicit) and Brain.LastOption then
            local Pointer
            for _, Entity: any in Reading.Entities do
                if Entity.Type == "it" then
                    Pointer = Entity
                    Used[Entity] = true
                end
            end

            local First: string = Tokens[1].Word
            if Pointer or First == "set" or First == "change" or First == "make" or First == "put" or First == "increase" or First == "decrease" or First == "raise" or First == "lower" then
                Target = {Type = Brain.LastOption.Type, Value = Brain.LastOption.Value, I = Pointer and Pointer.I or 1, J = Pointer and Pointer.J or 1}
            end
        end

        if not Target then
            return nil
        end

        Used[Target] = true
        if Target.Type == "option" and Explicit[Target.Value.Entry] then
            Used[Explicit[Target.Value.Entry]] = true
        end

        local Start: number = Target.J + 1
        for k: number = Target.J + 1, #Tokens do
            if Tokens[k].Word == "to" or Tokens[k].Word == "at" then
                Start = k + 1
                break
            end
        end

        if Start > #Tokens then
            return nil
        end

        local Parts: {string} = {}
        for k: number = Start, #Tokens do
            table.insert(Parts, Tokens[k].Raw)
        end

        for _, Entity: any in Reading.Entities do
            if Entity.I >= Start then
                Used[Entity] = true
            end
        end

        return {Target = Target, Value = table.concat(Parts, " ")}, Used
    end

    function Brain.Fillers.Bind(Reading)
        local Used = {}
        local Target, Key

        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" and not Target then
                Target = Entity.Value
                Used[Entity] = true
            elseif Entity.Type == "place" and (Entity.Value.Id == "gui" or Entity.Value.Id == "rebind gui") and not Target then
                Target = "GUI"
                Used[Entity] = true
            elseif Entity.Type == "key" and not Key then
                Key = Entity.Value
                Used[Entity] = true
            elseif Entity.Type == "it" and not Target then
                local Referred = Brain.Refer()
                if Referred and Referred.Type == "module" then
                    Target = Referred.Value
                    Used[Entity] = true
                end
            end
        end

        if not Target or not Key then
            return nil
        end

        return {Target = Target, Key = Key}, Used
    end

    function Brain.Fillers.ProfileName(_, _, Raw: string)
        local Name: string? = TextAfter(Raw, {"called", "named", "profile"})
        if not Name then
            local From, To = Raw:lower():match("^%a+%s+()%S.-()%s+profile")
            Name = From and Raw:sub(From, To - 1)
        end

        if not Name then
            return nil
        end

        Name = Name:gsub("^[Tt][Oo]%s+", ""):gsub("^[Tt]he%s+", ""):gsub("^[Mm]y%s+", ""):gsub("^[Aa]%s+", ""):gsub("^[Nn]ew%s+", ""):gsub("%s+[Pp]rofile$", ""):gsub("[^%w%s_%-]", "")
        Name = Name:match("^%s*(.-)%s*$"):sub(1, 30)

        return Name ~= "" and {Name = Name} or nil, {}
    end

    function Brain.Fillers.Profile(Reading, Tokens, Raw: string)
        local Verbs: {string} = {"switch", "load", "use", "swap", "change", "select", "apply", "delete", "remove", "erase", "go", "move", "pick"}
        if not Brain.HasWord(Tokens, {"profile", "profiles", "to"}) and not table.find(Verbs, Tokens[1].Word) then
            return nil
        end

        for _, Entity: any in Reading.Entities do
            if Entity.Type == "profile" then
                return {Name = Entity.Value}, {[Entity] = true}
            end
        end

        local Slots = Brain.Fillers.ProfileName(Reading, nil, Raw)
        local Found: string? = Slots and FindProfile(Slots.Name)

        return Found and {Name = Found} or nil, {}
    end

    function Brain.Fillers.List(Reading, Tokens)
        local Used = {}
        local Player, ListName

        for _, Entity: any in Reading.Entities do
            if Entity.Type == "player" and not Player then
                Player = Entity.Value
                Used[Entity] = true
            elseif Entity.Type == "place" and (Entity.Value.Id == "friends" or Entity.Value.Id == "targets") then
                ListName = Entity.Value.Id == "friends" and "Friends" or "Targets"
                Used[Entity] = true
            end
        end

        local Lists = {Friends = {}, Targets = {}}
        for Word: string in ("friend unfriend whitelist unwhitelist protect"):gmatch("%S+") do
            Lists.Friends[Stem(Word)] = true
        end

        for Word: string in ("target untarget focus prioritize"):gmatch("%S+") do
            Lists.Targets[Stem(Word)] = true
        end

        for _, Token: any in Tokens do
            local Word: string = Stem(Token.Word)
            if not ListName and Lists.Friends[Word] then
                ListName = "Friends"
            elseif not ListName and Lists.Targets[Word] then
                ListName = "Targets"
            end
        end

        if not ListName and Brain.HasWord(Tokens, {"attack", "hit", "kill"}) and Brain.HasWord(Tokens, {"dont", "never", "not"}) then
            ListName = "Friends"
        end

        if not Player or not ListName then
            return nil
        end

        return {Player = Player, List = ListName}, Used
    end

    function Brain.Fillers.Compare(Reading)
        local Modules, Used = {}, {}
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" and not table.find(Modules, Entity.Value) then
                table.insert(Modules, Entity.Value)
                Used[Entity] = true
            end
        end

        return #Modules >= 2 and {Modules = Modules} or nil, Used
    end

    function Brain.Fillers.Category(Reading)
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "category" then
                return {Name = Entity.Value.Category}, {[Entity] = true}
            elseif Entity.Type == "place" and Entity.Value.Id == "legit" then
                return {Name = "Legit"}, {[Entity] = true}
            end
        end

        return nil
    end

    function Brain.Fillers.Place(Reading)
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "place" or Entity.Type == "setting" or Entity.Type == "category" then
                return {Place = Entity.Value}, {[Entity] = true}
            end
        end

        return nil
    end

    function Brain.Fillers.Everything(Reading)
        local Used = {}
        for _, Entity: any in Reading.Entities do
            Used[Entity] = true
        end

        return {}, Used
    end

    function Brain.Fillers.Preset(Reading, Tokens, Raw: string)
        if not Brain.HasWord(Tokens, Brain.PresetWords) then
            return nil
        end

        local Named = TextAfter(Raw, {"called", "named"})
        Named = Named and (Named:match("^(.-)%s+with%s") or Named):gsub("[^%w%s_%-]", ""):match("^%s*(.-)%s*$"):sub(1, 30)

        local _, Used = Brain.Fillers.Everything(Reading)
        return {Name = Named ~= "" and Named or nil, New = Brain.HasWord(Tokens, Brain.PresetNouns)}, Used
    end

    function Brain.Fillers.News(Reading)
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" then
                return {Entry = Entity.Value}, {[Entity] = true}
            end
        end

        return {}, {}
    end

    function Brain.Fillers.Pair(Reading)
        local Modules, Used = {}, {}
        for _, Entity: any in Reading.Entities do
            local Entry = Entity.Type == "module" and Entity.Value or Entity.Type == "it" and Brain.Topic() or nil
            if Entry and not table.find(Modules, Entry) then
                table.insert(Modules, Entry)
                Used[Entity] = true
            end
        end

        return #Modules >= 2 and {Modules = Modules} or nil, Used
    end

    function Brain.Fillers.Mentioned(Reading)
        local Modules, Used = {}, {}
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" and not table.find(Modules, Entity.Value) then
                table.insert(Modules, Entity.Value)
                Used[Entity] = true
            end
        end

        return #Modules >= 1 and {Modules = Modules} or nil, Used
    end

    function Brain.Fillers.Topic(Reading, Tokens)
        if #Tokens > 9 then
            return nil
        end

        local Slots, Used = {}, {}
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" and not Slots.Entry then
                Slots.Entry = Entity.Value
                Used[Entity] = true
            elseif Entity.Type == "option" and not Slots.Entry then
                Slots.Entry, Slots.Option = Entity.Value.Entry, Entity.Value.Option
                Used[Entity] = true
            elseif Entity.Type == "it" or Entity.Type == "number" then
                Used[Entity] = true
            end
        end

        return (Slots.Entry or Brain.Topic()) and Slots or nil, Used
    end

    function Brain.Fillers.Goal(Reading, Tokens)
        local Used = {}
        for _, Entity: any in Reading.Entities do
            if (Entity.Type == "module" and not Brain.English(Entity.Value.Key)) or Entity.Type == "option" then
                return nil
            end

            Used[Entity] = true
        end

        if Brain.HasWord(Tokens, Brain.ModuleWords) then
            return {Explicit = true}, Used
        end

        local Picked = Brain.Goal(Tokens)
        return {Soft = #Picked == 0, Pick = Picked[1]}, Used
    end

    function Brain.Fillers.Setting(Reading, Tokens)
        local Used = {}
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "number" then
                Used[Entity] = true
            end
        end

        local Slots, Found = Brain.Fillers.Option(Reading, Tokens)
        if not Slots then
            local Last = Brain.LastOption and Brain.LastOption.Value
            local Module
            for _, Entity: any in Reading.Entities do
                Module = Module or (Entity.Type == "module" and Entity) or nil
            end

            if Module then
                Slots, Found = {Entry = Module.Value}, {[Module] = true}
            elseif Last and Last.Entry then
                Slots, Found = {Entry = Last.Entry, Option = Last.Option, Implicit = true}, {}
            elseif LastTopic and Index.Keys[LastTopic] then
                Slots, Found = {Entry = Index.Keys[LastTopic], Implicit = true}, {}
            else
                return nil
            end
        end

        for Entity: any in Found or {} do
            Used[Entity] = true
        end

        return Slots, Used
    end

    function Brain.Fillers.Effect(Reading, Tokens)
        local Slots, Used = Brain.Fillers.Setting(Reading, Tokens)
        return Slots and Slots.Option and Slots or nil, Used
    end

    function Brain.Fillers.Configure(Reading, Tokens)
        local Slots, Used = Brain.Fillers.Module(Reading)
        if not Slots then
            return nil
        end

        local Skip: {[number]: boolean} = {}
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" or Entity.Type == "option" then
                for k: number = Entity.I, Entity.J do
                    Skip[k] = true
                end
            elseif (Entity.Type == "place" or Entity.Type == "profile") and Entity.I == Entity.J and Brain.StyleOf({Tokens[Entity.I]}) then
                Used[Entity] = true
            end
        end

        local Style: string?
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "style" then
                Style = Style or Entity.Value
                Used[Entity] = true
            end
        end

        return {Entry = Slots.Entry, Style = Style or Brain.StyleOf(Tokens, Skip), Implicit = Slots.Implicit}, Used
    end

    function Brain.Fillers.BuildProfile(Reading, Tokens, Raw: string)
        local Used = {}
        for _, Entity: any in Reading.Entities do
            if Entity.Type == "module" or Entity.Type == "option" then
                return nil
            end

            Used[Entity] = true
        end

        if not Brain.HasWord(Tokens, Brain.PresetNouns) then
            return nil
        end

        local Named: string? = TextAfter(Raw, {"called", "named"})
        Named = Named and Named:gsub("[^%w%s_%-]", ""):match("^%s*(.-)%s*$"):sub(1, 30)
        local Before: {any} = {}
        for _, Token: any in Tokens do
            if Token.Word == "called" or Token.Word == "named" then
                break
            end

            table.insert(Before, Token)
        end

        local Style: string? = Brain.StyleOf(Before)
        local Wanted: boolean = Style ~= nil and Style ~= "Default"
        for _, Token: any in Before do
            Wanted = Wanted or Brain.Quality[Token.Word] == true
        end

        if not Wanted then
            return nil
        end

        return {Style = Style ~= "Default" and Style or nil, Name = Named ~= "" and Named or nil}, Used
    end

    Brain.FillerFor = {
        Bind = Brain.Fillers.Bind,
        BindInfo = Brain.Fillers.Module,
        BuildProfile = Brain.Fillers.BuildProfile,
        Configure = Brain.Fillers.Configure,
        PlaceInfo = Brain.Fillers.Place,
        Status = Brain.Fillers.Module,
        Close = Brain.Fillers.Targets,
        Compare = Brain.Fillers.Compare,
        Describe = Brain.Fillers.Module,
        Effect = Brain.Fillers.Effect,
        Favorite = Brain.Fillers.Module,
        Hide = Brain.Fillers.Module,
        HowTo = Brain.Fillers.Everything,
        Interaction = Brain.Fillers.Pair,
        ListWindows = Brain.Fillers.Everything,
        More = Brain.Fillers.Topic,
        Recommend = Brain.Fillers.Goal,
        Simpler = Brain.Fillers.Topic,
        Tradeoff = Brain.Fillers.Setting,
        Using = Brain.Fillers.Mentioned,
        ListAdd = Brain.Fillers.List,
        ListCategory = Brain.Fillers.Category,
        ListRemove = Brain.Fillers.List,
        Locate = Brain.Fillers.Targets,
        News = Brain.Fillers.News,
        Open = Brain.Fillers.Targets,
        OptionInfo = Brain.Fillers.Option,
        Preset = Brain.Fillers.Preset,
        ProfileCreate = Brain.Fillers.ProfileName,
        ProfileDelete = Brain.Fillers.Profile,
        ProfileSwitch = Brain.Fillers.Profile,
        SetValue = Brain.Fillers.Set,
        Settings = Brain.Fillers.Module,
        Toggle = Brain.Fillers.Switch,
        Trouble = Brain.Fillers.Module,
        TurnOff = Brain.Fillers.Switch,
        TurnOn = Brain.Fillers.Switch,
        Unbind = Brain.Fillers.Module
    }

    function Brain.Score(Intent: string, Probability: number, Reading, Slots, Used, FollowUp: boolean): number
        local Score: number = math.log(math.max(Probability, 0.0001)) + Reading.Quality

        for _, Entity: any in Reading.Entities do
            if Used[Entity] then
                Score += 0.4
            elseif Entity.Type == "all" or Entity.Type == "tabs" or Entity.Type == "it" then
                Score -= 0.3
            else
                Score -= 0.8
            end
        end

        if Slots.Implicit then
            Score -= 0.3
        end

        if Slots.Style and (Intent == "Configure" or Intent == "BuildProfile") then
            Score += 0.8
        end

        if FollowUp and Intent == Brain.LastIntent then
            Score += 2
        end

        return Score
    end

    function Brain.Name(Target): string
        if Target.Type == "module" then
            return Target.Value.Name
        elseif Target.Type == "option" then
            return `{Target.Value.Entry.Name} {Target.Value.Option.Name}`
        elseif Target.Type == "category" then
            return Target.Value.Category
        end

        return (Target.Value.Name:gsub("^the ", ""))
    end

    function Brain.Canonical(Candidate): string
        local Intent, Slots = Candidate.Intent, Candidate.Slots
        local function Targets(): string
            local Names: {string} = {}
            for _, Target: any in Slots.Targets or {} do
                table.insert(Names, Brain.Name(Target))
            end

            return JoinNames(Names, 4)
        end

        if Intent == "Open" or Intent == "Close" then
            return Slots.Collection and `{Intent} all tabs` or `{Intent} {Targets()}`
        elseif Intent == "Locate" then
            return `Where is {Targets()}?`
        elseif Intent == "TurnOn" or Intent == "TurnOff" or Intent == "Toggle" then
            local Verb: string = Intent == "TurnOn" and "Turn on" or Intent == "TurnOff" and "Turn off" or "Toggle"
            return Slots.Bulk and `{Verb} all {Slots.Bulk} modules` or Slots.BulkAll and `{Verb} everything` or `{Verb} {Targets()}`
        elseif Intent == "SetValue" then
            return `Set {Brain.Name(Slots.Target)} to {Slots.Value}`
        elseif Intent == "Bind" then
            return `Bind {Slots.Target == "GUI" and "the GUI" or Slots.Target.Name} to {Slots.Key}`
        elseif Intent == "ProfileCreate" then
            return `Create profile {Slots.Name}`
        elseif Intent == "Preset" then
            return Slots.New and "Make a new config with the core modules" or "Turn on the core modules"
        elseif Intent == "ProfileSwitch" then
            return `Switch to profile {Slots.Name}`
        elseif Intent == "ProfileDelete" then
            return `Delete profile {Slots.Name}`
        elseif Intent == "ListAdd" then
            return `Add {Slots.Player.Name} to {Slots.List}`
        elseif Intent == "ListRemove" then
            return `Remove {Slots.Player.Name} from {Slots.List}`
        elseif Intent == "ListCategory" then
            return `What is in {Slots.Name}?`
        elseif Intent == "Compare" then
            return `Compare {Slots.Modules[1].Name} and {Slots.Modules[2].Name}`
        elseif Intent == "BuildProfile" then
            return Slots.Style and `Make me a {Brain.StyleName(Slots.Style)} profile` or "Make me a good profile"
        elseif Intent == "Interaction" then
            return `Can {Slots.Modules[1].Name} and {Slots.Modules[2].Name} run together?`
        elseif Intent == "Using" then
            local Names: {string} = {}
            for _, Entry: any in Slots.Modules do
                table.insert(Names, Entry.Name)
            end

            return `I'm using {JoinNames(Names, 4)}`
        elseif Intent == "PlaceInfo" then
            return `What is {Slots.Place.Name}?`
        elseif Slots.Entry then
            local Names = {
                BindInfo = `What key is {Slots.Entry.Name} on?`,
                Status = `Is {Slots.Entry.Name} on?`,
                Configure = Slots.Style == "Default" and `Reset {Slots.Entry.Name} to default` or Slots.Style and `Make {Slots.Entry.Name} {Brain.StyleName(Slots.Style)}` or `Set up {Slots.Entry.Name}`,
                Describe = `What does {Slots.Entry.Name} do?`,
                Effect = `What does {Slots.Option and Slots.Option.Name or "that"} in {Slots.Entry.Name} change?`,
                Favorite = `Favorite {Slots.Entry.Name}`,
                More = `Tell me more about {Slots.Entry.Name}`,
                Simpler = `Explain {Slots.Entry.Name} simpler`,
                Tradeoff = `Is my {Slots.Entry.Name} {Slots.Option and Slots.Option.Name or "setup"} good?`,
                Hide = `Hide {Slots.Entry.Name}`,
                News = `What changed in {Slots.Entry.Name}?`,
                OptionInfo = `What is {Slots.Option and Slots.Option.Name or "that"} in {Slots.Entry.Name}?`,
                Settings = `{Slots.Entry.Name} settings`,
                Trouble = `{Slots.Entry.Name} is not working`,
                Unbind = `Unbind {Slots.Entry.Name}`
            }

            return Names[Intent] or Intent
        end

        local Names = {
            Code = "Write me a script",
            Count = "How many modules are there?",
            Help = "What can you do?",
            More = "Tell me more",
            Recommend = "Which module fits that?",
            Screenshot = "Look at my screen",
            Simpler = "Explain it simpler",
            ListEnabled = "What modules are on?",
            ListWindows = "What tabs are there?",
            News = "What's new?",
            ProfileList = "What profiles do I have?",
            Undo = "Undo"
        }

        return Names[Intent] or Intent
    end

    function Brain.Remember(Label: string, Undo: () -> ())
        table.insert(Brain.History, {Label = Label, Undo = Undo})
        if #Brain.History > 20 then
            table.remove(Brain.History, 1)
        end
    end

    function Brain.Undo()
        local Last = table.remove(Brain.History)
        if not Last then
            return {Text = "There is nothing for me to undo."}
        end

        Last.Undo()
        return {Text = `Undid that: {Last.Label}.`}
    end

    function Brain.WithUndo(Actions)
        Actions = Actions or {}
        table.insert(Actions, {
            Text = "Undo",
            Callback = function()
                Reply(Brain.Undo())
            end
        })

        return Actions
    end

    function Brain.Capture(Option): () -> ()
        local Component = Option.Option
        if not Component then
            return function() end
        end

        if Option.Type == "Toggle" then
            local Old: boolean = Component.Enabled
            return function()
                if Component.Enabled ~= Old then
                    Component:Toggle()
                end
            end
        elseif Option.Type == "Slider" then
            local Old: number = Component.Value
            return function()
                Component:SetValue(Old, nil, true)
            end
        elseif Option.Type == "TwoSlider" then
            local Low, High = Component.ValueMin, Component.ValueMax
            return function()
                Component:SetValue(false, Low)
                Component:SetValue(true, High)
            end
        elseif Option.Type == "ColorSlider" then
            local Hue, Sat, Value = Component.Hue, Component.Sat, Component.Value
            return function()
                Component:SetValue(Hue, Sat, Value)
            end
        elseif Option.Type == "Dropdown" or Option.Type == "TextBox" then
            local Old = Component.Value
            return function()
                Component:SetValue(Old)
            end
        end

        return function() end
    end

    function Brain.Capitalize(Text: string): string
        return (Text:gsub("^%l", string.upper))
    end

    function Brain.Windows(Kind: string)
        local Windows = {}
        for Name: string, Category: any in vape.Categories do
            if (Category.Type == "Category" and Name ~= "Favorites") or (Kind == "Close" and Category.Type == "CategoryList") then
                table.insert(Windows, {Name = Name, Category = Category, Order = table.find(Brain.WindowOrder, Name) or 99})
            end
        end

        table.sort(Windows, function(A, B)
            if A.Order ~= B.Order then
                return A.Order < B.Order
            end

            return A.Name < B.Name
        end)

        local Names: {string} = {}
        if Kind == "Close" then
            for _, Window: any in Windows do
                if Window.Category.Button and Window.Category.Button.Enabled then
                    Window.Category.Button:Toggle()
                    table.insert(Names, Window.Name)
                end
            end

            for _, Pane: any in vape.Settings do
                Pane.Object.Visible = false
            end

            return {Text = #Names > 0 and `Closed {#Names} tab{#Names == 1 and "" or "s"}: {JoinNames(Names, 10)}.` or "All the tabs are already closed."}
        end

        for _, Window: any in Windows do
            OpenWindow(Window.Category)
            table.insert(Names, Window.Name)
        end

        return {Text = `Opened all {#Names} tabs: {JoinNames(Names, 10)}. If they overlap, {Accent("Sort GUI")} in the GUI settings lines them up.`, Actions = PlaceActions(GetPlace("sort gui"))}
    end

    function Brain.NavigateModule(Kind: string, Entry, Slots)
        LastTopic = Entry.Key

        if Kind == "Close" then
            if not Entry.Legit then
                Entry.Module:SetExpanded(false)
            end

            return {Text = `Closed {Accent(Entry.Name)}'s settings.`}
        elseif Slots.Bind and Entry.Module.Bind and not Entry.Legit then
            ShowBind(Entry)
            return {Text = `Here is {Accent(Entry.Name)}'s bind button. Click it and press a key, or tell me something like "bind {Entry.Name} to R".`}
        end

        local Expand: boolean = Kind == "Open" or Slots.Expand
        ShowModule(Entry, nil, Expand)
        return {
            Text = Expand and `Opened {Accent(Entry.Name)}'s settings in {WhereText(Entry)}.` or `{Accent(Entry.Name)} is in {WhereText(Entry)}, I highlighted it for you.`,
            Actions = ModuleActions(Entry)
        }
    end

    function Brain.NavigatePlace(Kind: string, Place)
        if Kind == "Close" then
            if not Place.Close then
                return {Text = `{Brain.Capitalize(Place.Name)} cannot be closed from here.`}
            end

            Place.Close()
            return {Text = `Closed {Place.Name}.`}
        elseif Kind == "Open" and Place.Open then
            local Object = Place.Open()
            Highlight(typeof(Object) == "Instance" and Object or nil, Place.Name)

            return {Text = Place.Done or `Opened {Place.Name}.`}
        end

        Highlight(Place.Target(), Place.Hint)
        return {Text = `{Place.Hint} I highlighted it for you.`, Actions = Place.Open and {OpenAction(Place)} or nil}
    end

    function Brain.Navigate(Kind: string, Slots)
        if Slots.Collection then
            return Brain.Windows(Kind)
        end

        local Owners = {}
        for _, Target: any in Slots.Targets do
            if Target.Type == "option" then
                Owners[Target.Value.Entry] = true
            end
        end

        local Targets = {}
        for _, Target: any in Slots.Targets do
            if not (Target.Type == "module" and Owners[Target.Value]) then
                table.insert(Targets, Target)
            end
        end

        if #Targets == 1 then
            local Target = Targets[1]
            if Target.Type == "module" then
                return Brain.NavigateModule(Kind, Target.Value, Slots)
            elseif Target.Type == "option" then
                local Entry, Option = Target.Value.Entry, Target.Value.Option
                LastTopic = Entry.Key
                Brain.LastOption = Target

                if Kind == "Close" then
                    return Brain.NavigateModule(Kind, Entry, Slots)
                end

                ShowModule(Entry, Option)
                return {Text = `Here is {Accent(Option.Name)} in {Accent(Entry.Name)}'s settings, I highlighted it for you.`, Actions = ModuleActions(Entry, Option)}
            end

            return Brain.NavigatePlace(Kind, Target.Value)
        end

        local Names: {string} = {}
        local Last: GuiObject?
        for _, Target: any in Targets do
            if Target.Type == "module" or Target.Type == "option" then
                local Entry = Target.Type == "module" and Target.Value or Target.Value.Entry
                LastTopic = Entry.Key

                if Kind == "Close" then
                    if not Entry.Legit then
                        Entry.Module:SetExpanded(false)
                    end
                else
                    Last = RevealModule(Entry, Kind == "Open")
                end
            elseif Kind == "Close" then
                if Target.Value.Close then
                    Target.Value.Close()
                end
            elseif Kind == "Open" and Target.Value.Open then
                Target.Value.Open()
            else
                Last = Target.Value.Target()
            end

            table.insert(Names, Accent(Brain.Name(Target)))
        end

        if Last and Kind ~= "Close" then
            Highlight(Last, "Here")
        end

        return {Text = `{Kind == "Close" and "Closed" or Kind == "Open" and "Opened" or "Showing"} {JoinNames(Names, 8)}.`}
    end

    function Brain.Switch(Intent: string, Slots)
        local Action: string = Intent == "TurnOn" and "On" or Intent == "TurnOff" and "Off" or "Toggle"
        if Slots.BulkAll then
            if Action == "Off" then
                return EnabledReply()
            end

            return {Text = "I will not turn on every module at once, that would wreck your game. Pick a tab, like \"turn on all render modules\"."}
        elseif Slots.Bulk then
            return Brain.Bulk(Slots.Bulk, Action)
        end

        local Lines, Undos = {}, {}
        local Last
        for _, Target: any in Slots.Targets do
            if Target.Type == "module" then
                local Entry = Target.Value
                local Module = Entry.Module
                local Wanted: boolean = Action == "On" or (Action == "Toggle" and not Module.Enabled)
                LastTopic = Entry.Key
                Last = Entry

                if Module.Enabled ~= Wanted then
                    Module:Toggle()
                    table.insert(Undos, function()
                        Module:Toggle()
                    end)
                    table.insert(Lines, `turned {Accent(Entry.Name)} {Wanted and "on" or "off"}`)
                else
                    table.insert(Lines, `{Accent(Entry.Name)} was already {Wanted and "on" or "off"}`)
                end
            else
                local Option, Owner = Brain.OptionOf(Target)
                if Option.Type ~= "Toggle" then
                    table.insert(Lines, `{Accent(Option.Name)} is not an on or off setting, tell me a value for it instead`)
                else
                    local Current: boolean = Option.Option and Option.Option.Enabled or false
                    local Wanted: boolean = Action == "On" or (Action == "Toggle" and not Current)
                    local Restore = Brain.Capture(Option)
                    local _, Result = ApplyValue(Option, Wanted and "on" or "off")

                    table.insert(Undos, Restore)
                    table.insert(Lines, `{Result}{Owner and ` in {Accent(Owner.Name)}` or ""}`)
                    if Owner then
                        LastTopic = Owner.Key
                    end
                end
            end
        end

        local Text: string = `{Brain.Capitalize(JoinNames(Lines, #Lines))}.`
        if #Undos > 0 then
            Brain.Remember(JoinNames(Lines, #Lines), function()
                for i: number = #Undos, 1, -1 do
                    Undos[i]()
                end
            end)
        end

        local Actions = Last and #Slots.Targets == 1 and ModuleActions(Last) or {}
        return {Text = Text, Actions = #Undos > 0 and Brain.WithUndo(Actions) or Actions}
    end

    function Brain.Bulk(CategoryName: string, Action: string)
        local Changing = {}
        for _, Entry: any in Index.Entries do
            local Inside: boolean = (CategoryName == "Legit" and Entry.Legit) or (not Entry.Legit and Entry.Category == CategoryName)
            local Wanted: boolean = Action == "On" or (Action == "Toggle" and not Entry.Module.Enabled)
            if Inside and Entry.Module.Enabled ~= Wanted then
                table.insert(Changing, Entry)
            end
        end

        local Where: string = CategoryName == "Legit" and "the Legit menu" or CategoryName
        if #Changing == 0 then
            return {Text = `Everything in {Where} is already {Action == "Off" and "off" or "on"}.`}
        end

        local Names: {string} = {}
        for _, Entry: any in Changing do
            table.insert(Names, Entry.Name)
        end

        local function Apply()
            for _, Entry: any in Changing do
                Entry.Module:Toggle()
            end

            Brain.Remember(`switched {#Changing} modules in {Where}`, function()
                for _, Entry: any in Changing do
                    Entry.Module:Toggle()
                end
            end)
        end

        if Action == "Off" then
            Apply()
            return {Text = `Turned off {#Changing} module{#Changing == 1 and "" or "s"} in {Where}: {JoinNames(Names, 12)}.`, Actions = Brain.WithUndo()}
        end

        return {
            Text = `That turns on {#Changing} module{#Changing == 1 and "" or "s"} in {Where} at once ({JoinNames(Names, 8)}). Running that many together usually breaks something. Still want it?`,
            Actions = {
                {
                    Text = "Turn them on",
                    Callback = function()
                        Apply()
                        Reply({Text = `Turned on {#Changing} modules in {Where}.`, Actions = Brain.WithUndo()})
                    end
                }
            }
        }
    end

    function Brain.SetValue(Slots)
        local Option, Owner = Brain.OptionOf(Slots.Target)
        local Restore = Brain.Capture(Option)
        local Success, Result = ApplyValue(Option, Slots.Value)

        if Owner then
            LastTopic = Owner.Key
        end

        local Actions = Owner and ModuleActions(Owner, Option) or PlaceActions(Slots.Target.Value) or {}
        if not Success then
            return {Text = Result, Actions = Actions}
        end

        Brain.LastOption = Slots.Target
        Brain.Remember(`changed {Accent(Option.Name)}`, Restore)
        return {Text = `Done, {Result}{Owner and ` in {Accent(Owner.Name)}` or ""}.`, Actions = Brain.WithUndo(Actions)}
    end

    function Brain.Bind(Slots)
        if Slots.Target == "GUI" then
            local Old: {string} = table.clone(vape.GUIBind.Keys)
            vape.GUIBind:SetBind({Slots.Key})
            Brain.Remember("changed the GUI key", function()
                vape.GUIBind:SetBind(Old)
            end)

            return {Text = `The GUI now opens with {Accent(Slots.Key)}.`, Actions = Brain.WithUndo()}
        end

        local Entry = Slots.Target
        local Module = Entry.Module
        LastTopic = Entry.Key

        if Entry.Legit or not Module.Bind then
            return {Text = `Legit mods do not take keybinds, click {Accent(Entry.Name)} in the Legit menu to turn it on or off.`}
        elseif IsMobile() then
            return {Text = `Keys do not work on mobile. Hold {Accent(Entry.Name)} in the GUI for a second, then tap where you want its button.`}
        end

        local Old: {string} = table.clone(Module.Bind.Keys)
        Module.Bind:SetBind({Slots.Key})
        Brain.Remember(`bound {Accent(Entry.Name)} to {Slots.Key}`, function()
            Module.Bind:SetBind(Old)
        end)

        local Shared: {string} = {}
        for _, Other: any in Index.Entries do
            local Keys: {string}? = Other ~= Entry and Other.Module.Bind and Other.Module.Bind.Keys
            if Keys and #Keys == 1 and Keys[1] == Slots.Key then
                table.insert(Shared, Other.Name)
            end
        end

        return {
            Text = `Bound {Accent(Entry.Name)} to {Accent(Slots.Key)}.{#Shared > 0 and ` Heads up, {JoinNames(Shared, 3)} {#Shared == 1 and "uses" or "use"} that key too.` or ""}`,
            Actions = Brain.WithUndo({
                {
                    Text = "Show me",
                    Callback = function()
                        ShowBind(Entry)
                    end
                }
            })
        }
    end

    function Brain.Unbind(Slots)
        local Entry = Slots.Entry
        local Module = Entry.Module
        LastTopic = Entry.Key

        if Entry.Legit or not Module.Bind then
            return {Text = `{Accent(Entry.Name)} is a legit mod, it has no bind to remove.`}
        elseif #Module.Bind.Keys == 0 then
            return {Text = `{Accent(Entry.Name)} has no bind.`}
        end

        local Old: {string} = table.clone(Module.Bind.Keys)
        Module.Bind:SetBind({})
        Brain.Remember(`removed {Accent(Entry.Name)}'s bind`, function()
            Module.Bind:SetBind(Old)
        end)

        return {Text = `Removed the bind from {Accent(Entry.Name)}, it was {Accent(table.concat(Old, " + "))}.`, Actions = Brain.WithUndo()}
    end

    function Brain.Profile(Intent: string, Slots)
        local Profiles = vape.Categories.Profiles
        local Name: string = Slots.Name

        if Intent == "ProfileCreate" then
            if Profiles:GetValue(Name) then
                return {Text = `You already have a profile called {Accent(Name)}.`}
            end

            Profiles:ChangeValue(Name)
            Brain.Remember(`created the profile {Accent(Name)}`, function()
                if Profiles:GetValue(Name) then
                    Profiles:ChangeValue(Name)
                end
            end)

            return {
                Text = `Created the profile {Accent(Name)}. Switch to it whenever you want to start setting it up.`,
                Actions = Brain.WithUndo({
                    {
                        Text = "Switch to it",
                        Callback = function()
                            Reply({Text = `Switching to {Accent(Name)}...`})
                            SwitchProfile(Name)
                        end
                    }
                })
            }
        elseif Intent == "ProfileSwitch" then
            if Name == vape.Profile then
                return {Text = `You are already on {Accent(Name)}.`}
            end

            SwitchProfile(Name)
            return {Text = `Switching to {Accent(Name)}...`}
        end

        if Name == "default" then
            return {Text = "The default profile cannot be deleted."}
        elseif Name == vape.Profile then
            return {Text = `You are on {Accent(Name)} right now, switch to another profile first.`}
        end

        return {
            Text = `Delete the profile {Accent(Name)}? Its saved settings for this game will be gone for good.`,
            Actions = {
                {
                    Text = "Delete it",
                    Callback = function()
                        if Profiles:GetValue(Name) then
                            Profiles:ChangeValue(Name)
                        end

                        Reply({Text = `Deleted {Accent(Name)}.`})
                    end
                }
            }
        }
    end

    function Brain.Preset(Slots)
        local Wanted: {[any]: boolean} = {}
        local Entries = {}
        for _, Name: string in Brain.Essentials[CurrentGame() or ""] or Brain.Essentials.Universal do
            local Entry = Index.Keys[Compact(Name)]
            if Entry and not Entry.Legit then
                Wanted[Entry] = true
                table.insert(Entries, Entry)
            end
        end

        if #Entries == 0 then
            return {Text = "I do not have a set of core modules for this game yet."}
        end

        local Names: {string} = {}
        for _, Entry: any in Entries do
            table.insert(Names, Entry.Name)
        end

        local Listed: string = Accent(JoinNames(Names, #Names))
        if not Slots.New then
            local Changed = {}
            for _, Entry: any in Entries do
                if not Entry.Module.Enabled then
                    Entry.Module:Toggle()
                    table.insert(Changed, Entry)
                end
            end

            if #Changed > 0 then
                Brain.Remember("turned on the core modules", function()
                    for _, Entry: any in Changed do
                        if Entry.Module.Enabled then
                            Entry.Module:Toggle()
                        end
                    end
                end)
            end

            return {Text = `Turned on {#Changed} core module{#Changed == 1 and "" or "s"}, so these are all on now: {Listed}. Speed, Fly and Nuker stay off, they are better on a bind.`, Actions = #Changed > 0 and Brain.WithUndo() or nil}
        end

        local Profiles = vape.Categories.Profiles
        local Base: string = Slots.Name or "essentials"
        local Name: string = Base
        local Suffix: number = 2
        while Profiles:GetValue(Name) do
            Name = `{Base}{Suffix}`
            Suffix += 1
        end

        local Previous: string = vape.Profile
        Profiles:ChangeValue(Name)
        task.delay(0.2, function()
            if vape.ThreadFix then
                setthreadidentity(8)
            end

            vape:Save(Name)
            vape:Load(true)
            Profiles:ChangeValue()

            for _, Entry: any in Index.Entries do
                if not Entry.Legit and Entry.Module.Enabled ~= (Wanted[Entry] == true) then
                    Entry.Module:Toggle()
                end
            end

            vape:Save()
            Reply({
                Text = `{Accent(Name)} is ready and you are on it. Only the core modules are on: {Listed}. Speed, Fly and Nuker are off, they are better on a bind.`,
                Actions = {
                    {
                        Text = `Back to {Previous}`,
                        Callback = function()
                            Reply({Text = `Switching back to {Accent(Previous)}...`})
                            SwitchProfile(Previous)
                        end
                    }
                }
            })
        end)

        return {Text = `Making the profile {Accent(Name)} and switching to it...`}
    end

    function Brain.List(Intent: string, Slots)
        local Category = vape.Categories[Slots.List]
        local Name: string = Slots.Player.Name

        if Intent == "ListRemove" then
            for _, Entry: string in Category.List do
                if Entry:lower() == Name:lower() then
                    Category:ChangeValue(Entry)
                    Brain.Remember(`removed {Entry} from {Slots.List}`, function()
                        if not table.find(Category.List, Entry) then
                            Category:ChangeValue(Entry)
                        end
                    end)

                    return {Text = `Removed {Accent(Entry)} from your {Slots.List} list.`, Actions = Brain.WithUndo(PlaceActions(GetPlace(Slots.List:lower())))}
                end
            end

            return {Text = `{Escape(Name)} is not on your {Slots.List} list.`}
        end

        if table.find(Category.ListEnabled, Name) then
            return {Text = `{Accent(Name)} is already on your {Slots.List} list.`, Actions = PlaceActions(GetPlace(Slots.List:lower()))}
        elseif table.find(Category.List, Name) then
            table.insert(Category.ListEnabled, Name)
            Category:ChangeValue()
        else
            Category:ChangeValue(Name)
        end

        Brain.Remember(`added {Name} to {Slots.List}`, function()
            if table.find(Category.List, Name) then
                Category:ChangeValue(Name)
            end
        end)

        local Notes: string = Slots.Player.Found and "" or " They are not in this server, so make sure that is their exact username."
        local UseFriends = Category.Options["Use friends"]
        if UseFriends and not UseFriends.Enabled then
            Notes = `{Notes} {Accent("Use friends")} is off in its gear, so modules still treat them like anyone else.`
        end

        return {Text = `Added {Accent(Name)} to your {Slots.List} list.{Notes}`, Actions = Brain.WithUndo(PlaceActions(GetPlace(Slots.List:lower())))}
    end

    function Brain.Favorite(Slots, Tokens)
        local Entry = Slots.Entry
        local Module = Entry.Module
        local Wanted: boolean = not Brain.HasWord(Tokens, {"unfavorite", "unfavourite", "unstar", "unfav", "remove"})
        LastTopic = Entry.Key

        if Module.Favorited == Wanted then
            return {Text = `{Accent(Entry.Name)} is {Wanted and "already" or "not"} in your favorites.`}
        end

        Module:SetFavorite(Wanted)
        Brain.Remember(`{Wanted and "favorited" or "unfavorited"} {Accent(Entry.Name)}`, function()
            Module:SetFavorite(not Wanted)
        end)

        return {Text = `{Wanted and "Added" or "Removed"} {Accent(Entry.Name)} {Wanted and "to" or "from"} your favorites.`, Actions = Brain.WithUndo(PlaceActions(GetPlace("favorites")))}
    end

    function Brain.Hide(Slots, Tokens)
        local Entry = Slots.Entry
        local Module = Entry.Module
        local Visible: boolean = Brain.HasWord(Tokens, {"unhide", "unhidden", "visible", "back", "again"})
        LastTopic = Entry.Key

        if Entry.Legit then
            return {Text = "Legit mods cannot be hidden, but the search box in the Legit menu filters them."}
        elseif Module.Visible == Visible then
            return {Text = `{Accent(Entry.Name)} is already {Visible and "shown" or "hidden"}.`}
        end

        Module:SetVisible(Visible, true)
        Brain.Remember(`{Visible and "unhid" or "hid"} {Accent(Entry.Name)}`, function()
            Module:SetVisible(not Visible, true)
        end)

        return {Text = `{Accent(Entry.Name)} is {Visible and "back in" or "hidden from"} the {Entry.Category} window. {Visible and "" or "It still works, it is just out of the list."}`, Actions = Brain.WithUndo()}
    end

    function Brain.WindowsReply()
        local Lines: {string} = {}
        for _, Name: string in Brain.WindowOrder do
            local Category = vape.Categories[Name]
            if Category and Category.Type == "Category" then
                local Count: number = 0
                for _, Entry: any in Index.Entries do
                    if not Entry.Legit and Entry.Category == Name then
                        Count += 1
                    end
                end

                table.insert(Lines, `{Accent(Name)} ({Count})`)
            end
        end

        return {
            Text = `There are {#Lines} module tabs: {table.concat(Lines, ", ")}. Friends, Profiles and Targets have tabs of their own, and legit mods live in the Legit menu.`,
            Actions = {
                {
                    Text = "Open all tabs",
                    Callback = function()
                        Send("Open all tabs")
                    end
                }
            }
        }
    end

    function Brain.Changes(Intent: string): boolean
        return not Brain.Knowledge[Intent] and Intent ~= "Open" and Intent ~= "Close" and Intent ~= "Locate"
    end

    function Brain.AskFor(Intent: string, Unknown: {string}?)
        local Questions = {
            Bind = "Which module, and which key? Say it like \"bind Killaura to R\".",
            Close = "What should I close? I can close a tab, all of them, the Legit menu, the settings or the overlays menu.",
            Favorite = "Which module should I favorite?",
            Hide = "Which module should I hide?",
            ListAdd = "Who should I add, and to Friends or Targets? Say it like \"add Builderman to friends\".",
            ListRemove = "Who should I remove, and from Friends or Targets?",
            Locate = "What should I point out for you?",
            Open = "What should I open? I can open a tab like Combat, all of them at once, the Legit menu, the settings, Profiles, or any module.",
            ProfileCreate = "What should the new profile be called? Say it like \"create profile tryhard\".",
            ProfileDelete = `Which profile? You have {ProfileNames()}.`,
            ProfileSwitch = `Which profile? You have {ProfileNames()}.`,
            SetValue = "What should I change, and to what? Say it like \"set Killaura attack range to 15\".",
            Toggle = "What should I toggle?",
            TurnOff = "What should I turn off?",
            TurnOn = "What should I turn on?",
            Unbind = "Which module should I unbind?"
        }

        local Chips: {string} = Intent == "Open" and {"Open all tabs", "Open the Legit menu", "Open the settings", "Open Profiles"} or Intent == "Close" and {"Close all tabs", "Close the settings"} or {}
        local Actions = {}
        for _, Chip: string in Chips do
            table.insert(Actions, {
                Text = Chip,
                Callback = function()
                    Send(Chip)
                end
            })
        end

        local Prefix: string = Unknown and #Unknown > 0 and `I do not know what "{Escape(table.concat(Unknown, " "))}" is. ` or ""
        return {Text = `{Prefix}{Questions[Intent] or "Could you say that another way?"}`, Actions = Actions}
    end

    function Brain.Clarify(Candidates)
        Brain.Pending = Candidates
        local Actions = {}
        for _, Candidate: any in Candidates do
            local Text: string = Brain.Canonical(Candidate)
            table.insert(Actions, {
                Text = Text,
                Callback = function()
                    Brain.Learn(Candidate)
                    AddMessage(Text, true)
                    Reply(Brain.Execute(Candidate))
                end
            })
        end

        return {Text = "I can read that a couple of ways. Which one did you mean?", Actions = Actions}
    end

    function Brain.WordSet(Question: string): {[string]: boolean}
        local Words: {[string]: boolean} = {}
        for Word: string in Brain.Unslang(Question):lower():gsub("'", ""):gmatch("%w+") do
            Words[Word] = true
        end

        return Words
    end

    function Brain.Pick(List: {string}): string
        local Choice: number = math.random(1, #List)
        if #List > 1 and Brain.Picked[List] == Choice then
            Choice = Choice % #List + 1
        end

        Brain.Picked[List] = Choice
        return List[Choice]
    end

    function Brain.Chips(Questions: {string}?)
        if not Questions then
            return nil
        end

        local Actions = {}
        for _, Question: string in Questions do
            table.insert(Actions, {
                Text = Question,
                Callback = function()
                    Send(Question)
                end
            })
        end

        return Actions
    end

    function Brain.Say(Kind: string, Question: string?)
        local Words: {[string]: boolean} = Brain.WordSet(Question or "")
        for _, Group: any in Brain.Talk[Kind] do
            local Matched: boolean = not Group.Words and not Group.Test
            for Word: string in Group.Words or {} do
                Matched = Matched or Words[Word] == true
            end

            if Matched or (Group.Test and Group.Test(Words)) then
                local Result = Group.Reply and Group.Reply(Words)
                if Result then
                    return Result
                elseif Group.Replies then
                    local Chips = type(Group.Chips) == "function" and Group.Chips() or Group.Chips
                    return {Text = Brain.Pick(Group.Replies), Actions = Group.Suggest and Suggestions() or Brain.Chips(Chips)}
                end
            end
        end

        return {Text = "Ask me anything about CatVape.", Actions = Suggestions()}
    end

    function Brain.OffTopic(Decision, Question: string): boolean
        local Best = Decision.Best
        local Asking: boolean = Brain.IsQuestion(Decision.Tokens, Question) or (Best ~= nil and (Best.Intent == "Help" or Best.Intent == "HowTo" or Best.Intent == "Recommend"))
        if not Asking or (Best and Decision.Kind == "Execute" and not Brain.Knowledge[Best.Intent]) then
            return false
        elseif Best and Brain.Social[Best.Intent] and Best.Intent ~= "Help" and Brain.Addressing(Decision.Tokens) then
            return false
        end

        local Found: boolean = false
        for _, Token: any in Decision.Tokens do
            if Index.Keys[Token.Word] then
                return false
            end

            for _, Group: any in Brain.Talk.Offtopic do
                Found = Found or (Group.Words ~= nil and Group.Words[Token.Word] == true)
            end
        end

        return Found
    end

    function Brain.Chatter(Question: string)
        local Decision = Brain.Understand(Question)
        for i: number, Candidate: any in {Decision.Best, Decision.Runner} do
            if Brain.Social[Candidate.Intent] and (Candidate.Probability >= Brain.ChatFloor or (i == 1 and Candidate.Confidence >= Brain.ChatLead)) then
                return Brain.Runners[Candidate.Intent](Candidate.Slots, Question, Candidate)
            end
        end

        local Content: boolean = false
        for _, Token: any in Decision.Tokens or {} do
            Content = Content or not Brain.QuestionWords[Token.Word]
        end

        local Asking: boolean = Content and Brain.IsQuestion(Decision.Tokens, Question)
        return Brain.Runners[Asking and "Offtopic" or "Unclear"](nil, Question)
    end

    function Brain.Arithmetic(Expression: string): number?
        local Position: number = 1
        local Sum: () -> number?

        local function Peek(): string
            Position = Expression:match("^%s*()", Position)
            return Expression:sub(Position, Position)
        end

        local function Atom(): number?
            local Symbol: string = Peek()
            if Symbol == "(" then
                Position += 1
                local Value: number? = Sum()
                if not Value or Peek() ~= ")" then
                    return nil
                end

                Position += 1
                return Value
            elseif Symbol == "-" or Symbol == "@" then
                Position += 1
                local Value: number? = Atom()
                return Value and (Symbol == "-" and -Value or math.sqrt(Value)) or nil
            end

            local Number: string? = Expression:match("^%d*%.?%d+", Position)
            if not Number then
                return nil
            end

            Position += #Number
            return tonumber(Number)
        end

        local function Power(): number?
            local Base: number? = Atom()
            if Base and Peek() == "^" then
                Position += 1
                local Exponent: number? = Power()
                return Exponent and Base ^ Exponent or nil
            end

            return Base
        end

        local function Product(): number?
            local Value: number? = Power()
            while Value and (Peek() == "*" or Peek() == "/" or Peek() == "%") do
                local Operator: string = Peek()
                Position += 1
                local Next: number? = Power()
                if not Next then
                    return nil
                end

                Value = Operator == "*" and Value * Next or Operator == "/" and Value / Next or Value % Next
            end

            return Value
        end

        Sum = function(): number?
            local Value: number? = Product()
            while Value and (Peek() == "+" or Peek() == "-") do
                local Operator: string = Peek()
                Position += 1
                local Next: number? = Product()
                if not Next then
                    return nil
                end

                Value = Operator == "+" and Value + Next or Value - Next
            end

            return Value
        end

        local Value: number? = Sum()
        return Peek() == "" and Value or nil
    end

    function Brain.Calculate(Text: string): (number?, string?)
        local Expression: string = Text:lower():gsub("[',?!=]", " "):gsub("(%d)%s*x%s*(%d)", "%1 * %2"):gsub("([%+%-%*/%%%^%(%)])", " %1 "):gsub("%s+", " ")
        Expression = ` {Expression} `
        for _, Pair: {string} in Brain.MathWords do
            local Pattern: string = Pair[1]:gsub("%p", "%%%0")
            Expression = Expression:gsub(`%s{Pattern}%s`, function()
                return ` {Pair[2]} `
            end)
        end

        local Parts: {string} = {}
        for Word: string in Expression:gmatch("%S+") do
            if not Brain.MathFiller[Word] then
                table.insert(Parts, Word)
            end
        end

        Expression = table.concat(Parts, " ")
        if not Expression:match("^[%d%.%s%+%-%*/%%%^%(%)@]+$") or not (Expression:find("%d[%s%)]*[%+%-%*/%%%^]") or Expression:find("@")) then
            return nil
        end

        local Value: number? = Brain.Arithmetic(Expression)
        if not Value then
            return nil
        end

        local Shown: string = Expression:gsub("@%s*", "sqrt ")
        return Value, Shown
    end

    Brain.Runners = {
        Bind = function(Slots)
            return Brain.Bind(Slots)
        end,
        BuildProfile = function(Slots)
            return Brain.BuildProfile(Slots)
        end,
        BindInfo = function(Slots)
            LastTopic = Slots.Entry.Key
            return BindReply(Slots.Entry)
        end,
        Status = function(Slots)
            LastTopic = Slots.Entry.Key
            return {Text = `{Accent(Slots.Entry.Name)} is {Slots.Entry.Module.Enabled and "on" or "off"} right now.`, Actions = ModuleActions(Slots.Entry)}
        end,
        PlaceInfo = function(Slots)
            local Place = Slots.Place
            for _, Guide: any in Guides do
                if Guide.Place == Place.Id then
                    return {Text = Guide.Answer(), Actions = PlaceActions(Place)}
                end
            end

            if Place.Category then
                return CategoryReply(Place.Category)
            end

            return {Text = `{Brain.Capitalize(Place.Name)}: {Place.Hint}`, Actions = PlaceActions(Place)}
        end,
        Calculate = function(_, Question: string)
            local Value, Shown = Brain.Calculate(Question)
            if not Value then
                return Brain.Say("Unclear", Question)
            elseif Value ~= Value or math.abs(Value) == math.huge then
                return {Text = "That one has no answer, you can't divide by zero."}
            end

            local Rounded: number = math.round(Value * 1e6) / 1e6
            local Result: string = Rounded == math.floor(Rounded) and math.abs(Rounded) < 1e15 and string.format("%d", Rounded) or tostring(Rounded)
            return {Text = `{Shown} = {Accent(Result)}`}
        end,
        Close = function(Slots)
            return Brain.Navigate("Close", Slots)
        end,
        Compare = function(Slots)
            return Brain.CompareReply(Slots.Modules)
        end,
        Configure = function(Slots)
            return Brain.ConfigureReply(Slots.Entry, Slots.Style, Slots)
        end,
        Confirm = function(_, Question: string)
            local Pending = Brain.Pending
            if not Pending then
                return {Text = "Okay!"}
            end

            local Lower: string = Question:lower()
            local Choice = (Lower:find("second") or Lower:find("2")) and Pending[2] or Pending[1]
            Brain.Learn(Choice or Pending[1])
            return Brain.Execute(Choice or Pending[1])
        end,
        Count = function()
            return CountReply()
        end,
        Deny = function()
            Brain.Pending = nil
            return {Text = "Okay, never mind."}
        end,
        Describe = function(Slots, _, Candidate)
            LastTopic = Slots.Entry.Key
            Brain.Depth = {Key = Slots.Entry.Key, Level = 1}
            return DescribeReply(Slots.Entry, Candidate.Tokens and Brain.QueryOf(Candidate.Tokens))
        end,
        Effect = function(Slots, _, Candidate)
            return Brain.EffectReply(Slots.Entry, Slots.Option, Candidate.Tokens)
        end,
        Error = function(_, Question: string)
            return Brain.ErrorReply(Question)
        end,
        Favorite = function(Slots, _, Candidate)
            return Brain.Favorite(Slots, Candidate.Tokens)
        end,
        Hide = function(Slots, _, Candidate)
            return Brain.Hide(Slots, Candidate.Tokens)
        end,
        Interaction = function(Slots)
            return Brain.InteractionReply(Slots.Modules)
        end,
        ListAdd = function(Slots)
            return Brain.List("ListAdd", Slots)
        end,
        ListCategory = function(Slots)
            local Result = CategoryReply(Slots.Name)
            local Place = GetPlace(Slots.Name:lower()) or GetPlace("legit")
            Result.Actions = Place and {OpenAction(Place)} or nil
            return Result
        end,
        ListEnabled = function()
            return EnabledReply()
        end,
        ListRemove = function(Slots)
            return Brain.List("ListRemove", Slots)
        end,
        ListWindows = function()
            return Brain.WindowsReply()
        end,
        Locate = function(Slots)
            return Brain.Navigate("Locate", Slots)
        end,
        More = function(Slots)
            local Entry, Option = Slots.Entry, Slots.Option
            if not Entry then
                Entry, Option = Brain.Topic()
            end

            return Brain.MoreReply(Entry, Option)
        end,
        News = function(Slots)
            if Slots.Entry then
                LastTopic = Slots.Entry.Key
            end

            return NewsReply(Slots.Entry)
        end,
        Open = function(Slots)
            return Brain.Navigate("Open", Slots)
        end,
        OptionInfo = function(Slots)
            LastTopic = Slots.Entry.Key
            Brain.LastOption = {Type = "option", Value = {Entry = Slots.Entry, Option = Slots.Option}}
            Brain.Depth = {Key = Slots.Entry.Key, Level = 1, Option = Slots.Option}
            return OptionReply(Slots.Entry, {{Matched = 1, Option = Slots.Option, Order = 1, Score = 1}})
        end,
        Performance = function(Slots)
            return Brain.PerformanceReply(Slots.Tokens)
        end,
        Preset = function(Slots)
            return Brain.Preset(Slots)
        end,
        ProfileCreate = function(Slots)
            return Brain.Profile("ProfileCreate", Slots)
        end,
        ProfileDelete = function(Slots)
            return Brain.Profile("ProfileDelete", Slots)
        end,
        ProfileList = function()
            return {Text = `You have {ProfileNames()}, and you are on {Accent(vape.Profile)}.`, Actions = PlaceActions(GetPlace("profiles"))}
        end,
        ProfileSwitch = function(Slots)
            return Brain.Profile("ProfileSwitch", Slots)
        end,
        Recommend = function(_, Question: string, Candidate)
            return Brain.RecommendReply(Candidate.Tokens, Question)
        end,
        SetValue = function(Slots)
            return Brain.SetValue(Slots)
        end,
        Settings = function(Slots)
            LastTopic = Slots.Entry.Key
            Brain.Depth = {Key = Slots.Entry.Key, Level = 2}
            return SettingsReply(Slots.Entry)
        end,
        Simpler = function(Slots)
            local Entry, Option = Slots.Entry, Slots.Option
            if not Entry then
                Entry, Option = Brain.Topic()
            end

            if not Entry then
                return {Text = "Simpler than what? Ask me about a module first, like \"what does Killaura do\".", Actions = Suggestions()}
            end

            LastTopic = Entry.Key
            return Brain.SimpleReply(Entry, Option or (Brain.Depth.Key == Entry.Key and Brain.Depth.Option or nil))
        end,
        Symptom = function(Slots, Question: string)
            local Symptom = Slots.Symptom or Brain.SymptomOf(Slots.Tokens, true)
            return Symptom and Brain.SymptomReply(Symptom, Slots.Tokens, Question) or Brain.CulpritReply(Slots.Tokens)
        end,
        Toggle = function(Slots)
            return Brain.Switch("Toggle", Slots)
        end,
        Tradeoff = function(Slots, _, Candidate)
            return Brain.TradeoffReply(Slots.Entry, Slots.Option, Candidate.Tokens)
        end,
        Trouble = function(Slots, _, Candidate)
            LastTopic = Slots.Entry.Key
            return TroubleReply(Slots.Entry, Candidate.Tokens and Brain.QueryOf(Candidate.Tokens), Candidate.Tokens)
        end,
        TurnOff = function(Slots)
            return Brain.Switch("TurnOff", Slots)
        end,
        TurnOn = function(Slots)
            return Brain.Switch("TurnOn", Slots)
        end,
        Unbind = function(Slots)
            return Brain.Unbind(Slots)
        end,
        Undo = function()
            return Brain.Undo()
        end,
        Using = function(Slots)
            return Brain.UsingReply(Slots.Modules)
        end
    }

    for Kind: string in Brain.Talk do
        Brain.Runners[Kind] = Brain.Runners[Kind] or function(_, Question: string)
            return Brain.Say(Kind, Question)
        end
    end

    function Brain.Execute(Candidate, Question: string?)
        local Slots = Candidate.Slots
        Brain.Pending = nil
        Brain.LastIntent = Candidate.Intent
        Brain.Note(Slots)

        if Slots.Targets and #Slots.Targets > 0 then
            Brain.LastTargets = Slots.Targets
        elseif Slots.Entry then
            Brain.LastTargets = {{Type = "module", Value = Slots.Entry}}
        elseif type(Slots.Target) == "table" and Slots.Target.Type then
            Brain.LastTargets = {Slots.Target}
        elseif type(Slots.Target) == "table" and Slots.Target.Module then
            Brain.LastTargets = {{Type = "module", Value = Slots.Target}}
        end

        local Runner = Brain.Runners[Candidate.Intent]
        if not Runner then
            return Answer(Question or Brain.Canonical(Candidate))
        end

        return Runner(Candidate.Slots, Question or Brain.Canonical(Candidate), Candidate)
    end

    function Brain.IsFollowUp(Tokens): boolean
        local First: string = Tokens[1].Word
        local Second: string = Tokens[2] and Tokens[2].Word or ""
        return First == "and" or First == "also" or First == "plus" or First == "now" or First == "then" or Tokens[#Tokens].Word == "too"
            or ((First == "what" or First == "how") and Second == "about") or (First == "same" and (Second == "for" or Second == "with"))
    end

    function Brain.Ready()
        EnsureIndex()
        Brain.LoadDictionary()
        if not Places then
            BuildPlaces()
        end

        if not Brain.Model then
            Brain.Train()
        end
    end

    function Brain.QueryOf(Tokens): ({[string]: number}, {any})
        local Words: {string} = {}
        for _, Token: any in Tokens do
            if Token.Kind == "word" then
                table.insert(Words, Token.Word)
            end
        end

        local Loose: {string} = {}
        local Joined: {[number]: boolean} = {}
        for Size: number = 3, 2, -1 do
            for i: number = 1, #Words - Size + 1 do
                if Index.Keys[table.concat(Words, "", i, i + Size - 1)] then
                    for k: number = i, i + Size - 1 do
                        Joined[k] = true
                    end
                end
            end
        end

        for i: number, Word: string in Words do
            if not Joined[i] then
                table.insert(Loose, Word)
            end
        end

        local Query: {[string]: number} = BuildQuery(table.concat(Loose, " "))
        for i: number = 1, #Words - 2 do
            if Words[i] == "how" and Words[i + 1] == "much" and Brain.PriceWords[Words[i + 2]] then
                Query[Stem("price")] = 1
            end
        end

        return Query, FindMentions(Words)
    end

    function Brain.IsQuestion(Tokens, Question: string): boolean
        local First: string = Tokens[1].Word
        local Second: string = Tokens[2] and Tokens[2].Word or ""
        if Brain.QuestionWords[First] then
            return not Brain.Commanding[Second]
        end

        return Question:find("?", 1, true) ~= nil or Brain.HasWord(Tokens, {"why", "whys", "how"})
    end

    function Brain.Addressing(Tokens): boolean
        return Brain.HasWord(Tokens, {"you", "your", "yours", "yourself"})
    end

    function Brain.Inquiring(Tokens): boolean
        for _, Token: any in Tokens do
            if Brain.QuestionWords[Token.Word] or Brain.Requests[Token.Word] then
                return true
            end
        end

        return false
    end

    function Brain.IsAsking(Tokens, Question: string): boolean
        if Brain.IsQuestion(Tokens, Question) then
            return true
        end

        for i: number, Token: any in Tokens do
            local Next: string = Tokens[i + 1] and Tokens[i + 1].Word or ""
            if Brain.Complaints[Token.Word] then
                return true
            elseif (Token.Word == "keep" or Token.Word == "keeps") and Next:sub(-3) == "ing" then
                return true
            elseif Token.Word == "means" or Token.Word == "mean" or Token.Word == "should" or (i == 1 and Token.Word == "if") then
                return true
            elseif Brain.Auxiliary[Token.Word] and Brain.Subjects[Next] then
                return true
            elseif Token.Word == "only" and (Next == "works" or Next == "work" or Next == "working") then
                return true
            end
        end

        return false
    end

    function Brain.Recall(Decision, Question: string)
        local Best = Decision.Best
        local Intent: string? = Best and Best.Intent
        local Tokens = Decision.Tokens
        if Decision.Kind == "Empty" then
            return nil
        end

        local Asking: boolean = Brain.IsAsking(Tokens, Question)
        local Moving: boolean = Intent == "Open" or Intent == "Close" or Intent == "Locate"
        local Social: boolean = Intent ~= nil and Brain.Social[Intent] == true
        local Addressed: boolean = Social and Brain.Addressing(Tokens)
        local Casual: boolean = Social and not Brain.IsQuestion(Tokens, Question)
        if not Asking and ((Intent and (Brain.Changes(Intent) or Moving)) or (Decision.Wanted and Decision.WantedProbability >= 0.5)) then
            return nil
        end

        local Covered: {[string]: boolean} = {}
        if Decision.Kind == "Execute" then
            for _, Entity: any in Best.Reading.Entities do
                if Entity.Type ~= "module" then
                    for k: number = Entity.I, Entity.J do
                        local Term: string = Stem(Tokens[k].Word)
                        Covered[Term] = true

                        for _, Synonym: string in Synonyms[Term] or {} do
                            Covered[Synonym] = true
                        end
                    end
                end
            end
        end

        local Query, Mentions = Brain.QueryOf(Tokens)
        local Fact, Score, Topic, Count = FindFact(Query, Mentions, Covered)
        local Strong: boolean = Decision.Kind == "Execute" and Best ~= nil and Best.Probability >= 0.6 and Brain.Informative[Best.Intent] == true
        for _, Entry: any in Mentions do
            Strong = Strong or not Brain.English(Entry.Key)
        end

        for _, Entry: any in Strong and Fact and Mentions or {} do
            if not table.find(Fact.Modules or {}, Entry.Name) then
                return nil
            end
        end

        if not Fact or Topic <= 0 or ((Addressed or Casual) and Best.Probability >= Brain.SocialSure) then
            return nil
        elseif Casual then
            return Topic >= Brain.FactTopic and Score >= Brain.FactOver and Count >= 2 and Fact or nil
        elseif Decision.Kind == "Execute" and (Addressed or not Social) then
            if Brain.Changes(Intent) then
                return Score >= Brain.FactFloor and Fact or nil
            elseif Moving then
                Fact, Score, Topic, Count = FindFact(Query, Mentions)
                return Topic >= Brain.FactTopic and Score >= Brain.FactOver and Count >= 2 and Fact or nil
            end

            local Novel: boolean = false
            for _, Token: any in Tokens do
                Novel = Novel or (Token.Kind == "word" and not Brain.Templated[Token.Word] and not Covered[Stem(Token.Word)] and Fact.Terms[Stem(Token.Word)] ~= nil)
            end

            Novel = Novel and not Addressed

            return Topic >= Brain.FactTopic and ((Score >= Brain.FactOver and Count >= 2) or (Novel and Topic >= 2.5)) and Fact or nil
        end

        local Guide, GuideScore = FindGuide(Query)
        if Guide and GuideScore > Score then
            return nil
        end

        return Score >= Brain.FactFloor and Fact or nil
    end

    function Brain.FactReply(Fact)
        local Actions = {}
        for _, Name: string in Fact.Modules or {} do
            local Entry = Index.Keys[Compact(Name)]
            if Entry and #Actions < 2 and Fact.Text:find(Name, 1, true) then
                LastTopic = #Actions == 0 and Entry.Key or LastTopic
                table.insert(Actions, {
                    Text = Entry.Name,
                    Callback = function()
                        Send(`What does {Entry.Name} do?`)
                    end
                })
            end
        end

        local Success, Live = pcall(Fact.Live or function() end)
        local Text: string = FactText(Fact)
        return {Text = Success and Live and `{Text} {Live}` or Text, Actions = #Actions > 0 and Actions or nil}
    end

    function Brain.Satisfies(Lookup, Words: {[string]: boolean}, Tokens): boolean
        for _, Word: string in Lookup.Skip do
            if Words[Word] then
                return false
            end
        end

        for _, Group: {string} in Lookup.Needs or {} do
            local Found: boolean = false
            for _, Word: string in Group do
                if Word == "@player" then
                    for _, Token: any in Tokens do
                        local Name: string? = #Token.Word >= 3 and not Brain.Vocabulary().Set[Token.Word] and Brain.MatchPlayer(Token.Word) or nil
                        Found = Found or (Name ~= nil and Name ~= Players.LocalPlayer.Name)
                    end
                else
                    Found = Found or Words[Word] == true
                end
            end

            if not Found then
                return false
            end
        end

        return true
    end

    function Brain.LookupFor(Decision, Question: string)
        local Best = Decision.Best
        local Intent: string? = Best and Best.Intent
        local Tokens = Decision.Tokens
        if Decision.Kind == "Empty" or not Tokens then
            return nil
        end

        local Asking: boolean = Brain.IsAsking(Tokens, Question)
        local Moving: boolean = Intent == "Open" or Intent == "Close" or Intent == "Locate"
        if not Asking and ((Intent and (Brain.Changes(Intent) or Moving)) or (Decision.Wanted and Decision.WantedProbability >= 0.5)) then
            return nil
        end

        local Words: {[string]: boolean} = {}
        local Mentioned: boolean = false
        for _, Token: any in Tokens do
            Words[Token.Word] = true
            Mentioned = Mentioned or Index.Keys[Token.Word] ~= nil
        end

        local Query = Brain.QueryOf(Tokens)
        local Game: string? = CurrentGame()
        local Chosen, ChosenCount = nil, 0
        for _, Lookup: any in Lookups do
            if (not Lookup.Game or Lookup.Game == Game) and not (Lookup.SkipModules and Mentioned) and Brain.Satisfies(Lookup, Words, Tokens) then
                local Count: number = 0
                for Term: string in Lookup.Terms do
                    if Query[Term] == 1 then
                        Count += 1
                    end
                end

                if Count > ChosenCount then
                    Chosen, ChosenCount = Lookup, Count
                end
            end
        end

        return Chosen
    end

    function Brain.RunLookup(Lookup, Tokens)
        local Success, Text = pcall(Lookup.Run, Tokens)
        if not Success or type(Text) ~= "string" then
            warn(`[Uranium] Assistant could not read {Lookup.Id} : {Text}`)
            return {Text = "I could not read that from the game right now."}
        end

        return {Text = Text}
    end

    function Brain.Understand(Question: string)
        Brain.Ready()

        local Raw: string = StripPolite(Brain.Ungreet(Brain.Unpreface(Brain.Unslang(Question))))
        local Tokens = Brain.Tokenize(Raw)
        if #Tokens == 0 then
            return {Kind = "Empty"}
        elseif Brain.ErrorOf(Question) then
            return {Kind = "Error", Tokens = Tokens}
        elseif Brain.Calculate(Raw) then
            return {Kind = "Calculate", Tokens = Tokens}
        end

        Brain.Correct(Tokens)
        local Absent = Brain.Absent(Tokens)
        if Absent then
            return {Kind = "Elsewhere", Tokens = Tokens, Absent = Absent}
        end

        local FollowUp: boolean = Brain.IsFollowUp(Tokens)
        local Candidates = {}
        local Missing: {[string]: number} = {}

        for _, Reading: any in Brain.Readings(Brain.Extract(Tokens)) do
            local Distribution = Brain.Classify(Brain.Prepare(Brain.Delex(Tokens, Reading)))
            local Valid = {}
            local Mass: number = 0

            for Intent: string, Probability: number in Distribution do
                if Probability >= 0.02 then
                    local Filler = Brain.FillerFor[Intent]
                    local Slots, Used
                    if Filler then
                        Slots, Used = Filler(Reading, Tokens, Raw)
                    else
                        Slots, Used = {}, {}
                    end

                    if Slots then
                        Mass += Probability
                        table.insert(Valid, {
                            Intent = Intent,
                            Probability = Probability,
                            Reading = Reading,
                            Score = Brain.Score(Intent, Probability, Reading, Slots, Used or {}, FollowUp),
                            Slots = Slots,
                            Tokens = Tokens
                        })
                    elseif not Brain.Knowledge[Intent] and Intent ~= "BuildProfile" then
                        Missing[Intent] = math.max(Missing[Intent] or 0, Probability)
                    end
                end
            end

            for _, Candidate: any in Valid do
                Candidate.Confidence = Candidate.Probability / math.max(Mass, 0.0001)
                table.insert(Candidates, Candidate)
            end
        end

        table.sort(Candidates, function(A, B)
            return A.Score > B.Score
        end)

        local Remembered: string? = Brain.Memory and Brain.Memory[Brain.Phrase(Tokens)]
        for _, Candidate: any in Remembered and Candidates or {} do
            if Brain.Canonical(Candidate) == Remembered then
                return {Kind = "Execute", Best = Candidate, Tokens = Tokens, Unknown = {}}
            end
        end

        local Best = Candidates[1]
        local Runner
        for i: number = 2, #Candidates do
            if Brain.Canonical(Candidates[i]) ~= Brain.Canonical(Best) then
                Runner = Candidates[i]
                break
            end
        end

        local Wanted, WantedProbability = nil, 0
        for Intent: string, Probability: number in Missing do
            if Probability > WantedProbability then
                Wanted, WantedProbability = Intent, Probability
            end
        end

        local Vocabulary = Brain.Vocabulary()
        local Unknown: {string} = {}
        local Mentioned
        for _, Token: any in Tokens do
            if Token.Kind == "word" and not Token.Corrected and not Brain.Knows(Token.Word) and not Brain.MatchPlayer(Token.Word) then
                table.insert(Unknown, Token.Raw)
            end

            Mentioned = Mentioned or Index.Keys[Token.Word]
        end

        local Alike: boolean = Runner ~= nil and Runner.Reading ~= Best.Reading and math.abs(Runner.Reading.Quality - Best.Reading.Quality) < 0.3
        local Close: boolean = Runner ~= nil and Runner.Intent ~= "HowTo" and Runner.Intent ~= "Guide" and (Best.Score - Runner.Score < Brain.Margin or (Alike and Runner.Confidence >= 0.4 and Best.Score - Runner.Score < Brain.Margin * 2))
        local Decision = {Best = Best, Runner = Runner, Tokens = Tokens, Unknown = Unknown, Wanted = Wanted, WantedProbability = WantedProbability}

        if Wanted and WantedProbability >= 0.5 and (not Best or Best.Probability < WantedProbability - 0.2) then
            Decision.Kind = "Ask"
            Decision.Intent = Wanted
            Decision.Mentioned = Mentioned
        elseif Best and Brain.Social[Best.Intent] and Best.Probability >= Brain.SocialFloor and #Best.Reading.Entities == 0 and not Mentioned then
            Decision.Kind = "Execute"
        elseif not Best or Best.Intent == "HowTo" or Best.Intent == "Guide" or (Best.Intent == "Recommend" and Best.Slots.Soft) or Best.Probability < Brain.Floor or (#Unknown > 0 and Brain.Knowledge[Best.Intent] and Best.Probability < 0.5)
            or (Brain.Knowledge[Best.Intent] and (Best.Confidence < 0.3 or (Tokens[1].Word == "how" and (Tokens[2] or {}).Word ~= "many" and not Brain.Social[Best.Intent] and not Brain.Direct[Best.Intent]))) or (Brain.Changes(Best.Intent) and Best.Probability < Brain.Floor + 0.05) then
            Decision.Kind = "Answer"
        elseif Close and (Brain.Changes(Best.Intent) or Brain.Changes(Runner.Intent)) then
            Decision.Kind = "Clarify"
        else
            Decision.Kind = "Execute"
            Decision.Alternative = Close and not Brain.Knowledge[Best.Intent] ~= not Brain.Knowledge[Runner.Intent]
        end

        local Stated: string? = Brain.GoalText(Question)
        local _, GuideScore = FindGuide(Brain.QueryOf(Tokens))
        local Explicit: boolean = Brain.HasWord(Tokens, Brain.ModuleWords)
        local Modular: boolean = false
        for _, Entity: any in Best and Best.Reading.Entities or {} do
            Modular = Modular or Entity.Type == "module"
        end

        local Plainly: boolean = Stated ~= nil and Index.Keys[Compact(Stated)] ~= nil
        for _, Token: any in Tokens do
            Plainly = Plainly or (Index.Keys[Token.Word] ~= nil and not Brain.English(Token.Word))
        end

        Modular = false
        for _, Entity: any in Best and Best.Reading.Entities or {} do
            Modular = Modular or (Entity.Type == "module" and not Brain.English(Entity.Value.Key))
        end

        if Stated and (GuideScore < 2 or not Brain.HasWord(Tokens, {"how"})) and (not Best or Best.Intent == "Recommend" or not Brain.Changes(Best.Intent) or Best.Probability < 0.5) and not Plainly and not Modular then
            local Picked = Brain.Goal(Tokens, Explicit and Brain.Cut(` {table.concat(Brain.WordList(Tokens), " ")} `) or Stated)
            if Picked[1] or Explicit then
                Best = {Intent = "Recommend", Probability = Best and Best.Probability or 0, Confidence = 1, Reading = {Entities = {}, Quality = 0}, Score = 0, Slots = {Pick = Picked[1], Explicit = Explicit}, Tokens = Tokens}
                Decision.Best = Best
                Decision.Kind = "Execute"
            end
        else
            Stated = nil
        end

        local Depth = Brain.Depth
        if Best and Best.Intent == "Describe" and (Decision.Kind == "Execute" or Decision.Kind == "Answer") and Depth.Level >= 1 and Depth.Key == Best.Slots.Entry.Key
            and (Best.Slots.Implicit or Brain.HasWord(Tokens, {"how", "work", "works", "actually", "really", "exactly", "deeper", "more"})) then
            local Deeper = table.clone(Best)
            Deeper.Intent = "More"
            Decision.Kind = "Execute"
            Decision.Best = Deeper
            return Decision
        end

        local Commissioned = Brain.Commission(Decision, Question)
        local Problem: string? = not Commissioned and Brain.Problem(Decision, Question)
        local Steered = Commissioned or not Problem and Brain.Steer(Decision, Question)
        if Problem then
            Decision.Kind = Problem
            return Decision
        elseif Steered then
            local Candidate = table.clone(Best or {Probability = 0, Confidence = 1, Reading = {Entities = {}, Quality = 0}, Score = 0})
            Candidate.Intent, Candidate.Slots, Candidate.Tokens = Steered.Intent, Steered.Slots, Tokens
            Decision.Kind = "Execute"
            Decision.Best = Candidate
            return Decision
        elseif Best and Brain.Direct[Best.Intent] and (Decision.Kind == "Execute" or (Best.Intent == "Recommend" and Decision.Kind == "Answer")) and (Best.Intent ~= "Recommend" or Best.Slots.Explicit) then
            Decision.Kind = "Execute"
            return Decision
        end

        local Goal: boolean = Best ~= nil and Best.Intent == "Recommend" and (Decision.Kind == "Execute" or Decision.Kind == "Answer")
        local Picked: boolean = Goal and Decision.Kind == "Execute"
        if Goal then
            Decision.Kind = "Answer"
        end

        local Social: boolean = Decision.Kind == "Execute" and Brain.Social[Best.Intent] == true
        local Lookup = not (Goal and (Best.Probability >= 0.5 or Stated ~= nil)) and (not Social or Brain.Inquiring(Tokens) or Brain.IsQuestion(Tokens, Question)) and Brain.LookupFor(Decision, Question) or nil
        local Fact = not Lookup and Brain.Recall(Decision, Question)
        local Pick = Picked and Best.Slots.Pick or nil
        local Wanted: boolean = Picked and (Brain.GoalText(Question) ~= nil or Brain.HasWord(Tokens, Brain.ModuleWords))
        if Picked and (not Fact or Stated or (Wanted and Pick and table.find(Fact.Modules or {}, Pick.Name))) and not Brain.OffTopic(Decision, Question) then
            Decision.Kind = "Execute"
            return Decision
        end

        if Lookup then
            Decision.Kind = "Lookup"
            Decision.Lookup = Lookup
        elseif Brain.OffTopic(Decision, Question) then
            Decision.Kind = "Offtopic"
        elseif Fact then
            Decision.Kind = "Fact"
            Decision.Fact = Fact
        elseif Decision.Kind == "Execute" and Brain.Changes(Best.Intent) and Brain.IsAsking(Tokens, Question) then
            Decision.Kind = "Answer"
        end

        return Decision
    end

    function Brain.Think(Question: string, Nested: boolean?)
        Brain.Ready()
        if Brain.ErrorOf(Question) then
            Brain.LastIntent = nil
            return Brain.Runners.Error(nil, Question)
        end

        Question = Brain.Unpreface(Brain.Unslang(Question))

        local Steps: {string} = {}
        local Split: string = (` {Question} `):gsub("%s*[;,]?%s+and then%s+(%a+)", function(Verb: string): string
            return Brain.Commands[Verb:lower()] and `\n{Verb}` or ` and then {Verb}`
        end):gsub("%s*[;,]?%s+then%s+(%a+)", function(Verb: string): string
            return Brain.Commands[Verb:lower()] and `\n{Verb}` or ` then {Verb}`
        end)
        for _, Step: string in Split:gsub("%s*;%s*", "\n"):split("\n") do
            Step = Step:match("^%s*(.-)%s*$")
            if Step ~= "" then
                table.insert(Steps, Step)
            end
        end

        if not Nested and #Steps > 1 then
            local Texts: {string} = {}
            local Last
            for _, Step: string in Steps do
                Last = Brain.Think(Step, true)
                table.insert(Texts, Last.Text)
            end

            return {Text = table.concat(Texts, "\n\n"), Actions = Last and Last.Actions}
        end

        local Decision = Brain.Understand(Question)
        if Decision.Kind == "Empty" then
            return {Text = "Ask me anything about CatVape.", Actions = Suggestions()}
        elseif Decision.Kind == "Elsewhere" then
            Brain.LastIntent = nil
            return Brain.ElsewhereReply(Decision.Absent, Decision.Tokens)
        elseif Decision.Kind == "Calculate" or Decision.Kind == "Offtopic" or Decision.Kind == "Error" or Decision.Kind == "Performance" or Decision.Kind == "Symptom" then
            Brain.LastIntent = nil
            return Brain.Runners[Decision.Kind](Decision, Question)
        elseif Decision.Kind == "Ask" then
            if Decision.Intent == "Bind" and Decision.Mentioned then
                return BindReply(Decision.Mentioned)
            end

            return Brain.AskFor(Decision.Intent, Decision.Unknown)
        elseif Decision.Kind == "Answer" then
            Brain.LastIntent = Decision.Best and Decision.Best.Intent or nil
            return Answer(Question)
        elseif Decision.Kind == "Fact" then
            Brain.LastIntent = nil
            return Brain.FactReply(Decision.Fact)
        elseif Decision.Kind == "Lookup" then
            Brain.LastIntent = nil
            return Brain.RunLookup(Decision.Lookup, Decision.Tokens)
        elseif Decision.Kind == "Clarify" then
            return Brain.Clarify({Decision.Best, Decision.Runner})
        end

        local Result = Brain.Execute(Decision.Best, Question)
        if Decision.Alternative then
            local Runner = Decision.Runner
            local Text: string = Brain.Canonical(Runner)
            Result.Actions = Result.Actions or {}
            table.insert(Result.Actions, {
                Text = `Or: {Text}`,
                Callback = function()
                    Brain.Learn(Runner)
                    AddMessage(Text, true)
                    Reply(Brain.Execute(Runner))
                end
            })
        end

        return Result
    end

    function Send(Question: string)
        if vape.ThreadFix then
            setthreadidentity(8)
        end

        Question = Question:sub(1, 600):match("^%s*(.-)%s*$")
        if Question == "" then return end

        AddMessage(Question, true)
        local Thinking, ThinkingLabel = AddMessage("Thinking.", false, nil, true)
        local Animating: boolean = true
        task.spawn(function()
            if vape.ThreadFix then
                setthreadidentity(8)
            end

            for Step: number = 1, 40 do
                task.wait(0.25)
                if not Animating or not Thinking.Parent then
                    break
                end

                ThinkingLabel.Text = `Thinking{string.rep(".", Step % 3 + 1)}`
            end
        end)
        task.wait(0.6)

        local Started: number = os.clock()
        local Success, Result = pcall(Brain.Think, Question)
        local Took: number = os.clock() - Started
        Animating = false
        if not Success then
            warn(`[Uranium] Assistant errored answering "{Question}" : {Result}`)
            Result = {Text = "Something went wrong answering that, check your console."}
        end

        RemoveMessage(Thinking)
        Reply(Result, Took < 1 and `Thought for {math.max(1, math.round(Took * 1000))}ms` or `Thought for {math.round(Took * 10) / 10}s`)
    end

    Assistant = {
        Collapsed = false,
        GameGreetings = {
            BedWars = {"Which bed are we breaking first?", "Ready to win some games?", "Let's get your config match ready."},
            IllegalSoccer = {"Ready to score some goals?", "Want to tune your shots?"},
            TowerOfHell = {"Ready to climb the tower?"}
        },
        Greetings = {
            "What should we work on?",
            "What can I help with?",
            "Where should we start?",
            "What's on your mind?",
            "Ready when you are.",
            "What are we setting up today?",
            "Need a hand with something?",
            "Ask me anything about CatVape.",
            "What's the plan?",
            "How can I help?"
        },
        Mode = "Landing",
        Name = "Assistant",
        Type = "Assistant"
    }

    local ScreenColumn: number = math.floor((GUI.AbsoluteSize.X / Scale.Scale / 2 - 231) / 230 + 0.5)
    if ScreenColumn < 1 then
        ScreenColumn = 1
    end
    local ScreenTop: number = math.floor(GUI.AbsoluteSize.Y / Scale.Scale * 0.78) - 425
    if ScreenTop < 60 then
        ScreenTop = 60
    end
    Window = Instance.new("TextButton")
    Window.AutoButtonColor = false
    Window.BackgroundColor3 = UIPallet.Main
    Window.Name = "AssistantWindow"
    Window.Position = UDim2.fromOffset(6 + ScreenColumn * 230, ScreenTop)
    Window.Size = UDim2.fromOffset(ChatWidth, 234)
    Window.Text = ""
    StageWindow(Window, ClickGUI)
    Assistant.Default = Window.Position
    Assistant.Object = Window
    AddBlur(Window)
    AddCorner(Window, UDim.new(0, 12))
    AddDragHandler(Window)
    local WindowStroke: UIStroke = Instance.new("UIStroke")
    WindowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    WindowStroke.Color = Color3.fromRGB(85, 85, 85)
    WindowStroke.Transparency = 0.8
    WindowStroke.Parent = Window
    local Icon: ImageLabel = Instance.new("ImageLabel")
    Icon.BackgroundTransparency = 1
    Icon.Image = GetVapeAsset(`{vape.Directory}/assets/new/vape.png`)
    Icon.Position = UDim2.fromOffset(11, 12)
    Icon.Size = UDim2.fromOffset(16, 16)
    Icon.Parent = Window
    local Title: TextLabel = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.FontFace = UIPallet.Font
    Title.Position = UDim2.fromOffset(34, 0)
    Title.Size = UDim2.new(1, -100, 0, 41)
    Title.Text = AssistantTitle
    Title.TextColor3 = UIPallet.Text
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Window
    local NewChatButton: TextButton = Instance.new("TextButton")
    NewChatButton.BackgroundTransparency = 1
    NewChatButton.Position = UDim2.new(1, -53, 0, 0)
    NewChatButton.Size = UDim2.fromOffset(24, 40)
    NewChatButton.Text = ""
    NewChatButton.Parent = Window
    AddTooltip(NewChatButton, "New chat")
    local NewChatIcon: ImageLabel = Instance.new("ImageLabel")
    NewChatIcon.BackgroundTransparency = 1
    NewChatIcon.Image = GetVapeAsset(`{vape.Directory}/assets/new/editlarge.png`)
    NewChatIcon.ImageColor3 = Color3.fromRGB(140, 140, 140)
    NewChatIcon.Position = UDim2.fromOffset(6, 14)
    NewChatIcon.Size = UDim2.fromOffset(12, 12)
    NewChatIcon.Parent = NewChatButton
    local HistoryButton: TextButton = Instance.new("TextButton")
    HistoryButton.BackgroundTransparency = 1
    HistoryButton.Position = UDim2.new(1, -79, 0, 0)
    HistoryButton.Size = UDim2.fromOffset(24, 40)
    HistoryButton.Text = ""
    HistoryButton.Parent = Window
    Assistant.HistoryButton = HistoryButton
    AddTooltip(HistoryButton, "Chat history")
    local HistoryIcon: ImageLabel = Instance.new("ImageLabel")
    HistoryIcon.BackgroundTransparency = 1
    HistoryIcon.Image = GetVapeAsset(`{vape.Directory}/assets/new/legit_clock.png`)
    HistoryIcon.ImageColor3 = Color3.fromRGB(140, 140, 140)
    HistoryIcon.Position = UDim2.fromOffset(6, 14)
    HistoryIcon.Size = UDim2.fromOffset(12, 12)
    HistoryIcon.Parent = HistoryButton
    local ArrowButton: TextButton = Instance.new("TextButton")
    ArrowButton.BackgroundTransparency = 1
    ArrowButton.Position = UDim2.new(1, -29, 0, 0)
    ArrowButton.Size = UDim2.fromOffset(27, 40)
    ArrowButton.Text = ""
    ArrowButton.Parent = Window
    local Arrow: ImageLabel = Instance.new("ImageLabel")
    Arrow.BackgroundTransparency = 1
    Arrow.Image = GetVapeAsset(`{vape.Directory}/assets/new/downexpand.png`)
    Arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
    Arrow.Position = UDim2.fromOffset(9, 18)
    Arrow.Size = UDim2.fromOffset(9, 4)
    Arrow.Parent = ArrowButton
    local Divider: Frame = Instance.new("Frame")
    Divider.BackgroundColor3 = Color3.new(1, 1, 1)
    Divider.BackgroundTransparency = 0.928
    Divider.BorderSizePixel = 0
    Divider.Position = UDim2.fromOffset(0, 40)
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Parent = Window
    local Greeting: TextLabel = Instance.new("TextLabel")
    Greeting.BackgroundTransparency = 1
    Greeting.FontFace = UIPallet.Font
    Greeting.Position = UDim2.fromOffset(0, 60)
    Greeting.Size = UDim2.new(1, 0, 0, 28)
    Greeting.Text = "What should we work on?"
    Greeting.TextColor3 = UIPallet.Text
    Greeting.TextSize = 20
    Greeting.Parent = Window
    Chat = Instance.new("ScrollingFrame")
    Chat.BackgroundTransparency = 1
    Chat.BorderSizePixel = 0
    Chat.CanvasSize = UDim2.new()
    Chat.Position = UDim2.fromOffset(0, 41)
    Chat.ScrollBarImageTransparency = 0.75
    Chat.ScrollBarThickness = 2
    Chat.Size = UDim2.new(1, 0, 0, 300)
    Chat.Visible = false
    Chat.Parent = Window
    Assistant.Chat = Chat
    local ChatPadding: UIPadding = Instance.new("UIPadding")
    ChatPadding.PaddingBottom = UDim.new(0, 12)
    ChatPadding.PaddingLeft = UDim.new(0, 20)
    ChatPadding.PaddingRight = UDim.new(0, 20)
    ChatPadding.PaddingTop = UDim.new(0, 12)
    ChatPadding.Parent = Chat
    ChatList = Instance.new("UIListLayout")
    ChatList.Padding = UDim.new(0, 14)
    ChatList.SortOrder = Enum.SortOrder.LayoutOrder
    ChatList.Parent = Chat
    local HistoryList: ScrollingFrame = Instance.new("ScrollingFrame")
    HistoryList.BackgroundTransparency = 1
    HistoryList.BorderSizePixel = 0
    HistoryList.CanvasSize = UDim2.new()
    HistoryList.Position = UDim2.fromOffset(0, 41)
    HistoryList.ScrollBarImageTransparency = 0.75
    HistoryList.ScrollBarThickness = 2
    HistoryList.Size = UDim2.new(1, 0, 1, -49)
    HistoryList.Visible = false
    HistoryList.Parent = Window
    local HistoryPadding: UIPadding = Instance.new("UIPadding")
    HistoryPadding.PaddingLeft = UDim.new(0, 10)
    HistoryPadding.PaddingRight = UDim.new(0, 10)
    HistoryPadding.PaddingTop = UDim.new(0, 8)
    HistoryPadding.Parent = HistoryList
    local HistoryLayout: UIListLayout = Instance.new("UIListLayout")
    HistoryLayout.Padding = UDim.new(0, 2)
    HistoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
    HistoryLayout.Parent = HistoryList
    local HistoryEmpty: TextLabel = Instance.new("TextLabel")
    HistoryEmpty.BackgroundTransparency = 1
    HistoryEmpty.FontFace = UIPallet.Font
    HistoryEmpty.Size = UDim2.new(1, 0, 0, 60)
    HistoryEmpty.Text = "No saved chats yet, your conversations show up here."
    HistoryEmpty.TextColor3 = Color.Dark(UIPallet.Text, 0.45)
    HistoryEmpty.TextSize = 12
    HistoryEmpty.Visible = false
    HistoryEmpty.Parent = HistoryList
    local Composer: Frame = Instance.new("Frame")
    Composer.BackgroundColor3 = Color.Light(UIPallet.Main, 0.05)
    Composer.Parent = Window
    local ComposerCorner: UICorner = AddCorner(Composer, UDim.new(0, 18))
    local ComposerStroke: UIStroke = Instance.new("UIStroke")
    ComposerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ComposerStroke.Color = Color.Light(UIPallet.Main, 0.14)
    ComposerStroke.Parent = Composer
    InputBox = Instance.new("TextBox")
    InputBox.BackgroundTransparency = 1
    InputBox.ClearTextOnFocus = false
    InputBox.ClipsDescendants = true
    InputBox.FontFace = UIPallet.Font
    InputBox.PlaceholderColor3 = Color.Dark(UIPallet.Text, 0.4)
    InputBox.PlaceholderText = "Ask CatVape anything"
    InputBox.Text = ""
    InputBox.TextColor3 = UIPallet.Text
    InputBox.TextSize = 14
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.Parent = Composer
    local SendButton: TextButton = Instance.new("TextButton")
    SendButton.AutoButtonColor = false
    SendButton.BackgroundColor3 = Color.Light(UIPallet.Main, 0.22)
    SendButton.Size = UDim2.fromOffset(30, 30)
    SendButton.Text = ""
    SendButton.Parent = Composer
    AddCorner(SendButton, UDim.new(1, 0))
    AddTooltip(SendButton, "Send")
    local SendIcon: Frame = Instance.new("Frame")
    SendIcon.BackgroundTransparency = 1
    SendIcon.Size = UDim2.fromScale(1, 1)
    SendIcon.Parent = SendButton
    local SendParts: {Frame} = {}
    for _, Part: {any} in {{UDim2.fromOffset(15, 16), UDim2.fromOffset(2, 12), 0}, {UDim2.fromOffset(12.4, 12.6), UDim2.fromOffset(2, 8), 45}, {UDim2.fromOffset(17.6, 12.6), UDim2.fromOffset(2, 8), -45}} do
        local Bar: Frame = Instance.new("Frame")
        Bar.AnchorPoint = Vector2.new(0.5, 0.5)
        Bar.BackgroundColor3 = Color.Dark(UIPallet.Text, 0.3)
        Bar.BorderSizePixel = 0
        Bar.Position = Part[1]
        Bar.Rotation = Part[3]
        Bar.Size = Part[2]
        Bar.Parent = SendIcon
        AddCorner(Bar, UDim.new(1, 0))
        table.insert(SendParts, Bar)
    end
    local Suggest: Frame = Instance.new("Frame")
    Suggest.BackgroundTransparency = 1
    Suggest.Position = UDim2.fromOffset(20, 194)
    Suggest.Size = UDim2.new(1, -40, 0, 24)
    Suggest.Parent = Window
    local Footer: TextLabel = Instance.new("TextLabel")
    Footer.BackgroundTransparency = 1
    Footer.FontFace = UIPallet.Font
    Footer.Position = UDim2.fromOffset(0, 401)
    Footer.Size = UDim2.new(1, 0, 0, 16)
    Footer.Text = "This is an AI and can make mistakes."
    Footer.TextColor3 = Color.Dark(UIPallet.Text, 0.45)
    Footer.TextSize = 11
    Footer.Visible = false
    Footer.Parent = Window

    History = {
        Chats = {},
        File = `{vape.Directory}/profiles/assistantchats.json`,
        Limit = 30
    }

    function History.Day(Time: number): string
        local Now = os.date("*t")
        local Then = os.date("*t", Time)
        if Now.year == Then.year and Now.yday == Then.yday then
            return "Today"
        elseif Now.year == Then.year and Now.yday - Then.yday == 1 then
            return "Yesterday"
        end

        return (os.date("%b %d", Time):gsub(" 0", " "))
    end

    function History.Clock(Time: number): string
        return (os.date("%I:%M %p", Time):gsub("^0", ""))
    end

    function History.Load()
        local Saved = isfile(History.File) and LoadJSON(History.File)
        table.clear(History.Chats)
        if type(Saved) ~= "table" then return end

        for _, Entry: any in Saved do
            if type(Entry) == "table" and type(Entry.Title) == "string" and type(Entry.Messages) == "table" and type(Entry.Created) == "number" then
                table.insert(History.Chats, Entry)
            end
        end
    end

    function History.Save()
        if History.Queued then return end

        History.Queued = true
        task.delay(0.5, function()
            History.Queued = false
            WriteJSON(History.File, History.Chats)
        end)
    end

    function History.Record(Text: string, FromUser: boolean, Note: string?)
        if History.Replaying then return end

        local Current = History.Current
        if not Current then
            if not FromUser then return end

            local Title: string = Text:gsub("%s+", " "):match("^%s*(.-)%s*$")
            Current = {
                Created = os.time(),
                Messages = {},
                Title = #Title > 48 and `{Title:sub(1, 45)}...` or Title
            }
            History.Current = Current
        end

        table.insert(Current.Messages, {Note = Note, Role = FromUser and "user" or "bot", Text = Text})
        Current.Updated = os.time()
        while #Current.Messages > MaxMessages do
            table.remove(Current.Messages, 1)
        end

        local Position: number? = table.find(History.Chats, Current)
        if Position ~= 1 then
            if Position then
                table.remove(History.Chats, Position)
            end

            table.insert(History.Chats, 1, Current)
        end

        while #History.Chats > History.Limit do
            table.remove(History.Chats)
        end

        History.Save()
    end

    local function AddStamp()
        local Time: number = History.Current and History.Current.Created or os.time()
        local Stamp: TextLabel = Instance.new("TextLabel")
        Stamp.BackgroundTransparency = 1
        Stamp.FontFace = UIPallet.Font
        Stamp.LayoutOrder = MessageCount
        Stamp.RichText = true
        Stamp.Size = UDim2.new(1, 0, 0, 16)
        Stamp.Text = `<b>{History.Day(Time)}</b> {History.Clock(Time)}`
        Stamp.TextColor3 = Color.Dark(UIPallet.Text, 0.45)
        Stamp.TextSize = 12
        Stamp.Parent = Chat
        table.insert(Rows, Stamp)
    end

    function History.Open(Entry)
        ClearChat()
        History.Current = Entry
        History.Replaying = true
        Assistant:SetMode("Chat")

        for _, Message: any in Entry.Messages do
            if type(Message) == "table" and type(Message.Text) == "string" then
                AddMessage(Message.Text, Message.Role == "user", nil, nil, type(Message.Note) == "string" and Message.Note or nil)
            end
        end

        History.Replaying = false
    end

    function History.Delete(Entry)
        local Position: number? = table.find(History.Chats, Entry)
        if Position then
            table.remove(History.Chats, Position)
        end

        if History.Current == Entry then
            ClearChat()
        end

        History.Save()
        Assistant:SetMode("History")
    end

    function History.Refresh()
        for _, Child: Instance in HistoryList:GetChildren() do
            if Child:IsA("TextButton") then
                Child:Destroy()
            end
        end

        HistoryEmpty.Visible = #History.Chats == 0
        for i: number, Entry: any in History.Chats do
            local Row: TextButton = Instance.new("TextButton")
            Row.AutoButtonColor = false
            Row.BackgroundColor3 = Color.Light(UIPallet.Main, 0.06)
            Row.BackgroundTransparency = History.Current == Entry and 0 or 1
            Row.LayoutOrder = i
            Row.Size = UDim2.new(1, 0, 0, 36)
            Row.Text = ""
            Row.Parent = HistoryList
            AddCorner(Row, UDim.new(0, 8))
            local RowTitle: TextLabel = Instance.new("TextLabel")
            RowTitle.BackgroundTransparency = 1
            RowTitle.FontFace = UIPallet.Font
            RowTitle.Position = UDim2.fromOffset(12, 0)
            RowTitle.Size = UDim2.new(1, -130, 1, 0)
            RowTitle.Text = Entry.Title
            RowTitle.TextColor3 = UIPallet.Text
            RowTitle.TextSize = 13
            RowTitle.TextTruncate = Enum.TextTruncate.AtEnd
            RowTitle.TextXAlignment = Enum.TextXAlignment.Left
            RowTitle.Parent = Row
            local RowTime: TextLabel = Instance.new("TextLabel")
            RowTime.BackgroundTransparency = 1
            RowTime.FontFace = UIPallet.Font
            RowTime.Position = UDim2.new(1, -112, 0, 0)
            RowTime.Size = UDim2.new(0, 80, 1, 0)
            RowTime.Text = History.Day(Entry.Updated or Entry.Created)
            RowTime.TextColor3 = Color.Dark(UIPallet.Text, 0.45)
            RowTime.TextSize = 11
            RowTime.TextXAlignment = Enum.TextXAlignment.Right
            RowTime.Parent = Row
            local Remove: TextButton = Instance.new("TextButton")
            Remove.BackgroundTransparency = 1
            Remove.Position = UDim2.new(1, -28, 0, 0)
            Remove.Size = UDim2.fromOffset(28, 36)
            Remove.Text = ""
            Remove.Parent = Row
            AddTooltip(Remove, "Delete chat")
            local RemoveIcon: ImageLabel = Instance.new("ImageLabel")
            RemoveIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            RemoveIcon.BackgroundTransparency = 1
            RemoveIcon.Image = GetVapeAsset(`{vape.Directory}/assets/new/closemini.png`)
            RemoveIcon.ImageColor3 = Color3.fromRGB(140, 140, 140)
            RemoveIcon.Position = UDim2.fromScale(0.5, 0.5)
            RemoveIcon.Size = UDim2.fromOffset(14, 14)
            RemoveIcon.Parent = Remove

            Row.MouseEnter:Connect(function()
                Row.BackgroundTransparency = 0
            end)

            Row.MouseLeave:Connect(function()
                Row.BackgroundTransparency = History.Current == Entry and 0 or 1
            end)

            Row.MouseButton1Click:Connect(function()
                if vape.ThreadFix then
                    setthreadidentity(8)
                end

                History.Open(Entry)
            end)

            Remove.MouseEnter:Connect(function()
                RemoveIcon.ImageColor3 = UIPallet.Text
            end)

            Remove.MouseLeave:Connect(function()
                RemoveIcon.ImageColor3 = Color3.fromRGB(140, 140, 140)
            end)

            Remove.MouseButton1Click:Connect(function()
                if vape.ThreadFix then
                    setthreadidentity(8)
                end

                History.Delete(Entry)
            end)
        end
    end

    local function RefreshGreeting()
        local Pool: {string} = table.clone(Assistant.Greetings)
        for _, Line: string in Assistant.GameGreetings[CurrentGame() or ""] or {} do
            table.insert(Pool, Line)
        end

        local Hour: number = tonumber(os.date("%H")) or 12
        table.insert(Pool, Hour < 5 and "Up late? What should we work on?" or Hour < 12 and "Good morning, what should we work on?" or Hour < 18 and "Good afternoon, what can I do for you?" or "Good evening, what are we doing tonight?")
        Greeting.Text = Pool[math.random(1, #Pool)]
    end

    local function RefreshSuggestions()
        EnsureIndex()
        Suggest:ClearAllChildren()

        local X: number = 0
        for _, Action: any in Suggestions() do
            local Width: number = math.ceil(GetFontBounds(Action.Text, 12, UIPallet.Font).X) + 22
            if X + Width > ChatWidth - 40 then
                break
            end

            AddChip(Suggest, Action.Text, UDim2.fromOffset(X, 0), Width, Action.Callback)
            X += Width + 6
        end
    end

    function Assistant:Layout()
        local Open: boolean = not self.Collapsed
        local Chatting: boolean = self.Mode == "Chat"
        local Listing: boolean = self.Mode == "History"
        local Height: number = 41

        Title.Text = Listing and "Chat history" or AssistantTitle
        HistoryIcon.ImageColor3 = Listing and UIPallet.Text or Color3.fromRGB(140, 140, 140)
        Arrow.Rotation = Open and 0 or 180
        Divider.Visible = Open
        Greeting.Visible = Open and self.Mode == "Landing"
        Suggest.Visible = Open and self.Mode == "Landing"
        Chat.Visible = Open and Chatting
        HistoryList.Visible = Open and Listing
        Footer.Visible = Open and Chatting
        Composer.Visible = Open and not Listing

        if Open and Listing then
            Height = 425
        elseif Open and Chatting then
            Composer.Position = UDim2.fromOffset(16, 349)
            Composer.Size = UDim2.new(1, -32, 0, 46)
            ComposerCorner.CornerRadius = UDim.new(1, 0)
            InputBox.Position = UDim2.fromOffset(18, 11)
            InputBox.Size = UDim2.new(1, -66, 0, 24)
            SendButton.Position = UDim2.new(1, -38, 0, 8)
            Height = 425
        elseif Open then
            Composer.Position = UDim2.fromOffset(16, 102)
            Composer.Size = UDim2.new(1, -32, 0, 80)
            ComposerCorner.CornerRadius = UDim.new(0, 18)
            InputBox.Position = UDim2.fromOffset(16, 12)
            InputBox.Size = UDim2.new(1, -32, 0, 24)
            SendButton.Position = UDim2.new(1, -40, 1, -40)
            Height = 234
        end

        Window.Size = UDim2.fromOffset(ChatWidth, Height)
    end

    function Assistant:SetMode(Mode: string)
        self.Mode = Mode
        if Mode == "Chat" and MessageCount == 0 then
            AddStamp()
        elseif Mode == "Landing" then
            RefreshGreeting()
            RefreshSuggestions()
        elseif Mode == "History" then
            History.Refresh()
        end

        self:Layout()
    end

    function Assistant:ShowHistory(Show: boolean?)
        if Show == nil then
            Show = self.Mode ~= "History"
        end

        self:SetMode(Show and "History" or MessageCount > 0 and "Chat" or "Landing")
    end

    function Assistant:Collapse()
        self.Collapsed = not self.Collapsed
        self:Layout()
        vape:QueueSave()
    end

    function Assistant:Color() end

    function Assistant:Load(Data)
        if vape.ThreadFix then
            setthreadidentity(8)
        end

        if Data.Collapsed == nil then return end

        if Data.Position then
            Window.Position = UDim2.fromOffset(Data.Position.X, Data.Position.Y)
        end

        if Data.Collapsed ~= self.Collapsed then
            self:Collapse()
        end
    end

    function Assistant:Save(Data)
        Data.Assistant = {
            Collapsed = self.Collapsed,
            Position = {
                X = Window.Position.X.Offset,
                Y = Window.Position.Y.Offset
            }
        }
    end

    vape.Categories.Assistant = Assistant
    vape:Clean(ClearHighlight)
    History.Load()
    RefreshGreeting()
    Assistant:Layout()

    function Assistant:Forget()
        Brain.Learned = {}
        Brain.Memory = {}
        Brain.Model = nil
        WriteJSON(Brain.File, {})
        vape:CreateNotification(AssistantName, "Forgot every answer it learned from your choices", 5)
    end

    local function Submit()
        local Question: string = InputBox.Text
        InputBox.Text = ""
        Send(Question)
    end

    InputBox.FocusLost:Connect(function(Enter: boolean)
        if Enter then
            Submit()
        end
    end)

    InputBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Typed: boolean = InputBox.Text:match("%S") ~= nil
        SendButton.BackgroundColor3 = Typed and UIPallet.Text or Color.Light(UIPallet.Main, 0.22)
        for _, Bar: Frame in SendParts do
            Bar.BackgroundColor3 = Typed and UIPallet.Main or Color.Dark(UIPallet.Text, 0.3)
        end
    end)

    SendButton.MouseButton1Click:Connect(Submit)

    NewChatButton.MouseButton1Click:Connect(function()
        Brain.Pending = nil
        ClearChat()
    end)

    HistoryButton.MouseButton1Click:Connect(function()
        Assistant:ShowHistory()
    end)

    ArrowButton.MouseButton1Click:Connect(function()
        Assistant:Collapse()
    end)

    for _, Button: TextButton in {NewChatButton, HistoryButton, ArrowButton} do
        local ButtonIcon: ImageLabel = Button:FindFirstChildOfClass("ImageLabel")

        Button.MouseEnter:Connect(function()
            ButtonIcon.ImageColor3 = UIPallet.Text
        end)

        Button.MouseLeave:Connect(function()
            ButtonIcon.ImageColor3 = (Button == HistoryButton and Assistant.Mode == "History") and UIPallet.Text or Color3.fromRGB(140, 140, 140)
        end)
    end

    vape:Clean(ClickGUI:GetPropertyChangedSignal("Visible"):Connect(function()
        if not ClickGUI.Visible then return end

        if vape.ThreadFix then
            setthreadidentity(8)
        end

        if Assistant.Mode == "Landing" then
            RefreshGreeting()
            RefreshSuggestions()
        end

        task.defer(function()
            if not Brain.Model then
                Brain.Train()
            end
        end)
    end))

    ChatList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if vape.ThreadFix then
            setthreadidentity(8)
        end

        Chat.CanvasSize = UDim2.fromOffset(0, ChatList.AbsoluteContentSize.Y / Scale.Scale + 24)
        task.defer(function()
            Chat.CanvasPosition = Vector2.new(0, 1e6)
        end)
    end)
end)()