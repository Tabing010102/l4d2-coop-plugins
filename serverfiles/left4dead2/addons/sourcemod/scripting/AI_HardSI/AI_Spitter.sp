#pragma semicolon 1

public void Spitter_OnModuleStart() {
}

public void Spitter_OnModuleEnd() {
}
/* 
public Action:Boomer_OnPlayerRunCmd( boomer, &buttons, Float:vel[3], Float:angles[3] ) {
    
} */


// from l4d2_asiai.sp
/**
 * スピッターの処理
 *
 * スピッターはなんか特に意味なくジャンプしたりする
 */
/* 
#define SPITTER_RUN 200.0
#define SPITTER_SPIT_DELAY 2.0
#define SPITTER_JUMP_DELAY 0.1
// stock Action:onSpitterRunCmd(client, &buttons, Float:vel[3], Float:angles[3])
public Action Spitter_OnPlayerRunCmd(int client, int& buttons, float vel[3], float angles[3])
{
        if (getMoveSpeed(client) > SPITTER_RUN
                && delayExpired(client, 0, SPITTER_JUMP_DELAY)
                && (GetEntityFlags(client) & FL_ONGROUND))
        {
                // 逃げてるっぽいときジャンプする
                delayStart(client, 0);
                buttons |= IN_JUMP;
                if (getState(client, 0) == IN_MOVERIGHT) {
                        setState(client, 0, IN_MOVELEFT);
                        buttons |= IN_MOVERIGHT;
                        vel[1] = VEL_MAX;
                } else {
                        setState(client, 0, IN_MOVERIGHT);
                        buttons |= IN_MOVELEFT;
                        vel[1] = -VEL_MAX;
                }
                return Plugin_Changed;
        }

        if (buttons & IN_ATTACK) {
                // 吐くときついでにジャンプする
                if (delayExpired(client, 1, SPITTER_SPIT_DELAY)) {
                        delayStart(client, 1);
                        buttons |= IN_JUMP;
                        return Plugin_Changed;
                        // 吐く角度を変えたいけど
                        // 視線を真上にteleportさせても横に吐いてて
                        // 変更できなかった TODO
                }
        }

        return Plugin_Continue;
}

stock Float:getMoveSpeed(client)
{
        return g_move_speed[client];
}
stock any:getState(client, no)
{
        return g_state[client][no];
}
*/