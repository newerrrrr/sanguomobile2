#ifndef __LHSTMXTILELAYER_H__
#define __LHSTMXTILELAYER_H__

#include "cocos2d.h"
#include "../tiledMap/Tmx.h"
#include "LHSTmxBaseLayer.h"


class LHSTmxTileLayer : public cocos2d::Layer, public LHSTmxBaseLayer
{
protected:
	LHSTmxTileLayer(int width, int height, int tileWidth, int tileHeight);
public:
	~LHSTmxTileLayer();

	static LHSTmxTileLayer *create(int width,int height,int tileWidth,int tileHeight);

	virtual bool init()override;

	virtual LHSTmxLayerType getTmxLayerType(){ return kLHSTmxLayerType_TileLayer; };

	virtual void removeChild(Node* child, bool cleanup = true)override;
	virtual void removeChildByTag(int tag, bool cleanup = true)override;
	virtual void removeChildByName(const std::string &name, bool cleanup = true)override;
	virtual void removeAllChildren()override;
	virtual void removeAllChildrenWithCleanup(bool cleanup)override;

	virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)override;

	const LHSParallelogram * getParallelogram()const{ return &_parallelogram; };

	void addEditTile(cocos2d::Node * tile, int tileIndex_x, int tileIndex_y, int gid);

	void addCustomTile(cocos2d::Node * tile, int tileIndex_x, int tileIndex_y, int ZOrder, const char * customName);

	void removeTile(int tileIndex_x, int tileIndex_y, bool cleanup = true);

	void removeTileWithCustomName(const char * customName, bool cleanup = true);

	int getCustomTileCountWithCustomName(const char * customName);

	void removeAllTile(bool cleanup = true);

	int getZOrderWithIndex(const cocos2d::Vec2 & index);

	cocos2d::Vec2 getNodePositionWithIndex(const cocos2d::Vec2 & index);//根据下标获取块原点像素位置

	cocos2d::Vec2 getNodePositionCenterWithIndex(const cocos2d::Vec2 & index);//根据下标获取块中心点像素位置

	cocos2d::Vec2 getIndexWithNodePosition_Rough(cocos2d::Vec2 nodePos);//根据像素位置获取块下标

	CC_DEPRECATED_ATTRIBUTE cocos2d::Vec2 getIndexWithNodePosition(cocos2d::Vec2 nodePos);//根据像素位置获取块下标 低效

	int getGidWithNodePosition(cocos2d::Vec2 nodePos);//根据像素坐标获取gid

	int getGidWithIndex(cocos2d::Vec2 index);//根下标获取gid

	LHSTileData * getTileDataWithNodePosition(cocos2d::Vec2 nodePos);//根据像素坐标获取TileData

	LHSTileData *  getTileDataWithIndex(cocos2d::Vec2 index);//根下标获取TileData

public:
	int getWidth(){ return _width; };
	int getHeight(){ return _height; };
	int getTileWidth(){ return _tileWidth; };
	int getTileHeight(){ return _tileHeight; };


public:
	void setVisibleOperat(bool isOpen, cocos2d::Size offsetSize = cocos2d::Size::ZERO);

private:
	void _freeTile(LHSTileData ** tile, bool cleanup = true);

private:
	LHSParallelogram _parallelogram;

	LHSTileData ** _Tiles;
	std::map < cocos2d::Node* , cocos2d::Vec2> _showTiles_nodeKey;
	std::map < std::string , std::vector<cocos2d::Vec2> > _showTiles_customNameKey;

	const int _width;
	const int _height;
	const int _tileWidth;
	const int _tileHeight;
	const int _tileWidthHalf;
	const int _tileHeightHalf;

private:
	bool _isVisibleOperat;
	cocos2d::Size _offsetSizeVO;
};


#endif //__LHSTMXTILELAYER_H__