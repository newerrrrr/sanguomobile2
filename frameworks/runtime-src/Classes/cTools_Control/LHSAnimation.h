#ifndef __LHSANIMATION_H__
#define __LHSANIMATION_H__

#include "cocos2d.h"
#include "LHSAnimationReturn.h"

/**
FPS动画
**/

class LHSAnimation
{
public:
	LHSAnimation();
	~LHSAnimation();
	
	//传入: Frame前缀   帧率   是否回原始帧  返回数据指针
	static cocos2d::Animate* createFrameAnimationWithIdOrder(const char * prefixionName, float fps = 0.0666666666666667f, bool isOriginalFrame = true, LHSAnimationReturn * out_data = nullptr, int startID = 1);
};



#endif  // __LHSANIMATION_H__