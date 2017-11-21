#include "LHSTmxLayer.h"
#include "LHSTmxCache.h"

USING_NS_CC;


LHSTmxLayer::LHSTmxLayer(const char * tmxName)
	:_width(0)
	, _height(0)
	, _tileWidth(0)
	, _tileHeight(0)
	, _tileWidthHalf(0)
	, _tileHeightHalf(0)
	, _tmxName(tmxName)
	, _isVisibleOperat(true)
	, _offsetSizeVO(Size::ZERO)
{

}


LHSTmxLayer::~LHSTmxLayer()
{

}


LHSTmxLayer * LHSTmxLayer::create(const char * tmxFilename)
{
	LHSTmxData * tmxData = LHSTmxCache::getInstance()->loadTmxFile(tmxFilename);
	if (tmxData)
	{
		LHSTmxLayer * ret = new (std::nothrow) LHSTmxLayer(tmxFilename);
		if (ret && ret->_initWithTmxData(tmxData))
		{
			ret->autorelease();
			return ret;
		}
		CC_SAFE_DELETE(ret);
	}
	return nullptr;
}

#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
static bool s_CheckedMultipleTexture = false;
#endif

bool LHSTmxLayer::_initWithTmxData(LHSTmxData * tmxData)
{
	bool ret = false;
	do 
	{
		CC_BREAK_IF(!Layer::init());
		CC_BREAK_IF(!tmxData);

		_width = tmxData->getWidth();
		_height = tmxData->getHeight();
		_tileWidth = tmxData->getTileWidth();
		_tileHeight = tmxData->getTileHeight();
		_tileWidthHalf = _tileWidth / 2;
		_tileHeightHalf = _tileHeight / 2;

		const Size contentSize(_width * _tileWidthHalf + _height * _tileWidthHalf, _height * _tileHeightHalf + _width * _tileHeightHalf);
		this->setContentSize(contentSize);
		this->setAnchorPoint(Vec2::ZERO);
		this->setPosition(Vec2::ZERO);

		_parallelogram._posT.set(0 * _tileWidthHalf + (_height - (0 + 1)) * _tileWidthHalf + _tileWidthHalf, contentSize.height - (_tileHeight + 0 * _tileHeightHalf + 0 * _tileHeightHalf) + _tileHeight);
		_parallelogram._posL.set(0 * _tileWidthHalf + (_height - ((_height - 1) + 1)) * _tileWidthHalf, contentSize.height - (_tileHeight + (_height - 1) * _tileHeightHalf + 0 * _tileHeightHalf) + _tileHeightHalf);
		_parallelogram._posB.set((_width - 1) * _tileWidthHalf + (_height - ((_height - 1) + 1)) * _tileWidthHalf + _tileWidthHalf, contentSize.height - (_tileHeight + (_height - 1) * _tileHeightHalf + (_width - 1) * _tileHeightHalf));
		_parallelogram._posR.set((_width - 1) * _tileWidthHalf + (_height - (0 + 1)) * _tileWidthHalf + _tileWidth, contentSize.height - (_tileHeight + 0 * _tileHeightHalf + (_width - 1) * _tileHeightHalf) + _tileHeightHalf);


		const std::vector< Tmx::Layer* > layerVec = tmxData->getLayers();

		int layerZOrder = 1; //子层z从1开始,每次迭代+2
		for (auto it = layerVec.begin(); it != layerVec.end(); it++, layerZOrder+=2)
		{
			switch ((*it)->GetLayerType())
			{
			case Tmx::TMX_LAYERTYPE_TILE:
			{
				const Tmx::TileLayer * tileLayer = dynamic_cast<const Tmx::TileLayer*>((*it));

				LHSTmxTileLayer * cTileLayer = LHSTmxTileLayer::create(_width, _height, _tileWidth, _tileHeight);
				CCAssert(tileLayer->GetX() == 0 && tileLayer->GetY() == 0, "editor support , but our game not support !");
				cTileLayer->setPosition(Vec2(tileLayer->GetX(), tileLayer->GetY() * -1));
				cTileLayer->setVisible(tileLayer->IsVisible());
				cTileLayer->setCascadeOpacityEnabled(true);
				cTileLayer->setOpacity(tileLayer->GetOpacity() * 255);
				this->addChild(cTileLayer, layerZOrder, tileLayer->GetName());

#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
				Texture2D * batchTexture = nullptr;
#endif

				for (int y = 0; y < tileLayer->GetHeight(); ++y)
				{
					for (int x = 0; x < tileLayer->GetWidth(); ++x)
					{
						const Tmx::MapTile & mapTile = tileLayer->GetTile(x, y);
						if (mapTile.tilesetId != -1)
						{
							//mapTile.tilesetId;  //图片ID 0开始
							//mapTile.id;	//图片中的图块ID 0开始
							if (mapTile.gid != 0)
							{
								SpriteFrame * sf = tmxData->getSpriteFrame_globalGid(mapTile.gid);
								CCAssert(sf, "error");
								CC_BREAK_IF(!sf);

#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
								if (batchTexture == nullptr)
								{
									batchTexture = sf->getTexture();
								}
								else if (batchTexture != sf->getTexture())
								{	
									if (!s_CheckedMultipleTexture)
									{
										s_CheckedMultipleTexture = true;
										cocos2d::MessageBox("LiuYi quickly check map , same layer used multiple texture !", "warning");
									}
								}
#endif

								Sprite * sprite = Sprite::createWithSpriteFrame(sf);
								sprite->setFlippedX(mapTile.flippedHorizontally);
								sprite->setFlippedY(mapTile.flippedVertically);
								CCAssert(!mapTile.flippedDiagonally, "error: not support editor Z key");
								cTileLayer->addEditTile(sprite, x, y, mapTile.gid);
							}
						}
					}
				}
			}
				break;
			case Tmx::TMX_LAYERTYPE_IMAGE_LAYER:
			{
				const Tmx::ImageLayer * imageLayer = dynamic_cast<const Tmx::ImageLayer*>((*it));
				const Tmx::Image * image = imageLayer->GetImage();
				Texture2D * texture = tmxData->getTexture2D_image(image);
				LHSTmxImageLayer * cImageLayer = nullptr;
				if (texture)
					cImageLayer = LHSTmxImageLayer::createWithTexture(texture);
				else
					cImageLayer = LHSTmxImageLayer::create();
				cImageLayer->setAnchorPoint(Vec2(0.0f, 1.0f));
				cImageLayer->setPosition(Vec2(imageLayer->GetX(), contentSize.height - imageLayer->GetY()));
				cImageLayer->setVisible(imageLayer->IsVisible());
				cImageLayer->setOpacity(imageLayer->GetOpacity() * 255);
				this->addChild(cImageLayer, layerZOrder, imageLayer->GetName());
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


void LHSTmxLayer::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
{
	if (!_visible)
	{
		return;
	}
	if (_isVisibleOperat)
	{
		const Camera * camera = Camera::getVisitingCamera();
		if (camera)
		{
			Size contentSize = this->getContentSize();
			Vec2 wlt = camera->projectGL(this->convertToWorldSpace3D(Vec3(0, contentSize.height, 0)));
			Vec2 wlb = camera->projectGL(this->convertToWorldSpace3D(Vec3::ZERO));
			Vec2 wrt = camera->projectGL(this->convertToWorldSpace3D(Vec3(contentSize.width, contentSize.height, 0)));
			Vec2 wrb = camera->projectGL(this->convertToWorldSpace3D(Vec3(contentSize.width, 0, 0)));
			Director * director = Director::getInstance();
			float x = MIN(MIN(wlt.x, wlb.x), MIN(wrt.x, wrb.x));
			float y = MIN(MIN(wlt.y, wlb.y), MIN(wrt.y, wrb.y));
			float w = MAX(MAX(wlt.x, wlb.x), MAX(wrt.x, wrb.x)) - x;
			float h = MAX(MAX(wlt.y, wlb.y), MAX(wrt.y, wrb.y)) - y;
			if (!Rect(Vec2(_offsetSizeVO.width*-1.0f, _offsetSizeVO.height*-1.0f), director->getWinSize() + _offsetSizeVO * 2).intersectsRect(Rect(x, y, w, h)))
				return;
		}
	}
	Layer::visit(renderer, parentTransform, parentFlags);
}

void LHSTmxLayer::setVisibleOperat(bool isOpen, cocos2d::Size offsetSize /*= Size::ZERO*/)
{
	_isVisibleOperat = isOpen;
	_offsetSizeVO = offsetSize;
}