--[[
    TweenLib - Lightweight Tweening Implementation for SoloUI
    Compatible with multiple exploit executors through fallbacks
]]

local TweenLib = {}

-- Detect if Roblox's TweenService is available
local success, TweenService = pcall(function()
    return game:GetService("TweenService")
end)

-- Set up internal variables
local useTweenService = success
local activeTweens = {}
local tweenId = 0

-- Get current time in seconds
local function getTime()
    return tick()
end

-- Easing functions for fallback implementation
local EasingFunctions = {
    -- Linear (no easing)
    Linear = function(t)
        return t
    end,
    
    -- Sine
    SineIn = function(t)
        return 1 - math.cos(t * math.pi / 2)
    end,
    
    SineOut = function(t)
        return math.sin(t * math.pi / 2)
    end,
    
    SineInOut = function(t)
        return -(math.cos(math.pi * t) - 1) / 2
    end,
    
    -- Quad
    QuadIn = function(t)
        return t * t
    end,
    
    QuadOut = function(t)
        return 1 - (1 - t) * (1 - t)
    end,
    
    QuadInOut = function(t)
        return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2
    end,
    
    -- Cubic
    CubicIn = function(t)
        return t * t * t
    end,
    
    CubicOut = function(t)
        return 1 - math.pow(1 - t, 3)
    end,
    
    CubicInOut = function(t)
        return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
    end,
    
    -- Quart
    QuartIn = function(t)
        return t * t * t * t
    end,
    
    QuartOut = function(t)
        return 1 - math.pow(1 - t, 4)
    end,
    
    QuartInOut = function(t)
        return t < 0.5 and 8 * t * t * t * t or 1 - math.pow(-2 * t + 2, 4) / 2
    end,
    
    -- Quint
    QuintIn = function(t)
        return t * t * t * t * t
    end,
    
    QuintOut = function(t)
        return 1 - math.pow(1 - t, 5)
    end,
    
    QuintInOut = function(t)
        return t < 0.5 and 16 * t * t * t * t * t or 1 - math.pow(-2 * t + 2, 5) / 2
    end,
    
    -- Expo
    ExpoIn = function(t)
        return t == 0 and 0 or math.pow(2, 10 * t - 10)
    end,
    
    ExpoOut = function(t)
        return t == 1 and 1 or 1 - math.pow(2, -10 * t)
    end,
    
    ExpoInOut = function(t)
        return t == 0 and 0 or t == 1 and 1 or t < 0.5 and math.pow(2, 20 * t - 10) / 2 or (2 - math.pow(2, -20 * t + 10)) / 2
    end,
    
    -- Back
    BackIn = function(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return c3 * t * t * t - c1 * t * t
    end,
    
    BackOut = function(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
    end,
    
    BackInOut = function(t)
        local c1 = 1.70158
        local c2 = c1 * 1.525
        return t < 0.5 and (math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2 or (math.pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
    end,
    
    -- Elastic
    ElasticIn = function(t)
        local c4 = (2 * math.pi) / 3
        return t == 0 and 0 or t == 1 and 1 or -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * c4)
    end,
    
    ElasticOut = function(t)
        local c4 = (2 * math.pi) / 3
        return t == 0 and 0 or t == 1 and 1 or math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
    end,
    
    ElasticInOut = function(t)
        local c5 = (2 * math.pi) / 4.5
        return t == 0 and 0 or t == 1 and 1 or t < 0.5 and -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2 or (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 + 1
    end,
    
    -- Bounce
    BounceIn = function(t)
        return 1 - EasingFunctions.BounceOut(1 - t)
    end,
    
    BounceOut = function(t)
        local n1 = 7.5625
        local d1 = 2.75
        
        if t < 1 / d1 then
            return n1 * t * t
        elseif t < 2 / d1 then
            t = t - 1.5 / d1
            return n1 * t * t + 0.75
        elseif t < 2.5 / d1 then
            t = t - 2.25 / d1
            return n1 * t * t + 0.9375
        else
            t = t - 2.625 / d1
            return n1 * t * t + 0.984375
        end
    end,
    
    BounceInOut = function(t)
        return t < 0.5 and (1 - EasingFunctions.BounceOut(1 - 2 * t)) / 2 or (1 + EasingFunctions.BounceOut(2 * t - 1)) / 2
    end,
}

-- Map Roblox EasingStyle/Direction to our easing functions
local function getEasingFunction(style, direction)
    -- Default to Quad easing
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local styleName
    if style == Enum.EasingStyle.Linear then
        return EasingFunctions.Linear
    elseif style == Enum.EasingStyle.Sine then
        styleName = "Sine"
    elseif style == Enum.EasingStyle.Back then
        styleName = "Back"
    elseif style == Enum.EasingStyle.Bounce then
        styleName = "Bounce"
    elseif style == Enum.EasingStyle.Elastic then
        styleName = "Elastic"
    elseif style == Enum.EasingStyle.Exponential then
        styleName = "Expo"
    elseif style == Enum.EasingStyle.Circular then
        styleName = "Quad" -- Simplified fallback
    elseif style == Enum.EasingStyle.Cubic then
        styleName = "Cubic"
    elseif style == Enum.EasingStyle.Quart then
        styleName = "Quart"
    elseif style == Enum.EasingStyle.Quint then
        styleName = "Quint"
    else
        styleName = "Quad" -- Default
    end
    
    local directionName
    if direction == Enum.EasingDirection.In then
        directionName = "In"
    elseif direction == Enum.EasingDirection.Out then
        directionName = "Out"
    else
        directionName = "InOut"
    end
    
    return EasingFunctions[styleName .. directionName]
end

-- Lerp (Linear interpolation) between two values
local function lerp(start, finish, alpha)
    if typeof(start) == "number" then
        return start + (finish - start) * alpha
    elseif typeof(start) == "Vector2" then
        return Vector2.new(
            lerp(start.X, finish.X, alpha),
            lerp(start.Y, finish.Y, alpha)
        )
    elseif typeof(start) == "Vector3" then
        return Vector3.new(
            lerp(start.X, finish.X, alpha),
            lerp(start.Y, finish.Y, alpha),
            lerp(start.Z, finish.Z, alpha)
        )
    elseif typeof(start) == "UDim2" then
        return UDim2.new(
            lerp(start.X.Scale, finish.X.Scale, alpha),
            lerp(start.X.Offset, finish.X.Offset, alpha),
            lerp(start.Y.Scale, finish.Y.Scale, alpha),
            lerp(start.Y.Offset, finish.Y.Offset, alpha)
        )
    elseif typeof(start) == "UDim" then
        return UDim.new(
            lerp(start.Scale, finish.Scale, alpha),
            lerp(start.Offset, finish.Offset, alpha)
        )
    elseif typeof(start) == "CFrame" then
        return start:Lerp(finish, alpha)
    elseif typeof(start) == "Color3" then
        return Color3.new(
            lerp(start.R, finish.R, alpha),
            lerp(start.G, finish.G, alpha),
            lerp(start.B, finish.B, alpha)
        )
    elseif typeof(start) == "table" then
        local result = {}
        for key, value in pairs(start) do
            if finish[key] ~= nil then
                result[key] = lerp(value, finish[key], alpha)
            else
                result[key] = value
            end
        end
        return result
    else
        return finish -- For incompatible types, just jump to the end
    end
end

-- Custom tween implementation for fallback
function TweenLib:CustomTween(object, duration, easingFunction, properties)
    tweenId = tweenId + 1
    local currentTweenId = tweenId
    
    -- Store initial properties
    local initialProperties = {}
    for property, targetValue in pairs(properties) do
        if object[property] ~= nil then
            initialProperties[property] = object[property]
        end
    end
    
    -- Create tween object
    local tween = {
        PlaybackState = Enum.PlaybackState.Begin,
        Completed = Instance.new("BindableEvent")
    }
    
    -- Add to active tweens
    activeTweens[currentTweenId] = tween
    
    -- Play function
    function tween:Play()
        if self.PlaybackState == Enum.PlaybackState.Playing then
            return
        end
        
        self.PlaybackState = Enum.PlaybackState.Playing
        local startTime = getTime()
        local connection
        
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if activeTweens[currentTweenId] ~= self or self.PlaybackState ~= Enum.PlaybackState.Playing then
                connection:Disconnect()
                return
            end
            
            local elapsed = getTime() - startTime
            local alpha = math.clamp(elapsed / duration, 0, 1)
            local easedAlpha = easingFunction(alpha)
            
            -- Apply interpolated properties
            for property, targetValue in pairs(properties) do
                if initialProperties[property] ~= nil then
                    pcall(function()
                        object[property] = lerp(initialProperties[property], targetValue, easedAlpha)
                    end)
                end
            end
            
            -- Check if tween is complete
            if alpha >= 1 then
                self.PlaybackState = Enum.PlaybackState.Completed
                activeTweens[currentTweenId] = nil
                connection:Disconnect()
                self.Completed:Fire()
            end
        end)
        
        return self
    end
    
    -- Cancel function
    function tween:Cancel()
        if self.PlaybackState == Enum.PlaybackState.Completed or self.PlaybackState == Enum.PlaybackState.Cancelled then
            return
        end
        
        self.PlaybackState = Enum.PlaybackState.Cancelled
        activeTweens[currentTweenId] = nil
    end
    
    -- Connect to Completed event
    function tween.Completed.Connect(_, callback)
        return tween.Completed.Event:Connect(callback)
    end
    
    return tween
end

-- Main tween creation function
function TweenLib:Create(object, duration, properties, style, direction)
    -- Handle optional parameters
    if type(properties) ~= "table" and type(properties) ~= "userdata" then
        object, duration, properties, style, direction = object, properties, style, direction, nil
    end
    
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    if useTweenService then
        -- Use Roblox's TweenService if available
        local tweenInfo
        
        -- Handle number or TweenInfo
        if type(duration) == "number" then
            tweenInfo = TweenInfo.new(duration, style, direction)
        else
            tweenInfo = duration
        end
        
        local success, tween = pcall(function()
            return TweenService:Create(object, tweenInfo, properties)
        end)
        
        if success then
            return tween
        else
            -- Fallback to custom implementation if TweenService:Create fails
            useTweenService = false
        end
    end
    
    -- Use custom tween implementation
    return self:CustomTween(object, duration, getEasingFunction(style, direction), properties)
end

-- Make TweenLib available in the global environment
getfenv().SoloUITweenLib = TweenLib
getfenv().SoloUITweenLibLoaded = true

return TweenLib
