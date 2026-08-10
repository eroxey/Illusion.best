--[[ references ]]--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local GuiParent = (gethui and gethui()) or game:GetService("CoreGui")

--[[ library ]]--

local Library = {}

local Theme = {
    Background = Color3.fromRGB(16, 16, 18),
    Sidebar = Color3.fromRGB(19, 19, 21),
    Panel = Color3.fromRGB(24, 24, 27),
    Item = Color3.fromRGB(30, 30, 33),
    Hover = Color3.fromRGB(37, 37, 40),
    Pressed = Color3.fromRGB(44, 44, 47),

    Text = Color3.fromRGB(242, 242, 245),
    SubText = Color3.fromRGB(150, 150, 155),
    Muted = Color3.fromRGB(105, 105, 110),

    Accent = Color3.fromRGB(235, 235, 238),
    Border = Color3.fromRGB(58, 58, 62)
}

local function new(class, props, parent)
    local object = Instance.new(class)

    for key, value in pairs(props or {}) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 9)
    c.Parent = object
    return c
end

local function stroke(object, transparency)
    local s = Instance.new("UIStroke")
    s.Color = Theme.Border
    s.Thickness = 1
    s.Transparency = transparency or 0.3
    s.Parent = object
    return s
end

local function tween(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.18,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        properties
    ):Play()
end

local function hover(button, normal, over)
    button.MouseEnter:Connect(function()
        tween(button, {
            BackgroundColor3 = over
        }, 0.14)
    end)

    button.MouseLeave:Connect(function()
        tween(button, {
            BackgroundColor3 = normal
        }, 0.14)
    end)
end

local function press(button, normal)
    button.MouseButton1Down:Connect(function()
        tween(button, {
            BackgroundColor3 = Theme.Pressed
        }, 0.07)
    end)

    button.MouseButton1Up:Connect(function()
        tween(button, {
            BackgroundColor3 = normal
        }, 0.1)
    end)
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function serialize(value, kind)
    if kind == "Color3" then
        return {
            value.R,
            value.G,
            value.B
        }
    end

    if kind == "KeyCode" then
        return value.Name
    end

    return value
end

local function deserialize(value, kind)
    if kind == "Color3" and type(value) == "table" then
        return Color3.new(
            value[1] or 1,
            value[2] or 1,
            value[3] or 1
        )
    end

    if kind == "KeyCode" and type(value) == "string" then
        return Enum.KeyCode[value] or Enum.KeyCode.RightControl
    end

    return value
end

function Library:CreateWindow(options)
    options = options or {}

    local width = options.Width or 570
    local height = options.Height or 370
    local configFolder = options.ConfigFolder or "OrbitUI"

    local controls = {}
    local tabs = {}

    local gui = new("ScreenGui", {
        Name = "OrbitUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, GuiParent)

    local shadow = new("Frame", {
        Size = UDim2.fromOffset(width + 10, height + 10),
        Position = UDim2.new(
            0.5,
            -(width + 10) / 2,
            0.5,
            -(height + 10) / 2 + 5
        ),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0
    }, gui)

    corner(shadow, 17)

    local main = new("Frame", {
        Size = UDim2.fromOffset(width, height),
        Position = UDim2.new(
            0.5,
            -width / 2,
            0.5,
            -height / 2
        ),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    }, gui)

    corner(main, 15)
    stroke(main, 0.12)

    local header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1
    }, main)

    local title = new("TextLabel", {
        Size = UDim2.new(1, -75, 1, 0),
        Position = UDim2.fromOffset(17, 0),
        BackgroundTransparency = 1,
        Text = options.Title or "Orbit",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    }, header)

    local close = new("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -38, 0, 9),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 17,
        AutoButtonColor = false
    }, header)

    close.MouseEnter:Connect(function()
        tween(close, {
            TextColor3 = Theme.Text
        }, 0.12)
    end)

    close.MouseLeave:Connect(function()
        tween(close, {
            TextColor3 = Theme.Muted
        }, 0.12)
    end)

    local divider = new("Frame", {
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.fromOffset(12, 47),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0
    }, main)

    local sidebar = new("Frame", {
        Size = UDim2.new(0, 126, 1, -60),
        Position = UDim2.fromOffset(10, 55),
        BackgroundTransparency = 1
    }, main)

    local tabList = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1
    }, sidebar)

    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, tabList)

    local content = new("Frame", {
        Size = UDim2.new(1, -146, 1, -60),
        Position = UDim2.fromOffset(136, 55),
        BackgroundTransparency = 1
    }, main)

    local pageTitle = new("TextLabel", {
        Size = UDim2.new(1, -10, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    }, content)

    local pages = new("Frame", {
        Size = UDim2.new(1, 0, 1, -34),
        Position = UDim2.fromOffset(0, 34),
        BackgroundTransparency = 1
    }, content)

    local Window = {}

    local function selectTab(selected)
        for _, tab in ipairs(tabs) do
            local active = tab == selected

            tab.Page.Visible = active

            tween(tab.Button, {
                BackgroundColor3 = active
                    and Theme.Item
                    or Theme.Background
            }, 0.16)

            tween(tab.Label, {
                TextColor3 = active
                    and Theme.Text
                    or Theme.SubText
            }, 0.16)
        end

        pageTitle.Text = selected.Name
    end

    function Window:CreateTab(name)
        local page = new("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Muted,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        }, pages)

        new("UIPadding", {
            PaddingRight = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 8)
        }, page)

        new("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, page)

        local button = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        }, tabList)

        corner(button, 9)

        local label = new("TextLabel", {
            Size = UDim2.new(1, -18, 1, 0),
            Position = UDim2.fromOffset(9, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local tab = {
            Name = name,
            Page = page,
            Button = button,
            Label = label
        }

        table.insert(tabs, tab)

        hover(button, Theme.Background, Theme.Item)

        button.MouseButton1Click:Connect(function()
            selectTab(tab)
        end)

        local Tab = {}

        function Tab:CreateSection(name)
            local section = new("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            }, page)

            corner(section, 10)
            stroke(section, 0.35)

            new("TextLabel", {
                Size = UDim2.new(1, -24, 0, 35),
                Position = UDim2.fromOffset(12, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            }, section)

            local items = new("Frame", {
                Size = UDim2.new(1, -24, 0, 0),
                Position = UDim2.fromOffset(12, 35),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            }, section)

            new("UIListLayout", {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, items)

            new("UIPadding", {
                PaddingBottom = UDim.new(0, 10)
            }, items)

            local Section = {}

            local function register(name, kind, value, setter, getter)
                local id = tostring(#controls + 1) .. "_" .. name

                controls[id] = {
                    Name = name,
                    Kind = kind,
                    Get = getter,
                    Set = setter,
                    Value = value
                }

                return controls[id]
            end

            function Section:Label(text)
                return new("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, items)
            end

            function Section:Button(text, callback)
                local button = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    AutoButtonColor = false
                }, items)

                corner(button, 8)
                hover(button, Theme.Item, Theme.Hover)
                press(button, Theme.Item)

                button.MouseButton1Click:Connect(function()
                    if callback then
                        task.spawn(callback)
                    end
                end)

                return button
            end

            function Section:Toggle(text, default, callback)
                local value = default == true

                local button = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, items)

                local label = new("TextLabel", {
                    Size = UDim2.new(1, -55, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, button)

                local switch = new("Frame", {
                    Size = UDim2.fromOffset(38, 21),
                    Position = UDim2.new(1, -38, 0.5, -10),
                    BackgroundColor3 = Color3.fromRGB(44, 44, 47),
                    BorderSizePixel = 0
                }, button)

                corner(switch, 15)

                local knob = new("Frame", {
                    Size = UDim2.fromOffset(15, 15),
                    Position = UDim2.fromOffset(3, 3),
                    BackgroundColor3 = Theme.SubText,
                    BorderSizePixel = 0
                }, switch)

                corner(knob, 15)

                local function update(fire)
                    tween(switch, {
                        BackgroundColor3 = value
                            and Theme.Accent
                            or Color3.fromRGB(44, 44, 47)
                    }, 0.16)

                    tween(knob, {
                        Position = value
                            and UDim2.new(1, -18, 0, 3)
                            or UDim2.fromOffset(3, 3),

                        BackgroundColor3 = value
                            and Theme.Background
                            or Theme.SubText
                    }, 0.18)

                    if fire and callback then
                        task.spawn(callback, value)
                    end
                end

                local control = register(
                    text,
                    "Boolean",
                    value,
                    function(newValue, fire)
                        value = newValue == true
                        update(fire)
                    end,
                    function()
                        return value
                    end
                )

                button.MouseButton1Click:Connect(function()
                    control.Set(not value, true)
                end)

                update(false)

                return {
                    Set = function(_, newValue)
                        control.Set(newValue, true)
                    end,

                    Get = function()
                        return value
                    end
                }
            end

            function Section:Slider(text, min, max, default, callback)
                min = min or 0
                max = max or 100

                local value = math.clamp(
                    default or min,
                    min,
                    max
                )

                local holder = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 49),
                    BackgroundTransparency = 1
                }, items)

                new("TextLabel", {
                    Size = UDim2.new(1, -45, 0, 21),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, holder)

                local number = new("TextLabel", {
                    Size = UDim2.fromOffset(40, 21),
                    Position = UDim2.new(1, -40, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = Theme.SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, holder)

                local track = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 4),
                    Position = UDim2.fromOffset(0, 31),
                    BackgroundColor3 = Color3.fromRGB(43, 43, 46),
                    BorderSizePixel = 0
                }, holder)

                corner(track, 5)

                local fill = new("Frame", {
                    Size = UDim2.fromScale(
                        (value - min) / (max - min),
                        1
                    ),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0
                }, track)

                corner(fill, 5)

                local dragging = false

                local function setValue(newValue, fire)
                    value = math.clamp(
                        math.floor(newValue + 0.5),
                        min,
                        max
                    )

                    number.Text = tostring(value)

                    local percent = (value - min) / (max - min)

                    tween(fill, {
                        Size = UDim2.fromScale(percent, 1)
                    }, 0.1)

                    if fire and callback then
                        task.spawn(callback, value)
                    end
                end

                local function updateFromMouse(input)
                    local percent = math.clamp(
                        (input.Position.X - track.AbsolutePosition.X)
                        / track.AbsoluteSize.X,
                        0,
                        1
                    )

                    setValue(
                        min + ((max - min) * percent),
                        true
                    )
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateFromMouse(input)
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateFromMouse(input)
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                local control = register(
                    text,
                    "Number",
                    value,
                    function(newValue, fire)
                        setValue(newValue, fire)
                    end,
                    function()
                        return value
                    end
                )

                return {
                    Set = function(_, newValue)
                        control.Set(newValue, true)
                    end,

                    Get = function()
                        return value
                    end
                }
            end

            function Section:Dropdown(text, choices, default, callback)
                choices = choices or {}

                local value = default or choices[1] or "None"
                local opened = false

                local holder = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false
                }, items)

                local button = new("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false
                }, holder)

                corner(button, 8)

                new("TextLabel", {
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Position = UDim2.fromOffset(11, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, button)

                local current = new("TextLabel", {
                    Size = UDim2.new(0.45, -10, 1, 0),
                    Position = UDim2.new(0.55, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. "  ˅",
                    TextColor3 = Theme.SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, button)

                local menu = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 38),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 50
                }, holder)

                corner(menu, 8)
                stroke(menu, 0.2)

                local list = new("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder
                }, menu)

                local function rebuild()
                    for _, child in ipairs(menu:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    for _, choice in ipairs(choices) do
                        local option = new("TextButton", {
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = Theme.Item,
                            BorderSizePixel = 0,
                            Text = tostring(choice),
                            TextColor3 = Theme.SubText,
                            Font = Enum.Font.Gotham,
                            TextSize = 10,
                            AutoButtonColor = false,
                            ZIndex = 51
                        }, menu)

                        option.MouseEnter:Connect(function()
                            tween(option, {
                                BackgroundColor3 = Theme.Hover,
                                TextColor3 = Theme.Text
                            }, 0.1)
                        end)

                        option.MouseLeave:Connect(function()
                            tween(option, {
                                BackgroundColor3 = Theme.Item,
                                TextColor3 = Theme.SubText
                            }, 0.1)
                        end)

                        option.MouseButton1Click:Connect(function()
                            value = choice
                            current.Text = tostring(value) .. "  ˅"

                            opened = false

                            tween(menu, {
                                Size = UDim2.new(1, 0, 0, 0)
                            }, 0.14)

                            task.delay(0.14, function()
                                if not opened then
                                    menu.Visible = false
                                end
                            end)

                            if callback then
                                task.spawn(callback, value)
                            end
                        end)
                    end
                end

                button.MouseButton1Click:Connect(function()
                    opened = not opened

                    if opened then
                        rebuild()
                        menu.Visible = true

                        local amount = math.min(#choices * 28, 140)

                        tween(menu, {
                            Size = UDim2.new(1, 0, 0, amount)
                        }, 0.18)
                    else
                        tween(menu, {
                            Size = UDim2.new(1, 0, 0, 0)
                        }, 0.14)

                        task.delay(0.14, function()
                            if not opened then
                                menu.Visible = false
                            end
                        end)
                    end
                end)

                local control = register(
                    text,
                    "String",
                    value,
                    function(newValue, fire)
                        value = newValue
                        current.Text = tostring(value) .. "  ˅"

                        if fire and callback then
                            task.spawn(callback, value)
                        end
                    end,
                    function()
                        return value
                    end
                )

                return {
                    Set = function(_, newValue)
                        control.Set(newValue, true)
                    end,

                    Get = function()
                        return value
                    end
                }
            end

            function Section:Keybind(text, default, callback)
                local key = default or Enum.KeyCode.RightControl
                local listening = false

                local button = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false
                }, items)

                corner(button, 8)

                new("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.fromOffset(11, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, button)

                local keyText = new("TextLabel", {
                    Size = UDim2.new(0.4, -10, 1, 0),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = key.Name,
                    TextColor3 = Theme.SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, button)

                button.MouseButton1Click:Connect(function()
                    if listening then
                        return
                    end

                    listening = true
                    keyText.Text = "Press key..."

                    local connection

                    connection = UIS.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.Keyboard then
                            return
                        end

                        key = input.KeyCode
                        keyText.Text = key.Name
                        listening = false

                        connection:Disconnect()

                        if callback then
                            task.spawn(callback, key)
                        end
                    end)
                end)

                UIS.InputBegan:Connect(function(input, processed)
                    if processed or listening then
                        return
                    end

                    if input.KeyCode == key and callback then
                        task.spawn(callback, key, true)
                    end
                end)

                local control = register(
                    text,
                    "KeyCode",
                    key,
                    function(newValue)
                        key = newValue
                        keyText.Text = key.Name
                    end,
                    function()
                        return key
                    end
                )

                return {
                    Set = function(_, newKey)
                        control.Set(newKey)
                    end,

                    Get = function()
                        return key
                    end
                }
            end

            function Section:ColorPicker(text, default, callback)
                local color = default or Color3.new(1, 1, 1)
                local opened = false

                local button = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false
                }, items)

                corner(button, 8)

                new("TextLabel", {
                    Size = UDim2.new(1, -55, 1, 0),
                    Position = UDim2.fromOffset(11, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, button)

                local preview = new("Frame", {
                    Size = UDim2.fromOffset(25, 20),
                    Position = UDim2.new(1, -34, 0.5, -10),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0
                }, button)

                corner(preview, 6)

                local picker = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 38),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 40
                }, items)

                corner(picker, 9)
                stroke(picker, 0.2)

                local grid = new("Frame", {
                    Size = UDim2.new(1, -14, 1, -14),
                    Position = UDim2.fromOffset(7, 7),
                    BackgroundTransparency = 1,
                    ZIndex = 41
                }, picker)

                new("UIGridLayout", {
                    CellSize = UDim2.fromOffset(27, 27),
                    CellPadding = UDim2.fromOffset(5, 5)
                }, grid)

                local palette = {
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(210, 210, 210),
                    Color3.fromRGB(160, 160, 160),
                    Color3.fromRGB(100, 100, 100),
                    Color3.fromRGB(45, 45, 45),
                    Color3.fromRGB(0, 0, 0),

                    Color3.fromRGB(255, 100, 100),
                    Color3.fromRGB(255, 165, 80),
                    Color3.fromRGB(255, 225, 90),
                    Color3.fromRGB(125, 220, 120),
                    Color3.fromRGB(90, 180, 255),
                    Color3.fromRGB(170, 110, 255)
                }

                for _, pickedColor in ipairs(palette) do
                    local swatch = new("TextButton", {
                        BackgroundColor3 = pickedColor,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 42
                    }, grid)

                    corner(swatch, 7)

                    swatch.MouseButton1Click:Connect(function()
                        color = pickedColor
                        preview.BackgroundColor3 = color

                        opened = false

                        tween(picker, {
                            Size = UDim2.new(1, 0, 0, 0)
                        }, 0.14)

                        task.delay(0.14, function()
                            if not opened then
                                picker.Visible = false
                            end
                        end)

                        if callback then
                            task.spawn(callback, color)
                        end
                    end)
                end

                button.MouseButton1Click:Connect(function()
                    opened = not opened

                    if opened then
                        picker.Visible = true

                        tween(picker, {
                            Size = UDim2.new(1, 0, 0, 80)
                        }, 0.18)
                    else
                        tween(picker, {
                            Size = UDim2.new(1, 0, 0, 0)
                        }, 0.14)

                        task.delay(0.14, function()
                            if not opened then
                                picker.Visible = false
                            end
                        end)
                    end
                end)

                local control = register(
                    text,
                    "Color3",
                    color,
                    function(newColor, fire)
                        if typeof(newColor) ~= "Color3" then
                            return
                        end

                        color = newColor
                        preview.BackgroundColor3 = color

                        if fire and callback then
                            task.spawn(callback, color)
                        end
                    end,
                    function()
                        return color
                    end
                )

                return {
                    Set = function(_, newColor)
                        control.Set(newColor, true)
                    end,

                    Get = function()
                        return color
                    end
                }
            end

            function Section:Textbox(text, placeholder, callback)
                local box = new("TextBox", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = "",
                    PlaceholderText = placeholder or "Type something...",
                    PlaceholderColor3 = Theme.Muted,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, items)

                corner(box, 8)

                new("UIPadding", {
                    PaddingLeft = UDim.new(0, 11),
                    PaddingRight = UDim.new(0, 11)
                }, box)

                local control = register(
                    text,
                    "String",
                    "",
                    function(newValue, fire)
                        box.Text = tostring(newValue or "")

                        if fire and callback then
                            task.spawn(callback, box.Text)
                        end
                    end,
                    function()
                        return box.Text
                    end
                )

                box.FocusLost:Connect(function()
                    control.Value = box.Text

                    if callback then
                        task.spawn(callback, box.Text)
                    end
                end)

                return box
            end

            -- handy aliases if you prefer the longer names
            Section.CreateLabel = Section.Label
            Section.CreateButton = Section.Button
            Section.CreateToggle = Section.Toggle
            Section.CreateSlider = Section.Slider
            Section.CreateDropdown = Section.Dropdown
            Section.CreateKeybind = Section.Keybind
            Section.CreateColorPicker = Section.ColorPicker
            Section.CreateTextbox = Section.Textbox

            return Section
        end

        if #tabs == 1 then
            task.defer(function()
                selectTab(tab)
            end)
        end

        return Tab
    end

    --[[ config ]]--

    local function configPath(name)
        return configFolder .. "/" .. name .. ".json"
    end

    function Window:GetConfig()
        local Config = {}

        function Config:Save(name)
            if not writefile then
                return false, "writefile is not available"
            end

            name = name or "default"

            if makefolder and isfolder and not isfolder(configFolder) then
                pcall(makefolder, configFolder)
            end

            local data = {}

            for _, control in pairs(controls) do
                local ok, value = pcall(control.Get)

                if ok then
                    data[control.Name] = {
                        Type = control.Kind,
                        Value = serialize(value, control.Kind)
                    }
                end
            end

            local success, encoded = pcall(function()
                return HttpService:JSONEncode(data)
            end)

            if not success then
                return false, encoded
            end

            local ok, err = pcall(function()
                writefile(configPath(name), encoded)
            end)

            return ok, err
        end

        function Config:Load(name)
            if not readfile or not isfile then
                return false, "readfile/isfile is not available"
            end

            name = name or "default"

            if not isfile(configPath(name)) then
                return false, "config does not exist"
            end

            local ok, result = pcall(function()
                return HttpService:JSONDecode(
                    readfile(configPath(name))
                )
            end)

            if not ok then
                return false, result
            end

            for _, control in pairs(controls) do
                local saved = result[control.Name]

                if saved then
                    local value = deserialize(
                        saved.Value,
                        saved.Type or control.Kind
                    )

                    pcall(function()
                        control.Set(value, false)
                    end)
                end
            end

            return true
        end

        function Config:Delete(name)
            if not delfile or not isfile then
                return false
            end

            name = name or "default"

            if not isfile(configPath(name)) then
                return false
            end

            return pcall(function()
                delfile(configPath(name))
            end)
        end

        function Config:GetConfigs()
            if not listfiles then
                return {}
            end

            if not isfolder or not isfolder(configFolder) then
                return {}
            end

            local result = {}

            for _, file in ipairs(listfiles(configFolder)) do
                local fileName = file:match("([^/\\]+)%.json$")

                if fileName then
                    table.insert(result, fileName)
                end
            end

            table.sort(result)

            return result
        end

        return Config
    end

    --[[ notifications ]]--

    local notifications = new("Frame", {
        Size = UDim2.fromOffset(230, 300),
        Position = UDim2.new(1, -245, 1, -315),
        BackgroundTransparency = 1
    }, gui)

    new("UIListLayout", {
        Padding = UDim.new(0, 7),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    }, notifications)

    function Window:Notify(message, duration)
        duration = duration or 3

        local note = new("Frame", {
            Size = UDim2.new(1, 0, 0, 43),
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        }, notifications)

        corner(note, 10)
        stroke(note, 0.25)

        local text = new("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = Theme.Text,
            TextTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, note)

        tween(note, {
            BackgroundTransparency = 0
        }, 0.2)

        tween(text, {
            TextTransparency = 0
        }, 0.2)

        task.delay(duration, function()
            tween(note, {
                BackgroundTransparency = 1
            }, 0.2)

            tween(text, {
                TextTransparency = 1
            }, 0.2)

            task.delay(0.22, function()
                note:Destroy()
            end)
        end)
    end

    --[[ window controls ]]--

    local visible = true

    function Window:Toggle()
        visible = not visible

        if visible then
            main.Visible = true
            shadow.Visible = true

            main.Size = UDim2.fromOffset(width - 18, height - 18)
            shadow.BackgroundTransparency = 1

            tween(main, {
                Size = UDim2.fromOffset(width, height)
            }, 0.22)

            tween(shadow, {
                BackgroundTransparency = 0.7
            }, 0.22)
        else
            tween(main, {
                Size = UDim2.fromOffset(width - 18, height - 18)
            }, 0.18)

            tween(shadow, {
                BackgroundTransparency = 1
            }, 0.18)

            task.delay(0.18, function()
                if not visible then
                    main.Visible = false
                    shadow.Visible = false
                end
            end)
        end
    end

    function Window:Destroy()
        gui:Destroy()
    end

    makeDraggable(main, header)

    -- small entrance instead of having it pop in
    main.Size = UDim2.fromOffset(width - 18, height - 18)
    shadow.BackgroundTransparency = 1

    tween(main, {
        Size = UDim2.fromOffset(width, height)
    }, 0.28)

    tween(shadow, {
        BackgroundTransparency = 0.7
    }, 0.28)

    return Window
end

return Library
