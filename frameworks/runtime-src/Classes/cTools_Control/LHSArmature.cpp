#include "LHSArmature.h"

USING_NS_CC;

LHSArmature *LHSArmature::create()
{
	LHSArmature *armature = new (std::nothrow) LHSArmature();
	if (armature && armature->init())
	{
		armature->autorelease();
		return armature;
	}
	CC_SAFE_DELETE(armature);
	return nullptr;
}


LHSArmature *LHSArmature::create(const std::string& name)
{
	LHSArmature *armature = new (std::nothrow) LHSArmature();
	if (armature && armature->init(name))
	{
		armature->autorelease();
		return armature;
	}
	CC_SAFE_DELETE(armature);
	return nullptr;
}

LHSArmature *LHSArmature::create(const std::string& name, cocostudio::Bone *parentBone)
{
	LHSArmature *armature = new (std::nothrow) LHSArmature();
	if (armature && armature->init(name, parentBone))
	{
		armature->autorelease();
		return armature;
	}
	CC_SAFE_DELETE(armature);
	return nullptr;
}

LHSArmature::LHSArmature()
{

}

LHSArmature::~LHSArmature()
{

}

bool LHSArmature::init()
{
	return init("");
}

bool LHSArmature::init(const std::string& name)
{
	bool bRet = false;
	do
	{
		removeAllChildren();

		CC_SAFE_DELETE(_animation);
		_animation = new (std::nothrow) LHSArmatureAnimation();
		_animation->init(this);

		_boneDic.clear();
		_topBoneList.clear();

		_blendFunc = BlendFunc::ALPHA_PREMULTIPLIED;

		_name = name;

		cocostudio::ArmatureDataManager *armatureDataManager = cocostudio::ArmatureDataManager::getInstance();

		if (!_name.empty())
		{
			cocostudio::AnimationData *animationData = armatureDataManager->getAnimationData(name);
			CCASSERT(animationData, "AnimationData not exist! ");

			_animation->setAnimationData(animationData);


			cocostudio::ArmatureData *armatureData = armatureDataManager->getArmatureData(name);
			CCASSERT(armatureData, "armatureData doesn't exists!");

			_armatureData = armatureData;

			for (auto& element : armatureData->boneDataDic)
			{
				cocostudio::Bone *bone = createBone(element.first.c_str());

				//! init bone's  Tween to 1st movement's 1st frame
				do
				{
					cocostudio::MovementData *movData = animationData->getMovement(animationData->movementNames.at(0).c_str());
					CC_BREAK_IF(!movData);

					cocostudio::MovementBoneData *movBoneData = movData->getMovementBoneData(bone->getName().c_str());
					CC_BREAK_IF(!movBoneData || movBoneData->frameList.size() <= 0);

					cocostudio::FrameData *frameData = movBoneData->getFrameData(0);
					CC_BREAK_IF(!frameData);

					bone->getTweenData()->copy(frameData);
					bone->changeDisplayWithIndex(frameData->displayIndex, false);
				} while (0);
			}

			update(0);
			updateOffsetPoint();
		}
		else
		{
			_name = "new_armature";
			_armatureData = cocostudio::ArmatureData::create();
			_armatureData->name = _name;

			cocostudio::AnimationData *animationData = cocostudio::AnimationData::create();
			animationData->name = _name;

			armatureDataManager->addArmatureData(_name.c_str(), _armatureData);
			armatureDataManager->addAnimationData(_name.c_str(), animationData);

			_animation->setAnimationData(animationData);

		}

		setGLProgramState(GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR));

		setCascadeOpacityEnabled(true);
		setCascadeColorEnabled(true);

		bRet = true;
	} while (0);

	return bRet;
}

bool LHSArmature::init(const std::string& name, cocostudio::Bone *parentBone)
{
	_parentBone = parentBone;
	return init(name);
}

LHSArmatureAnimation * LHSArmature::getLHSAnimation()
{
	return dynamic_cast<LHSArmatureAnimation*>(this->getAnimation());
}