local GetService = game.GetService;

local Services = {
    UserInputService = GetService(game, 'UserInputService'),
    ReplicatedStorage = GetService(game, 'ReplicatedStorage'),
    TweenService = GetService(game, 'TweenService'),
    ScriptContext = GetService(game, 'ScriptContext'),
    RunService = GetService(game, 'RunService'),
    Players = GetService(game, 'Players'),
    HttpService = GetService(game, 'HttpService'),
}

local Module = {
    Settings = {
        Enabled = true,
        DistanceText = true,
        Range = 20000,
        BaseColor = Color3.fromRGB(255, 255, 255)
    },
    Groups = {}
}

Module.__index = Module

function Module.new(Group : string , Instance : Instance , Text : string)
    local self = setmetatable({
        Group = Group or 'All',
        Instance = Instance,
        Drawing = Drawing.new('Text'),
        Properties = { Enabled = true , Color = Module.Settings.BaseColor , Text = Text , Size = 15 , Font = 1 },
        Connections = {}
    } , Module)

    self.Drawing.Center = true
    self.Drawing.Outline = true

    if not Module.Groups[self.Group] then
        Module.Groups[self.Group] = {}
    end

    self.Key = #Module.Groups[self.Group] + 1

    table.insert(Module.Groups[self.Group], self)
    return self
end

function Module.SetGroupVisibility(Group : string , Value : boolean)
    for _,Esp in next, Module.Groups[Group] do
        Esp.Properties.Enabled = Value
    end
end

function Module.SetGroupColor(Group : string , Value : Color3)
    for _,Esp in next, Module.Groups[Group] do
        Esp.Properties.Color = Value
    end
end

function Module:SetupUpdateConnection()
    self.Connections['UpdateConnection'] = Services.RunService.RenderStepped:Connect(function()
        local Vector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(self.Instance:GetPivot().Position);
        local Magnitude = math.round((Services.Players.LocalPlayer.Character:GetPivot().Position - self.Instance:GetPivot().Position).Magnitude) or 0

        self.Drawing.Position = Vector2.new(Vector.X , Vector.Y);
        self.Drawing.Color = self.Properties.Color
        self.Drawing.Size = self.Properties.Size
        self.Drawing.Font = self.Properties.Font

        if Module.Settings.DistanceText then
            self.Drawing.Text = `{self.Properties.Text} [{Magnitude}]`
        else
            self.Drawing.Text = self.Properties.Text
        end

        if Module.Settings.Enabled then
            if self.Properties.Enabled then
                if OnScreen then
                    if Magnitude < Module.Settings.Range then
                        self.Drawing.Visible = true
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
end

function Module:SetupParentConnection()
    self.Connections['ParentConnection'] = self.Instance:GetPropertyChangedSignal('Parent'):Connect(function()
        if self.Instance.Parent == nil then
            self:Remove();
        end
    end)
end

function Module:Remove()
    for _,Connection in next, self.Connections do
        Connection:Disconnect();
    end

    self.Drawing:Remove();
    table.remove(Module.Groups[self.Group] , self.Key);
end

function Module.Unload()
    for _,Group in next, Module.Groups do
        for _,Table in next, Group do
            Table:Remove();
        end
    end
end

function Module:Setup()
    self:SetupUpdateConnection();
    self:SetupParentConnection();
end

return Module
