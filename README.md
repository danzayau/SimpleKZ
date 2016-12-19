# SimpleKZ Sourcemod Plugin for CS:GO

SimpleKZ is a timer plugin intended for CS:GO KZ maps with only the bare essentials.

============================

### Features

 * **KZ Map Compatibility** - Automatically detects start and end timers on KZTimer globally approved maps.
 * **Timer** - Simple timer that keeps track and tells you how long you took to complete the map.
 * **Teleport Menu** - Gives the ability to make a checkpoint and teleport back to it.
 * **Essential Timer Features** - Noclip, hide other players, spectate command, goto command, etc.
 
### Player Commands

 * ```!hide``` - Toggles the showing of other players.
 * ```!menu``` - Toggles the showing of the teleport menu.
 * ```!checkpoint``` - Set your checkpoint.
 * ```!gocheck``` - Teleport to your checkpoint.
 * ```!undo``` - Undo going to your checkpoint.
 * ```!start``` - Teleport to the start of the map.
 * ```!spec``` - Join spectators or spectate a specified player.
 * ```!goto``` - Teleport to a player.
 * ```+noclip``` - Noclip (bind a key to it in console).

============================

### Installation

 * Extract ```SimpleKZ.zip``` to ```csgo/``` in your server directory.
 * The config file executed by the plugin is ```csgo/cfg/sourcemod/SimpleKZ/SimpleKZ.cfg```.
 * SimpleKZ will block other menus from showing. To fix, add menu commands to ```csgo/cfg/sourcemod/SimpleKZ/exceptions_list.cfg```.
 
### Recommended Plugin

 * [**MovementTweaker**](https://github.com/danzayau/MovementTweaker) - Speed panel, adjusted bunnyhopping, prestrafe and universal weapon speed.