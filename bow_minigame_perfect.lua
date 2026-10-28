local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    Enabled = true,
    ToggleKey = Enum.KeyCode.V,
    TotalShots = 4,
    HitTolerancePixels = 4,
    ClickCooldown = 0.5,
    TargetOffsetY = -2,
    Notification = true,
}

local currentShot = 0
local lastTriggerTime = 0
local lastPositions = {}
local hasResetToBottom = true
local prevBowCenterY = nil

local lastDodgeTrigger = 0
local lastNeedlePositionsX = {}
local prevNeedleX = nil
local dodgeHasReset = true

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

local function triggerPerfectHit(clickPosition)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)

    pcall(function()
        local pos = clickPosition or Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
    end)

    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("MinigameAction")
            or ReplicatedStorage:FindFirstChild("BowMinigame")
            or ReplicatedStorage:FindFirstChild("ShootAction")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(currentShot, 0.75)
        end
    end)
end

local function isGoldColor(color)
    if not color then return false end
    return (color.R > 0.65) and (color.G > 0.55) and (color.B < 0.6) and (color.R >= color.B + 0.15)
end

local function isWhiteColor(c)
    if not c then return false end
    return (c.R > 0.85) and (c.G > 0.85) and (c.B > 0.85)
end

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

local function findGoldBandAndGauge(container)
    local goldBand = nil
    local gaugeFrame = nil

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            if not goldBand then
                if name:find("gold") or name:find("band") or name:find("sweet") or name:find("perfect") or name:find("target") then
                    goldBand = obj
                elseif obj.AbsoluteSize.Y > 0 and isGoldColor(obj.BackgroundColor3) then
                    goldBand = obj
                end
            end

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

local function getMovingObject(container)
    local movingObj = nil
    local maxMove = 0

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 0 then
            local name = obj.Name:lower()
            if name:find("bow") or name:find("arrow") or name:find("pointer") or name:find("needle") or name:find("fill") or name:find("bar") then
                local prevY = lastPositions[obj]
                local curY = obj.AbsolutePosition.Y
                if prevY ~= nil then
                    local delta = prevY - curY
                    if delta > 0.15 and delta > maxMove then
                        maxMove = delta
                        movingObj = obj
                    end
                end
                lastPositions[obj] = curY
            end
        end
    end

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

    local bowCenterY = movingObj.AbsolutePosition.Y + (movingObj.AbsoluteSize.Y * 0.5)
    local tol = CONFIG.HitTolerancePixels

    if bowCenterY > (targetY + 15) then
        hasResetToBottom = true
    end

    local isMovingUp = false
    if prevBowCenterY ~= nil then
        local delta = prevBowCenterY - bowCenterY
        if delta > 0.1 then
            isMovingUp = true
        end
    end

    local isAtCenter = math.abs(bowCenterY - targetY) <= (tol + 2)
    local justPassed = (bowCenterY <= targetY + tol) and (bowCenterY >= targetY - 35)
    local crossedDuringLag = (prevBowCenterY ~= nil) and (prevBowCenterY >= targetY - 4) and (bowCenterY <= targetY + tol) and (bowCenterY >= targetY - 45)

    if hasResetToBottom and isMovingUp and (isAtCenter or justPassed or crossedDuringLag) then
        hasResetToBottom = false
        lastTriggerTime = os.clock()
        currentShot = (currentShot % CONFIG.TotalShots) + 1

        triggerPerfectHit(clickPos)
        notify("PERFECT", string.format("Power Shot %d/%d (Y: %.1f / Target: %.1f)", currentShot, CONFIG.TotalShots, bowCenterY, targetY))
    end

    prevBowCenterY = bowCenterY
end

local function findDodgeContainer()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("INCOMING") or text:find("DODGE") or text:find("YOUR SHIELD") then
                        return gui
                    end
                end
            end
        end
    end
    return nil
end

local function getMovingNeedle(container)
    local bestObj = nil
    local maxMoveX = 0

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 8 then
            local prevX = lastNeedlePositionsX[obj]
            local curX = obj.AbsolutePosition.X
            if prevX ~= nil then
                local deltaX = math.abs(prevX - curX)
                if deltaX > 0.2 and deltaX > maxMoveX then
                    maxMoveX = deltaX
                    bestObj = obj
                end
            end
            lastNeedlePositionsX[obj] = curX
        end
    end

    if not bestObj then
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 10 and obj.AbsoluteSize.X < 25 then
                local name = obj.Name:lower()
                if name:find("needle") or name:find("pointer") or name:find("line") or name:find("cursor") then
                    return obj
                end
            end
        end
    end

    return bestObj
end

local function findWhiteDodgeZone(container, needle)
    local needleY = needle.AbsolutePosition.Y

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible and obj ~= needle then
            if obj.AbsoluteSize.X > 5 and obj.BackgroundTransparency < 0.6 then
                if math.abs(obj.AbsolutePosition.Y - needleY) < 40 then
                    local name = obj.Name:lower()
                    if name:find("white") or name:find("dodge") or name:find("sweet") or name:find("target") then
                        return obj
                    end
                    if isWhiteColor(obj.BackgroundColor3) then
                        return obj
                    end
                end
            end
        end
    end

    return nil
end

local function checkDodgeAlignment()
    if not CONFIG.Enabled then return end
    if (os.clock() - lastDodgeTrigger) < 0.45 then return end

    local container = findDodgeContainer()
    if not container then
        dodgeHasReset = true
        prevNeedleX = nil
        lastNeedlePositionsX = {}
        return
    end

    local needle = getMovingNeedle(container)
    if not needle then return end

    local whiteZone = findWhiteDodgeZone(container, needle)
    if not whiteZone then return end

    local whiteLeft = whiteZone.AbsolutePosition.X
    local whiteRight = whiteLeft + whiteZone.AbsoluteSize.X
    local whiteCenterX = whiteLeft + (whiteZone.AbsoluteSize.X * 0.5)

    local needleX = needle.AbsolutePosition.X + (needle.AbsoluteSize.X * 0.5)
    local tol = 8

    if needleX < (whiteLeft - 15) or needleX > (whiteRight + 15) then
        dodgeHasReset = true
    end

    local movingDir = 0
    if prevNeedleX ~= nil then
        local delta = needleX - prevNeedleX
        if delta > 0.15 then
            movingDir = 1
        elseif delta < -0.15 then
            movingDir = -1
        end
    end

    local isAtCenter = math.abs(needleX - whiteCenterX) <= tol
    local crossedCenter = false
    if prevNeedleX ~= nil and movingDir ~= 0 then
        if movingDir == 1 then
            if (prevNeedleX <= whiteCenterX + 5) and (needleX >= whiteCenterX - tol) and (needleX <= whiteRight + 25) then
                crossedCenter = true
            end
        elseif movingDir == -1 then
            if (prevNeedleX >= whiteCenterX - 5) and (needleX <= whiteCenterX + tol) and (needleX >= whiteLeft - 25) then
                crossedCenter = true
            end
        end
    end

    if dodgeHasReset and (isAtCenter or crossedCenter) then
        dodgeHasReset = false
        lastDodgeTrigger = os.clock()
        triggerPerfectHit(Vector2.new(whiteCenterX, whiteZone.AbsolutePosition.Y + (whiteZone.AbsoluteSize.Y * 0.5)))
        notify("DODGE", string.format("Perfect Dodge (X: %.1f / White: %.1f)", needleX, whiteCenterX))
    end

    prevNeedleX = needleX
end

RunService.RenderStepped:Connect(function()
    checkPowerShotAlignment()
    checkDodgeAlignment()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.ToggleKey then
        CONFIG.Enabled = not CONFIG.Enabled
        local status = CONFIG.Enabled and "ENABLED" or "DISABLED"
        notify("Auto Minigame", "Status: " .. status)
    end
end)

notify("Minigame Assistant", "Loaded (Press [" .. CONFIG.ToggleKey.Name .. "] to Toggle)")
