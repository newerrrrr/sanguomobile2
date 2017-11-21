#ifndef __LHSTMXLAYER_H__
#define __LHSTMXLAYER_H__

#include "cocos2d.h"
#include "LHSTmxData.h"
#include "LHSTmxImageLayer.h"
#include "LHSTmxTileLayer.h"


#define TMX_USE_CUSTOM_TILE_NAME		1


class LHSTmxLayer : public cocos2d::Layer
{
public:
	LHSTmxLayer(const char * tmxName);
	~LHSTmxLayer();

	static LHSTmxLayer * create(const char * tmxFilename);

	virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)override;

	const LHSParallelogram * getParallelogram()const{ return &_parallelogram; };

	int getWidth(){ return _width; };
	int getHeight(){ return _height; };
	int getTileWidth(){ return _tileWidth; };
	int getTileHeight(){ return _tileHeight; };

public:
	void setVisibleOperat(bool isOpen, cocos2d::Size offsetSize = cocos2d::Size::ZERO);

protected:
	bool _initWithTmxData(LHSTmxData * tmxData);

private:
	const std::string _tmxName;
	LHSParallelogram _parallelogram;
	int _width;
	int _height;
	int _tileWidth;
	int _tileHeight;
	int _tileWidthHalf;
	int _tileHeightHalf;

	bool _isVisibleOperat;
	cocos2d::Size _offsetSizeVO;
};




#endif //__LHSTMXLAYER_H__