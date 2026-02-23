local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bigdanix/elegant-ui-libs/refs/heads/main/millenium/source"))()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local vim = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local char, hum, hrp

local states = {noclip=false,}

local hasDrawing = (type(Drawing) == "table" and Drawing.new ~= nil)
local hasMouseMove = (type(mousemoverel) == "function")

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRootPart()
    local char = getCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local states = {
    noclip = false,
    cfSpeed = false,
    hitboxEnabled = false,
    aimbot = false,
    silentWalk = false,
    showFOV = false,
    fullbright = false,
    noFallDamage = false,
    fly = false,
    autoreload = false,
    autofarm = false,
}

local settings = {
    speedMultiplier = 2,
    hitboxSize = 5,
    hitboxPart = "Head",
    aimSmoothing = 5,
    aimFOV = 120,
    aimPart = "Head"
}

local flyVelocity, flySpeed = nil, 16

local AimFovCircle = nil
if hasDrawing then
    pcall(function()
        AimFovCircle = Drawing.new("Circle")
        AimFovCircle.Visible = false
        AimFovCircle.Thickness = 2
        AimFovCircle.NumSides = 100
        AimFovCircle.Color = Color3.fromRGB(0, 150, 255)
        AimFovCircle.Transparency = 0.8
        AimFovCircle.Filled = false
    end)
end

local function updateFOVCircle()
    pcall(function()
        if hasDrawing and AimFovCircle then
            AimFovCircle.Visible = states.showFOV and states.aimbot
            if AimFovCircle.Visible then
                AimFovCircle.Radius = settings.aimFOV
                AimFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            end
        end
    end)
end

local noclipConnection = nil

local function setNoClipState(state)
    pcall(function()
        states.noclip = state
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        
        if state then
            root.CFrame = root.CFrame * CFrame.Angles(math.rad(180), 0, 0)
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            noclipConnection = RS.Stepped:Connect(function()
                pcall(function()
                    if not root or not root.Parent then return end
                    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(180), 0, 0)
                    local move = Vector3.new()
                    if UIS:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
                    if move.Magnitude > 0 then
                        move = move.Unit
                        root.Velocity = move * 50
                        if move.Y ~= 0 then root.Velocity += Vector3.new(0, move.Y * 30, 0) end
                    else
                        root.Velocity = Vector3.zero
                    end
                end)
            end)
        else
            root.CFrame = root.CFrame * CFrame.Angles(math.rad(180), 0, 0)
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p ~= root then p.CanCollide = true end
            end
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            root.Velocity = Vector3.zero
        end
    end)
end

local speedConnection = nil
local function setCFSpeed(enabled)
    pcall(function()
        states.cfSpeed = true
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        if enabled then
            speedConnection = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local hrp = getRootPart()
                    local hum = getHumanoid()
                    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                        local mult = settings.speedMultiplier or 2
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (mult / 5))
                    end
                end)
            end)
        end
    end)
end

local expandedPlayers = {}
local hitboxConnection = nil

local function setHitbox(enabled)
    pcall(function()
        states.hitboxEnabled = enabled
        if hitboxConnection then
            hitboxConnection:Disconnect()
            hitboxConnection = nil
        end
        for player, data in pairs(expandedPlayers) do
            pcall(function()
                if data.part and data.part.Parent then
                    data.part.Size = data.originalSize
                    data.part.Transparency = data.originalTransparency
                    data.part.CanCollide = true
                    data.part.Massless = false
                end
            end)
        end
        expandedPlayers = {}
        if enabled then
            hitboxConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local playersFolder = workspace:FindFirstChild("Players") or workspace
                    for _, player in ipairs(playersFolder:GetChildren()) do
                        if player ~= getCharacter() then
                            local hum = player:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                local targetPart = settings.hitboxPart == "Body" and 
                                                 (player:FindFirstChild("HumanoidRootPart") or player:FindFirstChild("Torso")) or
                                                 player:FindFirstChild("Head")
                                if targetPart then
                                    if not expandedPlayers[player] then
                                        expandedPlayers[player] = {
                                            part = targetPart,
                                            originalSize = targetPart.Size,
                                            originalTransparency = targetPart.Transparency
                                        }
                                    end
                                    local size = settings.hitboxSize or 5
                                    targetPart.Size = Vector3.new(size, size, size)
                                    targetPart.Transparency = 0.5
                                    targetPart.CanCollide = false
                                    targetPart.Massless = true
                                end
                            end
                        end
                    end
                end)
            end)
        end
    end)
end

local aimbotConnection = nil

local function getClosestTarget(maxDist, targetPartSetting)
    local closest, closestDist = nil, maxDist
    pcall(function()
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local playersFolder = workspace:FindFirstChild("Players") or workspace
        for _, p in ipairs(playersFolder:GetChildren()) do
            if p ~= getCharacter() then
                local hum = p:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = p:FindFirstChild(targetPartSetting == "Closest Part" and "Head" or targetPartSetting)
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if dist < closestDist then 
                                closestDist = dist
                                closest = part 
                            end
                        end
                    end
                end
            end
        end
    end)
    return closest
end

local function setAimbot(enabled)
    pcall(function()
        states.aimbot = enabled
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        if enabled then
            aimbotConnection = RunService.RenderStepped:Connect(function()
                pcall(function()
                    updateFOVCircle()
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and hasMouseMove then
                        local target = getClosestTarget(settings.aimFOV or 120, settings.aimPart or "Head")
                        if target and mousemoverel then
                            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            local sp = Camera:WorldToViewportPoint(target.Position)
                            local smooth = settings.aimSmoothing or 5
                            mousemoverel((sp.X - center.X)/smooth, (sp.Y - center.Y)/smooth)
                        end
                    end
                end)
            end)
        else
            if hasDrawing and AimFovCircle then
                pcall(function() AimFovCircle.Visible = false end)
            end
        end
    end)
end

local silentWalkConnection = nil
local function setSilentWalk(enabled)
    pcall(function()
        states.silentWalk = enabled
        if silentWalkConnection then
            silentWalkConnection:Disconnect()
            silentWalkConnection = nil
        end
        if enabled then
            silentWalkConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = getCharacter()
                    if not char then return end
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("Sound") and (part.Name:lower():find("step") or part.Name:lower():find("walk")) then
                            part.Volume = 0
                        end
                    end
                end)
            end)
        else
            pcall(function()
                local char = getCharacter()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("Sound") and (part.Name:lower():find("step") or part.Name:lower():find("walk")) then
                            part.Volume = 0.5
                        end
                    end
                end
            end)
        end
    end)
end

local originalLightingSettings = {Brightness=Lighting.Brightness, TimeOfDay=Lighting.TimeOfDay, Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient}
local function setFullbrightState(state)
    pcall(function()
        states.fullbright = state
        if state then
            Lighting.Brightness = 2
            Lighting.TimeOfDay = "12:00:00"
            Lighting.Ambient = Color3.new(0.8, 0.8, 0.8)
            Lighting.OutdoorAmbient = Color3.new(0.8, 0.8, 0.8)
        else
            for k, v in pairs(originalLightingSettings) do Lighting[k] = v end
        end
    end)
end

local function setNoFallDamage(state)
    pcall(function()
        states.noFallDamage = state
        if state then
            if not hum or not hum.Parent or not hrp or not hrp.Parent then return end
            local fallCorrection = RS.Heartbeat:Connect(function()
                pcall(function()
                    if not states.noFallDamage or not hrp or not hrp.Parent then 
                        if fallCorrection then fallCorrection:Disconnect() end
                        return 
                    end
                    local velocity = hrp.AssemblyLinearVelocity
                    if velocity.Y < -50 then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.FilterDescendantsInstances = {char}
                        local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), rayParams)
                        if ray and ray.Distance < 10 then
                            local newCFrame = hrp.CFrame + Vector3.new(0, 0.5, 0)
                            hrp.CFrame = newCFrame
                            hrp.Velocity = Vector3.new(hrp.Velocity.X, -5, hrp.Velocity.Z)
                        end
                    end
                    if hum:GetState() == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end)
            end)
            table.insert(allConns, fallCorrection)
        else
            if hrp then
                pcall(function() hrp.Velocity = Vector3.new(hrp.Velocity.X, hrp.Velocity.Y, hrp.Velocity.Z) end)
            end
        end
    end)
end

local flyConn
local flyVelocity
local flySpeed = 16

local function getFlyDirection()
    local moveVec = Vector3.zero
    pcall(function()
        local camCF = workspace.CurrentCamera.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveVec += camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveVec -= camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveVec -= camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveVec += camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec -= Vector3.yAxis end
    end)
    if moveVec.Magnitude > 0 then return moveVec.Unit end
    return Vector3.zero
end

local function setFly(state)
    pcall(function()
        states.fly = state
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if flyVelocity then pcall(function() flyVelocity:Destroy() end) flyVelocity = nil end
        if not state then
            if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
            return
        end
        char = LocalPlayer.Character
        if not char then return end
        hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Name = "StealthFly"
        flyVelocity.MaxForce = Vector3.one * 4000
        flyVelocity.P = 500
        flyVelocity.Velocity = Vector3.zero
        flyVelocity.Parent = hrp
        flyConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not states.fly or not hrp or not hrp.Parent then return end
                local dir = getFlyDirection()
                if dir.Magnitude > 0 then
                    flyVelocity.Velocity = dir * flySpeed
                else
                    flyVelocity.Velocity = Vector3.zero
                end
            end)
        end)
    end)
end

local function AutoReload()
    local args = {
        [1] = "Weapon Reload",
        [2] = false,
        [3] = 1,
        [4] = "Rifle Ammunition",
        [5] = 5,
        [6] = 12,
        [7] = 30,
        [8] = 6,
        [9] = 42,
        [10] = 45,
        [11] = 2,
        [12] = 21,
        [13] = 28,
        [14] = 33,
        [15] = 37,
        [16] = 48,
        [17] = 26,
        [18] = 14,
        [19] = 14,
        [20] = 38,
        [21] = 26,
        [22] = 48,
        [23] = 36,
        [24] = 30,
        [25] = 15,
        [26] = 30,
        [27] = 5,
        [28] = 27,
        [29] = 11,
        [30] = 31,
        [31] = 43,
        [32] = 30,
        [33] = 5,
        [34] = 44,
        [35] = 40,
        [36] = 10,
        [37] = 23,
        [38] = 19,
        [39] = 32,
        [40] = 18,
        [41] = 45,
        [42] = 30,
        [43] = 29,
        [44] = 8,
        [45] = 23,
        [46] = 34,
        [47] = 2,
        [48] = 12,
        [49] = 5,
        [50] = 41,
        [51] = 47,
        [52] = 2,
        [53] = 2
    }
    spawn(function()
        while states.autoreload do
            pcall(function()
                wait(0.1)
                game:GetService("ReplicatedStorage").Remotes.RemoteEvent:FireServer(unpack(args))
            end)
        end
    end)
end

-- ============================================
-- AUTO FARM
-- ============================================
local autoFarmSettings = {
    slot = 1,
    delay = 0.15,
    range = 80,
    hitCount = 3,
}
local autoFarmLoop = nil

local function getMarker(resource)
    return resource:FindFirstChild("Marker", true)
end

local function getLookTarget()
    local r1, r2, r3, r4 = nil, nil, nil, nil
    pcall(function()
        local unitRay = Camera:ScreenPointToRay(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * autoFarmSettings.range, rayParams)
        if not result then return end
        local current = result.Instance
        while current and current.Parent do
            if current.Parent == workspace.Resources then
                r1, r2, r3, r4 = current, result.Instance, result.Position, result.Material
                return
            end
            current = current.Parent
        end
    end)
    return r1, r2, r3, r4
end

local function doFarmHit(resource, hitPart, position, material)
    pcall(function()
        local marker = getMarker(resource)
        local targetPart, targetCF, targetMat, isMarker

        if marker then
            targetPart = marker
            targetCF   = marker.CFrame
            targetMat  = Enum.Material.Wood
            isMarker   = true
        else
            targetPart = hitPart
            targetCF   = CFrame.new(position)
            targetMat  = material
            isMarker   = false
        end

        local args = {
            [1]  = "Melee Hit",
            [2]  = false,
            [3]  = targetPart,
            [4]  = targetCF,
            [5]  = targetMat,
            [6]  = autoFarmSettings.slot,
            [7]  = false,
            [8]  = resource,
            [10] = isMarker,
            [11] = 19, [12] = 20, [13] = 8,  [14] = 45, [15] = 1,
            [16] = 17, [17] = 22, [18] = 15, [19] = 4,  [20] = 27,
            [21] = 31, [22] = 31, [23] = 5,  [24] = 1,  [25] = 22,
            [26] = 9,  [27] = 25, [28] = 16, [29] = 43, [30] = 27,
            [31] = 19, [32] = 12, [33] = 15, [34] = 21, [35] = 37,
            [36] = 17, [37] = 47, [38] = 30, [39] = 29, [40] = 46,
            [41] = 15, [42] = 18, [43] = 5,  [44] = 22, [45] = 4,
            [46] = 31, [47] = 10, [48] = 8,
        }

        game:GetService("ReplicatedStorage").Remotes.RemoteEvent:FireServer(table.unpack(args, 1, 48))
    end)
end

local function setAutoFarm(enabled)
    pcall(function()
        states.autofarm = enabled

        if autoFarmLoop then
            task.cancel(autoFarmLoop)
            autoFarmLoop = nil
        end

        if enabled then
            autoFarmLoop = safeSpawn(function()
                while states.autofarm do
                    task.wait(autoFarmSettings.delay)
                    pcall(function()
                        local resource, part, position, material = getLookTarget()
                        if not resource then return end
                        for i = 1, autoFarmSettings.hitCount do
                            if not states.autofarm then break end
                            doFarmHit(resource, part, position, material)
                            task.wait(autoFarmSettings.delay)
                        end
                    end)
                end
            end)
        end
    end)
end
-- ============================================

local killAuraConnection = nil
local killAuraSettings = {
    enabled = false,
    range = 15,
    attackDelay = 0.1,
    adjustForHitbox = true,
    slot = 2,
    attackAllSlots = false
}

local function calcularDistanciaAjustada(minhaHead, targetHead)
    local dist = math.huge
    pcall(function()
        if not minhaHead or not targetHead then return end
        local distanciaCentro = (minhaHead.Position - targetHead.Position).Magnitude
        if killAuraSettings.adjustForHitbox then
            local tamanhoPadrao = 2
            local tamanhoAtual = targetHead.Size.X
            local raioExtra = math.max(0, (tamanhoAtual - tamanhoPadrao) / 2)
            dist = distanciaCentro - raioExtra
        else
            dist = distanciaCentro
        end
    end)
    return dist
end

local function getNearbyPlayers()
    local nearbyPlayers = {}
    pcall(function()
        local character = getCharacter()
        if not character then return end
        local head = character:FindFirstChild("Head")
        if not head then return end
        local playersFolder = workspace:FindFirstChild("Players")
        if playersFolder then
            for _, playerModel in pairs(playersFolder:GetChildren()) do
                if playerModel ~= character then
                    local targetHead = playerModel:FindFirstChild("Head")
                    local humanoid = playerModel:FindFirstChildOfClass("Humanoid")
                    if targetHead and humanoid and humanoid.Health > 0 then
                        local distance = calcularDistanciaAjustada(head, targetHead)
                        if distance <= killAuraSettings.range then
                            table.insert(nearbyPlayers, {
                                model = playerModel,
                                distance = distance,
                                hitboxSize = targetHead.Size.X
                            })
                        end
                    end
                end
            end
        end
        table.sort(nearbyPlayers, function(a, b) return a.distance < b.distance end)
    end)
    return nearbyPlayers
end

local function attackWithSlot(targetData, slotNumber)
    local success = false
    pcall(function()
        local targetPlayer = targetData.model
        local targetPart = targetPlayer:FindFirstChild("LeftUpperArm") or targetPlayer:FindFirstChild("Head")
        if not targetPart then return end
        local args = {
            [1] = "Melee Hit",
            [2] = false,
            [3] = targetPart,
            [4] = targetPart.CFrame,
            [5] = Enum.Material.Plastic,
            [6] = slotNumber,
            [7] = true,
            [8] = targetPlayer,
            [10] = false,
            [11] = 7,  [12] = 11, [13] = 15, [14] = 17, [15] = 48,
            [16] = 30, [17] = 3,  [18] = 20, [19] = 34, [20] = 4,
            [21] = 31, [22] = 7,  [23] = 20, [24] = 23, [25] = 45,
            [26] = 12, [27] = 9,  [28] = 45, [29] = 26, [30] = 10,
            [31] = 34, [32] = 35, [33] = 29, [34] = 42, [35] = 40,
            [36] = 1,  [37] = 2,  [38] = 38, [39] = 8,  [40] = 21,
            [41] = 8,  [42] = 16, [43] = 6,  [44] = 22, [45] = 9,
            [46] = 49, [47] = 5,  [48] = 1,  [49] = 4,  [50] = 36,
            [51] = 28, [52] = 16, [53] = 43, [54] = 44, [55] = 32,
            [56] = 35, [57] = 19, [58] = 16, [59] = 59, [60] = 34,
            [61] = 8
        }
        game:GetService("ReplicatedStorage").Remotes.RemoteEvent:FireServer(unpack(args))
        success = true
    end)
    return success
end

local function attackPlayer(targetData)
    pcall(function()
        if killAuraSettings.attackAllSlots then
            for slot = 1, 6 do
                attackWithSlot(targetData, slot)
                task.wait(0.05)
            end
        else
            attackWithSlot(targetData, killAuraSettings.slot)
        end
    end)
end

local function setKillAura(enabled)
    pcall(function()
        killAuraSettings.enabled = enabled
        if killAuraConnection then
            killAuraConnection:Disconnect()
            killAuraConnection = nil
        end
        if enabled then
            killAuraConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if not killAuraSettings.enabled then return end
                    local nearbyPlayers = getNearbyPlayers()
                    if #nearbyPlayers > 0 then
                        for _, playerData in pairs(nearbyPlayers) do
                            if not killAuraSettings.enabled then break end
                            attackPlayer(playerData)
                            task.wait(killAuraSettings.attackDelay)
                        end
                    end
                end)
            end)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    pcall(function()
        task.wait(0.5)
    end)
end)

-- UI Setup
local window = library:window({
    name = "Aspect", 
    suffix = "Software", 
    gameInfo = "Aspect Software - Private Edition"
})

window:seperator({name = "Visuals"})
local Player = window:tab({name = "Visuals", tabs = {"Player"}})

for _, tab in {Player} do
    local column = tab:column({})
    local section = column:section({name = "ESP", default = true, toggle = false})

    section:toggle({
        name = "Enable ESP",
        seperator = true,
        type = "toggle",
        callback = function(bool)
            pcall(function()
                if Espliberary and Espliberary.toggle_feature then
                    Espliberary:toggle_feature("Enabled", bool)
                end
            end)
        end
    })

    local features = {
        {name = "Names", feature = "Names"},
        {name = "Boxes", feature = "Boxes"},
        {name = "Healthbar", feature = "Healthbar"},
        {name = "Distance", feature = "Distance"},
        {name = "Weapon", feature = "Weapon"},
        {name = "Skeletons", feature = "Skeletons"}
    }

    for _, data in ipairs(features) do
        section:toggle({
            name = data.name,
            type = "toggle",
            callback = function(bool)
                pcall(function()
                    if Espliberary and Espliberary.toggle_feature then
                        Espliberary:toggle_feature(data.feature, bool)
                    end
                end)
            end
        })
    end

    section:slider({
        name = "Max Distance",
        min = 100,
        max = 5000,
        default = 1000,
        callback = function(value)
            pcall(function() Espliberary:set_max_distance(value) end)
        end
    })
end

window:seperator({name = "Combat"})
local CombatPage, KillAuraPage = window:tab({name = "Combat", tabs = {"Aimbot", "Kill Aura"}})

-- aba Aimbot
local column = CombatPage:column({})
local column2 = CombatPage:column({})
local aimbotSection = column:section({name = "Aimbot", default = true, toggle = false})

aimbotSection:toggle({
    name = "Enable Aimbot",
    seperator = true,
    type = "toggle",
    callback = function(bool) pcall(setAimbot, bool) end
})

aimbotSection:toggle({
    name = "Show FOV",
    type = "toggle",
    callback = function(bool)
        pcall(function()
            states.showFOV = bool
            updateFOVCircle()
        end)
    end
})

aimbotSection:slider({
    name = "Smoothness",
    min = 1,
    max = 20,
    default = 5,
    decimals = 0.1,
    callback = function(value) pcall(function() settings.aimSmoothing = value end) end
})

aimbotSection:slider({
    name = "FOV Size",
    min = 10,
    max = 800,
    default = 120,
    callback = function(value)
        pcall(function()
            settings.aimFOV = value
            updateFOVCircle()
        end)
    end
})

aimbotSection:list({
    name = "Target Part",
    default = "Head",
    options = {"Head", "HumanoidRootPart", "Torso", "Closest Part"},
    callback = function(value) pcall(function() settings.aimPart = value end) end
})

local hitboxSection = column2:section({name = "Hitbox", default = true, toggle = false})

hitboxSection:toggle({
    name = "Enable Hitbox",
    seperator = true,
    type = "toggle",
    callback = function(bool) pcall(setHitbox, bool) end
})

hitboxSection:slider({
    name = "Hitbox Size",
    min = 1,
    max = 38,
    default = 5,
    callback = function(value) pcall(function() settings.hitboxSize = value end) end
})

hitboxSection:list({
    name = "Body Part",
    default = "Head",
    options = {"Head"},
    callback = function(value) pcall(function() settings.hitboxPart = value end) end
})

-- aba Kill Aura
local kaColumn = KillAuraPage:column({})
local kaColumn2 = KillAuraPage:column({})
local killAuraSection = kaColumn:section({name = "Kill Aura", default = true, toggle = false})

killAuraSection:toggle({
    name = "Enable Kill Aura",
    type = "toggle",
    seperator = true,
    callback = function(bool) pcall(setKillAura, bool) end
})

killAuraSection:slider({
    name = "Range",
    min = 5,
    max = 50,
    default = 15,
    callback = function(value) pcall(function() killAuraSettings.range = value end) end
})

killAuraSection:slider({
    name = "Attack Delay",
    min = 0.01,
    max = 1,
    default = 0.1,
    decimals = 0.01,
    callback = function(value) pcall(function() killAuraSettings.attackDelay = value end) end
})

killAuraSection:toggle({
    name = "Adjust for Hitbox",
    type = "toggle",
    default = true,
    callback = function(bool) pcall(function() killAuraSettings.adjustForHitbox = bool end) end
})

killAuraSection:toggle({
    name = "Attack All Slots (1-6)",
    type = "toggle",
    seperator = true,
    default = false,
    callback = function(bool) pcall(function() killAuraSettings.attackAllSlots = bool end) end
})

killAuraSection:slider({
    name = "Weapon Slot",
    min = 1,
    max = 6,
    default = 2,
    callback = function(value) pcall(function() killAuraSettings.slot = value end) end
})

window:seperator({name = "Movement"})
local Movement = window:tab({name = "Movement", tabs = {"Main"}})

for _, tab in {Movement} do
    local column = tab:column({})
    local movementSection = column:section({name = "Movement", default = true, toggle = false})
    
    movementSection:keybind({
        name = "Noclip Keybind",
        default = false,
        active = false,
        seperator = true,
        callback = function(bool)
            pcall(function()
                states.noclip = bool
                setNoClipState(bool)
            end)
        end
    })

    movementSection:toggle({
        name = "No fall Damage",
        type = "toggle",
        seperator = true,
        default = false,
        callback = function(bool) pcall(setNoFallDamage, bool) end
    })

    movementSection:toggle({
        name = "CFrame Speed",
        type = "toggle",
        default = false,
        seperator = false,
        callback = function(bool) pcall(setCFSpeed, bool) end
    })
    
    movementSection:slider({
        name = "Speed Multiplier",
        min = 100,
        max = 250,
        default = 150,
        intervals = 0.1,
        callback = function(value) pcall(function() settings.speedMultiplier = value / 100 end) end
    })

    movementSection:keybind({
        name = "Fly (Might Be detected)",
        default = false,
        active = false,
        seperator = true,
        callback = function(bool)
            pcall(function()
                states.fly = bool
                setFly(states.fly)
            end)
        end
    })
end

window:seperator({name = "Exploits"})
local ExploitsPage, AutoFarmPage = window:tab({name = "Exploits", tabs = {"Exploits", "Auto Farm"}})

-- aba Exploits
local column = ExploitsPage:column({})
local column2 = ExploitsPage:column({})

local ExploitsSection = column:section({name = "Auto Reload", default = true, toggle = false})

ExploitsSection:toggle({
    name = "Auto Reload",
    type = "toggle",
    seperator = true,
    callback = function(bool)
        pcall(function()
            states.autoreload = bool
            if states.autoreload then AutoReload() end
        end)
    end
})

local miscSection = column2:section({name = "Miscellaneous", default = true, toggle = false})

miscSection:toggle({
    name = "Fullbright",
    type = "toggle",
    callback = function(bool) pcall(setFullbrightState, bool) end
})

-- aba Auto Farm
local afColumn = AutoFarmPage:column({})
local autoFarmSection = afColumn:section({name = "Auto Farm", default = true, toggle = false})

autoFarmSection:toggle({
    name = "Enable Auto Farm",
    type = "toggle",
    seperator = true,
    callback = function(bool) pcall(setAutoFarm, bool) end
})

autoFarmSection:slider({
    name = "Tool Slot",
    min = 1,
    max = 6,
    default = 1,
    callback = function(value) pcall(function() autoFarmSettings.slot = value end) end
})

autoFarmSection:slider({
    name = "Hit Delay",
    min = 0.05,
    max = 1,
    default = 0.15,
    decimals = 0.01,
    callback = function(value) pcall(function() autoFarmSettings.delay = value end) end
})

autoFarmSection:slider({
    name = "Hits Per Cycle",
    min = 1,
    max = 10,
    default = 3,
    callback = function(value) pcall(function() autoFarmSettings.hitCount = value end) end
})

autoFarmSection:slider({
    name = "Range",
    min = 10,
    max = 200,
    default = 80,
    callback = function(value) pcall(function() autoFarmSettings.range = value end) end
})

pcall(function() library:init_config(window) end)

pcall(function()
    if library.notification then
        library:notification({
            title = "Aspect Software",
            message = "Successfully loaded!",
            duration = 5
        })
    end
end)
