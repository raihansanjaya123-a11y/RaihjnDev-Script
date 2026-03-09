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
-- GLOBALS (hanya set kalau belum ada, supaya tidak reset saat reinject)
-- ============================================================
getgenv().GridSize       = getgenv().GridSize       or 4.5
getgenv().HitCount       = getgenv().HitCount       or 3
getgenv().EnablePabrik   = getgenv().EnablePabrik   or false
getgenv().PabrikStartX   = getgenv().PabrikStartX   or 1
getgenv().PabrikEndX     = getgenv().PabrikEndX     or 99
getgenv().PabrikStartY   = getgenv().PabrikStartY   or 37
getgenv().PabrikEndY     = getgenv().PabrikEndY     or 37
getgenv().GrowthTime     = getgenv().GrowthTime     or 30
getgenv().BreakPosX      = getgenv().BreakPosX      or 0
getgenv().BreakPosY      = getgenv().BreakPosY      or 0
getgenv().DropPosX       = getgenv().DropPosX       or 0
getgenv().DropPosY       = getgenv().DropPosY       or 0
getgenv().BlockThreshold = getgenv().BlockThreshold or 1
getgenv().KeepSeedAmt    = getgenv().KeepSeedAmt    or 20
getgenv().SelectedSeed   = getgenv().SelectedSeed   or ""
getgenv().SelectedBlock  = getgenv().SelectedBlock  or ""
getgenv().IsGhosting     = false
getgenv().HoldCFrame     = nil
getgenv().PlantHitCount  = getgenv().PlantHitCount  or 1
getgenv().YGap           = getgenv().YGap           or 2
getgenv().PlaceDelay     = getgenv().PlaceDelay     or 0.1
getgenv().DropDelay      = getgenv().DropDelay      or 0.5
getgenv().StepDelay      = getgenv().StepDelay      or 0.1
getgenv().BreakDelay     = getgenv().BreakDelay     or 0.15
getgenv().TotalDropAllTime = getgenv().TotalDropAllTime or 0
getgenv().CycleCount       = getgenv().CycleCount       or 0
getgenv().PabrikPaused     = getgenv().PabrikPaused     or false

-- ============================================================
-- LOAD MODUL (semua pakai pcall)
-- ============================================================
local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

local InventoryMod
pcall(function() InventoryMod = require(RS:WaitForChild("Modules"):WaitForChild("Inventory")) end)

local UIManager
pcall(function() UIManager = require(RS:WaitForChild("Managers"):WaitForChild("UIManager")) end)

-- Webhook pakai getgenv().SendWebhook dari loader
local function SendWebhook(content, callback)
    if getgenv().SendWebhook then
        getgenv().SendWebhook(content, callback)
    end
end

local function EditWebhook(messageId, content)
    if getgenv().EditWebhook then
        getgenv().EditWebhook(messageId, content)
    end
end

-- Pause: berhenti di tempat, tunggu sampai di-resume atau di-stop
local function WaitIfPaused()
    while getgenv().PabrikPaused do
        if getgenv().PabrikRestartCycle then
            error("__RESTART__")
        end
        task.wait(0.5)
    end
    if getgenv().PabrikRestartCycle then
        error("__RESTART__")
    end
end

-- Cek apakah harus stop beneran (bukan pause)
local function ShouldStop()
    WaitIfPaused()
    return not getgenv().EnablePabrik
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

    -- Sync HRP supaya tidak blink saat karakter jatuh/posisi beda
    pcall(function()
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp.Anchored then
                -- Pertahankan Z asli HRP, hanya paksa X dan Y ikut hitbox
                local hrpPos = hrp.Position
                hrp.CFrame = CFrame.new(
                    Vector3.new(pos.X, pos.Y, hrpPos.Z)
                )
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
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

-- walkToGrid: jalan step by step X dulu baru Y, anti blink dalam satu baris Y
local function walkToGrid(targetX, targetY)
    local cx, cy = GetMyPosition()
    while cx ~= targetX or cy ~= targetY do
        if not getgenv().EnablePabrik then break end
        if cx ~= targetX then cx = cx + (targetX > cx and 1 or -1)
        else cy = cy + (targetY > cy and 1 or -1) end
        SetHitBoxPos(cx, cy)
        task.wait(getgenv().StepDelay)
    end
    SetHitBoxPos(targetX, targetY)
end

-- walkToGridSafe: dipakai saat PINDAH Y (Y berbeda dari posisi sekarang)
-- Strategi: deteksi posisi X ujung zigzag sesuai baris saat ini (X1 atau X99),
-- jalan ke sana dulu, baru pindah Y step by step sambil paksa X tetap di ujung itu.
-- Ujung X1/X99 adalah posisi aman (tidak ada penghalang di area naik/turun).
local function walkToGridSafe(targetX, targetY)
    local cx, cy = GetMyPosition()

    if cy ~= targetY then
        -- Tentukan safeX: ujung X sesuai posisi zigzag saat ini
        -- Hitung baris sekarang berdasarkan Y (baris ke-N dari StartY)
        local startY  = getgenv().PabrikStartY
        local endY    = getgenv().PabrikEndY
        local gap     = getgenv().YGap or 2
        local x1      = getgenv().PabrikStartX
        local x2      = getgenv().PabrikEndX
        -- Hitung row index (1-based) dari Y sekarang
        local rowIdx
        if startY <= endY then
            rowIdx = math.floor((cy - startY) / gap) + 1
        else
            rowIdx = math.floor((startY - cy) / gap) + 1
        end
        -- Row ganjil: jalan x1→x2, selesai di x2 → safeX = x2
        -- Row genap: jalan x2→x1, selesai di x1 → safeX = x1
        local safeX = (rowIdx % 2 == 1) and x2 or x1

        -- Langkah 1: jalan ke safeX di Y sekarang
        if cx ~= safeX then
            walkToGrid(safeX, cy)
        end
        cx = safeX

        -- Langkah 2: pindah Y satu per satu, paksa X tetap di safeX tiap step
        local stepY = targetY > cy and 1 or -1
        while cy ~= targetY do
            if not getgenv().EnablePabrik then break end
            cy = cy + stepY
            SetHitBoxPos(safeX, cy)
            task.wait(getgenv().StepDelay)
        end

        -- Langkah 3: verifikasi Y sudah benar (retry kalau blink)
        for _ = 1, 5 do
            local _, actY = GetMyPosition()
            if actY == targetY then break end
            SetHitBoxPos(safeX, targetY)
            task.wait(0.1)
        end
        cx = safeX
    end

    -- Langkah 4: jalan ke targetX di Y yang sudah benar
    if cx ~= targetX then
        walkToGrid(targetX, targetY)
    else
        SetHitBoxPos(targetX, targetY)
        task.wait(0.05)
    end
end

local function EnsurePosition(targetX, targetY)
    -- Coba walkToGrid ulang sampai posisi bener, bukan teleport paksa
    local maxRetry = 3
    for i = 1, maxRetry do
        task.wait(0.05)
        local cx, cy = GetMyPosition()
        if cx == targetX and cy == targetY then break end
        -- Posisi belum tepat, walk lagi bukan teleport
        if i < maxRetry then
            walkToGrid(targetX, targetY)
        else
            -- Sudah retry 3x masih beda, baru SetHitBoxPos (last resort)
            SetHitBoxPos(targetX, targetY)
        end
    end
    -- Zero velocity supaya tidak drift
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
-- DETEKSI BLOCK PENGHALANG (dinonaktifkan — CAW tidak pakai)
-- ============================================================
local function IsBlockedTile(gx, gy)
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
-- DROP / UI HELPERS
-- ============================================================
local function CheckDropsAtGrid(TargetGridX, TargetGridY)
    local TargetFolders = { workspace:FindFirstChild("Drops"), workspace:FindFirstChild("Gems") }
    for _, folder in ipairs(TargetFolders) do
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                local pos = nil
                if obj:IsA("BasePart") then pos = obj.Position
                elseif obj:IsA("Model") and obj.PrimaryPart then pos = obj.PrimaryPart.Position
                elseif obj:IsA("Model") then
                    local firstPart = obj:FindFirstChildWhichIsA("BasePart")
                    if firstPart then pos = firstPart.Position end
                end

                if pos then
                    local dX = math.floor(pos.X / getgenv().GridSize + 0.5)
                    local dY = math.floor(pos.Y / getgenv().GridSize + 0.5)

                    if dX == TargetGridX and dY == TargetGridY then
                        -- Cek apakah drop ini adalah Sapling
                        local isSapling = false
                        for _, attrValue in pairs(obj:GetAttributes()) do
                            if type(attrValue) == "string" and string.find(string.lower(attrValue), "sapling") then isSapling = true; break end
                        end
                        if not isSapling then
                            for _, child in ipairs(obj:GetDescendants()) do
                                if child:IsA("StringValue") and string.find(string.lower(child.Value), "sapling") then isSapling = true; break end
                                for _, attrValue in pairs(child:GetAttributes()) do
                                    if type(attrValue) == "string" and string.find(string.lower(attrValue), "sapling") then isSapling = true; break end
                                end
                                if isSapling then break end
                            end
                        end

                        -- Cuma me-return True kalau dia beneran Sapling
                        if isSapling then return true end
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
    local slot    = GetSlotByItemID(targetID)
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
        if UIManager and type(UIManager.ClosePrompt) == "function" then UIManager:ClosePrompt() end
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") and string.find(string.lower(gui.Name), "prompt") then gui.Visible = false end
        end
    end)
    task.wait(0.1)
    pcall(function()
        if UIManager then
            if type(UIManager.ShowHUD) == "function" then UIManager:ShowHUD() end
            if type(UIManager.ShowUI)  == "function" then UIManager:ShowUI() end
        end
    end)
    pcall(function()
        local targetUIs = {"topbar","gems","playerui","hotbar","crosshair","mainhud","stats","inventory","backpack","menu","bottombar","buttons"}
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScreenGui") or gui:IsA("ImageLabel") then
                local gName = string.lower(gui.Name)
                for _, tName in ipairs(targetUIs) do
                    if string.find(gName, tName) and not string.find(gName, "prompt") then
                        if gui:IsA("ScreenGui") then gui.Enabled = true else gui.Visible = true end
                    end
                end
            end
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
-- REMOTES (lazy load, tidak crash saat load script)
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
-- HELPER: Farm Block loop (dipakai 2x, di awal dan fase 4)
-- TIDAK DIUBAH
-- ============================================================
local function DoFarmBlockLoop(breakPosX, breakPosY)
    local BreakTarget = Vector2.new(breakPosX - 1, breakPosY)
    local remPlace = GetRemotePlace()
    local remBreak = GetRemoteBreak()
    if not remPlace or not remBreak then
        warn("[Block] Remote tidak ada!"); return
    end
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
-- HELPER: Drop seed loop
-- ============================================================
local function DoDropSeedLoop()
    local dropped = 0
    local seedAmt = GetItemAmountByID(getgenv().SelectedSeed)
    if seedAmt <= getgenv().KeepSeedAmt then return 0 end

    local gs = StartGhost()
    walkToGrid(getgenv().DropPosX, getgenv().DropPosY)
    task.wait(1.5)

    while getgenv().PabrikIsRunning do
        local cur    = GetItemAmountByID(getgenv().SelectedSeed)
        local toDrop = cur - getgenv().KeepSeedAmt
        if toDrop <= 0 then break end
        local batch = math.min(toDrop, 200)
        local ok    = DropItemLogic(getgenv().SelectedSeed, batch)
        if ok then
            dropped = dropped + batch
            print("[Drop] Dropped:", batch, "| Total this call:", dropped)
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
-- MAIN LOOP (coroutine, bisa di-kill saat exit)
-- ============================================================
local mainCoro = coroutine.create(function()
    while true do
        task.wait(1)
        if getgenv().EnablePabrik and not getgenv().PabrikIsRunning and not getgenv().PabrikPaused then

        getgenv().PabrikIsRunning = true
        local ok, err = pcall(function()
            if ShouldStop() then return end
            if getgenv().SelectedSeed == "" or getgenv().SelectedBlock == "" then
                print("[Pabrik] Tunggu seed/block dipilih...")
                SendWebhook(
                    "⚠️ **[PABRIK] Seed/Block Belum Dipilih!**\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "🧱 Block: `"..(getgenv().SelectedBlock=="" and "BELUM DIPILIH" or getgenv().SelectedBlock).."`\n"..
                    "🌿 Seed: `"..(getgenv().SelectedSeed=="" and "BELUM DIPILIH" or getgenv().SelectedSeed).."`"
                )
                return
            end

            local cycleNum     = getgenv().CycleCount + 1
            local blockAmtAwal = GetItemAmountByID(getgenv().SelectedBlock)
            local seedAmtAwal  = GetItemAmountByID(getgenv().SelectedSeed)

            -- NOTIF: MULAI SIKLUS
            local msgIdSiklus = nil
            SendWebhook(
                "🚀 **[SIKLUS #"..cycleNum.."]** ⏳ Sedang berjalan...\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "🧱 Block: `"..blockAmtAwal.."x`  |  🌿 Seed: `"..seedAmtAwal.."x`\n"..
                "🔀 "..(blockAmtAwal > getgenv().BlockThreshold
                    and "Block ada → Farm block dulu"
                    or  "Block tidak ada → Langsung plant"),
                function(id) msgIdSiklus = id end
            )

            -- CEK AWAL: block sudah banyak
            if blockAmtAwal > getgenv().BlockThreshold then
                print("[Awal] Block banyak ("..blockAmtAwal.."), farm block dulu")
                if getgenv().CycleCount == 0 then
                    walkToGrid(getgenv().BreakPosX, getgenv().BreakPosY)
                else
                    walkToGridSafe(getgenv().BreakPosX, getgenv().BreakPosY)
                end
                task.wait(0.5)
                DoFarmBlockLoop(getgenv().BreakPosX, getgenv().BreakPosY)
                if ShouldStop() then return end
                local d = DoDropSeedLoop()
                if d > 0 then getgenv().TotalDropAllTime = getgenv().TotalDropAllTime + d end
                return
            end

            -- ════════════════════════════════
            -- FASE 1: PLANT
            -- ════════════════════════════════
            local msgIdPlant = nil
            SendWebhook(
                "🌱 **[FASE 1 — PLANT]** Siklus #"..cycleNum.." ⏳\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "🌿 Seed tersedia: `"..seedAmtAwal.."x`",
                function(id) msgIdPlant = id end
            )

            local plantPath = ZigzagPath(
                getgenv().PabrikStartX, getgenv().PabrikEndX,
                getgenv().PabrikStartY, getgenv().PabrikEndY,
                getgenv().YGap
            )
            print("[Plant] Total tile:", #plantPath)

            local lastPlantedX, lastPlantedY = nil, nil
            local plantedTiles = {}
            local skippedTiles = {}
            local skippedCount = 0
            local lastY = nil

            for i, point in ipairs(plantPath) do
                if ShouldStop() then
                    EditWebhook(msgIdPlant,
                        "🌱 **[FASE 1 — PLANT]** Siklus #"..cycleNum.." 🛑 STOP\n"..
                        "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                        "🌱 Planted: `"..#plantedTiles.."x`  |  Tile ke-`"..i.."`"
                    )
                    break
                end

                local slot = nil
                for retry = 1, 3 do
                    slot = GetSlotByItemID(getgenv().SelectedSeed)
                    if slot then break end
                    task.wait(0.3)
                end

                if not slot then
                    print("[Plant] Seed habis di tile", i)
                    EditWebhook(msgIdPlant,
                        "🌱 **[FASE 1 — PLANT]** Siklus #"..cycleNum.." ⚠️ Seed Habis\n"..
                        "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                        "🌱 Planted: `"..#plantedTiles.."x`  |  Tile ke-`"..i.."`"
                    )
                    break
                end

                if lastY ~= nil and point.Y ~= lastY then
                    walkToGridSafe(point.X, point.Y)
                else
                    walkToGrid(point.X, point.Y)
                end
                lastY = point.Y
                WaitIfPaused()
                if ShouldStop() then break end
                EnsurePosition(point.X, point.Y)
                if ShouldStop() then break end

                slot = GetSlotByItemID(getgenv().SelectedSeed)
                if not slot then
                    print("[Plant] Slot hilang saat jalan ke tile", i)
                    table.insert(skippedTiles, {X=point.X, Y=point.Y})
                    skippedCount = skippedCount + 1
                else
                    Doplant(point.X, point.Y, slot)
                    task.wait(getgenv().PlaceDelay)
                    WaitIfPaused()
                    lastPlantedX = point.X
                    lastPlantedY = point.Y
                    table.insert(plantedTiles, {X=point.X, Y=point.Y})

                    if #skippedTiles > 0 then
                        local stillSkipped = {}
                        for _, sk in ipairs(skippedTiles) do
                            if ShouldStop() then break end
                            local retrySlot = nil
                            for r = 1, 3 do
                                retrySlot = GetSlotByItemID(getgenv().SelectedSeed)
                                if retrySlot then break end
                                task.wait(0.3)
                            end
                            if not retrySlot then
                                table.insert(stillSkipped, sk)
                            else
                                if sk.Y ~= lastY then walkToGridSafe(sk.X, sk.Y)
                                else walkToGrid(sk.X, sk.Y) end
                                lastY = sk.Y
                                EnsurePosition(sk.X, sk.Y)
                                if ShouldStop() then break end
                                retrySlot = GetSlotByItemID(getgenv().SelectedSeed)
                                if retrySlot then
                                    Doplant(sk.X, sk.Y, retrySlot)
                                    task.wait(getgenv().PlaceDelay)
                                    lastPlantedX = sk.X
                                    lastPlantedY = sk.Y
                                    table.insert(plantedTiles, {X=sk.X, Y=sk.Y})
                                    skippedCount = skippedCount - 1
                                    if point.Y ~= lastY then walkToGridSafe(point.X, point.Y)
                                    else walkToGrid(point.X, point.Y) end
                                    lastY = point.Y
                                else
                                    table.insert(stillSkipped, sk)
                                end
                            end
                        end
                        skippedTiles = stillSkipped
                    end
                end
            end

            local plantedCount = #plantedTiles
            print("[Plant] Selesai. Planted:", plantedCount, "Skip:", skippedCount)

            -- DETAIL: FASE 1 SELESAI
            EditWebhook(msgIdPlant,
                "🌱 **[FASE 1 — PLANT]** Siklus #"..cycleNum.." ✅ Selesai\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "🌱 Ditanam: `"..plantedCount.."x`  |  ⛔ Skip: `"..skippedCount.."`\n"..
                "📍 Terakhir: `X="..tostring(lastPlantedX).." Y="..tostring(lastPlantedY).."`\n"..
                "🌿 Seed tersisa: `"..GetItemAmountByID(getgenv().SelectedSeed).."x`"
            )

            -- ════════════════════════════════
            -- FASE 2: WAIT
            -- ════════════════════════════════
            if ShouldStop() then return end
            local waitTime = getgenv().GrowthTime

            local msgIdWait = nil
            SendWebhook(
                "⏳ **[FASE 2 — WAIT]** Siklus #"..cycleNum.." ⏳\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "⏱️ Menunggu: `"..waitTime.." detik`",
                function(id) msgIdWait = id end
            )

            local waitElapsed = 0
            while waitElapsed < waitTime do
                if ShouldStop() then
                    EditWebhook(msgIdWait,
                        "⏳ **[FASE 2 — WAIT]** Siklus #"..cycleNum.." 🛑 STOP\n"..
                        "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`"
                    )
                    break
                end
                WaitIfPaused()
                if ShouldStop() then break end
                -- edit update sisa waktu tiap 30 detik
                if waitElapsed % 30 == 0 and waitElapsed > 0 then
                    EditWebhook(msgIdWait,
                        "⏳ **[FASE 2 — WAIT]** Siklus #"..cycleNum.." ⏳\n"..
                        "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                        "⏱️ Sisa: `"..(waitTime - waitElapsed).." detik`"
                    )
                end
                task.wait(1)
                waitElapsed = waitElapsed + 1
            end

            EditWebhook(msgIdWait,
                "⏳ **[FASE 2 — WAIT]** Siklus #"..cycleNum.." ✅ Selesai\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "⏱️ Selesai tunggu: `"..waitTime.." detik`"
            )

            -- ════════════════════════════════
            -- FASE 3: HARVEST
            -- ════════════════════════════════
            if ShouldStop() then return end
            print("[Harvest] Mulai,", #plantedTiles, "tile")
            local blockBefore = GetItemAmountByID(getgenv().SelectedBlock)
            local seedBefore  = GetItemAmountByID(getgenv().SelectedSeed)

            local msgIdHarvest = nil
            SendWebhook(
                "⛏️ **[FASE 3 — HARVEST]** Siklus #"..cycleNum.." ⏳\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "🌾 Total tile: `"..#plantedTiles.."x`",
                function(id) msgIdHarvest = id end
            )

            local lastHarvestY = nil
            for _, point in ipairs(plantedTiles) do
                if ShouldStop() then
                    EditWebhook(msgIdHarvest,
                        "⛏️ **[FASE 3 — HARVEST]** Siklus #"..cycleNum.." 🛑 STOP\n"..
                        "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`"
                    )
                    break
                end
                if lastHarvestY ~= nil and point.Y ~= lastHarvestY then
                    walkToGridSafe(point.X, point.Y)
                else
                    walkToGrid(point.X, point.Y)
                end
                lastHarvestY = point.Y
                WaitIfPaused()
                if ShouldStop() then break end
                EnsurePosition(point.X, point.Y)
                DoBreak(point.X, point.Y)
            end

            -- Sweep zigzag cepat
            if not ShouldStop() then
                local seenY = {}
                local yList = {}
                for _, tile in ipairs(plantedTiles) do
                    if not seenY[tile.Y] then seenY[tile.Y]=true; table.insert(yList, tile.Y) end
                end
                local farmGoUp = getgenv().PabrikStartY <= getgenv().PabrikEndY
                table.sort(yList, function(a,b) return farmGoUp and (a>b) or (a<b) end)

                -- Posisi awal dari harvest terakhir
                local cx, cy = GetMyPosition()
                for _, gy in ipairs(yList) do
                    if ShouldStop() then break end
                    -- Pindah Y langsung dari posisi sekarang, tidak perlu via safeX
                    if cy ~= gy then
                        walkToGrid(cx, gy)
                        cy = gy
                    end
                    -- Arah X dari posisi cx sekarang ke ujung berlawanan
                    local targetX = (cx <= (getgenv().PabrikStartX + getgenv().PabrikEndX) / 2)
                        and getgenv().PabrikEndX or getgenv().PabrikStartX
                    local xstep = cx < targetX and 1 or -1
                    local gx = cx
                    while true do
                        if ShouldStop() then break end
                        if xstep > 0 and gx > targetX then break end
                        if xstep < 0 and gx < targetX then break end
                        SetHitBoxPos(gx, gy)
                        WaitIfPaused()
                        gx = gx + xstep
                    end
                    cx = targetX
                end
                if not ShouldStop() then
                    walkToGridSafe(getgenv().BreakPosX, getgenv().BreakPosY)
                end
            end

            local blockGained = GetItemAmountByID(getgenv().SelectedBlock) - blockBefore
            local seedGained  = GetItemAmountByID(getgenv().SelectedSeed)  - seedBefore

            -- DETAIL: FASE 3 SELESAI
            EditWebhook(msgIdHarvest,
                "⛏️ **[FASE 3 — HARVEST]** Siklus #"..cycleNum.." ✅ Selesai\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "🧱 Block didapat: `"..blockGained.."x`\n"..
                "🌿 Seed didapat: `"..seedGained.."x`"
            )

            -- ════════════════════════════════
            -- FASE 4: BREAK
            -- ════════════════════════════════
            if ShouldStop() then return end
            print("[Block] Farm block")
            task.wait(0.3)

            local msgIdBreak = nil
            SendWebhook(
                "🔨 **[FASE 4 — BREAK]** Siklus #"..cycleNum.." ⏳\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "🧱 Block sekarang: `"..GetItemAmountByID(getgenv().SelectedBlock).."x`  |  Threshold: `"..getgenv().BlockThreshold.."`",
                function(id) msgIdBreak = id end
            )

            local breakStart = os.time()
            local breakUpdateThread = task.spawn(function()
                -- Tunggu msgIdBreak dapat value dulu (max 10 detik)
                local waited = 0
                while not msgIdBreak and waited < 10 do
                    task.wait(1); waited = waited + 1
                end
                local updateCount = 0
                while getgenv().PabrikIsRunning do
                    -- hitung 60 detik tapi skip waktu pause
                    local counted = 0
                    while counted < 60 and getgenv().PabrikIsRunning do
                        task.wait(1)
                        if not getgenv().PabrikPaused then counted = counted + 1 end
                    end
                    if not getgenv().PabrikIsRunning then break end
                    updateCount = updateCount + 1
                    local elapsed = os.time() - breakStart
                    EditWebhook(msgIdBreak,
                        "🔨 **[FASE 4 — BREAK]** Siklus #"..cycleNum.." ⏳ Update #"..updateCount.."\n"..
                        "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                        "🧱 Block tersisa: `"..GetItemAmountByID(getgenv().SelectedBlock).."x`  |  Threshold: `"..getgenv().BlockThreshold.."`\n"..
                        "⏱️ Sudah break: `"..string.format("%02d:%02d", math.floor(elapsed/60), elapsed%60).."`"
                    )
                end
            end)

            DoFarmBlockLoop(getgenv().BreakPosX, getgenv().BreakPosY)
            task.cancel(breakUpdateThread)

            local breakSec  = os.time() - breakStart
            local blockSisa = GetItemAmountByID(getgenv().SelectedBlock)
            local bm = math.floor(breakSec / 60)
            local bs = breakSec % 60

            -- DETAIL: FASE 4 SELESAI
            EditWebhook(msgIdBreak,
                "🔨 **[FASE 4 — BREAK]** Siklus #"..cycleNum.." ✅ Selesai\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "⏱️ Durasi: `"..string.format("%02d:%02d", bm, bs).."`\n"..
                "🧱 Block tersisa: `"..blockSisa.."x`"
            )

            -- ════════════════════════════════
            -- FASE 5: DROP
            -- ════════════════════════════════
            if ShouldStop() then return end

            local seedSebelumDrop = GetItemAmountByID(getgenv().SelectedSeed)
            local msgIdDrop = nil
            SendWebhook(
                "📦 **[FASE 5 — DROP]** Siklus #"..cycleNum.." ⏳\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "🌿 Seed: `"..seedSebelumDrop.."x`  |  Keep: `"..getgenv().KeepSeedAmt.."`\n"..
                "📤 Akan drop: `"..(math.max(0, seedSebelumDrop - getgenv().KeepSeedAmt)).."x`",
                function(id) msgIdDrop = id end
            )

            local droppedThisCycle = DoDropSeedLoop()
            getgenv().TotalDropAllTime = getgenv().TotalDropAllTime + droppedThisCycle
            getgenv().CycleCount       = getgenv().CycleCount + 1
            print("[Drop] Cycle:", droppedThisCycle, "| Total:", getgenv().TotalDropAllTime)

            -- DETAIL: FASE 5 SELESAI + edit ringkasan ke pesan siklus
            local ringkasan =
                "━━━━━━━━━━━━━━━━━━━━━━\n"..
                "📊 **RINGKASAN SIKLUS #"..getgenv().CycleCount.."**\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "🌿 `"..getgenv().SelectedSeed.."`  |  🧱 `"..getgenv().SelectedBlock.."`\n"..
                "🌱 Plant: `"..plantedCount.."x`  ⛔ Skip: `"..skippedCount.."`\n"..
                "⛏️ Harvest: `"..blockGained.."x` blk  `"..seedGained.."x` seed\n"..
                "🔨 Break: `"..string.format("%02d:%02d", bm, bs).."` | Sisa: `"..blockSisa.."x`\n"..
                "📦 Drop: `"..droppedThisCycle.."x`  |  Total: `"..getgenv().TotalDropAllTime.."x`"
            EditWebhook(msgIdDrop,
                "📦 **[FASE 5 — DROP]** Siklus #"..getgenv().CycleCount.." ✅ Selesai\n"..
                "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                "📤 Seed di-drop: `"..droppedThisCycle.."x`\n"..
                "🌿 Seed tersisa: `"..GetItemAmountByID(getgenv().SelectedSeed).."x`\n"..
                "📦 Total all time: `"..getgenv().TotalDropAllTime.."x`"
            )
            EditWebhook(msgIdSiklus,
                "🚀 **[SIKLUS #"..getgenv().CycleCount.."]** ✅ Selesai\n"..ringkasan
            )

            print("[Pabrik] Siklus", getgenv().CycleCount, "selesai!")
        end)
        if not ok then
            if tostring(err):find("__RESTART__") then
                print("[Pabrik] Restart cycle diminta")
                getgenv().PabrikRestartCycle = false
                getgenv().PabrikPaused = false
                pcall(function() pauseToggleRef:Set(false) end)
            else
                warn("[Pabrik] Error:", err)
            end
        end
        -- Jangan reset PabrikIsRunning kalau lagi pause (nanti loop akan mulai siklus baru)
        if not getgenv().PabrikPaused then
            getgenv().PabrikIsRunning = false
        end
        end
    end
end)

-- Simpan referensi coroutine supaya bisa di-kill dari loader
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

    local blockDropRef = MainTab:CreateDropdown({
        Name="Select Block", Options=availableItems, CurrentOption=availableItems[1], Flag="PabrikBlockDrop",
        Callback=function(opt)
            local id = type(opt)=="table" and tostring(opt[1] or "") or tostring(opt)
            getgenv().SelectedBlock = id
            Rayfield:Notify({Title="Block", Content=id, Duration=2})
        end,
    })
    local seedDropRef = MainTab:CreateDropdown({
        Name="Select Seed", Options=availableItems, CurrentOption=availableItems[1], Flag="PabrikSeedDrop",
        Callback=function(opt)
            local id = type(opt)=="table" and tostring(opt[1] or "") or tostring(opt)
            getgenv().SelectedSeed = id
            Rayfield:Notify({Title="Seed", Content=id, Duration=2})
        end,
    })
    MainTab:CreateButton({
        Name = "🔄 Refresh Item List",
        Callback = function()
            local items = ScanAvailableItems()
            local ok1 = pcall(function() blockDropRef:Refresh(items) end)
            if not ok1 then pcall(function() blockDropRef:UpdateOptions(items) end) end
            local ok2 = pcall(function() seedDropRef:Refresh(items) end)
            if not ok2 then pcall(function() seedDropRef:UpdateOptions(items) end) end
            Rayfield:Notify({Title="Refresh", Content=#items.." item ditemukan!", Duration=2})
        end
    })

    MainTab:CreateInput({Name="Keep Seed Amount", PlaceholderText="20", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().KeepSeedAmt=n end end})
    MainTab:CreateInput({Name="Block Threshold", PlaceholderText="1", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().BlockThreshold=n end end})

    local pauseToggleRef = nil
    local enableToggleRef = nil

    local _toggleLock = false

    pauseToggleRef = MainTab:CreateToggle({
        Name="⏸️ Pause Pabrik", CurrentValue=false, Flag="PausePabrikToggle",
        Callback=function(v)
            if _toggleLock then return end
            if v and not getgenv().EnablePabrik then
                _toggleLock = true
                pcall(function() pauseToggleRef:Set(false) end)
                _toggleLock = false
                Rayfield:Notify({Title="⚠️", Content="Enable Pabrik dulu sebelum pause.", Duration=2})
                return
            end
            getgenv().PabrikPaused = v
            if v then
                -- Pause ON → set EnablePabrik false (bot freeze), UI Enable → OFF
                getgenv().EnablePabrik = false
                _toggleLock = true
                pcall(function() enableToggleRef:Set(false) end)
                _toggleLock = false
                Rayfield:Notify({Title="⏸️ Paused", Content="Bot berhenti di titik ini.", Duration=3})
                SendWebhook(
                    "⏸️ **[PABRIK DIPAUSE]**\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "🏭 Siklus: `"..getgenv().CycleCount.."`  |  Lanjut saat di-resume"
                )
            else
                -- Pause OFF → resume, UI Enable → ON
                getgenv().EnablePabrik = true
                getgenv().PabrikPaused = false
                getgenv().PabrikIsRunning = false  -- reset supaya siklus baru bisa mulai kalau yang lama sudah selesai
                _toggleLock = true
                pcall(function() enableToggleRef:Set(true) end)
                _toggleLock = false
                Rayfield:Notify({Title="▶️ Resumed", Content="Bot lanjut dari titik terakhir.", Duration=3})
                SendWebhook(
                    "▶️ **[PABRIK DIRESUMED]**\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`"
                )
            end
        end,
    })

    enableToggleRef = MainTab:CreateToggle({
        Name="Enable Pabrik", CurrentValue=false, Flag="EnablePabrikToggle",
        Callback=function(v)
            if _toggleLock then return end
            if v then
                -- Enable ON → fresh start, pastikan pause off
                getgenv().EnablePabrik = true
                getgenv().PabrikPaused = false
                getgenv().PabrikStartTime = os.time()
                _toggleLock = true
                pcall(function() pauseToggleRef:Set(false) end)
                _toggleLock = false
                SendWebhook(
                    "✅ **[PABRIK DINYALAKAN]**\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "🌿 Seed: `"..getgenv().SelectedSeed.."`  |  🧱 Block: `"..getgenv().SelectedBlock.."`"
                )
                print("[Pabrik] Enable: true")
            else
                -- Enable OFF → stop beneran
                getgenv().EnablePabrik = false
                getgenv().PabrikPaused = false
                getgenv().PabrikIsRunning = false
                _toggleLock = true
                pcall(function() pauseToggleRef:Set(false) end)
                _toggleLock = false
                SendWebhook(
                    "🛑 **[PABRIK DIMATIKAN MANUAL]**\n"..
                    "👤 `"..LP.Name.."`  |  🕐 `"..FormatElapsed().."`\n"..
                    "🏭 Siklus selesai: `"..getgenv().CycleCount.."`\n"..
                    "📦 Total drop: `"..getgenv().TotalDropAllTime.."x`"
                )
                print("[Pabrik] Enable: false")
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

if not uiOk then
    warn("[Pabrik] UI Error: "..tostring(uiErr))
end

print("[Pabrik v3] Load selesai! Heartbeat:", getgenv().RaihjnHeartbeatPabrik ~= nil)
