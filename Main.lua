local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Farls-Xavier/UiLibrary/main/Library.lua"))()

local Ignore = {
    Flushable = {},
    Target = nil,
    CanPass = false
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
                "MaxDistance": 750,
                "Note": "FOR MAX DISTANCE I WOULD KEEP AT 750 OR DECREASE IDK WHY YOU WOULD BUT YOU CAN"
            }
        ]])
    else
        if not isfile("@FarlsXavier\\Arsenal\\Config.ini") then
            warn("Config file '@FarlsXavier\\Arsenal\\Config.ini' doesn't exist. Creating file.")
            writefile("@FarlsXavier\\Arsenal\\Config.ini", [[
                {
                    "Name": "Arsenal Script",
                    "MaxDistance": 750,
                    "Note": "FOR MAX DISTANCE I WOULD KEEP AT 750 OR DECREASE IDK WHY YOU WOULD BUT YOU CAN"
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

local ConfigDecode = HttpService:JSONDecode(readfile("@FarlsXavier\\Arsenal\\Config.ini"))

local Holding = false

local Window = Library:Window({
    Title = ConfigDecode.Name or "Arsenal - 286090429",
    OnClose = function()
        for i,v in pairs(Ignore.Flushable) do
            pcall(function()
                v:Remove()
                Ignore.CanPass = false
            end)
        end
        Library:destroy()
    end
})

local EspSettings = {
    TeamCheck = false
}

local TracerSettings = {
    Visible = false,
    Color = Color3.fromRGB(79, 47, 94),
    Position = "Bottom"
}

local BoxSettings = {
    Visible = false,
    Color = Color3.fromRGB(79, 47, 94)
}

local NameSettings = {
    Visible = false,
    Color = Color3.fromRGB(79, 47, 94)
}

local AimbotSettings = {
    Enabled = false,
    WallCheck = false,
    TeamCheck = false,
    Aimpart = "Head", -- Torso, Head
    Smoothness = 0
}

local FovSettings = {
    Visible = false,
    Enabled = false,
    Color = Color3.fromRGB(79, 47, 94),
    Size = 90
}

local Tabs = {
    ["Aim"] = Window:Tab({
        Text = "Aim",
        Icon = "rbxassetid://14966164502"
    }),

    ["ESP"] = Window:Tab({
        Text = "Visuals",
        Icon = "rbxassetid://14966779139"
    }),

    ["Player"] = Window:Tab({
        Text = "Player",
        Icon = "rbxassetid://14958157475"
    }),

    ["Skin Changer"] = Window:Tab({
        Text = "Skin Changer",
        Icon = "rbxassetid://14936481814"
    })
}

local AimTab = {
    ["Aimbot Toggle"] = Tabs.Aim:Toggle({
        Text = "Aimbot",
        Callback = function(v)
            AimbotSettings.Enabled = v
        end
    }),

    ["Wall Check Toggle"] = Tabs.Aim:Toggle({
        Text = "WallCheck",
        Callback = function(v)
            AimbotSettings.WallCheck = v
        end
    }), 

    ["Team Check Toggle"] = Tabs.Aim:Toggle({
        Text = "TeamCheck",
        Callback = function(v)
            AimbotSettings.TeamCheck = v
        end
    }),

    ["Smoothness Slider"] = Tabs.Aim:Slider({
        Text = "Smoothness",
        Min = 0,
        Max = 1,
        Default = 0,
        decimals = true,
        Callback = function(v)
            AimbotSettings.Smoothness = v
        end
    }),

    ["SEPERATOR11"] = Tabs.Aim:Label({
        Text = "--------------------------------------------"
    }),

    ["Fov enabled Toggle"] = Tabs.Aim:Toggle({
        Text = "FOV",
        Callback = function(v)
            FovSettings.Enabled = v
        end
    }),

    ["Fov Toggle"] = Tabs.Aim:Toggle({
        Text = "FOV Visible",
        Callback = function(v)
            FovSettings.Visible = v
        end
    }),

    ["Fov Size Slider"] = Tabs.Aim:Slider({
        Text = "FOV Size",
        Min = 10,
        Max = 999,
        Default = 90,
        Callback = function(v)
            FovSettings.Size = v
        end
    }),
}

local PlayerTab = {
    ["WalkSpeed Slider"] = Tabs.Player:Slider({
        Text = "WalkSpeed",
        Min = 0,
        Max = 500,
        Default = Char:WaitForChild("Humanoid", math.huge).WalkSpeed,
        Callback = function(v)
            Char:WaitForChild("Humanoid", math.huge).WalkSpeed = v
        end
    }),
    
    ["JumpPower Slider"] = Tabs.Player:Slider({
        Text = "JumpPower",
        Min = 0,
        Max = 500,
        Default = Char:WaitForChild("Humanoid", math.huge).JumpPower or Char:WaitForChild("Humanoid", math.huge).JumpHeight,
        Callback = function(v)
            Char:WaitForChild("Humanoid", math.huge).JumpPower = v
            pcall(function()
                Char:WaitForChild("Humanoid", math.huge).JumpHeight = v
            end)
        end
    })
}

local SkinChangerTab = {
    ["SoonLabel"] = Tabs["Skin Changer"]:Label({
        Text = "Will do when dropboxes(2032)",
        Weight = Enum.FontWeight.Heavy
    })
}

local fov = Drawing.new("Circle") fov.Transparency = 1 fov.Filled = false fov.Color = FovSettings.Color

local function GetClosestPlayer()
    local MaxDistance
    if FovSettings.Enabled == true then 
        MaxDistance = FovSettings.Size
    else
        MaxDistance = 9999999
        coroutine.wrap(function()
            wait(20); MaxDistance = 9999999
  	    end)()
    end

    for i,v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and Target == nil then
            if AimbotSettings.TeamCheck == true then
                if v.Team ~= Player.Team then
                    if v.Character ~= nil then
                        if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health > 0 then
                                local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                                if VectorDistance < MaxDistance and OnScreen == true then
                                    if AimbotSettings.WallCheck == true then
                                        if NotObstructing(v.Character[AimbotSettings.Aimpart].Position, {Player.Character, v.Character}) then
                                            Target = v
                                        end
                                    else
                                        Target = v
                                    end 
                                end
                            end
                        end
                    end
                end
            else
                if v.Character ~= nil then
					if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
						if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
							local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
							local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

							if VectorDistance < MaxDistance and OnScreen == true then
                                if AimbotSettings.WallCheck == true then
                                    if NotObstructing(v.Character[AimbotSettings.Aimpart].Position, {Player.Character, v.Character}) then
                                        Target = v
                                    end
                                else
                                    Target = v
                                end
							end
						end
					end
				end
            end
        end
    end

    return Target
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotSettings.Enabled == true then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotSettings.Enabled == true then
        Holding = false
        Target = nil
    end
end)

fov.Visible = false

coroutine.wrap(function()
    local CurrentStep

    Flush(CurrentStep)

    CurrentStep = RunService.RenderStepped:Connect(function()
        fov.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        if FovSettings.Enabled == true then
            fov.Visible = FovSettings.Visible
        else
            FovSettings.Visible = false
            fov.Visible = false
        end
        fov.Radius = FovSettings.Size
        if Holding == true and AimbotSettings.Enabled == true and Ignore.CanPass == true then
            if AimbotSettings.Smoothness > 0 then
                GetClosestPlayer()

                local part1, part2 = Target.Character:FindFirstChild("HumanoidRootPart"), Player.Character:FindFirstChild("HumanoidRootPart")
                local Distance = (part1.Position - part2.Position).Magnitude

                if Target and Target.Character and Target.Character:FindFirstChild(AimbotSettings.Aimpart) ~= nil and not Target:FindFirstChild("Deaded") or Target:FindFirstChild("RecentlyDied") and not Distance > ConfigDecode.MaxDistance then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Character[AimbotSettings.Aimpart].Position), AimbotSettings.Smoothness)
                end
            else
                GetClosestPlayer()

                local part1, part2 = Target.Character:FindFirstChild("HumanoidRootPart"), Player.Character:FindFirstChild("HumanoidRootPart")
                local Distance = (part1.Position - part2.Position).Magnitude

                if Target ~= nil and Target.Character and Target.Character:FindFirstChild(AimbotSettings.Aimpart) ~= nil and not Target:FindFirstChild("Deaded") or Target:FindFirstChild("RecentlyDied") and not Distance > ConfigDecode.MaxDistance then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[AimbotSettings.Aimpart].Position) 
                end
            end
        end
    end)
end)()

local function AddBoxes(player)
    local CurrentStep

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = BoxSettings.Color
    Box.Thickness = 2
    Box.Filled = false

    Flush(Box)
    Flush(CurrentStep)

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

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Box:Remove()
        end
    end)
end

local function AddTracer(player)
    local CurrentStep

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = TracerSettings.Color
    Tracer.Thickness = 1
    Tracer.Transparency = 1

    Flush(Tracer)
    Flush(CurrentStep)

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

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Tracer:Remove()
        end
    end)
end

local function AddName(player)
    local CurrentStep

    local Text = Drawing.new("Text")
    Text.Transparency = 1
    Text.Size = 14
    Text.Outline = true
    Text.Center = true
    Text.Color = NameSettings.Color
    Text.OutlineColor = Color3.fromRGB(0,0,0)
    Text.Text = player.DisplayName

    Flush(Text)
    Flush(CurrentStep)

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

function NotObstructing(Destination, Ignore)
    local Origin = Camera.CFrame.Position
    local CheckRay = Ray.new(Origin, Destination - Origin)
    local Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay, Ignore)
    return Hit == nil
end

function Flush(instance)
    table.insert(Ignore.Flushable, instance)
end
