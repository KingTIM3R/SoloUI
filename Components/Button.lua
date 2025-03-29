--[[
    Button Component for SoloUI
    Creates interactive buttons with solo leveling-themed styling
]]

local Button = {}
Button.__index = Button

-- Import dependencies
local TweenLib = {} -- Will be properly loaded in Create function

function Button:Create(section, config)
    local self = setmetatable({}, Button)
    self.Section = section
    self.Name = config.Name
    self.Callback = config.Callback
    self.Theme = section.Theme
    
    -- Load dependencies if not already loaded
    if not getfenv().SoloUITweenLibLoaded then
        TweenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Utilities/TweenLib.lua"))()
        getfenv().SoloUITweenLibLoaded = true
    else
        TweenLib = getfenv().SoloUITweenLib
    end
    
    -- Create button container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Button_" .. self.Name
    self.Container.Size = UDim2.new(1, 0, 0, 32)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = section.ElementsContainer
    
    -- Create actual button
    self.Button = Instance.new("TextButton")
    self.Button.Name = "ButtonElement"
    self.Button.Size = UDim2.new(1, 0, 1, 0)
    self.Button.BackgroundColor3 = self.Theme.Primary
    self.Button.BackgroundTransparency = 0.6
    self.Button.BorderSizePixel = 0
    self.Button.TextColor3 = self.Theme.Text
    self.Button.TextSize = 14
    self.Button.Font = self.Theme.Font
    self.Button.Text = self.Name
    self.Button.ClipsDescendants = true
    self.Button.AutoButtonColor = false
    self.Button.Parent = self.Container
    
    -- Add corner radius
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = self.Theme.CornerRadius
    cornerRadius.Parent = self.Button
    
    -- Add border stroke
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = self.Theme.BorderColor
    border.Transparency = 0.7
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Parent = self.Button
    
    -- Add solo leveling-themed decorations
    self:AddButtonDecorations()
    
    -- Add button functionality
    self.Button.MouseButton1Click:Connect(function()
        self:HandleClick()
    end)
    
    -- Add hover effects
    self.Button.MouseEnter:Connect(function()
        self:HandleHover(true)
    end)
    
    self.Button.MouseLeave:Connect(function()
        self:HandleHover(false)
    end)
    
    return self
end

function Button:AddButtonDecorations()
    -- Add holographic effect elements (solo leveling system-like)
    
    -- Add circuit-like decorative line
    local circuit = Instance.new("Frame")
    circuit.Name = "CircuitLine"
    circuit.Size = UDim2.new(0, 20, 0, 1)
    circuit.Position = UDim2.new(0, 5, 0.5, 0)
    circuit.BackgroundColor3 = self.Theme.Accent
    circuit.BackgroundTransparency = 0.5
    circuit.BorderSizePixel = 0
    circuit.ZIndex = 2
    circuit.Parent = self.Button
    
    -- Add corner radius to circuit line
    local circuitCorner = Instance.new("UICorner")
    circuitCorner.CornerRadius = UDim.new(1, 0)
    circuitCorner.Parent = circuit
    
    -- Add subtle glow effect
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(0, 30, 0, 30)
    glow.Position = UDim2.new(0, 0, 0.5, -15)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891970" -- Radial gradient
    glow.ImageColor3 = self.Theme.Accent
    glow.ImageTransparency = 0.85
    glow.Parent = self.Button
    
    -- Animate circuit line
    spawn(function()
        while self.Button.Parent do
            circuit.BackgroundTransparency = 0.5 + (math.sin(tick() * 2) * 0.2)
            glow.ImageTransparency = 0.85 + (math.sin(tick() * 2) * 0.1)
            wait(0.03)
        end
    end)
    
    -- Add click ripple effect
    self.RippleFunction = function(clickPos)
        -- Create ripple
        local ripple = Instance.new("Frame")
        ripple.Name = "ClickRipple"
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.BorderSizePixel = 0
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.85
        ripple.Position = UDim2.new(0, clickPos.X - self.Button.AbsolutePosition.X, 0, clickPos.Y - self.Button.AbsolutePosition.Y)
        ripple.Parent = self.Button
        
        -- Add corner radius
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        -- Animate the ripple
        local size = math.max(self.Button.AbsoluteSize.X, self.Button.AbsoluteSize.Y) * 2
        TweenLib:Create(ripple, 0.5, {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }):Play()
        
        -- Clean up ripple
        spawn(function()
            wait(0.5)
            ripple:Destroy()
        end)
    end
end

function Button:HandleClick()
    -- Play click animation
    TweenLib:Create(self.Button, 0.1, {
        BackgroundTransparency = 0.4,
        Size = UDim2.new(0.98, 0, 0.9, 0),
        Position = UDim2.new(0.01, 0, 0.05, 0)
    }):Play()
    
    -- Create ripple effect from center
    local center = Vector2.new(
        self.Button.AbsolutePosition.X + (self.Button.AbsoluteSize.X / 2),
        self.Button.AbsolutePosition.Y + (self.Button.AbsoluteSize.Y / 2)
    )
    self.RippleFunction(center)
    
    -- Revert to normal state
    spawn(function()
        wait(0.1)
        TweenLib:Create(self.Button, 0.1, {
            BackgroundTransparency = 0.6,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end)
    
    -- Call the callback
    pcall(self.Callback)
end

function Button:HandleHover(hovering)
    if hovering then
        -- Mouse enter effect
        TweenLib:Create(self.Button, 0.2, {
            BackgroundTransparency = 0.5,
            TextColor3 = self.Theme.Accent
        }):Play()
        
        -- Brighten border
        local border = self.Button:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.3
            }):Play()
        end
        
        -- Scale circuit line
        local circuit = self.Button:FindFirstChild("CircuitLine")
        if circuit then
            TweenLib:Create(circuit, 0.3, {
                Size = UDim2.new(0, 40, 0, 1)
            }):Play()
        end
    else
        -- Mouse leave effect
        TweenLib:Create(self.Button, 0.2, {
            BackgroundTransparency = 0.6,
            TextColor3 = self.Theme.Text
        }):Play()
        
        -- Reset border
        local border = self.Button:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.7
            }):Play()
        end
        
        -- Reset circuit line
        local circuit = self.Button:FindFirstChild("CircuitLine")
        if circuit then
            TweenLib:Create(circuit, 0.3, {
                Size = UDim2.new(0, 20, 0, 1)
            }):Play()
        end
    end
end

function Button:UpdateTheme(newTheme)
    self.Theme = newTheme
    
    -- Update button appearance
    self.Button.BackgroundColor3 = self.Theme.Primary
    self.Button.TextColor3 = self.Theme.Text
    self.Button.Font = self.Theme.Font
    
    -- Update border
    local border = self.Button:FindFirstChildOfClass("UIStroke")
    if border then
        border.Color = self.Theme.BorderColor
    end
    
    -- Update circuit line
    local circuit = self.Button:FindFirstChild("CircuitLine")
    if circuit then
        circuit.BackgroundColor3 = self.Theme.Accent
    end
    
    -- Update glow
    local glow = self.Button:FindFirstChild("Glow")
    if glow then
        glow.ImageColor3 = self.Theme.Accent
    end
end

function Button:SetText(text)
    self.Name = text
    self.Button.Text = text
end

return Button
