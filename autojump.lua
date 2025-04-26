-- GUI: Bers3rk botão, partículas, bounce, fúria com fogo, pulso variável
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar ScreenGui
local screenGui = playerGui:FindFirstChild("AutoJumpDisablerGui")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoJumpDisablerGui"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
end

-- Criar botão
local button = screenGui:FindFirstChild("DisableJumpButton")
if not button then
    button = Instance.new("TextButton")
    button.Parent = screenGui
    button.Size = UDim2.new(0, 100, 0, 50)
    button.Position = UDim2.new(0.5, -50, 0.5, -25)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = "Bers3rk"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.BackgroundTransparency = 0.1
    button.AutoButtonColor = false
    button.Name = "DisableJumpButton"
    button.ClipsDescendants = true
    button.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
end

-- Restaurar posição salva
local savedX = player:GetAttribute("JumpButtonX")
local savedY = player:GetAttribute("JumpButtonY")
if savedX and savedY then
    button.Position = UDim2.new(0, savedX, 0, savedY)
end

-- Função: desativar AutoJump
local function disableAutoJump()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
    humanoid.AutoJumpEnabled = false

    StarterGui:SetCore("SendNotification", {
        Title = "AutoJump",
        Text = "Auto Jump foi desativado!",
        Duration = 3
    })
end

button.MouseButton1Click:Connect(function()
    disableAutoJump()
    animateClick()
end)

-- Arrastar botão
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    button.Position = newPos
    player:SetAttribute("JumpButtonX", newPos.X.Offset)
    player:SetAttribute("JumpButtonY", newPos.Y.Offset)
end

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Pulso variável + bounce
task.spawn(function()
    while true do
        local growSize = UDim2.new(0, 110, 0, 55)
        local shrinkSize = UDim2.new(0, 100, 0, 50)

        local growTween = TweenService:Create(button, TweenInfo.new(math.random(1, 3), Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = growSize
        })
        local shrinkTween = TweenService:Create(button, TweenInfo.new(math.random(1, 3), Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = shrinkSize
        })

        growTween:Play()
        growTween.Completed:Wait()
        shrinkTween:Play()
        shrinkTween.Completed:Wait()
    end
end)

-- Partículas RGB quadradinhas
local particleEmitter = Instance.new("ParticleEmitter")
particleEmitter.Texture = "rbxassetid://2592323905" -- textura quadrada
particleEmitter.Parent = button
particleEmitter.Rate = 10
particleEmitter.Lifetime = NumberRange.new(0.5, 1)
particleEmitter.Speed = NumberRange.new(3,6)
particleEmitter.Size = NumberSequence.new(0.2)
particleEmitter.Transparency = NumberSequence.new(0.5)
particleEmitter.LightEmission = 1
particleEmitter.LockedToPart = true
particleEmitter.VelocitySpread = 180

task.spawn(function()
    local t = 0
    while true do
        t += 0.02
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        particleEmitter.Color = ColorSequence.new(Color3.fromRGB(r, g, b))
        button.TextColor3 = Color3.fromRGB(r, g, b)
        task.wait(0.03)
    end
end)

-- Cria "fogo" visual
local fireParticles = Instance.new("ParticleEmitter")
fireParticles.Texture = "rbxassetid://284205403 -- textura de fogo
fireParticles.Parent = button
fireParticles.Enabled = false
fireParticles.Lifetime = NumberRange.new(0.5)
fireParticles.Speed = NumberRange.new(5,10)
fireParticles.Rate = 50
fireParticles.Size = NumberSequence.new(0.3)
fireParticles.LightEmission = 1
fireParticles.Transparency = NumberSequence.new(0.3)
fireParticles.Rotation = NumberRange.new(0, 360)
fireParticles.VelocitySpread = 360

-- Modo de Fúria
local clickCount = 0
local furyActive = false

local function activateFury()
    if furyActive then return end
    furyActive = true
    StarterGui:SetCore("SendNotification", {
        Title = "BERSERK MODE",
        Text = "Fúria ativada!",
        Duration = 5
    })
    
    -- Liga fogo
    fireParticles.Enabled = true
    
    local furyTween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true), {
        Size = UDim2.new(0, 130, 0, 65),
        BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    })
    furyTween:Play()
    
    task.wait(5)
    
    furyTween:Cancel()
    button.Size = UDim2.new(0, 100, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    fireParticles.Enabled = false
    furyActive = false
end

function animateClick()
    clickCount += 1
    if clickCount >= 5 then
        activateFury()
        clickCount = 0
    end
end

-- AutoJump também quando morrer/resetar
player.CharacterAdded:Connect(function()
    task.wait(1)
    disableAutoJump()
end)

disableAutoJump()
