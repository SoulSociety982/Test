if _G.closet_gg then
    return
end

_G.closet_gg = true -- will error on "ByteCode", probably because I haven't coded how _G is used sometimes in exec environments

repeat
    task.wait()
until game:IsLoaded()

cloneref = cloneref or function(obj)
    return obj
end

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local Debris = cloneref(game:GetService("Debris"))
local Stats = cloneref(game:GetService("Stats"))
local ContentProvider = cloneref(game:GetService("ContentProvider"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextService = cloneref(game:GetService("TextService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Lighting = cloneref(game:GetService("Lighting"))
local GuiService = cloneref(game:GetService("GuiService"))
local CollectionService = cloneref(game:GetService("CollectionService"))
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    Players:GetPropertyChangedSignal('LocalPlayer'):Wait()
    LocalPlayer = Players.LocalPlayer
end

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

if not isfolder then
    function isfolder()
        return false
    end
end

if not makefolder then
    function makefolder()
        --
    end
end

if not writefile then
    function writefile()
        --
    end
end

if not readfile then
    function readfile()
        return nil
    end
end

local RandomNameAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
local GothamFontPath = "rbxasset://fonts/families/GothamSSm.json"
local MontserratFontPath = "rbxasset://fonts/families/Montserrat.json"
local SourceSansProFontPath = "rbxasset://fonts/families/SourceSansPro.json"
local IconsUrl = "https://raw.githubusercontent.com/CabineTsv/closet.gg/refs/heads/main/Interface/Rewrite/Icons.luau"
local ConfigFolderName = "Closet"
local ConfigsFolderName = ConfigFolderName .. "/Configs"
local DefaultToggleKey = "Enum.KeyCode.LeftControl"
local DefaultBackgroundTransparency = 0.04
local ExpandedModuleBaseHeight = 93
local CollapsedModuleSize = UDim2.new(1, -8, 0, ExpandedModuleBaseHeight)
local OpenWindowSize = UDim2.fromOffset(698, 479)
local MaxWindowWidthRatio = 0.92
local MaxWindowHeightRatio = 0.85
local MobileWindowHeightRatio = 0.72
local MinWindowScale = 0.4
local MinNotificationScale = 0.75
local NameCounter = 0

local ThemeFont = {Enum = nil}
local FontCache = {}
local UIFontScale = 1

local function MeasureFont(fontFamily)
    local boundsParams = Instance.new("GetTextBoundsParams")
    boundsParams.Text = "AaGgQjy 0129 Settings"
    boundsParams.Font = Font.new(fontFamily, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    boundsParams.Size = 100
    boundsParams.Width = 10000
    local success, bounds = pcall(function()
        return TextService:GetTextBoundsAsync(boundsParams)
    end)
    if success and bounds and bounds.X > 0 and bounds.Y > 0 then
        return bounds.X, bounds.Y
    end
    return nil, nil
end

local function ComputeFontScale(fontFamily)
    local baseWidth, baseHeight = MeasureFont(GothamFontPath)
    local newWidth, newHeight = MeasureFont(fontFamily)
    if not (baseWidth and baseHeight and newWidth and newHeight) then
        return 1
    end
    local heightRatio = baseHeight / newHeight
    local widthRatio = baseWidth / newWidth
    local rawScale = math.min(heightRatio, widthRatio * 1.15)
    local dampedScale = 1 + ((rawScale - 1) * 0.7)
    return math.clamp(dampedScale, 0.8, 1.25)
end

local function SetThemeFont(fontValue)
    if typeof(fontValue) == "EnumItem" then
        local success, sampleFont = pcall(Font.fromEnum, fontValue)
        if success and sampleFont then
            ThemeFont.Enum = fontValue
            UIFontScale = ComputeFontScale(sampleFont.Family)
            return
        end
    end
    ThemeFont.Enum = nil
    UIFontScale = 1
end

local function GenerateRandomString(length)
    NameCounter = NameCounter + 1
    local characterCount = length or math.random(14, 22)
    local characters = table.create(characterCount)
    for index = 1, characterCount do
        local alphabetIndex = math.random(1, 63)
        if index == characterCount then
            alphabetIndex = (alphabetIndex + NameCounter * 19 + characterCount * 7) % 63 + 1
        end
        characters[index] = string.sub(RandomNameAlphabet, alphabetIndex, alphabetIndex)
    end
    return table.concat(characters)
end

local GlobalRegistryKey = GenerateRandomString(math.random(14, 22))
local MarkerAttributeName = GenerateRandomString(math.random(12, 18))

local function GetInterfaceParent()
    local hiddenInterface
    pcall(function()
        if typeof(gethui) ~= "function" then
            return
        end
        hiddenInterface = gethui()
        if hiddenInterface then
            hiddenInterface = cloneref(hiddenInterface)
        end
    end)
    if hiddenInterface then
        return hiddenInterface
    end
    return CoreGui
end

local function ForEachInterfaceRoot(callback)
    callback(GetInterfaceParent())
    callback(CoreGui)
    callback(Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
end

local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    instance.Name = GenerateRandomString()
    if properties then
        for propertyName, propertyValue in pairs(properties) do
            if propertyName ~= "Parent" then
                instance[propertyName] = propertyValue
            end
        end
        instance.Parent = properties.Parent
    end
    return instance
end

local function RegisterInterface(screenGui)
    if not screenGui then
        return
    end
    screenGui:SetAttribute(MarkerAttributeName, GenerateRandomString(math.random(14, 22)))
    getgenv()[GlobalRegistryKey] = screenGui
    getgenv()._ClosetObfuscationRegistry = {
        GuiRoot = screenGui,
        GlobalKey = GlobalRegistryKey,
        MarkerAttribute = MarkerAttributeName
    }
end

local function DestroyPreviousInterface()
    local registry = getgenv()._ClosetObfuscationRegistry
    if typeof(registry) ~= "table" then
        return
    end
    if typeof(registry.GuiRoot) == "Instance" and registry.GuiRoot.Parent then
        pcall(function()
            registry.GuiRoot:Destroy()
        end)
    end
    if typeof(registry.GlobalKey) == "string" then
        local registeredInterface = getgenv()[registry.GlobalKey]
        if typeof(registeredInterface) == "Instance" and registeredInterface.Parent then
            pcall(function()
                registeredInterface:Destroy()
            end)
        end
        getgenv()[registry.GlobalKey] = nil
    end
    if typeof(registry.MarkerAttribute) == "string" then
        local previousMarkerAttribute = registry.MarkerAttribute
        ForEachInterfaceRoot(function(interfaceRoot)
            if not interfaceRoot then
                return
            end
            for _, child in interfaceRoot:GetChildren() do
                if child:IsA("ScreenGui") and child:GetAttribute(previousMarkerAttribute) ~= nil then
                    child:Destroy()
                end
            end
        end)
    end
end

local function CreateScreenGui()
    local screenGui = CreateInstance("ScreenGui", {
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = GetInterfaceParent()
    })
    RegisterInterface(screenGui)
    return screenGui
end

local function PlayTween(instance, tweenInfo, goals)
    local tween = TweenService:Create(instance, tweenInfo, goals)
    tween:Play()
    return tween
end

local function CreateQuintOutTweenInfo(duration)
    return TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

local function CreateSmoothTweenInfo(duration)
    return TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

local function CreateGothamFont(fontWeight)
    local cacheKey = (ThemeFont.Enum and ThemeFont.Enum.Name or "Gotham") .. tostring(fontWeight)
    local cachedFont = FontCache[cacheKey]
    if cachedFont then
        return cachedFont
    end
    local font
    if ThemeFont.Enum then
        local baseFont = Font.fromEnum(ThemeFont.Enum)
        local success, weightedFont = pcall(Font.new, baseFont.Family, fontWeight)
        font = success and weightedFont or baseFont
    else
        font = Font.new(GothamFontPath, fontWeight)
    end
    FontCache[cacheKey] = font
    return font
end

local function ApplyThemeFont(root)
    for _, descendant in root:GetDescendants() do
        if (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox"))
            and not descendant:GetAttribute("KeepFont") then
            local baseTextSize = descendant:GetAttribute("BaseTextSize")
            if not baseTextSize then
                baseTextSize = descendant.TextSize
                descendant:SetAttribute("BaseTextSize", baseTextSize)
            end
            local scaledTextSize = baseTextSize
            if UIFontScale ~= 1 then
                scaledTextSize = math.max(6, math.min(math.floor(baseTextSize * UIFontScale + 0.5), baseTextSize + 4))
            end
            descendant.FontFace = CreateGothamFont(descendant.FontFace.Weight)
            descendant.TextSize = scaledTextSize
        end
    end
end

local function MeasureText(text, font, textSize)
    local boundsParams = Instance.new("GetTextBoundsParams")
    boundsParams.Text = text
    boundsParams.Font = font
    boundsParams.Size = textSize
    boundsParams.Width = 10000
    return TextService:GetTextBoundsAsync(boundsParams)
end

local function AddCorner(parent, radius)
    return CreateInstance("UICorner", {
        CornerRadius = typeof(radius) == "UDim" and radius or UDim.new(0, radius),
        Parent = parent
    })
end

local function AddStroke(parent, color, transparency, useBorderMode)
    return CreateInstance("UIStroke", {
        Color = color,
        Transparency = transparency,
        ApplyStrokeMode = useBorderMode and Enum.ApplyStrokeMode.Border or Enum.ApplyStrokeMode.Contextual,
        Parent = parent
    })
end

local function StripKeyCodePrefix(keyCodeString)
    return (keyCodeString:gsub("Enum.KeyCode.", ""))
end

local function IsPrimaryPointerInput(inputObject)
    return inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch
end

local Mouse = Players.LocalPlayer:GetMouse()

local Language = {
    CheckboxEnabled = "Enabled",
    CheckboxDisabled = "Disabled",
    SliderValue = "Value",
    DropdownSelect = "Select",
    DropdownNone = "None",
    DropdownSelected = "Selected",
    ButtonClick = "Click",
    TextboxEnter = "Enter",
    ModuleEnabled = "Enabled",
    ModuleDisabled = "Disabled",
    TabGeneral = "General",
    TabSettings = "Settings",
    Loading = "Loading...",
    Error = "Error",
    Success = "Success"
}

local Colors = {
    Background = Color3.fromRGB(10, 11, 14),
    Card = Color3.fromRGB(18, 22, 32),
    CardDeep = Color3.fromRGB(14, 17, 26),
    Stroke = Color3.fromRGB(60, 60, 90),
    StrokeHot = Color3.fromRGB(85, 85, 125),
    Accent = Color3.fromRGB(130, 100, 255),
    AccentDim = Color3.fromRGB(55, 42, 122),
    AccentSoft = Color3.fromRGB(190, 170, 255),
    Text = Color3.fromRGB(240, 240, 255),
    SubText = Color3.fromRGB(160, 160, 185),
    Danger = Color3.fromRGB(240, 70, 70)
}

local DefaultColors = {}

for colorName, color in pairs(Colors) do
    DefaultColors[colorName] = color
end

local Themes = {
    Midnight = {
        Background = Color3.fromRGB(10, 11, 14),
        ModuleBackground = Color3.fromRGB(18, 22, 32),
        Accent = Color3.fromRGB(130, 100, 255),
        SecondaryAccent = Color3.fromRGB(190, 170, 255),
        Text = Color3.fromRGB(240, 240, 255),
        TextDark = Color3.fromRGB(160, 160, 185),
        Highlight = Color3.fromRGB(90, 60, 220),
        Stroke = Color3.fromRGB(60, 60, 90)
    },
    Rose = {
        Background = Color3.fromRGB(14, 10, 12),
        ModuleBackground = Color3.fromRGB(28, 18, 24),
        Accent = Color3.fromRGB(255, 100, 150),
        SecondaryAccent = Color3.fromRGB(255, 180, 210),
        Text = Color3.fromRGB(255, 245, 250),
        TextDark = Color3.fromRGB(200, 170, 185),
        Highlight = Color3.fromRGB(200, 50, 100),
        Stroke = Color3.fromRGB(80, 40, 60)
    },
    Sapphire = {
        Background = Color3.fromRGB(8, 12, 20),
        ModuleBackground = Color3.fromRGB(14, 22, 40),
        Accent = Color3.fromRGB(60, 140, 255),
        SecondaryAccent = Color3.fromRGB(140, 200, 255),
        Text = Color3.fromRGB(230, 240, 255),
        TextDark = Color3.fromRGB(150, 175, 220),
        Highlight = Color3.fromRGB(30, 100, 220),
        Stroke = Color3.fromRGB(30, 55, 100)
    },
    Emerald = {
        Background = Color3.fromRGB(8, 14, 12),
        ModuleBackground = Color3.fromRGB(14, 26, 22),
        Accent = Color3.fromRGB(50, 220, 140),
        SecondaryAccent = Color3.fromRGB(130, 255, 200),
        Text = Color3.fromRGB(230, 255, 245),
        TextDark = Color3.fromRGB(140, 195, 175),
        Highlight = Color3.fromRGB(20, 170, 100),
        Stroke = Color3.fromRGB(25, 70, 55)
    },
    Obsidian = {
        Background = Color3.fromRGB(8, 8, 10),
        ModuleBackground = Color3.fromRGB(15, 15, 20),
        Accent = Color3.fromRGB(200, 180, 120),
        SecondaryAccent = Color3.fromRGB(240, 220, 160),
        Text = Color3.fromRGB(245, 242, 235),
        TextDark = Color3.fromRGB(180, 170, 145),
        Highlight = Color3.fromRGB(160, 130, 70),
        Stroke = Color3.fromRGB(50, 45, 35)
    },
    Glacier = {
        Background = Color3.fromRGB(10, 14, 20),
        ModuleBackground = Color3.fromRGB(18, 26, 38),
        Accent = Color3.fromRGB(130, 210, 240),
        SecondaryAccent = Color3.fromRGB(190, 235, 255),
        Text = Color3.fromRGB(235, 248, 255),
        TextDark = Color3.fromRGB(155, 195, 220),
        Highlight = Color3.fromRGB(80, 175, 225),
        Stroke = Color3.fromRGB(35, 70, 100)
    },
    Crimson = {
        Background = Color3.fromRGB(12, 8, 8),
        ModuleBackground = Color3.fromRGB(24, 14, 14),
        Accent = Color3.fromRGB(220, 55, 75),
        SecondaryAccent = Color3.fromRGB(255, 120, 140),
        Text = Color3.fromRGB(255, 238, 240),
        TextDark = Color3.fromRGB(200, 160, 165),
        Highlight = Color3.fromRGB(170, 30, 50),
        Stroke = Color3.fromRGB(80, 30, 35)
    },
    Amber = {
        Background = Color3.fromRGB(12, 10, 6),
        ModuleBackground = Color3.fromRGB(24, 20, 12),
        Accent = Color3.fromRGB(255, 175, 50),
        SecondaryAccent = Color3.fromRGB(255, 215, 120),
        Text = Color3.fromRGB(255, 248, 230),
        TextDark = Color3.fromRGB(210, 185, 130),
        Highlight = Color3.fromRGB(210, 135, 20),
        Stroke = Color3.fromRGB(80, 60, 20)
    },
    Cyber = {
        Background = Color3.fromRGB(6, 6, 10),
        ModuleBackground = Color3.fromRGB(12, 12, 20),
        Accent = Color3.fromRGB(0, 240, 160),
        SecondaryAccent = Color3.fromRGB(60, 255, 220),
        Text = Color3.fromRGB(230, 255, 250),
        TextDark = Color3.fromRGB(120, 195, 185),
        Highlight = Color3.fromRGB(255, 50, 200),
        Stroke = Color3.fromRGB(20, 65, 55)
    },
    Neon = {
        Background = Color3.fromRGB(5, 4, 10),
        ModuleBackground = Color3.fromRGB(12, 10, 22),
        Accent = Color3.fromRGB(255, 30, 130),
        SecondaryAccent = Color3.fromRGB(130, 60, 255),
        Text = Color3.fromRGB(255, 250, 255),
        TextDark = Color3.fromRGB(185, 165, 210),
        Highlight = Color3.fromRGB(200, 0, 255),
        Stroke = Color3.fromRGB(70, 30, 80)
    },
    Sunset = {
        Background = Color3.fromRGB(14, 8, 10),
        ModuleBackground = Color3.fromRGB(28, 16, 20),
        Accent = Color3.fromRGB(255, 110, 70),
        SecondaryAccent = Color3.fromRGB(255, 175, 80),
        Text = Color3.fromRGB(255, 245, 235),
        TextDark = Color3.fromRGB(215, 175, 155),
        Highlight = Color3.fromRGB(220, 65, 30),
        Stroke = Color3.fromRGB(90, 40, 30)
    },
    Sakura = {
        Background = Color3.fromRGB(14, 10, 12),
        ModuleBackground = Color3.fromRGB(28, 18, 24),
        Accent = Color3.fromRGB(255, 175, 200),
        SecondaryAccent = Color3.fromRGB(255, 215, 228),
        Text = Color3.fromRGB(255, 245, 248),
        TextDark = Color3.fromRGB(215, 180, 195),
        Highlight = Color3.fromRGB(230, 110, 160),
        Stroke = Color3.fromRGB(80, 45, 65)
    },
    Monochrome = {
        Background = Color3.fromRGB(10, 10, 10),
        ModuleBackground = Color3.fromRGB(18, 18, 18),
        Accent = Color3.fromRGB(210, 210, 210),
        SecondaryAccent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(250, 250, 250),
        TextDark = Color3.fromRGB(155, 155, 155),
        Highlight = Color3.fromRGB(120, 120, 120),
        Stroke = Color3.fromRGB(45, 45, 45)
    },
    Ash = {
        Background = Color3.fromRGB(12, 13, 15),
        ModuleBackground = Color3.fromRGB(22, 24, 28),
        Accent = Color3.fromRGB(160, 200, 255),
        SecondaryAccent = Color3.fromRGB(200, 225, 255),
        Text = Color3.fromRGB(240, 242, 248),
        TextDark = Color3.fromRGB(160, 168, 185),
        Highlight = Color3.fromRGB(100, 150, 230),
        Stroke = Color3.fromRGB(45, 50, 65)
    },
    Forest = {
        Background = Color3.fromRGB(8, 12, 10),
        ModuleBackground = Color3.fromRGB(14, 22, 18),
        Accent = Color3.fromRGB(80, 210, 100),
        SecondaryAccent = Color3.fromRGB(155, 245, 165),
        Text = Color3.fromRGB(235, 255, 238),
        TextDark = Color3.fromRGB(150, 200, 160),
        Highlight = Color3.fromRGB(45, 160, 65),
        Stroke = Color3.fromRGB(28, 65, 38)
    },
    Ocean = {
        Background = Color3.fromRGB(6, 12, 18),
        ModuleBackground = Color3.fromRGB(10, 22, 36),
        Accent = Color3.fromRGB(30, 200, 255),
        SecondaryAccent = Color3.fromRGB(120, 225, 255),
        Text = Color3.fromRGB(225, 248, 255),
        TextDark = Color3.fromRGB(135, 185, 215),
        Highlight = Color3.fromRGB(10, 155, 230),
        Stroke = Color3.fromRGB(18, 60, 95)
    },
    Lavender = {
        Background = Color3.fromRGB(12, 10, 18),
        ModuleBackground = Color3.fromRGB(22, 18, 36),
        Accent = Color3.fromRGB(175, 155, 240),
        SecondaryAccent = Color3.fromRGB(215, 200, 255),
        Text = Color3.fromRGB(248, 245, 255),
        TextDark = Color3.fromRGB(190, 180, 220),
        Highlight = Color3.fromRGB(135, 110, 215),
        Stroke = Color3.fromRGB(60, 48, 90)
    },
    Coffee = {
        Background = Color3.fromRGB(12, 10, 8),
        ModuleBackground = Color3.fromRGB(24, 19, 14),
        Accent = Color3.fromRGB(205, 150, 90),
        SecondaryAccent = Color3.fromRGB(235, 200, 150),
        Text = Color3.fromRGB(255, 248, 238),
        TextDark = Color3.fromRGB(200, 175, 145),
        Highlight = Color3.fromRGB(165, 105, 50),
        Stroke = Color3.fromRGB(65, 48, 30)
    },
    Mint = {
        Background = Color3.fromRGB(8, 14, 12),
        ModuleBackground = Color3.fromRGB(14, 26, 22),
        Accent = Color3.fromRGB(80, 230, 195),
        SecondaryAccent = Color3.fromRGB(155, 255, 230),
        Text = Color3.fromRGB(230, 255, 248),
        TextDark = Color3.fromRGB(140, 200, 185),
        Highlight = Color3.fromRGB(35, 190, 160),
        Stroke = Color3.fromRGB(25, 72, 60)
    },
    Pink = {
        Background = Color3.fromRGB(14, 8, 12),
        ModuleBackground = Color3.fromRGB(28, 14, 24),
        Accent = Color3.fromRGB(255, 120, 190),
        SecondaryAccent = Color3.fromRGB(255, 185, 220),
        Text = Color3.fromRGB(255, 240, 248),
        TextDark = Color3.fromRGB(215, 170, 200),
        Highlight = Color3.fromRGB(220, 60, 150),
        Stroke = Color3.fromRGB(90, 35, 70)
    },
    Purple = {
        Background = Color3.fromRGB(10, 7, 16),
        ModuleBackground = Color3.fromRGB(20, 14, 32),
        Accent = Color3.fromRGB(160, 120, 240),
        SecondaryAccent = Color3.fromRGB(205, 170, 255),
        Text = Color3.fromRGB(245, 240, 255),
        TextDark = Color3.fromRGB(185, 165, 225),
        Highlight = Color3.fromRGB(120, 75, 210),
        Stroke = Color3.fromRGB(58, 38, 95)
    },
    Abyss = {
        Background = Color3.fromRGB(4, 4, 8),
        ModuleBackground = Color3.fromRGB(8, 8, 16),
        Accent = Color3.fromRGB(80, 180, 255),
        SecondaryAccent = Color3.fromRGB(140, 210, 255),
        Text = Color3.fromRGB(220, 235, 255),
        TextDark = Color3.fromRGB(120, 150, 200),
        Highlight = Color3.fromRGB(40, 130, 230),
        Stroke = Color3.fromRGB(20, 35, 65)
    },
    Vanta = {
        Background = Color3.fromRGB(3, 3, 3),
        ModuleBackground = Color3.fromRGB(8, 8, 8),
        Accent = Color3.fromRGB(255, 255, 255),
        SecondaryAccent = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(130, 130, 130),
        Highlight = Color3.fromRGB(160, 160, 160),
        Stroke = Color3.fromRGB(28, 28, 28)
    },
    Coral = {
        Background = Color3.fromRGB(14, 8, 6),
        ModuleBackground = Color3.fromRGB(28, 14, 12),
        Accent = Color3.fromRGB(255, 120, 95),
        SecondaryAccent = Color3.fromRGB(255, 180, 160),
        Text = Color3.fromRGB(255, 245, 242),
        TextDark = Color3.fromRGB(215, 175, 165),
        Highlight = Color3.fromRGB(220, 75, 50),
        Stroke = Color3.fromRGB(90, 35, 28)
    },
    Arctic = {
        Background = Color3.fromRGB(10, 14, 18),
        ModuleBackground = Color3.fromRGB(18, 26, 34),
        Accent = Color3.fromRGB(180, 230, 255),
        SecondaryAccent = Color3.fromRGB(220, 245, 255),
        Text = Color3.fromRGB(240, 250, 255),
        TextDark = Color3.fromRGB(160, 195, 220),
        Highlight = Color3.fromRGB(100, 190, 235),
        Stroke = Color3.fromRGB(40, 75, 105)
    },
    Void = {
        Background = Color3.fromRGB(5, 3, 10),
        ModuleBackground = Color3.fromRGB(10, 6, 20),
        Accent = Color3.fromRGB(200, 50, 255),
        SecondaryAccent = Color3.fromRGB(230, 130, 255),
        Text = Color3.fromRGB(248, 240, 255),
        TextDark = Color3.fromRGB(175, 145, 210),
        Highlight = Color3.fromRGB(155, 0, 220),
        Stroke = Color3.fromRGB(65, 22, 90)
    },
    Dusk = {
        Background = Color3.fromRGB(10, 8, 14),
        ModuleBackground = Color3.fromRGB(20, 16, 28),
        Accent = Color3.fromRGB(200, 140, 255),
        SecondaryAccent = Color3.fromRGB(255, 180, 220),
        Text = Color3.fromRGB(250, 245, 255),
        TextDark = Color3.fromRGB(185, 165, 210),
        Highlight = Color3.fromRGB(155, 90, 230),
        Stroke = Color3.fromRGB(65, 45, 90)
    },
    Lava = {
        Background = Color3.fromRGB(12, 5, 4),
        ModuleBackground = Color3.fromRGB(24, 10, 8),
        Accent = Color3.fromRGB(255, 80, 40),
        SecondaryAccent = Color3.fromRGB(255, 155, 60),
        Text = Color3.fromRGB(255, 242, 235),
        TextDark = Color3.fromRGB(210, 160, 140),
        Highlight = Color3.fromRGB(210, 40, 10),
        Stroke = Color3.fromRGB(95, 28, 18)
    },
    Steel = {
        Background = Color3.fromRGB(10, 12, 14),
        ModuleBackground = Color3.fromRGB(20, 24, 28),
        Accent = Color3.fromRGB(140, 175, 210),
        SecondaryAccent = Color3.fromRGB(185, 210, 235),
        Text = Color3.fromRGB(230, 238, 245),
        TextDark = Color3.fromRGB(150, 168, 190),
        Highlight = Color3.fromRGB(90, 130, 175),
        Stroke = Color3.fromRGB(42, 55, 70)
    },
    Toxic = {
        Background = Color3.fromRGB(6, 10, 5),
        ModuleBackground = Color3.fromRGB(10, 18, 8),
        Accent = Color3.fromRGB(130, 255, 60),
        SecondaryAccent = Color3.fromRGB(190, 255, 120),
        Text = Color3.fromRGB(235, 255, 228),
        TextDark = Color3.fromRGB(140, 205, 120),
        Highlight = Color3.fromRGB(85, 210, 20),
        Stroke = Color3.fromRGB(28, 68, 18)
    },
    Blush = {
        Background = Color3.fromRGB(14, 10, 11),
        ModuleBackground = Color3.fromRGB(28, 18, 20),
        Accent = Color3.fromRGB(255, 155, 170),
        SecondaryAccent = Color3.fromRGB(255, 200, 210),
        Text = Color3.fromRGB(255, 245, 247),
        TextDark = Color3.fromRGB(215, 175, 182),
        Highlight = Color3.fromRGB(230, 90, 115),
        Stroke = Color3.fromRGB(90, 40, 50)
    },
    Dark = {
        Background = Color3.fromRGB(14, 14, 16),
        ModuleBackground = Color3.fromRGB(24, 24, 28),
        Accent = Color3.fromRGB(100, 150, 255),
        SecondaryAccent = Color3.fromRGB(160, 195, 255),
        Text = Color3.fromRGB(245, 245, 252),
        TextDark = Color3.fromRGB(150, 155, 175),
        Highlight = Color3.fromRGB(60, 110, 230),
        Stroke = Color3.fromRGB(50, 52, 70)
    },
    Light = {
        Background = Color3.fromRGB(242, 243, 248),
        ModuleBackground = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(60, 120, 255),
        SecondaryAccent = Color3.fromRGB(30, 80, 220),
        Text = Color3.fromRGB(20, 20, 35),
        TextDark = Color3.fromRGB(90, 95, 120),
        Highlight = Color3.fromRGB(40, 95, 240),
        Stroke = Color3.fromRGB(200, 205, 220)
    },
    Glass = {
        Background = Color3.fromRGB(18, 20, 28),
        ModuleBackground = Color3.fromRGB(30, 32, 44),
        Accent = Color3.fromRGB(120, 180, 255),
        SecondaryAccent = Color3.fromRGB(180, 215, 255),
        Text = Color3.fromRGB(240, 244, 255),
        TextDark = Color3.fromRGB(155, 165, 200),
        Highlight = Color3.fromRGB(80, 145, 240),
        Stroke = Color3.fromRGB(80, 90, 130)
    },
    Aurora = {
        Background = Color3.fromRGB(7, 12, 14),
        ModuleBackground = Color3.fromRGB(13, 22, 26),
        Accent = Color3.fromRGB(45, 220, 180),
        SecondaryAccent = Color3.fromRGB(130, 150, 255),
        Text = Color3.fromRGB(230, 255, 250),
        TextDark = Color3.fromRGB(140, 190, 180),
        Highlight = Color3.fromRGB(20, 170, 140),
        Stroke = Color3.fromRGB(25, 60, 60)
    },
    Velvet = {
        Background = Color3.fromRGB(12, 7, 14),
        ModuleBackground = Color3.fromRGB(24, 15, 28),
        Accent = Color3.fromRGB(205, 70, 190),
        SecondaryAccent = Color3.fromRGB(255, 150, 220),
        Text = Color3.fromRGB(250, 240, 252),
        TextDark = Color3.fromRGB(190, 160, 195),
        Highlight = Color3.fromRGB(150, 40, 150),
        Stroke = Color3.fromRGB(60, 30, 65)
    },
    Solstice = {
        Background = Color3.fromRGB(13, 9, 6),
        ModuleBackground = Color3.fromRGB(26, 18, 12),
        Accent = Color3.fromRGB(255, 150, 60),
        SecondaryAccent = Color3.fromRGB(255, 205, 110),
        Text = Color3.fromRGB(255, 246, 232),
        TextDark = Color3.fromRGB(205, 175, 140),
        Highlight = Color3.fromRGB(210, 110, 30),
        Stroke = Color3.fromRGB(70, 45, 25)
    }
}

local ThemeMeta = {
    Midnight = {
        category = "Dark",
        desc = "Deep violet dark"
    },
    Rose = {
        category = "Dark",
        desc = "Warm crimson bloom"
    },
    Sapphire = {
        category = "Dark",
        desc = "Cool electric blue"
    },
    Emerald = {
        category = "Dark",
        desc = "Rich jewel green"
    },
    Obsidian = {
        category = "Premium",
        desc = "Gold on jet black"
    },
    Glacier = {
        category = "Premium",
        desc = "Icy arctic blue"
    },
    Crimson = {
        category = "Premium",
        desc = "Dramatic deep red"
    },
    Amber = {
        category = "Premium",
        desc = "Warm amber glow"
    },
    Cyber = {
        category = "Neon",
        desc = "Terminal matrix green"
    },
    Neon = {
        category = "Neon",
        desc = "Synthwave vibes"
    },
    Sunset = {
        category = "Neon",
        desc = "Warm dusk orange"
    },
    Sakura = {
        category = "Pastel",
        desc = "Soft cherry blossom"
    },
    Monochrome = {
        category = "Minimal",
        desc = "Pure grayscale"
    },
    Ash = {
        category = "Minimal",
        desc = "Cool blue-grey"
    },
    Forest = {
        category = "Nature",
        desc = "Deep woodland green"
    },
    Ocean = {
        category = "Nature",
        desc = "Oceanic deep blue"
    },
    Lavender = {
        category = "Pastel",
        desc = "Soft lilac dream"
    },
    Coffee = {
        category = "Warm",
        desc = "Rich espresso tones"
    },
    Mint = {
        category = "Pastel",
        desc = "Cool minty fresh"
    },
    Pink = {
        category = "Pastel",
        desc = "Vibrant hot pink"
    },
    Purple = {
        category = "Dark",
        desc = "Royal amethyst"
    },
    Abyss = {
        category = "Dark",
        desc = "Bottomless deep blue"
    },
    Vanta = {
        category = "Minimal",
        desc = "Absolute black"
    },
    Coral = {
        category = "Warm",
        desc = "Vibrant coral reef"
    },
    Arctic = {
        category = "Nature",
        desc = "Frozen tundra white"
    },
    Void = {
        category = "Neon",
        desc = "Ultraviolet darkness"
    },
    Dusk = {
        category = "Pastel",
        desc = "Twilight purple haze"
    },
    Lava = {
        category = "Neon",
        desc = "Molten fire red"
    },
    Steel = {
        category = "Minimal",
        desc = "Industrial blue-grey"
    },
    Toxic = {
        category = "Neon",
        desc = "Radioactive lime"
    },
    Blush = {
        category = "Pastel",
        desc = "Warm rosy pink"
    },
    Dark = {
        category = "Minimal",
        desc = "Clean dark default"
    },
    Light = {
        category = "Minimal",
        desc = "Bright light mode"
    },
    Glass = {
        category = "Premium",
        desc = "Translucent glass panel"
    },
    Aurora = {
        category = "Nature",
        desc = "Teal aurora glow"
    },
    Velvet = {
        category = "Premium",
        desc = "Rich plum magenta"
    },
    Solstice = {
        category = "Warm",
        desc = "Golden sunrise glow"
    }
}

local DefaultThemeName = "Midnight"
local ThemeVersion = 2

local Connections = setmetatable({}, {
    __index = {
        disconnect = function(self, connectionName)
            if not self[connectionName] then
                return
            end
            self[connectionName]:Disconnect()
            self[connectionName] = nil
        end,
        disconnect_all = function(self)
            for _, connection in self do
                if typeof(connection) ~= "function" then
                    connection:Disconnect()
                end
            end
        end
    }
})

local Library = {
    _all_modules = {},
    _config = nil,
    _choosing_keybind = false,
    _blocking_drag = false,
    _device = nil,
    _ui_open = true,
    _ui_scale = 1,
    _ui_loaded = false,
    _ui = nil,
    _dragging = false,
    _drag_start = nil,
    _container_position = nil,
    _tab = 0,
    _active_tab_ref = nil,
    _theme_container = nil,
    _container_uiscale = nil,
    _theme_pending = false,
    _theme_debounce = nil,
    _flag_appliers = {},
    _flag_apply_order = {},
    _late_flag_order = {},
    _keybind_appliers = {},
    _applying_config = false
}

Library.__index = Library

getgenv().GG = {Language = Language}

local Icons = loadstring(game:HttpGet(IconsUrl))()

local function ResolveIcon(iconName)
    if not iconName then
        return ""
    end
    if iconName:find("rbxassetid://") then
        return iconName
    end
    return Icons[iconName] or ""
end

DestroyPreviousInterface()

if not isfolder(ConfigFolderName) then
    makefolder(ConfigFolderName)
end

if not isfolder(ConfigsFolderName) then
    makefolder(ConfigsFolderName)
end

local ConfigStore = {}
ConfigStore.__index = ConfigStore

function ConfigStore:save(fileName, configData)
    self._pending_saves = self._pending_saves or {}
    self._pending_saves[fileName] = configData
    if self._save_scheduled then
        return
    end
    self._save_scheduled = true
    task.delay(0.15, function()
        self._save_scheduled = false
        self:flush()
    end)
end

function ConfigStore:flush()
    local pendingSaves = self._pending_saves
    if not pendingSaves then
        return
    end
    self._pending_saves = nil
    for fileName, configData in pairs(pendingSaves) do
        local success, errorMessage = pcall(function()
            writefile(ConfigFolderName .. "/" .. fileName .. ".json", HttpService:JSONEncode(configData))
        end)
        if not success then
            warn("failed to save config", errorMessage)
        end
    end
end

function ConfigStore:load(fileName)
    local success, loadedData = pcall(function()
        local filePath = ConfigFolderName .. "/" .. fileName .. ".json"
        if not isfile(filePath) then
            return nil
        end
        local fileContents = readfile(filePath)
        if not fileContents then
            return nil
        end
        return HttpService:JSONDecode(fileContents)
    end)
    if not success then
        warn("failed to load config", loadedData)
    end
    if type(loadedData) ~= "table" then
        loadedData = {_flags = {}, _keybinds = {}, _library = {}}
        self:save(fileName, loadedData)
    else
        loadedData._flags = type(loadedData._flags) == "table" and loadedData._flags or {}
        loadedData._keybinds = type(loadedData._keybinds) == "table" and loadedData._keybinds or {}
        loadedData._library = type(loadedData._library) == "table" and loadedData._library or {}
    end
    return loadedData
end

function ConfigStore:save_named(configName, configData)
    local success, errorMessage = pcall(function()
        writefile(ConfigsFolderName .. "/" .. configName .. ".json", HttpService:JSONEncode(configData))
    end)
    if not success then
        warn("failed to save named config", errorMessage)
    end
    return success
end

function ConfigStore:load_named(configName)
    local success, loadedData = pcall(function()
        local filePath = ConfigsFolderName .. "/" .. configName .. ".json"
        if not isfile(filePath) then
            return nil
        end
        local fileContents = readfile(filePath)
        if not fileContents then
            return nil
        end
        return HttpService:JSONDecode(fileContents)
    end)
    if not success then
        warn("failed to load named config", loadedData)
    end
    if not success or type(loadedData) ~= "table" then
        return nil
    end
    return loadedData
end

function ConfigStore:delete_named(configName)
    local success, errorMessage = pcall(function()
        local filePath = ConfigsFolderName .. "/" .. configName .. ".json"

        if isfile(filePath) then
            delfile(filePath)
        end
    end)

    if not success then
        warn("failed to delete named config", errorMessage)
    end

    return success
end

function ConfigStore:list_named()
    local configNames = {}

    local success, errorMessage = pcall(function()
        for _, filePath in ipairs(listfiles(ConfigsFolderName)) do
            local configName = filePath:match("([^/\\]+)%.json$")

            if configName then
                table.insert(configNames, configName)
            end
        end
    end)

    if not success then
        warn("failed to list configs", errorMessage)
    end

    return configNames
end

local function LoadInitialConfig()
    local loadedConfig = ConfigStore:load(game.GameId)
    local autoloadName = loadedConfig._flags._autoloadEnabled and loadedConfig._flags._autoloadName or nil

    if autoloadName and autoloadName ~= "" then
        local namedConfig = ConfigStore:load_named(autoloadName)

        if namedConfig then
            if type(namedConfig._flags) == "table" then
                namedConfig._flags._autoloadEnabled = true
                namedConfig._flags._autoloadName = autoloadName
                namedConfig._flags._selCfg = autoloadName
                loadedConfig._flags = namedConfig._flags
            end

            if type(namedConfig._keybinds) == "table" then
                loadedConfig._keybinds = namedConfig._keybinds
            end

            if type(namedConfig._window_x) == "number" and type(namedConfig._window_y) == "number" then
                loadedConfig._window_x = namedConfig._window_x
                loadedConfig._window_y = namedConfig._window_y
            end
        end
    end

    return loadedConfig
end

local function SaveConfig()
    ConfigStore:save(game.GameId, Library._config)
end

local function LerpColor(startColor, endColor, alpha)
    return Color3.new(
        startColor.R + (endColor.R - startColor.R) * alpha,
        startColor.G + (endColor.G - startColor.G) * alpha,
        startColor.B + (endColor.B - startColor.B) * alpha
    )
end

local function IsLightTheme()
    local background = Colors.Background
    return background.R * 0.299 + background.G * 0.587 + background.B * 0.114 > 0.55
end

local function DeriveStrokeHot(stroke)
    if IsLightTheme() then
        return Color3.new(stroke.R * 0.84, stroke.G * 0.78, stroke.B * 0.82)
    end

    return Color3.new(
        math.clamp(stroke.R * 1.2 + 0.05, 0, 1),
        math.clamp(stroke.G * 1.2 + 0.05, 0, 1),
        math.clamp(stroke.B * 1.22 + 0.06, 0, 1)
    )
end

local function DeriveAccentDim(accent)
    if IsLightTheme() then
        return Color3.new(accent.R * 0.5 + 0.5, accent.G * 0.5 + 0.5, accent.B * 0.5 + 0.5)
    end

    return Color3.new(
        math.clamp(accent.R * 0.42, 0, 1),
        math.clamp(accent.G * 0.42, 0, 1),
        math.clamp(accent.B * 0.48, 0, 1)
    )
end

local function DeriveCardDeep(card)
    if IsLightTheme() then
        return Color3.new(card.R * 0.95, card.G * 0.93, card.B * 0.95)
    end

    return Color3.new(card.R * 0.78, card.G * 0.78, card.B * 0.8)
end

local function DeriveToggleOffColor(card)
    if IsLightTheme() then
        return Color3.new(card.R * 0.84, card.G * 0.8, card.B * 0.84)
    end

    return Color3.new(
        math.clamp(card.R * 0.48, 0, 1),
        math.clamp(card.G * 0.48, 0, 1),
        math.clamp(card.B * 0.52, 0, 1)
    )
end

local function RefreshDerivedColors(changedColorName)
    local refreshAll = changedColorName == nil or changedColorName == "Background"

    if refreshAll or changedColorName == "Stroke" then
        Colors.StrokeHot = DeriveStrokeHot(Colors.Stroke)
    end

    if refreshAll or changedColorName == "Accent" then
        Colors.AccentDim = DeriveAccentDim(Colors.Accent)
    end

    if refreshAll or changedColorName == "Card" then
        Colors.CardDeep = DeriveCardDeep(Colors.Card)
    end
end

local function ApplySavedColors()
    local guiConfig = Library._config._gui

    if guiConfig and guiConfig.colors then
        for colorName, savedColor in pairs(guiConfig.colors) do
            if type(savedColor) == "table" and savedColor.H ~= nil and Colors[colorName] then
                Colors[colorName] = Color3.fromHSV(savedColor.H, savedColor.S, savedColor.V)
            end
        end
    end

    RefreshDerivedColors()
end

local function CreateAccentColorSequence()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.AccentSoft),
        ColorSequenceKeypoint.new(1, Colors.AccentDim)
    })
end

local function CreateTitleGradientSequence()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.AccentSoft),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(1, Colors.AccentSoft)
    })
end

local function CreateModuleTitleGradientSequence()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Text),
        ColorSequenceKeypoint.new(0.55, LerpColor(Colors.Text, Colors.AccentSoft, 0.55)),
        ColorSequenceKeypoint.new(1, Colors.AccentSoft)
    })
end

local function CreateStrokeGradientSequence()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Accent),
        ColorSequenceKeypoint.new(0.5, Colors.StrokeHot),
        ColorSequenceKeypoint.new(1, Colors.Accent)
    })
end

local function CreateTabLabelGradientSequence()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Text),
        ColorSequenceKeypoint.new(0.65, LerpColor(Colors.Text, Colors.SubText, 0.45)),
        ColorSequenceKeypoint.new(1, LerpColor(Colors.Text, Colors.SubText, 0.78))
    })
end

local ThemeBindings = {}
local ThemeHooks = {}
local ThemeSequences = {}

local function BindTheme(instance, properties)
    local existingBinding = ThemeBindings[instance]

    if existingBinding then
        for propertyName, source in pairs(properties) do
            existingBinding[propertyName] = source
        end

        return instance
    end

    ThemeBindings[instance] = properties
    return instance
end

local function BindThemeHook(owner, callback)
    ThemeHooks[owner] = callback

    owner.Destroying:Connect(function()
        ThemeHooks[owner] = nil
    end)
end

local function ApplyThemeBindings()
    ThemeSequences.AccentSequence = CreateAccentColorSequence()
    ThemeSequences.TitleSequence = CreateTitleGradientSequence()
    ThemeSequences.ModuleTitleSequence = CreateModuleTitleGradientSequence()
    ThemeSequences.StrokeSequence = CreateStrokeGradientSequence()

    for instance, properties in pairs(ThemeBindings) do
        if instance.Parent then
            for propertyName, source in pairs(properties) do
                if type(source) == "function" then
                    instance[propertyName] = source()
                else
                    instance[propertyName] = Colors[source] or ThemeSequences[source]
                end
            end
        else
            ThemeBindings[instance] = nil
        end
    end

    for _, callback in pairs(ThemeHooks) do
        callback()
    end
end

local function CreateDepthGradient(parent, darkness)
    local shade = 1 - (darkness or 0.12)

    return CreateInstance("UIGradient", {
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(shade, shade, shade)),
        Rotation = 90,
        Parent = parent
    })
end

local function CreateHueColorSequence()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1))
    })
end

local function CreateFadeGradient(parent, rotation)
    return CreateInstance("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation = rotation,
        Parent = parent
    })
end

local function CreateEdgeFadeGradient(parent, edgeStop, rotation)
    return CreateInstance("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(edgeStop, 0),
            NumberSequenceKeypoint.new(1 - edgeStop, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation = rotation,
        Parent = parent
    })
end

local function CreateTextFadeGradient(parent)
    return CreateInstance("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.704, 0),
            NumberSequenceKeypoint.new(0.872, 0.36),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Parent = parent
    })
end

local function CreateLabelText(parent, properties)
    properties.BackgroundTransparency = 1
    properties.Parent = parent
    return CreateInstance("TextLabel", properties)
end

local function ApplyRichOrPlainText(label, options)
    if options.rich then
        label.RichText = true
        label.Text = options.richtext or ""
    else
        label.Text = options.text or ""
    end
end

Library._config = LoadInitialConfig()

local GuiConfig = Library._config._gui

if not GuiConfig then
    GuiConfig = {}
    Library._config._gui = GuiConfig
end

if GuiConfig.toggle_key == nil then
    GuiConfig.toggle_key = DefaultToggleKey
end

if GuiConfig.hide_minimized == nil then
    GuiConfig.hide_minimized = false
end

if GuiConfig.bg_transparency == nil then
    GuiConfig.bg_transparency = DefaultBackgroundTransparency
end

if GuiConfig.theme_version ~= ThemeVersion then
    GuiConfig.theme = DefaultThemeName
    GuiConfig.colors = nil
    GuiConfig.theme_version = ThemeVersion
end

if GuiConfig.font then
    local success, savedFont = pcall(function()
        return Enum.Font[GuiConfig.font]
    end)

    if success and savedFont then
        SetThemeFont(savedFont)
    end
end

ApplySavedColors()

local NotificationScreenGui = CreateScreenGui()
NotificationScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local NotificationHolder = CreateInstance("Frame", {
    Size = UDim2.new(0, 330, 1, -40),
    Position = UDim2.new(0, 18, 1, -20),
    AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1,
    ClipsDescendants = false,
    Parent = NotificationScreenGui
})

CreateInstance("UIListLayout", {
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 10),
    Parent = NotificationHolder
})

local NotificationScale = CreateInstance("UIScale", {Parent = NotificationHolder})

function Library.SendNotification(options)
    if Library._applying_config then
        return
    end

    local duration = options.duration or 4
    local iconColor = options.iconColor or Colors.Accent

    local notificationSlot = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundTransparency = 1,
        Parent = NotificationHolder
    })

    local notificationCard = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = notificationSlot
    })

    AddCorner(notificationCard, 8)
    AddStroke(notificationCard, Colors.StrokeHot, 0.5, true)
    CreateDepthGradient(notificationCard, 0.1)

    local headerGlow = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = iconColor,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Parent = notificationCard
    })

    AddCorner(headerGlow, 8)
    CreateFadeGradient(headerGlow, 90)

    local iconBackground = CreateInstance("Frame", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 13, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = iconColor,
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
        Parent = notificationCard
    })

    AddCorner(iconBackground, 6)

    CreateInstance("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = ResolveIcon(options.icon),
        ImageColor3 = iconColor,
        Parent = iconBackground
    })

    CreateInstance("TextLabel", {
        Text = options.title or "Notification",
        FontFace = CreateGothamFont(Enum.FontWeight.Bold),
        TextSize = 13,
        TextColor3 = Colors.Text,
        TextTransparency = 0,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0, 9),
        Size = UDim2.new(1, -60, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notificationCard
    })

    CreateInstance("TextLabel", {
        Text = options.text or "",
        FontFace = CreateGothamFont(Enum.FontWeight.Regular),
        TextSize = 11,
        TextColor3 = Colors.SubText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0, 27),
        Size = UDim2.new(1, -60, 0, 28),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notificationCard
    })

    local progressTrack = CreateInstance("Frame", {
        Size = UDim2.new(1, -24, 0, 3),
        Position = UDim2.new(0, 12, 1, -5),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Colors.Stroke,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = notificationCard
    })

    AddCorner(progressTrack, 2)

    local progressFill = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = iconColor,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = progressTrack
    })

    AddCorner(progressFill, 2)

    if UIFontScale ~= 1 then
        ApplyThemeFont(notificationSlot)
    end

    local offscreenPosition = UDim2.new(-1.08, 0, 0, 0)
    notificationCard.Position = offscreenPosition

    PlayTween(
        notificationCard,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 0)}
    )

    PlayTween(
        progressFill,
        TweenInfo.new(duration - 0.04, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 1, 0)}
    )

    task.delay(duration, function()
        PlayTween(
            notificationCard,
            TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {Position = offscreenPosition}
        )

        task.delay(0.4, function()
            notificationSlot:Destroy()
        end)
    end)
end

function Library:get_screen_scale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewportSize = camera.ViewportSize

    if viewportSize.X < 200 or viewportSize.Y < 200 then
        return
    end

    local isTouch = self._device == "Mobile"
    local widthRatio = viewportSize.X / 1400
    local baseScale = 1

    if isTouch then
        baseScale = math.clamp(widthRatio * 0.97, 0.68, 0.9)
    elseif self._device == "Unknown" then
        baseScale = math.clamp(widthRatio, 0.5, 1.2)
    end

    local heightRatio = isTouch and MobileWindowHeightRatio or MaxWindowHeightRatio

    local fitScale = math.min(
        viewportSize.X * MaxWindowWidthRatio / OpenWindowSize.X.Offset,
        viewportSize.Y * heightRatio / OpenWindowSize.Y.Offset
    )

    self._viewport_size = viewportSize
    self._ui_scale = math.clamp(math.min(baseScale, fitScale), MinWindowScale, 1.2)
    NotificationScale.Scale = math.clamp(fitScale, MinNotificationScale, 1)
end

function Library:get_device()
    if not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        self._device = "PC"
    elseif UserInputService.TouchEnabled then
        self._device = "Mobile"
    elseif UserInputService.GamepadEnabled then
        self._device = "Console"
    else
        self._device = "Unknown"
    end
end

function Library:removed(callback)
    self._ui.AncestryChanged:Once(callback)
end

function Library:flag_type(flagName, expectedType)
    if Library._config._flags[flagName] == nil then
        return
    end

    return typeof(Library._config._flags[flagName]) == expectedType
end

function Library:register_flag(flagName, applier, applyLast)
    if not Library._flag_appliers[flagName] then
        table.insert(applyLast and Library._late_flag_order or Library._flag_apply_order, flagName)
    end

    Library._flag_appliers[flagName] = applier
end

function Library:apply_flags(newFlags)
    Library._applying_config = true

    local function ApplyFlag(flagName)
        local flagValue = newFlags[flagName]

        if flagValue == nil then
            return
        end

        local success, errorMessage = pcall(Library._flag_appliers[flagName], flagValue)

        if not success then
            warn("failed to apply flag", flagName, errorMessage)
        end
    end

    for _, flagName in ipairs(Library._flag_apply_order) do
        ApplyFlag(flagName)
    end

    for _, flagName in ipairs(Library._late_flag_order) do
        ApplyFlag(flagName)
    end

    for flagName, flagValue in pairs(newFlags) do
        if not Library._flag_appliers[flagName] then
            Library._config._flags[flagName] = flagValue
        end
    end

    Library._applying_config = false
end

function Library:apply_keybinds(newKeybinds)
    Library._config._keybinds = newKeybinds

    for flagName, applier in pairs(Library._keybind_appliers) do
        local success, errorMessage = pcall(applier)

        if not success then
            warn("failed to apply keybind", flagName, errorMessage)
        end
    end
end

function Library:arm_confirm_button(buttonGroup, buttonIndex, action)
    local isArmed = false
    local resetThread
    local originalText = buttonGroup._buttons[buttonIndex] and buttonGroup._buttons[buttonIndex].Text or "Delete"

    local function Disarm()
        isArmed = false
        resetThread = nil
        buttonGroup:set_button_text(buttonIndex, originalText)
        buttonGroup:set_button_color(buttonIndex, nil)
    end

    buttonGroup:set_button_callback(buttonIndex, function()
        if isArmed then
            if resetThread then
                task.cancel(resetThread)
            end

            Disarm()
            action()
            return
        end

        isArmed = true
        buttonGroup:set_button_text(buttonIndex, "Confirm?")
        buttonGroup:set_button_color(buttonIndex, Colors.Danger)
        resetThread = task.delay(3, Disarm)
    end)
end

function Library.new()
    local window = setmetatable({}, Library)
    window:create_ui()
    return window
end

local function AddCardHoverEffect(card)
    card.MouseEnter:Connect(function()
        PlayTween(card, CreateQuintOutTweenInfo(0.25), {
            BackgroundColor3 = LerpColor(Colors.CardDeep, Colors.Accent, 0.1),
            BackgroundTransparency = 0.08
        })
    end)

    card.MouseLeave:Connect(function()
        PlayTween(card, CreateQuintOutTweenInfo(0.25), {
            BackgroundColor3 = Colors.CardDeep,
            BackgroundTransparency = 0.15
        })
    end)
end

local function CreateSliderTrack(parent, size, isActive)
    local track = CreateInstance("Frame", {
        Active = isActive,
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 0.78,
        Position = UDim2.new(0.5, 0, 0.95, 0),
        Name = "Drag",
        Size = size,
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.Stroke,
        Parent = parent
    })

    AddCorner(track, 12)
    BindTheme(track, {BackgroundColor3 = "Stroke"})
    return track
end

local function CreateSliderFill(track, size)
    local fill = CreateInstance("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0, 0, 0.5, 0),
        Name = "Fill",
        Size = size,
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.Accent,
        Parent = track
    })

    AddCorner(fill, 3)

    local fillGradient = CreateInstance("UIGradient", {
        Color = CreateAccentColorSequence(),
        Parent = fill
    })

    local circle = CreateInstance("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Name = "Circle",
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 7, 0, 7),
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.AccentSoft,
        Parent = fill
    })

    AddCorner(circle, 12)
    BindTheme(fill, {BackgroundColor3 = "Accent"})
    BindTheme(fillGradient, {Color = "AccentSequence"})
    BindTheme(circle, {BackgroundColor3 = "AccentSoft"})
    return fill
end

local function CreateSliderValueLabel(parent, width, textSize, text)
    local valueLabel = CreateInstance("TextLabel", {
        FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
        TextColor3 = Colors.Text,
        TextTransparency = 0.2,
        Text = text,
        Name = "Value",
        Size = UDim2.new(0, width, 0, 13),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = textSize,
        Parent = parent
    })

    BindTheme(valueLabel, {TextColor3 = "Text"})
    return valueLabel
end

local function CreateSliderTitleLabel(parent, width, text)
    local titleLabel = CreateInstance("TextLabel", {
        FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
        TextSize = 11,
        TextColor3 = Colors.Text,
        TextTransparency = 0.16,
        Text = text,
        Size = UDim2.new(0, width, 0, 13),
        Position = UDim2.new(0, 0, 0.05, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent
    })

    BindTheme(titleLabel, {TextColor3 = "Text"})
    return titleLabel
end

local function CreateColorPickerPanel(panel, hue, saturation, value)
    local saturationValueBox = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        Position = UDim2.new(0, 0, 0, 4),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
        ClipsDescendants = true,
        Parent = panel
    })

    AddCorner(saturationValueBox, 7)

    local whiteOverlay = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = saturationValueBox
    })

    CreateFadeGradient(whiteOverlay)

    local blackOverlay = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = saturationValueBox
    })

    CreateInstance("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 90,
        Parent = blackOverlay
    })

    local saturationValueCursor = CreateInstance("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 5,
        Visible = false,
        Position = UDim2.new(saturation, 0, 1 - value, 0),
        Parent = saturationValueBox
    })

    AddCorner(saturationValueCursor, UDim.new(1, 0))

    local saturationValueCursorDot = CreateInstance("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = saturationValueCursor
    })

    AddCorner(saturationValueCursorDot, UDim.new(1, 0))

    local hueBar = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 0, 72),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = panel
    })

    AddCorner(hueBar, 5)

    CreateInstance("UIGradient", {
        Color = CreateHueColorSequence(),
        Parent = hueBar
    })

    local hueCursor = CreateInstance("Frame", {
        Size = UDim2.new(0, 6, 1, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(hue, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 4,
        Visible = false,
        Parent = hueBar
    })

    AddCorner(hueCursor, 3)

    local hueCursorCore = CreateInstance("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = hueCursor
    })

    AddCorner(hueCursorCore, 2)
    return saturationValueBox, saturationValueCursor, hueBar, hueCursor
end

local function CreateColorPickerHeader(parent, options)
    local row = CreateInstance("TextButton", {
        Name = "Row",
        Size = options.rowSize,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = options.layoutOrder,
        Parent = parent
    })

    local rowTitle = CreateInstance("TextLabel", {
        Text = options.title,
        FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
        TextSize = 11,
        TextColor3 = Colors.Text,
        TextTransparency = options.titleTransparency,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, options.titleWidth, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    BindTheme(rowTitle, {TextColor3 = "Text"})

    local swatch = CreateInstance("Frame", {
        Name = "Swatch",
        Size = UDim2.new(0, 44, 0, 14),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromHSV(options.hue, options.saturation, options.value),
        Parent = row
    })

    AddCorner(swatch, 5)

    local swatchStroke = AddStroke(swatch, Colors.StrokeHot, options.swatchStrokeTransparency)

    BindTheme(swatchStroke, {Color = "StrokeHot"})

    local arrow = CreateInstance("TextLabel", {
        Name = "PickerArrow",
        Text = "\u{203A}",
        FontFace = CreateGothamFont(Enum.FontWeight.Bold),
        TextSize = 14,
        TextColor3 = Colors.Accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 12, 1, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -50, 0.5, 0),
        Rotation = 90,
        Parent = row
    })

    BindTheme(arrow, {TextColor3 = "Accent"})
    return row, swatch, arrow
end

function Library:create_ui()
    local window = self

    ApplySavedColors()

    local screenGui = CreateScreenGui()

    local container = CreateInstance("Frame", {
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Name = "Container",
        BackgroundTransparency = GuiConfig.bg_transparency or DefaultBackgroundTransparency,
        BackgroundColor3 = Colors.Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Active = true,
        BorderSizePixel = 0,
        Parent = screenGui
    })

    if Library._config._window_x and Library._config._window_y then
        container.Position = UDim2.new(0.5, Library._config._window_x, 0.5, Library._config._window_y)
    end

    AddCorner(container, 8)
    CreateDepthGradient(container, 0.14)

    local containerStroke = AddStroke(container, Color3.new(1, 1, 1), 0.42, true)

    local containerStrokeGradient = CreateInstance("UIGradient", {
        Color = CreateStrokeGradientSequence(),
        Rotation = 35,
        Parent = containerStroke
    })

    BindTheme(container, {BackgroundColor3 = "Background"})
    BindTheme(containerStrokeGradient, {Color = "StrokeSequence"})

    local handler = CreateInstance("Frame", {
        BackgroundTransparency = 1,
        Name = "Handler",
        Size = UDim2.new(0, 698, 0, 479),
        BorderSizePixel = 0,
        Parent = container
    })

    local searchFrame = CreateInstance("Frame", {
        Name = "Search",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -14, 0, 10),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Colors.CardDeep,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = handler
    })

    AddCorner(searchFrame, UDim.new(1, 0))

    local searchStroke = AddStroke(searchFrame, Colors.StrokeHot, 0.5)

    local searchIcon = CreateInstance("ImageButton", {
        Size = UDim2.new(0, 15, 0, 15),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ImageColor3 = Colors.Accent,
        BackgroundTransparency = 1,
        Image = ResolveIcon("search"),
        Parent = searchFrame
    })

    local searchBox = CreateInstance("TextBox", {
        Size = UDim2.new(1, -38, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundTransparency = 1,
        TextTransparency = 1,
        PlaceholderText = "Search modules...",
        PlaceholderColor3 = Colors.SubText,
        TextColor3 = Colors.Text,
        FontFace = CreateGothamFont(Enum.FontWeight.Regular),
        TextSize = 12,
        ClearTextOnFocus = false,
        Text = "",
        Parent = searchFrame
    })

    CreateInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 2),
        Parent = searchBox
    })

    BindTheme(searchFrame, {BackgroundColor3 = "CardDeep"})
    BindTheme(searchStroke, {Color = "StrokeHot"})
    BindTheme(searchIcon, {ImageColor3 = "Accent"})

    BindTheme(searchBox, {
        PlaceholderColor3 = "SubText",
        TextColor3 = "Text"
    })

    local isSearchExpanded = false

    searchIcon.MouseButton1Click:Connect(function()
        if isSearchExpanded then
            return
        end

        isSearchExpanded = true

        PlayTween(searchFrame, CreateQuintOutTweenInfo(0.45), {Size = UDim2.new(0, 200, 0, 32)})
        PlayTween(searchBox, TweenInfo.new(0.3), {TextTransparency = 0})

        task.delay(0.15, function()
            searchBox:CaptureFocus()
        end)
    end)

    searchBox.FocusLost:Connect(function()
        if searchBox.Text ~= "" then
            return
        end

        isSearchExpanded = false
        searchBox:ReleaseFocus()

        PlayTween(searchFrame, CreateQuintOutTweenInfo(0.45), {Size = UDim2.new(0, 32, 0, 32)})
        PlayTween(searchBox, TweenInfo.new(0.2), {TextTransparency = 1})
    end)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local searchQuery = searchBox.Text:lower()

        for _, moduleEntry in ipairs(Library._all_modules) do
            moduleEntry.frame.Visible = searchQuery == "" or moduleEntry.title:find(searchQuery, 1, true) ~= nil
        end
    end)

    local tabsList = CreateInstance("ScrollingFrame", {
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        Name = "Tabs",
        Size = UDim2.new(0, 129, 0, 440),
        Selectable = false,
        AutomaticCanvasSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.0261, 0, 0.16, 0),
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0.5, 0),
        Parent = handler
    })

    CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabsList
    })

    local function CreateHorizontalDivider(position, size)
        local divider = CreateInstance("Frame", {
            Name = "Divider",
            BackgroundTransparency = 0.38,
            BorderSizePixel = 0,
            BackgroundColor3 = Colors.Stroke,
            Position = position,
            Size = size,
            Parent = handler
        })

        CreateEdgeFadeGradient(divider, 0.3)
        BindTheme(divider, {BackgroundColor3 = "Stroke"})
    end

    CreateHorizontalDivider(UDim2.new(0.23, 0, 0.12, 0), UDim2.new(0, 450, 0, 1))
    CreateHorizontalDivider(UDim2.new(0, 0, 0.12, 0), UDim2.new(0, 157, 0, 1))

    local verticalDivider = CreateInstance("Frame", {
        BackgroundTransparency = 0.48,
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.Stroke,
        Position = UDim2.new(0.225, 0, 0.13, 0),
        Size = UDim2.new(0, 1, 0.78, 0),
        Parent = handler
    })

    CreateEdgeFadeGradient(verticalDivider, 0.15, 90)
    BindTheme(verticalDivider, {BackgroundColor3 = "Stroke"})

    local titleText = "closet.gg"
    local titleTextSize = 15
    local titleWidth = MeasureText(titleText, CreateGothamFont(Enum.FontWeight.Bold), titleTextSize).X
    local minimizedSize = UDim2.fromOffset(math.ceil(titleWidth) + 54, 40)
    local nameOpenPosition = UDim2.new(0.056, 0, 0.055, 0)
    local logoOpenPosition = UDim2.new(0.025, 0, 0.055, 0)
    local buttonOpenPosition = UDim2.new(0.0201, 0, 0.0292, 0)

    local clientNameLabel = CreateInstance("TextLabel", {
        FontFace = CreateGothamFont(Enum.FontWeight.Bold),
        TextColor3 = Color3.new(1, 1, 1),
        TextTransparency = 0,
        Text = titleText,
        Name = "ClientName",
        Size = UDim2.new(0, math.ceil(titleWidth) + 4, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = nameOpenPosition,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = titleTextSize,
        Parent = handler
    })

    local clientNameGradient = CreateInstance("UIGradient", {
        Color = CreateTitleGradientSequence(),
        Offset = Vector2.new(-0.5, 0),
        Parent = clientNameLabel
    })

    BindTheme(clientNameGradient, {Color = "TitleSequence"})

    PlayTween(
        clientNameGradient,
        TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Offset = Vector2.new(0.5, 0)}
    )

    local pinIndicator = CreateInstance("Frame", {
        Name = "Pin",
        Position = UDim2.new(0.026, 0, 0.136, 0),
        Size = UDim2.new(0, 2, 0, 16),
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.Accent,
        Visible = false,
        Parent = handler
    })

    AddCorner(pinIndicator, 12)
    BindTheme(pinIndicator, {BackgroundColor3 = "Accent"})

    local logo = CreateInstance("ImageLabel", {
        ScaleType = Enum.ScaleType.Fit,
        AnchorPoint = Vector2.new(0, 0.5),
        Image = "rbxassetid://99206841644167",
        BackgroundTransparency = 1,
        Position = logoOpenPosition,
        Name = "Icon",
        Size = UDim2.new(0, 18, 0, 18),
        BorderSizePixel = 0,
        ImageColor3 = Colors.AccentSoft,
        ImageRectSize = Vector2.new(32, 32),
        Parent = handler
    })

    BindTheme(logo, {ImageColor3 = "AccentSoft"})

    local sectionsFolder = CreateInstance("Folder", {
        Name = "Sections",
        Parent = handler
    })

    local minimizeButton = CreateInstance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Name = "Minimize",
        Position = buttonOpenPosition,
        Size = UDim2.new(0, 24, 0, 24),
        BorderSizePixel = 0,
        Parent = handler
    })

    local containerScale = CreateInstance("UIScale", {Parent = container})

    window._container_uiscale = containerScale
    window._ui = screenGui
    window._theme_container = container
    window._theme_tabs_ref = tabsList

    local function ClampContainerPosition()
        local viewportSize = window._viewport_size

        if not viewportSize then
            return
        end

        local slackX = math.max((viewportSize.X - OpenWindowSize.X.Offset * window._ui_scale) / 2, 0)
        local slackY = math.max((viewportSize.Y - OpenWindowSize.Y.Offset * window._ui_scale) / 2, 0)

        container.Position = UDim2.new(
            0.5,
            math.clamp(container.Position.X.Offset, -slackX, slackX),
            0.5,
            math.clamp(container.Position.Y.Offset, -slackY, slackY)
        )
    end

    local function BeginDrag(inputObject)
        if Library._blocking_drag then
            return
        end

        if not IsPrimaryPointerInput(inputObject) then
            return
        end

        window._dragging = true
        window._drag_start = inputObject.Position
        window._container_position = container.Position

        Connections.container_input_ended = inputObject.Changed:Connect(function()
            if inputObject.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Connections:disconnect("container_input_ended")
            window._dragging = false
        end)
    end

    local function UpdateDrag(inputObject)
        if not window._dragging or Library._blocking_drag then
            return
        end

        if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement
            and inputObject.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local dragDelta = inputObject.Position - window._drag_start
        local startPosition = window._container_position

        container.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + dragDelta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + dragDelta.Y
        )
    end

    Connections.container_input_began = container.InputBegan:Connect(BeginDrag)
    Connections.input_changed = UserInputService.InputChanged:Connect(UpdateDrag)

    window:removed(function()
        window._ui = nil
        Connections:disconnect_all()

        if window._floating_gui then
            window._floating_gui:Destroy()
            window._floating_gui = nil
        end
    end)

    function window:Update1Run(transparencyValue)
        if transparencyValue == "nil" then
            container.BackgroundTransparency = DefaultBackgroundTransparency
        else
            pcall(function()
                container.BackgroundTransparency = tonumber(transparencyValue)
            end)
        end
    end

    function window:UIVisiblity()
        screenGui.Enabled = not screenGui.Enabled
    end

    function window:refresh_title_layout()
        task.spawn(function()
            titleWidth = MeasureText(titleText, CreateGothamFont(Enum.FontWeight.Bold), titleTextSize).X
            clientNameLabel.Size = UDim2.new(0, math.ceil(titleWidth) + 4, 0, 18)
            minimizedSize = UDim2.fromOffset(math.ceil(titleWidth) + 54, 40)

            if not window._ui_open then
                PlayTween(container, CreateQuintOutTweenInfo(0.4), {Size = minimizedSize})
            end
        end)
    end

    local function LayoutTitle(isOpening)
        local tweenInfo = CreateQuintOutTweenInfo(0.5)

        if isOpening then
            PlayTween(logo, tweenInfo, {Position = logoOpenPosition})
            PlayTween(clientNameLabel, tweenInfo, {Position = nameOpenPosition})
            PlayTween(minimizeButton, tweenInfo, {Position = buttonOpenPosition})
        else
            PlayTween(logo, tweenInfo, {Position = UDim2.fromOffset(14, 20)})
            PlayTween(clientNameLabel, tweenInfo, {Position = UDim2.fromOffset(40, 20)})
            PlayTween(minimizeButton, tweenInfo, {Position = UDim2.fromOffset(8, 8)})
        end
    end

    function window:change_visiblity(isOpening)
        self._vis_seq = (self._vis_seq or 0) + 1
        local visibilitySequence = self._vis_seq
        local isClosing = not isOpening
        local hideWhenMinimized = self._device == "PC" and GuiConfig.hide_minimized
        local targetScale = self._ui_scale or 1

        if isClosing and hideWhenMinimized then
            if containerScale then
                PlayTween(
                    containerScale,
                    TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    {Scale = 0.04}
                )

                task.delay(0.36, function()
                    if visibilitySequence ~= self._vis_seq then
                        return
                    end

                    if not self._ui_open then
                        screenGui.Enabled = false
                        containerScale.Scale = targetScale
                    end
                end)
            else
                screenGui.Enabled = false
            end

            return
        end

        local wasHidden = not screenGui.Enabled
        screenGui.Enabled = true

        if isOpening and containerScale then
            containerScale.Scale = wasHidden and 0.04 or targetScale * 0.94

            PlayTween(
                containerScale,
                TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Scale = targetScale}
            )
        end

        PlayTween(container, CreateQuintOutTweenInfo(0.5), {
            Size = isOpening and OpenWindowSize or minimizedSize
        })

        LayoutTitle(isOpening)
    end

    function window:get_floating_gui()
        if not self._floating_gui then
            self._floating_gui = CreateInstance("ScreenGui", {
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                DisplayOrder = 10,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                Parent = GetInterfaceParent()
            })

            self._floating_gui:SetAttribute(MarkerAttributeName, GenerateRandomString(math.random(14, 22)))
        end

        return self._floating_gui
    end

    function window:get_saved_position(positionKey)
        if not Library._config._library then
            Library._config._library = {}
        end

        local savedPosition = positionKey and Library._config._library[positionKey]

        if type(savedPosition) == "table" and savedPosition.x and savedPosition.y then
            return UDim2.fromScale(savedPosition.x, savedPosition.y)
        end

        return nil
    end

    function window:save_position(positionKey, position)
        if positionKey then
            Library._config._library[positionKey] = {x = position.X.Scale, y = position.Y.Scale}
            SaveConfig()
        end
    end

    function window:create_floating_button(buttonOptions)
        buttonOptions = buttonOptions or {}

        local minimumSize = buttonOptions.minimum_size or 32
        local maximumSize = buttonOptions.maximum_size or 96
        local buttonSize = math.clamp(buttonOptions.size or 52, minimumSize, maximumSize)
        local positionKey = buttonOptions.flag and buttonOptions.flag .. "_floating"
        local startPosition = buttonOptions.position or UDim2.fromScale(0.94, 0.45)
        local cornerRadius = buttonOptions.corner_radius
        local bodyRadius = cornerRadius and UDim.new(0, cornerRadius) or UDim.new(1, 0)
        local haloRadius = cornerRadius and UDim.new(0.127, cornerRadius) or bodyRadius
        local pingRadius = cornerRadius and UDim.new(0.206, cornerRadius) or bodyRadius
        local isToggled = false

        startPosition = self:get_saved_position(positionKey) or startPosition

        local floatingGui = self:get_floating_gui()

        local function ResolveButtonIcon(iconName)
            local image = ResolveIcon(iconName or "menu")

            if image == "" then
                return "rbxassetid://99206841644167", Vector2.new(32, 32)
            end

            return image, Vector2.new(0, 0)
        end

        local shell = CreateInstance("TextButton", {
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(buttonSize, buttonSize),
            Position = startPosition,
            BorderSizePixel = 0,
            Visible = buttonOptions.visible ~= false,
            Parent = floatingGui
        })

        local shellScale = CreateInstance("UIScale", {Parent = shell})

        local halo = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1.34, 1.34),
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 0.88,
            BorderSizePixel = 0,
            ZIndex = 1,
            Parent = shell
        })

        AddCorner(halo, haloRadius)

        local body = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Colors.Card,
            BackgroundTransparency = 0.06,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = shell
        })

        AddCorner(body, bodyRadius)
        CreateDepthGradient(body, 0.18)

        local bodyStroke = AddStroke(body, Color3.new(1, 1, 1), 0.2, true)

        local bodyStrokeGradient = CreateInstance("UIGradient", {
            Color = CreateStrokeGradientSequence(),
            Rotation = 35,
            Parent = bodyStroke
        })

        local iconImage, iconRectSize = ResolveButtonIcon(buttonOptions.icon)

        local icon = CreateInstance("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = iconImage,
            ImageRectSize = iconRectSize,
            ImageColor3 = Colors.AccentSoft,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 3,
            Parent = body
        })

        local ring = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 4,
            Visible = false,
            Parent = shell
        })

        local ringCorner = AddCorner(ring, bodyRadius)

        local ringStroke = AddStroke(ring, Colors.Accent, 0.2, true)

        local function GetBodyColor()
            return isToggled and Colors.Accent or Colors.Card
        end

        local function GetIconColor()
            return isToggled and Colors.Background or Colors.AccentSoft
        end

        BindTheme(halo, {BackgroundColor3 = "Accent"})
        BindTheme(body, {BackgroundColor3 = GetBodyColor})
        BindTheme(bodyStrokeGradient, {Color = "StrokeSequence"})
        BindTheme(icon, {ImageColor3 = GetIconColor})
        BindTheme(ringStroke, {Color = "Accent"})

        local isHovered = false
        local isPressed = false
        local hasMoved = false
        local pressPosition = Vector3.new(0, 0, 0)
        local pressCenter = Vector2.new(0, 0)
        local dragConnection
        local releaseConnection

        local function PlayState()
            local isActive = isHovered or isPressed or isToggled
            local targetScale = 1

            if isPressed then
                targetScale = 0.92
            elseif isHovered then
                targetScale = 1.08
            end

            PlayTween(shellScale, CreateQuintOutTweenInfo(0.25), {Scale = targetScale})
            PlayTween(halo, CreateQuintOutTweenInfo(0.3), {BackgroundTransparency = isActive and 0.72 or 0.88})
            PlayTween(bodyStroke, CreateQuintOutTweenInfo(0.3), {Transparency = isActive and 0 or 0.2})
        end

        local function PlayPing()
            ring.Size = UDim2.fromScale(1, 1)
            ringCorner.CornerRadius = bodyRadius
            ringStroke.Transparency = 0.2
            ring.Visible = true

            PlayTween(ring, CreateQuintOutTweenInfo(0.5), {Size = UDim2.fromScale(1.7, 1.7)})
            PlayTween(ringCorner, CreateQuintOutTweenInfo(0.5), {CornerRadius = pingRadius})

            PlayTween(ringStroke, TweenInfo.new(0.5), {Transparency = 1}).Completed:Once(function()
                ring.Visible = false
            end)
        end

        local function GetCenter()
            local viewport = floatingGui.AbsoluteSize
            local position = shell.Position

            return Vector2.new(
                position.X.Scale * viewport.X + position.X.Offset,
                position.Y.Scale * viewport.Y + position.Y.Offset
            )
        end

        local function PlaceCenter(center)
            local viewport = floatingGui.AbsoluteSize

            if viewport.X < 1 or viewport.Y < 1 then
                return
            end

            local halfSize = buttonSize / 2

            shell.Position = UDim2.fromScale(
                math.clamp(center.X, halfSize, math.max(halfSize, viewport.X - halfSize)) / viewport.X,
                math.clamp(center.Y, halfSize, math.max(halfSize, viewport.Y - halfSize)) / viewport.Y
            )
        end

        local function FinishPress()
            isPressed = false

            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end

            if releaseConnection then
                releaseConnection:Disconnect()
                releaseConnection = nil
            end

            if hasMoved then
                self:save_position(positionKey, shell.Position)
            else
                PlayPing()

                if buttonOptions.callback then
                    buttonOptions.callback()
                end
            end

            PlayState()
        end

        shell.InputBegan:Connect(function(inputObject)
            if isPressed or not IsPrimaryPointerInput(inputObject) then
                return
            end

            isPressed = true
            hasMoved = false
            pressPosition = inputObject.Position
            pressCenter = GetCenter()
            PlayState()

            dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
                if changedInput.UserInputType ~= Enum.UserInputType.MouseMovement
                    and changedInput.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end

                local delta = changedInput.Position - pressPosition

                if not hasMoved and delta.Magnitude < 8 then
                    return
                end

                hasMoved = true
                PlaceCenter(pressCenter + Vector2.new(delta.X, delta.Y))
            end)

            releaseConnection = UserInputService.InputEnded:Connect(function(endedInput)
                if IsPrimaryPointerInput(endedInput) then
                    FinishPress()
                end
            end)
        end)

        shell.MouseEnter:Connect(function()
            isHovered = true
            PlayState()
        end)

        shell.MouseLeave:Connect(function()
            isHovered = false
            PlayState()
        end)

        local floatingButton = {}

        function floatingButton:set_size(newSize)
            buttonSize = math.clamp(newSize, minimumSize, maximumSize)
            shell.Size = UDim2.fromOffset(buttonSize, buttonSize)
            bodyStroke.Thickness = math.clamp(buttonSize / 28, 1.5, 3)
            ringStroke.Thickness = bodyStroke.Thickness
            PlaceCenter(GetCenter())
        end

        function floatingButton:get_size()
            return buttonSize
        end

        function floatingButton:set_visible(isVisible)
            shell.Visible = isVisible
        end

        function floatingButton:set_position(newPosition)
            shell.Position = newPosition
            PlaceCenter(GetCenter())
        end

        function floatingButton:set_icon(iconName)
            icon.Image, icon.ImageRectSize = ResolveButtonIcon(iconName)
        end

        function floatingButton:set_active(isOn)
            isToggled = isOn and true or false
            PlayTween(body, CreateQuintOutTweenInfo(0.3), {BackgroundColor3 = GetBodyColor()})
            PlayTween(icon, CreateQuintOutTweenInfo(0.3), {ImageColor3 = GetIconColor()})
            PlayState()
        end

        function floatingButton:destroy()
            if dragConnection then
                dragConnection:Disconnect()
            end

            if releaseConnection then
                releaseConnection:Disconnect()
            end

            shell:Destroy()
        end

        floatingButton:set_size(buttonSize)
        return floatingButton
    end

    function window:create_watermark(watermarkOptions)
        watermarkOptions = watermarkOptions or {}

        local floatingGui = self:get_floating_gui()
        local positionKey = watermarkOptions.flag and watermarkOptions.flag .. "_watermark"
        local isDraggable = watermarkOptions.draggable ~= false
        local startPosition = self:get_saved_position(positionKey)
            or watermarkOptions.position
            or UDim2.fromOffset(12, GuiService:GetGuiInset().Y + 10)
        local fieldCount = 0

        local shell = CreateInstance("Frame", {
            Active = isDraggable,
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Colors.Card,
            BackgroundTransparency = 0.06,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = startPosition,
            Size = UDim2.fromOffset(0, 32),
            Visible = watermarkOptions.visible ~= false,
            Parent = floatingGui
        })

        local shellScale = CreateInstance("UIScale", {Parent = shell})

        AddCorner(shell, 8)
        CreateDepthGradient(shell, 0.14)

        local shellStroke = AddStroke(shell, Color3.new(1, 1, 1), 0.35, true)

        local shellStrokeGradient = CreateInstance("UIGradient", {
            Color = CreateStrokeGradientSequence(),
            Rotation = 35,
            Parent = shellStroke
        })

        local glow = CreateInstance("Frame", {
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 14),
            Parent = shell
        })

        AddCorner(glow, 8)
        CreateFadeGradient(glow, 90)

        local content = CreateInstance("Frame", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 32),
            Parent = shell
        })

        CreateInstance("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = content
        })

        CreateInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = content
        })

        local brand = CreateInstance("Frame", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Size = UDim2.fromOffset(0, 18),
            Parent = content
        })

        CreateInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 7),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = brand
        })

        local brandLogo = CreateInstance("ImageLabel", {
            BackgroundTransparency = 1,
            Image = logo.Image,
            ImageColor3 = Colors.AccentSoft,
            ImageRectSize = logo.ImageRectSize,
            LayoutOrder = 1,
            ScaleType = Enum.ScaleType.Fit,
            Size = UDim2.fromOffset(16, 16),
            Parent = brand
        })

        local brandTitle = CreateInstance("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            FontFace = CreateGothamFont(Enum.FontWeight.Bold),
            LayoutOrder = 2,
            Size = UDim2.fromOffset(0, 16),
            Text = watermarkOptions.title or titleText,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = brand
        })

        local brandGradient = CreateInstance("UIGradient", {
            Color = CreateTitleGradientSequence(),
            Offset = Vector2.new(-0.5, 0),
            Parent = brandTitle
        })

        local brandTween = PlayTween(
            brandGradient,
            TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Offset = Vector2.new(0.5, 0)}
        )

        BindTheme(shell, {BackgroundColor3 = "Card"})
        BindTheme(shellStrokeGradient, {Color = "StrokeSequence"})
        BindTheme(glow, {BackgroundColor3 = "Accent"})
        BindTheme(brandLogo, {ImageColor3 = "AccentSoft"})
        BindTheme(brandGradient, {Color = "TitleSequence"})

        local isPressed = false
        local hasMoved = false
        local pressPosition = Vector3.new(0, 0, 0)
        local pressCorner = Vector2.new(0, 0)
        local dragConnection
        local releaseConnection

        local function PlaceShell(corner)
            local viewport = floatingGui.AbsoluteSize
            local shellSize = shell.AbsoluteSize

            if viewport.X < 1 or viewport.Y < 1 then
                return
            end

            shell.Position = UDim2.fromScale(
                math.clamp(corner.X, 0, math.max(0, viewport.X - shellSize.X)) / viewport.X,
                math.clamp(corner.Y, 0, math.max(0, viewport.Y - shellSize.Y)) / viewport.Y
            )
        end

        local function FinishPress()
            isPressed = false

            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end

            if releaseConnection then
                releaseConnection:Disconnect()
                releaseConnection = nil
            end

            if hasMoved then
                self:save_position(positionKey, shell.Position)
            end
        end

        shell.InputBegan:Connect(function(inputObject)
            if not isDraggable or isPressed or not IsPrimaryPointerInput(inputObject) then
                return
            end

            isPressed = true
            hasMoved = false
            pressPosition = inputObject.Position
            pressCorner = shell.AbsolutePosition

            dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
                if changedInput.UserInputType ~= Enum.UserInputType.MouseMovement
                    and changedInput.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end

                local delta = changedInput.Position - pressPosition

                if not hasMoved and delta.Magnitude < 8 then
                    return
                end

                hasMoved = true
                PlaceShell(pressCorner + Vector2.new(delta.X, delta.Y))
            end)

            releaseConnection = UserInputService.InputEnded:Connect(function(endedInput)
                if IsPrimaryPointerInput(endedInput) then
                    FinishPress()
                end
            end)
        end)

        local function PlayShow()
            shellScale.Scale = 0.92
            PlayTween(shellScale, CreateQuintOutTweenInfo(0.35), {Scale = 1})
        end

        local watermark = {}

        function watermark:create_field(fieldOptions)
            fieldOptions = fieldOptions or {}
            fieldCount += 1

            local divider = CreateInstance("Frame", {
                BackgroundColor3 = Colors.StrokeHot,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                LayoutOrder = fieldCount * 2,
                Size = UDim2.fromOffset(1, 14),
                Parent = content
            })

            local fieldFrame = CreateInstance("Frame", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = fieldCount * 2 + 1,
                Size = UDim2.fromOffset(0, 16),
                Parent = content
            })

            CreateInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = fieldFrame
            })

            local keyLabel = CreateInstance("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                FontFace = CreateGothamFont(Enum.FontWeight.Regular),
                LayoutOrder = 1,
                Size = UDim2.fromOffset(0, 14),
                Text = fieldOptions.title or "",
                TextColor3 = Colors.SubText,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = fieldFrame
            })

            local valueLabel = CreateInstance("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                LayoutOrder = 2,
                Size = UDim2.fromOffset(0, 14),
                Text = tostring(fieldOptions.value or ""),
                TextColor3 = Colors.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = fieldFrame
            })

            BindTheme(divider, {BackgroundColor3 = "StrokeHot"})
            BindTheme(keyLabel, {TextColor3 = "SubText"})
            BindTheme(valueLabel, {TextColor3 = "Text"})

            local currentValue = valueLabel.Text
            local minimumWidth = 0

            local function FitValue()
                local width = math.ceil(valueLabel.TextBounds.X)

                if width > minimumWidth then
                    minimumWidth = width
                    valueLabel.Size = UDim2.fromOffset(minimumWidth, 14)
                end
            end

            local function ResetValue()
                minimumWidth = 0
                valueLabel.Size = UDim2.fromOffset(0, 14)
                FitValue()
            end

            valueLabel:GetPropertyChangedSignal("FontFace"):Connect(ResetValue)
            valueLabel:GetPropertyChangedSignal("TextSize"):Connect(ResetValue)
            FitValue()

            local field = {}

            function field:set_value(newValue)
                newValue = tostring(newValue)

                if newValue == currentValue then
                    return
                end

                currentValue = newValue
                valueLabel.Text = newValue
                FitValue()
            end

            function field:set_title(newTitle)
                keyLabel.Text = newTitle
            end

            function field:set_visible(isVisible)
                divider.Visible = isVisible
                fieldFrame.Visible = isVisible
            end

            function field:destroy()
                divider:Destroy()
                fieldFrame:Destroy()
            end

            if UIFontScale ~= 1 then
                ApplyThemeFont(fieldFrame)
            end

            return field
        end

        function watermark:set_title(newTitle)
            brandTitle.Text = newTitle
        end

        function watermark:set_visible(isVisible)
            local wasVisible = shell.Visible

            shell.Visible = isVisible

            if isVisible and not wasVisible then
                PlayShow()
            end
        end

        function watermark:set_position(newPosition)
            shell.Position = newPosition
        end

        function watermark:destroy()
            if dragConnection then
                dragConnection:Disconnect()
            end

            if releaseConnection then
                releaseConnection:Disconnect()
            end

            brandTween:Cancel()
            shell:Destroy()
        end

        if UIFontScale ~= 1 then
            ApplyThemeFont(shell)
        end

        if shell.Visible then
            PlayShow()
        end

        return watermark
    end

    function window:load()
        local imageLabels = {}

        for _, descendant in screenGui:GetDescendants() do
            if descendant:IsA("ImageLabel") then
                table.insert(imageLabels, descendant)
            end
        end

        ContentProvider:PreloadAsync(imageLabels)
        self:get_device()
        self:get_screen_scale()
        containerScale.Scale = self._ui_scale
        ClampContainerPosition()

        local function ApplyScreenScale()
            self:get_screen_scale()

            if screenGui.Enabled then
                PlayTween(containerScale, CreateQuintOutTweenInfo(0.25), {Scale = self._ui_scale})
            end

            ClampContainerPosition()
        end

        local function WatchViewport()
            Connections:disconnect("ui_scale")

            local camera = workspace.CurrentCamera

            if camera then
                Connections.ui_scale = camera:GetPropertyChangedSignal("ViewportSize"):Connect(ApplyScreenScale)
            end
        end

        WatchViewport()

        Connections.ui_camera = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            WatchViewport()
            ApplyScreenScale()
        end)

        local finalScale = containerScale.Scale
        containerScale.Scale = finalScale * 0.9

        PlayTween(container, CreateQuintOutTweenInfo(0.7), {Size = OpenWindowSize})
        PlayTween(containerScale, CreateQuintOutTweenInfo(0.7), {Scale = finalScale})
        self._ui_loaded = true
    end

    function window:update_tabs(activeTab, shouldAnimate)
        local isAnimated = shouldAnimate ~= false
        self._active_tab_ref = activeTab

        local function ApplyOrTween(instance, duration, properties)
            if isAnimated then
                PlayTween(instance, CreateQuintOutTweenInfo(duration), properties)
                return
            end

            for propertyName, propertyValue in pairs(properties) do
                instance[propertyName] = propertyValue
            end
        end

        for _, tab in tabsList:GetChildren() do
            if tab.Name == "Tab" then
                tab.BackgroundColor3 = Colors.CardDeep
                local indicator = tab:FindFirstChild("Indicator")
                local label = tab:FindFirstChildOfClass("TextLabel")
                local labelGradient = label and label:FindFirstChildOfClass("UIGradient")
                local icon = tab:FindFirstChild("Icon")

                if tab == activeTab then
                    tab:SetAttribute("_active", true)
                    ApplyOrTween(tab, 0.36, {BackgroundTransparency = 0.82})

                    if label then
                        ApplyOrTween(label, 0.36, {TextTransparency = 0, TextColor3 = Colors.Accent})
                    end

                    if labelGradient then
                        ApplyOrTween(labelGradient, 0.36, {Offset = Vector2.new(1, 0)})
                    end

                    if icon then
                        ApplyOrTween(icon, 0.36, {ImageTransparency = 0, ImageColor3 = Colors.Accent})
                    end

                    if indicator then
                        indicator.BackgroundColor3 = Colors.Accent

                        if isAnimated then
                            indicator.BackgroundTransparency = 1
                            indicator.Size = UDim2.new(0, 3, 0, 6)

                            PlayTween(
                                indicator,
                                TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                                {BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0, 22)}
                            )
                        else
                            indicator.BackgroundTransparency = 0
                            indicator.Size = UDim2.new(0, 3, 0, 22)
                        end
                    end
                else
                    tab:SetAttribute("_active", false)
                    ApplyOrTween(tab, 0.3, {BackgroundTransparency = 1})

                    if label then
                        ApplyOrTween(label, 0.3, {TextTransparency = 0.42, TextColor3 = Colors.Text})
                    end

                    if labelGradient then
                        ApplyOrTween(labelGradient, 0.3, {Offset = Vector2.new(0, 0)})
                    end

                    if icon then
                        ApplyOrTween(icon, 0.3, {ImageTransparency = 0.5, ImageColor3 = Colors.Text})
                    end

                    if indicator then
                        if isAnimated then
                            PlayTween(indicator, CreateQuintOutTweenInfo(0.24), {
                                BackgroundTransparency = 1,
                                Size = UDim2.new(0, 3, 0, 10)
                            })
                        else
                            indicator.BackgroundColor3 = Colors.Accent
                            indicator.BackgroundTransparency = 1
                            indicator.Size = UDim2.new(0, 3, 0, 10)
                        end
                    end
                end
            end
        end
    end

    function window:update_sections(leftSection, rightSection)
        for _, section in sectionsFolder:GetChildren() do
            if section == leftSection or section == rightSection then
                section.Visible = true
                section.Position = UDim2.new(section.Position.X.Scale, 14, section.Position.Y.Scale, section.Position.Y.Offset)

                local sectionScale = section:FindFirstChildOfClass("UIScale")

                if not sectionScale then
                    sectionScale = CreateInstance("UIScale", {Scale = 0.96, Parent = section})
                else
                    sectionScale.Scale = 0.96
                end

                PlayTween(section, CreateQuintOutTweenInfo(0.45), {
                    Position = UDim2.new(section.Position.X.Scale, 0, section.Position.Y.Scale, section.Position.Y.Offset)
                })

                PlayTween(sectionScale, CreateQuintOutTweenInfo(0.45), {Scale = 1})
            else
                section.Visible = false
            end
        end
    end

    function window:create_tab(tabTitle, iconName, tabOptions)
        local options = tabOptions or {}
        local tabApi = {}

        local labelBounds = MeasureText(tabTitle, CreateGothamFont(Enum.FontWeight.SemiBold), 13)
        local shouldAutoActivate = not options.no_activate and (not tabsList:FindFirstChild("Tab") or window._active_tab_ref == nil)

        local tabButton = CreateInstance("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Name = "Tab",
            Size = UDim2.new(0, 129, 0, 38),
            BorderSizePixel = 0,
            BackgroundColor3 = Colors.CardDeep,
            Parent = tabsList
        })

        if options.layout_order ~= nil then
            tabButton.LayoutOrder = options.layout_order
        else
            tabButton.LayoutOrder = window._tab
            window._tab = window._tab + 1
        end

        AddCorner(tabButton, 5)

        local tabScale = CreateInstance("UIScale", {Scale = 1, Parent = tabButton})

        local tabIndicator = CreateInstance("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0, 20),
            Position = UDim2.new(0, 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = tabButton
        })

        AddCorner(tabIndicator, 3)

        local tabLabel = CreateInstance("TextLabel", {
            FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
            TextColor3 = Colors.Text,
            TextTransparency = 0.38,
            Text = tabTitle,
            Size = UDim2.new(0, labelBounds.X, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0.24, 0, 0.5, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 13,
            Parent = tabButton
        })

        CreateInstance("UIGradient", {
            Color = CreateTabLabelGradientSequence(),
            Parent = tabLabel
        })

        CreateInstance("ImageLabel", {
            ScaleType = Enum.ScaleType.Fit,
            ImageTransparency = 0.45,
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.1, 0, 0.5, 0),
            Name = "Icon",
            Image = ResolveIcon(iconName),
            ImageColor3 = Colors.Text,
            Size = UDim2.new(0, 13, 0, 13),
            BorderSizePixel = 0,
            Parent = tabButton
        })

        local function CreateTabPage(xScale)
            local page = CreateInstance("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.XY,
                ScrollBarThickness = 0,
                Size = UDim2.new(0, 243, 0, 360),
                Selectable = false,
                ScrollBarImageTransparency = 1,
                BackgroundTransparency = 1,
                Position = UDim2.new(xScale, 0, 0.16, 0),
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0.5, 0),
                Visible = false,
                Parent = sectionsFolder
            })

            CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 10),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = page
            })

            CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, 1),
                PaddingBottom = UDim.new(0, 8),
                Parent = page
            })

            return page
        end

        local leftPage = CreateTabPage(0.23)
        local rightPage = CreateTabPage(0.6)

        if shouldAutoActivate then
            window:update_tabs(tabButton)
            window:update_sections(leftPage, rightPage)
        end

        tabButton.MouseEnter:Connect(function()
            if tabButton:GetAttribute("_active") then
                return
            end

            PlayTween(tabButton, CreateQuintOutTweenInfo(0.3), {BackgroundTransparency = 0.9})
        end)

        tabButton.MouseLeave:Connect(function()
            PlayTween(tabScale, CreateQuintOutTweenInfo(0.3), {Scale = 1})

            if tabButton:GetAttribute("_active") then
                return
            end

            PlayTween(tabButton, CreateQuintOutTweenInfo(0.3), {BackgroundTransparency = 1})
        end)

        tabButton.MouseButton1Down:Connect(function()
            PlayTween(tabScale, CreateSmoothTweenInfo(0.12), {Scale = 0.95})
        end)

        tabButton.MouseButton1Up:Connect(function()
            PlayTween(
                tabScale,
                TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Scale = 1}
            )
        end)

        tabButton.MouseButton1Click:Connect(function()
            window:update_tabs(tabButton)
            window:update_sections(leftPage, rightPage)
        end)

        function tabApi:create_module(moduleOptions)
            local layoutOrderCounter = 0

            local sizeManager = {
                _state = false,
                _size = 0,
                _multiplier = 0,
                _accent_bar = nil
            }

            local notificationsEnabled = false
            local page = moduleOptions.section == "right" and rightPage or leftPage
            moduleOptions.section = page

            local function GetNextLayoutOrder()
                local highestOrder = 0

                for _, child in page:GetChildren() do
                    if child:IsA("Frame") and highestOrder < child.LayoutOrder then
                        highestOrder = child.LayoutOrder
                    end
                end

                return highestOrder + 1
            end

            local moduleCard = CreateInstance("Frame", {
                ClipsDescendants = true,
                BorderSizePixel = 0,
                BackgroundTransparency = 0.68,
                Name = "Module",
                Size = CollapsedModuleSize,
                BackgroundColor3 = Colors.Card,
                LayoutOrder = GetNextLayoutOrder(),
                Parent = page
            })

            local defaultLayoutOrder = moduleCard.LayoutOrder
            moduleCard:SetAttribute("expanded", false)
            moduleCard:SetAttribute("pinned", false)

            CreateInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = moduleCard
            })

            AddCorner(moduleCard, 6)
            CreateDepthGradient(moduleCard, 0.12)
            local moduleStroke = AddStroke(moduleCard, Colors.Stroke, 0.32, true)

            table.insert(Library._all_modules, {
                frame = moduleCard,
                title = (moduleOptions.title or ""):lower(),
                manager = sizeManager,
                flag = moduleOptions.flag
            })

            local header = CreateInstance("TextButton", {
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Name = "Header",
                Size = UDim2.new(1, 0, 0, ExpandedModuleBaseHeight),
                BorderSizePixel = 0,
                Parent = moduleCard
            })

            local headerBackground = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 58),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Colors.CardDeep,
                BackgroundTransparency = 0.6,
                BorderSizePixel = 0,
                ZIndex = 0,
                Parent = header
            })

            CreateFadeGradient(headerBackground, 90)

            local accentBar = CreateInstance("Frame", {
                Name = "AccentBar",
                Size = UDim2.new(0, 2, 0, 50),
                Position = UDim2.new(0, 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Colors.AccentDim,
                BackgroundTransparency = 0.45,
                BorderSizePixel = 0,
                ZIndex = 3,
                Parent = header
            })

            AddCorner(accentBar, 2)
            sizeManager._accent_bar = accentBar

            local headerIcon = CreateInstance("ImageLabel", {
                ImageColor3 = Colors.AccentSoft,
                ScaleType = Enum.ScaleType.Fit,
                AnchorPoint = Vector2.new(0, 0.5),
                Image = "rbxassetid://79095934438045",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.071, 0, 0.82, 0),
                Name = "Icon",
                Size = UDim2.new(0, 15, 0, 15),
                BorderSizePixel = 0,
                ImageTransparency = 0.25,
                Parent = header
            })

            local isPinned = false

            local pinButton = CreateInstance("ImageButton", {
                Name = "PinBtn",
                Size = UDim2.new(0, 13, 0, 13),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, -23),
                BackgroundTransparency = 1,
                Image = ResolveIcon("pin") ~= "" and ResolveIcon("pin") or "rbxassetid://7072718362",
                ImageColor3 = Colors.SubText,
                ImageTransparency = 0.55,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = header
            })

            pinButton.MouseEnter:Connect(function()
                PlayTween(pinButton, TweenInfo.new(0.18), {
                    ImageColor3 = isPinned and Colors.Accent or Colors.Text,
                    ImageTransparency = 0.1
                })
            end)

            pinButton.MouseLeave:Connect(function()
                PlayTween(pinButton, TweenInfo.new(0.22), {
                    ImageColor3 = isPinned and Colors.Accent or Colors.SubText,
                    ImageTransparency = isPinned and 0.08 or 0.55
                })
            end)

            pinButton.MouseButton1Click:Connect(function()
                isPinned = not isPinned
                moduleCard:SetAttribute("pinned", isPinned)

                if isPinned then
                    moduleCard.LayoutOrder = -1000

                    PlayTween(pinButton, CreateQuintOutTweenInfo(0.35), {
                        ImageColor3 = Colors.Accent,
                        ImageTransparency = 0.08
                    })

                    PlayTween(moduleStroke, TweenInfo.new(0.35), {Color = Colors.Accent, Transparency = 0.55})
                else
                    moduleCard.LayoutOrder = defaultLayoutOrder

                    PlayTween(pinButton, CreateQuintOutTweenInfo(0.35), {
                        ImageColor3 = Colors.SubText,
                        ImageTransparency = 0.55
                    })

                    if not sizeManager._state then
                        PlayTween(
                            moduleStroke,
                            TweenInfo.new(0.35),
                            {Color = Colors.Stroke, Transparency = 0.32}
                        )
                    end
                end
            end)

            local moduleNameLabel = CreateInstance("TextLabel", {
                FontFace = CreateGothamFont(Enum.FontWeight.Bold),
                TextColor3 = Color3.new(1, 1, 1),
                TextTransparency = 0.06,
                Name = "ModuleName",
                Size = UDim2.new(0, 205, 0, 14),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0.073, 0, 0.24, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 13,
                Parent = header
            })

            local moduleNameGradient = CreateInstance("UIGradient", {
                Color = CreateModuleTitleGradientSequence(),
                Parent = moduleNameLabel
            })

            if moduleOptions.rich then
                moduleNameLabel.RichText = true
                moduleNameLabel.Text = moduleOptions.richtext or "Module"
            else
                moduleNameLabel.Text = moduleOptions.title or "Module"
            end

            local descriptionLabel = CreateInstance("TextLabel", {
                FontFace = CreateGothamFont(Enum.FontWeight.Regular),
                TextColor3 = Colors.SubText,
                TextTransparency = 0.1,
                Text = moduleOptions.description or "",
                Name = "Description",
                Size = UDim2.new(0, 205, 0, 13),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0.073, 0, 0.42, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 10,
                Parent = header
            })

            local toggleTrack = CreateInstance("Frame", {
                Name = "Toggle",
                BackgroundTransparency = 0.6,
                Position = UDim2.new(0.82, 0, 0.757, 0),
                Size = UDim2.new(0, 26, 0, 13),
                BorderSizePixel = 0,
                BackgroundColor3 = DeriveToggleOffColor(Colors.Card),
                Parent = header
            })

            AddCorner(toggleTrack, 12)
            local toggleStroke = AddStroke(toggleTrack, Colors.Stroke, 0.25)

            local toggleCircle = CreateInstance("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 0.1,
                Position = UDim2.new(0, 2, 0.5, 0),
                Name = "Circle",
                Size = UDim2.new(0, 9, 0, 9),
                BorderSizePixel = 0,
                BackgroundColor3 = Colors.SubText,
                Parent = toggleTrack
            })

            AddCorner(toggleCircle, 12)

            local keybindBadge = CreateInstance("Frame", {
                Name = "Keybind",
                BackgroundTransparency = 0.65,
                Position = UDim2.new(0.15, 0, 0.73, 0),
                Size = UDim2.new(0, 33, 0, 15),
                BorderSizePixel = 0,
                BackgroundColor3 = Colors.Accent,
                Parent = header
            })

            AddCorner(keybindBadge, 3)

            local keybindLabel = CreateInstance("TextLabel", {
                FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                TextColor3 = Colors.AccentSoft,
                Text = "None",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 25, 0, 13),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                TextSize = 10,
                Parent = keybindBadge
            })

            if moduleOptions.notify then
                local notifyFlagName = moduleOptions.flag .. "_notify"
                notificationsEnabled = Library._config._library[notifyFlagName] == true

                local bellButton = CreateInstance("ImageButton", {
                    Name = "Bell",
                    Size = UDim2.new(0, 18, 0, 18),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0.72, 0, 0.735, 0),
                    BackgroundTransparency = 1,
                    Image = ResolveIcon("bell"),
                    ImageColor3 = notificationsEnabled and Colors.Accent or Colors.SubText,
                    ImageTransparency = notificationsEnabled and 0.05 or 0.45,
                    BorderSizePixel = 0,
                    Parent = header
                })

                BindTheme(bellButton, {
                    ImageColor3 = function()
                        return notificationsEnabled and Colors.Accent or Colors.SubText
                    end
                })

                bellButton.MouseButton1Click:Connect(function()
                    notificationsEnabled = not notificationsEnabled
                    Library._config._library[notifyFlagName] = notificationsEnabled
                    SaveConfig()

                    PlayTween(bellButton, CreateQuintOutTweenInfo(0.3), {
                        ImageColor3 = notificationsEnabled and Colors.Accent or Colors.SubText,
                        ImageTransparency = notificationsEnabled and 0.05 or 0.45
                    })
                end)
            end

            for _, verticalScale in {0.62, 1} do
                local dividerLine = CreateInstance("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 0.12,
                    Position = UDim2.new(0.5, 0, verticalScale, 0),
                    Size = UDim2.new(0, 241, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Colors.Stroke,
                    Parent = header
                })

                BindTheme(dividerLine, {BackgroundColor3 = "Stroke"})
            end

            local optionsContainer = CreateInstance("Frame", {
                Name = "Options",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 8),
                BorderSizePixel = 0,
                Parent = moduleCard
            })

            CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 10),
                Parent = optionsContainer
            })

            CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 6),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionsContainer
            })

            BindTheme(moduleCard, {BackgroundColor3 = "Card"})
            BindTheme(headerBackground, {BackgroundColor3 = "CardDeep"})
            BindTheme(headerIcon, {ImageColor3 = "AccentSoft"})
            BindTheme(moduleNameGradient, {Color = "ModuleTitleSequence"})
            BindTheme(descriptionLabel, {TextColor3 = "SubText"})
            BindTheme(toggleStroke, {Color = "Stroke"})
            BindTheme(keybindBadge, {BackgroundColor3 = "Accent"})
            BindTheme(keybindLabel, {TextColor3 = "AccentSoft"})

            BindTheme(moduleStroke, {
                Color = function()
                    return (sizeManager._state or isPinned) and Colors.Accent or Colors.Stroke
                end
            })

            BindTheme(accentBar, {
                BackgroundColor3 = function()
                    return sizeManager._state and Colors.Accent or Colors.AccentDim
                end
            })

            BindTheme(pinButton, {
                ImageColor3 = function()
                    return isPinned and Colors.Accent or Colors.SubText
                end
            })

            BindTheme(toggleTrack, {
                BackgroundColor3 = function()
                    return sizeManager._state and Colors.Accent or DeriveToggleOffColor(Colors.Card)
                end
            })

            BindTheme(toggleCircle, {
                BackgroundColor3 = function()
                    return sizeManager._state and Colors.Background or Colors.SubText
                end
            })

            header.MouseEnter:Connect(function()
                if sizeManager._state then
                    return
                end

                PlayTween(moduleStroke, CreateQuintOutTweenInfo(0.28), {
                    Color = Colors.StrokeHot,
                    Transparency = 0.1
                })

                PlayTween(accentBar, TweenInfo.new(0.25), {BackgroundTransparency = 0.2})
            end)

            header.MouseLeave:Connect(function()
                if sizeManager._state then
                    return
                end

                PlayTween(
                    moduleStroke,
                    CreateQuintOutTweenInfo(0.32),
                    {Color = Colors.Stroke, Transparency = 0.32}
                )

                PlayTween(accentBar, TweenInfo.new(0.3), {BackgroundTransparency = 0.45})
            end)

            local function RefreshModuleSize()
                if sizeManager._state then
                    moduleCard.Size = UDim2.new(
                        1,
                        -8,
                        0,
                        ExpandedModuleBaseHeight + sizeManager._size + sizeManager._multiplier + 16
                    )
                end

                optionsContainer.Size = UDim2.new(1, -8, 0, sizeManager._size + sizeManager._multiplier)
            end

            function sizeManager:change_state(isExpanded)
                self._state = isExpanded
                moduleCard:SetAttribute("expanded", self._state)

                if self._state then
                    PlayTween(moduleCard, CreateQuintOutTweenInfo(0.55), {
                        Size = UDim2.new(1, -8, 0, ExpandedModuleBaseHeight + self._size + self._multiplier + 16)
                    })

                    PlayTween(toggleTrack, CreateQuintOutTweenInfo(0.5), {
                        BackgroundColor3 = Colors.Accent,
                        BackgroundTransparency = 0.3
                    })

                    PlayTween(toggleCircle, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 9, 0, 9),
                        Position = UDim2.new(1, -11, 0.5, 0),
                        BackgroundColor3 = Colors.Background
                    })

                    self._ab_tween = PlayTween(accentBar, CreateQuintOutTweenInfo(0.5), {
                        BackgroundColor3 = Colors.Accent,
                        BackgroundTransparency = 0.08
                    })

                    PlayTween(
                        moduleStroke,
                        CreateQuintOutTweenInfo(0.5),
                        {Color = Colors.Accent, Transparency = 0.68}
                    )
                else
                    PlayTween(moduleCard, CreateQuintOutTweenInfo(0.55), {Size = CollapsedModuleSize})

                    PlayTween(toggleTrack, CreateQuintOutTweenInfo(0.5), {
                        BackgroundColor3 = DeriveToggleOffColor(Colors.Card),
                        BackgroundTransparency = 0.6
                    })

                    PlayTween(toggleCircle, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 9, 0, 9),
                        Position = UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = Colors.SubText
                    })

                    self._ab_tween = PlayTween(accentBar, CreateQuintOutTweenInfo(0.5), {
                        BackgroundColor3 = Colors.AccentDim,
                        BackgroundTransparency = 0.45
                    })

                    PlayTween(
                        moduleStroke,
                        CreateQuintOutTweenInfo(0.5),
                        {Color = Colors.Stroke, Transparency = 0.32}
                    )
                end

                Library._config._flags[moduleOptions.flag] = self._state
                SaveConfig()
                moduleOptions.callback(self._state)

                if notificationsEnabled then
                    Library.SendNotification({
                        title = moduleOptions.title or "Module",
                        text = self._state and Language.ModuleEnabled or Language.ModuleDisabled,
                        icon = self._state and "check" or "x",
                        iconColor = self._state and Colors.Accent or Colors.Danger,
                        duration = 2.5
                    })
                end
            end

            function sizeManager:connect_keybind()
                if not Library._config._keybinds[moduleOptions.flag] then
                    return
                end

                Connections[moduleOptions.flag .. "_keybind"] = UserInputService.InputBegan:Connect(function(inputObject, isProcessed)
                    if isProcessed then
                        return
                    end

                    if tostring(inputObject.KeyCode) ~= Library._config._keybinds[moduleOptions.flag] then
                        return
                    end

                    self:change_state(not self._state)
                end)
            end

            function sizeManager:scale_keybind(isCleared)
                if Library._config._keybinds[moduleOptions.flag] and not isCleared then
                    local keybindText = StripKeyCodePrefix(Library._config._keybinds[moduleOptions.flag])
                    local textBounds = MeasureText(keybindText, Font.new(MontserratFontPath, Enum.FontWeight.Bold), 10)

                    keybindBadge.Size = UDim2.fromOffset(textBounds.X + 6, 15)
                    keybindLabel.Size = UDim2.fromOffset(textBounds.X, 13)
                else
                    keybindBadge.Size = UDim2.fromOffset(31, 15)
                    keybindLabel.Size = UDim2.fromOffset(25, 13)
                end
            end

            if Library._config._flags[moduleOptions.flag] == true then
                sizeManager._state = true
                moduleCard:SetAttribute("expanded", true)
                toggleTrack.BackgroundColor3 = Colors.Accent
                toggleTrack.BackgroundTransparency = 0.3
                toggleCircle.BackgroundColor3 = Colors.Background
                toggleCircle.Position = UDim2.new(1, -11, 0.5, 0)
                accentBar.BackgroundColor3 = Colors.Accent
                accentBar.BackgroundTransparency = 0.08
                moduleStroke.Color = Colors.Accent
                moduleStroke.Transparency = 0.68
                moduleOptions.callback(sizeManager._state)
            end

            if Library._config._keybinds[moduleOptions.flag] then
                keybindLabel.Text = StripKeyCodePrefix(Library._config._keybinds[moduleOptions.flag])
                sizeManager:connect_keybind()
                sizeManager:scale_keybind()
            end

            Library:register_flag(moduleOptions.flag, function(flagValue)
                if type(flagValue) == "boolean" and flagValue ~= sizeManager._state then
                    sizeManager:change_state(flagValue)
                end
            end, true)

            Library._keybind_appliers[moduleOptions.flag] = function()
                Connections:disconnect(moduleOptions.flag .. "_keybind")

                if Library._config._keybinds[moduleOptions.flag] then
                    keybindLabel.Text = StripKeyCodePrefix(Library._config._keybinds[moduleOptions.flag])
                    sizeManager:connect_keybind()
                    sizeManager:scale_keybind()
                else
                    keybindLabel.Text = "None"
                    sizeManager:scale_keybind(true)
                end
            end

            header.InputBegan:Connect(function(inputObject)
                if Library._choosing_keybind then
                    return
                end

                if inputObject.UserInputType ~= Enum.UserInputType.MouseButton3 then
                    return
                end

                Library._choosing_keybind = true

                Connections.keybind_choose_start = UserInputService.InputBegan:Connect(function(keyInput, isProcessed)
                    if isProcessed then
                        return
                    end

                    if keyInput.KeyCode == Enum.KeyCode.Unknown then
                        return
                    end

                    if keyInput.KeyCode == Enum.KeyCode.Backspace then
                        sizeManager:scale_keybind(true)
                        Library._config._keybinds[moduleOptions.flag] = nil
                        SaveConfig()
                        keybindLabel.Text = "None"
                        Connections:disconnect(moduleOptions.flag .. "_keybind")
                        Connections:disconnect("keybind_choose_start")
                        Library._choosing_keybind = false
                        return
                    end

                    Connections:disconnect("keybind_choose_start")
                    Library._config._keybinds[moduleOptions.flag] = tostring(keyInput.KeyCode)
                    SaveConfig()
                    Connections:disconnect(moduleOptions.flag .. "_keybind")
                    sizeManager:connect_keybind()
                    sizeManager:scale_keybind()
                    Library._choosing_keybind = false
                    keybindLabel.Text = StripKeyCodePrefix(Library._config._keybinds[moduleOptions.flag])
                end)
            end)

            header.MouseButton1Click:Connect(function()
                sizeManager:change_state(not sizeManager._state)
            end)

            function sizeManager:create_slider(sliderOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + 28
                RefreshModuleSize()

                local decimals = sliderOptions.decimals or 0
                local decimalMultiplier = 10 ^ decimals

                local function FormatValue(value)
                    if decimals == 0 then
                        return tostring(math.floor(value))
                    end

                    return string.format("%." .. decimals .. "f", value)
                end

                local sliderRow = CreateInstance("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Name = "Slider",
                    Size = UDim2.new(0, 207, 0, 22),
                    BorderSizePixel = 0,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                CreateSliderTitleLabel(sliderRow, 153, sliderOptions.title)

                local sliderTrack = CreateSliderTrack(sliderRow, UDim2.new(0, 207, 0, 4), false)
                local sliderFill = CreateSliderFill(sliderTrack, UDim2.new(0, 103, 0, 4))
                local valueLabel = CreateSliderValueLabel(sliderRow, 42, 10, "0")

                local sliderApi = {
                    set_percentage = function(self, rawValue)
                        local clampedValue = math.floor(
                            math.clamp(rawValue, sliderOptions.minimum_value, sliderOptions.maximum_value) * decimalMultiplier + 0.5
                        ) / decimalMultiplier

                        local fillOffset = math.clamp(
                            (clampedValue - sliderOptions.minimum_value) / (sliderOptions.maximum_value - sliderOptions.minimum_value),
                            0.02,
                            1
                        ) * sliderTrack.Size.X.Offset

                        Library._config._flags[sliderOptions.flag] = clampedValue
                        valueLabel.Text = FormatValue(clampedValue)

                        PlayTween(sliderFill, CreateSmoothTweenInfo(0.12), {
                            Size = UDim2.fromOffset(fillOffset, sliderTrack.Size.Y.Offset)
                        })

                        sliderOptions.callback(clampedValue)
                    end,
                    update = function(self)
                        self:set_percentage(
                            sliderOptions.minimum_value + (sliderOptions.maximum_value - sliderOptions.minimum_value) * math.clamp(
                                (Mouse.X - sliderTrack.AbsolutePosition.X) / sliderTrack.Size.X.Offset,
                                0,
                                1
                            )
                        )
                    end,
                    input = function(self)
                        self:update()

                        Connections["slider_drag_" .. sliderOptions.flag] = Mouse.Move:Connect(function()
                            self:update()
                        end)

                        Connections["slider_input_" .. sliderOptions.flag] = UserInputService.InputEnded:Connect(function(inputObject)
                            if not IsPrimaryPointerInput(inputObject) then
                                return
                            end

                            Connections:disconnect("slider_drag_" .. sliderOptions.flag)
                            Connections:disconnect("slider_input_" .. sliderOptions.flag)

                            if not sliderOptions.ignoresaved then
                                SaveConfig()
                            end
                        end)
                    end
                }

                if Library:flag_type(sliderOptions.flag, "number") and not sliderOptions.ignoresaved then
                    sliderApi:set_percentage(Library._config._flags[sliderOptions.flag])
                else
                    sliderApi:set_percentage(sliderOptions.value)
                end

                if not sliderOptions.ignoresaved then
                    Library:register_flag(sliderOptions.flag, function(flagValue)
                        if type(flagValue) == "number" and flagValue ~= Library._config._flags[sliderOptions.flag] then
                            sliderApi:set_percentage(flagValue)
                        end
                    end)
                end

                sliderRow.MouseButton1Down:Connect(function()
                    sliderApi:input()
                end)

                return sliderApi
            end

            function sizeManager:create_doubleslider(sliderOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + 28
                RefreshModuleSize()

                local decimals = sliderOptions.decimals or 0
                local decimalMultiplier = 10 ^ decimals

                local function FormatValue(value)
                    if decimals == 0 then
                        return tostring(math.floor(value))
                    end

                    return string.format("%." .. decimals .. "f", value)
                end

                local minimumValue = sliderOptions.minimum_value
                local maximumValue = sliderOptions.maximum_value
                local initialLow, initialHigh

                if sliderOptions.value and type(sliderOptions.value) == "table" then
                    initialLow = sliderOptions.value[1] or sliderOptions.value.L or minimumValue
                    initialHigh = sliderOptions.value[2] or sliderOptions.value.H or maximumValue
                else
                    initialLow = sliderOptions.value_low or minimumValue
                    initialHigh = sliderOptions.value_high or maximumValue
                end

                local savedLow, savedHigh
                local savedFlag = Library._config._flags[sliderOptions.flag]

                if savedFlag and type(savedFlag) == "table" then
                    if savedFlag.L ~= nil and savedFlag.H ~= nil then
                        savedLow = savedFlag.L
                        savedHigh = savedFlag.H
                    elseif savedFlag[1] ~= nil and savedFlag[2] ~= nil then
                        savedLow = savedFlag[1]
                        savedHigh = savedFlag[2]
                    else
                        savedLow = initialLow
                        savedHigh = initialHigh
                    end
                else
                    savedLow = initialLow
                    savedHigh = initialHigh
                end

                local clampedLow = math.clamp(savedLow, minimumValue, maximumValue)
                local clampedHigh = math.clamp(savedHigh, minimumValue, maximumValue)
                local orderedLow, orderedHigh

                if clampedHigh < clampedLow then
                    orderedLow = clampedHigh
                    orderedHigh = clampedLow
                else
                    orderedLow = clampedLow
                    orderedHigh = clampedHigh
                end

                local sliderRow = CreateInstance("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Name = "DoubleSlider",
                    Size = UDim2.new(0, 207, 0, 22),
                    BorderSizePixel = 0,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                CreateSliderTitleLabel(sliderRow, 120, sliderOptions.title)

                local sliderTrack = CreateSliderTrack(sliderRow, UDim2.new(0, 207, 0, 4), true)

                local rangeFill = CreateInstance("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 0.05,
                    Name = "RangeFill",
                    BorderSizePixel = 0,
                    BackgroundColor3 = Colors.Accent,
                    Parent = sliderTrack
                })

                AddCorner(rangeFill, 3)

                local rangeGradient = CreateInstance("UIGradient", {
                    Color = CreateAccentColorSequence(),
                    Parent = rangeFill
                })

                BindTheme(rangeFill, {BackgroundColor3 = "Accent"})
                BindTheme(rangeGradient, {Color = "AccentSequence"})

                local function CreateKnob(knobName)
                    local knob = CreateInstance("Frame", {
                        Active = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Name = knobName,
                        Size = UDim2.new(0, 7, 0, 7),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Colors.AccentSoft,
                        ZIndex = 2,
                        Parent = sliderTrack
                    })

                    AddCorner(knob, 12)
                    BindTheme(knob, {BackgroundColor3 = "AccentSoft"})
                    return knob
                end

                local lowKnob = CreateKnob("KnobL")
                local highKnob = CreateKnob("KnobR")

                local valueLabel = CreateInstance("TextLabel", {
                    FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                    TextColor3 = Colors.Text,
                    TextTransparency = 0.2,
                    Text = "0 - 0",
                    Name = "Value",
                    Size = UDim2.new(0, 80, 0, 13),
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextSize = 9,
                    Parent = sliderRow
                })

                BindTheme(valueLabel, {TextColor3 = "Text"})

                local activeKnobSide
                local rangeApi = {}

                local function ToTrackAlpha(value)
                    return (value - minimumValue) / (maximumValue - minimumValue)
                end

                function rangeApi:set_range(lowValue, highValue, skipSave)
                    local roundedLow = math.floor(math.clamp(lowValue, minimumValue, maximumValue) * decimalMultiplier + 0.5) / decimalMultiplier
                    local roundedHigh = math.floor(math.clamp(highValue, minimumValue, maximumValue) * decimalMultiplier + 0.5) / decimalMultiplier

                    if roundedHigh < roundedLow then
                        roundedLow, roundedHigh = roundedHigh, roundedLow
                    end

                    local minimumGap = decimals == 0 and 1 or math.max(
                        (maximumValue - minimumValue) * (0.5 / math.max(decimalMultiplier, 1)),
                        1 / decimalMultiplier
                    )

                    if activeKnobSide and roundedHigh - roundedLow < minimumGap then
                        if activeKnobSide == "low" then
                            roundedLow = math.clamp(roundedHigh - minimumGap, minimumValue, maximumValue)
                        else
                            roundedHigh = math.clamp(roundedLow + minimumGap, minimumValue, maximumValue)
                        end
                    end

                    Library._config._flags[sliderOptions.flag] = {L = roundedLow, H = roundedHigh}
                    valueLabel.Text = FormatValue(roundedLow) .. " - " .. FormatValue(roundedHigh)

                    local lowAlpha = ToTrackAlpha(roundedLow)
                    local highAlpha = ToTrackAlpha(roundedHigh)

                    rangeFill.Position = UDim2.new(lowAlpha, 0, 0.5, 0)
                    rangeFill.Size = UDim2.new(math.max(highAlpha - lowAlpha, 0.02), 0, 1, 0)
                    lowKnob.Position = UDim2.new(lowAlpha, 0, 0.5, 0)
                    highKnob.Position = UDim2.new(highAlpha, 0, 0.5, 0)

                    sliderOptions.callback(roundedLow, roundedHigh)

                    if not skipSave and not sliderOptions.ignoresaved then
                        SaveConfig()
                    end
                end

                function rangeApi:pick_which(mouseX)
                    local pointerValue = minimumValue + (maximumValue - minimumValue) * math.clamp((mouseX - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)

                    local currentHigh = Library._config._flags[sliderOptions.flag].H

                    if math.abs(pointerValue - Library._config._flags[sliderOptions.flag].L) <= math.abs(pointerValue - currentHigh) then
                        return "low"
                    end

                    return "high"
                end

                function rangeApi:update_from_mouse()
                    local currentRange = Library._config._flags[sliderOptions.flag]

                    if not currentRange or not activeKnobSide then
                        return
                    end

                    local pointerValue = minimumValue + (maximumValue - minimumValue) * math.clamp((Mouse.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)

                    local currentLow = currentRange.L
                    local currentHigh = currentRange.H

                    if activeKnobSide == "low" then
                        self:set_range(math.min(pointerValue, currentHigh), currentHigh, true)
                    elseif activeKnobSide == "high" then
                        self:set_range(currentLow, math.max(pointerValue, currentLow), true)
                    end
                end

                Library._config._flags[sliderOptions.flag] = {L = orderedLow, H = orderedHigh}
                rangeApi:set_range(orderedLow, orderedHigh, true)

                local function BeginKnobDrag(knobSide)
                    Connections:disconnect("dsl_drag_" .. sliderOptions.flag)
                    Connections:disconnect("dsl_end_" .. sliderOptions.flag)
                    activeKnobSide = knobSide
                    rangeApi:update_from_mouse()

                    Connections["dsl_drag_" .. sliderOptions.flag] = Mouse.Move:Connect(function()
                        rangeApi:update_from_mouse()
                    end)

                    Connections["dsl_end_" .. sliderOptions.flag] = UserInputService.InputEnded:Connect(function(inputObject)
                        if not IsPrimaryPointerInput(inputObject) then
                            return
                        end

                        Connections:disconnect("dsl_drag_" .. sliderOptions.flag)
                        Connections:disconnect("dsl_end_" .. sliderOptions.flag)
                        activeKnobSide = nil

                        if not sliderOptions.ignoresaved then
                            SaveConfig()
                        end
                    end)
                end

                lowKnob.InputBegan:Connect(function(inputObject)
                    if IsPrimaryPointerInput(inputObject) then
                        BeginKnobDrag("low")
                    end
                end)

                highKnob.InputBegan:Connect(function(inputObject)
                    if IsPrimaryPointerInput(inputObject) then
                        BeginKnobDrag("high")
                    end
                end)

                sliderTrack.InputBegan:Connect(function(inputObject)
                    if not IsPrimaryPointerInput(inputObject) then
                        return
                    end

                    BeginKnobDrag(rangeApi:pick_which(inputObject.Position.X))
                end)

                return rangeApi
            end

            function sizeManager:create_dropdown(dropdownOptions)
                if not dropdownOptions.Order then
                    layoutOrderCounter = layoutOrderCounter + 1
                end

                local searchRowHeight = dropdownOptions.search and 26 or 0
                local dropdownNotificationsEnabled = false
                local isInitialized = false
                local selectedOptions = {}

                if not dropdownOptions.Order then
                    if self._size == 0 then
                        self._size = 11
                    end

                    self._size = self._size + 45
                    RefreshModuleSize()
                end

                if not Library._config._flags[dropdownOptions.flag] then
                    Library._config._flags[dropdownOptions.flag] = {}
                end

                local dropdownButton = CreateInstance("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Name = "Dropdown",
                    Size = UDim2.new(0, 207, 0, 39),
                    BorderSizePixel = 0,
                    LayoutOrder = dropdownOptions.Order and dropdownOptions.OrderValue or layoutOrderCounter,
                    Parent = optionsContainer
                })

                local titleLabel = CreateInstance("TextLabel", {
                    FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                    TextSize = 11,
                    TextColor3 = Colors.Text,
                    TextTransparency = 0.16,
                    Text = dropdownOptions.title,
                    Size = UDim2.new(0, 207, 0, 13),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownButton
                })

                BindTheme(titleLabel, {TextColor3 = "Text"})

                if dropdownOptions.notify then
                    local notifyFlagName = dropdownOptions.flag .. "_dd_notify"

                    if not Library._config._library then
                        Library._config._library = {}
                    end

                    dropdownNotificationsEnabled = Library._config._library[notifyFlagName] == true

                    local bellButton = CreateInstance("ImageButton", {
                        Name = "DDBell",
                        Size = UDim2.new(0, 14, 0, 14),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        Image = ResolveIcon("bell"),
                        ImageColor3 = dropdownNotificationsEnabled and Colors.Accent or Colors.SubText,
                        ImageTransparency = dropdownNotificationsEnabled and 0.05 or 0.48,
                        BorderSizePixel = 0,
                        ZIndex = 6,
                        Parent = titleLabel
                    })

                    BindTheme(bellButton, {
                        ImageColor3 = function()
                            return dropdownNotificationsEnabled and Colors.Accent or Colors.SubText
                        end
                    })

                    bellButton.MouseButton1Click:Connect(function()
                        dropdownNotificationsEnabled = not dropdownNotificationsEnabled
                        Library._config._library[notifyFlagName] = dropdownNotificationsEnabled
                        SaveConfig()

                        PlayTween(bellButton, CreateQuintOutTweenInfo(0.3), {
                            ImageColor3 = dropdownNotificationsEnabled and Colors.Accent or Colors.SubText,
                            ImageTransparency = dropdownNotificationsEnabled and 0.05 or 0.48
                        })
                    end)
                end

                local dropdownPanel = CreateInstance("Frame", {
                    ClipsDescendants = true,
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 0.9,
                    Position = UDim2.new(0.5, 0, 1.2, 0),
                    Name = "Box",
                    Size = UDim2.new(0, 207, 0, 22),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Colors.Accent,
                    Parent = titleLabel
                })

                AddCorner(dropdownPanel, 4)

                local dropdownPanelStroke = AddStroke(dropdownPanel, Colors.StrokeHot, 0.42)

                BindTheme(dropdownPanel, {BackgroundColor3 = "Accent"})
                BindTheme(dropdownPanelStroke, {Color = "StrokeHot"})

                CreateInstance("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = dropdownPanel
                })

                local currentOptionRow = CreateInstance("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0, 207, 0, 22),
                    BorderSizePixel = 0,
                    LayoutOrder = 1,
                    Parent = dropdownPanel
                })

                local currentOptionLabel = CreateInstance("TextLabel", {
                    FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                    TextColor3 = Colors.Text,
                    TextTransparency = 0.1,
                    Name = "CurrentOption",
                    Size = UDim2.new(0, 161, 0, 13),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0.05, 0, 0.5, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 10,
                    Parent = currentOptionRow
                })

                CreateTextFadeGradient(currentOptionLabel)
                BindTheme(currentOptionLabel, {TextColor3 = "Text"})

                local arrowGlyph = CreateInstance("TextLabel", {
                    Text = "\u{21C5}",
                    FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                    TextSize = 10,
                    TextColor3 = Colors.Accent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0.91, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Parent = currentOptionRow
                })

                BindTheme(arrowGlyph, {TextColor3 = "Accent"})

                local dropdownSearchBox

                if dropdownOptions.search then
                    local searchRow = CreateInstance("Frame", {
                        Size = UDim2.new(0, 207, 0, searchRowHeight),
                        BackgroundColor3 = Colors.CardDeep,
                        BackgroundTransparency = 0.25,
                        BorderSizePixel = 0,
                        LayoutOrder = 2,
                        Parent = dropdownPanel
                    })

                    local dropdownSearchLine = CreateInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Colors.StrokeHot,
                        BackgroundTransparency = 0.5,
                        BorderSizePixel = 0,
                        Parent = searchRow
                    })

                    local dropdownSearchIcon = CreateInstance("ImageLabel", {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, 7, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        Image = ResolveIcon("search"),
                        ImageColor3 = Colors.SubText,
                        ImageTransparency = 0.25,
                        Parent = searchRow
                    })

                    dropdownSearchBox = CreateInstance("TextBox", {
                        Size = UDim2.new(1, -24, 1, -2),
                        Position = UDim2.new(0, 21, 0, 1),
                        BackgroundTransparency = 1,
                        TextColor3 = Colors.Text,
                        PlaceholderColor3 = Colors.SubText,
                        PlaceholderText = "Search...",
                        Text = "",
                        FontFace = CreateGothamFont(Enum.FontWeight.Regular),
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = false,
                        AutomaticSize = Enum.AutomaticSize.None,
                        Parent = searchRow
                    })

                    BindTheme(searchRow, {BackgroundColor3 = "CardDeep"})
                    BindTheme(dropdownSearchLine, {BackgroundColor3 = "StrokeHot"})
                    BindTheme(dropdownSearchIcon, {ImageColor3 = "SubText"})

                    BindTheme(dropdownSearchBox, {
                        TextColor3 = "Text",
                        PlaceholderColor3 = "SubText"
                    })
                end

                local optionsScroll = CreateInstance("ScrollingFrame", {
                    Active = true,
                    ScrollBarImageTransparency = 0.35,
                    ScrollBarImageColor3 = Colors.SubText,
                    AutomaticCanvasSize = Enum.AutomaticSize.XY,
                    ScrollBarThickness = 3,
                    Name = "Options",
                    Size = UDim2.new(0, 207, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    LayoutOrder = dropdownOptions.search and 3 or 2,
                    Parent = dropdownPanel
                })

                CreateInstance("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = optionsScroll
                })

                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, -1),
                    PaddingLeft = UDim.new(0, 8),
                    Parent = optionsScroll
                })

                BindTheme(optionsScroll, {ScrollBarImageColor3 = "SubText"})

                if dropdownSearchBox then
                    dropdownSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local searchQuery = dropdownSearchBox.Text:lower()

                        for _, optionRow in optionsScroll:GetChildren() do
                            if optionRow.Name == "Option" then
                                local optionButton = optionRow:IsA("TextButton") and optionRow or optionRow:FindFirstChild("OptionBtn")

                                if optionButton then
                                    local isVisible = searchQuery == "" or optionButton.Text:lower():find(searchQuery, 1, true) ~= nil
                                    optionRow.Visible = isVisible
                                end
                            end
                        end
                    end)
                end

                local function GetOptionButton(optionRow)
                    if optionRow:IsA("TextButton") then
                        return optionRow
                    end

                    return optionRow:FindFirstChild("OptionBtn")
                end

                local function RefreshOptionHighlights()
                    if dropdownOptions.multi_dropdown then
                        currentOptionLabel.Text = #selectedOptions == 0 and "None" or table.concat(selectedOptions, ", ")

                        for _, optionRow in optionsScroll:GetChildren() do
                            if optionRow.Name == "Option" then
                                local optionButton = GetOptionButton(optionRow)

                                if optionButton then
                                    local isSelected = table.find(selectedOptions, optionButton.Text) ~= nil
                                    optionButton.TextTransparency = isSelected and 0.1 or 0.6
                                    optionButton.TextColor3 = isSelected and Colors.AccentSoft or Colors.Text
                                end
                            end
                        end

                        Library._config._flags[dropdownOptions.flag] = {unpack(selectedOptions)}
                    else
                        for _, optionRow in optionsScroll:GetChildren() do
                            if optionRow.Name == "Option" then
                                local optionButton = GetOptionButton(optionRow)

                                if optionButton then
                                    local isSelected = optionButton.Text == currentOptionLabel.Text
                                    optionButton.TextTransparency = isSelected and 0.1 or 0.6
                                    optionButton.TextColor3 = isSelected and Colors.AccentSoft or Colors.Text
                                end
                            end
                        end
                    end
                end

                local function RefreshOptionColors()
                    for _, optionRow in optionsScroll:GetChildren() do
                        if optionRow.Name == "Option" then
                            local optionButton = GetOptionButton(optionRow)

                            if optionButton then
                                local isSelected

                                if dropdownOptions.multi_dropdown then
                                    isSelected = table.find(selectedOptions, optionButton.Text) ~= nil
                                else
                                    isSelected = optionButton.Text == currentOptionLabel.Text
                                end

                                optionButton.TextColor3 = isSelected and Colors.AccentSoft or Colors.Text
                            end

                            if optionRow:IsA("Frame") then
                                for _, child in optionRow:GetChildren() do
                                    if child:IsA("TextButton") and child ~= optionButton then
                                        child.BackgroundColor3 = Colors.Accent
                                        child.TextColor3 = Colors.AccentSoft
                                    end
                                end
                            end
                        end
                    end
                end

                BindThemeHook(dropdownButton, RefreshOptionColors)

                local dropdownApi = {_state = false, _size = 0}

                function dropdownApi:update(selectedValue)
                    if dropdownOptions.multi_dropdown then
                        local optionName = typeof(selectedValue) ~= "string" and selectedValue.Name or selectedValue
                        local existingIndex = table.find(selectedOptions, optionName)

                        if existingIndex then
                            table.remove(selectedOptions, existingIndex)
                        else
                            table.insert(selectedOptions, optionName)
                        end

                        RefreshOptionHighlights()
                        SaveConfig()
                        dropdownOptions.callback({unpack(selectedOptions)})

                        if dropdownNotificationsEnabled and isInitialized then
                            Library.SendNotification({
                                title = dropdownOptions.title or "Dropdown",
                                text = #selectedOptions > 0 and table.concat(selectedOptions, ", ") or "None",
                                icon = "check",
                                iconColor = Colors.Accent,
                                duration = 2.5
                            })
                        end
                    else
                        currentOptionLabel.Text = typeof(selectedValue) == "string" and selectedValue or selectedValue.Name
                        RefreshOptionHighlights()
                        Library._config._flags[dropdownOptions.flag] = selectedValue
                        SaveConfig()
                        dropdownOptions.callback(selectedValue)

                        if dropdownNotificationsEnabled and isInitialized then
                            Library.SendNotification({
                                title = dropdownOptions.title or "Dropdown",
                                text = typeof(selectedValue) == "string" and selectedValue or selectedValue.Name,
                                icon = "check",
                                iconColor = Colors.Accent,
                                duration = 2.5
                            })
                        end
                    end
                end

                local lastExpandedHeight = 0

                function dropdownApi:unfold_settings()
                    self._state = not self._state
                    local expandedHeight = self._size + searchRowHeight

                    if self._state then
                        sizeManager._multiplier = sizeManager._multiplier + expandedHeight
                        lastExpandedHeight = expandedHeight
                    else
                        sizeManager._multiplier = sizeManager._multiplier - expandedHeight
                        lastExpandedHeight = 0

                        if dropdownSearchBox then
                            dropdownSearchBox:ReleaseFocus()
                            dropdownSearchBox.Text = ""
                        end
                    end

                    PlayTween(moduleCard, CreateQuintOutTweenInfo(0.55), {
                        Size = UDim2.new(
                            1,
                            -8,
                            0,
                            ExpandedModuleBaseHeight + sizeManager._size + sizeManager._multiplier + 16
                        )
                    })

                    PlayTween(optionsContainer, CreateQuintOutTweenInfo(0.55), {
                        Size = UDim2.new(1, -8, 0, sizeManager._size + sizeManager._multiplier)
                    })

                    PlayTween(dropdownButton, CreateQuintOutTweenInfo(0.55), {
                        Size = UDim2.fromOffset(207, self._state and 39 + expandedHeight or 39)
                    })

                    PlayTween(dropdownPanel, CreateQuintOutTweenInfo(0.55), {
                        Size = UDim2.fromOffset(207, self._state and 22 + expandedHeight or 22)
                    })

                    PlayTween(arrowGlyph, CreateQuintOutTweenInfo(0.5), {Rotation = self._state and 180 or 0})
                end

                local function CreateOptionRow(optionValue, optionIndex)
                    local optionName = typeof(optionValue) == "string" and optionValue or optionValue.Name
                    local optionKeybindFlag = dropdownOptions.flag .. "_" .. optionName

                    if dropdownOptions.keybind then
                        local optionRow = CreateInstance("Frame", {
                            Size = UDim2.new(0, 186, 0, 16),
                            BackgroundTransparency = 1,
                            Name = "Option",
                            BorderSizePixel = 0,
                            Parent = optionsScroll
                        })

                        local optionButton = CreateInstance("TextButton", {
                            FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                            Active = false,
                            TextTransparency = 0.6,
                            TextSize = 10,
                            Size = UDim2.new(1, -44, 1, 0),
                            Position = UDim2.new(0, 0, 0, 0),
                            TextColor3 = Colors.Text,
                            Text = optionName,
                            AutoButtonColor = false,
                            Name = "OptionBtn",
                            BackgroundTransparency = 1,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Selectable = false,
                            BorderSizePixel = 0,
                            Parent = optionRow
                        })

                        CreateTextFadeGradient(optionButton)

                        local savedKeybind = Library._config._keybinds[optionKeybindFlag]
                        local keybindText = savedKeybind and StripKeyCodePrefix(savedKeybind) or "..."

                        local keybindButton = CreateInstance("TextButton", {
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, 0, 0.5, 0),
                            BackgroundColor3 = Colors.Accent,
                            BackgroundTransparency = 0.6,
                            TextColor3 = Colors.AccentSoft,
                            TextSize = 9,
                            FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                            Text = keybindText,
                            BorderSizePixel = 0,
                            AutoButtonColor = false,
                            Parent = optionRow
                        })

                        AddCorner(keybindButton, 3)

                        local function ResizeKeybindButton(text)
                            if text == "..." or text == "?" then
                                keybindButton.Size = UDim2.fromOffset(22, 14)
                                return
                            end

                            local textBounds = MeasureText(text, Font.new(GothamFontPath, Enum.FontWeight.SemiBold), 9)
                            keybindButton.Size = UDim2.fromOffset(math.max(22, textBounds.X + 8), 14)
                        end

                        ResizeKeybindButton(keybindText)

                        local function ConnectOptionKeybind()
                            Connections["dd_kb_" .. optionKeybindFlag] = UserInputService.InputBegan:Connect(function(inputObject, isProcessed)
                                if isProcessed then
                                    return
                                end

                                if tostring(inputObject.KeyCode) ~= Library._config._keybinds[optionKeybindFlag] then
                                    return
                                end

                                dropdownApi:update(optionValue)
                            end)
                        end

                        if savedKeybind then
                            ConnectOptionKeybind()
                        end

                        keybindButton.InputBegan:Connect(function(inputObject)
                            if inputObject.UserInputType ~= Enum.UserInputType.MouseButton3 then
                                return
                            end

                            if Library._choosing_keybind then
                                return
                            end

                            Library._choosing_keybind = true
                            keybindButton.Text = "?"
                            ResizeKeybindButton("?")

                            local keyConnection

                            keyConnection = UserInputService.InputBegan:Connect(function(keyInput, isProcessed)
                                if isProcessed then
                                    return
                                end

                                if keyInput.UserInputType ~= Enum.UserInputType.Keyboard then
                                    return
                                end

                                if keyInput.KeyCode == Enum.KeyCode.Unknown then
                                    return
                                end

                                keyConnection:Disconnect()

                                if keyInput.KeyCode == Enum.KeyCode.Backspace then
                                    Library._config._keybinds[optionKeybindFlag] = nil
                                    SaveConfig()
                                    keybindButton.Text = "..."
                                    ResizeKeybindButton("...")
                                    Connections:disconnect("dd_kb_" .. optionKeybindFlag)
                                else
                                    Library._config._keybinds[optionKeybindFlag] = tostring(keyInput.KeyCode)
                                    SaveConfig()
                                    keybindButton.Text = keyInput.KeyCode.Name
                                    ResizeKeybindButton(keyInput.KeyCode.Name)
                                    Connections:disconnect("dd_kb_" .. optionKeybindFlag)
                                    ConnectOptionKeybind()
                                end

                                Library._choosing_keybind = false
                            end)
                        end)

                        optionButton.MouseButton1Click:Connect(function()
                            dropdownApi:update(optionValue)
                        end)

                        if optionIndex <= dropdownOptions.maximum_options then
                            dropdownApi._size = dropdownApi._size + 16
                            optionsScroll.Size = UDim2.fromOffset(207, dropdownApi._size)
                        end
                    else
                        local optionButton = CreateInstance("TextButton", {
                            FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                            Active = false,
                            TextTransparency = 0.6,
                            TextSize = 10,
                            Size = UDim2.new(0, 186, 0, 16),
                            TextColor3 = Colors.Text,
                            Text = optionName,
                            AutoButtonColor = false,
                            Name = "Option",
                            BackgroundTransparency = 1,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Selectable = false,
                            BorderSizePixel = 0,
                            Parent = optionsScroll
                        })

                        CreateTextFadeGradient(optionButton)

                        optionButton.MouseButton1Click:Connect(function()
                            dropdownApi:update(optionValue)
                        end)

                        if optionIndex <= dropdownOptions.maximum_options then
                            dropdownApi._size = dropdownApi._size + 16
                            optionsScroll.Size = UDim2.fromOffset(207, dropdownApi._size)
                        end
                    end
                end

                if #dropdownOptions.options > 0 then
                    dropdownApi._size = 3

                    for optionIndex, optionValue in dropdownOptions.options do
                        CreateOptionRow(optionValue, optionIndex)
                    end
                end

                function dropdownApi:set_options(newOptions)
                    if self._state then
                        local expandedHeight = self._size + searchRowHeight
                        self._state = false
                        sizeManager._multiplier = sizeManager._multiplier - expandedHeight
                        lastExpandedHeight = 0
                        dropdownButton.Size = UDim2.fromOffset(207, 39)
                        dropdownPanel.Size = UDim2.fromOffset(207, 22)
                        arrowGlyph.Rotation = 0

                        if dropdownSearchBox then
                            dropdownSearchBox:ReleaseFocus()
                            dropdownSearchBox.Text = ""
                        end
                    end

                    for _, optionRow in optionsScroll:GetChildren() do
                        if optionRow.Name == "Option" then
                            optionRow:Destroy()
                        end
                    end

                    local previousSelectionText = currentOptionLabel.Text
                    local previousMultiSelection = {}

                    if dropdownOptions.multi_dropdown then
                        for _, optionName in ipairs(selectedOptions) do
                            previousMultiSelection[optionName] = true
                        end
                    end

                    selectedOptions = {}
                    self._size = #newOptions > 0 and 3 or 0
                    dropdownOptions.options = newOptions
                    dropdownOptions.maximum_options = #newOptions

                    for optionIndex, optionValue in ipairs(newOptions) do
                        CreateOptionRow(optionValue, optionIndex)
                    end

                    if dropdownOptions.multi_dropdown then
                        local restoredSelection = {}

                        for _, optionValue in ipairs(newOptions) do
                            local optionName = typeof(optionValue) == "string" and optionValue or optionValue.Name

                            if previousMultiSelection[optionName] then
                                table.insert(restoredSelection, optionName)
                            end
                        end

                        selectedOptions = restoredSelection

                        if #selectedOptions == 0 then
                            currentOptionLabel.Text = "None"
                            Library._config._flags[dropdownOptions.flag] = {}
                        else
                            currentOptionLabel.Text = table.concat(selectedOptions, ", ")
                            Library._config._flags[dropdownOptions.flag] = {unpack(selectedOptions)}
                        end

                        RefreshOptionHighlights()
                    else
                        local matchedPrevious = false

                        for _, optionValue in ipairs(newOptions) do
                            local optionName = typeof(optionValue) == "string" and optionValue or optionValue.Name

                            if optionName == previousSelectionText then
                                currentOptionLabel.Text = optionName
                                Library._config._flags[dropdownOptions.flag] = optionValue
                                matchedPrevious = true
                                break
                            end
                        end

                        if not matchedPrevious then
                            if newOptions[1] then
                                currentOptionLabel.Text = typeof(newOptions[1]) == "string" and newOptions[1] or newOptions[1].Name
                                Library._config._flags[dropdownOptions.flag] = newOptions[1]
                            else
                                currentOptionLabel.Text = "None"
                                Library._config._flags[dropdownOptions.flag] = "None"
                            end
                        end

                        RefreshOptionHighlights()
                    end

                    SaveConfig()
                    optionsScroll.Size = UDim2.fromOffset(207, self._size)

                    if sizeManager._state then
                        PlayTween(moduleCard, CreateQuintOutTweenInfo(0.4), {
                            Size = UDim2.new(
                                1,
                                -8,
                                0,
                                ExpandedModuleBaseHeight + sizeManager._size + sizeManager._multiplier + 16
                            )
                        })

                        PlayTween(optionsContainer, CreateQuintOutTweenInfo(0.4), {
                            Size = UDim2.new(1, -8, 0, sizeManager._size + sizeManager._multiplier)
                        })
                    end
                end

                function dropdownApi:New(newOptions)
                    dropdownButton:Destroy()
                    newOptions.OrderValue = dropdownButton.LayoutOrder
                    sizeManager._multiplier = sizeManager._multiplier - lastExpandedHeight
                    return sizeManager:create_dropdown(newOptions)
                end

                if dropdownOptions.multi_dropdown then
                    local savedSelection = Library._config._flags[dropdownOptions.flag]

                    if typeof(savedSelection) == "table" and #savedSelection > 0 then
                        for _, optionValue in ipairs(savedSelection) do
                            local optionName = typeof(optionValue) ~= "string" and optionValue.Name or optionValue

                            if not table.find(selectedOptions, optionName) then
                                table.insert(selectedOptions, optionName)
                            end
                        end

                        RefreshOptionHighlights()
                        dropdownOptions.callback({unpack(selectedOptions)})
                    else
                        currentOptionLabel.Text = "None"
                    end
                elseif Library:flag_type(dropdownOptions.flag, "string") then
                    dropdownApi:update(Library._config._flags[dropdownOptions.flag])
                elseif dropdownOptions.options[1] then
                    currentOptionLabel.Text = typeof(dropdownOptions.options[1]) == "string" and dropdownOptions.options[1]
                        or dropdownOptions.options[1].Name

                    RefreshOptionHighlights()
                    Library._config._flags[dropdownOptions.flag] = dropdownOptions.options[1]
                    SaveConfig()
                    dropdownOptions.callback(dropdownOptions.options[1])
                end

                if not dropdownOptions.multi_dropdown then
                    Library:register_flag(dropdownOptions.flag, function(flagValue)
                        if type(flagValue) == "string" and flagValue ~= currentOptionLabel.Text then
                            dropdownApi:update(flagValue)
                        end
                    end)
                end

                isInitialized = true

                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownApi:unfold_settings()
                end)

                return dropdownApi
            end

            function sizeManager:create_checkbox(checkboxOptions)
                layoutOrderCounter = layoutOrderCounter + 1
                local checkboxApi = {_state = false}

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + 21
                RefreshModuleSize()

                local checkboxRow = CreateInstance("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Name = "Checkbox",
                    Size = UDim2.new(0, 207, 0, 15),
                    BorderSizePixel = 0,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                local checkboxTitle = CreateInstance("TextLabel", {
                    FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                    TextSize = 11,
                    TextColor3 = Colors.Text,
                    TextTransparency = 0.16,
                    Text = checkboxOptions.title or "",
                    Size = UDim2.new(0, 142, 0, 13),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = checkboxRow
                })

                local checkboxKeybindBadge = CreateInstance("Frame", {
                    Name = "CBKey",
                    Size = UDim2.fromOffset(14, 14),
                    Position = UDim2.new(1, -20, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Colors.Accent,
                    BackgroundTransparency = 0.6,
                    BorderSizePixel = 0,
                    Parent = checkboxRow
                })

                AddCorner(checkboxKeybindBadge, 4)

                local savedKeybind = Library._config._keybinds[checkboxOptions.flag]

                local checkboxKeybindLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.AccentSoft,
                    TextSize = 10,
                    Font = Enum.Font.SourceSans,
                    Text = savedKeybind and StripKeyCodePrefix(savedKeybind) or "...",
                    Parent = checkboxKeybindBadge
                })

                local function ResizeKeybindBadge(text)
                    if text == "..." or text == "?" then
                        checkboxKeybindBadge.Size = UDim2.fromOffset(14, 14)
                        return
                    end

                    local textBounds = MeasureText(text, Font.fromEnum(Enum.Font.SourceSans), 10)
                    checkboxKeybindBadge.Size = UDim2.fromOffset(math.max(14, textBounds.X + 6), 14)
                end

                ResizeKeybindBadge(checkboxKeybindLabel.Text)

                local checkboxBox = CreateInstance("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 0.86,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Name = "Box",
                    Size = UDim2.new(0, 15, 0, 15),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Colors.Accent,
                    Parent = checkboxRow
                })

                AddCorner(checkboxBox, 4)

                local checkboxBoxStroke = AddStroke(checkboxBox, Colors.StrokeHot, 0.3)

                local checkboxFill = CreateInstance("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 0.08,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Name = "Fill",
                    Size = UDim2.fromOffset(0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Colors.Accent,
                    Parent = checkboxBox
                })

                AddCorner(checkboxFill, 3)

                BindTheme(checkboxTitle, {TextColor3 = "Text"})
                BindTheme(checkboxKeybindBadge, {BackgroundColor3 = "Accent"})
                BindTheme(checkboxKeybindLabel, {TextColor3 = "AccentSoft"})
                BindTheme(checkboxBox, {BackgroundColor3 = "Accent"})
                BindTheme(checkboxBoxStroke, {Color = "StrokeHot"})
                BindTheme(checkboxFill, {BackgroundColor3 = "Accent"})

                function checkboxApi:change_state(isChecked)
                    self._state = isChecked

                    PlayTween(checkboxBox, CreateQuintOutTweenInfo(0.45), {
                        BackgroundTransparency = isChecked and 0.62 or 0.86
                    })

                    PlayTween(
                        checkboxFill,
                        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        {Size = isChecked and UDim2.fromOffset(9, 9) or UDim2.fromOffset(0, 0)}
                    )

                    Library._config._flags[checkboxOptions.flag] = self._state
                    SaveConfig()
                    checkboxOptions.callback(self._state)
                end

                if Library:flag_type(checkboxOptions.flag, "boolean") then
                    checkboxApi:change_state(Library._config._flags[checkboxOptions.flag])
                end

                checkboxRow.MouseButton1Click:Connect(function()
                    checkboxApi:change_state(not checkboxApi._state)
                end)

                checkboxRow.InputBegan:Connect(function(inputObject, isProcessed)
                    if isProcessed
                        or inputObject.UserInputType ~= Enum.UserInputType.MouseButton3
                        or Library._choosing_keybind then
                        return
                    end

                    Library._choosing_keybind = true

                    local keyConnection

                    keyConnection = UserInputService.InputBegan:Connect(function(keyInput, isKeyProcessed)
                        if isKeyProcessed
                            or keyInput.UserInputType ~= Enum.UserInputType.Keyboard
                            or keyInput.KeyCode == Enum.KeyCode.Unknown then
                            return
                        end

                        keyConnection:Disconnect()

                        if keyInput.KeyCode == Enum.KeyCode.Backspace then
                            Library._config._keybinds[checkboxOptions.flag] = nil
                            SaveConfig()
                            checkboxKeybindLabel.Text = "..."
                            ResizeKeybindBadge("...")
                            Connections:disconnect(checkboxOptions.flag .. "_keybind")
                        else
                            Library._config._keybinds[checkboxOptions.flag] = tostring(keyInput.KeyCode)
                            SaveConfig()
                            Connections:disconnect(checkboxOptions.flag .. "_keybind")

                            Connections[checkboxOptions.flag .. "_keybind"] = UserInputService.InputBegan:Connect(function(boundInput, isBoundProcessed)
                                if isBoundProcessed then
                                    return
                                end

                                if tostring(boundInput.KeyCode) == Library._config._keybinds[checkboxOptions.flag] then
                                    checkboxApi:change_state(not checkboxApi._state)
                                end
                            end)

                            checkboxKeybindLabel.Text = StripKeyCodePrefix(Library._config._keybinds[checkboxOptions.flag])
                            ResizeKeybindBadge(checkboxKeybindLabel.Text)
                        end

                        Library._choosing_keybind = false
                    end)
                end)

                Connections[checkboxOptions.flag .. "_keypress"] = UserInputService.InputBegan:Connect(function(inputObject, isProcessed)
                    if isProcessed or inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end

                    local boundKeybind = Library._config._keybinds[checkboxOptions.flag]

                    if boundKeybind and tostring(inputObject.KeyCode) == boundKeybind then
                        checkboxApi:change_state(not checkboxApi._state)
                    end
                end)

                Library:register_flag(checkboxOptions.flag, function(flagValue)
                    if type(flagValue) == "boolean" and flagValue ~= checkboxApi._state then
                        checkboxApi:change_state(flagValue)
                    end
                end)

                Library._keybind_appliers[checkboxOptions.flag] = function()
                    local boundKeybind = Library._config._keybinds[checkboxOptions.flag]

                    checkboxKeybindLabel.Text = boundKeybind and StripKeyCodePrefix(boundKeybind) or "..."
                    ResizeKeybindBadge(checkboxKeybindLabel.Text)
                end

                return checkboxApi
            end

            function sizeManager:create_divider(dividerOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + 27
                RefreshModuleSize()

                local dividerRow = CreateInstance("Frame", {
                    Size = UDim2.new(0, 207, 0, 20),
                    BackgroundTransparency = 1,
                    Name = "DividerRow",
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                if dividerOptions and dividerOptions.showtopic then
                    local dividerLabel = CreateInstance("TextLabel", {
                        FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                        TextColor3 = Colors.Text,
                        TextTransparency = 0.2,
                        Text = dividerOptions.title,
                        Size = UDim2.new(0, 153, 0, 13),
                        Position = UDim2.new(0.5, 0, 0.501, 0),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        TextSize = 11,
                        ZIndex = 3,
                        TextStrokeTransparency = 0,
                        Parent = dividerRow
                    })

                    BindTheme(dividerLabel, {TextColor3 = "Text"})
                end

                local shouldShowLine = not dividerOptions or not dividerOptions.disableline

                if shouldShowLine then
                    local line = CreateInstance("Frame", {
                        Name = "DividerLine",
                        Size = UDim2.new(1, 0, 0, 1),
                        BackgroundColor3 = Colors.Text,
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        BackgroundTransparency = 0.55,
                        Position = UDim2.new(0, 0, 0.5, -0.5),
                        Parent = dividerRow
                    })

                    AddCorner(line, 2)
                    BindTheme(line, {BackgroundColor3 = "Text"})

                    CreateInstance("UIGradient", {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Parent = line
                    })
                end

                return true
            end

            function sizeManager:create_textbox(textboxOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + 45
                RefreshModuleSize()

                local textboxTitle = CreateInstance("TextLabel", {
                    Name = "TextboxTitle",
                    FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                    TextColor3 = Colors.Text,
                    TextTransparency = 0.16,
                    Text = textboxOptions.title or "Textbox",
                    Size = UDim2.new(0, 207, 0, 13),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 10,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                BindTheme(textboxTitle, {TextColor3 = "Text"})

                local textbox = CreateInstance("TextBox", {
                    FontFace = Font.new(SourceSansProFontPath, Enum.FontWeight.Regular),
                    TextColor3 = Colors.Text,
                    PlaceholderText = textboxOptions.placeholder or "Enter text...",
                    PlaceholderColor3 = Colors.SubText,
                    Text = Library._config._flags[textboxOptions.flag] or "",
                    Name = "Textbox",
                    Size = UDim2.new(0, 207, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 11,
                    BackgroundColor3 = Colors.CardDeep,
                    BackgroundTransparency = 0,
                    ClearTextOnFocus = false,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                AddCorner(textbox, 5)
                local textboxStroke = AddStroke(textbox, Colors.Accent, 0.55)

                BindTheme(textbox, {
                    BackgroundColor3 = "CardDeep",
                    TextColor3 = "Text",
                    PlaceholderColor3 = "SubText"
                })

                BindTheme(textboxStroke, {Color = "Accent"})

                CreateInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 7),
                    Parent = textbox
                })

                textbox.Focused:Connect(function()
                    PlayTween(textboxStroke, TweenInfo.new(0.2), {Transparency = 0.1})
                end)

                textbox.FocusLost:Connect(function()
                    PlayTween(textboxStroke, TweenInfo.new(0.2), {Transparency = 0.55})
                end)

                local textboxApi = {
                    _text = ""
                }

                function textboxApi:update_text(newText)
                    self._text = newText
                    Library._config._flags[textboxOptions.flag] = newText
                    SaveConfig()
                    textboxOptions.callback(newText)
                end

                function textboxApi:set_text(newText)
                    textbox.Text = newText
                    self._text = newText
                end

                function textboxApi:get_text()
                    return textbox.Text
                end

                if Library:flag_type(textboxOptions.flag, "string") then
                    textboxApi:update_text(Library._config._flags[textboxOptions.flag])
                end

                Library:register_flag(textboxOptions.flag, function(flagValue)
                    if type(flagValue) == "string" and flagValue ~= textbox.Text then
                        textboxApi:set_text(flagValue)
                        textboxApi:update_text(flagValue)
                    end
                end)

                textbox.FocusLost:Connect(function()
                    PlayTween(textboxStroke, TweenInfo.new(0.2), {Transparency = 0.55})
                    textboxApi:update_text(textbox.Text)
                end)

                return textboxApi
            end

            function sizeManager:create_label(labelOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + (labelOptions.customScale or 55)
                RefreshModuleSize()

                local labelCard = CreateInstance("Frame", {
                    Name = "Label",
                    BackgroundColor3 = Colors.CardDeep,
                    BackgroundTransparency = 0.15,
                    Size = UDim2.new(0, 207, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                AddCorner(labelCard, 4)

                local labelStroke = AddStroke(labelCard, Colors.Stroke, 0.25)

                BindTheme(labelCard, {BackgroundColor3 = "CardDeep"})
                BindTheme(labelStroke, {Color = "Stroke"})

                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, 7),
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    Parent = labelCard
                })

                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = labelCard
                })

                if labelOptions.title then
                    local labelTitle = CreateInstance("TextLabel", {
                        FontFace = CreateGothamFont(Enum.FontWeight.Bold),
                        TextColor3 = Colors.Text,
                        TextTransparency = 0.08,
                        Text = labelOptions.title,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 11,
                        TextWrapped = true,
                        LayoutOrder = 1,
                        Parent = labelCard
                    })

                    BindTheme(labelTitle, {TextColor3 = "Text"})
                end

                local labelBody = CreateInstance("TextLabel", {
                    FontFace = CreateGothamFont(Enum.FontWeight.Regular),
                    TextColor3 = Colors.SubText,
                    Text = labelOptions.text or "",
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextSize = 10,
                    TextWrapped = true,
                    LayoutOrder = 2,
                    Parent = labelCard
                })

                BindTheme(labelBody, {TextColor3 = "SubText"})

                local labelApi = {}

                function labelApi:set_text(newText)
                    labelBody.Text = newText
                end

                return labelApi
            end

            function sizeManager:create_button(buttonOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                local reservedHeight = 52

                if buttonOptions.title then
                    reservedHeight = reservedHeight + 20
                end

                if buttonOptions.description then
                    reservedHeight = reservedHeight + 18
                end

                self._size = self._size + (buttonOptions.customScale or reservedHeight)
                RefreshModuleSize()

                local buttonCard = CreateInstance("Frame", {
                    Name = "ModuleButton",
                    BackgroundColor3 = Colors.CardDeep,
                    BackgroundTransparency = 0.15,
                    Size = UDim2.new(0, 207, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                AddCorner(buttonCard, 4)

                local buttonCardStroke = AddStroke(buttonCard, Colors.Stroke, 0.25)

                BindTheme(buttonCard, {BackgroundColor3 = "CardDeep"})
                BindTheme(buttonCardStroke, {Color = "Stroke"})

                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    Parent = buttonCard
                })

                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = buttonCard
                })

                local buttonTitle

                if buttonOptions.title then
                    buttonTitle = CreateInstance("TextLabel", {
                        Name = "Title",
                        FontFace = CreateGothamFont(Enum.FontWeight.Bold),
                        TextColor3 = Colors.Text,
                        TextTransparency = 0.08,
                        Text = buttonOptions.title,
                        TextSize = 12,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        LayoutOrder = 1,
                        Parent = buttonCard
                    })

                    BindTheme(buttonTitle, {TextColor3 = "Text"})

                    if buttonOptions.rich then
                        buttonTitle.RichText = true
                    end
                end

                local buttonDescription

                if buttonOptions.description then
                    buttonDescription = CreateInstance("TextLabel", {
                        Name = "Description",
                        FontFace = CreateGothamFont(Enum.FontWeight.Regular),
                        TextColor3 = Colors.SubText,
                        Text = buttonOptions.description,
                        TextSize = 10,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        LayoutOrder = 2,
                        Parent = buttonCard
                    })

                    BindTheme(buttonDescription, {TextColor3 = "SubText"})
                end

                local button = CreateInstance("TextButton", {
                    Name = "Button",
                    FontFace = CreateGothamFont(Enum.FontWeight.Bold),
                    TextColor3 = Colors.Text,
                    Text = buttonOptions.buttonText or Language.ButtonClick,
                    TextSize = 11,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Colors.Accent,
                    BackgroundTransparency = 0.25,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    LayoutOrder = 3,
                    Parent = buttonCard
                })

                AddCorner(button, 5)
                BindTheme(button, {BackgroundColor3 = "Accent", TextColor3 = "Text"})

                button.MouseEnter:Connect(function()
                    PlayTween(buttonCard, CreateQuintOutTweenInfo(0.25), {
                        BackgroundColor3 = LerpColor(Colors.CardDeep, Colors.Accent, 0.1),
                        BackgroundTransparency = 0.08
                    })

                    PlayTween(button, CreateQuintOutTweenInfo(0.25), {BackgroundTransparency = 0.05})
                end)

                button.MouseLeave:Connect(function()
                    PlayTween(buttonCard, CreateQuintOutTweenInfo(0.25), {
                        BackgroundColor3 = Colors.CardDeep,
                        BackgroundTransparency = 0.15
                    })

                    PlayTween(button, CreateQuintOutTweenInfo(0.25), {BackgroundTransparency = 0.25})
                end)

                button.MouseButton1Down:Connect(function()
                    PlayTween(button, CreateSmoothTweenInfo(0.08), {
                        BackgroundTransparency = 0.5,
                        Size = UDim2.new(1, -2, 0, 30)
                    })
                end)

                button.MouseButton1Up:Connect(function()
                    PlayTween(button, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.05,
                        Size = UDim2.new(1, 0, 0, 30)
                    })
                end)

                button.MouseButton1Click:Connect(function()
                    if buttonOptions.callback then
                        buttonOptions.callback()
                    end
                end)

                local buttonApi = {}

                function buttonApi:set_title(newTitle)
                    if buttonTitle then
                        buttonTitle.Text = newTitle
                    end
                end

                function buttonApi:set_description(newDescription)
                    if buttonDescription then
                        buttonDescription.Text = newDescription
                    end
                end

                function buttonApi:set_button_text(newText)
                    button.Text = newText
                end

                function buttonApi:set_callback(newCallback)
                    buttonOptions.callback = newCallback
                end

                return buttonApi
            end

            function sizeManager:create_buttongroup(groupOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + 32
                RefreshModuleSize()

                local buttonDefinitions = groupOptions.buttons or {}
                local buttonCount = math.max(1, #buttonDefinitions)
                local buttonWidth = math.floor((207 - 4 * (buttonCount - 1)) / buttonCount)
                local buttonColors = {}

                local buttonGroupApi = {
                    _buttons = {}
                }

                local buttonRow = CreateInstance("Frame", {
                    Name = "ButtonGroup",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 207, 0, 26),
                    BorderSizePixel = 0,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                CreateInstance("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = buttonRow
                })

                for buttonIndex, buttonDefinition in ipairs(buttonDefinitions) do
                    local button = CreateInstance("TextButton", {
                        Name = "Button",
                        FontFace = CreateGothamFont(Enum.FontWeight.Bold),
                        TextSize = 10,
                        TextColor3 = Colors.Text,
                        Text = buttonDefinition.text or "Button " .. buttonIndex,
                        Size = UDim2.new(0, buttonWidth, 1, 0),
                        BackgroundColor3 = Colors.Accent,
                        BackgroundTransparency = 0.35,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        LayoutOrder = buttonIndex,
                        Parent = buttonRow
                    })

                    AddCorner(button, 5)

                    BindTheme(button, {
                        BackgroundColor3 = function()
                            return buttonColors[buttonIndex] or Colors.Accent
                        end,
                        TextColor3 = "Text"
                    })

                    button.MouseEnter:Connect(function()
                        PlayTween(button, CreateQuintOutTweenInfo(0.25), {BackgroundTransparency = 0.1})
                    end)

                    button.MouseLeave:Connect(function()
                        PlayTween(button, CreateQuintOutTweenInfo(0.25), {BackgroundTransparency = 0.35})
                    end)

                    button.MouseButton1Down:Connect(function()
                        PlayTween(button, CreateSmoothTweenInfo(0.1), {BackgroundTransparency = 0.6})
                    end)

                    button.MouseButton1Up:Connect(function()
                        PlayTween(button, CreateSmoothTweenInfo(0.2), {BackgroundTransparency = 0.1})
                    end)

                    button.MouseButton1Click:Connect(function()
                        if buttonDefinition.callback then
                            buttonDefinition.callback()
                        end
                    end)

                    buttonGroupApi._buttons[buttonIndex] = button
                end

                function buttonGroupApi:set_button_text(buttonIndex, newText)
                    if self._buttons[buttonIndex] then
                        self._buttons[buttonIndex].Text = newText
                    end
                end

                function buttonGroupApi:set_button_color(buttonIndex, newColor)
                    if self._buttons[buttonIndex] then
                        buttonColors[buttonIndex] = newColor

                        PlayTween(self._buttons[buttonIndex], CreateQuintOutTweenInfo(0.25), {
                            BackgroundColor3 = newColor or Colors.Accent
                        })
                    end
                end

                function buttonGroupApi:set_button_callback(buttonIndex, newCallback)
                    if buttonDefinitions[buttonIndex] then
                        buttonDefinitions[buttonIndex].callback = newCallback
                    end
                end

                return buttonGroupApi
            end

            function sizeManager:create_paragraph(paragraphOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + (paragraphOptions.customScale or 70)
                RefreshModuleSize()

                local paragraphCard = CreateInstance("Frame", {
                    BackgroundColor3 = Colors.CardDeep,
                    BackgroundTransparency = 0.15,
                    Size = UDim2.new(1, -16, 0, 30),
                    BorderSizePixel = 0,
                    Name = "Paragraph",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                AddCorner(paragraphCard, 4)

                local paragraphStroke = AddStroke(paragraphCard, Colors.Stroke, 0.25)

                BindTheme(paragraphCard, {BackgroundColor3 = "CardDeep"})
                BindTheme(paragraphStroke, {Color = "Stroke"})

                local paragraphTitle = CreateInstance("TextLabel", {
                    FontFace = CreateGothamFont(Enum.FontWeight.Bold),
                    TextColor3 = Colors.Text,
                    TextTransparency = 0.08,
                    Text = paragraphOptions.title or "Title",
                    Size = UDim2.new(1, -10, 0, 20),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 12,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Parent = paragraphCard
                })

                local bodyLabel = CreateInstance("TextLabel", {
                    FontFace = CreateGothamFont(Enum.FontWeight.Regular),
                    TextColor3 = Colors.SubText,
                    Size = UDim2.new(1, -10, 0, 20),
                    Position = UDim2.new(0, 5, 0, 30),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextSize = 11,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Parent = paragraphCard
                })

                BindTheme(paragraphTitle, {TextColor3 = "Text"})
                BindTheme(bodyLabel, {TextColor3 = "SubText"})
                bodyLabel:SetAttribute("SubText", true)
                ApplyRichOrPlainText(bodyLabel, paragraphOptions)
                AddCardHoverEffect(paragraphCard)
                return {}
            end

            function sizeManager:create_text(textOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + (textOptions.customScale or 50)
                RefreshModuleSize()

                local textCard = CreateInstance("Frame", {
                    BackgroundColor3 = Colors.CardDeep,
                    BackgroundTransparency = 0.15,
                    Size = UDim2.new(0, 207, 0, textOptions.CustomYSize or 20),
                    BorderSizePixel = 0,
                    Name = "Text",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                AddCorner(textCard, 4)

                local textCardStroke = AddStroke(textCard, Colors.Stroke, 0.25)

                BindTheme(textCard, {BackgroundColor3 = "CardDeep"})
                BindTheme(textCardStroke, {Color = "Stroke"})

                local textLabel = CreateInstance("TextLabel", {
                    FontFace = CreateGothamFont(Enum.FontWeight.Regular),
                    TextColor3 = Colors.SubText,
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextSize = 10,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Parent = textCard
                })

                BindTheme(textLabel, {TextColor3 = "SubText"})
                textLabel:SetAttribute("SubText", true)
                ApplyRichOrPlainText(textLabel, textOptions)
                AddCardHoverEffect(textCard)

                return {
                    Set = function(self, newOptions)
                        ApplyRichOrPlainText(textLabel, newOptions)
                    end
                }
            end

            function sizeManager:create_feature(featureOptions)
                layoutOrderCounter = layoutOrderCounter + 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + 20
                RefreshModuleSize()

                local featureRow = CreateInstance("Frame", {
                    Name = "Feature",
                    Size = UDim2.new(0, 207, 0, 16),
                    BackgroundTransparency = 1,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                CreateInstance("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = featureRow
                })

                local featureButton = CreateInstance("TextButton", {
                    Name = "FeatureBtn",
                    FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                    TextSize = 11,
                    Size = UDim2.new(1, -50, 0, 16),
                    BackgroundColor3 = Colors.CardDeep,
                    BackgroundTransparency = 0.38,
                    TextColor3 = Colors.Text,
                    Text = "  " .. (featureOptions.title or "Feature"),
                    AutoButtonColor = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 0.12,
                    Parent = featureRow
                })

                AddCorner(featureButton, 3)

                BindTheme(featureButton, {
                    BackgroundColor3 = "CardDeep",
                    TextColor3 = "Text"
                })

                local sideControls = CreateInstance("Frame", {
                    Size = UDim2.new(0, 45, 0, 16),
                    BackgroundTransparency = 1,
                    Parent = featureRow
                })

                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0.1, 0),
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = sideControls
                })

                local featureKeybindBadge = CreateInstance("TextLabel", {
                    Name = "FeatureKey",
                    FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
                    Size = UDim2.new(0, 15, 0, 15),
                    BackgroundColor3 = Colors.Accent,
                    TextColor3 = Colors.AccentSoft,
                    TextSize = 11,
                    BackgroundTransparency = 0.62,
                    LayoutOrder = 2,
                    Parent = sideControls
                })

                AddCorner(featureKeybindBadge, 3)

                local featureKeybindStroke = AddStroke(featureKeybindBadge, Colors.Accent, 0.4, true)
                featureKeybindStroke.Thickness = 1

                BindTheme(featureKeybindBadge, {
                    BackgroundColor3 = "Accent",
                    TextColor3 = "AccentSoft"
                })

                BindTheme(featureKeybindStroke, {Color = "Accent"})

                local keybindCaptureButton = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                    Parent = featureKeybindBadge
                })

                if not Library._config._flags then
                    Library._config._flags = {}
                end

                if not Library._config._flags[featureOptions.flag] then
                    Library._config._flags[featureOptions.flag] = {checked = false, BIND = featureOptions.default or "Unknown"}
                end

                local isChecked = Library._config._flags[featureOptions.flag].checked

                featureKeybindBadge.Text = Library._config._flags[featureOptions.flag].BIND == "Unknown" and "..."
                    or Library._config._flags[featureOptions.flag].BIND

                local toggleChecked

                if not featureOptions.disablecheck then
                    local checkButton = CreateInstance("TextButton", {
                        Size = UDim2.new(0, 15, 0, 15),
                        BackgroundColor3 = isChecked and Colors.Accent or Colors.CardDeep,
                        BackgroundTransparency = isChecked and 0.32 or 0.5,
                        Text = "",
                        LayoutOrder = 1,
                        Parent = sideControls
                    })

                    AddCorner(checkButton, 3)

                    local checkButtonStroke = AddStroke(checkButton, Colors.Accent, 0.35, true)
                    checkButtonStroke.Thickness = 1

                    BindTheme(checkButton, {
                        BackgroundColor3 = function()
                            return isChecked and Colors.Accent or Colors.CardDeep
                        end
                    })

                    BindTheme(checkButtonStroke, {Color = "Accent"})

                    toggleChecked = function()
                        isChecked = not isChecked

                        PlayTween(checkButton, TweenInfo.new(0.3), {
                            BackgroundColor3 = isChecked and Colors.Accent or Colors.CardDeep,
                            BackgroundTransparency = isChecked and 0.32 or 0.5
                        })

                        Library._config._flags[featureOptions.flag].checked = isChecked
                        SaveConfig()

                        if featureOptions.callback then
                            featureOptions.callback(isChecked)
                        end
                    end

                    checkButton.MouseButton1Click:Connect(toggleChecked)
                else
                    toggleChecked = function()
                        if featureOptions.button_callback then
                            featureOptions.button_callback()
                        end
                    end
                end

                keybindCaptureButton.MouseButton1Click:Connect(function()
                    featureKeybindBadge.Text = "..."

                    local keyConnection

                    keyConnection = UserInputService.InputBegan:Connect(function(inputObject, isProcessed)
                        if isProcessed then
                            return
                        end

                        if inputObject.UserInputType == Enum.UserInputType.Keyboard then
                            local keyName = inputObject.KeyCode.Name
                            Library._config._flags[featureOptions.flag].BIND = keyName
                            featureKeybindBadge.Text = keyName ~= "Unknown" and keyName or "..."
                            SaveConfig()
                            keyConnection:Disconnect()
                        elseif inputObject.UserInputType == Enum.UserInputType.MouseButton3 then
                            Library._config._flags[featureOptions.flag].BIND = "Unknown"
                            featureKeybindBadge.Text = "..."
                            SaveConfig()
                            keyConnection:Disconnect()
                        end
                    end)

                    Connections["feat_keybind_input_" .. featureOptions.flag] = keyConnection
                end)

                Connections["feat_keybind_press_" .. featureOptions.flag] = UserInputService.InputBegan:Connect(function(inputObject, isProcessed)
                    if isProcessed or inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end

                    if inputObject.KeyCode.Name == Library._config._flags[featureOptions.flag].BIND then
                        toggleChecked()
                    end
                end)

                featureButton.MouseButton1Click:Connect(function()
                    if featureOptions.button_callback then
                        featureOptions.button_callback()
                    end
                end)

                if not featureOptions.disablecheck and featureOptions.callback then
                    featureOptions.callback(isChecked)
                end

                return featureRow
            end

            function sizeManager:create_colorpicker(colorOptions)
                layoutOrderCounter = layoutOrderCounter + 1
                local colorState = {_h = 0, _s = 1, _v = 1}

                if Library._config._flags[colorOptions.flag] then
                    local savedColor = Library._config._flags[colorOptions.flag]

                    if type(savedColor) == "table" and savedColor.H ~= nil then
                        colorState._h = savedColor.H
                        colorState._s = savedColor.S
                        colorState._v = savedColor.V
                    end
                elseif colorOptions.color then
                    colorState._h, colorState._s, colorState._v = Color3.toHSV(colorOptions.color)
                end

                if self._size == 0 then
                    self._size = 11
                end

                self._size = self._size + 32
                RefreshModuleSize()

                local row, swatch, arrow = CreateColorPickerHeader(optionsContainer, {
                    rowSize = UDim2.new(0, 207, 0, 20),
                    layoutOrder = layoutOrderCounter,
                    title = colorOptions.title or "Color",
                    titleWidth = 150,
                    titleTransparency = 0.16,
                    hue = colorState._h,
                    saturation = colorState._s,
                    value = colorState._v,
                    swatchStrokeTransparency = 0.38
                })

                local panel = CreateInstance("Frame", {
                    Size = UDim2.new(0, 207, 0, 0),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    BorderSizePixel = 0,
                    LayoutOrder = layoutOrderCounter,
                    Parent = optionsContainer
                })

                local saturationValueBox, saturationValueCursor, hueBar, hueCursor = CreateColorPickerPanel(panel, colorState._h, colorState._s, colorState._v)

                local function GetCurrentColor()
                    return Color3.fromHSV(colorState._h, colorState._s, colorState._v)
                end

                local function RefreshPickerVisuals()
                    swatch.BackgroundColor3 = GetCurrentColor()
                    saturationValueBox.BackgroundColor3 = Color3.fromHSV(colorState._h, 1, 1)
                    saturationValueCursor.Position = UDim2.new(colorState._s, 0, 1 - colorState._v, 0)
                    hueCursor.Position = UDim2.new(colorState._h, 0, 0.5, 0)
                end

                local function CommitColor()
                    Library._config._flags[colorOptions.flag] = {H = colorState._h, S = colorState._s, V = colorState._v}
                    SaveConfig()

                    if colorOptions.callback then
                        colorOptions.callback(GetCurrentColor())
                    end
                end

                local isDraggingSaturationValue = false
                local isDraggingHue = false

                saturationValueBox.InputBegan:Connect(function(inputObject)
                    if IsPrimaryPointerInput(inputObject) then
                        isDraggingSaturationValue = true
                        Library._blocking_drag = true
                    end
                end)

                hueBar.InputBegan:Connect(function(inputObject)
                    if IsPrimaryPointerInput(inputObject) then
                        isDraggingHue = true
                        Library._blocking_drag = true
                    end
                end)

                Connections["cp_moved_" .. colorOptions.flag] = UserInputService.InputChanged:Connect(function(inputObject)
                    if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement
                        and inputObject.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    if isDraggingSaturationValue then
                        colorState._s = math.clamp(
                            (inputObject.Position.X - saturationValueBox.AbsolutePosition.X) / saturationValueBox.AbsoluteSize.X,
                            0,
                            1
                        )

                        colorState._v = 1 - math.clamp(
                            (inputObject.Position.Y - saturationValueBox.AbsolutePosition.Y) / saturationValueBox.AbsoluteSize.Y,
                            0,
                            1
                        )

                        RefreshPickerVisuals()

                        if colorOptions.callback then
                            colorOptions.callback(GetCurrentColor())
                        end
                    end

                    if not isDraggingHue then
                        return
                    end

                    colorState._h = math.clamp(
                        (inputObject.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X,
                        0,
                        1
                    )

                    RefreshPickerVisuals()

                    if colorOptions.callback then
                        colorOptions.callback(GetCurrentColor())
                    end
                end)

                Connections["cp_ended_" .. colorOptions.flag] = UserInputService.InputEnded:Connect(function(inputObject)
                    if not IsPrimaryPointerInput(inputObject) then
                        return
                    end

                    if isDraggingSaturationValue or isDraggingHue then
                        isDraggingSaturationValue = false
                        isDraggingHue = false
                        Library._blocking_drag = false
                        CommitColor()
                    end
                end)

                local isExpanded = false

                row.MouseButton1Click:Connect(function()
                    isExpanded = not isExpanded
                    saturationValueCursor.Visible = isExpanded
                    hueCursor.Visible = isExpanded
                    self._size = isExpanded and self._size + 90 or self._size - 90

                    PlayTween(panel, CreateQuintOutTweenInfo(0.4), {
                        Size = UDim2.new(0, 207, 0, isExpanded and 90 or 0)
                    })

                    PlayTween(arrow, CreateQuintOutTweenInfo(0.35), {Rotation = isExpanded and -90 or 90})

                    if sizeManager._state then
                        moduleCard.Size = UDim2.new(1, -8, 0, ExpandedModuleBaseHeight + self._size + self._multiplier + 16)
                    end

                    optionsContainer.Size = UDim2.new(1, -8, 0, self._size + self._multiplier)
                end)

                RefreshPickerVisuals()

                if colorOptions.callback then
                    colorOptions.callback(GetCurrentColor())
                end

                function colorState:Set(newColor, isSilent)
                    self._h, self._s, self._v = Color3.toHSV(newColor)
                    RefreshPickerVisuals()

                    if isSilent then
                        Library._config._flags[colorOptions.flag] = {H = self._h, S = self._s, V = self._v}
                        return
                    end

                    CommitColor()
                end

                return colorState
            end

            return sizeManager
        end

        tabApi._left = leftPage
        tabApi._right = rightPage
        return tabApi
    end

    function window:render_gui_theme()
        if self._theme_tabs_ref then
            for _, tab in self._theme_tabs_ref:GetChildren() do
                if tab.Name == "Tab" then
                    local indicator = tab:FindFirstChild("Indicator")

                    if indicator then
                        indicator.BackgroundColor3 = Colors.Accent
                    end

                    local label = tab:FindFirstChildOfClass("TextLabel")

                    if label then
                        local labelGradient = label:FindFirstChildOfClass("UIGradient")

                        if labelGradient then
                            labelGradient.Color = CreateTabLabelGradientSequence()
                        end
                    end

                    local icon = tab:FindFirstChild("Icon")

                    if icon and icon:IsA("GuiObject") then
                        icon.ImageColor3 = tab == self._active_tab_ref and Colors.Accent or Colors.Text
                    end
                end
            end
        end

        local success, errorMessage = pcall(ApplyThemeBindings)

        if not success then
            warn("failed to apply theme", errorMessage)
        end

        if self._active_tab_ref then
            self:update_tabs(self._active_tab_ref, false)
        end
    end

    function window:apply_gui_theme()
        if self._theme_debounce then
            task.cancel(self._theme_debounce)
        end

        self._theme_debounce = task.delay(0.6, function()
            self._theme_debounce = nil
            self:render_gui_theme()
        end)

        if self._theme_pending then
            return
        end

        self._theme_pending = true

        task.defer(function()
            self._theme_pending = false
            self:render_gui_theme()
        end)
    end

    function window:apply_gui_theme_fast()
        self:apply_gui_theme()
    end

    function window:bind_gui_toggle_key()
        Connections:disconnect("library_visibility")

        local toggleKeyName = StripKeyCodePrefix(GuiConfig.toggle_key or DefaultToggleKey)
        local toggleKeyCode = Enum.KeyCode.RightControl

        for _, keyCodeItem in Enum.KeyCode:GetEnumItems() do
            if keyCodeItem.Name == toggleKeyName then
                toggleKeyCode = keyCodeItem
                break
            end
        end

        Connections.library_visibility = UserInputService.InputBegan:Connect(function(inputObject, isProcessed)
            if isProcessed then
                return
            end

            if inputObject.KeyCode ~= toggleKeyCode then
                return
            end

            if not screenGui.Enabled then
                screenGui.Enabled = true
            end

            self._ui_open = not self._ui_open
            self:change_visiblity(self._ui_open)
        end)
    end

    local function BuildSettingsTab()
        local settingsTab = window:create_tab("Settings", "settings", {layout_order = 999999, no_activate = true})
        local interactionColumn = settingsTab._left
        local leftLayoutCounter = 0

        local function NextLayoutOrder()
            leftLayoutCounter = leftLayoutCounter + 1
            return leftLayoutCounter
        end

        local function CreateSettingsCard(column, title)
            local card = CreateInstance("Frame", {
                Name = "GUICard",
                BackgroundColor3 = Colors.Card,
                BackgroundTransparency = 0.68,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = NextLayoutOrder(),
                Parent = column
            })

            AddCorner(card, 8)

            local cardStroke = AddStroke(card, Colors.Stroke, 0.35)

            CreateDepthGradient(card, 0.12)
            BindTheme(card, {BackgroundColor3 = "Card"})
            BindTheme(cardStroke, {Color = "Stroke"})

            CreateInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 12),
                Parent = card
            })

            CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = card
            })

            local headLabel = CreateLabelText(card, {
                Size = UDim2.new(1, 0, 0, 16),
                FontFace = CreateGothamFont(Enum.FontWeight.Bold),
                TextSize = 12,
                TextColor3 = Colors.AccentSoft,
                TextTransparency = 0.1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = title,
                LayoutOrder = 0
            })

            BindTheme(headLabel, {TextColor3 = "AccentSoft"})
            return card
        end

        local interactionCard = CreateSettingsCard(interactionColumn, "Interaction")

        local toggleUiRow = CreateInstance("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = 1,
            Parent = interactionCard
        })

        local toggleUiLabel = CreateInstance("TextLabel", {
            Size = UDim2.new(0, 120, 1, 0),
            BackgroundTransparency = 1,
            FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
            TextSize = 11,
            TextColor3 = Colors.Text,
            TextTransparency = 0.14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Toggle UI",
            Parent = toggleUiRow
        })

        BindTheme(toggleUiLabel, {TextColor3 = "Text"})

        local toggleKeyButton = CreateInstance("TextButton", {
            Size = UDim2.new(0, 72, 0, 20),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            BackgroundColor3 = Colors.CardDeep,
            BackgroundTransparency = 0.35,
            Text = "",
            AutoButtonColor = false,
            Parent = toggleUiRow
        })

        AddCorner(toggleKeyButton, 4)
        local toggleKeyStroke = AddStroke(toggleKeyButton, Colors.StrokeHot, 0.45)

        local toggleKeyLabel = CreateInstance("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -6, 1, 0),
            Position = UDim2.new(0, 3, 0, 0),
            FontFace = Font.new(MontserratFontPath, Enum.FontWeight.Bold),
            TextSize = 10,
            TextColor3 = Colors.AccentSoft,
            Parent = toggleKeyButton
        })

        local function RefreshToggleKeyLabel()
            toggleKeyLabel.Text = StripKeyCodePrefix(GuiConfig.toggle_key or DefaultToggleKey)
        end

        RefreshToggleKeyLabel()
        BindTheme(toggleKeyButton, {BackgroundColor3 = "CardDeep"})
        BindTheme(toggleKeyStroke, {Color = "StrokeHot"})
        BindTheme(toggleKeyLabel, {TextColor3 = "AccentSoft"})

        toggleKeyButton.MouseButton1Click:Connect(function()
            local keyConnection

            keyConnection = UserInputService.InputBegan:Connect(function(inputObject, isProcessed)
                if isProcessed then
                    return
                end

                if inputObject.KeyCode == Enum.KeyCode.Unknown then
                    return
                end

                if inputObject.KeyCode == Enum.KeyCode.Backspace then
                    GuiConfig.toggle_key = DefaultToggleKey
                    SaveConfig()
                    RefreshToggleKeyLabel()
                    window:bind_gui_toggle_key()
                    keyConnection:Disconnect()
                    return
                end

                GuiConfig.toggle_key = tostring(inputObject.KeyCode)
                SaveConfig()
                RefreshToggleKeyLabel()
                window:bind_gui_toggle_key()
                keyConnection:Disconnect()
            end)
        end)

        local hideMinimizedRow = CreateInstance("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = 2,
            Parent = interactionCard
        })

        local hideMinimizedLabel = CreateInstance("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
            TextSize = 11,
            TextColor3 = Colors.Text,
            TextTransparency = 0.14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Hide When Minimized",
            Parent = hideMinimizedRow
        })

        BindTheme(hideMinimizedLabel, {TextColor3 = "Text"})

        local hideMinimizedToggle = CreateInstance("TextButton", {
            Size = UDim2.new(0, 36, 0, 18),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            BackgroundColor3 = DeriveToggleOffColor(Colors.Card),
            BackgroundTransparency = 0.6,
            Text = "",
            AutoButtonColor = false,
            Parent = hideMinimizedRow
        })

        AddCorner(hideMinimizedToggle, UDim.new(1, 0))

        local hideMinimizedCircle = CreateInstance("Frame", {
            Size = UDim2.new(0, 9, 0, 9),
            Position = UDim2.new(0, 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Colors.SubText,
            BorderSizePixel = 0,
            Parent = hideMinimizedToggle
        })

        AddCorner(hideMinimizedCircle, UDim.new(1, 0))
        local isHideMinimizedEnabled = GuiConfig.hide_minimized == true
        hideMinimizedRow.Visible = window._device == "PC"

        BindTheme(hideMinimizedToggle, {
            BackgroundColor3 = function()
                return isHideMinimizedEnabled and Colors.Accent or DeriveToggleOffColor(Colors.Card)
            end
        })

        BindTheme(hideMinimizedCircle, {
            BackgroundColor3 = function()
                return isHideMinimizedEnabled and Colors.Background or Colors.SubText
            end
        })

        local function SetHideMinimized(isEnabled)
            isHideMinimizedEnabled = isEnabled
            GuiConfig.hide_minimized = isEnabled
            SaveConfig()
            local toggleOffColor = DeriveToggleOffColor(Colors.Card)

            PlayTween(hideMinimizedToggle, CreateQuintOutTweenInfo(0.4), {
                BackgroundColor3 = isEnabled and Colors.Accent or toggleOffColor,
                BackgroundTransparency = isEnabled and 0.3 or 0.6
            })

            PlayTween(hideMinimizedCircle, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = isEnabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = isEnabled and Colors.Background or Colors.SubText
            })
        end

        if GuiConfig.hide_minimized == true then
            SetHideMinimized(true)
        end

        hideMinimizedToggle.MouseButton1Click:Connect(function()
            SetHideMinimized(not isHideMinimizedEnabled)
        end)

        local transparencyRow = CreateInstance("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = 3,
            Parent = interactionCard
        })

        local transparencyTitle = CreateInstance("TextLabel", {
            FontFace = CreateGothamFont(Enum.FontWeight.SemiBold),
            TextSize = 11,
            TextColor3 = Colors.Text,
            TextTransparency = 0.16,
            Text = "Window Transparency",
            Size = UDim2.new(0, 153, 0, 13),
            Position = UDim2.new(0, 0, 0.05, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = transparencyRow
        })

        local transparencyTrack = CreateSliderTrack(transparencyRow, UDim2.new(1, 0, 0, 4), true)
        local transparencyFill = CreateSliderFill(transparencyTrack, UDim2.new(0.5, 0, 1, 0))
        local transparencyValueLabel = CreateSliderValueLabel(transparencyRow, 42, 10, "")

        BindTheme(transparencyTitle, {TextColor3 = "Text"})

        local function SetWindowTransparency(rawValue)
            local clampedValue = math.clamp(rawValue, 0, 1)
            GuiConfig.bg_transparency = clampedValue
            SaveConfig()

            if window._theme_container then
                window._theme_container.BackgroundTransparency = clampedValue
            end

            transparencyFill.Size = UDim2.new(math.clamp(clampedValue, 0.02, 1), 0, 1, 0)
            transparencyValueLabel.Text = string.format("%.2f", clampedValue)
        end

        SetWindowTransparency(GuiConfig.bg_transparency or DefaultBackgroundTransparency)

        local function UpdateTransparencyFromMouse(mouseX)
            local trackWidth = transparencyTrack.AbsoluteSize.X

            if trackWidth < 1 then
                return
            end

            local alpha = math.clamp((mouseX - transparencyTrack.AbsolutePosition.X) / trackWidth, 0, 1)
            SetWindowTransparency(alpha)
        end

        transparencyRow.MouseButton1Down:Connect(function()
            Connections:disconnect("gui_tr_drag")
            Connections:disconnect("gui_tr_end")
            UpdateTransparencyFromMouse(Mouse.X)

            Connections.gui_tr_drag = UserInputService.InputChanged:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseMovement
                    or inputObject.UserInputType == Enum.UserInputType.Touch then
                    UpdateTransparencyFromMouse(inputObject.Position.X)
                end
            end)

            Connections.gui_tr_end = UserInputService.InputEnded:Connect(function(inputObject)
                if not IsPrimaryPointerInput(inputObject) then
                    return
                end

                Connections:disconnect("gui_tr_drag")
                Connections:disconnect("gui_tr_end")
                SaveConfig()
            end)
        end)

        local themeNames = {}

        for themeName in pairs(Themes) do
            table.insert(themeNames, themeName)
        end

        table.sort(themeNames)

        local fontNames = {}

        for _, fontItem in ipairs(Enum.Font:GetEnumItems()) do
            if fontItem.Name ~= "Unknown" then
                table.insert(fontNames, fontItem.Name)
            end
        end

        table.sort(fontNames)

        local themeColorFields = {
            {title = "Background", key = "Background", slot = "Background"},
            {title = "Module BG", key = "Card", slot = "ModuleBackground"},
            {title = "Accent", key = "Accent", slot = "Accent"},
            {title = "Secondary Accent", key = "AccentSoft", slot = "SecondaryAccent"},
            {title = "Text", key = "Text", slot = "Text"},
            {title = "Dim Text", key = "SubText", slot = "TextDark"},
            {title = "Stroke / Border", key = "Stroke", slot = "Stroke"}
        }

        if not GuiConfig.colors then
            GuiConfig.colors = {}
        end

        for _, field in ipairs(themeColorFields) do
            if not GuiConfig.colors[field.key] then
                local hue, saturation, value = Color3.toHSV(DefaultColors[field.key])
                GuiConfig.colors[field.key] = {H = hue, S = saturation, V = value}
            end
        end

        SaveConfig()

        local colorPickers = {}
        local isThemeBuilding = true

        local function StoreThemeColor(colorKey, newColor)
            local hue, saturation, value = Color3.toHSV(newColor)

            GuiConfig.colors[colorKey] = {H = hue, S = saturation, V = value}
            Colors[colorKey] = newColor
            RefreshDerivedColors(colorKey)
        end

        local function ApplyThemePreset(themeName)
            local theme = Themes[themeName]

            if not theme then
                return
            end

            GuiConfig.theme = themeName

            for _, field in ipairs(themeColorFields) do
                local presetColor = theme[field.slot]

                if presetColor then
                    StoreThemeColor(field.key, presetColor)
                    colorPickers[field.key]:Set(presetColor, true)
                end
            end

            RefreshDerivedColors()
            SaveConfig()
            window:apply_gui_theme()

            local themeInfo = ThemeMeta[themeName]

            Library.SendNotification({
                title = "Theme \u{B7} " .. themeName,
                text = themeInfo and themeInfo.desc or themeName,
                icon = "palette",
                duration = 2
            })
        end

        local function ApplyUIFont(fontName)
            local success, fontEnum = pcall(function()
                return Enum.Font[fontName]
            end)

            if not (success and fontEnum) then
                return
            end

            SetThemeFont(fontEnum)
            GuiConfig.font = fontName
            ApplyThemeFont(screenGui)
            ApplyThemeFont(NotificationHolder)

            if window._floating_gui then
                ApplyThemeFont(window._floating_gui)
            end

            window:refresh_title_layout()
            SaveConfig()

            Library.SendNotification({
                title = "Font \u{B7} " .. fontName,
                text = "UI font updated.",
                icon = "info",
                duration = 2
            })
        end

        local themeModule = settingsTab:create_module({
            title = "Theme Manager",
            description = "Switch themes and edit colors",
            flag = "theme_manager",
            section = "right",
            callback = function()
            end
        })

        local themeDropdown = themeModule:create_dropdown({
            title = "Theme Preset",
            flag = "theme_manager_theme",
            options = themeNames,
            maximum_options = #themeNames,
            callback = function(themeName)
                if isThemeBuilding then
                    return
                end

                ApplyThemePreset(themeName)
            end
        })

        themeModule:create_divider({showtopic = true, title = "Typography"})

        local fontDropdown = themeModule:create_dropdown({
            title = "UI Font",
            flag = "theme_manager_font",
            options = fontNames,
            maximum_options = #fontNames,
            callback = function(fontName)
                if isThemeBuilding then
                    return
                end

                ApplyUIFont(fontName)
            end
        })

        themeModule:create_divider({showtopic = true, title = "Live Editor"})

        for _, field in ipairs(themeColorFields) do
            colorPickers[field.key] = themeModule:create_colorpicker({
                title = field.title,
                flag = "theme_manager_" .. field.key:lower(),
                color = Colors[field.key],
                callback = function(newColor)
                    if isThemeBuilding then
                        return
                    end

                    StoreThemeColor(field.key, newColor)
                    window:apply_gui_theme()
                end
            })

            colorPickers[field.key]:Set(Colors[field.key], true)
        end

        themeDropdown:update(Themes[GuiConfig.theme] and GuiConfig.theme or DefaultThemeName)
        fontDropdown:update(ThemeFont.Enum and ThemeFont.Enum.Name or "Gotham")
        isThemeBuilding = false

        local ConfigControlFlags = {"_cfgName", "_selCfg", "_autoloadEnabled", "_autoloadName", "_cfgCode"}

        local function NotifyConfig(title, text, icon, iconColor)
            Library.SendNotification({
                title = title,
                text = text,
                icon = icon,
                iconColor = iconColor,
                duration = 2.5
            })
        end

        local function IsPreservedFlag(flagName)
            return table.find(ConfigControlFlags, flagName) ~= nil
                or flagName:sub(1, 4) == "_stg"
                or flagName:sub(1, 13) == "theme_manager"
        end

        local function ApplyFlags(newFlags)
            local appliedFlags = {}

            for flagName, flagValue in pairs(newFlags) do
                if type(flagName) == "string" and not IsPreservedFlag(flagName) then
                    appliedFlags[flagName] = flagValue
                end
            end

            Library:apply_flags(appliedFlags)
        end

        local function SnapshotFlags()
            local snapshotFlags = {}

            for flagName, flagValue in pairs(Library._config._flags) do
                if flagName ~= "_cfgCode" then
                    snapshotFlags[flagName] = flagValue
                end
            end

            return snapshotFlags
        end

        local function GetConfigList()
            local configNames = ConfigStore:list_named()
            return #configNames > 0 and configNames or {"(none)"}
        end

        local function AutoloadStatusText()
            local autoloadName = Library._config._flags._autoloadName

            if Library._config._flags._autoloadEnabled and autoloadName and autoloadName ~= "" then
                return "Autoloading \"" .. autoloadName .. "\" on launch"
            end

            return "Autoload is off"
        end

        local configModule = settingsTab:create_module({
            title = "Config",
            description = "Save, load, manage configs",
            flag = "_stg_cfg",
            section = "right",
            callback = function()
            end
        })

        configModule:create_textbox({
            title = "Config Name",
            flag = "_cfgName",
            placeholder = tostring(game.PlaceId),
            callback = function()
            end
        })

        local savedConfigsDropdown = configModule:create_dropdown({
            title = "Saved Configs",
            flag = "_selCfg",
            options = GetConfigList(),
            multi_dropdown = false,
            maximum_options = 30,
            callback = function()
            end
        })

        local function RefreshSavedConfigs()
            savedConfigsDropdown:set_options(GetConfigList())
        end

        local configButtons = configModule:create_buttongroup({
            buttons = {
                {
                    text = "Save",
                    callback = function()
                        local configName = Library._config._flags._cfgName or ""

                        if configName == "" then
                            configName = tostring(game.PlaceId)
                        end

                        local isSaved = ConfigStore:save_named(configName, {
                            _flags = SnapshotFlags(),
                            _keybinds = Library._config._keybinds,
                            _window_x = container.Position.X.Offset,
                            _window_y = container.Position.Y.Offset
                        })

                        if not isSaved then
                            NotifyConfig("Save Failed", configName, "x", Colors.Danger)
                            return
                        end

                        NotifyConfig("Saved", configName, "check")
                        RefreshSavedConfigs()
                    end
                },
                {
                    text = "Load",
                    callback = function()
                        local configName = Library._config._flags._selCfg or ""

                        if configName == "" or configName == "(none)" then
                            NotifyConfig("No Config", "Select a config first.", "x", Colors.Danger)
                            return
                        end

                        local namedConfig = ConfigStore:load_named(configName)

                        if not namedConfig then
                            NotifyConfig("Load Failed", configName, "x", Colors.Danger)
                            return
                        end

                        if type(namedConfig._flags) == "table" then
                            ApplyFlags(namedConfig._flags)
                        end

                        if type(namedConfig._keybinds) == "table" then
                            Library:apply_keybinds(namedConfig._keybinds)
                        end

                        if type(namedConfig._window_x) == "number" and type(namedConfig._window_y) == "number" then
                            Library._config._window_x = namedConfig._window_x
                            Library._config._window_y = namedConfig._window_y
                            container.Position = UDim2.new(0.5, namedConfig._window_x, 0.5, namedConfig._window_y)
                        end

                        SaveConfig()
                        ConfigStore:flush()
                        NotifyConfig("Loaded", configName, "check")
                    end
                },
                {
                    text = "Delete",
                    callback = function()
                    end
                }
            }
        })

        Library:arm_confirm_button(configButtons, 3, function()
            local configName = Library._config._flags._selCfg or ""

            if configName == "" or configName == "(none)" then
                return
            end

            ConfigStore:delete_named(configName)
            NotifyConfig("Deleted", configName, "check")
            RefreshSavedConfigs()
        end)

        configModule:create_divider({showtopic = true, title = "Autoload"})

        local autoloadLabel = configModule:create_label({
            title = "Status",
            text = AutoloadStatusText()
        })

        local isAutoloadReady = false

        configModule:create_checkbox({
            title = "Autoload Selected Config",
            flag = "_autoloadEnabled",
            callback = function(isEnabled)
                if isEnabled then
                    local selectedName = Library._config._flags._selCfg or ""

                    if selectedName == "" or selectedName == "(none)" then
                        Library._config._flags._autoloadEnabled = false
                        Library._config._flags._autoloadName = nil

                        if isAutoloadReady then
                            NotifyConfig("No Config", "Select a config to autoload first.", "x", Colors.Danger)
                        end
                    else
                        Library._config._flags._autoloadName = selectedName

                        if isAutoloadReady then
                            NotifyConfig("Autoload Set", selectedName, "check")
                        end
                    end
                else
                    Library._config._flags._autoloadName = nil

                    if isAutoloadReady then
                        NotifyConfig("Autoload Off", "This config will no longer load automatically.", "info")
                    end
                end

                SaveConfig()
                autoloadLabel:set_text(AutoloadStatusText())
            end
        })

        isAutoloadReady = true

        configModule:create_label({
            title = "How It Works",
            text = "Pick a saved config above, then enable Autoload. It'll load automatically the next time you run the script, until you turn it off.",
            customScale = 92
        })

        configModule:create_divider({showtopic = true, title = "Duplicate"})

        configModule:create_button({
            buttonText = "Duplicate Selected",
            callback = function()
                local sourceName = Library._config._flags._selCfg or ""
                local destinationName = Library._config._flags._cfgName or ""

                if sourceName == "" or sourceName == "(none)" then
                    NotifyConfig("No Source", "Select a config to copy.", "x", Colors.Danger)
                    return
                end

                if destinationName == "" then
                    NotifyConfig("No Name", "Enter a name for the copy.", "x", Colors.Danger)
                    return
                end

                local namedConfig = ConfigStore:load_named(sourceName)

                if not namedConfig then
                    return
                end

                if not ConfigStore:save_named(destinationName, namedConfig) then
                    NotifyConfig("Duplicate Failed", destinationName, "x", Colors.Danger)
                    return
                end

                NotifyConfig("Duplicated", sourceName .. " -> " .. destinationName, "check")
                RefreshSavedConfigs()
            end
        })

        configModule:create_divider({showtopic = true, title = "Import / Export"})

        local configCodeBox = configModule:create_textbox({
            title = "Config Code",
            flag = "_cfgCode",
            placeholder = "Paste a config code here...",
            callback = function()
            end
        })

        configModule:create_buttongroup({
            buttons = {
                {
                    text = "Export",
                    callback = function()
                        local isEncoded, encodedConfig = pcall(function()
                            return HttpService:JSONEncode({
                                _flags = SnapshotFlags(),
                                _keybinds = Library._config._keybinds
                            })
                        end)

                        if not isEncoded then
                            NotifyConfig("Export Failed", "Could not encode the current settings.", "x", Colors.Danger)
                            return
                        end

                        configCodeBox:set_text(encodedConfig)

                        local isCopied = false

                        if typeof(setclipboard) == "function" then
                            isCopied = pcall(setclipboard, encodedConfig)
                        end

                        NotifyConfig(
                            "Exported",
                            isCopied and "Copied to clipboard." or "Copy the code from the box above.",
                            "check"
                        )
                    end
                },
                {
                    text = "Import",
                    callback = function()
                        local rawCode = configCodeBox:get_text()

                        if rawCode == nil or rawCode == "" then
                            NotifyConfig("No Code", "Paste a config code first.", "x", Colors.Danger)
                            return
                        end

                        local isDecoded, decodedConfig = pcall(function()
                            return HttpService:JSONDecode(rawCode)
                        end)

                        if not isDecoded or typeof(decodedConfig) ~= "table" then
                            NotifyConfig("Import Failed", "That doesn't look like a valid config code.", "x", Colors.Danger)
                            return
                        end

                        if type(decodedConfig._flags) == "table" then
                            ApplyFlags(decodedConfig._flags)
                        end

                        if type(decodedConfig._keybinds) == "table" then
                            Library:apply_keybinds(decodedConfig._keybinds)
                        end

                        SaveConfig()
                        ConfigStore:flush()
                        NotifyConfig("Imported", "Settings applied.", "check")
                    end
                }
            }
        })

        if UIFontScale ~= 1 then
            ApplyThemeFont(screenGui)
            window:refresh_title_layout()
        end
    end

    task.defer(function()
        window:get_device()
        BuildSettingsTab()
        window:apply_gui_theme()
    end)

    window:bind_gui_toggle_key()

    minimizeButton.MouseButton1Click:Connect(function()
        if not screenGui.Enabled then
            screenGui.Enabled = true
        end

        window._ui_open = not window._ui_open
        window:change_visiblity(window._ui_open)
    end)

    return window
end

local DefaultConfig = {
    accuracy = 100,
    spam_threshold = 1.5,
    ping_compensation = true,
    parry_method = "Direct",
    parry_target = "Same",
    dynamic_accuracy = false,
    dynamic_offset = 0,
    curve_gain = 8,
    curve_bias = 0,
    spam_rate = 35,
    anti_lag = false,
    al_quality = true,
    al_quality_level = 1,
    al_shadows = true,
    al_post = true,
    al_atmosphere = true,
    al_water = true,
    al_particles = true,
    al_materials = false,
    al_textures = false,
    al_meshes = false,
    dynamic_spam = false,
    curve_method = "camera",
    curve_keybind = false,
    curve_notify = false,
    curve_console = true,
    cooldown_protection = false,
    auto_parry = false,
    auto_spam = false,
    ability_detection = true,
    auto_ability = false,
    phantom_detection = false,
    fury_detect = true,
    fury_burst = 34,
    fury_notify = true,
    death_slash_detect = true,
    death_slash_auto = true,
    death_slash_notify = true,
    duality_detect = true,
    duality_auto = true,
    duality_notify = true,
    duality_mode = "Randomized",
    hellhook_detection = true,
    hellhook_notify = true,
    unlock_all = false,
    unlock_all_data = {
        Sword = "",
        Explosion = "",
        Accessory = false,
        Emotes = {},
        Finishers = {},
        Favorites = {
            Sword = {},
            Explosion = {},
            Emote = {}
        }
    },
    ball_esp = false,
    ball_esp_distance = true,
    ball_esp_velocity = true,
    ball_esp_target = true
}

local Config = {}
local LastSavedConfig = ""

for key, value in pairs(DefaultConfig) do
    Config[key] = value
end

local function SaveScriptConfig()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Config)
    end)

    if success and encoded ~= LastSavedConfig then
        LastSavedConfig = encoded
        Library._config._script = HttpService:JSONDecode(encoded)
        SaveConfig()
    end
end

local function LoadScriptConfig()
    local savedConfig = Library._config._script

    if type(savedConfig) == "table" then
        for key, value in pairs(savedConfig) do
            if value ~= nil then
                Config[key] = value
            end
        end
    end

    if Config.curve_method == nil or Config.curve_method == "" then
        Config.curve_method = "camera"
    end
end

LoadScriptConfig()
_G.config = Config

LocalPlayer.OnTeleport:Connect(function()
    SaveScriptConfig()
    ConfigStore:flush()
end)

task.spawn(function()
    repeat
        SaveScriptConfig()
        task.wait(1)
    until not _G.closet_gg

    SaveScriptConfig()
end)

local Window = Library.new()
local CombatTab = Window:create_tab("Combat", "swords")
local AbilityDetections = Window:create_tab("Ability Detections", "shield")
local VisualTab = Window:create_tab("Visual", "eye")

local ActiveConnections = {}

local function Notify(title, text, icon, duration)
    Library.SendNotification({
        title = title,
        text = text,
        icon = icon or "info",
        duration = duration or 3
    })
end

local function Disconnect(name)
    local connection = ActiveConnections[name]

    if connection then
        connection:Disconnect()
        ActiveConnections[name] = nil
    end
end

local function LinearInterpolate(startValue, endValue, alpha)
    return startValue + (endValue - startValue) * alpha
end

local function InitializeFlag(flagName, defaultValue)
    if Library._config._flags[flagName] == nil then
        Library._config._flags[flagName] = defaultValue
    end
end

local Timing
local UnlockAll

local Util = {
    ReferencePing = 35,
    Epsilon = 0.0001,
    TouchDevice = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
    BallLifetime = 1 / 120,
    PingLifetime = 0.05,
    ClosestLifetime = 0.05,
    ScreenLifetime = 0.04,
    GuardLifetime = 0.05,
    Cache = {
        Balls = {},
        PrimaryBall = nil,
        BallsTime = -math.huge,
        PingMilliseconds = 0,
        PingTime = -math.huge,
        PingItem = nil,
        PingAverage = nil,
        PingJitter = 0,
        FrameTime = 1 / 60,
        ClosestTarget = nil,
        ClosestTime = -math.huge,
        VirtualInput = nil,
        TargetKeys = setmetatable({}, {__mode = "k"}),
        ScreenPositions = nil,
        ScreenTargets = {},
        ScreenTime = -math.huge,
        RandomTarget = nil,
        GuardTime = -math.huge,
        GuardResult = true
    }
}

function Util.GetPlayerGui()
    return LocalPlayer:FindFirstChild("PlayerGui")
end

function Util.GetAliveFolder()
    return Workspace:FindFirstChild("Alive")
end

function Util.GetRemote(name)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild(name)
end

function Util.WaitForRemote(name, timeout)
    local remotes = ReplicatedStorage:WaitForChild("Remotes", timeout)
    return remotes and remotes:WaitForChild(name, timeout)
end

function Util.GetVirtualInput()
    local cache = Util.Cache

    if not cache.VirtualInput then
        local success, service = pcall(function()
            return cloneref(game:GetService("VirtualInputManager"))
        end)

        cache.VirtualInput = success and service or nil
    end

    return cache.VirtualInput
end

function Util.IsVectorValid(vector)
    return typeof(vector) == "Vector3" and vector.X == vector.X and vector.Y == vector.Y and vector.Z == vector.Z and math.abs(vector.X) < math.huge and math.abs(vector.Y) < math.huge and math.abs(vector.Z) < math.huge
end

function Util.InvalidateBalls()
    Util.Cache.BallsTime = -math.huge
end

function Util.RefreshBalls()
    local cache = Util.Cache
    local currentTime = os.clock()
    local cachedBall = cache.PrimaryBall
    if currentTime - cache.BallsTime < Util.BallLifetime and (not cachedBall or cachedBall.Parent) then
        return
    end
    cache.BallsTime = currentTime
    local balls = {}
    local firstBall
    local ballsFolder = Workspace:FindFirstChild("Balls")
    if ballsFolder then
        for _, ball in ballsFolder:GetChildren() do
            if ball:GetAttribute("realBall") then
                balls[#balls + 1] = ball
                firstBall = firstBall or ball
                Timing.Watch(ball)
            end
        end
    end
    local trainingFolder = Workspace:FindFirstChild("TrainingBalls")
    if trainingFolder then
        for _, ball in trainingFolder:GetChildren() do
            if ball:IsA("BasePart") and ball:GetAttribute("realBall") ~= false then
                balls[#balls + 1] = ball
                firstBall = firstBall or ball
                Timing.Watch(ball)
            end
        end
    end
    cache.Balls = balls
    cache.PrimaryBall = firstBall
end

function Util.GetBall()
    Util.RefreshBalls()
    return Util.Cache.PrimaryBall
end

function Util.GetBalls()
    Util.RefreshBalls()
    return Util.Cache.Balls
end

function Util.GetBallLabel(ball)
    if ball and #Util.GetBalls() > 1 then
        return string.format(" | ball %s", ball.Name)
    end

    return ""
end

function Util.GetPing()
    local cache = Util.Cache
    local currentTime = os.clock()
    if currentTime - cache.PingTime < Util.PingLifetime then
        return cache.PingMilliseconds
    end
    cache.PingTime = currentTime
    local pingItem = cache.PingItem
    if not pingItem or not pingItem.Parent then
        local found, item = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]
        end)
        pingItem = found and item or nil
        cache.PingItem = pingItem
    end
    if pingItem then
        local read, value = pcall(pingItem.GetValue, pingItem)
        if read and type(value) == "number" then
            cache.PingMilliseconds = value
            local average = cache.PingAverage or value
            cache.PingAverage = average + (value - average) * 0.08
            cache.PingJitter = cache.PingJitter + (math.abs(value - average) - cache.PingJitter) * 0.08
        end
    end
    return cache.PingMilliseconds
end

function Util.GetPingSeconds()
    return math.clamp(Util.GetPing() / 1000, 0, 0.5)
end

function Util.GetEffectivePing()
    local current = Util.GetPing()
    local cache = Util.Cache
    local average = cache.PingAverage or current
    return average * 0.6 + current * 0.4 + cache.PingJitter * 0.5
end

function Util.GetFrameTime()
    return math.clamp(Util.Cache.FrameTime, 1 / 360, 0.25)
end

function Util.GetExtraLatency()
    local extraPing = math.max(Util.GetEffectivePing() - Util.ReferencePing, 0) / 1000
    local extraFrame = math.max(Util.GetFrameTime() - 1 / 60, 0)
    return extraPing + extraFrame
end

function Util.FindClosestPlayer(forceRefresh)
    local cache = Util.Cache
    local currentTime = os.clock()
    local cachedTarget = cache.ClosestTarget
    if not forceRefresh and cachedTarget and cachedTarget.Parent and cachedTarget.PrimaryPart and currentTime - cache.ClosestTime < Util.ClosestLifetime then
        return cachedTarget
    end
    cache.ClosestTime = currentTime
    local closestDistance = math.huge
    local closestCharacter
    local aliveFolder = Util.GetAliveFolder()
    if aliveFolder then
        for _, character in aliveFolder:GetChildren() do
            local primaryPart = character.PrimaryPart
            if character.Name ~= LocalPlayer.Name and primaryPart then
                local distance = LocalPlayer:DistanceFromCharacter(primaryPart.Position)
                if distance < closestDistance then
                    closestDistance = distance
                    closestCharacter = character
                end
            end
        end
    end
    cache.ClosestTarget = closestCharacter
    return closestCharacter
end

function Util.CanParry()
    local cache = Util.Cache
    local currentTime = os.clock()
    if currentTime - cache.GuardTime < Util.GuardLifetime then
        return cache.GuardResult
    end
    cache.GuardTime = currentTime
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    cache.GuardResult = not (rootPart and rootPart:FindFirstChild("SingularityCape"))
    return cache.GuardResult
end

function Util.GetCurveCFrame(override)
    local camera = Workspace.CurrentCamera
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return camera.CFrame
    end
    local target = override or Util.Cache.ClosestTarget
    local rootPosition = rootPart.Position
    local targetPosition = target and target.PrimaryPart and target.PrimaryPart.Position or rootPosition + camera.CFrame.LookVector * 1000
    local toTarget = (targetPosition - rootPosition).Unit
    local method = Config.curve_method
    if method == "dot" then
        return CFrame.lookAt(rootPosition, targetPosition + Vector3.new(0, 1.75, 0))
    elseif method == "backwards" then
        return CFrame.new(rootPosition, rootPosition - toTarget * 1000)
    elseif method == "slow" then
        return CFrame.new(rootPosition, rootPosition + Vector3.new(0, -350, 0))
    elseif method == "random" then
        local offset = Vector3.new(math.random(-1000, 1000), math.random(-350, 1000), math.random(-1000, 1000))
        return CFrame.new(rootPosition, targetPosition + offset)
    end
    return camera.CFrame
end

function Util.GetScreenPositions()
    local cache = Util.Cache
    local currentTime = os.clock()
    if cache.ScreenPositions and currentTime - cache.ScreenTime < Util.ScreenLifetime then
        return cache.ScreenPositions
    end
    local positions = {}
    local targets = {}
    local camera = Workspace.CurrentCamera
    local aliveFolder = Util.GetAliveFolder()
    local localCharacter = LocalPlayer.Character
    local keys = cache.TargetKeys
    if camera and aliveFolder then
        for _, character in aliveFolder:GetChildren() do
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local key = keys[character]
                if not key then
                    key = character.Name
                    if character == localCharacter then
                        key = LocalPlayer.Name
                        keys[character] = key
                    else
                        local player = Players:GetPlayerFromCharacter(character)
                        if player then
                            key = "Target<" .. player.UserId .. ">"
                            keys[character] = key
                        end
                    end
                end
                local success, screenPosition = pcall(camera.WorldToScreenPoint, camera, rootPart.Position)
                if success then
                    positions[key] = screenPosition
                    if character ~= localCharacter and Util.IsVectorValid(screenPosition) then
                        targets[#targets + 1] = {
                            Character = character,
                            Position = screenPosition
                        }
                    end
                end
            end
        end
    end
    cache.ScreenPositions = positions
    cache.ScreenTargets = targets
    cache.ScreenTime = currentTime
    return positions
end

function Util.GetTargetPosition(character)
    Util.GetScreenPositions()
    for _, entry in Util.Cache.ScreenTargets do
        if entry.Character == character then
            return entry.Position
        end
    end
    return nil
end

function Util.GetRandomTarget()
    Util.GetScreenPositions()
    local cache = Util.Cache
    local pool = {}
    for _, entry in cache.ScreenTargets do
        if entry.Position.Z > 0 then
            pool[#pool + 1] = entry
        end
    end
    if #pool == 0 then
        pool = cache.ScreenTargets
    end
    if #pool == 0 then
        return nil
    end
    if #pool > 1 then
        local others = {}
        for _, entry in pool do
            if entry.Character ~= cache.RandomTarget then
                others[#others + 1] = entry
            end
        end
        pool = others
    end
    local chosen = pool[math.random(#pool)].Character
    cache.RandomTarget = chosen
    return chosen
end

function Util.GetCursorPosition()
    if Util.TouchDevice then
        local viewportSize = Workspace.CurrentCamera.ViewportSize
        return {viewportSize.X / 2, viewportSize.Y / 2}
    end
    local mouseLocation = UserInputService:GetMouseLocation()
    return {mouseLocation.X, mouseLocation.Y}
end

ActiveConnections.Frames = RunService.Heartbeat:Connect(function(deltaTime)
    local cache = Util.Cache
    cache.FrameTime = cache.FrameTime + (math.min(deltaTime, 0.25) - cache.FrameTime) * 0.05
end)

local ParryController = {
    Function = nil,
    Signal = nil,
    Promise = nil,
    PromiseNotified = false,
    Runner = nil,
    Pool = {},
    Bypassed = false,
    BypassFailed = false,
    MissingNotified = false,
    Scale = 0.5,
    Arguments = nil,
    ArgumentsTime = -math.huge,
    ArgumentsLifetime = 0.025,
    BlockedTokens = {
        ["494kjkdf"] = true,
        ["64565gfdd"] = true
    },
    BlockedFlag = "X-23",
    Methods = {"Direct", "Signal", "Thread", "Coroutine", "Pool", "Traceback", "Proxy", "Inject", "Require", "Resolve"}
}

function ParryController.GetFunction()
    if ParryController.Function then
        return ParryController.Function
    end
    local controllers = ReplicatedStorage:FindFirstChild("Controllers")
    if not controllers then
        return nil
    end
    for _, controller in controllers:GetChildren() do
        local module = controller.Name:match("SwordsController") and controller:FindFirstChild("PRY")
        if module then
            local success, result = pcall(require, module)
            if success and type(result) == "function" then
                ParryController.Function = result
                return result
            end
        end
    end
    return nil
end

function ParryController.InstallBypass()
    if ParryController.Bypassed then
        return true
    end
    local parryFunction = ParryController.GetFunction()
    if not parryFunction or not hookfunction then
        return false
    end
    local success, upvalues = pcall(debug.getupvalues, parryFunction)
    if not success or type(upvalues) ~= "table" then
        return false
    end
    local seen = {}
    for _, upvalue in pairs(upvalues) do
        if typeof(upvalue) == "Instance" and upvalue:IsA("RemoteEvent") and not seen[upvalue] then
            seen[upvalue] = true
            local hooked = pcall(function()
                local originalFireServer
                originalFireServer = hookfunction(upvalue.FireServer, function(remote, ...)
                    local arguments = {...}
                    if type(arguments[2]) == "string" and ParryController.BlockedTokens[arguments[2]] then
                        return
                    end
                    if #arguments == 1 and arguments[1] == ParryController.BlockedFlag then
                        return
                    end
                    return originalFireServer(remote, ...)
                end)
            end)
            if hooked then
                ParryController.Bypassed = true
            end
        end
    end
    return ParryController.Bypassed
end

function ParryController.EnsureBypass()
    if ParryController.Bypassed or ParryController.BypassFailed then
        return
    end
    if not ParryController.InstallBypass() then
        ParryController.BypassFailed = true
        Notify("Parry Bypass", "Could not install the parry guard, parries may be flagged", "x", 6)
    end
end

function ParryController.FindPackage(name, author)
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if not packages then
        return nil
    end
    local packageModule = packages:FindFirstChild(name)
    if packageModule then
        return packageModule
    end
    local index = packages:FindFirstChild("_Index")
    if not index then
        return nil
    end
    local moduleName = string.lower(name)
    for _, package in index:GetChildren() do
        local module = package.Name:match(author .. "_" .. moduleName) and package:FindFirstChild(moduleName)
        if module then
            return module
        end
    end
    return nil
end

function ParryController.GetSignal(parryFunction)
    if ParryController.Signal then
        return ParryController.Signal
    end
    local success, signal = pcall(function()
        local newSignal = require(ParryController.FindPackage("Signal", "sleitnick")).new()
        newSignal:Connect(parryFunction)
        return newSignal
    end)
    if success then
        ParryController.Signal = signal
        return signal
    end
    return nil
end

function ParryController.GetPromise()
    if ParryController.Promise then
        return ParryController.Promise
    end
    local success, promise = pcall(function()
        return require(ParryController.FindPackage("Promise", "evaera"))
    end)
    if success then
        ParryController.Promise = promise
        return promise
    end
    if not ParryController.PromiseNotified then
        ParryController.PromiseNotified = true
        Notify("Parry", "Promise package not found", "x", 6)
    end
    return nil
end

function ParryController.RunDirect(parryFunction, ...)
    return (pcall(parryFunction, ...))
end

function ParryController.RunSignal(parryFunction, ...)
    local signal = ParryController.GetSignal(parryFunction)
    if not signal then
        return false
    end
    signal:Fire(...)
    return true
end

function ParryController.AcquireRunner(callback, ...)
    local savedRunner = ParryController.Runner
    ParryController.Runner = nil
    callback(...)
    ParryController.Runner = savedRunner
end

function ParryController.RunnerLoop()
    while true do
        ParryController.AcquireRunner(coroutine.yield())
    end
end

function ParryController.RunThread(parryFunction, ...)
    if not ParryController.Runner then
        ParryController.Runner = coroutine.create(ParryController.RunnerLoop)
        coroutine.resume(ParryController.Runner)
    end
    task.spawn(ParryController.Runner, parryFunction, ...)
    return true
end

function ParryController.RunCoroutine(parryFunction, ...)
    local thread = coroutine.create(function(callback, ...)
        callback(...)
    end)
    coroutine.resume(thread, parryFunction, ...)
    return true
end

function ParryController.PoolWorker()
    while true do
        local callback, scale, curveCFrame, screenPositions, cursorPosition, flag = coroutine.yield()
        if callback then
            callback(scale, curveCFrame, screenPositions, cursorPosition, flag)
        end
        table.insert(ParryController.Pool, coroutine.running())
    end
end

function ParryController.RunPool(parryFunction, ...)
    local worker = table.remove(ParryController.Pool)
    if not worker then
        worker = coroutine.create(ParryController.PoolWorker)
        coroutine.resume(worker)
    end
    task.spawn(worker, parryFunction, ...)
    return true
end

function ParryController.RunTraceback(parryFunction, ...)
    local thread = coroutine.create(function()
        local callback, scale, curveCFrame, screenPositions, cursorPosition, flag = coroutine.yield()
        callback(scale, curveCFrame, screenPositions, cursorPosition, flag)
    end)
    coroutine.resume(thread)
    task.spawn(thread, parryFunction, ...)
    return true
end

function ParryController.RunProxy(parryFunction, ...)
    task.spawn(parryFunction, ...)
    return (pcall(parryFunction, ...))
end

function ParryController.RunDeferred(promiseMethod, parryFunction, ...)
    local promise = ParryController.GetPromise()
    if not promise then
        return false
    end
    local arguments = {...}
    promise[promiseMethod](function(resolve)
        resolve()
    end):andThen(function()
        parryFunction(unpack(arguments, 1, 5))
    end)
    return true
end

function ParryController.RunInject(parryFunction, ...)
    return ParryController.RunDeferred("new", parryFunction, ...)
end

function ParryController.RunRequire(parryFunction, ...)
    local promise = ParryController.GetPromise()
    if not promise then
        return false
    end
    promise.resolve():andThenCall(parryFunction, ...)
    return true
end

function ParryController.RunResolve(parryFunction, ...)
    return ParryController.RunDeferred("defer", parryFunction, ...)
end

ParryController.Handlers = {
    Direct = ParryController.RunDirect,
    Signal = ParryController.RunSignal,
    Thread = ParryController.RunThread,
    Coroutine = ParryController.RunCoroutine,
    Pool = ParryController.RunPool,
    Traceback = ParryController.RunTraceback,
    Proxy = ParryController.RunProxy,
    Inject = ParryController.RunInject,
    Require = ParryController.RunRequire,
    Resolve = ParryController.RunResolve
}

function ParryController.BuildArguments(target)
    local targetPosition = target and Util.GetTargetPosition(target)
    if targetPosition then
        return ParryController.Scale, Util.GetCurveCFrame(target), Util.GetScreenPositions(), {targetPosition.X, targetPosition.Y}, false
    end
    local currentTime = os.clock()
    local arguments = ParryController.Arguments
    if not arguments or currentTime - ParryController.ArgumentsTime >= ParryController.ArgumentsLifetime then
        arguments = {
            ParryController.Scale,
            Util.GetCurveCFrame(),
            Util.GetScreenPositions(),
            Util.GetCursorPosition(),
            false
        }
        ParryController.Arguments = arguments
        ParryController.ArgumentsTime = currentTime
    end
    return unpack(arguments, 1, 5)
end

function ParryController.Fire(method, target)
    local parryFunction = ParryController.GetFunction()
    if not parryFunction then
        if not ParryController.MissingNotified then
            ParryController.MissingNotified = true
            Notify("Parry", "Parry function not found", "x", 6)
        end
        return false
    end
    ParryController.EnsureBypass()
    local handler = ParryController.Handlers[method] or ParryController.RunDirect
    local fired = handler(parryFunction, ParryController.BuildArguments(target))
    if fired and ServerSideParry then
        pcall(ServerSideParry.Play)
    end
    return fired
end

task.spawn(function()
    ReplicatedStorage:WaitForChild("Controllers", 30)
    ParryController.EnsureBypass()
end)

local ParryAnimation = {
    SwordApi = nil,
    Controller = nil,
    SwordsFolder = nil,
    SwordCache = {},
    LastPlayTime = 0,
    Cooldown = 0.18,
    Playing = false,
    Enabled = true,
    ActiveTracks = {},
    BypassNext = false,
    Token = 0,
    Connections = {}
}

pcall(function()
    ParryAnimation.SwordApi = require(ReplicatedStorage.Shared.SwordAPI)
end)

pcall(function()
    ParryAnimation.Controller = require(ReplicatedStorage.Controllers.AnimationController)
end)

pcall(function()
    ParryAnimation.SwordsFolder = ReplicatedStorage.Shared.ReplicatedInstances.Swords
end)

local function SafeDisconnect(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function()
            conn:Disconnect()
        end)
    end
end

function ParryAnimation.Disconnect(key)
    if ParryAnimation.Connections[key] then
        SafeDisconnect(ParryAnimation.Connections[key])
        ParryAnimation.Connections[key] = nil
    end
end

function ParryAnimation.GetSwordName(character)
    if UnlockAll and UnlockAll.Status == "active" and UnlockAll.Sword and character == LocalPlayer.Character then
        return UnlockAll.Sword
    end
    return (character and character:GetAttribute("CurrentlyEquippedSword"))
        or LocalPlayer:GetAttribute("CurrentlyEquippedSword")
end

function ParryAnimation.GetSwordData(swordName)
    if not swordName then
        return nil
    end
    local cached = ParryAnimation.SwordCache[swordName]
    if cached then
        return cached
    end
    local swordsFolder = ParryAnimation.SwordsFolder
    if not swordsFolder then
        return nil
    end
    local ok, data = pcall(function()
        return swordsFolder.GetSword:Invoke(swordName)
    end)
    if ok and data then
        ParryAnimation.SwordCache[swordName] = data
        return data
    end
    return nil
end

function ParryAnimation.GetParryAnimations(character, swordData)
    local swordApi = ParryAnimation.SwordApi
    if not swordApi or not swordData then
        return {}
    end
    local ok, result = pcall(function()
        return swordApi:GetAnimations(character, {"Parry", "GrabParry"}, swordData.AnimationType, swordData.SwordType)
    end)
    if ok and type(result) == "table" then
        return result
    end
    return {}
end

function ParryAnimation.GetAnimator(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return nil
    end
    return humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animator")
end

function ParryAnimation.LoadTrack(animator, animation)
    local controller = ParryAnimation.Controller
    if controller then
        local ok, track = pcall(function()
            return controller:LoadAnimation(animator, animation, true)
        end)
        if ok and track then
            return track
        end
    end
    local ok, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    return ok and track or nil
end

function ParryAnimation.GetPlayingTracks(animator)
    local controller = ParryAnimation.Controller
    if controller then
        local ok, tracks = pcall(function()
            return controller:GetPlayingAnimationTracks(animator)
        end)
        if ok and tracks then
            return tracks
        end
    end
    local ok, tracks = pcall(function()
        return animator:GetPlayingAnimationTracks()
    end)
    return (ok and tracks) or {}
end

function ParryAnimation.StopConflicting(animator)
    for _, track in ipairs(ParryAnimation.ActiveTracks) do
        pcall(function()
            track:Stop(0)
        end)
    end
    table.clear(ParryAnimation.ActiveTracks)
    for _, track in ParryAnimation.GetPlayingTracks(animator) do
        local name = track.Name
        local isParry = track:GetAttribute("GrabParry") or track:GetAttribute("Parry") or name == "GrabParry" or name == "Grab" or name == "SuccessParry" or name == "Success" or string.find(name, "Parry")
        if isParry then
            pcall(function()
                track:Stop(track:GetAttribute("StopFadeTime") or 0.1)
            end)
        end
    end
end

function ParryAnimation.PreloadSword(character)
    character = character or LocalPlayer.Character
    if not character then
        return
    end
    task.spawn(function()
        local swordName = ParryAnimation.GetSwordName(character)
        local swordData = ParryAnimation.GetSwordData(swordName)
        if not swordData then
            return
        end
        local animator = ParryAnimation.GetAnimator(character)
        if not animator or character ~= LocalPlayer.Character then
            return
        end
        local animations = ParryAnimation.GetParryAnimations(character, swordData)
        pcall(function()
            ContentProvider:PreloadAsync(animations)
        end)
        if character ~= LocalPlayer.Character then
            return
        end
        for _, animation in pairs(animations) do
            ParryAnimation.LoadTrack(animator, animation)
        end
    end)
end

function ParryAnimation.BindCharacter(character)
    ParryAnimation.Disconnect("SwordAttribute")
    if not character then
        return
    end
    ParryAnimation.PreloadSword(character)
    ParryAnimation.Connections.SwordAttribute = character:GetAttributeChangedSignal("CurrentlyEquippedSword"):Connect(function()
        ParryAnimation.PreloadSword(character)
    end)
end

ParryAnimation.BindCharacter(LocalPlayer.Character)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.defer(ParryAnimation.BindCharacter, character)
end)

LocalPlayer:GetAttributeChangedSignal("CurrentlyEquippedSword"):Connect(function()
    ParryAnimation.PreloadSword(LocalPlayer.Character)
end)

function ParryAnimation.BypassCooldown()
    ParryAnimation.BypassNext = true
end

function ParryAnimation.FireServerAttempt()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then
        return false
    end
    local buttonPress = remotes:FindFirstChild("ParryButtonPress")
    if buttonPress and buttonPress:IsA("BindableEvent") then
        pcall(function()
            buttonPress:Fire()
        end)
        return true
    end
    local attempt = remotes:FindFirstChild("ParryAttempt")
    if attempt and attempt:IsA("RemoteEvent") then
        pcall(function()
            attempt:FireServer()
        end)
        return true
    end
    return false
end

function ParryAnimation.Play()
    if not ParryAnimation.Enabled then
        return false
    end
    local character = LocalPlayer.Character
    if not character or not character.Parent then
        return false
    end
    local currentTime = os.clock()
    local allow = ParryAnimation.BypassNext or (currentTime - ParryAnimation.LastPlayTime >= ParryAnimation.Cooldown) or not ParryAnimation.Playing
    if not allow then
        return false
    end
    ParryAnimation.BypassNext = false
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 1)
    if not animator then
        return false
    end
    local swordName = ParryAnimation.GetSwordName(character)
    if not swordName then
        return false
    end
    local swordData = ParryAnimation.GetSwordData(swordName)
    if not swordData or character ~= LocalPlayer.Character then
        return false
    end
    ParryAnimation.StopConflicting(animator)
    local animations = ParryAnimation.GetParryAnimations(character, swordData)
    local played = false
    for _, animation in pairs(animations) do
        local track = ParryAnimation.LoadTrack(animator, animation)
        if track then
            local speed = track:GetAttribute("PlaySpeed") or 1
            local fade = track:GetAttribute("PlayFadeTime") or 0.001
            local weight = track:GetAttribute("PlayWeight") or 1
            pcall(function()
                track:Play(fade, weight, speed)
            end)
            local remaining = track.Length == 0 and 1 or (track.Length - track.TimePosition) * speed
            pcall(function()
                character:SetAttribute("ParryTime", math.max(character:GetAttribute("ParryTime") or 0, remaining))
            end)
            table.insert(ParryAnimation.ActiveTracks, track)
            played = true
        end
    end
    if played then
        ParryAnimation.LastPlayTime = currentTime
        ParryAnimation.Playing = true
        ParryAnimation.Token += 1
        local token = ParryAnimation.Token
        task.delay(1.2, function()
            if token == ParryAnimation.Token then
                ParryAnimation.Playing = false
            end
        end)
        ParryAnimation.FireServerAttempt()
    end
    return played
end

function ParryAnimation.Stop()
    for _, track in ipairs(ParryAnimation.ActiveTracks) do
        pcall(function()
            track:Stop(0)
        end)
    end
    table.clear(ParryAnimation.ActiveTracks)
    ParryAnimation.Playing = false
    ParryAnimation.Token += 1
end

function ParryAnimation.ForcePlay()
    ParryAnimation.BypassNext = true
    return ParryAnimation.Play()
end

local API = {}

function API.Play()
    return ParryAnimation.Play()
end

function API.Force()
    return ParryAnimation.ForcePlay()
end

function API.Stop()
    ParryAnimation.Stop()
end

function API.SetEnabled(state)
    ParryAnimation.Enabled = state and true or false
end

function API.SetCooldown(seconds)
    ParryAnimation.Cooldown = math.max(0.05, tonumber(seconds) or 0.18)
end

function API.IsPlaying()
    return ParryAnimation.Playing
end

function API.Preload()
    ParryAnimation.PreloadSword(LocalPlayer.Character)
end

API.Preload()

getgenv().ServerSideParry = API
getgenv().ParryAnim = API

--ServerSideParry.Play()

local Abilities

local Curve = {
    AerodynamicTime = -math.huge,
    States = setmetatable({}, {__mode = "k"}),
    Memo = setmetatable({}, {__mode = "k"}),
    ForeignTimes = setmetatable({}, {__mode = "k"}),
    ForeignHold = 0.1,
    ForeignSwordRange = 80,
    ForeignAlignment = 0.97,
    MemoLifetime = 0.004,
    CurvedAlignment = 0.9,
    ClosingAlignment = 0.3,
    CommitAlignment = 0.4,
    BackwardAlignment = -0.35,
    RecoverAlignment = 0.5,
    RecedingDeadzone = 0.015,
    GlobalGain = tonumber(Config.curve_gain) or 8,
    GlobalBlend = 0.08,
    MinimumGain = 3,
    MaximumGain = 20,
    GainSamples = 8,
    GainSpan = 0.2,
    MaximumGainWeight = 0.7,
    GainInterval = 0.03,
    FitWindow = 0.4,
    MinimumFitAngle = 0.12,
    MinimumFitSpan = 0.08,
    MaximumSamples = 16,
    SimulationStep = 0.02,
    SimulationSteps = 75,
    SimulationHorizon = 1.5,
    HitRadius = 9,
    ArrivalMargin = 0.02,
    FloorRatio = 0.6,
    FloorPing = 0.08,
    FloorCap = 0.85,
    EmergencyDistance = 12,
    EmergencyTime = 0.03,
    Bias = tonumber(Config.curve_bias) or 0,
    MaximumBias = 0.12,
    BiasFloorRatio = 0.35,
    SampleFreshTime = 0.08,
    SampleFadeTime = 0.15,
    SnapshotAge = 0.07,
    FastSpeedStart = 150,
    FastSpeedRange = 350,
    ExtrapolationFree = 60,
    ExtrapolationRange = 120
}

Timing = {
    Samples = setmetatable({}, {__mode = "k"}),
    Transitions = setmetatable({}, {__mode = "k"}),
    TargetChanges = setmetatable({}, {__mode = "k"}),
    LastTargets = setmetatable({}, {__mode = "k"}),
    Connections = {},
    Listener = nil,
    Remote = nil,
    Attempt = -math.huge,
    FrameTime = nil,
    LastGap = 0,
    ContinuityWindow = 0.25,
    MaximumTargetChanges = 8
}

local Spam = {
    Enabled = false,
    Threshold = 1.5,
    ParryTimes = {},
    Opponent = nil,
    EngagedAt = 0,
    ClashAt = 0,
    LastFire = 0,
    LastAttempt = 0,
    ConfirmStart = nil,
    RecentWindow = 0.75,
    PressureWindow = 0.5,
    StepInterval = 1 / 120,
    LastStep = 0,
    DefaultRate = 35,
    MinimumRate = 10,
    MaximumRate = 70,
    SlowFrameTime = 0.025,
    SlowInterval = 0.05,
    ConfirmDelay = 0.012,
    BroadRange = 120,
    ClashFlips = 3,
    ClashWindow = 0.8,
    ClashGap = 0.35,
    DynamicBase = 3,
    DynamicMinimum = 1,
    DynamicMaximum = 3.5
}

local Backwards = {
    States = setmetatable({}, {__mode = "k"}),
    ReverseAlignment = 0.2,
    ProgressLimit = -0.45,
    FastSpeed = 35
}

local Parry = {
    BallStates = setmetatable({}, {__mode = "k"}),
    AccuracyMultiplier = 1.5,
    PingLead = 0.35,
    CooldownTime = 1,
    VfxGraceTime = 0.314159,
    DynamicMaximum = 1.5,
    HandoffWindow = 0.1,
    Learning = {
        Offset = tonumber(Config.dynamic_offset) or 0,
        Pending = {},
        MinimumOffset = -0.08,
        MaximumOffset = 0.2,
        LateStep = 0.012,
        EarlyStep = 0.008,
        EdgeStep = 0.004,
        HitDistance = 9,
        ParryWindow = 0.5,
        Timeout = 1.5,
        DecayTime = 300,
        LeadFloorRatio = 0.35
    },
    BlockedUntil = 0,
    BlockTimeout = 1.25,
    EventsReady = false,
    RefundTime = -math.huge,
    RefundWindow = 0.15,
    RetryTime = 0.05
}

function Timing.Forget(ball)
    Timing.Samples[ball] = nil
    Timing.Buffers[ball] = nil
    Timing.Transitions[ball] = nil
    Timing.TargetChanges[ball] = nil
    Timing.LastTargets[ball] = nil
    Curve.States[ball] = nil
    Curve.Memo[ball] = nil
    Curve.ForeignTimes[ball] = nil
    Backwards.States[ball] = nil

    local connections = Timing.Connections[ball]

    if connections then
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end

        Timing.Connections[ball] = nil
    end
end

function Timing.RecordTargetChange(ball)
    local changes = Timing.TargetChanges[ball]
    local target = ball:GetAttribute("target")

    if not changes then
        changes = {}
        Timing.TargetChanges[ball] = changes
    end

    changes[#changes + 1] = {
        Time = os.clock(),
        Target = target,
        Previous = Timing.LastTargets[ball]
    }

    Timing.LastTargets[ball] = target

    if #changes > Timing.MaximumTargetChanges then
        table.remove(changes, 1)
    end
end

function Timing.GetClashOpponent(change)
    local localName = LocalPlayer.Name

    if change.Target == localName then
        return change.Previous
    end

    if change.Previous == localName then
        return change.Target
    end

    return nil
end

function Timing.GetClash(ball, window, gap)
    local changes = Timing.TargetChanges[ball]

    if not changes then
        return 0
    end

    local cutoff = os.clock() - window
    local flips = 0
    local opponent
    local newerTime

    for index = #changes, 1, -1 do
        local change = changes[index]
        local other = Timing.GetClashOpponent(change)

        if change.Time < cutoff
            or type(other) ~= "string"
            or other == ""
            or (opponent and other ~= opponent)
            or (newerTime and newerTime - change.Time > gap) then
            break
        end

        opponent = other
        newerTime = change.Time
        flips += 1
    end

    return flips, opponent
end

function Timing.Watch(ball)
    if Timing.Connections[ball] then
        return
    end

    local connections = {}
    Timing.Connections[ball] = connections
    Timing.LastTargets[ball] = ball:GetAttribute("target")

    Backwards.GetState(ball)

    local function ResetSample()
        Timing.Transitions[ball] = Timing.Samples[ball] or Timing.Transitions[ball]
        Timing.Samples[ball] = nil
        Timing.Buffers[ball] = nil
        Curve.Reset(ball)
    end

    connections[#connections + 1] = ball:GetAttributeChangedSignal("target"):Connect(function()
        Timing.RecordTargetChange(ball)
        ResetSample()
        Backwards.OnTargetChanged(ball)
    end)

    connections[#connections + 1] = ball:GetAttributeChangedSignal("from"):Connect(ResetSample)

    connections[#connections + 1] = ball.Destroying:Connect(function()
        Timing.Forget(ball)
    end)
end

Timing.Buffers = setmetatable({}, {__mode = "k"})
Timing.Interval = 1 / 30
Timing.BufferSize = 6

local function MedianVector(list)
    local xs, ys, zs = {}, {}, {}
    for index, vector in ipairs(list) do
        xs[index] = vector.X
        ys[index] = vector.Y
        zs[index] = vector.Z
    end

    local function Median(values)
        table.sort(values)
        local count = #values
        local middle = math.ceil(count / 2)
        if count % 2 == 0 then
            return (values[middle] + values[middle + 1]) / 2
        end
        return values[middle]
    end

    return Vector3.new(Median(xs), Median(ys), Median(zs))
end

function Timing.UpdateInterval(gap)
    local current = Timing.Interval
    if gap >= current * 0.5 and gap <= current * 2 then
        Timing.Interval = math.clamp(current * 0.95 + gap * 0.05, 1 / 120, 0.25)
    end
end

function Timing.Solve(sample, buffer)
    local count = #buffer
    local newest = buffer[count]
    local interval = Timing.Interval

    local sendTimes = {[count] = newest.Arrived}
    for index = count - 1, 1, -1 do
        sendTimes[index] = math.min(buffer[index].Arrived, sendTimes[index + 1] - interval)
    end

    local deltas = {}
    for index = 2, count do
        local dt = sendTimes[index] - sendTimes[index - 1]
        if dt > 1e-3 then
            deltas[#deltas + 1] = (buffer[index].Position - buffer[index - 1].Position) / dt
        end
    end

    local velocity = #deltas >= 2 and MedianVector(deltas) or newest.Velocity
    local oneWay = math.clamp(Util.GetPingSeconds() * 0.5, 0, 0.25)

    sample.Position = newest.Position + velocity * oneWay
    sample.Time = newest.Arrived
    sample.Velocity = velocity

    local previous = buffer[count - 1]
    if previous and newest.Arrived - previous.Arrived <= Timing.ContinuityWindow then
        sample.Previous = {
            Position = previous.Position,
            Time = previous.Arrived,
            Velocity = previous.Velocity
        }
    else
        sample.Previous = nil
    end
end

function Timing.Record(ball, position)
    if typeof(ball) ~= "Instance" or not ball:IsA("BasePart") or not ball.Parent then
        return
    end

    if not Util.IsVectorValid(position) then
        return
    end

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local zoomies = ball:FindFirstChild("zoomies")

    if not rootPart or not zoomies then
        return
    end

    local velocity = zoomies.VectorVelocity

    if not Util.IsVectorValid(velocity) then
        return
    end

    Timing.Watch(ball)

    local now = os.clock()
    local target = ball:GetAttribute("target")
    local sender = ball:GetAttribute("from")

    local buffer = Timing.Buffers[ball]
    if not buffer then
        buffer = {}
        Timing.Buffers[ball] = buffer
    end

    local newest = buffer[#buffer]

    if newest then
        if (position - newest.Position).Magnitude < 1e-3 then
            return
        end

        local gap = now - newest.Arrived
        if gap > 0 then
            Timing.UpdateInterval(gap)
        end
    end

    buffer[#buffer + 1] = {
        Position = position,
        Velocity = velocity,
        Arrived = now
    }

    if #buffer > Timing.BufferSize then
        table.remove(buffer, 1)
    end

    local sample = Timing.Samples[ball]

    if not sample
        or sample.Target ~= target
        or sample.Sender ~= sender
        or sample.Root ~= rootPart
        or sample.Zoomies ~= zoomies then
        sample = {
            Target = target,
            Sender = sender,
            Root = rootPart,
            Zoomies = zoomies
        }
        Timing.Samples[ball] = sample
    end

    Timing.Solve(sample, buffer)

    Timing.Transitions[ball] = nil
    Curve.Memo[ball] = nil
end

function Timing.Ensure()
    if Timing.Remote and Timing.Remote.Parent and Timing.Listener then
        return
    end

    local currentTime = os.clock()

    if currentTime - Timing.Attempt < 1 then
        return
    end

    Timing.Attempt = currentTime

    if Timing.Listener then
        Timing.Listener:Disconnect()
        Timing.Listener = nil
    end

    local remote = Util.GetRemote("ReplicateBallPosition")

    if not remote or not (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then
        return
    end

    Timing.Remote = remote
    Timing.Listener = remote.OnClientEvent:Connect(Timing.Record)
end

function Timing.Stop()
    if Timing.Listener then
        Timing.Listener:Disconnect()
        Timing.Listener = nil
    end

    for ball in pairs(Timing.Connections) do
        if typeof(ball) == "Instance" then
            Timing.Forget(ball)
        end
    end

    Timing.Remote = nil
    Timing.Interval = 1 / 30
    Timing.FrameTime = nil
    Timing.Attempt = -math.huge
end

function Timing.GetFrameGap()
    local currentTime = os.clock()
    local gap = Timing.FrameTime and currentTime - Timing.FrameTime or 0

    Timing.FrameTime = currentTime
    Timing.LastGap = gap
    return gap
end

function Curve.Reset(ball)
    local state = Curve.States[ball]

    if state then
        state.BackwardWarned = false
        state.Gain = nil
        state.GainWeight = 0
        table.clear(state.Times)
        table.clear(state.Angles)
    end

    Curve.Memo[ball] = nil
end

function Curve.GetState(ball)
    local state = Curve.States[ball]

    if not state then
        state = {
            Times = {},
            Angles = {},
            Gain = nil,
            GainWeight = 0,
            BackwardWarned = false
        }

        Curve.States[ball] = state
    end

    return state
end

function Curve.GetForeignRadius(speed, distance, pingSeconds, timeToArrival)
    local radius = 15 - math.min(distance / 1000, 15) + math.min(speed / 100, 40)

    if speed > 100 and timeToArrival > pingSeconds * 2 + 0.03 then
        radius = math.max(radius - 15, 15)
    end

    return radius
end

function Curve.GetAnchor(ball, sample, velocity, speed, currentTime)
    local anchorPosition = ball.Position

    if not sample then
        return anchorPosition
    end

    local age = currentTime - sample.Time

    if age < 0 or age >= Curve.SampleFadeTime then
        return anchorPosition
    end

    local projected = sample.Position + velocity * age

    if not Util.IsVectorValid(projected) then
        return anchorPosition
    end

    local timeWeight = age <= Curve.SampleFreshTime and 1
        or 1 - (age - Curve.SampleFreshTime) / (Curve.SampleFadeTime - Curve.SampleFreshTime)

    local reachWeight = 1 - math.clamp((speed * age - Curve.ExtrapolationFree) / Curve.ExtrapolationRange, 0, 1)
    return anchorPosition:Lerp(projected, timeWeight * reachWeight)
end

function Curve.GetAlignment(sample, velocity, speed, anchorPosition, rootPosition, rootVelocity, currentTime, pingSeconds)
    local pastPosition = rootPosition - rootVelocity * math.min(pingSeconds, 0.25)
    local liveOffset = pastPosition - anchorPosition
    local liveDistance = liveOffset.Magnitude
    local liveAlignment = liveDistance > Util.Epsilon and (liveOffset / liveDistance):Dot(velocity / speed) or 1

    if not sample then
        return liveAlignment
    end

    local age = currentTime - sample.Time
    local sampleVelocity = sample.Velocity
    local sampleSpeed = sampleVelocity.Magnitude

    if age < 0 or age > Curve.SnapshotAge or sampleSpeed <= Util.Epsilon then
        return liveAlignment
    end

    local snapshotPosition = rootPosition - rootVelocity * math.min(age + pingSeconds, 0.4)
    local snapshotOffset = snapshotPosition - sample.Position
    local snapshotDistance = snapshotOffset.Magnitude

    if snapshotDistance <= Util.Epsilon then
        return liveAlignment
    end

    local snapshotAlignment = (snapshotOffset / snapshotDistance):Dot(sampleVelocity / sampleSpeed)
    local speedWeight = math.clamp((speed - Curve.FastSpeedStart) / Curve.FastSpeedRange, 0, 1)
    local freshness = 1 - age / Curve.SnapshotAge
    return LinearInterpolate(liveAlignment, snapshotAlignment, speedWeight * freshness)
end

function Curve.FitGain(state, currentTime)
    local times = state.Times
    local angles = state.Angles
    local count = 0
    local sumTime = 0
    local sumLog = 0
    local sumTimeSquared = 0
    local sumProduct = 0
    local oldestAge = 0

    for index = #times, 1, -1 do
        local age = currentTime - times[index]

        if age > Curve.FitWindow then
            break
        end

        local angle = angles[index]

        if angle > Curve.MinimumFitAngle then
            local relativeTime = -age
            local logAngle = math.log(angle)

            count += 1
            sumTime += relativeTime
            sumLog += logAngle
            sumTimeSquared += relativeTime * relativeTime
            sumProduct += relativeTime * logAngle
            oldestAge = math.max(oldestAge, age)
        end
    end

    if count < 3 or oldestAge < Curve.MinimumFitSpan then
        return nil
    end

    local denominator = count * sumTimeSquared - sumTime * sumTime

    if denominator < 0.0001 then
        return nil
    end

    local slope = (count * sumProduct - sumTime * sumLog) / denominator
    local confidence = math.clamp(count / Curve.GainSamples, 0, 1) * math.clamp(oldestAge / Curve.GainSpan, 0, 1)

    return math.clamp(-slope, 0, Curve.MaximumGain), confidence
end

function Curve.RecordAngle(state, angle, currentTime)
    local times = state.Times
    local angles = state.Angles
    local count = #times

    if count > 0 and currentTime - times[count] < Curve.GainInterval then
        return
    end

    times[count + 1] = currentTime
    angles[count + 1] = angle

    if count + 1 > Curve.MaximumSamples then
        table.remove(times, 1)
        table.remove(angles, 1)
    end

    local fit, confidence = Curve.FitGain(state, currentTime)

    state.Gain = fit
    state.GainWeight = fit and confidence * Curve.MaximumGainWeight or 0

    if fit and fit > 0.5 and angle > 0.4 then
        local observed = math.clamp(fit, Curve.MinimumGain, Curve.MaximumGain)

        Curve.GlobalGain = LinearInterpolate(Curve.GlobalGain, observed, Curve.GlobalBlend * (0.5 + confidence * 0.5))
        Config.curve_gain = Curve.GlobalGain
    end
end

function Curve.ResolveGain(state)
    local gain = Curve.GlobalGain

    if state.Gain then
        gain += (state.Gain - gain) * (state.GainWeight or 0.5)
    end

    return math.clamp(gain, Curve.MinimumGain, Curve.MaximumGain)
end

function Curve.Rotate(direction, target, angle, rotation)
    if angle < 0.0001 then
        return direction
    end

    local sine = math.sin(angle)

    if sine > 0.001 then
        return (direction * math.sin(angle - rotation) + target * math.sin(rotation)) / sine
    end

    local perpendicular = direction:Cross(Vector3.yAxis)

    if perpendicular.Magnitude < 0.001 then
        perpendicular = direction:Cross(Vector3.xAxis)
    end

    return direction * math.cos(rotation) + perpendicular.Unit * math.sin(rotation)
end

function Curve.Simulate(startPosition, startDirection, speed, targetPosition, targetVelocity, gain)
    local step = Curve.SimulationStep
    local position = startPosition
    local direction = startDirection
    local elapsed = 0

    for _ = 1, Curve.SimulationSteps do
        local offset = targetPosition - position
        local distance = offset.Magnitude

        if distance <= Curve.HitRadius then
            return elapsed
        end

        local losDirection = offset / distance
        local angle = math.acos(math.clamp(direction:Dot(losDirection), -1, 1))
        local rotation = angle * (1 - math.exp(-gain * step))

        direction = Curve.Rotate(direction, losDirection, angle, rotation)

        local closingSpeed = speed * direction:Dot(losDirection)

        if closingSpeed > 0 and distance - closingSpeed * step <= Curve.HitRadius then
            return elapsed + (distance - Curve.HitRadius) / closingSpeed
        end

        position += direction * speed * step
        targetPosition += targetVelocity * step
        elapsed += step
    end

    return math.huge
end

function Curve.EstimateArrival(state, anchorPosition, velocity, speed, rootPosition, rootVelocity, distance, alignment)
    local minimumTime = distance / speed

    if minimumTime > Curve.SimulationHorizon then
        return math.huge
    end

    local arrival = Curve.Simulate(anchorPosition, velocity / speed, speed, rootPosition, rootVelocity, Curve.ResolveGain(state))

    if arrival < math.huge then
        arrival += Curve.HitRadius / speed
    end

    if alignment > Curve.ClosingAlignment then
        arrival = math.min(arrival, distance / (speed * alignment))
    end

    return arrival
end

function Curve.WarnBackward(analysis, state, distance, speed, angle, ball)
    if state.BackwardWarned or not Config.curve_console then
        return
    end

    state.BackwardWarned = true

    local returnText = analysis.Arrival < math.huge and string.format("%.2fs", analysis.Arrival) or "over 1.5s"

    warn(string.format(
        "[Closet Anti Curve] Backward curve detected | speed %.0f | distance %.0f | angle %.0f deg | return in %s | ping %dms%s",
        speed,
        distance,
        math.deg(angle),
        returnText,
        math.floor(Util.GetPing()),
        Util.GetBallLabel(ball)
    ))
end

function Curve.Compute(ball, currentTime, analysis)
    analysis.Time = currentTime
    analysis.Valid = false
    analysis.Curved = false
    analysis.Backward = false
    analysis.Arrival = math.huge
    analysis.MinimumTime = math.huge
    analysis.Alignment = 1
    analysis.ClosingRate = 0
    analysis.Speed = 0

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local zoomies = ball:FindFirstChild("zoomies")

    if not rootPart or not zoomies then
        return
    end

    local velocity = zoomies.VectorVelocity
    local rootPosition = rootPart.Position
    local rootVelocity = rootPart.AssemblyLinearVelocity

    if not (Util.IsVectorValid(velocity) and Util.IsVectorValid(rootPosition) and Util.IsVectorValid(rootVelocity)) then
        return
    end

    local speed = velocity.Magnitude

    if speed <= Util.Epsilon then
        return
    end

    local sample = Timing.Samples[ball]

    if sample and (sample.Root ~= rootPart or sample.Zoomies ~= zoomies) then
        sample = nil
    end

    local anchorPosition = Curve.GetAnchor(ball, sample, velocity, speed, currentTime)

    if not Util.IsVectorValid(anchorPosition) then
        return
    end

    local offset = rootPosition - anchorPosition
    local distance = offset.Magnitude

    if distance <= Util.Epsilon then
        return
    end

    local pingSeconds = Util.GetPingSeconds()
    local state = Curve.GetState(ball)
    local alignment = Curve.GetAlignment(sample, velocity, speed, anchorPosition, rootPosition, rootVelocity, currentTime, pingSeconds)
    local angle = math.acos(math.clamp(alignment, -1, 1))

    Curve.RecordAngle(state, angle, currentTime)

    local closingRate = offset:Dot(velocity - rootVelocity) / distance
    local minimumTime = distance / speed
    local isCurved = alignment < Curve.CurvedAlignment
    local arrival = minimumTime

    if isCurved then
        arrival = Curve.EstimateArrival(state, anchorPosition, velocity, speed, rootPosition, rootVelocity, distance, alignment)
    end

    local isForeign = currentTime - (Curve.ForeignTimes[ball] or -math.huge) < Curve.ForeignHold
        and alignment < Curve.ForeignAlignment
        and minimumTime > pingSeconds + Curve.FloorPing

    if isForeign then
        isCurved = true
        arrival = math.huge
    end

    local isBackward = alignment < Curve.BackwardAlignment and closingRate < -speed * Curve.RecedingDeadzone

    analysis.Valid = true
    analysis.Curved = isCurved
    analysis.Backward = isBackward
    analysis.Arrival = arrival
    analysis.MinimumTime = minimumTime
    analysis.Alignment = alignment
    analysis.ClosingRate = closingRate
    analysis.Speed = speed

    if isBackward then
        Curve.WarnBackward(analysis, state, distance, speed, angle, ball)
    elseif alignment > Curve.RecoverAlignment then
        state.BackwardWarned = false
    end
end

function Curve.Analyze(ball)
    local currentTime = os.clock()
    local analysis = Curve.Memo[ball]

    if analysis and currentTime - analysis.Time < Curve.MemoLifetime then
        return analysis
    end

    if not analysis then
        analysis = {}
        Curve.Memo[ball] = analysis
    end

    Curve.Compute(ball, currentTime, analysis)
    return analysis
end

function Curve.GetEmergencyDistance(speed, parryDistance)
    local lead = Util.GetPingSeconds() * 0.5 + Util.GetFrameTime() * 1.5 + Curve.EmergencyTime

    return math.clamp(speed * lead, Curve.EmergencyDistance, math.max(parryDistance, Curve.EmergencyDistance))
end

function Curve.ShouldParry(analysis, distance, speed, parryDistance)
    local isEmergency = analysis.Valid
        and analysis.ClosingRate > 0
        and distance <= Curve.GetEmergencyDistance(speed, parryDistance)

    if not analysis.Valid or not analysis.Curved then
        return distance <= parryDistance, isEmergency
    end

    local pingSeconds = Util.GetPingSeconds()
    local baseTime = parryDistance / speed
    local bias = math.max(Curve.Bias, -baseTime * Curve.BiasFloorRatio)
    local releaseTime = baseTime + Curve.ArrivalMargin + pingSeconds * 0.5 + bias

    if analysis.Arrival <= releaseTime then
        return true, isEmergency
    end

    local floorTime = math.min(math.max(baseTime * Curve.FloorRatio, pingSeconds + Curve.FloorPing), baseTime * Curve.FloorCap)

    if analysis.Alignment > Curve.CommitAlignment and analysis.MinimumTime <= floorTime then
        return true, isEmergency
    end

    return isEmergency, isEmergency
end

-- backwards curve: ball thrown at you by a sender, then curves back toward that sender
function Backwards.GetTargetName(ball)
    local target = ball:GetAttribute("target")

    if type(target) == "string" and target ~= "" then
        return target
    end

    return nil
end

function Backwards.GetDirection(name)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local alive = Util.GetAliveFolder()
    local model = type(name) == "string" and alive and alive:FindFirstChild(name)
    local otherPart = model and (model.PrimaryPart or model:FindFirstChild("HumanoidRootPart"))

    if not rootPart or not otherPart then
        return nil
    end

    local direction = rootPart.Position - otherPart.Position

    if direction.Magnitude <= 0.001 then
        return nil
    end

    return direction
end

function Backwards.GetState(ball)
    local state = Backwards.States[ball]

    if not state then
        state = {
            Target = Backwards.GetTargetName(ball),
            Source = nil,
            SourceDirection = nil,
            Reference = nil
        }

        Backwards.States[ball] = state
    end

    return state
end

function Backwards.Capture(ball, state)
    local zoomies = ball:FindFirstChild("zoomies")

    if not zoomies or ball.Parent == CoreGui or Backwards.GetTargetName(ball) == LocalPlayer.Name then
        return
    end

    if ball:GetAttribute("DribbleActive") == true then
        state.Reference = nil
        return
    end

    local velocity = zoomies.VectorVelocity

    if not Util.IsVectorValid(velocity) or velocity.Magnitude < 0.001 then
        return
    end

    state.Reference = velocity
end

function Backwards.OnTargetChanged(ball)
    local state = Backwards.GetState(ball)
    local previous = state.Target
    local current = Backwards.GetTargetName(ball)

    state.Target = current

    if current == LocalPlayer.Name then
        if ball:GetAttribute("DribbleActive") == true then
            state.Reference = nil
        end

        local sourceName = (type(previous) == "string" and previous ~= "" and previous ~= LocalPlayer.Name) and previous or nil

        state.Source = sourceName
        state.SourceDirection = Backwards.GetDirection(sourceName)
    else
        state.Reference = nil
        state.Source = nil
        state.SourceDirection = nil
        Backwards.Capture(ball, state)
    end
end

function Backwards.Forget(ball)
    Backwards.States[ball] = nil
end

function Backwards.IsIncoming(ball, velocity)
    if not Config.backwards_detect or ball.Parent == CoreGui then
        return false
    end

    if Backwards.GetTargetName(ball) ~= LocalPlayer.Name then
        return false
    end

    if not Util.IsVectorValid(velocity) then
        return false
    end

    local length = velocity.Magnitude

    if length < 0.001 then
        return false
    end

    local state = Backwards.GetState(ball)
    local sender = ball:GetAttribute("from")
    local source = state.Source
    local direction = state.SourceDirection

    if (not source or not direction) and type(sender) == "string" and sender ~= "" and sender ~= LocalPlayer.Name then
        source = sender
        direction = Backwards.GetDirection(sender)
    end

    if not source or sender ~= source or not direction then
        return false
    end

    local directionLength = direction.Magnitude

    if directionLength < 0.001 then
        return false
    end

    local reference = state.Reference
    local referenceMagnitude = reference and reference.Magnitude or 0
    local progress = direction:Dot(velocity) / (directionLength * length)

    if referenceMagnitude < 0.001 then
        return length >= Backwards.FastSpeed and progress < Backwards.ProgressLimit
    end

    local reverse = reference:Dot(velocity) / (referenceMagnitude * length)
    local matched = false

    if reverse > Backwards.ReverseAlignment and progress >= Backwards.ProgressLimit and progress < 0 then
        local sourceNow = Backwards.GetDirection(source)
        local sourceMagnitude = sourceNow and sourceNow.Magnitude or 0

        if sourceMagnitude > 0.001 then
            local distance = sourceNow:Dot(velocity) / (sourceMagnitude * length)

            matched = reverse > 0.95 and progress < -0.2 and distance < -0.2

            if distance < progress then
                progress, directionLength, direction = distance, sourceMagnitude, sourceNow
            end
        end
    end

    local isBackward = matched or (reverse > Backwards.ReverseAlignment and progress < Backwards.ProgressLimit)

    if not isBackward and (math.abs(direction.Y) > directionLength * 0.1
            or (reverse > Backwards.ReverseAlignment and progress < -0.2)) then
        local flatReference = Vector3.new(reference.X, 0, reference.Z)
        local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
        local flatDirection = Vector3.new(direction.X, 0, direction.Z)
        local flatReferenceMagnitude = flatReference.Magnitude
        local flatVelocityMagnitude = flatVelocity.Magnitude
        local flatDirectionMagnitude = flatDirection.Magnitude

        if flatReferenceMagnitude > referenceMagnitude * 0.35
            and flatVelocityMagnitude > length * 0.35
            and flatDirectionMagnitude > 0.001 then
            isBackward = flatReference:Dot(flatVelocity) / (flatReferenceMagnitude * flatVelocityMagnitude) > Backwards.ReverseAlignment
                and flatDirection:Dot(flatVelocity) / (flatDirectionMagnitude * flatVelocityMagnitude) < Backwards.ProgressLimit

            if isBackward and flatDirectionMagnitude <= 1 then
                local sourceNow = Backwards.GetDirection(source)
                local flatSource = sourceNow and Vector3.new(sourceNow.X, 0, sourceNow.Z)
                local flatSourceMagnitude = flatSource and flatSource.Magnitude or 0

                isBackward = flatSourceMagnitude > 0.001
                    and flatSource:Dot(flatVelocity) < Backwards.ProgressLimit * flatSourceMagnitude * flatVelocityMagnitude
            end
        end
    end

    if not isBackward and progress > 0.2 and reverse < 0 then
        state.Reference = nil
    end

    return isBackward
end

function Spam.RecordParry()
    local currentTime = os.clock()
    local times = Spam.ParryTimes

    times[#times + 1] = currentTime

    while times[1] and times[1] < currentTime - Spam.RecentWindow do
        table.remove(times, 1)
    end
end

function Spam.CountRecent(window)
    local times = Spam.ParryTimes
    local cutoff = os.clock() - window
    local count = 0

    for index = #times, 1, -1 do
        if times[index] < cutoff then
            break
        end

        count += 1
    end

    return count
end

function Spam.GetPressure()
    return Spam.CountRecent(Spam.PressureWindow) * 2
end

function Spam.Reset()
    Spam.EngagedAt = 0
    Spam.ClashAt = 0
    Spam.Opponent = nil
    Spam.ConfirmStart = nil
end

function Spam.Clear()
    table.clear(Spam.ParryTimes)
    Spam.Reset()
end

function Spam.GetThreshold(speed, targetChanges)
    if not Config.dynamic_spam then
        return Spam.Threshold
    end

    local pingScale = math.clamp(1 - (Util.GetEffectivePing() - Util.ReferencePing) / 200, 0.35, 1)
    local frameScale = math.clamp(1 / Util.GetFrameTime() / 60, 0.4, 1)
    local speedScale = math.clamp(1 - (speed - 150) / 3000, 0.5, 1)
    local clashScale = targetChanges >= 2 and 0.6 or 1
    local threshold = Spam.DynamicBase * pingScale * frameScale * speedScale * clashScale
    return math.clamp(threshold, Spam.DynamicMinimum, Spam.DynamicMaximum)
end

function Spam.IsHandling(currentTime)
    return Spam.Enabled and currentTime - Spam.LastFire < Parry.HandoffWindow
end

function Spam.GetEngagedWindow()
    return math.min(0.3 + Util.GetPing() / 1000, 0.5)
end

function Spam.IsClashing(currentTime)
    return Spam.Enabled and currentTime - math.max(Spam.EngagedAt, Spam.ClashAt) <= Spam.GetEngagedWindow()
end

function Spam.GetAccuracy(ball, target, pingFactor, rangeScale)
    local character = LocalPlayer.Character
    local rootPart = character and character.PrimaryPart
    local zoomies = ball and ball:FindFirstChild("zoomies")

    if not ball or not target or not target.PrimaryPart or not rootPart or not zoomies then
        return 0
    end

    local velocity = zoomies.VectorVelocity
    local speed = velocity.Magnitude

    if not Util.IsVectorValid(velocity) or speed < 0.001 then
        return 0
    end

    local lead = math.clamp(Util.GetPing() / 4000, 0, 0.03)
    local rootPosition = rootPart.Position
    local ballPosition = ball.Position + velocity * lead
    local targetPart = target.PrimaryPart
    local targetPosition = targetPart.Position + targetPart.AssemblyLinearVelocity * lead
    local ballOffset = rootPosition - ballPosition
    local ballDistance = ballOffset.Magnitude
    local entityDistance = (rootPosition - targetPosition).Magnitude
    local alignment = ballDistance > Util.Epsilon and (ballOffset / ballDistance):Dot(velocity / speed) or 0

    local speedRange = math.min(speed / 6, 95)
    local maximumDistance = (pingFactor + speedRange) * rangeScale

    if entityDistance > maximumDistance or ballDistance > maximumDistance then
        return 0
    end

    local stepDistance = math.clamp(10 + pingFactor, 10, 35)
    local multiBallBonus = #Util.GetBalls() >= 2 and 3 or 0
    local ballRange = (stepDistance + speedRange + multiBallBonus) * rangeScale
    local pinnedRange = (stepDistance + math.min(speed / 6, 30) + multiBallBonus) * rangeScale
    local backwardsBonus = math.clamp(alignment, -1, 0) * (5 - math.min(speed / 5, 5))
    return maximumDistance - backwardsBonus, ballDistance, entityDistance, ballRange, pinnedRange
end

function Spam.GetInterval()
    local rate = math.clamp(tonumber(Config.spam_rate) or Spam.DefaultRate, Spam.MinimumRate, Spam.MaximumRate)
    local interval = 1 / rate

    if Util.GetFrameTime() > Spam.SlowFrameTime then
        interval = math.max(interval, Spam.SlowInterval)
    end

    return interval
end

function Spam.GetClashGap()
    return Spam.ClashGap + Util.GetPingSeconds() * 0.5
end

function Spam.FindCharacter(name)
    local alive = Util.GetAliveFolder()
    local character = type(name) == "string" and name ~= LocalPlayer.Name and alive and alive:FindFirstChild(name)

    return character and character.PrimaryPart and character or nil
end

function Spam.GetOpponent(ball, clashOpponent)
    return Spam.FindCharacter(clashOpponent)
        or Spam.FindCharacter(ball:GetAttribute("target"))
        or Spam.FindCharacter(ball:GetAttribute("from"))
        or Util.FindClosestPlayer()
end

function Spam.GetBall(rootPosition)
    local localName = LocalPlayer.Name
    local gap = Spam.GetClashGap()
    local bestBall
    local bestDistance = math.huge

    for _, ball in Util.GetBalls() do
        local target = ball:GetAttribute("target")
        local involved = target == localName or ball:GetAttribute("from") == localName

        if not involved then
            local flips, opponent = Timing.GetClash(ball, Spam.ClashWindow, gap)

            involved = flips > 0 and opponent == target
        end

        if involved then
            local distance = (ball.Position - rootPosition).Magnitude

            if distance < bestDistance then
                bestDistance = distance
                bestBall = ball
            end
        end
    end

    return bestBall
end

function Spam.Step()
    local currentTime = os.clock()

    if currentTime - Spam.LastStep < Spam.StepInterval then
        return
    end

    Spam.LastStep = currentTime

    local character = LocalPlayer.Character
    local rootPart = character and character.PrimaryPart

    if not rootPart then
        return
    end

    if #Util.GetBalls() == 0 then
        Spam.Reset()
        return
    end

    local ball = Spam.GetBall(rootPart.Position)

    if not ball then
        Spam.ConfirmStart = nil
        return
    end

    local zoomies = ball:FindFirstChild("zoomies")
    local velocity = zoomies and zoomies.VectorVelocity

    if not velocity or not Util.IsVectorValid(velocity) or velocity.Magnitude < 0.001 then
        return
    end

    local speed = velocity.Magnitude

    if (rootPart.Position - ball.Position).Magnitude > Spam.BroadRange + speed * 0.03 then
        Spam.ConfirmStart = nil
        return
    end

    if Abilities.HellHook.ShouldSkip() or Abilities.Fury.IsActive() then
        return
    end

    if not Util.CanParry() or character:GetAttribute("Pulsed") or ball:FindFirstChild("ComboCounter") then
        return
    end

    local ballTarget = ball:GetAttribute("target")
    local pingMilliseconds = Util.GetPing()
    local pingFactor = math.clamp(pingMilliseconds / 10, 1, 16)
    local engagedWindow = Spam.GetEngagedWindow()
    local isEngaged = currentTime - Spam.EngagedAt <= engagedWindow
    local clashFlips, clashOpponent = Timing.GetClash(ball, Spam.ClashWindow, Spam.GetClashGap())
    local isClash = clashFlips >= Spam.ClashFlips
    local isActive = isEngaged or isClash

    if isClash then
        Spam.ClashAt = currentTime
    end

    local opponent = Spam.GetOpponent(ball, clashOpponent)

    if not opponent then
        Spam.ConfirmStart = nil
        return
    end

    Spam.Opponent = opponent

    local accuracy, ballDistance, entityDistance, ballRange, pinnedRange = Spam.GetAccuracy(ball, opponent, pingFactor, isActive and 1.15 or 1)

    if accuracy <= 0 or entityDistance > accuracy or ballDistance > accuracy then
        Spam.ConfirmStart = nil
        return
    end

    local threshold = Spam.GetThreshold(speed, clashFlips)
    local minimumParries = math.clamp(math.round(threshold), 1, 4)

    if not isActive and Spam.CountRecent(Spam.RecentWindow) < minimumParries then
        Spam.ConfirmStart = nil
        return
    end

    local isPinned = entityDistance <= pinnedRange and ballDistance <= ballRange

    if not isPinned then
        Spam.ConfirmStart = nil
        return
    end

    if ballTarget == LocalPlayer.Name and entityDistance > 30 and ballDistance > 30 then
        Spam.ConfirmStart = nil
        return
    end

    if not isClash and Spam.GetPressure() <= threshold then
        Spam.ConfirmStart = nil
        return
    end

    if not isActive then
        Spam.ConfirmStart = Spam.ConfirmStart or currentTime

        if currentTime - Spam.ConfirmStart < Spam.ConfirmDelay then
            return
        end
    end

    if currentTime - Spam.LastAttempt < Spam.GetInterval() then
        return
    end

    Spam.LastAttempt = currentTime

    if Parry.Fire(ball, opponent) then
        Spam.LastFire = currentTime
        Spam.EngagedAt = currentTime
    end
end

function Spam.SetEnabled(enabled)
    Config.auto_spam = enabled
    Spam.Enabled = enabled
    Disconnect("Spam")

    if enabled then
        ActiveConnections.Spam = RunService.PreSimulation:Connect(Spam.Step)
    else
        Spam.Clear()
    end
end

function Parry.IsApproachReady(ball, frameGap)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local sample = Timing.Samples[ball]
    local zoomies = ball:FindFirstChild("zoomies")

    if not rootPart
        or not sample
        or sample.Root ~= rootPart
        or sample.Zoomies ~= zoomies
        or sample.Target ~= LocalPlayer.Name
        or sample.Target ~= ball:GetAttribute("target")
        or sample.Sender ~= ball:GetAttribute("from") then
        return true
    end

    local currentTime = os.clock()
    local clampedGap = math.clamp(frameGap, 0, 0.1)
    local age = currentTime - sample.Time
    local previous = sample.Previous
    local span = previous and sample.Time - previous.Time

    if age < 0 then
        return true
    end

    if not previous and age > clampedGap then
        return true
    end

    if previous and (span <= 0 or span > 0.25 or age <= clampedGap or age > math.min(span, 0.1)) then
        return true
    end

    local velocity = zoomies.VectorVelocity
    local sampleVelocity = sample.Velocity
    local playerVelocity = rootPart.AssemblyLinearVelocity

    if not (Util.IsVectorValid(velocity)
        and Util.IsVectorValid(sampleVelocity)
        and Util.IsVectorValid(playerVelocity)
        and Util.IsVectorValid(rootPart.Position)
        and Util.IsVectorValid(ball.Position)) then
        return true
    end

    local speed = velocity.Magnitude
    local sampleSpeed = sampleVelocity.Magnitude

    if speed <= Util.Epsilon or sampleSpeed <= Util.Epsilon or speed < sampleSpeed * (1 - 1e-6) then
        return true
    end

    local radius = Workspace:GetAttribute("PARRY_RANGE")
    radius = type(radius) == "number" and radius > 0 and radius < math.huge and radius or 13

    local direction = velocity / speed
    local sampleDirection = sampleVelocity / sampleSpeed
    local rawOffset = rootPart.Position - sample.Position
    local relativeVelocity = velocity - playerVelocity
    local relativeSpeed = relativeVelocity.Magnitude

    if relativeSpeed <= Util.Epsilon
        or rawOffset:Dot(velocity) <= 0
        or rawOffset:Dot(relativeVelocity) <= 0
        or direction:Dot(sampleDirection) < 0.5
        or direction:Dot(rawOffset.Unit) < sampleDirection:Dot(rawOffset.Unit) - 1e-6
        or (velocity - sampleVelocity).Magnitude * age > radius then
        return true
    end

    local lead = Util.GetPingSeconds() + clampedGap

    local function CanEnter(offset)
        local alongDistance = offset:Dot(relativeVelocity) / relativeSpeed
        local missDistance = (offset - relativeVelocity / relativeSpeed * alongDistance).Magnitude

        if alongDistance <= 0 or offset:Dot(velocity) <= 0 or missDistance > radius then
            return false
        end

        local entryTime = (alongDistance - math.sqrt(math.max(radius * radius - missDistance * missDistance, 0))) / relativeSpeed
        return entryTime <= lead
    end

    return CanEnter(rawOffset) or CanEnter(rawOffset - velocity * age)
end

function Parry.Dispatch()
    Util.FindClosestPlayer()
    if not ParryController.Fire(Config.parry_method) then
        return false
    end
    Spam.RecordParry()
    return true
end

function Parry.GetTarget(pinned)
    if Config.parry_target ~= "Random" then
        return nil
    end

    local clashing = Spam.IsClashing(os.clock())

    if not pinned and clashing then
        pinned = Spam.Opponent
    end

    if pinned then
        return pinned.Parent and pinned.PrimaryPart and pinned or nil
    end

    if clashing then
        return nil
    end

    return Util.GetRandomTarget()
end

function Parry.Fire(ball, pinned, force)
    if not Util.CanParry() then
        return false
    end

    ball = ball or Util.GetBall()

    if ball and not force and not Parry.IsApproachReady(ball, Timing.LastGap) then
        return false
    end

    Util.FindClosestPlayer()

    if not ParryController.Fire(Config.parry_method, Parry.GetTarget(pinned)) then
        return false
    end

    Spam.RecordParry()
    return true
end

function Parry.IsBlocked(currentTime)
    return Parry.EventsReady and currentTime < Parry.BlockedUntil
end

function Parry.GetTimingBase(speed)
    return 2.4 + math.min(math.max(speed - 13, 0), 5000) * 0.002
end

function Parry.GetAccuracyMultiplier(speed)
    if not Config.dynamic_accuracy then
        return Parry.AccuracyMultiplier
    end

    local maximum = Parry.DynamicMaximum
    local latency = Util.GetExtraLatency()
    return math.max(maximum / (1 + latency * Parry.GetTimingBase(speed) * maximum), 0.05)
end

function Parry.GetAccuracyValue(speed)
    return math.clamp(math.floor(1 + Parry.GetAccuracyMultiplier(speed) * 66 + 0.5), 1, 100)
end

function Parry.GetDistance(speed)
    local pingPadding = math.clamp(Util.GetPing() / 100, 5, 17)
    local timingScale = math.max(Parry.GetTimingBase(speed) * Parry.GetAccuracyMultiplier(speed), 0.05)
    local baseDistance = math.max(speed / timingScale, 10)
    local frameLead = speed * Util.GetFrameTime() * 0.5
    local pingLead = 0
    local learnedLead = 0

    if Config.dynamic_accuracy then
        learnedLead = math.max(speed * Parry.Learning.Offset, -baseDistance * Parry.Learning.LeadFloorRatio)
    elseif Config.ping_compensation ~= false then
        pingLead = speed * Util.GetPingSeconds() * Parry.PingLead
    end

    return pingPadding + baseDistance + frameLead + pingLead + learnedLead
end

function Parry.Learn(outcome, elapsed, isCurved, ball)
    local learning = Parry.Learning
    local step = learning.EdgeStep

    if outcome == "late" then
        step = learning.LateStep
    elseif outcome == "early" then
        step = -learning.EarlyStep
    end

    local label
    local offset

    if isCurved then
        Curve.Bias = math.clamp(Curve.Bias + step, -Curve.MaximumBias, Curve.MaximumBias)
        Config.curve_bias = Curve.Bias
        label = "curve bias"
        offset = Curve.Bias
    elseif Config.dynamic_accuracy then
        learning.Offset = math.clamp(learning.Offset + step, learning.MinimumOffset, learning.MaximumOffset)
        Config.dynamic_offset = learning.Offset
        label = "lead offset"
        offset = learning.Offset
    else
        return
    end

    if outcome ~= "edge" and Config.curve_console then
        warn(string.format(
            "[Closet Parry] %s parry (%.0fms after press) | %s %+.0fms%s",
            outcome == "late" and "Late" or "Early",
            elapsed * 1000,
            label,
            offset * 1000,
            Util.GetBallLabel(ball)
        ))
    end
end

function Parry.DecayLearning(deltaTime)
    local factor = math.exp(-math.clamp(deltaTime, 0, 0.25) / Parry.Learning.DecayTime)

    Curve.Bias *= factor
    Parry.Learning.Offset *= factor
end

function Parry.ResolveOutcome(ball, pending, currentTime, rootPart)
    local learning = Parry.Learning
    local elapsed = currentTime - pending.FireTime

    if elapsed > learning.Timeout then
        learning.Pending[ball] = nil
        return
    end

    local pingSeconds = Util.GetPingSeconds()
    local lateLimit = pingSeconds * 0.5 + 0.05
    local earlyLimit = learning.ParryWindow + pingSeconds * 0.5

    if ball.Parent then
        local isTargetingMe = ball:GetAttribute("target") == LocalPlayer.Name

        if not isTargetingMe then
            learning.Pending[ball] = nil

            if elapsed <= lateLimit + 0.04 then
                Parry.Learn("edge", elapsed, pending.Curved, ball)
            end

            return
        end

        pending.TargetedMe = true

        local zoomies = ball:FindFirstChild("zoomies")
        local ballSpeed = zoomies and zoomies.VectorVelocity.Magnitude or 0
        local hitDistance = math.max(learning.HitDistance, ballSpeed * Util.GetFrameTime() * 1.5)

        if (rootPart.Position - ball.Position).Magnitude > hitDistance then
            return
        end
    elseif not pending.TargetedMe then
        learning.Pending[ball] = nil
        return
    end

    learning.Pending[ball] = nil

    if elapsed <= lateLimit then
        Parry.Learn("late", elapsed, pending.Curved, ball)
    elseif elapsed >= earlyLimit then
        Parry.Learn("early", elapsed, pending.Curved, ball)
    end
end

function Parry.ResolvePending(currentTime, rootPart)
    for ball, pending in pairs(Parry.Learning.Pending) do
        Parry.ResolveOutcome(ball, pending, currentTime, rootPart)
    end
end

function Parry.GetBallState(ball)
    local state = Parry.BallStates[ball]

    if state then
        return state
    end

    state = {CooldownUntil = 0}
    Parry.BallStates[ball] = state

    state.TargetConnection = ball:GetAttributeChangedSignal("target"):Connect(function()
        state.CooldownUntil = 0
    end)

    ball.Destroying:Once(function()
        state.TargetConnection:Disconnect()
        Parry.BallStates[ball] = nil
    end)

    return state
end

function Parry.StartCooldown(state, currentTime, duration)
    state.CooldownUntil = currentTime + (duration or Parry.CooldownTime)
end

function Parry.ShouldWaitForVfx(currentTime)
    local runtimeFolder = Workspace:FindFirstChild("Runtime")
    local tornado = runtimeFolder and runtimeFolder:FindFirstChild("Tornado")

    if not tornado then
        return false
    end

    local tornadoTime = tornado:GetAttribute("TornadoTime") or 1
    return currentTime - Curve.AerodynamicTime < tornadoTime + Parry.VfxGraceTime
end

function Parry.RecordAerodynamic(ball, currentTime)
    local aerodynamicEffect = ball:FindFirstChild("AeroDynamicSlashVFX")

    if aerodynamicEffect then
        Debris:AddItem(aerodynamicEffect, 0)
        Curve.AerodynamicTime = currentTime
    end
end

function Parry.Evaluate(ball, state, character, rootPart, currentTime)
    local zoomies = ball:FindFirstChild("zoomies")
    local velocity = zoomies and zoomies.VectorVelocity
    if not velocity or not Util.IsVectorValid(velocity) then
        return
    end
    Parry.RecordAerodynamic(ball, currentTime)
    if Parry.ShouldWaitForVfx(currentTime) then
        return
    end

    local ballTarget = ball:GetAttribute("target")
    if ballTarget ~= LocalPlayer.Name then
        return
    end

    local analysis = Curve.Analyze(ball)
    local speed = velocity.Magnitude
    local distance = (rootPart.Position - ball.Position).Magnitude
    local frameExcess = math.max(math.min(Timing.LastGap, 0.1) - Util.GetFrameTime(), 0)
    local parryDistance = Parry.GetDistance(speed) + speed * frameExcess
    local shouldParry, isEmergency = Curve.ShouldParry(analysis, distance, speed, parryDistance)
    if not shouldParry then
        return
    end

    if Abilities.ShouldSkipParry(character, distance, parryDistance) then
        Parry.StartCooldown(state, currentTime)
        return
    end

    if Abilities.HellHook.ShouldSkip() or Abilities.Fury.IsActive() or ball:FindFirstChild("ComboCounter") then
        return
    end

    if Spam.IsHandling(currentTime) then
        return
    end

    if not isEmergency and Backwards.IsIncoming(ball, velocity) then
        return
    end

    if Parry.IsBlocked(currentTime) then
        return false
    end

    if Parry.Fire(ball, nil, isEmergency or (analysis.Valid and analysis.Curved)) then
        local refunded = currentTime - Parry.RefundTime < Parry.RefundWindow

        Parry.StartCooldown(state, currentTime, refunded and Parry.RetryTime or nil)
        Parry.BlockedUntil = currentTime + Parry.CooldownTime
        Parry.Learning.Pending[ball] = {
            Ball = ball,
            FireTime = currentTime,
            TargetedMe = true,
            Curved = analysis.Valid and analysis.Curved
        }

        return true
    end

    return false
end

function Parry.GetUrgency(ball)
    if ball:GetAttribute("target") ~= LocalPlayer.Name then
        return math.huge
    end

    local analysis = Curve.Analyze(ball)

    if not analysis.Valid then
        return math.huge
    end

    local urgency = analysis.Curved and analysis.Arrival or analysis.MinimumTime
    urgency -= Parry.GetDistance(analysis.Speed) / analysis.Speed

    return urgency == urgency and urgency or math.huge
end

function Parry.GetNearestBall(position)
    local balls = Util.GetBalls()
    local nearest
    local nearestDistance = math.huge

    for _, ball in balls do
        local distance = (ball.Position - position).Magnitude

        if distance < nearestDistance then
            nearest = ball
            nearestDistance = distance
        end
    end

    if #balls > 1 and nearestDistance > Curve.ForeignSwordRange then
        return nil
    end

    return nearest
end

function Parry.GetParriedBall(swordPart)
    local balls = Util.GetBalls()
    local aliveFolder = Util.GetAliveFolder()

    if #balls > 1 and aliveFolder then
        local owner = swordPart

        while owner and owner.Parent ~= aliveFolder do
            owner = owner.Parent
        end

        local matched
        local matchedDistance = Curve.ForeignSwordRange

        for _, ball in balls do
            local distance = (ball.Position - swordPart.Position).Magnitude

            if owner and ball:GetAttribute("from") == owner.Name and distance < matchedDistance then
                matched = ball
                matchedDistance = distance
            end
        end

        if matched then
            return matched
        end
    end

    return Parry.GetNearestBall(swordPart.Position)
end

function Parry.Step()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not rootPart then
        return
    end

    local balls = Util.GetBalls()

    local frameGap = Timing.GetFrameGap()

    Timing.Ensure()
    Parry.ResolvePending(os.clock(), rootPart)
    Parry.DecayLearning(frameGap)
    Parry.Scan(character, rootPart, balls)
end

function Parry.Rescan()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if rootPart then
        Parry.Scan(character, rootPart, Util.GetBalls())
    end
end

function Parry.OnSuccess()
    if not Config.auto_parry then
        return
    end

    Parry.BlockedUntil = 0
    Parry.RefundTime = os.clock()
    Parry.Rescan()
end

function Parry.OnCooldown(isBlock, active, duration)
    if not isBlock or not Config.auto_parry then
        return
    end

    if active then
        Parry.BlockedUntil = os.clock() + math.min(tonumber(duration) or Parry.CooldownTime, Parry.BlockTimeout)
        return
    end

    Parry.BlockedUntil = 0
    Parry.Rescan()
end

function Parry.Scan(character, rootPart, balls)
    local aliveFolder = Util.GetAliveFolder()

    if aliveFolder and character.Parent == aliveFolder and rootPart:FindFirstChild("MaxShield") then
        return
    end

    if #balls == 0 then
        return
    end

    local currentTime = os.clock()
    local candidates = {}

    for _, ball in balls do
        if ball.Parent then
            local state = Parry.GetBallState(ball)
            Backwards.Capture(ball, Backwards.GetState(ball))

            if currentTime >= state.CooldownUntil then
                candidates[#candidates + 1] = {Ball = ball, State = state, Urgency = math.huge}
            end
        end
    end

    if #candidates > 1 then
        for _, candidate in candidates do
            candidate.Urgency = Parry.GetUrgency(candidate.Ball)
        end

        table.sort(candidates, function(first, second)
            return first.Urgency < second.Urgency
        end)
    end

    for _, candidate in candidates do
        if Parry.Evaluate(candidate.Ball, candidate.State, character, rootPart, currentTime) then
            break
        end
    end
end

function Parry.SetEnabled(enabled)
    Config.auto_parry = enabled
    Disconnect("AutoParry")

    if enabled then
        ActiveConnections.AutoParry = RunService.Heartbeat:Connect(Parry.Step)
    else
        Timing.Stop()
        table.clear(Parry.BallStates)
        table.clear(Parry.Learning.Pending)
        Parry.BlockedUntil = 0
        Abilities.Reset()
    end
end

function Parry.SetAccuracy(value)
    Config.accuracy = value
    Parry.AccuracyMultiplier = math.max((value - 1) * (1 / 66), 0.05)
end

function Parry.OnParrySuccessAll(_, swordPart)
    if not swordPart or not swordPart.Parent then
        return
    end

    local character = LocalPlayer.Character
    local rootPart = character and character.PrimaryPart
    local ball = Parry.GetParriedBall(swordPart)
    local zoomies = ball and ball:FindFirstChild("zoomies")

    if not rootPart or not zoomies or swordPart:IsDescendantOf(character) then
        return
    end

    local speed = zoomies.VectorVelocity.Magnitude

    if speed < Util.Epsilon then
        return
    end

    local distanceToBall = (rootPart.Position - ball.Position).Magnitude
    local pingSeconds = Util.GetPingSeconds()
    local timeToArrival = distanceToBall / speed - pingSeconds

    if distanceToBall > Curve.GetForeignRadius(speed, distanceToBall, pingSeconds, timeToArrival) then
        Curve.ForeignTimes[ball] = os.clock()
    end
end

Abilities = {
    AutoDeflect = {
        "Calming Deflection",
        "Raging Deflection",
        "Rapture",
        "Forcefield",
        "Aerodynamic Slash",
        "Slashes of Fury",
        "Singularity",
        "Death Slash",
        "Dribble",
        "Flash Counter",
        "Ninja Dash"
    },
    FireOnly = {
        "Infinity",
        "Quantum Arena",
        "Phantom",
        "Invisibility",
        "Ninja Dash",
        "Fracture",
        "Slash of Duality",
        "Pulse"
    },
    LastAttempt = -math.huge,
    AttemptCooldown = 0.6,
    ButtonPressEvent = nil,
    HellHook = {
        Active = false,
        ActiveUntil = 0,
        AddedConnection = nil,
        RemovedConnection = nil
    },
    Fury = {
        LocalActive = false,
        TimerEnd = 0,
        ComboBalls = setmetatable({}, {__mode = "k"}),
        LastComboNotify = 0
    },
    DeathSlash = {
        Active = false,
        Watching = false,
        LastFire = 0,
        FireCooldown = 0.05,
        WatchConnection = nil,
        AttributeConnection = nil
    },
    Duality = {
        Picking = false,
        MixedNext = "Light",
        BoundGuis = setmetatable({}, {__mode = "k"})
    }
}

local function IsDetectionEnabled()
    return Config.ability_detection ~= false
end

local function WaitForPlayerGui(timeout)
    return Util.GetPlayerGui() or LocalPlayer:WaitForChild("PlayerGui", timeout)
end

function Abilities.Reset()
    Abilities.LastAttempt = -math.huge
end

function Abilities.GetFolder(character)
    return character and character:FindFirstChild("Abilities")
end

function Abilities.HasEnabled(folder, names)
    if not folder then
        return false
    end

    for _, name in ipairs(names) do
        local ability = folder:FindFirstChild(name)

        if ability and ability.Enabled then
            return true
        end
    end

    return false
end

function Abilities.GetGradients()
    local playerGui = Util.GetPlayerGui()
    local hotbar = playerGui and playerGui:FindFirstChild("Hotbar")

    if not hotbar then
        return nil, nil
    end

    local blockFrame = hotbar:FindFirstChild("Block")
    local abilityFrame = hotbar:FindFirstChild("Ability")
    return blockFrame and blockFrame:FindFirstChild("UIGradient"), abilityFrame and abilityFrame:FindFirstChild("UIGradient")
end

function Abilities.IsReady(abilityGradient)
    return abilityGradient ~= nil and math.abs(abilityGradient.Offset.Y - 0.5) < 0.005
end

function Abilities.IsParryOnCooldown(parryGradient)
    return parryGradient ~= nil and parryGradient.Offset.Y <= 0.4
end

function Abilities.IsParryBlocked()
    local parryGradient = Abilities.GetGradients()

    return Abilities.IsParryOnCooldown(parryGradient)
end

function Abilities.IsParryReady()
    return not Abilities.IsParryBlocked()
end

function Abilities.PressButton()
    local event = Abilities.ButtonPressEvent or Util.GetRemote("AbilityButtonPress")

    Abilities.ButtonPressEvent = event

    if not event then
        return false
    end

    event:Fire()

    local fury = Abilities.Fury

    if fury.IsEquipped() or fury.HasEnabled() then
        fury.TimerEnd = os.clock() + 2
    end

    return true
end

function Abilities.TryFire(currentTime)
    if currentTime - Abilities.LastAttempt < Abilities.AttemptCooldown then
        return false
    end

    if not Abilities.PressButton() then
        return false
    end

    Abilities.LastAttempt = currentTime
    return true
end

function Abilities.ShouldSkipParry(character, distance, parryDistance)
    if not IsDetectionEnabled() or not character or distance > parryDistance then
        return false
    end

    local folder = Abilities.GetFolder(character)

    if not folder then
        return false
    end

    local parryGradient, abilityGradient = Abilities.GetGradients()

    if not Abilities.IsReady(abilityGradient) then
        return false
    end

    if character:GetAttribute("Pulsed") then
        return
    end

    local currentTime = os.clock()
    local hasDeflect = Abilities.HasEnabled(folder, Abilities.AutoDeflect)

    if Config.auto_ability then
        if Abilities.HasEnabled(folder, Abilities.FireOnly) then
            Abilities.TryFire(currentTime)
        end

        if hasDeflect then
            if Abilities.TryFire(currentTime) then
                local furyAbility = folder:FindFirstChild("Slashes of Fury")

                if furyAbility and furyAbility.Enabled then
                    Abilities.Fury.TimerEnd = os.clock() + 1
                end
            end

            return currentTime - Abilities.LastAttempt < Abilities.AttemptCooldown
        end
    end

    if Config.cooldown_protection and hasDeflect and not Spam.IsClashing(currentTime) and Abilities.IsParryOnCooldown(parryGradient) then
        Abilities.TryFire(currentTime)
        return currentTime - Abilities.LastAttempt < Abilities.AttemptCooldown
    end

    return false
end

do
    local hellHook = Abilities.HellHook

    function hellHook.Notify(message)
        if Config.hellhook_notify then
            Notify("Hell Hook", message, "info", 2)
        end
    end

    function hellHook.SetActive(isActive)
        if isActive then
            hellHook.Active = true
            hellHook.ActiveUntil = os.clock() + 0.85
            hellHook.Notify("hooked - autoparry hold")
        else
            hellHook.ActiveUntil = math.max(hellHook.ActiveUntil, os.clock() + 0.35)
        end
    end

    function hellHook.ShouldSkip()
        if not IsDetectionEnabled() or not Config.hellhook_detection then
            return false
        end

        local character = LocalPlayer.Character

        if character and character:FindFirstChild("HellHookUser") then
            hellHook.Active = true
            return true
        end

        if os.clock() < hellHook.ActiveUntil then
            return true
        end

        hellHook.Active = false
        return false
    end

    function hellHook.BindCharacter(character)
        if hellHook.AddedConnection then
            hellHook.AddedConnection:Disconnect()
            hellHook.AddedConnection = nil
        end

        if hellHook.RemovedConnection then
            hellHook.RemovedConnection:Disconnect()
            hellHook.RemovedConnection = nil
        end

        if not character then
            return
        end

        hellHook.AddedConnection = character.ChildAdded:Connect(function(child)
            if child.Name == "HellHookUser" and Config.hellhook_detection then
                hellHook.SetActive(true)
            end
        end)

        hellHook.RemovedConnection = character.ChildRemoved:Connect(function(child)
            if child.Name == "HellHookUser" then
                hellHook.SetActive(false)
                hellHook.Notify("hook ended")
            end
        end)

        if character:FindFirstChild("HellHookUser") and Config.hellhook_detection then
            hellHook.SetActive(true)
        end
    end

    hellHook.BindCharacter(LocalPlayer.Character)

    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        hellHook.BindCharacter(character)
    end)
end

do
    local fury = Abilities.Fury

    function fury.Notify(message)
        if Config.fury_notify then
            Notify("Slashes of Fury", message, "info", 2)
        end
    end

    function fury.Extend(duration)
        fury.LocalActive = true
        fury.TimerEnd = os.clock() + duration
    end

    function fury.IsActive()
        if not IsDetectionEnabled() or not Config.fury_detect then
            return false
        end

        return fury.TimerEnd > os.clock() or next(fury.ComboBalls) ~= nil
    end

    function fury.IsEquipped()
        return LocalPlayer:GetAttribute("EquippedAbility") == "Slashes of Fury"
    end

    function fury.HasEnabled()
        local folder = Abilities.GetFolder(LocalPlayer.Character)
        local ability = folder and folder:FindFirstChild("Slashes of Fury")
        return ability ~= nil and ability.Enabled == true
    end

    function fury.WatchCharacter(character)
        if not character then
            return
        end

        local function RefreshCatch()
            if character:GetAttribute("FuryCatch") then
                fury.Extend(1)
                fury.Notify("FuryCatch ON")
            end
        end

        RefreshCatch()
        character:GetAttributeChangedSignal("FuryCatch"):Connect(RefreshCatch)

        character.ChildAdded:Connect(function(child)
            if child.Name == "FuryHighlight" and child:IsA("Highlight") then
                fury.Extend(1)
                fury.Notify("FuryHighlight")
            end
        end)

        if character:FindFirstChild("FuryHighlight") then
            fury.LocalActive = true
        end
    end

    fury.WatchCharacter(LocalPlayer.Character)

    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        fury.WatchCharacter(character)
    end)

    local function BindTimer(gui)
        if not gui or gui.Name ~= "FuryTimer" then
            return
        end

        local function SyncTimer()
            if gui.Enabled then
                fury.Extend(1)
                fury.Notify("FuryTimer active")
            end
        end

        SyncTimer()
        gui:GetPropertyChangedSignal("Enabled"):Connect(SyncTimer)
    end

    task.spawn(function()
        local playerGui = WaitForPlayerGui(15)

        if not playerGui then
            return
        end

        BindTimer(playerGui:FindFirstChild("FuryTimer"))
        playerGui.ChildAdded:Connect(BindTimer)
    end)

    local function FindLabel(counter)
        local label = counter:FindFirstChildOfClass("TextLabel")

        if label then
            return label
        end

        for _, descendant in ipairs(counter:GetDescendants()) do
            if descendant:IsA("TextLabel") then
                return descendant
            end
        end

        return nil
    end

    local function BindCounter(ball, counter)
        local label = FindLabel(counter)

        if not label then
            return
        end

        local function ReadCount()
            local comboCount = tonumber(label.Text) or 1

            fury.ComboBalls[ball] = comboCount
            fury.Extend(1)

            local burstLimit = tonumber(Config.fury_burst)

            if IsDetectionEnabled() and Config.fury_detect and burstLimit and comboCount < burstLimit then
                task.spawn(Parry.Fire)
            end

            local currentTime = os.clock()

            if Config.fury_notify and currentTime - fury.LastComboNotify > 0.5 then
                fury.LastComboNotify = currentTime
                fury.Notify("Combo -> " .. tostring(comboCount))
            end
        end

        ReadCount()
        label:GetPropertyChangedSignal("Text"):Connect(ReadCount)

        counter.Destroying:Connect(function()
            fury.ComboBalls[ball] = nil
        end)
    end

    local function ScanBall(ball)
        local counter = ball:FindFirstChild("ComboCounter")

        if counter then
            BindCounter(ball, counter)
        end

        ball.ChildAdded:Connect(function(child)
            if child.Name == "ComboCounter" then
                BindCounter(ball, child)
            end
        end)
    end

    local function HookFolder(folder)
        if not folder then
            return
        end

        for _, ball in ipairs(folder:GetChildren()) do
            ScanBall(ball)
        end

        folder.ChildAdded:Connect(ScanBall)

        folder.ChildRemoved:Connect(function(ball)
            fury.ComboBalls[ball] = nil
        end)
    end

    task.spawn(function()
        HookFolder(Workspace:WaitForChild("Balls", 30))
        HookFolder(Workspace:WaitForChild("TrainingBalls", 30))
    end)
end

do
    local phantomEffects = {
        maxTransmission = true,
        transmissionpart = true
    }

    local function FindPhantomBall()
        local ballsFolder = Workspace:FindFirstChild("Balls")

        if not ballsFolder then
            return nil
        end

        for _, ball in ballsFolder:GetChildren() do
            if not ball:GetAttribute("realBall") then
                return ball
            end
        end

        return nil
    end

    local function RespondToPhantom(character, phantomBall)
        local startTime = os.clock()
        local hasFired = false
        local connection

        connection = RunService.PreSimulation:Connect(function()
            if not phantomBall.Parent or not phantomBall:GetAttribute("highlighted") then
                connection:Disconnect()
                return
            end

            if hasFired or os.clock() - startTime < 0.1 then
                return
            end

            hasFired = true

            local folder = Abilities.GetFolder(character)
            local parryGradient = Abilities.GetGradients()

            if Abilities.HasEnabled(folder, Abilities.AutoDeflect) and (not parryGradient or parryGradient.Offset.Y < 0.5) then
                Abilities.PressButton()
            end
        end)

        task.delay(3, function()
            if connection.Connected then
                connection:Disconnect()
            end
        end)
    end

    task.spawn(function()
        local runtimeFolder = Workspace:WaitForChild("Runtime", 30)

        if not runtimeFolder then
            return
        end

        runtimeFolder.ChildAdded:Connect(function(effect)
            if not IsDetectionEnabled() or not Config.phantom_detection or not phantomEffects[effect.Name] then
                return
            end

            local weld = effect:FindFirstChildWhichIsA("WeldConstraint")
            local character = LocalPlayer.Character

            if not weld or not character or not weld.Part1 or not weld.Part1:IsDescendantOf(character) then
                return
            end

            local phantomBall = FindPhantomBall()
            weld:Destroy()

            if phantomBall then
                RespondToPhantom(character, phantomBall)
            end
        end)
    end)
end

do
    local deathSlash = Abilities.DeathSlash

    function deathSlash.Notify(message)
        if Config.death_slash_notify then
            Notify("Death Slash", message, "info", 2)
        end
    end

    function deathSlash.GetTimerFrame()
        local playerGui = Util.GetPlayerGui()
        local timer = playerGui and playerGui:FindFirstChild("DeathSlashTimer")
        return timer and timer:FindFirstChild("Frame")
    end

    function deathSlash.IsPerfect(frame)
        if not frame then
            return false
        end

        local imageLabel = frame:FindFirstChild("ImageLabel")
        local circleFrame = frame:FindFirstChild("Circle")
        local innerFrame = frame:FindFirstChild("Inner")

        if not (imageLabel and circleFrame and innerFrame) then
            return false
        end

        local imageScale = imageLabel.Size.X.Scale
        local lowerBound = innerFrame.Size.X.Scale - 0.1
        local upperBound = circleFrame.Size.X.Scale + 0.1

        if imageScale < lowerBound or imageScale > upperBound then
            return false
        end

        local midpoint = (lowerBound + upperBound) * 0.5
        local halfRange = (upperBound - lowerBound) * 0.35
        return imageScale >= midpoint - halfRange and imageScale <= midpoint + halfRange
    end

    function deathSlash.Click()
        if mouse1click then
            mouse1click()
            return true
        end

        if mouse1press and mouse1release then
            mouse1press()
            task.wait()
            mouse1release()
            return true
        end

        local success = pcall(function()
            local camera = Workspace.CurrentCamera
            local center = camera.ViewportSize / 2
            local virtualInput = Util.GetVirtualInput()

            virtualInput:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
            task.wait()
            virtualInput:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
        end)

        return success
    end

    function deathSlash.FirePerfect()
        local currentTime = os.clock()

        if currentTime - deathSlash.LastFire < deathSlash.FireCooldown then
            return
        end

        deathSlash.LastFire = currentTime

        local fired = deathSlash.Click()

        deathSlash.Notify(fired and "PERFECT" or "PERFECT (no input path)")
    end

    function deathSlash.StopWatch()
        if deathSlash.WatchConnection then
            deathSlash.WatchConnection:Disconnect()
            deathSlash.WatchConnection = nil
        end

        deathSlash.Watching = false
        deathSlash.Active = false
    end

    function deathSlash.StartWatch(frame)
        if not IsDetectionEnabled() or deathSlash.Watching then
            return
        end

        deathSlash.Watching = true
        deathSlash.Active = true
        deathSlash.Notify("stance - watch timing")

        deathSlash.WatchConnection = RunService.RenderStepped:Connect(function()
            if not IsDetectionEnabled() or not Config.death_slash_detect then
                deathSlash.StopWatch()
                return
            end

            if not frame or not frame.Parent or not frame.Visible then
                deathSlash.StopWatch()
                return
            end

            if Config.death_slash_auto and deathSlash.IsPerfect(frame) then
                deathSlash.FirePerfect()
                deathSlash.StopWatch()
            end
        end)
    end

    function deathSlash.BindCharacter(character)
        if deathSlash.AttributeConnection then
            deathSlash.AttributeConnection:Disconnect()
            deathSlash.AttributeConnection = nil
        end

        if not character then
            return
        end

        local function OnStanceChanged()
            if character:GetAttribute("DEATH_SLASH_STANCE") then
                deathSlash.Active = true

                task.spawn(function()
                    local startTime = os.clock()
                    local frame

                    while os.clock() - startTime < 3 do
                        frame = deathSlash.GetTimerFrame()

                        if frame and frame.Visible then
                            break
                        end

                        task.wait(0.05)
                    end

                    if frame and frame.Visible and Config.death_slash_detect then
                        deathSlash.StartWatch(frame)
                    end
                end)
            else
                task.delay(0.3, function()
                    if not character:GetAttribute("DEATH_SLASH_STANCE") then
                        deathSlash.StopWatch()
                    end
                end)
            end
        end

        deathSlash.AttributeConnection = character:GetAttributeChangedSignal("DEATH_SLASH_STANCE"):Connect(OnStanceChanged)

        if character:GetAttribute("DEATH_SLASH_STANCE") then
            OnStanceChanged()
        end
    end

    deathSlash.BindCharacter(LocalPlayer.Character)

    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.15)
        deathSlash.BindCharacter(character)
    end)

    local function BindTimer(timer)
        if not timer or timer.Name ~= "DeathSlashTimer" then
            return
        end

        local frame = timer:FindFirstChild("Frame") or timer:WaitForChild("Frame", 2)

        if not frame then
            return
        end

        local function OnVisibilityChanged()
            if frame.Visible and Config.death_slash_detect then
                deathSlash.StartWatch(frame)
            elseif not frame.Visible then
                deathSlash.StopWatch()
            end
        end

        frame:GetPropertyChangedSignal("Visible"):Connect(OnVisibilityChanged)

        if frame.Visible then
            OnVisibilityChanged()
        end

        timer:GetPropertyChangedSignal("Enabled"):Connect(function()
            if timer.Enabled and frame.Visible and Config.death_slash_detect then
                deathSlash.StartWatch(frame)
            end
        end)
    end

    task.spawn(function()
        local playerGui = WaitForPlayerGui(30)

        if not playerGui then
            return
        end

        BindTimer(playerGui:FindFirstChild("DeathSlashTimer"))
        playerGui.ChildAdded:Connect(BindTimer)
    end)
end

do
    local duality = Abilities.Duality
    local choiceNames = {"Light", "Dark", "Dual"}

    function duality.Notify(message)
        if Config.duality_notify then
            Notify("Slash of Duality", message, "info", 2)
        end
    end

    function duality.IsOnCooldown(attributeName, character, currentTime)
        local cooldownEnd = character:GetAttribute(attributeName)
        return type(cooldownEnd) == "number" and cooldownEnd > currentTime
    end

    function duality.IsAvailable(choice, character)
        if not choice then
            return false
        end

        if choice:GetAttribute("Waiting") then
            return false
        end

        if not character then
            return true
        end

        local currentTime = Workspace:GetServerTimeNow()
        local lightCooling = duality.IsOnCooldown("LightDualityCooldown", character, currentTime)
        local darkCooling = duality.IsOnCooldown("DarkDualityCooldown", character, currentTime)

        if choice.Name == "Light" then
            return not lightCooling
        elseif choice.Name == "Dark" then
            return not darkCooling
        elseif choice.Name == "Dual" then
            return not lightCooling and not darkCooling
        end

        return true
    end

    function duality.PickName(choices, character)
        local mode = Config.duality_mode or "Randomized"
        local choicesByName = {}

        for _, choice in ipairs(choices) do
            choicesByName[choice.Name] = choice
        end

        local function IsAvailable(name)
            return duality.IsAvailable(choicesByName[name], character)
        end

        local function FirstAvailable(order)
            for _, name in ipairs(order) do
                if IsAvailable(name) then
                    return name
                end
            end

            return nil
        end

        if mode == "Light" then
            return FirstAvailable({"Light", "Dark", "Dual"})
        elseif mode == "Dark" then
            return FirstAvailable({"Dark", "Light", "Dual"})
        elseif mode == "Mixed" then
            local preferred = duality.MixedNext
            local alternative = preferred == "Light" and "Dark" or "Light"
            local picked = FirstAvailable({preferred, alternative, "Dual"})

            if picked == preferred then
                duality.MixedNext = alternative
            elseif picked == alternative then
                duality.MixedNext = preferred
            end

            return picked
        end

        local availableNames = {}

        for _, name in ipairs(choiceNames) do
            if IsAvailable(name) then
                availableNames[#availableNames + 1] = name
            end
        end

        return #availableNames > 0 and availableNames[math.random(1, #availableNames)] or nil
    end

    function duality.Press(choice)
        return (pcall(function()
            if firesignal then
                firesignal(choice.Activated)
            elseif getconnections then
                for _, connection in ipairs(getconnections(choice.Activated)) do
                    pcall(connection.Fire, connection)
                end
            else
                local position = choice.AbsolutePosition
                local size = choice.AbsoluteSize
                local x = position.X + size.X / 2
                local y = position.Y + size.Y / 2 + 36
                local virtualInput = Util.GetVirtualInput()

                virtualInput:SendMouseButtonEvent(x, y, 0, true, game, 1)
                task.wait()
                virtualInput:SendMouseButtonEvent(x, y, 0, false, game, 1)
            end
        end))
    end

    function duality.TryPick(gui)
        if not IsDetectionEnabled() or duality.Picking or not Config.duality_detect or not Config.duality_auto then
            return
        end

        local selection = gui and gui.Enabled and gui:FindFirstChild("Selection")
        local choicesFolder = selection and selection.Visible and selection:FindFirstChild("Choices")

        if not choicesFolder then
            return
        end

        local choices = {}

        for _, name in ipairs(choiceNames) do
            local choice = choicesFolder:FindFirstChild(name)

            if choice then
                choices[#choices + 1] = choice
            end
        end

        if #choices == 0 then
            return
        end

        local pickedName = duality.PickName(choices, LocalPlayer.Character)

        if not pickedName then
            duality.Notify("no choice available")
            return
        end

        local button = choicesFolder:FindFirstChild(pickedName)

        if not button then
            return
        end

        duality.Picking = true

        task.delay(0.05, function()
            local success = duality.Press(button)

            duality.Notify((success and "picked " or "failed ") .. pickedName)

            task.delay(0.35, function()
                duality.Picking = false
            end)
        end)
    end

    function duality.BindGui(gui)
        if not gui or gui.Name ~= "DualityChoice" or duality.BoundGuis[gui] then
            return
        end

        duality.BoundGuis[gui] = true

        local function RequestPick()
            if gui.Enabled and Config.duality_detect then
                task.defer(duality.TryPick, gui)
            end
        end

        gui:GetPropertyChangedSignal("Enabled"):Connect(RequestPick)

        local selection = gui:FindFirstChild("Selection")

        if selection then
            selection:GetPropertyChangedSignal("Visible"):Connect(RequestPick)
        end

        RequestPick()
    end

    task.spawn(function()
        local playerGui = WaitForPlayerGui(30)

        if not playerGui then
            return
        end

        duality.BindGui(playerGui:FindFirstChild("DualityChoice"))

        playerGui.ChildAdded:Connect(function(child)
            if child.Name == "DualityChoice" then
                task.wait(0.1)
                duality.BindGui(child)
            end
        end)
    end)
end

local AntiLag = {
    Enabled = false,
    Generation = 0,
    Working = false,
    Queue = {},
    Connections = {},
    Dispatch = {},
    Options = {},
    Pending = {},
    ModelCache = setmetatable({}, {__mode = "k"}),
    ModelCacheLifetime = 5,
    Processed = 0,
    CheckInterval = 150,
    DrainInterval = 16,
    ConfigKeys = {
        Quality = "al_quality",
        Shadows = "al_shadows",
        PostEffects = "al_post",
        Atmosphere = "al_atmosphere",
        Water = "al_water",
        Particles = "al_particles",
        Materials = "al_materials",
        Textures = "al_textures",
        Meshes = "al_meshes"
    },
    ShadowSettings = {
        GlobalShadows = false,
        EnvironmentDiffuseScale = 0,
        EnvironmentSpecularScale = 0
    },
    WaterSettings = {
        WaterWaveSize = 0,
        WaterWaveSpeed = 0,
        WaterReflectance = 0
    },
    ParticleClasses = {
        ParticleEmitter = true,
        Trail = true,
        Beam = true,
        Smoke = true,
        Fire = true,
        Sparkles = true
    },
    PostClasses = {
        BloomEffect = true,
        BlurEffect = true,
        DepthOfFieldEffect = true,
        SunRaysEffect = true
    },
    TextureClasses = {
        Decal = true,
        Texture = true
    },
    PartClasses = {
        Part = true,
        MeshPart = true,
        UnionOperation = true,
        WedgePart = true,
        CornerWedgePart = true,
        TrussPart = true,
        SpawnLocation = true,
        Seat = true,
        VehicleSeat = true
    },
    Saved = {
        QualityLevel = nil,
        Lighting = {},
        Water = {},
        Atmosphere = setmetatable({}, {__mode = "k"}),
        ParticleEnabled = setmetatable({}, {__mode = "k"}),
        ParticleLifetime = setmetatable({}, {__mode = "k"}),
        PostEnabled = setmetatable({}, {__mode = "k"}),
        CloudsEnabled = setmetatable({}, {__mode = "k"}),
        Transparency = setmetatable({}, {__mode = "k"}),
        CastShadow = setmetatable({}, {__mode = "k"}),
        Material = setmetatable({}, {__mode = "k"}),
        Reflectance = setmetatable({}, {__mode = "k"}),
        RenderFidelity = setmetatable({}, {__mode = "k"})
    }
}

AntiLag.GroupTables = {
    Particles = {
        {"ParticleEnabled", "Enabled"},
        {"ParticleLifetime", "Lifetime"}
    },
    PostEffects = {
        {"PostEnabled", "Enabled"}
    },
    Atmosphere = {
        {"CloudsEnabled", "Enabled"}
    },
    Textures = {
        {"Transparency", "Transparency"}
    },
    Shadows = {
        {"CastShadow", "CastShadow"}
    },
    Materials = {
        {"Material", "Material"},
        {"Reflectance", "Reflectance"}
    },
    Meshes = {
        {"RenderFidelity", "RenderFidelity"}
    }
}

AntiLag.DeferredClasses = {}

for className in pairs(AntiLag.PartClasses) do
    AntiLag.DeferredClasses[className] = true
end

for className in pairs(AntiLag.TextureClasses) do
    AntiLag.DeferredClasses[className] = true
end

AntiLag.InstanceGroups = {
    Shadows = true,
    PostEffects = true,
    Atmosphere = true,
    Particles = true,
    Materials = true,
    Textures = true,
    Meshes = true
}

function AntiLag.Assign(instance, property, value)
    instance[property] = value
end

function AntiLag.SaveProperty(saved, instance, property, value)
    if saved[instance] == nil then
        saved[instance] = instance[property]
    end

    instance[property] = value
end

function AntiLag.GetBudget()
    return math.clamp(Util.GetFrameTime() * 0.12, 0.0015, 0.004)
end

function AntiLag.IsInBalls(instance)
    local ballsFolder = Workspace:FindFirstChild("Balls")
    local trainingFolder = Workspace:FindFirstChild("TrainingBalls")

    return (ballsFolder ~= nil and instance:IsDescendantOf(ballsFolder))
        or (trainingFolder ~= nil and instance:IsDescendantOf(trainingFolder))
end

function AntiLag.IsCharacter(instance)
    local cache = AntiLag.ModelCache
    local currentTime = os.clock()
    local ancestor = instance.Parent

    while ancestor and ancestor ~= Workspace do
        if ancestor:IsA("Model") then
            local entry = cache[ancestor]

            if not entry or (not entry.Result and currentTime - entry.Time > AntiLag.ModelCacheLifetime) then
                entry = entry or {}
                entry.Result = ancestor:FindFirstChildOfClass("Humanoid") ~= nil or Players:FindFirstChild(ancestor.Name) ~= nil
                entry.Time = currentTime
                cache[ancestor] = entry
            end

            if entry.Result then
                return true
            end
        end

        ancestor = ancestor.Parent
    end

    return false
end

function AntiLag.IsProtected(instance)
    if AntiLag.IsInBalls(instance) then
        return true
    end

    local aliveFolder = Util.GetAliveFolder()

    if aliveFolder and instance:IsDescendantOf(aliveFolder) then
        return true
    end

    return AntiLag.IsCharacter(instance)
end

function AntiLag.ApplyParticle(instance)
    if AntiLag.IsInBalls(instance) then
        return
    end

    local saved = AntiLag.Saved

    AntiLag.SaveProperty(saved.ParticleEnabled, instance, "Enabled", false)

    if instance.ClassName == "ParticleEmitter" then
        AntiLag.SaveProperty(saved.ParticleLifetime, instance, "Lifetime", NumberRange.new(0))
    end
end

function AntiLag.ApplyPostEffect(instance)
    AntiLag.SaveProperty(AntiLag.Saved.PostEnabled, instance, "Enabled", false)
end

function AntiLag.ApplyAtmosphere(instance)
    local saved = AntiLag.Saved.Atmosphere

    if saved[instance] == nil then
        saved[instance] = {
            Density = instance.Density,
            Haze = instance.Haze,
            Glare = instance.Glare
        }
    end

    instance.Density = 0
    instance.Haze = 0
    instance.Glare = 0
end

function AntiLag.ApplyClouds(instance)
    AntiLag.SaveProperty(AntiLag.Saved.CloudsEnabled, instance, "Enabled", false)
end

function AntiLag.ApplyTexture(instance)
    if not instance.Parent or AntiLag.IsProtected(instance) then
        return
    end

    AntiLag.SaveProperty(AntiLag.Saved.Transparency, instance, "Transparency", 1)
end

function AntiLag.ApplyPart(part)
    if not part.Parent or AntiLag.IsProtected(part) then
        return
    end

    local options = AntiLag.Options
    local saved = AntiLag.Saved

    if options.Shadows then
        AntiLag.SaveProperty(saved.CastShadow, part, "CastShadow", false)
    end

    if options.Materials then
        AntiLag.SaveProperty(saved.Material, part, "Material", Enum.Material.SmoothPlastic)
        AntiLag.SaveProperty(saved.Reflectance, part, "Reflectance", 0)
    end

    if options.Meshes and part.ClassName == "MeshPart" and part.RenderFidelity ~= Enum.RenderFidelity.Performance then
        AntiLag.SaveProperty(saved.RenderFidelity, part, "RenderFidelity", Enum.RenderFidelity.Performance)
    end
end

function AntiLag.BuildDispatch()
    local options = AntiLag.Options
    local dispatch = {}

    local function AddClasses(classes, handler)
        for className in pairs(classes) do
            dispatch[className] = handler
        end
    end

    if options.Particles then
        AddClasses(AntiLag.ParticleClasses, AntiLag.ApplyParticle)
    end

    if options.PostEffects then
        AddClasses(AntiLag.PostClasses, AntiLag.ApplyPostEffect)
    end

    if options.Atmosphere then
        dispatch.Atmosphere = AntiLag.ApplyAtmosphere
        dispatch.Clouds = AntiLag.ApplyClouds
    end

    if options.Textures then
        AddClasses(AntiLag.TextureClasses, AntiLag.ApplyTexture)
    end

    if options.Shadows or options.Materials or options.Meshes then
        AddClasses(AntiLag.PartClasses, AntiLag.ApplyPart)
    end

    AntiLag.Dispatch = dispatch
end

function AntiLag.LoadOptions()
    for name, key in pairs(AntiLag.ConfigKeys) do
        AntiLag.Options[name] = Config[key] == true
    end
end

function AntiLag.Process(instance)
    local handler = AntiLag.Dispatch[instance.ClassName]

    if handler then
        pcall(handler, instance)
    end
end

function AntiLag.OnAdded(instance)
    local className = instance.ClassName
    local handler = AntiLag.Dispatch[className]

    if not handler then
        return
    end

    if AntiLag.DeferredClasses[className] then
        local pending = AntiLag.Pending

        pending[#pending + 1] = instance
    else
        pcall(handler, instance)
    end
end

function AntiLag.DrainPending()
    local batch = AntiLag.Pending

    if #batch == 0 then
        return
    end

    AntiLag.Pending = {}

    local started = os.clock()
    local budget = AntiLag.GetBudget()

    for index = 1, #batch do
        AntiLag.Process(batch[index])

        if index % AntiLag.DrainInterval == 0 and os.clock() - started >= budget then
            local remaining = AntiLag.Pending

            for restIndex = index + 1, #batch do
                remaining[#remaining + 1] = batch[restIndex]
            end

            return
        end
    end
end

function AntiLag.UpdateListeners()
    local needed = AntiLag.Enabled and next(AntiLag.Dispatch) ~= nil
    local connections = AntiLag.Connections

    if needed and not connections.Workspace then
        connections.Workspace = Workspace.DescendantAdded:Connect(AntiLag.OnAdded)
        connections.Lighting = Lighting.DescendantAdded:Connect(AntiLag.OnAdded)
        connections.Drain = RunService.Heartbeat:Connect(AntiLag.DrainPending)
    elseif not needed and connections.Workspace then
        connections.Workspace:Disconnect()
        connections.Lighting:Disconnect()
        connections.Drain:Disconnect()
        connections.Workspace = nil
        connections.Lighting = nil
        connections.Drain = nil
        AntiLag.Pending = {}
    end
end

function AntiLag.ApplyQuality()
    local rendering = settings().Rendering
    local saved = AntiLag.Saved

    if saved.QualityLevel == nil then
        saved.QualityLevel = rendering.QualityLevel
    end

    local level = math.clamp(math.floor(tonumber(Config.al_quality_level) or 1), 1, 10)

    rendering.QualityLevel = Enum.QualityLevel[string.format("Level%02d", level)]
end

function AntiLag.ApplyProperties(target, saved, settingsTable)
    for property, value in pairs(settingsTable) do
        local success, original = pcall(function()
            return target[property]
        end)

        if success and saved[property] == nil then
            saved[property] = original
        end

        pcall(AntiLag.Assign, target, property, value)
    end
end

function AntiLag.RestoreProperties(target, saved)
    for property, value in pairs(saved) do
        pcall(AntiLag.Assign, target, property, value)
    end

    table.clear(saved)
end

function AntiLag.RestoreTable(saved, property)
    local instances = {}
    local values = {}

    for instance, value in pairs(saved) do
        instances[#instances + 1] = instance
        values[#instances] = value
    end

    table.clear(saved)

    local started = os.clock()

    for index, instance in ipairs(instances) do
        pcall(AntiLag.Assign, instance, property, values[index])

        if index % AntiLag.CheckInterval == 0 and os.clock() - started >= AntiLag.GetBudget() then
            RunService.Heartbeat:Wait()
            started = os.clock()
        end
    end
end

function AntiLag.RestoreGroup(group)
    local saved = AntiLag.Saved

    if group == "Quality" then
        if saved.QualityLevel ~= nil then
            pcall(function()
                settings().Rendering.QualityLevel = saved.QualityLevel
            end)

            saved.QualityLevel = nil
        end

        return
    end

    if group == "Shadows" then
        AntiLag.RestoreProperties(Lighting, saved.Lighting)
    elseif group == "Water" then
        AntiLag.RestoreProperties(Workspace.Terrain, saved.Water)
        return
    elseif group == "Atmosphere" then
        for instance, original in pairs(saved.Atmosphere) do
            for property, value in pairs(original) do
                pcall(AntiLag.Assign, instance, property, value)
            end
        end

        table.clear(saved.Atmosphere)
    end

    for _, entry in ipairs(AntiLag.GroupTables[group] or {}) do
        AntiLag.RestoreTable(saved[entry[1]], entry[2])
    end
end

function AntiLag.Sweep(generation)
    local processed = 0
    local started = os.clock()
    local options = AntiLag.Options
    local needsWorld = options.Particles or options.Materials or options.Textures or options.Meshes or options.Shadows
    local roots = {Lighting}

    if needsWorld then
        roots[#roots + 1] = Workspace
    elseif Workspace.CurrentCamera then
        roots[#roots + 1] = Workspace.CurrentCamera
    end

    for _, root in ipairs(roots) do
        for _, child in ipairs(root:GetChildren()) do
            if child.Name ~= "Balls" and child.Name ~= "TrainingBalls" then
                AntiLag.Process(child)

                for _, descendant in ipairs(child:GetDescendants()) do
                    AntiLag.Process(descendant)
                    processed += 1

                    if processed % AntiLag.CheckInterval == 0 and os.clock() - started >= AntiLag.GetBudget() then
                        RunService.Heartbeat:Wait()
                        started = os.clock()

                        if AntiLag.Generation ~= generation then
                            return processed, false
                        end
                    end
                end
            end
        end

        RunService.Heartbeat:Wait()
        started = os.clock()

        if AntiLag.Generation ~= generation then
            return processed, false
        end
    end

    return processed, true
end

function AntiLag.RunApply(generation, group, announce)
    local options = AntiLag.Options

    if (group == nil or group == "Quality") and options.Quality then
        pcall(AntiLag.ApplyQuality)
    end

    if (group == nil or group == "Shadows") and options.Shadows then
        pcall(AntiLag.ApplyProperties, Lighting, AntiLag.Saved.Lighting, AntiLag.ShadowSettings)
    end

    if (group == nil or group == "Water") and options.Water then
        pcall(AntiLag.ApplyProperties, Workspace.Terrain, AntiLag.Saved.Water, AntiLag.WaterSettings)
    end

    if group ~= nil and not AntiLag.InstanceGroups[group] then
        return
    end

    if next(AntiLag.Dispatch) == nil then
        return
    end

    local processed, completed = AntiLag.Sweep(generation)

    if completed and announce then
        Notify("Anti Lag", string.format("Applied to %d objects", processed), "check", 3)
    end
end

function AntiLag.RunRestore(group)
    if group then
        AntiLag.RestoreGroup(group)
        return
    end

    AntiLag.RestoreGroup("Quality")
    AntiLag.RestoreGroup("Water")

    for name in pairs(AntiLag.InstanceGroups) do
        AntiLag.RestoreGroup(name)
    end
end

function AntiLag.Work()
    while #AntiLag.Queue > 0 do
        local operation = table.remove(AntiLag.Queue, 1)

        if operation.Kind == "apply" then
            if operation.Generation == AntiLag.Generation then
                AntiLag.RunApply(operation.Generation, operation.Group, operation.Announce)
            end
        else
            AntiLag.RunRestore(operation.Group)
        end
    end

    AntiLag.Working = false
end

function AntiLag.Enqueue(operation)
    table.insert(AntiLag.Queue, operation)

    if not AntiLag.Working then
        AntiLag.Working = true
        task.spawn(AntiLag.Work)
    end
end

function AntiLag.SetEnabled(enabled)
    if enabled == AntiLag.Enabled then
        return
    end

    AntiLag.Enabled = enabled
    AntiLag.Generation += 1

    if enabled then
        AntiLag.LoadOptions()
        AntiLag.BuildDispatch()
        AntiLag.UpdateListeners()

        AntiLag.Enqueue({
            Kind = "apply",
            Generation = AntiLag.Generation,
            Announce = true
        })
    else
        AntiLag.UpdateListeners()

        AntiLag.Enqueue({
            Kind = "restore"
        })
    end
end

function AntiLag.SetOption(name, enabled)
    AntiLag.Options[name] = enabled

    if not AntiLag.Enabled then
        return
    end

    AntiLag.BuildDispatch()
    AntiLag.UpdateListeners()

    if enabled then
        AntiLag.Enqueue({
            Kind = "apply",
            Generation = AntiLag.Generation,
            Group = name
        })
    else
        AntiLag.Enqueue({
            Kind = "restore",
            Group = name
        })
    end
end

function AntiLag.SetQualityLevel(level)
    Config.al_quality_level = math.clamp(math.floor(tonumber(level) or 1), 1, 10)

    if AntiLag.Enabled and AntiLag.Options.Quality then
        pcall(AntiLag.ApplyQuality)
    end
end

local UiReady = false

local NoRender = {
    Active = false,
    Connection = nil
}

function NoRender.Start()
    if NoRender.Active then
        return
    end

    NoRender.Active = true

    pcall(function()
        LocalPlayer.PlayerScripts.EffectScripts.ClientFX.Disabled = true
    end)

    local runtimeFolder = Workspace:FindFirstChild("Runtime")

    if runtimeFolder then
        NoRender.Connection = runtimeFolder.ChildAdded:Connect(function(effect)
            if NoRender.Active then
                Debris:AddItem(effect, 0)
            end
        end)
    end
end

function NoRender.Stop()
    if not NoRender.Active then
        return
    end

    NoRender.Active = false

    pcall(function()
        LocalPlayer.PlayerScripts.EffectScripts.ClientFX.Disabled = false
    end)

    if NoRender.Connection then
        NoRender.Connection:Disconnect()
        NoRender.Connection = nil
    end
end

UnlockAll = {
    Enabled = false,
    Status = nil,
    Run = 0,
    Loaded = false,
    Module = nil,
    ReadyTimeout = 60,
    LoadTimeout = 10,
    Types = {"Sword", "Explosion"},
    Connections = {},
    Originals = {},
    SavedEquipped = {},
    Defaults = {},
    SwordData = {},
    Clones = {},
    Favorites = {
        Sword = {},
        Explosion = {},
        Emote = {}
    },
    Deleted = {
        Sword = {},
        Explosion = {},
        Emote = {}
    },
    ShopState = {},
    ShopChanges = {},
    ShopItems = {
        Sword = {},
        Explosion = {}
    },
    ShopFields = {
        {"ItemsMatching", "ItemsMatching"},
        {"InDeleteMulti", "InDeleteMulti"},
        {"Owns", "OwnsItem"},
        {"Section", "Section"},
        {"ForceHide", "ForceHide"}
    },
    ShopActive = false,
    FavoriteStates = {},
    DefaultFavorites = {},
    EmoteItems = {},
    EmoteItemsList = {},
    EmoteDisplays = {},
    EmoteItemKeys = {},
    EmoteBuildIndex = 1,
    EmoteBuildToken = 0,
    EmoteBuilding = false,
    EmotesReady = false,
    EmoteCatalogLoaded = false,
    ButtonConnections = {},
    CardConnections = {},
    EquippedEmotes = {},
    Finishers = {},
    DefaultFinishers = {},
    Overlays = {},
    MultiDelete = {
        Sword = {},
        Explosion = {}
    },
    MultiDeleteCards = {},
    RequiredModules = {
        "Replion",
        "Trove",
        "GuiHandler",
        "InventoryClient",
        "InventoryShared",
        "InventoryController",
        "Shop",
        "ShopAPI",
        "TradeInfo",
        "Swords",
        "SwordFX",
        "SwordAPI",
        "EmoteWheel",
        "EmoteController",
        "DeletePrompt",
        "FinishersController",
        "VFX",
        "EmotesShared",
        "ItemInfo",
        "AwakenData",
        "EmotesFolder",
        "FireSwordInfo",
        "ParrySuccessAll",
        "ParrySuccessClient"
    },
    GetInfo = getinfo or debug.getinfo,
    GetUpvalues = getupvalues or debug.getupvalues,
    Patched = setmetatable({}, {__mode = "k"})
}

function UnlockAll.Track(connection)
    if UnlockAll.Status ~= "active" then
        UnlockAll.Cleanup(connection)

        return connection
    end

    UnlockAll.Connections[#UnlockAll.Connections + 1] = connection

    return connection
end

function UnlockAll.Cleanup(item)
    if typeof(item) == "RBXScriptConnection" then
        item:Disconnect()
    elseif type(item) == "thread" then
        if coroutine.status(item) ~= "dead" then
            task.cancel(item)
        end
    elseif type(item) == "table" then
        if type(item.Disconnect) == "function" then
            item:Disconnect()

            return
        end

        for _, child in item do
            UnlockAll.Cleanup(child)
        end
    end
end

function UnlockAll.DisconnectAll(signal)
    for _, connection in getconnections(signal) do
        pcall(connection.Disconnect, connection)
    end
end

function UnlockAll.Restore(key, target, field)
    local original = UnlockAll.Originals[key]

    if original then
        target[field or key] = original
        UnlockAll.Originals[key] = nil
    end
end

function UnlockAll.Upvalues(callback)
    if type(callback) ~= "function" then
        return {}
    end

    local success, upvalues = pcall(UnlockAll.GetUpvalues, callback)

    return success and type(upvalues) == "table" and upvalues or {}
end

function UnlockAll.GetCharacter()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if character and character.Parent and (not humanoid or humanoid.Health > 0) then
        return character
    end

    return nil
end

function UnlockAll.Fail(message)
    Notify("Unlock All", message, "x", 6)

    if UnlockAll.Module then
        UnlockAll.Module:change_state(false)
    end
end

function UnlockAll.Require(root, ...)
    local instance = root

    for _, name in {...} do
        instance = instance and instance:WaitForChild(name, UnlockAll.LoadTimeout)
    end

    if not instance then
        return nil
    end

    local success, module = pcall(require, instance)

    return success and module or nil
end

function UnlockAll.Load()
    if UnlockAll.Loaded then
        return true
    end

    if not (hookfunction and getconnections and UnlockAll.GetInfo and UnlockAll.GetUpvalues) then
        return false, "Executor is missing required functions"
    end

    local shared = ReplicatedStorage:WaitForChild("Shared", UnlockAll.LoadTimeout)
    local controllers = ReplicatedStorage:WaitForChild("Controllers", UnlockAll.LoadTimeout)
    local packages = ReplicatedStorage:WaitForChild("Packages", UnlockAll.LoadTimeout)
    local misc = ReplicatedStorage:WaitForChild("Misc", UnlockAll.LoadTimeout)
    local inventory = UnlockAll.Require(shared, "Inventory")

    UnlockAll.Replion = UnlockAll.Require(packages, "Replion")
    UnlockAll.Trove = UnlockAll.Require(packages, "Trove")
    UnlockAll.GuiHandler = UnlockAll.Require(ReplicatedStorage, "ClientGameModules", "GuiHandler")
    UnlockAll.InventoryClient = inventory and inventory.Client
    UnlockAll.InventoryShared = UnlockAll.Require(shared, "Inventory", "Shared")
    UnlockAll.InventoryController = UnlockAll.Require(controllers, "Trading", "InventoryController")
    UnlockAll.Shop = UnlockAll.Require(controllers, "UI", "ShopController")
    UnlockAll.ShopAPI = UnlockAll.Require(controllers, "UI", "ShopControllerAPI")
    UnlockAll.TradeInfo = UnlockAll.Require(shared, "Trading", "TradeInfo")
    UnlockAll.Swords = UnlockAll.Require(shared, "ReplicatedInstances", "Swords")
    UnlockAll.SwordFX = UnlockAll.Require(shared, "ReplicatedInstances", "SwordFX")
    UnlockAll.SwordAPI = UnlockAll.Require(shared, "SwordAPI")
    UnlockAll.EmoteWheel = UnlockAll.Require(controllers, "EmoteWheelController")
    UnlockAll.EmoteController = UnlockAll.Require(controllers, "EmoteController")
    UnlockAll.DeletePrompt = UnlockAll.Require(controllers, "DeleteItemPromptController")
    UnlockAll.FinishersController = UnlockAll.Require(controllers, "FinishersController")
    UnlockAll.VFX = UnlockAll.Require(controllers, "VFXController")
    UnlockAll.EmotesShared = UnlockAll.Require(shared, "EmotesShared")
    UnlockAll.ItemInfo = UnlockAll.Require(shared, "ItemInfo")
    UnlockAll.AwakenData = UnlockAll.Require(shared, "SecretAwakenData")
    UnlockAll.EmotesFolder = misc and misc:WaitForChild("Emotes", UnlockAll.LoadTimeout)
    UnlockAll.FireSwordInfo = Util.WaitForRemote("FireSwordInfo", UnlockAll.LoadTimeout)
    UnlockAll.ParrySuccessAll = Util.WaitForRemote("ParrySuccessAll", UnlockAll.LoadTimeout)
    UnlockAll.ParrySuccessClient = Util.WaitForRemote("ParrySuccessClient", UnlockAll.LoadTimeout)

    for _, name in UnlockAll.RequiredModules do
        if not UnlockAll[name] then
            return false, "Game module '" .. name .. "' not found"
        end
    end

    UnlockAll.AwakenBase = {}

    for name, data in UnlockAll.AwakenData do
        if type(data) == "table" and data.Awakened then
            UnlockAll.AwakenBase[data.Awakened.Value] = name
        end
    end

    UnlockAll.Loaded = true

    return true
end

function UnlockAll.ShopReady()
    local shop = UnlockAll.Shop
    local virtualItems = shop._virtualItems

    if not virtualItems then
        return false
    end

    local loadPage = shop._loadInventoryPage

    if loadPage then
        for _, kind in UnlockAll.Types do
            if virtualItems[kind] and not next(virtualItems[kind]) then
                loadPage(kind)
            end
        end
    end

    local pages = shop._inventoryPages
    local swordPage = pages and pages.Sword
    local explosionPage = pages and pages.Explosion

    return virtualItems.Sword ~= nil
        and next(virtualItems.Sword) ~= nil
        and virtualItems.Explosion ~= nil
        and next(virtualItems.Explosion) ~= nil
        and swordPage ~= nil
        and swordPage.BatchDepth == 0
        and explosionPage ~= nil
        and explosionPage.BatchDepth == 0
end

function UnlockAll.IsReady()
    local client = UnlockAll.Replion.Client

    UnlockAll.InventoryReplion = UnlockAll.InventoryReplion or client:GetReplion("Inventory")
    UnlockAll.DataReplion = UnlockAll.DataReplion or client:GetReplion("Data")

    return UnlockAll.InventoryReplion ~= nil and UnlockAll.ShopReady()
end

function UnlockAll.Save()
    local emotes = {}

    for slot, name in UnlockAll.EquippedEmotes do
        emotes[tostring(slot)] = name
    end

    Config.unlock_all_data = {
        Sword = UnlockAll.AwakenBase[UnlockAll.Sword] or UnlockAll.Sword or "",
        Explosion = UnlockAll.Explosion or "",
        Accessory = UnlockAll.Accessory == true,
        Emotes = emotes,
        Finishers = table.clone(UnlockAll.Finishers),
        Favorites = {
            Sword = table.clone(UnlockAll.Favorites.Sword),
            Explosion = table.clone(UnlockAll.Favorites.Explosion),
            Emote = table.clone(UnlockAll.Favorites.Emote)
        }
    }
end

function UnlockAll.GetData()
    local data = Config.unlock_all_data

    return type(data) == "table" and data or {}
end

function UnlockAll.LoadFavorites()
    local saved = UnlockAll.GetData().Favorites

    for kind, favorites in UnlockAll.Favorites do
        table.clear(favorites)

        local entries = type(saved) == "table" and saved[kind]

        if type(entries) == "table" then
            for name, favorited in entries do
                if favorited == true then
                    favorites[name] = true
                end
            end
        end
    end
end

function UnlockAll.ApplyFavorites()
    for kind, favorites in UnlockAll.Favorites do
        for name in favorites do
            UnlockAll.SetFavorite(kind, name, true, false)
        end
    end
end

function UnlockAll.GetFavoriteState(kind, name)
    local key = kind .. "\0" .. tostring(name)
    local state = UnlockAll.FavoriteStates[key]

    if state then
        return state
    end

    state = UnlockAll.InventoryController:GetFavoriteState(kind, name)

    if state then
        UnlockAll.FavoriteStates[key] = state
        UnlockAll.DefaultFavorites[key] = state:Get() == true
    end

    return state
end

function UnlockAll.GetShopFavorites()
    if UnlockAll.ShopFavorites then
        return UnlockAll.ShopFavorites
    end

    local page = UnlockAll.Shop._inventoryPages and UnlockAll.Shop._inventoryPages.Sword
    local markDirty = UnlockAll.Originals.MarkDirtySword or page and page.MarkDirty
    local second = UnlockAll.Upvalues(markDirty)[2]
    local fourth = UnlockAll.Upvalues(second)[4]

    for _, upvalue in UnlockAll.Upvalues(fourth) do
        if type(upvalue) == "table" and type(upvalue.Sword) == "table" and type(upvalue.Explosion) == "table" then
            UnlockAll.ShopFavorites = upvalue

            return upvalue
        end
    end

    return nil
end

function UnlockAll.SetFavorite(kind, name, favorited, persist)
    if not UnlockAll.Favorites[kind] then
        return
    end

    UnlockAll.Favorites[kind][name] = favorited and true or nil

    local state = UnlockAll.GetFavoriteState(kind, name)
    local shopFavorites = kind ~= "Emote" and UnlockAll.GetShopFavorites()

    if shopFavorites and shopFavorites[kind] then
        shopFavorites[kind][name] = favorited and true or nil

        local page = UnlockAll.Shop._inventoryPages and UnlockAll.Shop._inventoryPages[kind]

        if page and page.MarkDirty then
            page.MarkDirty(nil, true, true)
        end
    end

    if state then
        state:Set(favorited == true)
    end

    local consoleItem = UnlockAll.ConsoleItems and UnlockAll.ConsoleItems[kind] and UnlockAll.ConsoleItems[kind][name]

    if consoleItem then
        consoleItem.Data.IsFavorited:Set(favorited == true)
    end

    if persist ~= false then
        UnlockAll.Save()
    end
end

function UnlockAll.ToggleFavorite(kind, name)
    UnlockAll.SetFavorite(kind, name, not UnlockAll.Favorites[kind][name])
end

function UnlockAll.RestoreFavorites()
    local shopFavorites = UnlockAll.GetShopFavorites()

    for key, state in UnlockAll.FavoriteStates do
        local favorited = UnlockAll.DefaultFavorites[key] == true
        local separator = string.find(key, "\0", 1, true)
        local kind = separator and string.sub(key, 1, separator - 1)
        local name = separator and string.sub(key, separator + 1)

        if shopFavorites and shopFavorites[kind] and name then
            shopFavorites[kind][name] = favorited and true or nil
        end

        state:Set(favorited)
    end

    for _, kind in UnlockAll.Types do
        local page = UnlockAll.Shop._inventoryPages and UnlockAll.Shop._inventoryPages[kind]

        if page then
            page.MarkDirty(nil, true, true)
        end
    end

    table.clear(UnlockAll.FavoriteStates)
    table.clear(UnlockAll.DefaultFavorites)
end

function UnlockAll.GetShopState(item, key)
    local state = item and item[key]

    if type(state) == "table" and type(state.Get) == "function" then
        return state:Get()
    end

    return state
end

function UnlockAll.ApplyShopState(item, key, value)
    local state = item and item[key]

    if type(state) == "table" and type(state.Set) == "function" then
        state:Set(value)
    elseif item then
        item[key] = value
    end
end

function UnlockAll.SetShopState(item, changes)
    local state = item and UnlockAll.ShopState[item]

    if not state then
        return
    end

    local originals = UnlockAll.ShopChanges[item]
    local changed = false

    for _, field in UnlockAll.ShopFields do
        local key = field[1]
        local value = changes[key]

        if value ~= nil then
            local current = UnlockAll.GetShopState(item, field[2])

            if current ~= value then
                UnlockAll.ApplyShopState(item, field[2], value)
                originals = originals or {}

                if originals[key] == nil then
                    originals[key] = current
                elseif originals[key] == value then
                    originals[key] = nil
                end

                changed = true
            end

            state[key] = value
        end
    end

    if originals then
        UnlockAll.ShopChanges[item] = next(originals) and originals or nil
    end

    local page = UnlockAll.Shop._inventoryPages and UnlockAll.Shop._inventoryPages[item.Type]

    if changed and page and page.MarkDirty and page.BatchDepth == 0 then
        page.MarkDirty(item, false, true)
    end

    if changed and UnlockAll.ConsoleItems then
        UnlockAll.SyncConsoleItem(item)
    end
end

function UnlockAll.IsUnlockItem(item)
    return type(item) == "table" and tostring(item.Id or ""):match("^UnlockAll:") ~= nil
end

function UnlockAll.GetOwnedItem(kind, name)
    local client = UnlockAll.InventoryClient
    local ids = client:FindItems(kind, name)
    local id = type(ids) == "table" and ids[1]
    local item = id and client:GetItem(kind, id)

    if item and not UnlockAll.IsUnlockItem(item) then
        local copy = table.clone(item)

        copy.Id = copy.Id or id

        return copy
    end

    for _, owned in client:GetInventory()[kind] or {} do
        if owned.Name == name and not UnlockAll.IsUnlockItem(owned) then
            return owned
        end
    end

    return nil
end

function UnlockAll.GetRealEquipped(kind)
    local equipped = UnlockAll.InventoryClient:GetEquipped(kind)

    if not UnlockAll.IsUnlockItem(equipped) then
        return equipped
    end

    return UnlockAll.GetOwnedItem(kind, equipped.Name)
end

function UnlockAll.ActivateShop()
    if UnlockAll.ShopActive then
        return true
    end

    UnlockAll.ShopActive = true
    table.clear(UnlockAll.ShopState)
    table.clear(UnlockAll.ShopChanges)

    local run = UnlockAll.Run
    local deadline = os.clock() + 0.004
    local shop = UnlockAll.Shop
    local pages = shop._inventoryPages
    local states = UnlockAll.ShopState

    local function Slice(page)
        if os.clock() < deadline then
            return true
        end

        RunService.Heartbeat:Wait()

        if UnlockAll.Run ~= run or UnlockAll.Status ~= "active" then
            if page and page.EndBatch then
                page.EndBatch()
            end

            return false
        end

        deadline = os.clock() + 0.004

        return true
    end

    for _, kind in UnlockAll.Types do
        local page = pages and pages[kind]
        local items = shop._virtualItems[kind] or {}
        local chosen = UnlockAll.ShopItems[kind]
        local readyNames = {}

        if page and page.BeginBatch then
            page.BeginBatch()
        end

        table.clear(chosen)

        for _, item in items do
            local name = item.Name

            if name and name ~= "Random" then
                local owns = UnlockAll.GetShopState(item, "OwnsItem")
                local state = {
                    Owns = owns,
                    Section = UnlockAll.GetShopState(item, "Section"),
                    ForceHide = UnlockAll.GetShopState(item, "ForceHide"),
                    ItemsMatching = UnlockAll.GetShopState(item, "ItemsMatching"),
                    InDeleteMulti = UnlockAll.GetShopState(item, "InDeleteMulti"),
                    Virtual = owns ~= true
                }

                states[item] = state

                local current = chosen[name]

                if not current then
                    chosen[name] = item
                    readyNames[name] = owns and not state.ForceHide or nil
                elseif not readyNames[name] then
                    local currentState = states[current]

                    if owns and not state.ForceHide then
                        chosen[name] = item
                        readyNames[name] = true
                    elseif owns and not currentState.Owns then
                        chosen[name] = item
                    elseif currentState.ForceHide and not state.ForceHide then
                        chosen[name] = item
                    end
                end
            end

            if not Slice(page) then
                return false
            end
        end

        for _, item in items do
            local name = item.Name

            if name and name ~= "Random" then
                local state = states[item]
                local previous = table.clone(state)

                if item == chosen[name] then
                    local awakened = kind == "Sword" and UnlockAll.AwakenBase[name] ~= nil
                    local matching = state.ItemsMatching or {}

                    if UnlockAll.Deleted[kind][name] or awakened then
                        matching = {}
                    elseif #matching == 0 then
                        matching = {"UnlockAll:" .. name}
                    end

                    state.ItemsMatching = matching
                    state.InDeleteMulti = 0
                    state.Owns = #matching > 0
                    state.Section = state.Owns and "Owned" or "Unowned"
                    state.ForceHide = awakened
                else
                    state.ForceHide = true
                end

                local changes = {}

                for _, field in UnlockAll.ShopFields do
                    if state[field[1]] ~= previous[field[1]] then
                        changes[field[1]] = previous[field[1]]
                    end
                end

                UnlockAll.ShopChanges[item] = next(changes) and changes or nil
            end

            if not Slice(page) then
                return false
            end
        end

        for _, item in items do
            local changes = UnlockAll.ShopChanges[item]

            if changes then
                for _, field in UnlockAll.ShopFields do
                    if changes[field[1]] ~= nil then
                        UnlockAll.ApplyShopState(item, field[2], states[item][field[1]])
                    end
                end
            end
        end

        if page and page.MarkDirty then
            page.MarkDirty(nil, false, true)
        end

        if page and page.EndBatch then
            page.EndBatch()
        end
    end

    return true
end

function UnlockAll.RestoreShop()
    if not UnlockAll.ShopActive then
        return
    end

    UnlockAll.ShopActive = false

    local pages = UnlockAll.Shop._inventoryPages

    for _, kind in UnlockAll.Types do
        local page = pages and pages[kind]

        if page and page.BeginBatch then
            page.BeginBatch()
        end
    end

    for item, changes in UnlockAll.ShopChanges do
        for _, field in UnlockAll.ShopFields do
            if changes[field[1]] ~= nil then
                UnlockAll.ApplyShopState(item, field[2], changes[field[1]])
            end
        end
    end

    for _, kind in UnlockAll.Types do
        local page = pages and pages[kind]

        if page and page.MarkDirty then
            page.MarkDirty(nil, false, true)
        end

        if page and page.EndBatch then
            page.EndBatch()
        end
    end

    table.clear(UnlockAll.ShopState)
    table.clear(UnlockAll.ShopChanges)
    table.clear(UnlockAll.ShopItems.Sword)
    table.clear(UnlockAll.ShopItems.Explosion)
end

function UnlockAll.GetSelected()
    local console = UnlockAll.Console

    if console then
        local kind = console:GetCurrentPage()
        local page = console.PageInfo[kind]
        local selected = page and page.ItemState:Get()
        local name = selected and selected.ItemInfo.Name

        if UnlockAll.ShopItems[kind] and name then
            return kind, name, UnlockAll.ShopItems[kind][name]
        end

        return nil
    end

    local selected = UnlockAll.Shop and UnlockAll.Shop._selectedItem
    local kind = selected and selected.type
    local name = selected and selected.name

    if (kind == "Sword" or kind == "Explosion") and name then
        return kind, name, UnlockAll.ShopItems[kind][name]
    end

    return nil
end

function UnlockAll.GetShopHolder()
    local gui = Util.GetPlayerGui()
    local shop = gui and gui:FindFirstChild("Shop")

    return shop and shop:FindFirstChild("Holder")
end

function UnlockAll.MakeOverlay(name, target, callback)
    if not target then
        return
    end

    local overlay = Instance.new("TextButton")

    overlay.Name = "UnlockAll" .. name
    overlay.Text = ""
    overlay.AutoButtonColor = false
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.ZIndex = 100
    overlay.Visible = false
    overlay.Parent = target

    UnlockAll.Track(overlay.Activated:Connect(callback))
    UnlockAll.Overlays[name] = overlay
end

function UnlockAll.DestroyOverlays()
    for _, overlay in UnlockAll.Overlays do
        if overlay and overlay.Parent then
            overlay:Destroy()
        end
    end

    table.clear(UnlockAll.Overlays)
end

function UnlockAll.RefreshShop()
    if UnlockAll.Console then
        return
    end

    local kind, name, item = UnlockAll.GetSelected()
    local overlays = UnlockAll.Overlays
    local active = UnlockAll.Status == "active"
        and item ~= nil
        and not UnlockAll.Shop._multiDelete
        and UnlockAll.Deleted[kind][name] ~= true

    if overlays.Favorite then
        overlays.Favorite.Visible = active
    end

    if overlays.Accessory then
        overlays.Accessory.Visible = false
    end

    if overlays.Finisher then
        overlays.Finisher.Visible = false
    end

    local state = item and UnlockAll.ShopState[item]
    local owned = active and state ~= nil and state.Owns == true

    if overlays.Delete then
        overlays.Delete.Visible = owned
    end

    local holder = UnlockAll.GetShopHolder()
    local favorite = holder and holder:FindFirstChild("Favorite")

    if (kind == "Sword" or kind == "Explosion") and favorite then
        favorite.Visible = owned

        if owned then
            local favorited = UnlockAll.Favorites[kind][name] == true

            favorite.Image = favorited and "rbxassetid://15697987058" or "rbxassetid://15697981750"
            favorite.HoverImage = favorited and "rbxassetid://15697983062" or "rbxassetid://15697987058"
        end
    end

    local info = holder and holder:FindFirstChild("InfoBG")
    local secret = info and info:FindFirstChild("SecretUpgrade")

    if secret then
        secret.Visible = owned and kind == "Sword" and UnlockAll.AwakenData[name] ~= nil
    end

    local deleteButton = info and info:FindFirstChild("Delete")

    if deleteButton then
        deleteButton.Visible = overlays.Delete ~= nil and overlays.Delete.Visible
    end

    if info and kind and name and UnlockAll.Deleted[kind][name] == true then
        for _, buttonName in {
            "BuyButton",
            "GiftButton",
            "UpgradeButton",
            "Finisher",
            "ChangeStyle",
            "EquipAccessory",
            "SecretUpgrade",
            "CharacterUpgradeButton",
            "UpgradesInfoButton",
            "Equips"
        } do
            local button = info:FindFirstChild(buttonName)

            if button and button:IsA("GuiObject") then
                button.Visible = false
            end
        end
    end

    local buyButton = info and info:FindFirstChild("BuyButton")

    if buyButton and owned and state.Virtual then
        local equipped = kind == "Sword" and UnlockAll.Sword == name or kind == "Explosion" and UnlockAll.Explosion == name
        local priceTag = buyButton:FindFirstChild("PriceTag")

        buyButton.Visible = true
        buyButton.Active = true

        if priceTag then
            local price = priceTag:FindFirstChild("Price")
            local label = priceTag:FindFirstChild("TextLabel")

            if price then
                price.Visible = false
            end

            if label then
                label.Text = equipped and "Equipped" or "Equip"
            end
        end
    end

    local equips = info and info:FindFirstChild("Equips")

    if kind == "Sword" and owned and state.Virtual and equips then
        local data = UnlockAll.Shop._selectedItem and UnlockAll.Shop._selectedItem.data
        local finisherButton = equips:FindFirstChild("Finisher")
        local accessoryButton = equips:FindFirstChild("EquipAccessory")

        if finisherButton and data and data.HasFinisher then
            finisherButton.Visible = true
            finisherButton.ImageColor3 = Color3.new(1, 1, 1)
            finisherButton.Label.Text = UnlockAll.Finishers[name] and "UNEQUIP" or "EQUIP"

            if overlays.Finisher then
                overlays.Finisher.Visible = true
            end
        end

        if accessoryButton and data and data.AccessoryToggleable and UnlockAll.Sword == name then
            accessoryButton.Visible = true
            accessoryButton.Label.Text = UnlockAll.Accessory and "UNEQUIP ACCESSORY" or "EQUIP ACCESSORY"

            if overlays.Accessory then
                overlays.Accessory.Visible = true
            end
        end
    end

    if UnlockAll.Shop._multiDelete then
        UnlockAll.Shop:_updateMultiDeleteVisbility()
    end
end

function UnlockAll.SetAccessory(enabled)
    UnlockAll.Accessory = enabled == true
    LocalPlayer:SetAttribute("ShowSwordAccessory", UnlockAll.Accessory)

    if UnlockAll.Accessory and UnlockAll.Sword then
        UnlockAll.ApplySword(UnlockAll.Sword)
    elseif not UnlockAll.Accessory then
        local character = UnlockAll.GetCharacter()
        local accessories = character and character:FindFirstChild("SwordAccessories")

        if accessories then
            accessories:Destroy()
        end
    end

    UnlockAll.Save()
    UnlockAll.RefreshShop()

    for clone in UnlockAll.Clones do
        UnlockAll.UpdateClone(clone)
    end
end

function UnlockAll.SetFinisher(sword, enabled)
    if not sword then
        return
    end

    local path = {"Finishers", "Equipped", sword}

    if UnlockAll.DefaultFinishers[sword] == nil and UnlockAll.DataReplion then
        UnlockAll.DefaultFinishers[sword] = UnlockAll.DataReplion:Get(path) == true
    end

    UnlockAll.Finishers[sword] = enabled and true or nil

    if UnlockAll.DataReplion then
        UnlockAll.DataReplion:_set(path, enabled == true)
    end

    UnlockAll.Save()
    UnlockAll.RefreshShop()
end

function UnlockAll.GetCardType(card)
    local holder = UnlockAll.GetShopHolder()
    local pages = holder and holder:FindFirstChild("Pages")

    if pages and pages:FindFirstChild("Sword") and card:IsDescendantOf(pages.Sword) then
        return "Sword"
    end

    if pages and pages:FindFirstChild("Explosion") and card:IsDescendantOf(pages.Explosion) then
        return "Explosion"
    end

    return nil
end

function UnlockAll.UpdateMultiDelete()
    local total = 0

    for _, kind in UnlockAll.Types do
        for _, count in UnlockAll.MultiDelete[kind] do
            total += count
        end
    end

    local overlay = UnlockAll.Overlays.MultiDelete

    if overlay then
        overlay.Visible = UnlockAll.Status == "active"
    end

    local holder = UnlockAll.GetShopHolder()
    local deleteItems = holder and holder:FindFirstChild("DeleteItems")
    local title = deleteItems and deleteItems:FindFirstChild("Title")

    if title then
        title.Text = total > 0 and "Delete Items (" .. total .. ")" or "Delete Items"
    end
end

function UnlockAll.GetDeleteList()
    local holder = UnlockAll.GetShopHolder()
    local deleteItems = holder and holder:FindFirstChild("DeleteItems")
    local list = deleteItems and deleteItems:FindFirstChild("List")
    local canvas = list and list:FindFirstChild("ContentsCanvas")

    return canvas and canvas:FindFirstChild("ScrollingFrame")
end

function UnlockAll.SetDeleteCount(kind, name, count)
    local item = UnlockAll.ShopItems[kind][name]
    local state = item and UnlockAll.ShopState[item]

    if not state then
        return
    end

    local clamped = math.clamp(count, 0, #state.ItemsMatching)

    UnlockAll.MultiDelete[kind][name] = clamped > 0 and clamped or nil

    UnlockAll.SetShopState(item, {
        InDeleteMulti = clamped,
        ForceHide = clamped > 0 and clamped == #state.ItemsMatching
    })

    local key = kind .. "\0" .. name
    local card = UnlockAll.MultiDeleteCards[key]

    if clamped == 0 then
        if card then
            card:Destroy()
        end

        UnlockAll.MultiDeleteCards[key] = nil
    else
        local list = UnlockAll.GetDeleteList()

        if list then
            if not card or card.Parent ~= list then
                local layout = list:FindFirstChildWhichIsA("UIListLayout")
                local template = layout and layout:FindFirstChild("Template")
                local info = UnlockAll.ItemInfo[kind][name]

                if not template or not info then
                    return
                end

                local colors = UnlockAll.TradeInfo.SmallerSlotColors
                local color = colors[info.Rarity] or colors.Default

                card = template:Clone()
                card.Name = kind .. "_" .. name
                card.Visible = true
                card.Button.Label.Text = info.DisplayName or info.Name or name
                card.Button.Item.Vector.Image = info.Icon or ""
                card.Button.Item.Image = color.Image
                card.Button.Item.HoverImage = color.HoverImage
                card.Parent = list
                UnlockAll.MultiDeleteCards[key] = card

                local function Decrease()
                    UnlockAll.SetDeleteCount(kind, name, (UnlockAll.MultiDelete[kind][name] or 0) - 1)
                end

                card.Button.Activated:Connect(Decrease)
                card.Button.Item.Activated:Connect(Decrease)
            end

            card.Button.Item.Label.Text = "x" .. clamped
        end
    end

    UnlockAll.UpdateMultiDelete()
end

function UnlockAll.ClearMultiDelete()
    for _, kind in UnlockAll.Types do
        for name in UnlockAll.MultiDelete[kind] do
            local item = UnlockAll.ShopItems[kind][name]

            if item and not UnlockAll.Deleted[kind][name] then
                UnlockAll.SetShopState(item, {InDeleteMulti = 0, ForceHide = false})
            end
        end
    end

    table.clear(UnlockAll.MultiDelete.Sword)
    table.clear(UnlockAll.MultiDelete.Explosion)

    for key, card in UnlockAll.MultiDeleteCards do
        card:Destroy()
        UnlockAll.MultiDeleteCards[key] = nil
    end

    UnlockAll.UpdateMultiDelete()

    if UnlockAll.Status == "active" then
        UnlockAll.RefreshShop()
    end
end

function UnlockAll.ToggleMultiItem(card)
    if not UnlockAll.Shop._multiDelete then
        return
    end

    local kind = UnlockAll.GetCardType(card)
    local name = card:GetAttribute("Name")
    local item = kind and name and UnlockAll.ShopItems[kind][name]

    if not (item and UnlockAll.ShopState[item]) or UnlockAll.Deleted[kind][name] then
        return
    end

    UnlockAll.SetDeleteCount(kind, name, (UnlockAll.MultiDelete[kind][name] or 0) + 1)
end

function UnlockAll.HookMultiCard(card)
    if UnlockAll.Status ~= "active"
        or UnlockAll.CardConnections[card]
        or not card:IsA("GuiButton")
        or not UnlockAll.GetCardType(card) then
        return
    end

    UnlockAll.CardConnections[card] = card.Activated:Connect(function()
        UnlockAll.ToggleMultiItem(card)
    end)
end

function UnlockAll.CloseMultiDelete()
    UnlockAll.Shop._multiDelete = nil
    UnlockAll.Shop:_updateMultiDeleteVisbility()
    UnlockAll.Shop:_updateMultiDelete()
    UnlockAll.ClearMultiDelete()
end

function UnlockAll.ConfirmMultiDelete()
    if not UnlockAll.Shop._multiDelete then
        return
    end

    local entries = {}
    local total = 0

    for _, kind in UnlockAll.Types do
        for name, count in UnlockAll.MultiDelete[kind] do
            total += count
            entries[#entries + 1] = {Type = kind, Name = name, Quantity = count}
        end
    end

    UnlockAll.ConfirmDelete(entries, "x" .. total .. " items", UnlockAll.CloseMultiDelete)
end

function UnlockAll.HookMultiDelete(holder)
    local pages = holder:FindFirstChild("Pages")
    local deleteItems = holder:FindFirstChild("DeleteItems")
    local list = deleteItems and deleteItems:FindFirstChild("List")
    local buttons = list and list:FindFirstChild("Buttons")
    local shop = UnlockAll.Shop
    local original = shop._updateMultiDelete

    UnlockAll.Originals.CanDelete = shop._canDelete

    shop._canDelete = function()
        return false
    end

    UnlockAll.CloseMultiDelete()

    shop._updateMultiDelete = function(self)
        if UnlockAll.Status ~= "active" then
            return original(self)
        end

        if not self._multiDelete then
            UnlockAll.ClearMultiDelete()

            return
        end

        UnlockAll.UpdateMultiDelete()
    end

    UnlockAll.Originals.UpdateMultiDelete = original
    UnlockAll.MakeOverlay("MultiDelete", buttons and buttons:FindFirstChild("Delete"), UnlockAll.ConfirmMultiDelete)

    if pages then
        for _, descendant in pages:GetDescendants() do
            UnlockAll.HookMultiCard(descendant)
        end

        UnlockAll.Track(pages.DescendantAdded:Connect(function(descendant)
            task.defer(UnlockAll.HookMultiCard, descendant)
        end))
    end

    UnlockAll.UpdateMultiDelete()
end

function UnlockAll.ConfirmDelete(entries, description, onConfirm)
    local run = UnlockAll.Run

    UnlockAll.DeletePrompt:PromptConfirmation({
        PromptType = "Single",
        Description = "Are you sure you want to delete " .. description .. "? This cannot be undone."
    }, function(confirmed)
        if not confirmed or UnlockAll.Status ~= "active" or UnlockAll.Run ~= run then
            return
        end

        for _, entry in entries do
            UnlockAll.DeleteItem(entry.Type, entry.Name, entry.Quantity)
        end

        if onConfirm then
            onConfirm()
        end
    end)
end

function UnlockAll.PromptDelete(kind, name)
    local info = UnlockAll.ItemInfo[kind] and UnlockAll.ItemInfo[kind][name]

    UnlockAll.ConfirmDelete({{Type = kind, Name = name}}, "x1 " .. tostring(info and (info.DisplayName or info.Name) or name))
end

function UnlockAll.DeleteItem(kind, name, quantity)
    if UnlockAll.Status ~= "active" then
        return
    end

    if kind == "Emote" then
        local emote = UnlockAll.EmoteItems[name]

        if not emote then
            return
        end

        UnlockAll.Deleted.Emote[name] = true
        UnlockAll.SetFavorite("Emote", name, false, false)

        local inventory = UnlockAll.EmoteCaller and UnlockAll.EmoteCaller.Replion.Data.Inventory.Emote

        if inventory and inventory[emote.Id] then
            inventory[emote.Id] = nil

            if UnlockAll.EmoteView then
                UnlockAll.EmoteView.TriggerUpdate(emote, "Remove")
            end
        end

        for slot, equipped in UnlockAll.EquippedEmotes do
            if equipped == name then
                UnlockAll.EquippedEmotes[slot] = nil
            end
        end

        UnlockAll.UpdateEmoteWheel()
        UnlockAll.Save()

        return
    end

    local item = UnlockAll.ShopItems[kind] and UnlockAll.ShopItems[kind][name]
    local state = item and UnlockAll.ShopState[item]

    if not state then
        return
    end

    local matching = table.clone(state.ItemsMatching)

    for _ = 1, math.min(quantity or 1, #matching) do
        table.remove(matching)
    end

    UnlockAll.SetShopState(item, {ItemsMatching = matching, InDeleteMulti = 0})

    if #matching > 0 then
        UnlockAll.SetShopState(item, {ForceHide = false})
        UnlockAll.RefreshShop()

        return
    end

    UnlockAll.Deleted[kind][name] = true
    UnlockAll.SetFavorite(kind, name, false, false)
    UnlockAll.SetShopState(item, {Owns = false, Section = "Unowned", ForceHide = false})

    if kind == "Sword" and UnlockAll.Sword == name then
        UnlockAll.RestoreSword(true)
    elseif kind == "Explosion" and UnlockAll.Explosion == name then
        UnlockAll.RestoreExplosion(true)
    else
        UnlockAll.Save()
    end

    UnlockAll.RefreshShop()
end

function UnlockAll.OpenAwaken(sword)
    local data = UnlockAll.AwakenData[sword]

    if not data then
        return
    end

    UnlockAll.AwakenName = sword

    local upgrade = Util.GetPlayerGui().SecretUpgrade
    local main = upgrade.Main
    local requirement = UnlockAll.AwakenData.Requirement

    upgrade:SetAttribute("ToAwaken", nil)
    main.template1.vector.Image = data.Regular.Icon
    main.template2.vector.Image = data.Awakened.Icon
    main.template2.customs.c3.Visible = data.CustomSlash == true
    main.Progress.Fill.Size = UDim2.fromScale(1, 1)
    main.Progress.Progress.Text = requirement .. "/" .. requirement
    UnlockAll.GuiHandler:Open("SecretUpgrade")
end

function UnlockAll.AwakenSword(sword)
    local data = sword and UnlockAll.AwakenData[sword]
    local baseItem = sword and UnlockAll.ShopItems.Sword[sword]
    local awakenedItem = data and UnlockAll.ShopItems.Sword[data.Awakened.Value]
    local baseState = baseItem and UnlockAll.ShopState[baseItem]

    if UnlockAll.Status ~= "active" or not awakenedItem or not baseState or #baseState.ItemsMatching == 0 then
        return
    end

    UnlockAll.AwakenName = nil

    local remaining = table.clone(baseState.ItemsMatching)

    table.remove(remaining)

    UnlockAll.SetShopState(baseItem, {
        ItemsMatching = remaining,
        Owns = #remaining > 0,
        Section = #remaining > 0 and "Owned" or "Unowned",
        ForceHide = #remaining == 0
    })

    local awakened = data.Awakened.Value
    local matching = table.clone(UnlockAll.ShopState[awakenedItem].ItemsMatching)

    table.insert(matching, "UnlockAll:" .. awakened)
    UnlockAll.Deleted.Sword[awakened] = nil

    UnlockAll.SetShopState(awakenedItem, {
        ItemsMatching = matching,
        Owns = true,
        Section = "Owned",
        ForceHide = false
    })

    if UnlockAll.Sword == sword then
        UnlockAll.SelectSword(awakened, false)
    end

    if UnlockAll.Console then
        UnlockAll.Console.PageInfo.Sword.ItemState:Set(UnlockAll.ConsoleItems.Sword[awakened].Data)
    else
        UnlockAll.Shop:Select({type = "Sword", name = awakened, data = UnlockAll.GetSwordData(awakened)})
    end

    UnlockAll.GuiHandler:Open(UnlockAll.Console and "ControllerShop" or "Shop")
    UnlockAll.RefreshShop()
end

function UnlockAll.HookShop()
    local holder = UnlockAll.GetShopHolder()
    local info = holder and holder:FindFirstChild("InfoBG")

    if not holder or not info then
        return
    end

    local function Reapply(item)
        local state = UnlockAll.ShopState[item]

        if not state or not UnlockAll.ShopChanges[item] then
            return
        end

        for _, field in UnlockAll.ShopFields do
            if UnlockAll.GetShopState(item, field[2]) ~= state[field[1]] then
                UnlockAll.ApplyShopState(item, field[2], state[field[1]])
            end
        end

        if UnlockAll.ConsoleItems then
            UnlockAll.SyncConsoleItem(item)
        end
    end

    for _, kind in UnlockAll.Types do
        local page = UnlockAll.Shop._inventoryPages[kind]
        local markDirty = page.MarkDirty

        page.MarkDirty = function(item, ...)
            if UnlockAll.Status == "active" then
                if item then
                    Reapply(item)
                else
                    for _, virtual in UnlockAll.Shop._virtualItems[kind] do
                        Reapply(virtual)
                    end
                end
            end

            return markDirty(item, ...)
        end

        UnlockAll.Originals["MarkDirty" .. kind] = markDirty
    end

    local buyButton = info:FindFirstChild("BuyButton")

    if buyButton then
        UnlockAll.Track(buyButton.Activated:Connect(function()
            local kind, name = UnlockAll.GetSelected()

            if kind == "Sword" then
                UnlockAll.SelectSword(name)
            elseif kind == "Explosion" then
                UnlockAll.SelectExplosion(name)
            end

            task.defer(UnlockAll.RefreshShop)
        end))
    end

    UnlockAll.MakeOverlay("Favorite", holder:FindFirstChild("Favorite"), function()
        local kind, name = UnlockAll.GetSelected()

        if kind and name then
            UnlockAll.ToggleFavorite(kind, name)
            UnlockAll.RefreshShop()
        end
    end)

    UnlockAll.MakeOverlay("Delete", info:FindFirstChild("Delete"), function()
        local kind, name, item = UnlockAll.GetSelected()

        if kind and name and item and UnlockAll.ShopState[item] then
            UnlockAll.PromptDelete(kind, name)
        end
    end)

    local secretUpgrade = Util.GetPlayerGui():FindFirstChild("SecretUpgrade")
    local secretMain = secretUpgrade and secretUpgrade:FindFirstChild("Main")

    if secretMain then
        UnlockAll.MakeOverlay("AwakenOpen", info:FindFirstChild("SecretUpgrade"), function()
            local kind, name = UnlockAll.GetSelected()

            if kind == "Sword" then
                UnlockAll.OpenAwaken(name)
            end
        end)

        UnlockAll.MakeOverlay("Awaken", secretMain:FindFirstChild("Upgrade"), function()
            UnlockAll.AwakenSword(UnlockAll.AwakenName)
        end)

        if UnlockAll.Overlays.AwakenOpen then
            UnlockAll.Overlays.AwakenOpen.Visible = true
        end

        if UnlockAll.Overlays.Awaken then
            UnlockAll.Overlays.Awaken.Visible = true
        end
    end

    local equips = info:FindFirstChild("Equips")

    UnlockAll.MakeOverlay("Accessory", equips and equips:FindFirstChild("EquipAccessory"), function()
        local kind, name = UnlockAll.GetSelected()

        if kind == "Sword" and UnlockAll.Sword == name then
            UnlockAll.SetAccessory(not UnlockAll.Accessory)
        end
    end)

    UnlockAll.MakeOverlay("Finisher", equips and equips:FindFirstChild("Finisher"), function()
        local kind, name = UnlockAll.GetSelected()

        if kind == "Sword" then
            UnlockAll.SetFinisher(name, not UnlockAll.Finishers[name])
        end
    end)

    if UnlockAll.Shop.itemSelected and UnlockAll.Shop.itemSelected.Connect then
        UnlockAll.Track(UnlockAll.Shop.itemSelected:Connect(function()
            task.defer(UnlockAll.RefreshShop)
        end))
    end

    UnlockAll.HookMultiDelete(holder)
end

function UnlockAll.SyncConsoleItem(item)
    local consoleItem = UnlockAll.ConsoleItems[item.Type][item.Name]

    if not consoleItem or UnlockAll.ShopItems[item.Type][item.Name] ~= item then
        return
    end

    local state = UnlockAll.ShopState[item]
    local copies = state.ForceHide and 0 or #state.ItemsMatching

    consoleItem.Data.OwnedCopies:Set(copies)
    UnlockAll.ShopAPI:GetItemBaseOwnedState(item.Type, item.Name):SetTag("UnlockAll", copies > 0)
    UnlockAll.Console:UpdateItem(consoleItem.Data)
end

function UnlockAll.BindConsole(button, callback)
    for _, connection in getconnections(button.Activated) do
        if connection.Enabled and pcall(connection.Disable, connection) then
            UnlockAll.ConsoleConnections[#UnlockAll.ConsoleConnections + 1] = connection
        end
    end

    UnlockAll.Track(button.Activated:Connect(callback))
end

function UnlockAll.FindConsoleCancel(button)
    local variants = ReplicatedStorage.Controllers.UI.ShopControllerAPI:FindFirstChild("Variants")
    local variant = variants and variants:FindFirstChild("Console")

    if not variant or not getfenv then
        return nil
    end

    for _, connection in getconnections(button.Activated) do
        local handler = connection.Enabled and connection.Function

        if handler then
            local success, environment = pcall(getfenv, handler)

            if success and type(environment) == "table" and rawget(environment, "script") == variant then
                return connection
            end
        end
    end

    return nil
end

function UnlockAll.HookConsole()
    local api = UnlockAll.ShopAPI
    local console = api.ActiveVariant

    if not console then
        return
    end

    UnlockAll.Console = console
    UnlockAll.ConsoleItems = {Sword = {}, Explosion = {}}
    UnlockAll.ConsoleConnections = {}

    local gui = Util.GetPlayerGui()
    local main = gui.ControllerShop.Main
    local buttons = main.DeleteItems.List.Buttons

    local overrides = {
        SetEquipped = function(self, kind, id)
            if not UnlockAll.ShopItems[kind] then
                return UnlockAll.Originals.APISetEquipped(self, kind, id)
            end

            local item = UnlockAll.InventoryClient:GetItem(kind, id)
            local name = item and item.Name or id

            if not UnlockAll.ShopItems[kind][name] or UnlockAll.Deleted[kind][name] then
                return false
            end

            if kind == "Sword" then
                UnlockAll.SelectSword(name)
            else
                UnlockAll.SelectExplosion(name)
            end

            return true
        end,
        ToggleFavorited = function(self, entry)
            local kind = entry.ItemInfo.ItemType

            if not UnlockAll.ShopItems[kind] then
                return UnlockAll.Originals.APIToggleFavorited(self, entry)
            end

            UnlockAll.ToggleFavorite(kind, entry.ItemInfo.Name)

            return true
        end,
        ToggleSwordAccessory = function()
            UnlockAll.SetAccessory(not UnlockAll.Accessory)
        end,
        RequestFinisherEquip = function(_, entry)
            UnlockAll.SetFinisher(entry.Name, not UnlockAll.Finishers[entry.Name])

            return true
        end,
        ToggleSwordStyle = function()
            local info = UnlockAll.ItemInfo.Sword[UnlockAll.Sword]
            local styles = info and info.AnimationStyles[UnlockAll.Accessory and "Accessory" or "Base"]

            if styles and #styles > 0 then
                local current = table.find(styles, LocalPlayer:GetAttribute("AnimationStyle")) or 0

                LocalPlayer:SetAttribute("AnimationStyle", styles[current % #styles + 1])
            end
        end
    }

    for name, override in overrides do
        UnlockAll.Originals["API" .. name] = api[name]
        api[name] = override
    end

    local cancel = UnlockAll.FindConsoleCancel(buttons.Cancel)

    UnlockAll.ConsoleCancel = cancel

    UnlockAll.BindConsole(buttons.Delete, function()
        local entries = {}
        local total = 0
        local deleting = UnlockAll.Upvalues(console.GetDeletingItemState)[1]

        for entry, state in type(deleting) == "table" and deleting or {} do
            local count = state:Get()
            local kind = entry.ItemInfo.ItemType

            if count > 0 and UnlockAll.ShopItems[kind] then
                total += count
                entries[#entries + 1] = {Type = kind, Name = entry.ItemInfo.Name, Quantity = count}
            end
        end

        UnlockAll.ConfirmDelete(entries, "x" .. total .. " items", function()
            if cancel then
                pcall(cancel.Fire, cancel)
            end
        end)
    end)

    UnlockAll.BindConsole(main.Pages.Sword.Right.UpgradeButton, function()
        local kind, name = UnlockAll.GetSelected()

        if kind == "Sword" then
            UnlockAll.OpenAwaken(name)
        end
    end)

    UnlockAll.BindConsole(gui.SecretUpgrade.Main.Upgrade, function()
        UnlockAll.AwakenSword(UnlockAll.AwakenName)
    end)

    local run = UnlockAll.Run
    local deadline = os.clock() + 0.004

    for _, kind in UnlockAll.Types do
        for name, item in UnlockAll.ShopItems[kind] do
            local entry = table.clone(item.Item)

            if UnlockAll.ShopState[item].Virtual and kind == "Sword" then
                local info = UnlockAll.ItemInfo.Sword[name]

                entry.Finisher = info.HasFinisher or nil
                entry.Accessory = info.AccessoryUnlockable or nil
            end

            local data = api:GetItemData(kind, api:ParseItemKey(kind, entry))

            entry.Id = "UnlockAll:" .. kind .. ":" .. name
            UnlockAll.ConsoleItems[kind][name] = {Data = data, Item = entry, Favorite = data.IsFavorited:Get()}
            data.IsFavorited:Set(UnlockAll.Favorites[kind][name] == true)
            UnlockAll.SyncConsoleItem(item)

            if os.clock() >= deadline then
                RunService.Heartbeat:Wait()

                if UnlockAll.Run ~= run or UnlockAll.Status ~= "active" then
                    return
                end

                deadline = os.clock() + 0.004
            end
        end

        UnlockAll.Track(UnlockAll.InventoryClient:OnInventoryChange(kind, function()
            task.defer(function()
                if UnlockAll.Run ~= run or UnlockAll.Status ~= "active" then
                    return
                end

                for _, item in UnlockAll.ShopItems[kind] do
                    UnlockAll.SyncConsoleItem(item)
                end
            end)
        end))

        local equipped = UnlockAll[kind]

        if equipped then
            UnlockAll.SetEquipped(kind, equipped)
        end
    end
end

function UnlockAll.RestoreConsole()
    local console = UnlockAll.Console

    if not console then
        return
    end

    if UnlockAll.ConsoleCancel then
        pcall(UnlockAll.ConsoleCancel.Fire, UnlockAll.ConsoleCancel)
    end

    for _, method in {"SetEquipped", "ToggleFavorited", "ToggleSwordAccessory", "RequestFinisherEquip", "ToggleSwordStyle"} do
        UnlockAll.Restore("API" .. method, UnlockAll.ShopAPI, method)
    end

    for _, connection in UnlockAll.ConsoleConnections do
        pcall(connection.Enable, connection)
    end

    for kind, items in UnlockAll.ConsoleItems do
        for name, entry in items do
            entry.Data.OwnedCopies:Set(#UnlockAll.InventoryClient:FindItemsWithKey(kind, entry.Data.ParsedItemKey))
            entry.Data.IsFavorited:Set(entry.Favorite)
            UnlockAll.ShopAPI:GetItemBaseOwnedState(kind, name):SetTag("UnlockAll", nil)
            console:UpdateItem(entry.Data)
        end
    end

    UnlockAll.Console = nil
    UnlockAll.ConsoleItems = nil
    UnlockAll.ConsoleConnections = nil
    UnlockAll.ConsoleCancel = nil
end

function UnlockAll.PatchSwords()
    if UnlockAll.SwordsPatched then
        return
    end

    local equip = rawget(UnlockAll.Swords, "EquipSwordTo")
    local upvalues = UnlockAll.Upvalues(equip)

    if not next(upvalues) or not setupvalue then
        return
    end

    local playersIndex

    for index, upvalue in upvalues do
        if typeof(upvalue) == "Instance" and upvalue.ClassName == "Players" then
            playersIndex = index
        elseif type(upvalue) == "table"
            and type(rawget(upvalue, "cancel")) == "function"
            and type(rawget(upvalue, "begin")) == "function" then
            UnlockAll.SwordState = upvalue
        end
    end

    if not playersIndex and upvalues[3] == false and upvalues[4] == true and pcall(setupvalue, equip, 3, Players) then
        playersIndex = 3
    end

    if playersIndex and type(upvalues[playersIndex + 1]) == "boolean" then
        pcall(setupvalue, equip, playersIndex + 1, false)
    end

    UnlockAll.SwordsPatched = playersIndex ~= nil
end

function UnlockAll.GetSwordData(name)
    local data = UnlockAll.SwordData[name]

    if data then
        return data
    end

    local success, entry = pcall(UnlockAll.Swords.GetSword, UnlockAll.Swords, name)

    data = success and entry or nil

    if not data then
        local swords = ReplicatedStorage.Shared.ReplicatedInstances:FindFirstChild("Swords")
        local getter = swords and swords:FindFirstChild("GetSword")

        if getter then
            local invoked, result = pcall(getter.Invoke, getter, name)

            data = invoked and result or nil
        end
    end

    if data then
        UnlockAll.SwordData[name] = data
    end

    return data
end

function UnlockAll.HasEffect(name)
    local success, effect = pcall(UnlockAll.SwordFX.GetInstance, UnlockAll.SwordFX, name)

    return success and effect ~= nil
end

function UnlockAll.GetSlash(name)
    local data = UnlockAll.GetSwordData(name)

    if not data then
        return nil
    end

    if data.SlashName then
        UnlockAll.HasEffect(data.SlashName)

        return data.SlashName
    end

    if UnlockAll.HasEffect(name) then
        return name
    end

    local compact = (name:gsub("%s+", "")) .. "Slash"

    if UnlockAll.HasEffect(compact) then
        return compact
    end

    return "SlashEffect"
end

function UnlockAll.RemoveSwords(character, keep)
    if not character then
        return
    end

    for _, child in character:GetChildren() do
        if child:IsA("Model") and child.Name ~= keep and UnlockAll.GetSwordData(child.Name) then
            child:Destroy()
        end
    end
end

function UnlockAll.FindBlade()
    for _, connection in getconnections(UnlockAll.FireSwordInfo.OnClientEvent) do
        for _, upvalue in UnlockAll.Upvalues(connection.Function) do
            if type(upvalue) == "table" and type(rawget(upvalue, "SetSword")) == "function" then
                return upvalue
            end
        end
    end

    return nil
end

function UnlockAll.GetBlade()
    if not UnlockAll.BladeController then
        UnlockAll.BladeController = UnlockAll.FindBlade()
    end

    return UnlockAll.BladeController
end

function UnlockAll.PatchBlade(blade)
    if UnlockAll.Originals.SetSword then
        return
    end

    local original

    original = hookfunction(rawget(blade, "SetSword"), function(self, name)
        if UnlockAll.Status == "active" and UnlockAll.Sword then
            name = UnlockAll.Sword
        end

        return original(self, name)
    end)

    UnlockAll.Originals.SetSword = original
end

function UnlockAll.ApplySword(name)
    local character = UnlockAll.GetCharacter()

    if not character or not name then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 2)

    if not humanoid or humanoid.Health <= 0 or not character:FindFirstChild("HumanoidRootPart") then
        return
    end

    if UnlockAll.Sword and not UnlockAll.SavedEquipped.Sword then
        UnlockAll.Originals.EquippedSword = UnlockAll.GetRealEquipped("Sword")
        UnlockAll.SavedEquipped.Sword = true
    end

    UnlockAll.PatchSwords()

    if UnlockAll.SwordState then
        UnlockAll.SwordState.cancel(character)
    end

    if UnlockAll.Swords:EquipSwordTo(character, name) == false then
        return
    end

    UnlockAll.Slash = UnlockAll.GetSlash(name) or UnlockAll.Slash

    local blade = UnlockAll.GetBlade()

    if blade then
        pcall(UnlockAll.PatchBlade, blade)
        blade:SetSword(name)
    end

    if not UnlockAll.Accessory then
        local accessories = character:FindFirstChild("SwordAccessories")

        if accessories then
            accessories:Destroy()
        end

        task.defer(function()
            local deferred = character:FindFirstChild("SwordAccessories")

            if deferred then
                deferred:Destroy()
            end
        end)
    end

    task.defer(UnlockAll.RemoveSwords, character, name)
end

function UnlockAll.SetEquipped(kind, name)
    if not UnlockAll.SavedEquipped[kind] then
        UnlockAll.Originals["Equipped" .. kind] = UnlockAll.GetRealEquipped(kind)
        UnlockAll.SavedEquipped[kind] = true
    end

    local consoleItem = UnlockAll.ConsoleItems and UnlockAll.ConsoleItems[kind][name]
    local item = consoleItem and consoleItem.Item
        or UnlockAll.GetOwnedItem(kind, name)
        or {Name = name, Id = "UnlockAll:" .. kind .. ":" .. name}

    UnlockAll.InventoryReplion:_set({"Equipped", kind}, item)

    if UnlockAll.Shop and UnlockAll.Shop._selectedItem then
        UnlockAll.Shop:Select(UnlockAll.Shop._selectedItem, true)
    end
end

function UnlockAll.WatchSword(character)
    if not character then
        return
    end

    UnlockAll.Track(character.DescendantAdded:Connect(function(descendant)
        local sword = UnlockAll.Sword

        if UnlockAll.Status ~= "active" or not sword then
            return
        end

        local model = descendant:FindFirstAncestorOfClass("Model")

        while model and model.Parent ~= character do
            model = model:FindFirstAncestorOfClass("Model")
        end

        if not model or not model:GetAttribute("_equippedSword") or model.Name == sword then
            return
        end

        if descendant:IsA("BasePart") or descendant:IsA("Decal") then
            descendant.Transparency = 1
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
            descendant.Enabled = false
            descendant:Clear()
        elseif descendant:IsA("Beam")
            or descendant:IsA("Fire")
            or descendant:IsA("Smoke")
            or descendant:IsA("Sparkles")
            or descendant:IsA("Light") then
            descendant.Enabled = false
        end
    end))

    UnlockAll.Track(character:GetAttributeChangedSignal("CurrentlyEquippedSword"):Connect(function()
        local sword = UnlockAll.Sword

        if UnlockAll.Status == "active" and sword and character:GetAttribute("CurrentlyEquippedSword") ~= sword then
            task.defer(UnlockAll.ApplySword, sword)
        end
    end))

    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 2)

    if humanoid then
        UnlockAll.Track(humanoid.HealthChanged:Connect(function(health)
            local sword = UnlockAll.Sword

            if UnlockAll.Status == "active" and health > 0 and sword then
                task.defer(UnlockAll.ApplySword, sword)
            end
        end))
    end
end

function UnlockAll.GetCloneAnimationTypes()
    if UnlockAll.CloneAnimationTypes then
        return UnlockAll.CloneAnimationTypes
    end

    local types = {}

    for _, animation in ReplicatedStorage.Shared.SwordAPI.Collection:GetDescendants() do
        if animation:IsA("Animation") then
            for _, name in {"Idle", "Parry", "GrabParry", "SuccessParry"} do
                if animation:GetAttribute(name) then
                    local id = animation.AnimationId
                    local existing = types[id]

                    if existing == nil then
                        types[id] = name
                    else
                        types[id] = existing == name and name or false
                    end

                    break
                end
            end
        end
    end

    UnlockAll.CloneAnimationTypes = types

    return types
end

function UnlockAll.ClearCloneTracks(state)
    state.Data = nil

    for track, original in state.OriginalTracks do
        if state.Animator and state.Animator.Parent then
            track:Play(0, original.Weight, original.Speed)
        end
    end

    table.clear(state.OriginalTracks)

    for _, track in state.Tracks do
        track:Stop(0)
        track:Destroy()
    end

    table.clear(state.Tracks)
end

function UnlockAll.PlayCloneTrack(clone, track)
    local state = UnlockAll.Clones[clone]

    if not state or not state.Data or not track.IsPlaying then
        return
    end

    for _, own in state.Tracks do
        if track == own then
            return
        end
    end

    local animationType = track.Animation and UnlockAll.CloneAnimationTypes[track.Animation.AnimationId]

    if not animationType then
        return
    end

    local replacement = UnlockAll.SwordAPI:GetAnimations(clone, animationType, state.Data.AnimationType, state.Data.SwordType)[1]

    if not replacement or replacement.AnimationId == track.Animation.AnimationId then
        return
    end

    local replacementTrack = state.Tracks[replacement]

    if not replacementTrack then
        replacementTrack = state.Animator:LoadAnimation(replacement)
        state.Tracks[replacement] = replacementTrack
    end

    local weight = track.WeightTarget

    if track.Looped then
        state.OriginalTracks[track] = {Weight = weight, Speed = track.Speed}
    end

    replacementTrack.Priority = track.Priority
    replacementTrack.Looped = track.Looped
    replacementTrack:Play(0, weight, track.Speed)

    if replacementTrack.Length > 0 then
        replacementTrack.TimePosition = math.min(track.TimePosition, replacementTrack.Length)
    end

    track:Stop(0)
end

function UnlockAll.UpdateClone(clone)
    local state = UnlockAll.Clones[clone]

    if not state or state.Thread or UnlockAll.Status ~= "active" or not UnlockAll.Sword then
        return
    end

    local humanoid = clone:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

    if not animator
        or not clone:FindFirstChild("Torso")
        or not clone:FindFirstChild("Left Arm")
        or not clone:FindFirstChild("Right Arm") then
        return
    end

    if state.Model and state.Model.Parent == clone and state.Name == UnlockAll.Sword and state.Accessory == UnlockAll.Accessory then
        for _, child in clone:GetChildren() do
            if child ~= state.Model and child:GetAttribute("_equippedSword") then
                child:Destroy()
            end
        end

        return
    end

    state.Thread = task.defer(function()
        local sword = UnlockAll.Sword
        local accessory = UnlockAll.Accessory

        if not sword then
            state.Thread = nil

            return
        end

        UnlockAll.ClearCloneTracks(state)

        local data = UnlockAll.GetSwordData(sword)
        local success, model = pcall(UnlockAll.Swords.ForceEquipSwordTo, UnlockAll.Swords, clone, sword, nil, accessory)

        if UnlockAll.Clones[clone] ~= state then
            return
        end

        if not success or not model or not data then
            state.Thread = nil

            return
        end

        state.Model = model
        state.Name = sword
        state.Accessory = accessory
        state.Data = data
        state.Animator = animator

        if not state.Connections.Animation then
            state.Connections.Animation = animator.AnimationPlayed:Connect(function(track)
                UnlockAll.PlayCloneTrack(clone, track)
            end)
        end

        for _, track in animator:GetPlayingAnimationTracks() do
            UnlockAll.PlayCloneTrack(clone, track)
        end

        state.Thread = nil
        UnlockAll.UpdateClone(clone)
    end)
end

function UnlockAll.ClearClone(clone, restore)
    local state = UnlockAll.Clones[clone]

    if not state then
        return
    end

    UnlockAll.Clones[clone] = nil
    UnlockAll.Cleanup(state.Connections)
    UnlockAll.Cleanup(state.Thread)
    UnlockAll.ClearCloneTracks(state)

    if restore and state.Model and clone.Parent then
        local original = clone:GetAttribute("EquippedSword") or state.OriginalSword

        if original then
            task.defer(function()
                if clone.Parent and not UnlockAll.Clones[clone] then
                    UnlockAll.Swords:ForceEquipSwordTo(clone, original, nil, state.OriginalAccessory)
                end
            end)
        end
    end
end

function UnlockAll.WatchClone(clone)
    if UnlockAll.Status ~= "active"
        or UnlockAll.Clones[clone]
        or clone:GetAttribute("EncryptedCloneOwner") ~= LocalPlayer.Name then
        return
    end

    UnlockAll.GetCloneAnimationTypes()

    local state = {
        Connections = {},
        Tracks = {},
        OriginalTracks = {},
        OriginalSword = clone:GetAttribute("EquippedSword"),
        OriginalAccessory = clone:GetAttribute("HasAccessoryEquipped") == true
    }

    UnlockAll.Clones[clone] = state

    state.Connections.Loaded = clone.DescendantAdded:Connect(function(descendant)
        local relevant = descendant:IsA("Animator")

        if not relevant and descendant.Parent == clone then
            relevant = not state.Model or descendant:GetAttribute("_equippedSword")
        end

        if relevant then
            task.defer(UnlockAll.UpdateClone, clone)
        end
    end)

    UnlockAll.UpdateClone(clone)
end

function UnlockAll.SelectSword(name, persist)
    if not name or UnlockAll.Deleted.Sword[name] then
        return
    end

    UnlockAll.Sword = name
    UnlockAll.Slash = UnlockAll.GetSlash(name)
    UnlockAll.SetEquipped("Sword", name)
    UnlockAll.Protect("parry effects", UnlockAll.PatchParrySuccess)
    UnlockAll.Protect("parry animation", ParryAnimation.PreloadSword, LocalPlayer.Character)

    for _, clone in CollectionService:GetTagged("EncryptedClone") do
        UnlockAll.Protect("clone", UnlockAll.WatchClone, clone)
        UnlockAll.Protect("clone", UnlockAll.UpdateClone, clone)
    end

    task.defer(function()
        if UnlockAll.Status == "active" and UnlockAll.Sword == name then
            UnlockAll.ApplySword(name)
        end
    end)

    if persist ~= false then
        UnlockAll.Save()
    end
end

function UnlockAll.RestoreSword(persist)
    local default = UnlockAll.Defaults.Sword or "Base Sword"

    UnlockAll.Sword = nil
    UnlockAll.Slash = nil

    if UnlockAll.SavedEquipped.Sword then
        UnlockAll.InventoryReplion:_set({"Equipped", "Sword"}, UnlockAll.Originals.EquippedSword)
        UnlockAll.Originals.EquippedSword = nil
        UnlockAll.SavedEquipped.Sword = nil
    end

    UnlockAll.ApplySword(default)

    if persist then
        UnlockAll.Save()
    end

    for clone in UnlockAll.Clones do
        UnlockAll.ClearClone(clone, true)
    end
end

function UnlockAll.SelectExplosion(name, persist)
    if not name or UnlockAll.Deleted.Explosion[name] then
        return
    end

    UnlockAll.Explosion = name
    UnlockAll.SetEquipped("Explosion", name)
    LocalPlayer:SetAttribute("CurrentlyEquippedExplosion", name)

    local character = UnlockAll.GetCharacter()

    if character then
        character:SetAttribute("CurrentlyEquippedExplosion", name)
    end

    if persist ~= false then
        UnlockAll.Save()
    end
end

function UnlockAll.RestoreExplosion(persist)
    local default = UnlockAll.Defaults.Explosion or "Explosion Normal"

    UnlockAll.Explosion = nil

    if UnlockAll.SavedEquipped.Explosion then
        UnlockAll.InventoryReplion:_set({"Equipped", "Explosion"}, UnlockAll.Originals.EquippedExplosion)
        UnlockAll.Originals.EquippedExplosion = nil
        UnlockAll.SavedEquipped.Explosion = nil
    end

    LocalPlayer:SetAttribute("CurrentlyEquippedExplosion", default)

    local character = UnlockAll.GetCharacter()

    if character then
        character:SetAttribute("CurrentlyEquippedExplosion", default)
    end

    if persist then
        UnlockAll.Save()
    end
end

function UnlockAll.PatchExplosion()
    if not UnlockAll.VFX or UnlockAll.Originals.PlayExplosion then
        return
    end

    local original = UnlockAll.VFX.PlayExplosion

    UnlockAll.Originals.PlayExplosion = original

    UnlockAll.VFX.PlayExplosion = function(self, name, third, fourth, victim, source, flag)
        if UnlockAll.Status == "active" and flag and source == LocalPlayer.Character then
            if UnlockAll.Explosion then
                name = UnlockAll.Explosion
            end

            if UnlockAll.Sword and UnlockAll.Finishers[UnlockAll.Sword] and UnlockAll.FinishersController then
                local root = victim and victim:FindFirstChild("HumanoidRootPart")
                local alive = Workspace:FindFirstChild("Alive")
                local others = 0

                for _, character in alive and alive:GetChildren() or {} do
                    if character ~= victim then
                        others += 1
                    end
                end

                if root and alive and others <= 1 then
                    UnlockAll.FinishersController:PlayFinisher(UnlockAll.Sword, source, victim, root.CFrame, Workspace:GetServerTimeNow())
                end
            end
        end

        return original(self, name, third, fourth, victim, source, flag)
    end
end

function UnlockAll.IsMine(who)
    if tostring(who) == LocalPlayer.Name then
        return true
    end

    local model

    if type(who) == "table" then
        model = rawget(who, "Character")
    elseif typeof(who) == "Instance" then
        model = who
    end

    return typeof(model) == "Instance" and model:GetAttribute("EncryptedCloneOwner") == LocalPlayer.Name
end

function UnlockAll.PatchAll(handler)
    if UnlockAll.Patched[handler] then
        return
    end

    UnlockAll.Patched[handler] = true

    local original

    original = hookfunction(handler, function(...)
        local arguments = table.pack(...)

        if UnlockAll.Status == "active" and UnlockAll.Slash and UnlockAll.IsMine(arguments[4]) then
            arguments[1] = UnlockAll.Slash
            arguments[3] = UnlockAll.Sword
        end

        if setthreadidentity then
            setthreadidentity(2)
        end

        return original(table.unpack(arguments, 1, arguments.n))
    end)
end

function UnlockAll.PatchLocal(handler)
    if UnlockAll.Patched[handler] then
        return
    end

    UnlockAll.Patched[handler] = true

    local original

    original = hookfunction(handler, function(edge, root, blade)
        if UnlockAll.Status == "active" and UnlockAll.Slash then
            edge = UnlockAll.Slash
            blade = UnlockAll.Sword
        end

        if setthreadidentity then
            setthreadidentity(2)
        end

        return original(edge, root, blade)
    end)
end

function UnlockAll.IsParryHandler(handler)
    if type(handler) ~= "function" then
        return false
    end

    local success, info = pcall(UnlockAll.GetInfo, handler)

    return success and type(info) == "table" and info.name == "parrySuccessAll"
end

function UnlockAll.PatchParrySuccess()
    local client = UnlockAll.ParrySuccessClient

    for _, connection in getconnections(UnlockAll.ParrySuccessAll.OnClientEvent) do
        local handler = connection.Function

        if UnlockAll.IsParryHandler(handler) then
            pcall(UnlockAll.PatchAll, handler)
        end
    end

    for _, connection in getconnections(client:IsA("BindableEvent") and client.Event or client.OnClientEvent) do
        local handler = connection.Function

        if UnlockAll.IsParryHandler(handler) then
            pcall(UnlockAll.PatchLocal, handler)
        end
    end
end

function UnlockAll.StopEmote()
    if UnlockAll.EmoteTrove then
        UnlockAll.EmoteTrove:Destroy()
        UnlockAll.EmoteTrove = nil
    end

    local character = LocalPlayer.Character

    if character then
        character:SetAttribute("Emoting", nil)
    end
end

function UnlockAll.PlayEmote(name)
    local emote = UnlockAll.EmotesFolder:FindFirstChild(name)
    local character = UnlockAll.GetCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not emote or not humanoid or humanoid.MoveDirection.Magnitude > 0 then
        return
    end

    UnlockAll.StopEmote()
    UnlockAll.EmoteTrove = UnlockAll.Trove.new()
    character:SetAttribute("Emoting", emote:GetAttribute("EmoteName") or emote.Name)
    UnlockAll.EmotesShared:Play(character, UnlockAll.EmoteTrove, emote.Name, true, Workspace:GetServerTimeNow(), 1, nil, false)
end

function UnlockAll.PatchEmotes()
    if UnlockAll.Originals.EmotePlay then
        return
    end

    local play = UnlockAll.EmoteController.Play

    UnlockAll.Originals.EmotePlay = play

    UnlockAll.EmoteController.Play = function(self, name, extra)
        local emote = UnlockAll.Status == "active" and name and UnlockAll.EmotesFolder:FindFirstChild(name)

        if emote and emote.AnimationId ~= "" and emote.AnimationId ~= "rbxassetid://0" then
            return UnlockAll.PlayEmote(name)
        end

        return play(self, name, extra)
    end

    for _, method in {"UpdateHolderEmotes", "UpdateMenuContentEmotes"} do
        local original = UnlockAll.EmoteWheel[method]

        UnlockAll.Originals[method] = original

        UnlockAll.EmoteWheel[method] = function(self, ...)
            local result = original(self, ...)

            if UnlockAll.Status == "active" then
                UnlockAll.RefreshEmotes()
            end

            return result
        end
    end
end

function UnlockAll.GetEmoteSlot()
    local wheel = UnlockAll.EmoteWheel

    if wheel.type == "Menu" then
        return math.clamp(tonumber(wheel.selected) or 1, 1, 24)
    end

    return math.clamp(tonumber(wheel.selected) or UnlockAll.SelectedSlot or 1, 1, 8) + ((tonumber(wheel.page) or 1) - 1) * 8
end

function UnlockAll.SetEmoteButton(slot, name)
    local emote = UnlockAll.EmotesFolder:FindFirstChild(name)

    if not emote then
        return
    end

    local displayName = emote:GetAttribute("EmoteName") or emote.Name
    local icon = emote:GetAttribute("Icon") or ""
    local wheelGui = Util.GetPlayerGui():FindFirstChild("EmoteWheel")
    local wheel = wheelGui and wheelGui:FindFirstChild("Wheel")
    local menu = wheelGui and wheelGui:FindFirstChild("Menu")
    local holder = wheel and wheel:FindFirstChild("Holder")
    local content = menu and menu:FindFirstChild("Content")
    local onPage = math.floor((slot - 1) / 8) + 1 == (tonumber(UnlockAll.EmoteWheel.page) or 1)
    local wheelSlot = onPage and holder and holder:FindFirstChild(tostring((slot - 1) % 8 + 1))
    local menuSlot = content and content:FindFirstChild(tostring(slot))

    local function Fill(button)
        button:SetAttribute("EmoteId", name)
        button:SetAttribute("EmoteName", displayName)

        local vector = button:FindFirstChild("Vector")

        if vector then
            vector.Image = icon
        elseif button:IsA("ImageButton") then
            button.Image = icon
        end

        local label = button:FindFirstChild("Title") or button:FindFirstChild("ItemName") or button:FindFirstChild("Text")

        if label and label:IsA("TextLabel") then
            label.Text = displayName
        end
    end

    if wheelSlot then
        Fill(wheelSlot)
    end

    if menuSlot then
        Fill(menuSlot)
    end
end

function UnlockAll.RefreshEmotes()
    for slot, name in UnlockAll.EquippedEmotes do
        UnlockAll.SetEmoteButton(tonumber(slot) or slot, name)
    end
end

function UnlockAll.UpdateEmoteWheel()
    local wheel = UnlockAll.EmoteWheel
    local updateHolder = UnlockAll.Originals.UpdateHolderEmotes
    local updateMenu = UnlockAll.Originals.UpdateMenuContentEmotes

    if updateHolder then
        updateHolder(wheel)
    else
        wheel:UpdateHolderEmotes()
    end

    if updateMenu then
        updateMenu(wheel)
    else
        wheel:UpdateMenuContentEmotes()
    end

    wheel:updateCenterText()
    UnlockAll.RefreshEmotes()
end

function UnlockAll.ApplyEmote(slot, name)
    local index = tonumber(slot) or UnlockAll.GetEmoteSlot()

    if not name or UnlockAll.Deleted.Emote[name] or not UnlockAll.EmotesFolder:FindFirstChild(name) then
        return
    end

    UnlockAll.SelectedSlot = index
    UnlockAll.EquippedEmotes[index] = name
    UnlockAll.UpdateEmoteWheel()
    UnlockAll.Save()
end

function UnlockAll.GetEmoteScroller()
    if UnlockAll.EmoteContainer then
        return UnlockAll.EmoteContainer
    end

    local wheelGui = Util.GetPlayerGui():FindFirstChild("EmoteWheel")
    local list = wheelGui and wheelGui:FindFirstChild("List")

    return list and list:FindFirstChild("Content")
end

function UnlockAll.LoadEmotes()
    local inventory = UnlockAll.InventoryClient:GetInventory().Emote or {}

    if UnlockAll.EmoteCatalogLoaded then
        return inventory
    end

    table.clear(UnlockAll.EmoteItems)
    table.clear(UnlockAll.EmoteItemsList)
    table.clear(UnlockAll.EmoteDisplays)
    table.clear(UnlockAll.EmoteItemKeys)

    local owned = {}

    for _, item in inventory do
        if not UnlockAll.IsUnlockItem(item) then
            owned[item.Name] = true
        end
    end

    local deadline = os.clock() + 0.001

    for _, animation in UnlockAll.EmotesFolder:GetChildren() do
        local info = UnlockAll.ItemInfo.Emote[animation.Name]

        if animation:IsA("Animation") and info then
            UnlockAll.EmoteDisplays[info.DisplayName or info.Name] = animation.Name

            if not owned[animation.Name]
                and type(info.Icon) == "string"
                and info.Icon ~= ""
                and info.Icon ~= "rbxassetid://0"
                and info.Icon ~= animation.AnimationId then
                local item = {Name = animation.Name, Id = "UnlockAll:Emote:" .. animation.Name, CreatedAt = 0}

                UnlockAll.EmoteItems[animation.Name] = item
                UnlockAll.EmoteItemsList[#UnlockAll.EmoteItemsList + 1] = item
                UnlockAll.EmoteItemKeys[UnlockAll.InventoryShared:ItemToKey("Emote", item, {"Id"})] = item.Id
            end
        end

        if os.clock() >= deadline then
            RunService.Heartbeat:Wait()
            deadline = os.clock() + 0.001
        end
    end

    UnlockAll.EmoteCatalogLoaded = true

    return inventory
end

function UnlockAll.FillEmoteInventory()
    if UnlockAll.EmotesReady or UnlockAll.EmoteBuilding or not UnlockAll.EmoteView then
        return
    end

    UnlockAll.EmoteBuilding = true
    UnlockAll.EmoteBuildToken += 1

    local token = UnlockAll.EmoteBuildToken

    task.spawn(function()
        local list = UnlockAll.EmoteItemsList
        local inventory = UnlockAll.EmoteInventory
        local index = UnlockAll.EmoteBuildIndex

        while index <= #list and UnlockAll.EmoteBuildToken == token do
            local deadline = os.clock() + 0.001

            repeat
                local emote = list[index]

                if not inventory[emote.Id] and not UnlockAll.Deleted.Emote[emote.Name] then
                    inventory[emote.Id] = emote
                    UnlockAll.EmoteView.TriggerUpdate(emote, "Insert")
                end

                index += 1
            until index > #list or os.clock() >= deadline

            UnlockAll.EmoteBuildIndex = index

            if index <= #list then
                RunService.Heartbeat:Wait()
            end
        end

        if UnlockAll.EmoteBuildToken == token then
            UnlockAll.EmoteBuilding = false
            UnlockAll.EmotesReady = index > #list
        end
    end)
end

function UnlockAll.PatchInventory(inventory)
    if UnlockAll.Originals.CreateInventory then
        return
    end

    local source = UnlockAll.EmoteSource

    if not source or not source.Parent then
        local wheelGui = Util.GetPlayerGui():FindFirstChild("EmoteWheel")
        local list = wheelGui and wheelGui:FindFirstChild("List")

        source = list and list:FindFirstChild("Content")
        UnlockAll.EmoteSource = source
    end

    if not source then
        return
    end

    if not UnlockAll.EmoteContainer then
        local archivable = {}

        for _, descendant in source:GetDescendants() do
            if descendant:IsA("GuiButton") then
                archivable[descendant] = descendant.Archivable
                descendant.Archivable = false
            end
        end

        UnlockAll.EmoteContainer = source:Clone()

        for button, value in archivable do
            button.Archivable = value
        end

        local replion = UnlockAll.InventoryShared.CreateFakeReplion()

        UnlockAll.EmoteContainer.Name = "UnlockAllContent"
        UnlockAll.EmoteContainer.Visible = false
        UnlockAll.EmoteInventory = table.clone(inventory)
        replion.Data = {Inventory = {Emote = UnlockAll.EmoteInventory}}
        UnlockAll.EmoteCaller = {Replion = replion}
    end

    local client = UnlockAll.InventoryClient
    local originalFind = client.FindItemsWithKey
    local originalGet = client.GetItem

    UnlockAll.Originals.EmoteFindItemsWithKey = originalFind
    UnlockAll.Originals.EmoteGetItem = originalGet

    client.FindItemsWithKey = function(self, kind, key, ...)
        local id = kind == "Emote" and UnlockAll.EmoteItemKeys[key]

        if UnlockAll.Status == "active" and id then
            return {id}
        end

        return originalFind(self, kind, key, ...)
    end

    client.GetItem = function(self, kind, id, ...)
        if UnlockAll.Status == "active" and type(kind) == "string" and type(id) == "string" then
            if kind == "Emote" then
                local name = id:match("^UnlockAll:Emote:(.+)$")
                local emote = name and UnlockAll.EmoteItems[name]

                if emote then
                    return emote
                end
            end

            local consoleKind = UnlockAll.ConsoleItems and UnlockAll.ConsoleItems[kind]
            local name = consoleKind and id:match("^UnlockAll:" .. kind .. ":(.+)$")

            if name and consoleKind[name] then
                return consoleKind[name].Item
            end
        end

        return originalGet(self, kind, id, ...)
    end

    local container = UnlockAll.EmoteContainer

    container.Position = source.Position
    container.Size = source.Size
    container.Active = source.Active
    container.Visible = false
    container.Parent = source.Parent
    UnlockAll.EmoteOriginal = source
    UnlockAll.OriginalPosition = source.Position
    UnlockAll.OriginalSize = source.Size
    UnlockAll.OriginalActive = source.Active
    UnlockAll.OriginalVisible = source.Visible
    source.Visible = false
    source.Position = UDim2.fromOffset(-100000, -15)
    source.Active = false

    local controller = UnlockAll.InventoryController
    local createInventory = controller.CreateInventory

    UnlockAll.Originals.CreateInventory = createInventory

    controller.CreateInventory = function(self, options)
        if UnlockAll.Status ~= "active" or options.InventoryType ~= "Emote" then
            return createInventory(self, options)
        end

        local patched = table.clone(options)
        local onSlotCreated = patched.OnSlotCreated

        patched.Caller = UnlockAll.EmoteCaller
        patched.Container = UnlockAll.EmoteContainer
        patched.WatchOnChange = false

        patched.FindItemsWithKey = function(kind, key)
            local id = kind == "Emote" and UnlockAll.EmoteItemKeys[key]

            if id then
                return UnlockAll.EmoteInventory[id] and {id} or {}
            end

            return UnlockAll.InventoryShared:FindItemsWithKey(UnlockAll.EmoteCaller, kind, key)
        end

        patched.OnSlotCreated = function(view, item, slot, button, trove)
            if onSlotCreated then
                onSlotCreated(view, item, slot, button, trove)
            end

            if item and item.Name and button and trove then
                if UnlockAll.EmoteItems[item.Name] then
                    UnlockAll.DisconnectAll(button.Activated)
                end

                trove:Add(button.Activated:Connect(function()
                    task.defer(UnlockAll.ApplyEmote, UnlockAll.GetEmoteSlot(), item.Name)
                end))
            end
        end

        UnlockAll.EmoteView = createInventory(self, patched)

        return UnlockAll.EmoteView
    end

    if not UnlockAll.EmoteView then
        local known = {}
        local searchFrame = source.Parent:FindFirstChild("SearchFrame")

        if searchFrame then
            known[searchFrame.Search.MouseButton1Click] = {}
            known[searchFrame.SearchBG.SearchInput.FocusLost] = {}

            for signal, handlers in known do
                for _, connection in getconnections(signal) do
                    if connection.Function then
                        handlers[connection.Function] = true
                    end
                end
            end
        end

        local createSortOptions = controller.CreateSortOptions

        controller.CreateSortOptions = function() end

        local success, err = pcall(UnlockAll.EmoteWheel.populateEmoteList, UnlockAll.EmoteWheel)

        controller.CreateSortOptions = createSortOptions

        if not success then
            warn("[Unlock All] emote list failed: " .. tostring(err))
        end

        for signal, handlers in known do
            for _, connection in getconnections(signal) do
                if next(handlers) and connection.Function and not handlers[connection.Function] then
                    pcall(connection.Disconnect, connection)
                end
            end
        end
    end

    container.Visible = true
    UnlockAll.FillEmoteInventory()
end

function UnlockAll.RestoreInventory(full)
    UnlockAll.EmoteBuildToken += 1
    UnlockAll.EmoteBuilding = false
    UnlockAll.EmoteBuildIndex = 1
    UnlockAll.EmotesReady = false
    UnlockAll.Restore("CreateInventory", UnlockAll.InventoryController)
    UnlockAll.Restore("EmoteFindItemsWithKey", UnlockAll.InventoryClient, "FindItemsWithKey")
    UnlockAll.Restore("EmoteGetItem", UnlockAll.InventoryClient, "GetItem")
    UnlockAll.Cleanup(UnlockAll.ButtonConnections)
    table.clear(UnlockAll.ButtonConnections)

    if UnlockAll.EmoteContainer then
        UnlockAll.EmoteContainer.Visible = false
        UnlockAll.EmoteContainer.Parent = nil
    end

    if UnlockAll.EmoteOriginal then
        UnlockAll.EmoteOriginal.Position = UnlockAll.OriginalPosition
        UnlockAll.EmoteOriginal.Size = UnlockAll.OriginalSize
        UnlockAll.EmoteOriginal.Active = UnlockAll.OriginalActive
        UnlockAll.EmoteOriginal.Visible = UnlockAll.OriginalVisible
        UnlockAll.EmoteOriginal = nil
        UnlockAll.OriginalPosition = nil
        UnlockAll.OriginalSize = nil
        UnlockAll.OriginalActive = nil
        UnlockAll.OriginalVisible = nil
    end

    if not full then
        return
    end

    if UnlockAll.EmoteView then
        UnlockAll.EmoteView.Destroy()
        UnlockAll.EmoteView = nil
    end

    if UnlockAll.EmoteCaller then
        UnlockAll.EmoteCaller.Replion:Destroy()
        UnlockAll.EmoteCaller = nil
    end

    if UnlockAll.EmoteContainer then
        UnlockAll.EmoteContainer:Destroy()
        UnlockAll.EmoteContainer = nil
    end

    UnlockAll.EmoteSource = nil
    UnlockAll.EmoteInventory = nil
    UnlockAll.EmoteCatalogLoaded = false
end

function UnlockAll.BindEmoteCard(card)
    local connections = UnlockAll.ButtonConnections[card]

    if connections then
        UnlockAll.Cleanup(connections)
        UnlockAll.ButtonConnections[card] = nil
    end

    if UnlockAll.Status ~= "active" or not card.Parent then
        return
    end

    local label = card:FindFirstChild("ItemName")
    local name = label and UnlockAll.EmoteDisplays[label.Text]

    if not name or not UnlockAll.EmoteItems[name] then
        return
    end

    local favorite = card:FindFirstChild("Favorite")
    local delete = card:FindFirstChild("Delete")
    local bound = {}

    if favorite then
        UnlockAll.DisconnectAll(favorite.Activated)

        bound[#bound + 1] = favorite.Activated:Connect(function()
            UnlockAll.ToggleFavorite("Emote", name)
        end)
    end

    if delete then
        UnlockAll.DisconnectAll(delete.Activated)

        bound[#bound + 1] = delete.Activated:Connect(function()
            UnlockAll.PromptDelete("Emote", name)
        end)
    end

    UnlockAll.ButtonConnections[card] = bound
end

function UnlockAll.HookEmoteCard(card)
    if UnlockAll.Status ~= "active"
        or UnlockAll.CardConnections[card]
        or not card:IsA("GuiButton")
        or not card:FindFirstChild("ItemName") then
        return
    end

    UnlockAll.CardConnections[card] = card.ItemName:GetPropertyChangedSignal("Text"):Connect(function()
        task.defer(UnlockAll.BindEmoteCard, card)
    end)

    task.defer(UnlockAll.BindEmoteCard, card)
end

function UnlockAll.HookEmotes()
    local scroller = UnlockAll.GetEmoteScroller()

    if not scroller then
        return
    end

    for _, descendant in scroller:GetDescendants() do
        UnlockAll.HookEmoteCard(descendant)
    end

    UnlockAll.Track(scroller.DescendantAdded:Connect(function(descendant)
        task.defer(UnlockAll.HookEmoteCard, descendant)
    end))
end

function UnlockAll.WatchEmotes(character)
    local humanoid = character and (character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 2))

    if not humanoid then
        return
    end

    UnlockAll.Track(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if humanoid.MoveDirection ~= Vector3.zero and UnlockAll.EmoteTrove then
            UnlockAll.StopEmote()
        end
    end))
end

function UnlockAll.RestoreEmotes()
    table.clear(UnlockAll.EquippedEmotes)
    UnlockAll.StopEmote()
    UnlockAll.EmoteWheel:UpdateHolderEmotes()
    UnlockAll.EmoteWheel:UpdateMenuContentEmotes()
end

function UnlockAll.IsKnownItem(kind, name)
    local info = UnlockAll.ItemInfo[kind]

    return not info or info[name] ~= nil
end

function UnlockAll.SaveDefaults()
    local character = LocalPlayer.Character

    UnlockAll.Defaults.Sword = character and character:GetAttribute("CurrentlyEquippedSword")
        or LocalPlayer:GetAttribute("CurrentlyEquippedSword")
        or "Base Sword"
    UnlockAll.Defaults.Explosion = LocalPlayer:GetAttribute("CurrentlyEquippedExplosion")
        or character and character:GetAttribute("CurrentlyEquippedExplosion")
        or "Explosion Normal"
    UnlockAll.Defaults.Accessory = LocalPlayer:GetAttribute("ShowSwordAccessory") == true
end

function UnlockAll.ApplySaved()
    local data = UnlockAll.GetData()
    local sword = tostring(data.Sword or "")
    local explosion = tostring(data.Explosion or "")
    local emotes = type(data.Emotes) == "table" and data.Emotes or {}
    local finishers = type(data.Finishers) == "table" and data.Finishers or {}

    sword = UnlockAll.AwakenBase[sword] or sword
    UnlockAll.Accessory = data.Accessory == true
    LocalPlayer:SetAttribute("ShowSwordAccessory", UnlockAll.Accessory)

    if sword ~= ""
        and UnlockAll.IsKnownItem("Sword", sword)
        and (not UnlockAll.ShopActive or UnlockAll.ShopItems.Sword[sword]) then
        UnlockAll.SelectSword(sword, false)
    end

    if explosion ~= ""
        and UnlockAll.IsKnownItem("Explosion", explosion)
        and (not UnlockAll.ShopActive or UnlockAll.ShopItems.Explosion[explosion]) then
        UnlockAll.SelectExplosion(explosion, false)
    end

    table.clear(UnlockAll.EquippedEmotes)

    local owned = {}

    for _, item in UnlockAll.InventoryClient:GetInventory().Emote or {} do
        owned[item.Name] = true
    end

    for key, name in emotes do
        local slot = tonumber(key)

        if slot and type(name) == "string" and (owned[name] or UnlockAll.EmoteItems[name]) then
            UnlockAll.EquippedEmotes[slot] = name
        end
    end

    table.clear(UnlockAll.Finishers)

    for name, enabled in finishers do
        if enabled == true then
            UnlockAll.Finishers[name] = true

            if UnlockAll.DataReplion then
                local path = {"Finishers", "Equipped", name}

                UnlockAll.DefaultFinishers[name] = UnlockAll.DataReplion:Get(path) == true
                UnlockAll.DataReplion:_set(path, true)
            end
        end
    end

    UnlockAll.UpdateEmoteWheel()
end

function UnlockAll.Protect(name, callback, ...)
    local success, result = pcall(callback, ...)

    if not success then
        warn("[Unlock All] " .. name .. " failed: " .. tostring(result))
    end

    return success, result
end

function UnlockAll.Start()
    while UnlockAll.Status == "stopping" do
        task.wait()
    end

    if UnlockAll.Status or not UnlockAll.Enabled then
        return
    end

    UnlockAll.Status = "starting"
    UnlockAll.Run += 1

    local run = UnlockAll.Run
    local success, loaded, reason = pcall(UnlockAll.Load)

    if UnlockAll.Run ~= run then
        return
    end

    if not success or not loaded then
        UnlockAll.Status = nil
        UnlockAll.Fail(success and reason or tostring(loaded))

        return
    end

    local startTime = os.clock()

    while UnlockAll.Enabled and UnlockAll.Run == run do
        local checked, ready = pcall(UnlockAll.IsReady)

        if checked and ready then
            break
        end

        if os.clock() - startTime > UnlockAll.ReadyTimeout then
            if UnlockAll.Run == run then
                UnlockAll.Status = nil
                UnlockAll.Fail("Shop data did not load")
            end

            return
        end

        task.wait(0.2)
    end

    if not UnlockAll.Enabled or UnlockAll.Run ~= run then
        if UnlockAll.Run == run then
            UnlockAll.Status = nil
        end

        return
    end

    UnlockAll.Status = "active"

    local function Active()
        return UnlockAll.Run == run and UnlockAll.Status == "active"
    end

    for _, deleted in UnlockAll.Deleted do
        table.clear(deleted)
    end

    table.clear(UnlockAll.EquippedEmotes)
    table.clear(UnlockAll.SavedEquipped)
    table.clear(UnlockAll.Finishers)
    table.clear(UnlockAll.DefaultFinishers)

    UnlockAll.Accessory = false
    UnlockAll.Originals.EquippedSword = nil
    UnlockAll.Originals.EquippedExplosion = nil

    UnlockAll.Protect("favorites", UnlockAll.LoadFavorites)
    UnlockAll.Protect("defaults", UnlockAll.SaveDefaults)

    local emotesLoaded, inventory = pcall(UnlockAll.LoadEmotes)

    if not Active() then
        return
    end

    if emotesLoaded then
        UnlockAll.Protect("emote inventory", UnlockAll.PatchInventory, inventory)
        UnlockAll.Protect("emote cards", UnlockAll.HookEmotes)
        UnlockAll.Protect("emote playback", UnlockAll.PatchEmotes)
    else
        warn("[Unlock All] emote catalog failed: " .. tostring(inventory))
    end

    UnlockAll.Protect("explosion", UnlockAll.PatchExplosion)
    UnlockAll.Protect("parry effects", UnlockAll.PatchParrySuccess)
    UnlockAll.Protect("saved selection", UnlockAll.ApplySaved)

    if not Active() then
        return
    end

    task.spawn(function()
        while Active() do
            task.wait(0.5)

            if Active() and UnlockAll.Slash then
                pcall(UnlockAll.PatchParrySuccess)
            end
        end
    end)

    local character = LocalPlayer.Character

    UnlockAll.Protect("sword watch", UnlockAll.WatchSword, character)

    UnlockAll.Track(CollectionService:GetInstanceAddedSignal("EncryptedClone"):Connect(UnlockAll.WatchClone))

    UnlockAll.Track(CollectionService:GetInstanceRemovedSignal("EncryptedClone"):Connect(function(clone)
        UnlockAll.ClearClone(clone, true)
    end))

    for _, clone in CollectionService:GetTagged("EncryptedClone") do
        UnlockAll.Protect("clone", UnlockAll.WatchClone, clone)
    end

    UnlockAll.Protect("emote watch", UnlockAll.WatchEmotes, character)

    if not Active() then
        return
    end

    UnlockAll.Track(LocalPlayer:GetAttributeChangedSignal("CurrentlyEquippedSword"):Connect(function()
        local sword = UnlockAll.Sword

        if UnlockAll.Status == "active" and sword and LocalPlayer:GetAttribute("CurrentlyEquippedSword") ~= sword then
            task.defer(UnlockAll.ApplySword, sword)
        end
    end))

    UnlockAll.Track(LocalPlayer.CharacterAdded:Connect(function(spawned)
        UnlockAll.Protect("sword watch", UnlockAll.WatchSword, spawned)
        UnlockAll.Protect("emote watch", UnlockAll.WatchEmotes, spawned)

        task.delay(1, function()
            if UnlockAll.Run == run
                and UnlockAll.Status == "active"
                and LocalPlayer.Character == spawned
                and UnlockAll.Sword then
                UnlockAll.ApplySword(UnlockAll.Sword)

                if UnlockAll.Explosion then
                    LocalPlayer:SetAttribute("CurrentlyEquippedExplosion", UnlockAll.Explosion)
                    spawned:SetAttribute("CurrentlyEquippedExplosion", UnlockAll.Explosion)
                end
            end
        end)
    end))

    if not Active() then
        return
    end

    local activated, completed = UnlockAll.Protect("shop", UnlockAll.ActivateShop)

    if not activated or not completed or not Active() then
        return
    end

    UnlockAll.Protect("favorites", UnlockAll.ApplyFavorites)
    UnlockAll.Protect("shop hooks", UnlockAll.HookShop)
    UnlockAll.Protect("console", UnlockAll.HookConsole)
end

function UnlockAll.RestoreHooks()
    local shop = UnlockAll.Shop

    UnlockAll.Restore("UpdateMultiDelete", shop, "_updateMultiDelete")
    UnlockAll.Restore("CanDelete", shop, "_canDelete")

    for _, kind in UnlockAll.Types do
        UnlockAll.Restore("MarkDirty" .. kind, shop._inventoryPages[kind], "MarkDirty")
    end

    UnlockAll.Restore("PlayExplosion", UnlockAll.VFX)
    UnlockAll.Restore("EmotePlay", UnlockAll.EmoteController, "Play")
    UnlockAll.Restore("UpdateHolderEmotes", UnlockAll.EmoteWheel)
    UnlockAll.Restore("UpdateMenuContentEmotes", UnlockAll.EmoteWheel)
end

function UnlockAll.RestoreFinishers()
    for sword, default in UnlockAll.DefaultFinishers do
        if UnlockAll.DataReplion then
            UnlockAll.DataReplion:_set({"Finishers", "Equipped", sword}, default == true)
        end
    end

    table.clear(UnlockAll.Finishers)
    table.clear(UnlockAll.DefaultFinishers)
end

function UnlockAll.Stop()
    local previous = UnlockAll.Status

    UnlockAll.Run += 1

    if previous == "starting" then
        UnlockAll.Status = nil
    end

    if previous ~= "active" then
        return
    end

    UnlockAll.Status = "stopping"
    UnlockAll.Protect("hooks", UnlockAll.RestoreHooks)
    UnlockAll.Protect("multi delete", UnlockAll.CloseMultiDelete)
    UnlockAll.Cleanup(UnlockAll.Connections)
    table.clear(UnlockAll.Connections)
    UnlockAll.Cleanup(UnlockAll.CardConnections)
    table.clear(UnlockAll.CardConnections)
    UnlockAll.Protect("console", UnlockAll.RestoreConsole)
    UnlockAll.Protect("overlays", UnlockAll.DestroyOverlays)
    UnlockAll.Protect("emote inventory", UnlockAll.RestoreInventory)
    UnlockAll.Protect("shop", UnlockAll.RestoreShop)
    UnlockAll.Protect("favorites", UnlockAll.RestoreFavorites)
    LocalPlayer:SetAttribute("ShowSwordAccessory", UnlockAll.Defaults.Accessory == true)
    UnlockAll.Protect("finishers", UnlockAll.RestoreFinishers)
    UnlockAll.Protect("sword", UnlockAll.RestoreSword)
    UnlockAll.Protect("explosion", UnlockAll.RestoreExplosion)
    UnlockAll.Protect("emotes", UnlockAll.RestoreEmotes)
    UnlockAll.Sword = nil
    UnlockAll.Explosion = nil
    UnlockAll.Status = nil
end

function UnlockAll.SetEnabled(enabled)
    enabled = enabled == true
    Config.unlock_all = enabled
    UnlockAll.Enabled = enabled

    if enabled then
        task.defer(UnlockAll.Start)
    else
        UnlockAll.Stop()
    end
end

getgenv().UnlockAll = UnlockAll

local BallEsp = {
    Enabled = false,
    Gui = nil,
    Fields = nil,
    Module = nil,
    FieldCheckboxes = nil,
    LastUpdate = -math.huge,
    Interval = 0.05,
    FieldKeys = {
        Distance = "ball_esp_distance",
        Velocity = "ball_esp_velocity",
        Target = "ball_esp_target"
    }
}

function BallEsp.HasFields()
    for _, configKey in pairs(BallEsp.FieldKeys) do
        if Config[configKey] == true then
            return true
        end
    end

    return false
end

function BallEsp.ApplyFields()
    if not BallEsp.Fields then
        return
    end

    for fieldName, configKey in pairs(BallEsp.FieldKeys) do
        BallEsp.Fields[fieldName]:set_visible(Config[configKey] == true)
    end
end

function BallEsp.CreateWatermark()
    BallEsp.Gui = Window:create_watermark({
        flag = "ball_esp"
    })

    BallEsp.Fields = {
        Distance = BallEsp.Gui:create_field({title = "Distance", value = "--"}),
        Velocity = BallEsp.Gui:create_field({title = "Velocity", value = "--"}),
        Target = BallEsp.Gui:create_field({title = "Target", value = "--"})
    }

    BallEsp.ApplyFields()
end

function BallEsp.EnableAllFields()
    for _, configKey in pairs(BallEsp.FieldKeys) do
        Config[configKey] = true
    end

    if BallEsp.FieldCheckboxes then
        for _, fieldCheckbox in pairs(BallEsp.FieldCheckboxes) do
            fieldCheckbox:change_state(true)
        end
    end
end

function BallEsp.OnFieldsChanged()
    if BallEsp.HasFields() then
        BallEsp.ApplyFields()
        return
    end

    if UiReady then
        Notify("Ball ESP", "All fields are disabled, so Ball ESP will turn off.", "eye")
    end

    if BallEsp.Module and BallEsp.Module._state then
        BallEsp.Module:change_state(false)
    end
end

function BallEsp.Step()
    local currentTime = os.clock()

    if currentTime - BallEsp.LastUpdate < BallEsp.Interval then
        return
    end

    BallEsp.LastUpdate = currentTime

    local ball = Util.GetBall()
    local character = LocalPlayer.Character
    local rootPart = character and character.PrimaryPart
    local distance = "--"
    local speed = "--"
    local target = "--"

    if ball then
        local zoomies = ball:FindFirstChild("zoomies")
        local velocity = zoomies and zoomies.VectorVelocity or ball.AssemblyLinearVelocity

        speed = math.floor(velocity.Magnitude + 0.5)
        target = Backwards.GetTargetName(ball) or "None"

        if rootPart then
            distance = math.floor((ball.Position - rootPart.Position).Magnitude + 0.5)
        end
    end

    BallEsp.Fields.Distance:set_value(distance)
    BallEsp.Fields.Velocity:set_value(speed)
    BallEsp.Fields.Target:set_value(target)
end

function BallEsp.SetEnabled(enabled)
    if enabled == BallEsp.Enabled then
        return
    end

    BallEsp.Enabled = enabled
    Disconnect("BallEsp")

    if enabled then
        BallEsp.CreateWatermark()
        BallEsp.LastUpdate = -math.huge
        ActiveConnections.BallEsp = RunService.Heartbeat:Connect(BallEsp.Step)
    else
        BallEsp.Gui:destroy()
        BallEsp.Gui = nil
        BallEsp.Fields = nil
    end
end

local function AddCheckbox(module, title, flag, configKey, onChange)
    InitializeFlag(flag, Config[configKey] == true)

    return module:create_checkbox({
        title = title,
        flag = flag,
        callback = function(enabled)
            Config[configKey] = enabled

            if onChange then
                onChange(enabled)
            end
        end
    })
end

local function AddDropdown(module, title, flag, configKey, options, onChange)
    InitializeFlag(flag, Config[configKey] or options[1])

    return module:create_dropdown({
        title = title,
        flag = flag,
        options = options,
        multi_dropdown = false,
        maximum_options = #options,
        callback = function(value)
            Config[configKey] = value

            if onChange then
                onChange(value)
            end
        end
    })
end

task.spawn(function()
    local parrySuccessAll = Util.WaitForRemote("ParrySuccessAll", 30)

    if parrySuccessAll then
        parrySuccessAll.OnClientEvent:Connect(Parry.OnParrySuccessAll)
    end
end)

task.spawn(function()
    local cooldownRemote = Util.WaitForRemote("VisualCD", 30)
    local successRemote = Util.WaitForRemote("ParrySuccess", 30)

    if cooldownRemote and successRemote then
        cooldownRemote.OnClientEvent:Connect(Parry.OnCooldown)
        successRemote.OnClientEvent:Connect(Parry.OnSuccess)
        Parry.EventsReady = true
    end
end)

for _, folderName in {"Balls", "TrainingBalls"} do
    task.spawn(function()
        local ballsFolder = Workspace:WaitForChild(folderName, 30)

        if not ballsFolder then
            return
        end

        ballsFolder.ChildAdded:Connect(Util.InvalidateBalls)

        ballsFolder.ChildRemoved:Connect(function(ball)
            Timing.Forget(ball)
            Spam.Clear()
            Util.InvalidateBalls()
        end)
    end)
end

InitializeFlag("autoparry", Config.auto_parry == true)

local TriggerbotModule

local function SwitchExclusive(enabled, otherModule)
    if enabled and otherModule and otherModule._state then
        otherModule:change_state(false)
    end
end

local AutoParryModule = CombatTab:create_module({
    title = "Auto Parry",
    description = "",
    flag = "autoparry",
    section = "left",
    callback = function(enabled)
        Parry.SetEnabled(enabled)
        SwitchExclusive(enabled, TriggerbotModule)
    end
})

Parry.SetAccuracy(Config.accuracy or 100)

AutoParryModule:create_slider({
    title = "Parry Accuracy",
    flag = "_ap_accuracy",
    value = Config.accuracy or 100,
    minimum_value = 1,
    maximum_value = 100,
    decimals = 0,
    callback = Parry.SetAccuracy
})

local CurveModeDropdown = AddDropdown(
    AutoParryModule,
    "Curve Mode",
    "_ap_curvemode",
    "curve_method",
    {"camera", "dot", "backwards", "slow", "random"}
)

AddDropdown(AutoParryModule, "Parry Method", "_ap_parrymethod", "parry_method", ParryController.Methods)
AddDropdown(AutoParryModule, "Target", "_ap_target", "parry_target", {"Same", "Random"})

AddCheckbox(AutoParryModule, "Curve Hotkey", "_ap_curvehotkey", "curve_keybind")
AddCheckbox(AutoParryModule, "Curve Notification", "_ap_curvenotif", "curve_notify")
AddCheckbox(AutoParryModule, "Console Logs", "_ap_curveconsole", "curve_console")
AddCheckbox(AutoParryModule, "Ping Compensation", "_ap_pingcomp", "ping_compensation")

AddCheckbox(AutoParryModule, "Dynamic Accuracy", "_ap_dynamicaccuracy", "dynamic_accuracy", function(enabled)
    if enabled and UiReady then
        Notify("Dynamic Accuracy", string.format(
            "%dms ping, %d FPS -> accuracy %d",
            math.floor(Util.GetEffectivePing()),
            math.floor(1 / Util.GetFrameTime()),
            Parry.GetAccuracyValue(300)
        ), "check", 4)
    end
end)

local CurveHotkeys = {
    [Enum.KeyCode.One] = "camera",
    [Enum.KeyCode.Two] = "dot",
    [Enum.KeyCode.Three] = "backwards",
    [Enum.KeyCode.Four] = "slow",
    [Enum.KeyCode.Five] = "random"
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    local newMethod = CurveHotkeys[input.KeyCode]

    if gameProcessed or not Config.curve_keybind or not newMethod then
        return
    end

    if Config.curve_method == newMethod then
        if Config.curve_notify then
            Notify("Curve Method", "Already " .. newMethod, "info", 3)
        end

        return
    end

    Config.curve_method = newMethod
    CurveModeDropdown:update(newMethod)

    if Config.curve_notify then
        Notify("Curve Method", newMethod, "check", 3)
    end
end)

InitializeFlag("autospam", Config.auto_spam == true)

local AutoSpamModule = CombatTab:create_module({
    title = "Auto Spam",
    description = "",
    flag = "autospam",
    section = "right",
    callback = Spam.SetEnabled
})

Spam.Threshold = tonumber(Config.spam_threshold) or 1.5

AutoSpamModule:create_slider({
    title = "Spam Threshold",
    flag = "_as_threshold",
    value = Spam.Threshold,
    minimum_value = 0,
    maximum_value = 8,
    decimals = 1,
    callback = function(value)
        Spam.Threshold = tonumber(value) or 1.5
        Config.spam_threshold = Spam.Threshold
    end
})

AutoSpamModule:create_slider({
    title = "Spam Rate",
    flag = "_as_rate",
    value = tonumber(Config.spam_rate) or 35,
    minimum_value = 10,
    maximum_value = 70,
    decimals = 0,
    callback = function(value)
        Config.spam_rate = math.clamp(math.floor(tonumber(value) or 35), 10, 70)
    end
})

AddCheckbox(AutoSpamModule, "Dynamic Threshold", "_as_dynamicthreshold", "dynamic_spam", function(enabled)
    if enabled and UiReady then
        Notify(
            "Dynamic Threshold",
            string.format("Current threshold: %.1f", Spam.GetThreshold(300, 0)),
            "check",
            4
        )
    end
end)

local ManualSpam = {
    Enabled = false,
    Active = false,
    NextFire = 0,
    RetryDelay = 0.1
}

ManualSpam.Button = Window:create_floating_button({
    flag = "manual_Spam_button",
    icon = "shield",
    size = 52,
    visible = false,
    position = UDim2.fromScale(0.94, 0.6),
    callback = function()
        ManualSpam.SetActive(not ManualSpam.Active)
    end
})

function ManualSpam.Step()
    local currentTime = os.clock()
    if currentTime < ManualSpam.NextFire then
        return
    end
    local character = LocalPlayer.Character
    local canFire = character and character.PrimaryPart and #Util.GetBalls() > 0 and Util.CanParry()
    local fired = canFire and Parry.Dispatch()
    ManualSpam.NextFire = currentTime + (fired and Spam.GetInterval() or ManualSpam.RetryDelay)
end

function ManualSpam.SetActive(active)
    active = active and ManualSpam.Enabled
    if active == ManualSpam.Active then
        return
    end
    ManualSpam.Active = active
    Disconnect("ManualSpam")
    if active then
        ManualSpam.NextFire = 0
        ActiveConnections.ManualSpam = RunService.PreSimulation:Connect(ManualSpam.Step)
    else
        ServerSideParry.Stop()
    end
    ManualSpam.Button:set_active(active)
end

function ManualSpam.SetEnabled(enabled)
    ManualSpam.Enabled = enabled
    ManualSpam.Button:set_visible(enabled)
    if not enabled then
        ManualSpam.SetActive(false)
    end
end

local Manual_Spam = CombatTab:create_module({
    title = "Manual Spam",
    description = "",
    flag = "manual_spam",
    section = "right",
    callback = ManualSpam.SetEnabled
})

Manual_Spam:create_slider({
    title = "Button Size",
    flag = "manual_spam_button_size",
    minimum_value = 32,
    maximum_value = 96,
    value = 52,
    callback = function(size)
        ManualSpam.Button:set_size(size)
    end
})

local Triggerbot = {
    States = {},
    Pending = nil,
    NextParry = 0,
    Lockout = 1.3
}

function Triggerbot.Release(state)
    if Triggerbot.Pending == state then
        Triggerbot.Pending = nil
        Triggerbot.NextParry = 0
    end
end

function Triggerbot.Forget(ball)
    local state = Triggerbot.States[ball]

    if not state then
        return
    end

    Triggerbot.States[ball] = nil
    state.Target:Disconnect()
    state.Destroying:Disconnect()
    Triggerbot.Release(state)
end

function Triggerbot.GetState(ball)
    local state = Triggerbot.States[ball]

    if state then
        return state
    end

    state = {Parried = false}
    Triggerbot.States[ball] = state

    state.Target = ball:GetAttributeChangedSignal("target"):Connect(function()
        state.Parried = false
        Triggerbot.Release(state)
        Triggerbot.Evaluate(ball, state)
    end)

    state.Destroying = ball.Destroying:Once(function()
        Triggerbot.Forget(ball)
    end)

    return state
end

function Triggerbot.Evaluate(ball, state)
    if state.Parried or ball:GetAttribute("target") ~= LocalPlayer.Name then
        return
    end

    local currentTime = os.clock()

    if currentTime < Triggerbot.NextParry then
        return
    end

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local aliveFolder = Util.GetAliveFolder()

    if not rootPart or not aliveFolder or character.Parent ~= aliveFolder then
        return
    end

    Parry.RecordAerodynamic(ball, currentTime)

    if Parry.ShouldWaitForVfx(currentTime) or Abilities.IsParryBlocked() then
        return
    end

    local zoomies = ball:FindFirstChild("zoomies")
    local velocity = zoomies and zoomies.VectorVelocity

    if not velocity or not Util.IsVectorValid(velocity) then
        return
    end

    local distance = (rootPart.Position - ball.Position).Magnitude

    if Abilities.ShouldSkipParry(character, distance, Parry.GetDistance(velocity.Magnitude)) then
        return
    end

    if Spam.IsHandling(currentTime) or not Abilities.IsParryReady() then
        return
    end

    if Parry.Fire(ball) then
        Triggerbot.Pending = state
        Triggerbot.NextParry = currentTime + Triggerbot.Lockout
    end
end

function Triggerbot.Step()
    for _, ball in Util.GetBalls() do
        Triggerbot.Evaluate(ball, Triggerbot.GetState(ball))
    end
end

function Triggerbot.OnCooldown(isBlock, active, duration)
    if not isBlock then
        return
    end

    if active then
        Triggerbot.NextParry = os.clock() + (tonumber(duration) or Triggerbot.Lockout)
        return
    end

    if not Triggerbot.Pending then
        Triggerbot.NextParry = 0
    end

    Triggerbot.Step()
end

function Triggerbot.OnSuccess()
    local pending = Triggerbot.Pending

    if pending then
        pending.Parried = true
    end

    Triggerbot.Pending = nil
    Triggerbot.NextParry = 0
end

function Triggerbot.Stop()
    Disconnect("Triggerbot")
    Disconnect("TriggerbotCooldown")
    Disconnect("TriggerbotSuccess")

    for ball in pairs(Triggerbot.States) do
        Triggerbot.Forget(ball)
    end

    Triggerbot.Pending = nil
    Triggerbot.NextParry = 0
end

function Triggerbot.SetEnabled(enabled)
    Config.triggerbot = enabled
    Triggerbot.Stop()

    if not enabled then
        return
    end

    local cooldownRemote = Util.GetRemote("VisualCD")
    local successRemote = Util.GetRemote("ParrySuccess")

    if cooldownRemote then
        ActiveConnections.TriggerbotCooldown = cooldownRemote.OnClientEvent:Connect(Triggerbot.OnCooldown)
    end

    if successRemote then
        ActiveConnections.TriggerbotSuccess = successRemote.OnClientEvent:Connect(Triggerbot.OnSuccess)
    end

    ActiveConnections.Triggerbot = RunService.PreSimulation:Connect(Triggerbot.Step)
end

InitializeFlag("triggerbot", Config.triggerbot == true)
TriggerbotModule = CombatTab:create_module({
    title = "Triggerbot",
    description = "",
    flag = "triggerbot",
    section = "right",
    callback = function(enabled)
        Triggerbot.SetEnabled(enabled)
        SwitchExclusive(enabled, AutoParryModule)
    end
})

InitializeFlag("ability_detection", Config.ability_detection ~= false)

local AbilityDetectionModule = AbilityDetections:create_module({
    title = "Ability Detection",
    description = "",
    flag = "ability_detection",
    section = "left",
    callback = function(enabled)
        Config.ability_detection = enabled

        if not enabled then
            Abilities.Reset()
        end
    end
})

AddCheckbox(AbilityDetectionModule, "Auto Ability", "_ad_autoability", "auto_ability", function(enabled)
    if not enabled then
        Abilities.Reset()
    end
end)

AddCheckbox(AbilityDetectionModule, "Cooldown Protection", "_ad_cooldownprotect", "cooldown_protection", function(enabled)
    if not enabled then
        Abilities.Reset()
    end
end)

InitializeFlag("_mod_fury", Config.fury_detect == true)

local FuryModule = AbilityDetections:create_module({
    title = "Slash of Fury",
    description = "",
    flag = "_mod_fury",
    section = "left",
    callback = function(enabled)
        Config.fury_detect = enabled
    end
})

FuryModule:create_slider({
    title = "SOF Burst Count",
    flag = "_ad_furyburst",
    value = tonumber(Config.fury_burst) or 34,
    minimum_value = 1,
    maximum_value = 34,
    decimals = 0,
    callback = function(value)
        Config.fury_burst = tonumber(value) or 34
    end
})

AddCheckbox(FuryModule, "SOF Notification", "_ad_furynotify", "fury_notify")

InitializeFlag("_mod_deathslash", Config.death_slash_detect == true)

local DeathSlashModule = AbilityDetections:create_module({
    title = "Death Slash",
    description = "",
    flag = "_mod_deathslash",
    section = "left",
    callback = function(enabled)
        Config.death_slash_detect = enabled
        if not enabled then
            Abilities.DeathSlash.StopWatch()
        end
    end
})

AddCheckbox(DeathSlashModule, "Death Slash Auto", "_ad_deathauto", "death_slash_auto")
AddCheckbox(DeathSlashModule, "Death Slash Notify", "_ad_deathnotify", "death_slash_notify")

InitializeFlag("_mod_duality", Config.duality_detect == true)

local DualityModule = AbilityDetections:create_module({
    title = "Slash of Duality",
    description = "",
    flag = "_mod_duality",
    section = "right",
    callback = function(enabled)
        Config.duality_detect = enabled
    end
})

AddCheckbox(DualityModule, "Duality Auto", "_ad_dualityauto", "duality_auto")

AddDropdown(DualityModule, "Duality Mode", "_ad_dualitymode", "duality_mode", {"Randomized", "Light", "Dark", "Mixed"}, function(value)
    if value == "Mixed" then
        Abilities.Duality.MixedNext = "Light"
    end
end)

AddCheckbox(DualityModule, "Duality Notify", "_ad_dualitynotify", "duality_notify")

InitializeFlag("_mod_hellhook", Config.hellhook_detection == true)

local HellHookModule = AbilityDetections:create_module({
    title = "Hell Hook",
    description = "",
    flag = "_mod_hellhook",
    section = "right",
    callback = function(enabled)
        Config.hellhook_detection = enabled
        if not enabled then
            Abilities.HellHook.Active = false
            Abilities.HellHook.ActiveUntil = 0
        end
    end
})

AddCheckbox(HellHookModule, "Hell Hook Notify", "_ad_hellhooknotify", "hellhook_notify")

InitializeFlag("_mod_phantom", Config.phantom_detection == true)

local PhantomModule = AbilityDetections:create_module({
    title = "Phantom",
    description = "",
    flag = "_mod_phantom",
    section = "right",
    callback = function(enabled)
        Config.phantom_detection = enabled
    end
})

VisualTab:create_module({
    title = "No Render",
    description = "",
    flag = "no_render",
    section = "right",
    callback = function(enabled)
        if enabled then
            NoRender.Start()
        else
            NoRender.Stop()
        end
    end
})

InitializeFlag("anti_lag", Config.anti_lag == true)

local AntiLagModule = VisualTab:create_module({
    title = "Anti Lag",
    description = "",
    flag = "anti_lag",
    section = "left",
    callback = function(enabled)
        Config.anti_lag = enabled
        AntiLag.SetEnabled(enabled)
    end
})

AddCheckbox(AntiLagModule, "Lower Quality Level", "_al_quality", "al_quality", function(enabled)
    AntiLag.SetOption("Quality", enabled)
end)

AntiLagModule:create_slider({
    title = "Quality Level",
    flag = "_al_qualitylevel",
    value = tonumber(Config.al_quality_level) or 1,
    minimum_value = 1,
    maximum_value = 10,
    decimals = 0,
    callback = AntiLag.SetQualityLevel
})

AddCheckbox(AntiLagModule, "Disable Shadows", "_al_shadows", "al_shadows", function(enabled)
    AntiLag.SetOption("Shadows", enabled)
end)

AddCheckbox(AntiLagModule, "Remove Post Effects", "_al_post", "al_post", function(enabled)
    AntiLag.SetOption("PostEffects", enabled)
end)

AddCheckbox(AntiLagModule, "Remove Atmosphere and Clouds", "_al_atmosphere", "al_atmosphere", function(enabled)
    AntiLag.SetOption("Atmosphere", enabled)
end)

AddCheckbox(AntiLagModule, "Flatten Water", "_al_water", "al_water", function(enabled)
    AntiLag.SetOption("Water", enabled)
end)

AddCheckbox(AntiLagModule, "Disable Particles and Trails", "_al_particles", "al_particles", function(enabled)
    AntiLag.SetOption("Particles", enabled)
end)

AddCheckbox(AntiLagModule, "Smooth Materials", "_al_materials", "al_materials", function(enabled)
    AntiLag.SetOption("Materials", enabled)
end)

AddCheckbox(AntiLagModule, "Hide Textures and Decals", "_al_textures", "al_textures", function(enabled)
    AntiLag.SetOption("Textures", enabled)
end)

AddCheckbox(AntiLagModule, "Low Detail Meshes", "_al_meshes", "al_meshes", function(enabled)
    AntiLag.SetOption("Meshes", enabled)
end)

InitializeFlag("unlock_all", Config.unlock_all == true)

UnlockAll.Module = VisualTab:create_module({
    title = "Unlock All",
    description = "",
    flag = "unlock_all",
    section = "right",
    callback = UnlockAll.SetEnabled
})

InitializeFlag("ball_esp", Config.ball_esp == true)

BallEsp.Module = VisualTab:create_module({
    title = "Ball ESP",
    description = "",
    flag = "ball_esp",
    section = "left",
    callback = function(enabled)
        if enabled and not BallEsp.HasFields() then
            BallEsp.EnableAllFields()
        end

        Config.ball_esp = enabled
        BallEsp.SetEnabled(enabled)
    end
})

BallEsp.FieldCheckboxes = {
    Distance = AddCheckbox(BallEsp.Module, "Distance", "_be_distance", "ball_esp_distance", BallEsp.OnFieldsChanged),
    Velocity = AddCheckbox(BallEsp.Module, "Velocity", "_be_velocity", "ball_esp_velocity", BallEsp.OnFieldsChanged),
    Target = AddCheckbox(BallEsp.Module, "Target", "_be_target", "ball_esp_target", BallEsp.OnFieldsChanged)
}

Window:load()

UiReady = true

PolSec_SendWebhook({
    username = "Closet.GG | Bladeball",
    content = "Executed by " .. PolSec_Sanitize(LocalPlayer.Name, "[a-zA-Z0-9_]{2,20}")
})