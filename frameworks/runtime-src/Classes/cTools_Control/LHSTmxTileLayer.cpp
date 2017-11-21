#include "LHSTmxTileLayer.h"
#include "math/TransformUtils.h"

USING_NS_CC;


LHSTmxTileLayer * LHSTmxTileLayer::create(int width, int height, int tileWidth, int tileHeight)
{
	LHSTmxTileLayer *ret = new (std::nothrow) LHSTmxTileLayer(width,height,tileWidth,tileHeight);
	if (ret && ret->init())
	{
		ret->autorelease();
		return ret;
	}
	else
	{
		CC_SAFE_DELETE(ret);
		return nullptr;
	}
}


LHSTmxTileLayer::LHSTmxTileLayer(int width, int height, int tileWidth, int tileHeight)
	: _width(width)
	, _height(height)
	, _tileWidth(tileWidth)
	, _tileHeight(tileHeight)
	, _isVisibleOperat(false)
	, _offsetSizeVO(Size::ZERO)
	, _tileWidthHalf(tileWidth / 2)
	, _tileHeightHalf(tileHeight / 2)
{
	_Tiles = new LHSTileData*[width * height];
	memset(_Tiles, 0, sizeof(LHSTileData*) * width * height);

	Size contentSize(_width * _tileWidthHalf + _height * _tileWidthHalf, _height * _tileHeightHalf + _width * _tileHeightHalf);
	_parallelogram._posT.set(0 * _tileWidthHalf + (_height - (0 + 1)) * _tileWidthHalf + _tileWidthHalf, contentSize.height - (_tileHeight + 0 * _tileHeightHalf + 0 * _tileHeightHalf) + _tileHeight);
	_parallelogram._posL.set(0 * _tileWidthHalf + (_height - ((_height - 1) + 1)) * _tileWidthHalf, contentSize.height - (_tileHeight + (_height - 1) * _tileHeightHalf + 0 * _tileHeightHalf) + _tileHeightHalf);
	_parallelogram._posB.set((_width - 1) * _tileWidthHalf + (_height - ((_height - 1) + 1)) * _tileWidthHalf + _tileWidthHalf, contentSize.height - (_tileHeight + (_height - 1) * _tileHeightHalf + (_width - 1) * _tileHeightHalf));
	_parallelogram._posR.set((_width - 1) * _tileWidthHalf + (_height - (0 + 1)) * _tileWidthHalf + _tileWidth, contentSize.height - (_tileHeight + 0 * _tileHeightHalf + (_width - 1) * _tileHeightHalf) + _tileHeightHalf);
}


LHSTmxTileLayer::~LHSTmxTileLayer()
{
	removeAllTile(true);
	delete[] _Tiles;
}

bool LHSTmxTileLayer::init()
{
	bool ret = false;
	do 
	{
		CC_BREAK_IF(!Layer::init());

		this->setContentSize(Size(_width * _tileWidthHalf + _height * _tileWidthHalf, _height * _tileHeightHalf + _width * _tileHeightHalf));
		this->setAnchorPoint(Vec2::ZERO);

		ret = true;
	} while (false);

	return ret;
}


void LHSTmxTileLayer::removeChild(Node* child, bool cleanup /*= true*/)
{
	auto it = _showTiles_nodeKey.find(child);
	if (it != _showTiles_nodeKey.end())
		_freeTile(&(_Tiles[((int)(it->second.y)) * _width + ((int)(it->second.x))]), cleanup);
	else
		Layer::removeChild(child, cleanup);
}

void LHSTmxTileLayer::removeChildByTag(int tag, bool cleanup /*= true*/)
{
	CCASSERT(tag != Node::INVALID_TAG, "Invalid tag");
	Node *child = this->getChildByTag(tag);
	if (child == nullptr)
		CCLOG("cocos2d: removeChildByTag(tag = %d): child not found!", tag);
	else
		this->removeChild(child, cleanup);
}

void LHSTmxTileLayer::removeChildByName(const std::string &name, bool cleanup /*= true*/)
{
	CCASSERT(name.length() != 0, "Invalid name");
	Node *child = this->getChildByName(name);
	if (child == nullptr)
		CCLOG("cocos2d: removeChildByName(name = %s): child not found!", name.c_str());
	else
		this->removeChild(child, cleanup);
}

void LHSTmxTileLayer::removeAllChildren()
{
	this->removeAllChildrenWithCleanup(true);
}

void LHSTmxTileLayer::removeAllChildrenWithCleanup(bool cleanup)
{
	this->removeAllTile(cleanup);
	Layer::removeAllChildrenWithCleanup(cleanup);
}


void LHSTmxTileLayer::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
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
			Rect(Vec2(_offsetSizeVO.width*-1.0f, _offsetSizeVO.height*-1.0f), director->getWinSize() + _offsetSizeVO * 2);
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


void LHSTmxTileLayer::addEditTile(cocos2d::Node * tile, int tileIndex_x, int tileIndex_y, int gid)
{
	Size contentSize = this->getContentSize();

	Vec2 index(tileIndex_x, tileIndex_y);

	int i = tileIndex_y * _width + tileIndex_x;

	tile->setAnchorPoint(Vec2::ZERO);
	Vec2 position = this->getNodePositionWithIndex(index);
	tile->setPosition(position);

	Layer::addChild(tile, this->getZOrderWithIndex(index));

	CCAssert(_Tiles[i] == nullptr, "error : _Tiles[i] == nullptr");

	_freeTile(&(_Tiles[i]));

	tile->retain();
	_Tiles[i] = new LHSTileData(tile, Vec2(tileIndex_x,tileIndex_y) , gid);
	_showTiles_nodeKey.insert(std::pair<cocos2d::Node*, cocos2d::Vec2>(tile, Vec2(tileIndex_x, tileIndex_y)));
}


void LHSTmxTileLayer::addCustomTile(cocos2d::Node * tile, int tileIndex_x, int tileIndex_y, int ZOrder, const char * customName)
{
	Size contentSize = this->getContentSize();

	Vec2 index(tileIndex_x, tileIndex_y);

	int i = tileIndex_y * _width + tileIndex_x;

	tile->setAnchorPoint(Vec2::ZERO);
	Vec2 position = this->getNodePositionWithIndex(index);
	tile->setPosition(position);

	Layer::addChild(tile, ZOrder);

	//CCAssert(_Tiles[i] == nullptr, "error : _Tiles[i] == nullptr"); //新加入的物件覆盖以前加入的物件默认是被允许的

	_freeTile(&(_Tiles[i]));

	tile->retain();

	_Tiles[i] = new LHSTileData(tile, Vec2(tileIndex_x, tileIndex_y) , customName);
	_showTiles_nodeKey.insert(std::pair<cocos2d::Node*, cocos2d::Vec2>(tile, Vec2(tileIndex_x, tileIndex_y)));

	auto it = _showTiles_customNameKey.find(customName);
	if (it != _showTiles_customNameKey.end())
	{
		it->second.push_back(Vec2(tileIndex_x, tileIndex_y));
	}
	else
	{
		std::vector<Vec2> vec;
		vec.push_back(Vec2(tileIndex_x, tileIndex_y));
		_showTiles_customNameKey.insert(std::pair< std::string, std::vector<cocos2d::Vec2> >(customName, vec));
	}
}


void LHSTmxTileLayer::removeTile(int tileIndex_x, int tileIndex_y, bool cleanup /*= true*/)
{
	int i = tileIndex_y * _width + tileIndex_x;
	_freeTile(&(_Tiles[i]),cleanup);
}

void LHSTmxTileLayer::removeTileWithCustomName(const char * customName, bool cleanup /*= true*/)
{
	auto it = _showTiles_customNameKey.find(customName);
	if (it != _showTiles_customNameKey.end())
	{
		std::vector<cocos2d::Vec2> vec = it->second;
		_showTiles_customNameKey.erase(it);
		for (auto it2 = vec.begin(); it2 != vec.end(); it2++)
			removeTile((*it2).x, (*it2).y, cleanup);
	}
}

int LHSTmxTileLayer::getCustomTileCountWithCustomName(const char * customName)
{
	auto it = _showTiles_customNameKey.find(customName);
	if (it != _showTiles_customNameKey.end())
		return it->second.size();
	return 0;
}

void LHSTmxTileLayer::removeAllTile(bool cleanup /*= true*/)
{
	if (_showTiles_nodeKey.size() > 0)
	{
		_showTiles_nodeKey.clear();
		_showTiles_customNameKey.clear();
		for (int i = 0; i < _width * _height; i++)
			_freeTile(&(_Tiles[i]), cleanup);
	}
}

int LHSTmxTileLayer::getZOrderWithIndex(const cocos2d::Vec2 & index)
{
	if (index.x < 0 || index.x >= _width || index.y < 0 || index.y >= _height)
		return -1;
	return 1 + ((index.x + index.y) * _width + index.x) * 2;
}


cocos2d::Vec2 LHSTmxTileLayer::getNodePositionWithIndex(const cocos2d::Vec2 & index)
{
	if (index.x < 0 || index.x >= _width || index.y < 0 || index.y >= _height)
		return cocos2d::Vec2(-1, -1);
	return Vec2(index.x * _tileWidthHalf + (_height - (index.y + 1)) * _tileWidthHalf, _contentSize.height - (_tileHeight + index.y * _tileHeightHalf + index.x * _tileHeightHalf));
}


cocos2d::Vec2 LHSTmxTileLayer::getNodePositionCenterWithIndex(const cocos2d::Vec2 & index)
{
	Vec2 ret = getNodePositionWithIndex(index);
	if (ret.x != -1 && ret.y != -1)
	{
		ret.x += _tileWidthHalf;
		ret.y += _tileHeightHalf;
	}
	return ret;
}


cocos2d::Vec2 LHSTmxTileLayer::getIndexWithNodePosition_Rough(cocos2d::Vec2 nodePos)
{
	if (_parallelogram.containsPoint(nodePos))
	{
		Size contentSize = this->getContentSize();
		Vec2 pos(nodePos.x - _tileWidthHalf, nodePos.y - _tileHeight);
		int x = (contentSize.height - _tileHeight - pos.y) / _tileHeight + (pos.x + _tileWidthHalf - _height * _tileWidthHalf) / _tileWidth;
		int	y = (contentSize.height - _tileHeight - pos.y) / _tileHeight - (pos.x + _tileWidthHalf - _height * _tileWidthHalf) / _tileWidth;
		return (x < 0 || x >= _width || y < 0 || y >= _height) ? (Vec2(-1, -1)) : (Vec2(x, y));
	}
	return Vec2(-1, -1);
}

inline static bool s_tileContainsPoint(const Vec2 & position, const Size & size, const int & widthHalf, const int & heightHalf, const Vec2 & pos)
{
	if (Rect(position, size).containsPoint(pos))
	{
		LHSParallelogram parallelogram;
		parallelogram._posT.set(position.x + widthHalf, position.y + size.height);
		parallelogram._posL.set(position.x, position.y + heightHalf);
		parallelogram._posB.set(position.x + widthHalf, position.y);
		parallelogram._posR.set(position.x + size.width, position.y + heightHalf);
		return parallelogram.containsPoint(pos);
	}
	return false;
}

cocos2d::Vec2 LHSTmxTileLayer::getIndexWithNodePosition(cocos2d::Vec2 nodePos)
{
	cocos2d::Vec2 ret(-1, -1);

	if (_parallelogram.containsPoint(nodePos))
	{
		Size contentSize = this->getContentSize();

		int quadrants = 0;

		if (nodePos.x > contentSize.width / 2)
			quadrants = (nodePos.y > contentSize.height / 2) ? (1) : (4);
		else
			quadrants = (nodePos.y > contentSize.height / 2) ? (2) : (3);

		switch (quadrants)
		{
		case 1:
		{
			for (int y = 0; y < _height; ++y)
			{
				for (int x = 0; x < _width; ++x)
				{
					Vec2 position(x * _tileWidthHalf + (_height - (y + 1)) * _tileWidthHalf, contentSize.height - (_tileHeight + y * _tileHeightHalf + x * _tileHeightHalf));
					if (s_tileContainsPoint(position, Size(_tileWidth, _tileHeight), _tileWidthHalf, _tileHeightHalf, nodePos))
					{
						ret.set(x, y);
						return ret;
					}
				}
			}
		}
			break;
		case 2:
		{
			for (int x = 0; x < _width; ++x)
			{
				for (int y = 0; y < _height; ++y)
				{
					Vec2 position(x * _tileWidthHalf + (_height - (y + 1)) * _tileWidthHalf, contentSize.height - (_tileHeight + y * _tileHeightHalf + x * _tileHeightHalf));
					if (s_tileContainsPoint(position, Size(_tileWidth, _tileHeight), _tileWidthHalf, _tileHeightHalf, nodePos))
					{
						ret.set(x, y);
						return ret;
					}
				}
			}
		}
			break;
		case 3:
		{
			for (int y = _height - 1; y >= 0; --y)
			{
				for (int x = _width - 1; x >= 0; --x)
				{
					Vec2 position(x * _tileWidthHalf + (_height - (y + 1)) * _tileWidthHalf, contentSize.height - (_tileHeight + y * _tileHeightHalf + x * _tileHeightHalf));
					if (s_tileContainsPoint(position, Size(_tileWidth, _tileHeight), _tileWidthHalf, _tileHeightHalf, nodePos))
					{
						ret.set(x, y);
						return ret;
					}
				}
			}
		}
			break;
		case 4:
		{
			for (int x = _width - 1; x >= 0 ; --x)
			{
				for (int y = _height - 1; y >= 0; --y)
				{
					Vec2 position(x * _tileWidthHalf + (_height - (y + 1)) * _tileWidthHalf, contentSize.height - (_tileHeight + y * _tileHeightHalf + x * _tileHeightHalf));
					if (s_tileContainsPoint(position, Size(_tileWidth, _tileHeight), _tileWidthHalf, _tileHeightHalf, nodePos))
					{
						ret.set(x, y);
						return ret;
					}
				}
			}
		}
			break;
		default:
			break;
		}
	}

	return ret;
}

int LHSTmxTileLayer::getGidWithNodePosition(cocos2d::Vec2 nodePos)
{
	if (_parallelogram.containsPoint(nodePos))
		return getGidWithIndex(getIndexWithNodePosition_Rough(nodePos));
	return -1;
}

int LHSTmxTileLayer::getGidWithIndex(cocos2d::Vec2 index)
{
	if (index.x >= 0 && index.y >= 0 && index.x < _width && index.y < _height)
	{
		int i = ((int)index.y) * _width + ((int)index.x);
		if (_Tiles[i])
			return (_Tiles[i])->getEditGid();
		else
			return 0;
	}
	return -1;
}

LHSTileData * LHSTmxTileLayer::getTileDataWithNodePosition(cocos2d::Vec2 nodePos)
{
	if (_parallelogram.containsPoint(nodePos))
		return getTileDataWithIndex(getIndexWithNodePosition_Rough(nodePos));
	return nullptr;
}

LHSTileData * LHSTmxTileLayer::getTileDataWithIndex(cocos2d::Vec2 index)
{
	if (index.x >= 0 && index.y >= 0 && index.x < _width && index.y < _height)
		return _Tiles[((int)index.y) * _width + ((int)index.x)];
	return nullptr;
}

void LHSTmxTileLayer::_freeTile(LHSTileData ** tile, bool cleanup/* = true*/)
{
	if ((*tile))
	{
		const char * customName = (*tile)->getCustomName();
		if (strcmp(customName, ""))
		{
			auto it = _showTiles_customNameKey.find(customName);
			if (it != _showTiles_customNameKey.end())
			{
				for (auto it2 = it->second.begin(); it2 != it->second.end(); it2++)
				{
					if ((*it2) == (*tile)->getIndex())
					{
						it->second.erase(it2);
						break;
					}
				}
				if (it->second.size() == 0)
					_showTiles_customNameKey.erase(it);
			}
		}
		Node * p = (*tile)->getShowNode();
		_showTiles_nodeKey.erase(p);
		this->removeChild(p, cleanup);
		p->release();
		delete (*tile);
		(*tile) = nullptr;
	}
}

void LHSTmxTileLayer::setVisibleOperat(bool isOpen, cocos2d::Size offsetSize /*= Size::ZERO*/)
{
	_isVisibleOperat = isOpen;
	_offsetSizeVO = offsetSize;
}
