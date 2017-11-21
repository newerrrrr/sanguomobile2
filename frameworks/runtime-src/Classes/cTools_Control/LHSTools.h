#ifndef __LHSTOOLS_H__
#define __LHSTOOLS_H__

#include "cocos2d.h"

class LHSTools
{
public:
	//检查节点是否在场景中
	static bool checkInSceneOrder(cocos2d::Node * node);

	//检查所有祖先节点是否都显示(不包括自己)
	static bool checkAncestorsVisible(cocos2d::Node * node);

	//检查是否点到自己范围内(2D)
	static bool checkTouchInSelf(cocos2d::Node * node, cocos2d::Touch * touch);

	//检查是否点到自己范围内(3D)
	static bool checkTouchInSelf_3D(cocos2d::Node * node, cocos2d::Touch * touch);
};



#endif //__LHSTOOLS_H__