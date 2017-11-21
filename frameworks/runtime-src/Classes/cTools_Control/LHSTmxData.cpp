#include "LHSTmxData.h"

USING_NS_CC;

LHSTmxData::LHSTmxData()
	:_tmxMap(nullptr)
	, _width(0)
	, _height(0)
	, _tileWidth(0)
	, _tildHeight(0)
{

}


LHSTmxData::~LHSTmxData()
{
	for (auto it = _cacheTexture.begin(); it != _cacheTexture.end();it++)
		it->second->release();
	_cacheTexture.clear();

	for (auto it = _globalGidToFrameSprite.begin(); it != _globalGidToFrameSprite.end(); it++)
		it->second->release();
	_globalGidToFrameSprite.clear();

	CC_SAFE_DELETE(_tmxMap);
}


bool LHSTmxData::_initWithTmxFileName(const cocos2d::Data & tmxFileData, const std::string & fullFilename, const std::string & filename)
{
	bool ret = false;
	do
	{
		_tmxMap = new (std::nothrow) Tmx::Map();
		CC_BREAK_IF(!_tmxMap);
		_tmxMap->ParseText(std::string((char*)(tmxFileData.getBytes()), tmxFileData.getSize()));

		Tmx::MapOrientation orientation = _tmxMap->GetOrientation();
		CCAssert(orientation == Tmx::TMX_MO_ISOMETRIC, "only support 45 degrees map"); //暂时只支持45度地图
		CC_BREAK_IF(orientation != Tmx::TMX_MO_ISOMETRIC);

		_width = _tmxMap->GetWidth();
		_height = _tmxMap->GetHeight();
		_tileWidth = _tmxMap->GetTileWidth();
		_tildHeight = _tmxMap->GetTileHeight();

		TextureCache * textureCache = Director::getInstance()->getTextureCache();

		for (int i = 0; i < _tmxMap->GetNumTilesets(); i++)	//图块资源部分
		{
			const Tmx::Tileset *tileset = _tmxMap->GetTileset(i);

			const Tmx::Image* image = tileset->GetImage();
			std::string sourceName = tileset->GetImage()->GetSource();

			std::string sourcePath = sourceName;
			Texture2D * texture = nullptr;

			if (filename.find_last_of("/") != filename.npos)
			{
				std::string dir = filename.substr(0, filename.find_last_of("/") + 1);
				sourcePath = dir + sourcePath;
			}

			texture = textureCache->addImage(sourcePath);

			if (texture == nullptr)
			{
				sourcePath = sourceName;
				if (fullFilename.find_last_of("/") != fullFilename.npos)
				{
					std::string dir = fullFilename.substr(0, fullFilename.find_last_of("/") + 1);
					sourcePath = dir + sourcePath;
				}
				texture = textureCache->addImage(sourcePath);
			}

			CCAssert(texture, "error : not found texture");
			CC_BREAK_IF(!texture);
			texture->retain();//预防被removeUnusedTextures给误删除
			_cacheTexture.insert(std::pair<const Tmx::Image*, cocos2d::Texture2D*>(image, texture));

			int firstGid = tileset->GetFirstGid();
			int margin = tileset->GetMargin();
			int spacing = tileset->GetSpacing();
			int w_t = tileset->GetImage()->GetWidth();
			int h_t = tileset->GetImage()->GetHeight();
			int w_c = tileset->GetTileWidth();
			int h_c = tileset->GetTileHeight();

			int x_c = (w_t - margin + spacing) / (w_c + spacing);
			int y_c = (h_t - margin + spacing) / (h_c + spacing);

			for (int y = 0; y < y_c; y++)
			{
				for (int x = 0; x < x_c; x++)
				{
					float l = margin + x * spacing + x * w_c;
					float t = margin + y * spacing + y * h_c;
					SpriteFrame * sf = SpriteFrame::createWithTexture(texture, Rect(Vec2(l, t), Size(w_c, h_c)));
					sf->retain();
					_globalGidToFrameSprite.insert(std::pair<int, SpriteFrame*>(y * x_c + x + firstGid, sf));
				}
			}

			const std::vector< Tmx::Tile *> vec = tileset->GetTiles();
			for (auto it = vec.begin(); it != vec.end(); it++)
				_globalGidToTile.insert(std::pair<int, Tmx::Tile*>((*it)->GetId() + firstGid, *it));//图块属性也保留一下
		}


		for (int i = 0; i < _tmxMap->GetNumLayers(); i++)	//层数据部分
		{
			const Tmx::Layer * layer = _tmxMap->GetLayer(i);

			switch (layer->GetLayerType())
			{
			case Tmx::TMX_LAYERTYPE_TILE:
			{
				const Tmx::TileLayer * tileLayer = dynamic_cast<const Tmx::TileLayer*>(layer);
			}
				break;
			case Tmx::TMX_LAYERTYPE_IMAGE_LAYER:
			{
				const Tmx::ImageLayer * imageLayer = dynamic_cast<const Tmx::ImageLayer*>(layer);
				const Tmx::Image * image = imageLayer->GetImage();
				if (image) //可能没图
				{
					std::string sourceName = image->GetSource();

					std::string sourcePath = sourceName;
					Texture2D * texture = nullptr;

					if (filename.find_last_of("/") != filename.npos)
					{
						std::string dir = filename.substr(0, filename.find_last_of("/") + 1);
						sourcePath = dir + sourcePath;
					}

					texture = textureCache->addImage(sourcePath);

					if (texture == nullptr)
					{
						sourcePath = sourceName;
						if (fullFilename.find_last_of("/") != fullFilename.npos)
						{
							std::string dir = fullFilename.substr(0, fullFilename.find_last_of("/") + 1);
							sourcePath = dir + sourcePath;
						}
						texture = textureCache->addImage(sourcePath);
					}

					CCAssert(texture, "error : not found texture");

					if (texture)
					{
						texture->retain();//预防被removeUnusedTextures给误删除
						_cacheTexture.insert(std::pair<const Tmx::Image*, cocos2d::Texture2D*>(image, texture));
					}
				}
			}
				break;
			case Tmx::TMX_LAYERTYPE_OBJECTGROUP://暂时不支持对象层
			default:
				CCAssert(false, "error : not support");
				break;
			}
		}


		ret = true;
	} while (false);
	return ret;
}

std::string LHSTmxData::getTileProperty_globalGid(int gid, const std::string & propertyKey)
{
	auto it = _globalGidToTile.find(gid);
	if (it != _globalGidToTile.end())
		return it->second->GetProperties().GetStringProperty(propertyKey);
	return std::string();
}

std::string LHSTmxData::getLayerProperty_layerName(const std::string & name, const std::string & propertyKey)
{
	const std::vector< Tmx::Layer* > layerVec = _tmxMap->GetLayers();
	for (auto it = layerVec.begin(); it != layerVec.end(); it++)
		if ((*it)->GetName().compare(name) == 0)
			return (*it)->GetProperties().GetStringProperty(propertyKey);
	return std::string();
}

cocos2d::SpriteFrame * LHSTmxData::getSpriteFrame_globalGid(int gid)
{
	auto it = _globalGidToFrameSprite.find(gid);
	if (it != _globalGidToFrameSprite.end())
		return it->second;
	return nullptr;
}

cocos2d::Texture2D * LHSTmxData::getTexture2D_image(const Tmx::Image * image)
{
	if (image)
	{
		auto it = _cacheTexture.find(image);
		if (it != _cacheTexture.end())
			return it->second;
	}
	return nullptr;
}