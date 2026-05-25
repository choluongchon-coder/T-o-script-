-- ==========================================================
-- SCRIPT V22 - FIX LỖI "GẦN MÀ KHÔNG NHẶT" | QUÉT CỤC BỘ
-- ==========================================================

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local timeSpent = 0

-- [1] AUTO CHỌN PHE MARINES
spawn(function()
    while not Player.Team do
        task.wait(1)
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines") end)
    end
end)

-- [2] UI V22 (VIỀN ĐỎ + TÊN)
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "HydraDat_V22"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 120)
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 0, 0)

-- [3] HÀM NHẶT RƯƠNG GẦN NHẤT (FIXED)
local function GetClosestChest()
    local closest, minDistance = nil, 5000 -- Bán kính quét 5000 units
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("Part") and (v.Name:find("Chest") or v.Name:find("Box")) and v:FindFirstChild("TouchInterest") then
            local distance = (v.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            if distance < minDistance then
                closest = v
                minDistance = distance
            end
        end
    end
    return closest
end

-- [4] LUỒNG NHẶT RƯƠNG & BOSS (QUÉT CẬN CẢNH)
spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local char = Player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local targetChest = GetClosestChest()
            
            if targetChest then
                -- Dịch chuyển trực tiếp đến vị trí rương
                root.CFrame = targetChest.CFrame
                firetouchinterest(root, targetChest, 0)
                firetouchinterest(root, targetChest, 1)
                timeSpent = 0
            else
                -- Đánh Boss
                local Boss = game.Workspace.Enemies:FindFirstChild("Dough King") or game.Workspace.Enemies:FindFirstChild("Darkbeard")
                if Boss and Boss:FindFirstChild("HumanoidRootPart") then
                    root.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    timeSpent = 0
                else
                    timeSpent = timeSpent + 0.3
                end
            end
        end)
    end
end)

-- [5] HOP SERVER 45S
spawn(function()
    while task.wait(1) do
        if timeSpent >= 45 then
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
