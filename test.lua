-- สร้างหน้าต่างแจ้งเตือนบนจอเมื่อสคริปต์เริ่มทำงานสำเร็จ
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Exploit Loaded!",
    Text = "สคริปต์ตัวอย่างทำงานสำเร็จแล้ว",
    Duration = 5
})

-- ดึงข้อมูลตัวละครของคุณ
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- เปลี่ยนค่าความเร็วและการกระโดดเริ่มต้น (แก้ไขตัวเลขตรงนี้ได้)
humanoid.WalkSpeed = 50       -- ความเร็วปกติคือ 16
humanoid.JumpPower = 100      -- ความสูงปกติคือ 50

print("Setup WalkSpeed to 50 and JumpPower to 100 Completed.")

--[[
    DuckBlox - Minigame 4-Shot Simulation Tester (Studio QA)
    ตามแนวทาง Client-Server Architecture ใน roblox-systems-scripter.md:
    - รันในฝั่ง Client สำหรับทดสอบระบบมินิเกม
    - จำลองการกด Perfect 4 ครั้งต่อเนื่อง โดยแต่ละครั้งใช้เวลา 0.75 วินาที
    - ป้องกันการค้างด้วย Timeout ในการค้นหา RemoteEvent
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 1. ตั้งค่าพารามิเตอร์ของมินิเกม
local MINIGAME_CONFIG = {
    ActionRemoteName = "MinigameAction", -- ชื่อ RemoteEvent ใน ReplicatedStorage
    TotalShots = 4,                      -- จำนวนครั้งที่ต้องยิง (4 จุดตาม UI)
    ShotInterval = 0.75,                 -- จังหวะกด Perfect ต่อครั้ง (0.75 วินาที)
}

-- 2. ค้นหา RemoteEvent พร้อมระบบป้องกัน Script ค้าง
local actionRemote = ReplicatedStorage:WaitForChild(MINIGAME_CONFIG.ActionRemoteName, 5)

if not actionRemote then
    warn(("[MinigameTester] ไม่พบ RemoteEvent '%s' ใน ReplicatedStorage"):format(MINIGAME_CONFIG.ActionRemoteName))
    return
end

-- 3. ฟังก์ชันจำลองการส่งสัญญาณการยิงในแต่ละรอบ
local function simulateShot(shotNumber)
    if actionRemote and actionRemote:IsA("RemoteEvent") then
        -- ส่งข้อมูลรอบที่ยิงและเวลาที่ใช้ (Roblox แนบ LocalPlayer ให้ฝั่ง Server อัตโนมัติ)
        actionRemote:FireServer(shotNumber, MINIGAME_CONFIG.ShotInterval)
        print(("[MinigameTester] ยิงครั้งที่ %d/4 (เวลาจังหวะ: %.2f วินาที) สำเร็จ"):format(shotNumber, MINIGAME_CONFIG.ShotInterval))
    end
end

-- 4. เริ่มจำลองการเล่นมินิเกม 4 จังหวะ
task.wait(1)
print(("[MinigameTester] เริ่มต้นการทดสอบมินิเกม (%d จังหวะ, จังหวะละ %.2f วินาที)..."):format(
    MINIGAME_CONFIG.TotalShots, 
    MINIGAME_CONFIG.ShotInterval
))

for shot = 1, MINIGAME_CONFIG.TotalShots do
    task.wait(MINIGAME_CONFIG.ShotInterval)
    simulateShot(shot)
end

print("[MinigameTester] จบการทดสอบมินิเกมครบทั้ง 4 จังหวะเรียบร้อย")
