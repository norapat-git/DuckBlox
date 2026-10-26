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
        end
    end,
})
-- ========================================================
-- TAB 3: Minigame (ระบบมินิเกม & Auto Farm)
-- ========================================================
local MinigameTab = Window:CreateTab("Minigame", 4483362458)

MinigameTab:CreateSection("Auto Minigame (ฟาร์มอัตโนมัติ)")

local autoMinigameEnabled = false
local shotInterval = 0.75
local roundDelay = 2.0
local isSingleRunning = false

-- สวิตช์เปิด/ปิด Auto Minigame (วนลูปอัตโนมัติ)
MinigameTab:CreateToggle({
    Name = "🤖 Auto Minigame (เปิด/ปิด ออโต้ลูป)",
    CurrentValue = false,
    Flag = "AutoMinigameFlag",
    Callback = function(Value)
        autoMinigameEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Minigame Started",
                Content = "เปิดระบบเล่นมินิเกมอัตโนมัติแล้ว",
                Duration = 2.5,
                Image = 4483362458,
            })

            task.spawn(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                while autoMinigameEnabled do
                    local actionRemote = ReplicatedStorage:FindFirstChild("MinigameAction") 
                        or ReplicatedStorage:WaitForChild("MinigameAction", 3)

                    if not actionRemote then
                        warn("[Rayfield UI] ไม่พบ RemoteEvent 'MinigameAction' ใน ReplicatedStorage")
                        task.wait(2)
                    else
                        -- ยิง 4 จังหวะ
                        for shot = 1, 4 do
                            if not autoMinigameEnabled then break end
                            task.wait(shotInterval)
                            if actionRemote and actionRemote:IsA("RemoteEvent") then
                                actionRemote:FireServer(shot, shotInterval)
                            end
                            print(("[Rayfield UI] [Auto] ยิงครั้งที่ %d/4 (%.2fs)"):format(shot, shotInterval))
                        end

                        if not autoMinigameEnabled then break end
                        -- รอเริ่มรอบใหม่
                        task.wait(roundDelay)
                    end
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Minigame Stopped",
                Content = "ปิดระบบมินิเกมอัตโนมัติแล้ว",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

-- ปรับความเร็วจังหวะการยิงต่อครั้ง
MinigameTab:CreateSlider({
    Name = "Shot Interval (ดีเลย์จังหวะยิง)",
    Range = {0.2, 2.0},
    Increment = 0.05,
    Suffix = " วิ",
    CurrentValue = 0.75,
    Flag = "ShotIntervalFlag",
    Callback = function(Value)
        shotInterval = Value
    end,
})

-- ปรับดีเลย์พักระหว่างแต่ละรอบ
MinigameTab:CreateSlider({
    Name = "Round Delay (เวลาพักระหว่างรอบ)",
    Range = {0.5, 5.0},
    Increment = 0.5,
    Suffix = " วิ",
    CurrentValue = 2.0,
    Flag = "RoundDelayFlag",
    Callback = function(Value)
        roundDelay = Value
    end,
})

MinigameTab:CreateSection("Manual Trigger (ทดสอบยิง 1 รอบ)")

-- ปุ่มยิง 1 รอบแบบกดมือ
MinigameTab:CreateButton({
    Name = "🎯 Trigger 1 Sequence (4 Shots)",
    Callback = function()
        if isSingleRunning or autoMinigameEnabled then
            Rayfield:Notify({
                Title = "Notice",
                Content = "ระบบกำลังทำงานอยู่ กรุณารอสักครู่...",
                Duration = 2,
                Image = 4483362458,
            })
            return
        end

        isSingleRunning = true
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local actionRemote = ReplicatedStorage:FindFirstChild("MinigameAction") 
                or ReplicatedStorage:WaitForChild("MinigameAction", 3)

            Rayfield:Notify({
                Title = "Minigame Started",
                Content = ("เริ่มยิง 4 จังหวะ (รอบละ %.2f วินาที)"):format(shotInterval),
                Duration = 2,
                Image = 4483362458,
            })

            for shot = 1, 4 do
                task.wait(shotInterval)
                if actionRemote and actionRemote:IsA("RemoteEvent") then
                    actionRemote:FireServer(shot, shotInterval)
                end
                print(("[Rayfield UI] ยิงครั้งที่ %d/4 (%.2fs)"):format(shot, shotInterval))
            end

            Rayfield:Notify({
                Title = "Completed",
                Content = "ยิงครบ 4 ครั้งเรียบร้อยแล้ว",
                Duration = 2,
                Image = 4483362458,
            })
            isSingleRunning = false
        end)
    end,
})

