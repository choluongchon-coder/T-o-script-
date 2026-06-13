-- =========================================================================
-- SCRIPT: HYDRADAT STABLE (ANTI-CRASH, MƯỢT, 5x5)
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
-- 1. HÀM CẬP NHẬT TRẠNG THÁI MÀU
-------------------------------------------------------------------
local function UpdateButtonColor(btn, state)
    local color = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    btn.BorderColor3 = color
    btn.TextColor3 = color
end

-------------------------------------------------------------------
-- 2. LOGIC VÁN KHÔNG GÂY VĂNG (CẬP NHẬT TỌA ĐỘ TRỰC TIẾP)
-------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if _G.PlatformEnabled and hrp then
        if not PlatformPart or not PlatformPart.Parent then
            PlatformPart = Instance.new("Part")
            PlatformPart.Size = Vector3.new(15, 1, 15) -- 5x5
            PlatformPart.Material = Enum.Material.Neon
            PlatformPart.Transparency = 0.5
            PlatformPart.Anchored = true -- Giữ Anchored = true để không lỗi vật lý
            PlatformPart.CanCollide = true
            PlatformPart.Parent = Workspace
        end
        -- Cập nhật vị trí tức thời theo chân
        PlatformPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
    else
        if PlatformPart then PlatformPart:Destroy() PlatformPart = nil end
    end
    
    if _G.NoclipEnabled and char then
        for _, p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

-------------------------------------------------------------------
-- 3. GIAO DIỆN CHỐNG LỖI
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Position = UDim2.new(0, 80, 0, 5); MainToggle.Size = UDim2.new(0, 35, 0, 35)
MainToggle.Text = "OFF"; MainToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainToggle.BorderColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", MainToggle).CornerRadius = UDim.new(0.2, 0)

local ButtonBar = Instance.new("Frame", ScreenGui)
ButtonBar.BackgroundTransparency = 1; ButtonBar.Position = UDim2.new(0, 120, 0, 5); ButtonBar.Size = UDim2.new(0, 200, 0, 35); ButtonBar.Visible = false
Instance.new("UIListLayout", ButtonBar).FillDirection = Enum.FillDirection.Horizontal; Instance.new("UIListLayout", ButtonBar).Padding = UDim.new(0, 5)

local function CreateBtn(name, text, callback)
    local btn = Instance.new("TextButton", ButtonBar)
    btn.Name = name; btn.Size = UDim2.new(0, 35, 0, 35); btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.TextColor3 = Color3.fromRGB(255, 0, 0); btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.2, 0)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

CreateBtn("NC", "NC", function(btn) 
    _G.NoclipEnabled = not _G.NoclipEnabled; UpdateButtonColor(btn, _G.NoclipEnabled)
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
    _G.PlatformEnabled = not _G.PlatformEnabled; UpdateButtonColor(btn, _G.PlatformEnabled)
end)

MainToggle.MouseButton1Click:Connect(function()
    ButtonBar.Visible = not ButtonBar.Visible
    MainToggle.Text = ButtonBar.Visible and "ON" or "OFF"
    MainToggle.TextColor3 = ButtonBar.Visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    MainToggle.BorderColor3 = MainToggle.TextColor3
end)
 
