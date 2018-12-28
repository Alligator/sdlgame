#include "cvar_main.h"

cvar_t *com_errorMessage;
cvar_t *com_lastErrorStack;
cvar_t *vid_width;
cvar_t *vid_height;
cvar_t *vid_swapinterval;
cvar_t *vid_fullscreen;
cvar_t *vid_showfps;
cvar_t *vid_maxfps;
cvar_t *com_pause;
cvar_t *s_volume;

static cvarTable_t mainCvarTable[] = {
    { &com_errorMessage, "com_errorMessage", "", CVAR_ROM },
	{ &com_lastErrorStack, "com_lastErrorStack", "", CVAR_ROM },
    { &vid_width, "vid_width", "1280", 0 },
    { &vid_height, "vid_height", "720", 0 },
    { &vid_swapinterval, "vid_swapInterval", "1", 0 },
    { &vid_fullscreen, "vid_fullscreen", "0", 0 },
    { &vid_showfps, "vid_showfps", "0", 0 },
	{ &vid_maxfps, "vid_maxfps", "120", 0 },
	{ &com_pause, "com_pause", "0", 0 },
	{ &s_volume, "s_volume", "1.0", 0 },

};

static int mainCvarTableSize = sizeof( mainCvarTable ) / sizeof( mainCvarTable[0] );

void RegisterMainCvars( void ) {
    cvarTable_t *cv;
    int i;
	for ( i = 0, cv = mainCvarTable ; i < mainCvarTableSize ; i++, cv++ ) {
        *cv->cvar = Cvar_Get(cv->cvarName, cv->defaultString, cv->cvarFlags);
    }
}