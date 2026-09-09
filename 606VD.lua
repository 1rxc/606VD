--[[
    ================================================================
    606VD // PRO REALITY SUITE 2026
    CONFIDENTIAL & PROPRIETARY // PRIVATE SOURCE BUILD
    SYSTEM: SMART SINGLE KILLER ENGINE + SMART GREAT FIX GEN + LUXURY ESP
    AESTHETIC: GTA 6 LUXURY (ZERO STROKES // STRICT ZERO EMOJIS)
    ================================================================
]]

local Services = {
    Tween = game:GetService("TweenService"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService"),
    VIM = game:GetService("VirtualInputManager"),
    Gui = game:GetService("GuiService"),
    Lighting = game:GetService("Lighting"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Services.Workspace.CurrentCamera

-- Global Master Configuration
local Config = {
    System = {
        Active = true,
        MenuKey = Enum.KeyCode.RightControl,
        AltKey = Enum.KeyCode.V
    },
    Combat = {
        AutoParry = true,
        ParryDistance = 14.0,
        ParryCooldown = 0.85,
        FaceCheck = false -- Disabled by default for 360-degree parry protection against spins and flicks
    },
    Player = {
        AutoParry = true, -- Strict Player to Killer Parry
        AntiStun = true,  -- No Stun for Player/Survivor
        FastSpeed = false, -- Player Speed Boost
        SpeedValue = 22,   -- Normal player speed is 16
        OnlyWhenPlayer = true -- Only applies when playing as player/survivor
    },
    Killer = {
        AntiStun = true,
        FastSpeed = true,
        SpeedValue = 28,
        OnlyWhenKiller = true -- Only applies when playing as killer (disable to force anywhere)
    },
    Automation = {
        AutoGreatCheck = true,
        SmartGreat = true, -- Smart Great Fix Gen (Zero adjustment needed, instant perfect Great tap)
        AutoRepair = true,
        HitAngleStart = 105, 
        HitAngleEnd = 113,
        ClickDelay = 0, -- Instant Synchronous Tap (Zero Latency)
        TouchID = 8822,
        ActionPath = "Survivor-mob.Controls.action.check"
    },
    Visuals = {
        MasterESP = true,
        KillerESP = true,
        SurvivorESP = true, -- Player ESP
        GeneratorESP = true,
        GateESP = true,     -- Exit ESP
        HatchESP = true,
        HealthBars = true,
        GenProgressBars = true,
        ShowDistance = true,
        MaxHighlights = 24
    },
    Radar = {
        Enabled = true,
        Radius = 90,
        LineOfSight = true,
        ThreatMeter = true
    },
    Environment = {
        Fullbright = true,
        RemoveFog = true,
        FieldOfView = 85
    },
    Palette = {
        RedPrimary = Color3.fromRGB(255, 38, 58),
        RedDark = Color3.fromRGB(180, 20, 38),
        RedGlow = Color3.fromRGB(255, 75, 95),
        Killer = Color3.fromRGB(255, 38, 58),
        Survivor = Color3.fromRGB(0, 240, 255),
        Injured = Color3.fromRGB(255, 180, 30),
        Downed = Color3.fromRGB(255, 90, 10),
        Hooked = Color3.fromRGB(255, 50, 70),
        Generator = Color3.fromRGB(255, 38, 58),
        Gate = Color3.fromRGB(240, 245, 255),
        Window = Color3.fromRGB(70, 200, 255),
        Hatch = Color3.fromRGB(255, 215, 0),
        VicePink = Color3.fromRGB(255, 38, 58),
        ViceCyan = Color3.fromRGB(255, 75, 95),
        VicePurple = Color3.fromRGB(180, 20, 38)
    }
}

local MaskIntel = {
    ["Richard"] = "ROOSTER [RICHARD]",
    ["Tony"] = "TIGER [TONY]",
    ["Brandon"] = "PANTHER [BRANDON]",
    ["Cobra"] = "COBRA",
    ["Richter"] = "RAT [RICHTER]",
    ["Rabbit"] = "RABBIT [GRAHAM]",
    ["Alex"] = "SWAN/CHAINSAW [ALEX]",
    ["Aubrey"] = "PIG [AUBREY]",
    ["Don Juan"] = "HORSE [DON JUAN]",
    ["Rasmus"] = "OWL [RASMUS]",
    ["Dennis"] = "WOLF [DENNIS]",
    ["Carl"] = "GRASSHOPPER [CARL]",
    ["Jake"] = "SNAKE [JAKE]",
    ["Ted"] = "DOG [TED]",
    ["Rufus"] = "ELEPHANT [RUFUS]"
}

local State = {
    Connections = {},
    Highlights = {},
    HighlightCount = 0,
    Billboards = {},
    Generators = {},
    AnchorCache = {},
    Animators = {},
    CombatBound = {},
    WorldObjects = {
        Gates = {},
        Hatches = {}
    },
    BoundAnimators = {},
    ParryConnections = {},
    KillerConnections = {},
    PlayerConnections = {},
    SkillLoop = nil,
    LastNeedleRot = nil,
    LastParryTick = 0,
    LastWorldESP = 0,
    FPS = 60,
    Ping = 0,
    FinishedGens = 0,
    ActiveKiller = nil, -- STRICTLY ONLY 1 KILLER IN GAME
    LightingDefaults = {
        Ambient = Services.Lighting.Ambient,
        OutdoorAmbient = Services.Lighting.OutdoorAmbient,
        Brightness = Services.Lighting.Brightness,
        ClockTime = Services.Lighting.ClockTime,
        FogEnd = Services.Lighting.FogEnd,
        GlobalShadows = Services.Lighting.GlobalShadows
    }
}

--------------------------------------------------------------------------------
-- UTILITIES & ATTRIBUTE PARSERS
--------------------------------------------------------------------------------

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local ok, val = pcall(function() return child.Value end)
        if ok then return val end
    end
    return nil
end

-- CRASH-PROOF ANCHOR RESOLUTION (STRICTLY RETURNS BasePart ONLY - NEVER POSE OR FOLDER)
local function ResolveAnchorPart(obj)
    if not obj then return nil end
    local cached = State.AnchorCache[obj]
    if cached and cached.Parent and cached:IsA("BasePart") then
        return cached
    end

    local anchor = nil
    if obj:IsA("BasePart") then
        anchor = obj
    elseif obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then
        anchor = obj.PrimaryPart
    end

    if not anchor then
        for _, name in ipairs({"HumanoidRootPart", "Root", "Hitbox", "Center", "defaultMaterial", "Engine", "Wood", "Plank", "Part", "MeshPart"}) do
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("BasePart") and child.Name:lower() == name:lower() then
                    anchor = child
                    break
                end
            end
            if anchor then break end
        end
    end

    if not anchor then
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") then
                local p = desc.Parent
                local pName = p and p.Name:lower() or ""
                if not pName:find("anim") and not pName:find("keyframe") and not pName:find("pose") and not pName:find("ragdoll") and not pName:find("motor") then
                    anchor = desc
                    break
                end
            end
        end
    end

    if not anchor then
        local fallback = obj:FindFirstChildWhichIsA("BasePart", true)
        if fallback and fallback:IsA("BasePart") then
            anchor = fallback
        end
    end

    if anchor then
        State.AnchorCache[obj] = anchor
    end
    return anchor
end

-- SMART SINGLE KILLER RESOLUTION (GUARANTEES EXACTLY 1 KILLER IN GAME)
-- If a player is not the 1 killer, they are strictly treated as a player/survivor!
local function ResolveSingleKiller()
    -- Check if currently cached killer is still valid and in the match
    if State.ActiveKiller and State.ActiveKiller.Parent == Services.Players then
        local cChar = State.ActiveKiller.Character
        if cChar then
            local team = State.ActiveKiller.Team and State.ActiveKiller.Team.Name:lower() or ""
            local role = tostring(GetGameValue(State.ActiveKiller, "Role") or GetGameValue(State.ActiveKiller, "SelectedKiller") or ""):lower()
            local isKAttr = GetGameValue(State.ActiveKiller, "IsKiller") or GetGameValue(cChar, "IsKiller")
            local hasMask = GetGameValue(State.ActiveKiller, "Mask") or GetGameValue(cChar, "Mask") or cChar:FindFirstChild("Mask")
            local isCarrying = cChar:FindFirstChild("Carrying") or GetGameValue(cChar, "IsCarrying")

            if team:find("survivor") or team:find("victim") then
                State.ActiveKiller = nil
            elseif team:find("killer") or team:find("slasher") or role:find("killer") or isKAttr == true or hasMask or isCarrying then
                return State.ActiveKiller
            else
                local hasWeapon = false
                for _, item in ipairs(cChar:GetChildren()) do
                    if item:IsA("Tool") or item:IsA("Model") or item:IsA("MeshPart") then
                        local n = item.Name:lower()
                        if n:find("knife") or n:find("machete") or n:find("chainsaw") or n:find("cleaver") or n:find("axe") or n:find("hammer") or n:find("bat") or n:find("weapon") or n:find("slasher") then
                            hasWeapon = true; break
                        end
                    end
                end
                if hasWeapon then return State.ActiveKiller end
            end
        end
    end

    -- Priority 1: Definitive Killer/Slasher team
    for _, p in ipairs(Services.Players:GetPlayers()) do
        local team = p.Team and p.Team.Name:lower() or ""
        if (team:find("killer") or team:find("slasher") or team:find("hunter") or team:find("murderer") or team:find("beast")) and not team:find("survivor") then
            State.ActiveKiller = p
            return p
        end
    end

    -- Priority 2: Definitive Killer role and character attributes
    for _, p in ipairs(Services.Players:GetPlayers()) do
        local role = tostring(GetGameValue(p, "Role") or GetGameValue(p, "SelectedKiller") or ""):lower()
        local isKAttr = GetGameValue(p, "IsKiller")
        local maskAttr = GetGameValue(p, "Mask")
        if role:find("killer") or role:find("slasher") or isKAttr == true or maskAttr ~= nil then
            State.ActiveKiller = p
            return p
        end

        local char = p.Character
        if char then
            local charRole = tostring(GetGameValue(char, "Role") or GetGameValue(char, "SelectedKiller") or ""):lower()
            local charIsK = GetGameValue(char, "IsKiller")
            local charMask = GetGameValue(char, "Mask") or char:FindFirstChild("Mask")
            local isCarrying = char:FindFirstChild("Carrying") or GetGameValue(char, "IsCarrying")
            if charRole:find("killer") or charRole:find("slasher") or charIsK == true or charMask ~= nil or isCarrying then
                State.ActiveKiller = p
                return p
            end
        end
    end

    -- Priority 3: Character & Backpack Weapon Arsenal Inspection
    for _, p in ipairs(Services.Players:GetPlayers()) do
        local char = p.Character
        local bp = p:FindFirstChildOfClass("Backpack")
        local containers = {char, bp}
        for _, cont in ipairs(containers) do
            if cont then
                for _, item in ipairs(cont:GetChildren()) do
                    if item:IsA("Tool") or item:IsA("Model") or item:IsA("MeshPart") then
                        local tName = item.Name:lower()
                        if tName:find("knife") or tName:find("machete") or tName:find("chainsaw") or tName:find("cleaver") 
                            or tName:find("slasher") or tName:find("murderer") or tName:find("axe") or tName:find("hammer")
                            or tName:find("bat") or tName:find("killerweapon") or tName:find("scythe") or tName:find("claws") then
                            State.ActiveKiller = p
                            return p
                        end
                    end
                end
            end
        end
    end

    return State.ActiveKiller
end

-- Strictly determines player role: killer is the ONLY 1 in game; everyone else is Survivor
local function GetPlayerRole(player)
    if State.ActiveKiller and player == State.ActiveKiller then
        return "Killer"
    end
    return "Survivor"
end

local function HasLineOfSight(originPart, targetPart)
    if not originPart or not targetPart then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    params.IgnoreWater = true
    local dir = (targetPart.Position - originPart.Position)
    local res = Services.Workspace:Raycast(originPart.Position, dir, params)
    return res == nil
end

local function IsGeneratorModel(obj)
    if not obj or not obj:IsA("Model") then return false end
    if obj:FindFirstAncestorOfClass("Humanoid") then return false end
    if obj:FindFirstAncestor("RagdollConstraints") or obj.Name:find("Ragdoll") then return false end

    local name = obj.Name:lower()
    if name == "generator" or name:match("^generator%d*") or name:match("^gen_%d+") or name:match("^gen%d+") then
        return true
    end
    if obj:GetAttribute("RepairProgress") ~= nil or obj:GetAttribute("Progress") ~= nil then
        return true
    end
    if obj:FindFirstChild("RepairProgress") or obj:FindFirstChild("Progress") then
        return true
    end
    return false
end

local function GetGeneratorProgress(gen)
    if not gen then return 0 end
    for _, attr in ipairs({"RepairProgress", "Progress", "Percent", "Repaired", "Amount"}) do
        local v = gen:GetAttribute(attr)
        if type(v) == "number" then return v end
    end
    for _, name in ipairs({"RepairProgress", "Progress", "Percent", "Repaired", "Value"}) do
        local valObj = gen:FindFirstChild(name, true)
        if valObj and (valObj:IsA("NumberValue") or valObj:IsA("IntValue")) then
            return valObj.Value
        end
    end
    local cfg = gen:FindFirstChildWhichIsA("Configuration", true)
    if cfg then
        for _, vObj in ipairs(cfg:GetChildren()) do
            if vObj:IsA("NumberValue") or vObj:IsA("IntValue") then
                return vObj.Value
            end
        end
    end
    return 0
end

local function IsGeneratorCompleted(gen, progress)
    if progress >= 100 then return true end
    if gen:GetAttribute("Completed") == true or gen:GetAttribute("Finished") == true or gen:GetAttribute("Powered") == true then
        return true
    end
    for _, name in ipairs({"Completed", "Finished", "Powered", "Done"}) do
        local b = gen:FindFirstChild(name, true)
        if b and b:IsA("BoolValue") and b.Value == true then
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- HIGHLIGHT ENGINE (CRASH-PROOF & INSTANCE CAPPED)
--------------------------------------------------------------------------------

local function SafeHighlight(object, color, priority)
    if not Config.Visuals.MasterESP or not object then return end

    local hl = State.Highlights[object]
    if hl and hl.Parent then
        hl.FillColor = color
        hl.OutlineColor = color
        return hl
    end

    hl = object:FindFirstChild("VD_Highlight")
    if hl then
        hl.FillColor = color
        hl.OutlineColor = color
        State.Highlights[object] = hl
        return hl
    end

    if State.HighlightCount >= Config.Visuals.MaxHighlights and not priority then
        return nil
    end

    local ok, newHl = pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "VD_Highlight"
        h.FillTransparency = 0.65
        h.OutlineTransparency = 0.1
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = object
        h.FillColor = color
        h.OutlineColor = color
        h.Parent = object
        return h
    end)

    if ok and newHl then
        State.Highlights[object] = newHl
        State.HighlightCount = State.HighlightCount + 1
        return newHl
    end
    return nil
end

local function RemoveHighlight(object)
    if not object then return end
    local hl = State.Highlights[object] or object:FindFirstChild("VD_Highlight")
    if hl then
        pcall(function() hl:Destroy() end)
        State.Highlights[object] = nil
        State.HighlightCount = math.max(0, State.HighlightCount - 1)
    end
end

--------------------------------------------------------------------------------
-- 3D BILLBOARDS (WITHOUT STROKES)
--------------------------------------------------------------------------------

local function BuildTag(text, color, hasBar)
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Tag"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 150, 0, hasBar and 38 or 24)
    bb.MaxDistance = math.huge
    bb.LightInfluence = 0
    bb.ResetOnSpawn = false

    local lbl = Instance.new("TextLabel", bb)
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.RichText = true

    if hasBar then
        local barBg = Instance.new("Frame", bb)
        barBg.Name = "BarBG"
        barBg.Size = UDim2.new(0.85, 0, 0, 4)
        barBg.Position = UDim2.new(0.075, 0, 0, 22)
        barBg.BackgroundColor3 = Color3.fromRGB(28, 20, 38)
        barBg.BorderSizePixel = 0
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", barBg)
        fill.Name = "Fill"
        fill.Size = UDim2.new(1, 0, 1, 0)
        fill.BackgroundColor3 = color
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    end

    return bb
end

--------------------------------------------------------------------------------
-- WORLD MAP INDEXER (FILTERING ANIMATIONS, POSES, & CONSTRAINTS)
--------------------------------------------------------------------------------

local function IndexWorldObjects()
    local gens, gates, hatches = {}, {}, {}
    local checked = {}

    -- Targeted Map Search (Never scans entire 50k+ Workspace unless map folder missing)
    local mapFolder = Services.Workspace:FindFirstChild("Map") 
        or Services.Workspace:FindFirstChild("Interactables") 
        or Services.Workspace:FindFirstChild("Objects") 
        or Services.Workspace:FindFirstChild("Game")

    local searchRoots = {}
    if mapFolder then
        table.insert(searchRoots, mapFolder)
    else
        table.insert(searchRoots, Services.Workspace)
    end

    for _, root in ipairs(searchRoots) do
        if root then
            for _, obj in ipairs(root:GetDescendants()) do
                if not checked[obj] then
                    -- Filter out animation data, poses, keyframes, and constraint objects
                    if obj:IsA("Keyframe") or obj:IsA("Pose") or obj:IsA("KeyframeSequence") or obj:IsA("Animation") then
                        checked[obj] = true
                    elseif obj:FindFirstAncestorOfClass("KeyframeSequence") or obj:FindFirstAncestor("AnimSaves") or obj:FindFirstAncestor("RagdollConstraints") then
                        checked[obj] = true
                    elseif not (obj:IsA("Model") or obj:IsA("BasePart")) then
                        checked[obj] = true
                    else
                        local name = obj.Name:lower()
                        if IsGeneratorModel(obj) then
                            checked[obj] = true; table.insert(gens, obj)
                        elseif (name == "gate" or name:find("exitgate") or name:find("door")) and obj:IsA("Model") then
                            checked[obj] = true; table.insert(gates, obj)
                        elseif name == "hatch" or name == "trapdoor" or name:find("hatch") then
                            checked[obj] = true; table.insert(hatches, obj)
                        end
                    end
                end
            end
        end
    end

    State.Generators = gens
    State.WorldObjects.Gates = gates
    State.WorldObjects.Hatches = hatches

    -- Periodic Dead Highlight Pruning
    local actualCount = 0
    for obj, hl in pairs(State.Highlights) do
        if not obj or not obj.Parent or not hl or not hl.Parent then
            if hl then pcall(function() hl:Destroy() end) end
            State.Highlights[obj] = nil
        else
            actualCount = actualCount + 1
        end
    end
    State.HighlightCount = actualCount
end

--------------------------------------------------------------------------------
-- WORLD ESP PROCESSOR (CRASH-PROOFED)
--------------------------------------------------------------------------------

local function ProcessWorldESP()
    if not Config.Visuals.MasterESP then
        for _, list in pairs(State.WorldObjects) do
            for _, obj in ipairs(list) do
                local tag = obj:FindFirstChild("ESP_Tag", true)
                if tag then tag:Destroy() end
                RemoveHighlight(obj)
                local a = State.AnchorCache[obj]
                if a then RemoveHighlight(a) end
            end
        end
        for _, gen in ipairs(State.Generators) do
            local tag = gen:FindFirstChild("ESP_Tag", true)
            if tag then tag:Destroy() end
            RemoveHighlight(gen)
        end
        return
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position

    -- 1. Generators (Progress & Highlight)
    local finished = 0
    for i = #State.Generators, 1, -1 do
        local gen = State.Generators[i]
        if gen and gen.Parent then
            local prog = GetGeneratorProgress(gen)
            local isDone = IsGeneratorCompleted(gen, prog)
            local anchor = ResolveAnchorPart(gen)

            if isDone then
                finished = finished + 1
                local oldTag = gen:FindFirstChild("ESP_Tag", true)
                if oldTag then oldTag:Destroy() end
                RemoveHighlight(gen)
            elseif anchor and anchor:IsA("BasePart") and Config.Visuals.GeneratorESP then
                local cp = math.clamp(prog, 0, 100)
                local col = Config.Palette.RedDark:Lerp(Config.Palette.RedPrimary, cp / 100)
                local dist = myPos and math.floor((anchor.Position - myPos).Magnitude) or 0
                local text = string.format("GEN [%.1f%%]", prog)
                if Config.Visuals.ShowDistance then
                    text = string.format("GEN [%.1f%%]\n<font size=\"8\">[%dM]</font>", prog, dist)
                end

                local tag = anchor:FindFirstChild("ESP_Tag") or gen:FindFirstChild("ESP_Tag")
                if not tag then
                    tag = BuildTag(text, col, Config.Visuals.GenProgressBars)
                    tag.StudsOffset = Vector3.new(0, 3.2, 0)
                    tag.Adornee = anchor
                    tag.Parent = anchor
                    table.insert(State.Billboards, tag)
                else
                    local lbl = tag:FindFirstChild("Label")
                    if lbl and lbl.Text ~= text then
                        lbl.Text = text
                        lbl.TextColor3 = col
                    end
                    local fill = tag:FindFirstChild("BarBG") and tag.BarBG:FindFirstChild("Fill")
                    if fill then
                        fill.Size = UDim2.new(cp / 100, 0, 1, 0)
                        fill.BackgroundColor3 = col
                    end
                end

                SafeHighlight(gen, col, true)
            else
                local oldTag = gen:FindFirstChild("ESP_Tag", true)
                if oldTag then oldTag:Destroy() end
                RemoveHighlight(gen)
            end
        else
            table.remove(State.Generators, i)
        end
    end
    State.FinishedGens = finished

    -- 2. Enhanced Object ESP Processor (3D PHYSICAL OBJECT HIGHLIGHT WITH OPTIONAL NAME)
    local function ProcessObjectESPList(list, isEnabled, labelName, color, highlightRadius, showBillboard)
        highlightRadius = highlightRadius or 120
        for _, obj in ipairs(list) do
            if obj and obj.Parent then
                local anchor = ResolveAnchorPart(obj)
                if anchor and anchor:IsA("BasePart") and isEnabled then
                    local aPos = anchor.Position
                    local dist = myPos and (aPos - myPos).Magnitude or 0

                    -- 1. Billboard Name Tag (ONLY created/shown if showBillboard is true)
                    if showBillboard then
                        local distM = math.floor(dist)
                        local text = labelName
                        if Config.Visuals.ShowDistance then
                            text = string.format("%s\n<font size=\"8\">[%dM]</font>", labelName, distM)
                        end

                        local tag = anchor:FindFirstChild("ESP_Tag") or obj:FindFirstChild("ESP_Tag")
                        if not tag then
                            tag = BuildTag(text, color, false)
                            tag.StudsOffset = Vector3.new(0, 2.5, 0)
                            tag.Adornee = anchor
                            tag.Parent = anchor
                            table.insert(State.Billboards, tag)
                        else
                            local lbl = tag:FindFirstChild("Label")
                            if lbl and lbl.Text ~= text then
                                lbl.Text = text
                                lbl.TextColor3 = color
                            end
                        end
                    else
                        -- Destroy any name tag so only the 3D physical object is visible
                        local oldTag = obj:FindFirstChild("ESP_Tag", true) or (anchor and anchor:FindFirstChild("ESP_Tag"))
                        if oldTag then oldTag:Destroy() end
                    end

                    -- 2. 3D Physical Object ESP (Highlights the actual 3D model/parts through walls!)
                    local target = (obj:IsA("Model") and #obj:GetChildren() > 0) and obj or anchor
                    if dist <= highlightRadius then
                        SafeHighlight(target, color, false)
                    else
                        RemoveHighlight(target)
                    end
                else
                    local oldTag = obj:FindFirstChild("ESP_Tag", true) or (anchor and anchor:FindFirstChild("ESP_Tag"))
                    if oldTag then oldTag:Destroy() end
                    RemoveHighlight(obj)
                    if anchor then RemoveHighlight(anchor) end
                end
            end
        end
    end

    -- Exit Gates & Escape Hatches (Physical 3D highlight on exit gate model, NO name tag)
    ProcessObjectESPList(State.WorldObjects.Gates, Config.Visuals.GateESP, "EXIT GATE", Config.Palette.Gate, 9999, false)
    ProcessObjectESPList(State.WorldObjects.Hatches, Config.Visuals.HatchESP, "HATCH", Config.Palette.Hatch, 9999, false)
end

--------------------------------------------------------------------------------
-- COMBAT & AUTO PARRY ENGINE (MULTI-LAYER ATTACK DETECTION & ACTUATION)
--------------------------------------------------------------------------------

local AttackKeywords = {
    "swing", "slash", "attack", "hit", "strike", "knife", "machete", "heavy",
    "light", "cleave", "stab", "lunge", "kill", "punch", "smash", "weapon",
    "hammer", "axe", "down", "combat", "slasher", "murder", "cut", "chop"
}

local IgnoreKeywords = {
    "walk", "run", "idle", "sprint", "fall", "jump", "land", "crouch",
    "vault", "climb", "emote", "dance", "sit", "breathe", "turn", "inspect"
}

local function GetCharacterAnimator(char)
    if not char then return nil end
    local cached = State.Animators[char]
    if cached and cached.Parent then return cached end

    local human = char:FindFirstChildOfClass("Humanoid")
    local a = human and human:FindFirstChildOfClass("Animator")
    if not a then
        local animCtrl = char:FindFirstChildOfClass("AnimationController")
        a = animCtrl and animCtrl:FindFirstChildOfClass("Animator")
    end
    if not a then
        a = char:FindFirstChildWhichIsA("Animator", true)
    end
    if a then
        State.Animators[char] = a
    end
    return a
end

local function IsAttackAnimation(track)
    if not track then return false end
    local tName = (track.Name or ""):lower()
    local animId = ""
    if track.Animation then
        animId = tostring(track.Animation.AnimationId or ""):lower()
        local aName = (track.Animation.Name or ""):lower()
        tName = tName .. " " .. aName
    end

    for _, ign in ipairs(IgnoreKeywords) do
        if tName:find(ign) then
            return false
        end
    end

    for _, kw in ipairs(AttackKeywords) do
        if tName:find(kw) or animId:find(kw) then
            return true
        end
    end

    local prio = track.Priority
    if prio == Enum.AnimationPriority.Action 
        or prio == Enum.AnimationPriority.Action2 
        or prio == Enum.AnimationPriority.Action3 
        or prio == Enum.AnimationPriority.Action4 
        or tostring(prio):find("Action") then
        return true
    end

    return false
end

local function ExecuteAutoParry(source)
    -- STRICT SAFETY: Killer can never auto-parry themselves! Only survivors parry killers!
    if IsLocalPlayerKiller() then return false end

    local now = tick()
    if now - State.LastParryTick < Config.Combat.ParryCooldown then return false end
    State.LastParryTick = now

    task.spawn(function()
        local mPos = Services.Input:GetMouseLocation()

        -- 1. VirtualInputManager MouseButton2 (Right Click)
        pcall(function()
            Services.VIM:SendMouseButtonEvent(mPos.X, mPos.Y, 1, true, game, 1)
        end)

        -- 2. Native Executor mouse2 press / click
        if mouse2press then
            pcall(mouse2press)
        elseif mouse2click then
            pcall(mouse2click)
        end

        -- 3. VirtualUser Right Click (Button2Down)
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(mPos.X, mPos.Y))
        end)

        -- 4. Mobile Screen GUI Button (Parry / Block / Guard)
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _, desc in ipairs(pg:GetDescendants()) do
                    if (desc:IsA("ImageButton") or desc:IsA("TextButton")) and desc.Visible then
                        local dName = desc.Name:lower()
                        if dName:find("parry") or dName:find("block") or dName:find("guard") or dName:find("defend") then
                            if firesignal then
                                firesignal(desc.Activated)
                                firesignal(desc.MouseButton1Click)
                            elseif desc.Activated then
                                desc.Activated:Fire()
                            end
                        end
                    end
                end
            end
        end)

        -- 5. Fallback Keypress (F key)
        pcall(function()
            Services.VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        end)

        -- Hold right click for parry active window (160ms) to ensure engine registration
        task.wait(0.16)

        -- Clean input release
        pcall(function()
            Services.VIM:SendMouseButtonEvent(mPos.X, mPos.Y, 1, false, game, 1)
        end)
        if mouse2release then
            pcall(mouse2release)
        end
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Up(Vector2.new(mPos.X, mPos.Y))
        end)
        pcall(function()
            Services.VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end)
    end)
    return true
end

local function CheckAndTriggerParry(char, player, track)
    if not Config.Combat.AutoParry or not char then return end

    -- STRICT SINGLE KILLER VERIFICATION: Auto Parry ONLY triggers player to killer!
    local killer = State.ActiveKiller or ResolveSingleKiller()
    if not killer or player ~= killer then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local tRoot = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or ResolveAnchorPart(char)
    if not tRoot or not tRoot:IsA("BasePart") then return end

    local dist = (tRoot.Position - myRoot.Position).Magnitude
    if dist > Config.Combat.ParryDistance then return end

    if Config.Combat.FaceCheck then
        local toMe = (myRoot.Position - tRoot.Position).Unit
        if tRoot.CFrame.LookVector:Dot(toMe) < -0.2 then return end
    end

    local isAttack = false
    if track then
        isAttack = IsAttackAnimation(track)
    else
        isAttack = true
    end

    -- Trigger Auto Parry ONLY on genuine attacks from the true killer
    if isAttack then
        ExecuteAutoParry("KILLER_ATTACK_DETECTED")
    end
end

local function BindCombatListeners(player, char)
    if player == LocalPlayer or not char then return end

    -- Strictly only bind to the Killer (never bind to survivors/players)
    local killer = State.ActiveKiller or ResolveSingleKiller()
    if not killer or player ~= killer then return end

    if State.CombatBound[char] then return end
    State.CombatBound[char] = true

    local animator = GetCharacterAnimator(char)
    if animator and not State.BoundAnimators[animator] then
        State.BoundAnimators[animator] = true
        local conn = animator.AnimationPlayed:Connect(function(track)
            CheckAndTriggerParry(char, player, track)
        end)
        table.insert(State.ParryConnections, conn)
    end

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and not item:GetAttribute("ParryBound") then
            item:SetAttribute("ParryBound", true)
            local tConn = item.Activated:Connect(function()
                CheckAndTriggerParry(char, player, nil)
            end)
            table.insert(State.ParryConnections, tConn)
        end
    end

    -- Listen for newly equipped weapons dynamically without looping
    local cConn = char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and not child:GetAttribute("ParryBound") then
            child:SetAttribute("ParryBound", true)
            local tConn = child.Activated:Connect(function()
                CheckAndTriggerParry(char, player, nil)
            end)
            table.insert(State.ParryConnections, tConn)
        end
    end)
    table.insert(State.ParryConnections, cConn)
end

--------------------------------------------------------------------------------
-- REALITY KILLER INTELLIGENCE & PLAYER PROCESSING
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- KILLER PROTOCOLS ENGINE (ANTI STUN & FAST SPEED BOOST)
--------------------------------------------------------------------------------

local StunKeywords = {
    "stun", "blind", "flashed", "flashlight", "daze", "dazed", "headache",
    "stumble", "pallet"
}

local StunAttrNames = {
    "stunned", "isstunned", "stun", "blind", "blinded", "flashed",
    "ragdoll", "ragdolled", "headache", "palletstun"
}

local function IsLocalPlayerKiller()
    if State.ActiveKiller == LocalPlayer then return true end
    local killer = ResolveSingleKiller()
    if killer == LocalPlayer then return true end

    local team = LocalPlayer.Team and LocalPlayer.Team.Name:lower() or ""
    if (team:find("killer") or team:find("slasher") or team:find("hunter") or team:find("murderer") or team:find("beast")) and not team:find("survivor") then
        return true
    end

    local role = tostring(GetGameValue(LocalPlayer, "Role") or GetGameValue(LocalPlayer, "SelectedKiller") or ""):lower()
    if role:find("killer") or role:find("slasher") then return true end
    if GetGameValue(LocalPlayer, "IsKiller") == true then return true end

    local char = LocalPlayer.Character
    if char then
        if GetGameValue(char, "IsKiller") == true or GetGameValue(char, "Mask") ~= nil or char:FindFirstChild("Carrying") then
            return true
        end
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("knife") or n:find("machete") or n:find("chainsaw") or n:find("cleaver") or n:find("axe") or n:find("hammer") or n:find("slasher") then
                    return true
                end
            end
        end
    end

    return false
end

local function ShouldApplyKillerMods()
    if not Config.Killer.OnlyWhenKiller then
        return true
    end
    return IsLocalPlayerKiller()
end

local function CheckAndCancelStunAnim(track)
    if not Config.Killer.AntiStun or not ShouldApplyKillerMods() then return false end
    if not track then return false end
    local tName = (track.Name or ""):lower()
    local animId = ""
    if track.Animation then
        animId = tostring(track.Animation.AnimationId or ""):lower()
        local aName = (track.Animation.Name or ""):lower()
        tName = tName .. " " .. aName
    end
    -- Protect ALL combat, weapon, hit, wipe, lunge, and recovery animations from ever being cancelled!
    if tName:find("attack") or tName:find("swing") or tName:find("slash") 
        or tName:find("hit") or tName:find("wipe") or tName:find("cooldown") 
        or tName:find("lunge") or tName:find("weapon") or tName:find("m1")
        or tName:find("knife") or tName:find("machete") or tName:find("axe") 
        or tName:find("cleaver") or tName:find("hammer") or tName:find("bat")
        or tName:find("walk") or tName:find("run") or tName:find("idle") then
        return false
    end
    for _, kw in ipairs(StunKeywords) do
        if tName:find(kw) or animId:find(kw) then
            pcall(function() track:Stop(0) end)
            return true
        end
    end
    return false
end

local function CleanStunEffects(char)
    if not char then return end

    -- 1. Reset Humanoid State and PlatformStand
    local human = char:FindFirstChildOfClass("Humanoid")
    if human and human.Health > 0 then
        if human.PlatformStand then
            human.PlatformStand = false
            human:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        local state = human:GetState()
        if state == Enum.HumanoidStateType.Ragdoll 
            or state == Enum.HumanoidStateType.Physics 
            or state == Enum.HumanoidStateType.FallingDown 
            or state == Enum.HumanoidStateType.PlatformStanding then
            human:ChangeState(Enum.HumanoidStateType.GettingUp)
            human:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    -- 2. Clean Stun Attributes
    for _, attr in ipairs(StunAttrNames) do
        if char:GetAttribute(attr) == true then
            pcall(function() char:SetAttribute(attr, false) end)
        end
    end

    -- 3. Clean Stun/Ragdoll Value Objects and Constraints
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("ValueBase") then
            local cName = child.Name:lower()
            for _, kw in ipairs(StunAttrNames) do
                if cName:find(kw) then
                    if child:IsA("BoolValue") and child.Value == true then
                        pcall(function() child.Value = false end)
                    elseif child:IsA("NumberValue") and child.Value > 0 then
                        pcall(function() child.Value = 0 end)
                    end
                end
            end
        elseif child.Name == "RagdollConstraints" or child.Name:find("Stun") then
            pcall(function() child:Destroy() end)
        end
    end

    -- 4. Screen Blind / Flashlight GUI cleanup
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local gName = gui.Name:lower()
                if gName:find("blind") or gName:find("flashlight") or gName:find("stun") then
                    gui.Enabled = false
                end
            end
        end
    end

    -- 5. Stop playing stun animation tracks
    local anim = GetCharacterAnimator(char)
    if anim then
        local ok, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
        if ok and tracks then
            for _, t in ipairs(tracks) do
                CheckAndCancelStunAnim(t)
            end
        end
    end
end

local function ProcessKillerProtocols()
    if not ShouldApplyKillerMods() then return end

    local char = LocalPlayer.Character
    if not char then return end
    local human = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not human or human.Health <= 0 or not root then return end

    -- 1. Anti Stun Protocol (Only trigger on genuine ragdoll/stun states, never on attack recovery)
    if Config.Killer.AntiStun then
        if human.PlatformStand 
            or human:GetState() == Enum.HumanoidStateType.Ragdoll 
            or human:GetState() == Enum.HumanoidStateType.Physics 
            or human:GetState() == Enum.HumanoidStateType.PlatformStanding
            or char:GetAttribute("Stunned") == true
            or char:GetAttribute("IsStunned") == true then
            CleanStunEffects(char)
        end
    end

    -- 1B. Killer Weapon Left-Click Safeguard: Keep weapon tool ready and enabled
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            if not item.Enabled then
                item.Enabled = true
            end
        end
    end

    -- 2. Fast Speed Protocol
    if Config.Killer.FastSpeed then
        if human.WalkSpeed ~= Config.Killer.SpeedValue then
            human.WalkSpeed = Config.Killer.SpeedValue
        end
        if human.MoveDirection.Magnitude > 0 then
            local targetVel = human.MoveDirection * Config.Killer.SpeedValue
            root.AssemblyLinearVelocity = Vector3.new(targetVel.X, root.AssemblyLinearVelocity.Y, targetVel.Z)
        end
    end
end

local function BindLocalCharacterKillerMods(char)
    if not char then return end
    for _, c in pairs(State.KillerConnections) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    table.clear(State.KillerConnections)

    for _, c in pairs(State.PlayerConnections) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    table.clear(State.PlayerConnections)

    local human = char:WaitForChild("Humanoid", 3)
    if human then
        local stConn = human.StateChanged:Connect(function(_, newState)
            if Config.Killer.AntiStun and ShouldApplyKillerMods() then
                if newState == Enum.HumanoidStateType.Ragdoll 
                    or newState == Enum.HumanoidStateType.Physics 
                    or newState == Enum.HumanoidStateType.FallingDown 
                    or newState == Enum.HumanoidStateType.PlatformStanding then
                    human:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end)
        table.insert(State.KillerConnections, stConn)

        local wsConn = human:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Config.Killer.FastSpeed and ShouldApplyKillerMods() then
                if human.WalkSpeed ~= Config.Killer.SpeedValue then
                    human.WalkSpeed = Config.Killer.SpeedValue
                end
            end
        end)
        table.insert(State.KillerConnections, wsConn)
    end

    local anim = GetCharacterAnimator(char)
    if anim then
        local animConn = anim.AnimationPlayed:Connect(function(track)
            CheckAndCancelStunAnim(track)
        end)
        table.insert(State.KillerConnections, animConn)
    end
end


--------------------------------------------------------------------------------
-- PLAYER / SURVIVOR PROTOCOLS ENGINE (AUTO PARRY, SPEED & NO STUN)
--------------------------------------------------------------------------------

local function ShouldApplyPlayerMods()
    if not Config.Player.OnlyWhenPlayer then
        return true
    end
    return not IsLocalPlayerKiller()
end

local function CleanPlayerStunEffects(char)
    if not char then return end

    -- 1. Reset Humanoid State and PlatformStand
    local human = char:FindFirstChildOfClass("Humanoid")
    if human and human.Health > 0 then
        if human.PlatformStand then
            human.PlatformStand = false
            human:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        local state = human:GetState()
        if state == Enum.HumanoidStateType.Ragdoll 
            or state == Enum.HumanoidStateType.Physics 
            or state == Enum.HumanoidStateType.FallingDown 
            or state == Enum.HumanoidStateType.PlatformStanding then
            human:ChangeState(Enum.HumanoidStateType.GettingUp)
            human:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    -- 2. Clean Stun Attributes
    for _, attr in ipairs(StunAttrNames) do
        if char:GetAttribute(attr) == true then
            pcall(function() char:SetAttribute(attr, false) end)
        end
    end

    -- 3. Clean Stun/Ragdoll Value Objects and Constraints
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("ValueBase") then
            local cName = child.Name:lower()
            for _, kw in ipairs(StunAttrNames) do
                if cName:find(kw) then
                    if child:IsA("BoolValue") and child.Value == true then
                        pcall(function() child.Value = false end)
                    elseif child:IsA("NumberValue") and child.Value > 0 then
                        pcall(function() child.Value = 0 end)
                    end
                end
            end
        elseif child.Name == "RagdollConstraints" or child.Name:find("Stun") then
            pcall(function() child:Destroy() end)
        end
    end

    -- 4. Screen Blind / Flashlight GUI cleanup
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local gName = gui.Name:lower()
                if gName:find("blind") or gName:find("flashlight") or gName:find("stun") then
                    gui.Enabled = false
                end
            end
        end
    end

    -- 5. Stop playing stun animations on Player
    local anim = GetCharacterAnimator(char)
    if anim then
        local ok, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
        if ok and tracks then
            for _, t in ipairs(tracks) do
                local tName = (t.Name or ""):lower()
                local animId = ""
                if t.Animation then
                    animId = tostring(t.Animation.AnimationId or ""):lower()
                    tName = tName .. " " .. (t.Animation.Name or ""):lower()
                end
                if not (tName:find("walk") or tName:find("run") or tName:find("idle") or tName:find("jump") or tName:find("fall")) then
                    for _, kw in ipairs(StunKeywords) do
                        if tName:find(kw) or animId:find(kw) then
                            pcall(function() t:Stop(0) end)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function ProcessPlayerProtocols()
    if not ShouldApplyPlayerMods() then return end

    local char = LocalPlayer.Character
    if not char then return end
    local human = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not human or human.Health <= 0 or not root then return end

    -- 1. Player No Stun / Anti Stun Protocol
    if Config.Player.AntiStun then
        if human.PlatformStand 
            or human:GetState() == Enum.HumanoidStateType.Ragdoll 
            or human:GetState() == Enum.HumanoidStateType.Physics 
            or human:GetState() == Enum.HumanoidStateType.PlatformStanding
            or char:GetAttribute("Stunned") == true
            or char:GetAttribute("IsStunned") == true then
            CleanPlayerStunEffects(char)
        end
    end

    -- 2. Player Fast Speed Protocol
    if Config.Player.FastSpeed then
        if human.WalkSpeed ~= Config.Player.SpeedValue then
            human.WalkSpeed = Config.Player.SpeedValue
        end
        if human.MoveDirection.Magnitude > 0 then
            local targetVel = human.MoveDirection * Config.Player.SpeedValue
            root.AssemblyLinearVelocity = Vector3.new(targetVel.X, root.AssemblyLinearVelocity.Y, targetVel.Z)
        end
    end
end

local function BindLocalCharacterPlayerMods(char)
    if not char then return end
    for _, c in pairs(State.PlayerConnections) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    table.clear(State.PlayerConnections)

    local human = char:WaitForChild("Humanoid", 3)
    if human then
        local stConn = human.StateChanged:Connect(function(_, newState)
            if Config.Player.AntiStun and ShouldApplyPlayerMods() then
                if newState == Enum.HumanoidStateType.Ragdoll 
                    or newState == Enum.HumanoidStateType.Physics 
                    or newState == Enum.HumanoidStateType.FallingDown 
                    or newState == Enum.HumanoidStateType.PlatformStanding then
                    human:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end)
        table.insert(State.PlayerConnections, stConn)

        local wsConn = human:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Config.Player.FastSpeed and ShouldApplyPlayerMods() then
                if human.WalkSpeed ~= Config.Player.SpeedValue then
                    human.WalkSpeed = Config.Player.SpeedValue
                end
            end
        end)
        table.insert(State.PlayerConnections, wsConn)
    end
end

local CardRealKiller, CardKillerStatus, CardMask, CardGensLeft, CardKillerRole, CardPlayerRole
local ThreatRadarHUD, ThreatTitle, ThreatBarFill, ThreatDistBadge, ThreatTopAccent

local function ProcessEntities()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    -- Identify the exact single active match killer
    local killer = ResolveSingleKiller()
    local killerChar = killer and killer.Character
    local killerRoot = killerChar and ResolveAnchorPart(killerChar)
    local killerLOS = false
    local killerDist = 9999

    -- Update Intel Cards with Reality Data
    if killer then
        local kDisplayName = killer.DisplayName
        local kUser = killer.Name
        local kClass = tostring(GetGameValue(killer, "SelectedKiller") or GetGameValue(killerChar, "SelectedKiller") or "KILLER")
        
        if CardRealKiller then
            CardRealKiller(string.format("<font color=\"rgb(255,42,133)\">%s</font> (@%s)", kDisplayName:upper(), kUser))
        end

        local rawMask = GetGameValue(killer, "Mask") or GetGameValue(killerChar, "Mask")
        if CardMask then
            if rawMask then
                local mStr = tostring(rawMask)
                CardMask(MaskIntel[mStr] or mStr:upper())
            else
                CardMask(kClass:upper())
            end
        end

        if killerRoot and killerRoot:IsA("BasePart") and myRoot then
            local ok, kPos = pcall(function() return killerRoot.Position end)
            if ok and kPos then
                killerDist = (kPos - myRoot.Position).Magnitude
                local isChased = GetGameValue(LocalPlayer.Character, "IsChased") or (killerDist <= 35)
                local isCarrying = killerChar:FindFirstChild("Carrying") or GetGameValue(killerChar, "IsCarrying")

                if CardKillerStatus then
                    if isCarrying then
                        CardKillerStatus("<font color=\"rgb(255,140,0)\">CARRYING SURVIVOR</font>")
                    elseif isChased then
                        CardKillerStatus("<font color=\"rgb(255,45,65)\">IN CHASE</font>")
                    else
                        CardKillerStatus(string.format("PATROLLING [%dM AWAY]", math.floor(killerDist)))
                    end
                end

                if Config.Radar.LineOfSight then
                    local head = killerChar:FindFirstChild("Head") or killerRoot
                    if head and head:IsA("BasePart") and HasLineOfSight(head, myRoot) then
                        killerLOS = true
                    end
                end
            end
        end
    else
        if CardRealKiller then CardRealKiller("SEARCHING...") end
        if CardKillerStatus then CardKillerStatus("LOBBY / NO ACTIVE KILLER") end
        if CardMask then CardMask("NONE") end
    end

    if CardKillerRole then
        if IsLocalPlayerKiller() then
            CardKillerRole("<font color=\"rgb(255,42,133)\">CONFIRMED KILLER (ACTIVE)</font>")
        else
            CardKillerRole("<font color=\"rgb(115,105,140)\">SURVIVOR / WAITING</font>")
        end
    end

    if CardPlayerRole then
        if not IsLocalPlayerKiller() then
            CardPlayerRole("<font color=\"rgb(0,240,255)\">SURVIVOR / PLAYER (ACTIVE)</font>")
        else
            CardPlayerRole("<font color=\"rgb(115,105,140)\">PLAYING AS KILLER (MUTED)</font>")
        end
    end

    -- Process Player Billboard ESP & Combat Hooks
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local root = ResolveAnchorPart(char) or char:FindFirstChild("HumanoidRootPart")
            local human = char:FindFirstChildOfClass("Humanoid")

            if root and root:IsA("BasePart") then
                local ok, rPos = pcall(function() return root.Position end)
                if ok and rPos then
                    -- STRICT SINGLE KILLER LOGIC: Only the true 1 killer is killer. All others are Player/Survivor!
                    local isKiller = (p == killer)

                    -- Multi-Layer Combat Binding (Strictly Killer Only!)
                    if isKiller then
                        BindCombatListeners(p, char)
                    end

                    -- Visuals: Dedicated toggles for Killer ESP vs Player (Survivor) ESP
                    local shouldShow = Config.Visuals.MasterESP and ((isKiller and Config.Visuals.KillerESP) or (not isKiller and Config.Visuals.SurvivorESP))
                    if shouldShow then
                        local color = isKiller and Config.Palette.Killer or Config.Palette.Survivor
                        local isHooked = GetGameValue(char, "IsHooked")
                        local isKnocked = GetGameValue(char, "Knocked") or (human and human.PlatformStand)

                        if isHooked then color = Config.Palette.Hooked
                        elseif isKnocked then color = Config.Palette.Downed
                        elseif human and human.Health < human.MaxHealth then color = Config.Palette.Injured end

                        local dist = myRoot and math.floor((rPos - myRoot.Position).Magnitude) or 0
                        local tagText = isKiller 
                            and string.format("KILLER // %s", p.DisplayName:upper())
                            or string.format("PLAYER // %s", p.DisplayName:upper())

                        if Config.Visuals.ShowDistance then
                            tagText = string.format("%s\n<font size=\"8\">[%dM]</font>", tagText, dist)
                        end

                        local tag = root:FindFirstChild("ESP_Tag") or char:FindFirstChild("ESP_Tag")
                        if not tag then
                            tag = BuildTag(tagText, color, Config.Visuals.HealthBars and human ~= nil)
                            tag.StudsOffset = Vector3.new(0, 3, 0)
                            tag.Adornee = root
                            tag.Parent = root
                            table.insert(State.Billboards, tag)
                        else
                            local lbl = tag:FindFirstChild("Label")
                            if lbl then lbl.Text = tagText; lbl.TextColor3 = color end
                            local fill = tag:FindFirstChild("BarBG") and tag.BarBG:FindFirstChild("Fill")
                            if fill and human then
                                fill.Size = UDim2.new(math.clamp(human.Health / human.MaxHealth, 0, 1), 0, 1, 0)
                                fill.BackgroundColor3 = color
                            end
                        end

                        SafeHighlight(char, color, isKiller)
                    else
                        local oldTag = char:FindFirstChild("ESP_Tag", true) or (root and root:FindFirstChild("ESP_Tag"))
                        if oldTag then oldTag:Destroy() end
                        RemoveHighlight(char)
                    end
                end
            end
        end
    end

    -- Frame-by-Frame Active Attack & Lunge Monitor (Catches mid-strike dash & lunge attacks)
    -- Strictly only active for Survivors against the Killer! Never runs if LocalPlayer is Killer!
    if Config.Combat.AutoParry and myRoot and not IsLocalPlayerKiller() then
        local checkTarget = killer or State.ActiveKiller
        if checkTarget and checkTarget ~= LocalPlayer and checkTarget.Character then
            local c = checkTarget.Character
            local r = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart or ResolveAnchorPart(c)
            if r and r:IsA("BasePart") then
                local dist = (r.Position - myRoot.Position).Magnitude
                if dist <= Config.Combat.ParryDistance then
                    local anim = GetCharacterAnimator(c)
                    if anim then
                        local tracks = anim:GetPlayingAnimationTracks()
                        for _, tr in ipairs(tracks) do
                            if tr.IsPlaying and tr.TimePosition < 0.45 and IsAttackAnimation(tr) then
                                if Config.Combat.FaceCheck then
                                    local toMe = (myRoot.Position - r.Position).Unit
                                    if r.CFrame.LookVector:Dot(toMe) >= -0.2 then
                                        ExecuteAutoParry("ACTIVE_LUNGE_TRACK")
                                        break
                                    end
                                else
                                    ExecuteAutoParry("ACTIVE_LUNGE_TRACK")
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Threat Radar HUD (Sleek Tactical Alert)
    -- Strictly for Survivors: When playing as Killer, hide the threat radar HUD completely!
    if ThreatRadarHUD then
        local isLocalKiller = IsLocalPlayerKiller() or (killer == LocalPlayer)
        if not isLocalKiller and Config.Radar.Enabled and Config.Radar.ThreatMeter and killer and killer ~= LocalPlayer and killerDist <= Config.Radar.Radius then
            ThreatRadarHUD.Visible = true
            local factor = 1 - math.clamp(killerDist / Config.Radar.Radius, 0, 1)
            ThreatBarFill.Size = UDim2.new(factor, 0, 1, 0)

            local kName = killer.DisplayName:upper()
            if ThreatDistBadge then
                ThreatDistBadge.Text = string.format("%dM", math.floor(killerDist))
            end

            if killerLOS then
                ThreatTitle.Text = string.format("CRITICAL // %s IN LINE OF SIGHT", kName)
                ThreatBarFill.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
                if ThreatTopAccent then ThreatTopAccent.BackgroundColor3 = Color3.fromRGB(255, 30, 60) end
            else
                ThreatTitle.Text = string.format("THREAT DETECTED // %s", kName)
                ThreatBarFill.BackgroundColor3 = Config.Palette.VicePink
                if ThreatTopAccent then ThreatTopAccent.BackgroundColor3 = Config.Palette.VicePink end
            end
        else
            ThreatRadarHUD.Visible = false
        end
    end
end

--------------------------------------------------------------------------------
-- AUTO GREAT SKILL CHECK & SMART GREAT ENGINE
--------------------------------------------------------------------------------

local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch(Config.Automation.ActionPath, "[^%.]+") do 
        current = current and current:FindFirstChild(segment) 
    end
    return current
end

-- Instantaneous Zero-Latency Great Tap Actuator (PC + Mobile)
local function TriggerGreatAction()
    -- 1. Spacebar Key Down synchronously via VirtualInputManager
    pcall(function()
        Services.VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    end)

    -- 2. Virtual Touch Event for Mobile
    pcall(function()
        local b = GetActionTarget()
        if b and b:IsA("GuiObject") then
            local p, s, i = b.AbsolutePosition, b.AbsoluteSize, Services.Gui:GetGuiInset()
            local cx, cy = p.X + (s.X / 2) + i.X, p.Y + (s.Y / 2) + i.Y
            Services.VIM:SendTouchEvent(Config.Automation.TouchID, 0, cx, cy)
            Services.VIM:SendTouchEvent(Config.Automation.TouchID, 2, cx, cy)
        end
    end)

    -- 3. Firesignal for Touch/Click GUI buttons
    pcall(function()
        local b = GetActionTarget()
        if b and firesignal then
            firesignal(b.Activated)
            firesignal(b.MouseButton1Click)
        end
    end)

    -- 4. Mobile action check button scan
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local mob = pg:FindFirstChild("Survivor-mob")
            if mob then
                local action = mob:FindFirstChild("Controls") and mob.Controls:FindFirstChild("action")
                local chk = action and action:FindFirstChild("check")
                if chk and firesignal then
                    firesignal(chk.Activated)
                    firesignal(chk.MouseButton1Click)
                end
            end
        end
    end)

    -- 5. Release Space key safely after micro-hold
    task.spawn(function()
        task.wait(0.02)
        pcall(function()
            Services.VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end)
end

local function IsInTargetArc(r0, r1, targetStart, targetEnd)
    local winLen = (targetEnd - targetStart) % 360
    if ((r1 - targetStart) % 360) <= winLen then
        return true
    end
    if r0 ~= nil then
        local sweep = (r1 - r0) % 360
        if sweep > 0 and sweep < 180 then
            local distToStart = (targetStart - r0) % 360
            if distToStart <= sweep then
                return true
            end
        end
    end
    return false
end

local function BindSkillCheckGui(prompt)
    if not prompt then return end
    local check = prompt:WaitForChild("Check", 5)
    if not check then return end
    local line = check:WaitForChild("Line", 5)
    local goal = check:WaitForChild("Goal", 5)
    if not line or not goal then return end

    local function RunSkillTracker()
        if not Config.Automation.AutoGreatCheck then return end
        if check.Visible then
            if State.SkillLoop then State.SkillLoop:Disconnect(); State.SkillLoop = nil end
            State.LastNeedleRot = line.Rotation % 360
            State.SkillTriggered = false

            State.SkillLoop = Services.Run.RenderStepped:Connect(function()
                if not check.Visible or not check.Parent then
                    if State.SkillLoop then State.SkillLoop:Disconnect(); State.SkillLoop = nil end
                    State.LastNeedleRot = nil
                    State.SkillTriggered = false
                    return
                end

                if State.SkillTriggered then return end

                local lr = line.Rotation % 360
                local gr = goal.Rotation % 360
                local hitTarget = false

                -- SMART GREAT FIX GEN (Zero adjustment needed):
                -- Violence District Great sweet spot is (gr + 104) to (gr + 114) DEG.
                -- We tap instantly at (gr + 105) to (gr + 113) DEG with 0ms delay.
                if Config.Automation.SmartGreat then
                    local gs = (gr + 105) % 360
                    local ge = (gr + 113) % 360
                    if IsInTargetArc(State.LastNeedleRot, lr, gs, ge) then
                        hitTarget = true
                    end
                else
                    local angleStart = Config.Automation.HitAngleStart
                    local angleEnd = Config.Automation.HitAngleEnd
                    local ss = (gr + angleStart) % 360
                    local se = (gr + angleEnd) % 360
                    if IsInTargetArc(State.LastNeedleRot, lr, ss, se) then
                        hitTarget = true
                    end
                end

                if hitTarget then
                    State.SkillTriggered = true
                    if State.SkillLoop then State.SkillLoop:Disconnect(); State.SkillLoop = nil end
                    State.LastNeedleRot = nil

                    if not Config.Automation.SmartGreat and Config.Automation.ClickDelay > 0 then
                        task.delay(Config.Automation.ClickDelay, TriggerGreatAction)
                    else
                        TriggerGreatAction()
                    end
                else
                    State.LastNeedleRot = lr
                end
            end)
        elseif State.SkillLoop then
            State.SkillLoop:Disconnect()
            State.SkillLoop = nil
            State.LastNeedleRot = nil
            State.SkillTriggered = false
        end
    end

    check:GetPropertyChangedSignal("Visible"):Connect(RunSkillTracker)
    if check.Visible then RunSkillTracker() end
end

local function InitializeSkillEngine()
    task.spawn(function()
        for _, c in ipairs(PlayerGui:GetChildren()) do
            if c.Name == "SkillCheckPromptGui" or c.Name:find("SkillCheck") then
                BindSkillCheckGui(c)
            end
        end
        PlayerGui.ChildAdded:Connect(function(c)
            if c.Name == "SkillCheckPromptGui" or c.Name:find("SkillCheck") then
                task.wait(0.04)
                BindSkillCheckGui(c)
            end
        end)
    end)

    -- Auto Generator Repair Proximity Assist Loop
    task.spawn(function()
        while true do
            task.wait(0.25)
            if Config.System.Active and Config.Automation.AutoRepair and LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and State.Generators and #State.Generators > 0 then
                    for _, gen in ipairs(State.Generators) do
                        if gen and gen.Parent then
                            local prog = GetGeneratorProgress(gen)
                            if not IsGeneratorCompleted(gen, prog) then
                                local anchor = State.AnchorCache[gen] or gen:FindFirstChildWhichIsA("BasePart", true)
                                if anchor then
                                    local dist = (anchor.Position - root.Position).Magnitude
                                    if dist <= 14 then
                                        for _, p in ipairs(gen:GetDescendants()) do
                                            if p:IsA("ProximityPrompt") and p.Enabled then
                                                pcall(function()
                                                    if fireproximityprompt then
                                                        fireproximityprompt(p, 0)
                                                    end
                                                end)
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- 606 GTA 6 LUXURY UI ENGINE (ZERO STROKES // STRICT ZERO EMOJIS)
--------------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceDistrict_Suite"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.IgnoreGuiInset = true

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = PlayerGui
    end
end)

-- Comprehensive Script Close & Unload Engine
local function UnloadScript()
    Config.System.Active = false
    Config.Combat.AutoParry = false
    Config.Automation.AutoGreatCheck = false

    -- Disconnect all active connections
    for _, c in pairs(State.Connections) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    table.clear(State.Connections)

    for _, c in pairs(State.ParryConnections) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    table.clear(State.ParryConnections)

    if State.SkillLoop then
        pcall(function() State.SkillLoop:Disconnect() end)
        State.SkillLoop = nil
    end

    -- Remove all 3D Highlights
    for obj, hl in pairs(State.Highlights) do
        if hl then pcall(function() hl:Destroy() end) end
    end
    table.clear(State.Highlights)
    State.HighlightCount = 0

    -- Remove all 3D Billboard Tags
    for _, b in pairs(State.Billboards) do
        if b then pcall(function() b:Destroy() end) end
    end
    table.clear(State.Billboards)

    -- Sweep any leftover ESP tags or highlights in Workspace
    pcall(function()
        for _, desc in ipairs(Services.Workspace:GetDescendants()) do
            if desc.Name == "ESP_Tag" or desc.Name == "VD_Highlight" then
                pcall(function() desc:Destroy() end)
            end
        end
    end)

    -- Restore environmental lighting and player movement
    pcall(function()
        Services.Lighting.Ambient = State.LightingDefaults.Ambient
        Services.Lighting.OutdoorAmbient = State.LightingDefaults.OutdoorAmbient
        Services.Lighting.Brightness = State.LightingDefaults.Brightness
        Services.Lighting.ClockTime = State.LightingDefaults.ClockTime
        Services.Lighting.FogEnd = State.LightingDefaults.FogEnd
        Services.Lighting.GlobalShadows = State.LightingDefaults.GlobalShadows
        Camera.FieldOfView = 70
        if LocalPlayer.Character then
            local human = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if human then human.WalkSpeed = 16 end
        end
    end)

    for _, c in pairs(State.KillerConnections) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    table.clear(State.KillerConnections)

    -- Destroy UI ScreenGui completely
    pcall(function()
        ScreenGui:Destroy()
    end)
end

-- Premium Red & Black Luxury Palette Hierarchy
local C_BLACK          = Color3.fromRGB(10, 8, 12)       -- Deep Obsidian Matte
local C_SURFACE        = Color3.fromRGB(15, 12, 17)      -- Dark Carbon Header & Sidebar
local C_CONTAINER      = Color3.fromRGB(22, 17, 24)      -- Rich Charcoal Container Cards
local C_CONTAINER_HOVER= Color3.fromRGB(32, 22, 32)      -- Warm Ruby Hover State
local C_CONTAINER_ACT  = Color3.fromRGB(38, 18, 26)      -- Glowing Active Background
local C_BORDER         = Color3.fromRGB(50, 20, 28)      -- Deep Ruby 1px Framing
local C_BORDER_DIM     = Color3.fromRGB(32, 14, 20)      -- Dark Underline Accent
local C_RED            = Color3.fromRGB(255, 38, 58)     -- Radiant Crimson / Blood Red
local C_RED_DARK       = Color3.fromRGB(180, 20, 38)     -- Deep Velvet Crimson
local C_RED_GLOW       = Color3.fromRGB(255, 75, 95)     -- Neon Ruby Highlight
local C_WHITE          = Color3.fromRGB(252, 250, 255)   -- Pure Diamond White
local C_MUTED          = Color3.fromRGB(135, 125, 142)   -- Sleek Metallic Platinum
local C_MUTED_LIGHT    = Color3.fromRGB(175, 166, 185)   -- Crisp Secondary Label
local C_GREEN          = Color3.fromRGB(0, 245, 140)     -- Tactical Emerald Status

-- Backwards compatibility aliases
local C_ONYX   = C_BLACK
local C_PINK   = C_RED
local C_CYAN   = C_RED_GLOW
local C_PURPLE = C_RED_DARK

-- Outer Shell Frame
local Shell = Instance.new("Frame")
Shell.Name = "Shell_VD"
Shell.Size = UDim2.new(0, 670, 0, 425)
Shell.Position = UDim2.new(0.5, -335, 0.5, -212)
Shell.BackgroundColor3 = C_ONYX
Shell.BorderSizePixel = 0
Shell.ClipsDescendants = true
Shell.Parent = ScreenGui

Instance.new("UICorner", Shell).CornerRadius = UDim.new(0, 10)

-- Top Accent Ribbon (Vice City 3-Way Radiant Gradient)
local TopRibbon = Instance.new("Frame", Shell)
TopRibbon.Name = "TopRibbon"
TopRibbon.Size = UDim2.new(1, 0, 0, 3)
TopRibbon.Position = UDim2.new(0, 0, 0, 0)
TopRibbon.BorderSizePixel = 0

local RibbonGrad = Instance.new("UIGradient", TopRibbon)
RibbonGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 38, 58)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 16, 32)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 60, 80))
})

-- Header Bar
local Header = Instance.new("Frame", Shell)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 52)
Header.Position = UDim2.new(0, 0, 0, 3)
Header.BackgroundColor3 = C_SURFACE
Header.BorderSizePixel = 0

local HeaderBottomLine = Instance.new("Frame", Header)
HeaderBottomLine.Size = UDim2.new(1, 0, 0, 1)
HeaderBottomLine.Position = UDim2.new(0, 0, 1, -1)
HeaderBottomLine.BackgroundColor3 = C_BORDER
HeaderBottomLine.BorderSizePixel = 0

-- Header: 606 Title Logo (Exclusive Branding Placement)
local BrandPill = Instance.new("Frame", Header)
BrandPill.Name = "BrandPill"
BrandPill.Size = UDim2.new(0, 60, 0, 26)
BrandPill.Position = UDim2.new(0, 16, 0.5, -13)
BrandPill.BackgroundColor3 = Color3.fromRGB(26, 14, 20)
BrandPill.BorderSizePixel = 0
Instance.new("UICorner", BrandPill).CornerRadius = UDim.new(0, 6)

local BrandPillAccent = Instance.new("Frame", BrandPill)
BrandPillAccent.Size = UDim2.new(0, 2, 0.6, 0)
BrandPillAccent.Position = UDim2.new(0, 0, 0.2, 0)
BrandPillAccent.BackgroundColor3 = C_PINK
BrandPillAccent.BorderSizePixel = 0
Instance.new("UICorner", BrandPillAccent).CornerRadius = UDim.new(1, 0)

local Title606 = Instance.new("TextLabel", BrandPill)
Title606.Text = "606VD"
Title606.Size = UDim2.new(1, -2, 1, 0)
Title606.Position = UDim2.new(0, 2, 0, 0)
Title606.BackgroundTransparency = 1
Title606.TextColor3 = C_PINK
Title606.Font = Enum.Font.GothamBold
Title606.TextSize = 13
Title606.TextXAlignment = Enum.TextXAlignment.Center

local TitleDiv = Instance.new("Frame", Header)
TitleDiv.Size = UDim2.new(0, 1, 0, 22)
TitleDiv.Position = UDim2.new(0, 86, 0.5, -11)
TitleDiv.BackgroundColor3 = C_BORDER
TitleDiv.BorderSizePixel = 0

local MainTitle = Instance.new("TextLabel", Header)
MainTitle.Text = "VIOLENCE DISTRICT"
MainTitle.Size = UDim2.new(0, 180, 0, 18)
MainTitle.Position = UDim2.new(0, 98, 0.5, -9)
MainTitle.BackgroundTransparency = 1
MainTitle.TextColor3 = C_WHITE
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextSize = 13
MainTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Header: Telemetry HUD Box
local TelemetryBox = Instance.new("Frame", Header)
TelemetryBox.Size = UDim2.new(0, 145, 0, 28)
TelemetryBox.Position = UDim2.new(1, -225, 0.5, -14)
TelemetryBox.BackgroundColor3 = C_CONTAINER
TelemetryBox.BorderSizePixel = 0
Instance.new("UICorner", TelemetryBox).CornerRadius = UDim.new(0, 6)

local TelemetryDot = Instance.new("Frame", TelemetryBox)
TelemetryDot.Size = UDim2.new(0, 6, 0, 6)
TelemetryDot.Position = UDim2.new(0, 10, 0.5, -3)
TelemetryDot.BackgroundColor3 = C_GREEN
TelemetryDot.BorderSizePixel = 0
Instance.new("UICorner", TelemetryDot).CornerRadius = UDim.new(1, 0)

local TelemetryLabel = Instance.new("TextLabel", TelemetryBox)
TelemetryLabel.Text = "60 FPS  |  20 MS"
TelemetryLabel.Size = UDim2.new(1, -24, 1, 0)
TelemetryLabel.Position = UDim2.new(0, 22, 0, 0)
TelemetryLabel.BackgroundTransparency = 1
TelemetryLabel.TextColor3 = C_MUTED_LIGHT
TelemetryLabel.Font = Enum.Font.GothamBold
TelemetryLabel.TextSize = 10
TelemetryLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Header: Minimize Window Button ("-")
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -72, 0.5, -14)
MinBtn.BackgroundColor3 = C_CONTAINER
MinBtn.TextColor3 = C_MUTED_LIGHT
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

MinBtn.MouseEnter:Connect(function()
    Services.Tween:Create(MinBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C_CONTAINER_HOVER,
        TextColor3 = C_CYAN
    }):Play()
end)

MinBtn.MouseLeave:Connect(function()
    Services.Tween:Create(MinBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C_CONTAINER,
        TextColor3 = C_MUTED_LIGHT
    }):Play()
end)

-- Header: Close / Terminate Script Button ("X")
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(48, 16, 26)
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 95)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseEnter:Connect(function()
    Services.Tween:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(255, 45, 65),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

CloseBtn.MouseLeave:Connect(function()
    Services.Tween:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(48, 16, 26),
        TextColor3 = Color3.fromRGB(255, 75, 95)
    }):Play()
end)

-- Sidebar Layout
local Sidebar = Instance.new("Frame", Shell)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -55)
Sidebar.Position = UDim2.new(0, 0, 0, 55)
Sidebar.BackgroundColor3 = C_SURFACE
Sidebar.BorderSizePixel = 0

local SidebarRightLine = Instance.new("Frame", Sidebar)
SidebarRightLine.Size = UDim2.new(0, 1, 1, 0)
SidebarRightLine.Position = UDim2.new(1, -1, 0, 0)
SidebarRightLine.BackgroundColor3 = C_BORDER
SidebarRightLine.BorderSizePixel = 0

local NavHeader = Instance.new("TextLabel", Sidebar)
NavHeader.Text = "NAVIGATION"
NavHeader.Size = UDim2.new(1, -20, 0, 16)
NavHeader.Position = UDim2.new(0, 14, 0, 10)
NavHeader.BackgroundTransparency = 1
NavHeader.TextColor3 = C_MUTED
NavHeader.Font = Enum.Font.GothamBold
NavHeader.TextSize = 8
NavHeader.TextXAlignment = Enum.TextXAlignment.Left

local TabIndicator = Instance.new("Frame", Sidebar)
TabIndicator.Name = "TabIndicator"
TabIndicator.Size = UDim2.new(0, 3, 0, 20)
TabIndicator.Position = UDim2.new(0, 4, 0, 34)
TabIndicator.BackgroundColor3 = C_PINK
TabIndicator.BorderSizePixel = 0
Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(1, 0)

local TabScroll = Instance.new("ScrollingFrame", Sidebar)
TabScroll.Size = UDim2.new(1, -16, 1, -64)
TabScroll.Position = UDim2.new(0, 10, 0, 30)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 0
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local TabLayout = Instance.new("UIListLayout", TabScroll)
TabLayout.Padding = UDim.new(0, 4)
TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 8)
end)

-- Sidebar Bottom: Dedicated Close Script Button
local CloseScriptBtn = Instance.new("TextButton", Sidebar)
CloseScriptBtn.Size = UDim2.new(1, -16, 0, 28)
CloseScriptBtn.Position = UDim2.new(0, 8, 1, -34)
CloseScriptBtn.BackgroundColor3 = Color3.fromRGB(36, 16, 26)
CloseScriptBtn.Text = "CLOSE SCRIPT"
CloseScriptBtn.TextColor3 = Color3.fromRGB(255, 60, 80)
CloseScriptBtn.Font = Enum.Font.GothamBold
CloseScriptBtn.TextSize = 9
CloseScriptBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseScriptBtn).CornerRadius = UDim.new(0, 6)

CloseScriptBtn.MouseEnter:Connect(function()
    Services.Tween:Create(CloseScriptBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(56, 20, 36),
        TextColor3 = Color3.fromRGB(255, 95, 115)
    }):Play()
end)

CloseScriptBtn.MouseLeave:Connect(function()
    Services.Tween:Create(CloseScriptBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(36, 16, 26),
        TextColor3 = Color3.fromRGB(255, 60, 80)
    }):Play()
end)

-- Main Content Area
local Content = Instance.new("Frame", Shell)
Content.Name = "Content"
Content.Size = UDim2.new(1, -174, 1, -67)
Content.Position = UDim2.new(0, 168, 0, 61)
Content.BackgroundTransparency = 1

--------------------------------------------------------------------------------
-- THREAT RADAR HUD (TOP TACTICAL BANNER)
--------------------------------------------------------------------------------

ThreatRadarHUD = Instance.new("Frame", ScreenGui)
ThreatRadarHUD.Name = "ThreatRadar"
ThreatRadarHUD.Size = UDim2.new(0, 340, 0, 46)
ThreatRadarHUD.Position = UDim2.new(0.5, -170, 0, 22)
ThreatRadarHUD.BackgroundColor3 = C_ONYX
ThreatRadarHUD.BorderSizePixel = 0
ThreatRadarHUD.Visible = false
Instance.new("UICorner", ThreatRadarHUD).CornerRadius = UDim.new(0, 8)

ThreatTopAccent = Instance.new("Frame", ThreatRadarHUD)
ThreatTopAccent.Size = UDim2.new(1, 0, 0, 2)
ThreatTopAccent.Position = UDim2.new(0, 0, 0, 0)
ThreatTopAccent.BackgroundColor3 = C_PINK
ThreatTopAccent.BorderSizePixel = 0
Instance.new("UICorner", ThreatTopAccent).CornerRadius = UDim.new(1, 0)

ThreatTitle = Instance.new("TextLabel", ThreatRadarHUD)
ThreatTitle.Size = UDim2.new(1, -80, 0, 18)
ThreatTitle.Position = UDim2.new(0, 12, 0, 6)
ThreatTitle.BackgroundTransparency = 1
ThreatTitle.TextColor3 = C_PINK
ThreatTitle.Font = Enum.Font.GothamBold
ThreatTitle.TextSize = 10
ThreatTitle.Text = "THREAT DETECTED // ACTIVE SCAN"
ThreatTitle.TextXAlignment = Enum.TextXAlignment.Left

ThreatDistBadge = Instance.new("TextLabel", ThreatRadarHUD)
ThreatDistBadge.Size = UDim2.new(0, 56, 0, 18)
ThreatDistBadge.Position = UDim2.new(1, -66, 0, 6)
ThreatDistBadge.BackgroundColor3 = C_CONTAINER
ThreatDistBadge.TextColor3 = C_CYAN
ThreatDistBadge.Font = Enum.Font.GothamBold
ThreatDistBadge.TextSize = 10
ThreatDistBadge.Text = "--M"
ThreatDistBadge.BorderSizePixel = 0
Instance.new("UICorner", ThreatDistBadge).CornerRadius = UDim.new(0, 4)

local ThreatBarBG = Instance.new("Frame", ThreatRadarHUD)
ThreatBarBG.Size = UDim2.new(1, -24, 0, 5)
ThreatBarBG.Position = UDim2.new(0, 12, 0, 29)
ThreatBarBG.BackgroundColor3 = Color3.fromRGB(28, 18, 32)
ThreatBarBG.BorderSizePixel = 0
Instance.new("UICorner", ThreatBarBG).CornerRadius = UDim.new(1, 0)

ThreatBarFill = Instance.new("Frame", ThreatBarBG)
ThreatBarFill.Size = UDim2.new(0.5, 0, 1, 0)
ThreatBarFill.BackgroundColor3 = C_PINK
ThreatBarFill.BorderSizePixel = 0
Instance.new("UICorner", ThreatBarFill).CornerRadius = UDim.new(1, 0)

-- Mobile Floating Menu Toggle (Clean & Zero Emojis)
local MobileBadge = Instance.new("TextButton", ScreenGui)
MobileBadge.Name = "MobileMenuToggle"
MobileBadge.Size = UDim2.new(0, 64, 0, 32)
MobileBadge.Position = UDim2.new(0.04, 0, 0.25, 0)
MobileBadge.BackgroundColor3 = C_SURFACE
MobileBadge.Text = "MENU"
MobileBadge.TextColor3 = C_PINK
MobileBadge.Font = Enum.Font.GothamBold
MobileBadge.TextSize = 11
MobileBadge.BorderSizePixel = 0
Instance.new("UICorner", MobileBadge).CornerRadius = UDim.new(0, 6)

local MobAccent = Instance.new("Frame", MobileBadge)
MobAccent.Size = UDim2.new(1, 0, 0, 2)
MobAccent.Position = UDim2.new(0, 0, 1, -2)
MobAccent.BackgroundColor3 = C_CYAN
MobAccent.BorderSizePixel = 0
Instance.new("UICorner", MobAccent).CornerRadius = UDim.new(1, 0)

-- Dragging Engine
local function MakeDraggable(gui, handle)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Services.Input.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
MakeDraggable(Shell, Header)
MakeDraggable(MobileBadge, MobileBadge)

-- Toggle UI Animation Engine (Ultra Smooth Quart Easing)
local WindowOpen = true
local function ToggleUI()
    WindowOpen = not WindowOpen
    if WindowOpen then
        Shell.Visible = true
        Shell.Size = UDim2.new(0, 635, 0, 395)
        Shell.BackgroundTransparency = 0.3
        Services.Tween:Create(Shell, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 670, 0, 425),
            BackgroundTransparency = 0
        }):Play()
    else
        local tw = Services.Tween:Create(Shell, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 630, 0, 385),
            BackgroundTransparency = 0.5
        })
        tw:Play()
        tw.Completed:Connect(function()
            if not WindowOpen then Shell.Visible = false end
        end)
    end
end

MinBtn.MouseButton1Click:Connect(ToggleUI)
CloseBtn.MouseButton1Click:Connect(UnloadScript)
CloseScriptBtn.MouseButton1Click:Connect(UnloadScript)
MobileBadge.MouseButton1Click:Connect(ToggleUI)
Services.Input.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Config.System.MenuKey or input.KeyCode == Config.System.AltKey) then
        ToggleUI()
    end
end)

--------------------------------------------------------------------------------
-- TAB & LUXURY CONTROL BUILDER (WITH FULL-ROW TAP-TO-TOGGLE)
--------------------------------------------------------------------------------

local TabList = {}
local Builder = {}

function Builder:Tab(name, description)
    local tabIndex = #TabList + 1

    local btn = Instance.new("TextButton", TabScroll)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C_CONTAINER
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = C_MUTED
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local btnNotch = Instance.new("Frame", btn)
    btnNotch.Size = UDim2.new(0, 2, 0, 14)
    btnNotch.Position = UDim2.new(0, 2, 0.5, -7)
    btnNotch.BackgroundColor3 = C_RED
    btnNotch.BackgroundTransparency = 1
    btnNotch.BorderSizePixel = 0
    Instance.new("UICorner", btnNotch).CornerRadius = UDim.new(1, 0)

    local page = Instance.new("ScrollingFrame", Content)
    page.Name = name .. "_PAGE"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = C_RED
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false

    -- Section Header inside each page
    local pageHeader = Instance.new("Frame", page)
    pageHeader.Name = "PageHeader"
    pageHeader.Size = UDim2.new(1, -6, 0, 38)
    pageHeader.BackgroundTransparency = 1

    local pageTitle = Instance.new("TextLabel", pageHeader)
    pageTitle.Text = name .. " PROTOCOLS"
    pageTitle.Size = UDim2.new(1, 0, 0, 16)
    pageTitle.Position = UDim2.new(0, 2, 0, 0)
    pageTitle.BackgroundTransparency = 1
    pageTitle.TextColor3 = C_WHITE
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextSize = 12
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left

    local pageSub = Instance.new("TextLabel", pageHeader)
    pageSub.Text = description or "SYSTEM CONFIGURATION"
    pageSub.Size = UDim2.new(1, 0, 0, 14)
    pageSub.Position = UDim2.new(0, 2, 0, 16)
    pageSub.BackgroundTransparency = 1
    pageSub.TextColor3 = C_MUTED
    pageSub.Font = Enum.Font.GothamMedium
    pageSub.TextSize = 9
    pageSub.TextXAlignment = Enum.TextXAlignment.Left

    local pageLine = Instance.new("Frame", pageHeader)
    pageLine.Size = UDim2.new(1, 0, 0, 1)
    pageLine.Position = UDim2.new(0, 0, 1, -2)
    pageLine.BackgroundColor3 = C_BORDER_DIM
    pageLine.BorderSizePixel = 0

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 7)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    local function Switch()
        for _, t in ipairs(TabList) do
            t.Page.Visible = false
            Services.Tween:Create(t.Btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = C_MUTED,
                BackgroundTransparency = 1
            }):Play()
            if t.Notch then
                Services.Tween:Create(t.Notch, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
            end
        end

        page.Position = UDim2.new(0, 0, 0, 8)
        page.Visible = true
        Services.Tween:Create(page, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        Services.Tween:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = C_RED,
            BackgroundTransparency = 0.82,
            BackgroundColor3 = C_RED
        }):Play()
        Services.Tween:Create(btnNotch, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()

        local targetY = 34 + (tabIndex - 1) * 36
        Services.Tween:Create(TabIndicator, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 4, 0, targetY)
        }):Play()
    end

    btn.MouseEnter:Connect(function()
        if not page.Visible then
            Services.Tween:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.92,
                BackgroundColor3 = C_CONTAINER_HOVER,
                TextColor3 = C_WHITE
            }):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if not page.Visible then
            Services.Tween:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
                TextColor3 = C_MUTED
            }):Play()
        end
    end)

    btn.MouseButton1Click:Connect(Switch)
    table.insert(TabList, {Btn = btn, Page = page, Notch = btnNotch, Index = tabIndex})
    if #TabList == 1 then Switch() end
    local Widgets = {}

    -- FULL-ROW TAP-TO-TOGGLE COMPONENT (Red + Black Ultra Smooth Dynamic Toggle)
    function Widgets:Toggle(title, defaultVal, callback, accentColor)
        local activeColor = accentColor or C_RED

        local box = Instance.new("Frame", page)
        box.Size = UDim2.new(1, -6, 0, 44)
        box.BackgroundColor3 = defaultVal and C_CONTAINER_ACT or C_CONTAINER
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)

        -- Left Active Indicator Pill with dynamic height
        local activeBar = Instance.new("Frame", box)
        activeBar.Size = defaultVal and UDim2.new(0, 3, 0, 24) or UDim2.new(0, 3, 0, 16)
        activeBar.Position = defaultVal and UDim2.new(0, 0, 0.5, -12) or UDim2.new(0, 0, 0.5, -8)
        activeBar.BackgroundColor3 = defaultVal and activeColor or C_BORDER_DIM
        activeBar.BorderSizePixel = 0
        Instance.new("UICorner", activeBar).CornerRadius = UDim.new(1, 0)

        local label = Instance.new("TextLabel", box)
        label.Text = title
        label.Size = UDim2.new(1, -90, 0, 18)
        label.Position = UDim2.new(0, 16, 0, 6)
        label.BackgroundTransparency = 1
        label.TextColor3 = C_WHITE
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        local statusLabel = Instance.new("TextLabel", box)
        statusLabel.Text = defaultVal and "ACTIVE" or "DISABLED"
        statusLabel.Size = UDim2.new(1, -90, 0, 14)
        statusLabel.Position = UDim2.new(0, 16, 0, 24)
        statusLabel.BackgroundTransparency = 1
        statusLabel.TextColor3 = defaultVal and (accentColor or C_RED_GLOW) or C_MUTED
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.TextSize = 8
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left

        local switch = Instance.new("Frame", box)
        switch.Size = UDim2.new(0, 42, 0, 22)
        switch.Position = UDim2.new(1, -54, 0.5, -11)
        switch.BackgroundColor3 = defaultVal and activeColor or Color3.fromRGB(32, 18, 24)
        switch.BorderSizePixel = 0
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame", switch)
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = defaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local state = defaultVal
        local function SetState(val)
            state = val
            local col = state and activeColor or Color3.fromRGB(32, 18, 24)
            local pos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local barCol = state and activeColor or C_BORDER_DIM
            local barSize = state and UDim2.new(0, 3, 0, 24) or UDim2.new(0, 3, 0, 16)
            local barPos = state and UDim2.new(0, 0, 0.5, -12) or UDim2.new(0, 0, 0.5, -8)
            local boxCol = state and C_CONTAINER_ACT or C_CONTAINER
            
            statusLabel.Text = state and "ACTIVE" or "DISABLED"
            statusLabel.TextColor3 = state and (accentColor or C_RED_GLOW) or C_MUTED

            Services.Tween:Create(switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = col}):Play()
            Services.Tween:Create(dot, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = pos}):Play()
            Services.Tween:Create(activeBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = barCol,
                Size = barSize,
                Position = barPos
            }):Play()
            Services.Tween:Create(box, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = boxCol}):Play()
            callback(state)
        end

        -- Invisible full-card tap button with tactile feedback
        local tapOverlay = Instance.new("TextButton", box)
        tapOverlay.Name = "TapHitbox"
        tapOverlay.Size = UDim2.new(1, 0, 1, 0)
        tapOverlay.BackgroundTransparency = 1
        tapOverlay.Text = ""
        tapOverlay.ZIndex = 5

        tapOverlay.MouseButton1Click:Connect(function()
            Services.Tween:Create(box, TweenInfo.new(0.06), {Size = UDim2.new(1, -10, 0, 42)}):Play()
            task.wait(0.06)
            Services.Tween:Create(box, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, 44)}):Play()
            SetState(not state)
        end)

        tapOverlay.MouseEnter:Connect(function()
            if not state then
                Services.Tween:Create(box, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = C_CONTAINER_HOVER}):Play()
            end
        end)
        tapOverlay.MouseLeave:Connect(function()
            local target = state and C_CONTAINER_ACT or C_CONTAINER
            Services.Tween:Create(box, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = target}):Play()
        end)

        return SetState
    end

    -- Luxury Slider Component
    function Widgets:Slider(title, min, max, defaultVal, suffix, isFloat, callback)
        local box = Instance.new("Frame", page)
        box.Size = UDim2.new(1, -6, 0, 56)
        box.BackgroundColor3 = C_CONTAINER
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)

        local label = Instance.new("TextLabel", box)
        label.Text = title
        label.Size = UDim2.new(0.7, 0, 0, 20)
        label.Position = UDim2.new(0, 16, 0, 8)
        label.BackgroundTransparency = 1
        label.TextColor3 = C_WHITE
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        -- Sleek Value Badge Box in Deep Obsidian
        local badge = Instance.new("Frame", box)
        badge.Size = UDim2.new(0, 68, 0, 18)
        badge.Position = UDim2.new(1, -80, 0, 8)
        badge.BackgroundColor3 = C_BLACK
        badge.BorderSizePixel = 0
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)

        local num = Instance.new("TextLabel", badge)
        num.Text = tostring(defaultVal) .. (suffix or "")
        num.Size = UDim2.new(1, 0, 1, 0)
        num.BackgroundTransparency = 1
        num.TextColor3 = C_RED_GLOW
        num.Font = Enum.Font.GothamBold
        num.TextSize = 10
        num.TextXAlignment = Enum.TextXAlignment.Center

        local track = Instance.new("Frame", box)
        track.Size = UDim2.new(1, -32, 0, 5)
        track.Position = UDim2.new(0, 16, 0, 38)
        track.BackgroundColor3 = Color3.fromRGB(16, 12, 18)
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", track)
        local initScale = math.clamp((defaultVal - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(initScale, 0, 1, 0)
        fill.BackgroundColor3 = C_RED
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local fillGrad = Instance.new("UIGradient", fill)
        fillGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C_RED_DARK),
            ColorSequenceKeypoint.new(1, C_RED)
        })

        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 13, 0, 13)
        knob.Position = UDim2.new(initScale, -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local knobCenter = Instance.new("Frame", knob)
        knobCenter.Size = UDim2.new(0, 5, 0, 5)
        knobCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
        knobCenter.BackgroundColor3 = C_RED
        knobCenter.BorderSizePixel = 0
        Instance.new("UICorner", knobCenter).CornerRadius = UDim.new(1, 0)

        local active = false
        local function Apply(input)
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local raw = min + (max - min) * p
            local val = isFloat and (math.floor(raw * 2) / 2) or math.floor(raw)
            Services.Tween:Create(fill, TweenInfo.new(0.06), {Size = UDim2.new(p, 0, 1, 0)}):Play()
            Services.Tween:Create(knob, TweenInfo.new(0.06), {Position = UDim2.new(p, -6, 0.5, -6)}):Play()
            num.Text = tostring(val) .. (suffix or "")
            callback(val)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                active = true
                Apply(input)
            end
        end)
        Services.Input.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                active = false
            end
        end)
        Services.Input.InputChanged:Connect(function(input)
            if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                Apply(input)
            end
        end)

        box.MouseEnter:Connect(function()
            Services.Tween:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = C_CONTAINER_HOVER}):Play()
        end)
        box.MouseLeave:Connect(function()
            Services.Tween:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = C_CONTAINER}):Play()
        end)
    end

    -- Luxury Metric / Intel Card Component
    function Widgets:Card(label, val, accentColor)
        local card = Instance.new("Frame", page)
        card.Size = UDim2.new(1, -6, 0, 48)
        card.BackgroundColor3 = C_CONTAINER
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 7)

        local leftBar = Instance.new("Frame", card)
        leftBar.Size = UDim2.new(0, 3, 0, 24)
        leftBar.Position = UDim2.new(0, 0, 0.5, -12)
        leftBar.BackgroundColor3 = accentColor or C_CYAN
        leftBar.BorderSizePixel = 0
        Instance.new("UICorner", leftBar).CornerRadius = UDim.new(1, 0)

        local tit = Instance.new("TextLabel", card)
        tit.Text = label:upper()
        tit.Size = UDim2.new(1, -24, 0, 14)
        tit.Position = UDim2.new(0, 16, 0, 8)
        tit.BackgroundTransparency = 1
        tit.TextColor3 = C_MUTED
        tit.Font = Enum.Font.GothamBold
        tit.TextSize = 9
        tit.TextXAlignment = Enum.TextXAlignment.Left

        local data = Instance.new("TextLabel", card)
        data.Text = val
        data.Size = UDim2.new(1, -24, 0, 18)
        data.Position = UDim2.new(0, 16, 0, 24)
        data.BackgroundTransparency = 1
        data.TextColor3 = C_WHITE
        data.Font = Enum.Font.GothamBold
        data.TextSize = 11
        data.TextXAlignment = Enum.TextXAlignment.Left
        data.RichText = true

        return function(txt) data.Text = txt end
    end

    -- Luxury Action Button Component (Red + Black Theme with Left Ruby Accent)
    function Widgets:Button(title, isDestructive, callback)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(1, -6, 0, 36)
        b.BackgroundColor3 = isDestructive and Color3.fromRGB(38, 14, 20) or C_CONTAINER
        b.Text = title
        b.TextColor3 = isDestructive and Color3.fromRGB(255, 65, 80) or C_WHITE
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)

        local bar = Instance.new("Frame", b)
        bar.Size = UDim2.new(0, 3, 0.6, 0)
        bar.Position = UDim2.new(0, 0, 0.2, 0)
        bar.BackgroundColor3 = isDestructive and Color3.fromRGB(255, 50, 70) or C_RED_DARK
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        b.MouseEnter:Connect(function()
            Services.Tween:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = isDestructive and Color3.fromRGB(60, 18, 28) or C_CONTAINER_HOVER,
                TextColor3 = isDestructive and Color3.fromRGB(255, 100, 115) or C_RED_GLOW
            }):Play()
        end)

        b.MouseLeave:Connect(function()
            Services.Tween:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = isDestructive and Color3.fromRGB(38, 14, 20) or C_CONTAINER,
                TextColor3 = isDestructive and Color3.fromRGB(255, 65, 80) or C_WHITE
            }):Play()
        end)

        b.MouseButton1Click:Connect(function()
            Services.Tween:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -12, 0, 34)}):Play()
            task.wait(0.08)
            Services.Tween:Create(b, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, 36)}):Play()
            callback()
        end)
    end

    return Widgets
end

local PagePlayer   = Builder:Tab("PLAYER ONLY", "SURVIVOR PROTOCOLS // PARRY, SPEED & NO STUN")
local PageKiller   = Builder:Tab("KILLER ONLY", "EXCLUSIVE PROTOCOLS // ANTI STUN & FAST SPEED")
local PageCombat   = Builder:Tab("COMBAT", "AUTOMATED DEFENSE & PARRY TIMING")
local PageAuto     = Builder:Tab("AUTOMATION", "SMART GREAT ENGINE // ZERO CONFIGURATION")
local PageESP      = Builder:Tab("VISUALS", "ESP SYSTEM // TAP TO ON OR OFF")
local PageThreat   = Builder:Tab("RADAR", "THREAT PROXIMITY & LINE-OF-SIGHT SENSORS")
local PageWorld    = Builder:Tab("WORLD", "ENVIRONMENTAL LIGHTING & FOV CONTROL")
local PageIntel    = Builder:Tab("INTEL", "LIVE MATCH TELEMETRY & ACTIVE KILLER STATS")
local PageSettings = Builder:Tab("SETTINGS", "CACHE MANAGEMENT & ENGINE CONTROLS")

-- Player Protocols: PLAYER ONLY (Auto Parry Killer, Speed Adjust & No Stun)
CardPlayerRole = PagePlayer:Card("Player Role Detection", "CHECKING ROLE...", C_CYAN)

-- Combat: Auto Parry Killer (Strictly Player parry from Killer hit)
PagePlayer:Toggle("Auto Parry Killer Attacks", Config.Combat.AutoParry, function(v)
    Config.Combat.AutoParry = v
    Config.Player.AutoParry = v
end, Config.Palette.VicePink)

PagePlayer:Toggle("360-Degree Parry Protection", not Config.Combat.FaceCheck, function(v)
    Config.Combat.FaceCheck = not v
end)

PagePlayer:Slider("Parry Trigger Distance", 8, 20, Config.Combat.ParryDistance, " STUDS", false, function(v)
    Config.Combat.ParryDistance = v
end)

PagePlayer:Button("MANUAL TEST PARRY (RIGHT CLICK)", false, function()
    ExecuteAutoParry("MANUAL_TEST")
end)

-- Player Speed Adjust
PagePlayer:Toggle("Player Fast Speed Boost", Config.Player.FastSpeed, function(v)
    Config.Player.FastSpeed = v
    if not v and LocalPlayer.Character then
        local human = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if human then human.WalkSpeed = 16 end
    end
end, C_CYAN)

PagePlayer:Slider("Player WalkSpeed", 16, 45, Config.Player.SpeedValue, " STUDS/S", false, function(v)
    Config.Player.SpeedValue = v
    if Config.Player.FastSpeed and ShouldApplyPlayerMods() and LocalPlayer.Character then
        local human = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if human then human.WalkSpeed = v end
    end
end)

-- Player No Stun
PagePlayer:Toggle("No Stun / Anti Stun (Player)", Config.Player.AntiStun, function(v)
    Config.Player.AntiStun = v
    if v and LocalPlayer.Character then
        CleanPlayerStunEffects(LocalPlayer.Character)
    end
end, C_CYAN)

PagePlayer:Button("INSTANT RECOVER / CLEAR STUN", false, function()
    if LocalPlayer.Character then
        CleanPlayerStunEffects(LocalPlayer.Character)
    end
end)

PagePlayer:Toggle("Enforce Player Role Only", Config.Player.OnlyWhenPlayer, function(v)
    Config.Player.OnlyWhenPlayer = v
    if v and IsLocalPlayerKiller() and LocalPlayer.Character then
        local human = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if human then human.WalkSpeed = 16 end
    end
end)

-- Combat Protocols
PageCombat:Toggle("Auto Parry Killer Attacks", Config.Combat.AutoParry, function(v) Config.Combat.AutoParry = v end, Config.Palette.VicePink)
PageCombat:Toggle("Facing Angle Verification", Config.Combat.FaceCheck, function(v) Config.Combat.FaceCheck = v end)
PageCombat:Slider("Parry Trigger Distance", 8, 20, Config.Combat.ParryDistance, " STUDS", false, function(v) Config.Combat.ParryDistance = v end)
PageCombat:Button("MANUAL TEST PARRY (RIGHT CLICK)", false, function()
    ExecuteAutoParry("MANUAL_TEST")
end)

-- Killer Protocols: KILLER ONLY (Anti Stun & Fast Speed)
CardKillerRole = PageKiller:Card("Killer Role Detection", "CHECKING ROLE...", C_PINK)

PageKiller:Toggle("Anti Stun (Pallet & Blind Immune)", Config.Killer.AntiStun, function(v)
    Config.Killer.AntiStun = v
    if v and LocalPlayer.Character then
        CleanStunEffects(LocalPlayer.Character)
    end
end, Config.Palette.VicePink)

PageKiller:Toggle("Fast Speed Boost", Config.Killer.FastSpeed, function(v)
    Config.Killer.FastSpeed = v
    if not v and LocalPlayer.Character then
        local human = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if human then human.WalkSpeed = 16 end
    end
end, Config.Palette.ViceCyan)

PageKiller:Slider("Killer Fast Speed", 18, 55, Config.Killer.SpeedValue, " STUDS/S", false, function(v)
    Config.Killer.SpeedValue = v
    if Config.Killer.FastSpeed and ShouldApplyKillerMods() and LocalPlayer.Character then
        local human = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if human then human.WalkSpeed = v end
    end
end)

PageKiller:Toggle("Enforce Killer Role Only", Config.Killer.OnlyWhenKiller, function(v)
    Config.Killer.OnlyWhenKiller = v
    if v and not IsLocalPlayerKiller() and LocalPlayer.Character then
        local human = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if human then human.WalkSpeed = 16 end
    end
end)

PageKiller:Button("INSTANT RECOVER / CLEAR ALL STUNS", false, function()
    if LocalPlayer.Character then
        CleanStunEffects(LocalPlayer.Character)
    end
end)

-- Automation Protocols: PERFECT FIX GEN (Zero adjustment needed, instant auto tap)
PageAuto:Toggle("Auto Fix Gen (Perfect Great)", Config.Automation.AutoGreatCheck, function(v)
    Config.Automation.AutoGreatCheck = v
end)
PageAuto:Toggle("Smart Zero-Adjust Engine", Config.Automation.SmartGreat, function(v)
    Config.Automation.SmartGreat = v
end)
PageAuto:Toggle("Auto Generator Repair Assist", Config.Automation.AutoRepair, function(v)
    Config.Automation.AutoRepair = v
end)

-- Manual Fine-Tuning Sliders (Optional override when Smart Zero-Adjust is disabled)
PageAuto:Slider("Click Delay Compensation", 0, 100, 0, " MS", true, function(ms)
    Config.Automation.ClickDelay = ms / 1000
end)
PageAuto:Slider("Great Hit Angle Start", 95, 115, Config.Automation.HitAngleStart, " DEG", false, function(v)
    Config.Automation.HitAngleStart = v
end)
PageAuto:Slider("Great Hit Angle End", 108, 128, Config.Automation.HitAngleEnd, " DEG", false, function(v)
    Config.Automation.HitAngleEnd = v
end)

-- Visuals Protocols: TAP-TO-TOGGLE BUTTONS FOR KILLER, PLAYER, GENERATOR, AND EXIT
local SetKillerToggle = PageESP:Toggle("ESP Killer", Config.Visuals.KillerESP, function(v)
    Config.Visuals.KillerESP = v
    if not v then
        if State.ActiveKiller and State.ActiveKiller.Character then
            local tag = State.ActiveKiller.Character:FindFirstChild("ESP_Tag", true)
            if tag then tag:Destroy() end
            RemoveHighlight(State.ActiveKiller.Character)
        end
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p == State.ActiveKiller and p.Character then
                local tag = p.Character:FindFirstChild("ESP_Tag", true)
                if tag then tag:Destroy() end
                RemoveHighlight(p.Character)
            end
        end
    end
end, Config.Palette.Killer)

local SetPlayerToggle = PageESP:Toggle("ESP Player", Config.Visuals.SurvivorESP, function(v)
    Config.Visuals.SurvivorESP = v
    if not v then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= LocalPlayer and p ~= State.ActiveKiller and p.Character then
                local tag = p.Character:FindFirstChild("ESP_Tag", true)
                if tag then tag:Destroy() end
                RemoveHighlight(p.Character)
            end
        end
    end
end, Config.Palette.Survivor)

PageESP:Toggle("ESP Generator", Config.Visuals.GeneratorESP, function(v)
    Config.Visuals.GeneratorESP = v
    if not v then
        for _, gen in ipairs(State.Generators) do
            local tag = gen:FindFirstChild("ESP_Tag", true)
            if tag then tag:Destroy() end
            RemoveHighlight(gen)
        end
    end
end, Config.Palette.Generator)

PageESP:Toggle("ESP Exit", Config.Visuals.GateESP, function(v)
    Config.Visuals.GateESP = v
    if not v then
        for _, g in ipairs(State.WorldObjects.Gates) do
            local tag = g:FindFirstChild("ESP_Tag", true)
            if tag then tag:Destroy() end
            RemoveHighlight(g)
        end
    end
end, Config.Palette.Gate)

PageESP:Toggle("Master Visuals", Config.Visuals.MasterESP, function(v)
    Config.Visuals.MasterESP = v
    if not v then
        for _, tag in ipairs(State.Billboards) do if tag then tag:Destroy() end end
        table.clear(State.Billboards)
        for obj, hl in pairs(State.Highlights) do if hl then hl:Destroy() end end
        table.clear(State.Highlights)
    end
end)

-- Dedicated Action Buttons for Instant One-Tap Toggling
PageESP:Button("TOGGLE ESP KILLER [ON / OFF]", false, function()
    SetKillerToggle(not Config.Visuals.KillerESP)
end)

PageESP:Button("TOGGLE ESP PLAYER [ON / OFF]", false, function()
    SetPlayerToggle(not Config.Visuals.SurvivorESP)
end)

PageESP:Toggle("Escape Hatch", Config.Visuals.HatchESP, function(v)
    Config.Visuals.HatchESP = v
    if not v then
        for _, obj in ipairs(State.WorldObjects.Hatches) do
            local tag = obj:FindFirstChild("ESP_Tag", true)
            if tag then tag:Destroy() end
            RemoveHighlight(obj)
        end
    end
end)

PageESP:Toggle("Display Range [Studs]", Config.Visuals.ShowDistance, function(v) Config.Visuals.ShowDistance = v end)

-- Threat Radar Protocols
PageThreat:Toggle("Proximity Danger Sensor", Config.Radar.Enabled, function(v) Config.Radar.Enabled = v end)
PageThreat:Toggle("Killer Line-Of-Sight Raycasting", Config.Radar.LineOfSight, function(v) Config.Radar.LineOfSight = v end)
PageThreat:Toggle("Screen Threat Meter HUD", Config.Radar.ThreatMeter, function(v) Config.Radar.ThreatMeter = v end)
PageThreat:Slider("Danger Radius", 40, 160, Config.Radar.Radius, " STUDS", false, function(v) Config.Radar.Radius = v end)

-- Environmental Protocols
PageWorld:Toggle("Fullbright Ambient Max", Config.Environment.Fullbright, function(v) Config.Environment.Fullbright = v end)
PageWorld:Toggle("Remove Atmospheric Fog", Config.Environment.RemoveFog, function(v) Config.Environment.RemoveFog = v end)
PageWorld:Slider("Camera Field of View", 70, 120, Config.Environment.FieldOfView, "", false, function(v)
    Config.Environment.FieldOfView = v
    Camera.FieldOfView = v
end)

-- Reality Intel Cards
CardRealKiller   = PageIntel:Card("Active Match Killer", "SEARCHING FOR TARGET...", C_PINK)
CardKillerStatus = PageIntel:Card("Killer Tactical Status", "ANALYZING TELEMETRY...", C_GREEN)
CardMask         = PageIntel:Card("Hotline Mask Loadout", "NONE", C_PURPLE)
CardGensLeft     = PageIntel:Card("Generator Objective Progress", "0 / 5 COMPLETE", C_CYAN)

-- Settings & Maintenance
PageSettings:Button("Force Re-index Map Objects", false, function()
    for _, b in pairs(State.Billboards) do if b then b:Destroy() end end
    table.clear(State.Billboards)
    table.clear(State.AnchorCache)
    IndexWorldObjects()
    ProcessWorldESP()
end)

PageSettings:Button("CLOSE & UNLOAD SCRIPT", true, UnloadScript)

--------------------------------------------------------------------------------
-- RUNTIME ENGINE
--------------------------------------------------------------------------------

local frameCount = 0
local lastFpsTick = tick()
local lastHeartbeat = 0
local lastDeepScan = 0

State.Connections.Render = Services.Run.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsTick >= 1 then
        State.FPS = frameCount
        frameCount = 0
        lastFpsTick = now
        pcall(function()
            State.Ping = math.floor(Services.Players.LocalPlayer:GetNetworkPing() * 1000)
        end)
        TelemetryLabel.Text = string.format("%d FPS  |  %d MS", State.FPS, State.Ping)
    end
end)

State.Connections.Heartbeat = Services.Run.Heartbeat:Connect(function()
    local now = tick()

    if Config.Environment.Fullbright then
        Services.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Services.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Services.Lighting.Brightness = 2
        Services.Lighting.ClockTime = 14
    end
    if Config.Environment.RemoveFog then
        Services.Lighting.GlobalShadows = false
        Services.Lighting.FogEnd = 1e5
    end

    -- Periodic Map Re-index: Throttled to 16 seconds (Prevents heavy lag spikes!)
    if now - lastDeepScan > 16 then
        lastDeepScan = now
        IndexWorldObjects()
        if CardGensLeft then
            CardGensLeft(string.format("%d / 5 COMPLETE", math.clamp(State.FinishedGens, 0, 5)))
        end
    end

    -- Throttled World Object ESP: Runs at ~8 Hz (every 0.12s) - Butter-smooth distance, zero lag!
    if now - State.LastWorldESP >= 0.12 then
        State.LastWorldESP = now
        ProcessWorldESP()
    end

    -- Killer Protocols: Anti Stun & Fast Speed Enforcement
    ProcessKillerProtocols()

    -- Player Protocols: Anti Stun & Fast Speed Enforcement (Survivor)
    ProcessPlayerProtocols()

    -- Real-time Entity Processing & Auto Parry: Runs at full Heartbeat rate!
    if now - lastHeartbeat >= 0.03 then
        lastHeartbeat = now
        ProcessEntities()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    InitializeSkillEngine()
    table.clear(State.BoundAnimators)
    table.clear(State.CombatBound)
    table.clear(State.Animators)
    table.clear(State.AnchorCache)
    BindLocalCharacterKillerMods(char)
    BindLocalCharacterPlayerMods(char)
end)

if LocalPlayer.Character then
    task.spawn(function()
        BindLocalCharacterKillerMods(LocalPlayer.Character)
        BindLocalCharacterPlayerMods(LocalPlayer.Character)
    end)
end

IndexWorldObjects()
InitializeSkillEngine()
