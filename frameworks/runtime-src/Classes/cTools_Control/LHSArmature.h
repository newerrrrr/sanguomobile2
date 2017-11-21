#ifndef __LHSARMATURE_H__
#define __LHSARMATURE_H__

#include "cocos2d.h"
#include "cocostudio/CocoStudio.h"

#include "LHSArmatureAnimation.h"

class LHSArmature : public cocostudio::Armature
{
public:

	LHSArmature();
	~LHSArmature();

	static LHSArmature *create();

	static LHSArmature *create(const std::string& name);

	static LHSArmature *create(const std::string& name, cocostudio::Bone *parentBone);

	virtual bool init()override;

	virtual bool init(const std::string& name)override;

	virtual bool init(const std::string& name, cocostudio::Bone *parentBone)override;

	virtual LHSArmatureAnimation *getLHSAnimation();

};



#endif //__LHSARMATURE_H__