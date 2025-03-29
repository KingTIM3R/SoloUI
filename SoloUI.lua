--[[
    SoloUI - A Solo Leveling inspired UI Library for Roblox
    Compatible with multiple exploit executors (JJSploit, KRNL Mobile, Delta)
    
    Author: Anonymous
    Version: 1.0.0
]]

local SoloUI = {
    Windows = {},
    Theme = {
        Primary = Color3.fromRGB(28, 69, 161),       -- Main blue color
        Secondary = Color3.fromRGB(20, 38, 87),      -- Darker blue
        Background = Color3.fromRGB(10, 15, 30),     -- Dark background
        BackgroundTransparency = 0.2,                -- Slight transparency for holographic effect
        Text = Color3.fromRGB(220, 240, 255),        -- Light blue-white text
        Accent = Color3.fromRGB(87, 157, 255),       -- Bright blue for highlights
        Success = Color3.fromRGB(50, 200, 100),      -- Green for success states
        Error = Color3.fromRGB(255, 70, 70),         -- Red for error states
        BorderSize = 1,                              -- Border thickness
        BorderColor = Color3.fromRGB(40, 120, 255),  -- Border color
        CornerRadius = UDim.new(0, 4),               -- Corner roundness
        DropShadow = true,                           -- Enable drop shadows
        Font = Enum.Font.Gotham,                     -- Default font
        HoverBrightness = 0.1,                       -- How much brighter elements get on hover
        Animation = {
            Speed = 0.2,                             -- Animation speed in seconds
            Style = Enum.EasingStyle.Quart,          -- Easing style
            Direction = Enum.EasingDirection.Out     -- Easing direction
        }
    },
    Flags = {},
    Initialized = false,
    ConfigVersion = 1,
}

-- Import modules
-- For local testing, load files directly
local Detection = loadfile("Utilities/Detection.lua")()
local TweenLib = loadfile("Utilities/TweenLib.lua")()
local Window = loadfile("Components/Window.lua")()

-- Core functionality
function SoloUI:Init()
    if self.Initialized then return self end
    
    -- Detect executor environment
    self.Executor = Detection:GetExecutor()
    self.IsMobile = Detection:IsMobile()
    
    -- Adjust theme based on device
    if self.IsMobile then
        self.Theme.BorderSize = 2
        self.Theme.CornerRadius = UDim.new(0, 6)
    end
    
    -- Create core GUI container
    local coreGui = game:GetService("CoreGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SoloUILibrary"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    -- Handle protection/security based on executor
    local success, err = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = coreGui
        elseif gethui then
            screenGui.Parent = gethui()
        else
            screenGui.Parent = coreGui
        end
    end)
    
    if not success then
        screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self.ScreenGui = screenGui
    self.Initialized = true
    
    return self
end

function SoloUI:CreateWindow(config)
    assert(self.Initialized, "SoloUI must be initialized before creating a window. Call SoloUI:Init() first.")
    assert(type(config) == "table", "Window configuration must be a table")
    
    config = config or {}
    config.Title = config.Title or "SoloUI"
    config.Size = config.Size or UDim2.new(0, 550, 0, 400)
    config.Position = config.Position or UDim2.new(0.5, -275, 0.5, -200)
    config.Theme = config.Theme or self.Theme
    
    -- Initialize window
    local newWindow = Window:Create(self, config)
    table.insert(self.Windows, newWindow)
    
    return newWindow
end

function SoloUI:Notify(config)
    assert(self.Initialized, "SoloUI must be initialized before sending notifications. Call SoloUI:Init() first.")
    
    config = config or {}
    config.Title = config.Title or "Notification"
    config.Content = config.Content or ""
    config.Duration = config.Duration or 5
    config.Type = config.Type or "Info" -- Info, Success, Error, Warning
    
    -- Create notification (simplified implementation)
    local notifGui = Instance.new("Frame")
    notifGui.Name = "SoloNotification"
    notifGui.Size = UDim2.new(0, 300, 0, 80)
    notifGui.Position = UDim2.new(1, -320, 1, -100)
    notifGui.BackgroundColor3 = self.Theme.Background
    notifGui.BackgroundTransparency = self.Theme.BackgroundTransparency
    notifGui.BorderSizePixel = 0
    notifGui.Parent = self.ScreenGui
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = self.Theme.CornerRadius
    cornerRadius.Parent = notifGui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = self.Theme.Text
    titleLabel.TextSize = 16
    titleLabel.Font = self.Theme.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = config.Title
    titleLabel.Parent = notifGui
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, -20, 0, 40)
    contentLabel.Position = UDim2.new(0, 10, 0, 30)
    contentLabel.BackgroundTransparency = 1
    contentLabel.TextColor3 = self.Theme.Text
    contentLabel.TextSize = 14
    contentLabel.Font = self.Theme.Font
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Text = config.Content
    contentLabel.Parent = notifGui
    
    -- Add type-specific styling
    local typeColor
    if config.Type == "Success" then
        typeColor = self.Theme.Success
    elseif config.Type == "Error" then
        typeColor = self.Theme.Error
    elseif config.Type == "Warning" then
        typeColor = Color3.fromRGB(255, 180, 20)
    else
        typeColor = self.Theme.Accent
    end
    
    local colorBar = Instance.new("Frame")
    colorBar.Name = "TypeIndicator"
    colorBar.Size = UDim2.new(0, 4, 1, 0)
    colorBar.Position = UDim2.new(0, 0, 0, 0)
    colorBar.BackgroundColor3 = typeColor
    colorBar.BorderSizePixel = 0
    colorBar.Parent = notifGui
    
    -- Animation
    TweenLib:Create(notifGui, 0.3, {
        Position = UDim2.new(1, -320, 1, -100 - (#self.Windows * 90))
    }):Play()
    
    -- Auto-dismiss
    spawn(function()
        wait(config.Duration)
        TweenLib:Create(notifGui, 0.3, {
            Position = UDim2.new(1, 10, notifGui.Position.Y.Scale, notifGui.Position.Y.Offset)
        }):Play()
        wait(0.4)
        notifGui:Destroy()
    end)
    
    return notifGui
end

function SoloUI:SetTheme(newTheme)
    assert(type(newTheme) == "table", "Theme must be a table")
    
    -- Merge with existing theme
    for key, value in pairs(newTheme) do
        self.Theme[key] = value
    end
    
    -- Update all windows with new theme
    for _, window in ipairs(self.Windows) do
        if window.UpdateTheme then
            window:UpdateTheme(self.Theme)
        end
    end
    
    return self.Theme
end

-- Save/Load Configuration
function SoloUI:SaveConfig(name)
    assert(type(name) == "string", "Config name must be a string")
    
    local config = {
        Flags = self.Flags,
        Version = self.ConfigVersion
    }
    
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONEncode(config)
    end)
    
    if success then
        if writefile then
            writefile("SoloUI_" .. name .. ".json", result)
            return true
        else
            warn("File system functions not available in this executor")
            return false
        end
    else
        warn("Failed to encode config:", result)
        return false
    end
end

function SoloUI:LoadConfig(name)
    assert(type(name) == "string", "Config name must be a string")
    
    if not readfile then
        warn("File system functions not available in this executor")
        return false
    end
    
    local success, content = pcall(function()
        return readfile("SoloUI_" .. name .. ".json")
    end)
    
    if success then
        local parsed = game:GetService("HttpService"):JSONDecode(content)
        if parsed.Version == self.ConfigVersion then
            self.Flags = parsed.Flags
            return true
        else
            warn("Config version mismatch")
            return false
        end
    else
        warn("Failed to load config:", content)
        return false
    end
end

-- Cleanup function
function SoloUI:Destroy()
    for _, window in ipairs(self.Windows) do
        if window.Destroy then
            window:Destroy()
        end
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    self.Windows = {}
    self.Initialized = false
end

return SoloUI
