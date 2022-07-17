# l4d2-coop-plugins
个人使用的L4D2服务器战役模式插件  
[README](README.md) | [简体中文说明](README_zh_CN.md)  
**仅支持Linux平台**  
Windows平台可以查看`win`分支  
基于LinuxGSM, 可以使用LinuxGSM或用自己的启动脚本  
编辑`lgsm/config-lgsm/l4d2server/l4d2server.cfg`来自定义端口（默认`27015`），也可以参考LinuxGSM文档  
当前配置对应100 tick，如需其他tickrate，请修改`tick_door_speed`  
请编辑`serverfiles/left4dead2/addons/sourcemod/configs/admins_simple.ini`来把自己添加为管理员  
这组插件可能会有些许bug, **使用请自行承担风险**.  
# 一些说明
## 已知bug
切换关卡时，可能会被没收副武器，尤其是双枪、马格南  
关闭安全门切换关卡时，在安全门内倒地的生还者，会被赋予倒地时虚血的血量（超人）  
## match模式  
~~`thcoop`: 有特感增强的战役模式~~**(已弃用)**  
~~`thcoop2`: 有特感增强（混合插件）的战役模式~~**(已弃用)**  
~~`thcoopnosiai`: 原版特感的战役模式~~**(已弃用)**  
`thcoop4`: 有特感增强（混合插件）&&新特感控制的战役模式  
`thcoop4expert`: 有特感增强（混合插件）&&新特感控制的战役模式（专家）  
`thcoop4nosiai`: 原版特感&&新特感控制的战役模式  
`thcoop4nosiaiexpert`: 原版特感&&新特感控制的战役模式（专家）  
## 默认难度说明(thcoop4)
当`人数` ≤ `4`时，下计算公式按`4`计算
### 坦克血量
本repo使用修改版l4dinfectedbots(2.6.8)控制坦克血量，普通难度需x1.5倍  
简单：`3000 + (人数 - 4) * 750`  
普通：`6000 + (人数 - 4) * 1500`  
困难&专家：`8000 + (人数 - 4) * 2000`  
### 特感刷新时间
17-35秒  
### 特感数量
`thcoop4` 和 `thcoop4nosiai` 模式: `6 + floor((人数 - 4) / 2) * 3`，允许3个玩家控制特感位  
`thcoop4expert` 和 `thcoop4nosiaiexpert` 模式: `4 + (人数 - 4)`，不允许玩家控制特感  
## Lgofnoc相关指令
`/forcematch matchmode`: 设置服务器match模式为`matchmode`  
`/resetmatch`: 卸载当前match模式  
默认自动加载`thcoop4`模式，需要更改请修改主配置文件中的`autoloadlgofnoc xxx`  
`ai_tank_bhop` 参数控制tank连跳与否，`1`开启，`0`关闭  
## 玩家指令
`/jg`: 作为生还者加入游戏  
`/away`: 强制旁观  
`/zs`: 自杀  
`/csm`: 更换人物模型  
## 管理指令
### 一般管理指令
`/sset num`: 设置服务器最大人数为`num`  
`/sinfo`: 显示服务器信息  
`/rygive`: 多功能插件（给予物品、传送等）  
`/pause`: 暂停/恢复游戏  
### Bot控制指令
`/addbot`: 增加缺失的bot以供玩家控制  
`/kb`: 踢出所有bot  
### 多特控制指令(thcoop2)
`/off14`: 关闭多特  
`/on14`: 按配置文件刷特  
`/on142`: 按生还者人数刷特  
`/addif`: 每增加一个生还增加多少特感  
### 多特控制指令(thcoop4)
`/js`: 加入生还者  
`/ji`: 加入特感  
`/timer`: 更改特感生成时间  
`/zlimit`: 更改小ss数量  
其他功能由cvar控制  
### 备弹控制指令
~~`/offammo`: 关闭备弹修改~~  
~~`/onammo`: 双倍备弹~~  
~~`/onammo1`: 按配置文件修改备弹~~  
~~`/onammo2`: 无限备弹~~  
备弹现在由`l4d2_guncontrol`控制, 默认3倍备弹  
### 医疗物资管理指令
`/mmn`: 修改医疗物资倍数  
### 辅助？控制
`/onhw`: 自动给予红外  
`/offhw`: 关闭自动给予红外  
`/ontui`: 无限推  
`/offtui`: 关闭无限推  
`/onrb`: 按住空格自动连跳  
`/offrb`: 关闭按住空格自动连跳  
# 其他说明？待添加