#ifndef __LHSARMATUREANIMATION_H__
#define __LHSARMATUREANIMATION_H__

#include "cocos2d.h"
#include "cocostudio/CocoStudio.h"


class LHSArmatureAnimation : public cocostudio::ArmatureAnimation
{
public:
	LHSArmatureAnimation();
	~LHSArmatureAnimation();

	static LHSArmatureAnimation *create(cocostudio::Armature *armature);

	virtual bool init(cocostudio::Armature *armature)override;



	void registerScriptMovementHandler(int nHandler);
	void unregisterScriptMovementHandler(void);



	void registerScriptFrameHandler(int nHandler);
	void unregisterScriptFrameHandler(void);



private:
	int m_ScriptMovemenHander;
	int m_ScriptFrameHander;
};

#endif //__LHSARMATUREANIMATION_H__