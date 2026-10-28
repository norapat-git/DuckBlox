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

logLine("=== PlatformBattlesClient Modules & Scripts ===")
local pbc = LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("PlatformBattlesClient")
if pbc then
    for _, obj in ipairs(pbc:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local memberInfo = {}
            local success, res = pcall(function() return require(obj) end)
            if success and typeof(res) == "table" then
                for k, v in pairs(res) do
                    table.insert(memberInfo, string.format("%s (%s)", tostring(k), typeof(v)))
                end
            end
            logLine(string.format("local %s = require(%s)", obj.Name, obj:GetFullName()))
            if #memberInfo > 0 then
                logLine("Members: " .. table.concat(memberInfo, ", "))
            end
            logLine("")
        elseif obj:IsA("LocalScript") then
            logLine(string.format("[LocalScript] %s (%s)\n", obj.Name, obj:GetFullName()))
        end
    end
else
    logLine("PlatformBattlesClient not found under PlayerScripts!\n")
end

logLine("=== ReplicatedStorage.PlatformBattles All Modules ===")
local pb = ReplicatedStorage:FindFirstChild("PlatformBattles")
if pb then
    for _, obj in ipairs(pb:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local memberInfo = {}
            local success, res = pcall(function() return require(obj) end)
            if success and typeof(res) == "table" then
                for k, v in pairs(res) do
                    table.insert(memberInfo, string.format("%s (%s)", tostring(k), typeof(v)))
                end
            end
            logLine(string.format("local %s = require(%s)", obj.Name, obj:GetFullName()))
            if #memberInfo > 0 then
                logLine("Members: " .. table.concat(memberInfo, ", "))
            end
            logLine("")
        elseif obj:IsA("LocalScript") then
            logLine(string.format("[LocalScript] %s (%s)\n", obj.Name, obj:GetFullName()))
        end
    end
end

logLine("=== PlayerGui Battle & Combat Scripts ===")
local pgui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
if pgui then
    for _, obj in ipairs(pgui:GetDescendants()) do
        if obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
            local nlower = obj.Name:lower()
            local plower = obj:GetFullName():lower()
            if nlower:find("battle") or nlower:find("combat") or nlower:find("timing")
                or nlower:find("gauge") or nlower:find("bar") or nlower:find("bow")
                or nlower:find("arrow") or nlower:find("shot") or plower:find("battle")
                or plower:find("combat") then
                if obj:IsA("ModuleScript") then
                    local memberInfo = {}
                    local success, res = pcall(function() return require(obj) end)
                    if success and typeof(res) == "table" then
                        for k, v in pairs(res) do
                            table.insert(memberInfo, string.format("%s (%s)", tostring(k), typeof(v)))
                        end
                    end
                    logLine(string.format("local %s = require(%s)", obj.Name, obj:GetFullName()))
                    if #memberInfo > 0 then
                        logLine("Members: " .. table.concat(memberInfo, ", "))
                    end
                    logLine("")
                else
                    logLine(string.format("[LocalScript] %s (%s)\n", obj.Name, obj:GetFullName()))
                end
            end
        end
    end
end

local fullDump = table.concat(dumpLines, "\n")
copyToClipboard(fullDump)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "DuckBlox All Dumped",
        Text = "Copied all modules to clipboard! Paste it into txt.",
        Duration = 5
    })
end)
