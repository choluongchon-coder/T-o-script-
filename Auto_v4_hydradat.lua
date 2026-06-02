-- =========================================================================
-- SCRIPT: ALL-IN-ONE BLOX FRUIT (SUPER FAST INTERACT FIX)
-- CHỨC NĂNG: Sửa Kill Aura, Auto Bay Đỉnh Cây + Spam Thoại Vào Door & Clock
-- =========================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

-- TỐC ĐỘ 310
_G.TweenSpeed = 310 

-- Trạng thái các nút bấm trên Menu
_G.AutoFarmLvKemBatV4 = false
_G.AutoMuaGear        = false
_G.KillPlay           = false
_G.BayDenDoor         = false
_G.BayDenDongHo       = false
_G.AutoNhiemVuV4      = false
_G.AutoRipIndri       = false 

_G.IsFightingRip      = false 
local CurrentTween = nil

-------------------------------------------------------------------
-- 1. HÀM CÔNG CỤ DI CHUYỂN & CLICK CHUỘT
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
    if CurrentTween then CurrentTween:Cancel() end
    CurrentTween = nil
end

-- Bật xuyên tường liên tục
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        local IsMoving = _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.BayDenDoor or _G.BayDenDongHo or _G.AutoNhiemVuV4 or _G.IsFightingRip
        if IsMoving and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
        end
    end)
end)

-------------------------------------------------------------------
-- 2. LUỒNG FIX LỖI KILL AURA (GIẢ LẬP CLICK SIÊU TỐC - ĐẬP 100% TRÚNG)
-------------------------------------------------------------------
spawn(function()
    while task.wait() do
        if _G.AutoFarmLvKemBatV4 or _G.KillPlay or _G.AutoNhiemVuV4 or _G.IsFightingRip then
            pcall(function()
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                    if folderMobs then
                        for _, v in pairs(folderMobs:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                -- Nếu quái ở trong phạm vi đập tầm gần đến tầm trung
                                if (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < 60 then
                                    EquipMelee()
                                    -- Kích hoạt đập bằng click chuột hệ thống (Bỏ qua Validator chống chặn)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(0,0), camera.CFrame)
                                    
                                    -- Hỗ trợ thêm gói tin phụ tăng sát thương
                                    local tool = char:FindFirstChildOfClass("Tool")
                                    if tool then
                                        ReplicatedStorage.Remotes.Validator:FireServer(tool.Name, v.HumanoidRootPart.Position)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            task.wait(0.3)
        end
    end
end)

local function GetQuestData()
    local lv = player.Data.Level.Value
    local pId = game.PlaceId
    if pId == 7449423635 then 
        if lv >= 2300 then return "CandyRebelQuest", "Candy Rebel", 1, CFrame.new(-1050, 60, -14100)
        elseif lv >= 2225 then return "PeanutQuest", "Peanut Scout", 1, CFrame.new(-2030, 45, -11200)
        else return "IceCreamQuest", "Ice Cream Chef", 1, CFrame.new(-1250, 15, -12500) end
    elseif pId == 4442272160 then 
        if lv >= 1425 then return "ForgottenQuest", "Forgotten Zombie", 1, CFrame.new(-3050, 10, -5600)
        else return "ArcticQuest", "Snow Soldier", 1, CFrame.new(700, 15, -5300) end
    else 
        if lv >= 625 then return "WhisperQuest", "Whisperer", 1, CFrame.new(-4800, 20, 4300)
        else return "BanditQuest", "Bandit", 1, CFrame.new(1100, 10, 1500) end
    end
end

-------------------------------------------------------------------
-- 3. LUỒNG XỬ LÝ CHỨC NĂNG CORE (FIX ĐỈNH CÂY + SIÊU INTERACT)
-------------------------------------------------------------------

-- 7. AUTO RIP INDRA
spawn(function()
    while task.wait(0.2) do
        if _G.AutoRipIndri then
            pcall(function()
                local RipMonster = nil
                local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                if folderMobs then
                    for _, v in pairs(folderMobs:GetChildren()) do
                        if string.find(v.Name, "Rip_Indra") or string.find(v.Name, "Indra") then RipMonster = v break end
                    end
                end

                if RipMonster and RipMonster:FindFirstChild("Humanoid") and RipMonster.Humanoid.Health > 0 and RipMonster:FindFirstChild("HumanoidRootPart") then
                    _G.IsFightingRip = true
                    StopTween()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = RipMonster.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                    end
                else
                    _G.IsFightingRip = false
                end
            end)
        else
            _G.IsFightingRip = false
        end
    end
end)

-- 1. AUTO FARM LEVEL
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
                    if (player.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude < 25 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, questID)
                    end
                    return
                end
                
                local folderMobs = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Monster")
                local MobInZone = nil
                if folderMobs then
                    for _, m in pairs(folderMobs:GetChildren()) do
                        if m.Name == mobName and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                            MobInZone = m break
                        end
                    end
                end
                
                if MobInZone then
                    StopTween()
                    character.HumanoidRootPart.CFrame = MobInZone.HumanoidRootPart.CFrame * CFrame.new(0, 7.5, 0)
                else
                    toTarget(targetCFrame * CFrame.new(0, 25, 0))
                end
            end)
        end
    end
end)

-- 2. AUTO MUA GEAR
spawn(function()
    while task.wait(1) do
        if _G.AutoMuaGear then
            pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeAwakening") end)
        end
    end
end)

-- 3. KILL PLAYER
spawn(function()
    while task.wait(0.1) do
        if _G.KillPlay and not _G.IsFightingRip then
            pcall(function()
                local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then return end
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        StopTween()
                        myHrp.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                    end
                end
            end)
        end
    end
end)

-- 4. FIX: BAY ĐẾN ĐỈNH CÂY + NÓI CHUYỆN SIÊU NHANH VÀO DOOR V4
spawn(function()
    while task.wait(0.2) do
        if _G.BayDenDoor and not _G.IsFightingRip then
            pcall(function()
                -- Tọa độ đỉnh cây cổ thụ (Great Tree) nơi kích hoạt vào đền
                local DinhCayCFrame = CFrame.new(28122, 14920, -34) 
                toTarget(DinhCayCFrame)
                
                -- Khi đã đến đỉnh cây, liên tục gửi lệnh thoại siêu tốc để mở cửa/vào trong
                if (player.Character.HumanoidRootPart.Position - DinhCayCFrame.Position).Magnitude < 30 then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AncientOne", "Dialogue")
                    -- Bypass chọn nhanh dòng thoại
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AncientOne", "Check")
                end
            end)
        end
    end
end)

-- 5. FIX: BAY ĐẾN ĐỒNG HỒ + NÓI CHUYỆN SIÊU NHANH
spawn(function()
    while task.wait(0.2) do
        if _G.BayDenDongHo and not _G.IsFightingRip then
            pcall(function()
                -- Tọa độ phòng Đồng hồ cổ 
                local ClockCFrame = CFrame.new(28115, 15425, -25) 
                toTarget(ClockCFrame)
                
                -- Đến nơi lập tức spam tương tác lấy thông tin đồng hồ siêu tốc
                if (player.Character.HumanoidRootPart.Position - ClockCFrame.Position).Magnitude < 30 then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AncientClock", "Dialogue")
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AncientClock", "Check")
                end
            end)
        end
    end
end)

-- 6. AUTO HOÀN THÀNH NV UP V4
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
                                myHrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 7.5, 0)
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
        end
    end
end)

-------------------------------------------------------------------
-- 4. HỆ THỐNG GIAO DIỆN (GIỮ NGUYÊN MENU TAB)
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
ScreenGui.Name = "HydraDat_TabGUI_V4Fix"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 380)
MainFrame.Active = true

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

CreateFunctionRow("1", "Auto Farm Lv Kèm Bật V4", _G.AutoFarmLvKemBatV4, function(state) _G.AutoFarmLvKemBatV4 = state end)
CreateFunctionRow("2", "Auto Mua Gear", _G.AutoMuaGear, function(state) _G.AutoMuaGear = state end)
CreateFunctionRow("3", "Kill Play", _G.KillPlay, function(state) _G.KillPlay = state end)
CreateFunctionRow("4", "Bay Đến Đỉnh Cây Vào Door", _G.BayDenDoor, function(state) _G.BayDenDoor = state end)
CreateFunctionRow("5", "Bay Đến Phòng Đồng Hồ", _G.BayDenDongHo, function(state) _G.BayDenDongHo = state end)
CreateFunctionRow("6", "Auto Hoàn Thành NV Up V4", _G.AutoNhiemVuV4, function(state) _G.AutoNhiemVuV4 = state end)
CreateFunctionRow("7", "Auto Rip Indra (Ưu tiên)", _G.AutoRipIndri, function(state) _G.AutoRipIndri = state end)
