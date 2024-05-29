local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Farls-Xavier/UiLibrary/main/Library.lua"))()

local Ignore = { -- Doing a table caUSE WHY the fuck not!! well cause it cooler and it look better
    ToFlush = {},
    Target = nil,
    CanContinue = true
}

if not isfolder("@FarlsXavier") then
    error("Root folder '@FarlsXavier' does not exist.")
    return
else
    if not isfolder("@FarlsXavier\\Arsenal") then
        warn("Config folder '@FarlsXavier\\Arsenal' doesn't exist. Creating folder.")
        makefolder("@FarlsXavier\\Arsenal")
        writefile("@FarlsXavier\\Arsenal\\Config.ini", [[
            {
                "Name": "Arsenal Script",
                "MaxDistance": 500,
                "Note": "FOR MAX DISTANCE I WOULD KEEP AT 500 OR DECREASE IDK WHY YOU WOULD BUT YOU CAN"
            }
        ]])
    else
        if not isfile("@FarlsXavier\\Arsenal\\Config.ini") then
            warn("Config file '@FarlsXavier\\Arsenal\\Config.ini' doesn't exist. Creating file.")
            writefile("@FarlsXavier\\Arsenal\\Config.ini", [[
                {
                    "Name": "Arsenal Script",
                    "MaxDistance": 500,
                    "Note": "FOR MAX DISTANCE I WOULD KEEP AT 500 OR DECREASE IDK WHY YOU WOULD BUT YOU CAN"
                }
            ]])
        else
           print("Finished Startup")
        end
    end
end

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

local Camera = workspace.CurrentCamera

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Config = HttpService:JSONDecode(readfile("@FarlsXavier\\Arsenal\\Config.ini"))

local Window = Library:Window({
    Title = Config.Name.. " - 286090429" or "Arsenal - 286090429",
    OnClose = function()
        -- MUAHAHA NO MORE MEMORY LEAK!!!!
        for i,v in pairs(Ignore.ToFlush) do
            pcall(function()
                if typeof(v) == "RBXScriptConnection" then
                    print(v)
                    v:Disconnect()
                else
                    print(v)
                    v:Remove()
                end
                Ignore.CanContinue = false
            end)
        end
        
        Library:destroy()
    end
})

--I wont rework this stuff cause im too lazy :p
local EspSettings = {
    TeamCheck = false
}

local TracerSettings = {
    Visible = false,
    Color = Color3.fromRGB(126, 161, 255),
    Position = "Bottom"
}

local BoxSettings = {
    Visible = false,
    Color = Color3.fromRGB(126, 161, 255)
}

local NameSettings = {
    Visible = false,
    Color = Color3.fromRGB(126, 161, 255)
}

--[[ AIMBOT SETTINGS ]] --
local Holding = false

local AimbotSettings = {
    Enabled = false,
    WallCheck = false,
    TeamCheck = false,
    Aimpart = "Head", -- Torso, Closest, Head
    Smoothness = 0
}

local FovSettings = {
    Visible = false,
    Enabled = false,
    Color = Color3.fromRGB(126, 161, 255),
    Size = 90
}

local Tabs = {
    ["Aim Tab"] = Window:Tab({Text = "Aim", Icon = "rbxassetid://14966164502"}),
    ["ESP Tab"] = Window:Tab({Text = "ESP", Icon = "rbxassetid://14966779139"}),
    ["Player Tab"] = Window:Tab({Text = "Player", Icon = "rbxassetid://14958157475"}),
    ["SkinChanger Tab"] = Window:Tab({Text = "Skin Changer"}), -- No Icon tet too big
    ["Config Tab"] = Window:Tab({Text = "Config", Icon = "rbxassetid://13850085640"})
}

local Stuffs = {
    -- tabvle in da tabler
    aimTab = {
        AimbotToggle = Tabs["Aim Tab"]:Toggle({
            Text = "Aimbot",
            Callback = function(v)
                AimbotSettings.Enabled = v
            end
        }),
    
        Seperator1 = Tabs["Aim Tab"]:Label({Text = "Settings: "}),
    
        SmoothnessSlider = Tabs["Aim Tab"]:Slider({
            Text = "Smoothness",
            Min = 0,
            Max = 1,
            Default = 0,
            decimals = true,
            Callback = function(v)
                AimbotSettings.Smoothness = v
            end
        }),
    
        TeamcheckToggle = Tabs["Aim Tab"]:Toggle({
            Text = "Team check",
            Callback = function(v)
                AimbotSettings.TeamCheck = v
            end
        }),
    
        WallcheckToggle = Tabs["Aim Tab"]:Toggle({
            Text = "Wall check",
            Callback = function(v)
                AimbotSettings.WallCheck = v
            end
        }),
    
        Seperator2 = Tabs["Aim Tab"]:Label({Text = "Fov: "}),
    
        FovEnabledToggle = Tabs["Aim Tab"]:Toggle({
            Text = "Enabled",
            Callback = function(v)
                FovSettings.Enabled = v
            end
        }),
    
        FovVisibleToggle = Tabs["Aim Tab"]:Toggle({
            Text = "Visible",
            Callback = function(v)
                FovSettings.Visible = v
            end
        }),
    
        FovRadiusSlider = Tabs["Aim Tab"]:Slider({
            Text = "Size",
            Min = 10,
            Max = 999,
            Default = 90,
            Callback = function(v)
                FovSettings.Size = v
            end
        }),
    },
    
    espTab = {
        BoxesToggle = Tabs["ESP Tab"]:Toggle({
            Text = "Boxes",
            Callback = function(v)
                BoxSettings.Visible = v
            end
        }),
    
        NamesToggle = Tabs["ESP Tab"]:Toggle({
            Text = "Names",
            Callback = function(v)
                NameSettings.Visible = v
            end
        }),
    
        TracersToggle = Tabs["ESP Tab"]:Toggle({
            Text = "Tracers",
            Callback = function(v)
                TracerSettings.Visible = v
            end
        }),
    
        Seperator2 = Tabs["ESP Tab"]:Label({Text = "Settings: "}),
    
        TeamcheckToggle2 = Tabs["ESP Tab"]:Toggle({
            Text = "Team check",
            Callback = function(v)
                EspSettings.TeamCheck = v
            end
        })
    },
    
    playerTab = {
        WalkspeedToggle = Tabs["Player Tab"]:Toggle({
            Text = "Walkspeed(CFrame + not done)",
            Callback = function(v)
                
            end
        }),
    
        InfJumpToggle = Tabs["Player Tab"]:Toggle({
            Text = "Infinite Jump",
            Callback = function(v)
                if v == true then
                    local debouce = false
                    UserInputService.JumpRequest:Connect(function()
                        if not debouce then
                            debouce = true
                            Char:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                            task.wait()
                            debouce = false
                        end  
                    end)
                end
            end
        })
    },
    
    skinchangerTab = {
        
    },
    
    configTab = {
        
    }
}

local function NotObstructing(Destination, Ignore)
    local Origin = Camera.CFrame.Position
    local CheckRay = Ray.new(Origin, Destination - Origin)
    local Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay, Ignore)

    return Hit == nil
end

local function Flush(instance)
    table.insert(Ignore.ToFlush, instance)
end

local fov = Drawing.new("Circle")
local function UpdateFov(...) -- Using ... for like IF you do decide to add settings and can stay nil(Dont have to put args) well It wont be used AT ALL
    if (...) then
        local args = ...
        fov.Transparency = args.Transparency
        fov.Filled = args.Filled
        fov.Color = FovSettings.Color or args.Color
        fov.Position = args.Position
    else
        fov.Transparency = 1
        fov.Filled = false
        fov.Color = FovSettings.Color
        fov.Visible = FovSettings.Visible
        fov.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end
fov.Visible = false

Flush(fov)

local function GetClosestPlayer()
    local maxDistance = FovSettings.Enabled and FovSettings.Size or 9999999
    local mouseLocation = UserInputService:GetMouseLocation()
    local playerCharacter = Player.Character
    local aimbotSettings = AimbotSettings

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player and (not aimbotSettings.TeamCheck or player.Team ~= Player.Team) then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local humanoidRootPart = player.Character:WaitForChild("HumanoidRootPart")
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                local vectorDistance = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude

                if vectorDistance < maxDistance and onScreen then
                    local aimPart = player.Character:FindFirstChild(aimbotSettings.Aimpart)
                    if aimPart then
                        local aimPartPosition = aimPart.Position
                        if not aimbotSettings.WallCheck or NotObstructing(aimPartPosition, {playerCharacter, player.Character}) then
                            Ignore.Target = player
                            maxDistance = vectorDistance
                        end
                    end
                end
            end
        end
    end

    return Ignore.Target
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotSettings.Enabled == true then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotSettings.Enabled == true then
        Holding = false
        Ignore.Target = nil
    end
end)

coroutine.wrap(function()
    local CurrentStep

    CurrentStep = RunService.RenderStepped:Connect(function()
        if FovSettings.Enabled then
            UpdateFov()
        else
            FovSettings.Visible = false
            fov.Visible = false
        end
        fov.Radius = FovSettings.Size

        -- Okay ill try and make this readable if you are trying to look at it dw babe

        local UsingSmoothness = AimbotSettings.Smoothness > 0

        if Holding and AimbotSettings.Enabled and Ignore.CanContinue then
            if UsingSmoothness then
                local CP = GetClosestPlayer() -- Sussy name :flushed:

                if CP then
                    local TargetCharacter = CP.Character
                    if TargetCharacter then
                        local Part1, Part2 = TargetCharacter:FindFirstChild("HumanoidRootPart"), Char:FindFirstChild("HumanoidRootPart")
                        if Part1 and Part2 then
                            local Distance = (Part1.Position - Part2.Position).Magnitude

                            local IsDead = Ignore.Target:FindFirstChild("Deaded") or Ignore.Target:FindFirstChild("DiedRecently")

                            if CP and TargetCharacter:FindFirstChild(AimbotSettings.Aimpart) and not IsDead and Distance < Config.MaxDistance then
                                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetCharacter[AimbotSettings.Aimpart].Position), AimbotSettings.Smoothness)
                            end
                        end
                    end
                end
            else
                local CP = GetClosestPlayer() -- Sussy name :flushed:

                if CP then
                    local TargetCharacter = CP.Character
                    if TargetCharacter then
                        local Part1, Part2 = TargetCharacter:FindFirstChild("HumanoidRootPart"), Char:FindFirstChild("HumanoidRootPart")
                        if Part1 and Part2 then
                            local Distance = (Part1.Position - Part2.Position).Magnitude

                            local IsDead = Ignore.Target:FindFirstChild("Deaded") or Ignore.Target:FindFirstChild("DiedRecently")

                            if Ignore.Target and TargetCharacter:FindFirstChild(AimbotSettings.Aimpart) and IsDead == false and Distance < Config.MaxDistance then
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetCharacter[AimbotSettings.Aimpart].Position) 
                            end
                        end
                    end
                end
            end
        end 
    end)

    Flush(CurrentStep)
end)()

-- BEWARE MEMORY LEAK MIGHT BE DOWN HERE!!!!! kidding fixed last week 

local function AddBoxes(player)
    local CurrentStep -- I did this TO prevent lag in every esp func but now im too lazy to delete

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = BoxSettings.Color
    Box.Thickness = 2
    Box.Filled = false

    Flush(Box)

    local HeadOffset = Vector3.new(0, 0.5, 0)
    local LegOffset = Vector3.new(0, 3, 0)

    CurrentStep = RunService.RenderStepped:Connect(function()
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") ~= nil and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            local HeadPos = Camera:WorldToViewportPoint(player.Character.Head.Position + HeadOffset)
            local LegPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position - LegOffset)

            Box.Size = Vector2.new(1500 / Vector.Z, HeadPos.Y - LegPos.Y)
            Box.Position = Vector2.new(Vector.X - Box.Size.X / 2, Vector.Y - Box.Size.Y / 2)

            if OnScreen == true then
                if EspSettings.TeamCheck == true then
                    if player.Team ~= Player.Team then
                        Box.Visible = BoxSettings.Visible
                    else
                        Box.Visible = false
                    end
                else
                    Box.Visible = BoxSettings.Visible
                end
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
    end)

    Flush(CurrentStep)

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Box:Remove()
        end
    end)
end

local function AddTracer(player)
    local CurrentStep -- I did this TO prevent lag in every esp func but now im too lazy to delete

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = TracerSettings.Color
    Tracer.Thickness = 1
    Tracer.Transparency = 1

    Flush(Tracer)

    CurrentStep = RunService.RenderStepped:Connect(function()
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            if TracerSettings.Position == "Bottom" then
                Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1)
            elseif TracerSettings.Position == "Middle" then
                Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            elseif TracerSettings.Position == "Mouse" then
                Tracer.From = Vector2.new(Mouse.X, Mouse.Y)
            end
            Tracer.To = Vector2.new(Vector.X, Vector.Y)

            if OnScreen == true then
                if EspSettings.TeamCheck == true then
                    if player.Team ~= Player.Team then
                        Tracer.Visible = TracerSettings.Visible
                    else
                        Tracer.Visible = false
                    end
                else
                    Tracer.Visible = TracerSettings.Visible
                end
            else
                Tracer.Visible = false
            end
        else
            Tracer.Visible = false
        end
    end)

    Flush(CurrentStep)

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Tracer:Remove()
        end
    end)
end

local function AddName(player)
    local CurrentStep -- I did this TO prevent lag in every esp func but now im too lazy to delete

    local Text = Drawing.new("Text")
    Text.Transparency = 1
    Text.Size = 14
    Text.Outline = true
    Text.Center = true
    Text.Color = NameSettings.Color
    Text.OutlineColor = Color3.fromRGB(0,0,0)
    Text.Text = player.DisplayName

    Flush(Text)

    CurrentStep = RunService.RenderStepped:Connect(function()
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            Text.Position = Vector2.new(Vector.X, Vector.Y - 25)

            if OnScreen == true then
                if EspSettings.TeamCheck == true then
                    if player.Team ~= Player.Team then
                        Text.Visible = NameSettings.Visible
                    else
                        Text.Visible = false
                    end
                else
                    Text.Visible = NameSettings.Visible
                end
            else
                Text.Visible = false
            end
        else
            Text.Visible = false
        end
    end)

    Flush(CurrentStep)

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Text:Remove()
        end
    end)
end

for i,v in pairs(game.Players:GetPlayers()) do
    if v ~= Player then
        AddBoxes(v)
        AddTracer(v)
        AddName(v)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    AddBoxes(player)
    AddTracer(player)
    AddName(player)
end)
