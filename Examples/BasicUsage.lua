--[[
    SoloUI Basic Usage Example
    
    This example demonstrates how to create a simple script using the SoloUI library,
    showing off window creation, tabs, sections, and various UI components.
    
    Compatible with multiple exploit executors (JJSploit, KRNL Mobile, Delta)
]]

-- Load the SoloUI library from local file
loadstring(game:HttpGet('https://raw.githubusercontent.com/KingTIM3R/SoloUI/refs/heads/main/SoloUI.lua'))()

-- Initialize the library
SoloUI:Init()

-- Create a window
local Window = SoloUI:CreateWindow({
    Title = "SoloUI Example",
    Size = UDim2.new(0, 550, 0, 400), -- Default size
    Position = UDim2.new(0.5, -275, 0.5, -200), -- Center on screen
})

-- Create tabs
local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "★" -- Optional icon character
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙"
})

local CreditsTab = Window:CreateTab({
    Name = "Credits",
    Icon = "♥"
})

-- Create sections in the Home tab
local MainSection = HomeTab:CreateSection({
    Name = "Main Functions"
})

local FarmingSection = HomeTab:CreateSection({
    Name = "Farming Options"
})

-- Add a button to the Main section
MainSection:AddButton({
    Name = "Simple Button",
    Callback = function()
        SoloUI:Notify({
            Title = "Button Pressed",
            Content = "You clicked the simple button!",
            Duration = 3,
            Type = "Info"
        })
    end
})

-- Add a toggle
MainSection:AddToggle({
    Name = "Auto-Farm",
    Default = false,
    Flag = "autoFarm", -- Used for config saving/loading
    Callback = function(Value)
        SoloUI:Notify({
            Title = "Toggle Changed",
            Content = "Auto-Farm is now " .. (Value and "enabled" or "disabled"),
            Duration = 3,
            Type = Value and "Success" or "Error"
        })
        
        -- Your script logic here
        if Value then
            print("Auto-Farm enabled")
            -- Start farming functionality
        else
            print("Auto-Farm disabled")
            -- Stop farming functionality
        end
    end
})

-- Add a slider
FarmingSection:AddSlider({
    Name = "Farm Speed",
    Min = 1,
    Max = 100,
    Default = 50,
    Increment = 1,
    Flag = "farmSpeed",
    Callback = function(Value)
        print("Farm speed set to:", Value)
        -- Adjust farming speed logic here
    end
})

-- Add a dropdown
FarmingSection:AddDropdown({
    Name = "Target Area",
    Options = {"Grasslands", "Forest", "Desert", "Snowy Mountain", "Volcano"},
    Default = "Grasslands",
    Flag = "farmArea",
    Callback = function(Value)
        print("Farm area set to:", Value)
        -- Change farming area logic here
    end
})

-- Add a color picker
FarmingSection:AddColorPicker({
    Name = "Farm Trail Color",
    Default = Color3.fromRGB(28, 69, 161), -- Solo Leveling blue
    Flag = "farmTrailColor",
    Callback = function(Value)
        print("Farm trail color set to:", string.format("RGB(%d, %d, %d)", 
            math.floor(Value.R * 255 + 0.5), 
            math.floor(Value.G * 255 + 0.5), 
            math.floor(Value.B * 255 + 0.5))
        )
        -- Change trail color logic here
    end
})

-- Create sections in the Settings tab
local AppearanceSection = SettingsTab:CreateSection({
    Name = "Appearance"
})

local ConfigSection = SettingsTab:CreateSection({
    Name = "Configuration"
})

-- Add theme options
AppearanceSection:AddDropdown({
    Name = "Theme",
    Options = {"Default", "Dark", "Light", "Purple", "Green"},
    Default = "Default",
    Flag = "uiTheme",
    Callback = function(Value)
        -- Theme switcher logic
        if Value == "Default" then
            SoloUI:SetTheme({
                Primary = Color3.fromRGB(28, 69, 161),
                Secondary = Color3.fromRGB(20, 38, 87),
                Background = Color3.fromRGB(10, 15, 30),
                Text = Color3.fromRGB(220, 240, 255),
                Accent = Color3.fromRGB(87, 157, 255),
            })
        elseif Value == "Dark" then
            SoloUI:SetTheme({
                Primary = Color3.fromRGB(30, 30, 35),
                Secondary = Color3.fromRGB(20, 20, 25),
                Background = Color3.fromRGB(10, 10, 15),
                Text = Color3.fromRGB(200, 200, 220),
                Accent = Color3.fromRGB(100, 150, 250),
            })
        elseif Value == "Light" then
            SoloUI:SetTheme({
                Primary = Color3.fromRGB(210, 220, 240),
                Secondary = Color3.fromRGB(180, 190, 210),
                Background = Color3.fromRGB(230, 235, 245),
                Text = Color3.fromRGB(40, 50, 70),
                Accent = Color3.fromRGB(70, 120, 220),
            })
        elseif Value == "Purple" then
            SoloUI:SetTheme({
                Primary = Color3.fromRGB(74, 35, 120),
                Secondary = Color3.fromRGB(50, 20, 90),
                Background = Color3.fromRGB(30, 10, 45),
                Text = Color3.fromRGB(230, 220, 255),
                Accent = Color3.fromRGB(150, 80, 250),
            })
        elseif Value == "Green" then
            SoloUI:SetTheme({
                Primary = Color3.fromRGB(35, 85, 50),
                Secondary = Color3.fromRGB(20, 60, 35),
                Background = Color3.fromRGB(10, 30, 20),
                Text = Color3.fromRGB(220, 250, 230),
                Accent = Color3.fromRGB(70, 190, 100),
            })
        end
    end
})

-- Add configuration options
ConfigSection:AddButton({
    Name = "Save Configuration",
    Callback = function()
        local success = SoloUI:SaveConfig("MyConfig")
        SoloUI:Notify({
            Title = success and "Success" or "Error",
            Content = success and "Configuration saved!" or "Failed to save configuration",
            Duration = 3,
            Type = success and "Success" or "Error"
        })
    end
})

ConfigSection:AddButton({
    Name = "Load Configuration",
    Callback = function()
        local success = SoloUI:LoadConfig("MyConfig")
        SoloUI:Notify({
            Title = success and "Success" or "Error",
            Content = success and "Configuration loaded!" or "Failed to load configuration",
            Duration = 3,
            Type = success and "Success" or "Error"
        })
    end
})

-- Create a section in the Credits tab
local CreditsSection = CreditsTab:CreateSection({
    Name = "Credits"
})

-- Add credits information
CreditsSection:AddButton({
    Name = "SoloUI Library",
    Callback = function()
        SoloUI:Notify({
            Title = "Credits",
            Content = "SoloUI Library - A Solo Leveling themed UI library",
            Duration = 3,
            Type = "Info"
        })
    end
})

-- Add a feature showcase section
local ShowcaseSection = HomeTab:CreateSection({
    Name = "Feature Showcase"
})

-- Add a more complex button with status update
local StatusButton = ShowcaseSection:AddButton({
    Name = "Start Process",
    Callback = function()
        -- Change button text
        StatusButton:SetText("Processing...")
        
        -- Simulate a process
        for i = 1, 5 do
            SoloUI:Notify({
                Title = "Process Update",
                Content = "Step " .. i .. " of 5 completed",
                Duration = 1,
                Type = "Info"
            })
            
            wait(1)
        end
        
        -- Reset button text
        StatusButton:SetText("Complete!")
        
        -- Reset back to original after 2 seconds
        wait(2)
        StatusButton:SetText("Start Process")
    end
})

-- Notify the user that the UI is ready
SoloUI:Notify({
    Title = "SoloUI Loaded",
    Content = "Welcome to the SoloUI example!",
    Duration = 5,
    Type = "Success"
})

-- ADDITIONAL EXAMPLES

-- Example: Create a keybind section
local KeybindSection = SettingsTab:CreateSection({
    Name = "Keybinds"
})

KeybindSection:AddButton({
    Name = "Toggle UI Visibility (RightControl)",
    Callback = function()
        SoloUI:Notify({
            Title = "Keybind Info",
            Content = "Press RightControl to toggle the UI visibility",
            Duration = 3,
            Type = "Info"
        })
    end
})

-- Example: Create a character section with advanced features
local CharacterSection = HomeTab:CreateSection({
    Name = "Character Enhancements"
})

CharacterSection:AddToggle({
    Name = "Speed Boost",
    Default = false,
    Flag = "speedBoost",
    Callback = function(Value)
        -- Speed boost logic
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if Value then
            humanoid.WalkSpeed = 50
            SoloUI:Notify({
                Title = "Speed Boost",
                Content = "Speed increased to 50",
                Duration = 2,
                Type = "Success"
            })
        else
            humanoid.WalkSpeed = 16
            SoloUI:Notify({
                Title = "Speed Boost",
                Content = "Speed reset to normal",
                Duration = 2,
                Type = "Info"
            })
        end
    end
})

CharacterSection:AddToggle({
    Name = "Jump Boost",
    Default = false,
    Flag = "jumpBoost",
    Callback = function(Value)
        -- Jump boost logic
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if Value then
            humanoid.JumpPower = 100
            SoloUI:Notify({
                Title = "Jump Boost",
                Content = "Jump power increased to 100",
                Duration = 2,
                Type = "Success"
            })
        else
            humanoid.JumpPower = 50
            SoloUI:Notify({
                Title = "Jump Boost",
                Content = "Jump power reset to normal",
                Duration = 2,
                Type = "Info"
            })
        end
    end
})

-- Example: Create a game-specific section
local GameSection = HomeTab:CreateSection({
    Name = "Game Features"
})

GameSection:AddButton({
    Name = "Teleport to Lobby",
    Callback = function()
        SoloUI:Notify({
            Title = "Teleport",
            Content = "Attempting to teleport to lobby...",
            Duration = 3,
            Type = "Info"
        })
        
        -- Sample teleport logic (would be customized per game)
        local success = pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            
            -- Example coordinates - would be replaced with actual lobby position
            humanoidRootPart.CFrame = CFrame.new(0, 100, 0)
        end)
        
        if success then
            SoloUI:Notify({
                Title = "Teleport",
                Content = "Successfully teleported to lobby!",
                Duration = 3,
                Type = "Success"
            })
        else
            SoloUI:Notify({
                Title = "Teleport",
                Content = "Failed to teleport. Try again later.",
                Duration = 3,
                Type = "Error"
            })
        end
    end
})

-- Tutorial on how to use the library
local TutorialSection = CreditsTab:CreateSection({
    Name = "How to Use"
})

TutorialSection:AddButton({
    Name = "Show Tutorial",
    Callback = function()
        -- Display a series of notifications explaining how to use the UI
        
        SoloUI:Notify({
            Title = "Tutorial (1/4)",
            Content = "Use tabs at the left side to navigate between different categories",
            Duration = 4,
            Type = "Info"
        })
        
        wait(4.5)
        
        SoloUI:Notify({
            Title = "Tutorial (2/4)",
            Content = "Toggle features on/off using the switches",
            Duration = 4,
            Type = "Info"
        })
        
        wait(4.5)
        
        SoloUI:Notify({
            Title = "Tutorial (3/4)",
            Content = "Adjust values precisely with sliders and dropdowns",
            Duration = 4,
            Type = "Info"
        })
        
        wait(4.5)
        
        SoloUI:Notify({
            Title = "Tutorial (4/4)",
            Content = "Save your configuration in the Settings tab",
            Duration = 4,
            Type = "Success"
        })
    end
})

-- Return the window instance in case it's needed elsewhere
return Window
