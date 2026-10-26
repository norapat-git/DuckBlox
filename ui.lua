--[[
    Roblox Modern Clickable UI Script
    - รองรับทั้งใน Roblox Studio (PlayerGui) และ Executor ทั่วไป (gethui / CoreGui)
    - สามารถลากหน้าต่างได้ (Draggable)
    - มีปุ่มเปิด/ปิด (Toggle UI)
    - มีปุ่มตัวอย่างสำหรับกดใช้งาน (Speed Boost, High Jump, Reset)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 1. ตรวจสอบที่อยู่ Parent สำหรับวาง ScreenGui (ป้องกัน error กรณีรันในสภาพแวดล้อมต่างๆ)
local parentGui
if typeof(gethui) == "function" then
    parentGui = gethui()
elseif game:GetService("RunService"):IsStudio() then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
else
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    parentGui = (success and coreGui) or LocalPlayer:WaitForChild("PlayerGui")
end

-- ลบ UI เก่าทิ้งก่อนถ้ามี เพื่อไม่ให้ซ้อนกัน
if parentGui:FindFirstChild("ModernCustomUI") then
    parentGui.ModernCustomUI:Destroy()
end

-- 2. สร้าง ScreenGui หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernCustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

-- 3. ปุ่มกลมสำหรับ Toggle เปิด/ปิด UI บนหน้าจอ
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
ToggleBtn.Text = "UI"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(88, 101, 242)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

-- 4. หน้าต่างหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 360)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- แถบหัวเรื่องด้านบน (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Custom Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- ปุ่มปิด (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(235, 69, 75)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- กล่องรวมปุ่มกด (Buttons Container)
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95)
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Container

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.Parent = Container

-- 5. ฟังก์ชันสำหรับสร้างปุ่มกด (Create Button Helper)
local function createButton(text, color, onClick)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = color or Color3.fromRGB(40, 42, 54)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = Container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(60, 63, 78)
    btnStroke.Thickness = 1
    btnStroke.Parent = button

    -- เอฟเฟกต์แอนิเมชันเวลาเอาเมาส์ชี้และกด (Hover & Click Tween)
    local originalColor = button.BackgroundColor3
    local hoverColor = Color3.fromRGB(
        math.min(255, originalColor.R * 255 + 20),
        math.min(255, originalColor.G * 255 + 20),
        math.min(255, originalColor.B * 255 + 20)
    )

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        -- แอนิเมชันตอนกดปุ่ม
        local pressTween = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0.97, 0, 0, 39)})
        pressTween:Play()
        pressTween.Completed:Wait()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 42)}):Play()

        if onClick then
            pcall(onClick)
        end
    end)

    return button
end

-- 6. ระบบลากหน้าต่าง (Smooth Dragging)
local function makeDraggable(frame, dragHandle)
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
            TweenService:Create(frame, TweenInfo.new(0.08), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

makeDraggable(MainFrame, TopBar)
makeDraggable(ToggleBtn, ToggleBtn)

-- 7. ระบบซ่อน/แสดงหน้าต่าง
local isOpen = true
local function setUIVisible(visible)
    isOpen = visible
    MainFrame.Visible = visible
end

CloseBtn.MouseButton1Click:Connect(function()
    setUIVisible(false)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    setUIVisible(not isOpen)
end)

-- 8. ฟังก์ชันช่วยค้นหาตัวละคร
local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

-- ==========================================
-- 9. เพิ่มปุ่มคำสั่งต่างๆ ตรงนี้ (Custom Buttons)
-- ==========================================

createButton("⚡ Speed Boost (50)", Color3.fromRGB(88, 101, 242), function()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = 50
        print("[UI] WalkSpeed ตั้งเป็น 50 แล้ว")
    end
end)

createButton("🚀 High Jump (120)", Color3.fromRGB(59, 165, 93), function()
    local hum = getHumanoid()
    if hum then
        hum.JumpPower = 120
        print("[UI] JumpPower ตั้งเป็น 120 แล้ว")
    end
end)

createButton("🔄 Reset Stats (ปกติ)", Color3.fromRGB(240, 71, 71), function()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        print("[UI] รีเซ็ตความเร็วและแรงกระโดดกลับสู่ปกติ")
    end
end)

createButton("🔔 Send Notification", Color3.fromRGB(250, 166, 26), function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hello!",
        Text = "ปุ่มทำงานเรียบร้อยแล้ว",
        Duration = 3
    })
end)

print("[UI] โหลดเมนูเรียบร้อยแล้ว!")
