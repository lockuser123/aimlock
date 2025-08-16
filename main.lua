local a=game:GetService("Players")
local b=game:GetService("UserInputService")
local c=game:GetService("RunService")
local d=workspace.CurrentCamera
local e=a.LocalPlayer
local f=game:GetService("VirtualInputManager")
local g=Enum.KeyCode.Q
local h=nil
local i="Head"
local j=Instance.new("Highlight")
j.FillColor=Color3.fromRGB(0,0,255)
j.OutlineColor=Color3.fromRGB(255,255,255)
j.Parent=workspace
j.Enabled=false
local k=Drawing.new("Line")
k.Color=Color3.fromRGB(0,0,255)
k.Thickness=2
k.Transparency=1
k.Visible=false

local function l(m)
 local n=d.CFrame.Position
 local o=(m.Position-n)
 local p=RaycastParams.new()
 p.FilterDescendantsInstances={e.Character}
 p.FilterType=Enum.RaycastFilterType.Blacklist
 local q=workspace:Raycast(n,o,p)
 if q then
  local r=q.Instance
  return r:IsDescendantOf(m.Parent)
 else return true end
end

local function s()
 local t=nil
 local u=math.huge
 local v=b:GetMouseLocation()
 for _,w in ipairs(a:GetPlayers()) do
  if w~=e and w.Character then
   local x=w.Character
   local y=x:FindFirstChild(i)
   local z=x:FindFirstChildOfClass("Humanoid")
   if y and z and z.Health>5 and l(y) then
    local A,onScreen=d:WorldToViewportPoint(y.Position)
    if onScreen then
     local B=(Vector2.new(A.X,A.Y)-Vector2.new(v.X,v.Y)).Magnitude
     if B<u then
      u=B
      t=y
     end
    end
   end
  end
 end
 return t
end

local function C()
 local D=s()
 if D then
  h=D
  j.Adornee=D.Parent
  j.Enabled=true
  k.Visible=true
  print(""..(D.Parent and D.Parent.Name or"Unknown"))
 else
  h=nil
  j.Adornee=nil
  j.Enabled=false
  k.Visible=false
  print("")
 end
end

b.InputBegan:Connect(function(E,F)
 if F then return end
 if E.KeyCode==g then C() end
 if E.UserInputType==Enum.UserInputType.Gamepad1 and E.KeyCode==Enum.KeyCode.ButtonL3 then
  f:SendKeyEvent(true,g,false,game)
  task.wait(0.1)
  f:SendKeyEvent(false,g,false,game)
 end
end)

local G=getrawmetatable(game)
local H=G.__index
setreadonly(G,false)
G.__index=function(self,key)
 if not checkcaller() and self==e:GetMouse() and (key=="Hit" or key=="Target") and h then
  return CFrame.new(h.Position)
 end
 return H(self,key)
end
setreadonly(G,true)

c.RenderStepped:Connect(function()
 if h then
  local I=b:GetMouseLocation()
  local J,onScreen=d:WorldToViewportPoint(h.Position)
  if onScreen then
   k.From=Vector2.new(I.X,I.Y)
   k.To=Vector2.new(J.X,J.Y)
   k.Visible=true
  else k.Visible=false end
 else k.Visible=false end
end)
