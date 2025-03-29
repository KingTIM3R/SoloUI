--[[
    Toggle Component for SoloUI
    Creates interactive toggle switches with solo leveling-themed styling
]]

local Toggle = {}
Toggle.__index = Toggle

-- Import dependencies
local TweenLib = {} -- Will be properly loaded in Create function

function Toggle:Create(section, config)
    local self = setmetatable({}, Toggle)
    self.Section = section
    self.Name = config.Name
    self.Value = config.Default or false
    self.Callback = config.Callback
    self.Flag = config.Flag
    self.Theme = section.Theme
    
    -- Load dependencies if not already loaded
    if not getfenv().SoloUITweenLibLoaded then
        TweenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Utilities/TweenLib.lua"))()
        getfenv().SoloUITweenLibLoaded = true
    else
        TweenLib = getfenv().SoloUITweenLib
    end
    
    -- Create toggle container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Toggle_" .. self.Name
    self.Container.Size = UDim2.new(1, 0, 0, 32)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = section.ElementsContainer
    
    -- Create label
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -50, 1, 0)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.TextColor3 = self.Theme.Text
    self.Label.TextSize = 14
    self.Label.Font = self.Theme.Font
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Text = self.Name
    self.Label.Parent = self.Container
    
    -- Create toggle switch
    self.ToggleFrame = Instance.new("Frame")
    self.ToggleFrame.Name = "ToggleFrame"
    self.ToggleFrame.Size = UDim2.new(0, 36, 0, 18)
    self.ToggleFrame.Position = UDim2.new(1, -42, 0.5, -9)
    self.ToggleFrame.BackgroundColor3 = self.Theme.Secondary
    self.ToggleFrame.BackgroundTransparency = 0.5
    self.ToggleFrame.BorderSizePixel = 0
    self.ToggleFrame.Parent = self.Container
    
    -- Add corner radius to toggle frame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = self.ToggleFrame
    
    -- Add border stroke
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = self.Theme.BorderColor
    border.Transparency = 0.7
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Parent = self.ToggleFrame
    
    -- Create toggle indicator
    self.Indicator = Instance.new("Frame")
    self.Indicator.Name = "Indicator"
    self.Indicator.Size = UDim2.new(0, 14, 0, 14)
    self.Indicator.Position = UDim2.new(0, 2, 0.5, -7)
    self.Indicator.BackgroundColor3 = self.Theme.Text
    self.Indicator.BorderSizePixel = 0
    self.Indicator.Parent = self.ToggleFrame
    
    -- Add corner radius to indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = self.Indicator
    
    -- Add holographic effect
    self:AddHolographicEffects()
    
    -- Add interaction
    self.ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:Toggle()
        end
    end)
    
    -- Add hover effects
    self.ToggleFrame.MouseEnter:Connect(function()
        self:HandleHover(true)
    end)
    
    self.ToggleFrame.MouseLeave:Connect(function()
        self:HandleHover(false)
    end)
    
    -- Set initial state
    self:SetValue(self.Value)
    
    return self
end

function Toggle:AddHolographicEffects()
    -- Add holographic Solo Leveling-themed effects
    
    -- Add glow around indicator
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(0, 24, 0, 24)
    glow.Position = UDim2.new(0.5, -12, 0.5, -12)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891970" -- Radial gradient
    glow.ImageColor3 = self.Theme.Accent
    glow.ImageTransparency = 0.9
    glow.Visible = false
    glow.Parent = self.Indicator
    
    -- Add circuit-like pattern
    local circuit = Instance.new("Frame")
    circuit.Name = "Circuit"
    circuit.Size = UDim2.new(0, 10, 0, 1)
    circuit.Position = UDim2.new(0, -12, 0.5, 0)
    circuit.AnchorPoint = Vector2.new(0, 0.5)
    circuit.BackgroundColor3 = self.Theme.Accent
    circuit.BackgroundTransparency = 0.7
    circuit.BorderSizePixel = 0
    circuit.Parent = self.ToggleFrame
    
    -- Add corner radius to circuit
    local circuitCorner = Instance.new("UICorner")
    circuitCorner.CornerRadius = UDim.new(1, 0)
    circuitCorner.Parent = circuit
    
    -- Animate circuit
    spawn(function()
        while self.Container.Parent do
            circuit.BackgroundTransparency = 0.7 + (math.sin(tick() * 2) * 0.2)
            
            if self.Value then
                glow.ImageTransparency = 0.7 + (math.sin(tick() * 2) * 0.2)
            end
            
            wait(0.03)
        end
    end)
end

function Toggle:HandleHover(hovering)
    if hovering then
        -- Mouse enter effect
        TweenLib:Create(self.ToggleFrame, 0.2, {
            BackgroundTransparency = 0.4
        }):Play()
        
        -- Brighten border
        local border = self.ToggleFrame:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.3
            }):Play()
        end
    else
        -- Mouse leave effect
        TweenLib:Create(self.ToggleFrame, 0.2, {
            BackgroundTransparency = 0.5
        }):Play()
        
        -- Reset border
        local border = self.ToggleFrame:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.7
            }):Play()
        end
    end
end

function Toggle:Toggle()
    self:SetValue(not self.Value)
end

function Toggle:SetValue(value)
    self.Value = value
    
    -- Update UI
    if value then
        -- Animate to enabled state
        TweenLib:Create(self.Indicator, 0.2, {
            Position = UDim2.new(0, 20, 0.5, -7),
            BackgroundColor3 = self.Theme.Accent
        }):Play()
        
        TweenLib:Create(self.ToggleFrame, 0.2, {
            BackgroundColor3 = self.Theme.Primary
        }):Play()
        
        -- Show glow
        local glow = self.Indicator:FindFirstChild("Glow")
        if glow then
            glow.Visible = true
            TweenLib:Create(glow, 0.2, {
                ImageTransparency = 0.7
            }):Play()
        end
    else
        -- Animate to disabled state
        TweenLib:Create(self.Indicator, 0.2, {
            Position = UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = self.Theme.Text
        }):Play()
        
        TweenLib:Create(self.ToggleFrame, 0.2, {
            BackgroundColor3 = self.Theme.Secondary
        }):Play()
        
        -- Hide glow
        local glow = self.Indicator:FindFirstChild("Glow")
        if glow then
            TweenLib:Create(glow, 0.2, {
                ImageTransparency = 1
            }):Play()
            
            spawn(function()
                wait(0.2)
                glow.Visible = false
            end)
        end
    end
    
    -- Update flag value
    if self.Flag then
        self.Section.Tab.Window.UI.Flags[self.Flag] = value
    end
    
    -- Call callback
    pcall(function()
        self.Callback(value)
    end)
end

function Toggle:UpdateTheme(newTheme)
    self.Theme = newTheme
    
    -- Update appearance
    self.Label.TextColor3 = self.Theme.Text
    self.Label.Font = self.Theme.Font
    
    -- Update toggle frame
    if self.Value then
        self.ToggleFrame.BackgroundColor3 = self.Theme.Primary
        self.Indicator.BackgroundColor3 = self.Theme.Accent
    else
        self.ToggleFrame.BackgroundColor3 = self.Theme.Secondary
        self.Indicator.BackgroundColor3 = self.Theme.Text
    end
    
    -- Update border
    local border = self.ToggleFrame:FindFirstChildOfClass("UIStroke")
    if border then
        border.Color = self.Theme.BorderColor
    end
    
    -- Update circuit effect
    local circuit = self.ToggleFrame:FindFirstChild("Circuit")
    if circuit then
        circuit.BackgroundColor3 = self.Theme.Accent
    end
    
    -- Update glow
    local glow = self.Indicator:FindFirstChild("Glow")
    if glow then
        glow.ImageColor3 = self.Theme.Accent
    end
end

return Toggle
