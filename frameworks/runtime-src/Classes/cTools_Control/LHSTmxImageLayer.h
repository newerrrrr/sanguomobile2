#ifndef __LHSTMXIMAGELAYER_H__
#define __LHSTMXIMAGELAYER_H__

#include "cocos2d.h"
#include "../tiledMap/Tmx.h"
#include "LHSTmxBaseLayer.h"

class LHSTmxImageLayer : public cocos2d::Sprite , public LHSTmxBaseLayer
{
public:
	LHSTmxImageLayer();
	~LHSTmxImageLayer();

	static LHSTmxImageLayer* create();

	static LHSTmxImageLayer* createWithTexture(cocos2d::Texture2D *texture);

	virtual LHSTmxLayerType getTmxLayerType(){ return kLHSTmxLayerType_ImageLayer; };

	virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)override;


public:
	void setVisibleOperat(bool isOpen, cocos2d::Size offsetSize = cocos2d::Size::ZERO);

private:
	bool _isVisibleOperat;
	cocos2d::Size _offsetSizeVO;
};


#endif //__LHSTMXIMAGELAYER_H__