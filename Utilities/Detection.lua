--[[
    Detection Utility for SoloUI
    Detects executor environment and provides compatibility fallbacks
]]

local Detection = {}

-- List of known executors and their identifiers
local KNOWN_EXECUTORS = {
    ["Synapse X"] = {"syn", "syn_context_set", "is_synapse_function"},
    ["Script-Ware"] = {"import", "isourclosure", "getgenv"},
    ["KRNL"] = {"KRNL_LOADED", "request", "identifyexecutor"},
    ["JJSploit"] = {"is_sirhurt_closure", "not_sirhurt_closure", "XPROTECT"},
    ["Delta"] = {"delta_", "delta_print", "delta_connection"},
    ["Sentinel"] = {"getlocalhook", "gcinfo", "get_signal_cons"},
    ["ProtoSmasher"] = {"IS_PROTOSMASHER_CALLER", "get_thread_identity"},
    ["Temple"] = {"pebc_load", "getlocals", "getglobals"},
    ["Fluxus"] = {"fluxus_loaded", "hookfunction", "searchproto"},
    ["Vermillion"] = {"Vermillion", "VermillionRun", "SecureLoadstring"},
    ["Electron"] = {"electronwsi", "is_electron_function", "getspecialinfo"},
    ["Celestial"] = {"checkcaller", "identifyingexecutor", "getgc"},
    ["SirHurt"] = {"is_sirhurt_closure", "XPROTECT"}
}

-- Executor feature detection
local EXECUTOR_FEATURES = {
    DrawingAPI = {
        canDraw = false,
        hasNewDrawing = false,
        hasFillCircle = false
    },
    Debugging = {
        hasTraceback = false,
        hasGetUpvalues = false,
        hasSetUpvalues = false
    },
    FileSystem = {
        canReadFiles = false,
        canWriteFiles = false,
        canAppendFiles = false,
        canListFiles = false
    },
    Environment = {
        hasGetGenv = false,
        hasSetReadOnly = false,
        hasSetEnvironment = false,
        hasGetNamecallMethod = false
    },
    HTTP = {
        canRequest = false,
        canWebsocket = false
    },
    UI = {
        hasProtectGui = false,
        hasGetHui = false,
        hasUndetectGui = false
    },
    Clipboard = {
        hasSetClipboard = false
    }
}

-- Detect mobile device
function Detection:IsMobile()
    -- Check if running on mobile device
    local success, isMobile = pcall(function()
        return game:GetService("UserInputService").TouchEnabled and
               not game:GetService("UserInputService").KeyboardEnabled and
               not game:GetService("UserInputService").MouseEnabled
    end)
    
    if not success then
        -- Alternative detection method
        local screenSize = workspace.CurrentCamera.ViewportSize
        return screenSize.X < 800 or screenSize.Y < 500
    end
    
    return isMobile
end

-- Detect executor
function Detection:GetExecutor()
    local executorName = "Unknown"
    local isKRNLMobile = false
    
    -- Try to get executor name directly
    local success, detectedExecutor = pcall(function()
        return identifyexecutor and identifyexecutor() or "Unknown"
    end)
    
    if success and detectedExecutor ~= "Unknown" then
        executorName = detectedExecutor
        
        -- Check if it's KRNL Mobile
        if executorName:lower():find("krnl") and self:IsMobile() then
            isKRNLMobile = true
        end
        
        return {
            Name = executorName,
            IsMobile = isKRNLMobile or self:IsMobile()
        }
    end
    
    -- Try to detect using known identifiers
    for name, identifiers in pairs(KNOWN_EXECUTORS) do
        local found = false
        
        for _, identifier in ipairs(identifiers) do
            if getgenv()[identifier] ~= nil or getfenv()[identifier] ~= nil then
                found = true
                break
            end
        end
        
        if found then
            executorName = name
            
            -- Check if it's KRNL Mobile
            if name == "KRNL" and self:IsMobile() then
                isKRNLMobile = true
            end
            
            break
        end
    end
    
    -- Detect executor features
    self:DetectFeatures()
    
    return {
        Name = executorName,
        IsMobile = isKRNLMobile or self:IsMobile(),
        Features = EXECUTOR_FEATURES
    }
end

-- Detect supported features
function Detection:DetectFeatures()
    -- Drawing API
    EXECUTOR_FEATURES.DrawingAPI.canDraw = typeof(Drawing) == "table" or typeof(Drawing) == "function"
    
    if EXECUTOR_FEATURES.DrawingAPI.canDraw then
        -- Check if Drawing has filled circle
        EXECUTOR_FEATURES.DrawingAPI.hasFillCircle = pcall(function()
            local circle = Drawing.new("Circle")
            circle.Filled = true
            circle:Remove()
            return true
        end)
        
        -- Check if the new Drawing API is supported
        EXECUTOR_FEATURES.DrawingAPI.hasNewDrawing = pcall(function()
            local line = Drawing.new("Line")
            line.Visible = true
            line:Remove()
            return true
        end)
    end
    
    -- Debugging features
    EXECUTOR_FEATURES.Debugging.hasTraceback = typeof(debug.traceback) == "function"
    EXECUTOR_FEATURES.Debugging.hasGetUpvalues = typeof(debug.getupvalues) == "function" or typeof(getupvalues) == "function"
    EXECUTOR_FEATURES.Debugging.hasSetUpvalues = typeof(debug.setupvalue) == "function" or typeof(setupvalue) == "function"
    
    -- File system
    EXECUTOR_FEATURES.FileSystem.canReadFiles = typeof(readfile) == "function"
    EXECUTOR_FEATURES.FileSystem.canWriteFiles = typeof(writefile) == "function"
    EXECUTOR_FEATURES.FileSystem.canAppendFiles = typeof(appendfile) == "function"
    EXECUTOR_FEATURES.FileSystem.canListFiles = typeof(listfiles) == "function"
    
    -- Environment
    EXECUTOR_FEATURES.Environment.hasGetGenv = typeof(getgenv) == "function"
    EXECUTOR_FEATURES.Environment.hasSetReadOnly = typeof(setreadonly) == "function"
    EXECUTOR_FEATURES.Environment.hasSetEnvironment = typeof(setfenv) == "function"
    EXECUTOR_FEATURES.Environment.hasGetNamecallMethod = typeof(getnamecallmethod) == "function"
    
    -- HTTP
    EXECUTOR_FEATURES.HTTP.canRequest = typeof(request) == "function" or typeof(http) == "table" or typeof(http.request) == "function"
    EXECUTOR_FEATURES.HTTP.canWebsocket = typeof(WebSocket) == "table" or typeof(WebSocket) == "function"
    
    -- UI
    EXECUTOR_FEATURES.UI.hasProtectGui = typeof(syn) == "table" and typeof(syn.protect_gui) == "function"
    EXECUTOR_FEATURES.UI.hasGetHui = typeof(gethui) == "function"
    EXECUTOR_FEATURES.UI.hasUndetectGui = typeof(undetectgui) == "function"
    
    -- Clipboard
    EXECUTOR_FEATURES.Clipboard.hasSetClipboard = typeof(setclipboard) == "function"
end

-- Check if an exploit-specific feature is available
function Detection:HasFeature(category, feature)
    return EXECUTOR_FEATURES[category] and EXECUTOR_FEATURES[category][feature] == true
end

-- Get best UI container method for current executor
function Detection:GetBestUIContainer()
    if EXECUTOR_FEATURES.UI.hasProtectGui then
        return function(gui)
            syn.protect_gui(gui)
            gui.Parent = game:GetService("CoreGui")
        end
    elseif EXECUTOR_FEATURES.UI.hasGetHui then
        return function(gui)
            gui.Parent = gethui()
        end
    elseif EXECUTOR_FEATURES.UI.hasUndetectGui then
        return function(gui)
            gui.Parent = game:GetService("CoreGui")
            undetectgui(gui)
        end
    else
        return function(gui)
            local success, err = pcall(function()
                gui.Parent = game:GetService("CoreGui")
            end)
            
            if not success then
                gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            end
        end
    end
end

-- Get best drawing method for current executor
function Detection:GetDrawingMethod()
    if EXECUTOR_FEATURES.DrawingAPI.hasNewDrawing then
        return {
            Method = "Modern",
            Create = function(type)
                return Drawing.new(type)
            end
        }
    elseif EXECUTOR_FEATURES.DrawingAPI.canDraw then
        return {
            Method = "Legacy",
            Create = function(type)
                return Drawing.new(type)
            end
        }
    else
        -- Fallback using UI elements
        return {
            Method = "Fallback",
            Create = function(type)
                local object = Instance.new("Frame")
                object.BackgroundTransparency = 0
                object.BorderSizePixel = 0
                object.ZIndex = 10
                
                -- Add additional properties based on type
                if type == "Line" then
                    object.Size = UDim2.new(0, 1, 0, 10)
                elseif type == "Circle" then
                    object.Size = UDim2.new(0, 10, 0, 10)
                    
                    local uiCorner = Instance.new("UICorner")
                    uiCorner.CornerRadius = UDim.new(1, 0)
                    uiCorner.Parent = object
                elseif type == "Square" or type == "Quad" then
                    object.Size = UDim2.new(0, 10, 0, 10)
                elseif type == "Text" then
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.new(1, 1, 1)
                    textLabel.Font = Enum.Font.SourceSans
                    textLabel.TextSize = 14
                    textLabel.Text = ""
                    textLabel.Parent = object
                    
                    -- Add text property
                    object.Text = ""
                    
                    object:GetPropertyChangedSignal("Text"):Connect(function()
                        textLabel.Text = object.Text
                    end)
                end
                
                -- Add Visible property
                object.Visible = true
                
                -- Add Remove method
                object.Remove = function()
                    object:Destroy()
                end
                
                -- Set parent later
                return object
            end
        }
    end
end

-- Get best HTTP request method for current executor
function Detection:GetHTTPMethod()
    if typeof(syn) == "table" and typeof(syn.request) == "function" then
        return syn.request
    elseif typeof(http) == "table" and typeof(http.request) == "function" then
        return http.request
    elseif typeof(request) == "function" then
        return request
    elseif typeof(http_request) == "function" then
        return http_request
    else
        -- Fallback using Roblox's HttpService
        return function(options)
            local httpService = game:GetService("HttpService")
            
            local url = options.Url
            local method = options.Method or "GET"
            local body = options.Body
            local headers = options.Headers or {}
            
            if method == "GET" then
                local success, result
                
                if body then
                    -- If body is provided for GET, encode as query parameters
                    success, result = pcall(function()
                        return httpService:GetAsync(url, true, headers)
                    end)
                else
                    success, result = pcall(function()
                        return httpService:GetAsync(url, true, headers)
                    end)
                end
                
                if success then
                    return {
                        StatusCode = 200,
                        Body = result,
                        Headers = {},
                        Success = true
                    }
                else
                    return {
                        StatusCode = 0,
                        Body = "Error: " .. tostring(result),
                        Headers = {},
                        Success = false
                    }
                end
            elseif method == "POST" then
                local success, result = pcall(function()
                    return httpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson, headers)
                end)
                
                if success then
                    return {
                        StatusCode = 200,
                        Body = result,
                        Headers = {},
                        Success = true
                    }
                else
                    return {
                        StatusCode = 0,
                        Body = "Error: " .. tostring(result),
                        Headers = {},
                        Success = false
                    }
                end
            else
                return {
                    StatusCode = 0,
                    Body = "Error: Unsupported method in fallback HTTP implementation",
                    Headers = {},
                    Success = false
                }
            end
        end
    end
end

return Detection
