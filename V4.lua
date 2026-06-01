if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

_G.TweenSpeed = 300 

-- Trạng thái mặc định ban đầu (Tắt toàn bộ)
_G.AutoFarmLvKemBatV4 = false
_G.AutoMuaGear        = false
_G.KillPlay           = false
_G.BayDenDoor         = false
_G.BayDenDongHo       = false
_G.AutoNhiemVuV4      = false

local CurrentTween = nil

-------------------------------------------------------------------
-- 1. HÀM HỖ TRỢ DI CHUYỂN & TRANG BỊ VŨ KHÍ MELEE
-------------------------------------------------------------------
local function EquipMelee()
    local character = player.Character
    if not character then return nil end
    
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool and (currentTool:FindFirstChild("Melee") or currentTool.ToolTip == "Melee") then
        return currentTool
    end
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool:FindFirstChild("Melee") or tool.ToolTip == "Melee") then
            tool.Parent = character
            return tool
        end
    end
    return nil
end

local function toTarget(targetCFrame)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    
    if CurrentTween then CurrentTween:Cancel() end

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = distance / _G.TweenSpeed
    
    CurrentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    CurrentTween:Play()
    return CurrentTween
end

local function StopTween()
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
end

-- Bật xuyên tường chống kẹt khi bất kỳ tính năng di chuyển nào đang hoạt động
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        local IsMoving = _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.BayDenDoor or _G.BayDenDongHo or _G.AutoNhiemVuV4
        if IsMoving and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
        end
    end)
end)

-------------------------------------------------------------------
-- 2. HỆ THỐNG KHÓA CAMERA CHỐNG DÌM (TẮT LÀ NHẢ CAM TỰ DO NGAY)
-------------------------------------------------------------------
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local IsAnyFunctionOn = _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.BayDenDoor or _G.BayDenDongHo or _G.AutoNhiemVuV4
            
            if IsAnyFunctionOn then
                camera.CameraType = Enum.CameraType.Custom
                player.CameraMinZoomDistance = 15
                player.CameraMaxZoomDistance = 50
                
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrpPos = player.Character.HumanoidRootPart.Position
                    if camera.CFrame.Position.Y < hrpPos.Y + 5 then
                        camera.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 10, 0), hrpPos)
                    end
                end
            else
                player.CameraMinZoomDistance = 0.5
                player.CameraMaxZoomDistance = 400
            end
        end)
    end
end)

-------------------------------------------------------------------
-- 3. HÀM TỰ ĐỘNG GOM VÀ ĐẤNH QUÁI (GỘP CHUNG)
-------------------------------------------------------------------
local function ThucHienGomQuai(v)
    if not (_G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.AutoNhiemVuV4) then return end
    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
        local myHrp
