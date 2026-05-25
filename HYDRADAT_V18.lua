-- ==========================================================
-- SCRIPT V18 FINAL - HẢI QUÂN | 45S HOP | RƯƠNG > BOSS
-- ==========================================================

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local timeSpent = 0

-- [1] AUTO CHỌN PHE HẢI QUÂN (MARINES)
spawn(function()
    while not Player.Team do
        task.wait(1)
        pcall(function() 
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines") 
        end)
    end
end)

-- [2] UI V18 (VIỀN ĐỎ + ĐÚNG TÊN)
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "HydraDat_V18"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 120)
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "tiktok:hydradat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0.3, 0)
StatusLabel.Position = UDim2.new(0, 0, 0.4, 0)
StatusLabel.Text = "Trạng thái: Đang chạy..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1

-- [3] LUỒNG NHẶT RƯƠNG & ĐÁNH BOSS
spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local char = Player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            -- ƯU TIÊN 1: TÌM RƯƠNG
            local closestChest = nil
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name == "Chest" or v.Name == "Box") and v:FindFirstChild("TouchInterest") then
                    closestChest = v; break
                end
            end

            if closestChest then
                StatusLabel.Text = "Nhặt rương..."
                local dist = (closestChest.Position - char.HumanoidRootPart.Position).Magnitude
                local tween = TweenService:Create(char.HumanoidRootPart, TweenInfo.new(dist/280), {CFrame = closestChest.CFrame})
                tween:Play(); tween.Completed:Wait()
                firetouchinterest(char.HumanoidRootPart, closestChest, 0)
                timeSpent = 0
            else
                -- ƯU TIÊN 2: ĐÁNH BOSS
                StatusLabel.Text = "Kiểm tra Boss..."
                local Boss = game.Workspace.Enemies:FindFirstChild("Dough King") or game.Workspace.Enemies:FindFirstChild("Darkbeard")
                if Boss and Boss:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    timeSpent = 0
                else
                    timeSpent = timeSpent + 0.3
                end
            end
        end)
    end
end)

-- [4] HOP SERVER (45 GIÂY)
spawn(function()
    while task.wait(1) do
        if timeSpent >= 45 then
            StatusLabel.Text = "Hop Server..."
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
