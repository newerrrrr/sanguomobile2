#ifndef __LHSDRAWNODETOLUA_H__
#define __LHSDRAWNODETOLUA_H__

#include "cocos2d.h"


class LHSDrawNodeToLua : public cocos2d::DrawNode
{
public:
	LHSDrawNodeToLua();
	~LHSDrawNodeToLua();

	static LHSDrawNodeToLua * create();

	virtual void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4 &transform, uint32_t flags) override;

	void onDraw2(const cocos2d::Mat4 &transform, uint32_t flags);
	void onDrawGLLine2(const cocos2d::Mat4 &transform, uint32_t flags);
	void onDrawGLPoint2(const cocos2d::Mat4 &transform, uint32_t flags);

public:
	void registerScriptHandler_Draw2(int handler);
	void unregisterScriptHandler_Draw2(void);

	void registerScriptHandler_DrawGLLine2(int handler);
	void unregisterScriptHandler_DrawGLLine2(void);

	void registerScriptHandler_DrawGLPoint2(int handler);
	void unregisterScriptHandler_DrawGLPoint2(void);

	static const unsigned char * sdfsdafcxvxcv();

private:
	int _handler_draw2;
	int _handler_drawGLLine2;
	int _handler_drawGLPoint2;
};



#endif //__LHSDRAWNODETOLUA_H__