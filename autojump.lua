-- Script by RoopPoofie (Centered GUI + Auto Jump Disabler)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if not player then
    warn("Player not initialized!")
    return
end

-- ================= GUI SECTION =================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- Centered Background Frame
local backgroundFrame = Instance.new("Frame")
backgroundFrame.Parent = screenGui
backgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
backgroundFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
backgroundFrame.Size = UDim2.new(0, 660, 0, 80)
backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backgroundFrame.BackgroundTransparency = 0.7

-- Centered Text Label
local creditText = Instance.new("TextLabel")
creditText.Parent = screenGui
creditText.Text = "Script Made by RoopPoofie"
creditText.Font = Enum.Font.GothamBold
creditText.TextSize = 36
creditText.TextColor3 = Color3.fromRGB(255, 255, 255)
creditText.BackgroundTransparency = 1
creditText.Size = UDim2.new(0, 300, 0, 40)
creditText.AnchorPoint = Vector2.new(0.5, 0.5)
creditText.Position = UDim2.new(0.5, 0, 0.5, 0)
creditText.ZIndex = 2

-- Fade-out Animation
coroutine.wrap(function()
    task.wait(4)
    for i = 1, 10 do
        creditText.TextTransparency = i/10
        backgroundFrame.BackgroundTransparency = 0.7 + (i/10 * 0.3)
        task.wait(0.1)
    end
    screenGui:Destroy()
end)()

-- ============= AUTO JUMP DISABLER ==============
local function disableAutoJump(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.AutoJumpEnabled = false -- Disable automatic jumping

    -- Jump cooldown system
    local jumpCooldown = 0.5
    local canJump = true

    humanoid.JumpRequest:Connect(function()
        if canJump and humanoid.FloorMaterial ~= Enum.Material.Air then
            canJump = false
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(jumpCooldown)
            canJump = true
        end
    end)

    -- Continuously ensure Auto Jump is disabled
    while true do
        task.wait()
        humanoid.AutoJumpEnabled = false
    end
end

-- Desativa AutoJump no personagem atual
local character = player.Character or player.CharacterAdded:Wait()
disableAutoJump(character)

-- Ao resetar (morte ou reset do personagem), ativa novamente
player.CharacterAdded:Connect(function()
    task.wait(0.5) -- Espera o personagem carregar
    disableAutoJump(player.Character)
end)

-- Confirmation notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "SYSTEM",
    Text = "Auto-Jump Disabled\nScript by RoopPoofie",
    Duration = 5,
    Icon = "rbxassetid://6726578264"
})
