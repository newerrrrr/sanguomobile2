#ifndef __LHSTMXDATA_H__
#define __LHSTMXDATA_H__

#include "cocos2d.h"
#include "../tiledMap/Tmx.h"

class LHSTmxData
{
	friend class LHSTmxCache;
private:
	LHSTmxData();
	~LHSTmxData();
	bool _initWithTmxFileName(const cocos2d::Data & tmxFileData, const std::string & fullFilename, const std::string & filename);

public:

	int getWidth(){ return _width; };
	int getHeight(){ return _height; };
	int getTileWidth(){ return _tileWidth; };
	int getTileHeight(){ return _tildHeight; };

	//Tmx::Map * getTmxMap(){ return _tmxMap; };

	std::string getTileProperty_globalGid(int gid, const std::string & propertyKey);

	std::string getLayerProperty_layerName(const std::string & name, const std::string & propertyKey);

	const std::vector< Tmx::Layer* > &getLayers() const { return _tmxMap->GetLayers(); };

	cocos2d::SpriteFrame * getSpriteFrame_globalGid(int gid);

	cocos2d::Texture2D * getTexture2D_image(const Tmx::Image * image);

private:
	Tmx::Map * _tmxMap;
	std::map<int, cocos2d::SpriteFrame*> _globalGidToFrameSprite;
	std::map<int, Tmx::Tile*> _globalGidToTile;
	int _width;
	int _height;
	int _tileWidth;
	int _tildHeight;
	std::map<const Tmx::Image*, cocos2d::Texture2D*> _cacheTexture;
};




#endif //__LHSTMXDATA_H__