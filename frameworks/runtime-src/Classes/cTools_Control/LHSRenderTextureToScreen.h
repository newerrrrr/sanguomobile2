#ifndef __LHSRENDERTEXTURETOSCREEN_H__
#define __LHSRENDERTEXTURETOSCREEN_H__

#include "cocos2d.h"


class LHSRenderTextureToScreen : public cocos2d::Node
{
public:
	LHSRenderTextureToScreen();
	~LHSRenderTextureToScreen();

	static LHSRenderTextureToScreen * create(cocos2d::RenderTexture * rt);

	virtual bool initWithRenderTexture(cocos2d::RenderTexture * rt);

	virtual void setContentSize(const cocos2d::Size& contentSize)override final;

	virtual void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags)override final;

	virtual void onDraw(const cocos2d::Mat4 &transform, uint32_t flags);

public:
	void setFlippedY(bool flippedY);

protected:
	cocos2d::CustomCommand _customCommand;
	cocos2d::Texture2D * _texture;
	GLfloat _vVertices[12];
	GLfloat _fvTexture[8];
};



#endif //__LHSRENDERTEXTURETOSCREEN_H__