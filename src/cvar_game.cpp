#include "cvar_game.h"

cvar_t *p_gravity;
cvar_t *p_jumpHeight;
cvar_t *p_wallSlideSpeed;
cvar_t *p_earlyJumpEndModifier;
cvar_t *p_pogoJumpHeight;
cvar_t *p_doubleJumpHeight;
cvar_t *p_wallJumpX;
cvar_t *p_maxSpeed;
cvar_t *p_terminalVelocity;
cvar_t *p_speedJumpBonus;
cvar_t *p_airAccel;
cvar_t *p_turnAirAccel;
cvar_t *p_accel;
cvar_t *p_skidAccel;
cvar_t *p_groundFriction;
cvar_t *p_airFriction;

static cvarTable_t gameCvarTable[] = {
    { &p_gravity, "p_gravity", "550", 0 },
    { &p_jumpHeight, "p_jumpHeight", "280", 0 },
    { &p_wallSlideSpeed, "p_wallSlideSpeed", "45", 0 },
    { &p_earlyJumpEndModifier, "p_earlyJumpEndModifier", "0.5", 0 },
    { &p_pogoJumpHeight, "p_pogoJumpHeight", "350", 0 },
    { &p_doubleJumpHeight, "p_doubleJumpHeight", "245", 0 },
    { &p_wallJumpX, "p_wallJumpX", "95", 0 },
    { &p_maxSpeed, "p_maxSpeed", "170", 0 },
    { &p_terminalVelocity, "p_terminalVelocity", "230", 0 },
    { &p_speedJumpBonus, "p_speedJumpBonus", "35", 0 },
    { &p_airAccel, "p_airAccel", "190", 0 },
    { &p_turnAirAccel, "p_turnAirAccel", "325", 0 },
    { &p_accel, "p_accel", "175", 0 },
    { &p_skidAccel, "p_skidAccel", "420", 0 },
    { &p_groundFriction, "p_groundFriction", "300", 0 },
    { &p_airFriction, "p_airFriction", "100", 0 },
};

static int gameCvarTableSize = sizeof( gameCvarTable ) / sizeof( gameCvarTable[0] );

void RegisterGameCvars( void ) {
    cvarTable_t *cv;
    int i;
	for ( i = 0, cv = gameCvarTable ; i < gameCvarTableSize ; i++, cv++ ) {
        *cv->cvar = Cvar_Get(cv->cvarName, cv->defaultString, cv->cvarFlags);
    }

}