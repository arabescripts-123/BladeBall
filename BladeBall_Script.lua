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
local HITBOX_RADIUS = 15 -- raio da hitbox do parry em studs

local function getPing()
    local ok, p = pcall(function() return player:GetNetworkPing() end)
    if ok and p and p > 0 then return p end
    return 0.08
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

-- Velocidade de aproximacao real (dot product)
local function getClosingSpeed(ball, root)
    local toPlayer = (root.Position - ball.Position)
    local dist = toPlayer.Magnitude
    if dist < 0.1 then return manualSpeed end
    local dir = toPlayer.Unit

    -- Tenta velocity da bola
    local ballVel = Vector3.zero
    pcall(function() ballVel = ball.AssemblyLinearVelocity end)
    if ballVel.Magnitude < 5 then
        -- Fallback: calcula velocity manual
        if prevBallPos then
            local dt = tick() - prevTime
            if dt > 0 then
                ballVel = (ball.Position - prevBallPos) / dt
            end
        end
    end

    -- Dot product: velocidade na direcao do jogador
    local closingSpeed = ballVel:Dot(dir)
    -- Se negativo, bola se afasta
    return closingSpeed, ballVel.Magnitude
end

local function doParry()
    -- Prioridade: RemoteEvent direto ao servidor (mais rapido)
    pcall(function()
        if parryAttempt then parryAttempt:FireServer() end
    end)
    pcall(function()
        if parryButtonPress then parryButtonPress:Fire() end
    end)
    -- VIM como fallback
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.defer(function()
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
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

    -- Velocidade de aproximacao real via dot product
    local closingSpeed, totalSpeed = getClosingSpeed(ball, root)
    local approaching = closingSpeed > 5 -- bola vem na minha direcao

    -- Predição: onde a bola estara em (ping + buffer) segundos
    local pingVal = getPing()
    local ballVel = Vector3.zero
    pcall(function() ballVel = ball.AssemblyLinearVelocity end)
    if ballVel.Magnitude < 5 and prevBallPos and dt > 0 then
        ballVel = (ballPos - prevBallPos) / dt
    end
    local predictedPos = ballPos + ballVel * (pingVal + 0.05)
    local predictedDist = (predictedPos - rootPos).Magnitude
    local willHit = predictedDist <= HITBOX_RADIUS

    prevBallPos = ballPos
    prevTime = now

    if not approaching then
        alreadyParried = false
    end

    -- Velocidade efetiva: usa closingSpeed se positivo, senao manual
    local effectiveSpeed = closingSpeed > 10 and closingSpeed or (manualSpeed > 10 and manualSpeed or totalSpeed)
    if effectiveSpeed < 1 then effectiveSpeed = 1 end

    -- ETA baseado na velocidade de aproximacao real
    local eta = dist / effectiveSpeed

    -- Threshold DINAMICO: ping + constante/velocidade
    -- Bola rapida = threshold menor (menos margem necessaria)
    -- Bola lenta = threshold maior (mais tempo pra reagir)
    local dynamicOffset = math.clamp(15 / effectiveSpeed, 0.03, 0.30)
    local threshold = pingVal + dynamicOffset
    if threshold < 0.10 then threshold = 0.10 end

    -- Checa se EU sou o alvo
    local targetName = ""
    pcall(function() targetName = ball:GetAttribute("target") or "" end)
    local imTarget = targetName == player.Name
    local timeSinceParry = now - lastParryTime

    -- Modo clash: dist < 60, sou alvo, cooldown reduzido
    local isClash = imTarget and dist < 60 and effectiveSpeed > 80
    local cooldown = isClash and 0.08 or 0.40

    -- Log detalhado a cada 0.4s
    if now - lastLogTime >= 0.4 then
        lastLogTime = now

        local checks = {}
        table.insert(checks, approaching and "APROX:SIM" or "APROX:NAO")
        table.insert(checks, imTarget and "ALVO:SIM" or ("ALVO:NAO(" .. targetName .. ")"))
        table.insert(checks, string.format("ETA:%.3f", eta))
        table.insert(checks, string.format("TH:%.3f", threshold))
        table.insert(checks, string.format("CS:%.0f", closingSpeed))
        table.insert(checks, willHit and "PRED:HIT" or "PRED:miss")
        table.insert(checks, alreadyParried and "P:SIM" or "P:NAO")
        table.insert(checks, string.format("CD:%.2f", timeSinceParry))
        if isClash then table.insert(checks, "CLASH") end

        local shouldFire = imTarget and (approaching or willHit) and (eta <= threshold or willHit) and not alreadyParried and timeSinceParry > cooldown

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
    -- Condicao 1 (normal): sou alvo + approaching + ETA <= threshold
    -- Condicao 2 (preditivo): sou alvo + predicao diz que vai bater na hitbox
    -- Clash: cooldown reduzido a 0.08s
    local shouldParry = imTarget and (approaching or willHit) and (eta <= threshold or willHit) and not alreadyParried and timeSinceParry > cooldown

    if shouldParry then
        lastParryTime = now
        alreadyParried = true

        local mode = isClash and "CLASH" or (willHit and "PRED" or "NORMAL")
        log(string.format("!!! PARRY %s !!! ETA:%.3f D:%.0f CS:%.0f Spd:%.0f %s",
            mode, eta, dist, closingSpeed, effectiveSpeed, targetName), RED)

        doParry()
    end
end)

log("Diagnostico rodando. Jogue normalmente!", GREEN)
log("Aperte COPIAR pra me enviar os logs.", ORANGE)
