--[[
    Slider Component for SoloUI
    Creates interactive sliders with solo leveling-themed styling
]]

local Slider = {}
Slider.__index = Slider

-- Import dependencies
local TweenLib = {} -- Will be properly loaded in Create function

function Slider:Create(section, config)
    local self = setmetatable({}, Slider)
    self.Section = section
    self.Name = config.Name
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Value = config.Default or self.Min
    self.Increment = config.Increment or 1
    self.Callback = config.Callback
    self.Flag = config.Flag
    self.Theme = section.Theme
    self.Dragging = false
    
    -- Load dependencies if not already loaded
    if not getfenv().SoloUITweenLibLoaded then
        TweenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Utilities/TweenLib.lua"))()
        getfenv().SoloUITweenLibLoaded = true
    else
        TweenLib = getfenv().SoloUITweenLib
    end
    
    -- Create slider container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Slider_" .. self.Name
    self.Container.Size = UDim2.new(1, 0, 0, 50)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = section.ElementsContainer
    
    -- Create label
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -55, 0, 20)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.TextColor3 = self.Theme.Text
    self.Label.TextSize = 14
    self.Label.Font = self.Theme.Font
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Text = self.Name
    self.Label.Parent = self.Container
    
    -- Create value display
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name = "ValueLabel"
    self.ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    self.ValueLabel.Position = UDim2.new(1, -50, 0, 0)
    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.TextColor3 = self.Theme.Accent
    self.ValueLabel.TextSize = 14
    self.ValueLabel.Font = self.Theme.Font
    self.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.ValueLabel.Text = tostring(self.Value)
    self.ValueLabel.Parent = self.Container
    
    -- Create slider track
    self.SliderTrack = Instance.new("Frame")
    self.SliderTrack.Name = "SliderTrack"
    self.SliderTrack.Size = UDim2.new(1, 0, 0, 6)
    self.SliderTrack.Position = UDim2.new(0, 0, 0, 30)
    self.SliderTrack.BackgroundColor3 = self.Theme.Secondary
    self.SliderTrack.BackgroundTransparency = 0.5
    self.SliderTrack.BorderSizePixel = 0
    self.SliderTrack.Parent = self.Container
    
    -- Add corner radius to track
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = self.SliderTrack
    
    -- Add border stroke
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = self.Theme.BorderColor
    border.Transparency = 0.7
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Parent = self.SliderTrack
    
    -- Create slider fill
    self.SliderFill = Instance.new("Frame")
    self.SliderFill.Name = "SliderFill"
    self.SliderFill.Size = UDim2.new(0, 0, 1, 0)
    self.SliderFill.BackgroundColor3 = self.Theme.Accent
    self.SliderFill.BackgroundTransparency = 0.2
    self.SliderFill.BorderSizePixel = 0
    self.SliderFill.Parent = self.SliderTrack
    
    -- Add corner radius to fill
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = self.SliderFill
    
    -- Create slider thumb
    self.SliderThumb = Instance.new("Frame")
    self.SliderThumb.Name = "SliderThumb"
    self.SliderThumb.Size = UDim2.new(0, 14, 0, 14)
    self.SliderThumb.Position = UDim2.new(0, 0, 0.5, -7)
    self.SliderThumb.BackgroundColor3 = self.Theme.Accent
    self.SliderThumb.BorderSizePixel = 0
    self.SliderThumb.ZIndex = 2
    self.SliderThumb.Parent = self.SliderFill
    
    -- Add corner radius to thumb
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = self.SliderThumb
    
    -- Add Solo Leveling themed decorations
    self:AddHolographicEffects()
    
    -- Add slider functionality
    self:SetupInteraction()
    
    -- Set initial value
    self:SetValue(self.Value)
    
    return self
end

function Slider:AddHolographicEffects()
    -- Add holographic solo leveling-themed effects
    
    -- Add glow to thumb
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(0, 24, 0, 24)
    glow.Position = UDim2.new(0.5, -12, 0.5, -12)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891970" -- Radial gradient
    glow.ImageColor3 = self.Theme.Accent
    glow.ImageTransparency = 0.7
    glow.ZIndex = 1
    glow.Parent = self.SliderThumb
    
    -- Add circuit-like pattern to track
    local circuit = Instance.new("Frame")
    circuit.Name = "Circuit"
    circuit.Size = UDim2.new(0, 20, 0, 1)
    circuit.Position = UDim2.new(0, 5, 0.5, 0)
    circuit.BackgroundColor3 = self.Theme.Accent
    circuit.BackgroundTransparency = 0.5
    circuit.BorderSizePixel = 0
    circuit.Parent = self.SliderTrack
    
    -- Add corner radius to circuit
    local circuitCorner = Instance.new("UICorner")
    circuitCorner.CornerRadius = UDim.new(1, 0)
    circuitCorner.Parent = circuit
    
    -- Animate circuit pattern
    spawn(function()
        while self.Container.Parent do
            circuit.BackgroundTransparency = 0.5 + (math.sin(tick() * 2) * 0.3)
            glow.ImageTransparency = 0.7 + (math.sin(tick() * 1.5) * 0.15)
            wait(0.03)
        end
    end)
    
    -- Add value change particle effect
    self.EmitParticle = function()
        local particle = Instance.new("Frame")
        particle.Name = "Particle"
        particle.Size = UDim2.new(0, 4, 0, 4)
        particle.BackgroundColor3 = self.Theme.Accent
        particle.BackgroundTransparency = 0.5
        particle.BorderSizePixel = 0
        particle.Position = UDim2.new(0.5, -2, 0.5, -2)
        particle.ZIndex = 3
        particle.Parent = self.SliderThumb
        
        -- Add corner radius
        local particleCorner = Instance.new("UICorner")
        particleCorner.CornerRadius = UDim.new(1, 0)
        particleCorner.Parent = particle
        
        -- Animate the particle
        local xOffset = math.random(-20, 20)
        local yOffset = math.random(-20, 20)
        
        TweenLib:Create(particle, 0.4, {
            Position = UDim2.new(0.5, xOffset, 0.5, yOffset),
            Size = UDim2.new(0, 1, 0, 1),
            BackgroundTransparency = 1
        }):Play()
        
        -- Clean up
        spawn(function()
            wait(0.4)
            particle:Destroy()
        end)
    end
end

function Slider:SetupInteraction()
    -- Mouse button events
    self.SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            self:UpdateValue(input.Position.X)
        end
    end)
    
    self.SliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = false
        end
    end)
    
    -- Mouse movement
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            self:UpdateValue(input.Position.X)
        end
    end)
    
    -- Hover effects
    self.SliderTrack.MouseEnter:Connect(function()
        self:HandleHover(true)
    end)
    
    self.SliderTrack.MouseLeave:Connect(function()
        self:HandleHover(false)
    end)
end

function Slider:HandleHover(hovering)
    if hovering then
        -- Mouse enter effect
        TweenLib:Create(self.SliderTrack, 0.2, {
            BackgroundTransparency = 0.4
        }):Play()
        
        -- Brighten border
        local border = self.SliderTrack:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.3
            }):Play()
        end
        
        -- Enlarge thumb slightly
        TweenLib:Create(self.SliderThumb, 0.2, {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8)
        }):Play()
    else
        -- Mouse leave effect
        TweenLib:Create(self.SliderTrack, 0.2, {
            BackgroundTransparency = 0.5
        }):Play()
        
        -- Reset border
        local border = self.SliderTrack:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.7
            }):Play()
        end
        
        -- Reset thumb size
        TweenLib:Create(self.SliderThumb, 0.2, {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 0, 0.5, -7)
        }):Play()
    end
end

function Slider:UpdateValue(posX)
    -- Calculate relative position
    local trackStart = self.SliderTrack.AbsolutePosition.X
    local trackEnd = trackStart + self.SliderTrack.AbsoluteSize.X
    local relativePos = math.clamp((posX - trackStart) / (trackEnd - trackStart), 0, 1)
    
    -- Calculate value based on min/max and increment
    local exactValue = self.Min + (relativePos * (self.Max - self.Min))
    local roundedValue
    
    if self.Increment < 1 then
        -- For decimal increments, round to the nearest increment
        local decimalPlaces = math.log10(1 / self.Increment)
        roundedValue = math.floor(exactValue / self.Increment + 0.5) * self.Increment
        roundedValue = math.floor(roundedValue * 10^decimalPlaces + 0.5) / 10^decimalPlaces
    else
        -- For integer increments
        roundedValue = math.floor(exactValue / self.Increment + 0.5) * self.Increment
    end
    
    -- Clamp the value
    roundedValue = math.clamp(roundedValue, self.Min, self.Max)
    
    -- Set the value
    self:SetValue(roundedValue)
end

function Slider:SetValue(value)
    -- Clamp value to valid range
    value = math.clamp(value, self.Min, self.Max)
    
    -- Check if value changed
    local valueChanged = self.Value ~= value
    self.Value = value
    
    -- Update UI
    local percent = (value - self.Min) / (self.Max - self.Min)
    
    -- Update slider fill
    TweenLib:Create(self.SliderFill, 0.1, {
        Size = UDim2.new(percent, 0, 1, 0)
    }):Play()
    
    -- Update value label
    -- Format to avoid excessive decimals
    local displayValue
    if self.Increment < 1 then
        local decimalPlaces = math.log10(1 / self.Increment)
        displayValue = string.format("%." .. decimalPlaces .. "f", value)
    else
        displayValue = tostring(math.floor(value))
    end
    
    self.ValueLabel.Text = displayValue
    
    -- Update flag
    if self.Flag then
        self.Section.Tab.Window.UI.Flags[self.Flag] = value
    end
    
    -- Call callback if value changed
    if valueChanged then
        pcall(function()
            self.Callback(value)
        end)
        
        -- Emit particle effect for feedback
        if self.EmitParticle then
            self.EmitParticle()
        end
    end
end

function Slider:UpdateTheme(newTheme)
    self.Theme = newTheme
    
    -- Update appearance
    self.Label.TextColor3 = self.Theme.Text
    self.Label.Font = self.Theme.Font
    self.ValueLabel.TextColor3 = self.Theme.Accent
    self.ValueLabel.Font = self.Theme.Font
    
    self.SliderTrack.BackgroundColor3 = self.Theme.Secondary
    self.SliderFill.BackgroundColor3 = self.Theme.Accent
    self.SliderThumb.BackgroundColor3 = self.Theme.Accent
    
    -- Update border
    local border = self.SliderTrack:FindFirstChildOfClass("UIStroke")
    if border then
        border.Color = self.Theme.BorderColor
    end
    
    -- Update glow
    local glow = self.SliderThumb:FindFirstChild("Glow")
    if glow then
        glow.ImageColor3 = self.Theme.Accent
    end
    
    -- Update circuit
    local circuit = self.SliderTrack:FindFirstChild("Circuit")
    if circuit then
        circuit.BackgroundColor3 = self.Theme.Accent
    end
end

return Slider
