--=======================================================================
-- URANIUM HUB v3.0
-- Professional custom UI engine — zero external library dependencies
-- Auto game detection with native confirmation popup
-- Run: loadstring(game:HttpGet("https://raw.githubusercontent.com/Korsac2026/12345/main/Uranium.lua"))()
--=======================================================================

local Uranium = {}
Uranium.Name = "Uranium"
Uranium.Version = "3.0"
Uranium.Directory = "uranium"
Uranium.Sources = {}
Uranium.Ran = {}

local REPO = "https://raw.githubusercontent.com/Korsac2026/12345/main"

local isfile = isfile or function(p)
    local s, r = pcall(readfile, p)
    return s and r ~= nil and r ~= ""
end
if not isfolder(Uranium.Directory) then makefolder(Uranium.Directory) end
if not isfolder(Uranium.Directory .. "/dumps") then makefolder(Uranium.Directory .. "/dumps") end

-- config
Uranium.Config = { Accent = { 99, 155, 255 }, AutoRun = {} }
local function LoadConfig()
    if isfile(Uranium.Directory .. "/config.json") then
        local s, r = pcall(function()
            local raw = readfile(Uranium.Directory .. "/config.json")
            return game:GetService("HttpService"):JSONDecode(raw)
        end)
        if s and type(r) == "table" then
            for k, v in pairs(r) do Uranium.Config[k] = v end
        end
    end
end
LoadConfig()

local function SaveConfig()
    local ok = pcall(function()
        writefile(Uranium.Directory .. "/config.json", game:GetService("HttpService"):JSONEncode(Uranium.Config))
    end)
    return ok
end

--=======================================================================
-- UTILITIES
--=======================================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local function rgb(t) return Color3.new(t[1]/255, t[2]/255, t[3]/255) end
local function SaveAccent(a) Uranium.Config.Accent = {math.floor(a.R*255+0.5), math.floor(a.G*255+0.5), math.floor(a.B*255+0.5)} SaveConfig() end

local Theme = {}
function Theme.Accent() return rgb(Uranium.Config.Accent) end
Theme.Bg      = Color3.fromRGB(18, 18, 24)
Theme.BgLight = Color3.fromRGB(26, 26, 35)
Theme.BgInput = Color3.fromRGB(33, 33, 44)
Theme.Stroke  = Color3.fromRGB(48, 48, 62)
Theme.Text    = Color3.fromRGB(235, 235, 245)
Theme.TextDim = Color3.fromRGB(140, 140, 160)
Theme.Green   = Color3.fromRGB(90, 200, 120)
Theme.Red     = Color3.fromRGB(235, 90, 100)

local function Tween(obj, ti, props)
    local t = TweenService:Create(obj, TweenInfo.new(ti or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function Drag(gui, handle)
    handle = handle or gui
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local updateConn
            updateConn = UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    local delta = inp.Position - dragStart
                    gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            handle.InputEnded:Connect(function() if updateConn then updateConn:Disconnect() end end
            )
        end
    end)
end

local function Ripple(button, color)
    local circle = Instance.new("Frame")
    circle.Name = "Ripple"
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Position = UDim2.new(0.5, 0, 0.5, 0)
    circle.Size = UDim2.new(0, 0, 0, 0)
    circle.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    circle.BackgroundTransparency = 0.6
    circle.BorderSizePixel = 0
    circle.Parent = button
    local cnr = Instance.new("UICorner") cnr.CornerRadius = UDim.new(1, 0) cnr.Parent = circle
    Tween(circle, 0.35, {
        Size = UDim2.new(0, math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2, 0, math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2),
        BackgroundTransparency = 1
    })
    task.delay(0.4, function() if circle then circle:Destroy() end end)
end

local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function Parent()
    local ok, ui = pcall(function() return gethui and gethui() or game:GetService("CoreGui") end)
    if not ok then
        -- fallback: protect via pcall parent to PlayerGui
        return game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    return ui
end

--=======================================================================
-- UI ENGINE
--=======================================================================
local UI = {}
UI.Pages = {}
UI.Open = true

local function BuildWindow()
    local gui = Instance.new("ScreenGui")
    gui.Name = "Uranium_" .. tostring(math.floor(tick() * 1000))
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = Parent() end)

    -- main frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 620, 0, 400)
    main.BackgroundColor3 = Theme.Bg
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    Corner(main, 10)
    Stroke(main, Theme.Stroke, 1)

    -- shadow
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 60, 1, 60)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    shadow.Parent = main

    -- title bar
    local titlebar = Instance.new("Frame")
    titlebar.Name = "TitleBar"
    titlebar.Size = UDim2.new(1, 0, 0, 46)
    titlebar.BackgroundColor3 = Theme.Bg
    titlebar.BorderSizePixel = 0
    titlebar.Parent = main
    Corner(titlebar, 10)

    local titlebarLine = Instance.new("Frame")
    titlebarLine.Position = UDim2.new(0, 0, 1, -1)
    titlebarLine.Size = UDim2.new(1, 0, 0, 1)
    titlebarLine.BackgroundColor3 = Theme.Stroke
    titlebarLine.BorderSizePixel = 0
    titlebarLine.Parent = titlebar

    local logo = Instance.new("Frame")
    logo.Position = UDim2.new(0, 14, 0.5, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.Size = UDim2.new(0, 26, 0, 26)
    logo.BackgroundColor3 = Theme.Accent()
    logo.BorderSizePixel = 0
    logo.Parent = titlebar
    Corner(logo, 7)
    local logoDot = Instance.new("Frame")
    logoDot.AnchorPoint = Vector2.new(0.5, 0.5)
    logoDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoDot.Size = UDim2.new(0, 8, 0, 8)
    logoDot.BackgroundColor3 = Color3.new(1, 1, 1)
    logoDot.BorderSizePixel = 0
    logoDot.Parent = logo
    Corner(logoDot, 4)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 50, 0, 0)
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = "URANIUM"
    title.TextColor3 = Theme.Text
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titlebar

    local version = Instance.new("TextLabel")
    version.BackgroundTransparency = 1
    version.Position = UDim2.new(0, 138, 0, 0)
    version.Size = UDim2.new(0, 60, 1, 0)
    version.Font = Enum.Font.Gotham
    version.Text = "v" .. Uranium.Version
    version.TextColor3 = Theme.TextDim
    version.TextSize = 12
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.Parent = titlebar

    local closeBtn = Instance.new("TextButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -14, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.BackgroundColor3 = Theme.BgLight
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titlebar
    Corner(closeBtn, 7)
    local closeX = Instance.new("TextLabel")
    closeX.BackgroundTransparency = 1
    closeX.Size = UDim2.new(1, 0, 1, 0)
    closeX.Font = Enum.Font.GothamBold
    closeX.Text = "X"
    closeX.TextColor3 = Theme.TextDim
    closeX.TextSize = 13
    closeX.Parent = closeBtn
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, 0.15, {BackgroundColor3 = Theme.Red}) closeX.TextColor3 = Color3.new(1,1,1) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, 0.15, {BackgroundColor3 = Theme.BgLight}) closeX.TextColor3 = Theme.TextDim end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(main, 0.25, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
        task.delay(0.3, function() gui:Destroy() end)
    end)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, 0)
    toggleBtn.Size = UDim2.new(0, 28, 0, 28)
    toggleBtn.BackgroundColor3 = Theme.BgLight
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = titlebar
    Corner(toggleBtn, 7)
    local toggleI = Instance.new("TextLabel")
    toggleI.BackgroundTransparency = 1
    toggleI.Size = UDim2.new(1, 0, 1, 0)
    toggleI.Font = Enum.Font.GothamBold
    toggleI.Text = "-"
    toggleI.TextColor3 = Theme.TextDim
    toggleI.TextSize = 16
    toggleI.Parent = toggleBtn
    toggleBtn.MouseButton1Click:Connect(function()
        UI.Open = not UI.Open
        if UI.Open then
            main.Visible = true
            Tween(main, 0.3, {Size = UDim2.new(0, 620, 0, 400)})
            toggleI.Text = "-"
        else
            Tween(main, 0.25, {Size = UDim2.new(0, 620, 0, 46)})
            toggleI.Text = "+"
        end
    end)

    Drag(main, titlebar)

    -- sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Position = UDim2.new(0, 0, 0, 46)
    sidebar.Size = UDim2.new(0, 160, 1, -46)
    sidebar.BackgroundColor3 = Theme.BgLight
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sidebarList = Instance.new("ScrollingFrame")
    sidebarList.Name = "PageList"
    sidebarList.Position = UDim2.new(0, 0, 0, 52)
    sidebarList.Size = UDim2.new(1, 0, 1, -52)
    sidebarList.BackgroundTransparency = 1
    sidebarList.BorderSizePixel = 0
    sidebarList.ScrollBarThickness = 2
    sidebarList.ScrollBarImageColor3 = Theme.Accent()
    sidebarList.ScrollBarImageTransparency = 0.5
    sidebarList.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebarList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarList.Parent = sidebar
    local pad = Instance.new("UIListLayout")
    pad.Padding = UDim.new(0, 2)
    pad.SortOrder = Enum.SortOrder.LayoutOrder
    pad.Parent = sidebarList

    local searchbox = Instance.new("TextBox")
    searchbox.Name = "Search"
    searchbox.Position = UDim2.new(0, 10, 0, 10)
    searchbox.Size = UDim2.new(1, -20, 0, 34)
    searchbox.BackgroundColor3 = Theme.BgInput
    searchbox.BorderSizePixel = 0
    searchbox.PlaceholderText = "Search..."
    searchbox.Text = ""
    searchbox.Font = Enum.Font.Gotham
    searchbox.TextSize = 12
    searchbox.TextColor3 = Theme.Text
    searchbox.PlaceholderColor3 = Theme.TextDim
    searchbox.ClearTextOnFocus = false
    searchbox.Parent = sidebar
    Corner(searchbox, 7)

    -- content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.new(0, 160, 0, 46)
    content.Size = UDim2.new(1, -160, 1, -46)
    content.BackgroundTransparency = 1
    content.Parent = main

    UI.Gui = gui
    UI.Main = main
    UI.SidebarList = sidebarList
    UI.Content = content
    UI.Search = searchbox
end

-- page tab button + container
function UI.Page(name, iconText)
    local page = {}
    page.Name = name
    page.Sections = {}

    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.new(1, 1, 1)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = #UI.Pages + 1
    btn.Parent = UI.SidebarList

    local ico = Instance.new("TextLabel")
    ico.BackgroundTransparency = 1
    ico.Position = UDim2.new(0, 10, 0, 0)
    ico.Size = UDim2.new(0, 20, 1, 0)
    ico.Font = Enum.Font.GothamBold
    ico.Text = iconText or "•"
    ico.TextColor3 = Theme.TextDim
    ico.TextSize = 12
    ico.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 32, 0, 0)
    lbl.Size = UDim2.new(1, -32, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = name
    lbl.TextColor3 = Theme.TextDim
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.BackgroundColor3 = Theme.Accent()
    indicator.BorderSizePixel = 0
    indicator.Parent = btn

    local holder = Instance.new("ScrollingFrame")
    holder.Name = name .. "Page"
    holder.Size = UDim2.new(1, 0, 1, 0)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.ScrollBarThickness = 3
    holder.ScrollBarImageColor3 = Theme.Accent()
    holder.ScrollBarImageTransparency = 0.5
    holder.CanvasSize = UDim2.new(0, 0, 0, 0)
    holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    holder.Visible = false
    holder.Parent = UI.Content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = holder
    local pad2 = Instance.new("UIPadding")
    pad2.PaddingTop = UDim.new(0, 12)
    pad2.PaddingLeft = UDim.new(0, 12)
    pad2.PaddingRight = UDim.new(0, 12)
    pad2.PaddingBottom = UDim.new(0, 12)
    pad2.Parent = holder

    function page:Select()
        for _, p in ipairs(UI.Pages) do
            p.Holder.Visible = false
            Tween(p.Indicator, 0.2, {Size = UDim2.new(0, 3, 0, 0)})
            Tween(p.Label, 0.2, {TextColor3 = Theme.TextDim})
            Tween(p.Ico, 0.2, {TextColor3 = Theme.TextDim})
        end
        holder.Visible = true
        Tween(indicator, 0.25, {Size = UDim2.new(0, 3, 0, 18)})
        Tween(lbl, 0.2, {TextColor3 = Theme.Text})
        Tween(ico, 0.2, {TextColor3 = Theme.Accent()})
        UI.ActivePage = page
    end

    btn.MouseButton1Click:Connect(function() page:Select() end)

    page.Holder = holder
    page.Button = btn
    page.Indicator = indicator
    page.Label = lbl
    page.Ico = ico

    -- section inside page
    function page:Section(name)
        local sec = {}
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundColor3 = Theme.BgLight
        frame.BorderSizePixel = 0
        frame.LayoutOrder = #page.Sections + 1
        frame.Parent = holder
        Corner(frame, 8)
        Stroke(frame, Theme.Stroke, 1)

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 34)
        header.BackgroundColor3 = Color3.new(1, 1, 1)
        header.BackgroundTransparency = 0.97
        header.BorderSizePixel = 0
        header.Parent = frame
        Corner(header, 8)

        local hlabel = Instance.new("TextLabel")
        hlabel.BackgroundTransparency = 1
        hlabel.Position = UDim2.new(0, 12, 0, 0)
        hlabel.Size = UDim2.new(1, -24, 1, 0)
        hlabel.Font = Enum.Font.GothamBold
        hlabel.Text = string.upper(name)
        hlabel.TextColor3 = Theme.TextDim
        hlabel.TextSize = 11
        hlabel.TextXAlignment = Enum.TextXAlignment.Left
        hlabel.Parent = header

        local list = Instance.new("Frame")
        list.Position = UDim2.new(0, 0, 0, 34)
        list.Size = UDim2.new(1, 0, 0, 0)
        list.AutomaticSize = Enum.AutomaticSize.Y
        list.BackgroundTransparency = 1
        list.Parent = frame
        local llayout = Instance.new("UIListLayout")
        llayout.Padding = UDim.new(0, 4)
        llayout.SortOrder = Enum.SortOrder.LayoutOrder
        llayout.Parent = list
        local lpad = Instance.new("UIPadding")
        lpad.PaddingTop = UDim.new(0, 8)
        lpad.PaddingLeft = UDim.new(0, 10)
        lpad.PaddingRight = UDim.new(0, 10)
        lpad.PaddingBottom = UDim.new(0, 10)
        lpad.Parent = list

        local order = 0
        local function nextOrder() order = order + 1 return order end

        function sec:Label(text)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 0, 0)
            l.AutomaticSize = Enum.AutomaticSize.Y
            l.BackgroundTransparency = 1
            l.Font = Enum.Font.Gotham
            l.Text = text
            l.TextWrapped = true
            l.TextColor3 = Theme.TextDim
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.LayoutOrder = nextOrder()
            l.Parent = list
            return l
        end

        function sec:Button(name, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 34)
            b.BackgroundColor3 = Theme.BgInput
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Text = ""
            b.ClipsDescendants = true
            b.LayoutOrder = nextOrder()
            b.Parent = list
            Corner(b, 6)
            local bl = Instance.new("TextLabel")
            bl.BackgroundTransparency = 1
            bl.Size = UDim2.new(1, 0, 1, 0)
            bl.Font = Enum.Font.GothamBold
            bl.Text = name
            bl.TextColor3 = Theme.Text
            bl.TextSize = 12
            bl.Parent = b
            b.MouseEnter:Connect(function() Tween(b, 0.15, {BackgroundColor3 = Theme.Accent():Lerp(Theme.BgInput, 0.65)}) end)
            b.MouseLeave:Connect(function() Tween(b, 0.15, {BackgroundColor3 = Theme.BgInput}) end)
            b.MouseButton1Click:Connect(function()
                Ripple(b, Theme.Accent())
                local ok, err = pcall(callback)
                if not ok then Uranium.Notify("Error", tostring(err), 6) end
            end)
            return b
        end

        function sec:Toggle(name, default, callback)
            local state = default or false
            local t = Instance.new("TextButton")
            t.Size = UDim2.new(1, 0, 0, 34)
            t.BackgroundColor3 = Color3.new(1, 1, 1)
            t.BackgroundTransparency = 1
            t.AutoButtonColor = false
            t.Text = ""
            t.LayoutOrder = nextOrder()
            t.Parent = list

            local tl = Instance.new("TextLabel")
            tl.BackgroundTransparency = 1
            tl.Position = UDim2.new(0, 4, 0, 0)
            tl.Size = UDim2.new(1, -50, 1, 0)
            tl.Font = Enum.Font.Gotham
            tl.Text = name
            tl.TextColor3 = Theme.Text
            tl.TextSize = 12
            tl.TextXAlignment = Enum.TextXAlignment.Left
            tl.Parent = t

            local track = Instance.new("Frame")
            track.AnchorPoint = Vector2.new(1, 0.5)
            track.Position = UDim2.new(1, -6, 0.5, 0)
            track.Size = UDim2.new(0, 40, 0, 20)
            track.BackgroundColor3 = state and Theme.Accent() or Theme.BgInput
            track.BorderSizePixel = 0
            track.Parent = t
            Corner(track, 10)

            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.Position = UDim2.new(0, state and 22 or 2, 0.5, 0)
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            knob.Parent = track
            Corner(knob, 8)

            local function Set(v, silent)
                state = v
                Tween(track, 0.2, {BackgroundColor3 = v and Theme.Accent() or Theme.BgInput})
                Tween(knob, 0.2, {Position = UDim2.new(0, v and 22 or 2, 0.5, 0)})
                if not silent then
                    local ok, err = pcall(callback, v)
                    if not ok then Uranium.Notify("Error", tostring(err), 6) end
                end
            end

            t.MouseButton1Click:Connect(function() Set(not state) end)
            if default then pcall(callback, default) end
            local obj = {}
            function obj:Set(v) Set(v) end
            function obj:Get() return state end
            return obj
        end

        function sec:Slider(name, min, max, default, callback, decimals)
            local value = default or min
            local s = Instance.new("Frame")
            s.Size = UDim2.new(1, 0, 0, 48)
            s.BackgroundColor3 = Theme.BgInput
            s.BorderSizePixel = 0
            s.LayoutOrder = nextOrder()
            s.Parent = list
            Corner(s, 6)

            local sl = Instance.new("TextLabel")
            sl.BackgroundTransparency = 1
            sl.Position = UDim2.new(0, 10, 0, 4)
            sl.Size = UDim2.new(0, 150, 0, 18)
            sl.Font = Enum.Font.Gotham
            sl.Text = name
            sl.TextColor3 = Theme.Text
            sl.TextSize = 12
            sl.TextXAlignment = Enum.TextXAlignment.Left
            sl.Parent = s

            local sv = Instance.new("TextLabel")
            sv.AnchorPoint = Vector2.new(1, 0)
            sv.BackgroundTransparency = 1
            sv.Position = UDim2.new(1, -10, 0, 4)
            sv.Size = UDim2.new(0, 100, 0, 18)
            sv.Font = Enum.Font.GothamBold
            sv.Text = tostring(value)
            sv.TextColor3 = Theme.Accent()
            sv.TextSize = 12
            sv.TextXAlignment = Enum.TextXAlignment.Right
            sv.Parent = s

            local track = Instance.new("Frame")
            track.Position = UDim2.new(0, 10, 0, 30)
            track.Size = UDim2.new(1, -20, 0, 6)
            track.BackgroundColor3 = Theme.Bg:Lerp(Color3.new(0,0,0), 0.3)
            track.BorderSizePixel = 0
            track.Parent = s
            Corner(track, 3)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent()
            fill.BorderSizePixel = 0
            fill.Parent = track
            Corner(fill, 3)

            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            knob.Parent = track
            Corner(knob, 7)

            local dragging = false
            local function SetFromX(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = min + (max - min) * rel
                if decimals then value = math.floor(value * 10 ^ decimals) / 10 ^ decimals
                else value = math.floor(value + 0.5) end
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                sv.Text = tostring(value)
                local ok, err = pcall(callback, value)
                if not ok then Uranium.Notify("Error", tostring(err), 6) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    SetFromX(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    SetFromX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function() dragging = false end)

            local obj = {}
            function obj:Set(v) value = math.clamp(v, min, max) SetFromX(track.AbsolutePosition.X + track.AbsoluteSize.X * ((value - min)/(max - min))) end
            function obj:Get() return value end
            return obj
        end

        function sec:Dropdown(name, items, default, callback)
            local current = default
            local open = false
            local dd = Instance.new("Frame")
            dd.Size = UDim2.new(1, 0, 0, 34)
            dd.BackgroundColor3 = Theme.BgInput
            dd.BorderSizePixel = 0
            dd.ClipsDescendants = true
            dd.LayoutOrder = nextOrder()
            dd.Parent = list
            Corner(dd, 6)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundTransparency = 1
            btn.AutoButtonColor = false
            btn.Text = ""
            btn.ZIndex = 2
            btn.Parent = dd

            local dl = Instance.new("TextLabel")
            dl.BackgroundTransparency = 1
            dl.Position = UDim2.new(0, 10, 0, 0)
            dl.Size = UDim2.new(1, -40, 1, 0)
            dl.Font = Enum.Font.Gotham
            dl.Text = name .. ": " .. tostring(current or "")
            dl.TextColor3 = Theme.Text
            dl.TextSize = 12
            dl.TextXAlignment = Enum.TextXAlignment.Left
            dl.ZIndex = 2
            dl.Parent = dd

            local arrow = Instance.new("TextLabel")
            arrow.AnchorPoint = Vector2.new(1, 0.5)
            arrow.BackgroundTransparency = 1
            arrow.Position = UDim2.new(1, -12, 0.5, 0)
            arrow.Size = UDim2.new(0, 16, 0, 16)
            arrow.Font = Enum.Font.GothamBold
            arrow.Text = "V"
            arrow.TextColor3 = Theme.TextDim
            arrow.TextSize = 12
            arrow.Rotation = 180
            arrow.ZIndex = 2
            arrow.Parent = dd

            local listHolder = Instance.new("Frame")
            listHolder.Position = UDim2.new(0, 0, 0, 34)
            listHolder.Size = UDim2.new(1, 0, 0, #items * 30)
            listHolder.BackgroundTransparency = 1
            listHolder.ZIndex = 2
            listHolder.Parent = dd
            local llist = Instance.new("UIListLayout")
            llist.Padding = UDim.new(0, 2)
            llist.Parent = listHolder

            for _, item in ipairs(items) do
                local ib = Instance.new("TextButton")
                ib.Size = UDim2.new(1, -8, 0, 28)
                ib.BackgroundColor3 = Theme.BgLight
                ib.BorderSizePixel = 0
                ib.AutoButtonColor = false
                ib.Font = Enum.Font.Gotham
                ib.Text = "  " .. tostring(item)
                ib.TextColor3 = (item == current) and Theme.Accent() or Theme.Text
                ib.TextSize = 12
                ib.TextXAlignment = Enum.TextXAlignment.Left
                ib.ZIndex = 2
                ib.Parent = listHolder
                Corner(ib, 5)
                ib.MouseButton1Click:Connect(function()
                    current = item
                    dl.Text = name .. ": " .. tostring(item)
                    open = false
                    Tween(dd, 0.2, {Size = UDim2.new(1, 0, 0, 34)})
                    Tween(arrow, 0.2, {Rotation = 180})
                    local ok, err = pcall(callback, item)
                    if not ok then Uranium.Notify("Error", tostring(err), 6) end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    Tween(dd, 0.2, {Size = UDim2.new(1, 0, 0, 34 + #items * 30)})
                    Tween(arrow, 0.2, {Rotation = 0})
                else
                    Tween(dd, 0.2, {Size = UDim2.new(1, 0, 0, 34)})
                    Tween(arrow, 0.2, {Rotation = 180})
                end
            end)

            if default then pcall(callback, default) end
            local obj = {}
            function obj:Set(v) current = v dl.Text = name .. ": " .. tostring(v) end
            return obj
        end

        function sec:Keybind(name, default, callback)
            local binding = false
            local currentKey = default or Enum.KeyCode.Unknown
            local kb = Instance.new("TextButton")
            kb.Size = UDim2.new(1, 0, 0, 34)
            kb.BackgroundColor3 = Theme.BgInput
            kb.BorderSizePixel = 0
            kb.AutoButtonColor = false
            kb.Text = ""
            kb.LayoutOrder = nextOrder()
            kb.Parent = list
            Corner(kb, 6)

            local kl = Instance.new("TextLabel")
            kl.BackgroundTransparency = 1
            kl.Position = UDim2.new(0, 10, 0, 0)
            kl.Size = UDim2.new(1, -90, 1, 0)
            kl.Font = Enum.Font.Gotham
            kl.Text = name
            kl.TextColor3 = Theme.Text
            kl.TextSize = 12
            kl.TextXAlignment = Enum.TextXAlignment.Left
            kl.Parent = kb

            local kbox = Instance.new("TextLabel")
            kbox.AnchorPoint = Vector2.new(1, 0.5)
            kbox.Position = UDim2.new(1, -8, 0.5, 0)
            kbox.Size = UDim2.new(0, 70, 0, 22)
            kbox.BackgroundColor3 = Theme.Bg:Lerp(Color3.new(0,0,0), 0.25)
            kbox.Font = Enum.Font.GothamBold
            kbox.Text = binding and "..." or (currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None")
            kbox.TextColor3 = binding and Theme.Accent() or Theme.TextDim
            kbox.TextSize = 11
            kbox.Parent = kb
            Corner(kbox, 5)

            kb.MouseButton1Click:Connect(function()
                binding = true
                kbox.Text = "..."
                kbox.TextColor3 = Theme.Accent()
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    binding = false
                    kbox.Text = currentKey.Name
                    kbox.TextColor3 = Theme.TextDim
                elseif input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                    local ok, err = pcall(callback, currentKey)
                    if not ok then Uranium.Notify("Error", tostring(err), 6) end
                end
            end)

            local obj = {}
            function obj:Get() return currentKey end
            return obj
        end

        function sec:TextInput(name, default, callback)
            local ti = Instance.new("Frame")
            ti.Size = UDim2.new(1, 0, 0, 34)
            ti.BackgroundColor3 = Theme.BgInput
            ti.BorderSizePixel = 0
            ti.LayoutOrder = nextOrder()
            ti.Parent = list
            Corner(ti, 6)
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -20, 1, 0)
            box.Position = UDim2.new(0, 10, 0, 0)
            box.BackgroundTransparency = 1
            box.Font = Enum.Font.Gotham
            box.Text = default or ""
            box.PlaceholderText = name
            box.PlaceholderColor3 = Theme.TextDim
            box.TextColor3 = Theme.Text
            box.TextSize = 12
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false
            box.Parent = ti
            box.FocusLost:Connect(function(enter)
                pcall(callback, box.Text)
            end)
            return box
        end

        table.insert(page.Sections, sec)
        return sec
    end

    table.insert(UI.Pages, page)
    if #UI.Pages == 1 then task.delay(0.05, function() page:Select() end) end
    return page
end

-- search filtering
local function SetupSearch()
    UI.Search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = UI.Search.Text:lower()
        for _, p in ipairs(UI.Pages) do
            local match = p.Name:lower():find(q, 1, true) ~= nil
            p.Button.Visible = match or q == ""
        end
    end)
end

--=======================================================================
-- NOTIFICATIONS + CONFIRM POPUP (native)
--=======================================================================
local notifHolder
local function BuildNotifHolder()
    local g = Instance.new("ScreenGui")
    g.Name = "UraniumNotifications"
    g.ResetOnSpawn = false
    pcall(function() g.Parent = Parent() end)
    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.Position = UDim2.new(1, -12, 0, 12)
    holder.Size = UDim2.new(0, 290, 1, -24)
    holder.BackgroundTransparency = 1
    holder.Parent = g
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = holder
    notifHolder = holder
end

function Uranium.Notify(title, desc, time)
    if not notifHolder then BuildNotifHolder() end
    time = time or 4

    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 0)
    n.AutomaticSize = Enum.AutomaticSize.Y
    n.BackgroundColor3 = Theme.BgLight
    n.BorderSizePixel = 0
    n.Parent = notifHolder
    Corner(n, 8)
    Stroke(n, Theme.Stroke, 1)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = Theme.Accent()
    accent.BorderSizePixel = 0
    accent.ZIndex = 2
    accent.Parent = n
    Corner(accent, 2)

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0, 14, 0, 8)
    t.Size = UDim2.new(1, -50, 0, 16)
    t.Font = Enum.Font.GothamBold
    t.Text = title or "Uranium"
    t.TextColor3 = Theme.Text
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = n

    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1
    d.Position = UDim2.new(0, 14, 0, 26)
    d.Size = UDim2.new(1, -50, 0, 0)
    d.AutomaticSize = Enum.AutomaticSize.Y
    d.Font = Enum.Font.Gotham
    d.Text = desc or ""
    d.TextWrapped = true
    d.TextColor3 = Theme.TextDim
    d.TextSize = 12
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Parent = n

    local timer = Instance.new("Frame")
    timer.Position = UDim2.new(0, 0, 1, -2)
    timer.Size = UDim2.new(1, 0, 0, 2)
    timer.BackgroundColor3 = Theme.Accent()
    timer.BorderSizePixel = 0
    timer.Parent = n
    Corner(timer, 1)

    n.Size = UDim2.new(0, 0, 0, 0)
    Tween(n, 0.3, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 0})
    Tween(timer, time, {Size = UDim2.new(0, 0, 0, 2)})
    task.delay(time, function()
        Tween(n, 0.3, {BackgroundTransparency = 1})
        Tween(t, 0.3, {TextTransparency = 1})
        Tween(d, 0.3, {TextTransparency = 1})
        task.delay(0.35, function() n:Destroy() end)
    end)
end

function Uranium.ConfirmPopup(title, description, options, callback)
    -- options = { {Text="Yes", Primary=true}, ... }
    local g = Instance.new("ScreenGui")
    g.Name = "UraniumPopup"
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    pcall(function() g.Parent = Parent() end)

    local dim = Instance.new("Frame")
    dim.Size = UDim2.new(1, 0, 1, 0)
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 1
    dim.BorderSizePixel = 0
    dim.Parent = g
    Tween(dim, 0.2, {BackgroundTransparency = 0.45})

    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.new(0.5, 0, 0.5, 0)
    f.Size = UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = Theme.Bg
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = g
    Corner(f, 10)
    Stroke(f, Theme.Accent(), 1)
    Tween(f, 0.35, {Size = UDim2.new(0, 360, 0, 190)})

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0, 16, 0, 14)
    t.Size = UDim2.new(1, -32, 0, 20)
    t.Font = Enum.Font.GothamBold
    t.Text = title
    t.TextColor3 = Theme.Accent()
    t.TextSize = 15
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = f

    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1
    d.Position = UDim2.new(0, 16, 0, 40)
    d.Size = UDim2.new(1, -32, 0, 80)
    d.Font = Enum.Font.Gotham
    d.Text = description
    d.TextWrapped = true
    d.TextColor3 = Theme.Text
    d.TextSize = 13
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Parent = f

    local btnRow = Instance.new("Frame")
    btnRow.Position = UDim2.new(0, 16, 1, -56)
    btnRow.Size = UDim2.new(1, -32, 0, 40)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent = f
    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.Padding = UDim.new(0, 8)
    rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rowLayout.Parent = btnRow

    local done = false
    for _, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, opt.Width or 90, 1, 0)
        b.BackgroundColor3 = opt.Primary and Theme.Accent() or Theme.BgInput
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Font = Enum.Font.GothamBold
        b.Text = opt.Text
        b.TextColor3 = opt.Primary and Color3.new(1,1,1) or Theme.Text
        b.TextSize = 12
        b.Parent = btnRow
        Corner(b, 7)
        b.MouseEnter:Connect(function() Tween(b, 0.15, {BackgroundColor3 = opt.Primary and Theme.Accent():Lerp(Color3.new(1,1,1), 0.15) or Theme.BgInput:Lerp(Color3.new(1,1,1), 0.06)}) end)
        b.MouseLeave:Connect(function() Tween(b, 0.15, {BackgroundColor3 = opt.Primary and Theme.Accent() or Theme.BgInput}) end)
        b.MouseButton1Click:Connect(function()
            if done then return end
            done = true
            Tween(f, 0.2, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
            Tween(dim, 0.2, {BackgroundTransparency = 1})
            task.delay(0.25, function() g:Destroy() end)
            pcall(callback, opt.Value or opt.Text)
        end)
    end
end

--=======================================================================
-- GAME DETECTION
--=======================================================================
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
        warn("[Uranium] source failed:", src.Name, err)
        Uranium.Notify("Error", src.Name .. ": " .. tostring(err), 7)
    end
end

function Uranium.AutoDetect()
    local placeId = game.PlaceId
    local supported = Uranium.GetSupported(placeId)

    if #supported == 0 then
        Uranium.Notify("Uranium", "Game not supported yet.\nRunning in universal mode.", 6)
        return
    end

    local auto = Uranium.Config.AutoRun
    if auto[tostring(placeId)] == true then
        for _, src in ipairs(supported) do Uranium.RunSource(src) end
        Uranium.Notify("Uranium", "Auto-executed: " .. supported[1].Name, 4)
        return
    end

    local names = {}
    for _, s in ipairs(supported) do table.insert(names, s.Name) end

    Uranium.ConfirmPopup(
        "Game Detected",
        "This game is supported by Uranium:\n" .. table.concat(names, ", ") .. "\n\nDo you want to load the script?",
        {
            { Text = "Yes", Primary = true, Value = "yes", Width = 80 },
            { Text = "No", Value = "no", Width = 70 },
            { Text = "Always", Value = "always", Width = 90 },
        },
        function(answer)
            if answer == "always" then
                Uranium.Config.AutoRun[tostring(placeId)] = true
                SaveConfig()
            end
            if answer == "yes" or answer == "always" then
                for _, src in ipairs(supported) do Uranium.RunSource(src) end
                Uranium.Notify("Uranium", "Loading " .. table.concat(names, ", ") .. "...", 4)
            else
                Uranium.Notify("Uranium", "Skipped. You can load it manually from its page.", 5)
            end
        end
    )
end

--=======================================================================
-- BUILD
--=======================================================================
function Uranium.Build()
    BuildWindow()
    BuildNotifHolder()
    SetupSearch()

    -- Settings page
    local settings = UI.Page("Settings", "⚙")

    local uiSec = settings:Section("Interface")
    uiSec:Label("Customize the Uranium interface.")

    local presets = {
        { Name = "Uranium Blue",   C = { 99, 155, 255 } },
        { Name = "Emerald",        C = { 80, 220, 140 } },
        { Name = "Crimson",        C = { 235, 80, 95 } },
        { Name = "Violet",         C = { 160, 110, 255 } },
        { Name = "Amber",          C = { 255, 180, 60 } },
        { Name = "Cyan",           C = { 60, 210, 230 } },
        { Name = "Rose",           C = { 255, 105, 180 } },
    }
    local presetNames = {}
    for _, p in ipairs(presets) do table.insert(presetNames, p.Name) end

    local currentName = "Custom"
    for _, p in ipairs(presets) do
        if p.C[1] == Uranium.Config.Accent[1] and p.C[2] == Uranium.Config.Accent[2] and p.C[3] == Uranium.Config.Accent[3] then
            currentName = p.Name
        end
    end

    uiSec:Dropdown("Accent Color", presetNames, currentName, function(v)
        for _, p in ipairs(presets) do
            if p.Name == v then
                Uranium.Config.Accent = p.C
                SaveConfig()
                Uranium.Notify("Uranium", "Accent set to " .. v .. ".\nRe-execute to fully apply.", 5)
            end
        end
    end)

    uiSec:Slider("UI Scale", 70, 130, 100, function(v)
        local scale = v / 100
        pcall(function() UI.Main.Size = UDim2.new(0, 620 * scale, 0, 400 * scale) end)
    end, 0)

    local toggleBind = uiSec:Keybind("Toggle UI", Enum.KeyCode.RightShift, function()
        UI.Open = not UI.Open
        pcall(function()
            if UI.Open then
                UI.Main.Visible = true
                Tween(UI.Main, 0.3, {Size = UDim2.new(0, 620, 0, 400)})
            else
                Tween(UI.Main, 0.25, {Size = UDim2.new(0, 620, 0, 46)})
            end
        end)
    end)

    local detSec = settings:Section("Detection")
    detSec:Button("Re-detect Current Game", function()
        Uranium.AutoDetect()
    end)
    detSec:Button("Clear Saved Answers", function()
        Uranium.Config.AutoRun = {}
        SaveConfig()
        Uranium.Notify("Uranium", "Saved answers cleared.\nYou will be asked again.", 4)
    end)

    local aboutSec = settings:Section("About")
    aboutSec:Label("Uranium Hub v" .. Uranium.Version .. "\nRepo: Korsac2026/12345\nCustom engine — zero external UI libraries.")
    aboutSec:Button("Re-execute Hub", function()
        pcall(function() loadstring(game:HttpGet(REPO .. "/Uranium.lua"))() end)
    end)
    aboutSec:Button("Destroy UI", function()
        pcall(function() UI.Gui:Destroy() end)
        pcall(function() notifHolder.Parent:Destroy() end)
    end)

    -- Player page (universal utilities)
    local playerPg = UI.Page("Player", "P")
    local moveSec = playerPg:Section("Movement")
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
    local char

    moveSec:Slider("Walk Speed", 16, 400, 16, function(v)
        pcall(function() LP.Character.Humanoid.WalkSpeed = v end)
    end)
    moveSec:Slider("Jump Power", 50, 500, 50, function(v)
        pcall(function() LP.Character.Humanoid.JumpPower = v end)
    end)

    local infJump = false
    moveSec:Toggle("Infinite Jump", false, function(v) infJump = v end)
    UserInputService.JumpRequest:Connect(function()
        if infJump then
            pcall(function() LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
    end)

    local noClip = false
    moveSec:Toggle("NoClip", false, function(v) noClip = v end)
    game:GetService("RunService").Stepped:Connect(function()
        if noClip then
            pcall(function()
                for _, p in ipairs(LP.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end)
        end
    end)

    local flySec = playerPg:Section("Visual")
    flySec:Slider("Field of View", 30, 120, 70, function(v)
        pcall(function() game:GetService("Workspace").CurrentCamera.FieldOfView = v end)
    end)
    flySec:Toggle("Fullbright", false, function(v)
        if v then
            local Lighting = game:GetService("Lighting")
            Uranium._oldLight = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
            }
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1e6
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.new(1, 1, 1)
        elseif Uranium._oldLight then
            local Lighting = game:GetService("Lighting")
            for k, val in pairs(Uranium._oldLight) do
                pcall(function() Lighting[k] = val end)
            end
        end
    end)

    -- supported game sources get their pages built if user confirmed or answered
    local placeId = game.PlaceId
    local supported = Uranium.GetSupported(placeId)
    for _, src in ipairs(supported) do
        local auto = Uranium.Config.AutoRun[tostring(placeId)] == true
        if auto then Uranium.RunSource(src) end
    end

    -- unsupported info page
    if #supported == 0 then
        local main = UI.Page("Main", "M")
        local sec = main:Section("Uranium")
        local gameName = "Unknown"
        pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name end)
        sec:Label("Game: " .. gameName .. "\nPlaceId: " .. placeId .. "\n\nThis game has no scripts yet.\nSupported games:\n• Blox Fruits\n• Operation One\n\nMore coming soon.")
    end

    -- auto detect after build
    task.delay(0.75, function() Uranium.AutoDetect() end)
end

--=======================================================================
-- GAME SOURCES
--=======================================================================

Uranium.RegisterSource("Uranium Blox Fruits", { 2753915549, 4442272183, 7449423635 }, function()
    local pg = UI.Page("Blox Fruits", "B")
    local sec = pg:Section("Uranium Blox Fruits")

    sec:Dropdown("Team", { "Pirates", "Marines" }, "Pirates", function(v)
        getgenv().Team = v
    end)
    sec:Toggle("Auto Attack", true, function(v) getgenv().UraniumBF_AutoAttack = v end)
    sec:Slider("Fast Attack Delay", 0, 2, 0, function(v) getgenv().UraniumBF_Delay = v end, 1)
    sec:Toggle("Attack Mobs", true, function(v) getgenv().UraniumBF_Mobs = v end)
    sec:Toggle("Bring Monster", true, function(v) getgenv().UraniumBF_Bring = v end)
    sec:Slider("Bring Radius", 50, 1000, 250, function(v) getgenv().UraniumBF_Radius = v end)

    local sec2 = pg:Section("Full Script")
    sec2:Button("Load from Repo", function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(REPO .. "/src/uranium/dumps/bloxfruits_deob.lua"))()
        end)
        if ok then Uranium.Notify("Uranium", "Blox Fruits script loaded.", 4)
        else Uranium.Notify("Uranium", "Load error: " .. tostring(err), 7) end
    end)
    sec2:Button("Download to Disk", function()
        local ok, res = pcall(function() return game:HttpGet(REPO .. "/src/uranium/dumps/bloxfruits_deob.lua", true) end)
        if ok and res and #res > 1000 then
            writefile("uranium/dumps/bloxfruits_deob.lua", res)
            Uranium.Notify("Uranium", "Saved to disk (" .. #res .. " bytes).", 5)
        else Uranium.Notify("Uranium", "Download failed.", 5) end
    end)
    sec2:Button("Load from Disk", function()
        if isfile("uranium/dumps/bloxfruits_deob.lua") then
            local ok, err = pcall(function() loadstring(readfile("uranium/dumps/bloxfruits_deob.lua"))() end)
            if ok then Uranium.Notify("Uranium", "Loaded from disk.", 4)
            else Uranium.Notify("Uranium", "Error: " .. tostring(err), 7) end
        else Uranium.Notify("Uranium", "Not on disk yet.", 5) end
    end)
end)

Uranium.RegisterSource("Uranium Operation One", { 253832, 6229116934 }, function()
    local pg = UI.Page("Operation One", "O")
    local sec = pg:Section("Uranium Operation One")
    sec:Label("Dumped payload from the Operation One loader (Astro).\nNo key system, no anti-tamper, no rejoin kick.\nThe original script runs fully with its own GUI (Obsidian).")

    local sec2 = pg:Section("Load")
    sec2:Button("Execute from Repo", function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(REPO .. "/src/uranium/dumps/operationone_dump.lua"))()
        end)
        if ok then Uranium.Notify("Uranium", "Operation One loaded.", 4)
        else Uranium.Notify("Uranium", "Error: " .. tostring(err), 7) end
    end)
    sec2:Button("Download to Disk", function()
        local ok, res = pcall(function() return game:HttpGet(REPO .. "/src/uranium/dumps/operationone_dump.lua", true) end)
        if ok and res and #res > 10000 then
            writefile("uranium/dumps/operationone_dump.lua", res)
            Uranium.Notify("Uranium", "Saved to disk (" .. #res .. " bytes).", 5)
        else Uranium.Notify("Uranium", "Download failed.", 5) end
    end)
    sec2:Button("Execute from Disk", function()
        if isfile("uranium/dumps/operationone_dump.lua") then
            local ok, err = pcall(function() loadstring(readfile("uranium/dumps/operationone_dump.lua"))() end)
            if ok then Uranium.Notify("Uranium", "Loaded from disk.", 4)
            else Uranium.Notify("Uranium", "Error: " .. tostring(err), 7) end
        else Uranium.Notify("Uranium", "Not on disk yet.", 5) end
    end)
end)

--=======================================================================
-- BOOT
--=======================================================================
Uranium.Build()

Uranium.Notify("Uranium", "Hub loaded — v" .. Uranium.Version .. "\nPress RightShift to toggle UI.", 5)
shared.Uranium = Uranium
getgenv().Uranium = Uranium

return Uranium