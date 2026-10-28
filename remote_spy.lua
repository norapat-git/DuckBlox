local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
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
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "📡 DuckBlox Remote Spy • Live Logger"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 64, 0, 26)
ClearBtn.Position = UDim2.new(1, -104, 0.5, -13)
ClearBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 12
ClearBtn.AutoButtonColor = false
ClearBtn.Parent = TopBar

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

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

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -54)
Scroll.Position = UDim2.new(0, 10, 0, 48)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 85)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Active = true
Scroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 4)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Scroll

ClearBtn.MouseButton1Click:Connect(function()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end)

local logCount = 0

local function addRemoteEntry(remoteObj, method, args)
    logCount = logCount + 1

    local path = remoteObj:GetFullName()
    local name = remoteObj.Name
    local timeStr = os.date("%H:%M:%S")

    local serializedArgStrings = {}
    for i, a in ipairs(args) do
        table.insert(serializedArgStrings, serializeVal(a))
    end
    local argsFormatted = table.concat(serializedArgStrings, ", ")
    local copyCode = string.format("%s:%s(%s)", path, method, argsFormatted)

    local card = Instance.new("Frame")
    card.Name = "Entry_" .. logCount
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
    card.BorderSizePixel = 0
    card.LayoutOrder = -logCount
    card.Parent = Scroll

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(45, 50, 65)
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local cardPadding = Instance.new("UIPadding")
    cardPadding.PaddingTop = UDim.new(0, 8)
    cardPadding.PaddingBottom = UDim.new(0, 8)
    cardPadding.PaddingLeft = UDim.new(0, 10)
    cardPadding.PaddingRight = UDim.new(0, 10)
    cardPadding.Parent = card

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -90, 1, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = string.format("<font color=\"#5865F2\">[%s]</font> <font color=\"#2ECC71\">%s</font> • %s", timeStr, method, name)
    titleLbl.RichText = true
    titleLbl.TextColor3 = Color3.fromRGB(245, 245, 250)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 12.5
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = header

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 75, 0, 22)
    copyBtn.Position = UDim2.new(1, -75, 0, 1)
    copyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    copyBtn.Text = "📋 Copy"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 11
    copyBtn.AutoButtonColor = false
    copyBtn.Parent = header

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

    local children = Scroll:GetChildren()
    local frames = {}
    for _, c in ipairs(children) do
        if c:IsA("Frame") then table.insert(frames, c) end
    end
    if #frames > 40 then
        table.sort(frames, function(a, b) return a.LayoutOrder > b.LayoutOrder end)
        for i = 35, #frames do
            frames[i]:Destroy()
        end
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

if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" and typeof(checkcaller) == "function" then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            task.spawn(function()
                addRemoteEntry(self, method, args)
            end)
        end
        return oldNamecall(self, ...)
    end)
end
