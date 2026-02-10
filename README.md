# Elytra-UI

A powerful UI library for Roblox scripting. Created by RAKET90 (romb_pa).

## Features

- Beautiful Dark Theme with clean interface design
- Responsive Design with resizable window and smooth animations
- Multiple Components including Buttons, Toggles, Sliders, Dropdowns, Keybinds, and more
- Easy Keybind System with visual feedback
- Mini Bar showing player info, hub name, and game name
- Creator Info with built-in credit system
- Theme Support with 20 predefined themes
- Smooth Animations for polished user experience

## Installation

### Method 1: Direct Paste

Copy the main.lua content and paste it into your Roblox script.

### Method 2: Save as Module

Save main.lua as a ModuleScript in ReplicatedStorage and require it:

```lua
local Library = require(game.ReplicatedStorage.ElytraUI)
```

## Quick Start

### Basic Window Creation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/karatdushi-hub/elytra-ui/main/main.lua"))()

local Window = Library:CreateWindow({
    Title = "My Hub",
    Size = UDim2.new(0, 550, 0, 400),
    Transparency = 0.2,
    MinimizeKeybind = Enum.KeyCode.LeftControl,
    Blurring = false,
    Theme = "Dark",
    HubName = "My Custom Hub",
    GameName = "Universal",
    HubDescription = "The best hub for your gaming needs!"
})
```

### Creating Tabs

```lua
-- Create a tab section first
Window:AddTabSection({ Name = "Main", Order = 1 })

-- Create a tab
local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "rbxassetid://your-icon-id",
    Section = "Main"
})

-- Add a section to the tab
Window:AddSection({
    Name = "Player Settings",
    Tab = MainTab
})
```

## Components

### Button

```lua
Window:AddButton({
    Title = "Execute",
    Description = "Click to execute the script",
    Tab = MainTab,
    Callback = function()
        print("Button clicked!")
        -- Your code here
    end
})
```

### Toggle

```lua
Window:AddToggle({
    Title = "Enable Feature",
    Description = "Toggle this feature on or off",
    Default = false,
    Tab = MainTab,
    Callback = function(Value)
        print("Toggle value:", Value)
        -- Your code here
    end
})
```

### Slider

```lua
Window:AddSlider({
    Title = "Sensitivity",
    Description = "Adjust your sensitivity",
    MaxValue = 100,
    AllowDecimals = false,
    DecimalAmount = 0,
    Tab = MainTab,
    Callback = function(Value)
        print("Slider value:", Value)
        -- Your code here
    end
})
```

### Keybind

```lua
Window:AddKeybind({
    Title = "Toggle Menu",
    Description = "Press to toggle the menu",
    Tab = MainTab,
    Callback = function(Key)
        if Key then
            print("Keybind set to:", Key.Name)
        else
            print("Keybind cleared")
        end
        -- Your code here
    end
})
```

### Dropdown

```lua
Window:AddDropdown({
    Title = "Select Mode",
    Description = "Choose your preferred mode",
    Options = {
        ["Mode 1"] = "mode1_value",
        ["Mode 2"] = "mode2_value",
        ["Mode 3"] = "mode3_value"
    },
    Tab = MainTab,
    Callback = function(Value)
        print("Selected:", Value)
        -- Your code here
    end
})
```

### Input

```lua
Window:AddInput({
    Title = "Player Name",
    Description = "Enter player name to teleport",
    Tab = MainTab,
    Callback = function(Text)
        print("Input text:", Text)
        -- Your code here
    end
})
```

### Paragraph

```lua
Window:AddParagraph({
    Title = "Instructions",
    Description = "Welcome to the hub! Here's how to use it:\n\n1. Select a feature from the tabs\n2. Configure your settings\n3. Enjoy!",
    Tab = MainTab
})
```

## Settings

### Change Theme

```lua
-- Change theme by name (20 predefined themes available)
Window:SetThemeByName("Ocean")

-- Available themes: Light, Dark, Void, Ocean, Forest, Sunset, Purple, Rose, Ruby, Gold, Silver, Midnight, Cherry, Mint, Lavender, Coral, Sky, Emerald, Amber, Slate
```

### Change Window Settings

```lua
-- Change transparency
Window:SetSetting("Transparency", 0.3)

-- Change size
Window:SetSetting("Size", UDim2.new(0, 600, 0, 500))

-- Enable/disable blur
Window:SetSetting("Blur", true)

-- Change minimize keybind
Window:SetSetting("Keybind", Enum.KeyCode.RightControl)

-- Hide/show minimize icon
Window:SetSetting("MinimizeIconVisible", false)

-- Change hub name
Window:SetSetting("HubName", "My Awesome Hub")

-- Change game name
Window:SetSetting("GameName", "My Custom Game")

-- Change hub description
Window:SetSetting("HubDescription", "An amazing hub for everyone!")
```

### Notifications

```lua
Window:Notify({
    Title = "Success",
    Description = "Your settings have been saved!",
    Duration = 3
})
```

### Unload Window

```lua
-- Unload the window and all connections
Window:Unload()
```

## Adding Your Own Functions

### Basic Function with Toggle

```lua
-- Create a toggle for your function
Window:AddToggle({
    Title = "Speed Hack",
    Description = "Enable speed boost",
    Default = false,
    Tab = MainTab,
    Callback = function(Value)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        
        if Humanoid then
            if Value then
                Humanoid.WalkSpeed = 50
            else
                Humanoid.WalkSpeed = 16
            end
        end
    end
})
```

### Function with Keybind

```lua
-- Create a keybind for your function
Window:AddKeybind({
    Title = "Fly Keybind",
    Description = "Press to bind fly toggle key",
    Tab = MainTab,
    Callback = function(Key)
        if Key then
            -- Register the keybind
            Library:RegisterKeybind("FlyToggle", Key, function()
                -- Toggle fly function here
                print("Fly toggled!")
            end)
            Window:Notify({
                Title = "Keybind Set",
                Description = "Fly key: " .. Key.Name,
                Duration = 2
            })
        else
            -- Unregister the keybind
            Library:UnregisterKeybind("FlyToggle")
            Window:Notify({
                Title = "Keybind Cleared",
                Description = "Fly keybind cleared!",
                Duration = 2
            })
        end
    end
})
```

### Function with Slider

```lua
-- Create a slider for your function
Window:AddSlider({
    Title = "Jump Power",
    Description = "Set your jump height",
    MaxValue = 200,
    AllowDecimals = false,
    Tab = MainTab,
    Callback = function(Value)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        
        if Humanoid then
            Humanoid.JumpPower = Value
        end
    end
})
```

### Function with Dropdown

```lua
-- Create a dropdown for your function
Window:AddDropdown({
    Title = "Teleport Location",
    Description = "Select where to teleport",
    Options = {
        ["Spawn"] = Vector3.new(0, 0, 0),
        ["Base"] = Vector3.new(100, 10, 100),
        ["Tower"] = Vector3.new(-50, 20, -50)
    },
    Tab = MainTab,
    Callback = function(Position)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character
        
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = CFrame.new(Position)
        end
    end
})
```

## Library Functions

### Register Keybind

Register a global keybind that works even when the UI is closed:

```lua
Library:RegisterKeybind("MyFunction", Enum.KeyCode.F, function()
    print("Function triggered!")
    -- Your code here
end)
```

### Unregister Keybind

```lua
Library:UnregisterKeybind("MyFunction")
```

### Get All Themes

```lua
local AllThemes = Library:GetThemes()
```

### Get Theme by Name

```lua
local OceanTheme = Library:GetTheme("Ocean")
```

### Get Theme Names

```lua
local ThemeNames = Library:GetThemeNames()
```

## Window Functions

### Set Toggle Value

```lua
-- Set a toggle to true or false
Window:SetToggle("Speed Hack", true)
```

### Get Toggle Value

```lua
-- Get current toggle state
local IsEnabled = Window:GetToggle("Speed Hack")
```

### Get Hub Settings

```lua
local Settings = Window:GetHubSettings()
print(Settings.HubName)
print(Settings.GameName)
```

## Mini Bar

The mini bar is automatically created at the bottom-left of your window and displays:

- Player Icon with avatar
- Hub Name (customizable via HubName setting)
- Game Name (customizable via GameName setting)
- Player Name (automatically shows current player's name)

The mini bar background color changes with the selected theme.

## Theme System

The library includes 20 predefined themes:

1. Light - Light theme with dark text
2. Dark - Dark theme with light text
3. Void - Extra dark theme
4. Ocean - Blue ocean theme
5. Forest - Green forest theme
6. Sunset - Orange sunset theme
7. Purple - Purple theme
8. Rose - Pink rose theme
9. Ruby - Red ruby theme
10. Gold - Gold theme
11. Silver - Silver theme
12. Midnight - Dark blue midnight theme
13. Cherry - Red cherry theme
14. Mint - Green mint theme
15. Lavender - Purple lavender theme
16. Coral - Orange coral theme
17. Sky - Blue sky theme
18. Emerald - Green emerald theme
19. Amber - Yellow amber theme
20. Slate - Gray slate theme

Each theme includes:
- Primary - Main window background
- Secondary - Inner panels and Mini Bar background
- Component - Interactive components
- Interactables - Buttons, toggles (off state)
- Tab - Tab text color
- Title - Titles and headings
- Description - Descriptions
- Outline - Borders and strokes
- Icon - Image colors
- ToggleOn - Toggle color when enabled

## API Reference

### Library:CreateWindow(Settings)

Creates a new UI window.

Parameters:
- Title (string) - Window title
- Size (UDim2) - Window size
- Transparency (number) - Background transparency (0-0.8)
- MinimizeKeybind (Enum.KeyCode) - Key to toggle window
- Blurring (boolean) - Enable background blur
- Theme (string) - Theme mode name
- HubName (string) - Custom hub name
- GameName (string) - Custom game name
- HubDescription (string) - Hub description text

Returns: Window object

### Window Methods

- AddTab(Settings) - Add a new tab
- AddTabSection(Settings) - Add a tab section
- AddSection(Settings) - Add a section to a tab
- AddButton(Settings) - Add a button
- AddToggle(Settings) - Add a toggle switch
- AddSlider(Settings) - Add a slider
- AddKeybind(Settings) - Add a keybind selector
- AddDropdown(Settings) - Add a dropdown menu
- AddInput(Settings) - Add a text input
- AddParagraph(Settings) - Add a paragraph/text block
- Notify(Settings) - Show a notification
- SetSetting(Setting, Value) - Change window settings
- SetTheme(ThemeTable) - Set custom theme
- SetThemeByName(ThemeName) - Set theme by name
- SetToggle(ToggleName, Value) - Set toggle value
- GetToggle(ToggleName) - Get toggle value
- GetHubSettings() - Get current hub settings
- Unload() - Close and cleanup the window

## Credits

- Creator: RAKET90 (romb_pa)
- Repository: https://github.com/karatdushi-hub/elytra-ui

## License

This project is open source and available under the MIT License.
