    -- Services
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local player = game.Players.LocalPlayer

-- Multi-track URLs
local tracksURLs = {
    ["1"] = "https://raw.githubusercontent.com/mizuu-cloud/mizuu-autowok/refs/heads/main/FUNNY_NEW_1.json",
    ["2"] = "https://raw.githubusercontent.com/mizuu-cloud/mizuu-autowok/refs/heads/main/FUNNY_NEW_2.json",
    ["3"] = "https://raw.githubusercontent.com/mizuu-cloud/mizuu-autowok/refs/heads/main/FUNNY_NEW_3.json",
    ["4"] = "https://raw.githubusercontent.com/mizuu-cloud/mizuu-autowok/refs/heads/main/FUNNY_NEW_4.json",
    ["5"] = "https://raw.githubusercontent.com/mizuu-cloud/mizuu-autowok/refs/heads/main/FUNNY_NEW_5.json",
    ["6"] = "https://raw.githubusercontent.com/mizuu-cloud/mizuu-autowok/refs/heads/main/FUNNY_NEW_6.json",
    ["7"] = "https://raw.githubusercontent.com/mizuu-cloud/mizuu-autowok/refs/heads/main/FUNNY_NEW_SUMMIT.json"
}

local savedTracks = {}
local orderedTrackNames = {"1", "2", "3", "4", "5", "6", "7"}

    -- Load Tracks
    for _, name in ipairs(orderedTrackNames) do
        local url = tracksURLs[name]
        local success, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and data and data.points then
            savedTracks[name] = {}
            for _, p in ipairs(data.points) do
                table.insert(savedTracks[name], Vector3.new(p[1], p[2], p[3]))
            end
            print("Track loaded:", name, "Points:", #savedTracks[name])
        else
            warn("Failed to load track:", name)
            savedTracks[name] = {}
        end
    end

    -- Variables
    local running = false
    local speed = 16
    local rotationBlend = 0.12

    local verticalOffset = 0
    local avatarHeightOffset = 0
    local enableHeightFilter = false  -- ✅ TAMBAH INI JIKA MASIH MAU PAKAI
    local minY = -math.huge           -- ✅ TAMBAH INI JIKA MASIH MAU PAKAI  
    local maxY = math.huge            -- ✅ TAMBAH INI JIKA MASIH MAU PAKAI

    local originalHipHeight = nil
    local originalBodyHeightScale = nil

    -- Resume state variables
    local resumeData = {
        trackName = nil,
        trackIndex = 1,
        pointIndex = 1,
        lastFlatDir = Vector3.new(0, 0, 1)  -- Changed name for clarity
    }

    local function getHRP()
        local char = player.Character or player.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart")
    end

    -- ✅ FUNGSI UNTUK APPLY VERTICAL OFFSET KE TRACK
    local function applyTrackOffset(track)
        if not track or verticalOffset == 0 then 
            return track 
        end
        
        local originalPoints = #track
        local adjustedTrack = {}
        
        for _, point in ipairs(track) do
            local adjustedPoint = Vector3.new(
                point.X,
                point.Y + verticalOffset,
                point.Z
            )
            
            if enableHeightFilter then
                if adjustedPoint.Y >= minY and adjustedPoint.Y <= maxY then
                    table.insert(adjustedTrack, adjustedPoint)
                end
            else
                table.insert(adjustedTrack, adjustedPoint)
            end
        end
        
        print(string.format("📏 Track adjusted: %d → %d points | Offset: %d", 
            originalPoints, #adjustedTrack, verticalOffset))
        
        return adjustedTrack
    end

    -- ✅ FUNGSI UNTUK DETECT AVATAR HEIGHT
    local function getAvatarHeight()
        local char = player.Character
        if not char then return 5 end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid.HipHeight + 2
        end
        return 5
    end

    -- ✅ FUNGSI UNTUK APPLY AVATAR HEIGHT OFFSET
    local function applyAvatarHeightOffset()
        local char = player.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        -- Simpan original values jika belum disimpan
        if originalHipHeight == nil then
            originalHipHeight = humanoid.HipHeight
        end
        if originalBodyHeightScale == nil and typeof(humanoid.BodyHeightScale) == "number" then
            originalBodyHeightScale = humanoid.BodyHeightScale
        end
        
        -- Apply offset
        if avatarHeightOffset ~= 0 then
            humanoid.HipHeight = originalHipHeight + avatarHeightOffset
            
            if typeof(humanoid.BodyHeightScale) == "number" and originalBodyHeightScale then
                humanoid.BodyHeightScale = originalBodyHeightScale + (avatarHeightOffset / 3)
            end
            
            print("✅ Avatar height adjusted: " .. avatarHeightOffset)
        else
            resetAvatarHeight()
        end
    end

    -- ✅ FUNGSI UNTUK RESET AVATAR HEIGHT
    local function resetAvatarHeight()
        local char = player.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        if originalHipHeight then
            humanoid.HipHeight = originalHipHeight
        end
        
        if originalBodyHeightScale and typeof(humanoid.BodyHeightScale) == "number" then
            humanoid.BodyHeightScale = originalBodyHeightScale
        end
        
        print("✅ Avatar height reset to normal")
    end

    -- ✅ FUNGSI UNTUK ADAPTIVE JUMP TRIGGER
    local function shouldJump(deltaY, avatarHeight)
        local heightFactor = avatarHeight / 6
        
        local climbThreshold = 3 * heightFactor
        local steepThreshold = 5 * heightFactor
        
        if deltaY > climbThreshold then
            return true, true -- climb, spam jump
        elseif deltaY > steepThreshold * 0.7 then
            return true, false -- steep, normal jump
        else
            return false, false -- no jump
        end
    end

    local function findNearestTrackAndPoint()
        local hrp = getHRP()
        local currentPos = hrp.Position
        
        local nearestTrack = 1
        local nearestPoint = 1
        local nearestDistance = math.huge
        
        for trackIdx, name in ipairs(orderedTrackNames) do
            local track = savedTracks[name]
            if track then
                local adjustedTrack = applyTrackOffset(track)
                
                for pointIdx, point in ipairs(adjustedTrack) do
                    local distance = (currentPos - point).Magnitude
                    
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestTrack = trackIdx
                        nearestPoint = pointIdx
                    end
                end
            end
        end
        
        print("Nearest position: Track " .. nearestTrack .. " Point " .. nearestPoint .. " (Distance: " .. math.floor(nearestDistance) .. ")")
        return nearestTrack, nearestPoint
    end

local function respawnPlayer()
    local teleBase = workspace:WaitForChild("TeleBase")
    
    if player.Character then
        local humanoidRootPart = player.Character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = teleBase.CFrame
    end
end
    -- FUNCTION TRIGGERJUMP
    local lastLanding = 0
    local landingCooldown = 0.2

    local function triggerJump(humanoid, isClimb)
        if humanoid then
            local state = humanoid:GetState()

            if not isClimb and state == Enum.HumanoidStateType.Landed then
                lastLanding = tick()
                return
            end

            if (isClimb or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Freefall)
                and (isClimb or tick() - lastLanding > landingCooldown) then

                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end

    -- FUNCTION PLAYTRACK (YANG DIPERBAIKI)
function playTrack(track, trackName)
    if not track or #track < 2 then 
        print("Track tidak valid atau terlalu pendek")
        return false
    end
    local adjustedTrack = applyTrackOffset(track)
    if #adjustedTrack < 2 then return false end
    
    local hrp = getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.AutoRotate = false end

    -- ✅ GUNAKAN adjustedTrack, BUKAN track
    for i = 2, #adjustedTrack do
        if not running then 
            resumeData.pointIndex = i - 1
            resumeData.lastFlatDir = resumeData.lastFlatDir or Vector3.new(0, 0, 1)
            
            if humanoid then humanoid.AutoRotate = true end
            return false
        end

        -- ✅ PAKAI adjustedTrack
        local startPos = adjustedTrack[i-1]
        local targetPos = adjustedTrack[i]

        local distance = (targetPos - startPos).Magnitude
 local deltaY = targetPos.Y - startPos.Y
if deltaY > 3 then
    triggerJump(humanoid, true) -- spam jump untuk climb
end




 local duration = math.max(distance / speed, 0.05)

-- Hanya percepat saat turun, naik tetap normal
if deltaY < -5 then  -- Hanya saat turun curam
    duration = duration * 0.3
elseif deltaY < -2 then  -- Hanya saat turun sedang
    duration = duration * 0.5
end

        local elapsed = 0
while elapsed < duration and running do
    elapsed += RunService.Heartbeat:Wait()

    local t = math.clamp(elapsed / duration, 0, 1)
    local alpha
if deltaY > 2 then
    alpha = t ^ 2 -- Naik → awal lambat, akhir cepat
elseif deltaY < -2 then
    alpha = 1 - (1 - t) ^ 2 -- Turun → awal cepat, akhir lambat
else
    alpha = t -- Rata → linear
end


local currentPos
if math.abs(deltaY) > 5 then
    -- Smooth pakai easing curve biar natural (loncat/jatuh)
    local easedT
    if deltaY > 0 then
        -- Naik → awal lambat, akhir cepat
        easedT = t ^ 2
    else
        -- Turun → awal cepat, akhir melambat
        easedT = 1 - (1 - t) ^ 2
    end
    currentPos = startPos:Lerp(targetPos, easedT)
else
    currentPos = startPos:Lerp(targetPos, alpha)
end


-- SIMPLE FIX: Hanya update lastFlatDir jika bukan vertical murni
local direction = Vector3.new(targetPos.X - startPos.X, 0, targetPos.Z - startPos.Z)

-- Hanya update arah jika ada movement horizontal signifikan
if direction.Magnitude > 1.3 then  -- Threshold lebih besar
    resumeData.lastFlatDir = direction.Unit
end

-- Selalu pakai lastFlatDir, jangan pernah reset
local lookDir = resumeData.lastFlatDir
if lookDir.Magnitude < 0.1 then
    lookDir = Vector3.new(0, 0, 1)
end

local blend = 0.12
local targetCFrame = CFrame.new(currentPos, currentPos + lookDir)
local lerped = hrp.CFrame:Lerp(targetCFrame, blend)
hrp.CFrame = CFrame.new(currentPos) * (lerped - lerped.Position)
        end
    end

    if humanoid then humanoid.AutoRotate = true end
    resumeData.pointIndex = 1
    resumeData.lastFlatDir = Vector3.new(0, 0, 1)

    return true
end

    -- FUNCTION PLAYTRACKFROMPOINT (YANG DIPERBAIKI)
function playTrackFromPoint(track, trackName, startPointIndex, lastDirection)
    if not track or #track < 2 or startPointIndex >= #track then 
        print("Track tidak valid atau start point tidak valid")
        return false
    end
    local adjustedTrack = applyTrackOffset(track)
    if #adjustedTrack < 2 then return false end
    
    local hrp = getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.AutoRotate = false end

    resumeData.lastFlatDir = lastDirection or Vector3.new(0, 0, 1)

    -- ✅ GUNAKAN adjustedTrack, BUKAN track
    for i = startPointIndex + 1, #adjustedTrack do
        if not running then 
            resumeData.pointIndex = i - 1
            if humanoid then humanoid.AutoRotate = true end
            return false
        end

        -- ✅ PAKAI adjustedTrack
        local startPos = adjustedTrack[i-1]
        local targetPos = adjustedTrack[i]

        local distance = (targetPos - startPos).Magnitude
 local deltaY = targetPos.Y - startPos.Y
if deltaY > 3 then
    triggerJump(humanoid, true) -- spam jump untuk climb
end

local duration = math.max(distance / speed, 0.05)

-- Hanya percepat saat turun, naik tetap normal
if deltaY < -5 then  -- Hanya saat turun curam
    duration = duration * 0.3
elseif deltaY < -2 then  -- Hanya saat turun sedang
    duration = duration * 0.5
end

        local elapsed = 0
while elapsed < duration and running do
    elapsed += RunService.Heartbeat:Wait()

    local t = math.clamp(elapsed / duration, 0, 1)
  local alpha
if deltaY > 2 then
    alpha = t ^ 2
elseif deltaY < -2 then
    alpha = 1 - (1 - t) ^ 2
else
    alpha = t
end


local currentPos
if math.abs(deltaY) > 5 then
    local easedT
    if deltaY > 0 then
        easedT = t ^ 2
    else
        easedT = 1 - (1 - t) ^ 2
    end
    currentPos = startPos:Lerp(targetPos, easedT)
else
    currentPos = startPos:Lerp(targetPos, alpha)
end


-- SIMPLE FIX: Hanya update lastFlatDir jika bukan vertical murni
local direction = Vector3.new(targetPos.X - startPos.X, 0, targetPos.Z - startPos.Z)

-- Hanya update arah jika ada movement horizontal signifikan
if direction.Magnitude > 1 then  -- Threshold lebih besar
    resumeData.lastFlatDir = direction.Unit
end

-- Selalu pakai lastFlatDir, jangan pernah reset
local lookDir = resumeData.lastFlatDir
if lookDir.Magnitude < 0.1 then
    lookDir = Vector3.new(0, 0, 1)
end

local blend = 0.12
local targetCFrame = CFrame.new(currentPos, currentPos + lookDir)
local lerped = hrp.CFrame:Lerp(targetCFrame, blend)
hrp.CFrame = CFrame.new(currentPos) * (lerped - lerped.Position)
        end
    end

    if humanoid then humanoid.AutoRotate = true end
    return true -- Track selesai
end

    -- FUNCTION RESUMETRACKLOOP
    local function resumeTrackLoop()
        if not resumeData.trackName or not resumeData.trackIndex then
            print("No resume data available")
            return
        end
        
        local startIndex = resumeData.trackIndex
        for i = startIndex, #orderedTrackNames do
            if not running then break end
            
            local name = orderedTrackNames[i]
            print("Resuming track:", name)
            resumeData.trackName = name
            resumeData.trackIndex = i
            
            local track = savedTracks[name]
            if track and #track > 1 then
                local success, finished
                if i == startIndex then
                    success, finished = pcall(function()
                        return playTrackFromPoint(track, name, resumeData.pointIndex, resumeData.lastFlatDir)
                    end)
                else
                    resumeData.pointIndex = 1
                    resumeData.lastFlatDir = Vector3.new(0, 0, 1)
                    success, finished = pcall(function()
                        return playTrack(track, name)
                    end)
                end
                
                if not success then
                    print("Error resuming track '" .. name .. "':", finished)
                    finished = false
                end
                
                if not running then break end
                if not finished then
                    print("Resumed track stopped:", name)
                    break
                end
            end
        end
        
        if running then
        print("Completed all tracks, respawning...")
        respawnPlayer()
        player.CharacterAdded:Wait()
        getHRP()
        task.wait(1)

        -- Reset supaya mulai lagi dari awal
        resumeData = {
            trackName = orderedTrackNames[1],
            trackIndex = 1,
            pointIndex = 1,
            lastFlatDir = Vector3.new(0, 0, 1)
        }
        
        -- Lanjutkan loop setelah respawn
        if running then
            resumeTrackLoop()  -- Panggil diri sendiri untuk loop terus menerus
        end
    end
end

    local function runAutoSummitLoop()
        local startTrackIndex, startPointIndex = findNearestTrackAndPoint()
        
        while running do
            for trackIdx = startTrackIndex, #orderedTrackNames do
                if not running then break end

                local name = orderedTrackNames[trackIdx]
                local track = savedTracks[name]
                
                if track and #track > 1 then
                    print("Playing track:", name, "starting from point", startPointIndex)
                    resumeData.trackName = name
                    resumeData.trackIndex = trackIdx
                    
                    local success, finished
                    
                    if trackIdx == startTrackIndex then
                        success, finished = pcall(function()
                            return playTrackFromPoint(track, name, startPointIndex, resumeData.lastFlatDir)
                        end)
                    else
                        resumeData.pointIndex = 1
                        resumeData.lastFlatDir = Vector3.new(0, 0, 1)
                        success, finished = pcall(function()
                            return playTrack(track, name)
                        end)
                    end
                    
                    if not success then
                        print("Error playing track '" .. name .. "':", finished)
                        finished = false
                    end

                    if not running then break end
                    if not finished then
                        print("Track dihentikan:", name)
                        break
                    end
                    
                    startPointIndex = 1
                end
            end

            if running then
                print("Completed all tracks, teleporting to SummitReturnPad...")
                respawnPlayer()
                task.wait(1)

                startTrackIndex, startPointIndex = findNearestTrackAndPoint()
                resumeData.trackIndex = startTrackIndex
            end
        end
        print("Auto summit loop stopped")
    end

 -- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MT_PENGANGGURAN"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 320)
Frame.Position = UDim2.new(0.5, -150, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "MT FUNNY"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.TextScaled = true
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- Speed Input
local speedBox = Instance.new("TextBox", Frame)
speedBox.Size = UDim2.new(0.9, 0, 0, 40)
speedBox.Position = UDim2.new(0.05, 0, 0, 40)
speedBox.PlaceholderText = "Speed"
speedBox.Text = tostring(speed)
speedBox.TextColor3 = Color3.fromRGB(180, 180, 180)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedBox.TextScaled = true
speedBox.ClearTextOnFocus = false
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(speedBox.Text)
        if val and val > 0 then
            speed = val
        else
            speedBox.Text = tostring(speed)
        end
    end
end)

-- ✅ OFFSET SYSTEM - HAPUS DUPLICATE!
local offsetButton = Instance.new("TextButton", Frame)
offsetButton.Size = UDim2.new(0.9, 0, 0, 40)
offsetButton.Position = UDim2.new(0.05, 0, 0, 90)
offsetButton.Text = "AVATAR DEFAULT STANDART"
offsetButton.TextColor3 = Color3.fromRGB(180, 180, 180)
offsetButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
offsetButton.TextScaled = true
Instance.new("UICorner", offsetButton).CornerRadius = UDim.new(0, 6)

-- Variabel untuk expand state
local isOffsetExpanded = false

-- Option buttons (awalnya hidden)
-- Option buttons (awalnya hidden)
local optionDefault = Instance.new("TextButton", Frame)
optionDefault.Size = UDim2.new(0.9, 0, 0, 35)
optionDefault.Position = UDim2.new(0.05, 0, 0, 135)
optionDefault.Text = "DEFAULT STANDART"
optionDefault.TextColor3 = Color3.fromRGB(180, 180, 180)
optionDefault.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
optionDefault.TextScaled = true
optionDefault.Visible = false
Instance.new("UICorner", optionDefault).CornerRadius = UDim.new(0, 4)

local optionMini = Instance.new("TextButton", Frame)
optionMini.Size = UDim2.new(0.9, 0, 0, 35)
optionMini.Position = UDim2.new(0.05, 0, 0, 175)
optionMini.Text = "MINI"
optionMini.TextColor3 = Color3.fromRGB(180, 180, 180)
optionMini.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
optionMini.TextScaled = true
optionMini.Visible = false
Instance.new("UICorner", optionMini).CornerRadius = UDim.new(0, 4)

local optionTinggi = Instance.new("TextButton", Frame)
optionTinggi.Size = UDim2.new(0.9, 0, 0, 35)
optionTinggi.Position = UDim2.new(0.05, 0, 0, 215)
optionTinggi.Text = "TINGGI"
optionTinggi.TextColor3 = Color3.fromRGB(180, 180, 180)
optionTinggi.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
optionTinggi.TextScaled = true
optionTinggi.Visible = false
Instance.new("UICorner", optionTinggi).CornerRadius = UDim.new(0, 4)

-- ✅ BUAT TOMBOL LAIN DULU SEBELUM FUNCTION
-- Auto Summit Button
local autoBtn = Instance.new("TextButton", Frame)
autoBtn.Size = UDim2.new(0.9, 0, 0, 40)
autoBtn.Position = UDim2.new(0.05, 0, 0, 140)
autoBtn.Text = "AUTO SUMMIT (Loop)"
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 100)
autoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
autoBtn.TextScaled = true
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 6)

-- Animation & Reset Buttons
local animBtn = Instance.new("TextButton", Frame)
animBtn.Size = UDim2.new(0.44, 0, 0, 40)
animBtn.Position = UDim2.new(0.05, 0, 0, 190)
animBtn.Text = "ANIMASI: OFF"
animBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
animBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
animBtn.TextScaled = true
Instance.new("UICorner", animBtn).CornerRadius = UDim.new(0, 8)

local resetAvatarBtn = Instance.new("TextButton", Frame)
resetAvatarBtn.Size = UDim2.new(0.44, 0, 0, 40)
resetAvatarBtn.Position = UDim2.new(0.51, 0, 0, 190)
resetAvatarBtn.Text = "RESET AVATAR"
resetAvatarBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
resetAvatarBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
resetAvatarBtn.TextScaled = true
Instance.new("UICorner", resetAvatarBtn).CornerRadius = UDim.new(0, 8)

-- Pause & Stop All Buttons
local stopResumeBtn = Instance.new("TextButton", Frame)
stopResumeBtn.Size = UDim2.new(0.44, 0, 0, 40)
stopResumeBtn.Position = UDim2.new(0.05, 0, 0, 240)
stopResumeBtn.Text = "PAUSE"
stopResumeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
stopResumeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
stopResumeBtn.TextScaled = true
Instance.new("UICorner", stopResumeBtn).CornerRadius = UDim.new(0, 8)

local stopAllBtn = Instance.new("TextButton", Frame)
stopAllBtn.Size = UDim2.new(0.44, 0, 0, 40)
stopAllBtn.Position = UDim2.new(0.51, 0, 0, 240)
stopAllBtn.Text = "STOP ALL"
stopAllBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
stopAllBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
stopAllBtn.TextScaled = true
Instance.new("UICorner", stopAllBtn).CornerRadius = UDim.new(0, 8)


local function getCurrentOffsetName()
    if verticalOffset == -3 then
        return "DEFAULT STANDART"
    elseif verticalOffset == -4 then
        return "MINI"
    elseif verticalOffset == 0 then
        return "TINGGI"  
    else
        return "CUSTOM"
    end
end


local function toggleOffsetOptions()
    isOffsetExpanded = not isOffsetExpanded
    
    if isOffsetExpanded then
        -- EXPAND: Tampilkan options dan besarkan frame
        Frame.Size = UDim2.new(0, 300, 0, 460)
        optionDefault.Visible = true
        optionMini.Visible = true
        optionTinggi.Visible = true
        offsetButton.Text = "AVATAR : PILIH ↓"
        
        print("DEBUG: Expanding frame...")
        
        -- Geser SEMUA tombol ke bawah
        autoBtn.Position = UDim2.new(0.05, 0, 0, 260)
        animBtn.Position = UDim2.new(0.05, 0, 0, 310)
        resetAvatarBtn.Position = UDim2.new(0.51, 0, 0, 310)
        stopResumeBtn.Position = UDim2.new(0.05, 0, 0, 360)
        stopAllBtn.Position = UDim2.new(0.51, 0, 0, 360)
        
        print("DEBUG: Buttons moved down")
        
    else
        -- COLLAPSE: Sembunyikan options dan kecilkan frame
        Frame.Size = UDim2.new(0, 300, 0, 320)
        optionDefault.Visible = false
        optionMini.Visible = false
        optionTinggi.Visible = false
        offsetButton.Text = "AVATAR: " .. getCurrentOffsetName()
        
        print("DEBUG: Collapsing frame...")
        
        -- Kembalikan SEMUA tombol ke posisi normal
        autoBtn.Position = UDim2.new(0.05, 0, 0, 140)
        animBtn.Position = UDim2.new(0.05, 0, 0, 190)
        resetAvatarBtn.Position = UDim2.new(0.51, 0, 0, 190)
        stopResumeBtn.Position = UDim2.new(0.05, 0, 0, 240)
        stopAllBtn.Position = UDim2.new(0.51, 0, 0, 240)
        
        print("DEBUG: Buttons moved up")
    end
end

-- ✅ FUNCTION UNTUK SET OFFSET
local function setOffset(offsetValue, optionName)
    verticalOffset = offsetValue
    offsetButton.Text = "AVATAR: " .. optionName
    
    -- Auto collapse setelah milih
    if isOffsetExpanded then
        toggleOffsetOptions()
    end
    
    print("Track offset set to: " .. optionName .. " (" .. verticalOffset .. ")")
end

-- ✅ EVENT HANDLERS - PERBAIKI MAPPINGNYA
offsetButton.MouseButton1Click:Connect(toggleOffsetOptions)

optionDefault.MouseButton1Click:Connect(function()
    setOffset(-3, "DEFAULT STANDART")  -- DEFAULT = 0
end)

optionMini.MouseButton1Click:Connect(function()
    setOffset(-4, "MINI")  -- MINI = -3
end)

optionTinggi.MouseButton1Click:Connect(function()
    setOffset(0, "TINGGI")
end)

resetAvatarBtn.MouseButton1Click:Connect(function()
    verticalOffset = -3
    offsetButton.Text = "AVATAR: DEFAULT STANDART"
    print("✅ Track vertical offset direset ke DEFAULT (0)")
end)

-- Sisanya tetap sama...
local isPaused = false
local bypassIsActive = false
local bypassConn

local function restoreCharacterControl()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end

local function setupBypass(char)
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local lastPos = hrp.Position

    if bypassConn then bypassConn:Disconnect() end
    bypassConn = RunService.RenderStepped:Connect(function()
        if not hrp or not hrp.Parent then return end

        if bypassIsActive and running then
            local direction = (hrp.Position - lastPos)
            local dist = direction.Magnitude
            if dist > 0.01 then
                local moveVector = direction.Unit * math.clamp(dist * 5, 0, 1)
                humanoid:Move(moveVector, false)
            else
                humanoid:Move(Vector3.zero, false)
            end
        end

        lastPos = hrp.Position
    end)
end

player.CharacterAdded:Connect(function(char)
    setupBypass(char)
    task.wait(1)
    restoreCharacterControl()
    
    if avatarHeightOffset ~= 0 then
        task.wait(2)
        applyAvatarHeightOffset()
    end
end)

if player.Character then 
    setupBypass(player.Character)
    restoreCharacterControl()
    
    if avatarHeightOffset ~= 0 then
        task.wait(2)
        applyAvatarHeightOffset()
    end
end

local function stopAllTracks()
    running = false
    isPaused = false
    stopResumeBtn.Text = "PAUSE"
    stopResumeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)

    bypassIsActive = false
    animBtn.Text = "ANIMASI: OFF"
    animBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

    restoreCharacterControl()

    resumeData = {
        trackName = nil,
        trackIndex = 1,
        pointIndex = 1,
        lastFlatDir = Vector3.new(0, 0, 1)
    }

    print("All tracks stopped completely")
end

stopAllBtn.MouseButton1Click:Connect(function()
    stopAllTracks()
end)

stopResumeBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        isPaused = true
        stopResumeBtn.Text = "RESUME"
        stopResumeBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 0)

        bypassIsActive = false
        animBtn.Text = "ANIMASI: OFF"
        animBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

        restoreCharacterControl()

        print("Track paused - character can now move freely")
    else
        if isPaused and resumeData.trackName then
            running = true
            isPaused = false
            stopResumeBtn.Text = "PAUSE"
            stopResumeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)

            bypassIsActive = true
            animBtn.Text = "ANIMASI: ON"
            animBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)

            coroutine.wrap(function()
                resumeTrackLoop()
                if running then
                    print("Resume completed all tracks")
                else
                    print("Resume stopped early")
                end
            end)()

            print("Resuming from track:", resumeData.trackName, "at point", resumeData.pointIndex)
        else
            print("No track to resume")
        end
    end
end)

animBtn.MouseButton1Click:Connect(function()
    if running then
        bypassIsActive = not bypassIsActive
        if bypassIsActive then
            animBtn.Text = "ANIMASI: ON"
            animBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        else
            animBtn.Text = "ANIMASI: OFF"
            animBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    else
        bypassIsActive = false
        animBtn.Text = "ANIMASI: OFF"
        animBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        print("Animation can only be toggled when auto summit is running")
    end
end)

autoBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    isPaused = false
    stopResumeBtn.Text = "PAUSE"
    stopResumeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    
    bypassIsActive = true
    animBtn.Text = "ANIMASI: ON"
    animBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    coroutine.wrap(runAutoSummitLoop)()
end)

-- Minimize Button
local closeBtn = Instance.new("TextButton", Frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeBtn.TextScaled = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    local logoBtn = Instance.new("ImageButton", ScreenGui) -- Changed to ImageButton
    logoBtn.Size = UDim2.new(0, 40, 0, 40)
    logoBtn.Position = UDim2.new(0, 50, 0, 50)
    logoBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logoBtn.Image = "rbxassetid://106899268176689" -- Replace with your image ID
    logoBtn.ScaleType = Enum.ScaleType.Fit
    Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

    -- Drag function for logo button
    local function setupLogoDrag(target)
        local dragging, dragStart, startPos
        target.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = target.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        target.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    local delta = input.Position - dragStart
                    target.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end)
    end
    setupLogoDrag(logoBtn)

    logoBtn.MouseButton1Click:Connect(function()
        Frame.Visible = true
        logoBtn:Destroy()
    end)
end)

-- Drag Function for main frame
local function setupDrag(target)
    local dragging, dragStart, startPos
    target.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    target.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                target.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end
setupDrag(Frame)


local function createNotification()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "PERHATIAN",
        Text = "PILIH AVA TERLEBIH DAHULU",
        Duration = 6,
        Icon = "rbxassetid://106899268176689" 
    })
end

createNotification()
