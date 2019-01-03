#pragma once
#include "../game/shared.h"

void SubmitRenderCommands(renderCommandList_t *list);
void DrawImage(float x, float y, float w, float h, float ox, float oy, float alpha, float scale, byte flipBits, unsigned int handle, int imgW, int imgH);

extern byte currentColor[4];
extern int currentAlign;
extern float currentLineHeight;