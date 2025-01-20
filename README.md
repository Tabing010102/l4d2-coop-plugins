# l4d2-coop-plugins
Personally used Left 4 Dead 2 Coop Plugins  
[README](README.md) | [简体中文说明](README_zh_CN.md)  
**Windows Platform Alpha**  
Please add lanuch options to specific port and tickrate  
If you are using dedicated server, please modify startup script and rename `listenserver.cfg` in `cfg` folder to `server.cfg`  
Current configuration is for 100 tick, please modify `tick_door_speed` if you need other tickrate  
Please edit `left4dead2/addons/sourcemod/configs/admins_simple.ini` to add yourself as an administrator  
There may be some bugs with the plugin set, **USE AT YOUR OWN RISK**.  

# Some Descriptions

## Known Bugs
secondary weapons(especially dual-pistol and magnum) may not be saved when changing level  
when closing the safe room, a survivor which is incapped may be given health which he have when he is incapped(superman)  

## Match Modes
~~`thcoop`: Campaign mode with enhanced special infected~~ **(Deprecated)**  
~~`thcoop2`: Campaign mode with enhanced special infected (hybrid plugins)~~ **(Deprecated)**  
~~`thcoopnosiai`: Campaign mode with vanilla special infected~~ **(Deprecated)**  
`thcoop4`: Campaign mode with enhanced special infected (hybrid plugins) && new SI control (Hard)  
`thcoop4normal`: Campaign mode with enhanced special infected (hybrid plugins) && new SI control (Normal)  
`thcoop4hardplus`: Campaign mode with enhanced special infected (hybrid plugins) && new SI control (Hard+)  
`thcoop4expert`: Campaign mode with enhanced special infected (hybrid plugins) && new SI control (Expert)  
`thcoop4nosiai`: Campaign mode with vanilla special infected && new SI control  
`thcoop4nosiaiexpert`: Campaign mode with vanilla special infected && new SI control (Expert)  

## Default Difficulty Settings (thcoop4)
### Differences between Expert and Hard
Expert mode loads the `l4d_ragdoll_fader` plugin, which makes zombie corpses disappear instantly
### Tank Health
This repo uses l4dinfectedbots(2025-1-7) to control tank health
 - When player count > 4:
   - Easy & Normal: `6000 + (player_count - 4) * 750`
   - Hard & Expert: `8000 + (player_count - 4) * 1500`
 - When player count <= 4, tank health is reduced proportionally:
   - Easy & Normal: `6000 * (player_count / 4)`
   - Hard & Expert: `8000 * (player_count / 4)`
### Special Infected Spawn Time
25-35 seconds, slightly longer when player count < 4
### Special Infected Count
By default, players cannot control special infected. Quantities refer to `sourcemod/data/l4dinfectedbots/thcoop4.cfg`  
Default configuration recommends player count ≤ 14
### Special Infected Control Configuration
Refer to `sourcemod/data/l4dinfectedbots/xxx.cfg`, where `xxx` is the game mode. This repo adds the `thcoop4` mode  
`thcoop4normal` mode loads configurations from `thcoop4_normal.cfg`, other modes loads configurations from `thcoop4_hard.cfg`  
For other unlisted configurations, you can add a `my_mode.cfg` file and set cvar `l4d_infectedbots_read_data "my_mode"` to load it  
For more usage details, please refer to the [original repo](https://github.com/fbef0102/L4D1_2-Plugins/tree/9c92b6c245690997922f203d1be23e47f983b0c2/l4dinfectedbots)  

## Hard Plus Difficulty Description(thcoop4hardplus)
**Note: this difficulty is based on the offical `Hard` difficulty, you need to change the difficulty to `Hard` to use this mode**  
### Default damage changes(relative to the offical `Hard`)
Common infected: x2.0  
Special infected: x2.0  
Tank: punch and rock both make a 50hp damage  
Witch: not changed  
Friend Fire: x2.0  
Fire Damage: x1.75  
### Cvars of related plugins
`l4d_ncm_type1damage`: common infected damage multiplier  
`tank_damage_enable`: enable or disable tank damage change  
`tank_damage`: tank damage  
`tank_damage_modifier`: tank damage multiplier to incapped survivors relative to `tank_damage`  
### Other description
Damage of special infected may not be completely changed  
You may need to manual execute `/resetmatch` to correctly restore damage when changing to other matchmodes  

## Lgofnoc related commands
`/forcematch matchmode`: set server matchmode to `matchmode`  
`/resetmatch`: unload running matchmodes  
~~default autoloading `thcoop4` mode, please change `autoloadlgofnoc xxx` in the server config file to modify~~  
autoloading may crash the client built-in server, commenting `autoloadlgofnoc xxx` in the main config file  
please use `/forcematch matchmode` to manually load `matchmode` or just remove the `//` to autoload if you are using DS  
cvar `ai_tank_bhop` control tank bhop or not, set `1` to enable, set `0` to disable  
cvar `ai_boomer_bhop` control boomer bhop or not, set `1` to enable, set `0` to disable  

## Player commands
`/jg`: join game as a survivor  
`/away`: force idle  
`/zs`: commit suiside  
`/csm`: change survivor model  
`Shift + E`: mark a spot on the map at your crosshair  

## Management commands
### General commands
`/sset num`: set server max player to `num`  
`/sinfo`: show server maxplayer info  
`/rygive`: give items, teleport players, etc.  
`/pause`: pause/unpause game  
### Bot control commands
`/addbot`: add a bot for player(s) to control when necessary  
`/kb`: kick all bots  
### SI control commands(thcoop2)
`/off14`: turn off multi-SI mode  
`/on14`: turn on multi-SI mode, SI number is controlled by configuration file  
`/on142`: turn on multi-SI mode, SI number is determined by current players in-game  
`/addif`: specify how many SI added when one new player connected  
### SI control commands(thcoop4)
`/js`: join survivor  
`/ji`: join infected  
`/timer`: change SI spawn timer  
`/zlimit`: change max special infected limit  
Other feature is controlled by cvar  
### Ammo control commands
~~`/offammo`: disable ammo modification~~  
~~`/onammo`: enable double ammo~~  
~~`/onammo1`: enable custom ammo controled by configuration file~~  
~~`/onammo2`: enable unlimited ammo~~  
Ammo reservation is now controlled by `l4d2_guncontrol`, default triple ammo reserve  
### Recourse control commands
`/mmn`: control medical resources multiplier  
### Auxiliary? commands
`/onhw`: turn on auto giving lazer sets  
`/offhw`: turn off auto giving lazer sets  
`/ontui`: turn on unlimited m2  
`/offtui`: turn off unlimited m2  
`/onrb`: turn on auto bhop when space being pressed  
`/offrb`: turn off auto bhop when space being pressed  
# Other descriptions? to be added
