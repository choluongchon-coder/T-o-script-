-- =========================================================================
-- SCRIPT: HYDRADAT MINI - FIX LỖI TỤT VÁN KHI XUỐNG
-- =========================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

_G.NoclipEnabled = false 
_G.PlatformEnabled = false
local PlatformPart = nil
local NPC_Height = 12 

-------------------------------------------------------------------
-- HÀM ÉP VỊ TRÍ VÁN (CỐ ĐỊNH CHÂN)
-------------------------------------------------------------------
local function ForceSyncPlatform()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if _G.PlatformEnabled and hrp then
        if not PlatformPart or not PlatformPart.Parent then
            PlatformPart = Instance.new("Part")
            PlatformPart.Size = Vector3.new(15, 1, 15)
            PlatformPart.Material = Enum.Material.Neon
            PlatformPart.Color = Color3.fromRGB(255, 100, 100)
            PlatformPart.Transparency = 0.6
            PlatformPart.Anchored = true
            PlatformPart.CanCollide = true
            PlatformPart.Parent = Workspace
        end
        -- Dùng CFrame ép thẳng vào tọa độ chân
        PlatformPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
    elseif PlatformPart then
        PlatformPart:Destroy()
        PlatformPart = nil
    end
end

-- Vòng lặp cập nhật liên tục để ván không bao giờ rời chân
RunService.RenderStepped:Connect(ForceSyncPlatform)

RunService.Stepped:Connect(function()
    if _G.NoclipEnabled and player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-------------------------------------------------------------------
-- HÀM DỊCH CHUYỂN (GỌI ĐỒNG BỘ)
-------------------------------------------------------------------
local function MoveStep(direction)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        if direction == "UP" then 
            hrp.CFrame = hrp.CFrame + Vector3.new(0, NPC_Height, 0)
        else
            hrp.CFrame = hrp.CFrame + Vector3.new(0, -NPC_Height, 0)
        end
        -- Ép ván cập nhật ngay lập tức sau lệnh dịch chuyển
        ForceSyncPlatform()
    end
end

-------------------------------------------------------------------
-- GIAO DIỆN (GIỮ NGUYÊN)
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainToggle.Position = UDim2.new(0, 80, 0, 5) 
MainToggle.Size = UDim2.new(0, 35, 0, 35)
MainToggle.Text = "OFF"
MainToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BorderColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", MainToggle).CornerRadius = UDim.new(0.2, 0)

local ButtonBar = Instance.new("Frame", ScreenGui)
ButtonBar.BackgroundTransparency = 1
ButtonBar.Position = UDim2.new(0, 120, 0, 5) 
ButtonBar.Size = UDim2.new(0, 200, 0, 35)
ButtonBar.Visible = false
Instance.new("UIListLayout", ButtonBar).FillDirection = Enum.FillDirection.Horizontal

local function CreateBtn(name, text, callback)
    local btn = Instance.new("TextButton", ButtonBar)
    btn.Name = name
    btn.Size = UDim2.new(0, 35, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.2, 0)
    btn.MouseButton1Click:Connect(callback)
end

CreateBtn("NC", "NC", function() 
    _G.NoclipEnabled = not _G.NoclipEnabled 
end)
CreateBtn("UP", "▲", function() MoveStep("UP") end)
CreateBtn("DOWN", "▼", function() MoveStep("DOWN") end)
CreateBtn("PLAT", "VÁN", function() 
    _G.PlatformEnabled = not _G.PlatformEnabled 
end)

MainToggle.MouseButton1Click:Connect(function()
    ButtonBar.Visible = not ButtonBar.Visible
    MainToggle.Text = ButtonBar.Visible and "ON" or "OFF"
    MainToggle.TextColor3 = ButtonBar.Visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    MainToggle.BorderColor3 = MainToggle.TextColor3
end)
 
