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
## Match Modes  
`thcoop`: coop with improved special infected AI  
`thcoop2`: coop with improved special infected AI(mixed plugins)  
`thcoop4`: coop with improved special infected AI(mixed plugins) && new SI control plugins  
`thcoopnosiai`: coop with original special infected AI  
## Lgofnoc related commands
`/forcematch matchmode`: set server matchmode to `matchmode`  
`/resetmatch`: unload running matchmodes  
~~default autoloading `thcoop4` mode, please change `autoloadlgofnoc xxx` in the server config file to modify~~  
autoloading may crash the client built-in server, commenting `autoloadlgofnoc xxx` in the main config file  
please use `/forcematch matchmode` to manually load `matchmode` or just remove the `//` to autoload if you are using DS  
cvar `ai_tank_bhop` control tank bhop or not, set `1` to enable, set `0` to disable  
## Player commands
`/jg`: join game as a survivor  
`/away`: force idle  
`/zs`: commit suiside  
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
`/zlimit`: change common infected limit  
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