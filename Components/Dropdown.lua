--[[
    Dropdown Component for SoloUI
    Creates dropdown selection UI with solo leveling-themed styling
]]

local Dropdown = {}
Dropdown.__index = Dropdown

-- Import dependencies
local TweenLib = {} -- Will be properly loaded in Create function

function Dropdown:Create(section, config)
    local self = setmetatable({}, Dropdown)
    self.Section = section
    self.Name = config.Name
    self.Options = config.Options or {}
    self.Value = config.Default or (self.Options[1] or "")
    self.Callback = config.Callback
    self.Flag = config.Flag
    self.Theme = section.Theme
    self.Open = false
    
    -- Load dependencies if not already loaded
    if not getfenv().SoloUITweenLibLoaded then
        TweenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingTIM3R/SoloUI/refs/heads/main/Utilities/TweenLib.lua"))()
        getfenv().SoloUITweenLibLoaded = true
    else
        TweenLib = getfenv().SoloUITweenLib
    end
    
    -- Create dropdown container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Dropdown_" .. self.Name
    self.Container.Size = UDim2.new(1, 0, 0, 50)
    self.Container.ClipsDescendants = true
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = section.ElementsContainer
    
    -- Create label
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, 0, 0, 20)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.TextColor3 = self.Theme.Text
    self.Label.TextSize = 14
    self.Label.Font = self.Theme.Font
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Text = self.Name
    self.Label.Parent = self.Container
    
    -- Create dropdown button
    self.DropdownButton = Instance.new("TextButton")
    self.DropdownButton.Name = "DropdownButton"
    self.DropdownButton.Size = UDim2.new(1, 0, 0, 30)
    self.DropdownButton.Position = UDim2.new(0, 0, 0, 20)
    self.DropdownButton.BackgroundColor3 = self.Theme.Secondary
    self.DropdownButton.BackgroundTransparency = 0.5
    self.DropdownButton.BorderSizePixel = 0
    self.DropdownButton.TextColor3 = self.Theme.Text
    self.DropdownButton.TextSize = 14
    self.DropdownButton.Font = self.Theme.Font
    self.DropdownButton.Text = self.Value
    self.DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    self.DropdownButton.AutoButtonColor = false
    self.DropdownButton.Parent = self.Container
    
    -- Add padding for text
    local textPadding = Instance.new("UIPadding")
    textPadding.PaddingLeft = UDim.new(0, 10)
    textPadding.Parent = self.DropdownButton
    
    -- Add corner radius
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = self.Theme.CornerRadius
    buttonCorner.Parent = self.DropdownButton
    
    -- Add border stroke
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = self.Theme.BorderColor
    border.Transparency = 0.7
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Parent = self.DropdownButton
    
    -- Create arrow indicator
    self.Arrow = Instance.new("TextLabel")
    self.Arrow.Name = "Arrow"
    self.Arrow.Size = UDim2.new(0, 20, 0, 20)
    self.Arrow.Position = UDim2.new(1, -25, 0, 5)
    self.Arrow.BackgroundTransparency = 1
    self.Arrow.TextColor3 = self.Theme.Text
    self.Arrow.TextSize = 14
    self.Arrow.Font = Enum.Font.Code
    self.Arrow.Text = "▼"
    self.Arrow.Parent = self.DropdownButton
    
    -- Create dropdown list container
    self.DropdownList = Instance.new("Frame")
    self.DropdownList.Name = "DropdownList"
    self.DropdownList.Size = UDim2.new(1, 0, 0, 0) -- Will be sized based on options
    self.DropdownList.Position = UDim2.new(0, 0, 0, 50)
    self.DropdownList.BackgroundColor3 = self.Theme.Secondary
    self.DropdownList.BackgroundTransparency = 0.3
    self.DropdownList.BorderSizePixel = 0
    self.DropdownList.Visible = false
    self.DropdownList.Parent = self.Container
    
    -- Add corner radius to dropdown list
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = self.Theme.CornerRadius
    listCorner.Parent = self.DropdownList
    
    -- Add border stroke to dropdown list
    local listBorder = Instance.new("UIStroke")
    listBorder.Thickness = 1
    listBorder.Color = self.Theme.BorderColor
    listBorder.Transparency = 0.7
    listBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    listBorder.Parent = self.DropdownList
    
    -- Create option list
    self.OptionList = Instance.new("ScrollingFrame")
    self.OptionList.Name = "OptionList"
    self.OptionList.Size = UDim2.new(1, -10, 1, -10)
    self.OptionList.Position = UDim2.new(0, 5, 0, 5)
    self.OptionList.BackgroundTransparency = 1
    self.OptionList.BorderSizePixel = 0
    self.OptionList.ScrollBarThickness = 3
    self.OptionList.ScrollBarImageColor3 = self.Theme.Accent
    self.OptionList.ScrollBarImageTransparency = 0.5
    self.OptionList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated as options are added
    self.OptionList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.OptionList.Parent = self.DropdownList
    
    -- Add list layout for options
    local optionLayout = Instance.new("UIListLayout")
    optionLayout.Padding = UDim.new(0, 2)
    optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionLayout.Parent = self.OptionList
    
    -- Add solo leveling-themed decorations
    self:AddHolographicEffects()
    
    -- Add button functionality
    self.DropdownButton.MouseButton1Click:Connect(function()
        self:ToggleDropdown()
    end)
    
    -- Add hover effects
    self.DropdownButton.MouseEnter:Connect(function()
        self:HandleHover(true)
    end)
    
    self.DropdownButton.MouseLeave:Connect(function()
        self:HandleHover(false)
    end)
    
    -- Populate options
    self:SetOptions(self.Options)
    
    return self
end

function Dropdown:AddHolographicEffects()
    -- Add holographic solo leveling-themed effects
    
    -- Add circuit-like pattern to button
    local circuit = Instance.new("Frame")
    circuit.Name = "Circuit"
    circuit.Size = UDim2.new(0, 20, 0, 1)
    circuit.Position = UDim2.new(0, 5, 0.8, 0)
    circuit.BackgroundColor3 = self.Theme.Accent
    circuit.BackgroundTransparency = 0.7
    circuit.BorderSizePixel = 0
    circuit.Parent = self.DropdownButton
    
    -- Add corner radius to circuit
    local circuitCorner = Instance.new("UICorner")
    circuitCorner.CornerRadius = UDim.new(1, 0)
    circuitCorner.Parent = circuit
    
    -- Add circuit dot
    local circuitDot = Instance.new("Frame")
    circuitDot.Name = "CircuitDot"
    circuitDot.Size = UDim2.new(0, 3, 0, 3)
    circuitDot.Position = UDim2.new(0, 25, 0.8, -1)
    circuitDot.BackgroundColor3 = self.Theme.Accent
    circuitDot.BackgroundTransparency = 0.5
    circuitDot.BorderSizePixel = 0
    circuitDot.Parent = self.DropdownButton
    
    -- Add corner radius to circuit dot
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = circuitDot
    
    -- Animate circuit
    spawn(function()
        while self.Container.Parent do
            circuit.BackgroundTransparency = 0.7 + (math.sin(tick() * 2) * 0.2)
            circuitDot.BackgroundTransparency = 0.5 + (math.sin(tick() * 2) * 0.3)
            wait(0.03)
        end
    end)
end

function Dropdown:HandleHover(hovering)
    if hovering then
        -- Mouse enter effect
        TweenLib:Create(self.DropdownButton, 0.2, {
            BackgroundTransparency = 0.4
        }):Play()
        
        -- Brighten border
        local border = self.DropdownButton:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.3
            }):Play()
        end
    else
        -- Mouse leave effect
        TweenLib:Create(self.DropdownButton, 0.2, {
            BackgroundTransparency = 0.5
        }):Play()
        
        -- Reset border
        local border = self.DropdownButton:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.7
            }):Play()
        end
    end
end

function Dropdown:CreateOptionButton(option, index)
    local optionButton = Instance.new("TextButton")
    optionButton.Name = "Option_" .. option
    optionButton.Size = UDim2.new(1, 0, 0, 24)
    optionButton.BackgroundColor3 = self.Theme.Primary
    optionButton.BackgroundTransparency = 0.8
    optionButton.BorderSizePixel = 0
    optionButton.TextColor3 = self.Theme.Text
    optionButton.TextSize = 14
    optionButton.Font = self.Theme.Font
    optionButton.Text = option
    optionButton.TextXAlignment = Enum.TextXAlignment.Left
    optionButton.LayoutOrder = index
    optionButton.AutoButtonColor = false
    optionButton.Parent = self.OptionList
    
    -- Add padding for text
    local optionPadding = Instance.new("UIPadding")
    optionPadding.PaddingLeft = UDim.new(0, 10)
    optionPadding.Parent = optionButton
    
    -- Add corner radius
    local optionCorner = Instance.new("UICorner")
    optionCorner.CornerRadius = UDim.new(0, 4)
    optionCorner.Parent = optionButton
    
    -- Option selection
    optionButton.MouseButton1Click:Connect(function()
        self:SetValue(option)
        self:ToggleDropdown()
    end)
    
    -- Option hover effect
    optionButton.MouseEnter:Connect(function()
        TweenLib:Create(optionButton, 0.1, {
            BackgroundTransparency = 0.6,
            TextColor3 = self.Theme.Accent
        }):Play()
    end)
    
    optionButton.MouseLeave:Connect(function()
        TweenLib:Create(optionButton, 0.1, {
            BackgroundTransparency = 0.8,
            TextColor3 = self.Theme.Text
        }):Play()
    end)
    
    return optionButton
end

function Dropdown:SetOptions(options)
    -- Clear existing options
    for _, child in pairs(self.OptionList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Add new options
    self.Options = options
    
    for i, option in ipairs(options) do
        self:CreateOptionButton(option, i)
    end
    
    -- Update dropdown list size
    local maxOptionsVisible = math.min(#options, 5)
    self.DropdownList.Size = UDim2.new(1, 0, 0, maxOptionsVisible * 26)
    
    -- Update container size when open
    if self.Open then
        self.Container.Size = UDim2.new(1, 0, 0, 50 + self.DropdownList.Size.Y.Offset)
    end
    
    -- If current value is not in options list, reset to first option
    local found = false
    for _, option in ipairs(options) do
        if option == self.Value then
            found = true
            break
        end
    end
    
    if not found and #options > 0 then
        self:SetValue(options[1])
    elseif not found then
        self:SetValue("")
    end
end

function Dropdown:SetValue(value)
    if self.Value ~= value then
        self.Value = value
        self.DropdownButton.Text = value
        
        -- Update flag
        if self.Flag then
            self.Section.Tab.Window.UI.Flags[self.Flag] = value
        end
        
        -- Call callback
        pcall(function()
            self.Callback(value)
        end)
    end
end

function Dropdown:ToggleDropdown()
    self.Open = not self.Open
    
    if self.Open then
        -- Show dropdown list
        self.DropdownList.Visible = true
        
        -- Rotate arrow
        TweenLib:Create(self.Arrow, 0.2, {
            Rotation = 180
        }):Play()
        
        -- Resize container to fit dropdown list
        TweenLib:Create(self.Container, 0.2, {
            Size = UDim2.new(1, 0, 0, 50 + self.DropdownList.Size.Y.Offset)
        }):Play()
        
        -- Add holographic glow effect
        local glow = Instance.new("ImageLabel")
        glow.Name = "DropdownGlow"
        glow.Size = UDim2.new(1, 20, 1, 20)
        glow.Position = UDim2.new(0.5, 0, 0.5, 0)
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://4996891970" -- Radial gradient
        glow.ImageColor3 = self.Theme.Accent
        glow.ImageTransparency = 0.9
        glow.ZIndex = 0
        glow.Parent = self.DropdownList
        
        -- Animate glow
        spawn(function()
            while self.Open and glow and glow.Parent do
                glow.ImageTransparency = 0.85 + (math.sin(tick() * 1.5) * 0.1)
                wait(0.03)
            end
        end)
    else
        -- Rotate arrow back
        TweenLib:Create(self.Arrow, 0.2, {
            Rotation = 0
        }):Play()
        
        -- Resize container
        TweenLib:Create(self.Container, 0.2, {
            Size = UDim2.new(1, 0, 0, 50)
        }):Play()
        
        -- Hide dropdown list after animation
        spawn(function()
            wait(0.2)
            self.DropdownList.Visible = false
            
            -- Remove glow effect
            local glow = self.DropdownList:FindFirstChild("DropdownGlow")
            if glow then
                glow:Destroy()
            end
        end)
    end
end

function Dropdown:UpdateTheme(newTheme)
    self.Theme = newTheme
    
    -- Update appearance
    self.Label.TextColor3 = self.Theme.Text
    self.Label.Font = self.Theme.Font
    
    self.DropdownButton.BackgroundColor3 = self.Theme.Secondary
    self.DropdownButton.TextColor3 = self.Theme.Text
    self.DropdownButton.Font = self.Theme.Font
    
    self.Arrow.TextColor3 = self.Theme.Text
    
    self.DropdownList.BackgroundColor3 = self.Theme.Secondary
    
    -- Update borders
    local buttonBorder = self.DropdownButton:FindFirstChildOfClass("UIStroke")
    if buttonBorder then
        buttonBorder.Color = self.Theme.BorderColor
    end
    
    local listBorder = self.DropdownList:FindFirstChildOfClass("UIStroke")
    if listBorder then
        listBorder.Color = self.Theme.BorderColor
    end
    
    -- Update circuit effects
    local circuit = self.DropdownButton:FindFirstChild("Circuit")
    if circuit then
        circuit.BackgroundColor3 = self.Theme.Accent
    end
    
    local circuitDot = self.DropdownButton:FindFirstChild("CircuitDot")
    if circuitDot then
        circuitDot.BackgroundColor3 = self.Theme.Accent
    end
    
    -- Update options
    for _, child in pairs(self.OptionList:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = self.Theme.Primary
            child.TextColor3 = self.Theme.Text
            child.Font = self.Theme.Font
        end
    end
end

return Dropdown
