-- ==========================================================
-- SCRIPT OPTIMIZED V12: FIX HOP SERVER INSTANT
-- ==========================================================

_G.AutoChest = true
_G.FastAttack = false
local timeSpent = 0
local currentPlaceId = game.PlaceId
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- [0] GIAO DIỆN V12
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "HydraDat_V12"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 330, 0, 200)
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 3

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.15, 0)
Title.Position = UDim2.new(0, 0, 0.05, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Text = "🔥 tiktok:hydradat 🔥"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22

local SubTitle = Instance.new("TextLabel", MainFrame)
SubTitle.Size = UDim2.new(1, 0, 0.1, 0)
SubTitle.Position = UDim2.new(0, 0, 0.22, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.SourceSansBold
SubTitle.Text = "v12 fix hop sv"
SubTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
SubTitle.TextSize = 15

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -30, 0.13, 0)
StatusLabel.Position = UDim2.new(0, 15, 0.42, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Text = "Trạng thái: Hoạt động..."

local TimerLabel = Instance.new("TextLabel", MainFrame)
TimerLabel.Size = UDim2.new(1, -30, 0.13, 0)
TimerLabel.Position = UDim2.new(0, 15, 0.74, 0)
TimerLabel.BackgroundTransparency = 1
TimerLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
TimerLabel.Text = "Thời gian: 0s / 40s"

-- [1] HÀM HOP SERVER GỐC
function FastHop()
    StatusLabel.Text = "Trạng thái: 🚀 Đang nhảy server..."
    local url = "https://games.roblox.com/v1/games/" .. currentPlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local response = HttpService:JSONDecode(game:HttpGet(url))
    for _, server in pairs(response.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(currentPlaceId, server.id, game.Players.LocalPlayer)
            break
        end
    end
end

-- [2] LUỒNG CHÍNH
spawn(function()
    while true do
        task.wait(1)
        timeSpent = timeSpent + 1
        TimerLabel.Text = "Thời gian: " .. timeSpent .. "s / 40s"
        
        if timeSpent >= 40 then
            FastHop()
        end
        
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, v in pairs(game.Workspace:GetDescendants()) do
                    if v:IsA("Part") and (string.find(v.Name, "Chest") or string.find(v.Name, "Box")) and v:FindFirstChild("TouchInterest") then
                        timeSpent = 0
                        local hrp = char.HumanoidRootPart
                        local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new((v.Position - hrp.Position).Magnitude / 300), {CFrame = v.CFrame})
                        tween:Play()
                        tween.Completed:Wait()
                        firetouchinterest(hrp, v, 0)
                        firetouchinterest(hrp, v, 1)
                        task.wait(0.5)
                        v:Destroy()
                        break
                    end
                end
            end
        end)
    end
end)
