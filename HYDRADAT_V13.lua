-- ==========================================================
-- SCRIPT OPTIMIZED V13: FULL (BOSS + MARINES + FIX HOP)
-- ==========================================================

_G.AutoChest = true
_G.FastAttack = false
local timeSpent = 0
local currentPlaceId = game.PlaceId
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- [0] TỰ CHỌN PHE MARINES
spawn(function()
    pcall(function()
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local main = playerGui:WaitForChild("Main")
        local chooseTeam = main:WaitForChild("ChooseTeam")
        if chooseTeam.Enabled then
            local args = { [1] = "SetTeam", [2] = "Marines" }
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
        end
    end)
end)

-- [1] LUỒNG ĐÁNH BOSS & NHẶT RƯƠNG (FULL LOGIC)
spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            -- ƯU TIÊN ĐÁNH BOSS
            local bossName = (currentPlaceId == 4442272183 and "Darkbeard") or (currentPlaceId == 7449423635 and "Dough King")
            local boss = game.Workspace.Enemies:FindFirstChild(bossName)
            
            if boss and boss:FindFirstChild("HumanoidRootPart") and boss.Humanoid.Health > 0 then
                _G.FastAttack = true
                char.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 5.5, 0)
            else
                _G.FastAttack = false
                -- ĐI TÌM RƯƠNG
                local closest = nil
                local dist = math.huge
                for _, v in pairs(game.Workspace:GetDescendants()) do
                    if v:IsA("Part") and (string.find(v.Name, "Chest") or string.find(v.Name, "Box")) and v:FindFirstChild("TouchInterest") then
                        local mag = (v.Position - char.HumanoidRootPart.Position).Magnitude
                        if mag < dist then dist = mag; closest = v end
                    end
                end
                
                if closest then
                    timeSpent = 0
                    local tween = game:GetService("TweenService"):Create(char.HumanoidRootPart, TweenInfo.new((closest.Position - char.HumanoidRootPart.Position).Magnitude / 300), {CFrame = closest.CFrame})
                    tween:Play()
                    tween.Completed:Wait()
                    firetouchinterest(char.HumanoidRootPart, closest, 0)
                    firetouchinterest(char.HumanoidRootPart, closest, 1)
                    task.wait(0.5)
                    closest:Destroy()
                else
                    timeSpent = timeSpent + 0.1
                end
            end
        end)
    end
end)

-- [2] LUỒNG ĐẾM GIỜ & HOP SERVER
spawn(function()
    while true do
        task.wait(1)
        timeSpent = timeSpent + 1
        if timeSpent >= 40 then
            local url = "https://games.roblox.com/v1/games/" .. currentPlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            local response = HttpService:JSONDecode(game:HttpGet(url))
            for _, server in pairs(response.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(currentPlaceId, server.id, game.Players.LocalPlayer)
                    break
                end
            end
        end
    end
end)
