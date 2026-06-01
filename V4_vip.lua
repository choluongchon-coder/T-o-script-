if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

_G.TweenSpeed = 300 

-- Trạng thái các chức năng
_G.AutoFarmLvKemBatV4 = false
_G.AutoMuaGear        = false
_G.KillPlay           = false
_G.BayDenDoor         = false
_G.BayDenDongHo       = false
_G.AutoNhiemVuV4      = false

-------------------------------------------------------------------
-- 1. HÀM CÔNG CỤ HỖ TRỢ (TWEEN & TRANG BỊ MELEE)
-------------------------------------------------------------------
local function EquipMelee()
    local character = player.Character
    local backpack = player.Backpack
    if not character then return nil end
    
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool and (currentTool:FindFirstChild("Melee") or currentTool.ToolTip == "Melee") then
        return currentTool
    end
    
    for _, tool in pairs(backpack:GetChildren()) do
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
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = distance / _G.TweenSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- Bypass xuyên tường chống kẹt khi di chuyển
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
        end
    end)
end)

-------------------------------------------------------------------
-- 2. LUỒNG QUẢN LÝ CAMERA THÔNG MINH CHO TẤT CẢ CHỨC NĂNG
-- (Chống dìm cam xuống đất nhưng vẫn tự do xoay chuột xung quanh)
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
-- 3. HÀM GOM QUÁI VÀ ĐÁNH BẰNG MELEE X2 TỐC ĐỘ
-------------------------------------------------------------------
local function ThucHienGomQuai(v)
    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
        local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and (myHrp.Position - v.HumanoidRootPart.Position).Magnitude < 150 then
            local meleeTool = EquipMelee()
            if meleeTool then
                for i = 1, 2 do 
                    meleeTool:Activate()
                    ReplicatedStorage.Remotes.Validator:FireServer(meleeTool.Name, v.HumanoidRootPart.Position)
                end
            end
        end
    end
end

spawn(function()
    while task.wait() do
        pcall(function()
            if Workspace:FindFirstChild("Enemies") then
                for _, v in pairs(Workspace.Enemies:GetChildren()) do ThucHienGomQuai(v) end
            end
            if Workspace:FindFirstChild("Monster") then
                for _, v in pairs(Workspace.Monster:GetChildren()) do ThucHienGomQuai(v) end
            end
        end)
    end
end)

-------------------------------------------------------------------
-- 4. LUỒNG XỬ LÝ CÁC CHỨC NĂNG CHÍNH (LOGIC GAMEPLAY)
-------------------------------------------------------------------

-- HÀM LẤY DỮ LIỆU NHIỆM VỤ THEO CẤP ĐỘ KHÁC NHAU (3 SEA)
local function GetQuestData()
    local lv = player.Data.Level.Value
    local pId = game.PlaceId
    
    if pId == 7449423635 then 
        if lv >= 2800 then return "CandyRebelQuest", "Candy Rebel", 1, CFrame.new(-1050, 60, -14100)
        elseif lv >= 2725 then return "PeanutQuest", "Peanut Scout", 1, CFrame.new(-2030, 45, -11200)
        else return "IceCreamQuest", "Ice Cream Chef", 1, CFrame.new(-1250, 15, -12500) end
    elseif pId == 4442272160 then
        if lv >= 1425 then return "ForgottenQuest", "Forgotten Zombie", 1, CFrame.new(-3050, 10, -5600)
        else return "ArcticQuest", "Snow Soldier", 1, CFrame.new(700, 15, -5300) end
