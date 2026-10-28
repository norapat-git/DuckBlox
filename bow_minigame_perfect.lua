local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local globalEnv = (typeof(getgenv) == "function" and getgenv()) or _G
if globalEnv.DuckBloxMinigameCleanup then
    pcall(globalEnv.DuckBloxMinigameCleanup)
end

local CONFIG = {
    Enabled = true,
    ToggleKey = Enum.KeyCode.V,
    TotalShots = 4,
    HitTolerancePixels = 5,
    ClickCooldown = 0.4,
    TargetOffsetY = -2,
    Notification = true,
}

local isRunning = true
local activeConnections = {}
local activeThreads = {}

local function cleanup()
    isRunning = false
    for _, conn in ipairs(activeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(activeConnections)
    for _, thread in ipairs(activeThreads) do
        pcall(function() task.cancel(thread) end)
    end
    table.clear(activeThreads)
end

globalEnv.DuckBloxMinigameCleanup = cleanup

local activeDefenseClient = nil
local activeQTE = nil
local activeWarriorTiming = nil
local activeThiefTiming = nil
local activeMageTiming = nil

local function initGameFrameworkHooks()
    pcall(function()
        local ps = LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts")
        local pbc = ps and ps:FindFirstChild("PlatformBattlesClient")
        if not pbc then return end

        local qteMod = pbc:FindFirstChild("PixelQTE")
        if qteMod then
            local QTE = require(qteMod)
            if typeof(QTE) == "table" and not QTE._duckbloxHooked then
                QTE._duckbloxHooked = true
                local rawNew = QTE.new
                if typeof(rawNew) == "function" then
                    QTE.new = function(...)
                        local inst = rawNew(...)
                        activeQTE = inst
                        return inst
                    end
                end
                local rawRun = QTE._run
                if typeof(rawRun) == "function" then
                    QTE._run = function(self, ...)
                        activeQTE = self
                        local res = rawRun(self, ...)
                        if CONFIG.Enabled then
                            task.spawn(function()
                                while CONFIG.Enabled and isRunning do
                                    local isQTERunning = false
                                    pcall(function()
                                        if typeof(self.IsRunning) == "function" then
                                            isQTERunning = self:IsRunning()
                                        end
                                    end)
                                    if not isQTERunning then break end
                                    task.wait(0.08)
                                    pcall(function()
                                        if typeof(self._press) == "function" then
                                            self:_press()
                                        end
                                    end)
                                end
                            end)
                        end
                        return res
                    end
                end
                local rawDefense = QTE._defense
                if typeof(rawDefense) == "function" then
                    QTE._defense = function(self, ...)
                        activeQTE = self
                        local res = rawDefense(self, ...)
                        if CONFIG.Enabled then
                            task.spawn(function()
                                task.wait(0.08)
                                pcall(function()
                                    if typeof(self._press) == "function" then
                                        self:_press()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
                local rawGradeAt = QTE._gradeAt
                if typeof(rawGradeAt) == "function" then
                    QTE._gradeAt = function(self, ...)
                        local origGrade = rawGradeAt(self, ...)
                        if CONFIG.Enabled then
                            if typeof(origGrade) == "string" then
                                return "Perfect"
                            elseif typeof(origGrade) == "number" then
                                return 1
                            elseif typeof(origGrade) == "table" then
                                if origGrade.Grade then origGrade.Grade = "Perfect" end
                                if origGrade.grade then origGrade.grade = "Perfect" end
                                if origGrade.Outcome then origGrade.Outcome = "Perfect" end
                                return origGrade
                            end
                        end
                        return origGrade
                    end
                end
            end
        end

        local warriorMod = pbc:FindFirstChild("WarriorBladeTimingClient")
        if warriorMod then
            local WB = require(warriorMod)
            if typeof(WB) == "table" and not WB._duckbloxHooked then
                WB._duckbloxHooked = true
                local rawNew = WB.new
                if typeof(rawNew) == "function" then
                    WB.new = function(...)
                        local inst = rawNew(...)
                        activeWarriorTiming = inst
                        return inst
                    end
                end
                local rawStart = WB.Start
                if typeof(rawStart) == "function" then
                    WB.Start = function(self, ...)
                        activeWarriorTiming = self
                        local res = rawStart(self, ...)
                        if CONFIG.Enabled then
                            task.spawn(function()
                                task.wait(0.12)
                                pcall(function()
                                    if typeof(self._completeTrace) == "function" then
                                        self:_completeTrace()
                                    elseif typeof(self._finish) == "function" then
                                        self:_finish()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
            end
        end

        local thiefMod = pbc:FindFirstChild("ThiefSlashClient")
        if thiefMod then
            local TS = require(thiefMod)
            if typeof(TS) == "table" and not TS._duckbloxHooked then
                TS._duckbloxHooked = true
                local rawNew = TS.new
                if typeof(rawNew) == "function" then
                    TS.new = function(...)
                        local inst = rawNew(...)
                        activeThiefTiming = inst
                        return inst
                    end
                end
                local rawStart = TS.Start
                if typeof(rawStart) == "function" then
                    TS.Start = function(self, ...)
                        activeThiefTiming = self
                        local res = rawStart(self, ...)
                        if CONFIG.Enabled then
                            task.spawn(function()
                                task.wait(0.1)
                                pcall(function()
                                    if typeof(self._trySlash) == "function" then
                                        self:_trySlash()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
            end
        end

        local mageMod = pbc:FindFirstChild("MageRhythmClient")
        if mageMod then
            local MR = require(mageMod)
            if typeof(MR) == "table" and not MR._duckbloxHooked then
                MR._duckbloxHooked = true
                local rawNew = MR.new
                if typeof(rawNew) == "function" then
                    MR.new = function(...)
                        local inst = rawNew(...)
                        activeMageTiming = inst
                        return inst
                    end
                end
                local rawStart = MR.Start
                if typeof(rawStart) == "function" then
                    MR.Start = function(self, ...)
                        activeMageTiming = self
                        local res = rawStart(self, ...)
                        if CONFIG.Enabled then
                            task.spawn(function()
                                task.wait(0.15)
                                pcall(function()
                                    if typeof(self.Resolve) == "function" then
                                        self:Resolve()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
            end
        end

        local dtcMod = pbc:FindFirstChild("DefenseTimingClient")
        if dtcMod then
            local DTC = require(dtcMod)
            if typeof(DTC) == "table" and not DTC._duckbloxHooked then
                DTC._duckbloxHooked = true
                local rawNew = DTC.new
                if typeof(rawNew) == "function" then
                    DTC.new = function(...)
                        local inst = rawNew(...)
                        activeDefenseClient = inst
                        return inst
                    end
                end
                local rawStart = DTC.Start
                if typeof(rawStart) == "function" then
                    DTC.Start = function(self, ...)
                        activeDefenseClient = self
                        local res = rawStart(self, ...)
                        if CONFIG.Enabled then
                            task.spawn(function()
                                task.wait(0.08)
                                pcall(function()
                                    if typeof(self.Press) == "function" then
                                        self:Press()
                                    end
                                end)
                            end)
                        end
                        return res
                    end
                end
                local rawResolve = DTC.Resolve
                if typeof(rawResolve) == "function" then
                    DTC.Resolve = function(self, ...)
                        if activeDefenseClient == self then
                            activeDefenseClient = nil
                        end
                        return rawResolve(self, ...)
                    end
                end
                local rawDestroy = DTC.Destroy
                if typeof(rawDestroy) == "function" then
                    DTC.Destroy = function(self, ...)
                        if activeDefenseClient == self then
                            activeDefenseClient = nil
                        end
                        return rawDestroy(self, ...)
                    end
                end
            end
        end
    end)
end
initGameFrameworkHooks()

local function notify(title, text)
    if not CONFIG.Notification then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2.5
        })
    end)
end

local function triggerPerfectHit()
end

local function isActuallyVisible(obj)
    if not obj or not obj.Parent or not obj:IsA("GuiObject") then return false end
    if not obj.Visible or obj.AbsoluteSize.X <= 0 or obj.AbsoluteSize.Y <= 0 then
        return false
    end
    local parent = obj.Parent
    while parent do
        if parent:IsA("GuiObject") then
            if not parent.Visible then
                return false
            end
        elseif parent:IsA("LayerCollector") then
            return parent.Enabled
        end
        parent = parent.Parent
    end
    return true
end

local function isGoldColor(color)
    if not color then return false end
    return (color.R > 0.65) and (color.G > 0.55) and (color.B < 0.6) and (color.R >= color.B + 0.15)
end

local function isGreenColor(color)
    if not color then return false end
    return (color.G > 0.55) and (color.G > color.R) and (color.G > color.B)
end

local function isWhiteColor(c)
    if not c then return false end
    return (c.R > 0.85) and (c.G > 0.85) and (c.B > 0.85)
end

local function isRedNeedleColor(c)
    if not c then return false end
    return (c.R > 0.70) and (c.G < 0.58) and (c.B < 0.58) and ((c.R - c.G) > 0.20)
end

local function refreshBowCache()
    if bowCache.active and isActuallyVisible(bowCache.indicator) and (isActuallyVisible(bowCache.goldBand) or isActuallyVisible(bowCache.gaugeFrame)) then
        return
    end

    bowCache.active = false
    bowCache.goldBand = nil
    bowCache.gaugeFrame = nil
    bowCache.indicator = nil

    local foundContainer = nil
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("POWER SHOT") or text:find("GOLD BAND") then
                        if isActuallyVisible(label) then
                            local ancestor = label.Parent
                            while ancestor and ancestor ~= gui do
                                if ancestor:IsA("Frame") and ancestor.AbsoluteSize.X >= 200 and ancestor.AbsoluteSize.Y >= 120 then
                                    foundContainer = ancestor
                                    break
                                end
                                ancestor = ancestor.Parent
                            end
                            foundContainer = foundContainer or gui
                            break
                        end
                    end
                end
            end
            if foundContainer then break end
        end
    end

    if not foundContainer then
        currentShot = 0
        hasResetToBottom = true
        prevBowCenterY = nil
        return
    end

    local goldBand, gaugeFrame, indicator = nil, nil, nil
    local descendants = foundContainer:GetDescendants()

    for _, obj in ipairs(descendants) do
        if obj:IsA("GuiObject") and obj.Visible then
            local name = obj.Name:lower()
            if not goldBand then
                if (name:find("gold") or name:find("band") or name:find("sweet") or name:find("perfect") or name:find("target")) and isActuallyVisible(obj) then
                    goldBand = obj
                elseif obj.AbsoluteSize.Y > 0 and isGoldColor(obj.BackgroundColor3) and isActuallyVisible(obj) then
                    goldBand = obj
                end
            end
            if not gaugeFrame then
                if (name:find("gauge") or name:find("bar") or name:find("meter") or name:find("power")) and obj.AbsoluteSize.Y > 50 and isActuallyVisible(obj) then
                    gaugeFrame = obj
                end
            end
            if not indicator then
                if (name:find("bow") or name:find("arrow") or name:find("pointer")) and not name:find("shadow") and not name:find("bg") and isActuallyVisible(obj) then
                    indicator = obj
                end
            end
        end
    end

    if not indicator then
        for _, obj in ipairs(descendants) do
            if obj:IsA("GuiObject") and obj.Visible and obj.AbsoluteSize.Y > 5 then
                local name = obj.Name:lower()
                if (name:find("fill") or name:find("power") or isGreenColor(obj.BackgroundColor3)) and isActuallyVisible(obj) then
                    indicator = obj
                    break
                end
            end
        end
    end

    if indicator and (goldBand or gaugeFrame) then
        bowCache.goldBand = goldBand
        bowCache.gaugeFrame = gaugeFrame
        bowCache.indicator = indicator
        bowCache.active = true
    end
end

local function refreshDodgeCache()
    if dodgeCache.active and isActuallyVisible(dodgeCache.needle) and isActuallyVisible(dodgeCache.whiteZone) then
        return
    end

    dodgeCache.active = false
    dodgeCache.needle = nil
    dodgeCache.whiteZone = nil

    local foundContainer = nil
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text:upper()
                    if text:find("INCOMING") or text:find("HITS YOUR SHIELD") or text:find("DODGE = WHITE") or text:find("YOUR SHIELD") then
                        if isActuallyVisible(label) then
                            local ancestor = label.Parent
                            while ancestor and ancestor ~= gui do
                                if ancestor:IsA("Frame") and ancestor.AbsoluteSize.X >= 250 and ancestor.AbsoluteSize.Y >= 120 and isActuallyVisible(ancestor) then
                                    foundContainer = ancestor
                                    break
                                end
                                ancestor = ancestor.Parent
                            end
                            foundContainer = foundContainer or gui
                            break
                        end
                    end
                end
            end
            if foundContainer then break end
        end
    end

    if not foundContainer then
        dodgeHasReset = true
        prevNeedleX = nil
        return
    end

    local descendants = foundContainer:GetDescendants()
    local needle = nil

    for _, obj in ipairs(descendants) do
        if obj:IsA("GuiObject") and obj.Visible and not obj:IsA("TextLabel") and not obj:IsA("TextButton") then
            local sx = obj.AbsoluteSize.X
            local sy = obj.AbsoluteSize.Y
            if sx >= 2 and sx <= 28 and sy >= 24 and sy <= 150 and sy > (sx * 1.8) then
                local isRed = (obj.BackgroundTransparency < 0.6 and isRedNeedleColor(obj.BackgroundColor3))
                    or (obj:IsA("ImageLabel") and obj.ImageTransparency < 0.6 and isRedNeedleColor(obj.ImageColor3))
                if isRed and isActuallyVisible(obj) then
                    needle = obj
                    break
                end
            end
        end
    end

    if not needle then return end

    local needleCenterY = needle.AbsolutePosition.Y + (needle.AbsoluteSize.Y * 0.5)
    local bestZone = nil
    local bestDiffY = 999

    for _, obj in ipairs(descendants) do
        if obj:IsA("GuiObject") and obj.Visible and obj ~= needle and not obj:IsA("TextLabel") and not obj:IsA("TextButton") then
            local sx = obj.AbsoluteSize.X
            local sy = obj.AbsoluteSize.Y
            if sx >= 14 and sx <= 260 and sy >= 16 and sy <= 90 then
                local isWhite = (obj.BackgroundTransparency < 0.5 and isWhiteColor(obj.BackgroundColor3))
                    or (obj:IsA("ImageLabel") and obj.ImageTransparency < 0.5 and isWhiteColor(obj.ImageColor3))
                if isWhite then
                    local objCenterY = obj.AbsolutePosition.Y + (sy * 0.5)
                    local diffY = math.abs(objCenterY - needleCenterY)
                    if diffY <= 24 and diffY < bestDiffY and isActuallyVisible(obj) then
                        bestDiffY = diffY
                        bestZone = obj
                    end
                end
            end
        end
    end

    if needle and bestZone then
        dodgeCache.needle = needle
        dodgeCache.whiteZone = bestZone
        dodgeCache.active = true
    end
end

local scannerThread = task.spawn(function()
    while isRunning do
        if CONFIG.Enabled then
            pcall(refreshBowCache)
            pcall(refreshDodgeCache)
        else
            bowCache.active = false
            dodgeCache.active = false
        end
        task.wait(0.1)
    end
end)
table.insert(activeThreads, scannerThread)

local function checkPowerShotAlignment()
    if not CONFIG.Enabled or not bowCache.active then return end
    if (os.clock() - lastTriggerTime) < CONFIG.ClickCooldown then return end

    local indicator = bowCache.indicator
    local goldBand = bowCache.goldBand
    local gaugeFrame = bowCache.gaugeFrame

    if not indicator or not indicator.Parent or not indicator.Visible then
        bowCache.active = false
        hasResetToBottom = true
        prevBowCenterY = nil
        return
    end

    local targetY = nil
    if goldBand and goldBand.Parent and goldBand.Visible then
        targetY = goldBand.AbsolutePosition.Y + (goldBand.AbsoluteSize.Y * 0.5) + CONFIG.TargetOffsetY
    elseif gaugeFrame and gaugeFrame.Parent and gaugeFrame.Visible then
        targetY = gaugeFrame.AbsolutePosition.Y + (gaugeFrame.AbsoluteSize.Y * 0.48) + CONFIG.TargetOffsetY
    else
        bowCache.active = false
        return
    end

    local bowCenterY = indicator.AbsolutePosition.Y + (indicator.AbsoluteSize.Y * 0.5)
    local tol = CONFIG.HitTolerancePixels

    if bowCenterY > (targetY + 15) then
        hasResetToBottom = true
    end

    local isMovingUp = false
    if prevBowCenterY ~= nil then
        if (prevBowCenterY - bowCenterY) > 0.1 then
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
        pcall(function()
            if activeQTE and typeof(activeQTE._press) == "function" then
                activeQTE:_press()
            end
        end)
        triggerPerfectHit()
        notify("PERFECT", string.format("Power Shot %d/%d", currentShot, CONFIG.TotalShots))
    end

    prevBowCenterY = bowCenterY
end

local function checkDodgeAlignment()
    if not CONFIG.Enabled or not dodgeCache.active then return end
    if (os.clock() - lastDodgeTrigger) < 0.25 then return end

    local needle = dodgeCache.needle
    local whiteZone = dodgeCache.whiteZone

    if not needle or not needle.Parent or not needle.Visible or not whiteZone or not whiteZone.Parent or not whiteZone.Visible then
        dodgeCache.active = false
        dodgeHasReset = true
        prevNeedleX = nil
        return
    end

    local whiteLeft = whiteZone.AbsolutePosition.X
    local whiteRight = whiteLeft + whiteZone.AbsoluteSize.X
    local needleX = needle.AbsolutePosition.X + (needle.AbsoluteSize.X * 0.5)

    if needleX < (whiteLeft - 12) or needleX > (whiteRight + 12) then
        dodgeHasReset = true
    end

    local movingDir = 0
    if prevNeedleX ~= nil then
        local delta = needleX - prevNeedleX
        if delta > 0.1 then
            movingDir = 1
        elseif delta < -0.1 then
            movingDir = -1
        end
    end

    local shouldTrigger = false
    if movingDir == 1 then
        if (needleX >= whiteLeft - 2) and (needleX <= whiteRight + 35) and (prevNeedleX <= whiteRight + 5) then
            shouldTrigger = true
        end
    elseif movingDir == -1 then
        if (needleX <= whiteRight + 2) and (needleX >= whiteLeft - 35) and (prevNeedleX >= whiteLeft - 5) then
            shouldTrigger = true
        end
    end

    if dodgeHasReset and shouldTrigger then
        dodgeHasReset = false
        lastDodgeTrigger = os.clock()
        pcall(function()
            if activeDefenseClient and typeof(activeDefenseClient.Press) == "function" then
                activeDefenseClient:Press()
            elseif activeQTE and typeof(activeQTE._press) == "function" then
                activeQTE:_press()
            end
        end)
        triggerPerfectHit()
        notify("DODGE", "Perfect Dodge")
    end

    prevNeedleX = needleX
end


table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.ToggleKey then
        CONFIG.Enabled = not CONFIG.Enabled
        local status = CONFIG.Enabled and "ENABLED" or "DISABLED"
        notify("Auto Minigame", "Status: " .. status)
    end
end))

notify("Minigame Assistant", "Loaded (Press [" .. CONFIG.ToggleKey.Name .. "] to Toggle)")
