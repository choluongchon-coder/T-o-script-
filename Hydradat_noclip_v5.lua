-- =========================================================================
-- SCRIPT: HYDRADAT UNIVERSAL (R6 & R15 AUTO-DETECTION)
-- CHỨC NĂNG: Tự động nhận diện R6/R15, ván 5x5 dính chân, nút đổi màu xanh/đỏ
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
-- 1. HÀM TỰ ĐỘNG TÍNH TOÁN VỊ TRÍ CHÂN CHO CẢ R6 VÀ R15
-------------------------------------------------------------------
local function GetUniversalFootPosition(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return nil end
    
    -- Kiểm tra xem là R15 hay R6 dựa trên kiểu cấu trúc RigType
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        -- Tọa độ chân chuẩn cho R15 (Hạ thấp hơn một chút vì R15 cao hơn)
        return hrp.CFrame * CFrame.new(0, -3.6, 0)
    else
        -- Tọa độ chân chuẩn cho R6
        return hrp.CFrame * CFrame.new(0, -3.1, 0)
    end
end

-------------------------------------------------------------------
-- 2. LOGIC VÒNG LẶP HỆ THỐNG
-------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local char = player.Character
    
    if _G.PlatformEnabled and char then
        if not PlatformPart or not PlatformPart.Parent then
            PlatformPart = Instance.new("Part")
            PlatformPart.Size = Vector3.new(15, 1, 15) -- Kích thước ván gạch 5x5
            PlatformPart.Material = Enum.Material.Neon
            PlatformPart.Color = Color3.fromRGB(255, 100, 100) -- Màu đỏ nhạt
            PlatformPart.Transparency = 0.5
            PlatformPart.Anchored = true
            PlatformPart.CanCollide = true
            PlatformPart.Parent = Workspace
        end
        
        -- Gọi hàm quét tự động R6/R15 để ghim ván đúng chân
        local footPos = GetUniversalFootPosition(char)
        if footPos then
            PlatformPart.CFrame = footPos
        end
    else
        if PlatformPart then PlatformPart:Destroy() PlatformPart = nil end
    end
    
    -- Xử lý Noclip xuyên tường toàn thời gian khi bật
    if _G.NoclipEnabled and char then
        for _, p in pairs(char:GetChildren()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
    end
end)

-- Hàm dịch chuyển lên xuống
local function MoveStep(direction)
    pcall(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if direction == "UP" then 
                hrp.CFrame = hrp.CFrame + Vector3.new(0, NPC_Height, 0)
            elseif direction == "DOWN" then 
                hrp.CFrame = hrp.CFrame + Vector3.new(0, -NPC_Height, 0) 
            end
        end
    end)
end

-------------------------------------------------------------------
-- 3. GIAO DIỆN MINI BUTTONS CẠNH Ô CHAT ROBLOX
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Position = UDim2.new(0, 80, 0, 5); MainToggle.Size = UDim2.new(0, 35, 0, 35)
MainToggle.Text = "OFF"; MainToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainToggle.BorderColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", MainToggle).CornerRadius = UDim.new(0.2, 0)

local ButtonBar = Instance.new("Frame", ScreenGui)
ButtonBar.BackgroundTransparency = 1; ButtonBar.Position = UDim2.new(0, 120, 0, 5); ButtonBar.Size = UDim2.new(0, 200, 0, 35); ButtonBar.Visible = false
local Layout = Instance.new("UIListLayout", ButtonBar)
Layout.FillDirection = Enum.FillDirection.Horizontal; Layout.Padding = UDim.new(0, 5)

-- Hàm cập nhật màu viền/chữ cực chuẩn (Bật = Xanh lá, Tắt = Đỏ)
local function UpdateButtonColor(btn, state)
 
