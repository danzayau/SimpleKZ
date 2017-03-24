# SimpleKZ (CS:GO)

[![Build Status](https://travis-ci.org/danzayau/SimpleKZ.svg?branch=master)](https://travis-ci.org/danzayau/SimpleKZ)

*A timer plugin for climb maps with all the essentials.*

### Features

 * **KZ Map Compatibility** - Automatically detects start and end timers on KZTimer globally approved maps.
 * **Movement Styles** - Play KZ using different movement mechanics, including a legacy, KZTimer-like style.
 * **Customisable Experience** - Plenty of available options to provide the best possible experience for players. 
 * **Database Support** - Store player options, times and more using either a MySQL or SQLite database.
 * **Essential Extras** - Map bonus support, centre info panel, teleport menu, noclip, !goto, !measure and more.

---

### Requirements

 * **Tested Using**: SourceMod 1.8
 * [**MovementAPI Plugin**](https://github.com/danzayau/MovementAPI) (included in ```SimpleKZ-vX.X.X.zip```)

### Installation

 * Download and extract ```SimpleKZ-vX.X.X.zip``` from the latest GitHub release to ```csgo/``` in your server directory.
 * Check the config file ```csgo/cfg/sourcemod/SimpleKZ/kz.cfg``` is appropriate for your server.
 * Config files for server ConVars are also generated in that directory after starting the plugin.
 * Add a MySQL/SQLite database called ```simplekz``` to ```csgo/addons/sourcemod/configs/databases.cfg``` for storing player preferences, player times and more. This is essential in providing the best player experience this plugin can.
 * Check that ```csgo/cfg/sourcemod/SimpleKZ/mappool.cfg``` contains all maps you want to count towards rankings. You then use the admin command ```!updatemappool``` to update the maps database with this list.
 * This included map pool config contains only high quality maps that are possible on the default style.
 * SimpleKZ Core will work without the other plugins or a database if you do not need the related features.
 
### Mapping

To add a timer button to your map, use a ```func_button``` with a specific name.

 * Start button is named ```climb_startbutton```.
 * End button is named ```climb_endbutton```.
 * Bonus start buttons are named ```climb_bonusX_startbutton``` where X is the bonus number.
 * Bonus end buttons are named ```climb_bonusX_endbutton``` where X is the bonus number.
 
**NOTE:** Enable both the ```Don't move``` and ```Toggle``` flags to avoid any usability issues.

---

### Simple KZ Core Player Commands

**Timer Commands**

 * ```!checkpoint``` - Set your checkpoint.
 * ```!gocheck``` - Teleport to your checkpoint.
 * ```!pause```/```!resume``` - Toggle pausing your timer and stopping you in your position.
 * ```!undo``` - Undo teleport.
 * ```!start```/```!r``` - Teleport to the start of the map.
 * ```!stop``` - Stop your timer.

**Options**

 * ```!options``` - Open the options menu.
 * ```!menu``` - Toggle the visibility of the teleport menu.
 * ```!hide``` - Toggles the visibility of other players.
 * ```!speed``` - Toggle visibility of the centre information panel.
 * ```!hideweapon``` - Toggle visibility of your weapon.
 * ```!pistol``` - Open the pistol selection menu.
 
**Styles**

 * ```!style``` - Opens up the movement style selection menu.
 * ```!standard```/```!s``` - Switch to the standard style.
 * ```!legacy```/```!l``` - Switch to the legacy style.

**Other**

 * ```!nc``` - Toggle noclip.
 * ```+noclip``` - Noclip (bind a key to it in console).
 * ```!spec``` - Join spectators or spectate a specified player.
 * ```!goto``` - Teleport to another player. Usage: ```!goto <player>```
 * ```!measure``` - Open the measurement menu.
 * ```!stopsound``` - Stop all sounds e.g. map soundscapes (music).
 
### SimpleKZ Local Ranks Player Commands

These commands return results based on your currently selected style.
 
 * ```!top``` - Opens a menu showing the top record holders
 * ```!maptop``` - Opens a menu showing the top times of a map. Usage: ```!maptop <map>```
 * ```!bmaptop``` - Opens a menu showing the top bonus times of a map. Usage: ```!btop <#bonus> <map>```
 * ```!pb``` - Prints map times and ranks to chat. Usage: ```!pb <map> <player>```
 * ```!bpb``` - Prints PB bonus times and ranks to chat. Usage: ```!bpb <#bonus> <map> <player>```
 * ```!wr``` - Prints map record times to chat. Usage: ```!wr <map>```
 * ```!bwr``` - Prints bonus record times to chat. Usage: ```!bwr <#bonus> <map>```
 * ```!pc``` - Prints map completion to chat. Usage: ```!pc <player>```