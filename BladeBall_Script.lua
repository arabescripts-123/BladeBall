-- BladeBall Diagnostico Completo
-- Roda isso SEPARADO do script principal pra ver tudo que acontece
-- By @leo.zppln

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

repeat task.wait() until player.Character
task.wait(1)

local guiParent = gethui and gethui() or game:GetService("CoreGui")
pcall(function()
    local old = guiParent:FindFirstChild("DiagGui")
    if old then old:Destroy() end
end)

-- ============ GUI DE LOG ============
local sg = Instance.new("ScreenGui")
sg.Name = "DiagGui"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Parent = sg
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BackgroundTransparency = 0.1
frame.Position = UDim2.new(0.5, -250, 0, 10)
frame.Size = UDim2.new(0, 500, 0, 400)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.GothamBold
title.Text = "BLADE BALL - DIAGNOSTICO"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

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
local MAX_LOGS = 80

local function log(text, color)
    logOrder = logOrder + 1
    local l = Instance.new("TextLabel")
    l.Parent = scroll
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, 16)
    l.Font = Enum.Font.RobotoMono
    l.Text = string.format("[%.1f] %s", tick() % 1000, text)
    l.TextColor3 = color or Color3.new(1, 1, 1)
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = logOrder
    l.TextWrapped = true
    l.AutomaticSize = Enum.AutomaticSize.Y

    -- Limpa logs antigos
    local children = scroll:GetChildren()
    local labels = {}
    for _, c in pairs(children) do
        if c:IsA("TextLabel") then table.insert(labels, c) end
    end
    if #labels > MAX_LOGS then
        table.sort(labels, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        for i = 1, #labels - MAX_LOGS do
            labels[i]:Destroy()
        end
    end

    scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
end

local WHITE = Color3.new(1, 1, 1)
local GREEN = Color3.fromRGB(80, 255, 80)
local RED = Color3.fromRGB(255, 80, 80)
local YELLOW = Color3.fromRGB(255, 255, 80)
local CYAN = Color3.fromRGB(80, 220, 255)
local ORANGE = Color3.fromRGB(255, 160, 50)

-- ============ TESTE 1: PING ============
log("=== TESTE DE PING ===", CYAN)
local function testPing()
    local ok1, p1 = pcall(function() return player:GetNetworkPing() end)
    log("GetNetworkPing(): " .. (ok1 and tostring(p1) or "FALHOU: nao existe"), ok1 and GREEN or RED)

    local ok2, p2 = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    log("Stats DataPing: " .. (ok2 and (p2 .. "ms") or "FALHOU"), ok2 and GREEN or RED)
end
testPing()

-- ============ TESTE 2: REMOTES ============
log("", WHITE)
log("=== TESTE DE REMOTES ===", CYAN)

local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
log("ReplicatedStorage.Remotes existe: " .. tostring(Remotes ~= nil), Remotes and GREEN or RED)

if Remotes then
    log("Filhos de Remotes:", YELLOW)
    for _, child in pairs(Remotes:GetChildren()) do
        log("  " .. child.ClassName .. ": " .. child.Name, WHITE)
    end

    local pBP = Remotes:FindFirstChild("ParryButtonPress")
    local pA = Remotes:FindFirstChild("ParryAttempt")
    log("ParryButtonPress: " .. (pBP and pBP.ClassName or "NAO ENCONTRADO"), pBP and GREEN or RED)
    log("ParryAttempt: " .. (pA and pA.ClassName or "NAO ENCONTRADO"), pA and GREEN or RED)
else
    log("Buscando remotes em todo ReplicatedStorage...", YELLOW)
    for _, child in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if child.Name:lower():find("parry") then
            log("  ENCONTRADO: " .. child:GetFullName() .. " (" .. child.ClassName .. ")", GREEN)
        end
    end
end

-- ============ TESTE 3: WORKSPACE BALLS ============
log("", WHITE)
log("=== TESTE DE BOLA ===", CYAN)

local ballsFolder = workspace:FindFirstChild("Balls")
log("workspace.Balls existe: " .. tostring(ballsFolder ~= nil), ballsFolder and GREEN or RED)

if not ballsFolder then
    log("Buscando 'Ball' em todo workspace...", YELLOW)
    for _, child in pairs(workspace:GetDescendants()) do
        if child.Name:lower():find("ball") and child:IsA("BasePart") then
            log("  ENCONTRADO: " .. child:GetFullName(), GREEN)
        end
    end
end

-- ============ TESTE 4: WORKSPACE ALIVE ============
log("", WHITE)
log("=== TESTE DE ALIVE/TARGET ===", CYAN)

local alive = workspace:FindFirstChild("Alive")
log("workspace.Alive existe: " .. tostring(alive ~= nil), alive and GREEN or RED)

if alive then
    log("Jogadores em Alive: " .. #alive:GetChildren(), YELLOW)
    for _, plrModel in pairs(alive:GetChildren()) do
        local tc = plrModel:FindFirstChild("TargetCharacter")
        if tc then
            log("  " .. plrModel.Name .. " -> TargetCharacter: " .. tostring(tc.Value), WHITE)
        end
    end
end

-- ============ TESTE 5: MONITORAMENTO EM TEMPO REAL ============
log("", WHITE)
log("=== MONITORAMENTO EM TEMPO REAL ===", CYAN)
log("Esperando bola aparecer...", YELLOW)

local prevBallPos = nil
local prevDist = math.huge
local prevTime = tick()
local frameCount = 0
local lastLogTime = 0

-- Monitora bola aparecendo/sumindo
if ballsFolder then
    ballsFolder.ChildAdded:Connect(function(child)
        log("BOLA ADICIONADA: " .. child.Name .. " (" .. child.ClassName .. ")", GREEN)
        -- Analisa propriedades da bola
        task.wait(0.1)
        local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
        if part then
            log("  Position: " .. tostring(part.Position), WHITE)
            log("  Velocity: " .. tostring(part.Velocity) .. " Mag:" .. string.format("%.1f", part.Velocity.Magnitude), WHITE)
            local ok, alv = pcall(function() return part.AssemblyLinearVelocity end)
            log("  AssemblyLinearVelocity: " .. (ok and (tostring(alv) .. " Mag:" .. string.format("%.1f", alv.Magnitude)) or "FALHOU"), ok and WHITE or RED)
            log("  Anchored: " .. tostring(part.Anchored), part.Anchored and RED or GREEN)

            -- Checa filhos da bola
            log("  Filhos da bola:", YELLOW)
            for _, c in pairs(child:GetDescendants()) do
                log("    " .. c.ClassName .. ": " .. c.Name, WHITE)
            end

            -- Checa atributos
            local attrs = part:GetAttributes()
            if next(attrs) then
                log("  Atributos:", YELLOW)
                for k, v in pairs(attrs) do
                    log("    " .. k .. " = " .. tostring(v), WHITE)
                end
            else
                log("  Sem atributos", ORANGE)
            end
        end
    end)

    ballsFolder.ChildRemoved:Connect(function(child)
        log("BOLA REMOVIDA: " .. child.Name, RED)
    end)
end

-- Loop principal de monitoramento
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()

    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Encontra bola
    local ball = nil
    if ballsFolder then
        for _, b in pairs(ballsFolder:GetChildren()) do
            if b:IsA("BasePart") then ball = b break end
            local p = b:FindFirstChildWhichIsA("BasePart")
            if p then ball = p break end
        end
    end

    if not ball then
        if prevBallPos ~= nil then
            log("Bola sumiu do folder", RED)
            prevBallPos = nil
            prevDist = math.huge
        end
        return
    end

    local dt = now - prevTime
    prevTime = now

    local dist = (ball.Position - root.Position).Magnitude
    local approaching = dist < (prevDist - 0.3)

    -- Velocidade da bola (3 metodos)
    local velMag = ball.Velocity.Magnitude
    local ok, alvMag = pcall(function() return ball.AssemblyLinearVelocity.Magnitude end)
    alvMag = ok and alvMag or 0

    local manualSpeed = 0
    if prevBallPos and dt > 0 then
        manualSpeed = (ball.Position - prevBallPos).Magnitude / dt
    end
    prevBallPos = ball.Position

    -- Checa target
    local isTarget = false
    local targetInfo = "?"

    -- Metodo 1: atributo na bola
    pcall(function()
        local t = ball:GetAttribute("Target")
        if t then
            targetInfo = "Attr:" .. tostring(t)
            if t == player.Name then isTarget = true end
        end
    end)

    -- Metodo 2: ObjectValue na bola ou parent
    if not isTarget then
        local tv = ball:FindFirstChild("Target") or (ball.Parent and ball.Parent:FindFirstChild("Target"))
        if tv then
            if tv:IsA("ObjectValue") and tv.Value then
                targetInfo = "ObjVal:" .. tv.Value.Name
                if tv.Value == char or tv.Value == player then isTarget = true end
            elseif tv:IsA("StringValue") then
                targetInfo = "StrVal:" .. tv.Value
                if tv.Value == player.Name then isTarget = true end
            end
        end
    end

    -- Metodo 3: TargetCharacter em Alive
    if not isTarget and alive then
        for _, plrModel in pairs(alive:GetChildren()) do
            local tc = plrModel:FindFirstChild("TargetCharacter")
            if tc and tc:IsA("ObjectValue") and tc.Value == char then
                isTarget = true
                targetInfo = "Alive:" .. plrModel.Name .. "->eu"
                break
            end
        end
    end

    prevDist = dist

    -- Loga a cada 0.5s quando bola existe
    if now - lastLogTime >= 0.5 then
        lastLogTime = now

        local bestSpeed = math.max(velMag, alvMag, manualSpeed)
        local eta = bestSpeed > 1 and (dist / bestSpeed) or 999

        local color = approaching and YELLOW or WHITE
        if isTarget and approaching then color = RED end

        log(string.format("D:%.0f Vel:%.0f ALV:%.0f Man:%.0f ETA:%.2f %s %s %s",
            dist, velMag, alvMag, manualSpeed, eta,
            approaching and "APROX" or "afast",
            isTarget and "EU_ALVO" or "nao_alvo",
            "Tgt:" .. targetInfo
        ), color)
    end
end)

-- ============ TESTE 6: TESTA PARRY MANUAL ============
log("", WHITE)
log("=== APERTE 'T' PRA TESTAR PARRY MANUAL ===", ORANGE)

local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        log("--- TESTANDO PARRY ---", RED)

        -- Metodo 1
        local pBP = Remotes and Remotes:FindFirstChild("ParryButtonPress")
        if pBP then
            local ok, err = pcall(function() pBP:Fire() end)
            log("ParryButtonPress:Fire() -> " .. (ok and "OK" or ("ERRO: " .. tostring(err))), ok and GREEN or RED)
        else
            log("ParryButtonPress NAO ENCONTRADO", RED)
        end

        -- Metodo 2
        local pA = Remotes and Remotes:FindFirstChild("ParryAttempt")
        if pA then
            local ok, err = pcall(function() pA:FireServer() end)
            log("ParryAttempt:FireServer() -> " .. (ok and "OK" or ("ERRO: " .. tostring(err))), ok and GREEN or RED)
        else
            log("ParryAttempt NAO ENCONTRADO", RED)
        end

        -- Metodo 3
        local ok3, err3 = pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.defer(function()
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end)
        log("VirtualInputManager click -> " .. (ok3 and "OK" or ("ERRO: " .. tostring(err3))), ok3 and GREEN or RED)

        log("--- FIM TESTE PARRY ---", RED)
    end
end)

log("", WHITE)
log("Diagnostico pronto! Jogue normalmente.", GREEN)
log("Aperte T pra testar se o parry funciona.", ORANGE)
log("Os logs vao mostrar tudo em tempo real.", GREEN)
