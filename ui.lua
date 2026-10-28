--[[
    ========================================================================
    🦆 DuckBlox - Ultra Smooth Custom UI (No External Library)
    ========================================================================
    - ทำงานเร็ว ลื่น 100% Native Roblox (ไม่มีความหน่วง/Lag จาก Rayfield)
    - ไม่ต้องโหลดไลบรารีภายนอก (No HttpGet / No loadstring overhead)
    - มีระบบ Auto Bow (Auto Trigger Perfect ในมินิเกมยิงธนู)
    - ปรับแต่งหน้าตาให้สวยงาม โมเดิร์น พร้อมแอนิเมชัน TweenService ที่ลื่นไหล
    - รองรับระบบลากหน้าต่าง (Smooth Drag) และปุ่มเปิด/ปิด (Floating Toggle)
    ========================================================================
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- 1. ตรวจสอบ Parent สำหรับ GUI (รองรับทั้ง Studio และ Executor)
local parentGui
if typeof(gethui) == "function" then
    parentGui = gethui()
elseif RunService:IsStudio() then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
else
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    parentGui = (success and coreGui) or LocalPlayer:WaitForChild("PlayerGui")
end

-- ลบ UI ตัวเก่าออกถ้ามีอยู่
if parentGui:FindFirstChild("DuckBloxCustomUI") then
    parentGui.DuckBloxCustomUI:Destroy()
end

-- ========================================================
-- 🎨 STYLING CONFIG (ชุดสีและรูปแบบสไตล์ Modern Dark)
-- ========================================================
local THEME = {
    Background = Color3.fromRGB(20, 22, 28),
    TopBar = Color3.fromRGB(27, 30, 39),
    CardBg = Color3.fromRGB(30, 34, 44),
    Accent = Color3.fromRGB(88, 101, 242),       -- Discord Blurple
    Success = Color3.fromRGB(46, 204, 113),     -- Emerald Green
    Warning = Color3.fromRGB(241, 196, 15),     -- Gold
    Danger = Color3.fromRGB(231, 76, 60),       -- Red
    Text = Color3.fromRGB(245, 245, 250),
    TextMuted = Color3.fromRGB(150, 155, 175),
    Border = Color3.fromRGB(45, 50, 65),
}

-- ========================================================
-- 📦 GUI INSTANCES
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DuckBloxCustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999 -- อยู่บนสุดเหนือ UI และ Custom Cursor ของเกมเสมอ
ScreenGui.Parent = parentGui

-- 🖱️ Virtual Hardware Cursor (เคอร์เซอร์สำรอง รับประกันว่าเมาส์จะมองเห็นได้ 100%)
local VirtualCursor = Instance.new("ImageLabel")
VirtualCursor.Name = "DuckBloxVirtualCursor"
VirtualCursor.Size = UDim2.new(0, 24, 0, 24)
VirtualCursor.BackgroundTransparency = 1
VirtualCursor.Image = "rbxasset://textures/ArrowCursor.png"
VirtualCursor.ZIndex = 999999
VirtualCursor.Active = false -- ป้องกันไม่ให้บังการคลิกปุ่ม
VirtualCursor.Visible = false
VirtualCursor.Parent = ScreenGui

-- 🔘 Floating Toggle Button (ปุ่มกลมลอยบนจอสำหรับซ่อน/แสดง)
local ToggleBubble = Instance.new("TextButton")
ToggleBubble.Name = "ToggleBubble"
ToggleBubble.Size = UDim2.new(0, 52, 0, 52)
ToggleBubble.Position = UDim2.new(0.03, 0, 0.45, 0)
ToggleBubble.BackgroundColor3 = THEME.TopBar
ToggleBubble.Text = "🏹"
ToggleBubble.TextSize = 22
ToggleBubble.TextColor3 = THEME.Text
ToggleBubble.AutoButtonColor = false
ToggleBubble.Active = true -- ป้องกันคลิกทะลุเข้าเกม
ToggleBubble.Parent = ScreenGui

local BubbleCorner = Instance.new("UICorner")
BubbleCorner.CornerRadius = UDim.new(1, 0)
BubbleCorner.Parent = ToggleBubble

local BubbleStroke = Instance.new("UIStroke")
BubbleStroke.Color = THEME.Accent
BubbleStroke.Thickness = 2
BubbleStroke.Parent = ToggleBubble

-- 🖥️ Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -130)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true -- ซึมซับการคลิก ไม่ให้ทะลุไปยิงธนูในเกมเวลาลากหน้าต่าง
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.Border
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- TopBar (แถบด้านบนสำหรับลากหน้าต่าง)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = THEME.TopBar
TopBar.BorderSizePixel = 0
TopBar.Active = true -- ให้ TopBar ดักจับการคลิกเวลาลาก ไม่ส่ง Mouse1 ไปในเกม
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 14)
TopBarCorner.Parent = TopBar

-- Fix TopBar Corner ให้มุมล่างเรียบ
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

-- ปุ่มปิด (Close Button)
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

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Danger, TextColor3 = Color3.new(1, 1, 1)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 42, 54), TextColor3 = THEME.TextMuted}):Play()
end)

-- Scroll Container
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

-- ========================================================
-- 🧩 UI BUILDER HELPERS (ฟังก์ชันช่วยสร้าง Element)
-- ========================================================

-- Section Title
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

-- Interactive Button
local function createButton(text, icon, bgColor, onClick)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = bgColor or THEME.CardBg
    button.Text = (icon and icon .. "  " or "") .. text
    button.TextColor3 = THEME.Text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13.5
    button.AutoButtonColor = false
    button.Parent = ScrollContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.Border
    stroke.Thickness = 1
    stroke.Parent = button

    -- Smooth Hover & Click Tween
    local originalBg = button.BackgroundColor3
    local hoverBg = Color3.fromRGB(
        math.min(255, originalBg.R * 255 + 22),
        math.min(255, originalBg.G * 255 + 22),
        math.min(255, originalBg.B * 255 + 22)
    )

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = hoverBg
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = originalBg
        }):Play()
    end)

    button.MouseButton1Click:Connect(function()
        local pressTween = TweenService:Create(button, TweenInfo.new(0.08), {Size = UDim2.new(0.98, 0, 0, 40)})
        pressTween:Play()
        pressTween.Completed:Wait()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 42)}):Play()

        if onClick then
            pcall(onClick)
        end
    end)

    return button
end

-- Toggle Switch Component (สวิตช์แบบเคลื่อนไหวลื่นไหล คลีนไร้คำอธิบาย)
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

    -- Switch Capsule
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

        if onToggle then
            onToggle(isEnabled)
        end
    end

    switch.MouseButton1Click:Connect(function()
        updateSwitch(not isEnabled, true)
    end)

    return {
        Set = function(val) updateSwitch(val, true) end,
        Get = function() return isEnabled end
    }
end

-- ========================================================
-- 🏹 AUTO BOW LOGIC (ระบบตรวจจับและยิง Perfect อัตโนมัติ)
-- ========================================================
local autoBowEnabled = false
local lastBowTrigger = 0
local bowConnection = nil

local BOW_SETTINGS = {
    Cooldown = 0.45,
    Tolerance = 5,
    GuiNames = {"BowMinigame", "BowGui", "Minigame", "QTE", "TimingBar", "AimMinigame", "ArrowMinigame"},
    TargetNames = {"Perfect", "PerfectZone", "SweetSpot", "GreenZone", "TargetZone", "Target", "Goal"},
    IndicatorNames = {"Pointer", "Needle", "Indicator", "Cursor", "Bar", "Line", "Slider"},
}

local function triggerBowClick(x, y)
    -- 1. Virtual Mouse Click
    pcall(function()
        local clickX = x or (workspace.CurrentCamera.ViewportSize.X / 2)
        local clickY = y or (workspace.CurrentCamera.ViewportSize.Y / 2)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
        task.wait(0.015)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
    end)

    -- 2. Spacebar Keypress
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.015)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)

    -- 3. Tool Activate (ถ้าถือคันธนูอยู่)
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end)
end

local function isGoldColor(color)
    if not color then return false end
    return (color.R > 0.65) and (color.G > 0.55) and (color.B < 0.6) and (color.R >= color.B + 0.15)
end

local function isGreenColor(color)
    if not color then return false end
    return (color.G > 0.55) and (color.G > color.R) and (color.G > color.B)
end

local bowHasResetToBottom = true
local prevBowY = nil

local function scanAndTriggerBow()
    if not autoBowEnabled then return end
    if (os.clock() - lastBowTrigger) < BOW_SETTINGS.Cooldown then return end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    -- ค้นหา Minigame Container (ตรวจหาทั้ง POWER SHOT และชื่อทั่วไป)
    local activeContainer = nil
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("POWER SHOT") or text:find("GOLD BAND") or text:find("SPACE / CLICK") then
                        activeContainer = label:FindFirstAncestorOfClass("Frame") or label.Parent or gui
                        break
                    end
                end
            end
            if activeContainer then break end
            
            local lname = gui.Name:lower()
            if lname:find("bow") or lname:find("minigame") or lname:find("qte") or lname:find("timing") then
                activeContainer = gui
                break
            end
        end
    end

    if not activeContainer then
        -- เมื่อมินิเกมจบ ให้รีเซ็ตสถานะพร้อมเริ่มรอบใหม่
        bowHasResetToBottom = true
        prevBowY = nil
        return
    end

    local goldBand = nil
    local gaugeFrame = nil

    for _, obj in ipairs(activeContainer:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            if not goldBand then
                if name:find("gold") or name:find("band") or name:find("sweet") or name:find("perfect") or name:find("target") then
                    goldBand = obj
                elseif obj.AbsoluteSize.Y > 0 and (isGoldColor(obj.BackgroundColor3) or (obj:IsA("ImageLabel") and isGoldColor(obj.ImageColor3))) then
                    goldBand = obj
                end
            end
            if not gaugeFrame then
                if (name:find("gauge") or name:find("bar") or name:find("meter") or name:find("power")) and obj.AbsoluteSize.Y > 50 then
                    gaugeFrame = obj
                end
            end
        end
    end

    -- ค้นหาคันธนู (Bow) หรือตัวที่กำลังเลื่อน
    local indicator = nil
    for _, obj in ipairs(activeContainer:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            if (name:find("bow") or name:find("arrow") or name:find("pointer")) and not name:find("shadow") and not name:find("bg") then
                indicator = obj
                break
            end
        end
    end

    if not indicator then
        for _, obj in ipairs(activeContainer:GetDescendants()) do
            if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 5 then
                local name = obj.Name:lower()
                if name:find("fill") or name:find("power") or isGreenColor(obj.BackgroundColor3) then
                    indicator = obj
                    break
                end
            end
        end
    end

    if not indicator then return end

    -- คำนวณจุดเป้าหมาย: กึ่งกลางของ Gold Band
    local targetY = nil
    local clickPos = nil

    if goldBand then
        local goldCenter = goldBand.AbsolutePosition.Y + (goldBand.AbsoluteSize.Y * 0.5)
        targetY = goldCenter - 2
        clickPos = Vector2.new(
            goldBand.AbsolutePosition.X + (goldBand.AbsoluteSize.X / 2),
            goldCenter
        )
    elseif gaugeFrame then
        local gaugeCenter = gaugeFrame.AbsolutePosition.Y + (gaugeFrame.AbsoluteSize.Y * 0.48)
        targetY = gaugeCenter - 2
        clickPos = Vector2.new(
            gaugeFrame.AbsolutePosition.X + (gaugeFrame.AbsoluteSize.X / 2),
            gaugeCenter
        )
    end

    if not targetY then return end

    local bowCenterY = indicator.AbsolutePosition.Y + (indicator.AbsoluteSize.Y * 0.5)
    local tol = BOW_SETTINGS.Tolerance

    -- ตรวจสอบว่าคันธนูรีเซ็ตลงไปข้างล่างหรือยัง (เพื่อไม่ให้กดซ้ำรอบเดิม)
    if bowCenterY > (targetY + 15) then
        bowHasResetToBottom = true
    end

    -- คำนวณว่ากำลังเคลื่อนที่เลื่อนขึ้นจริงหรือไม่
    local isMovingUp = false
    if prevBowY ~= nil then
        local delta = prevBowY - bowCenterY
        if delta > 0.1 then -- ไวขึ้น ป้องกันเฟรมดรอป
            isMovingUp = true
        end
    end

    -- ป้องกันปัญหา Lag: ตรวจจับทั้งการอยู่กึ่งกลาง และการที่ข้ามเป้าหมายในเฟรมเดียว
    local isAtCenter = math.abs(bowCenterY - targetY) <= (tol + 2)
    local justPassed = (bowCenterY <= targetY + tol) and (bowCenterY >= targetY - 35)
    local crossedDuringLag = (prevBowY ~= nil) and (prevBowY >= targetY - 4) and (bowCenterY <= targetY + tol) and (bowCenterY >= targetY - 45)

    if bowHasResetToBottom and isMovingUp and (isAtCenter or justPassed or crossedDuringLag) then
        bowHasResetToBottom = false -- ล็อคทันที รอให้รอบถัดไปรีเซ็ตลงล่างก่อน
        lastBowTrigger = os.clock()
        triggerBowClick(clickPos.X, clickPos.Y)
        print(string.format("[Auto Bow] 🎯 POWER SHOT - Perfect Hit (Y: %.1f / Target: %.1f)", bowCenterY, targetY))
    end

    prevBowY = bowCenterY
end

-- สตาร์ท RenderStepped Loop สำหรับ Auto Bow
local function setAutoBowState(enabled)
    autoBowEnabled = enabled
    if enabled then
        if not bowConnection then
            bowConnection = RunService.RenderStepped:Connect(scanAndTriggerBow)
        end
        print("[DuckBlox UI] Auto Bow: ON (ตรวจจับระดับ Frame-Perfect)")
    else
        if bowConnection then
            bowConnection:Disconnect()
            bowConnection = nil
        end
        print("[DuckBlox UI] Auto Bow: OFF")
    end
end

-- ========================================================
-- 🛡️ AUTO DODGE LOGIC (กด Perfect Dodge ตรงแถบสีขาวอัตโนมัติ)
-- ========================================================
local autoDodgeEnabled = false
local lastDodgeTrigger = 0
local dodgeConnection = nil
local lastNeedlePositionsX = {}
local prevNeedleX = nil
local dodgeHasReset = true

local DODGE_SETTINGS = {
    Cooldown = 0.45,
    Tolerance = 8,
}

local function isWhiteColor(c)
    if not c then return false end
    return (c.R > 0.85) and (c.G > 0.85) and (c.B > 0.85)
end

-- ค้นหา ScreenGui หรือ Container หลักของ Incoming! / Dodge
local function findDodgeContainer()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("INCOMING") or text:find("DODGE") or text:find("YOUR SHIELD") then
                        return gui -- คืนค่าทั้ง ScreenGui เพื่อให้หาชิ้นส่วนในหน้าต่างเจอครบแน่นอน 100%
                    end
                end
            end
        end
    end
    return nil
end

-- ค้นหาเข็มสีแดงที่กำลังขยับแนวนอนจริง (Horizontal Motion Tracking)
local function getMovingNeedle(container)
    local bestObj = nil
    local maxMoveX = 0

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 8 then
            local prevX = lastNeedlePositionsX[obj]
            local curX = obj.AbsolutePosition.X
            if prevX ~= nil then
                local deltaX = math.abs(prevX - curX)
                if deltaX > 0.2 and deltaX > maxMoveX then
                    maxMoveX = deltaX
                    bestObj = obj
                end
            end
            lastNeedlePositionsX[obj] = curX
        end
    end

    -- Fallback ถ้ายังไม่เริ่มขยับ ให้หาตามชื่อเข็ม
    if not bestObj then
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 10 and obj.AbsoluteSize.X < 25 then
                local name = obj.Name:lower()
                if name:find("needle") or name:find("pointer") or name:find("line") or name:find("cursor") then
                    return obj
                end
            end
        end
    end

    return bestObj
end

-- ค้นหาแถบสีขาวจริง (White Zone) ในระดับความสูงเดียวกับเข็ม (กรอง TextLabel ทิ้ง)
local function findWhiteDodgeZone(container, needle)
    local needleY = needle.AbsolutePosition.Y

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible and obj ~= needle then
            -- ต้องเป็นวัตถุที่มีสีทึบ (BackgroundTransparency < 0.6) ป้องกันการจับโดน TextLabel โปร่งใส
            if obj.AbsoluteSize.X > 5 and obj.BackgroundTransparency < 0.6 then
                -- ต้องอยู่ในระดับความสูงเดียวกับเข็ม (ห่างกันไม่เกิน 40 พิกเซล)
                if math.abs(obj.AbsolutePosition.Y - needleY) < 40 then
                    local name = obj.Name:lower()
                    if name:find("white") or name:find("dodge") or name:find("sweet") or name:find("target") then
                        return obj
                    end
                    if isWhiteColor(obj.BackgroundColor3) then
                        return obj
                    end
                end
            end
        end
    end

    return nil
end

local function scanAndTriggerDodge()
    if not autoDodgeEnabled then return end
    if (os.clock() - lastDodgeTrigger) < DODGE_SETTINGS.Cooldown then return end

    local container = findDodgeContainer()
    if not container then
        dodgeHasReset = true
        prevNeedleX = nil
        lastNeedlePositionsX = {}
        return
    end

    local needle = getMovingNeedle(container)
    if not needle then return end

    local whiteZone = findWhiteDodgeZone(container, needle)
    if not whiteZone then return end

    -- พิกัดแนวนอน (X-Axis) ของ White Zone
    local whiteLeft = whiteZone.AbsolutePosition.X
    local whiteRight = whiteLeft + whiteZone.AbsoluteSize.X
    local whiteCenterX = whiteLeft + (whiteZone.AbsoluteSize.X * 0.5)

    -- พิกัด X ของเข็มสีแดง
    local needleX = needle.AbsolutePosition.X + (needle.AbsoluteSize.X * 0.5)
    local tol = DODGE_SETTINGS.Tolerance

    -- ตรวจสอบว่าเข็มอยู่นอกโซนสีขาวหรือไม่ (เพื่อรีเซ็ตเตรียมกดรอบใหม่)
    if needleX < (whiteLeft - 15) or needleX > (whiteRight + 15) then
        dodgeHasReset = true
    end

    -- คำนวณทิศทางการเคลื่อนที่ของเข็ม
    local movingDir = 0 -- 1 = ขวา, -1 = ซ้าย
    if prevNeedleX ~= nil then
        local delta = needleX - prevNeedleX
        if delta > 0.15 then
            movingDir = 1 -- เลื่อนจากซ้ายไปขวา
        elseif delta < -0.15 then
            movingDir = -1 -- เลื่อนจากขวาไปซ้าย
        end
    end

    -- ตรวจจับว่าเข็มเข้าสู่ White Zone หรือข้ามจุดกึ่งกลาง (รองรับแม้เกิด Lag)
    local isAtCenter = math.abs(needleX - whiteCenterX) <= tol
    local crossedCenter = false
    if prevNeedleX ~= nil and movingDir ~= 0 then
        if movingDir == 1 then
            -- เลื่อนจากซ้ายไปขวา: ข้าม whiteCenterX
            if (prevNeedleX <= whiteCenterX + 5) and (needleX >= whiteCenterX - tol) and (needleX <= whiteRight + 25) then
                crossedCenter = true
            end
        elseif movingDir == -1 then
            -- เลื่อนจากขวาไปซ้าย: ข้าม whiteCenterX
            if (prevNeedleX >= whiteCenterX - 5) and (needleX <= whiteCenterX + tol) and (needleX >= whiteLeft - 25) then
                crossedCenter = true
            end
        end
    end

    if dodgeHasReset and (isAtCenter or crossedCenter) then
        dodgeHasReset = false
        lastDodgeTrigger = os.clock()
        triggerBowClick(whiteCenterX, whiteZone.AbsolutePosition.Y + (whiteZone.AbsoluteSize.Y * 0.5))
        print(string.format("[Auto Dodge] 🛡️ PERFECT DODGE TRIGGERED! (Needle X: %.1f / WhiteCenter: %.1f)", needleX, whiteCenterX))
    end

    prevNeedleX = needleX
end

local function setAutoDodgeState(enabled)
    autoDodgeEnabled = enabled
    if enabled then
        if not dodgeConnection then
            dodgeConnection = RunService.RenderStepped:Connect(scanAndTriggerDodge)
        end
        print("[DuckBlox UI] Auto Dodge: ON")
    else
        if dodgeConnection then
            dodgeConnection:Disconnect()
            dodgeConnection = nil
        end
        print("[DuckBlox UI] Auto Dodge: OFF")
    end
end

-- ========================================================
-- ⚔️ AUTO COMBAT SYSTEM (ระบบต่อสู้อัตโนมัติ: โจมตี & ใช้สกิลจนจบ Combat)
-- ========================================================
local autoCombatEnabled = false
local autoCombatThread = nil

local COMBAT_CONFIG = {
    ActionDelay = 0.45,            -- หน่วงเวลาระหว่างรอบการกดแอ็กชัน (วินาที)
    PrioritizeSkills = true,       -- ลำดับความสำคัญ: ใช้ Skill ก่อน ถ้าติด CD ค่อยใช้ Attack
    
    -- คำค้นหา GUI การต่อสู้ (Combat GUI)
    CombatGuiKeywords = {"Combat", "Battle", "Fight", "Turn", "Match", "Action", "Dungeon", "Duel"},
    
    -- รายชื่อปุ่มโจมตีปกติ (Attack Buttons)
    AttackNames = {
        "Attack", "AttackBtn", "BasicAttack", "NormalAttack", "Strike", 
        "Hit", "Slash", "Punch", "Shoot", "Fire", "ActionButton", "Primary"
    },
    
    -- รายชื่อปุ่มสกิล (Skill Buttons)
    SkillNames = {
        "Skill", "Skill1", "Skill2", "Skill3", "Skill4", "SkillBtn", 
        "Ability", "Ability1", "Ability2", "Ability3", 
        "Spell", "Magic", "Special", "Burst", "Ultimate"
    },
    
    -- คำค้นหาปุ่มยืนยันเป้าหมายหรือเลือกศัตรู
    TargetNames = {"Target", "Select", "Confirm", "Enemy", "Opponent", "LockOn"},
}

-- จำลองการคลิกที่ปุ่ม GuiObject บนหน้าจอ
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

-- ตรวจสอบว่าสกิลพร้อมใช้งานหรือไม่ (ไม่ติดคูลดาวน์)
local function isSkillReady(button)
    if not button.Visible then return false end
    
    -- ตรวจสอบตัวหนังสือบนปุ่ม (กรณีระบุเวลา Cooldown เป็นวินาที เช่น "4.5", "2s")
    if button:IsA("TextButton") then
        local txt = button.Text:gsub("%s+", "")
        if tonumber(txt) or txt:match("^%d+%.?%d*s?$") then
            return false
        end
    end
    
    -- ตรวจสอบเลเยอร์ Cooldown Overlay หรือ Progress Bar
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

-- ค้นหาหน้าจอการต่อสู้ (Combat GUI) ที่กำลังเปิดอยู่
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
    
    -- หากไม่พบตามชื่อ GUI ให้สแกนหา GUI ใดๆ ที่มีปุ่ม Attack ปรากฏบนจอ
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, attName in ipairs(COMBAT_CONFIG.AttackNames) do
                local found = gui:FindFirstChild(attName, true)
                if found and found:IsA("GuiObject") and found.Visible then
                    return gui
                end
            end
        end
    end
    
    return nil
end

-- ฟังก์ชันหลัก auto combat: เลือก Attack หรือ Skill จนจบ Combat
local function autoCombat()
    print("⚔️ [DuckBlox UI] เริ่มต้นทำงาน auto combat...")
    
    while autoCombatEnabled do
        local combatGui = getActiveCombatGui()
        
        if combatGui then
            local actionDone = false
            
            -- ขั้นที่ 1: ตรวจหา Skill และกดใช้งานถ้าพร้อม (ไม่ติด CD)
            if COMBAT_CONFIG.PrioritizeSkills then
                for _, sName in ipairs(COMBAT_CONFIG.SkillNames) do
                    local skillBtn = combatGui:FindFirstChild(sName, true)
                    if skillBtn and skillBtn:IsA("GuiObject") and isSkillReady(skillBtn) then
                        clickGuiButton(skillBtn)
                        actionDone = true
                        print(("[Auto Combat] ⚡ ใช้สกิล: %s"):format(skillBtn.Name))
                        task.wait(0.2)
                        break
                    end
                end
            end
            
            -- ขั้นที่ 2: ถ้าไม่มีสกิลพร้อม ให้เลือกกด Attack ปกติ
            if not actionDone then
                for _, aName in ipairs(COMBAT_CONFIG.AttackNames) do
                    local atkBtn = combatGui:FindFirstChild(aName, true)
                    if atkBtn and atkBtn:IsA("GuiObject") and atkBtn.Visible then
                        clickGuiButton(atkBtn)
                        actionDone = true
                        print(("[Auto Combat] 🗡️ โจมตีปกติ (Attack): %s"):format(atkBtn.Name))
                        break
                    end
                end
            end
            
            -- ขั้นที่ 3: ยืนยันเป้าหมายอัตโนมัติ (Target / Confirm) ถ้ามีหน้าต่างขึ้นมา
            task.wait(0.12)
            for _, tName in ipairs(COMBAT_CONFIG.TargetNames) do
                local targetBtn = combatGui:FindFirstChild(tName, true)
                if targetBtn and targetBtn:IsA("GuiObject") and targetBtn.Visible then
                    clickGuiButton(targetBtn)
                    print("[Auto Combat] 🎯 เลือกเป้าหมายอัตโนมัติ")
                    break
                end
            end
            
            -- ขั้นที่ 4: กรณี Action RPG ทั่วไปที่ใช้ Tool หรือปุ่ม Space/LMB
            if not actionDone then
                local char = LocalPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
            
            task.wait(COMBAT_CONFIG.ActionDelay)
        else
            -- อยู่นอกสถานะต่อสู้ รอจนกว่าจะเริ่ม Combat รอบใหม่
            task.wait(0.5)
        end
    end
end

-- ฟังก์ชันสำหรับเปิด/ปิด auto combat
local function setAutoCombatState(enabled)
    autoCombatEnabled = enabled
    if enabled then
        -- เปิดระบบ Auto Bow อัตโนมัติเพื่อรองรับกรณีมี QTE Timing ระหว่างต่อสู้
        if not autoBowEnabled then
            setAutoBowState(true)
            if bowToggle and bowToggle.Set then
                bowToggle.Set(true)
            end
        end
        
        autoCombatThread = task.spawn(autoCombat)
        print("⚔️ [DuckBlox UI] Auto Combat: ON")
    else
        autoCombatEnabled = false
        if autoCombatThread then
            task.cancel(autoCombatThread)
            autoCombatThread = nil
        end
        print("⚔️ [DuckBlox UI] Auto Combat: OFF")
    end
end

-- ========================================================
-- 🎛️ POPULATE UI CONTENT (สร้างองค์ประกอบในหน้าจอ)
-- ========================================================

createSection("⚔️ Combat & Minigame")

local combatToggle = createToggle(
    "⚔️ Auto Combat (Attack & Skill)",
    false,
    function(state)
        setAutoCombatState(state)
    end
)

local bowToggle = createToggle(
    "🎯 Auto Bow (Perfect Hit)",
    false,
    function(state)
        setAutoBowState(state)
    end
)

local dodgeToggle = createToggle(
    "🛡️ Auto Dodge (White Zone)",
    false,
    function(state)
        setAutoDodgeState(state)
    end
)

-- ========================================================
-- 🖱️ SMOOTH DRAGGING & CONTROLS (ระบบลากและเปิด/ปิดหน้าต่าง)
-- ========================================================
local function enableSmoothDrag(frame, dragHandle)
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
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

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.06, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end

enableSmoothDrag(MainFrame, TopBar)
enableSmoothDrag(ToggleBubble, ToggleBubble)

-- Toggle UI Visibility with Smooth Scale/Fade Animation
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

CloseBtn.MouseButton1Click:Connect(toggleUI)
ToggleBubble.MouseButton1Click:Connect(toggleUI)

-- ปุ่มลัดบนคีย์บอร์ด (RightControl หรือ V สำหรับเปิด/ปิด UI)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.V then
        toggleUI()
    end
end)

-- 🖱️ จัดการแสดงผล Cursor ตลอดเวลาที่เปิด UI (แก้ปัญหาเกมซ่อนเมาส์/ล็อคเมาส์)
RunService.RenderStepped:Connect(function()
    if isWindowVisible then
        -- 1. ปลดล็อคเมาส์จากการล็อคกลางจอ (Camera LockCenter)
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end

        -- 2. สั่งเปิด MouseIcon ของระบบ
        UserInputService.MouseIconEnabled = true

        -- 3. อัปเดตตำแหน่ง Virtual Cursor สำรองให้ชี้ตรงหัวเมาส์แบบเรียลไทม์
        local mousePos = UserInputService:GetMouseLocation()
        VirtualCursor.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
        VirtualCursor.Visible = true
    else
        VirtualCursor.Visible = false
    end
end)

print("🦆 [DuckBlox UI] Ultra Smooth Custom UI โหลดสำเร็จแล้ว!")
