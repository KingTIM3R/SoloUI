--[[
    ColorPicker Component for SoloUI
    Creates color selection UI with solo leveling-themed styling
]]

local ColorPicker = {}
ColorPicker.__index = ColorPicker

-- Import dependencies
local TweenLib = {} -- Will be properly loaded in Create function

function ColorPicker:Create(section, config)
    local self = setmetatable({}, ColorPicker)
    self.Section = section
    self.Name = config.Name
    self.Value = config.Default or Color3.fromRGB(255, 255, 255)
    self.Callback = config.Callback
    self.Flag = config.Flag
    self.Theme = section.Theme
    self.Open = false
    
    -- Load dependencies if not already loaded
    if not getfenv().SoloUITweenLibLoaded then
        TweenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Utilities/TweenLib.lua"))()
        getfenv().SoloUITweenLibLoaded = true
    else
        TweenLib = getfenv().SoloUITweenLib
    end
    
    -- Create colorpicker container
    self.Container = Instance.new("Frame")
    self.Container.Name = "ColorPicker_" .. self.Name
    self.Container.Size = UDim2.new(1, 0, 0, 50)
    self.Container.ClipsDescendants = true
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = section.ElementsContainer
    
    -- Create label
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -60, 0, 20)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.TextColor3 = self.Theme.Text
    self.Label.TextSize = 14
    self.Label.Font = self.Theme.Font
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Text = self.Name
    self.Label.Parent = self.Container
    
    -- Create color preview
    self.ColorPreview = Instance.new("Frame")
    self.ColorPreview.Name = "ColorPreview"
    self.ColorPreview.Size = UDim2.new(0, 30, 0, 20)
    self.ColorPreview.Position = UDim2.new(1, -40, 0, 0)
    self.ColorPreview.BackgroundColor3 = self.Value
    self.ColorPreview.BorderSizePixel = 0
    self.ColorPreview.Parent = self.Container
    
    -- Add corner radius to preview
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = self.ColorPreview
    
    -- Add border stroke to preview
    local previewBorder = Instance.new("UIStroke")
    previewBorder.Thickness = 1
    previewBorder.Color = self.Theme.BorderColor
    previewBorder.Transparency = 0.7
    previewBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    previewBorder.Parent = self.ColorPreview
    
    -- Create color picker button
    self.PickerButton = Instance.new("TextButton")
    self.PickerButton.Name = "PickerButton"
    self.PickerButton.Size = UDim2.new(1, 0, 0, 30)
    self.PickerButton.Position = UDim2.new(0, 0, 0, 20)
    self.PickerButton.BackgroundColor3 = self.Theme.Secondary
    self.PickerButton.BackgroundTransparency = 0.5
    self.PickerButton.BorderSizePixel = 0
    self.PickerButton.TextColor3 = self.Theme.Text
    self.PickerButton.TextSize = 14
    self.PickerButton.Font = self.Theme.Font
    self.PickerButton.Text = "Select Color"
    self.PickerButton.AutoButtonColor = false
    self.PickerButton.Parent = self.Container
    
    -- Add corner radius to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = self.Theme.CornerRadius
    buttonCorner.Parent = self.PickerButton
    
    -- Add border stroke to button
    local buttonBorder = Instance.new("UIStroke")
    buttonBorder.Thickness = 1
    buttonBorder.Color = self.Theme.BorderColor
    buttonBorder.Transparency = 0.7
    buttonBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonBorder.Parent = self.PickerButton
    
    -- Create color picker panel
    self.PickerPanel = Instance.new("Frame")
    self.PickerPanel.Name = "PickerPanel"
    self.PickerPanel.Size = UDim2.new(1, 0, 0, 120)
    self.PickerPanel.Position = UDim2.new(0, 0, 0, 50)
    self.PickerPanel.BackgroundColor3 = self.Theme.Secondary
    self.PickerPanel.BackgroundTransparency = 0.3
    self.PickerPanel.BorderSizePixel = 0
    self.PickerPanel.Visible = false
    self.PickerPanel.Parent = self.Container
    
    -- Add corner radius to panel
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = self.Theme.CornerRadius
    panelCorner.Parent = self.PickerPanel
    
    -- Add border stroke to panel
    local panelBorder = Instance.new("UIStroke")
    panelBorder.Thickness = 1
    panelBorder.Color = self.Theme.BorderColor
    panelBorder.Transparency = 0.7
    panelBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    panelBorder.Parent = self.PickerPanel
    
    -- Create HSV color picker
    self:CreateHSVPicker()
    
    -- Create RGB sliders
    self:CreateRGBSliders()
    
    -- Add holographic effects
    self:AddHolographicEffects()
    
    -- Add button functionality
    self.PickerButton.MouseButton1Click:Connect(function()
        self:ToggleColorPicker()
    end)
    
    -- Add hover effects
    self.PickerButton.MouseEnter:Connect(function()
        self:HandleHover(true)
    end)
    
    self.PickerButton.MouseLeave:Connect(function()
        self:HandleHover(false)
    end)
    
    -- Set initial color
    self:SetColor(self.Value)
    
    return self
end

function ColorPicker:CreateHSVPicker()
    -- Create color saturation/value square
    self.SVPicker = Instance.new("ImageButton")
    self.SVPicker.Name = "SVPicker"
    self.SVPicker.Size = UDim2.new(0, 100, 0, 100)
    self.SVPicker.Position = UDim2.new(0, 10, 0, 10)
    self.SVPicker.BackgroundColor3 = Color3.fromHSV(1, 1, 1)
    self.SVPicker.BorderSizePixel = 0
    self.SVPicker.AutoButtonColor = false
    self.SVPicker.Image = "rbxassetid://4155801252" -- Saturation/Value square
    self.SVPicker.Parent = self.PickerPanel
    
    -- Add SV cursor
    self.SVCursor = Instance.new("Frame")
    self.SVCursor.Name = "SVCursor"
    self.SVCursor.Size = UDim2.new(0, 6, 0, 6)
    self.SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    self.SVCursor.Position = UDim2.new(1, 0, 0, 0) -- Will be updated based on current color
    self.SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    self.SVCursor.BorderSizePixel = 0
    self.SVCursor.ZIndex = 2
    self.SVCursor.Parent = self.SVPicker
    
    -- Add corner radius to cursor
    local cursorCorner = Instance.new("UICorner")
    cursorCorner.CornerRadius = UDim.new(1, 0)
    cursorCorner.Parent = self.SVCursor
    
    -- Create hue slider
    self.HuePicker = Instance.new("ImageButton")
    self.HuePicker.Name = "HuePicker"
    self.HuePicker.Size = UDim2.new(0, 20, 0, 100)
    self.HuePicker.Position = UDim2.new(0, 120, 0, 10)
    self.HuePicker.BackgroundColor3 = Color3.new(1, 1, 1)
    self.HuePicker.BorderSizePixel = 0
    self.HuePicker.AutoButtonColor = false
    self.HuePicker.Image = "rbxassetid://4155801252" -- Will use color overlay for hue
    self.HuePicker.Parent = self.PickerPanel
    
    -- Create hue gradient
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),   -- Red
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), -- Yellow
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),   -- Green
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),   -- Cyan
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),   -- Blue
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), -- Magenta
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))    -- Red
    })
    hueGradient.Parent = self.HuePicker
    
    -- Add hue cursor
    self.HueCursor = Instance.new("Frame")
    self.HueCursor.Name = "HueCursor"
    self.HueCursor.Size = UDim2.new(1, 4, 0, 2)
    self.HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    self.HueCursor.Position = UDim2.new(0.5, 0, 0, 0) -- Will be updated based on current hue
    self.HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    self.HueCursor.BorderSizePixel = 0
    self.HueCursor.ZIndex = 2
    self.HueCursor.Parent = self.HuePicker
    
    -- SV Picker functionality
    self.SVPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingSV = true
            self:UpdateSVFromInput(input)
        end
    end)
    
    self.SVPicker.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingSV = false
        end
    end)
    
    -- Hue Picker functionality
    self.HuePicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingHue = true
            self:UpdateHueFromInput(input)
        end
    end)
    
    self.HuePicker.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingHue = false
        end
    end)
    
    -- Mouse movement handling
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if self.DraggingSV then
                self:UpdateSVFromInput(input)
            elseif self.DraggingHue then
                self:UpdateHueFromInput(input)
            end
        end
    end)
end

function ColorPicker:CreateRGBSliders()
    -- Create RGB value displays
    self.RGBDisplay = Instance.new("Frame")
    self.RGBDisplay.Name = "RGBDisplay"
    self.RGBDisplay.Size = UDim2.new(0, 150, 0, 30)
    self.RGBDisplay.Position = UDim2.new(0, 150, 0, 10)
    self.RGBDisplay.BackgroundTransparency = 1
    self.RGBDisplay.BorderSizePixel = 0
    self.RGBDisplay.Parent = self.PickerPanel
    
    -- Create R value display
    self.RValue = Instance.new("TextLabel")
    self.RValue.Name = "RValue"
    self.RValue.Size = UDim2.new(0, 45, 0, 20)
    self.RValue.Position = UDim2.new(0, 0, 0, 0)
    self.RValue.BackgroundColor3 = self.Theme.Primary
    self.RValue.BackgroundTransparency = 0.5
    self.RValue.BorderSizePixel = 0
    self.RValue.TextColor3 = self.Theme.Text
    self.RValue.TextSize = 12
    self.RValue.Font = self.Theme.Font
    self.RValue.Text = "R: 255"
    self.RValue.Parent = self.RGBDisplay
    
    -- Add corner radius
    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 4)
    rCorner.Parent = self.RValue
    
    -- Create G value display
    self.GValue = Instance.new("TextLabel")
    self.GValue.Name = "GValue"
    self.GValue.Size = UDim2.new(0, 45, 0, 20)
    self.GValue.Position = UDim2.new(0, 50, 0, 0)
    self.GValue.BackgroundColor3 = self.Theme.Primary
    self.GValue.BackgroundTransparency = 0.5
    self.GValue.BorderSizePixel = 0
    self.GValue.TextColor3 = self.Theme.Text
    self.GValue.TextSize = 12
    self.GValue.Font = self.Theme.Font
    self.GValue.Text = "G: 255"
    self.GValue.Parent = self.RGBDisplay
    
    -- Add corner radius
    local gCorner = Instance.new("UICorner")
    gCorner.CornerRadius = UDim.new(0, 4)
    gCorner.Parent = self.GValue
    
    -- Create B value display
    self.BValue = Instance.new("TextLabel")
    self.BValue.Name = "BValue"
    self.BValue.Size = UDim2.new(0, 45, 0, 20)
    self.BValue.Position = UDim2.new(0, 100, 0, 0)
    self.BValue.BackgroundColor3 = self.Theme.Primary
    self.BValue.BackgroundTransparency = 0.5
    self.BValue.BorderSizePixel = 0
    self.BValue.TextColor3 = self.Theme.Text
    self.BValue.TextSize = 12
    self.BValue.Font = self.Theme.Font
    self.BValue.Text = "B: 255"
    self.BValue.Parent = self.RGBDisplay
    
    -- Add corner radius
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = self.BValue
    
    -- Add hex value display
    self.HexValue = Instance.new("TextLabel")
    self.HexValue.Name = "HexValue"
    self.HexValue.Size = UDim2.new(0, 100, 0, 20)
    self.HexValue.Position = UDim2.new(0, 150, 0, 70)
    self.HexValue.BackgroundColor3 = self.Theme.Primary
    self.HexValue.BackgroundTransparency = 0.5
    self.HexValue.BorderSizePixel = 0
    self.HexValue.TextColor3 = self.Theme.Text
    self.HexValue.TextSize = 12
    self.HexValue.Font = self.Theme.Font
    self.HexValue.Text = "#FFFFFF"
    self.HexValue.Parent = self.PickerPanel
    
    -- Add corner radius
    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 4)
    hexCorner.Parent = self.HexValue
    
    -- Add copy button for hex
    self.CopyButton = Instance.new("TextButton")
    self.CopyButton.Name = "CopyButton"
    self.CopyButton.Size = UDim2.new(0, 60, 0, 20)
    self.CopyButton.Position = UDim2.new(0, 255, 0, 70)
    self.CopyButton.BackgroundColor3 = self.Theme.Primary
    self.CopyButton.BackgroundTransparency = 0.5
    self.CopyButton.BorderSizePixel = 0
    self.CopyButton.TextColor3 = self.Theme.Text
    self.CopyButton.TextSize = 12
    self.CopyButton.Font = self.Theme.Font
    self.CopyButton.Text = "Copy"
    self.CopyButton.AutoButtonColor = false
    self.CopyButton.Parent = self.PickerPanel
    
    -- Add corner radius
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 4)
    copyCorner.Parent = self.CopyButton
    
    -- Copy button functionality
    self.CopyButton.MouseButton1Click:Connect(function()
        -- Copy hex value to clipboard if supported
        if setclipboard then
            setclipboard(self.HexValue.Text)
            
            -- Visual feedback
            local originalText = self.CopyButton.Text
            self.CopyButton.Text = "Copied!"
            
            spawn(function()
                wait(1)
                if self.CopyButton then
                    self.CopyButton.Text = originalText
                end
            end)
        else
            -- Fallback for executors without clipboard support
            self.CopyButton.Text = "Not supported"
            
            spawn(function()
                wait(1)
                if self.CopyButton then
                    self.CopyButton.Text = "Copy"
                end
            end)
        end
    end)
    
    -- Add hover effect for copy button
    self.CopyButton.MouseEnter:Connect(function()
        TweenLib:Create(self.CopyButton, 0.2, {
            BackgroundTransparency = 0.3,
            TextColor3 = self.Theme.Accent
        }):Play()
    end)
    
    self.CopyButton.MouseLeave:Connect(function()
        TweenLib:Create(self.CopyButton, 0.2, {
            BackgroundTransparency = 0.5,
            TextColor3 = self.Theme.Text
        }):Play()
    end)
end

function ColorPicker:AddHolographicEffects()
    -- Add holographic solo leveling-themed effects
    
    -- Add circuit-like pattern to button
    local circuit = Instance.new("Frame")
    circuit.Name = "Circuit"
    circuit.Size = UDim2.new(0, 20, 0, 1)
    circuit.Position = UDim2.new(0, 5, 0.8, 0)
    circuit.BackgroundColor3 = self.Theme.Accent
    circuit.BackgroundTransparency = 0.7
    circuit.BorderSizePixel = 0
    circuit.Parent = self.PickerButton
    
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
    circuitDot.Parent = self.PickerButton
    
    -- Add corner radius to circuit dot
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = circuitDot
    
    -- Add glow around color preview
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891970" -- Radial gradient
    glow.ImageColor3 = self.Value
    glow.ImageTransparency = 0.85
    glow.ZIndex = 0
    glow.Parent = self.ColorPreview
    
    -- Animate circuit and glow
    spawn(function()
        while self.Container.Parent do
            circuit.BackgroundTransparency = 0.7 + (math.sin(tick() * 2) * 0.2)
            circuitDot.BackgroundTransparency = 0.5 + (math.sin(tick() * 2) * 0.3)
            glow.ImageTransparency = 0.85 + (math.sin(tick() * 1.5) * 0.1)
            wait(0.03)
        end
    end)
end

function ColorPicker:HandleHover(hovering)
    if hovering then
        -- Mouse enter effect
        TweenLib:Create(self.PickerButton, 0.2, {
            BackgroundTransparency = 0.4
        }):Play()
        
        -- Brighten border
        local border = self.PickerButton:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.3
            }):Play()
        end
    else
        -- Mouse leave effect
        TweenLib:Create(self.PickerButton, 0.2, {
            BackgroundTransparency = 0.5
        }):Play()
        
        -- Reset border
        local border = self.PickerButton:FindFirstChildOfClass("UIStroke")
        if border then
            TweenLib:Create(border, 0.2, {
                Transparency = 0.7
            }):Play()
        end
    end
end

function ColorPicker:UpdateSVFromInput(input)
    local svAbsPos = self.SVPicker.AbsolutePosition
    local svAbsSize = self.SVPicker.AbsoluteSize
    
    local relativeX = math.clamp((input.Position.X - svAbsPos.X) / svAbsSize.X, 0, 1)
    local relativeY = math.clamp((input.Position.Y - svAbsPos.Y) / svAbsSize.Y, 0, 1)
    
    -- Update cursor position
    self.SVCursor.Position = UDim2.new(relativeX, 0, relativeY, 0)
    
    -- Update color
    local h, _, _ = Color3.toHSV(self.SVPicker.BackgroundColor3)
    local color = Color3.fromHSV(h, relativeX, 1 - relativeY)
    
    self:SetColor(color)
end

function ColorPicker:UpdateHueFromInput(input)
    local hueAbsPos = self.HuePicker.AbsolutePosition
    local hueAbsSize = self.HuePicker.AbsoluteSize
    
    local relativeY = math.clamp((input.Position.Y - hueAbsPos.Y) / hueAbsSize.Y, 0, 1)
    
    -- Update cursor position
    self.HueCursor.Position = UDim2.new(0.5, 0, relativeY, 0)
    
    -- Update hue
    local h = 1 - relativeY
    local s, v = self:GetSaturationValue()
    local color = Color3.fromHSV(h, s, v)
    
    -- Update saturation/value picker's color
    self.SVPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    
    self:SetColor(color)
end

function ColorPicker:GetSaturationValue()
    local relativeX = self.SVCursor.Position.X.Scale
    local relativeY = self.SVCursor.Position.Y.Scale
    
    return relativeX, 1 - relativeY
end

function ColorPicker:SetColor(color)
    -- Store the color
    self.Value = color
    
    -- Update color preview
    self.ColorPreview.BackgroundColor3 = color
    
    -- Update glow color
    local glow = self.ColorPreview:FindFirstChild("Glow")
    if glow then
        glow.ImageColor3 = color
    end
    
    -- Update HSV picker
    local h, s, v = Color3.toHSV(color)
    
    -- Update SV cursor position
    self.SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
    
    -- Update Hue cursor position
    self.HueCursor.Position = UDim2.new(0.5, 0, 1 - h, 0)
    
    -- Update SV picker background
    self.SVPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    
    -- Update RGB displays
    local r, g, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)
    self.RValue.Text = "R: " .. r
    self.GValue.Text = "G: " .. g
    self.BValue.Text = "B: " .. b
    
    -- Update hex value
    self.HexValue.Text = string.format("#%02X%02X%02X", r, g, b)
    
    -- Update flag
    if self.Flag then
        self.Section.Tab.Window.UI.Flags[self.Flag] = color
    end
    
    -- Call callback
    pcall(function()
        self.Callback(color)
    end)
end

function ColorPicker:ToggleColorPicker()
    self.Open = not self.Open
    
    if self.Open then
        -- Show color picker panel
        self.PickerPanel.Visible = true
        
        -- Resize container to fit panel
        TweenLib:Create(self.Container, 0.2, {
            Size = UDim2.new(1, 0, 0, 170)
        }):Play()
        
        -- Add holographic glow effect
        local glow = Instance.new("ImageLabel")
        glow.Name = "PanelGlow"
        glow.Size = UDim2.new(1, 30, 1, 30)
        glow.Position = UDim2.new(0.5, 0, 0.5, 0)
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://4996891970" -- Radial gradient
        glow.ImageColor3 = self.Theme.Accent
        glow.ImageTransparency = 0.9
        glow.ZIndex = 0
        glow.Parent = self.PickerPanel
        
        -- Animate glow
        spawn(function()
            while self.Open and glow and glow.Parent do
                glow.ImageTransparency = 0.85 + (math.sin(tick() * 1.5) * 0.1)
                wait(0.03)
            end
        end)
    else
        -- Resize container
        TweenLib:Create(self.Container, 0.2, {
            Size = UDim2.new(1, 0, 0, 50)
        }):Play()
        
        -- Hide panel after animation
        spawn(function()
            wait(0.2)
            self.PickerPanel.Visible = false
            
            -- Remove glow effect
            local glow = self.PickerPanel:FindFirstChild("PanelGlow")
            if glow then
                glow:Destroy()
            end
        end)
    end
end

function ColorPicker:UpdateTheme(newTheme)
    self.Theme = newTheme
    
    -- Update appearance
    self.Label.TextColor3 = self.Theme.Text
    self.Label.Font = self.Theme.Font
    
    self.PickerButton.BackgroundColor3 = self.Theme.Secondary
    self.PickerButton.TextColor3 = self.Theme.Text
    self.PickerButton.Font = self.Theme.Font
    
    self.PickerPanel.BackgroundColor3 = self.Theme.Secondary
    
    -- Update RGB displays
    self.RValue.BackgroundColor3 = self.Theme.Primary
    self.RValue.TextColor3 = self.Theme.Text
    self.RValue.Font = self.Theme.Font
    
    self.GValue.BackgroundColor3 = self.Theme.Primary
    self.GValue.TextColor3 = self.Theme.Text
    self.GValue.Font = self.Theme.Font
    
    self.BValue.BackgroundColor3 = self.Theme.Primary
    self.BValue.TextColor3 = self.Theme.Text
    self.BValue.Font = self.Theme.Font
    
    self.HexValue.BackgroundColor3 = self.Theme.Primary
    self.HexValue.TextColor3 = self.Theme.Text
    self.HexValue.Font = self.Theme.Font
    
    self.CopyButton.BackgroundColor3 = self.Theme.Primary
    self.CopyButton.TextColor3 = self.Theme.Text
    self.CopyButton.Font = self.Theme.Font
    
    -- Update borders
    local buttonBorder = self.PickerButton:FindFirstChildOfClass("UIStroke")
    if buttonBorder then
        buttonBorder.Color = self.Theme.BorderColor
    end
    
    local previewBorder = self.ColorPreview:FindFirstChildOfClass("UIStroke")
    if previewBorder then
        previewBorder.Color = self.Theme.BorderColor
    end
    
    local panelBorder = self.PickerPanel:FindFirstChildOfClass("UIStroke")
    if panelBorder then
        panelBorder.Color = self.Theme.BorderColor
    end
    
    -- Update circuit effects
    local circuit = self.PickerButton:FindFirstChild("Circuit")
    if circuit then
        circuit.BackgroundColor3 = self.Theme.Accent
    end
    
    local circuitDot = self.PickerButton:FindFirstChild("CircuitDot")
    if circuitDot then
        circuitDot.BackgroundColor3 = self.Theme.Accent
    end
end

return ColorPicker
