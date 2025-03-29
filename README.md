# SoloUI - Solo Leveling Themed Roblox UI Library

A sleek, modern UI library for Roblox exploits featuring a Solo Leveling inspired design aesthetic with holographic elements and blue circuit patterns.

## Features

- 🔵 **Solo Leveling Aesthetic**: Dark themes with blue accents and circuit-like patterns inspired by the "System" from Solo Leveling
- 🧩 **Complete Component Set**: Windows, tabs, buttons, toggles, sliders, dropdowns, color pickers and more
- 🌐 **Cross-Executor Compatibility**: Works on multiple Roblox executors including JJSploit, KRNL Mobile, and Delta
- 📱 **Mobile Support**: Responsive design with automatic mobile device detection
- 🎮 **Simple API**: Easy-to-use, intuitive method chaining for creating interfaces
- 🎨 **Customizable Themes**: Multiple built-in themes with full customization support
- 💾 **Configuration System**: Save and load UI states and user preferences

## Installation

Add this to your script:

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/KingTIM3R/SoloUI/refs/heads/main/SoloUI.lua'))()
```

## Basic Usage

```lua
-- Initialize the library
SoloUI:Init()

-- Create a window
local Window = SoloUI:CreateWindow({
    Title = "SoloUI Example",
    Size = UDim2.new(0, 550, 0, 400)
})

-- Create tabs
local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "★"
})

-- Create sections
local MainSection = HomeTab:CreateSection({
    Name = "Main Functions"
})

-- Add components
MainSection:AddButton({
    Name = "Simple Button",
    Callback = function()
        SoloUI:Notify({
            Title = "Button Pressed",
            Content = "You clicked the button!",
            Duration = 3,
            Type = "Info"
        })
    end
})

MainSection:AddToggle({
    Name = "Example Toggle",
    Default = false,
    Flag = "exampleToggle",
    Callback = function(Value)
        print("Toggle is now:", Value)
    end
})

MainSection:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Flag = "speedValue",
    Callback = function(Value)
        print("Slider value:", Value)
    end
})
```

## Components

### Window
The main container for your UI elements.

### Tab
Organizes content into different categories.

### Section
Groups related components within a tab.

### Button
Simple clickable button that triggers a callback function.

### Toggle
On/off switch with animated state changes.

### Slider
Adjustable value selector with a movable thumb.

### Dropdown
Selection menu with expandable options list.

### ColorPicker
Color selection tool with HSV picker and RGB values.

## Themes

SoloUI comes with several built-in themes:

- Default (Solo Leveling blue)
- Dark
- Light
- Purple
- Green

You can also create custom themes:

```lua
SoloUI:SetTheme({
    Primary = Color3.fromRGB(28, 69, 161),
    Secondary = Color3.fromRGB(20, 38, 87),
    Background = Color3.fromRGB(10, 15, 30),
    Text = Color3.fromRGB(220, 240, 255),
    Accent = Color3.fromRGB(87, 157, 255),
})
```

## Configuration

Save and load user preferences:

```lua
-- Save the current configuration
SoloUI:SaveConfig("MySettings")

-- Load a saved configuration
SoloUI:LoadConfig("MySettings")
```

## Cross-Executor Support

SoloUI is designed to work across multiple Roblox executors, with automatic detection and fallbacks for:

- Synapse X
- Script-Ware
- KRNL (including KRNL Mobile)
- JJSploit
- Delta
- Fluxus
- And more...

## Example Scripts

See the `Examples` folder for more detailed usage examples.

## License

This project is available for use under the MIT License. See the LICENSE file for more details.
