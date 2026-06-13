-- =========================================================================
-- SCRIPT: HYDRADAT FIX-DISPLAY (DÙNG PLAYERGUI - HIỆN 100%)
-- =========================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

-- Xóa các bản menu cũ để tránh xung đột
local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("HydraDat_Master") then PlayerGui:FindFirstChild("HydraDat_Master"):Destroy() end

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

_G.NoclipEnabled = false 
_G.PlatformEnabled = false
local PlatformPart = nil
local NPC_Height = 12 

-- Logic cập nhật ván (Giữ nguyên)
local function GetFootPosition(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    local offset = (hum.RigType == Enum.HumanoidRigType.R15) and -3.6 or -3.1
    return hrp.CFrame * CFrame.new(0, offset, 0)
end

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if _G.PlatformEnabled and char then
        if not PlatformPart or not PlatformPart.Parent then
            PlatformPart = Instance.new("Part")
            PlatformPart.Size = Vector3.new(15, 1, 15)
            PlatformPart.Material = Enum.Material.Neon
            PlatformPart.Color = Color3.fromRGB(255, 100, 100)
            PlatformPart.Transparency = 0.5
            PlatformPart.Anchored = true
            PlatformPart.CanCollide = true
            PlatformPart.Parent = Workspace
        end
        local pos = GetFootPosition(char)
        if pos then PlatformPart.CFrame = pos end
    elseif PlatformPart then
        PlatformPart:Destroy() PlatformPart = nil
    end
end)

-- Giao diện mới sử dụng PlayerGui (Chắc chắn hiện)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "HydraDat_Master"
ScreenGui.ResetOnSpawn = false -- Không mất khi chết

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Position = UDim2.new(0, 80, 0, 5); MainToggle.Size = UDim2.new(0, 35, 0, 35)
MainToggle.Text = "OFF"; MainToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainToggle.BorderColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", MainToggle).CornerRadius = UDim.new(0.2, 0)

local ButtonBar = Instance.new("Frame", ScreenGui)
ButtonBar.BackgroundTransparency = 1; ButtonBar.Position = UDim2.new(0, 120, 0, 5); ButtonBar.Size = UDim2.new(0, 200, 0, 35); ButtonBar.Visible = false
Instance.new("UIListLayout", ButtonBar).FillDirection = Enum.FillDirection.Horizontal; Instance.new("UIListLayout", ButtonBar).Padding = UDim.new(0, 5)

-- Hàm nút
local function CreateBtn(name, text, callback)
    local btn = Instance.new("TextButton", ButtonBar)
    btn.Size = UDim2.new(0, 35, 0, 35); btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.TextColor3 = Color3.fromRGB(255, 0, 0); btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.2, 0)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

CreateBtn("NC", "NC", function(btn) 
    _G.NoclipEnabled = not _G.NoclipEnabled
    local col = _G.NoclipEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    btn.BorderColor3 = col; btn.TextColor3 = col
end)

CreateBtn("UP", "▲", function() 
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, NPC_Height, 0) end
end)

CreateBtn("DOWN", "▼", function() 
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, -NPC_Height, 0) end
end)

CreateBtn("PLAT", "VÁN", function(btn) 
    _G.PlatformEnabled = not _G.PlatformEnabled
    local col = _G.PlatformEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    btn.BorderColor3 = col; btn.TextColor3 = col
end)

MainToggle.MouseButton1Click:Connect(function()
    ButtonBar.Visible = not ButtonBar.Visible
    MainToggle.Text = ButtonBar.Visible and "ON" or "OFF"
    MainToggle.TextColor3 = ButtonBar.Visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    MainToggle.BorderColor3 = MainToggle.TextColor3
end)
 
