--[[ references ]]--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Parent = (gethui and gethui()) or game:GetService("CoreGui")

--[[ library ]]--

local Library = {}

local Theme = {
    Main = Color3.fromRGB(18, 18, 20),
    Panel = Color3.fromRGB(23, 23, 25),
    Item = Color3.fromRGB(29, 29, 32),
    Hover = Color3.fromRGB(38, 38, 41),
    Pressed = Color3.fromRGB(45, 45, 48),

    White = Color3.fromRGB(242, 242, 245),
    Grey = Color3.fromRGB(155, 155, 160),
    DarkGrey = Color3.fromRGB(100, 100, 105),

    Accent = Color3.fromRGB(235, 235, 238),
    Border = Color3.fromRGB(55, 55, 59)
}

local function make(class, props, parent)
    local object = Instance.new(class)

    for key, value in pairs(props or {}) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function round(object, size)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, size or 10)
    corner.Parent = object
    return corner
end

local function outline(object, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Transparency = transparency or 0.35
    stroke.Parent = object
    return stroke
end

local function animate(object, props, speed)
    TweenService:Create(
        object,
        TweenInfo.new(
            speed or 0.2,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        props
    ):Play()
end

local function clickAnimation(button, normal, pressed)
    button.MouseButton1Down:Connect(function()
        animate(button, {
            BackgroundColor3 = pressed
        }, 0.08)
    end)

    button.MouseButton1Up:Connect(function()
        animate(button, {
            BackgroundColor3 = normal
        }, 0.14)
    end)

    button.MouseLeave:Connect(function()
        animate(button, {
            BackgroundColor3 = normal
        }, 0.14)
    end)
end

local function addHover(button, normal, hover)
    button.MouseEnter:Connect(function()
        animate(button, {
            BackgroundColor3 = hover
        }, 0.16)
    end)

    button.MouseLeave:Connect(function()
        animate(button, {
            BackgroundColor3 = normal
        }, 0.16)
    end)
end

local function makeDraggable(frame, handle)
    local moving = false
    local startMouse
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        moving = true
        startMouse = input.Position
        startPos = frame.Position
    end)

    UIS.InputChanged:Connect(function(input)
        if not moving or input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = input.Position - startMouse

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            moving = false
        end
    end)
end

--[[ window ]]--

function Library:CreateWindow(options)
    options = options or {}

    local width = options.Width or 590
    local height = options.Height or 360

    local Gui = make("ScreenGui", {
        Name = "MinimalUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, Parent)

    local Shadow = make("Frame", {
        Size = UDim2.fromOffset(width + 12, height + 12),
        Position = UDim2.new(0.5, -((width + 12) / 2), 0.5, -((height + 12) / 2) + 5),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0
    }, Gui)

    round(Shadow, 18)

    local Main = make("Frame", {
        Size = UDim2.fromOffset(width, height),
        Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0
    }, Gui)

    round(Main, 15)
    outline(Main, 0.15)

    local Header = make("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1
    }, Main)

    local Title = make("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(17, 0),
        BackgroundTransparency = 1,
        Text = options.Title or "Orbit",
        TextColor3 = Theme.White,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Header)

    local Close = make("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -38, 0, 9),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.Grey,
        Font = Enum.Font.Gotham,
        TextSize = 18,
        AutoButtonColor = false
    }, Header)

    Close.MouseEnter:Connect(function()
        animate(Close, {TextColor3 = Theme.White}, 0.15)
    end)

    Close.MouseLeave:Connect(function()
        animate(Close, {TextColor3 = Theme.Grey}, 0.15)
    end)

    Close.MouseButton1Click:Connect(function()
        animate(Main, {
            Size = UDim2.fromOffset(width - 12, height - 12),
            BackgroundTransparency = 1
        }, 0.18)

        animate(Shadow, {
            BackgroundTransparency = 1
        }, 0.18)

        task.delay(0.18, function()
            Gui:Destroy()
        end)
    end)

    local Line = make("Frame", {
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.fromOffset(12, 47),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0
    }, Main)

    local Sidebar = make("Frame", {
        Size = UDim2.new(0, 125, 1, -60),
        Position = UDim2.fromOffset(10, 54),
        BackgroundTransparency = 1
    }, Main)

    local Tabs = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    }, Sidebar)

    make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Tabs)

    local Content = make("Frame", {
        Size = UDim2.new(1, -145, 1, -60),
        Position = UDim2.fromOffset(135, 54),
        BackgroundTransparency = 1
    }, Main)

    local PageName = make("TextLabel", {
        Size = UDim2.new(1, -15, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.White,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Content)

    local Pages = make("Frame", {
        Size = UDim2.new(1, 0, 1, -34),
        Position = UDim2.fromOffset(0, 34),
        BackgroundTransparency = 1
    }, Content)

    local tabs = {}
    local firstPage

    local function showTab(info)
        for _, tab in ipairs(tabs) do
            local selected = tab == info

            animate(tab.Button, {
                BackgroundColor3 = selected and Theme.Item or Theme.Main
            }, 0.18)

            animate(tab.Text, {
                TextColor3 = selected and Theme.White or Theme.Grey
            }, 0.18)

            tab.Page.Visible = selected
        end

        PageName.Text = info.Name
    end

    function Window:CreateTab(name)
        local Page = make("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.DarkGrey,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        }, Pages)

        make("UIPadding", {
            PaddingRight = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 8)
        }, Page)

        make("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, Page)

        local TabButton = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Main,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        }, Tabs)

        round(TabButton, 9)

        local TabText = make("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.Grey,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        }, TabButton)

        local info = {
            Name = name,
            Page = Page,
            Button = TabButton,
            Text = TabText
        }

        table.insert(tabs, info)

        addHover(TabButton, Theme.Main, Theme.Item)

        TabButton.MouseButton1Click:Connect(function()
            showTab(info)
        end)

        local Tab = {}

        function Tab:CreateSection(title)
            local Section = make("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            }, Page)

            round(Section, 11)
            outline(Section, 0.35)

            local SectionTitle = make("TextLabel", {
                Size = UDim2.new(1, -24, 0, 35),
                Position = UDim2.fromOffset(12, 0),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Theme.White,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            }, Section)

            local Items = make("Frame", {
                Size = UDim2.new(1, -24, 0, 0),
                Position = UDim2.fromOffset(12, 35),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            }, Section)

            make("UIListLayout", {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, Items)

            make("UIPadding", {
                PaddingBottom = UDim.new(0, 11)
            }, Items)

            local SectionAPI = {}

            function SectionAPI:CreateLabel(text)
                return make("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 27),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Grey,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, Items)
            end

            function SectionAPI:CreateButton(text, callback)
                local Button = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = text,
                    TextColor3 = Theme.White,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    AutoButtonColor = false
                }, Items)

                round(Button, 8)
                clickAnimation(Button, Theme.Item, Theme.Pressed)

                Button.MouseEnter:Connect(function()
                    animate(Button, {BackgroundColor3 = Theme.Hover}, 0.15)
                end)

                Button.MouseLeave:Connect(function()
                    animate(Button, {BackgroundColor3 = Theme.Item}, 0.15)
                end)

                Button.MouseButton1Click:Connect(function()
                    if callback then
                        task.spawn(callback)
                    end
                end)

                return Button
            end

            function SectionAPI:CreateToggle(text, default, callback)
                local enabled = default == true

                local Button = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                }, Items)

                local Text = make("TextLabel", {
                    Size = UDim2.new(1, -55, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.White,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, Button)

                local Switch = make("Frame", {
                    Size = UDim2.fromOffset(38, 21),
                    Position = UDim2.new(1, -38, 0.5, -10),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 48),
                    BorderSizePixel = 0
                }, Button)

                round(Switch, 15)

                local Knob = make("Frame", {
                    Size = UDim2.fromOffset(15, 15),
                    Position = UDim2.fromOffset(3, 3),
                    BackgroundColor3 = Theme.Grey,
                    BorderSizePixel = 0
                }, Switch)

                round(Knob, 15)

                local function update(fire)
                    animate(Switch, {
                        BackgroundColor3 = enabled and Theme.White or Color3.fromRGB(45, 45, 48)
                    }, 0.16)

                    animate(Knob, {
                        Position = enabled
                            and UDim2.new(1, -18, 0, 3)
                            or UDim2.fromOffset(3, 3),
                        BackgroundColor3 = enabled and Theme.Main or Theme.Grey
                    }, 0.18)

                    if fire and callback then
                        task.spawn(callback, enabled)
                    end
                end

                Button.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    update(true)
                end)

                update(false)

                return {
                    Set = function(_, value)
                        enabled = value == true
                        update(true)
                    end,

                    Get = function()
                        return enabled
                    end
                }
            end

            function SectionAPI:CreateSlider(text, min, max, default, callback)
                local amount = math.clamp(default or min, min, max)

                local Holder = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 49),
                    BackgroundTransparency = 1
                }, Items)

                local Label = make("TextLabel", {
                    Size = UDim2.new(1, -45, 0, 21),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.White,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, Holder)

                local Number = make("TextLabel", {
                    Size = UDim2.fromOffset(40, 21),
                    Position = UDim2.new(1, -40, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(amount),
                    TextColor3 = Theme.Grey,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, Holder)

                local Track = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 4),
                    Position = UDim2.fromOffset(0, 31),
                    BackgroundColor3 = Color3.fromRGB(43, 43, 46),
                    BorderSizePixel = 0
                }, Holder)

                round(Track, 5)

                local Fill = make("Frame", {
                    Size = UDim2.fromScale((amount - min) / (max - min), 1),
                    BackgroundColor3 = Theme.White,
                    BorderSizePixel = 0
                }, Track)

                round(Fill, 5)

                local dragging = false

                local function setAmount(value, fire)
                    amount = math.clamp(value, min, max)

                    local percent = (amount - min) / (max - min)

                    Number.Text = tostring(amount)

                    animate(Fill, {
                        Size = UDim2.fromScale(percent, 1)
                    }, 0.1)

                    if fire and callback then
                        task.spawn(callback, amount)
                    end
                end

                local function move(input)
                    local percent = math.clamp(
                        (input.Position.X - Track.AbsolutePosition.X) /
                        Track.AbsoluteSize.X,
                        0,
                        1
                    )

                    local value = min + ((max - min) * percent)

                    setAmount(math.floor(value + 0.5), true)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        move(input)
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        move(input)
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                return {
                    Set = function(_, value)
                        setAmount(value, true)
                    end,

                    Get = function()
                        return amount
                    end
                }
            end

            function SectionAPI:CreateDropdown(text, options, default, callback)
                local selected = default or options[1] or "None"
                local opened = false

                local Holder = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false
                }, Items)

                local Button = make("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false
                }, Holder)

                round(Button, 8)

                local Name = make("TextLabel", {
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Position = UDim2.fromOffset(11, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.White,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, Button)

                local Current = make("TextLabel", {
                    Size = UDim2.new(0.4, -10, 1, 0),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected .. "  ˅",
                    TextColor3 = Theme.Grey,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, Button)

                local List = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 38),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 20
                }, Holder)

                round(List, 8)
                outline(List, 0.2)

                make("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder
                }, List)

                local function rebuild()
                    for _, child in ipairs(List:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    for _, option in ipairs(options) do
                        local optionButton = make("TextButton", {
                            Size = UDim2.new(1, 0, 0, 29),
                            BackgroundColor3 = Theme.Item,
                            BorderSizePixel = 0,
                            Text = option,
                            TextColor3 = Theme.Grey,
                            Font = Enum.Font.Gotham,
                            TextSize = 10,
                            AutoButtonColor = false,
                            ZIndex = 21
                        }, List)

                        optionButton.MouseEnter:Connect(function()
                            animate(optionButton, {
                                BackgroundColor3 = Theme.Hover
                            }, 0.12)
                        end)

                        optionButton.MouseLeave:Connect(function()
                            animate(optionButton, {
                                BackgroundColor3 = Theme.Item
                            }, 0.12)
                        end)

                        optionButton.MouseButton1Click:Connect(function()
                            selected = option
                            Current.Text = selected .. "  ˅"
                            opened = false
                            List.Visible = false
                            List.Size = UDim2.new(1, 0, 0, 0)

                            if callback then
                                task.spawn(callback, selected)
                            end
                        end)
                    end
                end

                Button.MouseButton1Click:Connect(function()
                    opened = not opened

                    if opened then
                        rebuild()
                        List.Visible = true
                        local target = #options * 29
                        animate(List, {
                            Size = UDim2.new(1, 0, 0, math.min(target, 145))
                        }, 0.18)
                    else
                        animate(List, {
                            Size = UDim2.new(1, 0, 0, 0)
                        }, 0.15)

                        task.delay(0.15, function()
                            if not opened then
                                List.Visible = false
                            end
                        end)
                    end
                end)

                return {
                    Set = function(_, value)
                        selected = value
                        Current.Text = selected .. "  ˅"

                        if callback then
                            task.spawn(callback, selected)
                        end
                    end,

                    Get = function()
                        return selected
                    end
                }
            end

            function SectionAPI:CreateTextbox(text, placeholder, callback)
                local Box = make("TextBox", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = "",
                    PlaceholderText = placeholder or "Type something...",
                    PlaceholderColor3 = Theme.DarkGrey,
                    TextColor3 = Theme.White,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, Items)

                round(Box, 8)

                local padding = Instance.new("UIPadding")
                padding.PaddingLeft = UDim.new(0, 11)
                padding.PaddingRight = UDim.new(0, 11)
                padding.Parent = Box

                Box.FocusLost:Connect(function()
                    if callback then
                        task.spawn(callback, Box.Text)
                    end
                end)

                return Box
            end

            function SectionAPI:CreateKeybind(text, default, callback)
                local current = default or Enum.KeyCode.RightControl
                local listening = false

                local Button = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false
                }, Items)

                round(Button, 8)

                local Label = make("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.fromOffset(11, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.White,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, Button)

                local Key = make("TextLabel", {
                    Size = UDim2.new(0.4, -10, 1, 0),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = current.Name,
                    TextColor3 = Theme.Grey,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, Button)

                Button.MouseButton1Click:Connect(function()
                    if listening then
                        return
                    end

                    listening = true
                    Key.Text = "Press key..."

                    local connection
                    connection = UIS.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
                            return
                        end

                        current = input.KeyCode
                        Key.Text = current.Name
                        listening = false

                        connection:Disconnect()

                        if callback then
                            task.spawn(callback, current)
                        end
                    end)
                end)

                UIS.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed or listening then
                        return
                    end

                    if input.KeyCode == current and callback then
                        task.spawn(callback, current, true)
                    end
                end)

                return {
                    Set = function(_, key)
                        current = key
                        Key.Text = key.Name
                    end,

                    Get = function()
                        return current
                    end
                }
            end

            function SectionAPI:CreateColorPicker(text, default, callback)
                local picked = default or Color3.new(1, 1, 1)
                local opened = false

                local Button = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false
                }, Items)

                round(Button, 8)

                local Label = make("TextLabel", {
                    Size = UDim2.new(1, -55, 1, 0),
                    Position = UDim2.fromOffset(11, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.White,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, Button)

                local Preview = make("Frame", {
                    Size = UDim2.fromOffset(25, 20),
                    Position = UDim2.new(1, -34, 0.5, -10),
                    BackgroundColor3 = picked,
                    BorderSizePixel = 0
                }, Button)

                round(Preview, 6)

                local Picker = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 86),
                    Position = UDim2.fromOffset(0, 39),
                    BackgroundColor3 = Theme.Item,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 30
                }, Items)

                round(Picker, 9)
                outline(Picker, 0.2)

                local colors = {
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(220, 220, 220),
                    Color3.fromRGB(170, 170, 170),
                    Color3.fromRGB(110, 110, 110),
                    Color3.fromRGB(45, 45, 45),
                    Color3.fromRGB(0, 0, 0),
                    Color3.fromRGB(255, 90, 90),
                    Color3.fromRGB(255, 180, 80),
                    Color3.fromRGB(255, 230, 90),
                    Color3.fromRGB(120, 220, 120),
                    Color3.fromRGB(90, 180, 255),
                    Color3.fromRGB(175, 110, 255)
                }

                local grid = make("Frame", {
                    Size = UDim2.new(1, -16, 1, -16),
                    Position = UDim2.fromOffset(8, 8),
                    BackgroundTransparency = 1,
                    ZIndex = 31
                }, Picker)

                make("UIGridLayout", {
                    CellSize = UDim2.fromOffset(28, 28),
                    CellPadding = UDim2.fromOffset(5, 5)
                }, grid)

                for _, color in ipairs(colors) do
                    local swatch = make("TextButton", {
                        BackgroundColor3 = color,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 32
                    }, grid)

                    round(swatch, 7)

                    swatch.MouseButton1Click:Connect(function()
                        picked = color
                        Preview.BackgroundColor3 = color
                        opened = false
                        Picker.Visible = false

                        if callback then
                            task.spawn(callback, picked)
                        end
                    end)
                end

                Button.MouseButton1Click:Connect(function()
                    opened = not opened
                    Picker.Visible = opened
                end)

                return {
                    Set = function(_, color)
                        picked = color
                        Preview.BackgroundColor3 = color

                        if callback then
                            task.spawn(callback, picked)
                        end
                    end,

                    Get = function()
                        return picked
                    end
                }
            end

            return SectionAPI
        end

        if not firstPage then
            firstPage = info
            task.defer(function()
                showTab(info)
            end)
        end

        return Tab
    end

    --[[ config ]]--

    function Window:CreateConfig(name)
        local folder = options.ConfigFolder or "MinimalUI"

        local api = {}

        local function path()
            return folder .. "/" .. name .. ".cfg"
        end

        local function collect()
            local data = {}

            for _, object in ipairs(Main:GetDescendants()) do
                if object:GetAttribute("ConfigName") then
                    data[object:GetAttribute("ConfigName")] = object:GetAttribute("Value")
                end
            end

            return data
        end

        function api:Save()
            if not writefile then
                return false
            end

            if makefolder and not isfolder(folder) then
                makefolder(folder)
            end

            local data = collect()

            writefile(path(), game:GetService("HttpService"):JSONEncode(data))
            return true
        end

        function api:Load()
            if not readfile or not isfile or not isfile(path()) then
                return false
            end

            local HttpService = game:GetService("HttpService")
            local data = HttpService:JSONDecode(readfile(path()))

            for _, object in ipairs(Main:GetDescendants()) do
                local key = object:GetAttribute("ConfigName")

                if key and data[key] ~= nil then
                    object:SetAttribute("Value", data[key])
                end
            end

            return true
        end

        function api:Delete()
            if isfile and isfile(path()) and delfile then
                delfile(path())
                return true
            end

            return false
        end

        function api:Exists()
            return isfile and isfile(path()) or false
        end

        return api
    end

    --[[ notifications ]]--

    local notifications = make("Frame", {
        Size = UDim2.fromOffset(230, 300),
        Position = UDim2.new(1, -245, 1, -315),
        BackgroundTransparency = 1
    }, Gui)

    make("UIListLayout", {
        Padding = UDim.new(0, 7),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    }, notifications)

    function Window:Notify(text, duration)
        duration = duration or 3

        local note = make("Frame", {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            BackgroundTransparency = 1
        }, notifications)

        round(note, 10)
        outline(note, 0.25)

        local label = make("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.White,
            TextTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, note)

        animate(note, {
            BackgroundTransparency = 0
        }, 0.2)

        animate(label, {
            TextTransparency = 0
        }, 0.2)

        task.delay(duration, function()
            animate(note, {
                BackgroundTransparency = 1
            }, 0.2)

            animate(label, {
                TextTransparency = 1
            }, 0.2)

            task.delay(0.22, function()
                note:Destroy()
            end)
        end)
    end

    function Window:Destroy()
        Gui:Destroy()
    end

    makeDraggable(Main, Header)

    -- Small entrance animation so it doesn't just pop onto the screen.
    Main.Size = UDim2.fromOffset(width - 20, height - 20)
    Shadow.BackgroundTransparency = 1

    animate(Main, {
        Size = UDim2.fromOffset(width, height)
    }, 0.3)

    animate(Shadow, {
        BackgroundTransparency = 0.55
    }, 0.3)

    local Window = {}

    Window.CreateTab = function(_, ...)
        return createTab(...)
    end

    return setmetatable(Window, {
        __index = {
            CreateTab = function(_, ...)
                return Window:CreateTab(...)
            end
        }
    })
end

return Library
