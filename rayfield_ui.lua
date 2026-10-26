--[[
    DuckBlox - Rayfield UI Library Template
    Official Docs: https://docs.sirius.menu/rayfield
    
    Rayfield เป็น UI Library ที่ทันสมัยที่สุดในปัจจุบัน:
    - สวยงามระดับพรีเมียม แอนิเมชันลื่นไหล
    - รองรับการแบ่งแท็บ (Tabs), ปุ่มกด (Buttons), สวิตช์ (Toggles), แถบเลื่อน (Sliders), ดรอปดาวน์ (Dropdowns)
    - มีระบบบันทึกการตั้งค่า (Auto Save Config)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🦆 DuckBlox Hub",
    Icon = 0,
    LoadingTitle = "DuckBlox Interface",
    LoadingSubtitle = "by Norapat",
    Theme = "Default", -- เลือกธีม: "Default", "AmberGlow", "Amethyst", "Ocean", "Serenity", "Green"

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DuckBloxConfig", -- โฟลเดอร์เซฟคอนฟิก
        FileName = "PlayerSettings"
    },

    KeySystem = false -- ตั้งเป็น true หากต้องการระบบใส่คีย์ก่อนเข้าใช้
})

-- ฟังก์ชันช่วยดึง Humanoid ของผู้เล่น
local function getHumanoid()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

-- ========================================================
-- TAB 1: Main (ระบบตัวละคร)
-- ========================================================
local MainTab = Window:CreateTab("Main", 4483362458) -- Title, ImageId

MainTab:CreateSection("Character Movement")

-- ปุ่มกด (Button)
MainTab:CreateButton({
    Name = "⚡ Set WalkSpeed to 50",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 50
            Rayfield:Notify({
                Title = "Success",
                Content = "ความเร็วเดินถูกตั้งเป็น 50 แล้ว",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

-- แถบเลื่อนปรับค่าความเร็ว (Slider)
MainTab:CreateSlider({
    Name = "WalkSpeed Slider",
    Range = {16, 250},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedFlag",
    Callback = function(Value)
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = Value
        end
    end,
})

-- แถบเลื่อนปรับแรงกระโดด (JumpPower Slider)
MainTab:CreateSlider({
    Name = "JumpPower Slider",
    Range = {50, 300},
    Increment = 5,
    Suffix = " Jump",
    CurrentValue = 50,
    Flag = "JumpPowerFlag",
    Callback = function(Value)
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = Value
        end
    end,
})

-- สวิตช์เปิด/ปิด (Toggle)
local infiniteJumpConnection = nil
MainTab:CreateToggle({
    Name = "Infinite Jump (กระโดดรัวกลางอากาศ)",
    CurrentValue = false,
    Flag = "InfJumpFlag",
    Callback = function(Value)
        if Value then
            infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local hum = getHumanoid()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
        end
    end,
})

-- ========================================================
-- TAB 2: Misc (ฟังก์ชันเสริม)
-- ========================================================
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Utilities")

-- กล่องเลือกตัวเลือก (Dropdown)
MiscTab:CreateDropdown({
    Name = "Teleport Preset (จุดวาร์ป)",
    Options = {"จุดเกิด (Spawn)", "จุดปลอดภัย", "กลางแมพ"},
    CurrentOption = {"จุดเกิด (Spawn)"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        print("เลือกวาร์ปไปที่: " .. Options[1])
    end,
})

-- ปุ่มรีเซ็ตค่าทั้งหมด
MiscTab:CreateButton({
    Name = "🔄 Reset Stats to Default",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            Rayfield:Notify({
                Title = "Reset Completed",
                Content = "ค่าตัวละครถูกคืนค่าเป็นปกติแล้ว",
                Duration = 2.5,
                Image = 4483362458,
            })
        end
    end,
})
