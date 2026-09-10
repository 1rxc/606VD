--[[
    ================================================================
    606FE // UNIVERSAL FE PLAYER SUITE 2026 // v1.1
    CONFIDENTIAL & PROPRIETARY // PRIVATE SOURCE BUILD
    SYSTEM: INTERACTIVE PLAYER LIST + BRING CONFIRMATION MODAL + GOTO
    VERSION: 1.1
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
    Version = "1.1",
    MenuKey = Enum.KeyCode.RightControl,
    AltKey = Enum.KeyCode.RightShift,
    SafeOffset = Vector3.new(0, 3, 0),
    BringDistance = 4
}

local Palette = {
    Background = Color3.fromRGB(12, 10, 18),
    Header = Color3.fromRGB(18, 14, 28),
    Card = Color3.fromRGB(22, 18, 34),
    CardHover = Color3.fromRGB(32, 26, 48),
    CardBorder = Color3.fromRGB(40, 32, 60),
    InputBG = Color3.fromRGB(16, 12, 24),
    TextPrimary = Color3.fromRGB(240, 245, 255),
    TextSecondary = Color3.fromRGB(140, 130, 160),
    AccentCyan = Color3.fromRGB(0, 240, 255),
    AccentRed = Color3.fromRGB(255, 38, 58),
    AccentGreen = Color3.fromRGB(46, 213, 115),
    DimBackdrop = Color3.fromRGB(6, 4, 10),
    ModalCard = Color3.fromRGB(20, 16, 32)
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

-- ScreenGui Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "606FE_Suite_v11_" .. tostring(math.random(10000, 99999))
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
MainFrame.Size = UDim2.new(0, 420, 0, 520)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
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
Header.ZIndex = 2
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
HeaderAccent.ZIndex = 3
HeaderAccent.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -120, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "606FE // PLAYER ENGINE"
TitleLabel.TextColor3 = Palette.TextPrimary
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = Header

-- Version Pill Badge
local VersionBadge = Instance.new("Frame")
VersionBadge.Name = "VersionBadge"
VersionBadge.Size = UDim2.new(0, 46, 0, 20)
VersionBadge.Position = UDim2.new(1, -95, 0, 16)
VersionBadge.BackgroundColor3 = Palette.Card
VersionBadge.BorderSizePixel = 0
VersionBadge.ZIndex = 3
VersionBadge.Parent = Header

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = VersionBadge

local BadgeText = Instance.new("TextLabel")
BadgeText.Size = UDim2.new(1, 0, 1, 0)
BadgeText.BackgroundTransparency = 1
BadgeText.Font = Enum.Font.GothamBold
BadgeText.Text = "v1.1"
BadgeText.TextColor3 = Palette.AccentCyan
BadgeText.TextSize = 10
BadgeText.ZIndex = 4
BadgeText.Parent = VersionBadge

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
CloseBtn.ZIndex = 3
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

-- Search & Filter Container
local SearchContainer = Instance.new("Frame")
SearchContainer.Name = "SearchContainer"
SearchContainer.Size = UDim2.new(1, -24, 0, 38)
SearchContainer.Position = UDim2.new(0, 12, 0, 60)
SearchContainer.BackgroundColor3 = Palette.Card
SearchContainer.BorderSizePixel = 0
SearchContainer.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchContainer

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -20, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.PlaceholderText = "Search player name or username..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 80, 110)
SearchBox.Text = ""
SearchBox.TextColor3 = Palette.TextPrimary
SearchBox.TextSize = 12
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Parent = SearchContainer

-- Player Counter Header
local CounterBar = Instance.new("Frame")
CounterBar.Name = "CounterBar"
CounterBar.Size = UDim2.new(1, -24, 0, 22)
CounterBar.Position = UDim2.new(0, 12, 0, 104)
CounterBar.BackgroundTransparency = 1
CounterBar.BorderSizePixel = 0
CounterBar.Parent = MainFrame

local CounterLabel = Instance.new("TextLabel")
CounterLabel.Name = "CounterLabel"
CounterLabel.Size = UDim2.new(1, 0, 1, 0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Font = Enum.Font.GothamBold
CounterLabel.Text = "PLAYERS IN SERVER (0)"
CounterLabel.TextColor3 = Palette.TextSecondary
CounterLabel.TextSize = 10
CounterLabel.TextXAlignment = Enum.TextXAlignment.Left
CounterLabel.Parent = CounterBar

-- Player List Scroll Container
local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Name = "PlayerListScroll"
PlayerListScroll.Size = UDim2.new(1, -24, 1, -136)
PlayerListScroll.Position = UDim2.new(0, 12, 0, 128)
PlayerListScroll.BackgroundTransparency = 1
PlayerListScroll.BorderSizePixel = 0
PlayerListScroll.ScrollBarThickness = 3
PlayerListScroll.ScrollBarImageColor3 = Palette.CardBorder
PlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListScroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = PlayerListScroll

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

--------------------------------------------------------------------
-- CONFIRMATION MODAL POPUP (TAP OPTION BRING OR NOT)
--------------------------------------------------------------------
local ModalBackdrop = Instance.new("Frame")
ModalBackdrop.Name = "ModalBackdrop"
ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
ModalBackdrop.Position = UDim2.new(0, 0, 0, 0)
ModalBackdrop.BackgroundColor3 = Palette.DimBackdrop
ModalBackdrop.BackgroundTransparency = 0.35
ModalBackdrop.BorderSizePixel = 0
ModalBackdrop.Visible = false
ModalBackdrop.ZIndex = 10
ModalBackdrop.Parent = MainFrame

local ModalCard = Instance.new("Frame")
ModalCard.Name = "ModalCard"
ModalCard.Size = UDim2.new(0, 360, 0, 240)
ModalCard.Position = UDim2.new(0.5, -180, 0.5, -120)
ModalCard.BackgroundColor3 = Palette.ModalCard
ModalCard.BorderSizePixel = 0
ModalCard.ClipsDescendants = true
ModalCard.ZIndex = 11
ModalCard.Parent = ModalBackdrop

local ModalCorner = Instance.new("UICorner")
ModalCorner.CornerRadius = UDim.new(0, 12)
ModalCorner.Parent = ModalCard

local ModalHeaderLine = Instance.new("Frame")
ModalHeaderLine.Size = UDim2.new(1, 0, 0, 2)
ModalHeaderLine.Position = UDim2.new(0, 0, 0, 0)
ModalHeaderLine.BackgroundColor3 = Palette.AccentRed
ModalHeaderLine.BorderSizePixel = 0
ModalHeaderLine.ZIndex = 12
ModalHeaderLine.Parent = ModalCard

local ModalTitle = Instance.new("TextLabel")
ModalTitle.Size = UDim2.new(1, -24, 0, 24)
ModalTitle.Position = UDim2.new(0, 12, 0, 12)
ModalTitle.BackgroundTransparency = 1
ModalTitle.Font = Enum.Font.GothamBlack
ModalTitle.Text = "CONFIRM PLAYER ACTION"
ModalTitle.TextColor3 = Palette.TextPrimary
ModalTitle.TextSize = 13
ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
ModalTitle.ZIndex = 12
ModalTitle.Parent = ModalCard

local ModalAvatar = Instance.new("ImageLabel")
ModalAvatar.Name = "ModalAvatar"
ModalAvatar.Size = UDim2.new(0, 48, 0, 48)
ModalAvatar.Position = UDim2.new(0, 16, 0, 42)
ModalAvatar.BackgroundColor3 = Palette.InputBG
ModalAvatar.BorderSizePixel = 0
ModalAvatar.Image = "rbxassetid://0"
ModalAvatar.ZIndex = 12
ModalAvatar.Parent = ModalCard

local ModalAvatarCorner = Instance.new("UICorner")
ModalAvatarCorner.CornerRadius = UDim.new(0, 24)
ModalAvatarCorner.Parent = ModalAvatar

local ModalTargetName = Instance.new("TextLabel")
ModalTargetName.Name = "ModalTargetName"
ModalTargetName.Size = UDim2.new(1, -80, 0, 20)
ModalTargetName.Position = UDim2.new(0, 72, 0, 44)
ModalTargetName.BackgroundTransparency = 1
ModalTargetName.Font = Enum.Font.GothamBold
ModalTargetName.Text = "PLAYER NAME"
ModalTargetName.TextColor3 = Palette.TextPrimary
ModalTargetName.TextSize = 13
ModalTargetName.TextXAlignment = Enum.TextXAlignment.Left
ModalTargetName.ZIndex = 12
ModalTargetName.Parent = ModalCard

local ModalQuestion = Instance.new("TextLabel")
ModalQuestion.Name = "ModalQuestion"
ModalQuestion.Size = UDim2.new(1, -80, 0, 20)
ModalQuestion.Position = UDim2.new(0, 72, 0, 66)
ModalQuestion.BackgroundTransparency = 1
ModalQuestion.Font = Enum.Font.GothamMedium
ModalQuestion.Text = "Do you want to bring this player to your location?"
ModalQuestion.TextColor3 = Palette.TextSecondary
ModalQuestion.TextSize = 10
ModalQuestion.TextWrapped = true
ModalQuestion.TextXAlignment = Enum.TextXAlignment.Left
ModalQuestion.ZIndex = 12
ModalQuestion.Parent = ModalCard

-- Buttons Container in Modal
local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(1, -32, 0, 110)
BtnContainer.Position = UDim2.new(0, 16, 0, 106)
BtnContainer.BackgroundTransparency = 1
BtnContainer.BorderSizePixel = 0
BtnContainer.ZIndex = 12
BtnContainer.Parent = ModalCard

-- Primary Action: BRING
local ModalBringBtn = Instance.new("TextButton")
ModalBringBtn.Name = "ModalBringBtn"
ModalBringBtn.Size = UDim2.new(1, 0, 0, 36)
ModalBringBtn.Position = UDim2.new(0, 0, 0, 0)
ModalBringBtn.BackgroundColor3 = Palette.AccentRed
ModalBringBtn.BorderSizePixel = 0
ModalBringBtn.Font = Enum.Font.GothamBold
ModalBringBtn.Text = "YES, BRING PLAYER"
ModalBringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModalBringBtn.TextSize = 12
ModalBringBtn.ZIndex = 13
ModalBringBtn.Parent = BtnContainer

local MBringCorner = Instance.new("UICorner")
MBringCorner.CornerRadius = UDim.new(0, 6)
MBringCorner.Parent = ModalBringBtn

-- Secondary Action: GOTO (Teleport to player)
local ModalGotoBtn = Instance.new("TextButton")
ModalGotoBtn.Name = "ModalGotoBtn"
ModalGotoBtn.Size = UDim2.new(0.48, -4, 0, 32)
ModalGotoBtn.Position = UDim2.new(0, 0, 0, 42)
ModalGotoBtn.BackgroundColor3 = Palette.Card
ModalGotoBtn.BorderSizePixel = 0
ModalGotoBtn.Font = Enum.Font.GothamBold
ModalGotoBtn.Text = "GOTO INSTEAD"
ModalGotoBtn.TextColor3 = Palette.AccentCyan
ModalGotoBtn.TextSize = 11
ModalGotoBtn.ZIndex = 13
ModalGotoBtn.Parent = BtnContainer

local MGotoCorner = Instance.new("UICorner")
MGotoCorner.CornerRadius = UDim.new(0, 6)
MGotoCorner.Parent = ModalGotoBtn

-- Dismiss Action: CANCEL (Do not bring)
local ModalCancelBtn = Instance.new("TextButton")
ModalCancelBtn.Name = "ModalCancelBtn"
ModalCancelBtn.Size = UDim2.new(0.48, -4, 0, 32)
ModalCancelBtn.Position = UDim2.new(0.52, 4, 0, 42)
ModalCancelBtn.BackgroundColor3 = Color3.fromRGB(28, 20, 38)
ModalCancelBtn.BorderSizePixel = 0
ModalCancelBtn.Font = Enum.Font.GothamBold
ModalCancelBtn.Text = "NO, CANCEL"
ModalCancelBtn.TextColor3 = Palette.TextSecondary
ModalCancelBtn.TextSize = 11
ModalCancelBtn.ZIndex = 13
ModalCancelBtn.Parent = BtnContainer

local MCancelCorner = Instance.new("UICorner")
MCancelCorner.CornerRadius = UDim.new(0, 6)
MCancelCorner.Parent = ModalCancelBtn

local SelectedPlayer = nil

local function ShowModal(player)
    SelectedPlayer = player
    ModalTargetName.Text = string.format("%s (@%s)", player.DisplayName, player.Name)
    ModalQuestion.Text = string.format("Bring %s to your current location?", player.DisplayName)
    
    pcall(function()
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size48x48
        local contentUri = Services.Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
        ModalAvatar.Image = contentUri
    end)
    
    ModalBackdrop.Visible = true
end

local function HideModal()
    ModalBackdrop.Visible = false
    SelectedPlayer = nil
end

ModalCancelBtn.MouseButton1Click:Connect(HideModal)

-- Execute BRING
ModalBringBtn.MouseButton1Click:Connect(function()
    if not SelectedPlayer then HideModal(); return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tChar = SelectedPlayer.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then
        Notify("606FE", "Your character is not ready!", 3)
        HideModal()
        return
    end
    if not tRoot then
        Notify("606FE", "Target character is not spawned!", 3)
        HideModal()
        return
    end
    
    -- Client-side bring displacement
    pcall(function()
        tRoot.CFrame = myRoot.CFrame + Vector3.new(0, 0, -Config.BringDistance)
    end)
    
    Notify("606FE // BRING", "Brought " .. SelectedPlayer.DisplayName .. " to you! (Client-side under FE)", 4)
    HideModal()
end)

-- Execute GOTO
ModalGotoBtn.MouseButton1Click:Connect(function()
    if not SelectedPlayer then HideModal(); return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHuman = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local tChar = SelectedPlayer.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot or not myHuman or myHuman.Health <= 0 then
        Notify("606FE", "Your character is dead or not spawned!", 3)
        HideModal()
        return
    end
    if not tRoot then
        Notify("606FE", "Target character is not spawned!", 3)
        HideModal()
        return
    end
    
    pcall(function()
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
    
    myRoot.CFrame = tRoot.CFrame + Config.SafeOffset
    Notify("606FE // GOTO", "Teleported to " .. SelectedPlayer.DisplayName, 3)
    HideModal()
end)

--------------------------------------------------------------------
-- DYNAMIC PLAYER LIST RENDERING
--------------------------------------------------------------------
local PlayerCards = {}

local function CreatePlayerCard(player)
    if player == LocalPlayer then return end
    
    local Card = Instance.new("TextButton")
    Card.Name = "PlayerCard_" .. player.Name
    Card.Size = UDim2.new(1, 0, 0, 54)
    Card.BackgroundColor3 = Palette.Card
    Card.BorderSizePixel = 0
    Card.AutoButtonColor = false
    Card.Text = ""
    Card.Parent = PlayerListScroll
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Name = "Avatar"
    Avatar.Size = UDim2.new(0, 38, 0, 38)
    Avatar.Position = UDim2.new(0, 8, 0, 8)
    Avatar.BackgroundColor3 = Palette.InputBG
    Avatar.BorderSizePixel = 0
    Avatar.Image = "rbxassetid://0"
    Avatar.Parent = Card
    
    local AvCorner = Instance.new("UICorner")
    AvCorner.CornerRadius = UDim.new(0, 19)
    AvCorner.Parent = Avatar
    
    pcall(function()
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size48x48
        local contentUri = Services.Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
        Avatar.Image = contentUri
    end)
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, -150, 0, 20)
    NameLabel.Position = UDim2.new(0, 54, 0, 8)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = player.DisplayName
    NameLabel.TextColor3 = Palette.TextPrimary
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Card
    
    local UserLabel = Instance.new("TextLabel")
    UserLabel.Name = "UserLabel"
    UserLabel.Size = UDim2.new(1, -150, 0, 16)
    UserLabel.Position = UDim2.new(0, 54, 0, 28)
    UserLabel.BackgroundTransparency = 1
    UserLabel.Font = Enum.Font.GothamMedium
    UserLabel.Text = "@" .. player.Name
    UserLabel.TextColor3 = Palette.TextSecondary
    UserLabel.TextSize = 10
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserLabel.Parent = Card
    
    local DistBadge = Instance.new("Frame")
    DistBadge.Name = "DistBadge"
    DistBadge.Size = UDim2.new(0, 70, 0, 24)
    DistBadge.Position = UDim2.new(1, -78, 0, 15)
    DistBadge.BackgroundColor3 = Palette.InputBG
    DistBadge.BorderSizePixel = 0
    DistBadge.Parent = Card
    
    local DistCorner = Instance.new("UICorner")
    DistCorner.CornerRadius = UDim.new(0, 6)
    DistCorner.Parent = DistBadge
    
    local DistText = Instance.new("TextLabel")
    DistText.Name = "DistText"
    DistText.Size = UDim2.new(1, 0, 1, 0)
    DistText.BackgroundTransparency = 1
    DistText.Font = Enum.Font.GothamBold
    DistText.Text = "-- M"
    DistText.TextColor3 = Palette.AccentCyan
    DistText.TextSize = 10
    DistText.Parent = DistBadge
    
    -- Card Tap: Opens Bring or Not Modal!
    Card.MouseButton1Click:Connect(function()
        ShowModal(player)
    end)
    
    -- Hover effect
    Card.MouseEnter:Connect(function()
        Card.BackgroundColor3 = Palette.CardHover
    end)
    Card.MouseLeave:Connect(function()
        Card.BackgroundColor3 = Palette.Card
    end)
    
    PlayerCards[player] = {
        Frame = Card,
        DistLabel = DistText,
        Name = string.lower(player.Name),
        DisplayName = string.lower(player.DisplayName)
    }
end

local function RemovePlayerCard(player)
    if PlayerCards[player] then
        pcall(function() PlayerCards[player].Frame:Destroy() end)
        PlayerCards[player] = nil
    end
end

local function RefreshPlayerList()
    local search = string.lower(string.gsub(SearchBox.Text, "%s+", ""))
    local count = 0
    
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not PlayerCards[p] then
                CreatePlayerCard(p)
            end
            
            local data = PlayerCards[p]
            if data then
                local visible = true
                if search ~= "" then
                    visible = string.find(data.Name, search, 1, true) or string.find(data.DisplayName, search, 1, true)
                end
                data.Frame.Visible = visible
                if visible then count = count + 1 end
            end
        end
    end
    
    CounterLabel.Text = string.format("PLAYERS IN SERVER (%d)", count)
end

-- Hook player added / removed
Services.Players.PlayerAdded:Connect(function(p)
    CreatePlayerCard(p)
    RefreshPlayerList()
end)

Services.Players.PlayerRemoving:Connect(function(p)
    RemovePlayerCard(p)
    if SelectedPlayer == p then
        HideModal()
    end
    RefreshPlayerList()
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshPlayerList)

-- Live distance updater loop for list
Services.Run.Heartbeat:Connect(function()
    if MainFrame.Visible then
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for player, data in pairs(PlayerCards) do
                if data.Frame.Visible and player.Character then
                    local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        local dist = math.floor((tRoot.Position - myRoot.Position).Magnitude)
                        data.DistLabel.Text = string.format("%dM", dist)
                    else
                        data.DistLabel.Text = "--"
                    end
                end
            end
        end
    end
end)

-- Initial population
for _, p in ipairs(Services.Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreatePlayerCard(p)
    end
end
RefreshPlayerList()

-- Floating Mini Toggle Button (Always accessible on screen)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "606FE_Toggle_v11"
ToggleButton.Size = UDim2.new(0, 84, 0, 32)
ToggleButton.Position = UDim2.new(0, 16, 0.5, -16)
ToggleButton.BackgroundColor3 = Palette.Header
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "606FE v1.1"
ToggleButton.TextColor3 = Palette.AccentCyan
ToggleButton.TextSize = 11
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

Notify("606FE v1.1", "Loaded! Tap any player to show Bring or Not option. Menu: RightControl", 4)
