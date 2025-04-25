-- GUI: Caveira RGB com borda RGB e brilho leve, arrastável, com animações e AutoJump disabler
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
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
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(0.5, -30, 0.5, -30)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = "☠️"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 0.1
    button.AutoButtonColor = true
    button.Name = "DisableJumpButton"
    button.ClipsDescendants = true
    button.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = button.BorderColor3
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0.25
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = button
end

-- Restaurar posição salva
local savedX = player:GetAttribute("JumpButtonX")
local savedY = player:GetAttribute("JumpButtonY")
if savedX and savedY then
    button.Position = UDim2.new(0, savedX, 0, savedY)
end

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
        Size = UDim2.new(0, 66, 0, 66)
    })
    local backTween = TweenService:Create(button, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 60, 0, 60)
    })
    clickTween:Play()
    clickTween.Completed:Connect(function()
        backTween:Play()
    end)
end

button.MouseButton1Click:Connect(function()
    disableAutoJump()
    animateClick()
end)

-- Animação ao arrastar
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
        Size = UDim2.new(0, 54, 0, 54)
    }):Play()
end

local function endDragEffect()
    TweenService:Create(button, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 60, 0, 60)
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

-- Animação RGB lenta e suave
local stroke = button:FindFirstChildWhichIsA("UIStroke")
task.spawn(function()
    local t = 0
    while true do
        t += 0.01
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        local rgbColor = Color3.fromRGB(r, g, b)
        button.TextColor3 = rgbColor
        button.BorderColor3 = rgbColor
        if stroke then
            stroke.Color = rgbColor
        end
        task.wait(0.03)
    end
end)

-- AutoJump ao renascer
player.CharacterAdded:Connect(function()
    task.wait(1)
    disableAutoJump()
end)

-- Primeira execução
disableAutoJump()
