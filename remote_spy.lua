local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local function destroyAllOld()
    local names = {"DuckBloxRemoteSpyUI", "DuckBloxRemoteSpyUI_v2", "DuckBloxCombatFinder", "DuckBloxHardwareCursor"}
    for _, n in ipairs(names) do
        pcall(function()
            if typeof(gethui) == "function" and gethui():FindFirstChild(n) then
                gethui()[n]:Destroy()
            end
        end)
        pcall(function()
            local cg = game:GetService("CoreGui")
            if cg:FindFirstChild(n) then cg[n]:Destroy() end
        end)
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(n) then
                LocalPlayer.PlayerGui[n]:Destroy()
            end
        end)
    end
end
destroyAllOld()

local parentGui
if typeof(gethui) == "function" then
    parentGui = gethui()
elseif RunService:IsStudio() then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
else
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    parentGui = (success and coreGui) or LocalPlayer:WaitForChild("PlayerGui")
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

local CursorGui = Instance.new("ScreenGui")
CursorGui.Name = "DuckBloxHardwareCursor"
CursorGui.DisplayOrder = 999999999
CursorGui.IgnoreGuiInset = true
CursorGui.ResetOnSpawn = false
CursorGui.Parent = parentGui

local CursorImg = Instance.new("ImageLabel")
CursorImg.Size = UDim2.new(0, 24, 0, 24)
CursorImg.BackgroundTransparency = 1
CursorImg.Image = "rbxasset://textures/ArrowCursor.png"
CursorImg.ZIndex = 999999999
CursorImg.Active = false
CursorImg.Parent = CursorGui

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DuckBloxCombatFinder"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = parentGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 440)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(88, 101, 242)
MainStroke.Thickness = 2
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
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🦆 Combat & Timing Finder • PlatformBattles"
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

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -20, 0, 34)
SearchBox.Position = UDim2.new(0, 10, 0, 52)
SearchBox.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
SearchBox.PlaceholderText = "🔍 Type to search (e.g. timing, bow, command, combat, blade)..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 135, 155)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.GothamBold
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 5
SearchBox.Parent = MainFrame

local SearchBoxCorner = Instance.new("UICorner")
SearchBoxCorner.CornerRadius = UDim.new(0, 8)
SearchBoxCorner.Parent = SearchBox

local SearchBoxStroke = Instance.new("UIStroke")
SearchBoxStroke.Color = Color3.fromRGB(88, 101, 242)
SearchBoxStroke.Thickness = 1.5
SearchBoxStroke.Parent = SearchBox

local SearchBoxPad = Instance.new("UIPadding")
SearchBoxPad.PaddingLeft = UDim.new(0, 12)
SearchBoxPad.PaddingRight = UDim.new(0, 12)
SearchBoxPad.Parent = SearchBox

local QuickFilterBar = Instance.new("Frame")
QuickFilterBar.Size = UDim2.new(1, -20, 0, 26)
QuickFilterBar.Position = UDim2.new(0, 10, 0, 92)
QuickFilterBar.BackgroundTransparency = 1
QuickFilterBar.Parent = MainFrame

local QuickFilterLayout = Instance.new("UIListLayout")
QuickFilterLayout.FillDirection = Enum.FillDirection.Horizontal
QuickFilterLayout.Padding = UDim.new(0, 6)
QuickFilterLayout.Parent = QuickFilterBar

local function createFilterPill(label, filterKeyword)
    local pill = Instance.new("TextButton")
    pill.Size = UDim2.new(0, 0, 1, 0)
    pill.AutomaticSize = Enum.AutomaticSize.X
    pill.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    pill.Text = " " .. label .. " "
    pill.TextColor3 = Color3.fromRGB(200, 210, 235)
    pill.Font = Enum.Font.GothamBold
    pill.TextSize = 11
    pill.AutoButtonColor = false
    pill.Parent = QuickFilterBar

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pill

    pill.MouseButton1Click:Connect(function()
        SearchBox.Text = filterKeyword
    end)
end

createFilterPill("🎯 All Timing/Minigames", "timing")
createFilterPill("🏹 Bow", "bow")
createFilterPill("⚔️ Combat/Action", "combat")
createFilterPill("⚡ Command", "command")
createFilterPill("🔄 Reset", "")

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "ResultsScroll"
Scroll.Size = UDim2.new(1, -20, 1, -130)
Scroll.Position = UDim2.new(0, 10, 0, 124)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Active = true
Scroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll

local ScrollPadding = Instance.new("UIPadding")
ScrollPadding.PaddingTop = UDim.new(0, 4)
ScrollPadding.PaddingBottom = UDim.new(0, 12)
ScrollPadding.Parent = Scroll

local allCards = {}

local function addCard(modObj)
    local name = modObj.Name
    local path = modObj:GetFullName()
    local nlower = name:lower()

    local isCombatOrTiming = nlower:find("timing") or nlower:find("bow") or nlower:find("minigame")
        or nlower:find("dodge") or nlower:find("combat") or nlower:find("battle")
        or nlower:find("command") or nlower:find("action") or nlower:find("slash")
        or nlower:find("blade") or nlower:find("shot") or nlower:find("rpg")

    local memberInfo = {}
    local success, res = pcall(function() return require(modObj) end)
    if success and typeof(res) == "table" then
        for k, v in pairs(res) do
            table.insert(memberInfo, string.format("%s (%s)", tostring(k), typeof(v)))
        end
    end
    local membersStr = #memberInfo > 0 and table.concat(memberInfo, ", ") or "Loaded"

    local card = Instance.new("Frame")
    card.Name = name .. " " .. path .. " " .. membersStr
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = isCombatOrTiming and Color3.fromRGB(34, 40, 58) or Color3.fromRGB(26, 30, 40)
    card.BorderSizePixel = 0
    card.LayoutOrder = isCombatOrTiming and -100 or 10
    card.Parent = Scroll

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = isCombatOrTiming and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(45, 50, 65)
    cardStroke.Thickness = isCombatOrTiming and 1.5 or 1
    cardStroke.Parent = card

    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingTop = UDim.new(0, 8)
    cardPad.PaddingBottom = UDim.new(0, 8)
    cardPad.PaddingLeft = UDim.new(0, 12)
    cardPad.PaddingRight = UDim.new(0, 12)
    cardPad.Parent = card

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.Parent = card

    local tagText = isCombatOrTiming and "⭐ [KEY MODULE]" or "[Module]"
    local tagColor = isCombatOrTiming and "#2ECC71" or "#F39C12"
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -85, 1, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = string.format("<font color=\"%s\">%s</font> <b>%s</b>", tagColor, tagText, name)
    titleLbl.RichText = true
    titleLbl.TextColor3 = Color3.fromRGB(245, 245, 250)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = header

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 75, 0, 22)
    copyBtn.Position = UDim2.new(1, -75, 0, 0)
    copyBtn.BackgroundColor3 = isCombatOrTiming and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(45, 50, 65)
    copyBtn.Text = "📋 Copy"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 11
    copyBtn.AutoButtonColor = false
    copyBtn.Parent = header

    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 6)
    copyCorner.Parent = copyBtn

    local fullCopy = string.format("local %s = require(%s)\nMembers: %s", name, path, membersStr)
    copyBtn.MouseButton1Click:Connect(function()
        copyToClipboard(fullCopy)
        copyBtn.Text = "✅ Copied!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        task.wait(1.5)
        if copyBtn.Parent then
            copyBtn.Text = "📋 Copy"
            copyBtn.BackgroundColor3 = isCombatOrTiming and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(45, 50, 65)
        end
    end)

    local pathLbl = Instance.new("TextLabel")
    pathLbl.Size = UDim2.new(1, 0, 0, 16)
    pathLbl.Position = UDim2.new(0, 0, 0, 24)
    pathLbl.BackgroundTransparency = 1
    pathLbl.Text = path
    pathLbl.TextColor3 = Color3.fromRGB(150, 155, 175)
    pathLbl.Font = Enum.Font.Code
    pathLbl.TextSize = 10.5
    pathLbl.TextXAlignment = Enum.TextXAlignment.Left
    pathLbl.Parent = card

    local memLbl = Instance.new("TextLabel")
    memLbl.Size = UDim2.new(1, 0, 0, 0)
    memLbl.Position = UDim2.new(0, 0, 0, 42)
    memLbl.AutomaticSize = Enum.AutomaticSize.Y
    memLbl.BackgroundTransparency = 1
    memLbl.Text = "Exports: " .. membersStr
    memLbl.TextColor3 = Color3.fromRGB(180, 220, 255)
    memLbl.Font = Enum.Font.Code
    memLbl.TextSize = 11
    memLbl.TextXAlignment = Enum.TextXAlignment.Left
    memLbl.TextWrapped = true
    memLbl.Parent = card

    table.insert(allCards, card)
end

local function scanAll()
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
            if obj:IsA("ModuleScript") then
                table.insert(modules, obj)
            end
        end
    end

    local pgui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        for _, obj in ipairs(pgui:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                table.insert(modules, obj)
            end
        end
    end

    for _, m in ipairs(modules) do
        addCard(m)
    end
end

scanAll()

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchBox.Text:lower():gsub("%s+", "")
    for _, card in ipairs(allCards) do
        if q == "" then
            card.Visible = true
        else
            card.Visible = (card.Name:lower():find(q, 1, true) ~= nil)
        end
    end
end)

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

RunService.RenderStepped:Connect(function()
    if not ScreenGui.Parent then
        if CursorGui.Parent then CursorGui:Destroy() end
        return
    end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
    local pos = UserInputService:GetMouseLocation()
    CursorImg.Position = UDim2.new(0, pos.X, 0, pos.Y)
end)
