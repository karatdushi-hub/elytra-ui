local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Utility
local function create(instanceType, props)
	local inst = Instance.new(instanceType)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

local function clamp(v, min, max) return math.min(math.max(v, min), max) end
local function lerp(a, b, t) return a + (b - a) * t end

-- Main Library
local NeonUI = {}
NeonUI.__index = NeonUI

function NeonUI.new()
	return setmetatable({
		windows = {},
		themes = {
			Dark = {
				Primary = Color3.fromRGB(30, 30, 30),
				Secondary = Color3.fromRGB(35, 35, 35),
				Component = Color3.fromRGB(40, 40, 40),
				Interactables = Color3.fromRGB(45, 45, 45),
				Tab = Color3.fromRGB(200, 200, 200),
				Title = Color3.fromRGB(240, 240, 240),
				Description = Color3.fromRGB(200, 200, 200),
				Outline = Color3.fromRGB(40, 40, 40),
				Icon = Color3.fromRGB(220, 220, 220),
			},
			Light = {
				Primary = Color3.fromRGB(232, 232, 232),
				Secondary = Color3.fromRGB(255, 255, 255),
				Component = Color3.fromRGB(245, 245, 245),
				Interactables = Color3.fromRGB(235, 235, 235),
				Tab = Color3.fromRGB(50, 50, 50),
				Title = Color3.fromRGB(0, 0, 0),
				Description = Color3.fromRGB(100, 100, 100),
				Outline = Color3.fromRGB(210, 210, 210),
				Icon = Color3.fromRGB(100, 100, 100),
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
				Icon = Color3.fromRGB(220, 220, 220),
			}
		}
	}, NeonUI)
end

function NeonUI:CreateWindow(config)
	assert(typeof(config) == "table", "Config must be a table")
	config.Size = config.Size or UDim2.fromOffset(570, 370)
	config.Transparency = clamp(config.Transparency or 0, 0, 1)
	config.Theme = config.Theme or "Dark"
	config.Blurring = config.Blurring ~= false
	config.MinimizeKeybind = config.MinimizeKeybind or Enum.KeyCode.LeftControl

	local window = create("ScreenGui", {
		Name = "NeonUI_Window",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	-- Core structure
	local bg = create("Frame", {
		Name = "Background",
		Size = config.Size,
		BackgroundColor3 = self.themes[config.Theme].Primary,
		BorderSizePixel = 0,
		Parent = window
	})

	create("UIStroke", {
		Color = self.themes[config.Theme].Outline,
		Thickness = 1,
		Parent = bg
	})

	local blurEffect = nil
	if config.Blurring then
		blurEffect = create("UIBlurEffect", {
			Intensity = 5,
			Size = 256,
			Parent = bg
		})
	end

	-- Title bar
	local titleBar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = self.themes[config.Theme].Secondary,
		BorderSizePixel = 0,
		Parent = bg
	})

	create("TextLabel", {
		Size = UDim2.new(1, -90, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Text = config.Title or "NeonUI",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = self.themes[config.Theme].Title,
		BackgroundTransparency = 1,
		Parent = titleBar
	})

	-- Buttons
	local closeBtn = create("TextButton", {
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -30, 0, 0),
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = self.themes[config.Theme].Description,
		BackgroundColor3 = self.themes[config.Theme].Interactables,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = titleBar
	})

	-- Content area
	local content = create("Frame", {
		Size = UDim2.new(1, 0, 1, -30),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = self.themes[config.Theme].Secondary,
		BorderSizePixel = 0,
		Parent = bg
	})

	-- Keybind panel (top-right)
	local keybindPanel = create("Frame", {
		Size = UDim2.new(0, 180, 0, 20),
		Position = UDim2.new(1, -190, 0, 5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
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
		Parent = keybindPanel
	})

	-- State
	local visible = true
	local connections = {}

	-- Drag
	do
		local dragging, dragStart, startPos
		connections[#connections+1] = titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = bg.Position
			end
		end)
		connections[#connections+1] = UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				bg.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end)
		connections[#connections+1] = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	-- Minimize toggle
	local function toggleVisibility()
		visible = not visible
		bg.Visible = visible
		if keybindPanel.Visible then
			keybindPanel.Visible = visible
		end
	end

	connections[#connections+1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == config.MinimizeKeybind then
			toggleVisibility()
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		window:Destroy()
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
	end)

	-- Public API
	local api = {
		_window = window,
		_bg = bg,
		_content = content,
		_theme = config.Theme,
		_blur = blurEffect,
		_keybindPanel = keybindPanel,
		_connections = connections,
		_visible = visible,
		_config = config
	}

	function api:SetTheme(themeName)
		local theme = self.themes[themeName]
		if not theme then return end
		self._theme = themeName
		self._bg.BackgroundColor3 = theme.Primary
		titleBar.BackgroundColor3 = theme.Secondary
		closeBtn.BackgroundColor3 = theme.Interactables
		closeBtn.TextColor3 = theme.Description
		self._content.BackgroundColor3 = theme.Secondary
	end

	function api:SetSetting(key, value)
		if key == "Transparency" then
			value = clamp(value, 0, 1)
			self._bg.BackgroundTransparency = value
		elseif key == "Blur" then
			if value and not self._blur then
				self._blur = create("UIBlurEffect", { Intensity = 5, Parent = self._bg })
			elseif not value and self._blur then
				self._blur:Destroy()
				self._blur = nil
			end
		elseif key == "Keybind" then
			self._config.MinimizeKeybind = value
		elseif key == "Size" then
			self._bg.Size = value
		end
	end

	function api:AddKeybindLabel(label, key)
		local frame = create("Frame", {
			Size = UDim2.new(0, 60, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = #self._keybindPanel:GetChildren(),
			Parent = self._keybindPanel
		})
		create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = label .. " – " .. tostring(key.KeyCode):gsub("Enum.KeyCode.", ""),
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Parent = frame
		})
		self._keybindPanel.Visible = true
	end

	function api:Notify(params)
		params.Duration = params.Duration or 3
		local notify = create("Frame", {
			Size = UDim2.fromOffset(300, 60),
			Position = UDim2.new(1, -310, 0, 10 + (#PlayerGui:GetChildren() * 70)),
			BackgroundColor3 = self.themes[self._theme].Primary,
			BorderSizePixel = 0,
			Parent = PlayerGui
		})
		create("UIStroke", {
			Color = self.themes[self._theme].Outline,
			Parent = notify
		})
		create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 5, 0, 5),
			Text = params.Title,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = self.themes[self._theme].Title,
			BackgroundTransparency = 1,
			Parent = notify
		})
		create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 5, 0, 25),
			Text = params.Description,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = self.themes[self._theme].Description,
			BackgroundTransparency = 1,
			Parent = notify
		})
		spawn(function()
			wait(params.Duration)
			notify:Destroy()
		end)
	end

	-- Placeholder for other components (button, slider, etc.)
	function api:AddButton(params)
		-- Simplified; full impl would clone template
		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			Text = params.Title,
			Font = Enum.Font.GothamSemibold,
			TextSize = 14,
			TextColor3 = self.themes[self._theme].Title,
			BackgroundColor3 = self.themes[self._theme].Component,
			AutoButtonColor = false,
			Parent = self._content
		})
		btn.MouseButton1Click:Connect(params.Callback)
	end

	-- Finalize
	window.Parent = PlayerGui
	table.insert(self.windows, api)
	return api
end

function NeonUI:Destroy()
	for _, win in ipairs(self.windows) do
		win._window:Destroy()
		for _, conn in ipairs(win._connections or {}) do
			conn:Disconnect()
		end
	end
	self.windows = {}
end

return NeonUI
