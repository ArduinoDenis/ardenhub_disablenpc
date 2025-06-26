# ArDenHub - Disable NPC

A simple FiveM script to disable NPCs (peds, vehicles, emergency vehicles, garbage trucks, boats, and aircraft) on your GTA V server.

## Features

- Disable pedestrian and vehicle NPCs
- Disable emergency vehicles and garbage trucks
- Adjustable density multipliers for peds and vehicles
- Easy configuration via `config.lua`

## Installation

1. Download or clone this repository into your server's `resources` folder.
2. Add the following line to your `server.cfg`:
   ```
   ensure ardenhub_disablenpc
   ```
3. Edit `config.lua` to customize which NPCs to disable and set density multipliers.

## Configuration

Edit the [`config.lua`](config.lua) file to enable or disable specific NPC types and set density multipliers

## Files

- [`fxmanifest.lua`](fxmanifest.lua) - Resource manifest
- [`config.lua`](config.lua) - Configuration file
- [`client.lua`](client.lua) - Main client script

## Credits

Developed by [arduinodenis.it](https://arduinodenis.it)

## License

This project is licensed under the MIT
