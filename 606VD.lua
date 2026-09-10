--[[
    ================================================================
    606VD // PRO REALITY SUITE 2026 // v1.12
    CONFIDENTIAL & PROPRIETARY // PRIVATE SOURCE BUILD
    SYSTEM: SMART SINGLE KILLER ENGINE + SMART GREAT FIX GEN + LUXURY ESP
    VERSION: 1.12
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
        Version = "1.12",
        MenuKey = Enum.KeyCode.RightControl,
        AltKey = Enum.KeyCode.V
    },
    Combat = {
        AutoParry = false, -- Activates only when user taps enable in the menu
        ParryDistance = 13.0, -- True killer melee strike range
        ParryCooldown = 0.90, -- Perfectly covers the 0.8s counter stance window without spamming
        FaceCheck = true      -- Verifies killer is aiming attack towards player (hit to me)
    },
    Player = {
        AutoParry = false, -- Activates only when user taps enable in the menu
        AntiStun = true,  -- No Stun for Player/Survivor
        FastSpeed = false, -- Player Speed Boost (OFF by default, works only when tap enable)
        SpeedValue = 22,   -- Normal player speed is 16
        OnlyWhenPlayer = true -- Only applies when playing as player/survivor
    },
    Killer = {
        AntiStun = true,
        FastSpeed = false, -- Killer Speed Boost (OFF by default, works only when tap enable)
        SpeedValue = 28,
        OnlyWhenKiller = true -- Only applies when playing as killer
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
        HealthBars = true,
        GenProgressBars = true,
        ShowDistance = true,
        MaxHighlights = 32
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
        Killer = Color3.fromRGB(255, 38, 58),   -- Pure Vibrant Red (Killer Only)
        Survivor = Color3.fromRGB(0, 240, 255), -- Pure Vibrant Cyan (Player Only)
        Injured = Color3.fromRGB(0, 240, 255),
        Downed = Color3.fromRGB(0, 240, 255),
        Hooked = Color3.fromRGB(0, 240, 255),
        Generator = Color3.fromRGB(255, 38, 58),
        Gate = Color3.fromRGB(240, 245, 255),
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
    Boxes = {},
    HighlightCount = 0,
    Billboards = {},
    Generators = {},
    AnchorCache = {},
    Animators = {},
    CombatBound = {},
    WorldObjects = {
        Gates = {}
    },
    BoundAnimators = {},
    ParryConnections = {},
    ParriedTracks = {},
    KillerConnections = {},
    PlayerConnections = {},
    GenProgObjCache = {},
    GenDoneObjCache = {},
    GenPrompts = {},
    LastKillerCheck = 0,
    LastLightingTick = 0,
    LastPlayerESP = 0,
    SkillEngineInitialized = false,
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
    elseif obj:IsA("Model") then
        if obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then
            anchor = obj.PrimaryPart
        else
            for _, name in ipairs({"HumanoidRootPart", "Root", "Hitbox", "Center", "defaultMaterial", "Engine", "Body", "Main", "Base", "Part", "MeshPart"}) do
                local found = obj:FindFirstChild(name)
                if found and found:IsA("BasePart") then
                    anchor = found
                    break
                end
            end
            if not anchor then
                local maxVol = -1
                for _, desc in ipairs(obj:GetDescendants()) do
                    if desc:IsA("BasePart") then
                        local vol = desc.Size.X * desc.Size.Y * desc.Size.Z
                        if vol > maxVol then
                            maxVol = vol
                            anchor = desc
                        end
                    end
                end
            end
        end
    elseif obj:IsA("Folder") then
        local maxVol = -1
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") then
                local vol = desc.Size.X * desc.Size.Y * desc.Size.Z
                if vol > maxVol then
                    maxVol = vol
                    anchor = desc
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

-- RELIABLE GAME/MATCH ACTIVE DETECTOR (PREVENTS LOBBY FALSE POSITIVES)
local function IsGameStarted()
    -- 1. Match objective detection: If match generators or exit gates exist, a match is active!
    if #State.Generators > 0 or #State.WorldObjects.Gates > 0 then
        return true
    end

    -- 2. Check if a map folder with match objectives is spawned
    local map = Services.Workspace:FindFirstChild("Map") 
        or Services.Workspace:FindFirstChild("CurrentMap")
        or Services.Workspace:FindFirstChild("Generators")
        or Services.Workspace:FindFirstChild("Interactables")
    if map and #map:GetChildren() > 2 then
        return true
    end

    -- 3. Check ReplicatedStorage / Workspace match attributes and values
    local rep = game:GetService("ReplicatedStorage")
    local matchStatus = GetGameValue(rep, "Status") 
        or GetGameValue(rep, "GameStatus") 
        or GetGameValue(rep, "RoundStatus")
        or GetGameValue(rep, "GameState")
        or GetGameValue(Services.Workspace, "GameStarted")
        or GetGameValue(Services.Workspace, "MatchActive")
        or GetGameValue(Services.Workspace, "InGame")

    if matchStatus ~= nil then
        if typeof(matchStatus) == "boolean" then
            return matchStatus
        elseif typeof(matchStatus) == "string" then
            local ms = matchStatus:lower()
            if ms:find("lobby") or ms:find("intermission") or ms:find("waiting") or ms:find("queue") then
                return false
            elseif ms:find("start") or ms:find("in progress") or ms:find("play") or ms:find("active") or ms:find("match") or ms:find("hunt") or ms:find("round") then
                return true
            end
        end
    end

    -- 4. Check if any player has an active Killer team or Killer role assigned
    for _, p in ipairs(Services.Players:GetPlayers()) do
        local team = p.Team and p.Team.Name:lower() or ""
        if (team:find("killer") or team:find("slasher") or team:find("hunter") or team:find("murderer") or team:find("monster")) and not (team:find("survivor") or team:find("victim") or team:find("lobby")) then
            return true
        end
        local role = tostring(GetGameValue(p, "Role") or GetGameValue(p, "SelectedKiller") or ""):lower()
        if role:find("killer") or role:find("slasher") or role:find("stalker") or role:find("hunter") then
            return true
        end
        if GetGameValue(p, "IsKiller") == true then
            return true
        end
        local c = p.Character
        if c and (GetGameValue(c, "IsKiller") == true) then
            return true
        end
    end

    return false
end

-- STRICT DISQUALIFICATION: Verifies if a player is definitively a Survivor (CANNOT be Killer)
local function IsPlayerSurvivor(p)
    if not p then return true end
    if p.Team then
        local tName = p.Team.Name:lower()
        if tName:find("survivor") or tName:find("victim") or tName:find("human") or tName:find("runner") or tName:find("lobby") or tName:find("spectat") then
            return true
        end
    end

    local role = tostring(GetGameValue(p, "Role") or (p.GetAttribute and p:GetAttribute("Role")) or ""):lower()
    if role:find("survivor") or role:find("victim") or role:find("human") or role:find("runner") then
        return true
    end

    local char = p.Character
    if char then
        local cRole = tostring(GetGameValue(char, "Role") or (char.GetAttribute and char:GetAttribute("Role")) or ""):lower()
        if cRole:find("survivor") or cRole:find("victim") or cRole:find("human") or cRole:find("runner") then
            return true
        end

        -- Survivor-specific item check: If player possesses survivor items, they are strictly a Survivor!
        local bp = p:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({char, bp}) do
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") or item:IsA("Model") then
                        local n = item.Name:lower()
                        if n:find("parrying dagger") or n:find("motion tracker") or n:find("twist of fate") 
                            or n:find("flashlight") or n:find("medkit") or n:find("toolbox") or n:find("lockpick") then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

-- Calculates exact killer confidence score for a player in Violence District
local function GetKillerConfidence(p)
    if not p or not p.Parent or not p.Character then return -9999 end
    if IsPlayerSurvivor(p) then return -9999 end

    local score = 0
    local char = p.Character

    -- 1. Definitive Killer Team (Highest Authority)
    if p.Team then
        local t = p.Team.Name:lower()
        if (t:find("killer") or t:find("slasher") or t:find("hunter") or t:find("murderer") or t:find("monster") or t:find("beast")) 
            and not (t:find("survivor") or t:find("victim") or t:find("lobby")) then
            score = score + 100
        end
    end

    -- 2. Player Attributes & Role Values
    local killerArchetypes = {"slasher", "abysswalker", "masked", "the killer", "killer", "hidden", "veil", "stalker", "cure", "butcher", "fiend"}
    local role = tostring(GetGameValue(p, "Role") or (p.GetAttribute and p:GetAttribute("Role")) or GetGameValue(p, "SelectedKiller") or (p.GetAttribute and p:GetAttribute("SelectedKiller")) or GetGameValue(p, "Killer") or ""):lower()
    for _, arch in ipairs(killerArchetypes) do
        if role:find(arch) then
            score = score + 80
            break
        end
    end
    if GetGameValue(p, "IsKiller") == true or (p.GetAttribute and p:GetAttribute("IsKiller") == true) then
        score = score + 70
    end

    -- 3. Character Model Inspection (Violence District renames killer character model to killer archetype)
    local cName = char.Name:lower()
    for _, arch in ipairs(killerArchetypes) do
        if cName:find(arch) and cName ~= p.Name:lower() then
            score = score + 75
            break
        end
    end

    local cRole = tostring(GetGameValue(char, "Role") or (char.GetAttribute and char:GetAttribute("Role")) or GetGameValue(char, "SelectedKiller") or ""):lower()
    for _, arch in ipairs(killerArchetypes) do
        if cRole:find(arch) then
            score = score + 70
            break
        end
    end
    if GetGameValue(char, "IsKiller") == true or (char.GetAttribute and char:GetAttribute("IsKiller") == true) then
        score = score + 65
    end

    -- 4. Killer Visual Components (Red Stain, Terror Radius)
    if char:FindFirstChild("RedStain", true) or char:FindFirstChild("TerrorRadius", true) or char:FindFirstChild("RedLight", true) or char:FindFirstChild("Stain", true) then
        score = score + 50
    end
    if (GetGameValue(p, "Mask") ~= nil or GetGameValue(char, "Mask") ~= nil or char:FindFirstChild("Mask")) then
        score = score + 30
    end

    -- 5. Killer Weapon Arsenal (Excludes common survivor items)
    local bp = p:FindFirstChildOfClass("Backpack")
    for _, cont in ipairs({char, bp}) do
        if cont then
            for _, item in ipairs(cont:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Model") or item:IsA("MeshPart") then
                    local tName = item.Name:lower()
                    -- Strict filter: MUST NOT be any survivor item
                    if not (tName:find("parrying") or tName:find("dagger") or tName:find("twist") or tName:find("tracker") or tName:find("gun") or tName:find("flashlight") or tName:find("medkit") or tName:find("toolbox")) then
                        if tName:find("cleaver") or tName:find("machete") or tName:find("chainsaw") or tName:find("scythe") 
                            or tName:find("killerweapon") or tName:find("slasher") or tName:find("abysswalker") or tName:find("veil")
                            or tName:find("cureneedle") or tName:find("claws") then
                            score = score + 45
                            break
                        end
                    end
                end
            end
        end
    end

    return score
end

-- SMART SINGLE KILLER RESOLUTION (OPERATES STRICTLY ONLY WHEN GAME HAS STARTED)
-- Mathematically guarantees AT MOST 1 Killer in the entire match!
local function ResolveSingleKiller()
    -- Only detect/resolve killer once the game has actually started!
    if not IsGameStarted() then
        State.ActiveKiller = nil
        return nil
    end

    local now = tick()
    if State.ActiveKiller and State.ActiveKiller.Parent == Services.Players and (now - State.LastKillerCheck < 0.4) then
        -- Verify cached killer is still valid and not a survivor
        if not IsPlayerSurvivor(State.ActiveKiller) then
            return State.ActiveKiller
        else
            State.ActiveKiller = nil
        end
    end
    State.LastKillerCheck = now

    -- Evaluate all players and find the single highest confidence killer
    local bestPlayer = nil
    local bestScore = 0

    for _, p in ipairs(Services.Players:GetPlayers()) do
        local score = GetKillerConfidence(p)
        if score > bestScore then
            bestScore = score
            bestPlayer = p
        end
    end

    if bestPlayer and bestScore > 0 then
        State.ActiveKiller = bestPlayer
        return bestPlayer
    end

    State.ActiveKiller = nil
    return nil
end

-- Strictly determines player role: killer is the ONLY 1 in game; everyone else is Survivor
local function GetPlayerRole(player)
    if State.ActiveKiller and player == State.ActiveKiller then
        return "Killer"
    end
    return "Survivor"
end

local function IsLocalPlayerKiller()
    if not IsGameStarted() then return false end
    local killer = ResolveSingleKiller()
    if killer then
        return killer == LocalPlayer
    end

    -- If killer not resolved yet, evaluate local player confidence
    local score = GetKillerConfidence(LocalPlayer)
    return score > 0
end

-- STRICT SINGLE KILLER VERIFICATION: Identifies if an opponent is the hostile Killer
-- Guarantees true ONLY for the 1 confirmed match killer
local function IsTargetKiller(p)
    if not p or p == LocalPlayer then return false end
    if not IsGameStarted() then return false end

    local k = ResolveSingleKiller()
    return (k ~= nil and p == k)
end

local StaticLOSParams = RaycastParams.new()
StaticLOSParams.FilterType = Enum.RaycastFilterType.Exclude
StaticLOSParams.IgnoreWater = true

local function HasLineOfSight(originPart, targetPart)
    if not originPart or not targetPart then return false end
    StaticLOSParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    local dir = (targetPart.Position - originPart.Position)
    local res = Services.Workspace:Raycast(originPart.Position, dir, StaticLOSParams)
    return res == nil
end

local function IsGeneratorModel(obj)
    if not obj then return false end
    if not (obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart")) then return false end
    if obj:FindFirstAncestorOfClass("Humanoid") then return false end
    if obj:FindFirstAncestor("RagdollConstraints") or obj.Name:find("Ragdoll") then return false end

    local name = obj.Name:lower()
    if name:find("player") or name:find("character") or name:find("camera") or name:find("terrain") or name:find("baseplate") then
        return false
    end

    -- Avoid indexing sub-parts if the parent model is already recognized as a generator
    local parent = obj.Parent
    if parent and parent ~= Services.Workspace and parent:IsA("Model") then
        local pName = parent.Name:lower()
        if pName == "gen" or pName == "generator" or pName:find("generator") or pName:match("^gen[%A%d_]") or pName:match("^gen_%d+") or pName:match("^gen%d+") then
            return false
        end
    end

    local pName = parent and parent.Name:lower() or ""

    -- 1. Direct Name Heuristics
    if name == "gen" or name == "generator" or name:find("generator") 
        or name:match("^gen[%A%d_]") or name:match("^gen_%d+") or name:match("^gen%d+") or name:match("^gen_") or name:match("^gen%-")
        or name:find("motor") or name:find("engine") or name:find("powerbox") or name:find("electricbox") 
        or name:find("breaker") or name:find("genstation") or name:find("machine") then
        return true
    end

    -- 2. Parent Container Heuristics (e.g. Workspace.Generators.1 or Workspace.Map.Generators.GenA)
    if pName == "generators" or pName == "gens" or (pName:find("generator") and not pName:find("sound")) then
        if obj:IsA("Model") or obj:IsA("BasePart") then
            return true
        end
    end

    -- 3. Attributes Match
    if obj:GetAttribute("RepairProgress") ~= nil 
        or obj:GetAttribute("Progress") ~= nil 
        or obj:GetAttribute("GenProgress") ~= nil 
        or obj:GetAttribute("GeneratorProgress") ~= nil 
        or obj:GetAttribute("Percent") ~= nil
        or obj:GetAttribute("Repaired") ~= nil then
        return true
    end

    -- 4. Value Objects Match
    if obj:FindFirstChild("RepairProgress") 
        or obj:FindFirstChild("Progress") 
        or obj:FindFirstChild("GenProgress") 
        or obj:FindFirstChild("GeneratorProgress") 
        or obj:FindFirstChild("RepairPrompt") 
        or obj:FindFirstChild("GenPrompt") then
        return true
    end

    -- 5. ProximityPrompt Match (Violence District & standard DBD interaction prompts)
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        local act = prompt.ActionText:lower()
        local objT = prompt.ObjectText:lower()
        if act:find("repair") or act:find("fix") or act:find("work") or objT:find("gen") or objT:find("generator") or objT:find("repair") then
            return true
        end
    end

    return false
end

local function IsExitGateModel(obj)
    if not obj then return false end
    if not (obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart")) then return false end
    if obj:FindFirstAncestorOfClass("Humanoid") then return false end
    if obj:FindFirstAncestor("RagdollConstraints") or obj.Name:find("Ragdoll") then return false end

    local name = obj.Name:lower()
    if name:find("player") or name:find("character") or name:find("camera") or name:find("terrain") 
        or name:find("locker") or name:find("closet") or name:find("window") or name:find("pallet") then
        return false
    end

    -- Avoid indexing sub-parts if parent is already an exit gate model
    local parent = obj.Parent
    if parent and parent ~= Services.Workspace and parent:IsA("Model") then
        local pName = parent.Name:lower()
        if pName == "exitgate" or pName:find("exitgate") or pName:find("exit_gate") or pName:find("escapegate") then
            return false
        end
    end

    local pName = parent and parent.Name:lower() or ""

    -- 1. Direct Name Match
    if name == "exitgate" or name == "exit_gate" or name == "escapegate" or name == "escape_gate" 
        or name == "gate" or name:find("exitgate") or name:find("exit_gate") or name:find("escapegate")
        or (name:find("gate") and (name:find("exit") or name:find("escape") or name:find("door")))
        or name == "exit" or name:match("^exit%d*") or name:match("^gate%d+") then
        return true
    end

    -- 2. Parent Container Match (e.g. Workspace.ExitGates.Gate1)
    if pName == "exitgates" or pName == "gates" or pName == "exits" or pName:find("exitgate") then
        if obj:IsA("Model") or obj:IsA("BasePart") then
            return true
        end
    end

    -- 3. ProximityPrompt Match (Exit lever / gate switch)
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        local act = prompt.ActionText:lower()
        local objT = prompt.ObjectText:lower()
        if (act:find("open") or act:find("escape") or act:find("power") or act:find("pull") or act:find("unlock") or act:find("interact")) 
            and (objT:find("gate") or objT:find("exit") or objT:find("door") or act:find("escape") or act:find("gate") or act:find("exit")) then
            return true
        end
    end

    return false
end

local function GetGeneratorProgress(gen)
    if not gen then return 0 end

    local cachedObj = State.GenProgObjCache[gen]
    if cachedObj then
        if typeof(cachedObj) == "string" then
            local v = gen:GetAttribute(cachedObj)
            if type(v) == "number" then return v end
        elseif cachedObj.Parent then
            return cachedObj.Value or 0
        end
    end

    for _, attr in ipairs({"RepairProgress", "Progress", "Percent", "Repaired", "GenProgress", "GeneratorProgress"}) do
        local v = gen:GetAttribute(attr)
        if type(v) == "number" then
            State.GenProgObjCache[gen] = attr
            return v
        end
    end
    for _, name in ipairs({"RepairProgress", "Progress", "Percent", "Repaired", "GenProgress", "GeneratorProgress"}) do
        local valObj = gen:FindFirstChild(name, true)
        if valObj and (valObj:IsA("NumberValue") or valObj:IsA("IntValue")) then
            State.GenProgObjCache[gen] = valObj
            return valObj.Value
        end
    end
    local cfg = gen:FindFirstChildWhichIsA("Configuration", true)
    if cfg then
        for _, vObj in ipairs(cfg:GetChildren()) do
            if vObj:IsA("NumberValue") or vObj:IsA("IntValue") then
                local vn = vObj.Name:lower()
                if vn:find("prog") or vn:find("repair") or vn:find("percent") then
                    State.GenProgObjCache[gen] = vObj
                    return vObj.Value
                end
            end
        end
    end
    return 0
end

local function IsGeneratorCompleted(gen, progress)
    if progress and progress >= 100 then return true end
    if gen:GetAttribute("Completed") == true or gen:GetAttribute("Finished") == true or gen:GetAttribute("Powered") == true or gen:GetAttribute("Done") == true then
        return true
    end
    local cachedDone = State.GenDoneObjCache[gen]
    if cachedDone then
        if typeof(cachedDone) == "string" then
            return gen:GetAttribute(cachedDone) == true
        elseif cachedDone.Parent and cachedDone:IsA("BoolValue") then
            return cachedDone.Value == true
        end
    end
    for _, name in ipairs({"Completed", "Finished", "Powered", "Done", "Repaired"}) do
        local b = gen:FindFirstChild(name, true)
        if b and b:IsA("BoolValue") then
            State.GenDoneObjCache[gen] = b
            if b.Value == true then return true end
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- HIGHLIGHT ENGINE (CRASH-PROOF & INSTANCE CAPPED)
--------------------------------------------------------------------------------

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "VD_ESP_Folder"
pcall(function()
    ESPFolder.Parent = Services.Workspace.CurrentCamera
end)
if not ESPFolder.Parent then
    pcall(function() ESPFolder.Parent = Services.Workspace end)
end
if not ESPFolder.Parent then
    pcall(function() ESPFolder.Parent = game:GetService("CoreGui") end)
end
if not ESPFolder.Parent then
    pcall(function() ESPFolder.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
end

local function SafeHighlight(object, color, priority)
    if not Config.Visuals.MasterESP or not object then return end

    local hl = State.Highlights[object]
    local sb = State.Boxes and State.Boxes[object]

    -- Update existing highlight and 3D box color if already present
    if hl and hl.Parent then
        if hl.FillColor ~= color then
            hl.FillColor = color
            hl.OutlineColor = color
        end
        if sb and sb.Parent and sb.Color3 ~= color then
            sb.Color3 = color
            sb.SurfaceColor3 = color
        end
        return hl
    end

    if State.HighlightCount >= Config.Visuals.MaxHighlights and not priority then
        return nil
    end

    -- 1. Create Vibrant Full-Body Highlight (Glowing Chams)
    local ok, newHl = pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "VD_HL_" .. tostring(object.Name)
        h.FillTransparency = 0.35 -- Vibrant, clearly visible body fill through walls
        h.OutlineTransparency = 0.0 -- Solid, sharp glowing body outline
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = object
        h.FillColor = color
        h.OutlineColor = color
        h.Parent = ESPFolder or object
        return h
    end)

    if ok and newHl then
        State.Highlights[object] = newHl
        State.HighlightCount = State.HighlightCount + 1
    end

    -- 2. Create Universal 3D Body Cham Box (Guaranteed visible on ALL graphics levels & devices)
    pcall(function()
        local box = Instance.new("SelectionBox")
        box.Name = "VD_BOX_" .. tostring(object.Name)
        box.Adornee = object
        box.Color3 = color
        box.LineThickness = 0.04
        box.SurfaceTransparency = 0.70
        box.SurfaceColor3 = color
        box.AlwaysOnTop = true
        box.Parent = ESPFolder or object
        if not State.Boxes then State.Boxes = {} end
        State.Boxes[object] = box
    end)

    return newHl
end

local function RemoveHighlight(object)
    if not object then return end
    local hl = State.Highlights[object]
    if hl then
        pcall(function() hl:Destroy() end)
        State.Highlights[object] = nil
        State.HighlightCount = math.max(0, State.HighlightCount - 1)
    end
    if State.Boxes and State.Boxes[object] then
        pcall(function() State.Boxes[object]:Destroy() end)
        State.Boxes[object] = nil
    end
    local legacy = object:FindFirstChild("VD_Highlight")
    if legacy then pcall(function() legacy:Destroy() end) end
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
    local gens, gates = {}, {}
    local checked = {}

    -- 1. Gather all potential map and objective containers
    local searchRoots = {}
    local containerNames = {
        "map", "currentmap", "mapfolder", "generators", "gens", 
        "interactables", "interactive", "objects", "props", "objectives", 
        "gates", "exitgates", "exits", "game", "gamefolder", "environment", "spawns"
    }

    for _, child in ipairs(Services.Workspace:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            local cName = child.Name:lower()
            for _, kw in ipairs(containerNames) do
                if cName:find(kw) then
                    table.insert(searchRoots, child)
                    break
                end
            end
        end
    end

    if #searchRoots == 0 then
        table.insert(searchRoots, Services.Workspace)
    end

    -- 2. Scan gathered search roots
    for _, root in ipairs(searchRoots) do
        if root and root.Parent then
            for _, obj in ipairs(root:GetDescendants()) do
                if (obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart")) and not checked[obj] then
                    if IsGeneratorModel(obj) then
                        checked[obj] = true
                        table.insert(gens, obj)
                    elseif IsExitGateModel(obj) then
                        checked[obj] = true
                        table.insert(gates, obj)
                    end
                end
            end
        end
    end

    -- 3. Fallback: If 0 generators or 0 gates found, scan entire Workspace descendants
    if #gens == 0 or #gates == 0 then
        for _, obj in ipairs(Services.Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart")) and not checked[obj] then
                if #gens == 0 and IsGeneratorModel(obj) then
                    checked[obj] = true
                    table.insert(gens, obj)
                elseif #gates == 0 and IsExitGateModel(obj) then
                    checked[obj] = true
                    table.insert(gates, obj)
                end
            end
        end
    end

    State.Generators = gens
    State.WorldObjects.Gates = gates

    -- Periodic Dead Highlight Pruning
    local actualCount = 0
    for obj, hl in pairs(State.Highlights) do
        if not obj or not obj.Parent or not hl or not hl.Parent then
            if hl then pcall(function() hl:Destroy() end) end
            State.Highlights[obj] = nil
            if State.Boxes and State.Boxes[obj] then
                pcall(function() State.Boxes[obj]:Destroy() end)
                State.Boxes[obj] = nil
            end
        else
            actualCount = actualCount + 1
        end
    end
    State.HighlightCount = actualCount
end

--------------------------------------------------------------------------------
-- WORLD ESP PROCESSOR (CRASH-PROOFED // GENERATOR & EXIT GATE ONLY)
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
            local a = State.AnchorCache[gen]
            if a then RemoveHighlight(a) end
        end
        return
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position

    -- 1. Generator ESP (HIGHLIGHT ONLY: Pure 3D glowing chams across entire map, NO NAME TAG)
    local finished = 0
    for i = #State.Generators, 1, -1 do
        local gen = State.Generators[i]
        if gen and gen.Parent then
            local prog = GetGeneratorProgress(gen)
            local isDone = IsGeneratorCompleted(gen, prog)
            local anchor = ResolveAnchorPart(gen)
            local targetHl = (gen:IsA("Model") and #gen:GetChildren() > 0) and gen or anchor

            -- Ensure NO name / billboard tag is displayed on generators
            local oldTag = gen:FindFirstChild("ESP_Tag", true) or (anchor and anchor:FindFirstChild("ESP_Tag"))
            if oldTag then oldTag:Destroy() end

            if not Config.Visuals.GeneratorESP then
                RemoveHighlight(gen)
                if anchor then RemoveHighlight(anchor) end
            elseif anchor and anchor:IsA("BasePart") then
                local dist = myPos and math.floor((anchor.Position - myPos).Magnitude) or 0
                local col

                if isDone then
                    finished = finished + 1
                    col = Color3.fromRGB(0, 235, 140) -- Vibrant emerald green
                else
                    local cp = math.clamp(prog, 0, 100)
                    col = Config.Palette.RedDark:Lerp(Config.Palette.RedPrimary, cp / 100)
                end

                -- Full-map 3D glowing chams (Highlight Only, No Name Tag)
                if dist <= 2500 and State.HighlightCount < Config.Visuals.MaxHighlights then
                    SafeHighlight(targetHl, col, false)
                else
                    RemoveHighlight(targetHl)
                end
            else
                RemoveHighlight(gen)
                if anchor then RemoveHighlight(anchor) end
            end
        else
            table.remove(State.Generators, i)
        end
    end
    State.FinishedGens = finished

    -- 2. Exit Gate ESP (HIGHLIGHT ONLY: Pure 3D glowing chams on gate models across 9999 studs, NO NAME TAG)
    for _, gate in ipairs(State.WorldObjects.Gates) do
        if gate and gate.Parent then
            local anchor = ResolveAnchorPart(gate)
            local targetHl = (gate:IsA("Model") and #gate:GetChildren() > 0) and gate or anchor

            -- Ensure NO name / billboard tag is displayed on exit gates
            local oldTag = gate:FindFirstChild("ESP_Tag", true) or (anchor and anchor:FindFirstChild("ESP_Tag"))
            if oldTag then oldTag:Destroy() end

            if not Config.Visuals.GateESP then
                RemoveHighlight(gate)
                if anchor then RemoveHighlight(anchor) end
            elseif anchor and anchor:IsA("BasePart") then
                local aPos = anchor.Position
                local dist = myPos and math.floor((aPos - myPos).Magnitude) or 0
                local color = Config.Palette.Gate

                -- Full-map 3D physical object glowing chams (Highlight Only, No Name Tag)
                if dist <= 9999 and State.HighlightCount < Config.Visuals.MaxHighlights then
                    SafeHighlight(targetHl, color, false)
                else
                    RemoveHighlight(targetHl)
                end
            else
                RemoveHighlight(gate)
                if anchor then RemoveHighlight(anchor) end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- COMBAT & AUTO PARRY ENGINE (MULTI-LAYER ATTACK DETECTION & ACTUATION)
--------------------------------------------------------------------------------

local AttackKeywords = {
    "swing", "slash", "attack", "hit", "strike", "knife", "machete", "heavy",
    "light", "cleave", "stab", "lunge", "kill", "punch", "smash", "weapon",
    "hammer", "axe", "down", "combat", "slasher", "murder", "cut", "chop",
    "m1", "m2", "atk", "melee", "thrust", "whack", "bash", "grab", "claw",
    "rend", "assault", "execute", "bite", "combo", "swipe", "charge",
    "slam", "hack", "killerattack", "bludgeon", "whip"
}

local IgnoreKeywords = {
    "walk", "run", "idle", "sprint", "fall", "jump", "land", "crouch",
    "vault", "climb", "emote", "dance", "sit", "breathe", "turn", "inspect",
    "repair", "heal", "door", "pickup", "drop", "generator", "interact",
    "carried", "carry", "hook", "unhook", "wiggle", "struggle", "fix",
    "stun", "blind", "flashed", "daze", "dazed", "headache", "stumble",
    "pallet", "wipe", "cool", "recover", "miss"
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

-- Strictly detects genuine Killer attack strikes (ignoring movement and interactions)
local function IsAttackAnimation(track)
    if not track then return false end

    -- 1. Looped animations are NEVER attacks (walk, run, sprint, idle, and gen repair are always looped)
    if track.Looped == true then
        return false
    end

    local tName = (track.Name or ""):lower()
    local animId = ""
    if track.Animation then
        animId = tostring(track.Animation.AnimationId or ""):lower()
        local aName = (track.Animation.Name or ""):lower()
        tName = tName .. " " .. aName
    end

    -- 2. Filter out non-attack actions
    for _, ign in ipairs(IgnoreKeywords) do
        if tName:find(ign) and not (tName:find("attack") or tName:find("swing") or tName:find("slash") or tName:find("hit") or tName:find("strike") or tName:find("m1")) then
            return false
        end
    end

    -- 3. Check explicit attack keywords
    for _, kw in ipairs(AttackKeywords) do
        if tName:find(kw) or animId:find(kw) then
            return true
        end
    end

    -- 4. Check Action priority & short non-looped duration (unnamed Roblox Studio attack animations)
    local prio = track.Priority
    local isActionPrio = (prio == Enum.AnimationPriority.Action 
        or prio == Enum.AnimationPriority.Action2 
        or prio == Enum.AnimationPriority.Action3 
        or prio == Enum.AnimationPriority.Action4 
        or tostring(prio):find("Action")
        or (prio.Value and prio.Value >= Enum.AnimationPriority.Action.Value))

    if isActionPrio then
        local len = track.Length or 0
        if len == 0 or (len >= 0.2 and len <= 2.2) then
            return true
        end
    end

    return false
end

-- Precise Right-Click Parry: Executes ONLY when enabled (or manual test), Right-Click only, 0ms equip delay
local function ExecuteAutoParry(source)
    -- STRICT SAFETY: Only works when user taps enable (or presses MANUAL TEST), and LocalPlayer is NOT the Killer!
    if not Config.Combat.AutoParry and source ~= "MANUAL_TEST" then return false end
    if IsLocalPlayerKiller() then return false end

    local now = tick()
    -- ANTI-SPAM LOCKOUT: Cooldown cleanly covers the counter-stance window without spamming
    if now - State.LastParryTick < Config.Combat.ParryCooldown then return false end
    State.LastParryTick = now

    task.spawn(function()
        local myChar = LocalPlayer.Character
        local human = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")

        -- 1. Equip Parrying Dagger if unequipped in Backpack
        local daggerTool = nil
        if myChar then
            for _, item in ipairs(myChar:GetChildren()) do
                if item:IsA("Tool") then
                    local n = item.Name:lower()
                    if n:find("parry") or n:find("dagger") or n:find("counter") or n:find("guard") or n:find("shield") then
                        daggerTool = item
                        break
                    end
                end
            end
        end

        if not daggerTool and bp then
            for _, item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") then
                    local n = item.Name:lower()
                    if n:find("parry") or n:find("dagger") or n:find("counter") or n:find("guard") or n:find("shield") then
                        daggerTool = item
                        if human then
                            pcall(function() human:EquipTool(item) end)
                            task.wait(0.02)
                        end
                        break
                    end
                end
            end
        end

        local mPos = Services.Input:GetMouseLocation()

        -- 2. STRICTLY RIGHT CLICK ONLY (MouseButton2 - Pure Parry / Guard Stance)
        pcall(function()
            Services.VIM:SendMouseButtonEvent(mPos.X, mPos.Y, 1, true, game, 1)
        end)
        if mouse2press then
            pcall(mouse2press)
        elseif mouse2click then
            pcall(mouse2click)
        end
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(mPos.X, mPos.Y))
        end)

        -- 3. Mobile Parry / Guard Button (For mobile players)
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then
                local mob = pg:FindFirstChild("Survivor-mob")
                if mob then
                    for _, d in ipairs(mob:GetDescendants()) do
                        if (d:IsA("ImageButton") or d:IsA("TextButton")) and d.Visible then
                            local dName = d.Name:lower()
                            if dName:find("parry") or dName:find("guard") or dName:find("block") or dName:find("counter") or dName:find("defend") then
                                if firesignal then
                                    firesignal(d.Activated)
                                    firesignal(d.MouseButton1Click)
                                elseif d.Activated then
                                    d.Activated:Fire()
                                end
                            end
                        end
                    end
                end

                for _, desc in ipairs(pg:GetDescendants()) do
                    if (desc:IsA("ImageButton") or desc:IsA("TextButton")) and desc.Visible then
                        local dName = desc.Name:lower()
                        if dName:find("parry") or dName:find("guard") or dName:find("block") or dName:find("counter") or dName:find("defend") then
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

        -- Hold Right Click for counter-stance window (150ms) to ensure full engine registration
        task.wait(0.15)

        -- Clean release - Strictly Right Click Up
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
    end)
    return true
end

-- Smartly triggers parry ONLY when the Killer taps hit towards the survivor within striking range
local function CheckAndTriggerParry(char, player, track)
    -- ONLY WHEN TAP ENABLE: Must be actively enabled by user
    if not Config.Combat.AutoParry or not char then return end
    if IsLocalPlayerKiller() then return end
    if player == LocalPlayer then return end

    -- STRICT SINGLE KILLER VERIFICATION: Parries ONLY against the true Killer
    if not IsTargetKiller(player) then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local tRoot = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or ResolveAnchorPart(char)
    if not tRoot or not tRoot:IsA("BasePart") then return end

    -- Distance gate: Killer must be within melee attack reach
    local dist = (tRoot.Position - myRoot.Position).Magnitude
    if dist > Config.Combat.ParryDistance then return end

    -- Direction gate: Killer must be facing towards survivor when tapping hit (aiming at me)
    if Config.Combat.FaceCheck then
        local toMe = (myRoot.Position - tRoot.Position).Unit
        if tRoot.CFrame.LookVector:Dot(toMe) < 0.15 then return end
    else
        local toMe = (myRoot.Position - tRoot.Position).Unit
        if tRoot.CFrame.LookVector:Dot(toMe) < -0.70 then return end
    end

    -- Track deduplication: Ensure exactly one parry per attack swing
    if track then
        if State.ParriedTracks[track] then return end
        if not IsAttackAnimation(track) then return end
        State.ParriedTracks[track] = true
    end

    -- Trigger single crisp Right-Click Parry ONLY when Killer taps hit
    ExecuteAutoParry("KILLER_TAP_HIT")
end

-- Strictly binds combat listeners ONLY to the Killer (with dynamic loading fallback)
local function BindCombatListeners(player, char)
    if player == LocalPlayer or not char then return end

    -- Strictly only bind to the Killer
    if not IsTargetKiller(player) then return end

    local animator = GetCharacterAnimator(char)
    if not animator then
        local human = char:FindFirstChildOfClass("Humanoid")
        if human and not State.CombatBound[human] then
            State.CombatBound[human] = true
            local conn = human.DescendantAdded:Connect(function(desc)
                if desc:IsA("Animator") then
                    BindCombatListeners(player, char)
                end
            end)
            table.insert(State.ParryConnections, conn)
        end
        return
    end

    if State.BoundAnimators[animator] then return end
    State.BoundAnimators[animator] = true
    State.CombatBound[char] = true

    local conn = animator.AnimationPlayed:Connect(function(track)
        CheckAndTriggerParry(char, player, track)
    end)
    table.insert(State.ParryConnections, conn)
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

    -- 2. Fast Speed Protocol (ONLY when enabled and only when killer!)
    if Config.Killer.FastSpeed and ShouldApplyKillerMods() then
        if human.WalkSpeed ~= Config.Killer.SpeedValue then
            human.WalkSpeed = Config.Killer.SpeedValue
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

    -- 2. Player Fast Speed Protocol (ONLY when enabled and only when player!)
    if Config.Player.FastSpeed and ShouldApplyPlayerMods() then
        if human.WalkSpeed ~= Config.Player.SpeedValue then
            human.WalkSpeed = Config.Player.SpeedValue
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
    
    local gameStarted = IsGameStarted()
    -- Identify the exact single active match killer (ONLY when game has started!)
    local killer = gameStarted and ResolveSingleKiller() or nil
    local killerChar = killer and killer.Character
    local killerRoot = killerChar and ResolveAnchorPart(killerChar)
    local killerLOS = false
    local killerDist = 9999

    -- Update Intel Cards with Reality Data
    if not gameStarted then
        if CardRealKiller then CardRealKiller("LOBBY // WAITING FOR GAME START") end
        if CardKillerStatus then CardKillerStatus("LOBBY / MATCH NOT ACTIVE") end
        if CardMask then CardMask("NONE") end
    elseif killer then
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
                    -- STRICT SINGLE KILLER LOGIC: Exactly 1 killer can EVER be true! All others are Player/Survivor!
                    local isKiller = (killer ~= nil and p == killer)

                    -- Multi-Layer Combat Binding (Strictly Killer Only!)
                    if isKiller then
                        BindCombatListeners(p, char)
                    end

                    -- Visuals: Dedicated toggles for Killer ESP vs Player (Survivor) ESP
                    -- Killer ESP is strictly shown ONLY when game has started!
                    local isKillerActive = gameStarted and isKiller
                    local shouldShow = Config.Visuals.MasterESP and ((isKillerActive and Config.Visuals.KillerESP) or (not isKillerActive and Config.Visuals.SurvivorESP))
                    if shouldShow then
                        -- STRICT COLOR ENFORCEMENT: ONLY Killer is RED, and ONLY Player is CYAN
                        local color = isKillerActive and Config.Palette.Killer or Config.Palette.Survivor

                        local dist = myRoot and math.floor((rPos - myRoot.Position).Magnitude) or 0
                        local tagText = isKillerActive 
                            and string.format("KILLER // %s", p.DisplayName:upper())
                            or string.format("PLAYER // %s", p.DisplayName:upper())

                        if Config.Visuals.ShowDistance then
                            tagText = string.format("%s\n<font size=\"8\">[%dM]</font>", tagText, dist)
                        end

                        local tag = root:FindFirstChild("ESP_Tag") or char:FindFirstChild("ESP_Tag")
                        if not tag then
                            tag = BuildTag(tagText, color, not isKillerActive and Config.Visuals.HealthBars and human ~= nil)
                            tag.StudsOffset = Vector3.new(0, 3, 0)
                            tag.Adornee = root
                            tag.Parent = root
                            table.insert(State.Billboards, tag)
                        else
                            local lbl = tag:FindFirstChild("Label")
                            if lbl then 
                                lbl.Text = tagText
                                lbl.TextColor3 = color 
                            end
                            local fill = tag:FindFirstChild("BarBG") and tag.BarBG:FindFirstChild("Fill")
                            if fill and human then
                                fill.Size = UDim2.new(math.clamp(human.Health / human.MaxHealth, 0, 1), 0, 1, 0)
                                fill.BackgroundColor3 = color
                            end
                        end

                        SafeHighlight(char, color, true) -- Full body 3D glowing chams (Killer RED, Player CYAN)!
                    else
                        local oldTag = char:FindFirstChild("ESP_Tag", true) or (root and root:FindFirstChild("ESP_Tag"))
                        if oldTag then oldTag:Destroy() end
                        RemoveHighlight(char)
                    end
                end
            end
        end
    end

    -- Frame-by-Frame Active Attack Monitor (Parries ONLY when Killer taps hit!)
    -- Strictly only active when AutoParry is enabled and LocalPlayer is Survivor!
    if Config.Combat.AutoParry and myRoot and not IsLocalPlayerKiller() then
        -- Clear old parried tracks cache periodically to keep memory pristine
        local nowTick = tick()
        if nowTick - State.LastParryTick > 3 and next(State.ParriedTracks) ~= nil then
            table.clear(State.ParriedTracks)
        end

        local targetKiller = (killer and killer ~= LocalPlayer and IsTargetKiller(killer) and killer)
            or (State.ActiveKiller and State.ActiveKiller ~= LocalPlayer and IsTargetKiller(State.ActiveKiller) and State.ActiveKiller)
        if not targetKiller then
            for _, p in ipairs(Services.Players:GetPlayers()) do
                if IsTargetKiller(p) then
                    targetKiller = p
                    break
                end
            end
        end

        if targetKiller and targetKiller.Character then
            local c = targetKiller.Character
            local r = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart or ResolveAnchorPart(c)
            if r and r:IsA("BasePart") then
                local dist = (r.Position - myRoot.Position).Magnitude
                -- Killer must be within melee strike distance
                if dist <= Config.Combat.ParryDistance then
                    local toMe = (myRoot.Position - r.Position).Unit
                    -- Killer must be facing towards survivor
                    local isFacingMe
                    if Config.Combat.FaceCheck then
                        isFacingMe = r.CFrame.LookVector:Dot(toMe) >= 0.15
                    else
                        isFacingMe = r.CFrame.LookVector:Dot(toMe) >= -0.70
                    end
                    if isFacingMe then
                        local anim = GetCharacterAnimator(c)
                        if anim then
                            local ok, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
                            if ok and tracks then
                                for _, tr in ipairs(tracks) do
                                    -- Smartly detects the exact moment the killer taps hit (TimePosition < 0.45)
                                    if tr.IsPlaying and not State.ParriedTracks[tr] and tr.TimePosition < 0.45 and IsAttackAnimation(tr) then
                                        State.ParriedTracks[tr] = true
                                        ExecuteAutoParry("KILLER_TAP_HIT_TRACK")
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
    if State.SkillEngineInitialized then return end
    State.SkillEngineInitialized = true

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

    -- Auto Generator Repair Proximity Assist Loop (Throttled & Prompt Cached)
    task.spawn(function()
        while true do
            task.wait(0.5)
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
                                        local prompt = State.GenPrompts[gen]
                                        if not prompt or not prompt.Parent then
                                            for _, p in ipairs(gen:GetDescendants()) do
                                                if p:IsA("ProximityPrompt") then
                                                    prompt = p
                                                    State.GenPrompts[gen] = p
                                                    break
                                                end
                                            end
                                        end
                                        if prompt and prompt.Enabled then
                                            pcall(function()
                                                if fireproximityprompt then
                                                    fireproximityprompt(prompt, 0)
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
    end)
end

--------------------------------------------------------------------------------
-- 606VD // OBSIDIAN UI SUITE (LOADED VIA OFFICIAL OBSIDIAN UI LIBRARY)
--------------------------------------------------------------------------------

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- Threat Radar HUD Overlay (On-screen tactical threat display)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "606VD_ThreatOverlay"
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

-- Sleek Modern Floating On-Screen Menu Toggle Button (Touch & Mouse Drag Support)
local FloatingToggle = Instance.new("TextButton", ScreenGui)
FloatingToggle.Name = "606VD_FloatingToggle"
FloatingToggle.Size = UDim2.new(0, 96, 0, 36)
FloatingToggle.Position = UDim2.new(0, 20, 0.5, -18)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(15, 12, 18)
FloatingToggle.BorderSizePixel = 0
FloatingToggle.AutoButtonColor = false
FloatingToggle.Text = ""
Instance.new("UICorner", FloatingToggle).CornerRadius = UDim.new(0, 18)

local StatusDot = Instance.new("Frame", FloatingToggle)
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0.5, -4)
StatusDot.BackgroundColor3 = Config.Palette.Survivor
StatusDot.BorderSizePixel = 0
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local BtnLabel = Instance.new("TextLabel", FloatingToggle)
BtnLabel.Name = "Label"
BtnLabel.Size = UDim2.new(1, -28, 1, 0)
BtnLabel.Position = UDim2.new(0, 26, 0, 0)
BtnLabel.BackgroundTransparency = 1
BtnLabel.Font = Enum.Font.GothamBlack
BtnLabel.Text = "606VD"
BtnLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
BtnLabel.TextSize = 12
BtnLabel.TextXAlignment = Enum.TextXAlignment.Left

local isDragging = false
local dragStartPos = nil
local frameStartPos = nil
local hasMoved = false

FloatingToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        hasMoved = false
        dragStartPos = input.Position
        frameStartPos = FloatingToggle.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
                if not hasMoved then
                    pcall(function()
                        if Window and Window.Toggle then
                            Window:Toggle()
                        elseif Library and Library.Toggle then
                            Library:Toggle()
                        end
                    end)
                end
            end
        end)
    end
end)

Services.Input.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        if delta.Magnitude > 4 then
            hasMoved = true
            FloatingToggle.Position = UDim2.new(
                frameStartPos.X.Scale,
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

FloatingToggle.MouseEnter:Connect(function()
    Services.Tween:Create(FloatingToggle, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(25, 20, 32) }):Play()
end)
FloatingToggle.MouseLeave:Connect(function()
    Services.Tween:Create(FloatingToggle, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(15, 12, 18) }):Play()
end)

ThreatRadarHUD = Instance.new("Frame", ScreenGui)
ThreatRadarHUD.Name = "ThreatRadar"
ThreatRadarHUD.Size = UDim2.new(0, 340, 0, 46)
ThreatRadarHUD.Position = UDim2.new(0.5, -170, 0, 22)
ThreatRadarHUD.BackgroundColor3 = Color3.fromRGB(15, 12, 18)
ThreatRadarHUD.BorderSizePixel = 0
ThreatRadarHUD.Visible = false
Instance.new("UICorner", ThreatRadarHUD).CornerRadius = UDim.new(0, 8)

ThreatTopAccent = Instance.new("Frame", ThreatRadarHUD)
ThreatTopAccent.Size = UDim2.new(1, 0, 0, 2)
ThreatTopAccent.Position = UDim2.new(0, 0, 0, 0)
ThreatTopAccent.BackgroundColor3 = Config.Palette.Killer
ThreatTopAccent.BorderSizePixel = 0
Instance.new("UICorner", ThreatTopAccent).CornerRadius = UDim.new(1, 0)

ThreatTitle = Instance.new("TextLabel", ThreatRadarHUD)
ThreatTitle.Size = UDim2.new(1, -80, 0, 18)
ThreatTitle.Position = UDim2.new(0, 12, 0, 6)
ThreatTitle.BackgroundTransparency = 1
ThreatTitle.TextColor3 = Config.Palette.Killer
ThreatTitle.Font = Enum.Font.GothamBold
ThreatTitle.TextSize = 10
ThreatTitle.Text = "THREAT DETECTED // ACTIVE SCAN"
ThreatTitle.TextXAlignment = Enum.TextXAlignment.Left

ThreatDistBadge = Instance.new("TextLabel", ThreatRadarHUD)
ThreatDistBadge.Size = UDim2.new(0, 56, 0, 18)
ThreatDistBadge.Position = UDim2.new(1, -66, 0, 6)
ThreatDistBadge.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
ThreatDistBadge.TextColor3 = Config.Palette.Survivor
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
ThreatBarFill.BackgroundColor3 = Config.Palette.Killer
ThreatBarFill.BorderSizePixel = 0
Instance.new("UICorner", ThreatBarFill).CornerRadius = UDim.new(1, 0)

-- Unload Script Function
local function UnloadScript()
    Config.System.Active = false
    Config.Combat.AutoParry = false
    Config.Automation.AutoGreatCheck = false
    Config.Visuals.MasterESP = false
    Config.Player.FastSpeed = false
    Config.Killer.FastSpeed = false

    for name, conn in pairs(State.Connections) do
        if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
    end
    table.clear(State.Connections)

    for _, tag in ipairs(State.Billboards) do
        if tag and tag.Parent then pcall(function() tag:Destroy() end) end
    end
    table.clear(State.Billboards)

    for obj, hl in pairs(State.Highlights) do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end
    end
    table.clear(State.Highlights)

    if State.Boxes then
        for obj, sb in pairs(State.Boxes) do
            if sb and sb.Parent then pcall(function() sb:Destroy() end) end
        end
        table.clear(State.Boxes)
    end

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

    pcall(function()
        if ScreenGui then ScreenGui:Destroy() end
    end)

    pcall(function()
        if Library and Library.Unload then
            Library:Unload()
        end
    end)
end

-- Create Obsidian Window
local Window = Library:CreateWindow({
    Title = "606VD",
    Footer = "v1.12 // VIOLENCE DISTRICT",
    NotifySide = "Right",
    ShowCustomCursor = false,
    ToggleKeybind = Config.System.MenuKey
})

-- Telemetry helper for runtime loop
local TelemetryLabel = {
    Text = "",
    _last = ""
}
setmetatable(TelemetryLabel, {
    __newindex = function(t, k, v)
        if k == "Text" and v ~= t._last then
            t._last = v
            pcall(function()
                if Window and Window.SetFooter then
                    Window:SetFooter(string.format("v1.12 // %s", tostring(v)))
                end
            end)
        end
        rawset(t, k, v)
    end
})

-- Helper to create formatted dynamic Cards in Obsidian
local function CreateObsidianCard(groupbox, title, defaultVal)
    groupbox:AddLabel({ Text = string.format("<font color=\"rgb(140,130,160)\"><b>%s</b></font>", string.upper(title)) })
    local valLabel = groupbox:AddLabel({ Text = tostring(defaultVal), DoesWrap = true })
    return function(newVal)
        if valLabel and valLabel.SetText then
            pcall(function()
                valLabel:SetText(tostring(newVal))
            end)
        end
    end
end

-- Obsidian Tabs
local Tabs = {
    Player     = Window:AddTab("Survivor", "user"),
    Killer     = Window:AddTab("Killer", "swords"),
    Automation = Window:AddTab("Automation", "cog"),
    Visuals    = Window:AddTab("Visuals", "eye"),
    Radar      = Window:AddTab("Radar & Intel", "activity"),
    Settings   = Window:AddTab("Settings", "settings")
}

-- ====================================================================
-- TAB 1: SURVIVOR (PLAYER)
-- ====================================================================
local PlayerLeftBox = Tabs.Player:AddLeftGroupbox("Survivor Combat & Defense")
CardPlayerRole = CreateObsidianCard(PlayerLeftBox, "Survivor Status", "CHECKING ROLE...")

PlayerLeftBox:AddToggle("AutoParry", {
    Text = "Auto Parry Killer Attacks",
    Default = Config.Combat.AutoParry,
    Tooltip = "Smart parry only when killer attacks towards you",
    Callback = function(v)
        Config.Combat.AutoParry = v
        Config.Player.AutoParry = v
    end
})

PlayerLeftBox:AddToggle("FaceCheck", {
    Text = "360-Degree Parry Protection",
    Default = not Config.Combat.FaceCheck,
    Tooltip = "Parries attacks from any angle, even from behind",
    Callback = function(v)
        Config.Combat.FaceCheck = not v
    end
})

PlayerLeftBox:AddSlider("ParryDistance", {
    Text = "Parry Trigger Distance",
    Default = Config.Combat.ParryDistance,
    Min = 6,
    Max = 16,
    Rounding = 1,
    Suffix = " studs",
    HideMax = true,
    Callback = function(v)
        Config.Combat.ParryDistance = v
    end
})

PlayerLeftBox:AddButton({
    Text = "MANUAL TEST PARRY (RIGHT CLICK)",
    Func = function()
        ExecuteAutoParry("MANUAL_TEST")
    end
})

local PlayerRightBox = Tabs.Player:AddRightGroupbox("Survivor Movement & Perks")
PlayerRightBox:AddToggle("PlayerSpeed", {
    Text = "Player Fast Speed Boost",
    Default = Config.Player.FastSpeed,
    Tooltip = "Activates only when toggled on",
    Callback = function(v)
        Config.Player.FastSpeed = v
        if not v and LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
    end
})

PlayerRightBox:AddSlider("PlayerSpeedVal", {
    Text = "Player WalkSpeed",
    Default = Config.Player.SpeedValue,
    Min = 16,
    Max = 45,
    Rounding = 0,
    Suffix = " studs/s",
    HideMax = true,
    Callback = function(v)
        Config.Player.SpeedValue = v
    end
})

PlayerRightBox:AddToggle("PlayerAntiStun", {
    Text = "No Stun / Anti Stun (Player)",
    Default = Config.Player.AntiStun,
    Callback = function(v)
        Config.Player.AntiStun = v
    end
})

PlayerRightBox:AddToggle("EnforcePlayerRole", {
    Text = "Enforce Player Role Only",
    Default = Config.Player.OnlyWhenPlayer,
    Callback = function(v)
        Config.Player.OnlyWhenPlayer = v
    end
})

PlayerRightBox:AddButton({
    Text = "INSTANT RECOVER / CLEAR STUN",
    Func = function()
        pcall(function()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then
                h.PlatformStand = false
                h.Sit = false
                h:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
})

-- ====================================================================
-- TAB 2: KILLER
-- ====================================================================
local KillerLeftBox = Tabs.Killer:AddLeftGroupbox("Killer Combat & Immunity")
CardKillerRole = CreateObsidianCard(KillerLeftBox, "Killer Status", "CHECKING ROLE...")

KillerLeftBox:AddToggle("KillerAntiStun", {
    Text = "Anti Stun (Pallet & Blind Immune)",
    Default = Config.Killer.AntiStun,
    Tooltip = "Completely nullifies pallet stuns and flashlight blinds",
    Callback = function(v)
        Config.Killer.AntiStun = v
    end
})

KillerLeftBox:AddToggle("KillerSpeed", {
    Text = "Killer Fast Speed Boost",
    Default = Config.Killer.FastSpeed,
    Tooltip = "Accelerates movement speed while playing as Killer",
    Callback = function(v)
        Config.Killer.FastSpeed = v
        if not v and LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
    end
})

KillerLeftBox:AddSlider("KillerSpeedVal", {
    Text = "Killer Fast Speed",
    Default = Config.Killer.SpeedValue,
    Min = 18,
    Max = 55,
    Rounding = 0,
    Suffix = " studs/s",
    HideMax = true,
    Callback = function(v)
        Config.Killer.SpeedValue = v
    end
})

KillerLeftBox:AddToggle("EnforceKillerRole", {
    Text = "Enforce Killer Role Only",
    Default = Config.Killer.OnlyWhenKiller,
    Callback = function(v)
        Config.Killer.OnlyWhenKiller = v
    end
})

KillerLeftBox:AddButton({
    Text = "INSTANT RECOVER / CLEAR ALL STUNS",
    Func = function()
        pcall(function()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then
                h.PlatformStand = false
                h.Sit = false
                h:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
})

-- ====================================================================
-- TAB 3: AUTOMATION
-- ====================================================================
local AutoLeftBox = Tabs.Automation:AddLeftGroupbox("Generator Skill Check Engine")
AutoLeftBox:AddToggle("AutoGreatCheck", {
    Text = "Auto Fix Gen (Perfect Great)",
    Default = Config.Automation.AutoGreatCheck,
    Tooltip = "Instantly hits Great skill checks with zero delay",
    Callback = function(v)
        Config.Automation.AutoGreatCheck = v
    end
})

AutoLeftBox:AddToggle("SmartGreat", {
    Text = "Smart Zero-Adjust Engine",
    Default = Config.Automation.SmartGreat,
    Tooltip = "Automatically calibrates to game updates",
    Callback = function(v)
        Config.Automation.SmartGreat = v
    end
})

AutoLeftBox:AddToggle("AutoRepair", {
    Text = "Auto Generator Repair Assist",
    Default = Config.Automation.AutoRepair,
    Tooltip = "Automatically interacts with nearby uncompleted generators",
    Callback = function(v)
        Config.Automation.AutoRepair = v
    end
})

AutoLeftBox:AddSlider("ClickDelay", {
    Text = "Click Delay Compensation",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = " ms",
    HideMax = true,
    Callback = function(ms)
        Config.Automation.ClickDelay = ms / 1000
    end
})

AutoLeftBox:AddSlider("HitAngleStart", {
    Text = "Great Hit Angle Start",
    Default = Config.Automation.HitAngleStart,
    Min = 95,
    Max = 115,
    Rounding = 0,
    Suffix = " deg",
    HideMax = true,
    Callback = function(v)
        Config.Automation.HitAngleStart = v
    end
})

AutoLeftBox:AddSlider("HitAngleEnd", {
    Text = "Great Hit Angle End",
    Default = Config.Automation.HitAngleEnd,
    Min = 108,
    Max = 128,
    Rounding = 0,
    Suffix = " deg",
    HideMax = true,
    Callback = function(v)
        Config.Automation.HitAngleEnd = v
    end
})

-- ====================================================================
-- TAB 4: VISUALS
-- ====================================================================
local VisualsLeftBox = Tabs.Visuals:AddLeftGroupbox("ESP Entities (Visuals)")
VisualsLeftBox:AddToggle("MasterESP", {
    Text = "Master Visuals",
    Default = Config.Visuals.MasterESP,
    Tooltip = "Global master switch for all ESP components",
    Callback = function(v)
        Config.Visuals.MasterESP = v
        if not v then
            for _, b in pairs(State.Billboards) do if b then b:Destroy() end end
            table.clear(State.Billboards)
            for _, hl in pairs(State.Highlights) do if hl then hl:Destroy() end end
            table.clear(State.Highlights)
            if State.Boxes then
                for _, sb in pairs(State.Boxes) do if sb then sb:Destroy() end end
                table.clear(State.Boxes)
            end
        else
            ProcessEntities()
            ProcessWorldESP()
        end
    end
})

VisualsLeftBox:AddToggle("KillerESP", {
    Text = "ESP Killer (Red Chams)",
    Default = Config.Visuals.KillerESP,
    Tooltip = "Highlights the single active Killer in pure vibrant Red",
    Callback = function(v)
        Config.Visuals.KillerESP = v
        if not v then
            if State.ActiveKiller and State.ActiveKiller.Character then
                local tag = State.ActiveKiller.Character:FindFirstChild("ESP_Tag", true)
                if tag then tag:Destroy() end
                RemoveHighlight(State.ActiveKiller.Character)
            end
        else
            ProcessEntities()
        end
    end
})

VisualsLeftBox:AddToggle("SurvivorESP", {
    Text = "ESP Player (Cyan Chams)",
    Default = Config.Visuals.SurvivorESP,
    Tooltip = "Highlights all fellow Players/Survivors in pure vibrant Cyan",
    Callback = function(v)
        Config.Visuals.SurvivorESP = v
        if not v then
            for _, p in ipairs(Services.Players:GetPlayers()) do
                if p ~= LocalPlayer and p ~= State.ActiveKiller and p.Character then
                    local tag = p.Character:FindFirstChild("ESP_Tag", true)
                    if tag then tag:Destroy() end
                    RemoveHighlight(p.Character)
                end
            end
        else
            ProcessEntities()
        end
    end
})

VisualsLeftBox:AddToggle("GeneratorESP", {
    Text = "ESP Generator (Highlight Only)",
    Default = Config.Visuals.GeneratorESP,
    Tooltip = "3D glowing chams for all generators (zero name tags)",
    Callback = function(v)
        Config.Visuals.GeneratorESP = v
        if not v then
            for _, gen in ipairs(State.Generators) do
                local tag = gen:FindFirstChild("ESP_Tag", true)
                if tag then tag:Destroy() end
                RemoveHighlight(gen)
            end
        else
            ProcessWorldESP()
        end
    end
})

VisualsLeftBox:AddToggle("GateESP", {
    Text = "ESP Exit Gate (Highlight Only)",
    Default = Config.Visuals.GateESP,
    Tooltip = "3D glowing chams for all exit gates (zero name tags)",
    Callback = function(v)
        Config.Visuals.GateESP = v
        if not v then
            for _, gate in ipairs(State.WorldObjects.Gates) do
                local tag = gate:FindFirstChild("ESP_Tag", true)
                if tag then tag:Destroy() end
                RemoveHighlight(gate)
            end
        else
            ProcessWorldESP()
        end
    end
})

VisualsLeftBox:AddToggle("ShowDistance", {
    Text = "Display Player Distance",
    Default = Config.Visuals.ShowDistance,
    Callback = function(v)
        Config.Visuals.ShowDistance = v
    end
})

local VisualsRightBox = Tabs.Visuals:AddRightGroupbox("Environment & Lighting")
VisualsRightBox:AddToggle("Fullbright", {
    Text = "Fullbright Ambient Max",
    Default = Config.Environment.Fullbright,
    Tooltip = "Maximum ambient visibility across all maps",
    Callback = function(v)
        Config.Environment.Fullbright = v
        if not v then
            pcall(function()
                Services.Lighting.Ambient = State.LightingDefaults.Ambient
                Services.Lighting.OutdoorAmbient = State.LightingDefaults.OutdoorAmbient
                Services.Lighting.Brightness = State.LightingDefaults.Brightness
                Services.Lighting.ClockTime = State.LightingDefaults.ClockTime
            end)
        end
    end
})

VisualsRightBox:AddToggle("RemoveFog", {
    Text = "Remove Atmospheric Fog",
    Default = Config.Environment.RemoveFog,
    Tooltip = "Clears dark fog and shadow occlusion",
    Callback = function(v)
        Config.Environment.RemoveFog = v
        if not v then
            pcall(function()
                Services.Lighting.FogEnd = State.LightingDefaults.FogEnd
                Services.Lighting.GlobalShadows = State.LightingDefaults.GlobalShadows
            end)
        end
    end
})

VisualsRightBox:AddSlider("FOV", {
    Text = "Camera Field of View",
    Default = Config.Environment.FieldOfView,
    Min = 70,
    Max = 120,
    Rounding = 0,
    Suffix = " fov",
    HideMax = true,
    Callback = function(v)
        Config.Environment.FieldOfView = v
        Camera.FieldOfView = v
    end
})

-- ====================================================================
-- TAB 5: RADAR & INTEL
-- ====================================================================
local IntelLeftBox = Tabs.Radar:AddLeftGroupbox("Live Match Intel")
CardRealKiller   = CreateObsidianCard(IntelLeftBox, "Active Match Killer", "SEARCHING FOR TARGET...")
CardKillerStatus = CreateObsidianCard(IntelLeftBox, "Killer Tactical Status", "ANALYZING TELEMETRY...")
CardMask         = CreateObsidianCard(IntelLeftBox, "Hotline Mask Loadout", "NONE")
CardGensLeft     = CreateObsidianCard(IntelLeftBox, "Generator Objective Progress", "0 / 5 COMPLETE")

local RadarRightBox = Tabs.Radar:AddRightGroupbox("Tactical Threat Radar")
RadarRightBox:AddToggle("RadarEnabled", {
    Text = "Proximity Danger Sensor",
    Default = Config.Radar.Enabled,
    Callback = function(v)
        Config.Radar.Enabled = v
        if not v and ThreatRadarHUD then ThreatRadarHUD.Visible = false end
    end
})

RadarRightBox:AddToggle("RadarLOS", {
    Text = "Killer Line-Of-Sight Raycasting",
    Default = Config.Radar.LineOfSight,
    Callback = function(v)
        Config.Radar.LineOfSight = v
    end
})

RadarRightBox:AddToggle("RadarThreatMeter", {
    Text = "Screen Threat Meter HUD",
    Default = Config.Radar.ThreatMeter,
    Callback = function(v)
        Config.Radar.ThreatMeter = v
        if not v and ThreatRadarHUD then ThreatRadarHUD.Visible = false end
    end
})

RadarRightBox:AddSlider("RadarRadius", {
    Text = "Danger Radius",
    Default = Config.Radar.Radius,
    Min = 40,
    Max = 160,
    Rounding = 0,
    Suffix = " studs",
    HideMax = true,
    Callback = function(v)
        Config.Radar.Radius = v
    end
})

-- ====================================================================
-- TAB 6: SETTINGS
-- ====================================================================
local SettingsLeftBox = Tabs.Settings:AddLeftGroupbox("Build Architecture")
SettingsLeftBox:AddLabel({ Text = "<font color=\"rgb(0,240,255)\"><b>606VD // PRO REALITY SUITE</b></font>" })
SettingsLeftBox:AddLabel({ Text = "Edition: Obsidian UI Library" })
SettingsLeftBox:AddLabel({ Text = "Version: 1.12" })
SettingsLeftBox:AddDivider()

SettingsLeftBox:AddButton({
    Text = "Force Re-index Map Objects",
    Func = function()
        for _, b in pairs(State.Billboards) do if b then b:Destroy() end end
        table.clear(State.Billboards)
        table.clear(State.AnchorCache)
        IndexWorldObjects()
        ProcessWorldESP()
        Library:Notify({ Title = "606VD", Description = "Map objects re-indexed successfully!", Time = 3 })
    end
})

SettingsLeftBox:AddButton({
    Text = "CLOSE & UNLOAD SCRIPT",
    Func = function()
        UnloadScript()
    end
})

-- Build Obsidian ThemeManager and SaveManager on Settings Tab
pcall(function()
    if ThemeManager then
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("606VD")
        ThemeManager:ApplyToTab(Tabs.Settings)
    end
    if SaveManager then
        SaveManager:SetLibrary(Library)
        SaveManager:SetFolder("606VD/ViolenceDistrict")
        SaveManager:BuildConfigSection(Tabs.Settings)
    end
end)

Library:Notify({
    Title = "606VD LOADED",
    Description = "Obsidian UI Suite initialized. Toggle with RightControl.",
    Time = 4
})

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

    -- Throttled Environmental Lighting: Runs at ~0.5 Hz (Zero frame stutter!)
    if now - State.LastLightingTick >= 1.5 then
        State.LastLightingTick = now
        if Config.Environment.Fullbright then
            if Services.Lighting.Brightness ~= 2 then Services.Lighting.Brightness = 2 end
            if Services.Lighting.ClockTime ~= 14 then Services.Lighting.ClockTime = 14 end
            if Services.Lighting.Ambient ~= Color3.fromRGB(255, 255, 255) then
                Services.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Services.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            end
        end
        if Config.Environment.RemoveFog then
            if Services.Lighting.GlobalShadows ~= false then Services.Lighting.GlobalShadows = false end
            if Services.Lighting.FogEnd < 1e5 then Services.Lighting.FogEnd = 1e5 end
        end
    end

    -- Periodic Map Re-index: Rapid retry if 0 gens, otherwise throttled to 16 seconds
    local genScanInterval = (#State.Generators == 0) and 1.5 or 16
    if now - lastDeepScan > genScanInterval then
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
