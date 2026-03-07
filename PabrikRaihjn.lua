-- ============================================================
-- SCRIPT PABRIK v2 - DENGAN WEBHOOK, BLOCK DETECTOR, SMART HARVEST
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
local HttpService = game:GetService("HttpService")

LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Globals
getgenv().GridSize       = 4.5
getgenv().HitCount       = 3
getgenv().EnablePabrik   = false
getgenv().PabrikStartX   = 0
getgenv().PabrikEndX     = 10
getgenv().PabrikStartY   = 37
getgenv().PabrikEndY     = 37
getgenv().GrowthTime     = 30
getgenv().BreakPosX      = 0
getgenv().BreakPosY      = 0
getgenv().DropPosX       = 0
getgenv().DropPosY       = 0
getgenv().BlockThreshold = 20
getgenv().KeepSeedAmt    = 20
getgenv().SelectedSeed   = ""
getgenv().SelectedBlock  = ""
getgenv().IsGhosting     = false
getgenv().HoldCFrame     = nil
getgenv().PlantHitCount  = 2
getgenv().YGap           = 2
getgenv().PlaceDelay     = 0.1
getgenv().DropDelay      = 0.5
getgenv().StepDelay      = 0.1
getgenv().BreakDelay     = 0.15

-- Stats untuk webhook
getgenv().TotalDropAllTime = getgenv().TotalDropAllTime or 0
getgenv().CycleCount       = getgenv().CycleCount or 0

-- Load modul
local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

local InventoryMod
pcall(function() InventoryMod = require(RS:WaitForChild("Modules"):WaitForChild("Inventory")) end)

local UIManager
pcall(function() UIManager = require(RS:WaitForChild("Managers"):WaitForChild("UIManager")) end)

-- ============================================================
-- WEBHOOK
-- ============================================================
local function SendWebhook(content)
    local url = getgenv().WebhookURL
    if not url or url == "" then return end
    pcall(function()
        local body = HttpService:JSONEncode({content = content})
        syn and syn.request and syn.request({
            Url    = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body   = body,
        }) or (http and http.request or request)({
            Url    = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body   = body,
        })
    end)
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

local function EnsurePosition(targetX, targetY)
    local cx, cy = GetMyPosition()
    if cx ~= targetX or cy ~= targetY then
        SetHitBoxPos(targetX, targetY)
        task.wait(0.1)
    end
end

-- ============================================================
-- DETEKSI BLOCK PENGHALANG
-- Cek apakah ada block solid di tile (gx, gy) di world
-- ============================================================
local function IsBlockedTile(gx, gy)
    -- Cek di Blocks/Tiles folder di workspace
    local worldPos = Vector3.new(gx * getgenv().GridSize, gy * getgenv().GridSize, 0)
    for _, fname in ipairs({"Blocks","Tiles","World","Map","Chunks","Terrain"}) do
        local folder = workspace:FindFirstChild(fname)
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local dx = math.floor(obj.Position.X / getgenv().GridSize + 0.5)
                    local dy = math.floor(obj.Position.Y / getgenv().GridSize + 0.5)
                    if dx == gx and dy == gy then
                        -- Ada block solid di tile ini
                        return true
                    end
                end
            end
        end
    end
    -- Raycast versi cepat (opsional fallback)
    local ray = workspace:Raycast(
        worldPos + Vector3.new(0, 0, 5),
        Vector3.new(0, 0, -10),
        RaycastParams.new()
    )
    if ray and ray.Instance then
        local dx = math.floor(ray.Instance.Position.X / getgenv().GridSize + 0.5)
        local dy = math.floor(ray.Instance.Position.Y / getgenv().GridSize + 0.5)
        if dx == gx and dy == gy and ray.Instance.Parent ~= workspace:FindFirstChild("Hitbox") then
            return true
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
                        if isSapling then return true end
                    end
                end
            end
        end
    end
    return false
end

local function DropItemLogic(targetID, dropAmount)
    local slot    = GetSlotByItemID(targetID)
    if not slot then return false end
    local dropR   = RS:WaitForChild("Remotes"):FindFirstChild("PlayerDrop") or RS:WaitForChild("Remotes"):FindFirstChild("PlayerDropItem")
    local promptR = RS:WaitForChild("Managers"):WaitForChild("UIManager"):FindFirstChild("UIPromptEvent")
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
    pcall(function()
        local targetUIs = {"topbar","gems","playerui","hotbar","crosshair","mainhud","stats","inventory","backpack","menu","bottombar","buttons"}
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScreenGui") or gui:IsA("ImageLabel") then
                local gName = string.lower(gui.Name)
                for _, tName in ipairs(targetUIs) do
                    if string.find(gName, tName) and not string.find(gName, "prompt") then
                        if gui:IsA("ScreenGui") then gui.Enabled=true else gui.Visible=true end
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
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = getgenv().HoldCFrame
        end
        if PlayerMovement then pcall(function()
            PlayerMovement.VelocityX=0; PlayerMovement.VelocityY=0
            PlayerMovement.VelocityZ=0; PlayerMovement.Grounded=true; PlayerMovement.Jumping=false
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
        PlayerMovement.VelocityX=0; PlayerMovement.VelocityY=0; PlayerMovement.VelocityZ=0
        PlayerMovement.Grounded = true
    end) end
end

local RemotePlace = RS:WaitForChild("Remotes"):WaitForChild("PlayerPlaceItem")
local RemoteBreak = RS:WaitForChild("Remotes"):WaitForChild("PlayerFist")

local function Doplant(gx, gy, slot)
    local v2 = Vector2.new(gx, gy)
    for i = 1, getgenv().PlantHitCount do
        pcall(function() RemotePlace:FireServer(v2, slot) end)
        if i < getgenv().PlantHitCount then task.wait(getgenv().PlaceDelay) end
    end
end

local function DoBreak(gx, gy)
    local v2 = Vector2.new(gx, gy)
    for _ = 1, getgenv().HitCount do
        if not getgenv().EnablePabrik then break end
        SetHitBoxPos(gx, gy)
        pcall(function() RemoteBreak:FireServer(v2) end)
        task.wait(getgenv().BreakDelay)
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1)
        local success, err = pcall(function()
            if not getgenv().EnablePabrik then return end
            if getgenv().SelectedSeed == "" or getgenv().SelectedBlock == "" then
                print("Menunggu seed dan block dipilih..."); return
            end

            -- -----------------------------------------------
            -- CEK AWAL: block sudah banyak, farm block dulu
            -- -----------------------------------------------
            local blockAmtAwal = GetItemAmountByID(getgenv().SelectedBlock)
            if blockAmtAwal > getgenv().BlockThreshold then
                print("[Awal] Block banyak ("..blockAmtAwal.."), farm block dulu")
                walkToGrid(getgenv().BreakPosX, getgenv().BreakPosY)
                EnsurePosition(getgenv().BreakPosX, getgenv().BreakPosY)
                task.wait(0.5)
                local BreakTargetAwal = Vector2.new(getgenv().BreakPosX-1, getgenv().BreakPosY)
                while getgenv().EnablePabrik do
                    local amt = GetItemAmountByID(getgenv().SelectedBlock)
                    if amt <= getgenv().BlockThreshold then break end
                    local bslot = GetSlotByItemID(getgenv().SelectedBlock)
                    if not bslot then break end
                    pcall(function() RemotePlace:FireServer(BreakTargetAwal, bslot) end)
                    task.wait(0.15)
                    for _ = 1, getgenv().HitCount do
                        if not getgenv().EnablePabrik then break end
                        SetHitBoxPos(getgenv().BreakPosX, getgenv().BreakPosY)
                        pcall(function() RemoteBreak:FireServer(BreakTargetAwal) end)
                        task.wait(getgenv().BreakDelay)
                    end
                    if CheckDropsAtGrid(BreakTargetAwal.X, BreakTargetAwal.Y) then
                        local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
                        local hum=char and char:FindFirstChildOfClass("Humanoid"); local mh=GetMyHitbox()
                        local eCF=hrp and hrp.CFrame; local eHCF=mh and mh.CFrame; local ePM
                        if PlayerMovement then pcall(function() ePM=PlayerMovement.Position end) end
                        if hrp then hrp.Anchored=true; getgenv().HoldCFrame=eCF; getgenv().IsGhosting=true end
                        if hum then
                            local anim=hum:FindFirstChildOfClass("Animator")
                            local tracks=anim and anim:GetPlayingAnimationTracks() or hum:GetPlayingAnimationTracks()
                            for _,t in ipairs(tracks) do t:Stop(0) end
                        end
                        walkToGrid(BreakTargetAwal.X, BreakTargetAwal.Y)
                        EnsurePosition(BreakTargetAwal.X, BreakTargetAwal.Y)
                        local t=0
                        while CheckDropsAtGrid(BreakTargetAwal.X, BreakTargetAwal.Y) and t<15 and getgenv().EnablePabrik do task.wait(0.1); t=t+1 end
                        task.wait(0.1)
                        walkToGrid(getgenv().BreakPosX, getgenv().BreakPosY)
                        EnsurePosition(getgenv().BreakPosX, getgenv().BreakPosY)
                        if hrp and eCF then
                            hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero
                            if mh and eHCF then mh.CFrame=eHCF; mh.AssemblyLinearVelocity=Vector3.zero end
                            hrp.CFrame=eCF
                            if PlayerMovement and ePM then pcall(function()
                                PlayerMovement.Position=ePM; PlayerMovement.OldPosition=ePM
                                PlayerMovement.VelocityX=0; PlayerMovement.VelocityY=0; PlayerMovement.VelocityZ=0; PlayerMovement.Grounded=true
                            end) end
                            RunService.Heartbeat:Wait(); RunService.Heartbeat:Wait()
                            hrp.Anchored=false
                        end
                        getgenv().IsGhosting=false
                    end
                end
                if not getgenv().EnablePabrik then return end
                -- Drop seed sebelum plant
                local seedAmtAwal = GetItemAmountByID(getgenv().SelectedSeed)
                if seedAmtAwal > getgenv().KeepSeedAmt then
                    local gs = StartGhost()
                    walkToGrid(getgenv().DropPosX, getgenv().DropPosY)
                    EnsurePosition(getgenv().DropPosX, getgenv().DropPosY)
                    task.wait(1.5)
                    local droppedAwal = 0
                    while getgenv().EnablePabrik do
                        local cur=GetItemAmountByID(getgenv().SelectedSeed); local toDrop=cur-getgenv().KeepSeedAmt
                        if toDrop<=0 then break end
                        local ok=DropItemLogic(getgenv().SelectedSeed, math.min(toDrop,200))
                        if ok then droppedAwal=droppedAwal+math.min(toDrop,200); task.wait(getgenv().DropDelay+0.3) else break end
                    end
                    StopGhost(gs)
                    ForceRestoreUI()
                    if droppedAwal > 0 then
                        getgenv().TotalDropAllTime = getgenv().TotalDropAllTime + droppedAwal
                    end
                end
                return
            end

            -- -----------------------------------------------
            -- FASE 1: PLANTING (skip tile yang ada block)
            -- -----------------------------------------------
            local plantPath = ZigzagPath(
                getgenv().PabrikStartX, getgenv().PabrikEndX,
                getgenv().PabrikStartY, getgenv().PabrikEndY, getgenv().YGap
            )
            print("[Plant] Total tile:", #plantPath)

            local lastPlantedX, lastPlantedY = nil, nil
            local plantedTiles = {}  -- simpan urutan tile yang berhasil di-plant
            local skippedCount  = 0

            for i, point in ipairs(plantPath) do
                if not getgenv().EnablePabrik then break end

                -- Cek block penghalang sebelum plant
                if IsBlockedTile(point.X, point.Y) then
                    print("[Plant] Tile", point.X, point.Y, "ada block, skip")
                    skippedCount = skippedCount + 1
                    -- jangan tambah ke plantedTiles, lanjut
                else
                    local slot = GetSlotByItemID(getgenv().SelectedSeed)
                    if not slot then
                        print("[Plant] Seed habis di tile", i)
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

            -- Log berapa yang di-skip
            if skippedCount > 0 then
                print("[Plant] Skip "..skippedCount.." tile karena ada block")
            end

            -- Tentukan tile terakhir yang di-plant
            local plantedCount = #plantedTiles
            print("[Plant] Selesai. Planted:", plantedCount, "tile. Terakhir:", tostring(lastPlantedX), tostring(lastPlantedY))

            -- Kirim webhook: info plant
            if lastPlantedX then
                task.spawn(function()
                    SendWebhook(
                        "**[PABRIK] PLANT SELESAI**\n" ..
                        "👤 Player: `" .. LP.Name .. "`\n" ..
                        "🌱 Seed: `" .. getgenv().SelectedSeed .. "`\n" ..
                        "📍 Plant sampai: `X=" .. lastPlantedX .. " Y=" .. lastPlantedY .. "`\n" ..
                        "✅ Total tile di-plant: `" .. plantedCount .. "`\n" ..
                        "⛔ Tile di-skip (ada block): `" .. skippedCount .. "`"
                    )
                end)
            end

            -- -----------------------------------------------
            -- FASE 2: WAITING
            -- -----------------------------------------------
            if not getgenv().EnablePabrik then return end
            print("[Wait] Tunggu", getgenv().GrowthTime, "detik")
            for _ = 1, getgenv().GrowthTime do
                if not getgenv().EnablePabrik then break end
                task.wait(1)
            end

            -- -----------------------------------------------
            -- FASE 3: HARVEST (hanya tile yang di-plant)
            -- -----------------------------------------------
            if not getgenv().EnablePabrik then return end
            print("[Harvest] Mulai, harvest", #plantedTiles, "tile yang di-plant")

            for _, point in ipairs(plantedTiles) do
                if not getgenv().EnablePabrik then break end
                walkToGrid(point.X, point.Y)
                EnsurePosition(point.X, point.Y)
                if not getgenv().EnablePabrik then break end
                DoBreak(point.X, point.Y)
            end

            -- Sweep balik TANPA ghosting (pickup biasa)
            if getgenv().EnablePabrik then
                print("[Harvest] Sweep balik pickup")
                for i = #plantedTiles, 1, -1 do
                    if not getgenv().EnablePabrik then break end
                    walkToGrid(plantedTiles[i].X, plantedTiles[i].Y)
                    EnsurePosition(plantedTiles[i].X, plantedTiles[i].Y)
                    task.wait(0.05)
                end
            end

            -- -----------------------------------------------
            -- FASE 4: FARM BLOCK
            -- -----------------------------------------------
            if not getgenv().EnablePabrik then return end
            print("[Block] Farm block")
            walkToGrid(getgenv().BreakPosX, getgenv().BreakPosY)
            EnsurePosition(getgenv().BreakPosX, getgenv().BreakPosY)
            task.wait(0.5)
            local BreakTarget = Vector2.new(getgenv().BreakPosX-1, getgenv().BreakPosY)

            while getgenv().EnablePabrik do
                local currentAmt = GetItemAmountByID(getgenv().SelectedBlock)
                if currentAmt <= getgenv().BlockThreshold then print("[Block] Threshold. Amt:", currentAmt); break end
                local blockSlot = GetSlotByItemID(getgenv().SelectedBlock)
                if not blockSlot then print("[Block] Slot nil!"); break end
                pcall(function() RemotePlace:FireServer(BreakTarget, blockSlot) end)
                task.wait(0.15)
                for _ = 1, getgenv().HitCount do
                    if not getgenv().EnablePabrik then break end
                    SetHitBoxPos(getgenv().BreakPosX, getgenv().BreakPosY)
                    pcall(function() RemoteBreak:FireServer(BreakTarget) end)
                    task.wait(getgenv().BreakDelay)
                end
                if CheckDropsAtGrid(BreakTarget.X, BreakTarget.Y) then
                    local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
                    local hum=char and char:FindFirstChildOfClass("Humanoid"); local mh=GetMyHitbox()
                    local eCF=hrp and hrp.CFrame; local eHCF=mh and mh.CFrame; local ePM
                    if PlayerMovement then pcall(function() ePM=PlayerMovement.Position end) end
                    if hrp then hrp.Anchored=true; getgenv().HoldCFrame=eCF; getgenv().IsGhosting=true end
                    if hum then
                        local anim=hum:FindFirstChildOfClass("Animator")
                        local tracks=anim and anim:GetPlayingAnimationTracks() or hum:GetPlayingAnimationTracks()
                        for _,t in ipairs(tracks) do t:Stop(0) end
                    end
                    walkToGrid(BreakTarget.X, BreakTarget.Y)
                    EnsurePosition(BreakTarget.X, BreakTarget.Y)
                    local t=0
                    while CheckDropsAtGrid(BreakTarget.X, BreakTarget.Y) and t<15 and getgenv().EnablePabrik do task.wait(0.1); t=t+1 end
                    task.wait(0.1)
                    walkToGrid(getgenv().BreakPosX, getgenv().BreakPosY)
                    EnsurePosition(getgenv().BreakPosX, getgenv().BreakPosY)
                    if hrp and eCF then
                        hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero
                        if mh and eHCF then mh.CFrame=eHCF; mh.AssemblyLinearVelocity=Vector3.zero end
                        hrp.CFrame=eCF
                        if PlayerMovement and ePM then pcall(function()
                            PlayerMovement.Position=ePM; PlayerMovement.OldPosition=ePM
                            PlayerMovement.VelocityX=0; PlayerMovement.VelocityY=0; PlayerMovement.VelocityZ=0; PlayerMovement.Grounded=true
                        end) end
                        RunService.Heartbeat:Wait(); RunService.Heartbeat:Wait()
                        hrp.Anchored=false
                    end
                    getgenv().IsGhosting=false
                end
            end

            -- -----------------------------------------------
            -- FASE 5: DROP SEED + WEBHOOK
            -- -----------------------------------------------
            if not getgenv().EnablePabrik then return end
            local currentSeedAmt = GetItemAmountByID(getgenv().SelectedSeed)
            print("[Drop] Seed:", currentSeedAmt, "Keep:", getgenv().KeepSeedAmt)
            local droppedThisCycle = 0

            if currentSeedAmt > getgenv().KeepSeedAmt then
                local gs = StartGhost()
                walkToGrid(getgenv().DropPosX, getgenv().DropPosY)
                EnsurePosition(getgenv().DropPosX, getgenv().DropPosY)
                task.wait(1.5)
                while getgenv().EnablePabrik do
                    local cur    = GetItemAmountByID(getgenv().SelectedSeed)
                    local toDrop = cur - getgenv().KeepSeedAmt
                    if toDrop <= 0 then break end
                    local batch = math.min(toDrop, 200)
                    local ok    = DropItemLogic(getgenv().SelectedSeed, batch)
                    if ok then
                        droppedThisCycle = droppedThisCycle + batch
                        task.wait(getgenv().DropDelay + 0.3)
                    else
                        break
                    end
                end
                StopGhost(gs)
                ForceRestoreUI()
            end

            -- Update total
            getgenv().TotalDropAllTime = getgenv().TotalDropAllTime + droppedThisCycle
            getgenv().CycleCount       = getgenv().CycleCount + 1

            print("[Drop] Cycle drop:", droppedThisCycle, "| Total all time:", getgenv().TotalDropAllTime)

            -- Kirim webhook: info drop per cycle
            task.spawn(function()
                SendWebhook(
                    "**[PABRIK] SIKLUS #" .. getgenv().CycleCount .. " SELESAI**\n" ..
                    "👤 Player: `" .. LP.Name .. "`\n" ..
                    "🌱 Seed dropped cycle ini: `" .. droppedThisCycle .. "x`\n" ..
                    "📦 Total seed dropped all time: `" .. getgenv().TotalDropAllTime .. "x`\n" ..
                    "📍 Plant terakhir di: `X=" .. tostring(lastPlantedX) .. " Y=" .. tostring(lastPlantedY) .. "`\n" ..
                    "🌿 Tile di-plant: `" .. plantedCount .. "` | Skip (block): `" .. skippedCount .. "`"
                )
            end)

            print("[Pabrik] Siklus", getgenv().CycleCount, "selesai!")
        end)
        if not success then warn("Error loop Pabrik:", err) end
    end
end)

-- ============================================================
-- UI
-- ============================================================
local Rayfield = getgenv().Rayfield
if not Rayfield then warn("Rayfield tidak ditemukan!"); return end

local MainTab = getgenv().RaihjnTab
if not MainTab then warn("RaihjnTab tidak ditemukan!"); return end

local ok, err = pcall(function()
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

    MainTab:CreateDropdown({
        Name="Select Block", Options=availableItems, CurrentOption=availableItems[1], Flag="BlockDropdown",
        Callback=function(opt)
            local id = type(opt)=="table" and tostring(opt[1] or "") or tostring(opt)
            getgenv().SelectedBlock=id
            Rayfield:Notify({Title="Block Selected", Content=id, Duration=3})
        end,
    })
    MainTab:CreateDropdown({
        Name="Select Seed", Options=availableItems, CurrentOption=availableItems[1], Flag="SeedDropdown",
        Callback=function(opt)
            local id = type(opt)=="table" and tostring(opt[1] or "") or tostring(opt)
            getgenv().SelectedSeed=id
            Rayfield:Notify({Title="Seed Selected", Content=id, Duration=3})
        end,
    })
    MainTab:CreateInput({Name="Keep Seed Amount", PlaceholderText="Jumlah seed disimpan", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().KeepSeedAmt=n end end})
    MainTab:CreateInput({Name="Block Threshold", PlaceholderText="Jumlah block minimum", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().BlockThreshold=n end end})

    MainTab:CreateToggle({
        Name="Enable Pabrik", CurrentValue=false, Flag="EnablePabrikToggle",
        Callback=function(v) getgenv().EnablePabrik=v; print("EnablePabrik:", v) end,
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
        local mh=GetMyHitbox(); if mh then
            local bx=math.floor(mh.Position.X/getgenv().GridSize+0.5)
            local by=math.floor(mh.Position.Y/getgenv().GridSize+0.5)
            getgenv().BreakPosX=bx; getgenv().BreakPosY=by
            BPX:Set(tostring(bx)); BPY:Set(tostring(by))
            Rayfield:Notify({Title="Break Pos", Content="X:"..bx.." Y:"..by, Duration=3})
        end
    end})

    MainTab:CreateSection("Drop Position")
    local DPX = MainTab:CreateInput({Name="Drop Pos X", PlaceholderText="X posisi drop", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().DropPosX=n end end})
    local DPY = MainTab:CreateInput({Name="Drop Pos Y", PlaceholderText="Y posisi drop", RemoveTextAfterFocusLost=false,
        Callback=function(t) local n=tonumber(t); if n then getgenv().DropPosY=n end end})
    MainTab:CreateButton({Name="Set Drop Pos (Current)", Callback=function()
        local mh=GetMyHitbox(); if mh then
            local dx=math.floor(mh.Position.X/getgenv().GridSize+0.5)
            local dy=math.floor(mh.Position.Y/getgenv().GridSize+0.5)
            getgenv().DropPosX=dx; getgenv().DropPosY=dy
            DPX:Set(tostring(dx)); DPY:Set(tostring(dy))
            Rayfield:Notify({Title="Drop Pos", Content="X:"..dx.." Y:"..dy, Duration=3})
        end
    end})

    MainTab:CreateSection("Webhook")
    MainTab:CreateButton({Name="Test Webhook", Callback=function()
        local url = getgenv().WebhookURL
        if not url or url=="" then
            Rayfield:Notify({Title="Webhook", Content="URL belum di-set di loader!", Duration=3}); return
        end
        task.spawn(function()
            SendWebhook("**[TEST]** Webhook dari `"..LP.Name.."` berhasil terhubung!")
        end)
        Rayfield:Notify({Title="Webhook", Content="Test dikirim!", Duration=3})
    end})

    MainTab:CreateSection("Stats")
    MainTab:CreateButton({Name="Lihat Stats (F9)", Callback=function()
        print("[Stats] Cycle:", getgenv().CycleCount, "| Total Drop:", getgenv().TotalDropAllTime)
        Rayfield:Notify({
            Title   = "Stats",
            Content = "Cycle: "..getgenv().CycleCount.."\nTotal Drop: "..getgenv().TotalDropAllTime,
            Duration = 5,
        })
    end})
    MainTab:CreateButton({Name="Reset Stats", Callback=function()
        getgenv().TotalDropAllTime=0; getgenv().CycleCount=0
        Rayfield:Notify({Title="Stats", Content="Stats di-reset", Duration=3})
    end})
end)

if not ok then warn("Error UI pabrik:", err) end

