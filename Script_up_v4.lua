if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
_G.TweenSpeed = 300 

-- Trạng thái các chức năng
_G.AutoFarmLvKemBatV4 = false
_G.AutoMuaGear        = false
_G.KillPlay           = false
_G.BayDenDoor         = false
_G.BayDenDongHo       = false
_G.AutoNhiemVuV4      = false

-------------------------------------------------------------------
-- HÀM HỖ TRỢ DI CHUYỂN & XUYÊN TƯỜNG (BYPASS)
-------------------------------------------------------------------
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

game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
        end
    end)
end)

-------------------------------------------------------------------
-- TẠO GIAO DIỆN THEO THIẾT KẾ MỚI
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "HydraDat_TabGUI"

-- KHUNG CHÍNH NỀN ĐEN VIỀN ĐỎ
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 330)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true -- Mặc định hiện lên khi chạy script

-- NÚT HÌNH VUÔNG 🤑 ĐỂ ẨN / HIỆN MENU
local ToggleMenuButton = Instance.new("TextButton")
ToggleMenuButton.Parent = ScreenGui
ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleMenuButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
ToggleMenuButton.BorderSizePixel = 1
ToggleMenuButton.Position = UDim2.new(0.02, 0, 0.2, 0) -- Nằm góc trái màn hình để bật/tắt menu
ToggleMenuButton.Size = UDim2.new(0, 40, 0, 40)
ToggleMenuButton.Text = "🤑"
ToggleMenuButton.TextSize = 22
ToggleMenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Xử lý ẩn hiện khi ấn nút 🤑
ToggleMenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- PHẦN TÊN Ở TRÊN CÙNG
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleLabel.BorderColor3 = Color3.fromRGB(255, 0, 0)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Text = "tiktok:HYDRADAT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18

-- CỘT DANH MỤC BÊN TRÁI
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

-- KHUNG CHỨA CHỨC NĂNG BÊN PHẢI
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

-- HÀM TẠO DÒNG CÓ NÚT TRÒN (ĐỎ = KO BẬT, XANH = BẬT)
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

    -- Nút tròn bật/tắt (Toggle)
    local ToggleCircle = Instance.new("TextButton")
    ToggleCircle.Parent = RowFrame
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- MẶC ĐỊNH LÀ MÀU ĐỎ (TẮT)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Position = UDim2.new(1, -45, 0.5, -12)
    ToggleCircle.Size = UDim2.new(0, 24, 0, 24)
    ToggleCircle.Text = ""
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0) -- Bo tròn hoàn toàn
    UICorner.Parent = ToggleCircle

    local isToggled = false
    ToggleCircle.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- ĐỔI SANG XANH LÁ (BẬT)
        else
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- QUAY VỀ MÀU ĐỎ (TẮT)
        end
        callback(isToggled)
    end)
end

-------------------------------------------------------------------
-- THIẾT LẬP KẾT NỐI 6 DÒNG CHỨC NĂNG
-------------------------------------------------------------------
CreateFunctionRow("1", "Auto Farm Lv Kèm Bật V4", function(state) _G.AutoFarmLvKemBatV4 = state end)
CreateFunctionRow("2", "Auto Mua Gear", function(state) _G.AutoMuaGear = state end)
CreateFunctionRow("3", "Kill Play", function(state) _G.KillPlay = state end)
CreateFunctionRow("4", "Bay Đến Door", function(state) _G.BayDenDoor = state end)
CreateFunctionRow("5", "Bay Đến Đồng Hồ", function(state) _G.BayDenDongHo = state end)
CreateFunctionRow("6", "Auto Hoàn Thành NV Up V4", function(state) _G.AutoNhiemVuV4 = state end)

-------------------------------------------------------------------
-- LUỒNG XỬ LÝ NGẦM GAMEPLAY
-------------------------------------------------------------------

-- LOGIC 1: AUTO FARM QUÁI (BAY TRÊN ĐẦU + ĐÁNH X2)
spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarmLvKemBatV4 then
            pcall(function()
                if player.Character:FindFirstChild("Awakening") and player.Character.Awakening.Value >= 100 then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                end
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        repeat
                            task.wait()
                            player.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                            for i = 1, 2 do
                                local combatTool = player.Character:FindFirstChildOfClass("Tool")
                                if combatTool then
                                    combatTool:Activate()
                                    game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(combatTool.Name, v.HumanoidRootPart.Position)
                                end
                            end
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), game.Workspace.CurrentCamera.CFrame)
                        until v.Humanoid.Health <= 0 or not _G.AutoFarmLvKemBatV4
                    end
                end
            end)
        end
    end
end)

-- LOGIC 2: TỰ ĐỘNG MUA GEAR
spawn(function()
    while task.wait(1) do
        if _G.AutoMuaGear then
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("UpgradeAwakening")
            end)
        end
    end
end)

-- LOGIC 3: KILL PLAY (BAY TRÊN ĐẦU PLAYER + ĐÁNH X2)
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
                        if (myHrp.Position - targetHrp.Position).Magnitude < 40 and targetHumanoid.Health > 0 then
                            repeat
                                task.wait()
                                myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 7, 0)
                                for i = 1, 2 do 
                                    local combatTool = player.Character:FindFirstChildOfClass("Tool") 
                                    if combatTool then
                                        combatTool:Activate()
                                        game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(combatTool.Name, targetHrp.Position)
                                    end
                                end
                            until targetHumanoid.Health <= 0 or not _G.KillPlay or not p.Character
                        end
                    end
                end
            end)
        end
    end
end)

-- LOGIC 4 & 5: DI CHUYỂN ĐẾN DOOR HOẶC ĐỒNG HỒ
spawn(function()
    while task.wait(0.5) do
        if _G.BayDenDoor then
            pcall(function()
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
        if _G.BayDenDongHo then
            pcall(function()
                local clock = Workspace.Map:FindFirstChild("GreatClock") or Workspace:FindFirstChild("AncientClock")
                if clock then
                    toTarget(clock.CFrame * CFrame.new(0, 5, 0))
                else
                    toTarget(CFrame.new(28122, 14896, -34))
                end
            end)
        end
    end
end)

-- LOGIC 6: TỰ ĐỘNG HOÀN THÀNH NV THEO TỪNG TỘC
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
                    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                            repeat
                                task.wait()
                                myHrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                                for i = 1, 2 do
                                    local tool = player.Character:FindFirstChildOfClass("Tool")
                                    if tool then tool:Activate() game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(tool.Name, mob.HumanoidRootPart.Position) end
                                end
                            until mob.Humanoid.Health <= 0 or not _G.AutoNhiemVuV4
                        end
                    end
                elseif myRace == "Fishman" then
                    myHrp.CFrame = CFrame.new(myHrp.Position.X, 150, myHrp.Position.Z)
                    for _, seaMob in pairs(Workspace.Enemies:GetChildren()) do
                        if string.find(seaMob.Name, "Sea") and seaMob:FindFirstChild("HumanoidRootPart") then
                            local tool = player.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                tool:Activate()
                                local VirtualInputManager = game:GetService("VirtualInputManager")
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                                task.wait(0.1)
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                            end
                        end
                    end
                elseif myRace == "Cyborg" then
                    myHrp.CFrame = CFrame.new(myHrp.Position.X, 15150, myHrp.Position.Z)
                end
            end)
        end
    end
end)
