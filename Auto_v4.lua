-- =========================================================================
-- SCRIPT: ALL-IN-ONE BLOX FRUIT (FIXED FULL CHỨC NĂNG)
-- ĐẶC TÍNH: Tốc độ 310, Khóa Cam, Sửa lỗi Teleport/Farm, Logic Auto Rip Chuẩn
-- =========================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- CẤU HÌNH TỐC ĐỘ BAY 310
_G.TweenSpeed = 310 

-- Trạng thái các nút bấm trên Menu
_G.AutoFarmLvKemBatV4 = false
_G.AutoMuaGear        = false
_G.KillPlay           = false
_G.BayDenDoor         = false
_G.BayDenDongHo       = false
_G.AutoNhiemVuV4      = false
_G.AutoRipIndri       = false -- Nút số 7: Phải BẬT thì mới kích hoạt cơ chế ưu tiên

-- Biến hệ thống nội bộ
_G.IsFightingRip      = false 
local CurrentTween = nil

-------------------------------------------------------------------
-- 1. HÀM CÔNG CỤ DI CHUYỂN & TRANG BỊ VŨ KHÍ
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

-- Hàm bay mượt sửa lỗi bị kẹt/đơ không di chuyển
local function toTarget(targetCFrame)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    
    if CurrentTween then CurrentTween:Cancel() end

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    -- Nếu khoảng cách quá xa (như qua đảo khác), dịch chuyển thẳng để chống lỗi Tween dìm
    if distance > 3000 then 
        hrp.CFrame = targetCFrame
        task.wait(0.2)
    end
    
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

-- Bật xuyên tường liên tục để không bị kẹt khi đang dùng chức năng
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        local IsMoving = _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.BayDenDoor or _G.BayDenDongHo or _G.AutoNhiemVuV4 or _G.IsFightingRip
        if IsMoving and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
        end
    end)
end)

-------------------------------------------------------------------
-- 2. LUỒNG KHÓA CAMERA TOÀN DIỆN (CHỐNG DÌM CAM)
-------------------------------------------------------------------
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local IsAnyFunctionOn = _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.BayDenDoor or _G.BayDenDongHo or _G.AutoNhiemVuV4 or _G.IsFightingRip
            
            if IsAnyFunctionOn then
                camera.CameraType = Enum.CameraType.Custom
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrpPos = player.Character.HumanoidRootPart.Position
                    if camera.CFrame.Position.Y < hrpPos.Y + 5 then
                        camera.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 12, 0), hrpPos)
                    end
                end
            end
        end)
    end
end)

-------------------------------------------------------------------
-- 3. FIX LỖI KILL AURA ĐẬP QUÁI (TỰ ĐỘNG KÍCH HOẠT KHI FARM VÀ ĐÁNH RIP)
-------------------------------------------------------------------
local function ThucHienGomQuai(v)
    if not (_G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.AutoNhiemVuV4 or _G.IsFightingRip) then return end
    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
        local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and (myHrp.Position - v.HumanoidRootPart.Position).Magnitude < 120 then
            local meleeTool = EquipMelee()
            if meleeTool then
                meleeTool:Activate()
                -- Gửi gói tin đập trực diện lên Server, quái sẽ mất máu 100% không lo lỗi kẹt tool
                ReplicatedStorage.Remotes.Validator:FireServer(meleeTool.Name, v.HumanoidRootPart.Position)
            end
        end
    end
end

spawn(function()
    while task.wait() do
        if _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.AutoNhiemVuV4 or _G.IsFightingRip then
            pcall(function()
                local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                if folderMobs then
                    for _, v in pairs(folderMobs:GetChildren()) do ThucHienGomQuai(v) end
                end
            end)
        else
            task.wait(0.3)
        end
    end
end)

-- Hàm lấy bãi quái chuẩn theo level từng Sea
local function GetQuestData()
    local lv = player.Data.Level.Value
    local pId = game.PlaceId
    if pId == 7449423635 then -- Sea 3
        if lv >= 2300 then return "CandyRebelQuest", "Candy Rebel", 1, CFrame.new(-1050, 60, -14100)
        elseif lv >= 2225 then return "PeanutQuest", "Peanut Scout", 1, CFrame.new(-2030, 45, -11200)
        else return "IceCreamQuest", "Ice Cream Chef", 1, CFrame.new(-1250, 15, -12500) end
    elseif pId == 4442272160 then -- Sea 2
        if lv >= 1425 then return "ForgottenQuest", "Forgotten Zombie", 1, CFrame.new(-3050, 10, -5600)
        else return "ArcticQuest", "Snow Soldier", 1, CFrame.new(700, 15, -5300) end
    else -- Sea 1
        if lv >= 625 then return "WhisperQuest", "Whisperer", 1, CFrame.new(-4800, 20, 4300)
        else return "BanditQuest", "Bandit", 1, CFrame.new(1100, 10, 1500) end
    end
end

-------------------------------------------------------------------
-- 4. LUỒNG XỬ LÝ CHỨC NĂNG CORE (KIỂM TRA NÚT 7 TRƯỚC KHI NGẮT)
-------------------------------------------------------------------

-- NÚT 7: AUTO RIP INDRA (ƯU TIÊN TUYỆT ĐỐI NẾU ĐƯỢC BẬT)
spawn(function()
    while task.wait(0.2) do
        if _G.AutoRipIndri then -- PHẢI BẬT NÚT 7 THÌ MỚI CHẠY LOGIC KIỂM TRA ĐÁNH RIP
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
                    _G.IsFightingRip = true -- Kích hoạt trạng thái chặn các luồng khác
                    StopTween()
                    
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        -- Bay lên đầu Rip Indra đập liên tục
                        player.Character.HumanoidRootPart.CFrame = RipMonster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                        EquipMelee()
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), camera.CFrame)
                    end
                else
                    _G.IsFightingRip = false -- Rip chết hoặc chưa ai gọi ra -> Trả lại quyền chạy cho nút khác
                end
            end)
        else
            _G.IsFightingRip = false -- Nút 7 TẮT -> Tuyệt đối không chặn luồng khác
        end
    end
end)

-- NÚT 1: AUTO FARM LEVEL (FIX LỖI KHÔNG TỰ CHẠY)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarmLvKemBatV4 and not _G.IsFightingRip then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                -- Tự bật tộc V4 khi đầy thanh nộ
                if character:FindFirstChild("Awakening") and character.Awakening.Value >= 100 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                end
                
                local questName, mobName, questID, targetCFrame = GetQuestData()
                
                -- Nhận nhiệm vụ nếu chưa có
                if not player.PlayerGui.Main.Quest.Visible then
                    StopTween()
                    toTarget(targetCFrame)
                    if (player.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude < 25 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, questID)
                    end
                    return
                end
                
                -- Tìm quái để đập
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
                    toTarget(targetCFrame * CFrame.new(0, 25, 0))
                end
            end)
        else
            if not _G.AutoFarmLvKemBatV4 and not _G.IsFightingRip then StopTween() end
        end
    end
end)

-- NÚT 2: AUTO MUA GEAR
spawn(function()
    while task.wait(1) do
        if _G.AutoMuaGear then
            pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeAwakening") end)
        end
    end
end)

-- NÚT 3: KILL PLAYER (CÓ LOGIC NGẮT)
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

-- NÚT 4: BAY ĐẾN DOOR (ĐÃ SỬA TỌA ĐỘ VÀ SỬA LỖI ĐƠ THEO MAP)
spawn(function()
    while task.wait(0.5) do
        if _G.BayDenDoor and not _G.IsFightingRip then
            pcall(function()
                local DoorMainCFrame = CFrame.new(28122, 14920, -34) -- Tọa độ chuẩn Door Đại Hùng Tinh
                toTarget(DoorMainCFrame)
                task.wait(0.2)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AncientOne", "Dialogue")
            end)
        else
            if not _G.BayDenDoor and not _G.IsFightingRip then StopTween() end
        end
    end
end)

-- NÚT 5: BAY ĐẾN ĐỒNG HỒ (ĐÃ FIX TỌA ĐỘ)
spawn(function()
    while task.wait(0.5) do
        if _G.BayDenDongHo and not _G.IsFightingRip then
            pcall(function()
                local ClockCFrame = CFrame.new(28115, 15425, -25) -- Tọa độ chuẩn phòng đồng hồ bí mật
                toTarget(ClockCFrame)
            end)
        else
            if not _G.BayDenDongHo and not _G.IsFightingRip then StopTween() end
        end
    end
end)

-- NÚT 6: AUTO HOÀN THÀNH NV UP V4
spawn(function()
    while task.wait(0.1) do
        if _G.AutoNhiemVuV4 and not _G.IsFightingRip then
            pcall(function()
                local myRace = player.Data.Race.Value
                local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then return end

                if myRace == "Skypia" or myRace == "Mink" then
                    StopTween()
                    toTarget(CFrame.new(28850, 14920, -250))
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
-- 5. HỆ THỐNG GIAO DIỆN KHỞI TẠO MENU (450x380 px)
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local success, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
ScreenGui.Name = "HydraDat_TabGUI_FinalFix"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 380)
MainFrame.Active = true

-- Kéo thả GUI mượt chống sập
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Nút Thu nhỏ/Mở Menu hình tròn 🤑
local ToggleMenuButton = Instance.new("TextButton", ScreenGui)
ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleMenuButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
ToggleMenuButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleMenuButton.Size = UDim2.new(0, 40, 0, 40)
ToggleMenuButton.Text = "🤑"; ToggleMenuButton.TextSize = 22; ToggleMenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ToggleMenuButton).CornerRadius = UDim.new(0.3, 0)
ToggleMenuButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleLabel.BorderColor3 = Color3.fromRGB(255, 0, 0)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Text = "tiktok:HYDRADAT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); TitleLabel.Font = Enum.Font.SourceSansBold; TitleLabel.TextSize = 18

local LeftPanel = Instance.new("Frame", MainFrame)
LeftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20); LeftPanel.BorderColor3 = Color3.fromRGB(40, 40, 40)
LeftPanel.Position = UDim2.new(0, 0, 0, 35); LeftPanel.Size = UDim2.new(0, 100, 1, -35)

local TabV4Button = Instance.new("TextButton", LeftPanel)
TabV4Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35); TabV4Button.BorderColor3 = Color3.fromRGB(255, 0, 0)
TabV4Button.Size = UDim2.new(1, 0, 1, -35); TabV4Button.Text = "V4"; TabV4Button.TextColor3 = Color3.fromRGB(255, 255, 255); TabV4Button.Font = Enum.Font.SourceSansBold; TabV4Button.TextSize = 20

local RightPanel = Instance.new("Frame", MainFrame)
RightPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15); RightPanel.BorderSizePixel = 0
RightPanel.Position = UDim2.new(0, 100, 0, 35); RightPanel.Size = UDim2.new(1, -100, 1, -35)
Instance.new("UIListLayout", RightPanel).SortOrder = Enum.SortOrder.LayoutOrder

-- Hàm tạo dòng gạt nút tròn
local function CreateFunctionRow(numText, nameText, initialValue, callback)
    local RowFrame = Instance.new("Frame", RightPanel)
    RowFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); RowFrame.BorderColor3 = Color3.fromRGB(45, 45, 45); RowFrame.Size = UDim2.new(1, 0, 0, 48)

    local TextLabel = Instance.new("TextLabel", RowFrame)
    TextLabel.BackgroundTransparency = 1; TextLabel.Position = UDim2.new(0, 15, 0, 0); TextLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TextLabel.Text = numText .. ". " .. nameText; TextLabel.TextColor3 = Color3.fromRGB(230, 230, 230); TextLabel.Font = Enum.Font.SourceSans; TextLabel.TextSize = 16; TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleCircle = Instance.new("TextButton", RowFrame)
    ToggleCircle.BackgroundColor3 = initialValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleCircle.BorderSizePixel = 0; ToggleCircle.Position = UDim2.new(1, -45, 0.5, -12); ToggleCircle.Size = UDim2.new(0, 24, 0, 24); ToggleCircle.Text = ""
    Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)

    local isToggled = initialValue
    ToggleCircle.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        ToggleCircle.BackgroundColor3 = isToggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        if not isToggled then StopTween() end
        callback(isToggled)
    end)
end

-------------------------------------------------------------------
-- KHỞI TẠO ĐỦ 7 NÚT BẤM HOÀN CHỈNH
-------------------------------------------------------------------
CreateFunctionRow("1", "Auto Farm Lv Kèm Bật V4", _G.AutoFarmLvKemBatV4, function(state) _G.AutoFarmLvKemBatV4 = state end)
CreateFunctionRow("2", "Auto Mua Gear", _G.AutoMuaGear, function(state) _G.AutoMuaGear = state end)
CreateFunctionRow("3", "Kill Play", _G.KillPlay, function(state) _G.KillPlay = state end)
CreateFunctionRow("4", "Bay Đến Door", _G.BayDenDoor, function(state) _G.BayDenDoor = state end)
CreateFunctionRow("5", "Bay Đến Đồng Hồ", _G.BayDenDongHo, function(state) _G.BayDenDongHo = state end)
CreateFunctionRow("6", "Auto Hoàn Thành NV Up V4", _G.AutoNhiemVuV4, function(state) _G.AutoNhiemVuV4 = state end)
CreateFunctionRow("7", "Auto Rip Indra (Ưu tiên)", _G.AutoRipIndri, function(state) _G.AutoRipIndri = state end)
