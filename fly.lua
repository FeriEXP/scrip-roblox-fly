--[[ 
Final Fly Script KRNL + Joystick untuk Ponsel
Fitur:
- Gerakan Kamera Bebas 360°
- Antarmuka Kecil, Pan & Zoom (Gaya Hussein)
- Kecepatan yang Dapat Disesuaikan +/-
- Ketinggian Y di Ponsel dan PC
- Joystick Asli untuk Ponsel
- Siap diimplementasikan di KRNL
]]

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flying = false
local speed = 60
local smoothness = 0.25
local bv, bg

-- GUI
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,140)
frame.Position = UDim2.new(0.05,0,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.3
frame.Active = true
frame.Draggable = true

local ui = Instance.new("UIGridLayout", frame)
ui.CellSize = UDim2.new(0,60,0,40)
ui.FillDirectionMaxCells = 3
ui.CellPadding = UDim2.new(0,5,0,5)

local function makeBtn(txt,col)
    local b = Instance.new("TextButton", frame)
    b.Text = txt
    b.BackgroundColor3 = col
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.SourceSansBold
    b.TextScaled = true
    return b
end

-- tombol
local btnOn = makeBtn("Terbang", Color3.fromRGB(255,255,0))
local btnPlus = makeBtn("+", Color3.fromRGB(0,200,0))
local btnMinus = makeBtn("-", Color3.fromRGB(200,0,0))
local btnClose = makeBtn("X", Color3.fromRGB(255,0,0))
local btnMini = makeBtn("-", Color3.fromRGB(100,100,100))
local btnUp = makeBtn("↑", Color3.fromRGB(0,150,255))
local btnDown = makeBtn("↓", Color3.fromRGB(0,255,150))

-- Mini
local miniCircle = Instance.new("TextButton", gui)
miniCircle.Size = UDim2.new(0,40,0,40)
miniCircle.Position = UDim2.new(0.05,0,0.25,0)
miniCircle.BackgroundColor3 = Color3.fromRGB(150,150,150)
miniCircle.Text = "+"
miniCircle.TextScaled = true
miniCircle.Font = Enum.Font.SourceSansBold
miniCircle.TextColor3 = Color3.fromRGB(0,0,0)
miniCircle.Visible = false

-- 
local flyUp, flyDown = false,false
btnUp.MouseButton1Down:Connect(function() flyUp = true end)
btnUp.MouseButton1Up:Connect(function() flyUp = false end)
btnDown.MouseButton1Down:Connect(function() flyDown = true end)
btnDown.MouseButton1Up:Connect(function() flyDown = false end)

-- Joystick 
local joystickBg = Instance.new("Frame", gui)
joystickBg.Size = UDim2.new(0,100,0,100)
joystickBg.Position = UDim2.new(0.05,0,0.7,0)
joystickBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
joystickBg.BackgroundTransparency = 0.5
joystickBg.Visible = UserInputService.TouchEnabled -- يظهر فقط على الجوال

local joystickHandle = Instance.new("Frame", joystickBg)
joystickHandle.Size = UDim2.new(0,40,0,40)
joystickHandle.Position = UDim2.new(0.5,-20,0.5,-20)
joystickHandle.BackgroundColor3 = Color3.fromRGB(150,150,150)
joystickHandle.BackgroundTransparency = 0.2
joystickHandle.AnchorPoint = Vector2.new(0.5,0.5)

local dragging = false
local dragInput, dragStartPos, handleStartPos

joystickHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStartPos = input.Position
        handleStartPos = joystickHandle.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                joystickHandle.Position = UDim2.new(0.5,-20,0.5,-20)
            end
        end)
    end
end)

joystickHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStartPos
        local maxDist = 40
        delta = Vector2.new(math.clamp(delta.X,-maxDist,maxDist), math.clamp(delta.Y,-maxDist,maxDist))
        joystickHandle.Position = UDim2.new(0.5 + delta.X/100, -20, 0.5 + delta.Y/100, -20)
    end
end)

-- دوال الطيران
local function startFly()
    if flying then return end
    flying = true

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Velocity = Vector3.zero

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.CFrame = hrp.CFrame

    hum.PlatformStand = true

    RunService.RenderStepped:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        local forward = Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
        local right = Vector3.new(cam.CFrame.RightVector.X,0,cam.CFrame.RightVector.Z)
        if forward.Magnitude>0 then forward=forward.Unit end
        if right.Magnitude>0 then right=right.Unit end

        local inputVec = Vector3.zero
        -- PC Input
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then inputVec = inputVec + Vector3.new(0,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then inputVec = inputVec + Vector3.new(0,0,-1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then inputVec = inputVec + Vector3.new(-1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then inputVec = inputVec + Vector3.new(1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or flyUp then inputVec = inputVec + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or flyDown then inputVec = inputVec + Vector3.new(0,-1,0) end

        -- Joystick Input
        if joystickBg.Visible then
            local handleDelta = (joystickHandle.Position - UDim2.new(0.5,-20,0.5,-20))
            inputVec = inputVec + Vector3.new(handleDelta.X.Scale*2,0,-handleDelta.Y.Scale*2)
        end

        local moveVector = forward*inputVec.Z + right*inputVec.X + Vector3.new(0,inputVec.Y,0)
        if moveVector.Magnitude>0 then
            bv.Velocity = bv.Velocity:Lerp(moveVector.Unit*speed, smoothness)
        else
            bv.Velocity = bv.Velocity:Lerp(Vector3.zero, smoothness)
        end

        bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
    end)
end

local function stopFly()
    flying = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    hum.PlatformStand = false
end

--  GUI
btnOn.MouseButton1Click:Connect(function() if flying then stopFly() else startFly() end end)
btnPlus.MouseButton1Click:Connect(function() speed=speed+10 end)
btnMinus.MouseButton1Click:Connect(function() if speed>10 then speed=speed-10 end end)
btnClose.MouseButton1Click:Connect(function() stopFly() gui:Destroy() end)
btnMini.MouseButton1Click:Connect(function() frame.Visible=false miniCircle.Visible=true end)
miniCircle.MouseButton1Click:Connect(function() frame.Visible=true miniCircle.Visible=false end)
