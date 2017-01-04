# SimpleKZ (CS:GO)

[![Build Status](https://travis-ci.org/danzayau/SimpleKZ.svg?branch=master)](https://travis-ci.org/danzayau/SimpleKZ)

SimpleKZ is a timer plugin for KZ maps with all the essentials.

============================

### Features

 * **KZ Map Compatibility** - Automatically detects start and end timers on KZTimer globally approved maps.
 * **Timer** - Simple timer that keeps track and tells you how long you took to complete the map.
 * **Teleport Menu** - Gives the ability to make a checkpoint and teleport back to it.
 * **Essential Extras** - Noclip, hide other players, spectate command, goto command, speed panel, and more.
 * **API** - Forwards and natives for you to use in other plugins (see [simplekz.inc](scripting/include/simplekz.inc)).

============================

### Requirements

 * **Tested Against**: SourceMod 1.7 Latest, 1.8 Latest, 1.9 Latest
 * [**MovementAPI**](https://github.com/danzayau/MovementAPI)
 * [**MovementTweaker**](https://github.com/danzayau/MovementTweaker)

### Installation

 * Extract ```SimpleKZ.zip``` to ```csgo/``` in your server directory.
 * Check the config file ```csgo/cfg/sourcemod/SimpleKZ/SimpleKZ.cfg``` is appropriate for your server.

============================

### Player Commands

 * ```!hide``` - Toggles the visibility of other players.
 * ```!menu``` - Toggles the visibility of the teleport menu.
 * ```!checkpoint``` - Set your checkpoint.
 * ```!gocheck``` - Teleport to your checkpoint.
 * ```!undo``` - Undo going to your checkpoint.
 * ```!start``` - Teleport to the start of the map.
 * ```!spec``` - Join spectators or spectate a specified player.
 * ```!goto``` - Teleport to a player.
 * ```!speed``` - Toggles the visibility of the centre information panel.
 * ```!hideweapon``` - Toggles the visiblity of weapon/viewmodel.
 * ```!pistol``` - Brings up the pistol selection menu.
 * ```+noclip``` - Noclip (bind a key to it in console).