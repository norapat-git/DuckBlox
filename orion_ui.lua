--[[
    DuckBlox - Orion UI Library Template
    
    Orion Library เป็นหนึ่งใน Library ที่ยอดนิยมและใช้งานง่ายที่สุด:
    - ออกแบบเรียบหรู สบายตา
    - โค้ดสั้น กระชับ เข้าใจง่าย
]]

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "🦆 DuckBlox Hub", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "DuckBloxOrion"
})

local function getHumanoid()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

-- ========================================================
-- TAB: Player
-- ========================================================
local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

PlayerTab:AddSection({
    Name = "Movement & Stats"
})

-- ปุ่มกด (Button)
PlayerTab:AddButton({
    Name = "⚡ Set WalkSpeed (50)",
    Callback = function()
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 50 end
        OrionLib:MakeNotification({
            Name = "Success",
            Content = "WalkSpeed ปรับเป็น 50 แล้ว",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end    
})

-- แถบเลื่อนปรับค่า (Slider)
PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(88, 101, 242),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = Value end
    end    
})

PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(59, 165, 93),
    Increment = 5,
    ValueName = "Jump",
    Callback = function(Value)
        local hum = getHumanoid()
        if hum then hum.JumpPower = Value end
    end    
})

-- สวิตช์เปิด/ปิด (Toggle)
PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        _G.InfJump = Value
    end    
})

-- ระบบ Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ปุ่มรีเซ็ตค่า
PlayerTab:AddButton({
    Name = "🔄 Reset Stats",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end    
})

-- ต้องเรียก Init ตอนท้ายสุดเพื่อให้ Orion โหลดหน้าต่างขึ้นมา
OrionLib:Init()
