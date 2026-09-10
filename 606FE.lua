--[[
    ================================================================
    606FE // UNIVERSAL FE PLAYER SUITE 2026
    CONFIDENTIAL & PROPRIETARY // PRIVATE SOURCE BUILD
    SYSTEM: ADVANCED TARGET RESOLVER + REPLICATED GOTO + FE BRING ENGINE
    AESTHETIC: GTA 6 LUXURY (ZERO STROKES // STRICT ZERO EMOJIS)
    ================================================================
]]

local Services = {
    Tween = game:GetService("TweenService"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cleanup previous instance if re-executing
if getgenv and getgenv()._606FE_Loaded then
    pcall(function()
        if getgenv()._606FE_Gui then
            getgenv()._606FE_Gui:Destroy()
        end
    end)
end

local Config = {
    Version = "1.0",
    MenuKey = Enum.KeyCode.RightControl,
    AltKey = Enum.KeyCode.RightShift,
    AntiFling = true,
    SafeOffset = Vector3.new(0, 3, 0),
    TeleportSpeed = 0.25
}

local Palette = {
    Background = Color3.fromRGB(12, 10, 18),
    Header = Color3.fromRGB(18, 14, 28),
    Card = Color3.fromRGB(22, 18, 34),
    CardBorder = Color3.fromRGB(40, 32, 60),
    InputBG = Color3.fromRGB(16, 12, 24),
    TextPrimary = Color3.fromRGB(240, 245, 255),
    TextSecondary = Color3.fromRGB(140, 130, 160),
    AccentCyan = Color3.fromRGB(0, 240, 255),
    AccentRed = Color3.fromRGB(255, 38, 58),
    AccentGreen = Color3.fromRGB(46, 213, 115),
    AccentPurple = Color3.fromRGB(160, 60, 255)
}

-- Safe GUI Parent Resolution (CoreGui -> gethui -> PlayerGui)
local function GetSafeGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    local ok, core = pcall(function() return Services.CoreGui end)
    if ok and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- System Notification Helper
local function Notify(title, text, duration)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = string.upper(title),
            Text = text,
            Duration = duration or 4
        })
    end)
end

-- Target Player Resolver (Supports partial username, display name, and case-insensitive matching)
local function ResolvePlayer(query)
    if not query or query == "" then return nil end
    local q = string.lower(string.gsub(query, "%s+", ""))
    
    -- Exact username match
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if string.lower(p.Name) == q then
            return p
        end
    end
    
    -- Exact display name match
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if string.lower(string.gsub(p.DisplayName, "%s+", "")) == q then
            return p
        end
    end
    
    -- Partial username match
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if string.find(string.lower(p.Name), q, 1, true) then
            return p
        end
    end
    
    -- Partial display name match
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if string.find(string.lower(p.DisplayName), q, 1, true) then
            return p
        end
    end
    
    return nil
end

-- ScreenGui Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "606FE_Suite_" .. tostring(math.random(10000, 99999))
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GetSafeGuiParent()

if getgenv then
    getgenv()._606FE_Loaded = true
    getgenv()._606FE_Gui = ScreenGui
end

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 480)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
MainFrame.BackgroundColor3 = Palette.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = Palette.Header
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderAccent = Instance.new("Frame")
HeaderAccent.Name = "AccentLine"
HeaderAccent.Size = UDim2.new(1, 0, 0, 2)
HeaderAccent.Position = UDim2.new(0, 0, 1, -2)
HeaderAccent.BackgroundColor3 = Palette.AccentCyan
HeaderAccent.BorderSizePixel = 0
HeaderAccent.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "606FE // PLAYER ENGINE"
TitleLabel.TextColor3 = Palette.TextPrimary
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(0, 120, 0, 14)
SubTitle.Position = UDim2.new(0, 16, 0, 32)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.GothamBold
SubTitle.Text = "FILTERING ENABLED SUITE v1.0"
SubTitle.TextColor3 = Palette.AccentCyan
SubTitle.TextSize = 9
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 20, 38)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Palette.TextSecondary
CloseBtn.TextSize = 13
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Window Dragging Functionality
local Dragging = false
local DragInput, DragStart, StartPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

Services.Input.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)

-- Content Container
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -24, 1, -64)
Content.Position = UDim2.new(0, 12, 0, 58)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Palette.CardBorder
Content.CanvasSize = UDim2.new(0, 0, 0, 560)
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.Parent = Content

-- Section: Target Input Card
local InputCard = Instance.new("Frame")
InputCard.Name = "InputCard"
InputCard.Size = UDim2.new(1, 0, 0, 84)
InputCard.BackgroundColor3 = Palette.Card
InputCard.BorderSizePixel = 0
InputCard.LayoutOrder = 1
InputCard.Parent = Content

local InputCardCorner = Instance.new("UICorner")
InputCardCorner.CornerRadius = UDim.new(0, 8)
InputCardCorner.Parent = InputCard

local InputTitle = Instance.new("TextLabel")
InputTitle.Size = UDim2.new(1, -20, 0, 20)
InputTitle.Position = UDim2.new(0, 10, 0, 8)
InputTitle.BackgroundTransparency = 1
InputTitle.Font = Enum.Font.GothamBold
InputTitle.Text = "TARGET USERNAME // DISPLAY NAME"
InputTitle.TextColor3 = Palette.TextSecondary
InputTitle.TextSize = 10
InputTitle.TextXAlignment = Enum.TextXAlignment.Left
InputTitle.Parent = InputCard

local TextBoxContainer = Instance.new("Frame")
TextBoxContainer.Size = UDim2.new(1, -20, 0, 38)
TextBoxContainer.Position = UDim2.new(0, 10, 0, 34)
TextBoxContainer.BackgroundColor3 = Palette.InputBG
TextBoxContainer.BorderSizePixel = 0
TextBoxContainer.Parent = InputCard

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = TextBoxContainer

local TargetBox = Instance.new("TextBox")
TargetBox.Name = "TargetBox"
TargetBox.Size = UDim2.new(1, -16, 1, 0)
TargetBox.Position = UDim2.new(0, 8, 0, 0)
TargetBox.BackgroundTransparency = 1
TargetBox.Font = Enum.Font.GothamMedium
TargetBox.PlaceholderText = "Type player name (e.g. Harasre)..."
TargetBox.PlaceholderColor3 = Color3.fromRGB(90, 80, 110)
TargetBox.Text = ""
TargetBox.TextColor3 = Palette.TextPrimary
TargetBox.TextSize = 12
TargetBox.ClearTextOnFocus = false
TargetBox.TextXAlignment = Enum.TextXAlignment.Left
TargetBox.Parent = TextBoxContainer

-- Section: Target Status Preview Card
local PreviewCard = Instance.new("Frame")
PreviewCard.Name = "PreviewCard"
PreviewCard.Size = UDim2.new(1, 0, 0, 72)
PreviewCard.BackgroundColor3 = Palette.Card
PreviewCard.BorderSizePixel = 0
PreviewCard.LayoutOrder = 2
PreviewCard.Parent = Content

local PreviewCorner = Instance.new("UICorner")
PreviewCorner.CornerRadius = UDim.new(0, 8)
PreviewCorner.Parent = PreviewCard

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Name = "Avatar"
AvatarImg.Size = UDim2.new(0, 48, 0, 48)
AvatarImg.Position = UDim2.new(0, 12, 0, 12)
AvatarImg.BackgroundColor3 = Palette.InputBG
AvatarImg.BorderSizePixel = 0
AvatarImg.Image = "rbxassetid://0"
AvatarImg.Parent = PreviewCard

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 24)
AvatarCorner.Parent = AvatarImg

local TargetNameLabel = Instance.new("TextLabel")
TargetNameLabel.Name = "TargetName"
TargetNameLabel.Size = UDim2.new(1, -74, 0, 20)
TargetNameLabel.Position = UDim2.new(0, 68, 0, 14)
TargetNameLabel.BackgroundTransparency = 1
TargetNameLabel.Font = Enum.Font.GothamBold
TargetNameLabel.Text = "NO TARGET SELECTED"
TargetNameLabel.TextColor3 = Palette.TextSecondary
TargetNameLabel.TextSize = 13
TargetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetNameLabel.Parent = PreviewCard

local TargetDistLabel = Instance.new("TextLabel")
TargetDistLabel.Name = "TargetDist"
TargetDistLabel.Size = UDim2.new(1, -74, 0, 16)
TargetDistLabel.Position = UDim2.new(0, 68, 0, 36)
TargetDistLabel.BackgroundTransparency = 1
TargetDistLabel.Font = Enum.Font.GothamMedium
TargetDistLabel.Text = "DISTANCE: -- STUDS"
TargetDistLabel.TextColor3 = Palette.AccentCyan
TargetDistLabel.TextSize = 11
TargetDistLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetDistLabel.Parent = PreviewCard

-- Section: Action Buttons Card
local ActionCard = Instance.new("Frame")
ActionCard.Name = "ActionCard"
ActionCard.Size = UDim2.new(1, 0, 0, 110)
ActionCard.BackgroundColor3 = Palette.Card
ActionCard.BorderSizePixel = 0
ActionCard.LayoutOrder = 3
ActionCard.Parent = Content

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 8)
ActionCorner.Parent = ActionCard

local ActionTitle = Instance.new("TextLabel")
ActionTitle.Size = UDim2.new(1, -20, 0, 20)
ActionTitle.Position = UDim2.new(0, 10, 0, 8)
ActionTitle.BackgroundTransparency = 1
ActionTitle.Font = Enum.Font.GothamBold
ActionTitle.Text = "REPLICATED ACTIONS"
ActionTitle.TextColor3 = Palette.TextSecondary
ActionTitle.TextSize = 10
ActionTitle.TextXAlignment = Enum.TextXAlignment.Left
ActionTitle.Parent = ActionCard

-- Button: BRING PLAYER
local BringBtn = Instance.new("TextButton")
BringBtn.Name = "BringBtn"
BringBtn.Size = UDim2.new(0.48, -4, 0, 42)
BringBtn.Position = UDim2.new(0, 10, 0, 32)
BringBtn.BackgroundColor3 = Palette.AccentRed
BringBtn.BorderSizePixel = 0
BringBtn.Font = Enum.Font.GothamBold
BringBtn.Text = "BRING PLAYER"
BringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BringBtn.TextSize = 12
BringBtn.Parent = ActionCard

local BringCorner = Instance.new("UICorner")
BringCorner.CornerRadius = UDim.new(0, 6)
BringCorner.Parent = BringBtn

-- Button: GOTO (TELEPORT TO TARGET)
local GotoBtn = Instance.new("TextButton")
GotoBtn.Name = "GotoBtn"
GotoBtn.Size = UDim2.new(0.48, -4, 0, 42)
GotoBtn.Position = UDim2.new(0.52, 2, 0, 32)
GotoBtn.BackgroundColor3 = Palette.AccentCyan
GotoBtn.BorderSizePixel = 0
GotoBtn.Font = Enum.Font.GothamBold
GotoBtn.Text = "GOTO PLAYER"
GotoBtn.TextColor3 = Color3.fromRGB(10, 15, 25)
GotoBtn.TextSize = 12
GotoBtn.Parent = ActionCard

local GotoCorner = Instance.new("UICorner")
GotoCorner.CornerRadius = UDim.new(0, 6)
GotoCorner.Parent = GotoBtn

local ActionNote = Instance.new("TextLabel")
ActionNote.Size = UDim2.new(1, -20, 0, 20)
ActionNote.Position = UDim2.new(0, 10, 0, 82)
ActionNote.BackgroundTransparency = 1
ActionNote.Font = Enum.Font.GothamMedium
ActionNote.Text = "Goto replicates 100% via LocalPlayer physics ownership"
ActionNote.TextColor3 = Palette.TextSecondary
ActionNote.TextSize = 9
ActionNote.TextXAlignment = Enum.TextXAlignment.Center
ActionNote.Parent = ActionCard

-- Section: Server Admin & FE Architecture Guide Card
local GuideCard = Instance.new("Frame")
GuideCard.Name = "GuideCard"
GuideCard.Size = UDim2.new(1, 0, 0, 140)
GuideCard.BackgroundColor3 = Palette.Card
GuideCard.BorderSizePixel = 0
GuideCard.LayoutOrder = 4
GuideCard.Parent = Content

local GuideCorner = Instance.new("UICorner")
GuideCorner.CornerRadius = UDim.new(0, 8)
GuideCorner.Parent = GuideCard

local GuideTitle = Instance.new("TextLabel")
GuideTitle.Size = UDim2.new(1, -20, 0, 20)
GuideTitle.Position = UDim2.new(0, 10, 0, 8)
GuideTitle.BackgroundTransparency = 1
GuideTitle.Font = Enum.Font.GothamBold
GuideTitle.Text = "FILTERING ENABLED (FE) ARCHITECTURE"
GuideTitle.TextColor3 = Palette.TextSecondary
GuideTitle.TextSize = 10
GuideTitle.TextXAlignment = Enum.TextXAlignment.Left
GuideTitle.Parent = GuideCard

local GuideDesc = Instance.new("TextLabel")
GuideDesc.Size = UDim2.new(1, -20, 0, 56)
GuideDesc.Position = UDim2.new(0, 10, 0, 30)
GuideDesc.BackgroundTransparency = 1
GuideDesc.Font = Enum.Font.GothamMedium
GuideDesc.Text = "Roblox FE assigns character physics ownership to each respective client. Under standard FE rules, moving an opponent client-side only affects your local screen. To replicate a true server-wide Bring, server execution (or an Admin command) is required."
GuideDesc.TextColor3 = Palette.TextSecondary
GuideDesc.TextSize = 10
GuideDesc.TextWrapped = true
GuideDesc.TextXAlignment = Enum.TextXAlignment.Left
GuideDesc.TextYAlignment = Enum.TextYAlignment.Top
GuideDesc.Parent = GuideCard

local CopyScriptBtn = Instance.new("TextButton")
CopyScriptBtn.Name = "CopyScriptBtn"
CopyScriptBtn.Size = UDim2.new(1, -20, 0, 34)
CopyScriptBtn.Position = UDim2.new(0, 10, 0, 96)
CopyScriptBtn.BackgroundColor3 = Palette.InputBG
CopyScriptBtn.BorderSizePixel = 0
CopyScriptBtn.Font = Enum.Font.GothamBold
CopyScriptBtn.Text = "COPY SERVER ADMIN SCRIPT TO CLIPBOARD"
CopyScriptBtn.TextColor3 = Palette.AccentCyan
CopyScriptBtn.TextSize = 10
CopyScriptBtn.Parent = GuideCard

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyScriptBtn

-- Floating Mini Toggle Button (Always accessible on screen)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "606FE_Toggle"
ToggleButton.Size = UDim2.new(0, 80, 0, 32)
ToggleButton.Position = UDim2.new(0, 16, 0.5, -16)
ToggleButton.BackgroundColor3 = Palette.Header
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "606FE"
ToggleButton.TextColor3 = Palette.AccentCyan
ToggleButton.TextSize = 12
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Keybind Toggle
Services.Input.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.MenuKey or input.KeyCode == Config.AltKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--------------------------------------------------------------------
-- TARGET LOGIC & TELEPORT IMPLEMENTATION
--------------------------------------------------------------------
local CurrentTarget = nil

local function UpdateTargetPreview()
    local text = TargetBox.Text
    local target = ResolvePlayer(text)
    CurrentTarget = target
    
    if target and target ~= LocalPlayer then
        TargetNameLabel.Text = string.format("%s (@%s)", target.DisplayName, target.Name)
        TargetNameLabel.TextColor3 = Palette.TextPrimary
        
        -- Fetch player avatar thumbnail
        pcall(function()
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size48x48
            local contentUri = Services.Players:GetUserThumbnailAsync(target.UserId, thumbType, thumbSize)
            AvatarImg.Image = contentUri
        end)
        
        -- Compute live distance
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if myRoot and tRoot then
            local dist = math.floor((tRoot.Position - myRoot.Position).Magnitude)
            TargetDistLabel.Text = string.format("DISTANCE: %d STUDS", dist)
        else
            TargetDistLabel.Text = "DISTANCE: AVAILABLE"
        end
    else
        TargetNameLabel.Text = (text ~= "" and "PLAYER NOT FOUND") or "NO TARGET SELECTED"
        TargetNameLabel.TextColor3 = (text ~= "" and Palette.AccentRed) or Palette.TextSecondary
        TargetDistLabel.Text = "DISTANCE: -- STUDS"
        AvatarImg.Image = "rbxassetid://0"
    end
end

TargetBox:GetPropertyChangedSignal("Text"):Connect(UpdateTargetPreview)

-- Live distance updater loop
Services.Run.Heartbeat:Connect(function()
    if MainFrame.Visible and CurrentTarget and CurrentTarget.Character then
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local tRoot = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and tRoot then
            local dist = math.floor((tRoot.Position - myRoot.Position).Magnitude)
            TargetDistLabel.Text = string.format("DISTANCE: %d STUDS", dist)
        end
    end
end)

-- Execute GOTO (Teleports LocalPlayer to target position safely)
GotoBtn.MouseButton1Click:Connect(function()
    if not CurrentTarget then
        Notify("606FE", "Please enter a valid player username first!", 3)
        return
    end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHuman = myChar and myChar:FindFirstChildOfClass("Humanoid")
    
    local tChar = CurrentTarget.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot or not myHuman or myHuman.Health <= 0 then
        Notify("606FE", "Your character is not spawned or is dead!", 3)
        return
    end
    
    if not tRoot then
        Notify("606FE", "Target character is not spawned yet!", 3)
        return
    end
    
    -- Safe velocity neutralization (prevents launching or ragdolling)
    pcall(function()
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
    
    -- Smooth safe arrival offset
    local targetCFrame = tRoot.CFrame + Config.SafeOffset
    myRoot.CFrame = targetCFrame
    
    Notify("606FE", "Teleported to " .. CurrentTarget.DisplayName, 3)
end)

-- Execute BRING Action
BringBtn.MouseButton1Click:Connect(function()
    if not CurrentTarget then
        Notify("606FE", "Please enter a valid player username first!", 3)
        return
    end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tChar = CurrentTarget.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then
        Notify("606FE", "Your character is not ready!", 3)
        return
    end
    if not tRoot then
        Notify("606FE", "Target character is not spawned!", 3)
        return
    end
    
    -- Client-side displacement attempt
    pcall(function()
        tRoot.CFrame = myRoot.CFrame + Vector3.new(0, 0, -4)
    end)
    
    Notify("606FE // BRING", "Brought " .. CurrentTarget.DisplayName .. " (Client-side). Under standard FE, only the server can replicate character movement across all players.", 5)
end)

-- Copy Server-Side Admin Script to Clipboard
local ServerAdminCode = [[-- 606FE SERVER ADMIN SCRIPT (Place in ServerScriptService)
game.Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        local args = string.split(msg, " ")
        if args[1]:lower() == ":bring" and args[2] then
            local targetName = args[2]:lower()
            for _, target in ipairs(game.Players:GetPlayers()) do
                if target.Name:lower():find(targetName) or target.DisplayName:lower():find(targetName) then
                    local pChar = player.Character
                    local tChar = target.Character
                    if pChar and tChar and pChar:FindFirstChild("HumanoidRootPart") and tChar:FindFirstChild("HumanoidRootPart") then
                        tChar.HumanoidRootPart.CFrame = pChar.HumanoidRootPart.CFrame + Vector3.new(0, 0, -4)
                        print(string.format("[606FE] Server brought %s to %s", target.Name, player.Name))
                    end
                    break
                end
            end
        end
    end)
end)]]

CopyScriptBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(ServerAdminCode)
        Notify("606FE", "Server admin script copied to clipboard!", 4)
    else
        Notify("606FE", "Your executor does not support setclipboard.", 4)
    end
end)

Notify("606FE SUITE", "Loaded successfully! Press RightControl to toggle menu.", 4)
