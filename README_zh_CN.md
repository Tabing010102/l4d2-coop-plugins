# l4d2-coop-plugins
个人使用的L4D2服务器战役模式插件  
[README](README.md) | [简体中文说明](README_zh_CN.md)  
**仅支持Linux平台**  
Windows平台可以查看`win`分支  
基于LinuxGSM, 可以使用LinuxGSM或用自己的启动脚本  
编辑`lgsm/config-lgsm/l4d2server/common.cfg`来自定义端口（默认`27015`），也可以参考LinuxGSM文档  
当前配置对应100 tick，如需其他tickrate，请修改`tick_door_speed`  
请编辑`serverfiles/left4dead2/addons/sourcemod/configs/admins_simple.ini`来把自己添加为管理员  
这组插件可能会有些许bug, **使用请自行承担风险**.  
# 一些说明
## match模式  
`thcoop`: 有特感增强的战役模式  
`thcoop2`: 有特感增强（混合插件）的战役模式  
`thcoopnosiai`: 原版特感的战役模式  
## Lgofnoc相关指令
`/forcematch matchmode`: 设置服务器match模式为`matchmode`  
`/resetmatch`: 卸载当前match模式  
默认自动加载`thcoop2`模式，需要更改请修改主配置文件中的`autoloadlgofnoc xxx`  
## 玩家指令
`/jg`: 作为生还者加入游戏  
`/away`: 强制旁观  
`/zs`: 自杀  
## 管理指令
### 一般管理指令
`/sset num`: 设置服务器最大人数为`num`  
`/sinfo`: 显示服务器信息  
`/rygive`: 多功能插件（给予物品、传送等）  
### Bot控制指令
`/addbot`: 增加缺失的bot以供玩家控制  
`/kb`: 踢出所有bot  
### 多特控制指令
`/off14`: 关闭多特  
`/on14`: 按配置文件刷特  
`/on142`: 按生还者人数刷特  
`/addif`: 每增加一个生还增加多少特感  
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
### Advanced Bot AI.vpk（生还者bot增强mod）控制指令
`/morebot`: 原地（但有的时候会生成在出生点）生成一只比尔bot。 此指令调用了vslib里的生成方法，生成的bot并不稳定，也不属于一般bot，当接管后生成的bot时会造成游戏崩溃。如果需要更多bot还是建议使用服务器插件来生成。  
`/botstop`: 当所有玩家阵亡，而bot自身无法自己完成战役时（刁钻的第三方图），强行伤血bot重开这局。  
`/botfindgas`: 关闭或开启bot找油和灌油的功能。  
`/botthrow`: 关闭或开启bot丢投掷的功能。  
`/botimmunity`: 关闭或开启对bot造成伤害（防黑枪）。---在管理员模式开启的情况下仅管理员可以使用。  
`/botescort`: 关闭或开启bot跟随玩家，防止bot乱跑。  
`/botunstick`: 关闭或开启bot卡住传送，开启以防止bot瞬移。  
`/botversus`: 关闭或开启平衡配置。---在管理员模式开启的情况下仅管理员可以使用。  
`/FractureRay`: 关闭或开启强力模式文件配置。---在管理员模式开启的情况下仅管理员可以使用。  
`/botmenu`: 打开指令菜单（观察者模式不可用）。 右键选择，左键确定。  
**其他说明请参考[Steam创意工坊页面](https://steamcommunity.com/sharedfiles/filedetails/?id=1968764163)**
# 其他说明？待添加