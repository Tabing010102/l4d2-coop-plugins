# l4d2-coop-plugins
Personally used Left 4 Dead 2 Dedicated Server Coop Plugins  
**LINUX SERVER SUPPORT ONLY**  
Please edit lgsm/config-lgsm/l4d2server/common.cfg to specify your own port(Default 27015), or you can refer to LinuxGSM configuration document.  
Please edit serverfiles/left4dead2/addons/sourcemod/configs/admins_simple.ini to add yourself as an administrator  
There may be some bugs with the plugin set, **USE AT YOUR OWN RISK**.  
# Some commands
## Player commands
/jg: join game as a survivor  
/away: force idle  
/zs: commit suiside  
## Management commands
### General commands
/sset [num]: set server max player to num  
/sinfo: show server maxplayer info  
/rygive: give items, teleport players, etc.  
### Bot control commands
/addbot: add a bot for player(s) to control when necessary  
/kb: kick all bots  
### SI control commands
/off14: turn off multi-SI mode  
/on14: turn on multi-SI mode, SI number is controlled by configuration file  
/on142: turn on multi-SI mode, SI number is determined by current players in-game  
/addif: specify how many SI added when one new player connected  
### Ammo control commands
~~/offammo: disable ammo modification~~  
~~/onammo: enable double ammo~~  
~~/onammo1: enable custom ammo controled by configuration file~~  
~~/onammo2: enable unlimited ammo~~  
Ammo reservation is now controlled by l4d2_guncontrol, default triple ammo reserve  
### Recourse control commands
/mmn: control medical resources multiplier  
### Auxiliary? commands
/onhw: turn on auto giving lazer sets  
/offhw: turn off auto giving lazer sets  
/ontui: turn on unlimited m2  
/offtui: turn off unlimited m2  
/onrb: turn on auto bhop when space being pressed  
/offrb: turn off auto bhop when space being pressed  
# Other descriptions? to be added