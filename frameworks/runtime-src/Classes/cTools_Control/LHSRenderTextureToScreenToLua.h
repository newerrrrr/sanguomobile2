#ifndef __LHSRENDERTEXTURETOSCREENTOLUA_H__
#define __LHSRENDERTEXTURETOSCREENTOLUA_H__

#include "cocos2d.h"
#include "LHSRenderTextureToScreen.h"

class LHSRenderTextureToScreenToLua : public LHSRenderTextureToScreen
{
public:
	LHSRenderTextureToScreenToLua();
	~LHSRenderTextureToScreenToLua();

	static LHSRenderTextureToScreenToLua * create(cocos2d::RenderTexture * rt);

	virtual void onDraw(const cocos2d::Mat4 &transform, uint32_t flags)override;

public:
	void registerScriptDrawHandler(int handler);

	void unregisterScriptDrawHandler(void);

private:
	int _drawHandler;
};



#endif //__LHSRENDERTEXTURETOSCREENTOLUA_H__