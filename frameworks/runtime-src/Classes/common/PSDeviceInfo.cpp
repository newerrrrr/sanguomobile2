
#include "PSDeviceInfo.h"
#include "Crypto.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID 
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#endif

//这个文件大部分函数都已停用

USING_NS_CC;

bool PSDeviceInfo::isLocalWiFiAvailable()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
    
    return true;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID 
    {
    	JniMethodInfo methodInfo; 
        if (JniHelper::getStaticMethodInfo(methodInfo, "org/cocos2dx/lua/AppActivity", "isLocalWiFiAvailable", 
            "()Z"))
        {
            jboolean ret = methodInfo.env->CallStaticBooleanMethod(methodInfo.classID, methodInfo.methodID);
    		methodInfo.env->DeleteLocalRef(methodInfo.classID);
    		return ret;
        }
        return false;
    }    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#else
    return true;
#endif
}

bool PSDeviceInfo::isInternetConnectionAvailable()
{
 #if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
    return true;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID 
    {
    	JniMethodInfo methodInfo;
        if (JniHelper::getStaticMethodInfo(methodInfo, "org/cocos2dx/lua/AppActivity", "isInternetConnectionAvailable", 
            "()Z"))
        {
            jboolean ret = methodInfo.env->CallStaticBooleanMethod(methodInfo.classID, methodInfo.methodID);
    		methodInfo.env->DeleteLocalRef(methodInfo.classID);
    		return ret;
        }
        return false;
    }    

#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#else
    return true;
#endif
}



bool PSDeviceInfo::saveToFile(std::string &filePath, std::string &uuid)
{
    FILE *fp = fopen(filePath.c_str(), "w+");
    if (fp)
    {
        fwrite((void *)uuid.c_str(), uuid.size(), 1, fp);
        fclose(fp);
        return true;
    }
    return false;
}
    
std::string PSDeviceInfo::getMyUUID()
{
	CCAssert(false, "");
    std::string uuid;
    FileUtils *_fileUtils = FileUtils::getInstance();
    
    // 1. read local uuid file
    std::string storagePath = _fileUtils->getWritablePath() + "sgMobile_2";
    std::string filePath = storagePath + "/uuid.bin";
    _fileUtils->createDirectory(storagePath);
    if (_fileUtils->isFileExist(filePath))
    {
        uuid = _fileUtils->getStringFromFile(filePath);
        if (uuid.size() > 0)
        {
            CCLOG("getMyUUID: from file ==%s", uuid.c_str());
            return uuid;
        }
        else 
        {
            _fileUtils->removeFile(filePath);
        }
    }
    
    // 2. get device uuid and save to file when no local uuid file.
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID 
    {
        JniMethodInfo methodInfo; 
        if (JniHelper::getStaticMethodInfo(methodInfo, "org/cocos2dx/lua/AppActivity", "getMyUUID", "()Ljava/lang/String;"))
        {
            jstring str = (jstring)methodInfo.env->CallStaticObjectMethod(methodInfo.classID, methodInfo.methodID);
            uuid = JniHelper::jstring2string(str);
            methodInfo.env->DeleteLocalRef(str);
            methodInfo.env->DeleteLocalRef(methodInfo.classID); 
            if (uuid.size() > 0)
            {
                // gen to md5 string
                //uuid = Crypto::MD5String((void *)tmp.c_str(), tmp.size());
                CCLOG("getMyUUID:from device: %s, %s", uuid.c_str());
            }
        }
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS 
    
#endif 
    
    if (uuid.size() == 0) 
    {
        // 3. gen random uuid after no local uuid file and get device uuid failed.
        std::srand((unsigned int)(time(nullptr)));
        uuid = StringUtils::format("%d_mobile2_%d", cocos2d::random(), cocos2d::random());
        //uuid = Crypto::MD5String((void *)str.c_str(), str.size());
        CCLOG("getMyUUID: random gen ==%s", uuid.c_str());
    }
    
    saveToFile(filePath, uuid);
    
    return uuid;
}

std::string PSDeviceInfo::getMD5String(std::string &str)
{
    str += "Salt.SanGuoMobile2";
    std::string md5 = Crypto::MD5String((void *)str.c_str(), str.size());
    return md5;
}
