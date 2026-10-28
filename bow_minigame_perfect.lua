--[[
    ========================================================================
    🏹 Auto Perfect "POWER SHOT" Bow Minigame - LocalScript
    ========================================================================
    ออกแบบเฉพาะสำหรับมินิเกมยิงธนู Power Shot (4 จังหวะ):
    - "Shoot when the power hits the gold band! [SPACE / CLICK]"
    - ตรวจจับแถบสีทอง (Gold Band) และการเลื่อนขึ้นของคันธนู / แถบพลังงานสีเขียว (Vertical Y-Axis)
    - ยิงระดับ Frame-Perfect (RenderStepped) ทันทีที่เข้าสู่ Gold Band
    - จำลองการกด [SPACEBAR] และ [LEFT CLICK] ครบ 4 รอบอัตโนมัติ
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
    ToggleKey = Enum.KeyCode.V,    -- ปุ่มลัด Toggle (กด V บนคีย์บอร์ด)
    
    TotalShots = 4,                -- มินิเกมนี้มีทั้งหมด 4 รอบ
    HitTolerancePixels = 6,        -- ระยะเผื่อความคลาดเคลื่อน (พิกเซล)
    ClickCooldown = 0.45,          -- คูลดาวน์หน่วงเวลาระหว่างรอบยิง (วินาที)
    
    Notification = true,
}

local currentShot = 0
local lastTriggerTime = 0

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
-- 🎯 Trigger Action (กด Spacebar และคลิกเมาส์ซ้ายพร้อมกัน)
-- ========================================================
local function triggerPerfectHit(clickPosition)
    -- 1. จำลองการกด SPACEBAR
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)

    -- 2. จำลองการคลิกเมาส์ซ้าย (Mouse 1)
    pcall(function()
        local pos = clickPosition or Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
    end)

    -- 3. หากมี RemoteEvent มินิเกมใน ReplicatedStorage
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("MinigameAction")
            or ReplicatedStorage:FindFirstChild("BowMinigame")
            or ReplicatedStorage:FindFirstChild("ShootAction")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(currentShot, 0.75)
        end
    end)
end

-- ========================================================
-- 🔍 Power Shot UI Scanner
-- ========================================================

-- ตรวจสอบว่าสีคล้ายกับ Gold Band หรือไม่ (โทนเหลือง/ทอง)
local function isGoldColor(color)
    if not color then return false end
    -- Gold Band มีค่า R สูง, G ปานกลาง-สูง, B ต่ำกว่า R/G
    return (color.R > 0.65) and (color.G > 0.55) and (color.B < 0.6) and (color.R >= color.B + 0.15)
end

-- ตรวจสอบว่าสีคล้ายกับ Green Fill หรือไม่ (แถบพลังงานสีเขียว)
local function isGreenColor(color)
    if not color then return false end
    return (color.G > 0.55) and (color.G > color.R) and (color.G > color.B)
end

-- ค้นหาหน้าจอ Power Shot โดยเฉพาะ
local function findPowerShotContainer()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            -- สแกนหา TextLabel ที่มีคำเฉพาะของมินิเกมนี้
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("POWER SHOT") or text:find("GOLD BAND") or text:find("SPACE / CLICK") then
                        -- ดึง Frame หลักที่ครอบคลุมมินิเกม
                        local container = label:FindFirstAncestorOfClass("Frame") or label.Parent
                        return container or gui
                    end
                end
            end
        end
    end
    return nil
end

-- ค้นหา Gold Band (แถบสีทอง)
local function findGoldBand(container)
    -- ค้นหาตามชื่อก่อน
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            if name:find("gold") or name:find("band") or name:find("sweet") or name:find("perfect") or name:find("target") then
                return obj
            end
        end
    end

    -- หากไม่เจอตามชื่อ ให้ตรวจจากค่าสี (BackgroundColor3 / ImageColor3)
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 0 then
            if isGoldColor(obj.BackgroundColor3) then
                return obj
            end
            if obj:IsA("ImageLabel") and isGoldColor(obj.ImageColor3) then
                return obj
            end
        end
    end

    return nil
end

-- ค้นหาคันธนู (Bow Icon) หรือ แถบพลังงานสีเขียว (Green Fill)
local function findMovingIndicator(container)
    -- 1. หาคันธนูที่เลื่อนขึ้นข้างหลอด (ImageLabel หรือ Frame ที่มีคำว่า Bow, Arrow, Needle, Icon)
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            if name:find("bow") or name:find("arrow") or name:find("needle") or name:find("pointer") or name:find("cursor") then
                return obj, "BOW"
            end
        end
    end

    -- 2. หาแถบพลังงานสีเขียว (Green Fill)
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            if (name:find("fill") or name:find("bar") or name:find("power")) and obj.AbsoluteSize.Y > 5 then
                return obj, "FILL"
            end
            if isGreenColor(obj.BackgroundColor3) and obj.AbsoluteSize.Y > 5 then
                return obj, "FILL"
            end
        end
    end

    return nil, nil
end

-- ========================================================
-- ⚡ Real-Time Vertical Detection (RenderStepped)
-- ========================================================
local function checkPowerShotAlignment()
    if not CONFIG.Enabled then return end
    if (os.clock() - lastTriggerTime) < CONFIG.ClickCooldown then return end

    local container = findPowerShotContainer()
    if not container then
        -- ถ้าหน้าต่างมินิเกมหายไป ให้รีเซ็ตรอบยิง
        if currentShot ~= 0 then
            currentShot = 0
        end
        return
    end

    local goldBand = findGoldBand(container)
    local indicator, indType = findMovingIndicator(container)

    if not goldBand or not indicator then return end

    -- พิกัดแนวตั้ง (Y-Axis) ของแถบสีทอง (Gold Band)
    local goldTop = goldBand.AbsolutePosition.Y
    local goldBottom = goldBand.AbsolutePosition.Y + goldBand.AbsoluteSize.Y
    local tol = CONFIG.HitTolerancePixels

    -- คำนวณตำแหน่ง Y ปัจจุบันของตัวที่เคลื่อนที่
    local currentY = nil
    if indType == "BOW" then
        -- ใช้จุดกึ่งกลางของคันธนู/ลูกศร
        currentY = indicator.AbsolutePosition.Y + (indicator.AbsoluteSize.Y / 2)
    elseif indType == "FILL" then
        -- แถบพลังงานเลื่อนขึ้นจากล่างขึ้นบน -> ขอบบนสุดของแท่งสีเขียวคือ AbsolutePosition.Y
        currentY = indicator.AbsolutePosition.Y
    end

    if not currentY then return end

    -- ตรวจสอบว่าจุดที่เลื่อนขึ้น เข้าไปอยู่ในกรอบความสูงของแถบสีทองแล้วหรือยัง
    if (currentY >= (goldTop - tol)) and (currentY <= (goldBottom + tol)) then
        lastTriggerTime = os.clock()
        currentShot = (currentShot % CONFIG.TotalShots) + 1

        local clickPos = Vector2.new(
            goldBand.AbsolutePosition.X + (goldBand.AbsoluteSize.X / 2),
            goldBand.AbsolutePosition.Y + (goldBand.AbsoluteSize.Y / 2)
        )

        triggerPerfectHit(clickPos)
        notify("🎯 PERFECT!", string.format("ยิงจังหวะ Perfect รอบที่ %d/%d สำเร็จ", currentShot, CONFIG.TotalShots))
    end
end

-- ========================================================
-- 🔄 Listeners
-- ========================================================
RunService.RenderStepped:Connect(checkPowerShotAlignment)

-- ปุ่มลัด Toggle เปิด/ปิด
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.ToggleKey then
        CONFIG.Enabled = not CONFIG.Enabled
        local status = CONFIG.Enabled and "เปิดใช้งาน (ENABLED)" or "ปิดใช้งาน (DISABLED)"
        notify("Auto Power Shot", "ระบบ: " .. status)
    end
end)

notify("🏹 Power Shot Loaded", "ระบบ Auto Perfect พร้อมทำงาน (กด [" .. CONFIG.ToggleKey.Name .. "] เพื่อเปิด/ปิด)")
