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

local SAFETY_OFFSET = 0.05
local lastParryTime = 0
local alreadyParried = false
local prevDist = math.huge
local prevBallPos = nil
local prevTime = tick()
local manualSpeed = 0
local lastLogTime = 0

local function getPing()
    local ok, p = pcall(function() return player:GetNetworkPing() end)
    if ok and p and p > 0 then return p end
    return 0.08
end

local function findBall()
    if not ballsFolder then return nil end
    for _, b in pairs(ballsFolder:GetChildren()) do
        if b:IsA("BasePart") then return b end
        local p = b:FindFirstChildWhichIsA("BasePart")
        if p then return p end
    end
    return nil
end

local function getBallSpeed(ball)
    local ok1, v1 = pcall(function() return ball.AssemblyLinearVelocity.Magnitude end)
    if ok1 and v1 > 5 then return v1, "AssemblyLV" end
    local ok2, v2 = pcall(function() return ball.Velocity.Magnitude end)
    if ok2 and v2 > 5 then return v2, "Velocity" end
    if manualSpeed > 5 then return manualSpeed, "Manual" end
    return 100, "Fallback"
end

local function doParry()
    local results = {}
    -- Metodo 1
    if parryButtonPress then
        local ok, err = pcall(function() parryButtonPress:Fire() end)
        table.insert(results, "BindableEvent:Fire()->" .. (ok and "OK" or tostring(err)))
    else
        table.insert(results, "BindableEvent->NAO EXISTE")
    end
    -- Metodo 2
    if parryAttempt then
        local ok, err = pcall(function() parryAttempt:FireServer() end)
        table.insert(results, "RemoteEvent:FireServer()->" .. (ok and "OK" or tostring(err)))
    else
        table.insert(results, "RemoteEvent->NAO EXISTE")
    end
    -- Metodo 3
    local ok3, err3 = pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.defer(function()
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end)
    table.insert(results, "VIM click->" .. (ok3 and "OK" or tostring(err3)))
    return results
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
    prevTime = now

    if not ball then
        if prevBallPos then
            prevBallPos = nil
            prevDist = math.huge
            alreadyParried = false
        end
        return
    end

    local dist = (ball.Position - root.Position).Magnitude

    -- Velocidade manual
    if prevBallPos and dt > 0 then
        manualSpeed = (ball.Position - prevBallPos).Magnitude / dt
    end
    prevBallPos = ball.Position

    local approaching = dist < (prevDist - 0.5)
    if not approaching then
        if alreadyParried and dist > prevDist then
            alreadyParried = false
        end
    end

    local ballSpeed, speedSource = getBallSpeed(ball)
    local pingVal = getPing()
    local eta = dist / ballSpeed
    local threshold = pingVal + SAFETY_OFFSET
    if threshold < 0.15 then threshold = 0.15 end

    -- Log detalhado a cada 0.4s
    if now - lastLogTime >= 0.4 then
        lastLogTime = now

        local checks = {}
        table.insert(checks, approaching and "APROX:SIM" or "APROX:NAO")
        table.insert(checks, string.format("ETA:%.3f", eta))
        table.insert(checks, string.format("THRESH:%.3f", threshold))
        table.insert(checks, eta <= threshold and "ETA<=THRESH:SIM" or "ETA<=THRESH:NAO")
        table.insert(checks, alreadyParried and "JA_PARRIED:SIM" or "JA_PARRIED:NAO")
        table.insert(checks, string.format("COOLDOWN:%.2f", now - lastParryTime))
        table.insert(checks, (now - lastParryTime) > 0.25 and "CD_OK:SIM" or "CD_OK:NAO")
        table.insert(checks, "SPD_SRC:" .. speedSource)

        local wouldParry = approaching and eta <= threshold and not alreadyParried and (now - lastParryTime) > 0.25

        local color = WHITE
        if wouldParry then color = GREEN
        elseif approaching then color = YELLOW end

        log(string.format("D:%.0f V:%.0f %s %s",
            dist, ballSpeed,
            table.concat(checks, " | "),
            wouldParry and ">>> DISPARARIA <<<" or ""
        ), color)
    end

    prevDist = dist

    -- LOGICA DE PARRY (identica ao script principal)
    if approaching and eta <= threshold and not alreadyParried and (now - lastParryTime) > 0.25 then
        lastParryTime = now
        alreadyParried = true

        log("!!! PARRY DISPARADO !!! ETA:" .. string.format("%.3f", eta) .. " Dist:" .. string.format("%.0f", dist), RED)

        local results = doParry()
        for _, r in pairs(results) do
            log("  " .. r, ORANGE)
        end
    end
end)

log("Diagnostico rodando. Jogue normalmente!", GREEN)
log("Aperte COPIAR pra me enviar os logs.", ORANGE)
