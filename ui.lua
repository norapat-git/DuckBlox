local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local globalEnv = (typeof(getgenv) == "function" and getgenv()) or _G
if globalEnv.DuckBloxCleanup then
    pcall(globalEnv.DuckBloxCleanup)
end

local parentGui
if typeof(gethui) == "function" then
    parentGui = gethui()
elseif RunService:IsStudio() then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
else
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    parentGui = (success and coreGui) or LocalPlayer:WaitForChild("PlayerGui")
end

if parentGui:FindFirstChild("DuckBloxCustomUI") then
    parentGui.DuckBloxCustomUI:Destroy()
end

local activeConnections = {}
local activeThreads = {}
local isRunning = true

local function trackConnection(conn)
    table.insert(activeConnections, conn)
    return conn
end

local function cleanupAll()
    isRunning = false
    for _, conn in ipairs(activeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(activeConnections)
    for _, thread in ipairs(activeThreads) do
        pcall(function() task.cancel(thread) end)
    end
    table.clear(activeThreads)
    if parentGui and parentGui:FindFirstChild("DuckBloxCustomUI") then
        parentGui.DuckBloxCustomUI:Destroy()
    end
    if parentGui and parentGui:FindFirstChild("DuckBloxHardwareCursor") then
        parentGui.DuckBloxHardwareCursor:Destroy()
    end
end

globalEnv.DuckBloxCleanup = cleanupAll

local THEME = {
    Background = Color3.fromRGB(20, 22, 28),
    TopBar = Color3.fromRGB(27, 30, 39),
    CardBg = Color3.fromRGB(30, 34, 44),
    Accent = Color3.fromRGB(88, 101, 242),
    Success = Color3.fromRGB(46, 204, 113),
    Danger = Color3.fromRGB(231, 76, 60),
    Text = Color3.fromRGB(245, 245, 250),
    TextMuted = Color3.fromRGB(150, 155, 175),
    Border = Color3.fromRGB(45, 50, 65),
}

local CursorGui = Instance.new("ScreenGui")
CursorGui.Name = "DuckBloxHardwareCursor"
CursorGui.DisplayOrder = 999999999
CursorGui.IgnoreGuiInset = true
CursorGui.ResetOnSpawn = false
CursorGui.Parent = parentGui

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DuckBloxCustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = parentGui

local VirtualCursor = Instance.new("ImageLabel")
VirtualCursor.Name = "DuckBloxVirtualCursor"
VirtualCursor.Size = UDim2.new(0, 24, 0, 24)
VirtualCursor.BackgroundTransparency = 1
VirtualCursor.Image = "rbxasset://textures/ArrowCursor.png"
VirtualCursor.ZIndex = 999999999
VirtualCursor.Active = false
VirtualCursor.Visible = false
VirtualCursor.Parent = CursorGui

local ToggleBubble = Instance.new("TextButton")
ToggleBubble.Name = "ToggleBubble"
ToggleBubble.Size = UDim2.new(0, 52, 0, 52)
ToggleBubble.Position = UDim2.new(0.03, 0, 0.45, 0)
ToggleBubble.BackgroundColor3 = THEME.TopBar
ToggleBubble.Text = "🏹"
ToggleBubble.TextSize = 22
ToggleBubble.TextColor3 = THEME.Text
ToggleBubble.AutoButtonColor = false
ToggleBubble.Active = true
ToggleBubble.Parent = ScreenGui

local BubbleCorner = Instance.new("UICorner")
BubbleCorner.CornerRadius = UDim.new(1, 0)
BubbleCorner.Parent = ToggleBubble

local BubbleStroke = Instance.new("UIStroke")
BubbleStroke.Color = THEME.Accent
BubbleStroke.Thickness = 2
BubbleStroke.Parent = ToggleBubble

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -130)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.Border
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = THEME.TopBar
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 14)
TopBarCorner.Parent = TopBar

local TopBarBottomMask = Instance.new("Frame")
TopBarBottomMask.Size = UDim2.new(1, 0, 0, 10)
TopBarBottomMask.Position = UDim2.new(0, 0, 1, -10)
TopBarBottomMask.BackgroundColor3 = THEME.TopBar
TopBarBottomMask.BorderSizePixel = 0
TopBarBottomMask.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🦆 DuckBlox Hub • <font color=\"#5865F2\">Ultra Fast</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = THEME.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.TextMuted
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

trackConnection(CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Danger, TextColor3 = Color3.new(1, 1, 1)}):Play()
end))

trackConnection(CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 42, 54), TextColor3 = THEME.TextMuted}):Play()
end))

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, -20, 1, -60)
ScrollContainer.Position = UDim2.new(0, 10, 0, 54)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = THEME.Border
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.Active = true
ScrollContainer.Parent = MainFrame

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 10)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Parent = ScrollContainer

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 12)
ContentPadding.PaddingLeft = UDim.new(0, 4)
ContentPadding.PaddingRight = UDim.new(0, 4)
ContentPadding.Parent = ScrollContainer

local function createSection(titleText)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 24)
    section.BackgroundTransparency = 1
    section.Text = string.upper(titleText)
    section.TextColor3 = THEME.TextMuted
    section.Font = Enum.Font.GothamBold
    section.TextSize = 11
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = ScrollContainer
    return section
end

local function createToggle(title, defaultState, onToggle)
    local isEnabled = defaultState or false

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 46)
    card.BackgroundColor3 = THEME.CardBg
    card.BorderSizePixel = 0
    card.Parent = ScrollContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = THEME.Border
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 1, 0)
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = THEME.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13.5
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 46, 0, 26)
    switch.Position = UDim2.new(1, -58, 0.5, -13)
    switch.BackgroundColor3 = isEnabled and THEME.Success or Color3.fromRGB(45, 50, 65)
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = card

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = isEnabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = switch

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    local function updateSwitch(state, animate)
        isEnabled = state
        local targetPos = isEnabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        local targetBg = isEnabled and THEME.Success or Color3.fromRGB(45, 50, 65)
        local targetStroke = isEnabled and THEME.Success or THEME.Border

        if animate then
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
            TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = targetStroke}):Play()
        else
            circle.Position = targetPos
            switch.BackgroundColor3 = targetBg
            cardStroke.Color = targetStroke
        end

        if onToggle then onToggle(isEnabled) end
    end

    trackConnection(switch.MouseButton1Click:Connect(function()
        updateSwitch(not isEnabled, true)
    end))

    return {
        Set = function(val) updateSwitch(val, true) end,
        Get = function() return isEnabled end
    }
end

local autoCombatEnabled = false
local autoBowEnabled = false
local autoDodgeEnabled = false

local lastBowTrigger = 0
local bowHasResetToBottom = true
local prevBowY = nil

local lastDodgeTrigger = 0
local prevNeedleX = nil
local dodgeHasReset = true

local bowCache = {
    active = false,
    container = nil,
    goldBand = nil,
    gaugeFrame = nil,
    indicator = nil,
}

local dodgeCache = {
    active = false,
    container = nil,
    needle = nil,
    whiteZone = nil,
}

local function triggerSpacebar()
    task.spawn(function()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end)
end

local function isActuallyVisible(obj)
    if not obj or not obj.Parent or not obj:IsA("GuiObject") then return false end
    if not obj.Visible or obj.AbsoluteSize.X <= 0 or obj.AbsoluteSize.Y <= 0 then
        return false
    end
    local parent = obj.Parent
    while parent do
        if parent:IsA("GuiObject") then
            if not parent.Visible then
                return false
            end
        elseif parent:IsA("LayerCollector") then
            return parent.Enabled
        end
        parent = parent.Parent
    end
    return true
end

local function isGoldColor(color)
    if not color then return false end
    return (color.R > 0.65) and (color.G > 0.55) and (color.B < 0.6) and (color.R >= color.B + 0.15)
end

local function isGreenColor(color)
    if not color then return false end
    return (color.G > 0.55) and (color.G > color.R) and (color.G > color.B)
end

local function isWhiteColor(c)
    if not c then return false end
    return (c.R > 0.85) and (c.G > 0.85) and (c.B > 0.85)
end

local function isRedNeedleColor(c)
    if not c then return false end
    return (c.R > 0.70) and (c.G < 0.58) and (c.B < 0.58) and ((c.R - c.G) > 0.20)
end

local function refreshBowCache(playerGui)
    if bowCache.active and isActuallyVisible(bowCache.indicator) and (isActuallyVisible(bowCache.goldBand) or isActuallyVisible(bowCache.gaugeFrame)) then
        return
    end

    bowCache.active = false
    bowCache.container = nil
    bowCache.goldBand = nil
    bowCache.gaugeFrame = nil
    bowCache.indicator = nil

    local foundContainer = nil
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("POWER SHOT") or text:find("GOLD BAND") then
                        if isActuallyVisible(label) then
                            local ancestor = label.Parent
                            while ancestor and ancestor ~= gui do
                                if ancestor:IsA("Frame") and ancestor.AbsoluteSize.X >= 200 and ancestor.AbsoluteSize.Y >= 120 then
                                    foundContainer = ancestor
                                    break
                                end
                                ancestor = ancestor.Parent
                            end
                            foundContainer = foundContainer or gui
                            break
                        end
                    end
                end
            end
            if foundContainer then break end
        end
    end

    if not foundContainer then
        bowHasResetToBottom = true
        prevBowY = nil
        return
    end

    local goldBand, gaugeFrame, indicator = nil, nil, nil
    local descendants = foundContainer:GetDescendants()

    for _, obj in ipairs(descendants) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            if not goldBand then
                if (name:find("gold") or name:find("band") or name:find("sweet") or name:find("perfect") or name:find("target")) and isActuallyVisible(obj) then
                    goldBand = obj
                elseif obj.AbsoluteSize.Y > 0 and (isGoldColor(obj.BackgroundColor3) or (obj:IsA("ImageLabel") and isGoldColor(obj.ImageColor3))) and isActuallyVisible(obj) then
                    goldBand = obj
                end
            end
            if not gaugeFrame then
                if (name:find("gauge") or name:find("bar") or name:find("meter") or name:find("power")) and obj.AbsoluteSize.Y > 50 and isActuallyVisible(obj) then
                    gaugeFrame = obj
                end
            end
            if not indicator then
                if (name:find("bow") or name:find("arrow") or name:find("pointer")) and not name:find("shadow") and not name:find("bg") and isActuallyVisible(obj) then
                    indicator = obj
                end
            end
        end
    end

    if not indicator then
        for _, obj in ipairs(descendants) do
            if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 5 then
                local name = obj.Name:lower()
                if (name:find("fill") or name:find("power") or isGreenColor(obj.BackgroundColor3)) and isActuallyVisible(obj) then
                    indicator = obj
                    break
                end
            end
        end
    end

    if indicator and (goldBand or gaugeFrame) then
        bowCache.container = foundContainer
        bowCache.goldBand = goldBand
        bowCache.gaugeFrame = gaugeFrame
        bowCache.indicator = indicator
        bowCache.active = true
    end
end

local function refreshDodgeCache(playerGui)
    if dodgeCache.active and isActuallyVisible(dodgeCache.needle) and isActuallyVisible(dodgeCache.whiteZone) then
        return
    end

    dodgeCache.active = false
    dodgeCache.container = nil
    dodgeCache.needle = nil
    dodgeCache.whiteZone = nil

    local foundContainer = nil
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("INCOMING") or text:find("HITS YOUR SHIELD") or text:find("DODGE = WHITE") or text:find("YOUR SHIELD") then
                        if isActuallyVisible(label) then
                            local ancestor = label.Parent
                            while ancestor and ancestor ~= gui do
                                if ancestor:IsA("Frame") and ancestor.AbsoluteSize.X >= 250 and ancestor.AbsoluteSize.Y >= 120 and isActuallyVisible(ancestor) then
                                    foundContainer = ancestor
                                    break
                                end
                                ancestor = ancestor.Parent
                            end
                            foundContainer = foundContainer or gui
                            break
                        end
                    end
                end
            end
            if foundContainer then break end
        end
    end

    if not foundContainer then
        dodgeHasReset = true
        prevNeedleX = nil
        return
    end

    local descendants = foundContainer:GetDescendants()
    local needle = nil

    for _, obj in ipairs(descendants) do
        if obj:IsA("GuiObject") and obj.Visible and not obj:IsA("TextLabel") and not obj:IsA("TextButton") then
            local sx = obj.AbsoluteSize.X
            local sy = obj.AbsoluteSize.Y
            if sx >= 2 and sx <= 28 and sy >= 24 and sy <= 150 and sy > (sx * 1.8) then
                local isRed = (obj.BackgroundTransparency < 0.6 and isRedNeedleColor(obj.BackgroundColor3))
                    or (obj:IsA("ImageLabel") and obj.ImageTransparency < 0.6 and isRedNeedleColor(obj.ImageColor3))
                if isRed and isActuallyVisible(obj) then
                    needle = obj
                    break
                end
            end
        end
    end

    if not needle then return end

    local needleCenterY = needle.AbsolutePosition.Y + (needle.AbsoluteSize.Y * 0.5)
    local bestZone = nil
    local bestDiffY = 999

    for _, obj in ipairs(descendants) do
        if obj:IsA("GuiObject") and obj.Visible and obj ~= needle and not obj:IsA("TextLabel") and not obj:IsA("TextButton") then
            local sx = obj.AbsoluteSize.X
            local sy = obj.AbsoluteSize.Y
            if sx >= 14 and sx <= 260 and sy >= 16 and sy <= 90 then
                local isWhite = (obj.BackgroundTransparency < 0.5 and isWhiteColor(obj.BackgroundColor3))
                    or (obj:IsA("ImageLabel") and obj.ImageTransparency < 0.5 and isWhiteColor(obj.ImageColor3))
                if isWhite then
                    local objCenterY = obj.AbsolutePosition.Y + (sy * 0.5)
                    local diffY = math.abs(objCenterY - needleCenterY)
                    if diffY <= 24 and diffY < bestDiffY and isActuallyVisible(obj) then
                        bestDiffY = diffY
                        bestZone = obj
                    end
                end
            end
        end
    end

    if needle and bestZone then
        dodgeCache.container = foundContainer
        dodgeCache.needle = needle
        dodgeCache.whiteZone = bestZone
        dodgeCache.active = true
    end
end

local scannerThread = task.spawn(function()
    while isRunning and ScreenGui.Parent do
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            if autoBowEnabled then
                pcall(refreshBowCache, playerGui)
            else
                bowCache.active = false
            end

            if autoDodgeEnabled then
                pcall(refreshDodgeCache, playerGui)
            else
                dodgeCache.active = false
            end
        end
        task.wait(0.1)
    end
end)
table.insert(activeThreads, scannerThread)

local function stepBow()
    if not autoBowEnabled or not bowCache.active then return end
    if (os.clock() - lastBowTrigger) < 0.4 then return end

    local indicator = bowCache.indicator
    local goldBand = bowCache.goldBand
    local gaugeFrame = bowCache.gaugeFrame

    if not indicator or not indicator.Parent or not indicator.Visible then
        bowCache.active = false
        bowHasResetToBottom = true
        prevBowY = nil
        return
    end

    local targetY = nil
    if goldBand and goldBand.Parent and goldBand.Visible then
        targetY = goldBand.AbsolutePosition.Y + (goldBand.AbsoluteSize.Y * 0.5) - 2
    elseif gaugeFrame and gaugeFrame.Parent and gaugeFrame.Visible then
        targetY = gaugeFrame.AbsolutePosition.Y + (gaugeFrame.AbsoluteSize.Y * 0.48) - 2
    else
        bowCache.active = false
        return
    end

    local bowCenterY = indicator.AbsolutePosition.Y + (indicator.AbsoluteSize.Y * 0.5)
    local tol = 5

    if bowCenterY > (targetY + 15) then
        bowHasResetToBottom = true
    end

    local isMovingUp = false
    if prevBowY ~= nil then
        if (prevBowY - bowCenterY) > 0.1 then
            isMovingUp = true
        end
    end

    local isAtCenter = math.abs(bowCenterY - targetY) <= (tol + 2)
    local justPassed = (bowCenterY <= targetY + tol) and (bowCenterY >= targetY - 35)
    local crossedDuringLag = (prevBowY ~= nil) and (prevBowY >= targetY - 4) and (bowCenterY <= targetY + tol) and (bowCenterY >= targetY - 45)

    if bowHasResetToBottom and isMovingUp and (isAtCenter or justPassed or crossedDuringLag) then
        bowHasResetToBottom = false
        lastBowTrigger = os.clock()
        triggerSpacebar()
    end

    prevBowY = bowCenterY
end

local function stepDodge()
    if not autoDodgeEnabled or not dodgeCache.active then return end
    if (os.clock() - lastDodgeTrigger) < 0.25 then return end

    local needle = dodgeCache.needle
    local whiteZone = dodgeCache.whiteZone

    if not needle or not needle.Parent or not needle.Visible or not whiteZone or not whiteZone.Parent or not whiteZone.Visible then
        dodgeCache.active = false
        dodgeHasReset = true
        prevNeedleX = nil
        return
    end

    local whiteLeft = whiteZone.AbsolutePosition.X
    local whiteRight = whiteLeft + whiteZone.AbsoluteSize.X
    local needleX = needle.AbsolutePosition.X + (needle.AbsoluteSize.X * 0.5)

    if needleX < (whiteLeft - 12) or needleX > (whiteRight + 12) then
        dodgeHasReset = true
    end

    local movingDir = 0
    if prevNeedleX ~= nil then
        local delta = needleX - prevNeedleX
        if delta > 0.1 then
            movingDir = 1
        elseif delta < -0.1 then
            movingDir = -1
        end
    end

    local shouldTrigger = false
    if movingDir == 1 then
        if (needleX >= whiteLeft - 2) and (needleX <= whiteRight + 35) and (prevNeedleX <= whiteRight + 5) then
            shouldTrigger = true
        end
    elseif movingDir == -1 then
        if (needleX <= whiteRight + 2) and (needleX >= whiteLeft - 35) and (prevNeedleX >= whiteLeft - 5) then
            shouldTrigger = true
        end
    end

    if dodgeHasReset and shouldTrigger then
        dodgeHasReset = false
        lastDodgeTrigger = os.clock()
        triggerSpacebar()
    end

    prevNeedleX = needleX
end

local function triggerGuiObject(obj)
    if not obj or not obj:IsA("GuiObject") then return false end

    local candidates = {obj}
    if obj.Parent and obj.Parent:IsA("GuiObject") then
        table.insert(candidates, obj.Parent)
    end
    local ancestorBtn = obj:FindFirstAncestorOfClass("GuiButton")
    if ancestorBtn and ancestorBtn ~= obj and ancestorBtn ~= obj.Parent then
        table.insert(candidates, ancestorBtn)
    end
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("GuiButton") then
            table.insert(candidates, child)
        end
    end

    local fired = false

    for _, target in ipairs(candidates) do
        if typeof(firesignal) == "function" then
            pcall(function()
                if target:IsA("GuiButton") then
                    firesignal(target.Activated)
                    firesignal(target.MouseButton1Click)
                    firesignal(target.MouseButton1Down)
                    firesignal(target.MouseButton1Up)
                    fired = true
                end
            end)
        end

        if typeof(getconnections) == "function" then
            pcall(function()
                if target:IsA("GuiButton") then
                    for _, c in ipairs(getconnections(target.Activated)) do
                        pcall(function() c:Fire() fired = true end)
                    end
                    for _, c in ipairs(getconnections(target.MouseButton1Click)) do
                        pcall(function() c:Fire() fired = true end)
                    end
                    for _, c in ipairs(getconnections(target.MouseButton1Down)) do
                        pcall(function() c:Fire() fired = true end)
                    end
                end
                for _, c in ipairs(getconnections(target.InputBegan)) do
                    pcall(function()
                        c:Fire({
                            UserInputType = Enum.UserInputType.MouseButton1,
                            UserInputState = Enum.UserInputState.Begin,
                            Position = Vector3.new(0, 0, 0),
                        }, false)
                        fired = true
                    end)
                end
            end)
        end
    end

    if not fired then
        local pos = obj.AbsolutePosition
        local size = obj.AbsoluteSize
        local centerX = pos.X + (size.X * 0.5)
        local centerY = pos.Y + (size.Y * 0.5)
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
            task.wait(0.015)
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
        end)
    end

    return true
end

local function isBlueSkillPipColor(c)
    if not c then return false end
    return (c.B > 0.78) and (c.G > 0.58) and (c.R < 0.55)
end

local function cleanMenuText(rawText)
    if not rawText then return "" end
    local stripped = rawText:gsub("<[^>]+>", ""):upper()
    stripped = stripped:gsub("^[^%w]+", ""):gsub("[^%w]+$", "")
    return stripped
end

local function scanCombatMenu()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1024, 768)
    local attackBtn = nil
    local skillsBtn = nil
    local combatGui = nil
    local parsedEN = nil
    local bluePipFound = false

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    if obj.Visible then
                        local raw = obj.Text or ""
                        local upper = raw:upper()

                        local enMatch = upper:match("EN%s*(%d+)%s*/%s*%d+")
                        if enMatch and isActuallyVisible(obj) then
                            parsedEN = tonumber(enMatch)
                        end

                        local cleaned = cleanMenuText(raw)
                        if cleaned == "ATTACK" and obj.AbsolutePosition.X < (vp.X * 0.35) and obj.AbsolutePosition.Y > (vp.Y * 0.50) then
                            if isActuallyVisible(obj) then
                                attackBtn = obj
                                combatGui = gui
                            end
                        elseif cleaned == "SKILLS" and obj.AbsolutePosition.X < (vp.X * 0.35) and obj.AbsolutePosition.Y > (vp.Y * 0.50) then
                            if isActuallyVisible(obj) then
                                skillsBtn = obj
                                combatGui = gui
                            end
                        elseif cleaned == "EN" and obj.AbsolutePosition.Y < (vp.Y * 0.60) and isActuallyVisible(obj) then
                            local statusContainer = obj.Parent and obj.Parent.Parent or obj.Parent
                            if statusContainer then
                                for _, sub in ipairs(statusContainer:GetDescendants()) do
                                    if sub:IsA("GuiObject") and not sub:IsA("TextLabel") and sub.Visible and sub.BackgroundTransparency < 0.5 then
                                        if sub.AbsoluteSize.X >= 2 and sub.AbsoluteSize.X <= 30 and math.abs(sub.AbsolutePosition.Y - obj.AbsolutePosition.Y) <= 14 then
                                            if isBlueSkillPipColor(sub.BackgroundColor3) and isActuallyVisible(sub) then
                                                bluePipFound = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not combatGui or (not attackBtn and not skillsBtn) then
        return nil
    end

    local currentEN = 0
    if parsedEN ~= nil then
        currentEN = parsedEN
    elseif bluePipFound then
        currentEN = 1
    end

    return {
        gui = combatGui,
        attackBtn = attackBtn,
        skillsBtn = skillsBtn,
        currentEN = currentEN,
        hasBluePoints = (currentEN > 0) or bluePipFound,
    }
end

local function isDescriptionOrSystemText(txt)
    if #txt < 2 or #txt > 34 then return true end
    if txt:find("SCALES WITH") or txt:find("IGNORES") or txt:find("LOOSE AN") or txt:find("DEALS ") then return true end
    if txt:find("^LV%s*%d+") or txt:find("^EN%s*%d+") or txt:find("^%d+%.?%d*K?/") then return true end
    if txt == "PARTY" or txt:find("^FOES") or txt == "ATTACK" or txt == "SKILLS" or txt == "SCROLL" or txt == "GUARD" or txt == "MEDITATE" or txt:find("^SATCHEL") or txt == "BACK" or txt == "CANCEL" then
        return true
    end
    local playerName = LocalPlayer.Name:upper()
    local displayName = LocalPlayer.DisplayName:upper()
    if txt == playerName or txt == displayName then return true end
    return false
end

local function getCenterPanelOptions(combatGui, currentEN)
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1024, 768)
    local minX = vp.X * 0.14
    local maxX = vp.X * 0.74
    local minY = vp.Y * 0.58

    local buttonOptions = {}
    local labelOptions = {}

    for _, obj in ipairs(combatGui:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local pos = obj.AbsolutePosition
            local size = obj.AbsoluteSize
            if pos.X >= minX and pos.X <= maxX and pos.Y >= minY and size.X >= 20 and size.Y >= 12 and size.Y <= 70 then
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local txt = obj:IsA("TextButton") and cleanMenuText(obj.Text) or ""
                    if txt == "" then
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("TextLabel") and child.Visible then
                                local ctxt = cleanMenuText(child.Text)
                                if ctxt ~= "" and not isDescriptionOrSystemText(ctxt) then
                                    txt = ctxt
                                    break
                                end
                            end
                        end
                    end
                    if not isDescriptionOrSystemText(txt) and isActuallyVisible(obj) then
                        local costMatch = (obj:IsA("TextButton") and obj.Text:upper():match("(%d+)%s*EN")) or nil
                        if not costMatch or not currentEN or tonumber(costMatch) <= currentEN then
                            table.insert(buttonOptions, obj)
                        end
                    end
                elseif obj:IsA("TextLabel") then
                    local raw = obj.Text or ""
                    local txt = cleanMenuText(raw)
                    if not isDescriptionOrSystemText(txt) and raw == raw:upper() and isActuallyVisible(obj) then
                        local costMatch = raw:upper():match("(%d+)%s*EN")
                        if not costMatch or not currentEN or tonumber(costMatch) <= currentEN then
                            table.insert(labelOptions, obj)
                        end
                    end
                end
            end
        end
    end

    if #buttonOptions > 0 then
        return buttonOptions
    end
    return labelOptions
end

local function selectEnemyTarget(combatGui)
    if not combatGui then return false end
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1024, 768)
    local minX = vp.X * 0.68
    local minY = vp.Y * 0.58

    local targetCandidates = {}

    for _, obj in ipairs(combatGui:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible and isActuallyVisible(obj) then
            local pos = obj.AbsolutePosition
            local size = obj.AbsoluteSize
            if pos.X >= minX and pos.Y >= minY and size.X >= 45 and size.Y >= 14 and size.Y <= 70 then
                local txt = (obj:IsA("TextLabel") or obj:IsA("TextButton")) and cleanMenuText(obj.Text) or ""
                if txt ~= "PARTY" and txt ~= "FOES" and not txt:find("^FOES") then
                    table.insert(targetCandidates, obj)
                end
            end
        end
    end

    if #targetCandidates > 0 then
        triggerGuiObject(targetCandidates[1])
        task.wait(0.08)
    end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)

    return #targetCandidates > 0
end

local function executeBasicAttack(menuState)
    if not menuState or not menuState.attackBtn then return end
    triggerGuiObject(menuState.attackBtn)
    task.wait(0.18)
    if bowCache.active or dodgeCache.active then return end
    selectEnemyTarget(menuState.gui)
end

local combatThread = task.spawn(function()
    while isRunning and ScreenGui.Parent do
        if autoCombatEnabled and not bowCache.active and not dodgeCache.active then
            local menuState = scanCombatMenu()
            if menuState then
                if menuState.hasBluePoints and menuState.skillsBtn then
                    triggerGuiObject(menuState.skillsBtn)
                    task.wait(0.22)

                    if not bowCache.active and not dodgeCache.active then
                        local skillOptions = getCenterPanelOptions(menuState.gui, menuState.currentEN)
                        if #skillOptions > 0 then
                            local chosenSkill = skillOptions[math.random(1, #skillOptions)]
                            triggerGuiObject(chosenSkill)
                            task.wait(0.18)
                            if not bowCache.active and not dodgeCache.active then
                                selectEnemyTarget(menuState.gui)
                            end
                            task.wait(0.25)
                        end

                        if not bowCache.active and not dodgeCache.active then
                            local afterCheck = scanCombatMenu()
                            if afterCheck and afterCheck.attackBtn then
                                executeBasicAttack(afterCheck)
                            end
                        end
                    end
                elseif menuState.attackBtn then
                    executeBasicAttack(menuState)
                end

                task.wait(0.45)
            else
                task.wait(0.25)
            end
        else
            task.wait(0.15)
        end
    end
end)
table.insert(activeThreads, combatThread)

createSection("⚔️ Combat & Minigame")

createToggle(
    "⚔️ Auto Combat (Attack & Skill)",
    false,
    function(state)
        autoCombatEnabled = state
    end
)

createToggle(
    "🎯 Auto Bow (Perfect Hit)",
    false,
    function(state)
        autoBowEnabled = state
        if not state then
            bowCache.active = false
            bowHasResetToBottom = true
            prevBowY = nil
        end
    end
)

createToggle(
    "🛡️ Auto Dodge (White Zone)",
    false,
    function(state)
        autoDodgeEnabled = state
        if not state then
            dodgeCache.active = false
            dodgeHasReset = true
            prevNeedleX = nil
        end
    end
)

local function enableSmoothDrag(frame, dragHandle)
    local dragging = false
    local dragInput, dragStart, startPos

    trackConnection(dragHandle.InputBegan:Connect(function(input)
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
    end))

    trackConnection(dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    trackConnection(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.06, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end))
end

enableSmoothDrag(MainFrame, TopBar)
enableSmoothDrag(ToggleBubble, ToggleBubble)

local isWindowVisible = true
local function toggleUI()
    isWindowVisible = not isWindowVisible
    if isWindowVisible then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 310, 0, 235)
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 340, 0, 260)
        }):Play()
    else
        local shrinkTween = TweenService:Create(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 310, 0, 235)
        })
        shrinkTween:Play()
        shrinkTween.Completed:Wait()
        if not isWindowVisible then
            MainFrame.Visible = false
        end
    end
end

trackConnection(CloseBtn.MouseButton1Click:Connect(toggleUI))
trackConnection(ToggleBubble.MouseButton1Click:Connect(toggleUI))

trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.V then
        toggleUI()
    end
end))

trackConnection(RunService.RenderStepped:Connect(function()
    if not ScreenGui.Parent then
        cleanupAll()
        return
    end

    stepBow()
    stepDodge()

    if isWindowVisible then
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end

        UserInputService.MouseIconEnabled = true

        local mousePos = UserInputService:GetMouseLocation()
        VirtualCursor.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
        VirtualCursor.Visible = true
    else
        VirtualCursor.Visible = false
    end
end))
