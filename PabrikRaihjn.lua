-- World Scan - Standalone
-- Scan: sapling di Drops (planted) + item biasa di Drops
-- Data tanaman server-side, tidak bisa dibaca dari client

local Players    = game:GetService("Players")
local LP         = Players.LocalPlayer
local GridSize   = getgenv().GridSize or 4.5

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name             = "World Scan",
    LoadingTitle     = "World Scan",
    LoadingSubtitle  = "by RaihjnDev",
    ConfigurationSaving = { Enabled = false },
    KeySystem        = false,
})

local ScanTab = Window:CreateTab("Scanner", nil)

local function GridPos(pos)
    return
        math.floor(pos.X / GridSize + 0.5),
        math.floor(pos.Y / GridSize + 0.5)
end

local function ScanWorld()
    local saplings  = {}
    local items     = {}
    local sapCount  = 0
    local itemCount = 0

    local folder = workspace:FindFirstChild("Drops")
    if not folder then return saplings, items, 0, 0 end

    for _, obj in ipairs(folder:GetChildren()) do
        local id  = obj:GetAttribute("id")
        local amt = obj:GetAttribute("amount") or 1
        if id then
            local pos = nil
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if p then pos = p.Position end
            end
            local gx, gy = 0, 0
            if pos then gx, gy = GridPos(pos) end

            local isSapling = tostring(id):lower():find("sapling") ~= nil
            local tbl = isSapling and saplings or items

            if tbl[id] then
                tbl[id].count = tbl[id].count + amt
                tbl[id].objs  = tbl[id].objs + 1
            else
                tbl[id] = {id=id, count=amt, objs=1, x=gx, y=gy}
            end

            if isSapling then sapCount = sapCount + 1
            else itemCount = itemCount + 1 end
        end
    end

    return saplings, items, sapCount, itemCount
end

local function RunScan()
    Rayfield:Notify({Title="Scanning...", Content="Sedang scan world", Duration=2})
    task.wait(0.3)

    local saplings, items, sapCount, itemCount = ScanWorld()

    -- Sapling lines
    local sapLines = {}
    for id, d in pairs(saplings) do
        table.insert(sapLines, string.format("[%s] x%d (%d obj) @ X%d Y%d", d.id, d.count, d.objs, d.x, d.y))
    end
    table.sort(sapLines)

    -- Item lines
    local itemLines = {}
    for id, d in pairs(items) do
        table.insert(itemLines, string.format("[%s] x%d (%d obj) @ X%d Y%d", d.id, d.count, d.objs, d.x, d.y))
    end
    table.sort(itemLines)

    -- Console output
    print("========== WORLD SCAN ==========")
    print(string.format(">> SAPLING/PLANTED: %d jenis, %d total", #sapLines, sapCount))
    if #sapLines == 0 then
        print("  (tidak ada sapling di world)")
    else
        for _, l in ipairs(sapLines) do print("  "..l) end
    end
    print(string.format(">> ITEM DROP: %d jenis, %d total obj", #itemLines, itemCount))
    if #itemLines == 0 then
        print("  (tidak ada item drop)")
    else
        for _, l in ipairs(itemLines) do print("  "..l) end
    end
    print("================================")

    -- Notify
    Rayfield:Notify({
        Title   = "Sapling: "..(#sapLines).." jenis / "..sapCount.." total",
        Content = #sapLines > 0 and table.concat(sapLines, "\n"):sub(1,250) or "(kosong)",
        Duration = 10,
    })
    task.wait(0.5)
    Rayfield:Notify({
        Title   = "Items: "..(#itemLines).." jenis / "..itemCount.." obj",
        Content = #itemLines > 0 and table.concat(itemLines, "\n"):sub(1,250) or "(kosong)",
        Duration = 10,
    })
end

-- ============================================================
-- UI
-- ============================================================
ScanTab:CreateSection("World Scanner")

ScanTab:CreateButton({
    Name = "Scan Sekarang",
    Callback = function()
        task.spawn(RunScan)
    end,
})

ScanTab:CreateButton({
    Name = "Debug: Workspace Structure",
    Callback = function()
        print("===== WORKSPACE =====")
        for _, child in ipairs(workspace:GetChildren()) do
            print("  "..child.Name.." ["..child.ClassName.."]")
            for _, sub in ipairs(child:GetChildren()) do
                print("    -> "..sub.Name.." ["..sub.ClassName.."]")
            end
        end
        print("====================")
        Rayfield:Notify({Title="Debug", Content="Lihat console", Duration=3})
    end,
})

ScanTab:CreateButton({
    Name = "Debug: Scan Tiles Sekitar",
    Callback = function()
        print("===== TILES SEKITAR POSISI =====")
        local hb = workspace:FindFirstChild("Hitbox")
        local myPart = hb and (hb:FindFirstChild(game.Players.LocalPlayer.Name) or hb:FindFirstChildWhichIsA("BasePart"))
        if not myPart then print("Hitbox tidak ditemukan"); return end

        local GS  = getgenv().GridSize or 4.5
        local myX = math.floor(myPart.Position.X / GS + 0.5)
        local myY = math.floor(myPart.Position.Y / GS + 0.5)
        print("Posisi saya: Grid X"..myX.." Y"..myY)

        local tiles = workspace:FindFirstChild("Tiles")
        if not tiles then print("Tiles tidak ada"); return end

        -- Scan semua Part di Tiles, bandingkan yang dekat vs yang jauh
        -- Kumpulkan semua properti unik
        local near  = {}  -- dalam radius 5 grid
        local total = 0

        for _, child in ipairs(tiles:GetChildren()) do
            if child:IsA("BasePart") then
                total = total + 1
                local gx = math.floor(child.Position.X / GS + 0.5)
                local gy = math.floor(child.Position.Y / GS + 0.5)
                local dist = math.abs(gx - myX) + math.abs(gy - myY)
                if dist <= 5 then
                    table.insert(near, {
                        gx=gx, gy=gy, dist=dist,
                        name=child.Name,
                        size=tostring(child.Size),
                        color=tostring(child.Color),
                        material=tostring(child.Material),
                        transparency=child.Transparency,
                        castShadow=child.CastShadow,
                        children=#child:GetChildren(),
                    })
                end
            end
        end

        print("Total Part di Tiles: "..total)
        print("Part dalam radius 5 grid: "..#near)
        table.sort(near, function(a,b) return a.dist < b.dist end)

        for i, p in ipairs(near) do
            if i > 10 then break end
            print(string.format("  [X%d Y%d dist%d] name=%s size=%s color=%s mat=%s transp=%.2f shadow=%s children=%d",
                p.gx, p.gy, p.dist, p.name, p.size, p.color, p.material, p.transparency, tostring(p.castShadow), p.children))
        end

        -- Cek apakah ada Model (bukan Part) di Tiles yang dekat
        print("\nModel di Tiles sekitar:")
        for _, child in ipairs(tiles:GetChildren()) do
            if child:IsA("Model") then
                local pos = child.PrimaryPart and child.PrimaryPart.Position
                if not pos then
                    local p = child:FindFirstChildWhichIsA("BasePart")
                    if p then pos = p.Position end
                end
                if pos then
                    local gx = math.floor(pos.X / GS + 0.5)
                    local gy = math.floor(pos.Y / GS + 0.5)
                    local dist = math.abs(gx - myX) + math.abs(gy - myY)
                    if dist <= 5 then
                        print(string.format("  Model[%s] X%d Y%d dist%d children=%d", child.Name, gx, gy, dist, #child:GetChildren()))
                        for k,v in pairs(child:GetAttributes()) do
                            print("    attr: "..tostring(k).." = "..tostring(v))
                        end
                    end
                end
            end
        end

        print("================================")
        Rayfield:Notify({Title="Scan Tiles", Content=#near.." part ditemukan, lihat console", Duration=3})
    end,
})

ScanTab:CreateButton({
    Name = "Debug: Tiles Children Detail",
    Callback = function()
        print("===== TILES CHILDREN DETAIL =====")
        local GS    = getgenv().GridSize or 4.5
        local hb    = workspace:FindFirstChild("Hitbox")
        local myPart = hb and (hb:FindFirstChild(game.Players.LocalPlayer.Name) or hb:FindFirstChildWhichIsA("BasePart"))
        local myX, myY = 0, 0
        if myPart then
            myX = math.floor(myPart.Position.X / GS + 0.5)
            myY = math.floor(myPart.Position.Y / GS + 0.5)
        end
        print("Posisi saya: X"..myX.." Y"..myY)

        local tiles = workspace:FindFirstChild("Tiles")
        if not tiles then print("Tiles tidak ada"); return end

        local printed = 0
        for _, child in ipairs(tiles:GetChildren()) do
            if child:IsA("BasePart") then
                local gx = math.floor(child.Position.X / GS + 0.5)
                local gy = math.floor(child.Position.Y / GS + 0.5)
                local dist = math.abs(gx - myX) + math.abs(gy - myY)
                if dist <= 8 then
                    printed = printed + 1
                    print(string.format("[X%d Y%d dist%d] transp=%.2f children=%d",
                        gx, gy, dist, child.Transparency, #child:GetChildren()))
                    -- Print semua children
                    for _, c in ipairs(child:GetChildren()) do
                        print("  child: "..c.Name.." ["..c.ClassName.."]")
                        -- Semua attribute
                        for k,v in pairs(c:GetAttributes()) do
                            print("    attr: "..tostring(k).." = "..tostring(v))
                        end
                        -- Value objects
                        if c:IsA("StringValue") or c:IsA("IntValue") or c:IsA("NumberValue") or c:IsA("BoolValue") then
                            print("    value: "..tostring(c.Value))
                        end
                        -- Grandchildren
                        for _, gc in ipairs(c:GetChildren()) do
                            print("    gc: "..gc.Name.." ["..gc.ClassName.."]")
                            for k,v in pairs(gc:GetAttributes()) do
                                print("      attr: "..tostring(k).." = "..tostring(v))
                            end
                            if gc:IsA("StringValue") or gc:IsA("IntValue") or gc:IsA("NumberValue") then
                                print("      value: "..tostring(gc.Value))
                            end
                        end
                    end
                end
            end
        end
        print("Total dicetak: "..printed)
        print("================================")
        Rayfield:Notify({Title="Tiles Detail", Content=printed.." tile, lihat console", Duration=3})
    end,
})

ScanTab:CreateButton({
    Name = "Debug: Tiles ImageLabel",
    Callback = function()
        print("===== TILES IMAGELABEL SCAN =====")
        local GS     = getgenv().GridSize or 4.5
        local hb     = workspace:FindFirstChild("Hitbox")
        local myPart = hb and (hb:FindFirstChild(game.Players.LocalPlayer.Name) or hb:FindFirstChildWhichIsA("BasePart"))
        local myX, myY = 0, 0
        if myPart then
            myX = math.floor(myPart.Position.X / GS + 0.5)
            myY = math.floor(myPart.Position.Y / GS + 0.5)
        end
        print("Posisi saya: X"..myX.." Y"..myY)

        local tiles = workspace:FindFirstChild("Tiles")
        if not tiles then print("Tiles tidak ada"); return end

        local withImage = 0
        local noImage   = 0

        for _, child in ipairs(tiles:GetChildren()) do
            if child:IsA("BasePart") then
                local gx   = math.floor(child.Position.X / GS + 0.5)
                local gy   = math.floor(child.Position.Y / GS + 0.5)
                local dist = math.abs(gx - myX) + math.abs(gy - myY)

                -- Ambil semua ImageLabel dari SurfaceGui
                local gui = child:FindFirstChildWhichIsA("SurfaceGui")
                if gui then
                    local images = {}
                    for _, il in ipairs(gui:GetDescendants()) do
                        if il:IsA("ImageLabel") and il.Image ~= "" and il.Visible then
                            table.insert(images, il.Image)
                        end
                    end

                    if #images > 0 then
                        withImage = withImage + 1
                        if dist <= 10 then
                            print(string.format("[X%d Y%d dist%d] %d image(s):", gx, gy, dist, #images))
                            for i, img in ipairs(images) do
                                if i <= 3 then print("  img: "..img) end
                            end
                        end
                    else
                        noImage = noImage + 1
                    end
                end
            end
        end

        print("Tile dengan image (ada tanaman?): "..withImage)
        print("Tile tanpa image (kosong?): "..noImage)
        print("================================")
        Rayfield:Notify({
            Title   = "Tiles Scan",
            Content = "Ada image: "..withImage.." | Kosong: "..noImage,
            Duration = 5,
        })
    end,
})

ScanTab:CreateButton({
    Name = "Debug: Scan Semua Remotes",
    Callback = function()
        print("===== REMOTES SCAN =====")
        local RS = game:GetService("ReplicatedStorage")

        local function scanFolder(folder, indent)
            indent = indent or ""
            for _, child in ipairs(folder:GetChildren()) do
                local t = child.ClassName
                if t == "RemoteEvent" or t == "RemoteFunction" or t == "BindableEvent" or t == "BindableFunction" then
                    print(indent..child.Name.." ["..t.."]")
                elseif child:IsA("Folder") or child:IsA("Model") then
                    print(indent..child.Name.." ["..t.."]")
                    scanFolder(child, indent.."  ")
                end
            end
        end

        scanFolder(RS)

        -- Cek juga Players LocalPlayer scripts
        print("\n===== PLAYER SCRIPTS =====")
        local ps = game.Players.LocalPlayer:FindFirstChild("PlayerScripts")
        if ps then
            for _, child in ipairs(ps:GetChildren()) do
                print("  "..child.Name.." ["..child.ClassName.."]")
            end
        end
        print("========================")
        Rayfield:Notify({Title="Remotes", Content="Lihat console", Duration=3})
    end,
})

ScanTab:CreateButton({
    Name = "Debug: Test PlayerSetPosition",
    Callback = function()
        print("===== TEST PlayerSetPosition =====")
        local RS = game:GetService("ReplicatedStorage")
        local rem = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("PlayerSetPosition")
        if not rem then print("Remote tidak ditemukan"); return end

        -- Coba berbagai format parameter
        local GS = getgenv().GridSize or 4.5
        local hb = workspace:FindFirstChild("Hitbox")
        local myPart = hb and (hb:FindFirstChild(game.Players.LocalPlayer.Name) or hb:FindFirstChildWhichIsA("BasePart"))
        local cx, cy = 0, 0
        if myPart then
            cx = math.floor(myPart.Position.X / GS + 0.5)
            cy = math.floor(myPart.Position.Y / GS + 0.5)
        end
        local targetX = cx + 3  -- geser 3 ke kanan
        local targetY = cy

        print("Posisi sekarang: X"..cx.." Y"..cy)
        print("Target: X"..targetX.." Y"..targetY)
        print("Mencoba berbagai format...")

        -- Format 1: Vector3 world pos
        task.spawn(function()
            print("Format 1: Vector3 world")
            pcall(function() rem:FireServer(Vector3.new(targetX * GS, targetY * GS, 0)) end)
            task.wait(0.5)

            -- Format 2: x, y angka biasa
            print("Format 2: number x, y")
            pcall(function() rem:FireServer(targetX * GS, targetY * GS) end)
            task.wait(0.5)

            -- Format 3: grid x, y
            print("Format 3: grid x, y")
            pcall(function() rem:FireServer(targetX, targetY) end)
            task.wait(0.5)

            -- Format 4: CFrame
            print("Format 4: CFrame")
            pcall(function() rem:FireServer(CFrame.new(targetX * GS, targetY * GS, 0)) end)
            task.wait(0.5)

            -- Format 5: table {x, y}
            print("Format 5: table")
            pcall(function() rem:FireServer({x=targetX*GS, y=targetY*GS}) end)
            task.wait(0.5)

            -- Cek posisi setelah semua format
            if myPart then
                local nx = math.floor(myPart.Position.X / GS + 0.5)
                local ny = math.floor(myPart.Position.Y / GS + 0.5)
                print("Posisi setelah test: X"..nx.." Y"..ny)
                if nx ~= cx or ny ~= cy then
                    print("BERHASIL PINDAH!")
                else
                    print("Tidak bergerak - format salah atau butuh validasi server")
                end
            end
        end)

        Rayfield:Notify({Title="Test Teleport", Content="Testing 5 format, lihat console", Duration=6})
    end,
})

ScanTab:CreateButton({
    Name = "Debug: Drops Sample",
    Callback = function()
        print("===== DROPS SAMPLE =====")
        local folder = workspace:FindFirstChild("Drops")
        if not folder then print("Drops tidak ditemukan"); return end
        local children = folder:GetChildren()
        print("Total: "..#children)
        for i, obj in ipairs(children) do
            if i > 5 then print("  ...truncated"); break end
            print("  ["..i.."] "..obj.Name.." ["..obj.ClassName.."]")
            for k,v in pairs(obj:GetAttributes()) do
                print("    "..tostring(k).." = "..tostring(v))
            end
        end
        print("========================")
        Rayfield:Notify({Title="Debug Drops", Content=#children.." obj, lihat console", Duration=3})
    end,
})
