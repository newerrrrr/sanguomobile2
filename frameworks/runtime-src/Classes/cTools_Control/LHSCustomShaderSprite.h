#ifndef __LHSCUSTOMSHADERSPRITE_H__
#define __LHSCUSTOMSHADERSPRITE_H__

#include "cocos2d.h"


class LHSCustomShaderSprite : public cocos2d::Sprite
{
public:
	LHSCustomShaderSprite();
	~LHSCustomShaderSprite();

	static LHSCustomShaderSprite* create();

	static LHSCustomShaderSprite* create(const std::string& filename);

	static LHSCustomShaderSprite* create(const std::string& filename, const cocos2d::Rect& rect);

	static LHSCustomShaderSprite* createWithTexture(cocos2d::Texture2D *texture);

	static LHSCustomShaderSprite* createWithTexture(cocos2d::Texture2D *texture, const cocos2d::Rect& rect, bool rotated = false);

	static LHSCustomShaderSprite* createWithSpriteFrame(cocos2d::SpriteFrame *spriteFrame);

	static LHSCustomShaderSprite* createWithSpriteFrameName(const std::string& spriteFrameName);

	virtual void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4 &transform, uint32_t flags) override final;

	virtual void onBeforeDraw(cocos2d::GLProgramState * glProgramState);

public:
	void registerScriptBeforeDrawHandler(int handler);
	void unregisterScriptBeforeDrawHandler(void);
private:
	int _beforeDrawHandler;
protected:
	cocos2d::CustomCommand _beforeDrawCommand;
};



#endif //__LHSRENDERTEXTURETOSCREEN_H__