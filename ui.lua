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

local activeDefenseClient = nil
local activeQTE = nil
local activeWarriorTiming = nil
local activeThiefTiming = nil
local activeMageTiming = nil
local activeCommandMenu = nil
local activeRunMapView = nil
local autoPlayEnabled = false
local lastAutoPlayAction = 0

local function isMinigameActive()
    if activeQTE then
        local running = false
        pcall(function()
            if typeof(activeQTE.IsRunning) == "function" then
                running = activeQTE:IsRunning()
            end
        end)
        if running then return true end
    end
    if activeDefenseClient ~= nil then
        return true
    end
    return false
end

local function initGameFrameworkHooks()
    pcall(function()
        local ps = LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts")
        local pbc = ps and ps:FindFirstChild("PlatformBattlesClient")
        if not pbc then return end

        local qteMod = pbc:FindFirstChild("PixelQTE")
        if qteMod then
            local QTE = require(qteMod)
            if typeof(QTE) == "table" and not QTE._duckbloxHooked then
                QTE._duckbloxHooked = true
                local rawNew = QTE.new
                if typeof(rawNew) == "function" then
                    QTE.new = function(...)
                        local inst = rawNew(...)
                        activeQTE = inst
                        return inst
                    end
                end
                local rawRun = QTE._run
                if typeof(rawRun) == "function" then
                    QTE._run = function(self, ...)
                        activeQTE = self
                        local res = rawRun(self, ...)
                        if autoBowEnabled then
                            task.spawn(function()
                                while autoBowEnabled and isRunning do
                                    local isQTERunning = false
                                    pcall(function()
                                        if typeof(self.IsRunning) == "function" then
                                            isQTERunning = self:IsRunning()
                                        end
                                    end)
                                    if not isQTERunning then break end
                                    task.wait(0.08)
                                    pcall(function()
                                        if typeof(self._press) == "function" then
                                            self:_press()
                                        end
                                    end)
                                end
                            end)
                        end
                        return res
                    end
                end
                local rawDefense = QTE._defense
                if typeof(rawDefense) == "function" then
                    QTE._defense = function(self, ...)
                        activeQTE = self
                        local res = rawDefense(self, ...)
                        if autoDodgeEnabled then
                            task.spawn(function()
                                task.wait(0.08)
                                pcall(function()
                                    if typeof(self._press) == "function" then
                                        self:_press()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
                local rawGradeAt = QTE._gradeAt
                if typeof(rawGradeAt) == "function" then
                    QTE._gradeAt = function(self, ...)
                        local origGrade = rawGradeAt(self, ...)
                        if autoBowEnabled or autoDodgeEnabled then
                            if typeof(origGrade) == "string" then
                                return "Perfect"
                            elseif typeof(origGrade) == "number" then
                                return 1
                            elseif typeof(origGrade) == "table" then
                                if origGrade.Grade then origGrade.Grade = "Perfect" end
                                if origGrade.grade then origGrade.grade = "Perfect" end
                                if origGrade.Outcome then origGrade.Outcome = "Perfect" end
                                return origGrade
                            end
                        end
                        return origGrade
                    end
                end
            end
        end

        local warriorMod = pbc:FindFirstChild("WarriorBladeTimingClient")
        if warriorMod then
            local WB = require(warriorMod)
            if typeof(WB) == "table" and not WB._duckbloxHooked then
                WB._duckbloxHooked = true
                local rawNew = WB.new
                if typeof(rawNew) == "function" then
                    WB.new = function(...)
                        local inst = rawNew(...)
                        activeWarriorTiming = inst
                        return inst
                    end
                end
                local rawStart = WB.Start
                if typeof(rawStart) == "function" then
                    WB.Start = function(self, ...)
                        activeWarriorTiming = self
                        local res = rawStart(self, ...)
                        if autoBowEnabled then
                            task.spawn(function()
                                task.wait(0.12)
                                pcall(function()
                                    if typeof(self._completeTrace) == "function" then
                                        self:_completeTrace()
                                    elseif typeof(self._finish) == "function" then
                                        self:_finish()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
            end
        end

        local thiefMod = pbc:FindFirstChild("ThiefSlashClient")
        if thiefMod then
            local TS = require(thiefMod)
            if typeof(TS) == "table" and not TS._duckbloxHooked then
                TS._duckbloxHooked = true
                local rawNew = TS.new
                if typeof(rawNew) == "function" then
                    TS.new = function(...)
                        local inst = rawNew(...)
                        activeThiefTiming = inst
                        return inst
                    end
                end
                local rawStart = TS.Start
                if typeof(rawStart) == "function" then
                    TS.Start = function(self, ...)
                        activeThiefTiming = self
                        local res = rawStart(self, ...)
                        if autoBowEnabled then
                            task.spawn(function()
                                task.wait(0.1)
                                pcall(function()
                                    if typeof(self._trySlash) == "function" then
                                        self:_trySlash()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
            end
        end

        local mageMod = pbc:FindFirstChild("MageRhythmClient")
        if mageMod then
            local MR = require(mageMod)
            if typeof(MR) == "table" and not MR._duckbloxHooked then
                MR._duckbloxHooked = true
                local rawNew = MR.new
                if typeof(rawNew) == "function" then
                    MR.new = function(...)
                        local inst = rawNew(...)
                        activeMageTiming = inst
                        return inst
                    end
                end
                local rawStart = MR.Start
                if typeof(rawStart) == "function" then
                    MR.Start = function(self, ...)
                        activeMageTiming = self
                        local res = rawStart(self, ...)
                        if autoBowEnabled then
                            task.spawn(function()
                                task.wait(0.15)
                                pcall(function()
                                    if typeof(self.Resolve) == "function" then
                                        self:Resolve()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
            end
        end

        local menuMod = pbc:FindFirstChild("PixelCommandMenu")
        if menuMod then
            local PCM = require(menuMod)
            if typeof(PCM) == "table" and not PCM._duckbloxHooked then
                PCM._duckbloxHooked = true
                local rawNew = PCM.new
                if typeof(rawNew) == "function" then
                    PCM.new = function(...)
                        local inst = rawNew(...)
                        activeCommandMenu = inst
                        return inst
                    end
                end
            end
        end

        local dtcMod = pbc:FindFirstChild("DefenseTimingClient")
        if dtcMod then
            local DTC = require(dtcMod)
            if typeof(DTC) == "table" and not DTC._duckbloxHooked then
                DTC._duckbloxHooked = true
                local rawNew = DTC.new
                if typeof(rawNew) == "function" then
                    DTC.new = function(...)
                        local inst = rawNew(...)
                        activeDefenseClient = inst
                        return inst
                    end
                end
                local rawStart = DTC.Start
                if typeof(rawStart) == "function" then
                    DTC.Start = function(self, ...)
                        activeDefenseClient = self
                        local res = rawStart(self, ...)
                        if autoDodgeEnabled then
                            task.spawn(function()
                                task.wait(0.08)
                                pcall(function()
                                    if typeof(self.Press) == "function" then
                                        self:Press()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
                local rawResolve = DTC.Resolve
                if typeof(rawResolve) == "function" then
                    DTC.Resolve = function(self, ...)
                        if activeDefenseClient == self then
                            activeDefenseClient = nil
                        end
                        return rawResolve(self, ...)
                    end
                end
                local rawDestroy = DTC.Destroy
                if typeof(rawDestroy) == "function" then
                    DTC.Destroy = function(self, ...)
                        if activeDefenseClient == self then
                            activeDefenseClient = nil
                        end
                        return rawDestroy(self, ...)
                    end
                end
            end
        end

        local runMapMod = pbc:FindFirstChild("RunMapView")
        if runMapMod then
            local RMV = require(runMapMod)
            if typeof(RMV) == "table" and not RMV._duckbloxHooked then
                RMV._duckbloxHooked = true
                local rawNew = RMV.new
                if typeof(rawNew) == "function" then
                    RMV.new = function(...)
                        local inst = rawNew(...)
                        activeRunMapView = inst
                        return inst
                    end
                end
            end
        end
    end)
end
initGameFrameworkHooks()

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
    if isMinigameActive() then return end
    selectEnemyTarget(menuState.gui)
end

local function tryCodeCombat()
    if not activeCommandMenu then return false end
    local canAct = false
    pcall(function()
        if typeof(activeCommandMenu._canAct) == "function" then
            canAct = activeCommandMenu:_canAct()
        end
    end)
    if not canAct then return false end

    local myEN = 0
    pcall(function()
        if typeof(activeCommandMenu._myEnergy) == "function" then
            myEN = tonumber(activeCommandMenu:_myEnergy()) or 0
        end
    end)

    local executed = false
    if myEN > 0 then
        pcall(function()
            if typeof(activeCommandMenu._setCommand) == "function" then
                activeCommandMenu:_setCommand(2)
            end
            if typeof(activeCommandMenu._confirmCommand) == "function" then
                activeCommandMenu:_confirmCommand()
            end
            task.wait(0.08)
            if typeof(activeCommandMenu._openList) == "function" then
                activeCommandMenu:_openList()
            end
            if typeof(activeCommandMenu._setListIndex) == "function" then
                activeCommandMenu:_setListIndex(1)
            end
            if typeof(activeCommandMenu._confirmList) == "function" then
                activeCommandMenu:_confirmList()
            end
            task.wait(0.08)
            if typeof(activeCommandMenu._beginTargeting) == "function" then
                activeCommandMenu:_beginTargeting()
            end
            if typeof(activeCommandMenu._setTarget) == "function" then
                activeCommandMenu:_setTarget(1)
            end
            if typeof(activeCommandMenu._pickTarget) == "function" then
                activeCommandMenu:_pickTarget(1)
            end
            if typeof(activeCommandMenu._perform) == "function" then
                activeCommandMenu:_perform()
                executed = true
            elseif typeof(activeCommandMenu._send) == "function" then
                activeCommandMenu:_send()
                executed = true
            end
        end)
    end

    if not executed then
        pcall(function()
            if typeof(activeCommandMenu._setCommand) == "function" then
                activeCommandMenu:_setCommand(1)
            end
            if typeof(activeCommandMenu._confirmCommand) == "function" then
                activeCommandMenu:_confirmCommand()
            end
            task.wait(0.08)
            if typeof(activeCommandMenu._beginTargeting) == "function" then
                activeCommandMenu:_beginTargeting()
            end
            if typeof(activeCommandMenu._setTarget) == "function" then
                activeCommandMenu:_setTarget(1)
            end
            if typeof(activeCommandMenu._pickTarget) == "function" then
                activeCommandMenu:_pickTarget(1)
            end
            if typeof(activeCommandMenu._perform) == "function" then
                activeCommandMenu:_perform()
                executed = true
            elseif typeof(activeCommandMenu._send) == "function" then
                activeCommandMenu:_send()
                executed = true
            end
        end)
    end

    return executed
end

local combatThread = task.spawn(function()
    while isRunning and ScreenGui.Parent do
        if autoCombatEnabled and not isMinigameActive() then
            local codeSuccess = false
            pcall(function()
                codeSuccess = tryCodeCombat()
            end)

            if codeSuccess then
                task.wait(0.4)
            else
                local menuState = scanCombatMenu()
                if menuState then
                    if menuState.hasBluePoints and menuState.skillsBtn then
                        triggerGuiObject(menuState.skillsBtn)
                        task.wait(0.22)

                        if not isMinigameActive() then
                            local skillOptions = getCenterPanelOptions(menuState.gui, menuState.currentEN)
                            if #skillOptions > 0 then
                                local chosenSkill = skillOptions[math.random(1, #skillOptions)]
                                triggerGuiObject(chosenSkill)
                                task.wait(0.18)
                                if not isMinigameActive() then
                                    selectEnemyTarget(menuState.gui)
                                end
                                task.wait(0.25)
                            end

                            if not isMinigameActive() then
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
            end
        else
            task.wait(0.15)
        end
    end
end)
table.insert(activeThreads, combatThread)

local function isDuckBloxGui(obj)
    local cur = obj
    while cur do
        if typeof(cur.Name) == "string" and cur.Name:find("DuckBlox") then
            return true
        end
        cur = cur.Parent
    end
    return false
end

local function checkAndClickContinue(playerGui)
    local continueKeywords = {
        "CONTINUE", "CLAIM", "COLLECT", "NEXT", "PROCEED", "VICTORY", "DONE",
        "ADVANCE", "OK", "TAP TO CONTINUE", "CLICK TO CONTINUE", "ACCEPT", "READY"
    }

    local bestButton = nil
    local bestPriority = 999

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and not isDuckBloxGui(gui) then
            for _, obj in ipairs(gui:GetDescendants()) do
                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and isActuallyVisible(obj) then
                    local name = obj.Name:upper()
                    local txt = obj:IsA("TextButton") and cleanMenuText(obj.Text) or ""

                    for priority, kw in ipairs(continueKeywords) do
                        if (txt == kw or txt:find("^" .. kw) or txt:find(kw .. "$") or name:find(kw)) and priority < bestPriority then
                            bestButton = obj
                            bestPriority = priority
                            break
                        end
                    end
                elseif obj:IsA("TextLabel") and isActuallyVisible(obj) then
                    local txt = cleanMenuText(obj.Text)
                    if txt == "TAP TO CONTINUE" or txt == "CLICK TO CONTINUE" or txt == "TOUCH TO CONTINUE" then
                        local parentBtn = obj.Parent
                        while parentBtn and parentBtn ~= gui do
                            if (parentBtn:IsA("TextButton") or parentBtn:IsA("ImageButton") or parentBtn:IsA("Frame")) and isActuallyVisible(parentBtn) then
                                bestButton = parentBtn
                                bestPriority = 1
                                break
                            end
                            parentBtn = parentBtn.Parent
                        end
                    end
                end
            end
        end
    end

    if bestButton then
        triggerGuiObject(bestButton)
        task.wait(0.06)
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
        return true
    end

    return false
end

local function checkAndChoosePath(playerGui)
    local pathKeywords = {
        "BATTLE", "REST", "EVENT", "ELITE", "TREASURE", "MYSTERY", "CHEST",
        "SHOP", "STAGE", "FLOOR", "VOTE", "SELECT", "CHOOSE", "ENTER"
    }

    local nodeCandidates = {}

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and not isDuckBloxGui(gui) then
            local gname = gui.Name:lower()
            local isMapOrRun = gname:find("map") or gname:find("run") or gname:find("node")
                or gname:find("choice") or gname:find("path") or gname:find("lobby")
                or gname:find("event") or gname:find("journey")

            for _, obj in ipairs(gui:GetDescendants()) do
                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and isActuallyVisible(obj) then
                    local name = obj.Name:upper()
                    local txt = obj:IsA("TextButton") and cleanMenuText(obj.Text) or ""

                    local matched = false
                    for _, kw in ipairs(pathKeywords) do
                        if txt == kw or txt:find(kw) or name:find(kw) then
                            matched = true
                            break
                        end
                    end

                    if not matched and isMapOrRun then
                        if name:find("NODE") or name:find("CHOICE") or name:find("OPTION") or name:find("PATH") or name:find("TIER") or name:find("CARD") then
                            matched = true
                        end
                    end

                    if matched and obj.AbsoluteSize.X >= 24 and obj.AbsoluteSize.Y >= 20 then
                        table.insert(nodeCandidates, obj)
                    end
                end
            end
        end
    end

    if #nodeCandidates > 0 then
        local chosenNode = nodeCandidates[1]
        triggerGuiObject(chosenNode)
        task.wait(0.08)
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
        return true
    end

    return false
end

local autoPlayThread = task.spawn(function()
    while isRunning and ScreenGui.Parent do
        if autoPlayEnabled and not isMinigameActive() then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui and (os.clock() - lastAutoPlayAction) >= 0.4 then
                local didContinue = false
                pcall(function()
                    didContinue = checkAndClickContinue(playerGui)
                end)

                if didContinue then
                    lastAutoPlayAction = os.clock()
                    task.wait(0.5)
                else
                    local didPath = false
                    pcall(function()
                        didPath = checkAndChoosePath(playerGui)
                    end)
                    if didPath then
                        lastAutoPlayAction = os.clock()
                        task.wait(0.6)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)
table.insert(activeThreads, autoPlayThread)

createSection("⚔️ Combat & Minigame")

createToggle(
    "⚔️ Auto Combat (Attack & Skill)",
    false,
    function(state)
        autoCombatEnabled = state
    end
)

createToggle(
    "🎯 Auto Minigame (Bow / All Classes)",
    false,
    function(state)
        autoBowEnabled = state
    end
)

createToggle(
    "🛡️ Auto Dodge (White Zone)",
    false,
    function(state)
        autoDodgeEnabled = state
    end
)

createSection("🗺️ Mode & Progression")

createToggle(
    "🗺️ Auto Play (Auto Path & Continue)",
    false,
    function(state)
        autoPlayEnabled = state
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
