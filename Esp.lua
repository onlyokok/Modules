local Module = { Settings = { Enabled = true , Range = 9e9 } , Groups = {   } }
Module.__index = Module

function Module.new(Options)
    local self = setmetatable({
        Group = Options.Group or 'All',
        Instance = Options.Instance,
        Text = Options.Text or Options.Instance.Name,
        Connections = {  }
    }, Module)

    self.Drawing = Drawing.new('Text')
    self.Drawing.Center = true
    self.Drawing.Outline = true
    self.Drawing.Font = 1
    self.Drawing.Size = 15

    if not Module.Groups[self.Group] then
        Module.Groups[self.Group] = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255),
            Content = {  }
        }
    end

    self.Key = game:GetService('HttpService'):GenerateGUID(false)
    Module.Groups[self.Group].Content[self.Key] = self

    self:Setup()

    return self
end

function Module:Setup()
    self.Connections['UpdateConnections'] = game:GetService('RunService').RenderStepped:Connect(function()
        local Vector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(self.Instance:GetPivot().Position)
        local Magnitude = math.round((game:GetService('Players').LocalPlayer.Character:GetPivot().Position - self.Instance:GetPivot().Position).Magnitude)

        self.Drawing.Position = Vector2.new(Vector.X, Vector.Y)
        self.Drawing.Color = Module.Groups[self.Group].Color
        self.Drawing.Text = `{self.Text} [{Magnitude}]`

        if Module.Settings.Enabled then
            if Module.Groups[self.Group].Enabled then
                if Magnitude < Module.Settings.Range then
                    if OnScreen then
                        self.Drawing.Visible = true
                    else
                        self.Drawing.Visible = false
                    end
                else
                    self.Drawing.Visible = false
                end
            else
                self.Drawing.Visible = false
            end
        else
            self.Drawing.Visible = false
        end
    end)

    self.Connections['ParentConnection'] = self.Instance:GetPropertyChangedSignal('Parent'):Connect(function()
        if self.Instance.Parent == nil then
            self:Remove()
        end
    end)
end

function Module:Remove()
    for _,Connection in next, self.Connections do
        Connection:Disconnect()
    end

    self.Drawing:Remove()
    Module.Groups[self.Group].Content[self.Key] = nil
end

function Module.SetGroupVisibility(Group, Value)
    if not Module.Groups[Group] then
        Module.Groups[Group] = {
            Enabled = Value,
            Color = Color3.fromRGB(255, 255, 255),
            Content = {  }
        }
    end
end

function Module.SetGroupColor(Group, Value)
    Module.Groups[Group] = {
            Enabled = true,
            Color = Value,
            Content = {  }
        }
end

function Module.RemoveAllInstances()
    for _,Group in next, Module.Groups do
        for _,Value in next, Group.Content do
            Value:Remove()
        end
    end
end

return Module
