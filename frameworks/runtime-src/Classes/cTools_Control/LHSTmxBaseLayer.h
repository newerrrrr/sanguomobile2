#ifndef __LHSTMXBASELAYER_H__
#define __LHSTMXBASELAYER_H__

#include "cocos2d.h"
#include "../tiledMap/Tmx.h"


typedef enum LHSTmxLayerType
{
	kLHSTmxLayerType_ImageLayer = 0,
	kLHSTmxLayerType_TileLayer,
}LHSTmxLayerType;


class LHSTmxBaseLayer
{
public:
	virtual LHSTmxLayerType getTmxLayerType() = 0;
};


#define calculate_determinant_2x3(X1,Y1,X2,Y2,X3,Y3) (X1*Y2+X2*Y3+X3*Y1-Y1*X2-Y2*X3-Y3*X1)


class LHSParallelogram
{
public:
	cocos2d::Vec2 _posT;
	cocos2d::Vec2 _posL;
	cocos2d::Vec2 _posB;
	cocos2d::Vec2 _posR;

	bool containsPoint(const cocos2d::Vec2 & pos) const
	{
		if (0 < calculate_determinant_2x3(_posT.x, _posT.y, _posL.x, _posL.y, pos.x, pos.y)
			&& 0 < calculate_determinant_2x3(_posL.x, _posL.y, _posB.x, _posB.y, pos.x, pos.y)
			&& 0 < calculate_determinant_2x3(_posB.x, _posB.y, _posR.x, _posR.y, pos.x, pos.y)
			&& 0 < calculate_determinant_2x3(_posR.x, _posR.y, _posT.x, _posT.y, pos.x, pos.y))
			return true;
		else
			return false;
	}

	cocos2d::Vec2 getT(){ return _posT; };
	cocos2d::Vec2 getL(){ return _posL; };
	cocos2d::Vec2 getB(){ return _posB; };
	cocos2d::Vec2 getR(){ return _posR; };
};


class LHSTileData
{
public:
	LHSTileData(cocos2d::Node * node, const cocos2d::Vec2 & index , int gid)
		: _showNode(node)
		, _Index(index)
		, _editGid(gid)
		, _customName("")
	{};
	LHSTileData(cocos2d::Node * node, const cocos2d::Vec2 & index, const char * name)
		: _showNode(node)
		, _Index(index)
		, _editGid(0)
		, _customName(name)
	{};
	const int _editGid;
	const std::string _customName;
	cocos2d::Node * _showNode;
	cocos2d::Vec2 _Index;

	int getEditGid(){ return _editGid; };
	const char * getCustomName()const{ return _customName.c_str(); };
	cocos2d::Node * getShowNode(){ return _showNode; };
	cocos2d::Vec2 getIndex(){ return _Index; };
};

#endif //__LHSTMXBASELAYER_H__