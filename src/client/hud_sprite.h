typedef struct
{
	string m_strImage;
	vector m_vecSize;
	vector m_vecCanvasSize;
	vector m_vecCanvasPos;
} hlsprite_t;

void HLSprite_Init(void);

void HLSprite_Draw_RGBA(string spriteName, vector spritePos, vector spriteColor, float spriteAlpha, bool isAdditive);

void HLSprite_Draw(string spriteName, vector spritePos, bool isAdditive);

void HLSprite_Draw_A(string spriteName, vector spritePos, float spriteAlpha, bool isAdditive);

void HLSprite_Draw_RGB(string spriteName, vector spritePos, vector spriteColor, bool isAdditive);

void HLSprite_DrawCrosshair(string spriteName);