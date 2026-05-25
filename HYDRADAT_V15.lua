-- ==========================================================
-- SCRIPT V15 - FIX LỖI | GIAO DIỆN CŨ | HOP TỨC THÌ
-- ==========================================================

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local timeSpent = 0

-- [1] TỰ ĐỘNG CHỌN PHE HẢI QUÂN
spawn(function()
    while not Player.Team do
        task.wait(2)
        pcall(function()
            local args = { [1] = "SetTeam", [2] = "Marines" }
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
        end)
    end
end)

-- [2] GIAO DIỆN CŨ (VIỀN ĐỎ)
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "HydraDat_V15"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 120)
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "V15 fix lỗi"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0.3, 0)
StatusLabel.Position = UDim2.new(0, 0, 0.4, 0)
StatusLabel.Text = "Trạng thái: Hoạt động"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1

local TimerLabel = Instance.new("TextLabel", MainFrame)
TimerLabel.Size = UDim2.new(1, 0, 0.3, 0)
TimerLabel.Position = UDim2.new(0, 0, 0.7, 0)
TimerLabel.Text = "Thời gian: 0s"
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
TimerLabel.BackgroundTransparency = 1

-- [3] HÀM BAY TỐC ĐỘ 280
local function SafeFly(targetCFrame)
    pcall(function()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local dist = (targetCFrame.Position - hrp.Position).Magnitude
            local tween = TweenService:Create(hrp, TweenInfo.new(dist / 280, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
            tween:Play()
            tween.Completed:Wait()
        end
    end)
end

-- [4] LUỒNG ĐÁNH BOSS & NHẶT RƯƠNG
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local char = Player.Character
            if not char then return end

            local Boss = game.Workspace.Enemies:FindFirstChild("Dough King") or game.Workspace.Enemies:FindFirstChild("Darkbeard")
            if Boss and Boss:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                timeSpent = 0
                StatusLabel.Text = "Đang đánh Boss"
            else
                local closestChest = nil
                for _, v in pairs(game.Workspace:GetDescendants()) do
                    if v:IsA("Part") and (v.Name == "Chest" or v.Name == "Box") and v:FindFirstChild("TouchInterest") then
                        closestChest = v
                        break
                    end
                end

                if closestChest then
                    StatusLabel.Text = "Đang nhặt rương"
                    SafeFly(closestChest.CFrame)
                    firetouchinterest(char.HumanoidRootPart, closestChest, 0)
                    firetouchinterest(char.HumanoidRootPart, closestChest, 1)
                    timeSpent = 0
                else
                    timeSpent = timeSpent + 0.5
                    StatusLabel.Text = "Đang tìm..."
                end
            end
            TimerLabel.Text = "Thời gian: " .. math.floor(timeSpent) .. "s"
        end)
    end
end)

-- [5] LUỒNG HOP SERVER TỨC THÌ (40S)
spawn(function()
    while task.wait(1) do
        if timeSpent >= 40 then
            StatusLabel.Text = "Đang chuyển Server..."
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            local response = HttpService:JSONDecode(game:HttpGet(url))
            for _, s in pairs(response.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
                    break
                end
            end
        end
    end
end)
