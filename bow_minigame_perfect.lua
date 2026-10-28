--[[
    ========================================================================
    🏹 Auto Perfect "POWER SHOT" Bow Minigame - LocalScript
    ========================================================================
    ปรับปรุงระบบคำนวณตำแหน่งจังหวะ Perfect:
    - แก้ไขปัญหากดเร็วเกินไป (Early): เดิมทีกดทันทีที่แตะขอบล่างของแถบ
    - ปรับมาเล็งที่ "กึ่งกลางของแถบสีทอง (Center of Gold Band)" หรือ "กลางหลอด" พอดีเป๊ะ
    - มีระบบ Motion Tracker ตรวจจับเฉพาะวัตถุที่กำลังขยับเลื่อนขึ้นจริงแบบ Real-time
    - ปรับชดเชยค่า Offset ได้ (TargetOffset) เพื่อความแม่นยำสูงสุด
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
    HitTolerancePixels = 4,        -- ขอบเขตความคลาดเคลื่อน (พิกเซล)
    ClickCooldown = 0.5,           -- คูลดาวน์ระหว่างรอบยิง (วินาที)
    
    -- การปรับตำแหน่งเล็ง:
    -- 0 = กึ่งกลางแถบสีทอง (Gold Band Center) พอดีเป๊ะ
    -- ติดลบ (-) = ให้เลื่อนขึ้นไปสูงขึ้นอีกนิดก่อนกด (หน่วงเวลากดช้าลง)
    -- เป็นบวก (+) = ให้กดเร็วขึ้นอีกนิด
    TargetOffsetY = -2,
    
    Notification = true,
}

local currentShot = 0
local lastTriggerTime = 0
local lastPositions = {}           -- บันทึกพิกัดเฟรมก่อนหน้าเพื่อหาตัวที่กำลังขยับ
local hasResetToBottom = true
local prevBowCenterY = nil

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
-- 🔍 Scanner & Target Calculation
-- ========================================================

-- ตรวจสอบสีโทนทอง/เหลืองของ Gold Band
local function isGoldColor(color)
    if not color then return false end
    return (color.R > 0.65) and (color.G > 0.55) and (color.B < 0.6) and (color.R >= color.B + 0.15)
end

-- ค้นหา Container หลักของ Power Shot
local function findPowerShotContainer()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("POWER SHOT") or text:find("GOLD BAND") or text:find("SPACE / CLICK") then
                        local container = label:FindFirstAncestorOfClass("Frame") or label.Parent
                        return container or gui
                    end
                end
            end
        end
    end
    return nil
end

-- ค้นหาแถบสีทอง (Gold Band) และหลอดพลังงาน
local function findGoldBandAndGauge(container)
    local goldBand = nil
    local gaugeFrame = nil

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            -- ค้นหา Gold Band
            if not goldBand then
                if name:find("gold") or name:find("band") or name:find("sweet") or name:find("perfect") or name:find("target") then
                    goldBand = obj
                elseif obj.AbsoluteSize.Y > 0 and isGoldColor(obj.BackgroundColor3) then
                    goldBand = obj
                end
            end

            -- ค้นหาตัวหลอด Gauge หลัก
            if not gaugeFrame then
                if name:find("gauge") or name:find("bar") or name:find("meter") or name:find("power") then
                    if obj.AbsoluteSize.Y > 50 then
                        gaugeFrame = obj
                    end
                end
            end
        end
    end

    return goldBand, gaugeFrame
end

-- ค้นหาวัตถุที่กำลังขยับเลื่อนขึ้น (Motion Tracking)
local function getMovingObject(container)
    local movingObj = nil
    local maxMove = 0

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 0 then
            local name = obj.Name:lower()
            -- กรองเอาเฉพาะตัวที่น่าจะเป็นคันธนู, ลูกศร หรือหลอดพลังงาน
            if name:find("bow") or name:find("arrow") or name:find("pointer") or name:find("needle") or name:find("fill") or name:find("bar") then
                local prevY = lastPositions[obj]
                local curY = obj.AbsolutePosition.Y
                if prevY ~= nil then
                    local delta = prevY - curY -- เลื่อนขึ้น = delta เป็นบวก
                    if delta > 0.15 and delta > maxMove then
                        maxMove = delta
                        movingObj = obj
                    end
                end
                lastPositions[obj] = curY
            end
        end
    end

    -- Fallback: หากยังไม่พบการขยับ ให้หาตามชื่อคันธนู
    if not movingObj then
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("GuiObject") and obj.Visible then
                local name = obj.Name:lower()
                if (name:find("bow") or name:find("arrow")) and not name:find("shadow") and not name:find("bg") then
                    return obj
                end
            end
        end
    end

    return movingObj
end

-- ========================================================
-- ⚡ Real-Time Center Alignment (RenderStepped)
-- ========================================================
local function checkPowerShotAlignment()
    if not CONFIG.Enabled then return end
    if (os.clock() - lastTriggerTime) < CONFIG.ClickCooldown then return end

    local container = findPowerShotContainer()
    if not container then
        if currentShot ~= 0 then
            currentShot = 0
            lastPositions = {}
        end
        return
    end

    local goldBand, gaugeFrame = findGoldBandAndGauge(container)
    local movingObj = getMovingObject(container)

    if not movingObj then return end

    -- คำนวณพิกัดเป้าหมาย (Target Y):
    -- ลำดับที่ 1: เล็งที่ "กึ่งกลางของแถบสีทอง" (Center of Gold Band)
    -- ลำดับที่ 2: หากหาแถบทองไม่เจอ ให้เล็งที่กึ่งกลางหลอด Gauge (Center of Gauge)
    local targetY = nil
    local clickPos = nil

    if goldBand then
        local goldCenter = goldBand.AbsolutePosition.Y + (goldBand.AbsoluteSize.Y * 0.5)
        targetY = goldCenter + CONFIG.TargetOffsetY
        clickPos = Vector2.new(
            goldBand.AbsolutePosition.X + (goldBand.AbsoluteSize.X / 2),
            goldCenter
        )
    elseif gaugeFrame then
        local gaugeCenter = gaugeFrame.AbsolutePosition.Y + (gaugeFrame.AbsoluteSize.Y * 0.48)
        targetY = gaugeCenter + CONFIG.TargetOffsetY
        clickPos = Vector2.new(
            gaugeFrame.AbsolutePosition.X + (gaugeFrame.AbsoluteSize.X / 2),
            gaugeCenter
        )
    end

    if not targetY then return end

    -- พิกัด Y ปัจจุบันของคันธนู (ใช้จุดกึ่งกลางของไอคอนธนู)
    local bowCenterY = movingObj.AbsolutePosition.Y + (movingObj.AbsoluteSize.Y * 0.5)
    local tol = CONFIG.HitTolerancePixels

    -- ตรวจสอบว่าคันธนูรีเซ็ตลงไปข้างล่างหรือยัง
    if bowCenterY > (targetY + 15) then
        hasResetToBottom = true
    end

    -- ตรวจสอบความเร็วการเลื่อนขึ้น
    local isMovingUp = false
    if prevBowCenterY ~= nil then
        local delta = prevBowCenterY - bowCenterY
        if delta > 0.1 then
            isMovingUp = true
        end
    end

    -- ป้องกันปัญหา Lag: ดักจับทั้งการอยู่กึ่งกลาง และการที่ข้ามเป้าหมายในเฟรมเดียวตอน FPS ตก
    local isAtCenter = math.abs(bowCenterY - targetY) <= (tol + 2)
    local justPassed = (bowCenterY <= targetY + tol) and (bowCenterY >= targetY - 35)
    local crossedDuringLag = (prevBowCenterY ~= nil) and (prevBowCenterY >= targetY - 4) and (bowCenterY <= targetY + tol) and (bowCenterY >= targetY - 45)

    if hasResetToBottom and isMovingUp and (isAtCenter or justPassed or crossedDuringLag) then
        hasResetToBottom = false -- ล็อคทันทีจนกว่าจะเริ่มรอบใหม่
        lastTriggerTime = os.clock()
        currentShot = (currentShot % CONFIG.TotalShots) + 1

        triggerPerfectHit(clickPos)
        notify("🎯 PERFECT!", string.format("ยิงที่กึ่งกลางแถบทองรอบที่ %d/%d สำเร็จ (Y: %.1f / Target: %.1f)", currentShot, CONFIG.TotalShots, bowCenterY, targetY))
    end

    prevBowCenterY = bowCenterY
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

notify("🏹 Power Shot Loaded", "เล็งกึ่งกลางแถบทอง (Perfect Center) กด [" .. CONFIG.ToggleKey.Name .. "] เพื่อเปิด/ปิด")
