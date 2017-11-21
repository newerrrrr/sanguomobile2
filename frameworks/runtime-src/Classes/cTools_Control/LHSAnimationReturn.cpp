#include "LHSAnimationReturn.h"

LHSAnimationReturn::LHSAnimationReturn()
	:m_TotalFrameNum(0)
	,m_TotalTime(0.0f)
	,m_Fps(0.0f)
{
	
}

LHSAnimationReturn::~LHSAnimationReturn()
{

}

LHSAnimationReturn * LHSAnimationReturn::create()
{
	LHSAnimationReturn * ret = new (std::nothrow) LHSAnimationReturn();
	if (ret)
		ret->autorelease();
	return ret;
}

