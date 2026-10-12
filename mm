-- Roblox Studio Script: DASKK XX (Player Abilities System)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ==========================================
-- Config / ตั้งค่าคุณสมบัติ
-- ==========================================
local WALK_SPEED = 50       -- ความเร็วการวิ่ง (ปกติ 16)
local JUMP_POWER = 100      -- ความสูงการกระโดด (ปกติ 50)
local FLY_SPEED = 50        -- ความเร็วในการบิน

local isFlying = false
local bodyVelocity = nil
local bodyGyro = nil

-- ==========================================
-- 1. ฟังก์ชันปรับความเร็ว (WalkSpeed)
-- ==========================================
local function setCustomSpeed(speed)
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

-- ==========================================
-- 2. ฟังก์ชันปรับความสูงการกระโดด (JumpPower)
-- ==========================================
local function setCustomJump(power)
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = power
    end
end

-- ==========================================
-- 3. ฟังก์ชันระบบบิน (Fly Mode)
-- ==========================================
local function toggleFly()
    isFlying = not isFlying
    
    if isFlying then
        -- เปิดการบิน: สร้างแรงเคลื่อนที่สภาวะลอยตัว
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = rootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        humanoid.PlatformStand = true -- ปิดท่าทางการเดินปกติ
    else
        -- ปิดการบิน: ลบแรงลอยตัวออก
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        humanoid.PlatformStand = false
    end
end

-- อัปเดตทิศทางการบินตามมุมมองกล้อง
RunService.RenderStepped:Connect(function()
    if isFlying and bodyVelocity and bodyGyro then
        local camera = workspace.CurrentCamera
        bodyGyro.CFrame = camera.CFrame
        
        -- คำนวณทิศทางการเคลื่อนที่จากแป้นพิมพ์ (WASD)
        local moveVector = humanoid.MoveDirection
        if moveVector.Magnitude > 0 then
            bodyVelocity.Velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(moveVector.X, 0, moveVector.Z)) * FLY_SPEED
        else
            bodyVelocity.Velocity = Vector3.zero
        end
    end
end)

-- ==========================================
-- การเรียกใช้งานตัวอย่าง
-- ==========================================

-- สั่งเปิดใช้งานความเร็วและความสูงกระโดด
setCustomSpeed(WALK_SPEED)
setCustomJump(JUMP_POWER)

-- ตัวอย่าง: กดปุ่ม 'F' บนคีย์บอร์ดเพื่อเปิด/ปิดการบิน
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)
