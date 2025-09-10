local pL = game:GetService("Players")
local uIS = game:GetService("UserInputService")
local rS = game:GetService("RunService")
local cam = workspace.CurrentCamera
local lp = pL.LocalPlayer
local vIM = game:GetService("VirtualInputManager")

local saKey = Enum.KeyCode.Q
local lPart, lPlr = nil, nil
local tBone = "Head"


local hl = Instance.new("Highlight")
hl.FillColor = Color3.fromRGB(0, 0, 255)
hl.OutlineColor = Color3.fromRGB(255, 255, 255)
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.Parent = game.CoreGui
hl.Enabled = false


local tr = Drawing.new("Line")
tr.Color = Color3.fromRGB(0, 0, 255)
tr.Thickness = 2
tr.Transparency = 1
tr.Visible = false


local function vis(pt)
    local o = cam.CFrame.Position
    local d = (pt.Position - o)
    local prm = RaycastParams.new()
    prm.FilterDescendantsInstances = {lp.Character}
    prm.FilterType = Enum.RaycastFilterType.Blacklist
    local r = workspace:Raycast(o, d, prm)
    return r and r.Instance:IsDescendantOf(pt.Parent) or true
end


local function gCT()
    local cP, cPl, sD = nil, nil, math.huge
    local mP = uIS:GetMouseLocation()
    for _,pl in ipairs(pL:GetPlayers()) do
        if pl ~= lp and pl.Character then
            local ch = pl.Character
            local pt = ch:FindFirstChild(tBone)
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if pt and hum and hum.Health > 5 and vis(pt) then
                local sP,onS = cam:WorldToViewportPoint(pt.Position)
                if onS then
                    local d = (Vector2.new(sP.X,sP.Y)-Vector2.new(mP.X,mP.Y)).Magnitude
                    if d < sD then
                        sD, cP, cPl = d, pt, pl
                    end
                end
            end
        end
    end
    return cP, cPl
end


local function lSAT()
    local t,pl = gCT()
    if t then
        lPart, lPlr = t, pl
        hl.Adornee, hl.Enabled, tr.Visible = t.Parent, true, true
        print("Locked onto:", pl.Name)
    else
        lPart, lPlr, hl.Adornee, hl.Enabled, tr.Visible = nil,nil,nil,false,false
    end
end


local function sRL(pl)
    pl.CharacterAdded:Connect(function(ch)
        if pl == lPlr then
            task.spawn(function()
                ch:WaitForChild("Humanoid",5)
                ch:WaitForChild(tBone,5)
                lPart = ch:FindFirstChild(tBone)
                hl.Adornee, hl.Enabled, tr.Visible = ch,true,true
                print("Re-locked:", pl.Name)
            end)
        end
    end)
end

for _,pl in ipairs(pL:GetPlayers()) do if pl~=lp then sRL(pl) end end
pL.PlayerAdded:Connect(function(pl) if pl~=lp then sRL(pl) end end)


uIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == saKey then lSAT() end
    if i.UserInputType==Enum.UserInputType.Gamepad1 and i.KeyCode==Enum.KeyCode.ButtonL3 then
        vIM:SendKeyEvent(true,Enum.KeyCode.Q,false,game)
        task.wait(.1)
        vIM:SendKeyEvent(false,Enum.KeyCode.Q,false,game)
    end
end)


local raw = getrawmetatable(game)
local old = raw.__index
setreadonly(raw,false)
raw.__index = function(s,k)
    if not checkcaller() and s==lp:GetMouse() and (k=="Hit" or k=="Target") and lPart then
        return CFrame.new(lPart.Position)
    end
    return old(s,k)
end
setreadonly(raw,true)


rS.RenderStepped:Connect(function()
    if lPlr and lPlr.Character then
        local ch = lPlr.Character
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local bn = ch:FindFirstChild(tBone)
        if hum and hum.Health>0 and bn then
            lPart = bn
            local mP = uIS:GetMouseLocation()
            local tP,onS = cam:WorldToViewportPoint(lPart.Position)
            if onS then
                tr.From,tr.To,tr.Visible = Vector2.new(mP.X,mP.Y),Vector2.new(tP.X,tP.Y),true
                hl.Adornee, hl.Enabled = ch,true
            else tr.Visible=false end
        else tr.Visible=false end
    else tr.Visible=false end
end)
