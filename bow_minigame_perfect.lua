--[[
    ========================================================================
    🏹 Auto Perfect Bow Minigame - LocalScript
    ========================================================================
    รองรับการทำงาน 2 รูปแบบหลัก:
    1. UI Detection Mode (ตรวจจับเข็ม/แถบเลื่อนบน UI แบบ Real-time):
       - คำนวณพิกัด AbsolutePosition ของ Pointer/Needle กับ Perfect Zone
       - เมื่อเข็มวิ่งมาถึงโซน Perfect จะสั่ง Trigger ทันทีในระดับ Frame-Perfect (RenderStepped)
       - จำลองการคลิกด้วย VirtualInputManager / VirtualUser / Tool Activate

    2. RemoteEvent Direct Mode (ยิงผ่าน RemoteEvent โดยตรง):
       - ยิง RemoteEvent ทันทีเมื่อเข้าสู่จังหวะ Perfect สำหรับเกมที่ใช้ระบบ Server/Client Sync
    ========================================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ========================================================
-- ⚙️ CONFIGURATION (การตั้งค่า)
-- ========================================================
local CONFIG = {
    Enabled = true,                -- เปิด/ปิดการทำงานเริ่มต้น
    ToggleKey = Enum.KeyCode.V,    -- ปุ่มลัดสำหรับ เปิด/ปิด (กด V บนคีย์บอร์ด)
    
    -- โหมดการทำงาน: "UI_DETECTION" หรือ "REMOTE_FIRE" หรือ "HYBRID" (ทำทั้งคู่)
    Mode = "UI_DETECTION", 

    -- [1] ตั้งค่าสำหรับ UI Detection
    UI = {
        -- คำค้นหาชื่อ GUI หรือ Frame ที่เกี่ยวข้องกับมินิเกมยิงธนู
        PossibleGuiNames = {"BowMinigame", "BowGui", "Minigame", "QTE", "TimingBar", "AimMinigame", "ArrowMinigame"},
        
        -- ชื่อของโซน Perfect (Target)
        PossibleTargetNames = {"Perfect", "PerfectZone", "SweetSpot", "GreenZone", "TargetZone", "Target", "Goal"},
        
        -- ชื่อของเข็มหรือตัวเลื่อน (Indicator / Needle)
        PossibleIndicatorNames = {"Pointer", "Needle", "Indicator", "Cursor", "Bar", "Line", "Slider"},
        
        -- ความคลาดเคลื่อนที่ยอมรับได้ (offset เป็น pixels)
        HitTolerancePixels = 4,
        
        -- คูลดาวน์หลังจากการกด 1 ครั้ง (วินาที) ป้องกันการกดเบิ้ล
        ClickCooldown = 0.5,
    },

    -- [2] ตั้งค่าสำหรับ RemoteEvent Mode
    Remote = {
        RemoteName = "MinigameAction", -- เปลี่ยนตามชื่อ RemoteEvent ของเกม
        TotalShots = 4,                -- จำนวนนัดที่ต้องยิง
        PerfectInterval = 0.75,        -- เวลาจังหวะ Perfect (วินาที)
        AutoLoop = false,              -- เล่นวนลูปอัตโนมัติหรือไม่
    },

    -- [3] การแจ้งเตือน
    Notification = true,
}

-- ========================================================
-- 🔔 Notification Helper
-- ========================================================
local function notify(title, text)
    if not CONFIG.Notification then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2.5
        })
    end)
    print(string.format("[%s] %s", title, text))
end

-- ========================================================
-- 🎯 Click / Input Simulator (จำลองการคลิก)
-- ========================================================
local function triggerPerfectHit(targetPosition)
    -- วิธีที่ 1: ใช้ VirtualInputManager จำลองการคลิกเมาส์ซ้ายจริง
    pcall(function()
        local clickX = targetPosition and targetPosition.X or (workspace.CurrentCamera.ViewportSize.X / 2)
        local clickY = targetPosition and targetPosition.Y or (workspace.CurrentCamera.ViewportSize.Y / 2)

        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
    end)

    -- วิธีที่ 2: จำลองการกด Spacebar (กรณีมินิเกมใช้ Spacebar กด)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)

    -- วิธีที่ 3: สั่ง Tool:Activate() ถ้าตัวละครถือธนูอยู่
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end)
end

-- ========================================================
-- 🔍 UI Scanner & Hit Box Overlap Detector
-- ========================================================
local lastTriggerTime = 0

-- ค้นหา Object ตามรายชื่อที่ระบุ
local function findDescendantByNames(parent, nameList)
    for _, name in ipairs(nameList) do
        local found = parent:FindFirstChild(name, true)
        if found and found:IsA("GuiObject") and found.Visible then
            return found
        end
    end
    return nil
end

-- ค้นหาหน้าจอ Minigame GUI ปัจจุบัน
local function getActiveMinigameGui()
    for _, guiName in ipairs(CONFIG.UI.PossibleGuiNames) do
        local gui = PlayerGui:FindFirstChild(guiName)
        if gui and gui:IsA("ScreenGui") and gui.Enabled then
            return gui
        end
    end
    
    -- หากไม่เจอตามชื่อ ให้สแกนหา ScreenGui ใดๆ ที่มีคำว่า Minigame หรือ Bow
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local lower = gui.Name:lower()
            if lower:find("bow") or lower:find("minigame") or lower:find("qte") or lower:find("shoot") then
                return gui
            end
        end
    end
    
    return nil
end

-- ตรวจสอบว่าเข็ม (Indicator) เข้าสู่โซน Perfect หรือยัง
local function checkUIAlignment()
    if not CONFIG.Enabled then return end
    if os.clock() - lastTriggerTime < CONFIG.UI.ClickCooldown then return end

    local minigameGui = getActiveMinigameGui()
    if not minigameGui then return end

    local targetZone = findDescendantByNames(minigameGui, CONFIG.UI.PossibleTargetNames)
    local indicator = findDescendantByNames(minigameGui, CONFIG.UI.PossibleIndicatorNames)

    if not targetZone or not indicator then return end

    -- ดึงตำแหน่งและขนาด Absolute บนหน้าจอ
    local targetPos = targetZone.AbsolutePosition
    local targetSize = targetZone.AbsoluteSize

    local indPos = indicator.AbsolutePosition
    local indSize = indicator.AbsoluteSize

    -- จุดกึ่งกลางของเข็ม
    local indCenterX = indPos.X + (indSize.X / 2)
    local indCenterY = indPos.Y + (indSize.Y / 2)

    -- ขอบเขตของโซน Perfect (รวมค่า Tolerance)
    local tol = CONFIG.UI.HitTolerancePixels
    local minX = targetPos.X - tol
    local maxX = targetPos.X + targetSize.X + tol
    local minY = targetPos.Y - tol
    local maxY = targetPos.Y + targetSize.Y + tol

    -- ตรวจสอบการทับซ้อน (Overlap) แกน X และ Y
    local inZoneX = (indCenterX >= minX and indCenterX <= maxX)
    local inZoneY = (indCenterY >= minY and indCenterY <= maxY)

    if inZoneX and inZoneY then
        lastTriggerTime = os.clock()
        notify("🎯 Perfect Hit!", "ตรวจจับจังหวะ Perfect สำเร็จ กำลังยิง...")
        triggerPerfectHit(Vector2.new(indCenterX, indCenterY))
    end
end

-- ========================================================
-- 📡 RemoteEvent Direct Execution
-- ========================================================
local function fireRemotePerfectSequence()
    local remote = ReplicatedStorage:FindFirstChild(CONFIG.Remote.RemoteName)
        or ReplicatedStorage:WaitForChild(CONFIG.Remote.RemoteName, 2)

    if not remote or not remote:IsA("RemoteEvent") then
        warn("[AutoBow] ไม่พบ RemoteEvent: " .. tostring(CONFIG.Remote.RemoteName))
        return
    end

    task.spawn(function()
        notify("🏹 Bow Remote", "เริ่มส่งสัญญาณยิง Perfect ตามจังหวะ...")
        for shot = 1, CONFIG.Remote.TotalShots do
            if not CONFIG.Enabled then break end
            task.wait(CONFIG.Remote.PerfectInterval)
            remote:FireServer(shot, CONFIG.Remote.PerfectInterval)
            print(string.format("[AutoBow] FireServer Shot %d/%d (Perfect)", shot, CONFIG.Remote.TotalShots))
        end
        notify("✅ เสร็จสิ้น", "ส่งคำสั่งยิงครบทุกจังหวะแล้ว")
    end)
end

-- ========================================================
-- 🔄 Game Loop & Input Listeners
-- ========================================================

-- เชื่อมต่อ RenderStepped สำหรับการสแกนระดับ Frame-Perfect (60-144+ FPS)
RunService.RenderStepped:Connect(function()
    if CONFIG.Mode == "UI_DETECTION" or CONFIG.Mode == "HYBRID" then
        checkUIAlignment()
    end
end)

-- ปุ่มลัด Toggle เปิด/ปิด สคริปต์
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.ToggleKey then
        CONFIG.Enabled = not CONFIG.Enabled
        local status = CONFIG.Enabled and "เปิดใช้งาน (ENABLED)" or "ปิดใช้งาน (DISABLED)"
        notify("Auto Bow Status", "ระบบ: " .. status)
        
        -- ถ้าเปิดใช้งานในโหมด Remote ให้เริ่ม Sequence ทันที
        if CONFIG.Enabled and (CONFIG.Mode == "REMOTE_FIRE" or CONFIG.Mode == "HYBRID") then
            fireRemotePerfectSequence()
        end
    end
end)

notify("🏹 Auto Bow Loaded", "กด [" .. CONFIG.ToggleKey.Name .. "] เพื่อเปิด/ปิดระบบ")
