local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function create(t, props)
	local inst = Instance.new(t)
	if props then for k,v in pairs(props) do inst[k] = v end end
	return inst
end

local clamp = math.clamp
local lerp = function(a,b,t) return a + (b-a)*t end

local NeonUI = {}
NeonUI.__index = NeonUI

function NeonUI.new()
	return setmetatable({
		windows = {},
		themes = {
			Dark = {
				Primary = Color3.fromRGB(30,30,30),
				Secondary = Color3.fromRGB(35,35,35),
				Component = Color3.fromRGB(40,40,40),
				Interactables = Color3.fromRGB(45,45,45),
				Tab = Color3.fromRGB(200,200,200),
				Title = Color3.fromRGB(240,240,240),
				Description = Color3.fromRGB(200,200,200),
				Outline = Color3.fromRGB(40,40,40),
				Icon = Color3.fromRGB(220,220,220)
			},
			Light = {
				Primary = Color3.fromRGB(232,232,232),
				Secondary = Color3.fromRGB(255,255,255),
				Component = Color3.fromRGB(245,245,245),
				Interactables = Color3.fromRGB(235,235,235),
				Tab = Color3.fromRGB(50,50,50),
				Title = Color3.fromRGB(0,0,0),
				Description = Color3.fromRGB(100,100,100),
				Outline = Color3.fromRGB(210,210,210),
				Icon = Color3.fromRGB(100,100,100)
			},
			Void = {
				Primary = Color3.fromRGB(15,15,15),
				Secondary = Color3.fromRGB(20,20,20),
				Component = Color3.fromRGB(25,25,25),
				Interactables = Color3.fromRGB(30,30,30),
				Tab = Color3.fromRGB(200,200,200),
				Title = Color3.fromRGB(240,240,240),
				Description = Color3.fromRGB(200,200,200),
				Outline = Color3.fromRGB(40,40,40),
				Icon = Color3.fromRGB(220,220,220)
			}
		}
	}, NeonUI)
end

function NeonUI:CreateWindow(cfg)
	assert(typeof(cfg) == "table", "CreateWindow expects table config")
	cfg.Size = cfg.Size or UDim2.fromOffset(570, 370)
	cfg.Transparency = clamp(cfg.Transparency or 0, 0, 1)
	cfg.Theme = cfg.Theme or "Dark"
	cfg.Blurring = cfg.Blurring ~= false
	cfg.MinimizeKeybind = cfg.MinimizeKeybind or Enum.KeyCode.LeftControl

	local win = create("ScreenGui", {
		Name = "NeonUI_Window_" .. tick(),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui
	})

	local bg = create("Frame", {
		Name = "Background",
		Size = cfg.Size,
		BackgroundColor3 = self.themes[cfg.Theme].Primary,
		BorderSizePixel = 0,
		Parent = win
	})

	create("UIStroke", { Color = self.themes[cfg.Theme].Outline, Thickness = 1, Parent = bg })

	local blur = nil
	if cfg.Blurring then
		blur = create("UIBlurEffect", { Intensity = 5, Parent = bg })
	end

	-- Title bar
	local titleBar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = self.themes[cfg.Theme].Secondary,
		BorderSizePixel = 0,
		Parent = bg
	})

	create("TextLabel", {
		Size = UDim2.new(1, -90, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Text = cfg.Title or "NeonUI",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = self.themes[cfg.Theme].Title,
		BackgroundTransparency = 1,
		Parent = titleBar
	})

	local closeBtn = create("TextButton", {
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -30, 0, 0),
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = self.themes[cfg.Theme].Description,
		BackgroundColor3 = self.themes[cfg.Theme].Interactables,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = titleBar
	})

	-- Keybind panel (top-right)
	local keyPanel = create("Frame", {
		Size = UDim2.new(0, 180, 0, 20),
		Position = UDim2.new(1, -190, 0, 5),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Visible = false,
		Parent = bg
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 5),
		Parent = keyPanel
	})

	-- Content
	local content = create("Frame", {
		Size = UDim2.new(1, 0, 1, -30),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = self.themes[cfg.Theme].Secondary,
		BorderSizePixel = 0,
		Parent = bg
	})

	-- State
	local visible = true
	local conns = {}

	-- Drag
	do
		local dragStart, startPos
		conns[#conns+1] = titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragStart = input.Position
				startPos = bg.Position
			end
		end)
		conns[#conns+1] = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
				local delta = input.Position - dragStart
				bg.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end)
		conns[#conns+1] = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragStart = nil
			end
		end)
	end

	-- Toggle visibility
	local function toggle()
		visible = not visible
		bg.Visible = visible
		keyPanel.Visible = visible
	end

	conns[#conns+1] = UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == cfg.MinimizeKeybind then toggle() end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		win:Destroy()
		for _,c in ipairs(conns) do c:Disconnect() end
	end)

	-- API
	local api = {
		_win = win,
		_bg = bg,
		_content = content,
		_theme = cfg.Theme,
		_blur = blur,
		_keyPanel = keyPanel,
		_conns = conns,
		_visible = visible,
		_cfg = cfg
	}

	function api:SetTheme(name)
		local t = self.themes[name]
		if not t then return end
		self._theme = name
		self._bg.BackgroundColor3 = t.Primary
		titleBar.BackgroundColor3 = t.Secondary
		content.BackgroundColor3 = t.Secondary
		closeBtn.BackgroundColor3 = t.Interactables
		closeBtn.TextColor3 = t.Description
	end

	function api:SetSetting(k, v)
		if k == "Transparency" then
			self._bg.BackgroundTransparency = clamp(v, 0, 1)
		elseif k == "Blur" then
			if v and not self._blur then
				self._blur = create("UIBlurEffect", { Intensity = 5, Parent = self._bg })
			elseif not v and self._blur then
				self._blur:Destroy()
				self._blur = nil
			end
		elseif k == "Keybind" then
			self._cfg.MinimizeKeybind = v
		elseif k == "Size" then
			self._bg.Size = v
		end
	end

	function api:AddKeybindLabel(label, key)
		local f = create("Frame", { Size = UDim2.new(0, 60, 1, 0), BackgroundTransparency = 1, Parent = self._keyPanel })
		create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = label .. " – " .. tostring(key.KeyCode):gsub("Enum.KeyCode.", ""),
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(255,255,255),
			BackgroundTransparency = 1,
			Parent = f
		})
		self._keyPanel.Visible = true
	end

	function api:Notify(p)
		p.Duration = p.Duration or 3
		local n = create("Frame", {
			Size = UDim2.fromOffset(300, 60),
			Position = UDim2.new(1, -310, 0, 10 + (#PlayerGui:GetChildren() * 70)),
			BackgroundColor3 = self.themes[self._theme].Primary,
			BorderSizePixel = 0,
			Parent = PlayerGui
		})
		create("UIStroke", { Color = self.themes[self._theme].Outline, Parent = n })
		create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 5, 0, 5),
			Text = p.Title,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = self.themes[self._theme].Title,
			BackgroundTransparency = 1,
			Parent = n
		})
		create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 5, 0, 25),
			Text = p.Description,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = self.themes[self._theme].Description,
			BackgroundTransparency = 1,
			Parent = n
		})
		spawn(function()
			wait(p.Duration)
			n:Destroy()
		end)
	end

	-- Placeholder components (you can expand these)
	function api:AddButton(p)
		local b = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			Text = p.Title,
			Font = Enum.Font.GothamSemibold,
			TextSize = 14,
			TextColor3 = self.themes[self._theme].Title,
			BackgroundColor3 = self.themes[self._theme].Component,
			AutoButtonColor = false,
			Parent = self._content
		})
		b.MouseButton1Click:Connect(p.Callback)
	end

	function api:AddToggle(p)
		local t = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			Text = p.Title,
			Font = Enum.Font.GothamSemibold,
			TextSize = 14,
			TextColor3 = self.themes[self._theme].Title,
			BackgroundColor3 = self.themes[self._theme].Component,
			AutoButtonColor = false,
			Parent = self._content
		})
		local state = p.Default or false
		local function update()
			t.BackgroundColor3 = state and Color3.fromRGB(153,155,255) or self.themes[self._theme].Interactables
		end
		update()
		t.MouseButton1Click:Connect(function()
			state = not state
			update()
			p.Callback(state)
		end)
	end

	-- Finalize
	api:Notify({ Title = "Ready", Description = "Press " .. tostring(cfg.MinimizeKeybind) .. " to toggle", Duration = 3 })
	return api
end

function NeonUI:Destroy()
	for _, w in ipairs(self.windows) do
		if w._win then w._win:Destroy() end
		for _, c in ipairs(w._conns or {}) do c:Disconnect() end
	end
	self.windows = {}
end

return NeonUI
