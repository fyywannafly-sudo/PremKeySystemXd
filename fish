local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:AddTheme({
    Name = "Fyy Exploit", 
    
    Accent = WindUI:Gradient({                                                  
        ["0"] = { Color = Color3.fromHex("#1f1f23"), Transparency = 0 },        
        ["100"]   = { Color = Color3.fromHex("#18181b"), Transparency = 0 },    
    }, {                                                                        
        Rotation = 0,                                                           
    }),                                                                         
    Dialog = Color3.fromHex("#161616"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Background = Color3.fromHex("#101010"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa")
})
local Window = WindUI:CreateWindow({
    Title = "FyyExploit",
    Icon = "slack", 
    Author = "Fyy X Mount",
    Folder = "FyyConfig",
    
    Size = UDim2.fromOffset(530, 300),
    MinSize = Vector2.new(320, 300),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 150,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    
    User = {
        Enabled = false,
        Anonymous = true,
        Callback = function()
            print("clicked")
        end,
    },
})

Window:SetToggleKey(Enum.KeyCode.G)

WindUI:Notify({
    Title = "FyyLoader",
    Content = "Press G To Open/Close Menu!",
    Duration = 4, 
    Icon = "slack",
})
---------------- TAB ---------------

local Info = Window:Tab({
    Title = "Info",
    Icon = "info", 
    Locked = false,
})

local Player = Window:Tab({
    Title = "Player",
    Icon = "user", 
    Locked = false,
})

local Auto = Window:Tab({
    Title = "Main",
    Icon = "play", 
    Locked = false,
})

local Shop = Window:Tab({
    Title = "Shop",
    Icon = "bug-play", 
    Locked = false,
})

local Teleport = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin",
    Locked = false,
})

local Quest = Window:Tab({
    Title = "Quest",
    Icon = "loader", 
    Locked = false,
})

local Trade = Window:Tab({
    Title = "Trade",
    Icon = "pickaxe", 
    Locked = false,
})

local Discord = Window:Tab({
    Title = "Webhook",
    Icon = "settings", 
    Locked = false,
})

----------- END OF TAB -------------
local Section = Info:Section({ 
    Title = "Have Problem / Need Help? Join Server Now",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Center",
    TextSize = 17, 
    Opened = true,
})

Info:Select()

local function copyLink(link, buttonTitle, notifTitle, notifContent)
    local Button = Info:Button({
        Title = buttonTitle or "Copy Link",
        Desc = "Klik untuk menyalin link",
        Locked = false,
        Callback = function()
            if setclipboard then
                setclipboard(link)
            end

            WindUI:Notify({
                Title = notifTitle or "Copied!",
                Content = notifContent or ("Link '" .. link .. "' berhasil dicopy ✅"),
                Duration = 3,
                Icon = "bell",
            })

            print("Link copied:", link) -- optional log
        end
    })

    return Button
end


copyLink(
    "https://discord.gg/77nEeYeFRp", 
    "Copy Discord Link",              
    "Discord Copied!",                 
    "Link berhasil disalin ke clipboard ✅" 
)

------------- END OF TAB DISCORD -------------------

local Section = Player:Section({ 
    Title = "Player Feature",
})

local WalkSpeedInput = Player:Input({
    Title = "Set WalkSpeed",
    Placeholder = "Masukkan angka, contoh: 50",
    Callback = function(value)
        WalkSpeedInput.Value = tonumber(value) or 16
    end
})


local WalkSpeedToggle = Player:Toggle({
    Title = "WalkSpeed",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        if state then
           
            humanoid.WalkSpeed = WalkSpeedInput.Value or 16
        else
           
            humanoid.WalkSpeed = 16
        end
    end
})

Player:Space()
Player:Divider()

local InfiniteJumpConnection = nil

local InfiniteJumpToggle = Player:Toggle({
    Title = "Infinite Jump",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        
        if state then
            InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if InfiniteJumpConnection then
                InfiniteJumpConnection:Disconnect()
                InfiniteJumpConnection = nil
            end
        end
    end
})

local NoClipConnection = nil

local NoClipToggle = Player:Toggle({
    Title = "NoClip",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        
        if state then
            NoClipConnection = game:GetService("RunService").Stepped:Connect(function()
                local character = player.Character
                if character then
                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if NoClipConnection then
                NoClipConnection:Disconnect()
                NoClipConnection = nil
            end
            
            local character = player.Character
            if character then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

local NoFallToggle = Player:Toggle({
    Title = "No Fall Damage",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local heartbeat = game:GetService("RunService").Heartbeat
        local rstepped = game:GetService("RunService").RenderStepped
        local zeroVec = Vector3.new(0,0,0)
        local noFallConnection = nil
        local enabled = state

        local function enableNoFall(chr)
            local root = chr:WaitForChild("HumanoidRootPart", 5)
            if not root then return end

            noFallConnection = heartbeat:Connect(function()
                if not root.Parent then
                    if noFallConnection then
                        noFallConnection:Disconnect()
                        noFallConnection = nil
                    end
                    return
                end

                local oldvel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = zeroVec
                rstepped:Wait()
                root.AssemblyLinearVelocity = oldvel
            end)
        end

        local function disableNoFall()
            if noFallConnection then
                noFallConnection:Disconnect()
                noFallConnection = nil
            end
        end

        if state then
            if player.Character then
                enableNoFall(player.Character)
            end
            player.CharacterAdded:Connect(function(char)
                if NoFallToggle.Value then
                    enableNoFall(char)
                end
            end)
        else
            disableNoFall()
        end
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    textSize = 20,
    textStrokeTransparency = 0.6,
    yOffset = 2,
}

local currentName = "FyyOnTOP#1 👑"
local customGui
local conns = {}
local hiddenGuis = {}
local enabled = false

local function rainbowColor(t)
    local r = math.sin(t*2) * 127 + 128
    local g = math.sin(t*2 + 2) * 127 + 128
    local b = math.sin(t*2 + 4) * 127 + 128
    return Color3.fromRGB(r,g,b)
end

local function hideGuiIfTarget(gui)
    if (gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and gui.Name ~= "FyyOnTOP#1" then
        if gui.Enabled ~= false then
            hiddenGuis[gui] = true
            gui.Enabled = false
        end
    end
end

local function restoreHiddenGuis()
    for gui in pairs(hiddenGuis) do
        if gui and gui.Parent then
            pcall(function()
                gui.Enabled = true
            end)
        end
    end
    hiddenGuis = {}
end

local function createNameTag(character)
    local head = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso")
    if not head then return end

    if customGui then
        customGui:Destroy()
        customGui = nil
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FyyOnTOP#1"
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, CONFIG.yOffset, 0)
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = currentName
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = CONFIG.textSize
    label.TextStrokeTransparency = CONFIG.textStrokeTransparency
    label.TextColor3 = Color3.fromRGB(255,0,0)
    label.TextScaled = false
    label.Parent = billboard

    local t = 0
    local conn = RunService.RenderStepped:Connect(function(dt)
        if not billboard.Parent then
            pcall(function() conn:Disconnect() end)
            return
        end
        t += dt
        label.TextColor3 = rainbowColor(t)
        label.Text = currentName
    end)

    table.insert(conns, conn)
    customGui = billboard
end

local function hideDefaultNameTag(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid.NameDisplayDistance = 0
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end)
    end

    local head = character:FindFirstChild("Head")
    if head then
        for _, gui in ipairs(head:GetChildren()) do
            hideGuiIfTarget(gui)
        end
        local conn = head.ChildAdded:Connect(function(child)
            task.defer(function()
                hideGuiIfTarget(child)
            end)
        end)
        table.insert(conns, conn)
    end
end

local function disconnectAll()
    for i = #conns, 1, -1 do
        local c = conns[i]
        pcall(function() 
            if c and typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end)
        conns[i] = nil
    end
end

local function setEnabled(state)
    enabled = state
    if state then
        if LocalPlayer.Character then
            hideDefaultNameTag(LocalPlayer.Character)
            createNameTag(LocalPlayer.Character)
        end
    else
        disconnectAll()
        if customGui then
            customGui:Destroy()
            customGui = nil
        end
        restoreHiddenGuis()
    end
end

_G.SetMyVisualName = function(newName)
    currentName = tostring(newName)
    if enabled and LocalPlayer.Character then
        createNameTag(LocalPlayer.Character)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if enabled then
        task.delay(1, function()
            if enabled and char:FindFirstChild("HumanoidRootPart") then
                hideDefaultNameTag(char)
                createNameTag(char)
            end
        end)
    end
end)

setEnabled(false)

local HideNameToggle = Player:Toggle({
    Title = "Hide Name",
    Type = "Toggle",
    Default = false,
    Callback = function(Value)
        setEnabled(Value)
    end
})

local AntiLagButton = Player:Button({
    Title = "Apply Anti Lag",
    Desc = "Optimalkan game untuk mengurangi lag",
    Callback = function()
        WindUI:Notify({
            Title = "Anti Lag",
            Content = "Mengaplikasikan optimasi...",
            Duration = 2,
            Icon = "loader",
        })
        
        local Lighting = game:GetService("Lighting")
        local Workspace = game:GetService("Workspace")
        local player = game.Players.LocalPlayer
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then
                obj.Material = Enum.Material.Plastic
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Sparkles") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = false
            end
        end

        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") then
                obj.Enabled = false
            end
        end

        local camera = Workspace.CurrentCamera
        for _, obj in ipairs(camera:GetChildren()) do
            if obj:IsA("BlurEffect") then
                obj.Enabled = false
            end
        end

        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then
            sky.CelestialBodiesShown = false
            sky.StarCount = 0
        end

        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.FogEnd = 100000
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                obj.Playing = false
            end
        end
        
        WindUI:Notify({
            Title = "Anti Lag",
            Content = "Optimasi berhasil diaplikasikan!",
            Duration = 3,
            Icon = "check",
        })
    end
})

Player:Space()
Player:Divider()

local Section = Player:Section({
    Title = "Gui External",
    Opened = true,
})

local FlyButton = Player:Button({
    Title = "Fly GUI",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()

        WindUI:Notify({
            Title = "Fly",
            Content = "Fly GUI berhasil dijalankan ✅",
            Duration = 3,
            Icon = "bell"
        })
    end
})

---------------- END OF PLAYER ------------------
local Section = Auto:Section({ 
    Title = "Main Feature",
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local REEquipToolFromHotbar = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
local RFChargeFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
local RFRequestFishingMinigameStarted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]
local REFishingCompleted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]
local REUnequipToolFromHotbar = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/UnequipToolFromHotbar"]
local RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
local REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

local lastFishTime = 0
local running = false
local equipped = false
local lastResetTime = 0
local fishCheckEnabled = false
local initialSetupDone = false  -- 🆕 Flag untuk setup awal

local function safeFire(remote, arg)
	if not remote then
		return false
	end
	local ok, err = pcall(function()
		if arg ~= nil then
			remote:FireServer(arg)
		else
			remote:FireServer()
		end
	end)
	if not ok then
		return false
	end
	return true
end

local function safeInvoke(remote, arg1, arg2)
	if not remote then
		return nil
	end
	local ok, res = pcall(function()
		if arg1 ~= nil and arg2 ~= nil then
			return remote:InvokeServer(arg1, arg2)
		elseif arg1 ~= nil then
			return remote:InvokeServer(arg1)
		else
			return remote:InvokeServer()
		end
	end)
	if not ok then
		return nil
	end
	return res
end

local function showNotification(title, content)
    if WindUI and WindUI.Notify then
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = 3,
        })
    elseif Auto and Auto.Notify then
        Auto:Notify({
            Title = title,
            Content = content,
            Duration = 3,
        })
    end
end

local function equipToolOnce()
    if not equipped then
        for i = 1, 3 do
            safeFire(REEquipToolFromHotbar, 1)
        end
        equipped = true
    end
end

local function resetTool()
    safeFire(REUnequipToolFromHotbar)
    equipped = false
    equipToolOnce()
end

-- 🆕 FUNGSI CHARGE & REQUEST
local function doChargeAndRequest()
    safeInvoke(RFChargeFishingRod, 1759970580.257502)
    safeInvoke(RFRequestFishingMinigameStarted, -1.233184814453125, 0.9741226549257175)
end

local function forceResetFishing()
    showNotification("🚨 Stuck Detected", "Resetting fishing...")
    
    -- ❌ BATALKAN FISHING
    for i = 1, 2 do
        safeInvoke(RFCancelFishingInputs)
    end
    
    -- 🔄 RESET TOOL (Unequip + Equip)
    resetTool()
    
    -- 🎯 TAMBAHAN BARU: CHARGE & REQUEST SETELAH RESET
    task.wait(0.5)  -- ⏳ Kasih delay sebentar buat pastikan tool ready
    doChargeAndRequest()  -- 🔥 LANGSUNG CHARGE & REQUEST LAGI
    
    lastFishTime = tick()  -- ⏰ RESET TIMER
end

local function fishCheckLoop()
    local retryCount = 0
    local maxRetries = 10
    
    while running and fishCheckEnabled do
        local currentTime = tick()
        if currentTime - lastFishTime >= 15 and lastFishTime > 0 then
            retryCount = retryCount + 1
            forceResetFishing()
            
            if retryCount >= maxRetries then
                retryCount = 0
            end
        else
            retryCount = 0
        end
        task.wait(1)
    end
end

-- 🚀 PROCESS 1: SPAM COMPLETED TERUS MENERUS
local function spamCompletedLoop()
    while running do
        safeFire(REFishingCompleted)
        task.wait(0.1)
    end
end

-- ⏱️ PROCESS 2: EQUIP TOOL SETIAP 2 DETIK
local function equipToolLoop()
    while running do
        safeFire(REEquipToolFromHotbar, 1)
        task.wait(2)
    end
end

-- 🛡️ PROCESS 3: PERIODIC RESET SETIAP 5 MENIT
local function periodicResetLoop()
    while running do
        task.wait(300)
        if running then
            resetTool()
            lastResetTime = tick()
        end
    end
end

-- 🆕 EVENT HANDLER: TRIGGER CHARGE & REQUEST SETIAP DAPET IKAN
local function setupFishCaughtHandler()
    REFishCaught.OnClientEvent:Connect(function(fishName, fishData)
        lastFishTime = tick()
        
        -- 🎯 LANGSUNG CHARGE & REQUEST 1x SETIAP DAPET IKAN
        if running then
            doChargeAndRequest()
        end
    end)
end

local function fishingCycle()
    lastResetTime = tick()
    lastFishTime = tick()
    fishCheckEnabled = true
    
    -- 🆕 SETUP FISH CAUGHT HANDLER
    setupFishCaughtHandler()
    
    -- ✅ STEP 1: SPAM PARALEL (COMPLETED + EQUIP TOOL)
    task.spawn(spamCompletedLoop)
    task.spawn(equipToolLoop)
    task.spawn(fishCheckLoop)
    task.spawn(periodicResetLoop)
    
    -- ✅ STEP 2: SETUP AWAL - CHARGE & REQUEST 1x SAJA
    task.wait(1)  -- ⏳ Kasih delay sebentar buat pastikan tool ter-equip
    doChargeAndRequest()  -- 🎯 INITIAL CHARGE & REQUEST 1x
    initialSetupDone = true
    
    
    -- 🔄 MAIN LOOP 
    while running do
        task.wait(0.1)
    end
    
    fishCheckEnabled = false
    initialSetupDone = false
end

local Toggle = Auto:Toggle({
    Title = "Auto Fishing", 
    Type = "Toggle",
    Desc = "INSTANT FISHING - SMART TRIGGER SYSTEM",
    Default = false,
    Callback = function(state) 
        running = state
        if running then
            showNotification("🎣 Auto Fishing", "Starting...")
            task.spawn(fishingCycle)
        else
            safeInvoke(RFCancelFishingInputs)
            safeFire(REUnequipToolFromHotbar)
            equipped = false
            fishCheckEnabled = false
            initialSetupDone = false
            showNotification("🎣 Auto Fishing", "Stopped")
        end
    end
})

Auto:Space()
Auto:Divider()

local Section = Auto:Section({ 
    Title = "Teleport Feature",
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local teleportLocations = {
    ["Sisypus Statue"] = Vector3.new(-3732, -135, -887),
    ["Treasure Room"] = Vector3.new(-3598, -276, -1641),
    -- ["Location 3"] = Vector3.new(x, y, z)
}

local teleportEnabled = false
local selectedLocation = ""
local freezeConnection = nil

local function freezePlayer(freeze)
    if freeze then
        -- Freeze player dengan method yang lebih smooth
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                -- Method 1: Set walk speed ke 0
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                
                -- Method 2: Platform stand (lebih efektif)
                humanoid.PlatformStand = true
                
                -- Method 3: Continuous position correction
                freezeConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if teleportEnabled and rootPart then
                        local targetPosition = teleportLocations[selectedLocation]
                        if targetPosition then
                            rootPart.CFrame = CFrame.new(targetPosition)
                        end
                    end
                end)
            end
        end
    else
        -- Unfreeze player
        if freezeConnection then
            freezeConnection:Disconnect()
            freezeConnection = nil
        end
        
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 -- Default walk speed
                humanoid.JumpPower = 50 -- Default jump power
                humanoid.PlatformStand = false
            end
        end
    end
end

-- Dropdown untuk pilih lokasi
local LocationDropdown = Auto:Dropdown({
    Title = "Teleport Location",
    Values = { "Sisypus Statue", "Treasure Room" },
    Value = "",
    Callback = function(option) 
        selectedLocation = option
        print("Location selected: " .. option)
        
        -- Auto update position jika teleport sedang aktif
        if teleportEnabled and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local targetPosition = teleportLocations[selectedLocation]
            
            if rootPart and targetPosition then
                rootPart.CFrame = CFrame.new(targetPosition)
                showNotification("📍 Teleport", "Updated to " .. selectedLocation)
            end
        end
    end
})

local TeleportToggle = Auto:Toggle({
    Title = "Teleport & Freeze to Position",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        teleportEnabled = state
        if teleportEnabled then
            -- Cek apakah lokasi sudah dipilih
            if selectedLocation == "" then
                showNotification("❌ Teleport", "Please select a location first!")
                teleportEnabled = false
                TeleportToggle:Set(false)
                return
            end
            
            -- Teleport dan freeze player
            if player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local targetPosition = teleportLocations[selectedLocation]
                
                if rootPart and targetPosition then
                    -- Teleport ke posisi target
                    rootPart.CFrame = CFrame.new(targetPosition)
                    
                    -- Freeze player
                    freezePlayer(true)
                    
                    showNotification("📍 Teleport", "Teleported to " .. selectedLocation .. " & frozen")
                else
                    teleportEnabled = false
                    TeleportToggle:Set(false)
                end
            else
                teleportEnabled = false
                TeleportToggle:Set(false)
            end
        else
            -- Unfreeze player
            freezePlayer(false)
        end
    end
})

Auto:Divider()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Config
local Folder = "FyyConfig"
local ConfigFile = Folder .. "/SavedPosition.json"

-- Buat folder jika belum ada
if not isfolder(Folder) then
    makefolder(Folder)
end

-- Load saved position
local savedPosition = nil
local function loadPosition()
    if isfile(ConfigFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success then
            savedPosition = data
        end
    end
end

-- Save position to file
local function savePosition()
    local success, err = pcall(function()
        writefile(ConfigFile, HttpService:JSONEncode(savedPosition))
    end)
    return success
end

-- Load position saat start
loadPosition()

-- Variables
local teleportEnabled = false
local freezeConnection = nil

-- Function untuk save position saat ini
local function saveCurrentPosition()
    if player.Character then
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            savedPosition = {
                X = math.floor(rootPart.Position.X),
                Y = math.floor(rootPart.Position.Y) + 2, -- 🔼 TAMBAH 5 UNTUK ATAS
                Z = math.floor(rootPart.Position.Z)
            }
            
            if savePosition() then
                showNotification("Save Position", "Position saved! (" .. savedPosition.X .. ", " .. savedPosition.Y .. ", " .. savedPosition.Z .. ")")
                return true
            else
                showNotification("❌ Save Position", "Failed to save position!")
                return false
            end
        end
    end
    showNotification("❌ Save Position", "No character found!")
    return false
end

-- Freeze player function
local function freezePlayer(freeze)
    if freeze then
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                humanoid.PlatformStand = true
                
                freezeConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if teleportEnabled and rootPart and savedPosition then
                        rootPart.CFrame = CFrame.new(savedPosition.X, savedPosition.Y, savedPosition.Z)
                    end
                end)
            end
        end
    else
        if freezeConnection then
            freezeConnection:Disconnect()
            freezeConnection = nil
        end
        
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
                humanoid.PlatformStand = false
            end
        end
    end
end

-- ========== SAVE POSITION TAB ==========

-- Button untuk save position
local SavePositionButton = Auto:Button({
    Title = "Save Current Position",
    Callback = function()
        saveCurrentPosition()
    end
})

-- Toggle untuk teleport ke saved position
local SaveTeleportToggle = Auto:Toggle({
    Title = "Teleport to Saved Position",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        teleportEnabled = state
        if teleportEnabled then
            -- Cek apakah ada position yang disimpan
            if not savedPosition then
                showNotification("❌ Teleport", "No position saved! Click 'Save Current Position' first.")
                teleportEnabled = false
                SaveTeleportToggle:Set(false)
                return
            end
            
            -- Teleport dan freeze player
            if player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    -- Teleport ke posisi yang disimpan
                    rootPart.CFrame = CFrame.new(savedPosition.X, savedPosition.Y, savedPosition.Z)
                    
                    -- Freeze player
                    freezePlayer(true)
                    
                    showNotification("📍 Teleport", "Teleported to saved position & frozen")
                else
                    teleportEnabled = false
                    SaveTeleportToggle:Set(false)
                end
            else
                teleportEnabled = false
                SaveTeleportToggle:Set(false)
            end
        else
            -- Unfreeze player
            freezePlayer(false)
        end
    end
})

Auto:Space()
Auto:Divider()
local Section = Auto:Section({ 
    Title = "Auto Sell Feature",
})

-- Auto Sell Feature
local autoSellEnabled = false
local autoSellConnection = nil
local autoSellInterval = 5 -- Default 5 menit

-- Slider untuk set interval timer
local AutoSellSlider = Auto:Slider({
    Title = "Auto Sell Timer (Minutes)",
    Step = 1,
    Value = {
        Min = 1,
        Max = 30,
        Default = 5,
    },
    Callback = function(value)
        autoSellInterval = value
    end
})

-- Function untuk invoke server sell all items
local function sellAllItems()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]
    
    pcall(function()
        RFSellAllItems:InvokeServer()
    end)
end

-- Function untuk start auto sell timer
local function startAutoSell()
    if autoSellConnection then
        autoSellConnection:Disconnect()
        autoSellConnection = nil
    end
    
    autoSellConnection = game:GetService("RunService").Heartbeat:Connect(function()
        wait(autoSellInterval * 60)
        if autoSellEnabled then
            sellAllItems()
        end
    end)
    
    -- Jalanin pertama kali langsung
    sellAllItems()
end

-- Function untuk stop auto sell
local function stopAutoSell()
    if autoSellConnection then
        autoSellConnection:Disconnect()
        autoSellConnection = nil
    end
end

-- Toggle untuk auto sell
local AutoSellToggle = Auto:Toggle({
    Title = "Enable Auto Sell",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        autoSellEnabled = state
        if autoSellEnabled then
            startAutoSell()
        else
            stopAutoSell()
        end
    end
})

-- Button untuk manual sell
local ManualSellButton = Auto:Button({
    Title = "Sell All Items Now",
    Callback = function()
        sellAllItems()
    end
})

local Section = Auto:Section({ 
    Title = "Auto Favorite Feature",
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REFavoriteItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FavoriteItem"]
local REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]

local fishTiers = {
    ["Common"] = {
        43, 20, 66, 45, 64, 31, 46, 116, 32, 63, 
        33, 65, 62, 51, 61, 92, 91, 90, 108, 109,
        111, 112, 113, 114, 115, 135, 154, 151, 166, 165,
        198, 234, 281, 279, 290
    },
    ["Uncommon"] = {
        44, 59, 19, 67, 41, 68, 60, 50, 117, 29,
        42, 30, 58, 28, 69, 190, 87, 86, 94, 106,
        107, 121, 120, 139, 140, 144, 142, 163, 161, 153,
        164, 189, 182, 186, 188, 197, 202, 203, 204, 211,
        232, 237, 242, 280, 287, 289, 275, 285, 262, 288
    },
    ["Rare"] = {
        18, 71, 40, 72, 23, 89, 88, 93, 119, 157,
        191, 183, 184, 194, 196, 210, 209, 239, 238, 235,
        241, 278, 282, 277, 284
    },
    ["Epic"] = {
        18, 71, 40, 72, 23, 89, 88, 93, 119, 157,
        191, 183, 184, 194, 196, 210, 209, 239, 238, 235,
        241, 278, 282, 277, 284, 17, 22, 37, 53, 57,
        26, 70, 14, 49, 25, 24, 48, 36, 38, 16,
        56, 55, 27, 39, 74, 73, 95, 96, 138, 143,
        160, 155, 162, 149, 207, 227, 233, 266, 267, 271,
        265, 276, 268, 270
    },
    ["Legendary"] = {
        15, 47, 75, 52, 21, 34, 54, 35, 97, 110,
        137, 146, 147, 152, 199, 208, 224, 236, 243, 286,
        283, 274
    },
    ["Mythic"] = {
        98, 122, 158, 150, 185, 205, 215, 240, 247, 249,
        248, 273, 264, 263
    },
    ["SECRET"] = {
        82, 99, 136, 141, 159, 156, 145, 187, 200, 195,
        206, 201, 225, 218, 228, 226, 83, 176, 292, 293,
        272, 269
    }
}

local autoFavoriteEnabled = false
local connection = nil
local selectedTiers = {""}

local function getSelectedFishIds()
    local targetFishIds = {}
    for _, tierName in pairs(selectedTiers) do
        if fishTiers[tierName] then
            for _, fishId in pairs(fishTiers[tierName]) do
                table.insert(targetFishIds, fishId)
            end
        end
    end
    return targetFishIds
end

local function handleFishCaught(fishId, weightData, itemData, isNew)
    local targetFishIds = getSelectedFishIds()
    if fishId and table.find(targetFishIds, fishId) then
        if itemData and itemData.InventoryItem and itemData.InventoryItem.UUID then
            REFavoriteItem:FireServer(itemData.InventoryItem.UUID)
        else
            REFavoriteItem:FireServer(fishId)
        end
    end
end

local Dropdown = Auto:Dropdown({
    Title = "Auto Favorite With Rarity",
    Values = {"Common", "Uncommon", "Rare", "Epic","Legendary", "Mythic","SECRET"},
    Value = {""},
    Multi = true,
    AllowNone = false,
    Callback = function(selected)
        selectedTiers = selected
    end
})

local Toggle = Auto:Toggle({
    Title = "Auto Favorite Fish",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        autoFavoriteEnabled = state
        if autoFavoriteEnabled then
            local targetFishIds = getSelectedFishIds()
            if #targetFishIds > 0 then
                connection = REObtainedNewFishNotification.OnClientEvent:Connect(handleFishCaught)
            else
                autoFavoriteEnabled = false
                Toggle:Set(false)
            end
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

------------ END OF MAIN FEATURE --------------


-- Webhook Feature
local webhookEnabled = false
local webhookUrl = ""
local selectedWebhookTiers = {}
local webhookConnection = nil

-- Mapping fish ID ke nama ikan (Semua Tier)
local fishNameMapping = {
    -- Tier 1 - Common (sebelumnya)
    [20] = "Ash Basslet", [31] = "Corazon Damsel", [32] = "Orangy Goby", [33] = "Specked Butterfly",
    [43] = "Reef Chromis", [45] = "Boa Angelfish", [46] = "Jennifer Dottyback", [51] = "Volcanic Basslet",
    [61] = "Yellowstate Angelfish", [62] = "Vintage Blue Tang", [63] = "Skunk Tilefish", [64] = "Clownfish",
    [65] = "Strawberry Dotty", [66] = "Azure Damsel", [90] = "Gingerbread Tang", [91] = "Mistletoe Damsel",
    [92] = "Festive Goby", [108] = "Conspi Angelfish", [109] = "Fade Tang", [111] = "Masked Angelfish",
    [112] = "Pygmy Goby", [113] = "Sail Tang", [114] = "Watanabei Angelfish", [115] = "White Tang",
    [116] = "Zoster Butterfly", [135] = "Patriot Tang", [151] = "Boar Fish", [154] = "Electric Eel",
    [165] = "Skeleton Fish", [166] = "Dead Fish", [198] = "Herring Fish", [234] = "Old Boot",
    [279] = "Runic Wispeye", [281] = "Waveback Fish", [290] = "Beanie Leedsicheye",
    
    -- Tier 2 - Uncommon (sebelumnya)
    [44] = "Banded Butterfly", [59] = "Candy Butterfly", [19] = "Coal Tang", [67] = "Copperband Butterfly",
    [41] = "Fire Goby", [68] = "Flame Angelfish", [60] = "Jewel Tang", [50] = "Magma Goby",
    [117] = "Bandit Angelfish", [29] = "Scissortail Dartfish", [42] = "Shrimp Goby", [30] = "Tricolore Butterfly",
    [58] = "Vintage Damsel", [28] = "White Clownfish", [69] = "Yello Damselfish", [190] = "Salmon",
    [87] = "Lava Butterfly", [86] = "Slurpfish Chromis", [94] = "Gingerbread Clownfish", [106] = "Blue-Banded Goby",
    [107] = "Blumato Clownfish", [121] = "Bleekers Damsel", [120] = "Pink Smith Damsel", [139] = "Silver Tuna",
    [140] = "Pilot Fish", [144] = "Racoon Butterfly Fish", [142] = "Orange Basslet", [163] = "Viperfish",
    [161] = "Spotted Lantern Fish", [153] = "Dark Eel", [164] = "Swordfish", [189] = "Rockfish",
    [182] = "Blackcap Basslet", [186] = "Parrot Fish", [188] = "Red Snapper", [197] = "Gar Fish",
    [202] = "Flat Fish", [203] = "Flying Fish", [204] = "Lion Fish", [211] = "Wahoo",
    [232] = "Sea Shell", [237] = "Conch Shell", [242] = "Arowana", [280] = "Abyshorn Fish",
    [287] = "Zebra Snakehead", [289] = "Water Snake", [275] = "Sail Fish", [285] = "Red Goatfish",
    [262] = "Ancient Arapaima", [288] = "Drippy Tucanare",
    
    -- Tier 3 - Rare (sebelumnya)
    [18] = "Charmed Tang", [71] = "Darwin Clownfish", [40] = "Kau Cardinal", [72] = "Korean Angelfish",
    [23] = "Maze Angelfish", [89] = "Volsail Tang", [88] = "Rockform Cardianl", [93] = "Christmastree Longnose",
    [119] = "Ballina Angelfish", [157] = "Jellyfish", [191] = "Sheepshead Fish", [183] = "Catfish",
    [184] = "Coney Fish", [194] = "Barracuda Fish", [196] = "Frog", [210] = "Dark Tentacle",
    [209] = "Starfish", [239] = "Antique Cup", [238] = "Antique Watch", [235] = "Pearl",
    [241] = "King Mackerel", [278] = "Viperangler Fish", [282] = "Parrot Fish", [277] = "Mossy Fishlet",
    [284] = "Freshwater Piranha",
    
    -- Tier 4 - Epic (baru)
    [17] = "Astra Damsel", [22] = "Blue Lobster", [37] = "Bumblebee Grouper", [53] = "Chrome Tuna",
    [57] = "Cow Clownfish", [26] = "Domino Damsel", [70] = "Dorhey Tang", [14] = "Enchanted Angelfish",
    [49] = "Firecoal Damsel", [25] = "Greenbee Grouper", [24] = "Starjam Tang", [48] = "Lavafin Tuna",
    [36] = "Lobster", [38] = "Longnose Butterfly", [16] = "Magic Tang", [56] = "Maroon Butterfly",
    [55] = "Moorish Idol", [27] = "Panther Grouper", [39] = "Sushi Cardinal", [74] = "Unicorn Tang",
    [73] = "Yellowfin Tuna", [95] = "Candycane Lobster", [96] = "Festive Pufferfish", [138] = "Axolotl",
    [143] = "Pufferfish", [160] = "Monk Fish", [155] = "Fangtooth", [162] = "Vampire Squid",
    [149] = "Angler Fish", [207] = "Pink Dolphin", [227] = "Narwhal", [233] = "Expensive Chain",
    [266] = "Crescent Artifact", [267] = "Diamond Artifact", [271] = "Hourglass Diamond Artifact",
    [265] = "Arrow Artifact", [276] = "Spear Guardian", [268] = "Skeleton Angler Fish", [270] = "Goliath Tiger",
    
    -- Tier 5 - Legendary (baru)
    [15] = "Abyss Seahorse", [47] = "Blueflame Ray", [75] = "Dotted Stingray", [52] = "Hammerhead Shark",
    [21] = "Hawks Turtle", [34] = "Loggerhead Turtle", [54] = "Manta Ray", [35] = "Prismy Seahorse",
    [97] = "Gingerbread Turtle", [110] = "Lined Cardinal Fish", [137] = "Plasma Shark", [146] = "Strippled Seahorse",
    [147] = "Thresher Shark", [152] = "Deep Sea Crab", [199] = "Lake Sturgeon", [208] = "Saw Fish",
    [224] = "Synodontis", [236] = "Diamond Ring", [243] = "Ruby", [286] = "Temple Spokes Tuna",
    [283] = "Sacred Guardian Squid", [274] = "Manoai Statue Fish",
    
    -- Tier 6 - Mythic (baru)
    [98] = "Gingerbread Shark", [122] = "Loving Shark", [158] = "King Crab", [150] = "Blob Fish",
    [185] = "Hermit Crab", [205] = "Luminous Fish", [215] = "Armor Catfish", [240] = "Magma Shark",
    [247] = "Sharp One", [249] = "Hybodus Shark", [248] = "Panther Eel", [273] = "Mammoth Appafish",
    [264] = "Ancient Relic Crocodile", [263] = "Crocodile",
    
    -- Tier 7 - SECRET (baru)
    [82] = "Blob Shark", [99] = "Great Christmas Whale", [136] = "Frostborn Shark", [141] = "Great Whale",
    [159] = "Robot Kraken", [156] = "Giant Squid", [145] = "Worm Fish", [187] = "Queen Crab",
    [200] = "Orca", [195] = "Crystal Crab", [206] = "Monster Shark", [201] = "Eerie Shark",
    [225] = "Scare", [218] = "Thin Armor Shark", [228] = "Lochness Monster", [226] = "Megalodon",
    [83] = "Ghost Shark", [176] = "Ghost Worm Fish", [292] = "King Jelly", [293] = "Bone Whale",
    [272] = "Mosasaur Shark", [269] = "Elshark Gran Maja"
}

-- Mapping fish ID ke sell price
local fishPriceMapping = {
    -- Tier 1 - Common (sebelumnya)
    [20] = 19, [31] = 19, [32] = 36, [33] = 19, [43] = 19, [45] = 22, [46] = 19, [51] = 19,
    [61] = 19, [62] = 19, [63] = 36, [64] = 19, [65] = 27, [66] = 22, [90] = 26, [91] = 26,
    [92] = 21, [108] = 19, [109] = 43, [111] = 19, [112] = 21, [113] = 24, [114] = 22, [115] = 21,
    [116] = 28, [135] = 36, [151] = 24, [154] = 22, [165] = 26, [166] = 19, [198] = 21, [234] = 19,
    [279] = 22, [281] = 22, [290] = 19,
    
    -- Tier 2 - Uncommon (sebelumnya)
    [44] = 153, [59] = 419, [19] = 74, [67] = 76, [41] = 347, [68] = 135, [60] = 347, [50] = 135,
    [117] = 105, [29] = 369, [42] = 90, [30] = 112, [58] = 180, [28] = 347, [69] = 99, [190] = 103,
    [87] = 153, [86] = 3830, [94] = 72, [106] = 91, [107] = 95, [121] = 74, [120] = 62, [139] = 62,
    [140] = 58, [144] = 71, [142] = 64, [163] = 94, [161] = 88, [153] = 96, [164] = 84, [189] = 92,
    [182] = 95, [186] = 93, [188] = 97, [197] = 72, [202] = 58, [203] = 55, [204] = 143, [211] = 105,
    [232] = 76, [237] = 72, [242] = 61, [280] = 63, [287] = 164, [289] = 61, [275] = 59, [285] = 145,
    [262] = 64, [288] = 65,
    
    -- Tier 3 - Rare (sebelumnya)
    [18] = 393, [71] = 869, [40] = 869, [72] = 391, [23] = 153, [89] = 369, [88] = 347, [93] = 190,
    [119] = 391, [157] = 402, [191] = 412, [183] = 422, [184] = 287, [194] = 392, [196] = 432,
    [210] = 392, [209] = 385, [239] = 430, [238] = 1680, [235] = 715, [241] = 358, [278] = 430,
    [282] = 440, [277] = 430, [284] = 410,
    
    -- Tier 4 - Epic (baru)
    [17] = 1633, [22] = 11355, [37] = 3225, [53] = 4050, [57] = 1044, [26] = 1444, [70] = 1044,
    [14] = 4200, [49] = 1044, [25] = 5732, [24] = 4200, [48] = 4500, [36] = 15750, [38] = 1575,
    [16] = 4500, [56] = 1044, [55] = 2700, [27] = 1044, [39] = 1282, [74] = 2835, [73] = 3600,
    [95] = 2138, [96] = 1244, [138] = 3971, [143] = 1145, [160] = 3200, [155] = 1840, [162] = 3770,
    [149] = 3620, [207] = 3910, [227] = 2045, [233] = 1580, [266] = 0, [267] = 0, [271] = 0,
    [265] = 0, [276] = 1150, [268] = 2750, [270] = 1380,
    
    -- Tier 5 - Legendary (baru)
    [15] = 38500, [47] = 45000, [75] = 31500, [52] = 46500, [21] = 40500, [34] = 27000, [54] = 24750,
    [35] = 29250, [97] = 38750, [110] = 3100, [137] = 94500, [146] = 40500, [147] = 44000, [152] = 4680,
    [199] = 14350, [208] = 11250, [224] = 3825, [236] = 3580, [243] = 13950, [286] = 4730, [283] = 28500,
    [274] = 4700,
    
    -- Tier 6 - Mythic (baru)
    [98] = 89253, [122] = 59583, [158] = 218500, [150] = 26200, [185] = 29700, [205] = 31150,
    [215] = 30500, [240] = 89500, [247] = 54000, [249] = 63500, [248] = 151500, [273] = 66000,
    [264] = 98000, [263] = 29500,
    
    -- Tier 7 - SECRET (baru)
    [82] = 98000, [99] = 195000, [136] = 100000, [141] = 180000, [159] = 327500, [156] = 162300,
    [145] = 280000, [187] = 218500, [200] = 231500, [195] = 162000, [206] = 245000, [201] = 88500,
    [225] = 280000, [218] = 91000, [228] = 330000, [226] = 345000, [83] = 125000, [176] = 195000,
    [292] = 225000, [293] = 255000, [272] = 180000, [269] = 325000
}

-- Input untuk webhook URL
local WebhookInput = Discord:Input({
    Title = "Webhook URL",
    Value = "",
    Type = "Input",
    Callback = function(input)
        webhookUrl = input
    end
})

-- Dropdown untuk pilih tier yang mau di-notif
local WebhookTierDropdown = Discord:Dropdown({
    Title = "Tiers to Notify",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"},
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        selectedWebhookTiers = selected
    end
})

-- Function untuk dapatkan tier name dari fish ID
local function getTierFromFishId(fishId)
    for tierName, fishList in pairs(fishTiers) do
        if table.find(fishList, fishId) then
            return tierName
        end
    end
    return "Unknown"
end

-- Function untuk dapatkan nama ikan dari fish ID
local function getFishNameFromId(fishId)
    return fishNameMapping[fishId] or "Unknown Fish"
end

-- Function untuk dapatkan harga ikan dari fish ID
local function getFishPriceFromId(fishId)
    return fishPriceMapping[fishId] or 0
end

-- Function untuk dapatkan username player
local function getPlayerUsername()
    local player = game.Players.LocalPlayer
    if player then
        return player.Name
    end
    return "Unknown Player"
end

-- Function untuk dapatkan display name player
local function getPlayerDisplayName()
    local player = game.Players.LocalPlayer
    if player then
        return player.DisplayName
    end
    return "Unknown Player"
end

-- Function untuk dapatkan warna berdasarkan tier
local function getTierColor(tier)
    local tierColors = {
        ["Common"] = 0x808080,
        ["Uncommon"] = 0x00FF00, 
        ["Rare"] = 0x0000FF,
        ["Epic"] = 0x800080,
        ["Legendary"] = 0xFFA500,
        ["Mythic"] = 0xFF0000,
        ["SECRET"] = 0x00FFFF
    }
    return tierColors[tier] or 0x000000
end

-- Function untuk dapatkan emoji berdasarkan tier
local function getTierEmoji(tier)
    local tierEmojis = {
        ["Common"] = "⚪",
        ["Uncommon"] = "🟢", 
        ["Rare"] = "🔵",
        ["Epic"] = "🟣",
        ["Legendary"] = "🟠",
        ["Mythic"] = "🔴",
        ["SECRET"] = "💎"
    }
    return tierEmojis[tier] or "❓"
end

-- Function untuk format harga dengan koma
local function formatPrice(price)
    return tostring(price):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

-- Function untuk dapatkan rarity badge
local function getRarityBadge(tier)
    local badges = {
        ["Common"] = "📜 Common",
        ["Uncommon"] = "🌿 Uncommon", 
        ["Rare"] = "🎣 Rare",
        ["Epic"] = "💜 Epic",
        ["Legendary"] = "👑 Legendary",
        ["Mythic"] = "✨ Mythic",
        ["SECRET"] = "🔮 SECRET"
    }
    return badges[tier] or "❓ Unknown"
end

-- Function untuk kirim webhook
local function sendWebhook(fishName, fishTier, fishWeight, fishId)
    if not webhookEnabled or webhookUrl == "" then
        return
    end
    
    if not table.find(selectedWebhookTiers, fishTier) then
        return
    end
    
    local fishPrice = getFishPriceFromId(fishId)
    local tierEmoji = getTierEmoji(fishTier)
    local rarityBadge = getRarityBadge(fishTier)
    local playerUsername = getPlayerUsername()
    local playerDisplayName = getPlayerDisplayName()
    
    local playerName = playerDisplayName ~= playerUsername and playerDisplayName .. " (@" .. playerUsername .. ")" or playerUsername
    
    local payload = {
        ["username"] = "FyyCommunity - " .. playerName,
        ["avatar_url"] = "https://via.placeholder.com/128/7289DA/FFFFFF?text=🎣",
        ["embeds"] = {{
            ["title"] = tierEmoji .. " **FISH CAUGHT!** " .. tierEmoji,
            ["description"] = "**" .. fishName .. "**",
            ["color"] = getTierColor(fishTier),
            ["fields"] = {
                {
                    ["name"] = "🎯 Caught By",
                    ["value"] = "**" .. playerName .. "**",
                    ["inline"] = false
                },
                {
                    ["name"] = " ",
                    ["value"] = " ",
                    ["inline"] = false
                },
                {
                    ["name"] = "📊 Rarity",
                    ["value"] = rarityBadge,
                    ["inline"] = false
                },
                {
                    ["name"] = " ",
                    ["value"] = " ",
                    ["inline"] = false
                },
                {
                    ["name"] = "⚖️ Weight",
                    ["value"] = "**" .. fishWeight .. " kg**",
                    ["inline"] = false
                },
                {
                    ["name"] = " ",
                    ["value"] = " ",
                    ["inline"] = false
                },
                {
                    ["name"] = "💰 Sell Price",
                    ["value"] = "**$" .. formatPrice(fishPrice) .. "**",
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "FyyCommunity • " .. os.date("%Y-%m-%d %H:%M:%S")
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    pcall(function()
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode(payload)
        })
    end)
end

-- Function untuk handle fish caught untuk webhook
local function handleWebhookFishCaught(fishId, weightData, itemData, isNew)
    local fishTier = getTierFromFishId(fishId)
    local fishName = getFishNameFromId(fishId)
    local fishWeight = weightData and weightData.Weight or "N/A"
    
    sendWebhook(fishName, fishTier, fishWeight, fishId)
end

-- Toggle untuk webhook
local WebhookToggle = Discord:Toggle({
    Title = "Enable Webhook Notifications",
    Type = "Toggle",
    Default = false,
    Callback = function(state)
        webhookEnabled = state
        if webhookEnabled then
            if webhookUrl == "" then
                showNotification("❌ Webhook", "Please enter webhook URL first!")
                webhookEnabled = false
                WebhookToggle:Set(false)
                return
            end
            
            if #selectedWebhookTiers == 0 then
                showNotification("❌ Webhook", "Please select at least one tier!")
                webhookEnabled = false
                WebhookToggle:Set(false)
                return
            end
            
            webhookConnection = REObtainedNewFishNotification.OnClientEvent:Connect(handleWebhookFishCaught)
            showNotification("🔔 Webhook", "Notifications enabled!")
        else
            if webhookConnection then
                webhookConnection:Disconnect()
                webhookConnection = nil
            end
            showNotification("🔔 Webhook", "Notifications disabled")
        end
    end
})

--------------- QUEST -------------

local Button = Quest:Button({
    Title = "Check Quest DeepSea",
    Icon = "bird", 
    Callback = function()
        -- 🔍 GET QUEST DATA
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local QuestList = require(ReplicatedStorage.Shared.Quests.QuestList)
        local questData = Replion.Client:WaitReplion("Data")
        
        -- 🎯 CEK DEEP SEA QUEST
        local deepSeaData = questData:Get({"DeepSea", "Available", "Forever"})
        
        if not deepSeaData or not deepSeaData.Quests then
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "🎣 Deep Sea Quest",
                    Content = "Quest not found or not activated yet!",
                    Duration = 5,
                })
            end
            return
        end
        
        -- 📊 GET QUEST NAMES AND CALCULATE REAL PROGRESS
        local deepSeaQuestInfo = QuestList.DeepSea
        local progressText = ""
        
        if deepSeaQuestInfo and deepSeaQuestInfo.Forever then
            for i, questInfo in ipairs(deepSeaQuestInfo.Forever) do
                local questProgress = deepSeaData.Quests[i]
                local targetValue = questInfo.Arguments.value
                local currentProgress = 0
                local progressPercent = 0
                
                if questProgress then
                    currentProgress = questProgress.Progress
                    progressPercent = math.floor((currentProgress / targetValue) * 100)
                end
                
                progressText = progressText .. string.format("%d. %s : %d/%d (%d%%)\n", 
                    i, questInfo.DisplayName, currentProgress, targetValue, progressPercent)
            end
        else
            progressText = "Quest info not found in QuestList"
        end
        
        -- 🔔 TAMPILKAN NOTIFICATION
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "🌊 Deep Sea Quest Progress",
                Content = progressText,
                Duration = 10,
            })
        elseif Auto and Auto.Notify then
            Auto:Notify({
                Title = "🌊 Deep Sea Quest Progress", 
                Content = progressText,
                Duration = 10,
            })
        end
    end
})



local Button = Quest:Button({
    Title = "Check Quest Element Jungle",
    Callback = function()
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local QuestList = require(ReplicatedStorage.Shared.Quests.QuestList)
        local questData = Replion.Client:WaitReplion("Data")
        
        local elementJungleData = questData:Get({"ElementJungle", "Available", "Forever"})
        
        if not elementJungleData or not elementJungleData.Quests then
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Element Jungle Quest",
                    Content = "Quest not active yet!",
                    Duration = 5,
                })
            end
            return
        end
        
        local progressText = ""
        local elementJungleQuests = QuestList.ElementJungle.Forever
        
        for i, questInfo in ipairs(elementJungleQuests) do
            local questProgress = elementJungleData.Quests[i]
            local target = questInfo.Arguments.value
            local current = questProgress and questProgress.Progress or 0
            local percent = math.floor((current / target) * 100)
            
            local status = current >= target and "✅" or "🔄"
            
            progressText = progressText .. string.format("%d. %s : %d/%d (%d%%)\n", 
                i, questInfo.DisplayName, current, target, percent)
        end
        
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "Element Jungle Quest Progress",
                Content = progressText,
                Duration = 10,
            })
        end
    end
})
