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
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
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
Title.Text = "📡 DuckBlox Remote Spy & Explorer"
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

local LiveTabBtn = Instance.new("TextButton")
LiveTabBtn.Size = UDim2.new(0, 130, 1, 0)
LiveTabBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
LiveTabBtn.Text = "🔴 Live Logs (0)"
LiveTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LiveTabBtn.Font = Enum.Font.GothamBold
LiveTabBtn.TextSize = 12
LiveTabBtn.AutoButtonColor = false
LiveTabBtn.Parent = TabBar

local LiveTabCorner = Instance.new("UICorner")
LiveTabCorner.CornerRadius = UDim.new(0, 6)
LiveTabCorner.Parent = LiveTabBtn

local ExplorerTabBtn = Instance.new("TextButton")
ExplorerTabBtn.Size = UDim2.new(0, 170, 1, 0)
ExplorerTabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
ExplorerTabBtn.Text = "📦 All Remotes (0)"
ExplorerTabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
ExplorerTabBtn.Font = Enum.Font.GothamBold
ExplorerTabBtn.TextSize = 12
ExplorerTabBtn.AutoButtonColor = false
ExplorerTabBtn.Parent = TabBar

local ExplorerTabCorner = Instance.new("UICorner")
ExplorerTabCorner.CornerRadius = UDim.new(0, 6)
ExplorerTabCorner.Parent = ExplorerTabBtn

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 70, 1, 0)
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

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 84)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Hook Status: Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(140, 145, 165)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

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
LiveScroll.Visible = true
LiveScroll.Parent = MainFrame

local LiveList = Instance.new("UIListLayout")
LiveList.Padding = UDim.new(0, 8)
LiveList.SortOrder = Enum.SortOrder.LayoutOrder
LiveList.Parent = LiveScroll

local LivePadding = Instance.new("UIPadding")
LivePadding.PaddingTop = UDim.new(0, 4)
LivePadding.PaddingBottom = UDim.new(0, 10)
LivePadding.Parent = LiveScroll

local ExplorerScroll = Instance.new("ScrollingFrame")
ExplorerScroll.Size = UDim2.new(1, -20, 1, -114)
ExplorerScroll.Position = UDim2.new(0, 10, 0, 106)
ExplorerScroll.BackgroundTransparency = 1
ExplorerScroll.BorderSizePixel = 0
ExplorerScroll.ScrollBarThickness = 4
ExplorerScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 85)
ExplorerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ExplorerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ExplorerScroll.Active = true
ExplorerScroll.Visible = false
ExplorerScroll.Parent = MainFrame

local ExplorerList = Instance.new("UIListLayout")
ExplorerList.Padding = UDim.new(0, 6)
ExplorerList.SortOrder = Enum.SortOrder.LayoutOrder
ExplorerList.Parent = ExplorerScroll

local ExplorerPadding = Instance.new("UIPadding")
ExplorerPadding.PaddingTop = UDim.new(0, 4)
ExplorerPadding.PaddingBottom = UDim.new(0, 10)
ExplorerPadding.Parent = ExplorerScroll

LiveTabBtn.MouseButton1Click:Connect(function()
    LiveTabBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    LiveTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExplorerTabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    ExplorerTabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
    LiveScroll.Visible = true
    ExplorerScroll.Visible = false
end)

ExplorerTabBtn.MouseButton1Click:Connect(function()
    ExplorerTabBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    ExplorerTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LiveTabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    LiveTabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
    ExplorerScroll.Visible = true
    LiveScroll.Visible = false
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, child in ipairs(LiveScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end)

local liveCount = 0

local function addLiveEntry(remoteObj, method, args)
    liveCount = liveCount + 1
    LiveTabBtn.Text = string.format("🔴 Live Logs (%d)", liveCount)

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
    titleLbl.Text = string.format("<font color=\"#5865F2\">[%s]</font> <font color=\"#2ECC71\">%s</font> • %s", timeStr, method, name)
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
    argsBox.Text = argsFormatted ~= "" and ("Args: (" .. argsFormatted .. ")") or "(No Arguments)"
    argsBox.TextColor3 = Color3.fromRGB(230, 235, 245)
    argsBox.Font = Enum.Font.Code
    argsBox.TextSize = 11.5
    argsBox.TextXAlignment = Enum.TextXAlignment.Left
    argsBox.TextWrapped = true
    argsBox.Parent = card
end

local explorerCount = 0
local function populateAllRemotes()
    for _, child in ipairs(ExplorerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    explorerCount = 0

    local targets = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            table.insert(targets, obj)
        end
    end

    local localPlayer = Players.LocalPlayer
    if localPlayer then
        for _, obj in ipairs(localPlayer:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                table.insert(targets, obj)
            end
        end
    end

    for _, obj in ipairs(targets) do
        explorerCount = explorerCount + 1
        local path = obj:GetFullName()
        local name = obj.Name
        local cName = obj.ClassName

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 40)
        card.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
        card.BorderSizePixel = 0
        card.Parent = ExplorerScroll

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

    ExplorerTabBtn.Text = string.format("📦 All Remotes (%d)", explorerCount)
end

populateAllRemotes()

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

local hookSuccess = false

if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
    local oldNamecall
    local success, err = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local isSender = (typeof(checkcaller) == "function" and checkcaller()) or false
            if not isSender then
                if method == "FireServer" or method == "InvokeServer" or method == "Fire" or method == "Invoke" then
                    local args = {...}
                    task.spawn(function()
                        addLiveEntry(self, method, args)
                    end)
                end
            end
            return oldNamecall(self, ...)
        end)
    end)

    if success then
        hookSuccess = true
        StatusLabel.Text = "✅ Hook Status: Active (Listening for FireServer/InvokeServer)"
        StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        StatusLabel.Text = "⚠️ hookmetamethod error: " .. tostring(err)
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
else
    StatusLabel.Text = "⚠️ Executor does not support hookmetamethod! Use [All Remotes] tab."
    StatusLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
end
