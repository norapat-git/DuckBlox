local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
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
VirtualCursor.ZIndex = 999999
VirtualCursor.Active = false
VirtualCursor.Visible = false
VirtualCursor.Parent = ScreenGui

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

local COMBAT_CONFIG = {
    ActionDelay = 0.5,
    PrioritizeSkills = true,
    CombatGuiKeywords = {"Combat", "Battle", "Fight", "Turn", "Match", "Action", "Dungeon", "Duel"},
    AttackNames = {
        "Attack", "AttackBtn", "BasicAttack", "NormalAttack", "Strike",
        "Hit", "Slash", "Punch", "Shoot", "Fire", "ActionButton", "Primary"
    },
    SkillNames = {
        "Skill", "Skill1", "Skill2", "Skill3", "Skill4", "SkillBtn",
        "Ability", "Ability1", "Ability2", "Ability3",
        "Spell", "Magic", "Special", "Burst", "Ultimate"
    },
    TargetNames = {"Target", "Select", "Confirm", "Enemy", "Opponent", "LockOn"},
}

local function clickGuiButton(button)
    if not button or not button:IsA("GuiObject") then return false end
    local pos = button.AbsolutePosition
    local size = button.AbsoluteSize
    local centerX = pos.X + (size.X / 2)
    local centerY = pos.Y + (size.Y / 2)

    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.015)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end)
    return true
end

local function isSkillReady(button)
    if not button.Visible then return false end

    if button:IsA("TextButton") then
        local txt = button.Text:gsub("%s+", "")
        if tonumber(txt) or txt:match("^%d+%.?%d*s?$") then
            return false
        end
    end

    for _, child in ipairs(button:GetDescendants()) do
        if child:IsA("GuiObject") and child.Visible then
            local cname = child.Name:lower()
            if (cname:find("cooldown") or cname:find("cd") or cname:find("mask")) and child.BackgroundTransparency < 0.9 then
                return false
            end
            if child:IsA("TextLabel") and child.Visible then
                local ltxt = child.Text:gsub("%s+", "")
                if tonumber(ltxt) or ltxt:match("^%d+%.?%d*s?$") then
                    return false
                end
            end
        end
    end

    return true
end

local function getActiveCombatGui()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local lname = gui.Name:lower()
            for _, kw in ipairs(COMBAT_CONFIG.CombatGuiKeywords) do
                if lname:find(kw:lower()) then
                    return gui
                end
            end
        end
    end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, attName in ipairs(COMBAT_CONFIG.AttackNames) do
                local found = gui:FindFirstChild(attName, true)
                if found and found:IsA("GuiObject") and isActuallyVisible(found) then
                    return gui
                end
            end
        end
    end

    return nil
end

local combatThread = task.spawn(function()
    while isRunning and ScreenGui.Parent do
        if autoCombatEnabled and not bowCache.active and not dodgeCache.active then
            local combatGui = getActiveCombatGui()
            if combatGui then
                local actionDone = false

                if COMBAT_CONFIG.PrioritizeSkills then
                    for _, sName in ipairs(COMBAT_CONFIG.SkillNames) do
                        if bowCache.active or dodgeCache.active then break end
                        local skillBtn = combatGui:FindFirstChild(sName, true)
                        if skillBtn and skillBtn:IsA("GuiObject") and isActuallyVisible(skillBtn) and isSkillReady(skillBtn) then
                            clickGuiButton(skillBtn)
                            actionDone = true
                            task.wait(0.2)
                            break
                        end
                    end
                end

                if not actionDone and not bowCache.active and not dodgeCache.active then
                    for _, aName in ipairs(COMBAT_CONFIG.AttackNames) do
                        local atkBtn = combatGui:FindFirstChild(aName, true)
                        if atkBtn and atkBtn:IsA("GuiObject") and isActuallyVisible(atkBtn) then
                            clickGuiButton(atkBtn)
                            actionDone = true
                            break
                        end
                    end
                end

                if not bowCache.active and not dodgeCache.active then
                    task.wait(0.12)
                    for _, tName in ipairs(COMBAT_CONFIG.TargetNames) do
                        local targetBtn = combatGui:FindFirstChild(tName, true)
                        if targetBtn and targetBtn:IsA("GuiObject") and isActuallyVisible(targetBtn) then
                            clickGuiButton(targetBtn)
                            break
                        end
                    end
                end

                task.wait(COMBAT_CONFIG.ActionDelay)
            else
                task.wait(0.5)
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
