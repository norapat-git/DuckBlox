local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function serialize(val, depth)
    depth = depth or 0
    if depth > 2 then return "..." end
    local t = typeof(val)
    if t == "string" then
        return string.format("%q", val)
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "table" then
        local parts = {}
        for k, v in pairs(val) do
            table.insert(parts, string.format("[%s] = %s", serialize(k, depth + 1), serialize(v, depth + 1)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif t == "Instance" then
        return val:GetFullName()
    else
        return string.format("<%s> %s", t, tostring(val))
    end
end

print("========================================")
print("🦆 DuckBlox Remote Scanner Initialized")
print("========================================")

print("[Found Remotes in ReplicatedStorage]")
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        print(string.format("  • [%s] %s", obj.ClassName, obj:GetFullName()))
    end
end

if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" and typeof(checkcaller) == "function" then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            local serializedArgs = {}
            for i, arg in ipairs(args) do
                table.insert(serializedArgs, string.format("Arg %d: %s", i, serialize(arg)))
            end
            local remotePath = self:GetFullName()
            print("--------------------------------------------------")
            print(string.format("⚡ [REMOTE FIRED] %s:%s()", remotePath, method))
            if #serializedArgs > 0 then
                print("   " .. table.concat(serializedArgs, "\n   "))
            else
                print("   (No Arguments)")
            end
            print("--------------------------------------------------")
        end
        return oldNamecall(self, ...)
    end)
    print("✅ Hooked __namecall successfully (Listening for FireServer/InvokeServer...)")
else
    print("⚠️ Executor does not support hookmetamethod. Listing remotes only.")
end
