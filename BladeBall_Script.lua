-- Blade Ball Script
-- By @leo.zppln
print("[BladeBall] Iniciando...")

local player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

repeat task.wait() until player.Character or player.CharacterAdded:Wait()
task.wait(0.5)

local guiParent = gethui and gethui() or game:GetService("CoreGui")
if not guiParent then guiParent = player:WaitForChild("PlayerGui") end

pcall(function()
    local existing = guiParent:FindFirstChild("BladeBallGui")
    if existing then existing:Destroy() end
    -- Mata GameAnalyzer se estiver aberto pra nao conflitar
    local ga = guiParent:FindFirstChild("GameAnalyzerGui")
    if ga then ga:Destroy() end
end)
task.wait(0.3)

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BladeBallGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 12, 12)
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 380)
MainFrame.BackgroundTransparency = 0.05
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Parent = MainFrame
mainStroke.Color = Color3.fromRGB(180, 40, 40)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Parent = TitleBar
TitleBarFix.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
TitleBarFix.Size = UDim2.new(1, 0, 0, 14)
TitleBarFix.Position = UDim2.new(0, 0, 1, -14)
TitleBarFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -45, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🔴 BladeBall"
Title.TextColor3 = Color3.fromRGB(255, 120, 120)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Active = true

-- Rejoin
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Parent = TitleBar
rejoinBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
rejoinBtn.Position = UDim2.new(1, -36, 0, 6)
rejoinBtn.Size = UDim2.new(0, 30, 0, 30)
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.Text = "R"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.TextSize = 13
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 8)

-- Credit
local creditLabel = Instance.new("TextLabel")
creditLabel.Parent = MainFrame
creditLabel.BackgroundTransparency = 1
creditLabel.Position = UDim2.new(0, 0, 1, -18)
creditLabel.Size = UDim2.new(1, 0, 0, 18)
creditLabel.Font = Enum.Font.GothamSemibold
creditLabel.Text = "By @leo.zppln"
creditLabel.TextColor3 = Color3.fromRGB(180, 80, 80)
creditLabel.TextSize = 13
creditLabel.TextTransparency = 0.2

-- Dragging
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============ BUTTON FACTORY ============
local function createButton(text, position)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(35, 18, 18)
    btn.Position = position
    btn.Size = UDim2.new(0, 145, 0, 32)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(220, 200, 200)
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Parent = btn
    stroke.Color = Color3.fromRGB(70, 35, 35)
    stroke.Thickness = 1
    stroke.Transparency = 0.5

    local indicator = Instance.new("Frame")
    indicator.Parent = btn
    indicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    indicator.Position = UDim2.new(1, -24, 0.5, -6)
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.BorderSizePixel = 0
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local iStroke = Instance.new("UIStroke")
    iStroke.Parent = indicator
    iStroke.Color = Color3.fromRGB(255, 255, 255)
    iStroke.Thickness = 1
    iStroke.Transparency = 0.7

    return btn, indicator
end

local function createKeyBox(text, position)
    local box = Instance.new("TextBox")
    box.Parent = MainFrame
    box.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    box.Position = position
    box.Size = UDim2.new(0, 38, 0, 32)
    box.Font = Enum.Font.GothamBold
    box.Text = text
    box.TextColor3 = Color3.fromRGB(255, 140, 140)
    box.TextSize = 11
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke")
    s.Parent = box
    s.Color = Color3.fromRGB(100, 40, 40)
    s.Thickness = 1
    s.Transparency = 0.5
    return box
end

-- ============ SEPARADORES ============
local function createSeparator(yPos)
    local sep = Instance.new("Frame")
    sep.Parent = MainFrame
    sep.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    sep.Position = UDim2.new(0, 15, 0, yPos)
    sep.Size = UDim2.new(0, 210, 0, 1)
    sep.BorderSizePixel = 0
    sep.BackgroundTransparency = 0.6
    return sep
end

-- ============ SECTION LABELS ============
local function createSectionLabel(text, yPos)
    local label = Instance.new("TextLabel")
    label.Parent = MainFrame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, yPos)
    label.Size = UDim2.new(0, 200, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 100, 100)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

-- ============ BOTOES ============
createSectionLabel("⚔ COMBATE", 48)

local autoParryBtn, autoParryInd = createButton("Auto Parry", UDim2.new(0, 12, 0, 68))
local parryKeyBox = createKeyBox("P", UDim2.new(0, 162, 0, 68))

-- Info label do auto parry
local parryInfoLabel = Instance.new("TextLabel")
parryInfoLabel.Parent = MainFrame
parryInfoLabel.BackgroundTransparency = 1
parryInfoLabel.Position = UDim2.new(0, 14, 0, 104)
parryInfoLabel.Size = UDim2.new(0, 212, 0, 14)
parryInfoLabel.Font = Enum.Font.GothamSemibold
parryInfoLabel.Text = "Auto | Vel:0 Dist:0"
parryInfoLabel.TextColor3 = Color3.fromRGB(200, 160, 160)
parryInfoLabel.TextSize = 10
parryInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

createSeparator(124)
createSectionLabel("🎯 MOVIMENTO", 129)

local clickTpBtn, clickTpInd = createButton("Click TP", UDim2.new(0, 12, 0, 149))
local tpKeyBox = createKeyBox("Q", UDim2.new(0, 162, 0, 149))

local espBtn, espInd = createButton("ESP Players", UDim2.new(0, 12, 0, 189))
local espKeyBox = createKeyBox("J", UDim2.new(0, 162, 0, 189))

createSeparator(229)
createSectionLabel("🛡 UTILIDADES", 234)

local speedBtn, speedInd = createButton("Speed", UDim2.new(0, 12, 0, 254))
local speedBox = createKeyBox("50", UDim2.new(0, 162, 0, 254))

local flyBtn, flyInd = createButton("Fly", UDim2.new(0, 12, 0, 294))
local flyKeyBox = createKeyBox("F", UDim2.new(0, 162, 0, 294))

-- ============ VARIAVEIS ============
local autoParryEnabled = false
local clickTpEnabled = false
local espEnabled = false
local speedEnabled = false
local walkSpeed = 50
local flying = false
local flySpeed = 65
local bodyVelocity, bodyGyro = nil, nil

local parryKey = Enum.KeyCode.P
local tpKey = Enum.KeyCode.Q
local espKey = Enum.KeyCode.J
local flyKey = Enum.KeyCode.F
local toggleKey = Enum.KeyCode.X

-- ============ AUTO PARRY ============
local ANIMATION_DELAY = 0.5 -- tempo entre clicar e o parry efetivamente bater
local PING_EXTRA = 0.05 -- margem extra de seguranca
local lastParryTime = 0
local alreadyParried = false
local prevDist = math.huge

-- Cache dos remotes do Blade Ball
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
local parryButtonPress = Remotes and Remotes:FindFirstChild("ParryButtonPress")
local parryAttempt = Remotes and Remotes:FindFirstChild("ParryAttempt")
local Stats = game:GetService("Stats")

local function getPing()
    -- Ping em segundos (Stats.Network.ServerStatsItem["Data Ping"] em ms)
    local ok, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    if ok and ping then return ping end
    -- Fallback: tenta player:GetNetworkPing()
    local ok2, p2 = pcall(function() return player:GetNetworkPing() end)
    return (ok2 and p2) or 0.08
end

local function findBall()
    local ballsFolder = workspace:FindFirstChild("Balls")
    if not ballsFolder then return nil end
    for _, b in pairs(ballsFolder:GetChildren()) do
        if b:IsA("BasePart") then return b end
        local part = b:FindFirstChildWhichIsA("BasePart")
        if part then return part end
    end
    return nil
end

-- Checa se EU sou o alvo - tenta 3 metodos
local function amITarget(ball)
    local char = player.Character
    if not char then return false end

    -- Metodo 1: Atributo "Target" direto na bola (string com nome do player)
    pcall(function()
        local t = ball:GetAttribute("Target")
        if t and t == player.Name then return true end
    end)

    -- Metodo 2: ObjectValue "Target" na bola
    local targetVal = ball:FindFirstChild("Target") or ball.Parent:FindFirstChild("Target")
    if targetVal then
        if targetVal:IsA("ObjectValue") and targetVal.Value then
            if targetVal.Value == char or targetVal.Value == player then return true end
        elseif targetVal:IsA("StringValue") and targetVal.Value == player.Name then
            return true
        end
    end

    -- Metodo 3: TargetCharacter em workspace.Alive (alguem mirando em mim)
    local alive = workspace:FindFirstChild("Alive")
    if alive then
        for _, plrModel in pairs(alive:GetChildren()) do
            local tc = plrModel:FindFirstChild("TargetCharacter")
            if tc and tc:IsA("ObjectValue") and tc.Value == char then
                return true
            end
        end
    end

    return false
end

local function doParry()
    -- Metodo 1: BindableEvent (como o jogo faz internamente ao clicar)
    pcall(function()
        if parryButtonPress and parryButtonPress:IsA("BindableEvent") then
            parryButtonPress:Fire()
        end
    end)
    -- Metodo 2: RemoteEvent direto ao servidor
    pcall(function()
        if parryAttempt and parryAttempt:IsA("RemoteEvent") then
            parryAttempt:FireServer()
        end
    end)
    -- Metodo 3: Simula click do mouse (fallback)
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.defer(function()
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end)
end

RunService.Heartbeat:Connect(function()
    if not autoParryEnabled then
        parryInfoLabel.Text = "Auto Parry: OFF"
        return
    end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local ball = findBall()
    if not ball then
        prevDist = math.huge
        alreadyParried = false
        parryInfoLabel.Text = "Sem bola"
        return
    end

    local dist = (ball.Position - root.Position).Magnitude
    local approaching = dist < prevDist

    -- Reset parry flag quando bola se afasta (foi rebatida ou mudou de alvo)
    if not approaching then
        alreadyParried = false
    end
    prevDist = dist

    -- Velocidade real da bola (AssemblyLinearVelocity e mais preciso)
    local vel = ball:GetPropertyChangedSignal("AssemblyLinearVelocity") and ball.AssemblyLinearVelocity or ball.Velocity
    local ballSpeed = vel.Magnitude

    -- Verifica se a bola esta vindo na minha direcao (dot product)
    local dirToBall = (root.Position - ball.Position)
    local dotProduct = dirToBall.Unit:Dot(vel.Unit)
    local comingAtMe = dotProduct > 0.3 -- bola apontando pra mim

    local imTarget = amITarget(ball)
    local ping = getPing()

    -- ETA = distancia / velocidade
    local eta = ballSpeed > 1 and (dist / ballSpeed) or 999

    -- Threshold: preciso clicar ANIMATION_DELAY + ping antes do impacto
    -- Se eta <= threshold, hora de clicar
    local threshold = ANIMATION_DELAY + ping + PING_EXTRA

    parryInfoLabel.Text = string.format("D:%.0f S:%.0f T:%.2f P:%dms %s",
        dist, ballSpeed, eta, ping * 1000, imTarget and "[ALVO]" or (comingAtMe and "[VINDO]" or ""))

    local now = tick()

    -- Condicoes para parry:
    -- 1. Sou o alvo OU bola vem na minha direcao (dot product)
    -- 2. Bola se aproximando
    -- 3. ETA <= threshold (hora de clicar considerando delay + ping)
    -- 4. Nao ja parried neste ciclo
    -- 5. Cooldown minimo de 0.3s entre parrys
    if (imTarget or comingAtMe) and approaching and eta <= threshold and not alreadyParried and (now - lastParryTime) > 0.3 then
        lastParryTime = now
        alreadyParried = true
        doParry()
    end
end)

-- ============ CLICK TP (MOUSE) ============
local mouse = player:GetMouse()

local function doClickTp()
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if mouse.Target then
        root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end

-- ============ ESP ============
local espBoxes = {}
local espConnections = {}

local function addESP(plr)
    if plr == player or not espEnabled then return end
    local function createHighlight(char)
        if not espEnabled or not char:FindFirstChild("Head") then return end
        pcall(function()
            for _, obj in pairs(char:GetChildren()) do
                if obj:IsA("Highlight") then obj:Destroy() end
            end
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(200, 40, 40)
            hl.OutlineColor = Color3.fromRGB(255, 80, 80)
            hl.FillTransparency = 0.8
            hl.OutlineTransparency = 0.4
            hl.Adornee = char
            hl.Parent = char

            local bb = Instance.new("BillboardGui")
            bb.Adornee = char:FindFirstChild("Head")
            bb.Size = UDim2.new(0, 100, 0, 30)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Parent = char:FindFirstChild("Head")

            local nl = Instance.new("TextLabel")
            nl.Size = UDim2.new(1, 0, 1, 0)
            nl.BackgroundTransparency = 1
            nl.Text = plr.Name
            nl.TextColor3 = Color3.fromRGB(255, 100, 100)
            nl.TextStrokeTransparency = 0.3
            nl.Font = Enum.Font.GothamBold
            nl.TextSize = 14
            nl.Parent = bb

            if not espBoxes[plr] then espBoxes[plr] = {} end
            table.insert(espBoxes[plr], hl)
            table.insert(espBoxes[plr], bb)
        end)
    end
    if plr.Character then createHighlight(plr.Character) end
    espConnections[plr] = plr.CharacterAdded:Connect(function(char)
        if espEnabled then task.wait(0.3); createHighlight(char) end
    end)
end

local function removeESP(plr)
    if espBoxes[plr] then
        for _, v in pairs(espBoxes[plr]) do pcall(function() v:Destroy() end) end
        espBoxes[plr] = nil
    end
    if espConnections[plr] then espConnections[plr]:Disconnect(); espConnections[plr] = nil end
end

local function enableESP()
    for _, plr in pairs(game.Players:GetPlayers()) do addESP(plr) end
    espConnections._added = game.Players.PlayerAdded:Connect(function(plr)
        if espEnabled then task.wait(0.5); addESP(plr) end
    end)
    espConnections._removing = game.Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)
end

local function disableESP()
    for plr in pairs(espBoxes) do removeESP(plr) end
    if espConnections._added then espConnections._added:Disconnect(); espConnections._added = nil end
    if espConnections._removing then espConnections._removing:Disconnect(); espConnections._removing = nil end
end

-- ============ SPEED ============
local function updateSpeed()
    pcall(function()
        if player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = speedEnabled and walkSpeed or 16 end
        end
    end)
end

-- ============ FLY ============
local function startFly()
    flying = true
    pcall(function()
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        humanoid.PlatformStand = true
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = root
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root
    end)
end

local function stopFly()
    flying = false
    pcall(function()
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.PlatformStand = false end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if not flying or not player.Character then return end
    pcall(function()
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root or not bodyVelocity then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end
        bodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        if bodyGyro then bodyGyro.CFrame = cam.CFrame end
    end)
end)



-- ============ BUTTON CLICKS ============
autoParryBtn.MouseButton1Click:Connect(function()
    autoParryEnabled = not autoParryEnabled
    autoParryInd.BackgroundColor3 = autoParryEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 60, 60)
end)

clickTpBtn.MouseButton1Click:Connect(function()
    clickTpEnabled = not clickTpEnabled
    clickTpInd.BackgroundColor3 = clickTpEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 60, 60)
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then enableESP() else disableESP() end
    espInd.BackgroundColor3 = espEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 60, 60)
end)

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    updateSpeed()
    speedInd.BackgroundColor3 = speedEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 60, 60)
end)

flyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
    flyInd.BackgroundColor3 = flying and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 60, 60)
end)

rejoinBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end)

-- ============ KEY BOXES ============
speedBox.FocusLost:Connect(function()
    local v = tonumber(speedBox.Text)
    if v and v >= 1 and v <= 500 then walkSpeed = v else walkSpeed = 50; speedBox.Text = "50" end
    updateSpeed()
end)

parryKeyBox.FocusLost:Connect(function()
    local t = parryKeyBox.Text:upper()
    local ok, k = pcall(function() return Enum.KeyCode[t] end)
    if ok and k then parryKey = k; parryKeyBox.Text = t else parryKeyBox.Text = "P"; parryKey = Enum.KeyCode.P end
end)

tpKeyBox.FocusLost:Connect(function()
    local t = tpKeyBox.Text:upper()
    local ok, k = pcall(function() return Enum.KeyCode[t] end)
    if ok and k then tpKey = k; tpKeyBox.Text = t else tpKeyBox.Text = "Q"; tpKey = Enum.KeyCode.Q end
end)

espKeyBox.FocusLost:Connect(function()
    local t = espKeyBox.Text:upper()
    local ok, k = pcall(function() return Enum.KeyCode[t] end)
    if ok and k then espKey = k; espKeyBox.Text = t else espKeyBox.Text = "J"; espKey = Enum.KeyCode.J end
end)

flyKeyBox.FocusLost:Connect(function()
    local t = flyKeyBox.Text:upper()
    local ok, k = pcall(function() return Enum.KeyCode[t] end)
    if ok and k then flyKey = k; flyKeyBox.Text = t else flyKeyBox.Text = "F"; flyKey = Enum.KeyCode.F end
end)

-- ============ KEYBINDS ============
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == toggleKey then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == parryKey then
        autoParryEnabled = not autoParryEnabled
        autoParryInd.BackgroundColor3 = autoParryEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 60, 60)
    elseif input.KeyCode == tpKey and clickTpEnabled then
        pcall(doClickTp)
    elseif input.KeyCode == espKey then
        espEnabled = not espEnabled
        if espEnabled then enableESP() else disableESP() end
        espInd.BackgroundColor3 = espEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 60, 60)
    elseif input.KeyCode == flyKey then
        if flying then stopFly() else startFly() end
        flyInd.BackgroundColor3 = flying and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 60, 60)
    end
end)

-- ============ RESPAWN ============
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if speedEnabled then updateSpeed() end
    if flying then startFly() end
end)

-- ============ PARENT GUI ============
pcall(function() ScreenGui.Parent = guiParent end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

print("[BladeBall] Carregado! X=Menu | P=AutoParry | Q=TP | J=ESP | F=Fly")
