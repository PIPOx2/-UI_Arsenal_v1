

local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")

-- ── Persistence ─────────────────────────────────────────────
local FOLDER, FILE = "ArsenalHub", "ArsenalHub/settings.json"
local canSave = writefile and readfile and isfile and isfolder and makefolder

_G.Settings = { Theme = "Fire", SizeX = 560, SizeY = 340 }

local function loadSettings()
    if not canSave then return end
    if not isfolder(FOLDER) then makefolder(FOLDER) end
    if not isfile(FILE) then
        writefile(FILE, HttpService:JSONEncode(_G.Settings))
    else
        local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(FILE))
        if ok and type(data) == "table" then
            for k, v in pairs(data) do _G.Settings[k] = v end
        else
            writefile(FILE, HttpService:JSONEncode(_G.Settings))
        end
    end
end

local saveCooldown = false
local function saveSettings()
    if not canSave or saveCooldown then return end
    saveCooldown = true
    pcall(writefile, FILE, HttpService:JSONEncode(_G.Settings))
    task.delay(0.5, function() saveCooldown = false end)
end

loadSettings()

-- ── Themes ──────────────────────────────────────────────────
local THEMES = {
    { name="Fire",    ac=Color3.fromHex"ff5f32", dk=Color3.fromHex"5a2110", bg=Color3.fromHex"0e0e10", pn=Color3.fromHex"141418", sb=Color3.fromHex"111114", cd=Color3.fromHex"1c1c21", su=Color3.fromHex"787890", br=Color3.fromHex"282830", sl=Color3.fromHex"26263a" },
    { name="Cyan",    ac=Color3.fromHex"00d4ff", dk=Color3.fromHex"003d4d", bg=Color3.fromHex"090d10", pn=Color3.fromHex"0e1418", sb=Color3.fromHex"0b1014", cd=Color3.fromHex"131c21", su=Color3.fromHex"6a8090", br=Color3.fromHex"1a2830", sl=Color3.fromHex"162030" },
    { name="Rose",    ac=Color3.fromHex"ff4d8f", dk=Color3.fromHex"5c0f2a", bg=Color3.fromHex"100a0d", pn=Color3.fromHex"180d12", sb=Color3.fromHex"130a0f", cd=Color3.fromHex"1f1118", su=Color3.fromHex"906070", br=Color3.fromHex"301020", sl=Color3.fromHex"28101a" },
    { name="Emerald", ac=Color3.fromHex"00e887", dk=Color3.fromHex"004d2a", bg=Color3.fromHex"08100d", pn=Color3.fromHex"0d1510", sb=Color3.fromHex"0a120e", cd=Color3.fromHex"111d16", su=Color3.fromHex"5a8070", br=Color3.fromHex"1a2820", sl=Color3.fromHex"152218" },
    { name="Violet",  ac=Color3.fromHex"9b6dff", dk=Color3.fromHex"2e1a66", bg=Color3.fromHex"0c0b12", pn=Color3.fromHex"121018", sb=Color3.fromHex"0f0d15", cd=Color3.fromHex"1a1826", su=Color3.fromHex"7868a0", br=Color3.fromHex"262234", sl=Color3.fromHex"201d30" },
    { name="Gold",    ac=Color3.fromHex"ffb800", dk=Color3.fromHex"4d3600", bg=Color3.fromHex"100f08", pn=Color3.fromHex"18160a", sb=Color3.fromHex"14120a", cd=Color3.fromHex"201d0e", su=Color3.fromHex"908050", br=Color3.fromHex"302a10", sl=Color3.fromHex"282210" },
    { name="Ice",     ac=Color3.fromHex"6ec6ff", dk=Color3.fromHex"0d2d45", bg=Color3.fromHex"080c12", pn=Color3.fromHex"0d1018", sb=Color3.fromHex"0a0e15", cd=Color3.fromHex"111620", su=Color3.fromHex"607080", br=Color3.fromHex"182030", sl=Color3.fromHex"142030" },
}

local TH = THEMES[1]
for _, t in ipairs(THEMES) do
    if t.name == _G.Settings.Theme then TH = t; break end
end
_G.Settings.Theme = TH.name

local WT = Color3.fromRGB(225, 225, 232)

-- ── Utility ──────────────────────────────────────────────────
local function tw(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function corner(r, p) local c = Instance.new("UICorner"); c.CornerRadius = r; c.Parent = p; return c end
local function stroke(color, thick, p) local s = Instance.new("UIStroke"); s.Color = color; s.Thickness = thick; s.Parent = p; return s end
local function padding(t, l, r, b, p)
    local u = Instance.new("UIPadding"); u.PaddingTop = UDim.new(0,t); u.PaddingLeft = UDim.new(0,l)
    u.PaddingRight = UDim.new(0,r); u.PaddingBottom = UDim.new(0,b); u.Parent = p; return u
end

local function hexToColor3(hex)
    hex = hex:gsub("^#", "")
    if #hex ~= 6 then return nil end
    local r, g, b = tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16)
    return (r and g and b) and Color3.fromRGB(r,g,b) or nil
end
local function color3ToHex(c)
    return string.format("%02X%02X%02X", math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
end
local function rgbToColor3(s)
    local r,g,b = s:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    r,g,b = tonumber(r), tonumber(g), tonumber(b)
    return (r and g and b) and Color3.fromRGB(math.clamp(r,0,255),math.clamp(g,0,255),math.clamp(b,0,255)) or nil
end
local function color3ToRgb(c)
    return math.round(c.R*255)..","..math.round(c.G*255)..","..math.round(c.B*255)
end

-- ── Input helpers (PC + Touch) ───────────────────────────────
local MOUSE   = { Enum.UserInputType.MouseButton1 }
local TOUCH   = { Enum.UserInputType.Touch }
local MOVE    = { Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch }

local function isPress(inp)  return inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch end
local function isMove(inp)   return inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch end
local function inputPos(inp) return inp.Position end

-- ── Theme registry ───────────────────────────────────────────
local themeListeners = {}
local function onTheme(fn) table.insert(themeListeners, fn) end
local function fireTheme()
    _G.Settings.Theme = TH.name
    saveSettings()
    for _, fn in ipairs(themeListeners) do pcall(fn, TH) end
end

-- ── New instance helper ──────────────────────────────────────
local function new(cls, props, parent)
    local o = Instance.new(cls)
    if props then for k, v in pairs(props) do o[k] = v end end
    if parent then o.Parent = parent end
    return o
end

-- ── Cleanup previous GUI ─────────────────────────────────────
pcall(function() CoreGui:FindFirstChild("ArsenalHub"):Destroy() end)

-- ============================================================
--  Library
-- ============================================================
local Library = {}

function Library:Window(title, sizeOverride)

    -- ── Root ScreenGui ───────────────────────────────────────
    local ui = new("ScreenGui", {
        Name = "ArsenalHub", ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false, DisplayOrder = 999
    }, CoreGui)

    -- ── Main Window Frame ────────────────────────────────────
    local Win = new("Frame", {
        Name = "Win", BackgroundColor3 = TH.bg, BorderSizePixel = 0,
        Position = UDim2.new(0.5,-230,0.5,-170),
        Size = sizeOverride or UDim2.new(0,_G.Settings.SizeX,0,_G.Settings.SizeY),
        Active = true, Draggable = true, ClipsDescendants = true
    }, ui)
    local winStroke = stroke(TH.br, 1.5, Win)

    -- Shadow
    new("ImageLabel", {
        BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(1,70,1,70), ZIndex=0,
        Image="rbxassetid://5554236805", ImageColor3=Color3.new(0,0,0),
        ImageTransparency=0.45, ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(23,23,277,277)
    }, Win)

    -- ── Title Bar ────────────────────────────────────────────
    local TBar = new("Frame", {
        BackgroundColor3=TH.pn, BorderSizePixel=0, Size=UDim2.new(1,0,0,44), ZIndex=3
    }, Win)
    new("Frame", { -- separator
        BackgroundColor3=TH.br, BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0), Size=UDim2.new(1,0,0,1)
    }, TBar)

    local AcDot = new("Frame", {
        BackgroundColor3=TH.ac, BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,14,0.5,0), Size=UDim2.new(0,9,0,9)
    }, TBar)
    corner(UDim.new(1,0), AcDot)

    new("TextLabel", {
        BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,28,0.5,0), Size=UDim2.new(1,-120,0,20),
        Font=Enum.Font.GothamBold, Text=title or "Arsenal Hub",
        TextColor3=WT, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
    }, TBar)

    local VerBadge = new("TextLabel", {
        BackgroundColor3=TH.dk, BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-14,0.5,0), Size=UDim2.new(0,44,0,20),
        Font=Enum.Font.GothamBold, Text="UI v3.0", TextColor3=TH.ac, TextSize=9
    }, TBar)
    corner(UDim.new(0,6), VerBadge)

    -- ── Sidebar ──────────────────────────────────────────────
    local Sidebar = new("Frame", {
        Name="Sidebar", BackgroundColor3=TH.sb, BorderSizePixel=0,
        Position=UDim2.new(0,0,0,45), Size=UDim2.new(0,104,1,-45), ClipsDescendants=false
    }, Win)
    new("Frame", {
        BackgroundColor3=TH.br, BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,1,1,0)
    }, Sidebar)

    local TabList = new("ScrollingFrame", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,1,-52),
        ClipsDescendants=true, ScrollBarThickness=0, ScrollingEnabled=true,
        CanvasSize=UDim2.new(0,0,0,0)
    }, Sidebar)
    local tabLayout = new("UIListLayout", {
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2)
    }, TabList)
    padding(8,0,0,0, TabList)
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0,0,0,tabLayout.AbsoluteContentSize.Y+16)
    end)

    local Indic = new("Frame", {
        Name="Indic", BackgroundColor3=TH.ac, BorderSizePixel=0,
        Position=UDim2.new(0,0,0,0), Size=UDim2.new(0,3,0,28), ZIndex=1
    }, Sidebar)
    corner(UDim.new(0,2), Indic)

    local PlayerCard = new("Frame", {
        BackgroundColor3=TH.pn, BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0), Size=UDim2.new(1,0,0,52)
    }, Sidebar)
    new("Frame", { BackgroundColor3=TH.br, BorderSizePixel=0, Size=UDim2.new(1,0,0,1) }, PlayerCard)
    new("TextLabel", {
        BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.4,0), Size=UDim2.new(1,-8,0,16),
        Font=Enum.Font.GothamBold, Text=Players.LocalPlayer.Name,
        TextColor3=WT, TextSize=10, TextTruncate=Enum.TextTruncate.AtEnd
    }, PlayerCard)
    new("TextLabel", {
        BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.72,0), Size=UDim2.new(1,-8,0,14),
        Font=Enum.Font.Gotham, Text="● online", TextColor3=Color3.fromRGB(72,210,120), TextSize=9
    }, PlayerCard)

    -- ── Content Area ─────────────────────────────────────────
    local Content = new("Frame", {
        Name="Content", BackgroundColor3=TH.pn, BorderSizePixel=0,
        Position=UDim2.new(0,101,0,45), Size=UDim2.new(1,-105,1,-45), ClipsDescendants=true
    }, Win)

    -- ── Resize Button ────────────────────────────────────────
    local ResizeBtn = new("ImageButton", {
        Name="Resize", BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,0,1,0), Size=UDim2.new(0,20,0,20),
        ZIndex=20, Image="rbxassetid://132603703878244", ImageColor3=TH.su,
        AutoButtonColor=false, Rotation=90
    }, Win)
    ResizeBtn.MouseEnter:Connect(function() tw(ResizeBtn,{ImageColor3=TH.ac},0.15) end)
    ResizeBtn.MouseLeave:Connect(function() tw(ResizeBtn,{ImageColor3=TH.su},0.15) end)

    do -- resize drag (PC + touch)
        local minW, minH = 280, 260
        local drag = false
        local sx, sy, smx, smy = 0, 0, 0, 0

        local function startResize(pos)
            drag = true
            sx, sy = Win.Size.X.Offset, Win.Size.Y.Offset
            smx, smy = pos.X, pos.Y
        end
        local function doResize(pos)
            if not drag then return end
            Win.Size = UDim2.new(0, math.max(minW, sx+(pos.X-smx)), 0, math.max(minH, sy+(pos.Y-smy)))
        end
        local function endResize()
            if not drag then return end
            drag = false
            _G.Settings.SizeX = Win.Size.X.Offset
            _G.Settings.SizeY = Win.Size.Y.Offset
            saveSettings()
        end

        ResizeBtn.InputBegan:Connect(function(inp)
            if isPress(inp) then startResize(inp.Position) end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if drag and isMove(inp) then doResize(inp.Position) end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if drag and isPress(inp) then endResize() end
        end)
    end

    -- ── Theme reactions ──────────────────────────────────────
    onTheme(function(t)
        tw(Win,        {BackgroundColor3=t.bg}, 0.22) ; winStroke.Color = t.br
        tw(TBar,       {BackgroundColor3=t.pn}, 0.22)
        tw(AcDot,      {BackgroundColor3=t.ac}, 0.22)
        tw(VerBadge,   {BackgroundColor3=t.dk, TextColor3=t.ac}, 0.22)
        tw(Sidebar,    {BackgroundColor3=t.sb}, 0.22)
        tw(Indic,      {BackgroundColor3=t.ac}, 0.22)
        tw(PlayerCard, {BackgroundColor3=t.pn}, 0.22)
        tw(Content,    {BackgroundColor3=t.pn}, 0.22)
        ResizeBtn.ImageColor3 = t.su
    end)

    -- ── Tab System ───────────────────────────────────────────
    local tabs       = {}   -- { btn, icon, lbl, page }
    local curIdx     = 0
    local curPage    = nil
    local transiting = false
    local DUR        = 0.14

    local function moveIndic(idx)
        local btn = tabs[idx] and tabs[idx].btn
        if not btn then return end
        local top  = math.floor((btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y) + (btn.AbsoluteSize.Y - btn.AbsoluteSize.Y*0.55)/2)
        local h2   = math.floor(btn.AbsoluteSize.Y * 0.55)
        tw(Indic, {Size=UDim2.new(0,3,0,h2)},    0.12, Enum.EasingStyle.Quad)
        tw(Indic, {Position=UDim2.new(0,0,0,top)},0.28, Enum.EasingStyle.Quint)
    end
    TabList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if curIdx == 0 then return end
        local btn = tabs[curIdx] and tabs[curIdx].btn
        if not btn then return end
        local top = math.floor((btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y) + (btn.AbsoluteSize.Y - btn.AbsoluteSize.Y*0.55)/2)
        local h2  = math.floor(btn.AbsoluteSize.Y * 0.55)
        Indic.Size     = UDim2.new(0,3,0,h2)
        Indic.Position = UDim2.new(0,0,0,top)
    end)

    local function resetPage(p)
        p.Visible = false; p.Position = UDim2.new(0,0,0,0)
        p.BackgroundTransparency = 0; p.CanvasPosition = Vector2.new(0,0)
    end

    local function switchPage(newIdx, newPage)
        if newIdx == curIdx then return end
        if transiting then
            if curPage then resetPage(curPage) end
            newPage.Position = UDim2.new(0,0,0,0); newPage.BackgroundTransparency = 0
            newPage.Visible = true; curIdx = newIdx; curPage = newPage; return
        end
        transiting = true
        local dir = newIdx > curIdx and 1 or -1
        local old = curPage; curPage = newPage; curIdx = newIdx

        if not old then
            newPage.Visible = true; newPage.Position = UDim2.new(0,0,0,0)
            newPage.BackgroundTransparency = 0; transiting = false; return
        end

        local ov = new("Frame", {
            BackgroundColor3=TH.pn, BackgroundTransparency=1, BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,0,0,dir*-20), ZIndex=100
        }, Content)
        tw(ov, {Position=UDim2.new(0,0,0,0), BackgroundTransparency=0}, DUR, Enum.EasingStyle.Sine)
        task.delay(DUR+0.02, function()
            resetPage(old)
            newPage.Position = UDim2.new(0,0,0,dir*10); newPage.BackgroundTransparency = 1; newPage.Visible = true
            tw(newPage, {Position=UDim2.new(0,0,0,0), BackgroundTransparency=0}, DUR, Enum.EasingStyle.Quad)
            tw(ov, {Position=UDim2.new(0,0,0,dir*20), BackgroundTransparency=1}, DUR+0.04, Enum.EasingStyle.Sine)
            task.delay(DUR+0.06, function() ov:Destroy(); transiting = false end)
        end)
    end

    -- ── Tab Builder ──────────────────────────────────────────
    local Tabs = {}
    function Tabs:Tab(tabName, tabIcon)

        local TabBtn = new("TextButton", {
            Name=tabName, BackgroundColor3=WT, BackgroundTransparency=1, BorderSizePixel=0,
            Size=UDim2.new(1,0,0,50), AutoButtonColor=false, Text="", ZIndex=2
        }, TabList)
        corner(UDim.new(0,7), TabBtn)

        local TIcon = new("ImageLabel", {
            Name="TIcon", BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0),
            Position=UDim2.new(0.5,0,0,8), Size=UDim2.new(0,20,0,20),
            ScaleType=Enum.ScaleType.Fit, Image="rbxassetid://"..tabIcon, ImageColor3=TH.su, ZIndex=3
        }, TabBtn)

        local TLbl = new("TextLabel", {
            Name="TLbl", BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,1),
            Position=UDim2.new(0.5,0,1,-6), Size=UDim2.new(1,-4,0,11),
            Font=Enum.Font.GothamSemibold, Text=tabName, TextColor3=TH.su,
            TextSize=10, TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=3
        }, TabBtn)

        local Page = new("ScrollingFrame", {
            Name="Page_"..tabName, BackgroundColor3=TH.pn, BackgroundTransparency=0,
            BorderSizePixel=0, Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,0,1,0),
            Visible=false, Active=true, ScrollBarThickness=3, ScrollBarImageColor3=WT,
            CanvasSize=UDim2.new(0,0,0,0)
        }, Content)
        local pgLayout = new("UIListLayout", {
            HorizontalAlignment=Enum.HorizontalAlignment.Left,
            SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4)
        }, Page)
        padding(10,14,14,20, Page)
        pgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,pgLayout.AbsoluteContentSize.Y+32)
        end)

        local myIdx = #tabs + 1
        table.insert(tabs, { btn=TabBtn, icon=TIcon, lbl=TLbl })

        local function activate()
            for _, t in ipairs(tabs) do
                tw(t.btn,  {BackgroundTransparency=1},      0.15)
                tw(t.icon, {ImageColor3=TH.su},             0.15)
                tw(t.lbl,  {TextColor3=TH.su},              0.15)
            end
            tw(TabBtn, {BackgroundColor3=TH.dk, BackgroundTransparency=0}, 0.15)
            tw(TIcon,  {ImageColor3=WT},  0.15)
            tw(TLbl,   {TextColor3=WT},   0.15)
            task.defer(function() moveIndic(myIdx) end)
            switchPage(myIdx, Page)
        end

        TabBtn.MouseButton1Click:Connect(activate)
        TabBtn.MouseEnter:Connect(function()
            if curIdx ~= myIdx then
                tw(TabBtn,{BackgroundColor3=TH.dk, BackgroundTransparency=0.6},0.15)
                tw(TIcon, {ImageColor3=WT},0.15); tw(TLbl,{TextColor3=WT},0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if curIdx ~= myIdx then
                tw(TabBtn,{BackgroundTransparency=1},0.15)
                tw(TIcon, {ImageColor3=TH.su},0.15); tw(TLbl,{TextColor3=TH.su},0.15)
            end
        end)

        onTheme(function(t)
            tw(Page, {BackgroundColor3=t.pn}, 0.22)
            if curIdx == myIdx then
                tw(TabBtn,{BackgroundColor3=t.dk},0.22)
                tw(TIcon, {ImageColor3=WT},       0.22)
                tw(TLbl,  {TextColor3=WT},         0.22)
            else
                tw(TIcon,{ImageColor3=t.su},0.22)
                tw(TLbl, {TextColor3=t.su}, 0.22)
            end
        end)

        if myIdx == 1 then task.defer(activate) end

        -- ── Element Builders ─────────────────────────────────
        local E = {}

        -- Section
        function E:Section(text)
            local s = new("TextLabel", {
                Name="Section", BackgroundTransparency=1, BorderSizePixel=0,
                Size=UDim2.new(1,-28,0,20), Font=Enum.Font.GothamBold,
                Text=(text or "Section"):upper(), TextColor3=TH.ac, TextSize=9,
                TextXAlignment=Enum.TextXAlignment.Left
            }, Page)
            padding(8,0,0,0, s)
            local line = new("Frame", {
                BackgroundColor3=TH.br, BorderSizePixel=0,
                AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0), Size=UDim2.new(1,0,0,1)
            }, s)
            onTheme(function(t) tw(s,{TextColor3=t.ac},0.22); tw(line,{BackgroundColor3=t.br},0.22) end)
        end

        -- Toggle (switch style)
        function E:Toggle(label, default, callback)
            callback = callback or function() end
            local on = default == true

            local Row = new("Frame", {
                Name="Toggle", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,-28,0,30)
            }, Page)
            new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,4,0,0), Size=UDim2.new(1,-50,1,0),
                Font=Enum.Font.Gotham, Text=label or "Toggle", TextColor3=WT, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left
            }, Row)

            local Track = new("TextButton", {
                BackgroundColor3=on and TH.ac or TH.sl, BorderSizePixel=0,
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
                Size=UDim2.new(0,40,0,20), AutoButtonColor=false, Text=""
            }, Row)
            corner(UDim.new(1,0), Track)

            local Knob = new("Frame", {
                BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
                AnchorPoint=Vector2.new(0,0.5),
                Position=on and UDim2.new(0,22,0.5,0) or UDim2.new(0,2,0.5,0),
                Size=UDim2.new(0,16,0,16)
            }, Track)
            corner(UDim.new(1,0), Knob)

            onTheme(function(t) tw(Track,{BackgroundColor3=on and t.ac or t.sl},0.22) end)

            Track.MouseButton1Down:Connect(function()
                tw(Track,{Size=UDim2.new(0,38,0,18)},0.08,Enum.EasingStyle.Sine)
                tw(Knob, {Position=UDim2.new(0,on and 16 or 2,0.5,0), Size=UDim2.new(0,22,0,16)},0.10,Enum.EasingStyle.Sine)
            end)
            Track.MouseButton1Click:Connect(function()
                on = not on
                tw(Track,{Size=UDim2.new(0,40,0,20), BackgroundColor3=on and TH.ac or TH.sl},0.15,Enum.EasingStyle.Sine)
                tw(Knob, {Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,on and 22 or 2,0.5,0)},0.17,Enum.EasingStyle.Sine)
                callback(on)
            end)
        end

        -- Toggle Button (checkbox style)
        function E:ToggleButton(label, default, callback)
            callback = callback or function() end
            local on = false

            local Row = new("Frame", {
                Name="ToggleButton", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,-28,0,30)
            }, Page)
            local HitBox = new("TextButton", {
                BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false
            }, Row)
            corner(UDim.new(0,4), HitBox)
            new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,4,0,0), Size=UDim2.new(1,-50,1,0),
                Font=Enum.Font.Gotham, Text=label or "Toggle", TextColor3=WT, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left
            }, HitBox)
            new("UITextSizeConstraint", { MaxTextSize=11 }, HitBox)

            local Box = new("ImageButton", {
                BackgroundColor3=Color3.fromRGB(20,20,20), BorderSizePixel=0,
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
                Size=UDim2.new(0,19,0,19), AutoButtonColor=false, Image="", ZIndex=2
            }, Row)
            corner(UDim.new(0,4), Box)
            local boxStroke = stroke(TH.ac, 1, Box)

            local Dot = new("Frame", {
                BackgroundColor3=TH.ac, BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
                Size=UDim2.new(0,0,0,0)
            }, Box)
            corner(UDim.new(0,2), Dot)

            onTheme(function(t) boxStroke.Color=t.ac; tw(Dot,{BackgroundColor3=t.ac},0.22) end)

            local function toggle()
                on = not on
                tw(Dot, {Size=on and UDim2.new(0,15,0,15) or UDim2.new(0,0,0,0)}, 0.17, Enum.EasingStyle.Sine)
                callback(on)
            end
            Box.MouseButton1Click:Connect(toggle)
            HitBox.MouseButton1Click:Connect(toggle)
            if default == true then task.delay(0.1, toggle) end
        end

        -- Slider
        function E:Slider(label, mn, mx, val, callback)
            callback = callback or function() end
            local cur = math.clamp(math.round(val), mn, mx)
            local dragging = false

            local Wrap = new("Frame", {
                Name="Slider", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,-28,0,28)
            }, Page)
            local wLayout = new("UIListLayout", {
                Parent=Wrap, FillDirection=Enum.FillDirection.Horizontal,
                SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Center,
                Padding=UDim.new(0,8)
            })

            local SLbl = new("TextLabel", {
                BackgroundTransparency=1, Size=UDim2.new(0,80,0,18), LayoutOrder=1,
                Font=Enum.Font.Gotham, Text=label or "Slider", TextColor3=WT, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left
            }, Wrap)

            local TrackWrap = new("Frame", {
                BackgroundTransparency=1, Size=UDim2.new(1,-156,0,18), LayoutOrder=2
            }, Wrap)

            local Track = new("TextButton", {
                BackgroundColor3=TH.sl, BorderSizePixel=0,
                AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.5,0),
                Size=UDim2.new(1,0,0,5), AutoButtonColor=false, Text=""
            }, TrackWrap)
            corner(UDim.new(1,0), Track)

            local pct = (mx==mn) and 0 or (cur-mn)/(mx-mn)

            local Fill = new("Frame", {
                BackgroundColor3=TH.ac, BorderSizePixel=0, Size=UDim2.new(pct,0,1,0)
            }, Track)
            corner(UDim.new(1,0), Fill)

            local Knob = new("ImageButton", {
                BackgroundColor3=TH.ac, AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.new(pct,0,0.5,0), Size=UDim2.new(0,14,0,18),
                ZIndex=2, AutoButtonColor=false, Image="rbxassetid://90932274644195",
                ImageColor3=Color3.fromRGB(35,35,35), Active=true
            }, Track)
            corner(UDim.new(0,3), Knob)
            local knobStroke = stroke(TH.ac, 2, Knob)

            local ValBox = new("TextBox", {
                BackgroundTransparency=1, Size=UDim2.new(0,36,0,18), LayoutOrder=3,
                Font=Enum.Font.GothamBold, Text=tostring(cur), TextColor3=TH.ac,
                TextSize=11, TextXAlignment=Enum.TextXAlignment.Right, ClearTextOnFocus=false
            }, Wrap)

            local ResetBtn = new("ImageButton", {
                BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(0,20,0,20),
                LayoutOrder=4, AutoButtonColor=false, Image="rbxassetid://127886082324245",
                ImageColor3=TH.su, ZIndex=6
            }, Wrap)

            local function applyVal(v, instant)
                v = math.clamp(math.round(v), mn, mx)
                local rel = (mx==mn) and 0 or (v-mn)/(mx-mn)
                if instant then
                    Fill.Size = UDim2.new(rel,0,1,0); Knob.Position = UDim2.new(rel,0,0.5,0)
                else
                    tw(Fill,{Size=UDim2.new(rel,0,1,0)},0.15); tw(Knob,{Position=UDim2.new(rel,0,0.5,0)},0.15)
                end
                ValBox.Text = tostring(v); cur = v; callback(v)
            end

            local function slide(posX)
                local rel = math.clamp((posX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                applyVal(mn + (mx-mn)*rel, true)
            end

            local function startDrag(posX) dragging=true; tw(Knob,{Size=UDim2.new(0,15,0,20)},0.1); slide(posX) end
            local function endDrag()   dragging=false; tw(Knob,{Size=UDim2.new(0,14,0,18)},0.12,Enum.EasingStyle.Sine) end

            Track.InputBegan:Connect(function(inp) if isPress(inp) then startDrag(inp.Position.X) end end)
            Track.InputEnded:Connect(function(inp) if isPress(inp) then endDrag() end end)
            Knob.InputBegan:Connect(function(inp)  if isPress(inp) then startDrag(inp.Position.X) end end)
            Knob.InputEnded:Connect(function(inp)  if isPress(inp) then endDrag() end end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and isMove(inp) then slide(inp.Position.X) end
            end)

            Track.MouseEnter:Connect(function() if not dragging then tw(Knob,{Size=UDim2.new(0,15,0,20)},0.12,Enum.EasingStyle.Sine) end end)
            Track.MouseLeave:Connect(function() if not dragging then tw(Knob,{Size=UDim2.new(0,14,0,18)},0.12,Enum.EasingStyle.Sine) end end)

            ValBox:GetPropertyChangedSignal("Text"):Connect(function()
                ValBox.Text = ValBox.Text:gsub("[^%d%-]","")
            end)
            ValBox.FocusLost:Connect(function()
                local n = tonumber(ValBox.Text)
                if n then applyVal(n) else ValBox.Text = tostring(cur) end
            end)

            ResetBtn.MouseEnter:Connect(function()  tw(ResetBtn,{ImageColor3=TH.ac},0.12) end)
            ResetBtn.MouseLeave:Connect(function()  tw(ResetBtn,{ImageColor3=TH.su},0.12) end)
            ResetBtn.MouseButton1Click:Connect(function()
                applyVal(val)
                tw(ResetBtn,{ImageColor3=TH.ac},0.08)
                task.delay(0.3, function() tw(ResetBtn,{ImageColor3=TH.su},0.2) end)
            end)

            onTheme(function(t)
                tw(SLbl,     {TextColor3=t.su},      0.22)
                tw(ValBox,   {TextColor3=t.ac},      0.22)
                tw(ResetBtn, {ImageColor3=t.su},     0.22)
                tw(Track,    {BackgroundColor3=t.sl},0.22)
                tw(Fill,     {BackgroundColor3=t.ac},0.22)
                knobStroke.Color = t.ac; Knob.BackgroundColor3 = t.ac
            end)

            applyVal(cur)
        end

        -- Button
        function E:Button(label, callback)
            callback = callback or function() end

            local BtnWrap = new("Frame", {
                Name="ButtonWrap", BackgroundTransparency=1, BorderSizePixel=0,
                Size=UDim2.new(1,-28,0,28), ClipsDescendants=true
            }, Page)

            local Btn = new("TextButton", {
                BackgroundColor3=TH.cd, BorderSizePixel=0, Size=UDim2.new(1,0,1,0),
                AutoButtonColor=false, Font=Enum.Font.GothamBold,
                Text=label or "Button", TextColor3=TH.ac, TextSize=11, ZIndex=2
            }, BtnWrap)
            corner(UDim.new(0,7), Btn)
            local btnStroke = stroke(TH.br, 1, Btn)

            local Glow = new("Frame", {
                BackgroundColor3=TH.ac, BackgroundTransparency=1, BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
                Size=UDim2.new(0,0,0,0), ZIndex=1
            }, Btn)
            corner(UDim.new(1,0), Glow)

            local hov = false
            Btn.MouseEnter:Connect(function()
                hov = true
                tw(Btn,{BackgroundColor3=TH.dk, TextColor3=WT},0.18,Enum.EasingStyle.Sine)
                tw(btnStroke,{Color=TH.ac, Thickness=1.5},0.18,Enum.EasingStyle.Sine)
            end)
            Btn.MouseLeave:Connect(function()
                hov = false
                tw(Btn,{BackgroundColor3=TH.cd, TextColor3=TH.ac},0.22,Enum.EasingStyle.Sine)
                tw(btnStroke,{Color=TH.br, Thickness=1},0.22,Enum.EasingStyle.Sine)
            end)
            Btn.MouseButton1Down:Connect(function()
                tw(BtnWrap,{Size=UDim2.new(1,-28,0,24)},0.09,Enum.EasingStyle.Sine)
                tw(Btn,{BackgroundColor3=TH.ac, TextColor3=Color3.new(1,1,1)},0.09,Enum.EasingStyle.Sine)
                btnStroke.Color = TH.ac
                -- ripple
                Glow.BackgroundTransparency=0.55; Glow.Size=UDim2.new(0,0,0,0)
                tw(Glow,{Size=UDim2.new(2,0,4,0), BackgroundTransparency=1},0.45,Enum.EasingStyle.Quad)
            end)
            Btn.MouseButton1Click:Connect(function()
                tw(BtnWrap,{Size=UDim2.new(1,-28,0,30)},0.08,Enum.EasingStyle.Back)
                task.delay(0.08, function()
                    tw(BtnWrap,{Size=UDim2.new(1,-28,0,28)},0.14,Enum.EasingStyle.Bounce)
                end)
                if hov then
                    tw(Btn,{BackgroundColor3=TH.dk, TextColor3=WT},0.18)
                    btnStroke.Color=TH.ac; btnStroke.Thickness=1.5
                else
                    tw(Btn,{BackgroundColor3=TH.cd, TextColor3=TH.ac},0.18)
                    btnStroke.Color=TH.br; btnStroke.Thickness=1
                end
                callback()
            end)
            onTheme(function(t)
                if not hov then tw(Btn,{BackgroundColor3=t.cd, TextColor3=t.ac},0.22); btnStroke.Color=t.br end
                Glow.BackgroundColor3=t.ac
            end)
        end

        -- Keybind
        function E:Keybind(label, keyPreset, callback)
            callback = callback or function() end
            local key = (keyPreset and keyPreset.Name) or "E"

            local Row = new("Frame", {
                Name="Keybind", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,-28,0,30)
            }, Page)
            new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,4,0,0), Size=UDim2.new(1,-54,1,0),
                Font=Enum.Font.Gotham, Text=label or "Keybind", TextColor3=WT, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left
            }, Row)

            local Badge = new("TextButton", {
                BackgroundColor3=TH.sl, BorderSizePixel=0,
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
                Size=UDim2.new(0,44,0,20), AutoButtonColor=false,
                Font=Enum.Font.GothamBold, Text=key, TextColor3=WT, TextSize=11
            }, Row)
            corner(UDim.new(0,4), Badge)
            onTheme(function(t) tw(Badge,{BackgroundColor3=t.sl},0.22) end)

            local binding = false
            Badge.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true; Badge.Text = "..."; Badge.TextColor3 = TH.su
                local conn
                conn = UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe or inp.KeyCode == Enum.KeyCode.Unknown then return end
                    key = inp.KeyCode.Name; Badge.Text = key; Badge.TextColor3 = WT
                    binding = false; conn:Disconnect()
                end)
            end)
            UserInputService.InputBegan:Connect(function(inp, gpe)
                if not gpe and inp.KeyCode.Name == key then callback(key) end
            end)
        end

        -- Single Dropdown
        function E:Single(label, opts, default, callback)
            opts = opts or {}; callback = callback or function() end
            local curSel = default or opts[1]
            local open = false
            local optEls = {}

            local Wrap = new("Frame", {
                Name="Single", BackgroundTransparency=1, BorderSizePixel=0,
                Size=UDim2.new(1,-29,0,55), ClipsDescendants=true
            }, Page)

            new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,2,0,3), Size=UDim2.new(1,0,0,14),
                Font=Enum.Font.Gotham, Text=label or "Single", TextColor3=WT, TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Left
            }, Wrap)

            local DBtn = new("Frame", {
                Name="DBtn", BackgroundColor3=TH.cd, BorderSizePixel=0,
                Position=UDim2.new(0,1,0,18), Size=UDim2.new(0.99,0,0,30), AutomaticSize=Enum.AutomaticSize.Y
            }, Wrap)
            corner(UDim.new(0,6), DBtn)
            local dbStroke = stroke(TH.br, 1, DBtn)

            local Tags = new("Frame", {
                BackgroundTransparency=1, Position=UDim2.new(0,8,0,5),
                Size=UDim2.new(1,-30,0,20), AutomaticSize=Enum.AutomaticSize.Y
            }, DBtn)
            local tLayout = new("UIListLayout", {
                FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder,
                Padding=UDim.new(0,3), Wraps=true, HorizontalAlignment=Enum.HorizontalAlignment.Left
            }, Tags)

            local DArrow = new("ImageLabel", {
                BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.new(1,-16,0.5,0), Size=UDim2.new(0,16,0,16),
                Image="rbxassetid://71063555855798"
            }, DBtn)

            local DList = new("Frame", {
                Name="DList", BackgroundColor3=TH.cd, BorderSizePixel=0,
                Position=UDim2.new(0,1,0,51), Size=UDim2.new(1,0,0,0), ClipsDescendants=true
            }, Wrap)
            corner(UDim.new(0,6), DList)
            local dlStroke = stroke(TH.br, 1, DList); dlStroke.Transparency = 1
            new("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder }, DList)

            local fh = #opts * 28 + 6

            local function buildTag()
                for _, c in ipairs(Tags:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
                if curSel and curSel ~= "" then
                    local tw2 = new("Frame", {
                        BackgroundColor3=TH.dk, BorderSizePixel=0, AutomaticSize=Enum.AutomaticSize.X, Size=UDim2.new(0,0,0,18)
                    }, Tags)
                    corner(UDim.new(0,4), tw2)
                    local tl = new("UIListLayout", {
                        FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder,
                        VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,2)
                    }, tw2)
                    new("TextLabel", {
                        LayoutOrder=1, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
                        Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold,
                        Text=" "..curSel, TextColor3=WT, TextSize=10
                    }, tw2)
                    new("Frame", {LayoutOrder=3,BackgroundTransparency=1,Size=UDim2.new(0,3,1,0)}, tw2)
                    onTheme(function(t) tw(tw2,{BackgroundColor3=t.dk},0.22) end)
                else
                    new("TextLabel", {
                        BackgroundTransparency=1, Size=UDim2.new(0,0,0,18),
                        Font=Enum.Font.Gotham, Text="    —", TextColor3=TH.su, TextSize=11
                    }, Tags)
                end
            end
            buildTag()

            local function clearAll()
                for _, el in ipairs(optEls) do
                    el.selected = false
                    tw(el.radio,{BackgroundColor3=TH.sl},0.13); el.radioStroke.Color=TH.br
                    el.radioDot.TextTransparency=1; tw(el.otx,{TextColor3=TH.su},0.12)
                    el.btn.BackgroundTransparency=1; el.xbtn.Visible=false
                end
            end

            local function closeDD()
                open = false; dbStroke.Color = TH.br
                tw(DArrow,{Rotation=0},0.2); dlStroke.Transparency=1
                DList:TweenSize(UDim2.new(1,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                Wrap:TweenSize(UDim2.new(1,-29,0,55),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
            end

            local DBtnClick = new("TextButton", {
                BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0),
                Text="", AutoButtonColor=false, ZIndex=5
            }, DBtn)

            for _, opt in ipairs(opts) do
                local sel = opt == curSel
                local Item = new("TextButton", {
                    BackgroundColor3=TH.ac, BackgroundTransparency=sel and 0.88 or 1,
                    BorderSizePixel=0, Size=UDim2.new(1,0,0,28), AutoButtonColor=false, Text=""
                }, DList)
                corner(UDim.new(0,5), Item)

                local Radio = new("Frame", {
                    BackgroundColor3=sel and TH.ac or TH.sl, BorderSizePixel=0,
                    AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,10,0.5,0), Size=UDim2.new(0,13,0,13)
                }, Item)
                corner(UDim.new(0,3), Radio)
                local radioStroke = stroke(sel and TH.ac or TH.br, 1.5, Radio)

                local RadioDot = new("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                    Font=Enum.Font.GothamBold, Text="✓", TextColor3=Color3.new(1,1,1),
                    TextSize=9, TextTransparency=sel and 0 or 1
                }, Radio)

                local OTx = new("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.new(0,30,0,0), Size=UDim2.new(1,-56,1,0),
                    Font=Enum.Font.Gotham, Text=opt, TextColor3=sel and WT or TH.su,
                    TextSize=11, TextXAlignment=Enum.TextXAlignment.Left
                }, Item)

                local XBtn = new("ImageButton", {
                    BackgroundTransparency=1, BorderSizePixel=0, AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,-6,0.5,0), Size=UDim2.new(0,18,0,18),
                    Image="rbxassetid://107560529463028", ImageColor3=TH.su,
                    AutoButtonColor=false, ZIndex=10, Visible=sel
                }, Item)

                local el = { btn=Item, radio=Radio, radioStroke=radioStroke, radioDot=RadioDot, otx=OTx, xbtn=XBtn, selected=sel }
                table.insert(optEls, el)

                XBtn.MouseEnter:Connect(function() XBtn.ImageColor3=Color3.fromRGB(240,60,60) end)
                XBtn.MouseLeave:Connect(function() XBtn.ImageColor3=TH.su end)
                XBtn.MouseButton1Click:Connect(function()
                    curSel=""; clearAll(); buildTag(); callback("")
                end)
                Item.MouseEnter:Connect(function() if not el.selected then tw(Item,{BackgroundTransparency=0.94},0.12) end end)
                Item.MouseLeave:Connect(function() if not el.selected then tw(Item,{BackgroundTransparency=1},0.12) end end)
                Item.MouseButton1Click:Connect(function()
                    clearAll(); curSel=opt; el.selected=true
                    tw(el.radio,{BackgroundColor3=TH.ac},0.13); el.radioStroke.Color=TH.ac
                    el.radioDot.TextTransparency=0; tw(el.otx,{TextColor3=WT},0.12)
                    el.btn.BackgroundTransparency=0.88; el.xbtn.Visible=true
                    buildTag(); callback(opt); closeDD()
                end)
                onTheme(function(t)
                    tw(Item,{BackgroundColor3=t.ac},0.22)
                    if el.selected then
                        tw(el.radio,{BackgroundColor3=t.ac},0.22); el.radioStroke.Color=t.ac; tw(el.otx,{TextColor3=WT},0.22)
                    else
                        tw(el.radio,{BackgroundColor3=t.sl},0.22); el.radioStroke.Color=t.br; tw(el.otx,{TextColor3=t.su},0.22)
                    end
                end)
            end

            DBtnClick.MouseButton1Click:Connect(function()
                open = not open
                tw(DArrow,{Rotation=open and 180 or 0},0.2)
                dbStroke.Color = open and TH.ac or TH.br; dlStroke.Transparency = open and 0 or 1
                if open then
                    Wrap:TweenSize(UDim2.new(1,-29,0,55+2+fh),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                    DList:TweenSize(UDim2.new(0.99,0,0,fh),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                else
                    DList:TweenSize(UDim2.new(0.99,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                    Wrap:TweenSize(UDim2.new(1,-29,0,55),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                end
            end)
            onTheme(function(t)
                tw(DBtn,{BackgroundColor3=t.cd},0.22); tw(DList,{BackgroundColor3=t.cd},0.22)
                dbStroke.Color=open and t.ac or t.br; dlStroke.Color=t.br
            end)
        end

        -- Multi Dropdown
        function E:Multi(label, opts, defaults, callback)
            opts = opts or {}; defaults = defaults or {}; callback = callback or function() end
            local selected = {}
            for _, v in ipairs(defaults) do selected[v] = true end
            local open = false
            local chkEls = {}

            local Wrap = new("Frame", {
                Name="Multi", BackgroundTransparency=1, BorderSizePixel=0,
                Size=UDim2.new(1,-29,0,55), ClipsDescendants=true
            }, Page)
            new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,2,0,3), Size=UDim2.new(1,0,0,14),
                Font=Enum.Font.Gotham, Text=label or "Multi", TextColor3=WT, TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Left
            }, Wrap)

            local DBtn2 = new("Frame", {
                BackgroundColor3=TH.cd, BorderSizePixel=0, Position=UDim2.new(0,1,0,18),
                Size=UDim2.new(0.99,0,0,30), AutomaticSize=Enum.AutomaticSize.Y
            }, Wrap)
            corner(UDim.new(0,6), DBtn2)
            local db2Stroke = stroke(TH.br, 1, DBtn2)

            local Tags2 = new("Frame", {
                BackgroundTransparency=1, Position=UDim2.new(0,8,0,5),
                Size=UDim2.new(1,-30,0,20), AutomaticSize=Enum.AutomaticSize.Y
            }, DBtn2)
            new("UIListLayout", {
                FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder,
                Padding=UDim.new(0,3), Wraps=true, HorizontalAlignment=Enum.HorizontalAlignment.Left
            }, Tags2)

            new("ImageLabel", {
                BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.new(1,-16,0.5,0), Size=UDim2.new(0,16,0,16),
                Image="rbxassetid://71063555855798"
            }, DBtn2)

            local DList2 = new("Frame", {
                BackgroundColor3=TH.cd, BorderSizePixel=0,
                Position=UDim2.new(0,1,0,51), Size=UDim2.new(1,0,0,0), ClipsDescendants=true
            }, Wrap)
            corner(UDim.new(0,6), DList2)
            local dl2Stroke = stroke(TH.br, 1, DList2); dl2Stroke.Transparency = 1
            new("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder }, DList2)

            local fh2 = #opts * 28 + 6
            local DArrow2 -- declare for toggle

            local function rebuildTags()
                for _, c in ipairs(Tags2:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
                local any = false
                for _, opt in ipairs(opts) do
                    if selected[opt] then
                        any = true
                        local tw2 = new("Frame", {
                            BackgroundColor3=TH.dk, BorderSizePixel=0, AutomaticSize=Enum.AutomaticSize.X, Size=UDim2.new(0,0,0,18)
                        }, Tags2)
                        corner(UDim.new(0,4), tw2)
                        new("UIListLayout", {
                            FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder,
                            VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,2)
                        }, tw2)
                        new("TextLabel", {
                            LayoutOrder=1, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
                            Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold,
                            Text=" "..opt, TextColor3=WT, TextSize=10
                        }, tw2)
                        new("Frame", {LayoutOrder=3,BackgroundTransparency=1,Size=UDim2.new(0,3,1,0)}, tw2)
                        onTheme(function(t) tw(tw2,{BackgroundColor3=t.dk},0.22) end)
                    end
                end
                if not any then
                    new("TextLabel", {
                        BackgroundTransparency=1, Size=UDim2.new(0,0,0,18),
                        Font=Enum.Font.Gotham, Text="    —", TextColor3=TH.su, TextSize=11
                    }, Tags2)
                end
            end
            rebuildTags()

            local DBtnClick2 = new("TextButton", {
                BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0),
                Text="", AutoButtonColor=false, ZIndex=5
            }, DBtn2)
            DArrow2 = new("ImageLabel", {
                BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.new(1,-16,0.5,0), Size=UDim2.new(0,16,0,16),
                Image="rbxassetid://71063555855798"
            }, DBtn2)

            for _, opt in ipairs(opts) do
                local on2 = selected[opt] or false
                local Item = new("TextButton", {
                    BackgroundColor3=TH.ac, BackgroundTransparency=on2 and 0.88 or 1,
                    BorderSizePixel=0, Size=UDim2.new(1,0,0,28), AutoButtonColor=false, Text=""
                }, DList2)
                corner(UDim.new(0,5), Item)

                local ChkBox = new("Frame", {
                    BackgroundColor3=on2 and TH.ac or TH.sl, BorderSizePixel=0,
                    AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,10,0.5,0), Size=UDim2.new(0,13,0,13)
                }, Item)
                corner(UDim.new(0,3), ChkBox)
                local chkStroke = stroke(on2 and TH.ac or TH.br, 1.5, ChkBox)

                local ChkDot = new("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                    Font=Enum.Font.GothamBold, Text="✓", TextColor3=Color3.new(1,1,1),
                    TextSize=9, TextTransparency=on2 and 0 or 1
                }, ChkBox)

                local OTx2 = new("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.new(0,30,0,0), Size=UDim2.new(1,-36,1,0),
                    Font=Enum.Font.Gotham, Text=opt, TextColor3=on2 and WT or TH.su,
                    TextSize=11, TextXAlignment=Enum.TextXAlignment.Left
                }, Item)

                table.insert(chkEls, {box=ChkBox,stroke=chkStroke,dot=ChkDot,otx=OTx2,opt=opt})

                Item.MouseEnter:Connect(function() if not selected[opt] then tw(Item,{BackgroundTransparency=0.94},0.12) end end)
                Item.MouseLeave:Connect(function() if not selected[opt] then tw(Item,{BackgroundTransparency=1},0.12) end end)
                Item.MouseButton1Click:Connect(function()
                    selected[opt] = not selected[opt]
                    local s = selected[opt]
                    tw(ChkBox,{BackgroundColor3=s and TH.ac or TH.sl},0.13)
                    chkStroke.Color = s and TH.ac or TH.br
                    ChkDot.TextTransparency = s and 0 or 1
                    tw(OTx2,{TextColor3=s and WT or TH.su},0.12)
                    Item.BackgroundTransparency = s and 0.88 or 1
                    rebuildTags()
                    local t = {}; for k in pairs(selected) do t[#t+1]=k end; callback(t)
                end)
                onTheme(function(t)
                    tw(Item,{BackgroundColor3=t.dk},0.22)
                    local s = selected[opt]
                    tw(ChkBox,{BackgroundColor3=s and t.ac or t.sl},0.22); chkStroke.Color=s and t.ac or t.br
                end)
            end

            DBtnClick2.MouseButton1Click:Connect(function()
                open = not open
                tw(DArrow2,{Rotation=open and 180 or 0},0.2)
                db2Stroke.Color=open and TH.ac or TH.br; dl2Stroke.Transparency=open and 0 or 1
                if open then
                    Wrap:TweenSize(UDim2.new(1,-29,0,55+2+fh2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                    DList2:TweenSize(UDim2.new(0.99,0,0,fh2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                else
                    DList2:TweenSize(UDim2.new(0.99,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                    Wrap:TweenSize(UDim2.new(1,-29,0,55),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
                end
            end)
            onTheme(function(t)
                tw(DBtn2,{BackgroundColor3=t.cd},0.22); tw(DList2,{BackgroundColor3=t.cd},0.22)
                db2Stroke.Color=open and t.ac or t.br; dl2Stroke.Color=t.br
            end)
        end

        -- ColorPicker
        function E:ColorPicker(label, initColor, callback)
            callback = callback or function() end
            initColor = initColor or Color3.fromRGB(255,80,50)
            local h, s, v = Color3.toHSV(initColor)
            local pickerOpen = false
            local curColor   = initColor

            local Row = new("Frame", {
                Name="ColorPicker", BackgroundTransparency=1, BorderSizePixel=0,
                Size=UDim2.new(1,-28,0,30), ClipsDescendants=true
            }, Page)
            new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,4,0,0), Size=UDim2.new(1,-70,1,0),
                Font=Enum.Font.Gotham, Text=label or "Color", TextColor3=WT, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left
            }, Row)

            local Swatch = new("TextButton", {
                BackgroundColor3=curColor, BorderSizePixel=0,
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
                Size=UDim2.new(0,56,0,22), AutoButtonColor=false, Text=""
            }, Row)
            corner(UDim.new(0,5), Swatch)
            local swStroke = stroke(TH.br, 1, Swatch)

            local SwHex = new("TextLabel", {
                BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                Font=Enum.Font.GothamBold, Text="#"..color3ToHex(curColor),
                TextColor3=Color3.new(1,1,1), TextSize=8, TextStrokeTransparency=0.4
            }, Swatch)

            local PANEL_H = 228
            local Panel = new("Frame", {
                Name="CPPanel", BackgroundColor3=TH.cd, BorderSizePixel=0,
                Position=UDim2.new(0,0,1,4), Size=UDim2.new(1,0,0,0), ClipsDescendants=true
            }, Row)
            corner(UDim.new(0,8), Panel)
            local panelStroke = stroke(TH.br, 1, Panel)

            -- SV gradient
            local GradOuter = new("Frame", {
                BackgroundColor3=Color3.fromHSV(h,1,1), BorderSizePixel=0,
                Position=UDim2.new(0,10,0,10), Size=UDim2.new(1,-20,0,110)
            }, Panel)
            corner(UDim.new(0,6), GradOuter)

            local GS = new("Frame", {BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Size=UDim2.new(1,0,1,0)}, GradOuter)
            corner(UDim.new(0,6), GS)
            local gsSat = new("UIGradient", {Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1,0))}), Rotation=0}, GS)

            local GV = new("Frame", {BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Size=UDim2.new(1,0,1,0)}, GS)
            corner(UDim.new(0,6), GV)
            new("UIGradient", {Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}), Rotation=90}, GV)

            local PCursor = new("Frame", {
                BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(s,0,1-v,0),
                Size=UDim2.new(0,12,0,12), ZIndex=5
            }, GradOuter)
            corner(UDim.new(1,0), PCursor)
            stroke(Color3.new(0,0,0), 1.5, PCursor)

            local GBtn = new("TextButton", {BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=6}, GradOuter)

            -- Hue
            new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,10,0,128), Size=UDim2.new(0.5,0,0,14),
                Font=Enum.Font.Gotham, Text="Hue", TextColor3=TH.su, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left
            }, Panel)
            local HueTrack = new("TextButton", {
                BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
                Position=UDim2.new(0,10,0,144), Size=UDim2.new(1,-20,0,10),
                AutoButtonColor=false, Text=""
            }, Panel)
            corner(UDim.new(1,0), HueTrack)
            new("UIGradient", {Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
            })}, HueTrack)

            local HueKnob = new("Frame", {
                BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(h,0,0.5,0),
                Size=UDim2.new(0,14,0,14), ZIndex=2
            }, HueTrack)
            corner(UDim.new(1,0), HueKnob)
            local hkStroke = stroke(TH.br, 1.5, HueKnob)

            -- HEX / RGB labels
            for _, t in ipairs({{"HEX","Hex",0,10,162},{"RGB","Rgb",0.5,2,162}}) do
                new("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.new(t[3],t[4],0,t[5]), Size=UDim2.new(0.5,-12,0,14),
                    Font=Enum.Font.Gotham, Text=t[1], TextColor3=TH.su, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left
                }, Panel)
            end

            local HexBox = new("TextBox", {
                BackgroundColor3=TH.bg, BorderSizePixel=0,
                Position=UDim2.new(0,10,0,178), Size=UDim2.new(0.47,-2,0,22),
                Font=Enum.Font.GothamBold, Text="#"..color3ToHex(curColor), TextColor3=WT,
                TextSize=10, PlaceholderText="#RRGGBB", ClearTextOnFocus=false
            }, Panel)
            corner(UDim.new(0,5), HexBox)
            local hexStroke = stroke(TH.br, 1, HexBox)

            local RgbBox = new("TextBox", {
                BackgroundColor3=TH.bg, BorderSizePixel=0,
                Position=UDim2.new(0.5,2,0,178), Size=UDim2.new(0.5,-12,0,22),
                Font=Enum.Font.GothamBold, Text=color3ToRgb(curColor), TextColor3=WT,
                TextSize=10, PlaceholderText="R,G,B", ClearTextOnFocus=false
            }, Panel)
            corner(UDim.new(0,5), RgbBox)
            local rgbStroke = stroke(TH.br, 1, RgbBox)

            local function updateUI()
                curColor = Color3.fromHSV(h, s, v)
                GradOuter.BackgroundColor3 = Color3.fromHSV(h,1,1)
                PCursor.Position = UDim2.new(s,0,1-v,0)
                tw(Swatch,{BackgroundColor3=curColor},0.12)
                SwHex.Text = "#"..color3ToHex(curColor)
                if not HexBox:IsFocused() then HexBox.Text = "#"..color3ToHex(curColor) end
                if not RgbBox:IsFocused() then RgbBox.Text = color3ToRgb(curColor) end
                callback(curColor)
            end

            local gradDrag, hueDrag = false, false
            GBtn.InputBegan:Connect(function(inp)
                if not isPress(inp) then return end
                gradDrag = true
                local ap,az = GradOuter.AbsolutePosition, GradOuter.AbsoluteSize
                s = math.clamp((inp.Position.X-ap.X)/az.X,0,1); v = math.clamp(1-(inp.Position.Y-ap.Y)/az.Y,0,1); updateUI()
            end)
            GBtn.InputEnded:Connect(function(inp) if isPress(inp) then gradDrag=false end end)
            HueTrack.InputBegan:Connect(function(inp)
                if not isPress(inp) then return end
                hueDrag = true
                local ap,az = HueTrack.AbsolutePosition, HueTrack.AbsoluteSize
                h = math.clamp((inp.Position.X-ap.X)/az.X,0,1); HueKnob.Position=UDim2.new(h,0,0.5,0); updateUI()
            end)
            HueTrack.InputEnded:Connect(function(inp) if isPress(inp) then hueDrag=false end end)
            UserInputService.InputChanged:Connect(function(inp)
                if not isMove(inp) then return end
                if gradDrag then
                    local ap,az = GradOuter.AbsolutePosition, GradOuter.AbsoluteSize
                    s = math.clamp((inp.Position.X-ap.X)/az.X,0,1); v = math.clamp(1-(inp.Position.Y-ap.Y)/az.Y,0,1); updateUI()
                elseif hueDrag then
                    local ap,az = HueTrack.AbsolutePosition, HueTrack.AbsoluteSize
                    h = math.clamp((inp.Position.X-ap.X)/az.X,0,1); HueKnob.Position=UDim2.new(h,0,0.5,0); updateUI()
                end
            end)

            HexBox.FocusLost:Connect(function()
                local c = hexToColor3(HexBox.Text)
                if c then h,s,v=Color3.toHSV(c); HueKnob.Position=UDim2.new(h,0,0.5,0); updateUI(); hexStroke.Color=TH.br
                else hexStroke.Color=Color3.fromRGB(240,60,60) end
            end)
            RgbBox.FocusLost:Connect(function()
                local c = rgbToColor3(RgbBox.Text)
                if c then h,s,v=Color3.toHSV(c); HueKnob.Position=UDim2.new(h,0,0.5,0); updateUI(); rgbStroke.Color=TH.br
                else rgbStroke.Color=Color3.fromRGB(240,60,60) end
            end)

            Swatch.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    Row:TweenSize(UDim2.new(1,-28,0,30+PANEL_H+8),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.28,true)
                    Panel:TweenSize(UDim2.new(1,0,0,PANEL_H),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.28,true)
                else
                    Row:TweenSize(UDim2.new(1,-28,0,30),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.24,true)
                    Panel:TweenSize(UDim2.new(1,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.24,true)
                end
                tw(swStroke,{Color=pickerOpen and TH.ac or TH.br},0.14)
            end)

            onTheme(function(t)
                tw(Panel,  {BackgroundColor3=t.cd},0.22)
                tw(HexBox, {BackgroundColor3=t.bg},0.22); tw(RgbBox,{BackgroundColor3=t.bg},0.22)
                swStroke.Color=pickerOpen and t.ac or t.br; panelStroke.Color=t.br
                hexStroke.Color=t.br; rgbStroke.Color=t.br; hkStroke.Color=t.br
            end)

            updateUI()
        end

        -- ThemeSelector
        function E:ThemeSelector()
            if not _G._ArsenalCustomThemes then _G._ArsenalCustomThemes = {} end
            local savedThemes = _G._ArsenalCustomThemes
            local SLOT_KEYS   = {"ac","dk","bg","pn","sb","cd","su","br","sl"}
            local SLOT_LABELS = { ac="Accent", dk="Dark Button", bg="Background", pn="Panel", sb="Sidebar", cd="Card", su="Subtle", br="Border", sl="Slot Off" }

            E.Section(self, "Select Theme")

            local GridWrap = new("Frame", {
                Name="ThemeGrid", BackgroundTransparency=1, BorderSizePixel=0,
                Size=UDim2.new(1,-28,0,0), AutomaticSize=Enum.AutomaticSize.Y
            }, Page)
            new("UIGridLayout", {
                CellSize=UDim2.new(0.31,0,0,52), CellPadding=UDim2.new(0,6,0,6), SortOrder=Enum.SortOrder.LayoutOrder
            }, GridWrap)

            local allCards = {}

            local function refreshCards()
                for _, cd in ipairs(allCards) do
                    local active = cd.theme.name == TH.name
                    tw(cd.card,{BackgroundColor3=active and TH.dk or TH.cd},0.18)
                    cd.stroke.Color=active and TH.ac or TH.br; cd.stroke.Thickness=active and 1.5 or 1
                    tw(cd.lbl,{TextColor3=active and TH.ac or TH.su},0.18)
                end
            end

            local function makeCard(parent, theme, deletable)
                local Card = new("TextButton", {
                    BackgroundColor3=TH.cd, BorderSizePixel=0, AutoButtonColor=false, Text=""
                }, parent)
                corner(UDim.new(0,7), Card)
                local cardStroke = stroke(theme.name==TH.name and TH.ac or TH.br, theme.name==TH.name and 1.5 or 1, Card)

                local SwRow = new("Frame", {BackgroundTransparency=1,Position=UDim2.new(0,6,0,6),Size=UDim2.new(1,-12,0,14)}, Card)
                new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,3)},SwRow)
                for _, k in ipairs({"ac","bg","pn","sb"}) do
                    local d = new("Frame",{BackgroundColor3=theme[k],BorderSizePixel=0,Size=UDim2.new(0,12,1,0)},SwRow)
                    corner(UDim.new(0,3),d)
                end

                local NameLbl = new("TextLabel", {
                    BackgroundTransparency=1, AnchorPoint=Vector2.new(0,1),
                    Position=UDim2.new(0,6,1,-6), Size=UDim2.new(1,-12,0,14),
                    Font=Enum.Font.GothamBold, Text=theme.name,
                    TextColor3=theme.name==TH.name and TH.ac or TH.su, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left
                }, Card)

                if deletable then
                    local DelBtn = new("ImageButton", {
                        BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0),
                        Position=UDim2.new(1,-2,0,2), Size=UDim2.new(0,13,0,13),
                        Image="rbxassetid://107560529463028", ImageColor3=TH.su, ZIndex=5, AutoButtonColor=false
                    }, Card)
                    DelBtn.MouseEnter:Connect(function() DelBtn.ImageColor3=Color3.fromRGB(240,60,60) end)
                    DelBtn.MouseLeave:Connect(function() DelBtn.ImageColor3=TH.su end)
                    DelBtn.MouseButton1Click:Connect(function()
                        for i,t in ipairs(savedThemes) do if t.name==theme.name then table.remove(savedThemes,i); break end end
                        for i,cd in ipairs(allCards) do if cd.card==Card then table.remove(allCards,i); break end end
                        Card:Destroy()
                    end)
                    onTheme(function(t) DelBtn.ImageColor3=t.su end)
                end

                Card.MouseEnter:Connect(function()
                    if TH.name~=theme.name then tw(Card,{BackgroundColor3=theme.dk},0.14); tw(cardStroke,{Color=theme.ac},0.14) end
                end)
                Card.MouseLeave:Connect(function()
                    if TH.name~=theme.name then tw(Card,{BackgroundColor3=TH.cd},0.14); tw(cardStroke,{Color=TH.br},0.14) end
                end)
                Card.MouseButton1Down:Connect(function() tw(Card,{Size=UDim2.new(0.97,0,0.97,0)},0.08,Enum.EasingStyle.Sine) end)
                Card.MouseButton1Click:Connect(function()
                    tw(Card,{Size=UDim2.new(1,0,1,0)},0.15,Enum.EasingStyle.Back)
                    TH = theme; fireTheme(); refreshCards()
                end)

                local entry = {card=Card,stroke=cardStroke,lbl=NameLbl,theme=theme}
                table.insert(allCards, entry)
                onTheme(function(t)
                    local active = t.name==theme.name
                    tw(Card,{BackgroundColor3=active and t.dk or t.cd},0.22)
                    cardStroke.Color=active and t.ac or t.br; cardStroke.Thickness=active and 1.5 or 1
                    tw(NameLbl,{TextColor3=active and t.ac or t.su},0.22)
                end)
            end

            for _, theme in ipairs(THEMES) do makeCard(GridWrap, theme, false) end

            -- Custom color editor
            E.Section(self, "Custom Colors")

            local editTheme = {}; for k,v in pairs(TH) do editTheme[k]=v end; editTheme.name="Custom"
            local colorDefs = {}
            for _, k in ipairs(SLOT_KEYS) do table.insert(colorDefs,{label=SLOT_LABELS[k],key=k,color=editTheme[k]}) end

            local selIdx     = -1
            local pickerOpen = false
            local rowEls2    = {}
            local chips2     = {}

            local PH, ROW_H, PICK_H = 48, 34, 228
            local listH2 = #colorDefs * ROW_H + 4

            local Outer2 = new("Frame", {
                Name="CCOuter", BackgroundTransparency=1, BorderSizePixel=0,
                Size=UDim2.new(1,-28,0,PH), ClipsDescendants=true
            }, Page)

            local TitleBar2 = new("Frame", {BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,20)}, Outer2)
            local TitleTx2  = new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,2,0,0), Size=UDim2.new(1,-52,1,0),
                Font=Enum.Font.GothamBold, Text="Color Slots", TextColor3=TH.ac, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left
            }, TitleBar2)
            local TitleLine2 = new("Frame", {
                BackgroundColor3=TH.br, BorderSizePixel=0, AnchorPoint=Vector2.new(0,1),
                Position=UDim2.new(0,0,1,0), Size=UDim2.new(1,0,0,1)
            }, TitleBar2)
            local EditBtn2 = new("TextButton", {
                BackgroundColor3=TH.sl, BorderSizePixel=0, AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,0,1.8,0), Size=UDim2.new(0,44,0,25),
                AutoButtonColor=false, Font=Enum.Font.GothamBold,
                Text="Edit", TextColor3=TH.su, TextSize=9
            }, TitleBar2)
            corner(UDim.new(0,4), EditBtn2)

            local PrevRow2 = new("Frame", {
                BackgroundTransparency=1, BorderSizePixel=0,
                Position=UDim2.new(0,0,0,22), Size=UDim2.new(1,0,0,PH-22)
            }, Outer2)
            new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},PrevRow2)

            for i, def in ipairs(colorDefs) do
                local cw = new("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X},PrevRow2)
                new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,HorizontalAlignment=Enum.HorizontalAlignment.Center,Padding=UDim.new(0,2)},cw)
                local Chip2 = new("Frame",{BackgroundColor3=editTheme[def.key],BorderSizePixel=0,Size=UDim2.new(0,24,0,14)},cw)
                corner(UDim.new(0,3),Chip2)
                local cs2 = stroke(TH.br,1,Chip2)
                local cl2 = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0,32,0,9),Font=Enum.Font.Gotham,Text=def.label,TextColor3=TH.su,TextSize=7,TextTruncate=Enum.TextTruncate.AtEnd},cw)
                chips2[i] = {chip=Chip2,stroke=cs2,lbl=cl2,key=def.key}
                onTheme(function(t) tw(cs2,{Color=t.br},0.22); tw(cl2,{TextColor3=t.su},0.22) end)
            end

            local EditList2 = new("Frame", {
                BackgroundColor3=TH.cd, BorderSizePixel=0,
                Position=UDim2.new(0,0,0,PH+4), Size=UDim2.new(1,0,0,0), ClipsDescendants=true
            }, Outer2)
            corner(UDim.new(0,6),EditList2)
            local elStroke2 = stroke(TH.br,1,EditList2)
            new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},EditList2)

            local function openPicker2(i)
                selIdx=i; pickerOpen=true
                local k=colorDefs[i].key; local ph2,ps2,pv2 = Color3.toHSV(editTheme[k])
                -- update picker state (set externally via closure below)
                _openPicker2State(ph2,ps2,pv2)
                local total=PH+4+listH2+4+PICK_H+4
                Outer2:TweenSize(UDim2.new(1,-28,0,total),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.28,true)
                PickPanel2:TweenSize(UDim2.new(1,0,0,PICK_H),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.28,true)
                ppStroke2.Color=TH.ac
            end
            local function closePicker2()
                selIdx=-1; pickerOpen=false
                Outer2:TweenSize(UDim2.new(1,-28,0,PH+4+listH2+4),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.24,true)
                PickPanel2:TweenSize(UDim2.new(1,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.24,true)
                ppStroke2.Color=TH.br
                for _,el in ipairs(rowEls2) do tw(el.selRing,{Transparency=1},0.14) end
            end

            for i, def in ipairs(colorDefs) do
                local CRow2 = new("TextButton", {
                    BackgroundColor3=TH.ac, BackgroundTransparency=1, BorderSizePixel=0,
                    Size=UDim2.new(1,0,0,ROW_H), AutoButtonColor=false, Text=""
                }, EditList2)
                corner(UDim.new(0,5),CRow2)
                local RS2 = new("Frame",{BackgroundColor3=editTheme[def.key],BorderSizePixel=0,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),Size=UDim2.new(0,20,0,20)},CRow2)
                corner(UDim.new(0,4),RS2)
                local rss2 = stroke(TH.br,1,RS2)
                new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,38,0,0),Size=UDim2.new(1,-110,1,0),Font=Enum.Font.Gotham,Text=def.label,TextColor3=WT,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},CRow2)
                local RHex2 = new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-28,0.5,0),Size=UDim2.new(0,56,0,14),Font=Enum.Font.GothamBold,Text="#"..color3ToHex(editTheme[def.key]),TextColor3=TH.su,TextSize=8,TextXAlignment=Enum.TextXAlignment.Right},CRow2)
                local ChkIco2 = new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),Size=UDim2.new(0,18,0,18),Font=Enum.Font.GothamBold,Text="›",TextColor3=TH.ac,TextSize=16,TextTransparency=1},CRow2)
                local SelRing2 = stroke(TH.ac,2,RS2); SelRing2.Transparency=1

                CRow2.MouseEnter:Connect(function() if selIdx~=i then tw(CRow2,{BackgroundTransparency=0.92},0.12) end end)
                CRow2.MouseLeave:Connect(function() if selIdx~=i then tw(CRow2,{BackgroundTransparency=1},0.12) end end)

                rowEls2[i]={row=CRow2,swatch=RS2,swStroke=rss2,hexLbl=RHex2,checkIco=ChkIco2,selRing=SelRing2,key=def.key}

                CRow2.MouseButton1Click:Connect(function()
                    for j,el in ipairs(rowEls2) do
                        el.checkIco.TextTransparency=1; tw(el.selRing,{Transparency=1},0.14)
                        if j~=i then tw(el.row,{BackgroundTransparency=1},0.14) end
                    end
                    if selIdx==i then
                        tw(CRow2,{BackgroundTransparency=1},0.14); closePicker2()
                    else
                        CRow2.BackgroundColor3=TH.dk; tw(CRow2,{BackgroundTransparency=0},0.15)
                        ChkIco2.TextTransparency=0; tw(SelRing2,{Transparency=0},0.15)
                        openPicker2(i)
                    end
                end)
                onTheme(function(t) tw(rss2,{Color=t.br},0.22); tw(RHex2,{TextColor3=t.su},0.22); tw(ChkIco2,{TextColor3=t.ac},0.22); SelRing2.Color=t.ac end)
            end

            -- Picker Panel 2
            local PickPanel2 = new("Frame", {
                BackgroundColor3=TH.cd, BorderSizePixel=0,
                Position=UDim2.new(0,0,0,PH+4+listH2+4), Size=UDim2.new(1,0,0,0), ClipsDescendants=true
            }, Outer2)
            corner(UDim.new(0,8),PickPanel2)
            local ppStroke2 = stroke(TH.br,1,PickPanel2)

            local ph2,ps2,pv2 = 0,1,1
            local pDrag2,phDrag2 = false,false

            local GO2 = new("ImageLabel",{BackgroundColor3=Color3.fromHSV(0,1,1),BorderSizePixel=0,Position=UDim2.new(0,10,0,10),Size=UDim2.new(1,-20,0,110),Image="rbxassetid://4155801252",ZIndex=2},PickPanel2)
            corner(UDim.new(0,6),GO2)
            local PC2b = new("Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(ps2,0,1-pv2,0),Size=UDim2.new(0,12,0,12),ZIndex=5},GO2)
            corner(UDim.new(1,0),PC2b); stroke(Color3.new(0,0,0),1.5,PC2b)
            local GB2 = new("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=6},GO2)

            local HT2b = new("TextButton",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.new(0,10,0,128),Size=UDim2.new(1,-20,0,10),AutoButtonColor=false,Text=""},PickPanel2)
            corner(UDim.new(1,0),HT2b)
            new("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})},HT2b)
            local HK2b = new("Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(ph2,0,0.5,0),Size=UDim2.new(0,14,0,14),ZIndex=2},HT2b)
            corner(UDim.new(1,0),HK2b); local hk2bStroke=stroke(TH.br,1.5,HK2b)

            for _, info in ipairs({{"HEX",0,10,146},{"RGB",0.5,2,146}}) do
                local L=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(info[2],info[3],0,info[4]),Size=UDim2.new(0.5,-12,0,12),Font=Enum.Font.Gotham,Text=info[1],TextColor3=TH.su,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},PickPanel2)
                onTheme(function(t) tw(L,{TextColor3=t.su},0.22) end)
            end

            local HexBox2b = new("TextBox",{BackgroundColor3=TH.bg,BorderSizePixel=0,Position=UDim2.new(0,10,0,160),Size=UDim2.new(0.47,-2,0,22),Font=Enum.Font.GothamBold,Text="#FFFFFF",TextColor3=WT,TextSize=10,PlaceholderText="#RRGGBB",ClearTextOnFocus=false},PickPanel2)
            corner(UDim.new(0,5),HexBox2b); local hb2bStroke=stroke(TH.br,1,HexBox2b)
            local RgbBox2b = new("TextBox",{BackgroundColor3=TH.bg,BorderSizePixel=0,Position=UDim2.new(0.5,2,0,160),Size=UDim2.new(0.5,-12,0,22),Font=Enum.Font.GothamBold,Text="255,255,255",TextColor3=WT,TextSize=10,PlaceholderText="R,G,B",ClearTextOnFocus=false},PickPanel2)
            corner(UDim.new(0,5),RgbBox2b); local rb2bStroke=stroke(TH.br,1,RgbBox2b)

            local function syncPicker2()
                local nc = Color3.fromHSV(ph2,ps2,pv2)
                GO2.BackgroundColor3 = Color3.fromHSV(ph2,1,1)
                PC2b.Position = UDim2.new(ps2,0,1-pv2,0); HK2b.Position = UDim2.new(ph2,0,0.5,0)
                if not HexBox2b:IsFocused() then HexBox2b.Text="#"..color3ToHex(nc) end
                if not RgbBox2b:IsFocused() then RgbBox2b.Text=color3ToRgb(nc) end
                if selIdx>=1 then
                    local k=colorDefs[selIdx].key; editTheme[k]=nc
                    if chips2[selIdx]  then tw(chips2[selIdx].chip,{BackgroundColor3=nc},0.12) end
                    if rowEls2[selIdx] then tw(rowEls2[selIdx].swatch,{BackgroundColor3=nc},0.12); rowEls2[selIdx].hexLbl.Text="#"..color3ToHex(nc) end
                end
            end

            function _openPicker2State(h,s,v) ph2,ps2,pv2=h,s,v; syncPicker2() end

            GB2.InputBegan:Connect(function(inp)
                if not isPress(inp) then return end; pDrag2=true
                local ap,az=GO2.AbsolutePosition,GO2.AbsoluteSize
                ps2=math.clamp((inp.Position.X-ap.X)/az.X,0,1); pv2=math.clamp(1-(inp.Position.Y-ap.Y)/az.Y,0,1); syncPicker2()
            end)
            GB2.InputEnded:Connect(function(inp) if isPress(inp) then pDrag2=false end end)
            HT2b.InputBegan:Connect(function(inp)
                if not isPress(inp) then return end; phDrag2=true
                local ap,az=HT2b.AbsolutePosition,HT2b.AbsoluteSize
                ph2=math.clamp((inp.Position.X-ap.X)/az.X,0,0.9999); syncPicker2()
            end)
            HT2b.InputEnded:Connect(function(inp) if isPress(inp) then phDrag2=false end end)
            UserInputService.InputChanged:Connect(function(inp)
                if not isMove(inp) then return end
                if pDrag2 then
                    local ap,az=GO2.AbsolutePosition,GO2.AbsoluteSize
                    ps2=math.clamp((inp.Position.X-ap.X)/az.X,0,1); pv2=math.clamp(1-(inp.Position.Y-ap.Y)/az.Y,0,1); syncPicker2()
                elseif phDrag2 then
                    local ap,az=HT2b.AbsolutePosition,HT2b.AbsoluteSize
                    ph2=math.clamp((inp.Position.X-ap.X)/az.X,0,0.9999); syncPicker2()
                end
            end)
            HexBox2b.FocusLost:Connect(function()
                local c=hexToColor3(HexBox2b.Text)
                if c then ph2,ps2,pv2=Color3.toHSV(c); syncPicker2(); hb2bStroke.Color=TH.br
                else hb2bStroke.Color=Color3.fromRGB(240,60,60) end
            end)
            RgbBox2b.FocusLost:Connect(function()
                local c=rgbToColor3(RgbBox2b.Text)
                if c then ph2,ps2,pv2=Color3.toHSV(c); syncPicker2(); rb2bStroke.Color=TH.br
                else rb2bStroke.Color=Color3.fromRGB(240,60,60) end
            end)

            local editMode2 = false
            local function toggleEditMode()
                editMode2 = not editMode2
                if editMode2 then
                    EditBtn2.Text="Done"; tw(EditBtn2,{BackgroundColor3=TH.dk,TextColor3=TH.ac},0.14)
                    Outer2:TweenSize(UDim2.new(1,-28,0,PH+4+listH2+4),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.28,true)
                    EditList2:TweenSize(UDim2.new(1,0,0,listH2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.28,true)
                    elStroke2.Transparency=0
                else
                    EditBtn2.Text="Edit"; tw(EditBtn2,{BackgroundColor3=TH.sl,TextColor3=TH.su},0.14)
                    selIdx=-1
                    for _,el in ipairs(rowEls2) do tw(el.row,{BackgroundTransparency=1},0.14); el.checkIco.TextTransparency=1; tw(el.selRing,{Transparency=1},0.14) end
                    Outer2:TweenSize(UDim2.new(1,-28,0,PH),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.24,true)
                    EditList2:TweenSize(UDim2.new(1,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.24,true)
                    PickPanel2:TweenSize(UDim2.new(1,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.24,true)
                    elStroke2.Transparency=1; pickerOpen=false
                end
            end
            EditBtn2.MouseButton1Click:Connect(toggleEditMode)
            EditBtn2.MouseEnter:Connect(function() tw(EditBtn2,{BackgroundColor3=TH.dk,TextColor3=TH.ac},0.14) end)
            EditBtn2.MouseLeave:Connect(function() if not editMode2 then tw(EditBtn2,{BackgroundColor3=TH.sl,TextColor3=TH.su},0.14) end end)

            onTheme(function(t)
                tw(TitleTx2,{TextColor3=t.ac},0.22); tw(TitleLine2,{BackgroundColor3=t.br},0.22)
                tw(EditList2,{BackgroundColor3=t.cd},0.22); tw(PickPanel2,{BackgroundColor3=t.cd},0.22)
                tw(HexBox2b,{BackgroundColor3=t.bg},0.22); tw(RgbBox2b,{BackgroundColor3=t.bg},0.22)
                elStroke2.Color=t.br; hk2bStroke.Color=t.br
                ppStroke2.Color=pickerOpen and t.ac or t.br
                if not editMode2 then tw(EditBtn2,{BackgroundColor3=t.sl,TextColor3=t.su},0.22)
                else tw(EditBtn2,{BackgroundColor3=t.dk,TextColor3=t.ac},0.22) end
            end)

            -- Apply button
            local ApplyBtn = new("TextButton", {
                BackgroundColor3=TH.ac, BorderSizePixel=0, Size=UDim2.new(1,-28,0,30),
                AutoButtonColor=false, Font=Enum.Font.GothamBold,
                Text="✓  Apply Edited Colors", TextColor3=Color3.new(1,1,1), TextSize=12
            }, Page)
            corner(UDim.new(0,7),ApplyBtn)
            ApplyBtn.MouseButton1Down:Connect(function() tw(ApplyBtn,{Size=UDim2.new(1,-32,0,28)},0.08,Enum.EasingStyle.Sine) end)
            ApplyBtn.MouseButton1Click:Connect(function()
                tw(ApplyBtn,{Size=UDim2.new(1,-28,0,30)},0.14,Enum.EasingStyle.Back)
                local snap={}; for k,v in pairs(editTheme) do snap[k]=v end
                snap.name = (#NameBox2.Text>0) and NameBox2.Text or "Custom"
                TH=snap; fireTheme(); refreshCards()
            end)
            onTheme(function(t) tw(ApplyBtn,{BackgroundColor3=t.ac},0.22) end)

            -- Custom grid
            E.Section(self, "Saved Themes")

            local CGrid = new("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,-28,0,0),AutomaticSize=Enum.AutomaticSize.Y},Page)
            new("UIGridLayout",{CellSize=UDim2.new(0.31,0,0,52),CellPadding=UDim2.new(0,6,0,6),SortOrder=Enum.SortOrder.LayoutOrder},CGrid)

            local EmptyLbl = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),Font=Enum.Font.Gotham,Text="No Saved Themes",TextColor3=TH.su,TextSize=10,Visible=#savedThemes==0},CGrid)
            onTheme(function(t) tw(EmptyLbl,{TextColor3=t.su},0.22) end)

            for _, t in ipairs(savedThemes) do makeCard(CGrid,t,true); EmptyLbl.Visible=false end

            -- Save section
            E.Section(self, "Save Theme")

            local NameWrap2 = new("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,-28,0,28)},Page)
            local NameBox2 = new("TextBox",{BackgroundColor3=TH.cd,BorderSizePixel=0,Size=UDim2.new(0,230,1,0),Font=Enum.Font.Gotham,Text="",TextColor3=WT,TextSize=11,PlaceholderText="Theme Name...",ClearTextOnFocus=false,ZIndex=3},NameWrap2)
            corner(UDim.new(0,7),NameBox2)
            local nameStroke2 = stroke(TH.br,1,NameBox2)
            NameBox2.Focused:Connect(function() tw(nameStroke2,{Color=TH.ac,Thickness=1.5},0.12) end)
            NameBox2.FocusLost:Connect(function() tw(nameStroke2,{Color=TH.br,Thickness=1},0.12) end)

            local SaveBtn2 = new("TextButton",{BackgroundColor3=TH.ac,BorderSizePixel=0,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text="  ＋  Save Theme  ",TextColor3=WT,TextSize=12,Position=UDim2.new(0,240,0,0)},NameWrap2)
            corner(UDim.new(0,7),SaveBtn2)
            SaveBtn2.MouseButton1Down:Connect(function() tw(SaveBtn2,{TextTransparency=0.3},0.08) end)
            SaveBtn2.MouseButton1Click:Connect(function()
                tw(SaveBtn2,{TextTransparency=0},0.12)
                local snap={}; for k,v in pairs(editTheme) do snap[k]=v end
                snap.name = (#NameBox2.Text>0) and NameBox2.Text or ("Custom "..(#savedThemes+1))
                table.insert(savedThemes,snap); EmptyLbl.Visible=false
                makeCard(CGrid,snap,true); NameBox2.Text=""
                tw(nameStroke2,{Color=TH.ac},0.12); task.delay(0.5,function() tw(nameStroke2,{Color=TH.br},0.2) end)
            end)
            onTheme(function(t) tw(SaveBtn2,{BackgroundColor3=t.ac},0.22); tw(NameBox2,{BackgroundColor3=t.cd},0.22) end)
        end

        return E
    end

    local W = {}
    function W:Tab(...) return Tabs:Tab(...) end
    return W
end
return Library
