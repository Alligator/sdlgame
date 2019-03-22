// note: using c99 designated initializers for cleaner code here. this is in a separate .c file
// because clang will allow c99 in c++ compilation, but msvc won't
#include <SDL/SDL.h>
#include "keys.h"

#define PADBASE(i) (CONTROLLER_KEY_START + SDL_CONTROLLER_BUTTON_MAX * (i - 1))
#define GAMEPAD(i) \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_A] = "PAD" #i "_A", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_B] = "PAD" #i "_B", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_X] = "PAD" #i "_X", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_Y] = "PAD" #i "_Y", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_BACK] = "PAD" #i "_BACK", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_GUIDE] = "PAD" #i "_GUIDE", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_START] = "PAD" #i "_START", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_LEFTSTICK] = "PAD" #i "_L3", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_RIGHTSTICK] = "PAD" #i "_R3", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_LEFTSHOULDER] = "PAD" #i "_L1", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_RIGHTSHOULDER] = "PAD" #i "_R1", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_DPAD_UP] = "PAD" #i "_UP", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_DPAD_DOWN] = "PAD" #i "_DOWN", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_DPAD_LEFT] = "PAD" #i "_LEFT", \
	[PADBASE(i) + SDL_CONTROLLER_BUTTON_DPAD_RIGHT] = "PAD" #i "_RIGHT",

const char * keys[MAX_KEYS] = {
	GAMEPAD(1)
	GAMEPAD(2)
	GAMEPAD(3)
	GAMEPAD(4)
	[SDL_NUM_SCANCODES + SDL_BUTTON_LEFT] = "MOUSE1",
	[SDL_NUM_SCANCODES + SDL_BUTTON_RIGHT] = "MOUSE2",
	[SDL_NUM_SCANCODES + SDL_BUTTON_MIDDLE] = "MOUSE3",
	[SDL_NUM_SCANCODES + SDL_BUTTON_X1] = "MOUSE4",
	[SDL_NUM_SCANCODES + SDL_BUTTON_X2] = "MOUSE5",
	[SDL_SCANCODE_UNKNOWN] = "<UNKNOWN>",
	[SDL_SCANCODE_A] = "A",
	[SDL_SCANCODE_B] = "B",
	[SDL_SCANCODE_C] = "C",
	[SDL_SCANCODE_D] = "D",
	[SDL_SCANCODE_E] = "E",
	[SDL_SCANCODE_F] = "F",
	[SDL_SCANCODE_G] = "G",
	[SDL_SCANCODE_H] = "H",
	[SDL_SCANCODE_I] = "I",
	[SDL_SCANCODE_J] = "J",
	[SDL_SCANCODE_K] = "K",
	[SDL_SCANCODE_L] = "L",
	[SDL_SCANCODE_M] = "M",
	[SDL_SCANCODE_N] = "N",
	[SDL_SCANCODE_O] = "O",
	[SDL_SCANCODE_P] = "P",
	[SDL_SCANCODE_Q] = "Q",
	[SDL_SCANCODE_R] = "R",
	[SDL_SCANCODE_S] = "S",
	[SDL_SCANCODE_T] = "T",
	[SDL_SCANCODE_U] = "U",
	[SDL_SCANCODE_V] = "V",
	[SDL_SCANCODE_W] = "W",
	[SDL_SCANCODE_X] = "X",
	[SDL_SCANCODE_Y] = "Y",
	[SDL_SCANCODE_Z] = "Z",
	[SDL_SCANCODE_1] = "1",
	[SDL_SCANCODE_2] = "2",
	[SDL_SCANCODE_3] = "3",
	[SDL_SCANCODE_4] = "4",
	[SDL_SCANCODE_5] = "5",
	[SDL_SCANCODE_6] = "6",
	[SDL_SCANCODE_7] = "7",
	[SDL_SCANCODE_8] = "8",
	[SDL_SCANCODE_9] = "9",
	[SDL_SCANCODE_0] = "0",
	[SDL_SCANCODE_RETURN] = "RETURN",
	[SDL_SCANCODE_ESCAPE] = "ESCAPE",
	[SDL_SCANCODE_BACKSPACE] = "BACKSPACE",
	[SDL_SCANCODE_TAB] = "TAB",
	[SDL_SCANCODE_SPACE] = "SPACE",
	[SDL_SCANCODE_MINUS] = "MINUS",
	[SDL_SCANCODE_EQUALS] = "EQUALS",
	[SDL_SCANCODE_LEFTBRACKET] = "LEFTBRACKET",
	[SDL_SCANCODE_RIGHTBRACKET] = "RIGHTBRACKET",
	[SDL_SCANCODE_BACKSLASH] = "BACKSLASH",
	[SDL_SCANCODE_NONUSHASH] = "NONUSHASH",
	[SDL_SCANCODE_SEMICOLON] = "SEMICOLON",
	[SDL_SCANCODE_APOSTROPHE] = "APOSTROPHE",
	[SDL_SCANCODE_GRAVE] = "GRAVE",
	[SDL_SCANCODE_COMMA] = "COMMA",
	[SDL_SCANCODE_PERIOD] = "PERIOD",
	[SDL_SCANCODE_SLASH] = "SLASH",
	[SDL_SCANCODE_CAPSLOCK] = "CAPSLOCK",
	[SDL_SCANCODE_F1] = "F1",
	[SDL_SCANCODE_F2] = "F2",
	[SDL_SCANCODE_F3] = "F3",
	[SDL_SCANCODE_F4] = "F4",
	[SDL_SCANCODE_F5] = "F5",
	[SDL_SCANCODE_F6] = "F6",
	[SDL_SCANCODE_F7] = "F7",
	[SDL_SCANCODE_F8] = "F8",
	[SDL_SCANCODE_F9] = "F9",
	[SDL_SCANCODE_F10] = "F10",
	[SDL_SCANCODE_F11] = "F11",
	[SDL_SCANCODE_F12] = "F12",
	[SDL_SCANCODE_PRINTSCREEN] = "PRINTSCREEN",
	[SDL_SCANCODE_SCROLLLOCK] = "SCROLLLOCK",
	[SDL_SCANCODE_PAUSE] = "PAUSE",
	[SDL_SCANCODE_INSERT] = "INSERT",
	[SDL_SCANCODE_HOME] = "HOME",
	[SDL_SCANCODE_PAGEUP] = "PAGEUP",
	[SDL_SCANCODE_DELETE] = "DELETE",
	[SDL_SCANCODE_END] = "END",
	[SDL_SCANCODE_PAGEDOWN] = "PAGEDOWN",
	[SDL_SCANCODE_RIGHT] = "RIGHTARROW",
	[SDL_SCANCODE_LEFT] = "LEFTARROW",
	[SDL_SCANCODE_DOWN] = "DOWNARROW",
	[SDL_SCANCODE_UP] = "UPARROW",
	[SDL_SCANCODE_NUMLOCKCLEAR] = "NUMLOCKCLEAR",
	[SDL_SCANCODE_KP_DIVIDE] = "KP_DIVIDE",
	[SDL_SCANCODE_KP_MULTIPLY] = "KP_MULTIPLY",
	[SDL_SCANCODE_KP_MINUS] = "KP_MINUS",
	[SDL_SCANCODE_KP_PLUS] = "KP_PLUS",
	[SDL_SCANCODE_KP_ENTER] = "KP_ENTER",
	[SDL_SCANCODE_KP_1] = "KP_1",
	[SDL_SCANCODE_KP_2] = "KP_2",
	[SDL_SCANCODE_KP_3] = "KP_3",
	[SDL_SCANCODE_KP_4] = "KP_4",
	[SDL_SCANCODE_KP_5] = "KP_5",
	[SDL_SCANCODE_KP_6] = "KP_6",
	[SDL_SCANCODE_KP_7] = "KP_7",
	[SDL_SCANCODE_KP_8] = "KP_8",
	[SDL_SCANCODE_KP_9] = "KP_9",
	[SDL_SCANCODE_KP_0] = "KP_0",
	[SDL_SCANCODE_KP_PERIOD] = "KP_PERIOD",
	[SDL_SCANCODE_NONUSBACKSLASH] = "NONUSBACKSLASH",
	[SDL_SCANCODE_APPLICATION] = "APPLICATION",
	[SDL_SCANCODE_POWER] = "POWER",
	[SDL_SCANCODE_KP_EQUALS] = "KP_EQUALS",
	[SDL_SCANCODE_F13] = "F13",
	[SDL_SCANCODE_F14] = "F14",
	[SDL_SCANCODE_F15] = "F15",
	[SDL_SCANCODE_F16] = "F16",
	[SDL_SCANCODE_F17] = "F17",
	[SDL_SCANCODE_F18] = "F18",
	[SDL_SCANCODE_F19] = "F19",
	[SDL_SCANCODE_F20] = "F20",
	[SDL_SCANCODE_F21] = "F21",
	[SDL_SCANCODE_F22] = "F22",
	[SDL_SCANCODE_F23] = "F23",
	[SDL_SCANCODE_F24] = "F24",
	[SDL_SCANCODE_EXECUTE] = "EXECUTE",
	[SDL_SCANCODE_HELP] = "HELP",
	[SDL_SCANCODE_MENU] = "MENU",
	[SDL_SCANCODE_SELECT] = "SELECT",
	[SDL_SCANCODE_STOP] = "STOP",
	[SDL_SCANCODE_AGAIN] = "AGAIN",
	[SDL_SCANCODE_UNDO] = "UNDO",
	[SDL_SCANCODE_CUT] = "CUT",
	[SDL_SCANCODE_COPY] = "COPY",
	[SDL_SCANCODE_PASTE] = "PASTE",
	[SDL_SCANCODE_FIND] = "FIND",
	[SDL_SCANCODE_MUTE] = "MUTE",
	[SDL_SCANCODE_VOLUMEUP] = "VOLUMEUP",
	[SDL_SCANCODE_VOLUMEDOWN] = "VOLUMEDOWN",
	[SDL_SCANCODE_KP_COMMA] = "KP_COMMA",
	[SDL_SCANCODE_KP_EQUALSAS400] = "KP_EQUALSAS400",
	[SDL_SCANCODE_INTERNATIONAL1] = "INTERNATIONAL1",
	[SDL_SCANCODE_INTERNATIONAL2] = "INTERNATIONAL2",
	[SDL_SCANCODE_INTERNATIONAL3] = "INTERNATIONAL3",
	[SDL_SCANCODE_INTERNATIONAL4] = "INTERNATIONAL4",
	[SDL_SCANCODE_INTERNATIONAL5] = "INTERNATIONAL5",
	[SDL_SCANCODE_INTERNATIONAL6] = "INTERNATIONAL6",
	[SDL_SCANCODE_INTERNATIONAL7] = "INTERNATIONAL7",
	[SDL_SCANCODE_INTERNATIONAL8] = "INTERNATIONAL8",
	[SDL_SCANCODE_INTERNATIONAL9] = "INTERNATIONAL9",
	[SDL_SCANCODE_LANG1] = "LANG1",
	[SDL_SCANCODE_LANG2] = "LANG2",
	[SDL_SCANCODE_LANG3] = "LANG3",
	[SDL_SCANCODE_LANG4] = "LANG4",
	[SDL_SCANCODE_LANG5] = "LANG5",
	[SDL_SCANCODE_LANG6] = "LANG6",
	[SDL_SCANCODE_LANG7] = "LANG7",
	[SDL_SCANCODE_LANG8] = "LANG8",
	[SDL_SCANCODE_LANG9] = "LANG9",
	[SDL_SCANCODE_ALTERASE] = "ALTERASE",
	[SDL_SCANCODE_SYSREQ] = "SYSREQ",
	[SDL_SCANCODE_CANCEL] = "CANCEL",
	[SDL_SCANCODE_CLEAR] = "CLEAR",
	[SDL_SCANCODE_PRIOR] = "PRIOR",
	[SDL_SCANCODE_RETURN2] = "RETURN2",
	[SDL_SCANCODE_SEPARATOR] = "SEPARATOR",
	[SDL_SCANCODE_OUT] = "OUT",
	[SDL_SCANCODE_OPER] = "OPER",
	[SDL_SCANCODE_CLEARAGAIN] = "CLEARAGAIN",
	[SDL_SCANCODE_CRSEL] = "CRSEL",
	[SDL_SCANCODE_EXSEL] = "EXSEL",
	[SDL_SCANCODE_KP_00] = "KP_00",
	[SDL_SCANCODE_KP_000] = "KP_000",
	[SDL_SCANCODE_THOUSANDSSEPARATOR] = "THOUSANDSSEPARATOR",
	[SDL_SCANCODE_DECIMALSEPARATOR] = "DECIMALSEPARATOR",
	[SDL_SCANCODE_CURRENCYUNIT] = "CURRENCYUNIT",
	[SDL_SCANCODE_CURRENCYSUBUNIT] = "CURRENCYSUBUNIT",
	[SDL_SCANCODE_KP_LEFTPAREN] = "KP_LEFTPAREN",
	[SDL_SCANCODE_KP_RIGHTPAREN] = "KP_RIGHTPAREN",
	[SDL_SCANCODE_KP_LEFTBRACE] = "KP_LEFTBRACE",
	[SDL_SCANCODE_KP_RIGHTBRACE] = "KP_RIGHTBRACE",
	[SDL_SCANCODE_KP_TAB] = "KP_TAB",
	[SDL_SCANCODE_KP_BACKSPACE] = "KP_BACKSPACE",
	[SDL_SCANCODE_KP_A] = "KP_A",
	[SDL_SCANCODE_KP_B] = "KP_B",
	[SDL_SCANCODE_KP_C] = "KP_C",
	[SDL_SCANCODE_KP_D] = "KP_D",
	[SDL_SCANCODE_KP_E] = "KP_E",
	[SDL_SCANCODE_KP_F] = "KP_F",
	[SDL_SCANCODE_KP_XOR] = "KP_XOR",
	[SDL_SCANCODE_KP_POWER] = "KP_POWER",
	[SDL_SCANCODE_KP_PERCENT] = "KP_PERCENT",
	[SDL_SCANCODE_KP_LESS] = "KP_LESS",
	[SDL_SCANCODE_KP_GREATER] = "KP_GREATER",
	[SDL_SCANCODE_KP_AMPERSAND] = "KP_AMPERSAND",
	[SDL_SCANCODE_KP_DBLAMPERSAND] = "KP_DBLAMPERSAND",
	[SDL_SCANCODE_KP_VERTICALBAR] = "KP_VERTICALBAR",
	[SDL_SCANCODE_KP_DBLVERTICALBAR] = "KP_DBLVERTICALBAR",
	[SDL_SCANCODE_KP_COLON] = "KP_COLON",
	[SDL_SCANCODE_KP_HASH] = "KP_HASH",
	[SDL_SCANCODE_KP_SPACE] = "KP_SPACE",
	[SDL_SCANCODE_KP_AT] = "KP_AT",
	[SDL_SCANCODE_KP_EXCLAM] = "KP_EXCLAM",
	[SDL_SCANCODE_KP_MEMSTORE] = "KP_MEMSTORE",
	[SDL_SCANCODE_KP_MEMRECALL] = "KP_MEMRECALL",
	[SDL_SCANCODE_KP_MEMCLEAR] = "KP_MEMCLEAR",
	[SDL_SCANCODE_KP_MEMADD] = "KP_MEMADD",
	[SDL_SCANCODE_KP_MEMSUBTRACT] = "KP_MEMSUBTRACT",
	[SDL_SCANCODE_KP_MEMMULTIPLY] = "KP_MEMMULTIPLY",
	[SDL_SCANCODE_KP_MEMDIVIDE] = "KP_MEMDIVIDE",
	[SDL_SCANCODE_KP_PLUSMINUS] = "KP_PLUSMINUS",
	[SDL_SCANCODE_KP_CLEAR] = "KP_CLEAR",
	[SDL_SCANCODE_KP_CLEARENTRY] = "KP_CLEARENTRY",
	[SDL_SCANCODE_KP_BINARY] = "KP_BINARY",
	[SDL_SCANCODE_KP_OCTAL] = "KP_OCTAL",
	[SDL_SCANCODE_KP_DECIMAL] = "KP_DECIMAL",
	[SDL_SCANCODE_KP_HEXADECIMAL] = "KP_HEXADECIMAL",
	[SDL_SCANCODE_LCTRL] = "LCTRL",
	[SDL_SCANCODE_LSHIFT] = "LSHIFT",
	[SDL_SCANCODE_LALT] = "LALT",
	[SDL_SCANCODE_LGUI] = "LGUI",
	[SDL_SCANCODE_RCTRL] = "RCTRL",
	[SDL_SCANCODE_RSHIFT] = "RSHIFT",
	[SDL_SCANCODE_RALT] = "RALT",
	[SDL_SCANCODE_RGUI] = "RGUI",
	[SDL_SCANCODE_MODE] = "MODE",
	[SDL_SCANCODE_AUDIONEXT] = "AUDIONEXT",
	[SDL_SCANCODE_AUDIOPREV] = "AUDIOPREV",
	[SDL_SCANCODE_AUDIOSTOP] = "AUDIOSTOP",
	[SDL_SCANCODE_AUDIOPLAY] = "AUDIOPLAY",
	[SDL_SCANCODE_AUDIOMUTE] = "AUDIOMUTE",
	[SDL_SCANCODE_MEDIASELECT] = "MEDIASELECT",
	[SDL_SCANCODE_WWW] = "WWW",
	[SDL_SCANCODE_MAIL] = "MAIL",
	[SDL_SCANCODE_CALCULATOR] = "CALCULATOR",
	[SDL_SCANCODE_COMPUTER] = "COMPUTER",
	[SDL_SCANCODE_AC_SEARCH] = "AC_SEARCH",
	[SDL_SCANCODE_AC_HOME] = "AC_HOME",
	[SDL_SCANCODE_AC_BACK] = "AC_BACK",
	[SDL_SCANCODE_AC_FORWARD] = "AC_FORWARD",
	[SDL_SCANCODE_AC_STOP] = "AC_STOP",
	[SDL_SCANCODE_AC_REFRESH] = "AC_REFRESH",
	[SDL_SCANCODE_AC_BOOKMARKS] = "AC_BOOKMARKS",
	[SDL_SCANCODE_BRIGHTNESSDOWN] = "BRIGHTNESSDOWN",
	[SDL_SCANCODE_BRIGHTNESSUP] = "BRIGHTNESSUP",
	[SDL_SCANCODE_DISPLAYSWITCH] = "DISPLAYSWITCH",
	[SDL_SCANCODE_KBDILLUMTOGGLE] = "KBDILLUMTOGGLE",
	[SDL_SCANCODE_KBDILLUMDOWN] = "KBDILLUMDOWN",
	[SDL_SCANCODE_KBDILLUMUP] = "KBDILLUMUP",
	[SDL_SCANCODE_EJECT] = "EJECT",
	[SDL_SCANCODE_SLEEP] = "SLEEP",
	[SDL_SCANCODE_APP1] = "APP1",
	[SDL_SCANCODE_APP2] = "APP2",
	[SDL_SCANCODE_AUDIOREWIND] = "AUDIOREWIND",
	[SDL_SCANCODE_AUDIOFASTFORWARD] = "AUDIOFASTFORWARD",
};