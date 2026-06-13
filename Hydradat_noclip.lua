-- =========================================================================
-- SCRIPT: HYDRADAT MINI (VÁN 7x7 KHÓA CHÂN DI CHUYỂN, STEP x2)
-- =========================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

_G.NoclipEnabled = false 
_G.PlatformEnabled = false
local PlatformPart = nil
local NPC_Height = 12 -- Dịch chuyển x2 tầm 2 NPC

-------------------------------------------------------------------
-- 1. LOGIC NOCLIP & KHÓA VÁN ĐI THEO DƯỚI CHÂN
-------------------------------------------------------------------
RunService.Stepped:Connect(function()
    pcall(function()
        if _G.NoclipEnabled and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end)

-- Vòng lặp khóa ván luôn ở dưới chân kể cả khi bay lên/xuống
RunService.RenderStepped:Connect(function()
    pcall(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if _G.PlatformEnabled and hrp then
            -- Nếu chưa có ván thì tạo mới
            if not PlatformPart or not PlatformPart:IsDescendantOf(Workspace) then
                PlatformPart = Instance.new("Part")
                PlatformPart.Size = Vector3.new(21, 1, 21) -- Kích thước ván 7x7
                PlatformPart.Material = Enum.Material.Neon
                PlatformPart.Color = Color3.fromRGB(255, 100, 100) -- Đỏ nhạt
                PlatformPart.Transparency = 0.6
                PlatformPart.Anchored = true
                PlatformPart.CanCollide = true
                PlatformPart.Parent = Workspace
            end
            -- Khóa chặt ván theo tọa độ nhân vật (luôn ở dưới chân 3.5 block)
            PlatformPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
        else
            -- Nếu tắt thì xóa ván
            if PlatformPart then PlatformPart:Destroy() PlatformPart = nil end
        end
    end)
end)

-- Hàm dịch chuyển lên xuống
local function MoveStep(direction)
    pcall(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if direction == "UP" then 
                hrp.CFrame = hrp.CFrame * CFrame.new(0, NPC_Height, 0)
            elseif direction == "DOWN" then 
                hrp.CFrame = hrp.CFrame * CFrame.new(0, -NPC_Height, 0) 
            end
        end
    end)
end

-------------------------------------------------------------------
-- 2. GIAO DIỆN (GIỮ NGUYÊN VỊ TRÍ GẦN Ô CHAT)
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
ScreenGui.Name = "HydraDat_Mini_Fixed"

local ButtonSize = UDim2.new(0, 35, 0, 35)

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainToggle.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BorderSizePixel = 1
MainToggle.Position = UDim2.new(0, 80, 0, 5) 
MainToggle.Size = ButtonSize
MainToggle.Text = "OFF"
MainToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.Font = Enum.Font.SourceSansBold
MainToggle.TextSize = 13
Instance.new("UICorner", MainToggle).CornerRadius = UDim.new(0.2, 0)

local ButtonBar = Instance.new("Frame", ScreenGui)
ButtonBar.BackgroundTransparency = 1
ButtonBar.Position = UDim2.new(0, 120, 0, 5) 
ButtonBar.Size = UDim2.new(0, 200, 0, 35)
ButtonBar.Visible = false

local ListLayout = Instance.new("UIListLayout", ButtonBar)
ListLayout.FillDirection = Enum.FillDirection.Horizontal
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)

local function CreateMiniButton(name, text, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Name = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    btn.Size = ButtonSize
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.2, 0)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

CreateMiniButton("NC", "NC", ButtonBar, function()
    _G.NoclipEnabled = not _G.NoclipEnabled
    local b = ButtonBar:FindFirstChild("NC")
    b.BorderColor3 = _G.NoclipEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    b.TextColor3 = _G.NoclipEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

CreateMiniButton("UP", "▲", ButtonBar, function() MoveStep("UP") end)
CreateMiniButton("DOWN", "▼", ButtonBar, function() MoveStep("DOWN") end)

CreateMiniButton("PLAT", "VÁN", ButtonBar, function()
    _G.PlatformEnabled = not _G.PlatformEnabled
    local b = ButtonBar:FindFirstChild("PLAT")
    b.BorderColor3 = _G.PlatformEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    b.TextColor3 = _G.PlatformEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

MainToggle.MouseButton1Click:Connect(function()
    ButtonBar.Visible = not ButtonBar.Visible
    MainToggle.Text = ButtonBar.Visible and "ON" or "OFF"
    MainToggle.TextColor3 = ButtonBar.Visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    MainToggle.BorderColor3 = MainToggle.TextColor3
end)
 
