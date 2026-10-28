local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function copyToClipboard(str)
    pcall(function()
        if typeof(setclipboard) == "function" then
            setclipboard(str)
        elseif typeof(toclipboard) == "function" then
            toclipboard(str)
        end
    end)
end

local dumpLines = {}
local function logLine(txt)
    table.insert(dumpLines, txt)
    print(txt)
end

logLine("=== PlatformBattlesClient Modules ===")
local pbc = LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("PlatformBattlesClient")
if pbc then
    for _, obj in ipairs(pbc:GetChildren()) do
        if obj:IsA("ModuleScript") then
            local memberInfo = {}
            local success, res = pcall(function() return require(obj) end)
            if success and typeof(res) == "table" then
                for k, v in pairs(res) do
                    table.insert(memberInfo, string.format("%s (%s)", tostring(k), typeof(v)))
                end
            end
            logLine(string.format("[PBC Module] %s", obj.Name))
            if #memberInfo > 0 then
                logLine("   Members: " .. table.concat(memberInfo, ", "))
            end
        end
    end
else
    logLine("PlatformBattlesClient not found under PlayerScripts!")
end

logLine("\n=== Timing & Combat Modules in ReplicatedStorage ===")
local pb = ReplicatedStorage:FindFirstChild("PlatformBattles")
if pb then
    for _, obj in ipairs(pb:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local nlower = obj.Name:lower()
            if nlower:find("timing") or nlower:find("bow") or nlower:find("shot")
                or nlower:find("arrow") or nlower:find("dodge") or nlower:find("blade")
                or nlower:find("slash") or nlower:find("qte") or nlower:find("minigame") then
                local memberInfo = {}
                local success, res = pcall(function() return require(obj) end)
                if success and typeof(res) == "table" then
                    for k, v in pairs(res) do
                        table.insert(memberInfo, string.format("%s (%s)", tostring(k), typeof(v)))
                    end
                end
                logLine(string.format("[PB Timing Module] %s (%s)", obj.Name, obj:GetFullName()))
                if #memberInfo > 0 then
                    logLine("   Members: " .. table.concat(memberInfo, ", "))
                end
            end
        end
    end
end

local fullDump = table.concat(dumpLines, "\n")
copyToClipboard(fullDump)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Timing Modules Dumped",
        Text = "Dump copied to clipboard! Paste it here.",
        Duration = 5
    })
end)
