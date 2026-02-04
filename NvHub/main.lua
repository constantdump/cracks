task.spawn(function()
-- [[ NVHUB PREMIUM: HVH EDITION ]]
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
-- [[ RAGE GUNS HOOK LOGIC WITH RESET FIX ]]
_G.RageSettings = {
    Enabled = false,
    Recoil = 0,
    Spread = 0,
    ProjSpeed = 0,
    Cooldown = 0
}
local OriginalStats = {} 
local clientItemModule = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
local inputFunc = clientItemModule.Input
local oldRage;
if hookfunction then
    oldRage = hookfunction(inputFunc, function(...)
        local args = {...}
        if type(args[1]) == "table" and args[1].Info then
            local gunName = args[1].Name or "Default"
            if not OriginalStats[gunName] then
                OriginalStats[gunName] = {
                    Recoil = args[1].Info.ShootRecoil,
                    Spread = args[1].Info.ShootSpread,
                    Speed = args[1].Info.ProjectileSpeed,
                    CD = args[1].Info.ShootCooldown,
                    QCD = args[1].Info.QuickShotCooldown
                }
            end
            if _G.RageSettings.Enabled then
                args[1].Info.ShootRecoil = _G.RageSettings.Recoil
                args[1].Info.ShootSpread = _G.RageSettings.Spread
                args[1].Info.ProjectileSpeed = _G.RageSettings.ProjSpeed
                args[1].Info.ShootCooldown = _G.RageSettings.Cooldown
                args[1].Info.QuickShotCooldown = _G.RageSettings.Cooldown
            else
                local orig = OriginalStats[gunName]
                args[1].Info.ShootRecoil = orig.Recoil
                args[1].Info.ShootSpread = orig.Spread
                args[1].Info.ProjectileSpeed = orig.Speed
                args[1].Info.ShootCooldown = orig.CD
                args[1].Info.QuickShotCooldown = orig.QCD
            end
        end
        return oldRage(...)
    end)
end
-- [[ SETTINGS & AUTO-SAVE LOGIC ]]
_G.NvSettings = {
    AimEnabled = false, AimBind = "MouseButton2", AimPart = "Head", Hardlock = false,
    SmoothEnabled = false, SmoothValue = 0, ShakeEnabled = false, ShakeValue = 0,
    WallCheck = true, TeamCheck = true, KatanaCheck = true,
    UnlockRivalsActive = false,
    FOVVisible = true, FOVSize = 150,
    Box = false, Corners = false, Health = false, Names = false, 
    WeaponESP = false,
    CharmsFill = false, CharmsOutline = false,
    Crosshair = true, CrossSpin = false, CrossSpinSpeed = 5,
    Watermark = true, WMOutline = true,
    Rainbow = false, RainbowSpeed = 2,
    Fly = false, FlySpeed = 50, FlyBind = "F",
    HvHMovement = false,
    JumpEnabled = false, JumpPower = 50, Noclip = false,
    NoArms = false, -- New Setting Added
    TriggerBot = false, StickEnabled = false, StickBind = "J", StickTarget = nil,
    StickSpin = false, SpinBotSpeed = 10, StickHeight = 0, StickDistance = 5,
    StickLookAt = false,
    MenuBind = "RightShift", CurrentAngle = 0, ShowArrayList = true,
    ShowMobileButton = true,
    StaffDetectorActive = false,
    DeviceSpoofer = false,
    SpoofedDevice = "MouseKeyboard",
    RageGunsEnabled = false
}
local NS = _G.NvSettings
local ConfigFile = "nvhubpremiumcfg.json" -- New config name applied [cite: 9]
local function SaveSettings()
    local success, encoded = pcall(function() return HttpService:JSONEncode(NS) end)
    if success then writefile(ConfigFile, encoded) end
end
local function LoadSettings()
    if isfile(ConfigFile) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success then for k, v in pairs(decoded) do NS[k] = v end end
    end
end
LoadSettings()
-- [[ NO ARMS LOGIC ]]
local function disableIfArm(obj)
    if NS.NoArms and obj:IsA("BasePart") then
        if obj.Name == "RightArm" or obj.Name == "LeftArm" then
            obj.Transparency = 1
            obj.CanCollide = false
            obj.Anchored = true
        end
    end
end
for _, obj in pairs(workspace:GetDescendants()) do disableIfArm(obj) end
workspace.DescendantAdded:Connect(disableIfArm)
-- [[ AUTO REDEEM CODES LOGIC ]]
local function RedeemCodes()
    local codes = {"COMMUNITY20", "FREE146", "BONUS", "BOOST", "ROBLOX_RTC", "MERRYMERRYXMAS<3"}
    for _, code in ipairs(codes) do
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.Data.RedeemCode:InvokeServer(code)
        end)
    end
end
-- [[ CUSTOM BUTTONS CONFIGURATION ]]
local CUSTOM_BUTTON_NAME = "Unlock all rivals" 
local function CUSTOM_SCRIPT_LOGIC()
    NS.UnlockRivalsActive = not NS.UnlockRivalsActive
    if NS.UnlockRivalsActive then
        loadstring(game:HttpGet("https://pastefy.app/EBhPhzTz/raw"))()
    end
    SaveSettings()
end
local CUSTOM_BUTTON_2_NAME = "Staff Detector"
local function CUSTOM_SCRIPT_2_LOGIC()
    NS.StaffDetectorActive = not NS.StaffDetectorActive
    if NS.StaffDetectorActive then
        loadstring(game:HttpGet("https://pastefy.app/IgRHJvgY/raw"))()
    end
    SaveSettings()
end
if NS.StaffDetectorActive then
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Itsnvfr/NvHub/refs/heads/main/ng %20staff %20detector"))()
    end)
end
if NS.UnlockRivalsActive then
    task.spawn(function()
        loadstring(game:HttpGet("https://pastefy.app/EBhPhzTz/raw"))()
    end)
end
-- [[ DEVICE SPOOFER LOGIC ]]
local function ApplyDeviceSpoof(deviceName)
    NS.SpoofedDevice = deviceName
    SaveSettings()
    pcall(function()
        local ControlRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replication"):WaitForChild("Fighter"):WaitForChild("SetControls")
        ControlRemote:FireServer(deviceName)
    end)
end
-- Updated Premium Theme: Yellow
local Accent = Color3.fromRGB(255, 255, 0)
local TrueDark = Color3.fromRGB(10, 10, 10)
local ButtonDark = Color3.fromRGB(18, 18, 18)
local DarkerOutline = Color3.fromRGB(5, 5, 5)
local FontStyle = Enum.Font.Arcade
-- [[ CURSOR & TRAIL LOGIC ]]
local CustomCursor = Drawing.new("Square")
CustomCursor.Size = Vector2.new(6, 6)
CustomCursor.Color = Accent
CustomCursor.Filled = true
CustomCursor.Thickness = 1
CustomCursor.Visible = false
local CursorOutline = Drawing.new("Square")
CursorOutline.Size = Vector2.new(8, 8)
CursorOutline.Color = Color3.new(0, 0, 0)
CursorOutline.Filled = false
CursorOutline.Thickness = 1
CursorOutline.Visible = false
local CursorTrail = Drawing.new("Text")
CursorTrail.Text = "NvHub"
CursorTrail.Color = Color3.new(1, 1, 1)
CursorTrail.Size = 14
CursorTrail.Font = 2
CursorTrail.Outline = true
CursorTrail.Visible = false
local trailPos = UIS:GetMouseLocation()
-- [[ ARRAYLIST LOGIC ]]
local ArrayGui = Instance.new("ScreenGui", CoreGui)
ArrayGui.Name = "NvArrayList"
local ArrayListHolder = Instance.new("Frame", ArrayGui)
ArrayListHolder.Size = UDim2.new(0, 200, 1, 0)
ArrayListHolder.Position = UDim2.new(1, -210, 0, 10)
ArrayListHolder.BackgroundTransparency = 1
local ArrayLayout = Instance.new("UIListLayout", ArrayListHolder)
ArrayLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ArrayLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ArrayLayout.Padding = UDim.new(0, 2)
local ActiveLabels = {}
local function UpdateArrayList()
    if not NS.ShowArrayList then 
        for _, v in pairs(ActiveLabels) do v.obj:Destroy() end
        ActiveLabels = {}
        return 
    end
    local Features = {
        {"Aimbot", NS.AimEnabled},
        {"Hardlock", NS.Hardlock},
        {CUSTOM_BUTTON_NAME, NS.UnlockRivalsActive},
        {CUSTOM_BUTTON_2_NAME, NS.StaffDetectorActive},
        {"ESP", NS.Box or NS.Corners},
        {"Weapon ESP", NS.WeaponESP},
        {"No Arms", NS.NoArms},
        {"Charms", NS.CharmsFill or NS.CharmsOutline},
        {"Fly", NS.Fly},
        {"HvH", NS.HvHMovement},
        {"Jump", NS.JumpEnabled},
        {"Noclip", NS.Noclip},
        {"Trigger", NS.TriggerBot},
        {"Stick", NS.StickEnabled},
        {"Spoofing", NS.DeviceSpoofer},
        {"Rage Guns", NS.RageGunsEnabled}
    }
    for _, feat in pairs(Features) do
        local name, enabled = feat[1], feat[2]
        if enabled and not ActiveLabels[name] then
            local Label = Instance.new("TextLabel", ArrayListHolder)
            Label.Name = name
            Label.Size = UDim2.new(0, 0, 0, 25)
            Label.BackgroundColor3 = TrueDark
            Label.BackgroundTransparency = 0.1
            Label.BorderSizePixel = 0
            Label.TextColor3 = Accent
            Label.Text = " " .. name .. " "
            Label.Font = FontStyle
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Right
            Label.ClipsDescendants = true
            local Line = Instance.new("Frame", Label)
            Line.Size = UDim2.new(0, 2, 1, 0)
            Line.Position = UDim2.new(1, -2, 0, 0)
            Line.BackgroundColor3 = Accent
            Line.BorderSizePixel = 0
            ActiveLabels[name] = {obj = Label}
            local textWidth = game:GetService("TextService"):GetTextSize(Label.Text, Label.TextSize, Label.Font, Vector2.new(500, 500)).X + 10
            TweenService:Create(Label, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, textWidth, 0, 25)}):Play()
        elseif not enabled and ActiveLabels[name] then
            local obj = ActiveLabels[name].obj
            ActiveLabels[name] = nil
            local t = TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 0, 0, 25)})
            t:Play()
            t.Completed:Connect(function() obj:Destroy() end)
        end
    end
end
-- [[ BLUR LOGIC ]]
local MenuBlur = Instance.new("BlurEffect", Lighting)
MenuBlur.Size = 0
MenuBlur.Enabled = true
-- [[ DRAWING OBJECTS ]]
local FOVCircle = Drawing.new("Circle")
local WM = Drawing.new("Text")
local CrossLines = {T = Drawing.new("Line"), B = Drawing.new("Line"), L = Drawing.new("Line"), R = Drawing.new("Line")}
-- [[ UI ENGINE ]]
if CoreGui:FindFirstChild("NvHub_Pixel") then CoreGui.NvHub_Pixel:Destroy() end
local MainGui = Instance.new("ScreenGui", CoreGui)
MainGui.Name = "NvHub_Pixel"
local MainHolder = Instance.new("Frame", MainGui);
MainHolder.Size = UDim2.new(1, 0, 1, 0); MainHolder.BackgroundTransparency = 1;
MainHolder.Position = UDim2.new(0, 0, -1.2, 0)
_G.MainHolderRef = MainHolder 
local MobBtn = Instance.new("TextButton", MainGui)
MobBtn.Name = "MobileToggle";
MobBtn.Size = UDim2.new(0, 50, 0, 50); MobBtn.Position = UDim2.new(0.1, 0, 0.1, 0); MobBtn.BackgroundColor3 = TrueDark; MobBtn.Text = "Nv";
MobBtn.TextColor3 = Accent; MobBtn.Font = FontStyle; MobBtn.TextSize = 20; MobBtn.Visible = NS.ShowMobileButton;
local sM = Instance.new("UIStroke", MobBtn); sM.Color = DarkerOutline;
sM.Thickness = 1.5; sM.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local function AddStroke(obj, color, thickness)
    local s = Instance.new("UIStroke", obj);
    s.Color = color or DarkerOutline; s.Thickness = thickness or 1.2; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
    return s
end
local function CreateTab(name, x)
    local F = Instance.new("Frame", MainHolder); F.Size = UDim2.new(0, 200, 0, 480);
    F.Position = UDim2.new(0.5, x, 0.1, 0); 
    F.BackgroundColor3 = TrueDark; F.BackgroundTransparency = 0.3; F.BorderSizePixel = 0;
    AddStroke(F, DarkerOutline, 1.2)
    local tabName = (name == "Settings") and "SETTINGS" or name:upper()
    local T = Instance.new("TextLabel", F);
    T.Size = UDim2.new(1, 0, 0, 35); T.Text = tabName; T.TextColor3 = Accent; T.Font = FontStyle; T.TextSize = 18;
    T.BackgroundColor3 = Color3.fromRGB(22, 22, 22); T.BorderSizePixel = 0; T.BackgroundTransparency = 0.2
    local Sc = Instance.new("ScrollingFrame", F);
    Sc.Size = UDim2.new(1, -10, 1, -45); Sc.Position = UDim2.new(0, 5, 0, 40); Sc.BackgroundTransparency = 1; Sc.ScrollBarThickness = 1;
    Sc.CanvasSize = UDim2.new(0, 0, 4, 0); Sc.ScrollBarImageColor3 = Accent; Sc.BorderSizePixel = 0
    Instance.new("UIListLayout", Sc).Padding = UDim.new(0, 6);
    return Sc
end
local function AddToggle(p, t, k, hasSlide, slideHeight)
    local B = Instance.new("TextButton", p);
    B.Size = UDim2.new(1, 0, 0, 32); B.Font = FontStyle; B.Text = t; B.TextSize = 14; B.BackgroundColor3 = ButtonDark;
    B.TextColor3 = Color3.new(0.8, 0.8, 0.8); B.BorderSizePixel = 0; B.BackgroundTransparency = 0.1;
    AddStroke(B, Color3.fromRGB(20, 20, 20), 1)
    local SlideFrame = nil
    if hasSlide then SlideFrame = Instance.new("Frame", p);
        SlideFrame.Size = UDim2.new(1, 0, 0, 0); SlideFrame.ClipsDescendants = true; SlideFrame.BackgroundTransparency = 1;
        Instance.new("UIListLayout", SlideFrame).Padding = UDim.new(0, 3) end
    local function UpdateVisuals(instant)
        local targetCol = NS[k] and Accent or ButtonDark;
        local targetText = NS[k] and Color3.new(0, 0, 0) or Color3.new(0.8, 0.8, 0.8);
        local slideSize = NS[k] and UDim2.new(1, 0, 0, slideHeight or 40) or UDim2.new(1, 0, 0, 0)
        if instant then 
            B.BackgroundColor3 = targetCol;
            B.TextColor3 = targetText; if SlideFrame then SlideFrame.Size = slideSize end 
        else 
            TweenService:Create(B, TweenInfo.new(0.2), {BackgroundColor3 = targetCol, TextColor3 = targetText}):Play();
            if SlideFrame then TweenService:Create(SlideFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = slideSize}):Play() end 
        end
        if k == "ShowMobileButton" then MobBtn.Visible = NS[k] end
        if k == "RageGunsEnabled" then _G.RageSettings.Enabled = NS[k] end
    end
    B.MouseButton1Click:Connect(function() NS[k] = not NS[k]; UpdateVisuals(false); SaveSettings(); UpdateArrayList() end)
    UpdateVisuals(true);
    return SlideFrame
end
local function AddAdjuster(p, t, k, s, isRage)
    local F = Instance.new("Frame", p);
    F.Size = UDim2.new(1, 0, 0, 35); F.BackgroundTransparency = 1
    local initialVal = isRage and _G.RageSettings[k] or NS[k]
    local L = Instance.new("TextLabel", F);
    L.Size = UDim2.new(0.55, 0, 1, 0); L.Text = t..": "..initialVal; L.TextColor3 = Color3.new(1, 1, 1); L.Font = FontStyle;
    L.TextSize = 11; L.BackgroundTransparency = 1; L.TextXAlignment = 0
    local P = Instance.new("TextButton", F);
    P.Size = UDim2.new(0, 25, 0, 25); P.Position = UDim2.new(0.85, 0, 0.15, 0); P.Text = "+"; P.BackgroundColor3 = ButtonDark;
    P.TextColor3 = Accent; P.Font = FontStyle; P.BorderSizePixel = 0; AddStroke(P, DarkerOutline)
    local M = Instance.new("TextButton", F);
    M.Size = UDim2.new(0, 25, 0, 25); M.Position = UDim2.new(0.65, 0, 0.15, 0); M.Text = "-"; M.BackgroundColor3 = ButtonDark;
    M.TextColor3 = Accent; M.Font = FontStyle; M.BorderSizePixel = 0; AddStroke(M, DarkerOutline)
    P.MouseButton1Click:Connect(function() 
        if isRage then _G.RageSettings[k] = _G.RageSettings[k] + s; L.Text = t..": ".._G.RageSettings[k]
        else NS[k] = NS[k] + s; L.Text = t..": "..NS[k]; SaveSettings() end
    end)
    M.MouseButton1Click:Connect(function() 
        if isRage then _G.RageSettings[k] = math.max(0, _G.RageSettings[k] - s); L.Text = t..": ".._G.RageSettings[k]
        else NS[k] = NS[k] - s; 
            L.Text = t..": "..NS[k]; SaveSettings() end
    end)
end
-- [[ TAB SETUP ]]
local AT = CreateTab("Aimbot", -520);
local VT = CreateTab("Visuals", -310); local MT = CreateTab("Movement", -100); local BT = CreateTab("Bots", 110);
local ST = CreateTab("Settings", 320)
AddToggle(AT, "AIMBOT ENABLED", "AimEnabled")
AddToggle(AT, "HARDLOCK", "Hardlock")
local bA = Instance.new("TextButton", AT); bA.Size = UDim2.new(1,0,0,32);
bA.Text = "BIND: "..NS.AimBind; bA.BackgroundColor3 = ButtonDark; bA.TextColor3 = Accent; bA.Font = FontStyle; bA.TextSize=14; bA.BorderSizePixel = 0;
AddStroke(bA, DarkerOutline)
local pA = Instance.new("TextButton", AT); pA.Size = UDim2.new(1,0,0,32); pA.Text = "PART: "..NS.AimPart; pA.BackgroundColor3 = ButtonDark; pA.TextColor3 = Color3.new(1,1,1);
pA.Font = FontStyle; pA.TextSize=14; pA.BorderSizePixel = 0; AddStroke(pA, Color3.fromRGB(30,30,30))
local sldS = AddToggle(AT, "SMOOTHNESS", "SmoothEnabled", true);
if sldS then AddAdjuster(sldS, "Smoothness", "SmoothValue", 1) end
local sldSh = AddToggle(AT, "SHAKE", "ShakeEnabled", true);
if sldSh then AddAdjuster(sldSh, "Shake Power", "ShakeValue", 1) end
AddToggle(AT, "WALL CHECK", "WallCheck"); AddToggle(AT, "TEAM CHECK", "TeamCheck");
AddToggle(AT, "KATANA CHECK", "KatanaCheck")
AddToggle(AT, "SHOW FOV", "FOVVisible"); AddAdjuster(AT, "FOV Size", "FOVSize", 10)
bA.MouseButton1Click:Connect(function() bA.Text = "..."; local i = UIS.InputBegan:Wait(); if i.UserInputType == Enum.UserInputType.Keyboard then NS.AimBind = i.KeyCode.Name elseif i.UserInputType.Name:find("MouseButton") then NS.AimBind = i.UserInputType.Name end; bA.Text = "BIND: "..NS.AimBind; SaveSettings() end)
pA.MouseButton1Click:Connect(function() local p={"Head","HumanoidRootPart","Closest"}; local i=table.find(p,NS.AimPart) or 1; NS.AimPart=p[i%3+1]; pA.Text="PART: "..NS.AimPart; SaveSettings() end)
AddToggle(VT, "BOX ESP", "Box");
AddToggle(VT, "CORNER ESP", "Corners"); AddToggle(VT, "HEALTH BAR", "Health"); AddToggle(VT, "NAMES", "Names")
-- WEAPON ESP BUTTON REMOVED
AddToggle(VT, "CHARMS FILL", "CharmsFill")
AddToggle(VT, "CHARMS OUTLINE", "CharmsOutline")
AddToggle(VT, "CROSSHAIR", "Crosshair");
AddToggle(VT, "CROSSHAIR SPIN", "CrossSpin"); AddAdjuster(VT, "Spin Speed", "CrossSpinSpeed", 1)
AddToggle(VT, "WATERMARK", "Watermark")
AddToggle(VT, "RAINBOW MODE", "Rainbow");
AddAdjuster(VT, "Rain Speed", "RainbowSpeed", 1)
AddToggle(MT, "FLY ENABLED", "Fly"); AddAdjuster(MT, "Fly Speed", "FlySpeed", 5)
local bF = Instance.new("TextButton", MT); bF.Size = UDim2.new(1,0,0,32);
bF.Text = "FLY KEY: "..NS.FlyBind; bF.BackgroundColor3 = ButtonDark; bF.TextColor3 = Accent; bF.Font = FontStyle; bF.TextSize=14; bF.BorderSizePixel = 0;
AddStroke(bF, DarkerOutline)
AddToggle(MT, "CUSTOM JUMP", "JumpEnabled"); AddAdjuster(MT, "Jump Power", "JumpPower", 10)
AddToggle(MT, "NOCLIP", "Noclip")
AddToggle(MT, "HVH MOVEMENT", "HvHMovement")
bF.MouseButton1Click:Connect(function() bF.Text = "..."; local i=UIS.InputBegan:Wait(); NS.FlyBind=i.KeyCode.Name; bF.Text="FLY KEY: "..NS.FlyBind; SaveSettings() end)
AddToggle(BT, "TRIGGER BOT", "TriggerBot")
AddToggle(BT, "STICK TO PLAYER", "StickEnabled")
local bSt = Instance.new("TextButton", BT);
bSt.Size = UDim2.new(1,0,0,32); bSt.Text = "STICK KEY: "..NS.StickBind; bSt.BackgroundColor3 = ButtonDark; bSt.TextColor3 = Accent; bSt.Font = FontStyle; bSt.TextSize=14;
bSt.BorderSizePixel = 0; AddStroke(bSt, DarkerOutline)
AddToggle(BT, "SPIN AROUND", "StickSpin"); AddAdjuster(BT, "Spin Speed", "SpinBotSpeed", 2)
AddToggle(BT, "LOOK AT TARGET", "StickLookAt")
AddAdjuster(BT, "Distance", "StickDistance", 1);
AddAdjuster(BT, "Height", "StickHeight", 1)
bSt.MouseButton1Click:Connect(function() bSt.Text="..."; local i=UIS.InputBegan:Wait(); NS.StickBind=i.KeyCode.Name; bSt.Text="STICK KEY: "..NS.StickBind; SaveSettings() end)
local RageSlide = AddToggle(BT, "ENABLE RAGE GUNS", "RageGunsEnabled", true, 160)
if RageSlide then
    AddAdjuster(RageSlide, "Recoil", "Recoil", 0.1, true)
    AddAdjuster(RageSlide, "Spread", "Spread", 0.1, true)
    AddAdjuster(RageSlide, "Proj Speed", "ProjSpeed", 1000, true)
    AddAdjuster(RageSlide, "Cooldown", "Cooldown", 0.05, true)
end
local CustomB = Instance.new("TextButton", ST)
CustomB.Size = UDim2.new(1, 0, 0, 32);
CustomB.Text = CUSTOM_BUTTON_NAME:upper(); CustomB.BackgroundColor3 = Color3.fromRGB(25, 25, 25); CustomB.TextColor3 = Color3.new(1, 1, 1); CustomB.Font = FontStyle; CustomB.TextSize = 14;
CustomB.BorderSizePixel = 0; AddStroke(CustomB, DarkerOutline)
CustomB.MouseButton1Click:Connect(function() CUSTOM_SCRIPT_LOGIC(); UpdateArrayList() end)
local StaffB = Instance.new("TextButton", ST)
StaffB.Size = UDim2.new(1, 0, 0, 32); StaffB.Text = CUSTOM_BUTTON_2_NAME:upper();
StaffB.BackgroundColor3 = Color3.fromRGB(25, 25, 25); StaffB.TextColor3 = Color3.new(1, 1, 1); StaffB.Font = FontStyle; StaffB.TextSize = 14; StaffB.BorderSizePixel = 0;
AddStroke(StaffB, DarkerOutline)
StaffB.MouseButton1Click:Connect(function() CUSTOM_SCRIPT_2_LOGIC(); UpdateArrayList() end)
local SpoofSlide = AddToggle(ST, "DEVICE SPOOFER", "DeviceSpoofer", true, 140)
if SpoofSlide then
    local devices = {"MouseKeyboard", "Gamepad", "Touch", "VR"}
    for _, dev in pairs(devices) do
        local dBtn = Instance.new("TextButton", SpoofSlide);
        dBtn.Size = UDim2.new(1,0,0,30); dBtn.Text = dev; dBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); dBtn.TextColor3 = (NS.SpoofedDevice == dev and Accent or Color3.new(1,1,1));
        dBtn.Font = FontStyle; dBtn.TextSize = 12; dBtn.BorderSizePixel = 0; AddStroke(dBtn, DarkerOutline)
        dBtn.MouseButton1Click:Connect(function()
            ApplyDeviceSpoof(dev)
            for _, child in pairs(SpoofSlide:GetChildren()) do if child:IsA("TextButton") then child.TextColor3 = Color3.new(1,1,1) end end
            dBtn.TextColor3 = Accent
        end)
    end
end
-- [[ NEW SETTINGS SECTION ]]
AddToggle(ST, "NO ARMS", "NoArms") -- New Toggle
local RedeemBtn = Instance.new("TextButton", ST)
RedeemBtn.Size = UDim2.new(1, 0, 0, 32); RedeemBtn.Text = "AUTO REDEEM CODES"; RedeemBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); RedeemBtn.TextColor3 = Accent; RedeemBtn.Font = FontStyle; RedeemBtn.TextSize = 14;
RedeemBtn.BorderSizePixel = 0; AddStroke(RedeemBtn, DarkerOutline)
RedeemBtn.MouseButton1Click:Connect(RedeemCodes)
AddToggle(ST, "SHOW ENABLED LIST", "ShowArrayList")
AddToggle(ST, "MOBILE HIDE BUTTON", "ShowMobileButton")
local DiscB = Instance.new("TextButton", ST);
DiscB.Size = UDim2.new(1,0,0,32); DiscB.Text = "COPY DISCORD"; DiscB.BackgroundColor3 = Color3.fromRGB(25,25,25); DiscB.TextColor3 = Color3.fromRGB(114, 137, 218); DiscB.Font = FontStyle; DiscB.TextSize=14;
DiscB.BorderSizePixel = 0; AddStroke(DiscB, Color3.fromRGB(40, 45, 60))
DiscB.MouseButton1Click:Connect(function() setclipboard("discord.gg/SEnDae8eBc"); DiscB.Text = "COPIED!"; task.wait(1); DiscB.Text = "COPY DISCORD" end)
local MenuB = Instance.new("TextButton", ST);
MenuB.Size = UDim2.new(1,0,0,32); MenuB.Text = "MENU KEY: "..NS.MenuBind; MenuB.BackgroundColor3 = ButtonDark; MenuB.TextColor3 = Accent; MenuB.Font = FontStyle; MenuB.TextSize=14;
MenuB.BorderSizePixel = 0; AddStroke(MenuB, DarkerOutline)
MenuB.MouseButton1Click:Connect(function() MenuB.Text="..."; local i=UIS.InputBegan:Wait(); NS.MenuBind=i.KeyCode.Name; MenuB.Text="MENU KEY: "..NS.MenuBind; SaveSettings() end)
-- [[ GAMEPLAY LOGIC ]]
local function IsVisible(part, character)
    if not NS.WallCheck then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
    return not result or result.Instance:IsDescendantOf(character)
end
local function GetStickTarget()
    local target, closestDist = nil, 9999
    local mousePos = UIS:GetMouseLocation()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
     -- i put double line cuz disabled tm check  --if NS.TeamCheck and v.Team ~= nil and v.Team == LocalPlayer.Team then continue end
            if NS.KatanaCheck and v.Character:FindFirstChild("Katana") then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local mag = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if mag < closestDist then closestDist = mag;
                target = v.Character.HumanoidRootPart end
        end
    end
    return target
end
local function GetClosestTarget()
    local target, closestDist = nil, NS.FOVSize
    local mousePos = UIS:GetMouseLocation()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if NS.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if NS.KatanaCheck and v.Character:FindFirstChild("Katana") then continue end
            local part = nil
            if NS.AimPart == "Closest" then
                local minPartDist = 9999
                for _, child in pairs(v.Character:GetChildren()) do
                    if child:IsA("BasePart") then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(child.Position)
                        if onScreen then
                            local mag = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if mag < minPartDist then minPartDist = mag;
                                part = child end
                        end
                    end
                end
            else part = v.Character:FindFirstChild(NS.AimPart) end
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if mag < closestDist and IsVisible(part, v.Character) then closestDist = mag;
                        target = part end
                end
            end
        end
    end
    return target
end
task.spawn(function()
    while true do
        task.wait(0.05)
        if NS.TriggerBot then
            local target = LocalPlayer:GetMouse().Target
            if target and target.Parent:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(target.Parent)
                if player and player ~= LocalPlayer then
                    if not (NS.TeamCheck and player.Team == LocalPlayer.Team) then
                        mouse1click()
                    end
                end
            end
        end
    end
end)
RunService.RenderStepped:Connect(function()
    local mouse = UIS:GetMouseLocation()
    local mid = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local col = NS.Rainbow and Color3.fromHSV(tick() * (NS.RainbowSpeed/10) % 1, 1, 1) or Accent
    local isMenuOpen = MainHolder.Position.Y.Scale > -0.5
    CustomCursor.Visible = isMenuOpen
    CursorOutline.Visible = isMenuOpen
    CursorTrail.Visible = isMenuOpen
    if isMenuOpen then
        UIS.MouseIconEnabled = false
        CustomCursor.Position = mouse - Vector2.new(3, 3)
        CursorOutline.Position = mouse - Vector2.new(4, 4)
        trailPos = trailPos:Lerp(mouse, 0.15)
        CursorTrail.Position = trailPos + Vector2.new(12, 12)
    else
        UIS.MouseIconEnabled = true
    end
    FOVCircle.Visible = NS.FOVVisible; FOVCircle.Position = mouse; FOVCircle.Radius = NS.FOVSize;
    FOVCircle.Color = col
    WM.Visible = NS.Watermark; WM.Text = "NvHub V2"; WM.Position = mid + Vector2.new(0, 35);
    WM.Color = col; WM.Center = true; WM.Size = 26; WM.Font = 2 
    if NS.CrossSpin then NS.CurrentAngle = (NS.CurrentAngle + NS.CrossSpinSpeed) % 360 end
    for i, v in pairs(CrossLines) do
        local angle = math.rad((NS.CurrentAngle + (i=="T" and 0 or i=="B" and 180 or i=="L" and 90 or 270)))
        v.Visible = NS.Crosshair;
        v.Color = col; v.From = mid + (Vector2.new(math.cos(angle), math.sin(angle)) * 5);
        v.To = mid + (Vector2.new(math.cos(angle), math.sin(angle)) * 15)
    end
    local target = GetClosestTarget()
    if NS.StickEnabled and NS.StickLookAt and NS.StickTarget then
        local head = NS.StickTarget.Parent:FindFirstChild("Head")
        if head then target = head end
    end
    if NS.AimEnabled or (NS.StickEnabled and NS.StickLookAt) then
        if target then
            local isPressed = true
            if not (NS.StickEnabled and NS.StickLookAt) then
                isPressed = pcall(function() return NS.AimBind:find("MouseButton") and UIS:IsMouseButtonPressed(Enum.UserInputType[NS.AimBind]) or UIS:IsKeyDown(Enum.KeyCode[NS.AimBind]) end)
            end
            if isPressed then
                local tPos = Camera:WorldToViewportPoint(target.Position)
                local shX, shY = 0, 0
                if NS.ShakeEnabled then
                    local sV = (NS.ShakeValue * 0.4) ^ 2.2 
                    local t = tick() * 55
                    shX = (math.noise(t, 0) * sV) + (math.random(-sV, sV) * 0.5)
                    shY = (math.noise(0, t) * sV) + (math.random(-sV, sV) * 0.5)
                end
                if NS.Hardlock or (NS.StickEnabled and NS.StickLookAt) then
                    mousemoverel(tPos.X - mouse.X + shX, tPos.Y - mouse.Y + shY)
                else
                    local smooth = (NS.SmoothEnabled) and (NS.SmoothValue) or 0
                    if smooth <= 1 then
                        mousemoverel(tPos.X - mouse.X + shX, tPos.Y - mouse.Y + shY)
                    else
                        local weight = 1 / (math.pow(smooth, 1.8) * 0.02)
                        mousemoverel((tPos.X - mouse.X + shX) * weight, (tPos.Y - mouse.Y + shY) * weight)
                    end
                end
            end
        end
    end
end)
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Hum and NS.JumpEnabled then Hum.UseJumpPower = true;
        Hum.JumpPower = NS.JumpPower end
  if NS.HvHMovement and Root then
        -- We save your real movement velocity
        local actualVelocity = Root.Velocity
        -- We "flicker" a massive velocity offset to confuse the server's lag compensation
        -- This makes your character 'desync' or 'ghost' for others
        Root.Velocity = actualVelocity + Vector3.new(math.random(-250, 250), math.random(-5, 5), math.random(-250, 250))
        -- We immediately reset it on the next internal step so your own movement stays smooth
        RunService.RenderStepped:Wait()
        Root.Velocity = actualVelocity
        -- Slight angle jitter to break headshot tracking for other aimbots
        Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
    end
    if NS.Fly and Root then
        local vel = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel = vel + (Camera.CFrame.LookVector * NS.FlySpeed) end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel = vel - (Camera.CFrame.LookVector * NS.FlySpeed) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel = vel - (Camera.CFrame.RightVector * NS.FlySpeed) end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel = vel + (Camera.CFrame.RightVector * NS.FlySpeed) end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + (Vector3.new(0, 1, 0) * NS.FlySpeed) end
        Root.Velocity = Vector3.new(0,0,0);
        Root.CFrame = Root.CFrame + (vel * RunService.Heartbeat:Wait())
    end
    if NS.StickEnabled and Root then
        if not NS.StickTarget or not NS.StickTarget.Parent or NS.StickTarget.Parent.Humanoid.Health <= 0 then NS.StickTarget = GetStickTarget() end
        if NS.StickTarget then
            local angle = NS.StickSpin and tick() * NS.SpinBotSpeed or 0
            local offset = Vector3.new(math.cos(angle) * NS.StickDistance, NS.StickHeight, math.sin(angle) * NS.StickDistance)
            Root.CFrame = CFrame.new(NS.StickTarget.Position + offset, NS.StickTarget.Position)
            Root.Velocity = Vector3.new(0,0,0)
        end
    else NS.StickTarget = nil end
    if NS.Noclip then for _,v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end
end)
local function ToggleMenu()
    local IsVis = MainHolder.Position.Y.Scale > -0.5
    local TargetPos = IsVis and UDim2.new(0,0,-1.2,0) or UDim2.new(0,0,0,0)
    TweenService:Create(MainHolder, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = TargetPos}):Play()
    TweenService:Create(MenuBlur, TweenInfo.new(0.4), {Size = IsVis and 0 or 20}):Play()
end
MobBtn.MouseButton1Click:Connect(ToggleMenu)
UIS.InputBegan:Connect(function(i,g) 
    if not g then
        if i.KeyCode.Name == NS.FlyBind then NS.Fly = not NS.Fly;
            UpdateArrayList() end
        if i.KeyCode.Name == "J" then 
            NS.StickEnabled = not NS.StickEnabled
            if NS.StickEnabled then NS.StickTarget = GetStickTarget() end
            UpdateArrayList() 
        end
        if i.KeyCode.Name == NS.MenuBind then ToggleMenu() end
    end 
end)
local function CreateESP(plr)
    local Objects = {Box=Drawing.new("Square"), Name=Drawing.new("Text"), Weapon=Drawing.new("Text"), Health=Drawing.new("Line"), Corners={}}
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = CoreGui
    Highlight.Name = "NvCharms_" .. plr.Name
    for i=1,8 do Objects.Corners[i] = Drawing.new("Line");
        Objects.Corners[i].Thickness=1.5 end
    Objects.Name.Center=true; Objects.Name.Outline=true; Objects.Name.Color=Color3.new(1,1,1); Objects.Name.Font=2
    Objects.Weapon.Center=true; Objects.Weapon.Outline=true; Objects.Weapon.Color=Accent; Objects.Weapon.Font=2;
    Objects.Weapon.Size=14 
    Objects.Box.Thickness=1; Objects.Box.Filled=false
    Objects.Health.Thickness=2;
    Objects.Health.Color=Color3.new(0,1,0)
    RunService.RenderStepped:Connect(function()
        local Char = plr.Character
        if Char and Char:FindFirstChild("HumanoidRootPart") and plr ~= LocalPlayer and Char:FindFirstChild("Humanoid") and Char.Humanoid.Health > 0 then
            local hrp = Char.HumanoidRootPart; local pos, on = Camera:WorldToViewportPoint(hrp.Position)
            local col = NS.Rainbow and Color3.fromHSV(tick() * (NS.RainbowSpeed/10) % 1, 1, 1) or Accent
            Highlight.Enabled = NS.CharmsFill or NS.CharmsOutline
            Highlight.Adornee = Char
            Highlight.FillColor = col
            Highlight.FillTransparency = NS.CharmsFill and 0.4 or 1
            Highlight.OutlineColor = Color3.new(1,1,1)
            Highlight.OutlineTransparency = NS.CharmsOutline and 0 or 1
            if on then
                local h = 2500/pos.Z; local w = h/1.5; local bPos = Vector2.new(pos.X-w/2, pos.Y-h/2)
                Objects.Box.Visible = NS.Box;
                Objects.Box.Position = bPos; Objects.Box.Size = Vector2.new(w,h); Objects.Box.Color = col
                Objects.Name.Visible = NS.Names;
                Objects.Name.Position = Vector2.new(pos.X, bPos.Y-15); Objects.Name.Text = plr.Name
                Objects.Health.Visible = NS.Health;
                Objects.Health.From = Vector2.new(bPos.X-5, bPos.Y+h); Objects.Health.To = Vector2.new(bPos.X-5, bPos.Y+(h*(1-Char.Humanoid.Health/Char.Humanoid.MaxHealth)));
                Objects.Health.Color = NS.Rainbow and col or Color3.new(0,1,0)
                local l = w/4
                for _,v in pairs(Objects.Corners) do v.Visible=NS.Corners;
                    v.Color=col end
                Objects.Corners[1].From=bPos; Objects.Corners[1].To=bPos+Vector2.new(l,0); Objects.Corners[2].From=bPos;
                Objects.Corners[2].To=bPos+Vector2.new(0,l)
                Objects.Corners[3].From=bPos+Vector2.new(w,0); Objects.Corners[3].To=bPos+Vector2.new(w-l,0); Objects.Corners[4].From=bPos+Vector2.new(w,0);
                Objects.Corners[4].To=bPos+Vector2.new(w,l)
                Objects.Corners[5].From=bPos+Vector2.new(0,h); Objects.Corners[5].To=bPos+Vector2.new(l,h); Objects.Corners[6].From=bPos+Vector2.new(0,h);
                Objects.Corners[6].To=bPos+Vector2.new(0,h-l)
                Objects.Corners[7].From=bPos+Vector2.new(w,h); Objects.Corners[7].To=bPos+Vector2.new(w-l,h); Objects.Corners[8].From=bPos+Vector2.new(w,h);
                Objects.Corners[8].To=bPos+Vector2.new(w,h-l)
                return
            end
        end
        Highlight.Enabled = false
        Objects.Box.Visible=false;
        Objects.Name.Visible=false; Objects.Weapon.Visible=false; Objects.Health.Visible=false; for _,v in pairs(Objects.Corners) do v.Visible=false end
    end)
end
for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end;
Players.PlayerAdded:Connect(CreateESP)
task.wait(0.5);
TweenService:Create(MainHolder, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
TweenService:Create(MenuBlur, TweenInfo.new(0.4), {Size = 20}):Play()
UpdateArrayList()
end)
