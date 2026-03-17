-- ================================================
-- ⚔️ CONQUER THE WORLD WW2 - FULL HUB v2
-- Mobile Friendly | Delta Executor
-- Fitur: Auto Attack, Auto Troops, Auto Research,
--        Auto Buy, Auto Collect Income, Auto Factory
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local StarterGui       = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local player           = Players.LocalPlayer

-- State
local state = {
    autoAttack   = false,
    autoMove     = false,
    autoResearch = false,
    autoBuy      = false,
    autoCollect  = false,
    autoFactory  = false,
    autoTPInvader = false,
}

-- Track posisi territory kita sebelumnya
local myTerritoryPositions = {}
local lastInvaderPos = nil

-- ============================================================
-- NOTIFY
-- ============================================================
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = 3
        })
    end)
end

-- ============================================================
-- REMOTE HELPER
-- ============================================================
local remoteCache = {}
local function findRemote(name)
    if remoteCache[name] then return remoteCache[name] end
    for _, svc in ipairs({
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
    }) do
        for _, v in ipairs(svc:GetDescendants()) do
            if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction"))
            and v.Name:lower():find(name:lower()) then
                remoteCache[name] = v
                return v
            end
        end
    end
    return nil
end

local function fireR(name, ...)
    pcall(function()
        local r = findRemote(name)
        if not r then return end
        if r:IsA("RemoteEvent") then r:FireServer(...)
        elseif r:IsA("RemoteFunction") then r:InvokeServer(...) end
    end)
end

local function fireMany(names, ...)
    for _, n in ipairs(names) do fireR(n, ...) end
end

-- ============================================================
-- GUI BUTTON FIRE HELPER
-- ============================================================
local function fireGUIButtons(keywords)
    pcall(function()
        for _, gui in ipairs({player.PlayerGui, game.CoreGui}) do
            pcall(function()
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") or v:IsA("ImageButton") then
                        local txt = (v:IsA("TextButton") and v.Text:lower()) or ""
                        local nam = v.Name:lower()
                        for _, kw in ipairs(keywords) do
                            if txt:find(kw) or nam:find(kw) then
                                pcall(function() v.MouseButton1Click:Fire() end)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- ============================================================
-- CLICK HELPER
-- ============================================================
local function clickObj(obj)
    if not obj then return end
    pcall(function()
        local cd = obj:FindFirstChild("ClickDetector", true)
        local pp = obj:FindFirstChild("ProximityPrompt", true)
        if cd then fireclickdetector(cd) end
        if pp then fireproximityprompt(pp) end
    end)
end

-- ============================================================
-- SCAN HELPERS
-- ============================================================
local function scanWorkspace(keywords)
    local results = {}
    local seen = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if seen[obj] then continue end
            seen[obj] = true
            local nLow = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if nLow:find(kw) then
                    local pos = Vector3.new(0,0,0)
                    if obj:IsA("BasePart") then pos = obj.Position
                    else
                        local bp = obj:FindFirstChildOfClass("BasePart")
                        if bp then pos = bp.Position end
                    end
                    table.insert(results, {obj=obj, name=obj.Name, pos=pos})
                    break
                end
            end
        end
    end)
    return results
end

-- ============================================================
-- AUTO ACTIONS
-- ============================================================
local function doAttack()
    pcall(function()
        fireMany({"Attack","AttackTerritory","LaunchAttack","Invade",
                  "InvadeTerritory","Combat","DeclareWar","Strike"})
        fireGUIButtons({"attack","invade","declare","war","strike"})
        local terr = scanWorkspace({"territory","country","province","region","land"})
        for _, t in ipairs(terr) do
            local owner = t.obj:GetAttribute("Owner") or t.obj:GetAttribute("Nation") or ""
            if tostring(owner) ~= player.Name then clickObj(t.obj) end
        end
    end)
end

local function doNuke()
    pcall(function()
        fireMany({"LaunchNuke","NukeAttack","FireNuke","DeployNuke",
                  "UseNuke","SendNuke","NuclearStrike","AtomicBomb"})
        fireGUIButtons({"nuke","nuclear","atom","bomb"})
    end)
end

local function doMoveTroops()
    pcall(function()
        fireMany({"MoveTroops","MoveArmy","SendTroops","DeployTroops",
                  "AdvanceTroops","RelocateTroops","MoveUnit"})
        fireGUIButtons({"move","deploy","advance","march","troop"})
        local troops = scanWorkspace({"troop","army","soldier","infantry","tank","division"})
        for _, t in ipairs(troops) do clickObj(t.obj) end
    end)
end

local function doResearch()
    pcall(function()
        fireMany({"Research","DoResearch","StartResearch","UnlockResearch",
                  "BuyResearch","UpgradeResearch","ResearchTech"})
        fireGUIButtons({"research","tech","upgrade","unlock","science"})
    end)
end

local function doBuy()
    pcall(function()
        -- Beli semua yang tersedia
        fireMany({"Buy","Purchase","BuyUnit","BuyBuilding","BuyTroop",
                  "BuyTank","BuyPlane","BuyNavy","BuyInfantry",
                  "BuildUnit","Recruit","Train","Enlist"})
        fireGUIButtons({"buy","purchase","build","recruit","train",
                        "enlist","hire","deploy","produce"})
        -- Klik semua tombol beli di workspace
        local buyObjs = scanWorkspace({"buy","shop","store","recruit","train",
                                       "produce","build","manufacture"})
        for _, b in ipairs(buyObjs) do clickObj(b.obj) end
    end)
end

local function doCollect()
    pcall(function()
        fireMany({"CollectIncome","Collect","ClaimIncome","GetIncome",
                  "ClaimReward","CollectRevenue","TaxCollect",
                  "CollectMoney","GetMoney","ClaimMoney"})
        fireGUIButtons({"collect","claim","income","revenue","tax",
                        "money","cash","earn","receive"})
        local collectObjs = scanWorkspace({"income","revenue","tax",
                                           "collect","treasury","money","cash"})
        for _, c in ipairs(collectObjs) do clickObj(c.obj) end
    end)
end

local function doFactory()
    pcall(function()
        fireMany({"BuildFactory","UpgradeFactory","CreateFactory",
                  "BuildIndustry","UpgradeIndustry","BuildProduction",
                  "ConstructFactory","PlaceFactory"})
        fireGUIButtons({"factory","industry","production","manufacture",
                        "construct","build","upgrade"})
        local factObjs = scanWorkspace({"factory","industry","production",
                                        "manufacture","plant","facility"})
        for _, f in ipairs(factObjs) do clickObj(f.obj) end
    end)
end

-- ============================================================
-- LOOP RUNNER
-- ============================================================
local function startLoop(key, interval, fn, onStop)
    state[key] = true
    task.spawn(function()
        while state[key] do
            pcall(fn)
            task.wait(interval)
        end
        if onStop then pcall(onStop) end
    end)
end

local function stopLoop(key)
    state[key] = false
end

-- ============================================================
-- GUI BUILDER HELPERS
-- ============================================================
local C = Color3.fromRGB
local UI = UDim2.new

local function newInst(cls, props, parent)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do
        pcall(function() inst[k] = v end)
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(r, parent)
    return newInst("UICorner", {CornerRadius = UDim.new(0, r)}, parent)
end

local function stroke(color, thick, parent)
    return newInst("UIStroke", {Color=color, Thickness=thick}, parent)
end

local function mkFrame(props, parent)
    local f = newInst("Frame", props, parent)
    corner(12, f)
    return f
end

local function mkLabel(props, parent)
    return newInst("TextLabel", props, parent)
end

local function mkButton(txt, bg, parent, x, y, w, h)
    local b = newInst("TextButton", {
        Position         = UI(x, 4, 0, y),
        Size             = UI(w, -8, 0, h or 48),
        BackgroundColor3 = bg,
        Text             = txt,
        TextColor3       = C(255,255,255),
        Font             = Enum.Font.GothamBold,
        TextScaled       = true,
        ZIndex           = 8,
    }, parent)
    corner(10, b)
    return b
end

local function mkInfoLabel(parent, txt, y)
    return mkLabel({
        Position         = UI(0, 6, 0, y),
        Size             = UI(1, -12, 0, 20),
        BackgroundTransparency = 1,
        Text             = txt,
        TextColor3       = C(160, 160, 160),
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 8,
    }, parent)
end

local function mkStatusRow(parent, y)
    local statusLbl = mkLabel({
        Position         = UI(0, 6, 0, y),
        Size             = UI(0.5, -8, 0, 22),
        BackgroundTransparency = 1,
        Text             = "⏹️ Tidak aktif",
        TextColor3       = C(180, 180, 100),
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 8,
    }, parent)
    local logLbl = mkLabel({
        Position         = UI(0.5, 2, 0, y),
        Size             = UI(0.5, -8, 0, 22),
        BackgroundTransparency = 1,
        Text             = "📝 -",
        TextColor3       = C(140, 200, 140),
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 8,
    }, parent)
    return statusLbl, logLbl
end

local function makeToggleBtn(parent, offTxt, onTxt, offColor, onColor, x, y, w, h, key, interval, actionFn, statusLbl, logLbl, notifyText)
    local btn = mkButton(offTxt, offColor, parent, x, y, w, h)
    btn.MouseButton1Click:Connect(function()
        if not state[key] then
            startLoop(key, interval, function()
                actionFn()
                if logLbl then logLbl.Text = "📝 "..os.date("%H:%M:%S") end
            end)
            btn.BackgroundColor3 = onColor
            btn.Text = onTxt
            if statusLbl then statusLbl.Text = "✅ Aktif" statusLbl.TextColor3 = C(80,220,80) end
            notify(notifyText, "✅ Aktif!")
        else
            stopLoop(key)
            btn.BackgroundColor3 = offColor
            btn.Text = offTxt
            if statusLbl then statusLbl.Text = "⏹️ Tidak aktif" statusLbl.TextColor3 = C(180,180,100) end
            if logLbl then logLbl.Text = "📝 Dihentikan" end
            notify(notifyText, "❌ Nonaktif")
        end
    end)
    return btn
end

-- ============================================================
-- SCAN PENJAJAH / INVADER
-- ============================================================

-- Cari semua enemy/penjajah yang masuk territory kita
local function findInvaders()
    local invaders = {}
    pcall(function()
        -- Scan semua pemain musuh di workspace
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Cek apakah musuh (beda team)
                    local isEnemy = true
                    pcall(function()
                        if player.Team and p.Team then
                            isEnemy = player.Team ~= p.Team
                        end
                    end)
                    if isEnemy then
                        table.insert(invaders, {
                            name   = p.Name,
                            pos    = hrp.Position,
                            obj    = p.Character,
                            player = p,
                        })
                    end
                end
            end
        end

        -- Scan unit/pasukan musuh di workspace
        local enemyKeywords = {"enemy","invader","hostile","attacker","opponent","foe"}
        for _, obj in ipairs(workspace:GetDescendants()) do
            local nLow = obj.Name:lower()
            for _, kw in ipairs(enemyKeywords) do
                if nLow:find(kw) then
                    local owner = tostring(obj:GetAttribute("Owner") or obj:GetAttribute("Nation") or "")
                    if owner ~= player.Name and owner ~= "" then
                        local pos = Vector3.new(0,0,0)
                        if obj:IsA("BasePart") then pos = obj.Position
                        else
                            local bp = obj:FindFirstChildOfClass("BasePart")
                            if bp then pos = bp.Position end
                        end
                        table.insert(invaders, {
                            name = obj.Name.." ("..owner..")",
                            pos  = pos,
                            obj  = obj,
                        })
                    end
                    break
                end
            end
        end
    end)
    return invaders
end

-- Teleport pasukan ke posisi
local function teleportTroopsTo(targetPos)
    pcall(function()
        -- TP karakter player ke target
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
        end
        -- Fire remote TP/deploy pasukan
        fireMany({
            "TeleportTroops","DeployTroops","SendTroopsTo",
            "MoveTroopsTo","RelocateTroops","AdvanceTo"
        })
        -- Fire GUI deploy
        fireGUIButtons({"deploy","send","move","advance","teleport"})
    end)
end

-- Deteksi serangan masuk (territory kita diserang)
local function detectIncoming()
    local incoming = nil
    pcall(function()
        -- Cek semua pemain musuh
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Cek apakah musuh sedang menyerang (ada di dekat territory kita)
                    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        local dist = (hrp.Position - myHRP.Position).Magnitude
                        -- Jika musuh dalam radius 500 studs dari kita
                        if dist < 500 then
                            local isEnemy = true
                            pcall(function()
                                if player.Team and p.Team then
                                    isEnemy = player.Team ~= p.Team
                                end
                            end)
                            if isEnemy then
                                incoming = {
                                    name = p.Name,
                                    pos  = hrp.Position,
                                    dist = dist,
                                }
                            end
                        end
                    end
                end
            end
        end

        -- Juga cek dari attribute territory yang diserang
        for _, obj in ipairs(workspace:GetDescendants()) do
            local isUnderAttack = obj:GetAttribute("UnderAttack") or
                                  obj:GetAttribute("Invaded") or
                                  obj:GetAttribute("Attacked") or
                                  obj:GetAttribute("IsAttacked")
            if isUnderAttack == true or isUnderAttack == 1 then
                local pos = Vector3.new(0,0,0)
                if obj:IsA("BasePart") then pos = obj.Position
                else
                    local bp = obj:FindFirstChildOfClass("BasePart")
                    if bp then pos = bp.Position end
                end
                incoming = {name = obj.Name, pos = pos, dist = 0}
                break
            end
        end
    end)
    return incoming
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local function createGUI()
    pcall(function()
        local old = game.CoreGui:FindFirstChild("ConquerHubV2")
        if old then old:Destroy() end
    end)

    local ScreenGui = newInst("ScreenGui", {
        Name            = "ConquerHubV2",
        ResetOnSpawn    = false,
        IgnoreGuiInset  = true,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() ScreenGui.Parent = game.CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = player.PlayerGui end

    -- -------------------------------------------------------
    -- OPEN BUTTON
    -- -------------------------------------------------------
    local OpenBtn = newInst("TextButton", {
        Size             = UI(0, 62, 0, 62),
        Position         = UI(1, -72, 1, -180),
        BackgroundColor3 = C(100, 15, 15),
        Text             = "⚔️",
        TextColor3       = C(255,255,255),
        Font             = Enum.Font.GothamBold,
        TextSize         = 28,
        ZIndex           = 15,
    }, ScreenGui)
    corner(18, OpenBtn)
    stroke(C(200,50,50), 1.5, OpenBtn)

    -- -------------------------------------------------------
    -- MAIN FRAME (horizontal, from bottom)
    -- -------------------------------------------------------
    local Frame = mkFrame({
        Size             = UI(1, -20, 0, 330),
        Position         = UI(0, 10, 1, -350),
        BackgroundColor3 = C(14, 12, 10),
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 5,
    }, ScreenGui)
    stroke(C(140, 25, 25), 1.5, Frame)

    -- -------------------------------------------------------
    -- TITLE BAR
    -- -------------------------------------------------------
    local TitleBar = newInst("Frame", {
        Size             = UI(1, 0, 0, 42),
        BackgroundColor3 = C(100, 15, 15),
        BorderSizePixel  = 0,
        ZIndex           = 6,
    }, Frame)
    corner(12, TitleBar)

    mkLabel({
        Size             = UI(1, -55, 1, 0),
        Position         = UI(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text             = "⚔️  CONQUER THE WORLD  ·  WW2 HUB",
        TextColor3       = C(255, 220, 160),
        Font             = Enum.Font.GothamBold,
        TextScaled       = true,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, TitleBar)

    local CloseBtn = newInst("TextButton", {
        Size             = UI(0, 32, 0, 32),
        Position         = UI(1, -36, 0, 5),
        BackgroundColor3 = C(190, 40, 40),
        Text             = "✕",
        TextColor3       = C(255,255,255),
        Font             = Enum.Font.GothamBold,
        TextScaled       = true,
        ZIndex           = 7,
    }, TitleBar)
    corner(8, CloseBtn)

    -- -------------------------------------------------------
    -- TAB BAR
    -- -------------------------------------------------------
    local TabScroll = newInst("ScrollingFrame", {
        Size                  = UI(1, -16, 0, 38),
        Position              = UI(0, 8, 0, 46),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 0,
        ScrollingDirection    = Enum.ScrollingDirection.X,
        CanvasSize            = UI(0, 0, 0, 0),
        ZIndex                = 6,
    }, Frame)

    local TabLayout = newInst("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 5),
        SortOrder     = Enum.SortOrder.LayoutOrder,
    }, TabScroll)

    local TABS = {
        {icon="⚔️", name="Serang"},
        {icon="🪖", name="Pasukan"},
        {icon="🔬", name="Riset"},
        {icon="🛒", name="Auto Buy"},
        {icon="💰", name="Income"},
        {icon="🏭", name="Factory"},
    }

    local tabBtns = {}
    for i, t in ipairs(TABS) do
        local btn = newInst("TextButton", {
            Size             = UI(0, 88, 1, 0),
            BackgroundColor3 = C(40, 20, 18),
            Text             = t.icon.." "..t.name,
            TextColor3       = C(160, 130, 110),
            Font             = Enum.Font.GothamBold,
            TextScaled       = true,
            ZIndex           = 7,
            LayoutOrder      = i,
        }, TabScroll)
        corner(8, btn)
        table.insert(tabBtns, btn)
    end

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UI(0, TabLayout.AbsoluteContentSize.X + 10, 0, 0)
    end)

    -- -------------------------------------------------------
    -- CONTENT AREA
    -- -------------------------------------------------------
    local Content = newInst("Frame", {
        Size             = UI(1, -16, 1, -94),
        Position         = UI(0, 8, 0, 90),
        BackgroundTransparency = 1,
        ZIndex           = 6,
    }, Frame)

    local panels = {}
    local function makePanel()
        local p = newInst("Frame", {
            Size             = UI(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible          = false,
            ZIndex           = 6,
        }, Content)
        table.insert(panels, p)
        return p
    end

    -- -------------------------------------------------------
    -- TAB 1: AUTO ATTACK
    -- -------------------------------------------------------
    local P1 = makePanel()
    local s1, l1 = mkStatusRow(P1, 0)
    makeToggleBtn(P1, "⚔️ Auto Serang: OFF", "⚔️ Auto Serang: ON",
        C(110,18,18), C(200,30,30),
        0, 26, 0.6, 48, "autoAttack", 3,
        doAttack, s1, l1, "Auto Attack")

    local onceAtk = mkButton("💥 Sekali", C(150,60,20), P1, 0.6, 26, 0.4, 48)
    onceAtk.MouseButton1Click:Connect(function()
        pcall(doAttack)
        l1.Text = "📝 Serang sekali "..os.date("%H:%M:%S")
        notify("Attack","💥 Serangan diluncurkan!")
    end)

    local nukeBtn = mkButton("☢️ Launch Nuke", C(70,20,110), P1, 0, 80, 0.5, 46)
    nukeBtn.MouseButton1Click:Connect(function()
        pcall(doNuke)
        l1.Text = "📝 ☢️ Nuke! "..os.date("%H:%M:%S")
        notify("Nuke","☢️ Nuclear Strike!")
    end)

    local warBtn = mkButton("📜 Declare War", C(130,40,15), P1, 0.5, 80, 0.5, 46)
    warBtn.MouseButton1Click:Connect(function()
        pcall(function()
            fireMany({"DeclareWar","War","StartWar","BeginWar"})
            fireGUIButtons({"declare","war","begin war"})
        end)
        l1.Text = "📝 War declared "..os.date("%H:%M:%S")
        notify("War","📜 War declared!")
    end)

    mkInfoLabel(P1, "ℹ️ Fire remote + klik territory musuh otomatis", 134)

    -- -------------------------------------------------------
    -- TAB 2: AUTO TROOPS
    -- -------------------------------------------------------
    local P2 = makePanel()
    local s2, l2 = mkStatusRow(P2, 0)
    makeToggleBtn(P2, "🪖 Auto Move: OFF", "🪖 Auto Move: ON",
        C(40,65,25), C(70,160,35),
        0, 26, 0.6, 48, "autoMove", 4,
        doMoveTroops, s2, l2, "Auto Troops")

    local moveOnce = mkButton("👆 Sekali", C(55,90,30), P2, 0.6, 26, 0.4, 48)
    moveOnce.MouseButton1Click:Connect(function()
        pcall(doMoveTroops)
        l2.Text = "📝 Move sekali "..os.date("%H:%M:%S")
        notify("Troops","🪖 Pasukan digerakkan!")
    end)

    local scanTrp = mkButton("🔍 Scan Pasukan", C(25,70,110), P2, 0, 80, 0.5, 46)
    local tpTroop = mkButton("📍 TP ke Pasukan", C(20,90,90), P2, 0.5, 80, 0.5, 46)

    local troopCountLbl = mkLabel({
        Position=UI(0,6,0,134), Size=UI(1,-12,0,22),
        BackgroundTransparency=1, Text="🪖 Pasukan: belum discan",
        TextColor3=C(170,210,170), Font=Enum.Font.GothamBold,
        TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8,
    }, P2)

    scanTrp.MouseButton1Click:Connect(function()
        task.spawn(function()
            local troops = scanWorkspace({"troop","army","soldier","infantry","tank","division","unit"})
            troopCountLbl.Text = "🪖 "..#troops.." pasukan ditemukan"
            notify("Scan","🪖 "..#troops.." pasukan!")
        end)
    end)

    tpTroop.MouseButton1Click:Connect(function()
        pcall(function()
            local troops = scanWorkspace({"troop","army","soldier","infantry"})
            if #troops > 0 then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(troops[1].pos + Vector3.new(0,5,0)) end
                notify("TP","📍 TP ke pasukan!")
            else
                notify("TP","❌ Tidak ada pasukan ditemukan")
            end
        end)
    end)

    mkInfoLabel(P2, "ℹ️ Gerak semua pasukan ke territory musuh otomatis", 162)

    -- -------------------------------------------------------
    -- AUTO TP KE PENJAJAH / INVADER
    -- -------------------------------------------------------
    local invaderSepLbl = mkLabel({
        Position         = UI(0, 6, 0, 180),
        Size             = UI(1, -12, 0, 1),
        BackgroundColor3 = C(80, 30, 30),
        BackgroundTransparency = 0,
        Text             = "",
        ZIndex           = 8,
    }, P2)

    mkLabel({
        Position         = UI(0, 6, 0, 186),
        Size             = UI(1, -12, 0, 20),
        BackgroundTransparency = 1,
        Text             = "🚨 Auto TP ke Penjajah / Saat Diserang:",
        TextColor3       = C(255, 180, 80),
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 8,
    }, P2)

    local invaderStatusLbl = mkLabel({
        Position         = UI(0, 6, 0, 208),
        Size             = UI(0.55, -8, 0, 20),
        BackgroundTransparency = 1,
        Text             = "⏹️ Tidak aktif",
        TextColor3       = C(180, 180, 100),
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 8,
    }, P2)

    local invaderLogLbl = mkLabel({
        Position         = UI(0.55, 2, 0, 208),
        Size             = UI(0.45, -8, 0, 20),
        BackgroundTransparency = 1,
        Text             = "📝 -",
        TextColor3       = C(140, 200, 140),
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 8,
    }, P2)

    -- Tombol Auto TP Penjajah
    local AutoTPInvBtn = mkButton(
        "🚨 Auto TP Penjajah: OFF",
        C(120, 30, 30), P2, 0, 232, 0.65, 46
    )

    -- Tombol TP Manual ke penjajah
    local ManualTPInvBtn = mkButton(
        "📍 TP Sekali",
        C(160, 60, 20), P2, 0.65, 232, 0.35, 46
    )

    -- Tombol Scan penjajah
    local ScanInvBtn = mkButton(
        "🔍 Scan Penjajah",
        C(25, 70, 120), P2, 0, 284, 0.5, 42
    )

    -- Tombol TP pasukan ke penjajah
    local TPTroopsInvBtn = mkButton(
        "🪖 Kirim Pasukan",
        C(80, 50, 20), P2, 0.5, 284, 0.5, 42
    )

    -- Hasil scan penjajah scroll
    local InvScroll = newInst("ScrollingFrame", {
        Size                   = UI(1, 0, 0, 52),
        Position               = UI(0, 0, 0, 332),
        BackgroundTransparency = 1,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = C(200, 50, 50),
        ScrollingDirection     = Enum.ScrollingDirection.X,
        CanvasSize             = UI(0, 0, 0, 0),
        ZIndex                 = 8,
    }, P2)

    local InvLayout = newInst("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 4),
    }, InvScroll)

    local function showInvaders(invaders)
        for _, v in ipairs(InvScroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for i, inv in ipairs(invaders) do
            local tag = newInst("TextButton", {
                Size             = UI(0, 110, 1, -4),
                BackgroundColor3 = C(90, 20, 20),
                Text             = "🚨 "..inv.name,
                TextColor3       = C(255, 200, 200),
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextWrapped      = true,
                ZIndex           = 9,
                LayoutOrder      = i,
            }, InvScroll)
            corner(6, tag)
            tag.MouseButton1Click:Connect(function()
                pcall(function()
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(inv.pos + Vector3.new(0, 5, 3))
                    end
                end)
                invaderLogLbl.Text = "📝 TP ke "..inv.name
                notify("TP Penjajah", "🚨 TP ke "..inv.name.."!")
            end)
        end
        InvScroll.CanvasSize = UI(0, InvLayout.AbsoluteContentSize.X + 10, 0, 0)
    end

    InvLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        InvScroll.CanvasSize = UI(0, InvLayout.AbsoluteContentSize.X + 10, 0, 0)
    end)

    -- Scan penjajah manual
    ScanInvBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            invaderLogLbl.Text = "📝 Scanning..."
            local invaders = findInvaders()
            if #invaders == 0 then
                invaderLogLbl.Text = "📝 Tidak ada penjajah"
                notify("Scan","✅ Aman! Tidak ada penjajah")
            else
                invaderLogLbl.Text = "📝 "..#invaders.." penjajah!"
                showInvaders(invaders)
                notify("Scan","🚨 "..#invaders.." penjajah ditemukan!")
            end
        end)
    end)

    -- TP manual ke penjajah terdekat
    ManualTPInvBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local invaders = findInvaders()
            if #invaders > 0 then
                -- Cari penjajah terdekat
                local nearest = invaders[1]
                local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local minDist = math.huge
                    for _, inv in ipairs(invaders) do
                        local d = (inv.pos - myHRP.Position).Magnitude
                        if d < minDist then
                            minDist = d
                            nearest = inv
                        end
                    end
                end
                pcall(function()
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(nearest.pos + Vector3.new(0,5,3)) end
                end)
                invaderLogLbl.Text = "📝 TP ke "..nearest.name
                notify("TP","🚨 TP ke penjajah "..nearest.name.."!")
                showInvaders(invaders)
            else
                notify("TP","✅ Tidak ada penjajah saat ini")
                invaderLogLbl.Text = "📝 Tidak ada penjajah"
            end
        end)
    end)

    -- Kirim pasukan ke penjajah
    TPTroopsInvBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local invaders = findInvaders()
            if #invaders > 0 then
                teleportTroopsTo(invaders[1].pos)
                doMoveTroops()
                invaderLogLbl.Text = "📝 Pasukan dikirim ke "..invaders[1].name
                notify("Pasukan","🪖 Pasukan dikirim ke penjajah!")
            else
                notify("Pasukan","✅ Tidak ada penjajah")
            end
        end)
    end)

    -- Auto TP ke penjajah toggle
    AutoTPInvBtn.MouseButton1Click:Connect(function()
        state.autoTPInvader = not state.autoTPInvader
        if state.autoTPInvader then
            AutoTPInvBtn.BackgroundColor3 = C(200, 30, 30)
            AutoTPInvBtn.Text = "🚨 Auto TP Penjajah: ON"
            invaderStatusLbl.Text = "✅ Memantau..."
            invaderStatusLbl.TextColor3 = C(80, 220, 80)
            notify("Auto TP Penjajah","🚨 Aktif! Memantau serangan masuk")

            task.spawn(function()
                while state.autoTPInvader do
                    pcall(function()
                        -- Deteksi serangan masuk
                        local incoming = detectIncoming()
                        if incoming then
                            -- Ada penjajah! TP ke sana
                            local hrp = player.Character and
                                        player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = CFrame.new(incoming.pos + Vector3.new(0,5,3))
                            end
                            -- Kirim pasukan juga
                            teleportTroopsTo(incoming.pos)
                            doMoveTroops()
                            doAttack()

                            invaderLogLbl.Text = "📝 🚨 "..incoming.name.." "..os.date("%H:%M:%S")
                            invaderStatusLbl.Text = "🚨 Diserang!"
                            invaderStatusLbl.TextColor3 = C(255, 80, 80)

                            -- Scan dan tampilkan semua penjajah
                            local allInv = findInvaders()
                            if #allInv > 0 then showInvaders(allInv) end

                            notify("PENJAJAH!","🚨 "..incoming.name.." menyerang! TP + kirim pasukan!")
                            task.wait(3) -- cooldown setelah deteksi
                        else
                            invaderStatusLbl.Text = "✅ Memantau..."
                            invaderStatusLbl.TextColor3 = C(80, 220, 80)
                        end
                    end)
                    task.wait(2) -- cek setiap 2 detik
                end
            end)
        else
            state.autoTPInvader = false
            AutoTPInvBtn.BackgroundColor3 = C(120, 30, 30)
            AutoTPInvBtn.Text = "🚨 Auto TP Penjajah: OFF"
            invaderStatusLbl.Text = "⏹️ Tidak aktif"
            invaderStatusLbl.TextColor3 = C(180, 180, 100)
            invaderLogLbl.Text = "📝 Dihentikan"
            notify("Auto TP Penjajah","❌ Nonaktif")
        end
    end)

    mkInfoLabel(P2, "ℹ️ Auto TP + kirim pasukan saat territory diserang penjajah", 390)

    -- -------------------------------------------------------
    -- TAB 3: AUTO RESEARCH
    -- -------------------------------------------------------
    local P3 = makePanel()
    local s3, l3 = mkStatusRow(P3, 0)
    makeToggleBtn(P3, "🔬 Auto Research: OFF", "🔬 Auto Research: ON",
        C(30,30,110), C(60,60,200),
        0, 26, 0.6, 48, "autoResearch", 5,
        doResearch, s3, l3, "Auto Research")

    local resOnce = mkButton("🔬 Sekali", C(50,50,150), P3, 0.6, 26, 0.4, 48)
    resOnce.MouseButton1Click:Connect(function()
        pcall(doResearch)
        l3.Text = "📝 Research sekali "..os.date("%H:%M:%S")
        notify("Research","🔬 Research done!")
    end)

    -- Research shortcuts grid
    local resGrid = {
        {"☢️ Nuke",    C(70,20,110),  {"nuke","nuclear","uranium"}},
        {"✈️ Bomber",  C(25,70,130),  {"bomber","aircraft","plane"}},
        {"🏭 Industry",C(75,55,20),   {"industry","factory","production"}},
        {"⚔️ Infantry",C(110,25,25),  {"infantry","soldier"}},
        {"🛡️ Defense", C(25,80,55),   {"defense","fortification","bunker"}},
        {"🚂 Supply",  C(55,40,75),   {"logistics","supply","transport"}},
    }
    for i, item in ipairs(resGrid) do
        local col = (i-1) % 3
        local row = math.floor((i-1) / 3)
        local b = mkButton(item[1], item[2], P3, col*(1/3), 82+row*50, 1/3, 42)
        b.MouseButton1Click:Connect(function()
            pcall(function()
                for _, kw in ipairs(item[3]) do
                    fireR("Research", kw)
                    fireR("DoResearch", kw)
                    fireR("UnlockResearch", kw)
                end
                fireGUIButtons(item[3])
            end)
            l3.Text = "📝 "..item[1].." "..os.date("%H:%M:%S")
            notify("Research","🔬 "..item[1])
        end)
    end

    -- -------------------------------------------------------
    -- TAB 4: AUTO BUY
    -- -------------------------------------------------------
    local P4 = makePanel()
    local s4, l4 = mkStatusRow(P4, 0)
    makeToggleBtn(P4, "🛒 Auto Buy: OFF", "🛒 Auto Buy: ON",
        C(30,80,40), C(50,170,60),
        0, 26, 0.6, 48, "autoBuy", 4,
        doBuy, s4, l4, "Auto Buy")

    local buyOnce = mkButton("🛒 Beli Sekali", C(40,120,50), P4, 0.6, 26, 0.4, 48)
    buyOnce.MouseButton1Click:Connect(function()
        pcall(doBuy)
        l4.Text = "📝 Buy sekali "..os.date("%H:%M:%S")
        notify("Buy","🛒 Auto buy done!")
    end)

    local buyItems = {
        {"🪖 Infantry",  C(100,40,40),  {"infantry","soldier","recruit"}},
        {"🛡️ Tank",      C(60,60,30),   {"tank","armor","armored"}},
        {"✈️ Plane",     C(25,65,120),  {"plane","aircraft","bomber","fighter"}},
        {"🚢 Navy",      C(15,60,110),  {"navy","ship","submarine","vessel"}},
        {"🏰 Fort",      C(55,45,30),   {"fort","fortification","bunker","wall"}},
        {"🔫 Artillery", C(80,45,25),   {"artillery","cannon","gun","mortar"}},
    }
    for i, item in ipairs(buyItems) do
        local col = (i-1) % 3
        local row = math.floor((i-1) / 3)
        local b = mkButton(item[1], item[2], P4, col*(1/3), 82+row*50, 1/3, 42)
        b.MouseButton1Click:Connect(function()
            pcall(function()
                for _, kw in ipairs(item[3]) do
                    fireR("Buy", kw)
                    fireR("Purchase", kw)
                    fireR("Recruit", kw)
                    fireR("Train", kw)
                end
                fireGUIButtons(item[3])
            end)
            l4.Text = "📝 Buy "..item[1].." "..os.date("%H:%M:%S")
            notify("Buy","🛒 "..item[1].." dibeli!")
        end)
    end

    mkInfoLabel(P4, "ℹ️ Auto buy semua unit, bangunan & pasukan", 192)

    -- -------------------------------------------------------
    -- TAB 5: AUTO COLLECT INCOME
    -- -------------------------------------------------------
    local P5 = makePanel()
    local s5, l5 = mkStatusRow(P5, 0)
    makeToggleBtn(P5, "💰 Auto Collect: OFF", "💰 Auto Collect: ON",
        C(90,60,10), C(200,160,20),
        0, 26, 0.6, 48, "autoCollect", 3,
        doCollect, s5, l5, "Auto Collect")

    local colOnce = mkButton("💰 Collect Sekali", C(150,110,15), P5, 0.6, 26, 0.4, 48)
    colOnce.MouseButton1Click:Connect(function()
        pcall(doCollect)
        l5.Text = "📝 Collect "..os.date("%H:%M:%S")
        notify("Collect","💰 Income collected!")
    end)

    local colItems = {
        {"💰 Tax",       C(150,110,15), {"tax","collect","income"}},
        {"🏦 Treasury",  C(100,75,10),  {"treasury","bank","revenue"}},
        {"🏭 Production",C(80,60,20),   {"production","output","yield"}},
        {"🛢️ Oil",       C(50,40,60),   {"oil","fuel","petroleum","resource"}},
        {"🌾 Food",      C(70,100,20),  {"food","grain","farm","agriculture"}},
        {"💎 All",       C(120,30,120), {"all","every","total","claim"}},
    }
    for i, item in ipairs(colItems) do
        local col = (i-1) % 3
        local row = math.floor((i-1) / 3)
        local b = mkButton(item[1], item[2], P5, col*(1/3), 82+row*50, 1/3, 42)
        b.MouseButton1Click:Connect(function()
            pcall(function()
                for _, kw in ipairs(item[3]) do
                    fireR("Collect", kw)
                    fireR("CollectIncome", kw)
                    fireR("ClaimIncome", kw)
                    fireR("GetIncome", kw)
                end
                fireGUIButtons(item[3])
            end)
            l5.Text = "📝 "..item[1].." "..os.date("%H:%M:%S")
            notify("Collect","💰 "..item[1].." collected!")
        end)
    end

    mkInfoLabel(P5, "ℹ️ Auto collect tax, revenue, dan semua income", 192)

    -- -------------------------------------------------------
    -- TAB 6: AUTO FACTORY
    -- -------------------------------------------------------
    local P6 = makePanel()
    local s6, l6 = mkStatusRow(P6, 0)
    makeToggleBtn(P6, "🏭 Auto Factory: OFF", "🏭 Auto Factory: ON",
        C(70,45,15), C(180,120,30),
        0, 26, 0.6, 48, "autoFactory", 5,
        doFactory, s6, l6, "Auto Factory")

    local facOnce = mkButton("🏭 Build Sekali", C(130,85,20), P6, 0.6, 26, 0.4, 48)
    facOnce.MouseButton1Click:Connect(function()
        pcall(doFactory)
        l6.Text = "📝 Build "..os.date("%H:%M:%S")
        notify("Factory","🏭 Factory built!")
    end)

    local facItems = {
        {"🏭 Factory",    C(130,85,20),  {"factory","manufacture"}},
        {"⚙️ Upgrade",    C(90,65,20),   {"upgrade","improve","enhance"}},
        {"🔧 Repair",     C(70,50,30),   {"repair","fix","restore"}},
        {"🏗️ Construct",  C(80,60,25),   {"construct","build","create"}},
        {"⚡ Power",      C(140,120,10), {"power","energy","electricity"}},
        {"🔩 Industry",   C(75,55,25),   {"industry","industrial","production"}},
    }
    for i, item in ipairs(facItems) do
        local col = (i-1) % 3
        local row = math.floor((i-1) / 3)
        local b = mkButton(item[1], item[2], P6, col*(1/3), 82+row*50, 1/3, 42)
        b.MouseButton1Click:Connect(function()
            pcall(function()
                for _, kw in ipairs(item[3]) do
                    fireR("BuildFactory", kw)
                    fireR("UpgradeFactory", kw)
                    fireR("BuildIndustry", kw)
                end
                fireGUIButtons(item[3])
            end)
            l6.Text = "📝 "..item[1].." "..os.date("%H:%M:%S")
            notify("Factory","🏭 "..item[1].." done!")
        end)
    end

    mkInfoLabel(P6, "ℹ️ Auto build & upgrade factory + industry", 192)

    -- -------------------------------------------------------
    -- TAB SWITCHING
    -- -------------------------------------------------------
    local function switchTab(idx)
        for i, p in ipairs(panels) do p.Visible = (i == idx) end
        for i, t in ipairs(tabBtns) do
            if i == idx then
                t.BackgroundColor3 = C(110, 18, 18)
                t.TextColor3       = C(255, 220, 160)
            else
                t.BackgroundColor3 = C(40, 20, 18)
                t.TextColor3       = C(160, 130, 110)
            end
        end
    end

    for i, t in ipairs(tabBtns) do
        t.MouseButton1Click:Connect(function() switchTab(i) end)
    end

    switchTab(1)

    -- -------------------------------------------------------
    -- DRAG
    -- -------------------------------------------------------
    local dragging, dragStart, startPos = false, nil, nil

    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = Frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            Frame.Position = UI(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- -------------------------------------------------------
    -- OPEN / CLOSE
    -- -------------------------------------------------------
    OpenBtn.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Frame.Visible = false
    end)

    -- Auto buka
    Frame.Visible = true
end

createGUI()
notify("Conquer Hub v2", "✅ Loaded! ⚔️ WW2 Hub aktif")
print("✅ Conquer The World WW2 Hub v2 loaded!")
