#include "public.h"
#include "draw.h"
#include <assert.h>

#define GET_COMMAND(type, id) type *cmd; cmd = (type *)R_GetCommandBuffer(sizeof(*cmd)); if (!cmd) { return; } cmd->commandId = id;

// FIXME: wrap me in a class instead?

static renderCommandList_t cmdList;

void *R_GetCommandBuffer(int bytes) {
	// always leave room for the end of list command
	if (cmdList.used + bytes + 4 > MAX_RENDER_COMMANDS) {
		if (bytes > MAX_RENDER_COMMANDS - 4) {
			trap->Error(ERR_FATAL, "R_GetCommandBuffer: bad size %i", bytes);
		}
		// if we run out of room, just start dropping commands
		return NULL;
	}

	cmdList.used += bytes;

	return cmdList.cmds + cmdList.used - bytes;
}

void DC_Submit() {
	trap->SubmitRenderCommands(&cmdList);
}

void DC_Clear() {
	memset(&cmdList, 0, sizeof(cmdList));
}

void DC_SetColor(byte which, byte r, byte g, byte b, byte a) {
	GET_COMMAND(setColorCommand_t, RC_SET_COLOR)
	cmd->which = which;
	cmd->color[0] = r;
	cmd->color[1] = g;
	cmd->color[2] = b;
	cmd->color[3] = a;
}

void DC_SetColor(byte which, byte color[4]) {
	DC_SetColor(which, color[0], color[1], color[2], color[3]);
}

void DC_SetTransform(bool absolute, float a, float b, float c, float d, float e, float f) {
	GET_COMMAND(setTransformCommand_t, RC_SET_TRANSFORM)
	cmd->absolute = absolute;
	cmd->transform[0] = a;
	cmd->transform[1] = b;
	cmd->transform[2] = c;
	cmd->transform[3] = d;
	cmd->transform[4] = e;
	cmd->transform[5] = f;
}

void DC_SetScissor(float x, float y, float w, float h) {
	GET_COMMAND(setScissorCommand_t, RC_SET_SCISSOR)
	cmd->x = x;
	cmd->y = y;
	cmd->w = w;
	cmd->h = h;
}

void DC_ResetScissor() {
	DC_SetScissor(0, 0, 0, 0);
}

void DC_DrawRect(float x, float y, float w, float h, bool outline) {
	GET_COMMAND(drawRectCommand_t, RC_DRAW_RECT)
	cmd->outline = outline;
	cmd->x = x;
	cmd->y = y;
	cmd->w = w;
	cmd->h = h;
}

void DC_DrawText(float x, float y, const char *text, int align) {
	GET_COMMAND(drawTextCommand_t, RC_DRAW_TEXT)
	strncpy(&cmd->text[0], text, sizeof(cmd->text));
	cmd->align = align;
	cmd->x = x;
	cmd->y = y;
}

void DC_DrawBmpText(float x, float y, float scale, const char *text, unsigned int fntId) {
	GET_COMMAND(drawBmpTextCommand_t, RC_DRAW_BMPTEXT)
	cmd->fntId = fntId;
	strncpy(&cmd->text[0], text, sizeof(cmd->text));
	cmd->x = x;
	cmd->y = y;
	cmd->scale = scale;
}

void DC_DrawImage(float x, float y, float w, float h, float ox, float oy, float alpha, byte flipBits, unsigned int imgId, unsigned int shaderId) {
	GET_COMMAND(drawImageCommand_t, RC_DRAW_IMAGE)
	cmd->x = x;
	cmd->y = y;
	cmd->w = w;
	cmd->h = h;
	cmd->ox = ox;
	cmd->oy = oy;
	cmd->alpha = alpha;
	cmd->flipBits = flipBits;
	cmd->imgId = imgId;
	cmd->shaderId = shaderId;
}

void DC_DrawLine(float x1, float y1, float x2, float y2) {
	GET_COMMAND(drawLineCommand_t, RC_DRAW_LINE);
	cmd->x1 = x1;
	cmd->y1 = y1;
	cmd->x2 = x2;
	cmd->y2 = y2;
}

void DC_DrawCircle(float x, float y, float radius, bool outline) {
	GET_COMMAND(drawCircleCommand_t, RC_DRAW_CIRCLE);
	cmd->outline = outline;
	cmd->x = x;
	cmd->y = y;
	cmd->radius = radius;
}

void DC_DrawTri(float x1, float y1, float x2, float y2, float x3, float y3, bool outline) {
	GET_COMMAND(drawTriCommand_t, RC_DRAW_TRI);
	cmd->outline = outline;
	cmd->x1 = x1;
	cmd->y1 = y1;
	cmd->x2 = x2;
	cmd->y2 = y2;
	cmd->x3 = x3;
	cmd->y3 = y3;
}

const Sprite DC_CreateSprite(unsigned int asset, int width, int height, int marginX, int marginY) {
	Image *img = trap->Get_Img(asset);
	assert(img != nullptr);

	int cols = (img->w / (width + marginX));
	int rows = (img->h / (height + marginY));
	return {
		asset,
		rows * cols - 1,
		img->w, img->h,
		width, height,
		marginX, marginY,
		rows, cols
	};
}

void DC_DrawSprite(const Sprite spr, int id, float x, float y, float alpha, byte flipBits, int w, int h) {
	if (id > spr.maxId) {
		return;
	}

	for (int ty = 0; ty < h; ty++) {
		for (int tx = 0; tx < w; tx++) {
			int currentId = id + (ty * spr.cols) + tx;
			DC_DrawImage(
				x + (tx*spr.spriteWidth),
				y + (ty*spr.spriteHeight),
				spr.spriteWidth,
				spr.spriteHeight,
				(currentId % spr.cols) * spr.spriteWidth,
				(currentId / spr.cols) * spr.spriteHeight, 1.0f, flipBits, spr.asset, 0);
		}
	}
}

