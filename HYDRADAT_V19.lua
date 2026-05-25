-- ==========================================================
-- SCRIPT V19 - FULL FIX | AUTO TRIỆU HỒI BOSS | STATUS FIXED
-- ==========================================================

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local timeSpent = 0

-- [1] AUTO CHỌN PHE HẢI QUÂN
spawn(function()
    while not Player.Team do
        task.wait(1)
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines") end)
    end
end)

-- [2] UI V19 (FIX HIỂN THỊ TRẠNG THÁI)
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "HydraDat_V19"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.3, 0)
Title.Text = "tiktok:hydradat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0.3, 0)
StatusLabel.Position = UDim2.new(0, 0, 0.35, 0)
StatusLabel.Text = "V19: Khởi chạy..."
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.BackgroundTransparency = 1

local TimerLabel = Instance.new("TextLabel", MainFrame)
TimerLabel.Size = UDim2.new(1, 0, 0.3, 0)
TimerLabel.Position = UDim2.new(0, 0, 0.65, 0)
TimerLabel.Text = "Thời gian: 0s / 45s"
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
TimerLabel.BackgroundTransparency = 1

-- [3] LUỒNG CHÍNH: NHẶT RƯƠNG + VẬT PHẨM + TRIỆU HỒI
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local char = Player.Character
            -- Nhặt rương & vật phẩm triệu hồi
            local target = nil
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name:find("Chest") or v.Name:find("Box") or v.Name:find("Chalice")) and v:FindFirstChild("TouchInterest") then
                    target = v; break
                end
            end

            if target then
                StatusLabel.Text = "Đang lấy vật phẩm/rương"
                local dist = (target.Position - char.HumanoidRootPart.Position).Magnitude
                local tween = TweenService:Create(char.HumanoidRootPart, TweenInfo.new(dist/280), {CFrame = target.CFrame})
                tween:Play(); tween.Completed:Wait()
                firetouchinterest(char.HumanoidRootPart, target, 0)
                timeSpent = 0
            else
                -- Kiểm tra triệu hồi Boss
                local Boss = game.Workspace.Enemies:FindFirstChild("Dough King") or game.Workspace.Enemies:FindFirstChild("Darkbeard")
                if not Boss then
                    StatusLabel.Text = "Triệu hồi Boss..."
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("SummonBoss")
                else
                    StatusLabel.Text = "Đang đánh Boss"
                    char.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                end
                timeSpent = timeSpent + 0.5
            end
            TimerLabel.Text = "Thời gian: " .. math.floor(timeSpent) .. "s / 45s"
        end)
    end
end)

-- [4] HOP SERVER 45S
spawn(function()
    while task.wait(1) do
        if timeSpent >= 45 then
            StatusLabel.Text = "Hop Server ngay!"
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
            for _, s in pairs(servers.data) do
                if s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
                    break
                end
            end
        end
    end
end)
