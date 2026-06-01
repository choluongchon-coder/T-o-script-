if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

_G.TweenSpeed = 300 

-- Trạng thái các chức năng ban đầu
_G.AutoFarmLvKemBatV4 = false
_G.AutoMuaGear        = false
_G.KillPlay           = false
_G.BayDenDoor         = false
_G.BayDenDongHo       = false
_G.AutoNhiemVuV4      = false

-------------------------------------------------------------------
-- 1. HÀM CÔNG CỤ HỖ TRỢ (TWEEN & CHỈ TRANG BỊ MELEE)
-------------------------------------------------------------------
local function EquipMelee()
    local character = player.Character
    local backpack = player.Backpack
    if not character then return nil end
    
    -- Kiểm tra nếu đang cầm sẵn vũ khí Melee
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool and (currentTool:FindFirstChild("Melee") or currentTool.ToolTip == "Melee") then
        return currentTool
    end
    
    -- Nếu đang cầm thứ khác hoặc chưa cầm, tự động tìm và trang bị Melee
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

-- Bypass chống kẹt/xuyên tường khi dịch chuyển farm
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
        end
    end)
end)

-------------------------------------------------------------------
-- 2. LUỒNG QUẢN LÝ CAMERA THÔNG MINH CHO TẤT CẢ CHỨC NĂNG
-- (Chống dìm góc nhìn xuống đất nhưng vẫn cho phép xoay tự tự do)
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
            -- Bắt buộc lôi Melee ra đấm
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
-- 4. LUỒNG XỬ LÝ CÁC LOGIC CHỨC NĂNG CHÍNH
-------------------------------------------------------------------
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
    end
    if lv >= 625 then return "WhisperQuest", "Whisperer", 1, CFrame.new(-4800, 20, 4300)
    else return "BanditQuest", "Bandit", 1, CFrame.new(1100, 10, 1500) end
end

-- LOGIC 1: AUTO FARM LV BẰNG MELEE KÈM BẬT V4
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarmLvKemBatV4 then
            pcall(function()
                EquipMelee()
                local character = player.Character
                if character and character:FindFirstChild("Awakening") and character.Awakening.Value >= 100 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                end
                
                local questName, mobName, questID, targetCFrame = GetQuestData()
                if not player.PlayerGui.Main.Quest.Visible then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, questID)
                    task.wait(0.5)
                end
                
                local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                local HasMob = false
                
                if folderMobs then
                    for _, m in pairs(folderMobs:GetChildren()) do
                        if m.Name == mobName and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                            if m.Humanoid.MaxHealth < 500000 then
                                HasMob = true
                                repeat
                                    task.wait()
                                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                        player.Character.HumanoidRootPart.CFrame = m.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                                    end
                                    game:GetService("VirtualUser"):CaptureController()
                                    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), camera.CFrame)
                                until not m or m.Humanoid.Health <= 0 or not _G.AutoFarmLvKemBatV4
                            end
                        end
                    end
                end
                if not HasMob then toTarget(targetCFrame) end
            end)
        end
    end
end)

-- LOGIC 2: AUTO MUA GEAR TẠI CHỖ TỪ XA (KHÔNG QUAY LẠI NPC)
spawn(function()
    while task.wait(1) do
        if _G.AutoMuaGear then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeAwakening")
            end)
        end
    end
end)

-- LOGIC 3: KILL PLAY
spawn(function()
    while task.wait() do
        if _G.KillPlay then
            pcall(function()
                local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then return end
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                        local targetHrp = p.Character.HumanoidRootPart
                        local targetHumanoid = p.Character.Humanoid
                        if (myHrp.Position - targetHrp.Position).Magnitude < 100 and targetHumanoid.Health > 0 then
                            repeat
                                task.wait()
                                myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 7, 0)
                            until targetHumanoid.Health <= 0 or not _G.KillPlay or not p.Character
                        end
                    end
                end
            end)
        end
    end
end)

-- LOGIC 4: BAY ĐẾN DOOR
spawn(function()
    while task.wait(0.5) do
        if _G.BayDenDoor then
            pcall(function()
                toTarget(CFrame.new(28122, 14896, -34))
                task.wait(0.8)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AncientOne", "Dialogue")
                task.wait(0.5)

                local myRace = player.Data.Race.Value
                local doorFolder = Workspace.Map:FindFirstChild("Trials") or Workspace:FindFirstChild("TrialDoors")
                if doorFolder then
                    for _, door in pairs(doorFolder:GetChildren()) do
                        if string.find(string.lower(door.Name), string.lower(myRace)) then
                            toTarget(door.CFrame * CFrame.new(0, 3, 0))
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- LOGIC 5: BAY ĐẾN ĐỒNG HỒ
spawn(function()
    while task.wait(0.5) do
        if _G.BayDenDongHo then
            pcall(function()
                local clock = Workspace.Map:FindFirstChild("GreatClock") or Workspace:FindFirstChild("AncientClock")
                if clock then
                    toTarget(clock.CFrame * CFrame.new(0, 5, 0))
                else
                    toTarget(CFrame.new(28115, 15410, -25)) 
                end
            end)
        end
    end
end)

-- LOGIC 6: AUTO HOÀN THÀNH NV UP V4 THEO TỘC
spawn(function()
    while task.wait(0.1) do
        if _G.AutoNhiemVuV4 then
            pcall(function()
                local myRace = player.Data.Race.Value
                local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then return end

                if myRace == "Skypia" or myRace == "Mink" then
                    local FinishPoint = Workspace.Map:FindFirstChild("FinishPoint") or Workspace:FindFirstChild("EndTrial")
                    if FinishPoint then toTarget(FinishPoint.CFrame) else toTarget(CFrame.new(28850, 14920, -250)) end
                elseif myRace == "Human" or myRace == "Ghoul" then
                    local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                    if folderMobs then
                        for _, mob in pairs(folderMobs:GetChildren()) do
                            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                                repeat
                                    task.wait()
                                    myHrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                                until mob.Humanoid.Health <= 0 or not _G.AutoNhiemVuV4
                            end
                        end
                    end
                elseif myRace == "Fishman" then
                    myHrp.CFrame = CFrame.new(myHrp.Position.X, 150, myHrp.Position.Z)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                elseif myRace == "Cyborg" then
                    myHrp.CFrame = CFrame.new(myHrp.Position.X, 15150, myHrp.Position.Z)
                end
            end)
        end
    end
end)

-------------------------------------------------------------------
-- 5. GIAO DIỆN MENU HÌNH VUÔNG 🤑 (NÚT TRÒN ĐIỀU KHIỂN)
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "HydraDat_TabGUI"

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 330)
MainFrame.Active = true
MainFrame.Draggable = true

local ToggleMenuButton = Instance.new("TextButton")
ToggleMenuButton.Parent = ScreenGui
ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleMenuButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
ToggleMenuButton.BorderSizePixel = 1
ToggleMenuButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleMenuButton.Size = UDim2.new(0, 40, 0, 40)
ToggleMenuButton.Text = "🤑"
ToggleMenuButton.TextSize = 22
ToggleMenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)

ToggleMenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleLabel.BorderColor3 = Color3.fromRGB(255, 0, 0)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Text = "tiktok:HYDRADAT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18

local LeftPanel = Instance.new("Frame")
LeftPanel.Parent = MainFrame
LeftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LeftPanel.BorderColor3 = Color3.fromRGB(40, 40, 40)
LeftPanel.Position = UDim2.new(0, 0, 0, 35)
LeftPanel.Size = UDim2.new(0, 100, 1, -35)

local TabV4Button = Instance.new("TextButton")
TabV4Button.Parent = LeftPanel
TabV4Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabV4Button.BorderColor3 = Color3.fromRGB(255, 0, 0)
TabV4Button.Size = UDim2.new(1, 0, 1, -35)
TabV4Button.Text = "V4"
TabV4Button.TextColor3 = Color3.fromRGB(255, 255, 255)
TabV4Button.Font = Enum.Font.SourceSansBold
TabV4Button.TextSize = 20

local RightPanel = Instance.new("Frame")
RightPanel.Parent = MainFrame
RightPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
RightPanel.BorderSizePixel = 0
RightPanel.Position = UDim2.new(0, 100, 0, 35)
RightPanel.Size = UDim2.new(1, -100, 1, -35)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = RightPanel
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 0)

local function CreateFunctionRow(numText, nameText, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Parent = RightPanel
    RowFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    RowFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
    RowFrame.Size = UDim2.new(1, 0, 0, 48)

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = RowFrame
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 15, 0, 0)
    TextLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TextLabel.Text = numText .. ". " .. nameText
    TextLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 16
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleCircle = Instance.new("TextButton")
    ToggleCircle.Parent = RowFrame
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Position = UDim2.new(1, -45, 0.5, -12)
    ToggleCircle.Size = UDim2.new(0, 24, 0, 24)
    ToggleCircle.Text = ""
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ToggleCircle

    local isToggled = false
    ToggleCircle.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        callback(isToggled)
    end)
end

-------------------------------------------------------------------
-- KẾT NỐI KHỞI TẠO CÁC NÚT BẤM TRÊN GIAO DIỆN
-------------------------------------------------------------------
CreateFunctionRow("1", "Auto Farm Lv Kèm Bật V4", function(state) _G.AutoFarmLvKemBatV4 = state end)
CreateFunctionRow("2", "Auto Mua Gear", function(state) _G.AutoMuaGear = state end)
CreateFunctionRow("3", "Kill Play", function(state) _G.KillPlay = state end)
CreateFunctionRow("4", "Bay Đến Door", function(state) _G.BayDenDoor = state end)
CreateFunctionRow("5", "Bay Đến Đồng Hồ", function(state) _G.BayDenDongHo = state end)
CreateFunctionRow("6", "Auto Hoàn Thành NV Up V4", function(state) _G.AutoNhiemVuV4 = state end)
