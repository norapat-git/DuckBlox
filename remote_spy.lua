local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local parentGui
if typeof(gethui) == "function" then
    parentGui = gethui()
elseif RunService:IsStudio() then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
else
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    parentGui = (success and coreGui) or LocalPlayer:WaitForChild("PlayerGui")
end

if parentGui:FindFirstChild("DuckBloxRemoteSpyUI") then
    parentGui.DuckBloxRemoteSpyUI:Destroy()
end

local function copyToClipboard(str)
    pcall(function()
        if typeof(setclipboard) == "function" then
            setclipboard(str)
        elseif typeof(toclipboard) == "function" then
            toclipboard(str)
        end
    end)
end

local function serializeVal(val, depth)
    depth = depth or 0
    if depth > 3 then return "..." end
    local t = typeof(val)
    if t == "string" then
        return string.format("%q", val)
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "table" then
        local parts = {}
        for k, v in pairs(val) do
            table.insert(parts, string.format("[%s] = %s", serializeVal(k, depth + 1), serializeVal(v, depth + 1)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif t == "Instance" then
        return val:GetFullName()
    else
        return string.format("<%s> %s", t, tostring(val))
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DuckBloxRemoteSpyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = parentGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 50, 65)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Color3.fromRGB(27, 30, 39)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TopBarMask = Instance.new("Frame")
TopBarMask.Size = UDim2.new(1, 0, 0, 10)
TopBarMask.Position = UDim2.new(0, 0, 1, -10)
TopBarMask.BackgroundColor3 = Color3.fromRGB(27, 30, 39)
TopBarMask.BorderSizePixel = 0
TopBarMask.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "📡 PlatformBattles RPG Explorer"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.Padding = UDim.new(0, 8)
TabListLayout.Parent = TabBar

local ModulesTabBtn = Instance.new("TextButton")
ModulesTabBtn.Size = UDim2.new(0, 160, 1, 0)
ModulesTabBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
ModulesTabBtn.Text = "📜 Battle Modules (0)"
ModulesTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModulesTabBtn.Font = Enum.Font.GothamBold
ModulesTabBtn.TextSize = 12
ModulesTabBtn.AutoButtonColor = false
ModulesTabBtn.Parent = TabBar

local ModulesTabCorner = Instance.new("UICorner")
ModulesTabCorner.CornerRadius = UDim.new(0, 6)
ModulesTabCorner.Parent = ModulesTabBtn

local LiveTabBtn = Instance.new("TextButton")
LiveTabBtn.Size = UDim2.new(0, 150, 1, 0)
LiveTabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
LiveTabBtn.Text = "📥 RPGState Logs (0)"
LiveTabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
LiveTabBtn.Font = Enum.Font.GothamBold
LiveTabBtn.TextSize = 12
LiveTabBtn.AutoButtonColor = false
LiveTabBtn.Parent = TabBar

local LiveTabCorner = Instance.new("UICorner")
LiveTabCorner.CornerRadius = UDim.new(0, 6)
LiveTabCorner.Parent = LiveTabBtn

local RemotesTabBtn = Instance.new("TextButton")
RemotesTabBtn.Size = UDim2.new(0, 120, 1, 0)
RemotesTabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
RemotesTabBtn.Text = "📦 Remotes (13)"
RemotesTabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
RemotesTabBtn.Font = Enum.Font.GothamBold
RemotesTabBtn.TextSize = 12
RemotesTabBtn.AutoButtonColor = false
RemotesTabBtn.Parent = TabBar

local RemotesTabCorner = Instance.new("UICorner")
RemotesTabCorner.CornerRadius = UDim.new(0, 6)
RemotesTabCorner.Parent = RemotesTabBtn

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 60, 1, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 11.5
ClearBtn.AutoButtonColor = false
ClearBtn.Parent = TabBar

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1, -20, 0, 26)
SearchBar.Position = UDim2.new(0, 10, 0, 84)
SearchBar.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
SearchBar.PlaceholderText = "🔍 Search modules (e.g. command, timing, combat, bow, minigame)..."
SearchBar.PlaceholderColor3 = Color3.fromRGB(120, 125, 145)
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.fromRGB(240, 245, 255)
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 12
SearchBar.TextXAlignment = Enum.TextXAlignment.Left
SearchBar.ClearTextOnFocus = false
SearchBar.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchBar

local SearchPad = Instance.new("UIPadding")
SearchPad.PaddingLeft = UDim.new(0, 10)
SearchPad.PaddingRight = UDim.new(0, 10)
SearchPad.Parent = SearchBar

local ModulesScroll = Instance.new("ScrollingFrame")
ModulesScroll.Size = UDim2.new(1, -20, 1, -122)
ModulesScroll.Position = UDim2.new(0, 10, 0, 114)
ModulesScroll.BackgroundTransparency = 1
ModulesScroll.BorderSizePixel = 0
ModulesScroll.ScrollBarThickness = 4
ModulesScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 85)
ModulesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ModulesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ModulesScroll.Active = true
ModulesScroll.Visible = true
ModulesScroll.Parent = MainFrame

SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBar.Text:lower():gsub("%s+", "")
    for _, card in ipairs(ModulesScroll:GetChildren()) do
        if card:IsA("Frame") then
            if query == "" then
                card.Visible = true
            else
                local name = card.Name:lower()
                card.Visible = (name:find(query, 1, true) ~= nil)
            end
        end
    end
end)

local ModulesList = Instance.new("UIListLayout")
ModulesList.Padding = UDim.new(0, 6)
ModulesList.SortOrder = Enum.SortOrder.LayoutOrder
ModulesList.Parent = ModulesScroll

local ModulesPadding = Instance.new("UIPadding")
ModulesPadding.PaddingTop = UDim.new(0, 4)
ModulesPadding.PaddingBottom = UDim.new(0, 10)
ModulesPadding.Parent = ModulesScroll

local LiveScroll = Instance.new("ScrollingFrame")
LiveScroll.Size = UDim2.new(1, -20, 1, -114)
LiveScroll.Position = UDim2.new(0, 10, 0, 106)
LiveScroll.BackgroundTransparency = 1
LiveScroll.BorderSizePixel = 0
LiveScroll.ScrollBarThickness = 4
LiveScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 85)
LiveScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LiveScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LiveScroll.Active = true
LiveScroll.Visible = false
LiveScroll.Parent = MainFrame

local LiveList = Instance.new("UIListLayout")
LiveList.Padding = UDim.new(0, 8)
LiveList.SortOrder = Enum.SortOrder.LayoutOrder
LiveList.Parent = LiveScroll

local LivePadding = Instance.new("UIPadding")
LivePadding.PaddingTop = UDim.new(0, 4)
LivePadding.PaddingBottom = UDim.new(0, 10)
LivePadding.Parent = LiveScroll

local RemotesScroll = Instance.new("ScrollingFrame")
RemotesScroll.Size = UDim2.new(1, -20, 1, -114)
RemotesScroll.Position = UDim2.new(0, 10, 0, 106)
RemotesScroll.BackgroundTransparency = 1
RemotesScroll.BorderSizePixel = 0
RemotesScroll.ScrollBarThickness = 4
RemotesScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 85)
RemotesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
RemotesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RemotesScroll.Active = true
RemotesScroll.Visible = false
RemotesScroll.Parent = MainFrame

local RemotesList = Instance.new("UIListLayout")
RemotesList.Padding = UDim.new(0, 6)
RemotesList.SortOrder = Enum.SortOrder.LayoutOrder
RemotesList.Parent = RemotesScroll

local RemotesPadding = Instance.new("UIPadding")
RemotesPadding.PaddingTop = UDim.new(0, 4)
RemotesPadding.PaddingBottom = UDim.new(0, 10)
RemotesPadding.Parent = RemotesScroll

local function selectTab(activeBtn, activeScroll)
    ModulesTabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    ModulesTabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
    LiveTabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    LiveTabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
    RemotesTabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    RemotesTabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)

    ModulesScroll.Visible = false
    LiveScroll.Visible = false
    RemotesScroll.Visible = false

    activeBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activeScroll.Visible = true
end

ModulesTabBtn.MouseButton1Click:Connect(function()
    selectTab(ModulesTabBtn, ModulesScroll)
end)

LiveTabBtn.MouseButton1Click:Connect(function()
    selectTab(LiveTabBtn, LiveScroll)
end)

RemotesTabBtn.MouseButton1Click:Connect(function()
    selectTab(RemotesTabBtn, RemotesScroll)
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, child in ipairs(LiveScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end)

local liveCount = 0

local function addLiveEntry(remoteObj, method, args)
    liveCount = liveCount + 1
    LiveTabBtn.Text = string.format("📥 RPGState Logs (%d)", liveCount)

    local path = typeof(remoteObj) == "Instance" and remoteObj:GetFullName() or tostring(remoteObj)
    local name = typeof(remoteObj) == "Instance" and remoteObj.Name or "Unknown"
    local timeStr = os.date("%H:%M:%S")

    local serialized = {}
    for i, a in ipairs(args) do
        table.insert(serialized, serializeVal(a))
    end
    local argsFormatted = table.concat(serialized, ", ")
    local copyCode = string.format("%s:%s(%s)", path, method, argsFormatted)

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
    card.BorderSizePixel = 0
    card.LayoutOrder = -liveCount
    card.Parent = LiveScroll

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(45, 50, 65)
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingTop = UDim.new(0, 8)
    cardPad.PaddingBottom = UDim.new(0, 8)
    cardPad.PaddingLeft = UDim.new(0, 10)
    cardPad.PaddingRight = UDim.new(0, 10)
    cardPad.Parent = card

    local head = Instance.new("Frame")
    head.Size = UDim2.new(1, 0, 0, 24)
    head.BackgroundTransparency = 1
    head.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -85, 1, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = string.format("<font color=\"#5865F2\">[%s]</font> <font color=\"#3498DB\">%s</font> • %s", timeStr, method, name)
    titleLbl.RichText = true
    titleLbl.TextColor3 = Color3.fromRGB(245, 245, 250)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 12.5
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = head

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 75, 0, 22)
    copyBtn.Position = UDim2.new(1, -75, 0, 1)
    copyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    copyBtn.Text = "📋 Copy"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 11
    copyBtn.AutoButtonColor = false
    copyBtn.Parent = head

    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 6)
    copyCorner.Parent = copyBtn

    copyBtn.MouseButton1Click:Connect(function()
        copyToClipboard(copyCode)
        copyBtn.Text = "✅ Copied!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        task.wait(1.5)
        if copyBtn.Parent then
            copyBtn.Text = "📋 Copy"
            copyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end
    end)

    local pathLbl = Instance.new("TextLabel")
    pathLbl.Size = UDim2.new(1, 0, 0, 16)
    pathLbl.Position = UDim2.new(0, 0, 0, 26)
    pathLbl.BackgroundTransparency = 1
    pathLbl.Text = path
    pathLbl.TextColor3 = Color3.fromRGB(150, 155, 175)
    pathLbl.Font = Enum.Font.Code
    pathLbl.TextSize = 11
    pathLbl.TextXAlignment = Enum.TextXAlignment.Left
    pathLbl.Parent = card

    local argsBox = Instance.new("TextLabel")
    argsBox.Size = UDim2.new(1, 0, 0, 0)
    argsBox.Position = UDim2.new(0, 0, 0, 44)
    argsBox.AutomaticSize = Enum.AutomaticSize.Y
    argsBox.BackgroundTransparency = 1
    argsBox.Text = argsFormatted ~= "" and ("Data: (" .. argsFormatted .. ")") or "(No Arguments)"
    argsBox.TextColor3 = Color3.fromRGB(230, 235, 245)
    argsBox.Font = Enum.Font.Code
    argsBox.TextSize = 11.5
    argsBox.TextXAlignment = Enum.TextXAlignment.Left
    argsBox.TextWrapped = true
    argsBox.Parent = card
end

local function populateRemotes()
    local targets = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            table.insert(targets, obj)
        end
    end

    for _, obj in ipairs(targets) do
        local path = obj:GetFullName()
        local name = obj.Name
        local cName = obj.ClassName

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 42)
        card.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
        card.BorderSizePixel = 0
        card.Parent = RemotesScroll

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 6)
        cardCorner.Parent = card

        local cardPad = Instance.new("UIPadding")
        cardPad.PaddingLeft = UDim.new(0, 10)
        cardPad.PaddingRight = UDim.new(0, 10)
        cardPad.Parent = card

        local tagColor = cName:find("Function") and "#E67E22" or "#5865F2"
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -85, 0, 20)
        titleLbl.Position = UDim2.new(0, 0, 0, 2)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = string.format("<font color=\"%s\">[%s]</font> <b>%s</b>", tagColor, cName, name)
        titleLbl.RichText = true
        titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = card

        local pathLbl = Instance.new("TextLabel")
        pathLbl.Size = UDim2.new(1, -85, 0, 16)
        pathLbl.Position = UDim2.new(0, 0, 0, 22)
        pathLbl.BackgroundTransparency = 1
        pathLbl.Text = path
        pathLbl.TextColor3 = Color3.fromRGB(140, 145, 165)
        pathLbl.Font = Enum.Font.Code
        pathLbl.TextSize = 10.5
        pathLbl.TextXAlignment = Enum.TextXAlignment.Left
        pathLbl.Parent = card

        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 75, 0, 24)
        copyBtn.Position = UDim2.new(1, -75, 0.5, -12)
        copyBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
        copyBtn.Text = "📋 Copy"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 11
        copyBtn.AutoButtonColor = false
        copyBtn.Parent = card

        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 6)
        copyCorner.Parent = copyBtn

        copyBtn.MouseButton1Click:Connect(function()
            copyToClipboard(path)
            copyBtn.Text = "✅ Copied!"
            copyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            task.wait(1.5)
            if copyBtn.Parent then
                copyBtn.Text = "📋 Copy"
                copyBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
            end
        end)
    end
end

local function populateModules()
    local modules = {}
    local pb = ReplicatedStorage:FindFirstChild("PlatformBattles")
    if pb then
        for _, obj in ipairs(pb:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                table.insert(modules, obj)
            end
        end
    end

    local ps = LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then
        for _, obj in ipairs(ps:GetDescendants()) do
            if obj:IsA("ModuleScript") and (obj.Name:lower():find("battle") or obj.Name:lower():find("combat") or obj.Name:lower():find("rpg")) then
                table.insert(modules, obj)
            end
        end
    end

    local count = 0
    for _, mod in ipairs(modules) do
        count = count + 1
        local path = mod:GetFullName()
        local name = mod.Name

        local memberInfo = {}
        local success, res = pcall(function() return require(mod) end)
        if success and typeof(res) == "table" then
            for k, v in pairs(res) do
                table.insert(memberInfo, string.format("%s (%s)", tostring(k), typeof(v)))
            end
        end

        local membersStr = #memberInfo > 0 and table.concat(memberInfo, ", ") or "Module Loaded"

        local nlower = name:lower()
        local isPriority = nlower:find("timing") or nlower:find("bow") or nlower:find("minigame")
            or nlower:find("dodge") or nlower:find("combat") or nlower:find("battle")
            or nlower:find("command") or nlower:find("action") or nlower:find("slash")
            or nlower:find("blade") or nlower:find("rpg")

        local card = Instance.new("Frame")
        card.Name = name .. "_" .. path
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = isPriority and Color3.fromRGB(34, 40, 56) or Color3.fromRGB(28, 32, 42)
        card.BorderSizePixel = 0
        card.LayoutOrder = isPriority and -100 or count
        card.Parent = ModulesScroll

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 6)
        cardCorner.Parent = card

        local cardPad = Instance.new("UIPadding")
        cardPad.PaddingTop = UDim.new(0, 6)
        cardPad.PaddingBottom = UDim.new(0, 6)
        cardPad.PaddingLeft = UDim.new(0, 10)
        cardPad.PaddingRight = UDim.new(0, 10)
        cardPad.Parent = card

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 22)
        header.BackgroundTransparency = 1
        header.Parent = card

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -85, 1, 0)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = string.format("<font color=\"#F39C12\">[Module]</font> <b>%s</b>", name)
        titleLbl.RichText = true
        titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = header

        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 75, 0, 22)
        copyBtn.Position = UDim2.new(1, -75, 0, 0)
        copyBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
        copyBtn.Text = "📋 Copy"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 11
        copyBtn.AutoButtonColor = false
        copyBtn.Parent = header

        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 6)
        copyCorner.Parent = copyBtn

        local fullCopy = string.format("local %s = require(%s)\n-- Members: %s", name, path, membersStr)
        copyBtn.MouseButton1Click:Connect(function()
            copyToClipboard(fullCopy)
            copyBtn.Text = "✅ Copied!"
            copyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            task.wait(1.5)
            if copyBtn.Parent then
                copyBtn.Text = "📋 Copy"
                copyBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
            end
        end)

        local pathLbl = Instance.new("TextLabel")
        pathLbl.Size = UDim2.new(1, 0, 0, 16)
        pathLbl.Position = UDim2.new(0, 0, 0, 22)
        pathLbl.BackgroundTransparency = 1
        pathLbl.Text = path
        pathLbl.TextColor3 = Color3.fromRGB(140, 145, 165)
        pathLbl.Font = Enum.Font.Code
        pathLbl.TextSize = 10.5
        pathLbl.TextXAlignment = Enum.TextXAlignment.Left
        pathLbl.Parent = card

        local memLbl = Instance.new("TextLabel")
        memLbl.Size = UDim2.new(1, 0, 0, 0)
        memLbl.Position = UDim2.new(0, 0, 0, 38)
        memLbl.AutomaticSize = Enum.AutomaticSize.Y
        memLbl.BackgroundTransparency = 1
        memLbl.Text = "Functions/Keys: " .. membersStr
        memLbl.TextColor3 = Color3.fromRGB(180, 220, 255)
        memLbl.Font = Enum.Font.Code
        memLbl.TextSize = 11
        memLbl.TextXAlignment = Enum.TextXAlignment.Left
        memLbl.TextWrapped = true
        memLbl.Parent = card
    end

    ModulesTabBtn.Text = string.format("📜 Battle Modules (%d)", count)
end

populateRemotes()
populateModules()

local rpgState = ReplicatedStorage:FindFirstChild("PlatformBattles") and ReplicatedStorage.PlatformBattles:FindFirstChild("Remotes") and ReplicatedStorage.PlatformBattles.Remotes:FindFirstChild("RPGState")
if rpgState and rpgState:IsA("RemoteEvent") then
    pcall(function()
        rpgState.OnClientEvent:Connect(function(...)
            local args = {...}
            task.spawn(function()
                addLiveEntry(rpgState, "OnClientEvent", args)
            end)
        end)
    end)
end

for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and obj ~= rpgState then
        pcall(function()
            obj.OnClientEvent:Connect(function(...)
                local args = {...}
                task.spawn(function()
                    addLiveEntry(obj, "OnClientEvent", args)
                end)
            end)
        end)
    end
end

local function enableDragging(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

enableDragging(MainFrame, TopBar)
