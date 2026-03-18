-- BladeBall Diagnostico + Auto Parry Debug
-- Roda SEPARADO do script principal
-- By @leo.zppln

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")

repeat task.wait() until player.Character
task.wait(1)

local guiParent = gethui and gethui() or game:GetService("CoreGui")
pcall(function()
    local old = guiParent:FindFirstChild("DiagGui")
    if old then old:Destroy() end
end)

-- ============ GUI ============
local sg = Instance.new("ScreenGui")
sg.Name = "DiagGui"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Parent = sg
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BackgroundTransparency = 0.1
frame.Position = UDim2.new(0.5, -250, 0, 10)
frame.Size = UDim2.new(0, 500, 0, 420)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.GothamBold
title.Text = "BLADE BALL - DIAGNOSTICO AUTO PARRY"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Botao copiar
local copyBtn = Instance.new("TextButton")
copyBtn.Parent = frame
copyBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
copyBtn.Position = UDim2.new(1, -75, 0, 3)
copyBtn.Size = UDim2.new(0, 70, 0, 24)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Text = "COPIAR"
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.TextSize = 11
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame")
scroll.Parent = frame
scroll.BackgroundTransparency = 1
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.Size = UDim2.new(1, -10, 1, -40)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 2)

pcall(function() sg.Parent = guiParent end)
if not sg.Parent then sg.Parent = player:WaitForChild("PlayerGui") end

local logOrder = 0
local MAX_LOGS = 150
local allLogs = {}

local GREEN = Color3.fromRGB(80, 255, 80)
local RED = Color3.fromRGB(255, 80, 80)
local YELLOW = Color3.fromRGB(255, 255, 80)
local CYAN = Color3.fromRGB(80, 220, 255)
local ORANGE = Color3.fromRGB(255, 160, 50)
local WHITE = Color3.new(1, 1, 1)

local function log(text, color)
    logOrder = logOrder + 1
    local line = string.format("[%.1f] %s", tick() % 1000, text)
    table.insert(allLogs, line)

    local l = Instance.new("TextLabel")
    l.Parent = scroll
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, 14)
    l.Font = Enum.Font.RobotoMono
    l.Text = line
    l.TextColor3 = color or WHITE
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = logOrder
    l.TextWrapped = true
    l.AutomaticSize = Enum.AutomaticSize.Y

    local children = scroll:GetChildren()
    local labels = {}
    for _, c in pairs(children) do
        if c:IsA("TextLabel") then table.insert(labels, c) end
    end
    if #labels > MAX_LOGS then
        table.sort(labels, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        for i = 1, #labels - MAX_LOGS do labels[i]:Destroy() end
    end
    scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
end

-- Botao copiar
copyBtn.MouseButton1Click:Connect(function()
    local txt = table.concat(allLogs, "\n")
    if setclipboard then
        setclipboard(txt)
        copyBtn.Text = "COPIADO!"
    elseif toclipboard then
        toclipboard(txt)
        copyBtn.Text = "COPIADO!"
    else
        copyBtn.Text = "SEM SUPORTE"
    end
    task.delay(2, function() copyBtn.Text = "COPIAR" end)
end)

-- ============ TESTES INICIAIS ============
log("=== ESTRUTURA DO JOGO ===", CYAN)

local ballsFolder = workspace:FindFirstChild("Balls")
log("workspace.Balls: " .. (ballsFolder and "SIM" or "NAO"), ballsFolder and GREEN or RED)

local alive = workspace:FindFirstChild("Alive")
log("workspace.Alive: " .. (alive and "SIM (" .. #alive:GetChildren() .. " jogadores)" or "NAO"), alive and GREEN or RED)

local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
log("ReplicatedStorage.Remotes: " .. (Remotes and "SIM" or "NAO"), Remotes and GREEN or RED)

local parryButtonPress = Remotes and Remotes:FindFirstChild("ParryButtonPress")
local parryAttempt = Remotes and Remotes:FindFirstChild("ParryAttempt")
log("ParryButtonPress: " .. (parryButtonPress and parryButtonPress.ClassName or "NAO ENCONTRADO"), parryButtonPress and GREEN or RED)
log("ParryAttempt: " .. (parryAttempt and parryAttempt.ClassName or "NAO ENCONTRADO"), parryAttempt and GREEN or RED)

if Remotes then
    log("Todos remotes com 'parry':", YELLOW)
    for _, c in pairs(Remotes:GetDescendants()) do
        if c.Name:lower():find("parry") then
            log("  " .. c.Name .. " (" .. c.ClassName .. ")", WHITE)
        end
    end
end

local ok, ping = pcall(function() return player:GetNetworkPing() end)
log("Ping: " .. (ok and string.format("%.0fms", ping * 1000) or "GetNetworkPing falhou"), ok and GREEN or RED)

-- ============ AUTO PARRY (COPIA EXATA DO SCRIPT PRINCIPAL + LOGS) ============
log("", WHITE)
log("=== AUTO PARRY ATIVO COM DEBUG ===", CYAN)
log("Cada decisao sera logada em tempo real", YELLOW)

local lastParryTime = 0
local alreadyParried = false
local prevDist = math.huge
local prevBallPos = nil
local prevTime = tick()
local manualSpeed = 0
local lastLogTime = 0
local HITBOX_RADIUS = 15
local cachedPing = 0.08
local lastPingTime = 0
local lastBallVel = Vector3.zero -- pra detectar aceleracao brusca

-- Pre-sample ping a cada 1s (evita overhead por frame)
local function getPing()
    local now = tick()
    if now - lastPingTime > 1 then
        lastPingTime = now
        local ok, p = pcall(function() return player:GetNetworkPing() end)
        if ok and p and p > 0 then cachedPing = p end
    end
    return cachedPing
end

local function findBall()
    if not ballsFolder then return nil end
    for _, b in pairs(ballsFolder:GetChildren()) do
        local part = b:IsA("BasePart") and b or b:FindFirstChildWhichIsA("BasePart")
        if part and not part.Anchored then
            local isReal = part:GetAttribute("realBall")
            if isReal == true or isReal == nil then return part end
        end
    end
    return nil
end

local function doParry()
    pcall(function()
        if parryAttempt then parryAttempt:FireServer() end
    end)
    pcall(function()
        if parryButtonPress then parryButtonPress:Fire() end
    end)
    -- Simula tecla E (keybind principal do parry)
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.defer(function()
            vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end)
end

-- Monitora bola aparecendo
if ballsFolder then
    ballsFolder.ChildAdded:Connect(function(child)
        log("BOLA NOVA: " .. child.Name .. " (" .. child.ClassName .. ")", GREEN)
        task.wait(0.1)
        local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
        if part then
            log("  Anchored: " .. tostring(part.Anchored), part.Anchored and RED or GREEN)
            log("  Velocity: " .. string.format("%.1f", part.Velocity.Magnitude), WHITE)
            local ok, alv = pcall(function() return part.AssemblyLinearVelocity.Magnitude end)
            log("  AssemblyLV: " .. (ok and string.format("%.1f", alv) or "ERRO"), ok and WHITE or RED)
            for _, c in pairs(child:GetDescendants()) do
                log("  filho: " .. c.Name .. " (" .. c.ClassName .. ")", WHITE)
            end
            local attrs = part:GetAttributes()
            for k, v in pairs(attrs) do
                log("  attr: " .. k .. "=" .. tostring(v), ORANGE)
            end
        end
    end)
    ballsFolder.ChildRemoved:Connect(function(child)
        log("BOLA REMOVIDA: " .. child.Name, RED)
        prevDist = math.huge
        prevBallPos = nil
        alreadyParried = false
    end)
end

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local ball = findBall()
    local now = tick()
    local dt = now - prevTime

    if not ball then
        if prevBallPos then
            prevBallPos = nil
            prevDist = math.huge
            alreadyParried = false
            lastBallVel = Vector3.zero
        end
        prevTime = now
        return
    end

    local ballPos = ball.Position
    local rootPos = root.Position
    local dist = (ballPos - rootPos).Magnitude

    -- Velocidade manual (posicao entre frames)
    if prevBallPos and dt > 0 then
        manualSpeed = (ballPos - prevBallPos).Magnitude / dt
    end

    -- Velocity da bola (AssemblyLV ou manual)
    local ballVel = Vector3.zero
    pcall(function() ballVel = ball.AssemblyLinearVelocity end)
    if ballVel.Magnitude < 5 and prevBallPos and dt > 0 then
        ballVel = (ballPos - prevBallPos) / dt
    end

    -- Velocidade relativa: considera movimento do jogador
    local playerVel = Vector3.zero
    pcall(function() playerVel = root.AssemblyLinearVelocity end)
    local relativeVel = ballVel - playerVel

    -- Dot product com velocidade relativa (mais preciso)
    local toPlayer = rootPos - ballPos
    local dirToPlayer = dist > 0.1 and toPlayer.Unit or Vector3.zero
    local closingSpeed = relativeVel:Dot(dirToPlayer)
    local approaching = closingSpeed > 5

    -- Deteccao de aceleracao brusca (anti-curve/pull)
    -- So ativa se bola vindo na minha direcao E perto
    local acceleration = (ballVel - lastBallVel).Magnitude
    local suddenSpike = acceleration > 80 and dt > 0 and dt < 0.5 and closingSpeed > 30 and dist < 50
    lastBallVel = ballVel

    -- Predicao: posicao futura considerando velocidade do jogador
    local pingVal = getPing()
    local predictedBallPos = ballPos + ballVel * (pingVal + 0.04)
    local predictedPlayerPos = rootPos + playerVel * (pingVal + 0.04)
    local predictedDist = (predictedBallPos - predictedPlayerPos).Magnitude
    local willHit = predictedDist <= HITBOX_RADIUS

    prevBallPos = ballPos
    prevTime = now

    if not approaching then
        alreadyParried = false
    end

    -- Velocidade efetiva
    local effectiveSpeed = closingSpeed > 10 and closingSpeed or (manualSpeed > 10 and manualSpeed or ballVel.Magnitude)
    if effectiveSpeed < 1 then effectiveSpeed = 1 end

    -- ETA
    local eta = dist / effectiveSpeed

    -- Threshold: base + buffer dinamico + ping
    -- Bola lenta precisa de MAIS antecedencia
    local baseOffset = 0.05
    local dynamicBuffer = math.clamp(20 / (effectiveSpeed + 1), 0.02, 0.35)
    local threshold = pingVal + baseOffset + dynamicBuffer
    if threshold < 0.12 then threshold = 0.12 end

    -- Checa se EU sou o alvo
    local targetName = ""
    pcall(function() targetName = ball:GetAttribute("target") or "" end)
    local imTarget = targetName == player.Name
    local timeSinceParry = now - lastParryTime

    -- Modo clash: dist < 60, sou alvo, cooldown reduzido
    local isClash = imTarget and dist < 60 and effectiveSpeed > 80
    local cooldown = isClash and 0.08 or 0.35

    -- Log detalhado a cada 0.4s
    if now - lastLogTime >= 0.4 then
        lastLogTime = now

        local checks = {}
        table.insert(checks, approaching and "AP:Y" or "AP:N")
        table.insert(checks, imTarget and "TG:Y" or ("TG:N(" .. targetName .. ")"))
        table.insert(checks, string.format("E:%.3f", eta))
        table.insert(checks, string.format("T:%.3f", threshold))
        table.insert(checks, string.format("CS:%.0f", closingSpeed))
        table.insert(checks, willHit and "PH:Y" or "PH:N")
        table.insert(checks, suddenSpike and "SPIKE!" or "")
        table.insert(checks, alreadyParried and "P:Y" or "P:N")
        table.insert(checks, string.format("CD:%.2f", timeSinceParry))
        if isClash then table.insert(checks, "CL") end

        local predHitLog = willHit and closingSpeed > 0
        local spikeParryLog = suddenSpike and imTarget
        local shouldFire = imTarget and ((approaching or predHitLog) and (eta <= threshold or predHitLog) or spikeParryLog) and not alreadyParried and timeSinceParry > cooldown

        local color = WHITE
        if shouldFire then color = GREEN
        elseif imTarget and approaching then color = YELLOW end

        log(string.format("D:%.0f V:%.0f %s %s",
            dist, effectiveSpeed,
            table.concat(checks, " | "),
            shouldFire and ">>> FIRE <<<" or ""
        ), color)
    end

    prevDist = dist

    -- LOGICA DE PARRY
    local predHit = willHit and closingSpeed > 0
    local spikeParry = suddenSpike and imTarget
    local shouldParry = imTarget and ((approaching or predHit) and (eta <= threshold or predHit) or spikeParry) and not alreadyParried and timeSinceParry > cooldown

    if shouldParry then
        lastParryTime = now
        alreadyParried = true

        local mode = spikeParry and "SPIKE" or (isClash and "CLASH" or (willHit and "PRED" or "NORMAL"))
        log(string.format("!!! PARRY %s !!! E:%.3f D:%.0f CS:%.0f V:%.0f A:%.0f %s",
            mode, eta, dist, closingSpeed, effectiveSpeed, acceleration, targetName), RED)

        doParry()
    end
end)

log("Diagnostico rodando. Jogue normalmente!", GREEN)
log("Aperte COPIAR pra me enviar os logs.", ORANGE)
