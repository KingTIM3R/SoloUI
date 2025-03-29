--[[
    Window Component for SoloUI
    Creates the main window container with tabs
]]

local Window = {}
Window.__index = Window

-- Import dependencies
local TweenLib = {} -- Will be properly loaded in Create function
local Tab = {} -- Will be properly loaded in Create function

function Window:Create(ui, config)
    local self = setmetatable({}, Window)
    self.UI = ui
    self.Title = config.Title or "SoloUI Window"
    self.Size = config.Size or UDim2.new(0, 550, 0, 400)
    self.Position = config.Position or UDim2.new(0.5, -275, 0.5, -200)
    self.Theme = config.Theme or ui.Theme
    self.Tabs = {}
    self.TabButtons = {}
    self.CurrentTab = nil
    self.Draggable = config.Draggable ~= false
    self.TabButtonWidth = config.TabButtonWidth or 160
    
    -- Load dependencies if not already loaded
    if not getfenv().SoloUITweenLibLoaded then
        TweenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingTIM3R/SoloUI/refs/heads/main/Utilities/TweenLib.lua"))()
        getfenv().SoloUITweenLibLoaded = true
    else
        TweenLib = getfenv().SoloUITweenLib
    end
    
    if not getfenv().SoloUITabLoaded then
        Tab = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SoloUI/main/Components/Tab.lua"))()
        getfenv().SoloUITabLoaded = true
    else
        Tab = getfenv().SoloUITab
    end
    
    -- Create window container
    self.Container = Instance.new("Frame")
    self.Container.Name = "SoloUIWindow_" .. self.Title
    self.Container.Size = self.Size
    self.Container.Position = self.Position
    self.Container.BackgroundColor3 = self.Theme.Background
    self.Container.BackgroundTransparency = self.Theme.BackgroundTransparency
    self.Container.BorderSizePixel = 0
    self.Container.Parent = ui.ScreenGui
    
    -- Create rounded corners
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = self.Theme.CornerRadius
    cornerRadius.Parent = self.Container
    
    -- Add blue glow border (holographic effect)
    local borderEffect = Instance.new("UIStroke")
    borderEffect.Thickness = self.Theme.BorderSize
    borderEffect.Color = self.Theme.BorderColor
    borderEffect.Transparency = 0.2
    borderEffect.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    borderEffect.Parent = self.Container
    
    -- Create drop shadow (optional based on Theme)
    if self.Theme.DropShadow then
        local dropShadow = Instance.new("ImageLabel")
        dropShadow.Name = "DropShadow"
        dropShadow.Size = UDim2.new(1, 30, 1, 30)
        dropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        dropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        dropShadow.BackgroundTransparency = 1
        dropShadow.Image = "rbxassetid://7192699148" -- Shadow asset
        dropShadow.ImageColor3 = Color3.fromRGB(0, 0, 30)
        dropShadow.ImageTransparency = 0.6
        dropShadow.ZIndex = -1
        dropShadow.Parent = self.Container
    end
    
    -- Create title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundColor3 = self.Theme.Secondary
    self.TitleBar.BackgroundTransparency = 0.1
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Container
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = self.Theme.CornerRadius
    titleCorner.Parent = self.TitleBar
    
    -- Create title label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "TitleLabel"
    self.TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.TextColor3 = self.Theme.Text
    self.TitleLabel.TextSize = 16
    self.TitleLabel.Font = self.Theme.Font
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Text = self.Title
    self.TitleLabel.Parent = self.TitleBar
    
    -- Create close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 24, 0, 24)
    self.CloseButton.Position = UDim2.new(1, -28, 0, 3)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.TextColor3 = self.Theme.Text
    self.CloseButton.TextSize = 16
    self.CloseButton.Font = self.Theme.Font
    self.CloseButton.Text = "✕"
    self.CloseButton.Parent = self.TitleBar
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleVisibility(false)
    end)
    
    -- Create minimize button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
    self.MinimizeButton.Position = UDim2.new(1, -56, 0, 3)
    self.MinimizeButton.BackgroundTransparency = 1
    self.MinimizeButton.TextColor3 = self.Theme.Text
    self.MinimizeButton.TextSize = 16
    self.MinimizeButton.Font = self.Theme.Font
    self.MinimizeButton.Text = "−"
    self.MinimizeButton.Parent = self.TitleBar
    
    self.Minimized = false
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Create tab container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.Container
    
    -- Create tab navigation
    self.TabNavigation = Instance.new("Frame")
    self.TabNavigation.Name = "TabNavigation"
    self.TabNavigation.Size = UDim2.new(0, self.TabButtonWidth, 1, 0)
    self.TabNavigation.Position = UDim2.new(0, 0, 0, 0)
    self.TabNavigation.BackgroundColor3 = self.Theme.Secondary
    self.TabNavigation.BackgroundTransparency = 0.5
    self.TabNavigation.BorderSizePixel = 0
    self.TabNavigation.Parent = self.TabContainer
    
    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = self.Theme.CornerRadius
    navCorner.Parent = self.TabNavigation
    
    -- Create tab button container
    self.TabButtonContainer = Instance.new("ScrollingFrame")
    self.TabButtonContainer.Name = "TabButtonContainer"
    self.TabButtonContainer.Size = UDim2.new(1, 0, 1, -20)
    self.TabButtonContainer.Position = UDim2.new(0, 0, 0, 10)
    self.TabButtonContainer.BackgroundTransparency = 1
    self.TabButtonContainer.BorderSizePixel = 0
    self.TabButtonContainer.ScrollBarThickness = 2
    self.TabButtonContainer.ScrollBarImageColor3 = self.Theme.Accent
    self.TabButtonContainer.ScrollBarImageTransparency = 0.5
    self.TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated as tabs are added
    self.TabButtonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabButtonContainer.Parent = self.TabNavigation
    
    -- Create tab content container
    self.TabContentContainer = Instance.new("Frame")
    self.TabContentContainer.Name = "TabContentContainer"
    self.TabContentContainer.Size = UDim2.new(1, -self.TabButtonWidth, 1, 0)
    self.TabContentContainer.Position = UDim2.new(0, self.TabButtonWidth, 0, 0)
    self.TabContentContainer.BackgroundTransparency = 1
    self.TabContentContainer.BorderSizePixel = 0
    self.TabContentContainer.Parent = self.TabContainer
    
    -- Add solo leveling themed decoration
    self:AddHolographicEffects()
    
    -- Make window draggable
    if self.Draggable then
        self:MakeDraggable()
    end
    
    -- Setup close keybind (Default: RightControl)
    self:SetupKeybinds(config.CloseKeybind or Enum.KeyCode.RightControl)
    
    -- Initial animations
    self:AnimateOpen()
    
    return self
end

function Window:AddHolographicEffects()
    -- Add blue circuit-like pattern to the background (Solo Leveling system-like)
    local circuitPattern = Instance.new("Frame")
    circuitPattern.Name = "CircuitPattern"
    circuitPattern.Size = UDim2.new(1, 0, 1, 0)
    circuitPattern.Position = UDim2.new(0, 0, 0, 0)
    circuitPattern.BackgroundTransparency = 1
    circuitPattern.ZIndex = 0
    circuitPattern.Parent = self.Container
    
    -- Use a combination of frames to create circuit patterns
    for i = 1, 8 do
        local line = Instance.new("Frame")
        line.Name = "Circuit_" .. i
        line.BackgroundColor3 = self.Theme.BorderColor
        line.BackgroundTransparency = 0.9
        line.BorderSizePixel = 0
        
        -- Random positioning and sizing
        local isHorizontal = math.random() > 0.5
        local size = math.random(50, 200)
        local thickness = math.random(1, 2)
        
        if isHorizontal then
            line.Size = UDim2.new(0, size, 0, thickness)
            line.Position = UDim2.new(math.random(), 0, math.random(), 0)
        else
            line.Size = UDim2.new(0, thickness, 0, size)
            line.Position = UDim2.new(math.random(), 0, math.random(), 0)
        end
        
        -- Add rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = line
        
        line.Parent = circuitPattern
        
        -- Optional: animate glow effect
        spawn(function()
            while self.Container.Parent do
                local transparency = 0.8 + (math.sin(tick() * 0.5) * 0.15)
                line.BackgroundTransparency = transparency
                wait(0.03)
            end
        end)
    end
    
    -- Add subtle pulse animation to the border
    spawn(function()
        local stroke = self.Container:FindFirstChildOfClass("UIStroke")
        if stroke then
            while self.Container.Parent do
                for i = 0, 2 * math.pi, 0.1 do
                    if not stroke or not stroke.Parent then break end
                    stroke.Transparency = 0.2 + (math.sin(i) * 0.15)
                    wait(0.05)
                end
            end
        end
    end)
end

function Window:MakeDraggable()
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.Container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Window:SetupKeybinds(closeKeybind)
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == closeKeybind then
            self:ToggleVisibility()
        end
    end)
end

function Window:AnimateOpen()
    self.Container.Position = UDim2.new(self.Position.X.Scale, self.Position.X.Offset, self.Position.Y.Scale, self.Position.Y.Offset - 30)
    self.Container.BackgroundTransparency = 1
    
    -- Find all direct children to animate
    for _, child in pairs(self.Container:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ImageLabel") then
            child.BackgroundTransparency = 1
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                child.TextTransparency = 1
            end
            if child:IsA("ImageLabel") then
                child.ImageTransparency = 1
            end
        end
    end
    
    -- Animate container
    TweenLib:Create(self.Container, self.Theme.Animation.Speed, {
        Position = self.Position,
        BackgroundTransparency = self.Theme.BackgroundTransparency
    }):Play()
    
    -- Animate children
    wait(0.1)
    for _, child in pairs(self.Container:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ImageLabel") then
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenLib:Create(child, self.Theme.Animation.Speed, {
                    TextTransparency = 0
                }):Play()
            end
            if child:IsA("ImageLabel") then
                TweenLib:Create(child, self.Theme.Animation.Speed, {
                    ImageTransparency = child.Name == "DropShadow" and 0.6 or 0
                }):Play()
            end
            
            TweenLib:Create(child, self.Theme.Animation.Speed, {
                BackgroundTransparency = child.Name == "TabContentContainer" and 1 or 
                                         child.Name == "CircuitPattern" and 1 or
                                         child.Name == "TabButtonContainer" and 1 or
                                         child.Name == "TabContainer" and 1 or
                                         (child.BackgroundTransparency > 0.8 and child.BackgroundTransparency) or
                                         0
            }):Play()
        end
    end
end

function Window:CreateTab(config)
    config = config or {}
    config.Name = config.Name or "Tab " .. (#self.Tabs + 1)
    config.Icon = config.Icon or ""
    
    -- Create tab button
    local tabButtonHeight = 32
    local yOffset = #self.TabButtons * (tabButtonHeight + 4)
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "TabButton_" .. config.Name
    tabButton.Size = UDim2.new(1, -20, 0, tabButtonHeight)
    tabButton.Position = UDim2.new(0, 10, 0, yOffset + 5)
    tabButton.BackgroundColor3 = self.Theme.Secondary
    tabButton.BackgroundTransparency = 0.8
    tabButton.BorderSizePixel = 0
    tabButton.TextColor3 = self.Theme.Text
    tabButton.TextSize = 14
    tabButton.Font = self.Theme.Font
    tabButton.Text = config.Name
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.Parent = self.TabButtonContainer
    
    -- Add rounded corners
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = tabButton
    
    -- Add padding for text
    local textPadding = Instance.new("UIPadding")
    textPadding.PaddingLeft = UDim.new(0, 10)
    textPadding.Parent = tabButton
    
    -- Add icon if provided
    if config.Icon ~= "" then
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.Size = UDim2.new(0, 16, 0, 16)
        iconLabel.Position = UDim2.new(0, -5, 0.5, -8)
        iconLabel.BackgroundTransparency = 1
        iconLabel.TextColor3 = self.Theme.Text
        iconLabel.TextSize = 14
        iconLabel.Font = Enum.Font.Code
        iconLabel.Text = config.Icon
        iconLabel.Parent = tabButton
    end
    
    -- Create tab content container
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = "TabContent_" .. config.Name
    tabContent.Size = UDim2.new(1, -20, 1, -20)
    tabContent.Position = UDim2.new(0, 10, 0, 10)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = self.Theme.Accent
    tabContent.ScrollBarImageTransparency = 0.5
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    tabContent.Parent = self.TabContentContainer
    
    -- Create section list layout
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Padding = UDim.new(0, 10)
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Parent = tabContent
    
    -- Create new tab
    local newTab = Tab:Create(self, {
        Name = config.Name,
        Button = tabButton,
        Container = tabContent
    })
    
    -- Add to tab lists
    table.insert(self.Tabs, newTab)
    table.insert(self.TabButtons, tabButton)
    
    -- Tab button click handler
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(newTab)
    end)
    
    -- Tab button hover effects
    tabButton.MouseEnter:Connect(function()
        TweenLib:Create(tabButton, 0.2, {
            BackgroundTransparency = 0.6
        }):Play()
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab and self.CurrentTab.Name == newTab.Name then
            TweenLib:Create(tabButton, 0.2, {
                BackgroundTransparency = 0.4
            }):Play()
        else
            TweenLib:Create(tabButton, 0.2, {
                BackgroundTransparency = 0.8
            }):Play()
        end
    end)
    
    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(newTab)
    end
    
    return newTab
end

function Window:SelectTab(tab)
    -- Hide all tabs
    for _, t in ipairs(self.Tabs) do
        t.Container.Visible = false
        
        TweenLib:Create(t.Button, 0.2, {
            BackgroundTransparency = 0.8,
            TextColor3 = self.Theme.Text
        }):Play()
    end
    
    -- Show selected tab
    tab.Container.Visible = true
    self.CurrentTab = tab
    
    -- Update button appearance
    TweenLib:Create(tab.Button, 0.2, {
        BackgroundTransparency = 0.4,
        TextColor3 = self.Theme.Accent
    }):Play()
    
    -- Add selection indicator
    if tab.SelectionIndicator then
        tab.SelectionIndicator:Destroy()
    end
    
    local indicator = Instance.new("Frame")
    indicator.Name = "SelectionIndicator"
    indicator.Size = UDim2.new(0, 3, 1, -4)
    indicator.Position = UDim2.new(0, 0, 0, 2)
    indicator.BackgroundColor3 = self.Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = tab.Button
    
    -- Add rounded corners
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 2)
    indicatorCorner.Parent = indicator
    
    tab.SelectionIndicator = indicator
    
    -- Animate indicator
    indicator.Size = UDim2.new(0, 0, 1, -4)
    TweenLib:Create(indicator, 0.3, {
        Size = UDim2.new(0, 3, 1, -4)
    }):Play()
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        self.OriginalSize = self.Container.Size
        
        TweenLib:Create(self.Container, 0.3, {
            Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 30)
        }):Play()
        
        self.TabContainer.Visible = false
    else
        TweenLib:Create(self.Container, 0.3, {
            Size = self.OriginalSize or self.Size
        }):Play()
        
        self.TabContainer.Visible = true
    end
end

function Window:ToggleVisibility(visible)
    -- If visible parameter is provided, use it, otherwise toggle
    if visible ~= nil then
        self.Container.Visible = visible
    else
        self.Container.Visible = not self.Container.Visible
    end
    
    -- If becoming visible, play animation
    if self.Container.Visible then
        self:AnimateOpen()
    end
end

function Window:UpdateTheme(newTheme)
    self.Theme = newTheme
    
    -- Update window appearance
    self.Container.BackgroundColor3 = self.Theme.Background
    self.Container.BackgroundTransparency = self.Theme.BackgroundTransparency
    
    -- Update title bar
    self.TitleBar.BackgroundColor3 = self.Theme.Secondary
    self.TitleLabel.TextColor3 = self.Theme.Text
    self.TitleLabel.Font = self.Theme.Font
    
    -- Update border
    local border = self.Container:FindFirstChildOfClass("UIStroke")
    if border then
        border.Color = self.Theme.BorderColor
        border.Thickness = self.Theme.BorderSize
    end
    
    -- Update tab navigation
    self.TabNavigation.BackgroundColor3 = self.Theme.Secondary
    
    -- Update tab buttons
    for _, button in ipairs(self.TabButtons) do
        button.BackgroundColor3 = self.Theme.Secondary
        button.TextColor3 = self.Theme.Text
        button.Font = self.Theme.Font
        
        local indicator = button:FindFirstChild("SelectionIndicator")
        if indicator then
            indicator.BackgroundColor3 = self.Theme.Accent
        end
    end
    
    -- Update all tabs
    for _, tab in ipairs(self.Tabs) do
        if tab.UpdateTheme then
            tab:UpdateTheme(self.Theme)
        end
    end
end

function Window:Destroy()
    if self.Container then
        self.Container:Destroy()
    end
end

return Window
