-- GUI: Bolinha moderna, arrastável, com ícone de pulo e AutoJump disabler persistente
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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

-- Criar ou reutilizar o botão (a bolinha)
local button = screenGui:FindFirstChild("DisableJumpButton")
if not button then
    button = Instance.new("TextButton")
    button.Parent = screenGui
    button.Size = UDim2.new(0, 60, 0, 60)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Preto moderno (cinza escuro)
    button.Text = "⤴" -- Ícone de pulo simples
    button.TextColor3 = Color3.fromRGB(255, 255, 255) -- Branco
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Name = "DisableJumpButton"
    button.BackgroundTransparency = 0.1
    button.ClipsDescendants = true
    button.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
end

-- Restaurar posição anterior, se houver
local savedX = player:GetAttribute("JumpButtonX")
local savedY = player:GetAttribute("JumpButtonY")
if savedX and savedY then
    button.Position = UDim2.new(0, savedX, 0, savedY)
else
    button.Position = UDim2.new(0.5, -30, 0.5, -30)
end

-- Função para desativar AutoJump
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

-- Clique desativa AutoJump
button.MouseButton1Click:Connect(function()
    disableAutoJump()
end)

-- Arrastar com mouse ou toque
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
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Garante que o AutoJump seja desativado após respawn
player.CharacterAdded:Connect(function()
    task.wait(1)
    disableAutoJump()
end)

-- Executa na primeira vez
disableAutoJump()
