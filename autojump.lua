-- GUI: Bers3rk botão, arrastável, RGB no texto, sem borda, pulso suave
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar ou reutilizar a ScreenGui
local screenGui = playerGui:FindFirstChild("AutoJumpDisablerGui")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoJumpDisablerGui"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
end

-- Criar ou reutilizar o botão
local button = screenGui:FindFirstChild("DisableJumpButton")
if not button then
    button = Instance.new("TextButton")
    button.Parent = screenGui
    button.Size = UDim2.new(0, 100, 0, 50) -- 100x50
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

-- Som de clique
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://9118823101"
clickSound.Volume = 0.3
clickSound.Parent = button

-- Função: Desativar AutoJump
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

-- Animação ao clicar
local function animateClick()
    local clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 110, 0, 55)
    })
    local backTween = TweenService:Create(button, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 100, 0, 50)
    })
    clickTween:Play()
    clickTween.Completed:Connect(function()
        backTween:Play()
    end)
end

button.MouseButton1Click:Connect(function()
    disableAutoJump()
    animateClick()
    if clickSound.IsLoaded then
        clickSound:Play()
    else
        clickSound.Loaded:Wait()
        clickSound:Play()
    end
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

local function startDragEffect()
    TweenService:Create(button, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.4,
        Size = UDim2.new(0, 95, 0, 45)
    }):Play()
end

local function endDragEffect()
    TweenService:Create(button, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 100, 0, 50)
    }):Play()
end

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        startDragEffect()

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                endDragEffect()
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

-- Efeito RGB lento no texto "Bers3rk"
task.spawn(function()
    local t = 0
    while true do
        t += 0.01
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        button.TextColor3 = Color3.fromRGB(r, g, b)
        task.wait(0.03)
    end
end)

-- Efeito de brilho ao passar o mouse/dedo
button.MouseEnter:Connect(function()
    TweenService:Create(button, TweenInfo.new(0.25), {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    }):Play()
end)

button.MouseLeave:Connect(function()
    TweenService:Create(button, TweenInfo.new(0.25), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    }):Play()
end)

-- Animação de pulso contínuo
task.spawn(function()
    while true do
        local pulseOut = TweenService:Create(button, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 105, 0, 55)
        })
        local pulseIn = TweenService:Create(button, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 100, 0, 50)
        })
        pulseOut:Play()
        pulseOut.Completed:Wait()
        pulseIn:Play()
        pulseIn.Completed:Wait()
    end
end)

-- AutoJump ao renascer
player.CharacterAdded:Connect(function()
    task.wait(1)
    disableAutoJump()
end)

-- Primeira execução
disableAutoJump()
