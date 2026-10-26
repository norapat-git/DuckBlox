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
