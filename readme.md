# ArDenHub - Disable NPC

A simple and optimized FiveM script to disable NPCs (peds and vehicles) on your GTA V server, with low `resmon` usage and easy customization.

## Features

- Disable pedestrian and vehicle NPCs
- Disable cops, dispatch, wanted level, boats, and garbage trucks
- Adjustable density multipliers for peds and vehicles
- Optional cleanup system for already spawned entities
- Runtime toggle command (`/npc`, `/npc on`, `/npc off`) with ESX/QBCore group permission support
- Easy configuration via `config.lua`

## Installation

1. Download or clone this repository into your server's `resources` folder.
2. Add the following line to your `server.cfg`:
   ```
   ensure ardenhub_disablenpc
   ```
3. Edit `config.lua` to customize which NPCs to disable and set density multipliers.

## Configuration

Edit the [`config.lua`](config.lua) file to enable or disable specific NPC types and set density multipliers.

### Command permissions (ESX/QBCore)

Inside `config.lua` -> `Config.command`:

- `useFrameworkPermissions = true` enables framework-based permission checks.
- `framework = "auto"` tries ESX first and then QBCore. You can force `"esx"` or `"qbcore"`.
- `allowedGroups = {"admin", "superadmin", "god"}` defines who can use `/npc`.

Any player outside the configured groups/permissions will be denied.

## Runtime usage

### Command

- `/npc` -> toggle ON/OFF
- `/npc on` -> force ON
- `/npc off` -> force OFF

### Event

```lua
TriggerEvent("ardenhub_disablenpc:setEnabled", true)  -- ON
TriggerEvent("ardenhub_disablenpc:setEnabled", false) -- OFF
```

### Exports

```lua
exports["ardenhub_disablenpc"]:SetEnabled(true)
local isEnabled = exports["ardenhub_disablenpc"]:IsEnabled()
```

## Files

- [`fxmanifest.lua`](fxmanifest.lua) - Resource manifest
- [`config.lua`](config.lua) - Shared configuration
- [`client.lua`](client.lua) - Main client script
- [`server.lua`](server.lua) - Server-side framework permission checks

## Credits

Developed by [arduinodenis.it](https://arduinodenis.it)

## License

This project is licensed under the MIT
