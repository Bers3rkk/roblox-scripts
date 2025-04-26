-- SCRIPT "BERS3RK BUTTON" v2.1: Fúria dura 15 segundos

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Bers3rkGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Criar Botão
local button = Instance.new("TextButton")
button.Name = "Bers3rkButton"
button.Parent = screenGui
button.Size = UDim2.new(0, 100, 0, 50)
button.Position = UDim2.new(0.5, -50, 0.8, -25)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.BackgroundTransparency = 0.1
button.BorderSizePixel = 0
button.Text = "Bers3rk"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.Gotham
button.TextScaled = true
button.AutoButtonColor = false
button.ZIndex = 10

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

-- Partículas RGB quadradas
local particleEmitter = Instance.new("ParticleEmitter")
particleEmitter.Texture = "rbxassetid://2592323905"
particleEmitter.Parent = button
particleEmitter.Rate = 10
particleEmitter.Lifetime = NumberRange.new(0.5, 1)
particleEmitter.Speed = NumberRange.new(3,6)
particleEmitter.Size = NumberSequence.new(0.2)
particleEmitter.Transparency = NumberSequence.new(0.5)
particleEmitter.LightEmission = 1
particleEmitter.LockedToPart = true
particleEmitter.VelocitySpread = 180

-- Loop RGB lento
task.spawn(function()
    local t = 0
    while true do
        t += 0.02
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        local color = Color3.fromRGB(r, g, b)
        particleEmitter.Color = ColorSequence.new(color)
        button.TextColor3 = color
        task.wait(0.03)
    end
end)

-- Movimento de Bounce + Pulso variável
task.spawn(function()
    while true do
        local growSize = UDim2.new(0, 110, 0, 55)
        local shrinkSize = UDim2.new(0, 100, 0, 50)

        local growTween = TweenService:Create(button, TweenInfo.new(math.random(1, 2), Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = growSize
        })
        local shrinkTween = TweenService:Create(button, TweenInfo.new(math.random(1, 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = shrinkSize
        })

        growTween:Play()
        growTween.Completed:Wait()
        shrinkTween:Play()
        shrinkTween.Completed:Wait()
    end
end)

-- Botão arrastável
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

-- Função de Desativar AutoJump
local function disableAutoJump()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.AutoJumpEnabled = false

    StarterGui:SetCore("SendNotification", {
        Title = "AutoJump",
        Text = "Auto Jump desativado!",
        Duration = 3
    })
end

-- Fúria
local clickCount = 0
local furyActive = false

-- Cria efeito de fogo
local fireEmitter = Instance.new("ParticleEmitter")
fireEmitter.Parent = button
fireEmitter.Texture = "rbxassetid://4605944955"
fireEmitter.Rate = 0
fireEmitter.Lifetime = NumberRange.new(0.5, 1)
fireEmitter.Speed = NumberRange.new(5, 10)
fireEmitter.Size = NumberSequence.new(0.4)
fireEmitter.LightEmission = 1
fireEmitter.Rotation = NumberRange.new(0, 360)
fireEmitter.VelocitySpread = 360
fireEmitter.Transparency = NumberSequence.new(0.5)

function activateFury()
    if furyActive then return end
    furyActive = true

    StarterGui:SetCore("SendNotification", {
        Title = "BERSERK MODE",
        Text = "Fúria ativada por 15s!",
        Duration = 5
    })

    fireEmitter.Rate = 100

    local furyTween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true), {
        Size = UDim2.new(0, 130, 0, 65),
        BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    })
    furyTween:Play()

    task.delay(15, function()
        furyTween:Cancel()
        fireEmitter.Rate = 0
        button.Size = UDim2.new(0, 100, 0, 50)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        furyActive = false
    end)
end

function countClicks()
    clickCount += 1
    if clickCount >= 5 then
        activateFury()
        clickCount = 0
    end
end

button.MouseButton1Click:Connect(function()
    disableAutoJump()
    countClicks()
end)

-- AutoJump fix quando morrer/resetar
player.CharacterAdded:Connect(function()
    task.wait(1)
    disableAutoJump()
end)

disableAutoJump()
