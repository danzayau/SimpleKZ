# SimpleKZ Plugin Package (CS:GO)

[![Build Status](https://travis-ci.org/danzayau/SimpleKZ.svg?branch=master)](https://travis-ci.org/danzayau/SimpleKZ)

## Features

 * **Timer** - Obviously!
 * **Movement Styles** - Custom movement mechanics. Includes Legacy (KZTimer) and Competitive styles.
 * **Customisable Experience** - Plenty of options to provide the best possible experience for players. 
 * **Database Support** - Store player options, times and more using either a MySQL or SQLite database.
 * Map bonus support, HUD, teleport menu, noclip, !goto, !measure and much, much more.

## Usage

### Server Requirements

 * SourceMod 1.8+
 * 128 Tick
 * [**MovementAPI Plugin**](https://github.com/danzayau/MovementAPI) (included)

### Server Installation

 * Download and extract ```SimpleKZ-vX.X.X.zip``` from the latest GitHub release to ```csgo/``` in the server directory.
 * Check ```csgo/cfg/sourcemod/simplekz/kz.cfg``` is appropriate for the server.
 * ConVar config files are also generated in that directory after starting the plugins.
 * Add a MySQL/SQLite database called ```simplekz``` to ```csgo/addons/sourcemod/configs/databases.cfg```.
 * Use ```!updatemappool``` to populate the ranked map pool with those in ```csgo/cfg/sourcemod/simplekz/mappool.cfg```.
 
### Mapping

To add a timer button to a map, use a ```func_button``` with a specific name.

 * Start button is named ```climb_startbutton```.
 * End button is named ```climb_endbutton```.
 * Bonus start buttons are named ```climb_bonusX_startbutton``` where X is the bonus number.
 * Bonus end buttons are named ```climb_bonusX_endbutton``` where X is the bonus number.
 
**NOTE:** Enable both the ```Don't move``` and ```Toggle``` flags to avoid any usability issues.

### [Commands](COMMANDS.md)