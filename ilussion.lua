--[[ ref ]]--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local parent = (gethui and gethui()) or game:GetService("CoreGui")


--[[ Other ]]--

local Library = {}

local folder = "Ilussion.best"
local cfgFolder = folder .. "/configs"

if makefolder then
    pcall(makefolder, folder)
    pcall(makefolder, cfgFolder)
end

local colors = {
    bg = Color3.fromRGB(19, 19, 21),
    side = Color3.fromRGB(16, 16, 18),
    card = Color3.fromRGB(29, 29, 32),
    row = Color3.fromRGB(35, 35, 38),
    hover = Color3.fromRGB(42, 42, 45),

    border = Color3.fromRGB(55, 55, 59),
    text = Color3.fromRGB(237, 237, 240),
    sub = Color3.fromRGB(153, 153, 159),
    dim = Color3.fromRGB(105, 105, 111),

    accent = Color3.fromRGB(185, 220, 125)
}

local connections = {}


--[[ Helpers ]]--

local function new(class, props, parentObj)
    local obj = Instance.new(class)

    for k, v in pairs(props or {}) do
        obj[k] = v
    end

    obj.Parent = parentObj
    return obj
end

local function corner(obj, size)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, size or 7)
    c.Parent = obj
    return c
end

local function outline(obj, alpha)
    local s = Instance.new("UIStroke")
    s.Color = colors.border
    s.Thickness = 1
    s.Transparency = alpha or 0.25
    s.Parent = obj
    return s
end

local function tween(obj, props, speed)
    local info = TweenInfo.new(
        speed or 0.16,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

    return TweenService:Create(obj, info, props)
end

local function play(obj, props, speed)
    tween(obj, props, speed):Play()
end

local function spawnCallback(fn, ...)
    if fn then
        task.spawn(fn, ...)
    end
end

local function addConnection(conn)
    table.insert(connections, conn)
    return conn
end

local function makeRow(parentObj, height)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, height or 36),
        BackgroundColor3 = colors.row,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, parentObj)

    corner(row, 7)

    row.MouseEnter:Connect(function()
        play(row, {
            BackgroundColor3 = colors.hover
        }, 0.1)
    end)

    row.MouseLeave:Connect(function()
        play(row, {
            BackgroundColor3 = colors.row
        }, 0.1)
    end)

    return row
end

local function rowLabel(row, text)
    return new("TextLabel", {
        Position = UDim2.fromOffset(11, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = colors.text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)
end

local function colorData(c)
    return {
        r = math.floor(c.R * 255 + 0.5),
        g = math.floor(c.G * 255 + 0.5),
        b = math.floor(c.B * 255 + 0.5)
    }
end

local function fromColor(data)
    if type(data) ~= "table" then
        return Color3.new(1, 1, 1)
    end

    return Color3.fromRGB(
        tonumber(data.r) or 255,
        tonumber(data.g) or 255,
        tonumber(data.b) or 255
    )
end

local function keyName(key)
    if typeof(key) == "EnumItem" then
        return key.Name
    end

    return tostring(key)
end

local function getKey(name)
    if type(name) ~= "string" then
        return Enum.KeyCode.Unknown
    end

    for _, item in ipairs(Enum.KeyCode:GetEnumItems()) do
        if item.Name == name then
            return item
        end
    end

    return Enum.KeyCode.Unknown
end


--[[ Window ]]--

local Window = {}
Window.__index = Window

function Library:CreateWindow(settings)
    settings = settings or {}

    local width = settings.Width or 570
    local height = settings.Height or 370

    local gui = new("ScreenGui", {
        Name = settings.Name or "Ilussion.best",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, parent)

    local main = new("Frame", {
        Size = UDim2.fromOffset(width, height),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = colors.bg,
        BorderSizePixel = 0
    }, gui)

    corner(main, 11)
    outline(main)

    local top = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1
    }, main)

    local title = new("TextLabel", {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = settings.Title or "Orbit",
        TextColor3 = colors.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    }, top)

    local close = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -13, 0.5, 0),
        Size = UDim2.fromOffset(25, 25),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = colors.sub,
        Font = Enum.Font.Gotham,
        TextSize = 20,
        AutoButtonColor = false
    }, top)

    close.MouseEnter:Connect(function()
        play(close, {TextColor3 = colors.text}, 0.1)
    end)

    close.MouseLeave:Connect(function()
        play(close, {TextColor3 = colors.sub}, 0.1)
    end)

    new("Frame", {
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = colors.border,
        BorderSizePixel = 0
    }, main)

    local sidebar = new("Frame", {
        Position = UDim2.fromOffset(0, 46),
        Size = UDim2.new(0, 135, 1, -46),
        BackgroundColor3 = colors.side,
        BorderSizePixel = 0
    }, main)

    new("Frame", {
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = colors.border,
        BorderSizePixel = 0
    }, sidebar)

    local tabList = new("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 9),
        Size = UDim2.new(1, -16, 1, -18),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, sidebar)

    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, tabList)

    local content = new("Frame", {
        Position = UDim2.fromOffset(135, 46),
        Size = UDim2.new(1, -135, 1, -46),
        BackgroundTransparency = 1
    }, main)

    local pageTitle = new("TextLabel", {
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -36, 0, 40),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = colors.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    }, content)

    local pages = new("Frame", {
        Position = UDim2.fromOffset(18, 40),
        Size = UDim2.new(1, -36, 1, -51),
        BackgroundTransparency = 1
    }, content)

    local tabs = {}
    local active
    local allControls = {}

    local window = setmetatable({
        Gui = gui,
        Main = main,
        Tabs = tabs,
        Controls = allControls
    }, Window)

    -- simple drag, nothing fancy
    do
        local dragging = false
        local startMouse
        local startPos

        top.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end

            dragging = true
            startMouse = input.Position
            startPos = main.Position
        end)

        UIS.InputChanged:Connect(function(input)
            if not dragging then
                return
            end

            if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end

            local delta = input.Position - startMouse

            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function selectTab(tab)
        if active == tab then
            return
        end

        for _, item in ipairs(tabs) do
            local on = item == tab

            play(item.button, {
                BackgroundColor3 = on and colors.card or colors.side
            }, 0.1)

            play(item.label, {
                TextColor3 = on and colors.text or colors.sub
            }, 0.1)

            item.page.Visible = on
        end

        active = tab
        pageTitle.Text = tab.name
    end

    close.Activated:Connect(function()
        window:Destroy()
    end)


    --[[ Tabs ]]--

    function window:CreateTab(name)
        local button = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = colors.side,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        }, tabList)

        corner(button, 6)

        local label = new("TextLabel", {
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = colors.sub,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local page = new("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = colors.border,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        }, pages)

        new("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4)
        }, page)

        new("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, page)

        local tab = {
            name = name,
            button = button,
            label = label,
            page = page
        }

        table.insert(tabs, tab)

        button.Activated:Connect(function()
            selectTab(tab)
        end)


        --[[ Sections ]]--

        function tab:CreateSection(name)
            local box = new("Frame", {
                Size = UDim2.new(1, 0, 0, 43),
                BackgroundColor3 = colors.card,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            }, page)

            corner(box, 8)
            outline(box, 0.3)

            new("TextLabel", {
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -24, 0, 35),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = colors.text,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            }, box)

            local body = new("Frame", {
                Position = UDim2.fromOffset(10, 35),
                Size = UDim2.new(1, -20, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            }, box)

            new("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, body)

            new("UIPadding", {
                PaddingBottom = UDim.new(0, 10)
            }, body)

            local section = {
                Body = body,
                Holder = box
            }


            --[[ Basic ]]--

            function section:Label(text)
                local label = new("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = colors.sub,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, body)

                return label
            end

            function section:Button(text, callback)
                local row = makeRow(body)

                local button = new("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = colors.text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    AutoButtonColor = false
                }, row)

                button.Activated:Connect(function()
                    play(row, {
                        BackgroundColor3 = colors.accent
                    }, 0.05)

                    task.delay(0.08, function()
                        if row.Parent then
                            play(row, {
                                BackgroundColor3 = colors.row
                            }, 0.1)
                        end
                    end)

                    spawnCallback(callback)
                end)

                return button
            end

            function section:Action(text, buttonText, callback)
                local row = makeRow(body)

                rowLabel(row, text)

                local button = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(82, 24),
                    BackgroundColor3 = colors.accent,
                    BorderSizePixel = 0,
                    Text = buttonText,
                    TextColor3 = colors.bg,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    AutoButtonColor = false
                }, row)

                corner(button, 5)

                button.Activated:Connect(function()
                    spawnCallback(callback)
                end)

                return button
            end


            --[[ Toggle ]]--

            function section:Toggle(text, default, callback)
                local row = makeRow(body)
                rowLabel(row, text)

                local state = default == true

                local track = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(36, 19),
                    BackgroundColor3 = state and colors.accent or colors.bg,
                    BorderSizePixel = 0
                }, row)

                corner(track, 10)
                outline(track, 0.35)

                local knob = new("Frame", {
                    Size = UDim2.fromOffset(15, 15),
                    Position = state
                        and UDim2.new(1, -17, 0.5, -7.5)
                        or UDim2.fromOffset(2, 2),
                    BackgroundColor3 = state and colors.bg or colors.sub,
                    BorderSizePixel = 0
                }, track)

                corner(knob, 10)

                local hit = new("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, row)

                local function set(v, fire)
                    state = v == true

                    play(track, {
                        BackgroundColor3 = state and colors.accent or colors.bg
                    })

                    play(knob, {
                        Position = state
                            and UDim2.new(1, -17, 0.5, -7.5)
                            or UDim2.fromOffset(2, 2),

                        BackgroundColor3 = state and colors.bg or colors.sub
                    })

                    if fire then
                        spawnCallback(callback, state)
                    end
                end

                hit.Activated:Connect(function()
                    set(not state, true)
                end)

                set(state, false)

                local control = {
                    Type = "Toggle",

                    Set = function(_, value)
                        set(value, true)
                    end,

                    Get = function()
                        return state
                    end
                }

                table.insert(allControls, control)

                return control
            end


            --[[ Slider ]]--

            function section:Slider(text, min, max, default, callback)
                min = tonumber(min) or 0
                max = tonumber(max) or 100

                if max <= min then
                    max = min + 1
                end

                local value = math.clamp(
                    tonumber(default) or min,
                    min,
                    max
                )

                local row = makeRow(body, 51)
                rowLabel(row, text)

                local valueText = new("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.fromOffset(55, 30),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = colors.sub,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, row)

                local bar = new("Frame", {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, -10),
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundColor3 = colors.bg,
                    BorderSizePixel = 0
                }, row)

                corner(bar, 4)

                local fill = new("Frame", {
                    Size = UDim2.fromScale(
                        (value - min) / (max - min),
                        1
                    ),
                    BackgroundColor3 = colors.accent,
                    BorderSizePixel = 0
                }, bar)

                corner(fill, 4)

                local hit = new("TextButton", {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 3),
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, row)

                local dragging = false

                local function set(v, fire)
                    value = math.clamp(
                        math.floor(v + 0.5),
                        min,
                        max
                    )

                    local percent = (value - min) / (max - min)

                    valueText.Text = tostring(value)

                    play(fill, {
                        Size = UDim2.fromScale(percent, 1)
                    }, 0.08)

                    if fire then
                        spawnCallback(callback, value)
                    end
                end

                hit.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then

                        dragging = true

                        local percent = math.clamp(
                            (input.Position.X - bar.AbsolutePosition.X)
                            / bar.AbsoluteSize.X,
                            0,
                            1
                        )

                        set(min + (max - min) * percent, true)
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if not dragging then
                        return
                    end

                    if input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch then

                        local percent = math.clamp(
                            (input.Position.X - bar.AbsolutePosition.X)
                            / bar.AbsoluteSize.X,
                            0,
                            1
                        )

                        set(min + (max - min) * percent, true)
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                set(value, false)

                local control = {
                    Type = "Slider",

                    Set = function(_, v)
                        set(v, true)
                    end,

                    Get = function()
                        return value
                    end
                }

                table.insert(allControls, control)

                return control
            end


            --[[ Dropdown ]]--

            function section:Dropdown(text, options, default, callback)
                options = options or {}

                local selected = default or options[1]
                local open = false

                local row = makeRow(
                    body,
                    36
                )

                rowLabel(row, text)

                local current = new("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -17, 0, 0),
                    Size = UDim2.new(0.42, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Text = tostring(selected or ""),
                    TextColor3 = colors.sub,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, row)

                local arrow = new("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.fromOffset(12, 36),
                    BackgroundTransparency = 1,
                    Text = "v",
                    TextColor3 = colors.sub,
                    Font = Enum.Font.Gotham,
                    TextSize = 11
                }, row)

                local list = new("Frame", {
                    Position = UDim2.fromOffset(0, 36),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1
                }, row)

                new("UIListLayout", {
                    Padding = UDim.new(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder
                }, list)

                local optionHeight = 27
                local extra = (#options * optionHeight) + (#options * 3) + 5

                local function setOpen(v)
                    open = v

                    tween(row, {
                        Size = UDim2.new(
                            1,
                            0,
                            0,
                            open and (36 + extra) or 36
                        )
                    }, 0.14):Play()

                    tween(arrow, {
                        Rotation = open and 180 or 0
                    }, 0.14):Play()
                end

                for i, option in ipairs(options) do
                    local button = new("TextButton", {
                        LayoutOrder = i,
                        Size = UDim2.new(1, 0, 0, optionHeight),
                        BackgroundColor3 = colors.bg,
                        BorderSizePixel = 0,
                        Text = tostring(option),
                        TextColor3 = colors.sub,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        AutoButtonColor = false
                    }, list)

                    corner(button, 5)

                    button.MouseEnter:Connect(function()
                        play(button, {
                            BackgroundColor3 = colors.hover,
                            TextColor3 = colors.text
                        }, 0.08)
                    end)

                    button.MouseLeave:Connect(function()
                        play(button, {
                            BackgroundColor3 = colors.bg,
                            TextColor3 = colors.sub
                        }, 0.08)
                    end)

                    button.Activated:Connect(function()
                        selected = option
                        current.Text = tostring(option)

                        setOpen(false)

                        spawnCallback(callback, option)
                    end)
                end

                local hit = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, row)

                hit.Activated:Connect(function()
                    setOpen(not open)
                end)

                local control = {
                    Type = "Dropdown",

                    Set = function(_, value)
                        for _, option in ipairs(options) do
                            if option == value then
                                selected = value
                                current.Text = tostring(value)
                                spawnCallback(callback, value)
                                break
                            end
                        end
                    end,

                    Get = function()
                        return selected
                    end
                }

                table.insert(allControls, control)

                return control
            end


            --[[ Keybind ]]--

            function section:Keybind(text, defaultKey, callback)
                local row = makeRow(body)
                rowLabel(row, text)

                local key = defaultKey
                local listening = false

                local button = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(82, 24),
                    BackgroundColor3 = colors.bg,
                    BorderSizePixel = 0,
                    Text = key and key.Name or "NONE",
                    TextColor3 = colors.sub,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    AutoButtonColor = false
                }, row)

                corner(button, 5)
                outline(button, 0.35)

                button.Activated:Connect(function()
                    listening = true
                    button.Text = "..."

                    play(button, {
                        BackgroundColor3 = colors.accent,
                        TextColor3 = colors.bg
                    }, 0.1)
                end)

                local conn = UIS.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end

                    if listening then
                        key = input.KeyCode
                        listening = false

                        button.Text = key.Name

                        play(button, {
                            BackgroundColor3 = colors.bg,
                            TextColor3 = colors.sub
                        }, 0.1)

                        return
                    end

                    if not gameProcessed
                        and key
                        and input.KeyCode == key then

                        spawnCallback(callback, key)
                    end
                end)

                table.insert(connections, conn)

                local control = {
                    Type = "Keybind",

                    Set = function(_, value)
                        key = value
                        button.Text = key and key.Name or "NONE"
                    end,

                    Get = function()
                        return key
                    end
                }

                table.insert(allControls, control)

                return control
            end


            --[[ Color ]]--

            function section:ColorPicker(text, default, callback)
                local value = default or Color3.fromRGB(255, 255, 255)
                local open = false

                local h, s, v = Color3.toHSV(value)

                local row = makeRow(body, 36)
                rowLabel(row, text)

                local swatch = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(42, 19),
                    BackgroundColor3 = value,
                    BorderSizePixel = 0
                }, row)

                corner(swatch, 5)
                outline(swatch, 0.3)

                local panel = new("Frame", {
                    Position = UDim2.fromOffset(0, 36),
                    Size = UDim2.new(1, 0, 0, 116),
                    BackgroundColor3 = colors.bg,
                    BorderSizePixel = 0,
                    Visible = false
                }, row)

                corner(panel, 6)
                outline(panel, 0.3)

                local sv = new("Frame", {
                    Position = UDim2.fromOffset(8, 8),
                    Size = UDim2.new(1, -48, 1, -16),
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    BorderSizePixel = 0
                }, panel)

                corner(sv, 5)

                local white = new("Frame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0
                }, sv)

                corner(white, 5)

                new("UIGradient", {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                }, white)

                local black = new("Frame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0
                }, sv)

                corner(black, 5)

                new("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    })
                }, black)

                local cursor = new("Frame", {
                    Size = UDim2.fromOffset(8, 8),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(s, 1 - v)
                }, sv)

                corner(cursor, 8)
                outline(cursor, 0)

                local hue = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -8, 0, 8),
                    Size = UDim2.fromOffset(24, 100),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0
                }, panel)

                corner(hue, 5)

                new("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    })
                }, hue)

                local hueCursor = new("Frame", {
                    Size = UDim2.new(1, 4, 0, 3),
                    Position = UDim2.new(0, -2, 1 - h, -1),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0
                }, hue)

                corner(hueCursor, 2)

                local function update(fire)
                    value = Color3.fromHSV(h, s, v)

                    swatch.BackgroundColor3 = value
                    sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

                    cursor.Position = UDim2.fromScale(s, 1 - v)
                    hueCursor.Position = UDim2.new(0, -2, 1 - h, -1)

                    if fire then
                        spawnCallback(callback, value)
                    end
                end

                local svDrag = false

                sv.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDrag = true
                    end
                end)

                hue.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local y = math.clamp(
                            (input.Position.Y - hue.AbsolutePosition.Y)
                            / hue.AbsoluteSize.Y,
                            0,
                            1
                        )

                        h = 1 - y
                        update(true)
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                        return
                    end

                    if svDrag then
                        s = math.clamp(
                            (input.Position.X - sv.AbsolutePosition.X)
                            / sv.AbsoluteSize.X,
                            0,
                            1
                        )

                        v = 1 - math.clamp(
                            (input.Position.Y - sv.AbsolutePosition.Y)
                            / sv.AbsoluteSize.Y,
                            0,
                            1
                        )

                        update(true)
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDrag = false
                    end
                end)

                local hit = new("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, row)

                hit.Activated:Connect(function()
                    open = not open
                    panel.Visible = open

                    row.Size = UDim2.new(
                        1,
                        0,
                        0,
                        open and 159 or 36
                    )
                end)

                update(false)

                local control = {
                    Type = "Color",

                    Set = function(_, color)
                        if typeof(color) ~= "Color3" then
                            return
                        end

                        value = color
                        h, s, v = Color3.toHSV(color)
                        update(true)
                    end,

                    Get = function()
                        return value
                    end
                }

                table.insert(allControls, control)

                return control
            end

            return section
        end

        if #tabs == 1 then
            task.defer(function()
                selectTab(tab)
            end)
        end

        return tab
    end


    --[[ Config ]]--

    local config = {}

    local function getValues()
        local data = {}

        for i, control in ipairs(allControls) do
            local value = control.Get()

            if typeof(value) == "Color3" then
                data[tostring(i)] = {
                    type = "Color3",
                    value = colorData(value)
                }

            elseif typeof(value) == "EnumItem" then
                data[tostring(i)] = {
                    type = "EnumItem",
                    value = value.Name
                }

            elseif type(value) == "string"
                or type(value) == "number"
                or type(value) == "boolean" then

                data[tostring(i)] = {
                    type = type(value),
                    value = value
                }
            end
        end

        return data
    end

    local function applyValues(data)
        if type(data) ~= "table" then
            return
        end

        for i, control in ipairs(allControls) do
            local item = data[tostring(i)]

            if not item then
                continue
            end

            local value = item.value

            if item.type == "Color3" then
                value = fromColor(value)

            elseif item.type == "EnumItem" then
                value = getKey(value)
            end

            pcall(function()
                control:Set(value)
            end)
        end
    end

    function config:Save(name)
        if not writefile then
            return false, "writefile is unavailable"
        end

        if type(name) ~= "string" or name == "" then
            return false, "invalid config name"
        end

        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(getValues())
        end)

        if not ok then
            return false, encoded
        end

        local success, err = pcall(function()
            writefile(
                cfgFolder .. "/" .. name .. ".json",
                encoded
            )
        end)

        return success, err
    end

    function config:Load(name)
        if not readfile or not isfile then
            return false, "file functions are unavailable"
        end

        local path = cfgFolder .. "/" .. name .. ".json"

        if not isfile(path) then
            return false, "config not found"
        end

        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)

        if not ok then
            return false, data
        end

        applyValues(data)
        return true
    end

    function config:Delete(name)
        if not delfile or not isfile then
            return false, "file functions are unavailable"
        end

        local path = cfgFolder .. "/" .. name .. ".json"

        if not isfile(path) then
            return false, "config not found"
        end

        local ok, err = pcall(function()
            delfile(path)
        end)

        return ok, err
    end

    function config:Refresh()
        if not listfiles then
            return {}
        end

        local result = {}

        local ok, files = pcall(function()
            return listfiles(cfgFolder)
        end)

        if not ok then
            return result
        end

        for _, path in ipairs(files) do
            local name = path:match("([^/\\]+)%.json$")

            if name then
                table.insert(result, name)
            end
        end

        table.sort(result)

        return result
    end

    function config:GetConfigs()
        return self:Refresh()
    end

    function config:Has(name)
        if not isfile then
            return false
        end

        return isfile(
            cfgFolder .. "/" .. tostring(name) .. ".json"
        )
    end

    window.Config = config


    --[[ Notifications ]]--

    local noticeHolder = new("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.fromOffset(260, 400),
        BackgroundTransparency = 1
    }, gui)

    new("UIListLayout", {
        Padding = UDim.new(0, 7),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    }, noticeHolder)

    function window:Notify(titleText, message, duration)
        duration = duration or 3

        local box = new("Frame", {
            Size = UDim2.new(1, 0, 0, 57),
            BackgroundColor3 = colors.card,
            BorderSizePixel = 0
        }, noticeHolder)

        corner(box, 8)
        outline(box, 0.2)

        local bar = new("Frame", {
            Size = UDim2.fromOffset(3, 57),
            BackgroundColor3 = colors.accent,
            BorderSizePixel = 0
        }, box)

        corner(bar, 2)

        new("TextLabel", {
            Position = UDim2.fromOffset(13, 7),
            Size = UDim2.new(1, -22, 0, 19),
            BackgroundTransparency = 1,
            Text = titleText or "Notification",
            TextColor3 = colors.text,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        }, box)

        new("TextLabel", {
            Position = UDim2.fromOffset(13, 26),
            Size = UDim2.new(1, -22, 0, 23),
            BackgroundTransparency = 1,
            Text = message or "",
            TextColor3 = colors.sub,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        }, box)

        box.Position = UDim2.new(1, 20, 0, 0)

        play(box, {
            Position = UDim2.new(0, 0, 0, 0)
        }, 0.18)

        task.delay(duration, function()
            if not box.Parent then
                return
            end

            local out = tween(box, {
                Position = UDim2.new(1, 20, 0, 0)
            }, 0.18)

            out.Completed:Connect(function()
                if box then
                    box:Destroy()
                end
            end)
        end)
    end


    --[[ Window API ]]--

    function window:SetTitle(text)
        title.Text = tostring(text)
    end

    function window:Open()
        main.Visible = true
    end

    function window:Close()
        main.Visible = false
    end

    function window:Toggle()
        main.Visible = not main.Visible
    end

    function window:Destroy()
        for _, conn in ipairs(connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end

        table.clear(connections)

        if gui then
            gui:Destroy()
        end
    end

    function window:GetConfig()
        return config
    end

    return window
end


--[[ Return ]]--

return Library
