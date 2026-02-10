--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
}

--// Elytra-UI Protection
local ElytraUI = {
	WindowCreated = false,
	ActiveFunctions = {},
	MinimizeIconVisible = true,
	MinimizeIcon = nil,
	HubSettings = {
		HubName = "Elytra Hub",
		GameName = "Universal",
		HubDescription = "A powerful UI library for Roblox",
		CreatorName = "RAKET90 (romb_pa)",
		RepositoryUrl = "https://github.com/karatdushi-hub/elytra-ui"
	}
}

local Theme = { --// (Dark Theme)
	--// Frames:
	Primary = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(35, 35, 35),
	Component = Color3.fromRGB(40, 40, 40),
	Interactables = Color3.fromRGB(45, 45, 45),

	--// Text:
	Tab = Color3.fromRGB(200, 200, 200),
	Title = Color3.fromRGB(240,240,240),
	Description = Color3.fromRGB(200,200,200),

	--// Outlines:
	Shadow = Color3.fromRGB(0, 0, 0),
	Outline = Color3.fromRGB(40, 40, 40),

	--// Image:
	Icon = Color3.fromRGB(220, 220, 220),
}

--// Predefined Themes
local Themes = {
	Light = {
		Primary = Color3.fromRGB(232, 232, 232),
		Secondary = Color3.fromRGB(255, 255, 255),
		Component = Color3.fromRGB(245, 245, 245),
		Interactables = Color3.fromRGB(235, 235, 235),
		Tab = Color3.fromRGB(50, 50, 50),
		Title = Color3.fromRGB(0, 0, 0),
		Description = Color3.fromRGB(100, 100, 100),
		Outline = Color3.fromRGB(210, 210, 210),
		Icon = Color3.fromRGB(100, 100, 100)
	},
	Dark = {
		Primary = Color3.fromRGB(30, 30, 30),
		Secondary = Color3.fromRGB(35, 35, 35),
		Component = Color3.fromRGB(40, 40, 40),
		Interactables = Color3.fromRGB(45, 45, 45),
		Tab = Color3.fromRGB(200, 200, 200),
		Title = Color3.fromRGB(240, 240, 240),
		Description = Color3.fromRGB(200, 200, 200),
		Outline = Color3.fromRGB(40, 40, 40),
		Icon = Color3.fromRGB(220, 220, 220)
	},
	Void = {
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(20, 20, 20),
		Component = Color3.fromRGB(25, 25, 25),
		Interactables = Color3.fromRGB(30, 30, 30),
		Tab = Color3.fromRGB(200, 200, 200),
		Title = Color3.fromRGB(240, 240, 240),
		Description = Color3.fromRGB(200, 200, 200),
		Outline = Color3.fromRGB(40, 40, 40),
		Icon = Color3.fromRGB(220, 220, 220)
	}
}

--// Services & Functions
local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

local Tween = function(Object : Instance, Speed : number, Properties : {},  Info : { EasingStyle: Enum?, EasingDirection: Enum? })
	local Style, Direction

	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end

	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = (Property);
	end

	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}

	return UDim2.new(unpack(New))
end

local Color = function(Color, Factor, Mode)
	Mode = Mode or Setup.ThemeMode

	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;

		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		Connect(Canvas.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position

				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		Connect(Canvas.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				DragInput = Input
			end
		end)

		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end
end

Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}

Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")

			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)

				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))

				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)

				local NewPosition = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
			end
		end

		Connect(Player.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Setup [UI]
if (identifyexecutor) then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
	-- Custom Blur implementation
	Blur = {};
	local Lighting = game:GetService("Lighting");
	local RunService = game:GetService("RunService");

	Blur.BlurEnabled = {}

	function Blur.new(frame, blurIntensity)
		local self = setmetatable({
			blurIntensity = blurIntensity or 0.5;
			depthOfField = Instance.new("DepthOfFieldEffect");
			root = Instance.new("Folder");

			parts = {};
			parents = {};

			camera = workspace.CurrentCamera;
			bindId = "neon:blur_effect";

			frame = Instance.new("Frame");
			folder = Instance.new("Folder");
			owner = frame;

		}, Blur);

		table.insert(Blur.BlurEnabled, frame)

		self.depthOfField.Name = "";
		self.depthOfField.Parent = Lighting;
		self.depthOfField.FarIntensity = 0;
		self.depthOfField.FocusDistance = 51.6;
		self.depthOfField.InFocusRadius = 50;
		self.depthOfField.NearIntensity = self.blurIntensity;

		self.root.Name = "blurSnox";
		self.root.Parent = self.camera;

		self.frame.Name = "blurEffect";
		self.frame.Parent = frame;
		self.frame.Size = UDim2.new(0.95, 0, 0.95, 0);
		self.frame.Position = UDim2.new(0.5, 0, 0.5, 0);
		self.frame.AnchorPoint = Vector2.new(0.5, 0.5);
		self.frame.BackgroundTransparency = 1;

		self.folder.Parent = self.root;
		self.folder.Name = self.frame.Name;
		self.parents[#self.parents + 1] = self.frame;

		local continue = self:isNotNaN(self.camera:ScreenPointToRay(0, 0).Origin.x);
		while (not continue) do
			RunService.RenderStepped:Wait();
			continue = self:isNotNaN(self.camera:ScreenPointToRay(0, 0).Origin.x);
		end;

		self:bindToRenderStep();

		return self;
	end;

	function Blur:isNotNaN(x)
		return x == x;
	end;

	function Blur:updateOrientation(fetchProperties)
		local properties = {
			Transparency = 0.98;
			BrickColor = BrickColor.new('Institutional white');
		};

		local zIndex = (1 - 0.05 * self.frame.ZIndex);

		local tl, br = self.frame.AbsolutePosition, self.frame.AbsolutePosition + self.frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)

		local rot = 0;

		for _, v in ipairs(self.parents) do
			rot = rot + v.Rotation
		end

		if rot ~= 0 and rot%180 ~= 0 then
			local mid, s, c, vec = tl:lerp(br, 0.5), math.sin(math.rad(rot)), math.cos(math.rad(rot)), tl;
			tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid;
			tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid;
			bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid;
			br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid;
		end

		self:drawQuad(
			self.camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
			self.camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
			self.camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
			self.camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
			self.parts
		);

		if (fetchProperties) then
			for _, pt in pairs(self.parts) do
				pt.Parent = self.folder
			end;

			for propName, propValue in pairs(properties) do
				for _, pt in pairs(self.parts) do
					pt[propName] = propValue;
				end;
			end;
		end;
	end;

	function Blur:drawQuad(v1, v2, v3, v4, parts)
		parts[1], parts[2] = self:drawTriangle(v1, v2, v3, parts[1], parts[2]);
		parts[3], parts[4] = self:drawTriangle(v3, v2, v4, parts[3], parts[4]);
	end;

	function Blur:drawTriangle(v1, v2, v3, p0, p1)
		local s1 = (v1 - v2).magnitude;
		local s2 = (v2 - v3).magnitude;
		local s3 = (v3 - v1).magnitude;

		local smax = math.max(s1, s2, s3);

		local A, B, C
		if (s1 == smax) then
			A, B, C = v1, v2, v3;
		elseif (s2 == smax) then
			A, B, C = v2, v3, v1;
		elseif (s3 == smax) then
			A, B, C = v3, v1, v2;
		end;

		local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude;
		local perp = math.sqrt((C - A).magnitude ^ 2 - para * para);
		local dif_para = (A - B).magnitude - para;

		local st = CFrame.new(B, A);
		local za = CFrame.Angles(math.pi / 2, 0, 0);

		local cf0 = st;

		local Top_Look = (cf0 * za).lookVector;
		local Mid_Point = A + CFrame.new(A, B).lookVector * para;
		local Needed_Look = CFrame.new(Mid_Point, C).lookVector;
		local dot = (Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z);

		local ac = CFrame.Angles(0, 0, math.acos(dot))

		cf0 = (cf0 * ac)

		if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
			cf0 = cf0 * CFrame.Angles(0, 0, -2 * math.acos(dot))
		end

		cf0 = (cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2)));

		local cf1 = st * ac * CFrame.Angles(0, math.pi, 0)
		if (((cf1 * za).lookVector - Needed_Look).magnitude > 0.01) then
			cf1 = cf1 * CFrame.Angles(0, 0, 2 * math.acos(dot))
		end

		cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2);

		if (not p0) then
			p0 = Instance.new('Part');
			p0.FormFactor = "Custom";
			p0.TopSurface = 0;
			p0.BottomSurface = 0;
			p0.Anchored = true;
			p0.CanCollide = false;
			p0.CastShadow = false;
			p0.Material = Enum.Material.Glass;
			p0.Size = Vector3.new(0.2, 0.2, 0.2);

			local mesh = Instance.new("SpecialMesh", p0);
			mesh.MeshType = 2;
			mesh.Name = "WedgeMesh"
		end;

		p0.WedgeMesh.Scale = Vector3.new(0, perp / 0.2, para / 0.2);
		p0.CFrame = cf0;

		if (not p1) then
			p1 = p0:clone();
		end;

		p1.WedgeMesh.Scale = Vector3.new(0, perp / 0.2, dif_para / 0.2);
		p1.CFrame = cf1;

		return p0, p1;
	end;

	function Blur:setBlurIntensity(intensity)
		self.blurIntensity = intensity;
		self.depthOfField.NearIntensity = intensity;
	end;

	function Blur:bindToRenderStep()
		self:updateOrientation(true);
		RunService:BindToRenderStep(self.bindId, 2000, function()
			self:updateOrientation(true);
		end);
	end;

	Blur.__index = Blur;
else
	Screen = (script.Parent);
	-- Custom Blur implementation
	Blur = {};
	local Lighting = game:GetService("Lighting");
	local RunService = game:GetService("RunService");

	Blur.BlurEnabled = {}

	function Blur.new(frame, blurIntensity)
		local self = setmetatable({
			blurIntensity = blurIntensity or 0.5;
			depthOfField = Instance.new("DepthOfFieldEffect");
			root = Instance.new("Folder");

			parts = {};
			parents = {};

			camera = workspace.CurrentCamera;
			bindId = "neon:blur_effect";

			frame = Instance.new("Frame");
			folder = Instance.new("Folder");
			owner = frame;

		}, Blur);

		table.insert(Blur.BlurEnabled, frame)

		self.depthOfField.Name = "";
		self.depthOfField.Parent = Lighting;
		self.depthOfField.FarIntensity = 0;
		self.depthOfField.FocusDistance = 51.6;
		self.depthOfField.InFocusRadius = 50;
		self.depthOfField.NearIntensity = self.blurIntensity;

		self.root.Name = "blurSnox";
		self.root.Parent = self.camera;

		self.frame.Name = "blurEffect";
		self.frame.Parent = frame;
		self.frame.Size = UDim2.new(0.95, 0, 0.95, 0);
		self.frame.Position = UDim2.new(0.5, 0, 0.5, 0);
		self.frame.AnchorPoint = Vector2.new(0.5, 0.5);
		self.frame.BackgroundTransparency = 1;

		self.folder.Parent = self.root;
		self.folder.Name = self.frame.Name;
		self.parents[#self.parents + 1] = self.frame;

		local continue = self:isNotNaN(self.camera:ScreenPointToRay(0, 0).Origin.x);
		while (not continue) do
			RunService.RenderStepped:Wait();
			continue = self:isNotNaN(self.camera:ScreenPointToRay(0, 0).Origin.x);
		end;

		self:bindToRenderStep();

		return self;
	end;

	function Blur:isNotNaN(x)
		return x == x;
	end;

	function Blur:updateOrientation(fetchProperties)
		local properties = {
			Transparency = 0.98;
			BrickColor = BrickColor.new('Institutional white');
		};

		local zIndex = (1 - 0.05 * self.frame.ZIndex);

		local tl, br = self.frame.AbsolutePosition, self.frame.AbsolutePosition + self.frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)

		local rot = 0;

		for _, v in ipairs(self.parents) do
			rot = rot + v.Rotation
		end

		if rot ~= 0 and rot%180 ~= 0 then
			local mid, s, c, vec = tl:lerp(br, 0.5), math.sin(math.rad(rot)), math.cos(math.rad(rot)), tl;
			tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid;
			tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid;
			bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid;
			br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid;
		end

		self:drawQuad(
			self.camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
			self.camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
			self.camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
			self.camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
			self.parts
		);

		if (fetchProperties) then
			for _, pt in pairs(self.parts) do
				pt.Parent = self.folder
			end;

			for propName, propValue in pairs(properties) do
				for _, pt in pairs(self.parts) do
					pt[propName] = propValue;
				end;
			end;
		end;
	end;

	function Blur:drawQuad(v1, v2, v3, v4, parts)
		parts[1], parts[2] = self:drawTriangle(v1, v2, v3, parts[1], parts[2]);
		parts[3], parts[4] = self:drawTriangle(v3, v2, v4, parts[3], parts[4]);
	end;

	function Blur:drawTriangle(v1, v2, v3, p0, p1)
		local s1 = (v1 - v2).magnitude;
		local s2 = (v2 - v3).magnitude;
		local s3 = (v3 - v1).magnitude;

		local smax = math.max(s1, s2, s3);

		local A, B, C
		if (s1 == smax) then
			A, B, C = v1, v2, v3;
		elseif (s2 == smax) then
			A, B, C = v2, v3, v1;
		elseif (s3 == smax) then
			A, B, C = v3, v1, v2;
		end;

		local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude;
		local perp = math.sqrt((C - A).magnitude ^ 2 - para * para);
		local dif_para = (A - B).magnitude - para;

		local st = CFrame.new(B, A);
		local za = CFrame.Angles(math.pi / 2, 0, 0);

		local cf0 = st;

		local Top_Look = (cf0 * za).lookVector;
		local Mid_Point = A + CFrame.new(A, B).lookVector * para;
		local Needed_Look = CFrame.new(Mid_Point, C).lookVector;
		local dot = (Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z);

		local ac = CFrame.Angles(0, 0, math.acos(dot))

		cf0 = (cf0 * ac)

		if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
			cf0 = cf0 * CFrame.Angles(0, 0, -2 * math.acos(dot))
		end

		cf0 = (cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2)));

		local cf1 = st * ac * CFrame.Angles(0, math.pi, 0)
		if (((cf1 * za).lookVector - Needed_Look).magnitude > 0.01) then
			cf1 = cf1 * CFrame.Angles(0, 0, 2 * math.acos(dot))
		end

		cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2);

		if (not p0) then
			p0 = Instance.new('Part');
			p0.FormFactor = "Custom";
			p0.TopSurface = 0;
			p0.BottomSurface = 0;
			p0.Anchored = true;
			p0.CanCollide = false;
			p0.CastShadow = false;
			p0.Material = Enum.Material.Glass;
			p0.Size = Vector3.new(0.2, 0.2, 0.2);

			local mesh = Instance.new("SpecialMesh", p0);
			mesh.MeshType = 2;
			mesh.Name = "WedgeMesh"
		end;

		p0.WedgeMesh.Scale = Vector3.new(0, perp / 0.2, para / 0.2);
		p0.CFrame = cf0;

		if (not p1) then
			p1 = p0:clone();
		end;

		p1.WedgeMesh.Scale = Vector3.new(0, perp / 0.2, dif_para / 0.2);
		p1.CFrame = cf1;

		return p0, p1;
	end;

	function Blur:setBlurIntensity(intensity)
		self.blurIntensity = intensity;
		self.depthOfField.NearIntensity = intensity;
	end;

	function Blur:bindToRenderStep()
		self:updateOrientation(true);
		RunService:BindToRenderStep(self.bindId, 2000, function()
			self:updateOrientation(true);
		end);
	end;

	Blur.__index = Blur;
end

Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function() 
	Screen.Parent = Player.GUI
end)

--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};

--// Keybind System for Functions
local KeybindRegistry = {} -- Stores all registered keybinds: { [KeyCode] = { Name, Callback } }

-- Register a keybind for a function
function Library:RegisterKeybind(Name: string, KeyCode: Enum.KeyCode, Callback: function)
	if not Name or not KeyCode or not Callback then
		warn("[Elytra-UI]: RegisterKeybind requires Name, KeyCode, and Callback")
		return
	end

	-- Remove existing keybind with same name
	for Key, Data in pairs(KeybindRegistry) do
		if Data.Name == Name then
			KeybindRegistry[Key] = nil
		end
	end

	-- Register new keybind
	KeybindRegistry[KeyCode] = {
		Name = Name,
		Callback = Callback
	}

	return true
end

-- Unregister a keybind by name
function Library:UnregisterKeybind(Name: string)
	if not Name then return false end

	for Key, Data in pairs(KeybindRegistry) do
		if Data.Name == Name then
			KeybindRegistry[Key] = nil
			return true
		end
	end

	return false
end

-- Get all registered keybinds
function Library:GetKeybinds()
	return KeybindRegistry
end

-- Clear all keybinds
function Library:ClearKeybinds()
	KeybindRegistry = {}
end

-- Input handler for keybinds
Services.Input.InputBegan:Connect(function(Input, Focused)
	if not Focused and Input.KeyCode then
		local KeybindData = KeybindRegistry[Input.KeyCode]
		if KeybindData then
			task.spawn(function()
				KeybindData.Callback()
			end)
		end
	end
end)

--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	local Original = (UseCurrentSize and Window.Size) or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")


	SetProperty(Shadow, { Transparency = 1 })
	SetProperty(Window, {
		Size = Multiplied,
		GroupTransparency = 1,
		Visible = true,
	})

	Tween(Shadow, .25, { Transparency = 0.5 })
	Tween(Window, .25, {
		Size = Original,
		GroupTransparency = Transparency or 0,
	})
end

function Animations:Close(Window: CanvasGroup)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, {
		Size = Original,
	})

	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, {
		Size = Multiplied,
		GroupTransparency = 1,
	})

	task.wait(.25)
	Window.Size = Original
	Window.Visible = false
end


function Animations:Component(Component: any, Custom: boolean)	
	Connect(Component.InputBegan, function() 
		if Custom then
			Tween(Component, .25, { Transparency = .85 });
		else
			Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
		end
	end)

	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .25, { Transparency = 1 });
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component });
		end
	end)
end

--// Library [Window]

function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string, HubName: string?, GameName: string?, HubDescription: string? })
	--// Elytra-UI Protection: Auto unload if window already exists
	if ElytraUI.WindowCreated then
		-- Call unload on existing window if available
		if ElytraUI.CurrentWindow and ElytraUI.CurrentWindow.Unload then
			ElytraUI.CurrentWindow:Unload()
		else
			error("[Elytra-UI]: Window already exists! Only one window can be created at a time.")
		end
	end
	ElytraUI.WindowCreated = true

	--// Apply custom hub settings
	if Settings.HubName then
		ElytraUI.HubSettings.HubName = Settings.HubName
	end
	if Settings.GameName then
		ElytraUI.HubSettings.GameName = Settings.GameName
	end
	if Settings.HubDescription then
		ElytraUI.HubSettings.HubDescription = Settings.HubDescription
	end

	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");

	local Options = {};
	local Examples = {};
	local Opened = true;
	local Maximized = false;
	local BlurEnabled = false
	local WindowConnections = {} -- Store all connections for unload
	local IsAnimating = false -- Prevent rapid minimize/maximize
	local DropdownOpen = false -- Prevent multiple dropdowns open
	local MiniBar = nil -- Store mini bar reference
	local UnbindButtons = {} -- Store unbind buttons for theme updates

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	--// UI Blur & More
	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	--// Elytra-UI: Limit transparency to max 0.8
	Setup.Transparency = math.clamp(Settings.Transparency or 0, 0, 0.8)
	Setup.Size = Settings.Size
	Setup.ThemeMode = Settings.Theme or "Dark"

	if Settings.Blurring then
		Blurs[Settings.Title] = Blur.new(Window, 5)
		BlurEnabled = true
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	--// Animate
	local Close = function()
		if IsAnimating then return end -- Prevent rapid minimize/maximize

		IsAnimating = true

		if Opened then
			if BlurEnabled then
				Blurs[Settings.Title].root.Parent = nil
			end

			Opened = false
			Animations:Close(Window)
			Window.Visible = false
		else
			Animations:Open(Window, Setup.Transparency)
			Opened = true

			if BlurEnabled then
				Blurs[Settings.Title].root.Parent = workspace.CurrentCamera
			end
		end

		task.wait(0.3) -- Wait for animation to complete
		IsAnimating = false
	end

	--// Elytra-UI: Unload function to close window and disconnect all connections
	function Options:Unload()
		-- Disconnect all stored connections
		for _, Connection in pairs(WindowConnections) do
			if Connection then
				Connection:Disconnect()
			end
		end

		-- Disconnect blur
		if BlurEnabled and Blurs[Settings.Title] then
			Blurs[Settings.Title].root.Parent = nil
		end

		-- Destroy window
		Window:Destroy()

		-- Reset window created flag
		ElytraUI.WindowCreated = false
		ElytraUI.CurrentWindow = nil

		-- Clear active functions
		ElytraUI.ActiveFunctions = {}

		-- Destroy minimize icon
		if ElytraUI.MinimizeIcon and ElytraUI.MinimizeIcon.Parent then
			ElytraUI.MinimizeIcon.Parent:Destroy()
		end
	end

	--// Elytra-UI: Custom Connect function to store connections
	local function ElytraConnect(Signal, Callback)
		local Connection = Signal:Connect(Callback)
		table.insert(WindowConnections, Connection)
		return Connection
	end

	--// Elytra-UI: Create Minimize Icon
	local MinimizeIconGui = Instance.new("ScreenGui")
	MinimizeIconGui.Name = "ElytraMinimizeIconGui"
	MinimizeIconGui.ResetOnSpawn = false
	MinimizeIconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local MinimizeIcon = Instance.new("ImageButton")
	MinimizeIcon.Name = "MinimizeIcon"
	MinimizeIcon.Size = UDim2.new(0, 50, 0, 50)
	MinimizeIcon.Position = UDim2.new(0, 10, 0.5, -25)
	MinimizeIcon.BackgroundTransparency = 1
	MinimizeIcon.Image = "rbxassetid://18945940179"
	MinimizeIcon.Parent = MinimizeIconGui

	local IconCorner = Instance.new("UICorner")
	IconCorner.CornerRadius = UDim.new(0, 8)
	IconCorner.Parent = MinimizeIcon

	xpcall(function()
		MinimizeIconGui.Parent = game.CoreGui
	end, function()
		MinimizeIconGui.Parent = Player.GUI
	end)

	ElytraUI.MinimizeIcon = MinimizeIcon

	--// Elytra-UI: Minimize Icon hover animation
	ElytraConnect(MinimizeIcon.MouseEnter, function()
		Tween(MinimizeIcon, .2, { Size = UDim2.new(0, 55, 0, 55) })
	end)

	ElytraConnect(MinimizeIcon.MouseLeave, function()
		Tween(MinimizeIcon, .2, { Size = UDim2.new(0, 50, 0, 50) })
	end)

	--// Elytra-UI: Minimize Icon click to toggle window
	ElytraConnect(MinimizeIcon.MouseButton1Click, function()
		Close()
	end)

	--// Elytra-UI: Create Mini Bar (in left sidebar)
	local function CreateMiniBar()
		-- Create mini bar frame inside the Sidebar (left side)
		local MiniBarFrame = Instance.new("Frame")
		MiniBarFrame.Name = "MiniBar"
		MiniBarFrame.Size = UDim2.new(1, -10, 0, 60) -- Reduced height
		MiniBarFrame.Position = UDim2.new(0, 5, 1, -70) -- Bottom of Sidebar
		MiniBarFrame.BackgroundColor3 = Theme.Secondary
		MiniBarFrame.BackgroundTransparency = 0.1
		MiniBarFrame.BorderSizePixel = 0
		MiniBarFrame.Parent = Sidebar

		local MiniBarCorner = Instance.new("UICorner")
		MiniBarCorner.CornerRadius = UDim.new(0, 6)
		MiniBarCorner.Parent = MiniBarFrame

		-- Player icon (left side) - use player avatar
		local PlayerIcon = Instance.new("ImageLabel")
		PlayerIcon.Name = "PlayerIcon"
		PlayerIcon.Size = UDim2.new(0, 40, 0, 40) -- Smaller icon
		PlayerIcon.Position = UDim2.new(0, 8, 0.5, -20) -- Centered vertically
		PlayerIcon.BackgroundColor3 = Theme.Primary
		PlayerIcon.BackgroundTransparency = 0
		PlayerIcon.BorderSizePixel = 0
		-- Get player avatar thumbnail
		local success, content = pcall(function()
			return game:GetService("Players"):GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
		end)
		PlayerIcon.Image = success and content or "rbxassetid://6626517375" -- Fallback to default if fails
		PlayerIcon.Parent = MiniBarFrame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = PlayerIcon

		-- Info container (right side)
		local InfoContainer = Instance.new("Frame")
		InfoContainer.Name = "InfoContainer"
		InfoContainer.Size = UDim2.new(1, -55, 1, -10)
		InfoContainer.Position = UDim2.new(0, 50, 0, 5)
		InfoContainer.BackgroundTransparency = 1
		InfoContainer.BorderSizePixel = 0
		InfoContainer.Parent = MiniBarFrame

		-- Hub name (top)
		local HubNameLabel = Instance.new("TextLabel")
		HubNameLabel.Name = "HubName"
		HubNameLabel.Size = UDim2.new(1, 0, 0, 14)
		HubNameLabel.Position = UDim2.new(0, 0, 0, 0)
		HubNameLabel.BackgroundTransparency = 1
		HubNameLabel.TextColor3 = Theme.Title
		HubNameLabel.TextSize = 12
		HubNameLabel.Font = Enum.Font.GothamBold
		HubNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		HubNameLabel.Text = ElytraUI.HubSettings.HubName
		HubNameLabel.Parent = InfoContainer

		-- Game name (middle)
		local GameNameLabel = Instance.new("TextLabel")
		GameNameLabel.Name = "GameName"
		GameNameLabel.Size = UDim2.new(1, 0, 0, 12)
		GameNameLabel.Position = UDim2.new(0, 0, 0, 16)
		GameNameLabel.BackgroundTransparency = 1
		GameNameLabel.TextColor3 = Theme.Tab
		GameNameLabel.TextSize = 10
		GameNameLabel.Font = Enum.Font.Gotham
		GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		GameNameLabel.Text = ElytraUI.HubSettings.GameName
		GameNameLabel.Parent = InfoContainer

		-- Player name (bottom)
		local PlayerNameLabel = Instance.new("TextLabel")
		PlayerNameLabel.Name = "PlayerName"
		PlayerNameLabel.Size = UDim2.new(1, 0, 0, 12)
		PlayerNameLabel.Position = UDim2.new(0, 0, 0, 30)
		PlayerNameLabel.BackgroundTransparency = 1
		PlayerNameLabel.TextColor3 = Theme.Description
		PlayerNameLabel.TextSize = 10
		PlayerNameLabel.Font = Enum.Font.Gotham
		PlayerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		PlayerNameLabel.Text = LocalPlayer.Name
		PlayerNameLabel.Parent = InfoContainer

		return MiniBarFrame
	end

	MiniBar = CreateMiniBar()

	for Index, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") then
			local Name = Button.Name
			Animations:Component(Button, true)

			ElytraConnect(Button.MouseButton1Click, function()
				if Name == "Close" then
					Close()
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size });
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
					end
				elseif Name == "Minimize" then
					Opened = false
					Window.Visible = false
					if BlurEnabled then
						Blurs[Settings.Title].root.Parent = nil
					end
				end
			end)
		end
	end

	ElytraConnect(Services.Input.InputBegan, function(Input, Focused)
		if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
			Close()
		end
	end)

	--// Tab Functions

	function Options:SetTab(Name: string)
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");

				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) });
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(Opened, { Value = true });
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) });
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(Opened, { Value = false });
				end
			end
		end

		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true

					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });

				elseif not SameName and Opened.Value then
					Opened.Value = false

					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });	

					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Example = Examples["SectionExample"];
		local Section = Clone(Example);

		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo["Tabs"][Settings.Title] then 
			error("[UI LIB]: A tab with the same name has already been created") 
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local Tab = Clone(Example);

		if not Settings.Icon then
			Destroy(Tab["ICO"]);
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon });
		end

		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title });

		SetProperty(Main, { 
			Parent = MainExample.Parent,
			Name = Settings.Title;
		});

		SetProperty(Tab, {
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title;
			Visible = true;
		});

		ElytraConnect(Tab.MouseButton1Click, function()
			Options:SetTab(Tab.Name);
		end)

		return Main.ScrollingFrame
	end
	
	--// Notifications
	
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, {
			Parent = Screen["Frame"],
		})
		
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			local Wait = task.wait;
			
			Animations:Open(Notification, Setup.Transparency, true); Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end

	--// Component Functions

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")

		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings: { Name: string, Tab: Instance }) 
		local Section = Clone(Components["Section"]);
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any })
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);

		ElytraConnect(Button.MouseButton1Click, Settings.Callback)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any })
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];

		ElytraConnect(Input.MouseButton1Click, function()
			TextBox:CaptureFocus()
		end)

		ElytraConnect(TextBox.FocusLost, function()
			Settings.Callback(TextBox.Text)
		end)

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		
		local Set = function(Value)
			if Value then
				Tween(Main,   .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			
			On.Value = Value
		end 

		ElytraConnect(Toggle.MouseButton1Click, function()
			local Value = not On.Value

			Set(Value)
			Settings.Callback(Value)
		end)

		Animations:Component(Toggle);
		Set(Settings.Default);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddKeybind(Settings: { Title: string, Description: string, Tab: Instance, Callback: any })
		local Dropdown = Clone(Components["Keybind"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Bind = Dropdown["Main"].Options;
		local MainFrame = Dropdown["Main"];

		-- Redesign keybind component: Unbind button on left, keybind display on right
		-- Reset Bind to original size and position
		Bind.Size = UDim2.new(1, -40, 1, 0)
		Bind.Position = UDim2.new(0, 35, 0, 0)

		-- Create unbind button (left side) - square with rounded corners, white with black dot
		local UnbindButton = Instance.new("TextButton")
		UnbindButton.Name = "UnbindButton"
		UnbindButton.Size = UDim2.new(0, 24, 0, 24)
		UnbindButton.Position = UDim2.new(0, 5, 0.5, -12)
		UnbindButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		UnbindButton.BackgroundTransparency = 0
		UnbindButton.BorderSizePixel = 0
		UnbindButton.Text = ""
		UnbindButton.ZIndex = 3
		UnbindButton.Parent = MainFrame

		local UnbindCorner = Instance.new("UICorner")
		UnbindCorner.CornerRadius = UDim.new(0, 6)
		UnbindCorner.Parent = UnbindButton

		-- Black dot indicator (only visible when keybind is set)
		local DotIndicator = Instance.new("Frame")
		DotIndicator.Name = "DotIndicator"
		DotIndicator.Size = UDim2.new(0, 8, 0, 8)
		DotIndicator.Position = UDim2.new(0.5, -4, 0.5, -4)
		DotIndicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		DotIndicator.BackgroundTransparency = 1
		DotIndicator.BorderSizePixel = 0
		DotIndicator.ZIndex = 4
		DotIndicator.Parent = UnbindButton

		local DotCorner = Instance.new("UICorner")
		DotCorner.CornerRadius = UDim.new(1, 0)
		DotCorner.Parent = DotIndicator

		-- Store unbind button for theme updates
		table.insert(UnbindButtons, { Button = UnbindButton, Dot = DotIndicator })

		-- Hover animation for unbind button
		ElytraConnect(UnbindButton.MouseEnter, function()
			Tween(UnbindButton, .15, { BackgroundColor3 = Color3.fromRGB(240, 240, 240) })
		end)

		ElytraConnect(UnbindButton.MouseLeave, function()
			Tween(UnbindButton, .15, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
		end)

		local CurrentKey = nil
		local DetectConnection = nil
		local IsBinding = false

		-- Update dot visibility based on keybind state
		local function UpdateDot()
			if CurrentKey then
				DotIndicator.BackgroundTransparency = 0
			else
				DotIndicator.BackgroundTransparency = 1
			end
		end

		-- Unbind button click handler
		ElytraConnect(UnbindButton.MouseButton1Click, function()
			if not CurrentKey then return end

			if DetectConnection then
				DetectConnection:Disconnect()
				DetectConnection = nil
			end

			CurrentKey = nil
			SetProperty(Bind, { Text = "None" })
			Settings.Callback(nil)
			IsBinding = false
			UpdateDot()
		end)

		-- Keybind click handler - click on the keybind display area
		ElytraConnect(Dropdown.MouseButton1Click, function()
			if IsBinding then return end

			IsBinding = true
			SetProperty(Bind, { Text = "..." })

			if DetectConnection then
				DetectConnection:Disconnect()
				DetectConnection = nil
			end

			-- Start listening for key input
			DetectConnection = ElytraConnect(game.UserInputService.InputBegan, function(Key, Focused)
				if not Focused then
					if DetectConnection then
						DetectConnection:Disconnect()
						DetectConnection = nil
					end

					if Key.KeyCode and Key.KeyCode ~= Enum.KeyCode.Unknown then
						CurrentKey = Key.KeyCode
						local KeyName = tostring(Key.KeyCode):gsub("Enum%..*%.", "")
						SetProperty(Bind, { Text = KeyName })
						UpdateDot()
						task.delay(0.1, function()
							Settings.Callback(Key.KeyCode)
							IsBinding = false
						end)
					else
						if CurrentKey then
							local KeyName = tostring(CurrentKey):gsub("Enum%..*%.", "")
							SetProperty(Bind, { Text = KeyName })
						else
							SetProperty(Bind, { Text = "None" })
						end
						UpdateDot()
						IsBinding = false
					end
				end
			end)
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any })
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown["Main"].Options;

		ElytraConnect(Dropdown.MouseButton1Click, function()
			if DropdownOpen then return end -- Prevent multiple dropdowns open
			DropdownOpen = true

			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example["Top"]["Buttons"];

			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window });
			Animations:Open(Example, 0, true)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)

					ElytraConnect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 });
						Animations:Close(Example);
						task.wait(2)
						Destroy(Example);
						DropdownOpen = false -- Reset dropdown open flag
					end)
				end
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local Title, Description = Options:GetLabels(Button);
				local Selected = Button["Value"];

				Animations:Component(Button);
				SetProperty(Title, { Text = Index });
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				Destroy(Description);

				ElytraConnect(Button.MouseButton1Click, function()
					local NewValue = not Selected.Value

					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						Settings.Callback(Option)
						Text.Text = Index

						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component });
					end

					Selected.Value = NewValue
					Tween(BG, .25, { BackgroundTransparency = 1 });
					Animations:Close(Example);
					task.wait(2)
					Destroy(Example);
					DropdownOpen = false -- Reset dropdown open flag
				end)
			end
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);

		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];

		local Active = false
		local Value = 0
		
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X			
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			
			if Number then
				Number = (Number > Settings.MaxValue and Settings.MaxValue) or (Number < 0 and 0) or Number
			end
			
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / Settings.MaxValue) or Scale, 1)
			Settings.Callback(Value)
		end

		local Activate = function()
			Active = true

			repeat task.wait()
				Update()
			until not Active
		end

		ElytraConnect(Amount.FocusLost, function()
			Update(tonumber(Amount.Text) or 0)
		end)

		ElytraConnect(Fire.MouseButton1Down, Activate)
		ElytraConnect(Services.Input.InputEnded, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(Value, 1);
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance })
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);

		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, {
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	local ThemeHandlers = {
		Names = {
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") and Theme.Component then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark");
				end
			end,

			["Title"] = function(Label)
				if Label:IsA("TextLabel") and Theme.Title then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Description"] = function(Label)
				if Label:IsA("TextLabel") and Theme.Description then
					Label.TextColor3 = Theme.Description
				end
			end,

			["Section"] = function(Label)
				if Label:IsA("TextLabel") and Theme.Title then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" and Theme.Title then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					if Theme.Primary then
						Label.BackgroundColor3 = Theme.Primary
					end
					if Theme.Outline and Label.UIStroke then
						Label.UIStroke.Color = Theme.Outline
					end
				end
			end,

			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") and Theme.Tab then
					Label.TextColor3 = Theme.Tab
				end
			end,

			["Main"] = function(Label)
				if Label:IsA("Frame") then

					if Label.Parent == Window and Theme.Secondary then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value
						local Circle = Label:FindFirstChild("Circle")

						if not Toggle.Value then
							if Theme.Interactables then
								Label.BackgroundColor3 = Theme.Interactables
							end
							if Theme.Primary and Circle then
								Circle.BackgroundColor3 = Theme.Primary
							end
						end
					else
						if Theme.Interactables then
							Label.BackgroundColor3 = Theme.Interactables
						end
					end
				elseif Label:FindFirstChild("Padding") and Theme.Title then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Amount"] = function(Label)
				if Label:IsA("Frame") and Theme.Interactables then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Slide"] = function(Label)
				if Label:IsA("Frame") and Theme.Interactables then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Input"] = function(Label)
				if Label:IsA("TextLabel") and Theme.Title then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") and Theme.Component then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" and Theme.Title then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") and Theme.Outline then
					Stroke.Color = Theme.Outline
				end
			end,

			["DropdownExample"] = function(Label)
				if Theme.Secondary then
					Label.BackgroundColor3 = Theme.Secondary
				end
			end,

			["Underline"] = function(Label)
				if Label:IsA("Frame") and Theme.Outline then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
		},

		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" and Theme.Icon then
					Label.ImageColor3 = Theme.Icon
				end
			end,

			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") and Theme.Title then
					Label.TextColor3 = Theme.Title
				end
			end,

			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") and Theme.Component then
					Label.BackgroundColor3 = Theme.Component
				end
			end,

			["ScrollingFrame"] = function(Label)
				if Theme.Component then
					Label.ScrollBarImageColor3 = Theme.Component
				end
			end,
		},
	}

	function Options:SetTheme(Info)
		Theme = Info or Theme

		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		if Theme.Shadow then
			Window.UIStroke.Color = Theme.Shadow
		end

		-- Update MinimizeIcon colors
		if ElytraUI.MinimizeIcon then
			ElytraUI.MinimizeIcon.ImageColor3 = Theme.Icon
		end

		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class =  ThemeHandlers.Names[Descendant.Name],  ThemeHandlers.Classes[Descendant.ClassName]

			if Name then
				Name(Descendant);
			elseif Class then
				Class(Descendant);
			end
		end
	end

	--// Changing Settings

	function Options:SetSetting(Setting, Value) --// Available settings - Size, Transparency, Blur, Theme, Keybind, MinimizeIconVisible
		if Setting == "Size" then

			Window.Size = Value
			Setup.Size = Value

		elseif Setting == "Transparency" then

			--// Elytra-UI: Limit transparency to max 0.8
			local ClampedValue = math.clamp(Value, 0, 0.8)
			Window.GroupTransparency = ClampedValue
			Setup.Transparency = ClampedValue

			for Index, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = ClampedValue
				end
			end

		elseif Setting == "Blur" then

			local AlreadyBlurred, Root = Blurs[Settings.Title], nil

			if AlreadyBlurred then
				Root = Blurs[Settings.Title]["root"]
			end

			if Value then
				BlurEnabled = true

				if not AlreadyBlurred or not Root then
					Blurs[Settings.Title] = Blur.new(Window, 5)
				elseif Root and not Root.Parent then
					Root.Parent = workspace.CurrentCamera
				end
			elseif not Value and (AlreadyBlurred and Root and Root.Parent) then
				Root.Parent = nil
				BlurEnabled = false
			end

		elseif Setting == "Theme" and typeof(Value) == "table" then

			Options:SetTheme(Value)

		elseif Setting == "Keybind" then

			Setup.Keybind = Value

		elseif Setting == "MinimizeIconVisible" then

			if ElytraUI.MinimizeIcon then
				ElytraUI.MinimizeIcon.Visible = Value
			end
			ElytraUI.MinimizeIconVisible = Value

		elseif Setting == "HubName" then

			ElytraUI.HubSettings.HubName = Value
			-- Update mini bar hub name if exists
			if MiniBar and MiniBar:FindFirstChild("InfoContainer") then
				local HubName = MiniBar.InfoContainer:FindFirstChild("HubName")
				if HubName then
					HubName.Text = Value
				end
			end

		elseif Setting == "GameName" then

			ElytraUI.HubSettings.GameName = Value
			-- Update mini bar game name if exists
			if MiniBar and MiniBar:FindFirstChild("InfoContainer") then
				local GameName = MiniBar.InfoContainer:FindFirstChild("GameName")
				if GameName then
					GameName.Text = Value
				end
			end

		elseif Setting == "HubDescription" then

			ElytraUI.HubSettings.HubDescription = Value

		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end

	--// Get hub settings function
	function Options:GetHubSettings()
		return {
			HubName = ElytraUI.HubSettings.HubName,
			GameName = ElytraUI.HubSettings.GameName,
			HubDescription = ElytraUI.HubSettings.HubDescription,
			CreatorName = ElytraUI.HubSettings.CreatorName,
			RepositoryUrl = ElytraUI.HubSettings.RepositoryUrl
		}
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)

	--// Elytra-UI: Ensure theme is always applied
	if Settings.Theme then
		Setup.ThemeMode = Settings.Theme
	else
		Setup.ThemeMode = "Dark"
	end
	Options:SetTheme(Theme)

	--// Elytra-UI: Store reference to current window for auto unload
	ElytraUI.CurrentWindow = Options

	return Options
end

return Library
