-- ==========================================================
-- SCRIPT V20 - FIX LỖI NHẶT RƯƠNG (CƯỠNG BỨC CHẠM)
-- ==========================================================

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local timeSpent = 0

-- [1] TỰ CHỌN PHE HẢI QUÂN
spawn(function()
    while not Player.Team do
        task.wait(1)
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines") end)
    end
end)

-- [2] GIAO DIỆN V20
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "HydraDat_V20"
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
StatusLabel.Text = "V20: Đang khởi chạy..."
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.BackgroundTransparency = 1

-- [3] HÀM NHẶT RƯƠNG CƯỠNG BỨC (FIXED)
local function ForceCollectChest()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        -- Tìm các đối tượng có tên là Chest hoặc Box (thường là Model hoặc Part)
        if (v.Name:find("Chest") or v.Name:find("Box")) and v:FindFirstChild("PrimaryPart") or v:IsA("Part") then
            local targetPos = v:IsA("Model") and v.PrimaryPart.Position or v.Position
            
            -- Bay tới rương
            local dist = (targetPos - Player.Character.HumanoidRootPart.Position).Magnitude
            local tween = TweenService:Create(Player.Character.HumanoidRootPart, TweenInfo.new(dist/280), {CFrame = CFrame.new(targetPos)})
            tween:Play(); tween.Completed:Wait()
            
            -- Cưỡng bức chạm nhiều lần
            for i = 1, 5 do
                firetouchinterest(Player.Character.HumanoidRootPart, v:IsA("Model") and v.PrimaryPart or v, 0)
                firetouchinterest(Player.Character.HumanoidRootPart, v:IsA("Model") and v.PrimaryPart or v, 1)
            end
            timeSpent = 0
            return true
        end
    end
    return false
end

-- [4] LUỒNG CHÍNH
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local Boss = game.Workspace.Enemies:FindFirstChild("Dough King") or game.Workspace.Enemies:FindFirstChild("Darkbeard")
            
            if ForceCollectChest() then
                StatusLabel.Text = "Đang nhặt rương..."
            elseif Boss and Boss:FindFirstChild("HumanoidRootPart") then
                StatusLabel.Text = "Đang đánh Boss..."
                Player.Character.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                timeSpent = 0
            else
                StatusLabel.Text = "Tìm rương/boss..."
                timeSpent = timeSpent + 0.5
            end
        end)
    end
end)

-- [5] HOP SERVER 45S
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
