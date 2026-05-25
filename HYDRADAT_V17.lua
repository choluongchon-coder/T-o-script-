-- ==========================================================
-- SCRIPT V17 - FULL FIX | SPEED 280 | FAST ATTACK X2
-- ==========================================================

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local timeSpent = 0

-- [1] AUTO MARINES
spawn(function()
    while not Player.Team do
        task.wait(2)
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        end)
    end
end)

-- [2] UI V17
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "HydraDat_V17"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 120)
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "HydraDat V17"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0.3, 0)
StatusLabel.Position = UDim2.new(0, 0, 0.4, 0)
StatusLabel.Text = "Trạng thái: Khởi chạy..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1

-- [3] HÀM FAST ATTACK X2
local function FastAttack()
    pcall(function()
        local Combat = require(Player.PlayerScripts.CombatFramework)
        local Camera = require(Player.PlayerScripts.CombatFramework.CameraShaker)
        Combat.activeController.hitboxMagnitude = 60
        Combat.activeController:attack()
        task.wait(0.1) -- x2 speed
        Combat.activeController:attack()
    end)
end

-- [4] LUỒNG CHÍNH (BOSS, SUMMON, RƯƠNG)
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local char = Player.Character
            local Boss = game.Workspace.Enemies:FindFirstChild("Dough King") or game.Workspace.Enemies:FindFirstChild("Darkbeard")
            
            -- Tự triệu hồi
            if not Boss then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SummonBoss")
            end

            if Boss and Boss:FindFirstChild("HumanoidRootPart") then
                StatusLabel.Text = "Đang diệt Boss (x2 Att)"
                char.HumanoidRootPart.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                FastAttack()
                timeSpent = 0
            else
                -- Nhặt rương
                local chest = nil
                for _, v in pairs(game.Workspace:GetDescendants()) do
                    if v:IsA("Part") and (v.Name == "Chest" or v.Name == "Box") and v:FindFirstChild("TouchInterest") then
                        chest = v; break
                    end
                end

                if chest then
                    StatusLabel.Text = "Đang nhặt rương..."
                    local dist = (chest.Position - char.HumanoidRootPart.Position).Magnitude
                    local tween = TweenService:Create(char.HumanoidRootPart, TweenInfo.new(dist/280), {CFrame = chest.CFrame})
                    tween:Play(); tween.Completed:Wait()
                    firetouchinterest(char.HumanoidRootPart, chest, 0)
                    timeSpent = 0
                else
                    timeSpent = timeSpent + 0.5
                    StatusLabel.Text = "Đang tìm..."
                end
            end
        end)
    end
end)

-- [5] HOP SERVER TỨC THÌ
spawn(function()
    while task.wait(1) do
        if timeSpent >= 40 then
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
