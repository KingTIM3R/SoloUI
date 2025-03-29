--[[
    Tab Component for SoloUI
    Creates tabs with sections for controls
]]

local Tab = {}
Tab.__index = Tab

-- Import dependencies
local TweenLib = {} -- Will be properly loaded in Create function
local Section = {} -- Will be properly loaded in Create function

function Tab:Create(window, config)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Name = config.Name
    self.Button = config.Button
    self.Container = config.Container
    self.Sections = {}
    self.Theme = window.Theme
    
    -- Load dependencies if not already loaded
    if not getfenv().SoloUITweenLibLoaded then
        TweenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingTIM3R/SoloUI/refs/heads/main/Utilities/TweenLib.lua"))()
        getfenv().SoloUITweenLibLoaded = true
    else
        TweenLib = getfenv().SoloUITweenLib
    end
    
    -- Add Solo Leveling-themed decorations
    self:AddSystemDecorations()
    
    return self
end

function Tab:AddSystemDecorations()
    -- Add subtle blue lines (circuit-like patterns)
    local decoration = Instance.new("Frame")
    decoration.Name = "TabDecoration"
    decoration.Size = UDim2.new(1, 0, 0, 2)
    decoration.Position = UDim2.new(0, 0, 0, 0)
    decoration.BackgroundColor3 = self.Theme.Accent
    decoration.BackgroundTransparency = 0.7
    decoration.BorderSizePixel = 0
    decoration.ZIndex = 0
    decoration.Parent = self.Container
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = decoration
    
    -- Add animation effect
    spawn(function()
        while self.Container.Parent do
            local transparency = 0.6 + (math.sin(tick() * 0.5) * 0.2)
            decoration.BackgroundTransparency = transparency
            wait(0.03)
        end
    end)
end

function Tab:CreateSection(config)
    config = config or {}
    config.Name = config.Name or "Section"
    
    -- Create section container
    local sectionContainer = Instance.new("Frame")
    sectionContainer.Name = "Section_" .. config.Name
    sectionContainer.Size = UDim2.new(1, 0, 0, 36) -- Initial size, will expand with content
    sectionContainer.BackgroundColor3 = self.Theme.Secondary
    sectionContainer.BackgroundTransparency = 0.6
    sectionContainer.BorderSizePixel = 0
    sectionContainer.Parent = self.Container
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Theme.CornerRadius
    corner.Parent = sectionContainer
    
    -- Add subtle border glow
    local borderGlow = Instance.new("UIStroke")
    borderGlow.Thickness = 1
    borderGlow.Color = self.Theme.BorderColor
    borderGlow.Transparency = 0.7
    borderGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    borderGlow.Parent = sectionContainer
    
    -- Create section header
    local sectionHeader = Instance.new("TextLabel")
    sectionHeader.Name = "SectionHeader"
    sectionHeader.Size = UDim2.new(1, -20, 0, 30)
    sectionHeader.Position = UDim2.new(0, 10, 0, 0)
    sectionHeader.BackgroundTransparency = 1
    sectionHeader.TextColor3 = self.Theme.Text
    sectionHeader.TextSize = 14
    sectionHeader.Font = self.Theme.Font
    sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
    sectionHeader.Text = config.Name
    sectionHeader.Parent = sectionContainer
    
    -- Create elements container
    local elementsContainer = Instance.new("Frame")
    elementsContainer.Name = "ElementsContainer"
    elementsContainer.Size = UDim2.new(1, -20, 0, 0) -- Will be resized as elements are added
    elementsContainer.Position = UDim2.new(0, 10, 0, 30)
    elementsContainer.BackgroundTransparency = 1
    elementsContainer.BorderSizePixel = 0
    elementsContainer.Parent = sectionContainer
    
    -- Add list layout for elements
    local elementsLayout = Instance.new("UIListLayout")
    elementsLayout.Padding = UDim.new(0, 6)
    elementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    elementsLayout.Parent = elementsContainer
    
    -- Update section size when elements are added/removed
    elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        elementsContainer.Size = UDim2.new(1, -20, 0, elementsLayout.AbsoluteContentSize.Y)
        sectionContainer.Size = UDim2.new(1, 0, 0, elementsContainer.Size.Y.Offset + 36)
    end)
    
    -- Create section API
    local section = {
        Container = sectionContainer,
        ElementsContainer = elementsContainer,
        Header = sectionHeader,
        Tab = self,
        Theme = self.Theme,
        Elements = {}
    }
    
    -- Add element creation functions
    
    -- Create Button
    function section:AddButton(config)
        config = config or {}
        config.Name = config.Name or "Button"
        config.Callback = config.Callback or function() end
        
        -- Load Button component if not already loaded
        local Button
        if not getfenv().SoloUIButtonLoaded then
            Button = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Components/Button.lua"))()
            getfenv().SoloUIButtonLoaded = true
        else
            Button = getfenv().SoloUIButton
        end
        
        -- Create button element
        local button = Button:Create(self, config)
        table.insert(self.Elements, button)
        
        return button
    end
    
    -- Create Toggle
    function section:AddToggle(config)
        config = config or {}
        config.Name = config.Name or "Toggle"
        config.Default = config.Default or false
        config.Flag = config.Flag or config.Name:gsub("%s+", "_"):lower() .. "_toggle"
        config.Callback = config.Callback or function() end
        
        -- Load Toggle component if not already loaded
        local Toggle
        if not getfenv().SoloUIToggleLoaded then
            Toggle = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Components/Toggle.lua"))()
            getfenv().SoloUIToggleLoaded = true
        else
            Toggle = getfenv().SoloUIToggle
        end
        
        -- Create toggle element
        local toggle = Toggle:Create(self, config)
        table.insert(self.Elements, toggle)
        
        -- Register flag
        self.Tab.Window.UI.Flags[config.Flag] = config.Default
        
        return toggle
    end
    
    -- Create Slider
    function section:AddSlider(config)
        config = config or {}
        config.Name = config.Name or "Slider"
        config.Min = config.Min or 0
        config.Max = config.Max or 100
        config.Default = config.Default or config.Min
        config.Increment = config.Increment or 1
        config.Flag = config.Flag or config.Name:gsub("%s+", "_"):lower() .. "_slider"
        config.Callback = config.Callback or function() end
        
        -- Load Slider component if not already loaded
        local Slider
        if not getfenv().SoloUISliderLoaded then
            Slider = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Components/Slider.lua"))()
            getfenv().SoloUISliderLoaded = true
        else
            Slider = getfenv().SoloUISlider
        end
        
        -- Create slider element
        local slider = Slider:Create(self, config)
        table.insert(self.Elements, slider)
        
        -- Register flag
        self.Tab.Window.UI.Flags[config.Flag] = config.Default
        
        return slider
    end
    
    -- Create Dropdown
    function section:AddDropdown(config)
        config = config or {}
        config.Name = config.Name or "Dropdown"
        config.Options = config.Options or {}
        config.Default = config.Default or (config.Options[1] or "")
        config.Flag = config.Flag or config.Name:gsub("%s+", "_"):lower() .. "_dropdown"
        config.Callback = config.Callback or function() end
        
        -- Load Dropdown component if not already loaded
        local Dropdown
        if not getfenv().SoloUIDropdownLoaded then
            Dropdown = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Components/Dropdown.lua"))()
            getfenv().SoloUIDropdownLoaded = true
        else
            Dropdown = getfenv().SoloUIDropdown
        end
        
        -- Create dropdown element
        local dropdown = Dropdown:Create(self, config)
        table.insert(self.Elements, dropdown)
        
        -- Register flag
        self.Tab.Window.UI.Flags[config.Flag] = config.Default
        
        return dropdown
    end
    
    -- Create ColorPicker
    function section:AddColorPicker(config)
        config = config or {}
        config.Name = config.Name or "Color Picker"
        config.Default = config.Default or Color3.fromRGB(255, 255, 255)
        config.Flag = config.Flag or config.Name:gsub("%s+", "_"):lower() .. "_color"
        config.Callback = config.Callback or function() end
        
        -- Load ColorPicker component if not already loaded
        local ColorPicker
        if not getfenv().SoloUIColorPickerLoaded then
            ColorPicker = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Components/ColorPicker.lua"))()
            getfenv().SoloUIColorPickerLoaded = true
        else
            ColorPicker = getfenv().SoloUIColorPicker
        end
        
        -- Create color picker element
        local colorPicker = ColorPicker:Create(self, config)
        table.insert(self.Elements, colorPicker)
        
        -- Register flag
        self.Tab.Window.UI.Flags[config.Flag] = config.Default
        
        return colorPicker
    end
    
    -- Add section to tab's sections
    table.insert(self.Sections, section)
    
    -- Add Solo Leveling styled decoration
    self:AddSectionDecorations(sectionContainer)
    
    return section
end

function Tab:AddSectionDecorations(sectionContainer)
    -- Add subtle circuit-like patterns to section
    for i = 1, 3 do
        local circuit = Instance.new("Frame")
        circuit.Name = "CircuitLine_" .. i
        circuit.BackgroundColor3 = self.Theme.BorderColor
        circuit.BackgroundTransparency = 0.85
        circuit.BorderSizePixel = 0
        
        -- Randomize placement and size
        local thickness = 1
        local length = math.random(20, 100)
        local xPos = math.random(10, 200)
        local yPos = math.random(10, 40)
        
        -- Horizontal or vertical line
        local isHorizontal = i % 2 == 0
        if isHorizontal then
            circuit.Size = UDim2.new(0, length, 0, thickness)
            circuit.Position = UDim2.new(0, xPos, 0, yPos)
        else
            circuit.Size = UDim2.new(0, thickness, 0, length)
            circuit.Position = UDim2.new(0, xPos, 0, yPos)
        end
        
        -- Add rounded corners
        local cornerRadius = Instance.new("UICorner")
        cornerRadius.CornerRadius = UDim.new(1, 0)
        cornerRadius.Parent = circuit
        
        circuit.Parent = sectionContainer
        
        -- Add slight pulsing animation
        spawn(function()
            while sectionContainer.Parent do
                local transparency = 0.85 + (math.sin(tick() * 0.3 + i) * 0.1)
                circuit.BackgroundTransparency = transparency
                wait(0.03)
            end
        end)
    end
end

function Tab:UpdateTheme(newTheme)
    self.Theme = newTheme
    
    -- Update all sections
    for _, section in ipairs(self.Sections) do
        section.Container.BackgroundColor3 = self.Theme.Secondary
        section.Header.TextColor3 = self.Theme.Text
        section.Header.Font = self.Theme.Font
        
        -- Update border glow
        local border = section.Container:FindFirstChildOfClass("UIStroke")
        if border then
            border.Color = self.Theme.BorderColor
        end
        
        -- Update all elements in the section
        for _, element in ipairs(section.Elements) do
            if element.UpdateTheme then
                element:UpdateTheme(self.Theme)
            end
        end
    end
end

return Tab
