-- =========================================================================
-- SCRIPT: ALL-IN-ONE BLOX FRUIT (V4 & AUTO RIP INDRA)
-- THÔNG TIN: Tốc độ 310, Khóa Cam Toàn Diện, Giao diện Chống Sập, Nút Gạt Tròn
-- =========================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- CẤU HÌNH TỐC ĐỘ BAY CHUẨN 310
_G.TweenSpeed = 310 

-- Khởi tạo trạng thái tắt hoàn toàn ban đầu
_G.AutoFarmLvKemBatV4 = false
_G.AutoMuaGear        = false
_G.KillPlay           = false
_G.BayDenDoor         = false
_G.BayDenDongHo       = false
_G.AutoNhiemVuV4      = false
_G.AutoRipIndri       = false
_G.IsFightingRip      = false -- Cờ trạng thái ưu tiên đánh Rip

local CurrentTween = nil

-------------------------------------------------------------------
-- 1. HÀM CÔNG CỤ TỐI ƯU (CHỈ MELEE - KHÔNG LẠC VŨ KHÍ KHÁC)
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

-- Vòng lặp Noclip Xuyên tường khi kích hoạt chức năng di chuyển
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        local IsMoving = _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.BayDenDoor or _G.BayDenDongHo or _G.AutoNhiemVuV4 or _G.IsFightingRip
        if IsMoving and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
        end
    end)
end)

-------------------------------------------------------------------
-- 2. LUỒNG KHÓA CAMERA THÔNG MINH (CHỐNG DÌM CHO CẢ 7 CHỨC NĂNG)
-------------------------------------------------------------------
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local IsAnyFunctionOn = _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.BayDenDoor or _G.BayDenDongHo or _G.AutoNhiemVuV4 or _G.IsFightingRip
            
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
-- 3. HÀM GOM QUÁI TỰ ĐỘNG ĐẬP MELEE
-------------------------------------------------------------------
local function ThucHienGomQuai(v)
    if not (_G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.AutoNhiemVuV4 or _G.IsFightingRip) then return end
    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
        local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and (myHrp.Position - v.HumanoidRootPart.Position).Magnitude < 150 then
            local meleeTool = EquipMelee()
            if meleeTool then
                meleeTool:Activate()
                ReplicatedStorage.Remotes.Validator:FireServer(meleeTool.Name, v.HumanoidRootPart.Position)
            end
        end
    end
end

spawn(function()
    while task.wait() do
        if _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.AutoNhiemVuV4 or _G.IsFightingRip then
            pcall(function()
                if Workspace:FindFirstChild("Enemies") then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do ThucHienGomQuai(v) end
                end
                if Workspace:FindFirstChild("Monster") then
                    for _, v in pairs(Workspace.Monster:GetChildren()) do ThucHienGomQuai(v) end
                end
            end)
        else
            task.wait(0.3)
        end
    end
end)

-------------------------------------------------------------------
-- 4. ĐỊNH VỊ BÃI FARM CHUẨN THEO ĐÚNG CẤP ĐỘ CỦA MỖI SEA
-------------------------------------------------------------------
local function GetQuestData()
    local lv = player.Data.Level.Value
    local pId = game.PlaceId
    
    -- SEA 3
    if pId == 7449423635 then 
        if lv >= 2300 then return "CandyRebelQuest", "Candy Rebel", 1, CFrame.new(-1050, 60, -14100)
        elseif lv >= 2225 then return "PeanutQuest", "Peanut Scout", 1, CFrame.new(-2030, 45, -11200)
        else return "IceCreamQuest", "Ice Cream Chef", 1, CFrame.new(-1250, 15, -12500) end
    -- SEA 2
    elseif pId == 4442272160 then
        if lv >= 1425 then return "ForgottenQuest", "Forgotten Zombie", 1, CFrame.new(-3050, 10, -5600)
        else return "ArcticQuest", "Snow Soldier", 1, CFrame.new(700, 15, -5300) end
    -- SEA 1
    else
        if lv >= 625 then return "WhisperQuest", "Whisperer", 1, CFrame.new(-4800, 20, 4300)
        else return "BanditQuest", "Bandit", 1, CFrame.new(1100, 10, 1500) end
    end
end

-------------------------------------------------------------------
-- 5. LUỒNG XỬ LÝ CHỨC NĂNG CORE (CÓ HỆ THỐNG ƯU TIÊN RIP INDRA)
-------------------------------------------------------------------

-- CHỨC NĂNG 7: AUTO RIP INDRI (HÀNG ƯU TIÊN TỐI CAO)
spawn(function()
    while task.wait(0.2) do
        if _G.AutoRipIndri then
            pcall(function()
                local RipMonster = nil
                local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                
                if folderMobs then
                    for _, v in pairs(folderMobs:GetChildren()) do
                        if string.find(v.Name, "Rip_Indra") or string.find(v.Name, "Indra") then
                            RipMonster = v
                            break
                        end
                    end
                end

                if RipMonster and RipMonster:FindFirstChild("Humanoid") and RipMonster.Humanoid.Health > 0 and RipMonster:FindFirstChild("HumanoidRootPart") then
                    _G.IsFightingRip = true -- Bật cờ ngắt các script khác
                    StopTween()
                    
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        -- Bay đứng trên đầu Rip Indra đập Melee
                        player.Character.HumanoidRootPart.CFrame = RipMonster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                        EquipMelee()
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), camera.CFrame)
                    end
                else
                    _G.IsFightingRip = false -- Rip chết hoặc chưa spawn, tắt cờ ưu tiên
                end
            end)
        else
            _G.IsFightingRip = false
        end
    end
end)

-- LOGIC 1: AUTO FARM CHUẨN LV + TỰ BẬT V4 (BỊ NGẮT KHI CÓ RIP)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarmLvKemBatV4 and not _G.IsFightingRip then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                if character:FindFirstChild("Awakening") and character.Awakening.Value >= 100 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                end
                
                local questName, mobName, questID, targetCFrame = GetQuestData()
                
                if not player.PlayerGui.Main.Quest.Visible then
                    StopTween()
                    toTarget(targetCFrame)
                    if (player.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude < 15 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, questID)
                    end
                    return
                end
                
                local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                local MobInZone = nil
                if folderMobs then
                    for _, m in pairs(folderMobs:GetChildren()) do
                        if m.Name == mobName and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                            MobInZone = m
                            break
                        end
                    end
                end
                
                if MobInZone then
                    StopTween()
                    character.HumanoidRootPart.CFrame = MobInZone.HumanoidRootPart.CFrame * CFrame.new(0, 7.5, 0)
                    EquipMelee()
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), camera.CFrame)
                else
                    toTarget(targetCFrame * CFrame.new(0, 30, 0))
                end
            end)
        else
            if not _G.AutoFarmLvKemBatV4 and not _G.IsFightingRip then StopTween() end
        end
    end
end)

-- LOGIC 2: AUTO MUA GEAR TẠI CHỖ
spawn(function()
    while task.wait(1) do
        if _G.AutoMuaGear then
            pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeAwakening") end)
        end
    end
end)

-- LOGIC 3: KILL PLAYER (BỊ NGẮT KHI CÓ RIP)
spawn(function()
    while task.wait(0.1) do
        if _G.KillPlay and not _G.IsFightingRip then
            pcall(function()
                local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then return end
                
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                        local targetHrp = p.Character.HumanoidRootPart
                        local targetHumanoid = p.Character.Humanoid
                        if targetHumanoid.Health > 0 then
                            StopTween()
                            repeat
                                task.wait()
                                if not _G.KillPlay or _G.IsFightingRip or not p.Character then break end
                                myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 7, 0)
                                EquipMelee()
                                game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), camera.CFrame)
                            until targetHumanoid.Health <= 0 or not _G.KillPlay
                        end
                    end
                end
            end)
        else
            if not _G.KillPlay and not _G.IsFightingRip then StopTween() end
        end
    end
end)

-- LOGIC 4: BAY ĐẾN DOOR (BỊ NGẮT KHI CÓ RIP)
spawn(function()
    while task.wait(0.5) do
        if _G.BayDenDoor and not _G.IsFightingRip then
            pcall(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                
                local DoorMainCFrame = CFrame.new(28122, 14920, -34) 
                toTarget(DoorMainCFrame)
                
                task.wait(0.5)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AncientOne", "Dialogue")
                
                local myRace = player.Data.Race.Value
                local doorFolder = Workspace.Main:FindFirstChild("Trials") or Workspace:FindFirstChild("TrialDoors") or Workspace.Map:FindFirstChild("Trials")
                if doorFolder then
                    for _, door in pairs(doorFolder:GetChildren()) do
                        if string.find(string.lower(door.Name), string.lower(myRace)) then
                            toTarget(door.CFrame * CFrame.new(0, 5, 0))
                            break
                        end
                    end
                end
            end)
        else
            if not _G.BayDenDoor and not _G.IsFightingRip then StopTween() end
        end
    end
end)

-- LOGIC 5: BAY ĐẾN ĐỒNG HỒ (BỊ NGẮT KHI CÓ RIP)
spawn(function()
    while task.wait(0.5) do
        if _G.BayDenDongHo and not _G.IsFightingRip then
            pcall(function()
                local clock = Workspace.Map:FindFirstChild("GreatClock") or Workspace:FindFirstChild("AncientClock")
                if clock then
                    toTarget(clock.CFrame * CFrame.new(0, 8, 0))
                else
                    toTarget(CFrame.new(28115, 15425, -25)) 
                end
            end)
        else
            if not _G.BayDenDongHo and not _G.IsFightingRip then StopTween() end
        end
    end
end)

-- LOGIC 6: AUTO HOÀN THÀNH NHIỆM VỤ TỘC V4 (BỊ NGẮT KHI CÓ RIP)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoNhiemVuV4 and not _G.IsFightingRip then
            pcall(function()
                local myRace = player.Data.Race.Value
                local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then return end

                if myRace == "Skypia" or myRace == "Mink" then
                    StopTween()
                    local FinishPoint = Workspace.Map:FindFirstChild("FinishPoint") or Workspace:FindFirstChild("EndTrial")
                    if FinishPoint then toTarget(FinishPoint.CFrame) else toTarget(CFrame.new(28850, 14920, -250)) end
                elseif myRace == "Human" or myRace == "Ghoul" then
                    local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                    if folderMobs then
                        for _, mob in pairs(folderMobs:GetChildren()) do
                            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                                StopTween()
                                repeat
                                    task.wait()
                                    if not _G.AutoNhiemVuV4 or _G.IsFightingRip then break end
                                    myHrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 7.5, 0)
                                    EquipMelee()
                                until mob.Humanoid.Health <= 0 or not _G.AutoNhiemVuV4
                            end
                        end
                    end
                elseif myRace == "Fishman" then
                    StopTween()
                    myHrp.CFrame = CFrame.new(myHrp.Position.X, 150, myHrp.Position.Z)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                elseif myRace == "Cyborg" then
                    StopTween()
                    myHrp.CFrame = CFrame.new(myHrp.Position.X, 15150, myHrp.Position.Z)
                end
            end)
        else
            if not _G.AutoNhiemVuV4 and not _G.IsFightingRip then StopTween() end
        end
    end
end)

-------------------------------------------------------------------
-- 6. HỆ THỐNG GIAO DIỆN MỚI CHỐNG SẬP SCRIPT (LÊN 100%)
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end
ScreenGui.Name = "HydraDat_TabGUI_Fixed100"

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 380) 
MainFrame.Active = true

-- Hệ thống kéo thả GUI mượt mà chống crash
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

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

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0.3, 0)
UICornerBtn.Parent = ToggleMenuButton

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

local function CreateFunctionRow(numText, nameText, initialValue, callback)
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
    ToggleCircle.BackgroundColor3 = initialValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Position = UDim2.new(1, -45, 0.5, -12)
    ToggleCircle.Size = UDim2.new(0, 24, 0, 24)
    ToggleCircle.Text = ""
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ToggleCircle

    local isToggled = initialValue
    ToggleCircle.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            StopTween()
        end
        callback(isToggled)
    end)
end

-------------------------------------------------------------------
-- KHỞI TẠO NÚT BẤM ĐẦY ĐỦ ĐÚNG 7 CHỨC NĂNG
-------------------------------------------------------------------
CreateFunctionRow("1", "Auto Farm Lv Kèm Bật V4", _G.AutoFarmLvKemBatV4, function(state) _G.AutoFarmLvKemBatV4 = state end)
CreateFunctionRow("2", "Auto Mua Gear", _G.AutoMuaGear, function(state) _G.AutoMuaGear = state end)
CreateFunctionRow("3", "Kill Play", _G.KillPlay, function(state) _G.KillPlay = state end)
CreateFunctionRow("4", "Bay Đến Door", _G.BayDenDoor, function(state) _G.BayDenDoor = state end)
CreateFunctionRow("5", "Bay Đến Đồng Hồ", _G.BayDenDongHo, function(state) _G.BayDenDongHo = state end)
CreateFunctionRow("6", "Auto Hoàn Thành NV Up V4", _G.AutoNhiemVuV4, function(state) _G.AutoNhiemVuV4 = state end)
CreateFunctionRow("7", "Auto Rip Indra (Ưu tiên)", _G.AutoRipIndri, function(state) _G.AutoRipIndri = state end)
