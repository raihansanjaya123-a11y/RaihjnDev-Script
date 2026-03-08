-- ============================================================
-- SCRIPT PABRIK v3 - FIXED LOAD + WEBHOOK + BLOCK DETECTOR
-- Webhook dikirim via getgenv().SendWebhook dari loader
-- ============================================================

if getgenv().RaihjnHeartbeatPabrik then
    getgenv().RaihjnHeartbeatPabrik:Disconnect()
    getgenv().RaihjnHeartbeatPabrik = nil
end

local Players     = game:GetService("Players")
local LP          = Players.LocalPlayer
local RS          = game:GetService("ReplicatedStorage")
local RunService  = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ============================================================
-- GLOBALS
-- ============================================================
getgenv().GridSize         = getgenv().GridSize         or 4.5
getgenv().HitCount         = getgenv().HitCount         or 3
getgenv().EnablePabrik     = getgenv().EnablePabrik     or false
getgenv().PabrikStartX     = getgenv().PabrikStartX     or 1
getgenv().PabrikEndX       = getgenv().PabrikEndX       or 99
getgenv().PabrikStartY     = getgenv().PabrikStartY     or 37
getgenv().PabrikEndY       = getgenv().PabrikEndY       or 37
getgenv().GrowthTime       = getgenv().GrowthTime       or 30
getgenv().BreakPosX        = getgenv().BreakPosX        or 0
getgenv().BreakPosY        = getgenv().BreakPosY        or 0
getgenv().DropPosX         = getgenv().DropPosX         or 0
getgenv().DropPosY         = getgenv().DropPosY         or 0
getgenv().BlockThreshold   = getgenv().BlockThreshold   or 1
getgenv().KeepSeedAmt      = getgenv().KeepSeedAmt      or 20
getgenv().SelectedSeed     = getgenv().SelectedSeed     or ""
getgenv().SelectedBlock    = getgenv().SelectedBlock    or ""
getgenv().IsGhosting       = false
getgenv().HoldCFrame       = nil
getgenv().PlantHitCount    = getgenv().PlantHitCount    or 1
getgenv().YGap             = getgenv().YGap             or 2
getgenv().PlaceDelay       = getgenv().PlaceDelay       or 0.1
getgenv().DropDelay        = getgenv().DropDelay        or 0.5
getgenv().StepDelay        = getgenv().StepDelay        or 0.1
getgenv().BreakDelay       = getgenv().BreakDelay       or 0.15
getgenv().TotalDropAllTime = getgenv().TotalDropAllTime or 0
getgenv().CycleCount       = getgenv().CycleCount       or 0

-- ============================================================
-- LOAD MODUL
-- ============================================================
local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

local InventoryMod
pcall(function() InventoryMod = require(RS:WaitForChild("Modules"):WaitForChild("Inventory")) end)

local UIManager
pcall(function() UIManager = require(RS:WaitForChild("Managers"):WaitForChild("UIManager")) end)

local function SendWebhook(content)
    if getgenv().SendWebhook then getgenv().SendWebhook(content) end
end

local function FormatElapsed()
    local elapsed = os.time() - (getgenv().PabrikStartTime or os.time())
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    local s = elapsed % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- ============================================================
-- INVENTORY
-- ============================================================
local function GetAllItem()
    local results = {}
    local stacks  = nil
    if InventoryMod then
        for _, key in ipairs({"Stacks","Items","stacks","items"}) do
            if type(InventoryMod[key]) == "table" then stacks = InventoryMod[key]; break end
        end
        if not stacks then
            for _, m in ipairs({"GetStacks","GetItems","GetInventory"}) do
                if type(InventoryMod[m]) == "function" then
                    local ok, d = pcall(function() return InventoryMod[m](InventoryMod) end)
                    if ok and type(d) == "table" then stacks = d; break end
                end
            end
        end
    end
    if stacks then
        for slotIndex, data in pairs(stacks) do
            if type(data) == "table" then
                local id = data.Id or data.ItemId or data.item_id or data.ID
                if id then
                    local amt = tonumber(data.Amount or data.Amt or data.Count or 1) or 1
                    table.insert(results, {Slot=slotIndex, Id=tostring(id), Amount=amt})
                end
            end
        end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in pairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local id  = tostring(tool:GetAttribute("Id") or tool:GetAttribute("ID") or tool:GetAttribute("ItemId") or tool.Name)
                local amt = tonumber(tool:GetAttribute("Amount") or 1) or 1
                table.insert(results, {Slot=tool.Name, Id=id, Amount=amt})
            end
        end
    end
    return results
end

local function GetSlotByItemID(targetID)
    if not targetID or targetID == "" then return nil end
    targetID = tostring(targetID)
    for _, item in ipairs(GetAllItem()) do
        if item.Id == targetID and item.Amount > 0 then return item.Slot end
    end
    return nil
end

local function GetItemAmountByID(targetID)
    if not targetID or targetID == "" then return 0 end
    targetID = tostring(targetID)
    local total = 0
    for _, item in ipairs(GetAllItem()) do
        if item.Id == targetID then total = total + item.Amount end
    end
    return total
end

local function ScanAvailableItems()
    local items, seen = {}, {}
    for _, item in ipairs(GetAllItem()) do
        if not seen[item.Id] then seen[item.Id]=true; table.insert(items, item.Id) end
    end
    table.sort(items)
    if #items == 0 then items = {"Kosong"} end
    return items
end

-- ============================================================
-- HITBOX & MOVEMENT
-- ============================================================
local function GetMyHitbox()
    local h = workspace:FindFirstChild("Hitbox")
    return h and h:FindFirstChild(LP.Name)
end

local function GetMyPosition()
    local h = GetMyHitbox()
    if not h then return 0, 0 end
    return
        math.floor(h.Position.X / getgenv().GridSize + 0.5),
        math.floor(h.Position.Y / getgenv().GridSize + 0.5)
end

local function SetHitBoxPos(x, y)
    local h = GetMyHitbox()
    if not h then return end
    local pos = Vector3.new(x * getgenv().GridSize, y * getgenv().GridSize, h.Position.Z)
    h.CFrame = CFrame.new(pos)
    -- Sync HRP hanya kalau posisinya jauh, supaya tidak fight physics engine
    pcall(function()
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp.Anchored then
                local diff = (hrp.Position - Vector3.new(pos.X, pos.Y, hrp.Position.Z)).Magnitude
                if diff > getgenv().GridSize then
                    -- Jauh banget, baru sync HRP
                    hrp.CFrame = CFrame.new(Vector3.new(pos.X, pos.Y, hrp.Position.Z))
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end)
    if PlayerMovement then
        pcall(function()
            PlayerMovement.Position    = pos
            PlayerMovement.OldPosition = pos
            PlayerMovement.VelocityX   = 0
            PlayerMovement.VelocityY   = 0
            PlayerMovement.VelocityZ   = 0
            PlayerMovement.Grounded    = true
        end)
    end
end

local function walkToGrid(targetX, targetY)
    local maxSteps = math.abs(targetX - (select(1, GetMyPosition()))) +
                     math.abs(targetY - (select(2, GetMyPosition()))) + 10
    local steps = 0
    local cx, cy = GetMyPosition()
    while (cx ~= targetX or cy ~= targetY) and steps < maxSteps do
        if not getgenv().EnablePabrik then break end
        if cx ~= targetX then cx = cx + (targetX > cx and 1 or -1)
        else cy = cy + (targetY > cy and 1 or -1) end
        SetHitBoxPos(cx, cy)
        task.wait(getgenv().StepDelay)
        -- Re-read posisi setelah step supaya tidak drift
        local rx, ry = GetMyPosition()
        if rx == targetX and ry == targetY then break end
        steps = steps + 1
    end
    -- Paksa ke target di akhir
    SetHitBoxPos(targetX, targetY)
end

local function EnsurePosition(targetX, targetY)
    local maxRetry = 3
    for i = 1, maxRetry do
        task.wait(0.05)
        local cx, cy = GetMyPosition()
        if cx == targetX and cy == targetY then break end
        if i < maxRetry then
            walkToGrid(targetX, targetY)
        else
            SetHitBoxPos(targetX, targetY)
        end
    end
    pcall(function()
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp.Anchored then
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

-- ============================================================
-- DETEKSI BLOCK PENGHALANG
-- ============================================================
local function IsBlockedTile(gx, gy)
    for _, fname in ipairs({"Blocks","Tiles","World","Map","Chunks"}) do
        local folder = workspace:FindFirstChild(fname)
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local ok2, dx, dy = pcall(function()
                        return
                            math.floor(obj.Position.X / getgenv().GridSize + 0.5),
                            math.floor(obj.Position.Y / getgenv().GridSize + 0.5)
                    end)
                    if ok2 and dx == gx and dy == gy then return true end
                end
            end
        end
    end
    return false
end

-- ============================================================
-- ZIGZAG
-- ============================================================
local function ZigzagPath(x1, x2, y1, y2, gap)
    local path  = {}
    local ystep = (y1 <= y2) and gap or -gap
    local row, y = 0, y1
    while true do
        if ystep > 0 and y > y2 then break end
        if ystep < 0 and y < y2 then break end
        row = row + 1
        local xs = (row%2==1) and x1 or x2
        local xe = (row%2==1) and x2 or x1
        local xstep = (xs <= xe) and 1 or -1
        local x = xs
        while true do
            if xstep > 0 and x > xe then break end
            if xstep < 0 and x < xe then break end
            table.insert(path, {X=x, Y=y})
            x = x + xstep
        end
        y = y + ystep
    end
    return path
end

-- ============================================================
-- SCAN WORLD DROPS
-- ============================================================
local function ScanWorldDrops()
    local found, seen = {}, {}
    -- Folder yang biasa dipakai CAW untuk drops
    local scanFolders = {"Drops","Gems","Items","WorldDrops","Pickups","Collectibles"}
    for _, fname in ipairs(scanFolders) do
        local folder = workspace:FindFirstChild(fname)
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                -- Ambil ID dari attribute
                local id = nil
                for _, attrKey in ipairs({"Id","ID","ItemId","item_id","Name","Type"}) do
                    local v = obj:GetAttribute(attrKey)
                    if v and tostring(v) ~= "" then id = tostring(v); break end
                end
                -- Kalau ga ada attribute, cek StringValue di dalamnya
                if not id then
                    for _, c in ipairs(obj:GetDescendants()) do
                        if c:IsA("StringValue") and c.Name:lower():find("id") and c.Value ~= "" then
                            id = c.Value; break
                        end
                    end
                end
                -- Fallback ke nama object
                if not id then id = obj.Name end

                if id and id ~= "" and not seen[id] then
                    seen[id] = true
                    -- Hitung jumlah yang ada di world
                    local count = 0
                    for _, o2 in pairs(folder:GetChildren()) do
                        local oid = o2:GetAttribute("Id") or o2:GetAttribute("ID") or o2:GetAttribute("ItemId") or o2.Name
                        if tostring(oid) == id then count = count + 1 end
                    end
                    table.insert(found, {Id=id, Count=count, Folder=fname})
                end
            end
        end
    end
    table.sort(found, function(a,b) return a.Count > b.Count end)
    return found
end

-- ============================================================
-- DROP / UI HELPERS
-- ============================================================

local function CheckDropsAtGrid(gx, gy)
    for _, fname in ipairs({"Drops","Gems"}) do
        local folder = workspace:FindFirstChild(fname)
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                local pos
                if obj:IsA("BasePart") then pos = obj.Position
                elseif obj:IsA("Model") then
                    local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if p then pos = p.Position end
                end
                if pos then
                    local dx = math.floor(pos.X / getgenv().GridSize + 0.5)
                    local dy = math.floor(pos.Y / getgenv().GridSize + 0.5)
                    if dx == gx and dy == gy then
                        local isSapling = false
                        for _, v in pairs(obj:GetAttributes()) do
                            if type(v)=="string" and v:lower():find("sapling") then isSapling=true; break end
                        end
                        if not isSapling then
                            for _, c in ipairs(obj:GetDescendants()) do
                                if c:IsA("StringValue") and c.Value:lower():find("sapling") then isSapling=true; break end
                            end
                        end
                        if not isSapling then return true end
                    end
                end
            end
        end
    end
    return false
end
local function GetDropRemote()
    local rem = RS:FindFirstChild("Remotes")
    if not rem then return nil end
    return rem:FindFirstChild("PlayerDrop") or rem:FindFirstChild("PlayerDropItem")
end

local function GetPromptRemote()
    local mgr = RS:FindFirstChild("Managers")
    if not mgr then return nil end
    local uim = mgr:FindFirstChild("UIManager")
    if not uim then return nil end
    return uim:FindFirstChild("UIPromptEvent")
end

local function DropItemLogic(targetID, dropAmount)
    local slot = GetSlotByItemID(targetID)
    if not slot then return false end
    local dropR   = GetDropRemote()
    local promptR = GetPromptRemote()
    if dropR and promptR then
        pcall(function() dropR:FireServer(slot) end)
        task.wait(0.2)
        pcall(function() promptR:FireServer({ButtonAction="drp", Inputs={amt=tostring(dropAmount)}}) end)
        task.wait(0.1)
        pcall(function()
            for _, g in pairs(LP.PlayerGui:GetDescendants()) do
                if g:IsA("Frame") and g.Name:lower():find("prompt") then g.Visible=false end
            end
        end)
        return true
    end
    return false
end

local function ForceRestoreUI()
    pcall(function()
        if UIManager and type(UIManager.ClosePrompt)=="function" then UIManager:ClosePrompt() end
        for _, g in pairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("Frame") and g.Name:lower():find("prompt") then g.Visible=false end
        end
    end)
    task.wait(0.1)
    pcall(function()
        if UIManager then
            if type(UIManager.ShowHUD)=="function" then UIManager:ShowHUD() end
            if type(UIManager.ShowUI)=="function"  then UIManager:ShowUI() end
        end
    end)
end

-- ============================================================
-- GHOSTING
-- ============================================================
getgenv().RaihjnHeartbeatPabrik = RunService.Heartbeat:Connect(function()
    if getgenv().IsGhosting and getgenv().HoldCFrame then
        local c = LP.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = getgenv().HoldCFrame end
        end
        if PlayerMovement then pcall(function()
            PlayerMovement.VelocityX=0; PlayerMovement.VelocityY=0
            PlayerMovement.VelocityZ=0; PlayerMovement.Grounded=true
            PlayerMovement.Jumping=false
        end) end
    end
end)

local function StartGhost()
    local char = LP.Character
    if not char then return nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local state = {hrp=hrp, cframe=hrp.CFrame, anchored=hrp.Anchored}
    hrp.Anchored = true
    getgenv().HoldCFrame = state.cframe
    getgenv().IsGhosting = true
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local anim = hum:FindFirstChildOfClass("Animator")
        if anim then
            for _, track in pairs(anim:GetPlayingAnimationTracks()) do track:Stop(0) end
        end
    end
    return state
end

local function StopGhost(state)
    if not state or not state.hrp then return end
    getgenv().IsGhosting = false
    state.hrp.Anchored   = state.anchored or false
    state.hrp.CFrame     = state.cframe
    if PlayerMovement then pcall(function()
        PlayerMovement.Position = state.cframe.Position
        PlayerMovement.VelocityX=0; PlayerMovement.VelocityY=0
        PlayerMovement.VelocityZ=0; PlayerMovement.Grounded=true
    end) end
end

-- ============================================================
-- REMOTES
-- ============================================================
local function GetRemotePlace()
    return RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("PlayerPlaceItem")
end
local function GetRemoteBreak()
    return RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("PlayerFist")
end

local function Doplant(gx, gy, slot)
    local rem = GetRemotePlace()
    if not rem then return end
    local v2 = Vector2.new(gx, gy)
    for i = 1, getgenv().PlantHitCount do
        pcall(function() rem:FireServer(v2, slot) end)
        if i < getgenv().PlantHitCount then task.wait(getgenv().PlaceDelay) end
    end
end

local function DoBreak(gx, gy)
    local rem = GetRemoteBreak()
    if not rem then return end
    local v2 = Vector2.new(gx, gy)
    for _ = 1, getgenv().HitCount do
        if not getgenv().EnablePabrik then break end
        SetHitBoxPos(gx, gy)
        pcall(function() rem:FireServer(v2) end)
        task.wait(getgenv().BreakDelay)
    end
end

-- ============================================================
-- FARM BLOCK LOOP
-- ============================================================
local function DoFarmBlockLoop(breakPosX, breakPosY)
    local BreakTarget = Vector2.new(breakPosX - 1, breakPosY)
    local remPlace = GetRemotePlace()
    local remBreak = GetRemoteBreak()
    if not remPlace or not remBreak then warn("[Block] Remote tidak ada!"); return end
    while getgenv().EnablePabrik do
        local currentAmt = GetItemAmountByID(getgenv().SelectedBlock)
        if currentAmt <= getgenv().BlockThreshold then
            print("[Block] Threshold. Amt:", currentAmt); break
        end
        local blockSlot = GetSlotByItemID(getgenv().SelectedBlock)
        if not blockSlot then print("[Block] Slot nil!"); break end

        pcall(function() remPlace:FireServer(BreakTarget, blockSlot) end)
        task.wait(0.15)

        for _ = 1, getgenv().HitCount do
            if not getgenv().EnablePabrik then break end
            SetHitBoxPos(breakPosX, breakPosY)
            pcall(function() remBreak:FireServer(BreakTarget) end)
            task.wait(getgenv().BreakDelay)
        end

        if CheckDropsAtGrid(BreakTarget.X, BreakTarget.Y) then
            local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local mh   = GetMyHitbox()
            local eCF  = hrp and hrp.CFrame
            local eHCF = mh  and mh.CFrame
            local ePM
            if PlayerMovement then pcall(function() ePM = PlayerMovement.Position end) end

            if hrp then hrp.Anchored=true; getgenv().HoldCFrame=eCF; getgenv().IsGhosting=true end
            if hum then
                local anim   = hum:FindFirstChildOfClass("Animator")
                local tracks = anim and anim:GetPlayingAnimationTracks() or hum:GetPlayingAnimationTracks()
                for _, t in ipairs(tracks) do t:Stop(0) end
            end

            walkToGrid(BreakTarget.X, BreakTarget.Y)
            local t = 0
            while CheckDropsAtGrid(BreakTarget.X, BreakTarget.Y) and t < 15 and getgenv().EnablePabrik do
                task.wait(0.1); t = t + 1
            end
            task.wait(0.1)
            walkToGrid(breakPosX, breakPosY)

            if hrp and eCF then
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                if mh and eHCF then mh.CFrame = eHCF; mh.AssemblyLinearVelocity = Vector3.zero end
                hrp.CFrame = eCF
                if PlayerMovement and ePM then pcall(function()
                    PlayerMovement.Position=ePM; PlayerMovement.OldPosition=ePM
                    PlayerMovement.VelocityX=0; PlayerMovement.VelocityY=0
                    PlayerMovement.VelocityZ=0; PlayerMovement.Grounded=true
                end) end
                RunService.Heartbeat:Wait(); RunService.Heartbeat:Wait()
                hrp.Anchored = false
            end
            getgenv().IsGhosting = false
        end
    end
end

-- ============================================================
-- DROP SEED LOOP
-- ============================================================
local function DoDropSeedLoop()
    local dropped = 0
    local seedAmt = GetItemAmountByID(getgenv().SelectedSeed)
    if seedAmt <= getgenv().KeepSeedAmt then return 0 end

    local gs = StartGhost()
    walkToGrid(getgenv().DropPosX, getgenv().DropPosY)
    task.wait(1.5)

    while getgenv().EnablePabrik do
        local cur    = GetItemAmountByID(getgenv().SelectedSeed)
        local toDrop = cur - getgenv().KeepSeedAmt
        if toDrop <= 0 then break end
        local batch = math.min(toDrop, 200)
        local ok    = DropItemLogic(getgenv().SelectedSeed, batch)
        if ok then
            dropped = dropped + batch
            task.wait(getgenv().DropDelay + 0.3)
        else
            break
        end
    end

    StopGhost(gs)
    ForceRestoreUI()
    return dropped
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
local mainCoro = coroutine.create(function()
    while true do
        task.wait(1)
        if getgenv().EnablePabrik and not getgenv().PabrikIsRunning then

        getgenv().PabrikIsRunning = true
        local ok, err = pcall(function()
            if not getgenv().EnablePabrik then return end

            -- Webhook kalau seed/block belum dipilih
            if getgenv().SelectedSeed == "" or getgenv().SelectedBlock == "" then
                print("[Pabrik] Tunggu seed/block dipilih...")
                task.spawn(function()
                    SendWebhook(
                        "⚠️ **[PABRIK] Seed/Block Belum Dipilih!**\n"..
                        "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                        "🧱 Block: `"..(getgenv().SelectedBlock == "" and "BELUM DIPILIH" or getgenv().SelectedBlock).."`\n"..
                        "🌿 Seed: `"..(getgenv().SelectedSeed == "" and "BELUM DIPILIH" or getgenv().SelectedSeed).."`"
                    )
                end)
                return
            end

            -- ========================
            -- WEBHOOK: MULAI SIKLUS
            -- ========================
            local cycleNumAwal = getgenv().CycleCount + 1
            local blockAmtAwal = GetItemAmountByID(getgenv().SelectedBlock)
            local seedAmtAwal  = GetItemAmountByID(getgenv().SelectedSeed)
            local keputusan    = blockAmtAwal > getgenv().BlockThreshold
                and "🔨 Block ada di inventory ("..blockAmtAwal.."x) → Farm block dulu"
                or  "🌱 Block tidak ada / di threshold → Langsung plant"

            task.spawn(function()
                SendWebhook(
                    "🚀 **[MULAI SIKLUS #"..cycleNumAwal.."]**\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n\n"..
                    "📦 **Scan Inventory:**\n"..
                    "🧱 Block: `"..blockAmtAwal.."x` (threshold: "..getgenv().BlockThreshold..")\n"..
                    "🌿 Seed: `"..seedAmtAwal.."x` (keep: "..getgenv().KeepSeedAmt..")\n\n"..
                    "🔀 **Keputusan:** "..keputusan
                )
            end)

            -- CEK AWAL
            if blockAmtAwal > getgenv().BlockThreshold then
                print("[Awal] Block banyak, farm block dulu")
                walkToGrid(getgenv().BreakPosX, getgenv().BreakPosY)
                task.wait(0.5)
                DoFarmBlockLoop(getgenv().BreakPosX, getgenv().BreakPosY)
                if not getgenv().EnablePabrik then return end
                local d = DoDropSeedLoop()
                if d > 0 then getgenv().TotalDropAllTime = getgenv().TotalDropAllTime + d end
                return
            end

            -- FASE 1: PLANTING
            local plantPath = ZigzagPath(
                getgenv().PabrikStartX, getgenv().PabrikEndX,
                getgenv().PabrikStartY, getgenv().PabrikEndY,
                getgenv().YGap
            )

            local lastPlantedX, lastPlantedY = nil, nil
            local plantedTiles = {}
            local skippedCount = 0

            for i, point in ipairs(plantPath) do
                if not getgenv().EnablePabrik then
                    -- Webhook toggle OFF saat plant
                    task.spawn(function()
                        SendWebhook(
                            "🛑 **[PABRIK] Di-stop Manual Saat Plant**\n"..
                            "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                            "📍 Berhenti di tile ke-`"..i.."` dari `"..#plantPath.."`"
                        )
                    end)
                    break
                end
                if IsBlockedTile(point.X, point.Y) then
                    skippedCount = skippedCount + 1
                else
                    local slot = GetSlotByItemID(getgenv().SelectedSeed)
                    if not slot then
                        print("[Plant] Seed habis di tile", i)
                        -- Webhook seed habis
                        task.spawn(function()
                            SendWebhook(
                                "⚠️ **[FASE 1 — PLANT] Seed Habis!**\n"..
                                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                                "📍 Berhenti di tile ke-`"..i.."` dari `"..#plantPath.."`\n"..
                                "✅ Sudah ditanam: `"..#plantedTiles.."x`  |  ⛔ Skip: `"..skippedCount.."`"
                            )
                        end)
                        break
                    end
                    walkToGrid(point.X, point.Y)
                    EnsurePosition(point.X, point.Y)
                    if not getgenv().EnablePabrik then break end
                    Doplant(point.X, point.Y, slot)
                    task.wait(getgenv().PlaceDelay)
                    lastPlantedX = point.X
                    lastPlantedY = point.Y
                    table.insert(plantedTiles, {X=point.X, Y=point.Y})
                end
            end

            local plantedCount = #plantedTiles
            local seedLeft     = GetItemAmountByID(getgenv().SelectedSeed)
            local cycleNum     = cycleNumAwal
            print("[Plant] Selesai. Planted:", plantedCount, "Skip:", skippedCount)

            -- WEBHOOK FASE 1: PLANT
            task.spawn(function()
                SendWebhook(
                    "🌱 **[FASE 1 — PLANT]** Siklus #"..cycleNum.."\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "✅ Ditanam: `"..plantedCount.."x`  |  ⛔ Skip: `"..skippedCount.."`\n"..
                    "📍 Posisi terakhir: `X="..tostring(lastPlantedX).." Y="..tostring(lastPlantedY).."`\n"..
                    "🌿 Seed tersisa: `"..seedLeft.."x`"
                )
            end)

            -- FASE 2: WAITING
            if not getgenv().EnablePabrik then return end
            local waitTime = getgenv().GrowthTime
            print("[Wait] Tunggu", waitTime, "detik")

            -- WEBHOOK FASE 2: WAIT
            task.spawn(function()
                SendWebhook(
                    "⏳ **[FASE 2 — WAIT]** Siklus #"..cycleNum.."\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "⏱️ Menunggu: `"..waitTime.." detik`"
                )
            end)

            for _ = 1, waitTime do
                if not getgenv().EnablePabrik then
                    task.spawn(function()
                        SendWebhook(
                            "🛑 **[PABRIK] Di-stop Manual Saat Wait**\n"..
                            "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`"
                        )
                    end)
                    break
                end
                task.wait(1)
            end

            -- FASE 3: HARVEST
            if not getgenv().EnablePabrik then return end
            print("[Harvest] Mulai,", #plantedTiles, "tile")
            local blockBefore = GetItemAmountByID(getgenv().SelectedBlock)
            local seedBefore  = GetItemAmountByID(getgenv().SelectedSeed)

            for _, point in ipairs(plantedTiles) do
                if not getgenv().EnablePabrik then
                    task.spawn(function()
                        SendWebhook(
                            "🛑 **[PABRIK] Di-stop Manual Saat Harvest**\n"..
                            "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`"
                        )
                    end)
                    break
                end
                walkToGrid(point.X, point.Y)
                EnsurePosition(point.X, point.Y)
                DoBreak(point.X, point.Y)
            end
            -- ============================================================
            -- SWEEP BALIK — scan per Y dari Y terakhir harvest → Y pertama
            -- Per Y: scan seluruh X=StartX-EndX, collect drop max 0.5 detik per tile
            -- ============================================================
            if getgenv().EnablePabrik then
                -- Kumpulkan semua Y unik yang di-plant
                local seenY = {}
                local yList = {}
                for _, tile in ipairs(plantedTiles) do
                    if not seenY[tile.Y] then
                        seenY[tile.Y] = true
                        table.insert(yList, tile.Y)
                    end
                end

                -- Sort Y: dari Y terakhir harvest → Y pertama
                -- Kalau StartY <= EndY berarti farm naik → sweep dari Y besar ke kecil
                -- Kalau StartY > EndY berarti farm turun → sweep dari Y kecil ke besar
                local farmGoUp = getgenv().PabrikStartY <= getgenv().PabrikEndY
                table.sort(yList, function(a, b)
                    return farmGoUp and (a > b) or (a < b)
                end)

                for _, gy in ipairs(yList) do
                    if not getgenv().EnablePabrik then break end

                    -- Jalan ke tengah X di Y ini dulu
                    local midX = math.floor((getgenv().PabrikStartX + getgenv().PabrikEndX) / 2)
                    walkToGrid(midX, gy)

                    -- Verifikasi Y sudah benar
                    local retryY = 0
                    while retryY < 3 do
                        local _, cy = GetMyPosition()
                        if cy == gy then break end
                        SetHitBoxPos(midX, gy)
                        task.wait(0.1)
                        retryY = retryY + 1
                    end

                    -- Jalan ke setiap tile X — collect otomatis saat badan lewat
                    for gx = getgenv().PabrikStartX, getgenv().PabrikEndX do
                        if not getgenv().EnablePabrik then break end
                        walkToGrid(gx, gy)
                        -- Verifikasi Y tidak blink setelah jalan
                        local cx, cy = GetMyPosition()
                        if cy ~= gy then
                            SetHitBoxPos(gx, gy)
                            task.wait(0.1)
                        end
                        task.wait(getgenv().StepDelay or 0.1)
                    end
                end

                -- Selesai sweep → jalan ke BreakPos dengan verifikasi
                if getgenv().EnablePabrik then
                    walkToGrid(getgenv().BreakPosX, getgenv().BreakPosY)
                    local retryB = 0
                    while retryB < 3 do
                        local cx, cy = GetMyPosition()
                        if cx == getgenv().BreakPosX and cy == getgenv().BreakPosY then break end
                        SetHitBoxPos(getgenv().BreakPosX, getgenv().BreakPosY)
                        task.wait(0.1)
                        retryB = retryB + 1
                    end
                end
            end

            local blockGained = GetItemAmountByID(getgenv().SelectedBlock) - blockBefore
            local seedGained  = GetItemAmountByID(getgenv().SelectedSeed)  - seedBefore

            -- WEBHOOK FASE 3: HARVEST
            task.spawn(function()
                SendWebhook(
                    "⛏️ **[FASE 3 — HARVEST]** Siklus #"..cycleNum.."\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "🧱 Block didapat: `"..blockGained.."x`\n"..
                    "🌿 Seed didapat: `"..seedGained.."x`"
                )
            end)

            -- FASE 4: FARM BLOCK
            if not getgenv().EnablePabrik then return end
            print("[Block] Farm block")
            -- Sudah di BreakPos dari sweep balik, langsung mulai
            task.wait(0.3)
            local breakStart = os.time()
            DoFarmBlockLoop(getgenv().BreakPosX, getgenv().BreakPosY)
            local breakSec  = os.time() - breakStart
            local blockSisa = GetItemAmountByID(getgenv().SelectedBlock)
            local bm = math.floor(breakSec / 60)
            local bs = breakSec % 60

            -- WEBHOOK FASE 4: BREAK
            task.spawn(function()
                SendWebhook(
                    "🔨 **[FASE 4 — BREAK]** Siklus #"..cycleNum.."\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "⏱️ Durasi: `"..string.format("%02d:%02d", bm, bs).."`\n"..
                    "🧱 Block tersisa: `"..blockSisa.."x`"
                )
            end)

            -- FASE 5: DROP SEED
            if not getgenv().EnablePabrik then return end
            local droppedThisCycle = DoDropSeedLoop()
            getgenv().TotalDropAllTime = getgenv().TotalDropAllTime + droppedThisCycle
            getgenv().CycleCount       = getgenv().CycleCount + 1
            print("[Drop] Cycle:", droppedThisCycle, "| Total:", getgenv().TotalDropAllTime)

            -- WEBHOOK FASE 5 + RINGKASAN
            task.spawn(function()
                SendWebhook(
                    "📦 **[FASE 5 — DROP]** Siklus #"..getgenv().CycleCount.."\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "🌱 Drop cycle ini: `"..droppedThisCycle.."x`\n"..
                    "📦 Total all time: `"..getgenv().TotalDropAllTime.."x`\n\n"..
                    "━━━━━━━━━━━━━━━━━━━━━━\n"..
                    "📊 **RINGKASAN SIKLUS #"..getgenv().CycleCount.."**\n"..
                    "🌿 Seed: `"..getgenv().SelectedSeed.."`  |  🧱 Block: `"..getgenv().SelectedBlock.."`\n"..
                    "✅ Plant: `"..plantedCount.."x`  |  ⛔ Skip: `"..skippedCount.."`\n"..
                    "⛏️ Block harvest: `"..blockGained.."x`  |  🌿 Seed harvest: `"..seedGained.."x`\n"..
                    "🔨 Break: `"..string.format("%02d:%02d", bm, bs).."`  |  Sisa: `"..blockSisa.."x`\n"..
                    "🌱 Drop: `"..droppedThisCycle.."x`  |  Total: `"..getgenv().TotalDropAllTime.."x`"
                )
            end)

            print("[Pabrik] Siklus", getgenv().CycleCount, "selesai!")
        end)
        if not ok then warn("[Pabrik] Error:", err) end
        getgenv().PabrikIsRunning = false
        end -- end if EnablePabrik
    end
end)

getgenv().PabrikCoroutine = mainCoro
task.spawn(function() coroutine.resume(mainCoro) end)

-- ============================================================
-- UI
-- ============================================================
local Rayfield = getgenv().Rayfield
if not Rayfield then warn("[Pabrik] Rayfield nil!"); return end
local MainTab = getgenv().RaihjnTab
if not MainTab then warn("[Pabrik] RaihjnTab nil!"); return end

local uiOk, uiErr = pcall(function()

    MainTab:CreateSection("Delay Settings")
    MainTab:CreateInput({Name="Plant Delay", PlaceholderText="0.1", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().PlaceDelay=n end end})
    MainTab:CreateInput({Name="Hit Count", PlaceholderText="3", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().HitCount=n end end})
    MainTab:CreateInput({Name="Break Delay", PlaceholderText="0.15", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().BreakDelay=n end end})
    MainTab:CreateInput({Name="Step Delay", PlaceholderText="0.1", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().StepDelay=n end end})
    MainTab:CreateInput({Name="Growth Time", PlaceholderText="Waktu tumbuh (detik)", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().GrowthTime=n end end})

    MainTab:CreateSection("Item Settings")
    local availableItems = ScanAvailableItems()

    -- Scan World Drops button
    MainTab:CreateButton({
        Name="Scan World Drops",
        Callback=function()
            local drops = ScanWorldDrops()
            if #drops == 0 then
                Rayfield:Notify({Title="Scan World", Content="Tidak ada drop ditemukan!", Duration=3})
                return
            end
            -- Print ke console lengkap
            print("========= WORLD DROPS =========")
            for _, d in ipairs(drops) do
                print(string.format("[%s] %s — %dx", d.Folder, d.Id, d.Count))
            end
            print("================================")
            -- Notify ringkasan top 3
            local msg = ""
            for i = 1, math.min(3, #drops) do
                msg = msg .. drops[i].Id .. " x"..drops[i].Count.."\n"
            end
            if #drops > 3 then msg = msg .. "(+"..( #drops-3).." lainnya, cek console)" end
            Rayfield:Notify({Title="World Drops ("..#drops.." item)", Content=msg, Duration=6})
        end,
    })

    local blockDropdown = MainTab:CreateDropdown({
        Name="Select Block", Options=availableItems, CurrentOption=availableItems[1], Flag="PabrikBlockDrop",
        Callback=function(opt)
            local id = type(opt)=="table" and tostring(opt[1] or "") or tostring(opt)
            getgenv().SelectedBlock = id
            Rayfield:Notify({Title="Block", Content=id, Duration=2})
        end,
    })
    local seedDropdown = MainTab:CreateDropdown({
        Name="Select Seed", Options=availableItems, CurrentOption=availableItems[1], Flag="PabrikSeedDrop",
        Callback=function(opt)
            local id = type(opt)=="table" and tostring(opt[1] or "") or tostring(opt)
            if not id:find("_sapling") then id = id .. "_sapling" end
            getgenv().SelectedSeed = id
            Rayfield:Notify({Title="Seed", Content=id, Duration=2})
        end,
    })
    MainTab:CreateButton({
        Name="Refresh Item List",
        Callback=function()
            local items = ScanAvailableItems()
            -- Coba semua method yang mungkin ada di Rayfield
            local ok1 = pcall(function() blockDropdown:Refresh(items, items[1]) end)
            if not ok1 then
                local ok2 = pcall(function() blockDropdown:UpdateOptions(items) end)
                if not ok2 then
                    pcall(function() blockDropdown:Set(items[1]) end)
                end
            end
            local ok3 = pcall(function() seedDropdown:Refresh(items, items[1]) end)
            if not ok3 then
                local ok4 = pcall(function() seedDropdown:UpdateOptions(items) end)
                if not ok4 then
                    pcall(function() seedDropdown:Set(items[1]) end)
                end
            end
            Rayfield:Notify({Title="Refresh", Content=#items.." item ditemukan!", Duration=2})
        end,
    })

    MainTab:CreateInput({Name="Keep Seed Amount", PlaceholderText="20", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().KeepSeedAmt=n end end})
    MainTab:CreateInput({Name="Block Threshold", PlaceholderText="1", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().BlockThreshold=n end end})

    MainTab:CreateToggle({
        Name="Enable Pabrik", CurrentValue=false, Flag="EnablePabrikToggle",
        Callback=function(v)
            getgenv().EnablePabrik = v
            if v then
                getgenv().PabrikStartTime = os.time()
                print("[Pabrik] Enable: true | Timer mulai")
                task.spawn(function()
                    SendWebhook(
                        "✅ **[PABRIK] Dinyalakan**\n"..
                        "👤 `"..LP.Name.."`  |  🎮 `"..game.Name.."`\n"..
                        "🌿 Seed: `"..(getgenv().SelectedSeed == "" and "Belum dipilih" or getgenv().SelectedSeed).."`\n"..
                        "🧱 Block: `"..(getgenv().SelectedBlock == "" and "Belum dipilih" or getgenv().SelectedBlock).."`"
                    )
                end)
            else
                getgenv().PabrikIsRunning = false
                print("[Pabrik] Enable: false")
                task.spawn(function()
                    SendWebhook(
                        "🛑 **[PABRIK] Dimatikan Manual**\n"..
                        "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                        "📊 Cycle selesai: `"..(getgenv().CycleCount or 0).."x`\n"..
                        "📦 Total drop: `"..(getgenv().TotalDropAllTime or 0).."x`"
                    )
                end)
            end
        end,
    })

    MainTab:CreateSection("Farm Position")
    MainTab:CreateInput({Name="Start X", PlaceholderText="X awal", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().PabrikStartX=n end end})
    MainTab:CreateInput({Name="End X", PlaceholderText="X akhir", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().PabrikEndX=n end end})
    MainTab:CreateInput({Name="Start Y", PlaceholderText="Y awal", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().PabrikStartY=n end end})
    MainTab:CreateInput({Name="End Y", PlaceholderText="Y akhir", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().PabrikEndY=n end end})

    MainTab:CreateSection("Break Position")
    local BPX = MainTab:CreateInput({Name="Break Pos X", PlaceholderText="X berdiri farm block", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().BreakPosX=n end end})
    local BPY = MainTab:CreateInput({Name="Break Pos Y", PlaceholderText="Y berdiri farm block", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().BreakPosY=n end end})
    MainTab:CreateButton({Name="Set Break Pos (Current)", Callback=function()
        local mh = GetMyHitbox()
        if mh then
            local bx = math.floor(mh.Position.X/getgenv().GridSize+0.5)
            local by = math.floor(mh.Position.Y/getgenv().GridSize+0.5)
            getgenv().BreakPosX=bx; getgenv().BreakPosY=by
            pcall(function() BPX:Set(tostring(bx)); BPY:Set(tostring(by)) end)
            Rayfield:Notify({Title="Break Pos", Content="X:"..bx.." Y:"..by, Duration=3})
        end
    end})

    MainTab:CreateSection("Drop Position")
    local DPX = MainTab:CreateInput({Name="Drop Pos X", PlaceholderText="X posisi drop", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().DropPosX=n end end})
    local DPY = MainTab:CreateInput({Name="Drop Pos Y", PlaceholderText="Y posisi drop", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().DropPosY=n end end})
    MainTab:CreateButton({Name="Set Drop Pos (Current)", Callback=function()
        local mh = GetMyHitbox()
        if mh then
            local dx = math.floor(mh.Position.X/getgenv().GridSize+0.5)
            local dy = math.floor(mh.Position.Y/getgenv().GridSize+0.5)
            getgenv().DropPosX=dx; getgenv().DropPosY=dy
            pcall(function() DPX:Set(tostring(dx)); DPY:Set(tostring(dy)) end)
            Rayfield:Notify({Title="Drop Pos", Content="X:"..dx.." Y:"..dy, Duration=3})
        end
    end})

end)

if not uiOk then warn("[Pabrik] UI Error: "..tostring(uiErr)) end

print("[Pabrik v3] Load selesai! Heartbeat:", getgenv().RaihjnHeartbeatPabrik ~= nil)
