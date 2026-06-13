-- =========================================================================
-- SCRIPT: HYDRADAT MINI BUTTONS (COLOR STATUS SYNC)
-- CHỨC NĂNG: Nút vuông nhỏ cạnh ô Chat, Đỏ = Tắt, Xanh lá = Bật 
-- =========================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Biến trạng thái chức năng
_G.NoclipEnabled = false 
_G.PlatformEnabled = false
local PlatformPart = nil
local NPC_Height = 6 

-------------------------------------------------------------------
-- 1. LOGIC CHỨC NĂNG (NOCLIP & VÁN ĐỎ)
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

RunService.RenderStepped:Connect(function()
    pcall(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if _G.PlatformEnabled and hrp then
            if not PlatformPart or not PlatformPart:IsDescendantOf(Workspace) then
                PlatformPart = Instance.new("Part")
                PlatformPart.Size = Vector3.new(27, 1, 27) -- Ván 9x9
                PlatformPart.Material = Enum.Material.Neon
                PlatformPart.Color = Color3.fromRGB(255, 100, 100) -- Đỏ nhạt
                PlatformPart.Transparency = 0.6
                PlatformPart.Anchored = true
                PlatformPart.CanCollide = true
                PlatformPart.Parent = Workspace
            end
            PlatformPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
        else
            if PlatformPart then PlatformPart:Destroy() PlatformPart = nil end
        end
    end)
end)

local function MoveStep(direction)
    pcall(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if direction == "UP" then hrp.CFrame = hrp.CFrame * CFrame.new(0, NPC_Height, 0)
            elseif direction == "DOWN" then hrp.CFrame = hrp.CFrame * CFrame.new(0, -NPC_Height, 0) end
        end
    end)
end

-------------------------------------------------------------------
-- 2. GIAO DIỆN MINI BUTTONS CẠNH Ô CHAT ROBLOX
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
ScreenGui.Name = "HydraDat_MiniMenu_ColorSync"

-- Kích thước ô vuông nhỏ bằng đầu nhân vật (35x35 pixel)
local ButtonSize = UDim2.new(0, 35, 0, 35)

-- NÚT CHÍNH: ON / OFF (Cạnh ô chat)
local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainToggle.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Đỏ lúc chưa mở
MainToggle.BorderSizePixel = 1
MainToggle.Position = UDim2.new(0, 80, 0, 5) 
MainToggle.Size = ButtonSize
MainToggle.Text = "OFF"
MainToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.Font = Enum.Font.SourceSansBold
MainToggle.TextSize = 13
Instance.new("UICorner", MainToggle).CornerRadius = UDim.new(0.2, 0)

-- THANH CHỨA CÁC NÚT CHỨC NĂNG
local ButtonBar = Instance.new("Frame", ScreenGui)
ButtonBar.BackgroundTransparency = 1
ButtonBar.Position = UDim2.new(0, 120, 0, 5) 
ButtonBar.Size = UDim2.new(0, 200, 0, 35)
ButtonBar.Visible = false

local ListLayout = Instance.new("UIListLayout", ButtonBar)
ListLayout.FillDirection = Enum.FillDirection.Horizontal
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)

-- Hàm tạo nhanh các nút vuông nhỏ với màu đồng bộ trạng thái
local function CreateMiniButton(name, text, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Name = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Mặc định chưa bật = Đỏ
    btn.Size = ButtonSize
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 0, 0) -- Mặc định chưa bật = Chữ đỏ
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.2, 0)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 1. Nút Noclip (NC)
local NcBtn = CreateMiniButton("NC", "NC", ButtonBar, function()
    _G.NoclipEnabled = not _G.NoclipEnabled
    local btn = ButtonBar:FindFirstChild("NC")
    if _G.NoclipEnabled then
        btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- 2. Nút Bay Lên (▲) - Vì đây là nút nhấn phát ăn ngay chứ không giữ trạng thái nên để màu đỏ cố định
local UpBtn = CreateMiniButton("UP", "▲", ButtonBar, function()
    MoveStep("UP")
end)

-- 3. Nút Bay Xuống (▼)
local DownBtn = CreateMiniButton("DOWN", "▼", ButtonBar, function()
    MoveStep("DOWN")
end)

-- 4. Nút Ván Đỏ (PLAT)
local PlatBtn = CreateMiniButton("PLAT", "VÁN", ButtonBar, function()
    _G.PlatformEnabled = not _G.PlatformEnabled
    local btn = ButtonBar:FindFirstChild("PLAT")
    if _G.PlatformEnabled then
        btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Xử lý ẩn/hiện menu chính khi bấm nút OFF/ON
MainToggle.MouseButton1Click:Connect(function()
    ButtonBar.Visible = not ButtonBar.Visible
    if ButtonBar.Visible then
        MainToggle.Text = "ON"
        MainToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
        MainToggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
    else
        MainToggle.Text = "OFF"
        MainToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
        MainToggle.BorderColor3 = Color3.fromRGB(255, 0, 0)
    end
end)
 
