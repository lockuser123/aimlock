local Plrs = game:GetService("Players")
local UISvc = game:GetService("UserInputService")
local RnSvc = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local LP = Plrs.LocalPlayer
local VIMgr = game:GetService("VirtualInputManager")

local KeyAim = Enum.KeyCode.Q
local LockP, LockPart = nil, nil
local Bone = "Head"

local HL = Instance.new("Highlight")
HL.FillColor = Color3.fromRGB(0,0,255)
HL.OutlineColor = Color3.fromRGB(255,255,255)
HL.Parent = workspace
HL.Enabled = false

local TR = Drawing.new("Line")
TR.Color = Color3.fromRGB(0,0,255)
TR.Thickness = 2
TR.Transparency = 1
TR.Visible = false

local LastHealth = {}
local LastHitDamage = 0
local LastHitTime = 0
local DISPLAY_DURATION = 1.8

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "SilentAimDamageDisplay"

local DamageLabel = Instance.new("TextLabel")
DamageLabel.Size = UDim2.new(0,250,0,25)
DamageLabel.Position = UDim2.new(0,10,0,10)
DamageLabel.BackgroundTransparency = 1
DamageLabel.TextColor3 = TR.Color
DamageLabel.TextStrokeTransparency = 0
DamageLabel.TextScaled = false
DamageLabel.Font = Enum.Font.GothamSemibold
DamageLabel.TextSize = 18
DamageLabel.Text = ""
DamageLabel.Parent = ScreenGui

local function IsVisible(Pt)
    local Org = Cam.CFrame.Position
    local Dir = Pt.Position - Org
    local RP = RaycastParams.new()
    RP.FilterDescendantsInstances = {LP.Character}
    RP.FilterType = Enum.RaycastFilterType.Blacklist
    local R = workspace:Raycast(Org, Dir, RP)
    return R and R.Instance:IsDescendantOf(Pt.Parent)
end

local function GetClosestTarget()
    local CPart, CPlr
    local MinDist = math.huge
    local MPos = UISvc:GetMouseLocation()
    for _, Plr in ipairs(Plrs:GetPlayers()) do
        if Plr ~= LP and Plr.Character then
            local Char = Plr.Character
            local Part = Char:FindFirstChild(Bone)
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            if Part and Hum and Hum.Health>5 and IsVisible(Part) then
                local SPos, OnScreen = Cam:WorldToViewportPoint(Part.Position)
                if OnScreen and SPos.Z > 0 then
                    local Dist = (Vector2.new(SPos.X,SPos.Y) - Vector2.new(MPos.X,MPos.Y)).Magnitude
                    if Dist < MinDist then
                        MinDist = Dist
                        CPart = Part
                        CPlr = Plr
                    end
                end
            end
        end
    end
    return CPlr, CPart
end

local function _0x1f(Hum, Plr)
    if Hum then
        LastHealth[Plr] = Hum.Health
        LastHitDamage = 0
        LastHitTime = 0
        Hum.HealthChanged:Connect(function(_0x2a)
            local _0x2b = LastHealth[Plr] or _0x2a
            if _0x2a < _0x2b then
                LastHitDamage = _0x2b - _0x2a
                LastHitTime = tick()
            else
                LastHitDamage = 0
            end
            LastHealth[Plr] = _0x2a
        end)
    end
end

local function LockTarget()
    local TP, TPart = GetClosestTarget()
    if TP and TPart then
        LockP, LockPart = TP, TPart
        HL.Adornee = TPart.Parent
        HL.Enabled = true
        TR.Visible = true

        _0x1f(TP.Character and TP.Character:FindFirstChildOfClass("Humanoid"), TP)
    else
        LockP, LockPart = nil, nil
        HL.Adornee = nil
        HL.Enabled = false
        TR.Visible = false
        LastHitDamage = 0
        LastHitTime = 0
    end
end

UISvc.InputBegan:Connect(function(Input, GameProc)
    if GameProc then return end
    if Input.KeyCode == KeyAim then LockTarget() end
    if Input.UserInputType==Enum.UserInputType.Gamepad1 and Input.KeyCode==Enum.KeyCode.ButtonL3 then
        VIMgr:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.1)
        VIMgr:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end
end)

local mt = getrawmetatable(game)
local OldIndex = mt.__index
setreadonly(mt,false)
mt.__index = function(Self, Key)
    if not checkcaller() and Self == LP:GetMouse() and (Key=="Hit" or Key=="Target") and LockPart then
        return CFrame.new(LockPart.Position)
    end
    return OldIndex(Self, Key)
end
setreadonly(mt,true)

local function _0x2c(P)
    local function _0x2d(Char)
        local NPart = Char:WaitForChild(Bone,5)
        if NPart and P == LockP then
            LockPart = NPart
            HL.Adornee = Char
            HL.Enabled = true
            _0x1f(Char:FindFirstChildOfClass("Humanoid"), P)
        end
    end
    if P.Character then _0x2d(P.Character) end
    P.CharacterAdded:Connect(_0x2d)
end

for _,P in ipairs(Plrs:GetPlayers()) do
    if P ~= LP then _0x2c(P) end
end
Plrs.PlayerAdded:Connect(function(P)
    if P ~= LP then _0x2c(P) end
end)

RnSvc.RenderStepped:Connect(function()
    if LockP and LockPart then
        local MPos = UISvc:GetMouseLocation()
        local TPos, OnScr = Cam:WorldToViewportPoint(LockPart.Position)
        if OnScr and TPos.Z > 0 then
            TR.From = MPos
            TR.To = Vector2.new(TPos.X, TPos.Y)
            TR.Visible = true
        else
            TR.Visible = false
        end
        HL.Enabled = true

        if LastHitDamage > 0 and tick() - LastHitTime <= DISPLAY_DURATION then
            DamageLabel.Text = LockP.DisplayName.." has taken "..math.floor(LastHitDamage).." dmg"
        else
            DamageLabel.Text = ""
        end
    else
        TR.Visible = false
        HL.Enabled = false
        DamageLabel.Text = ""
        LastHitDamage = 0
        LastHitTime = 0
    end
end)
