
#ifndef NETWORKSTATE_H
#define NETWORKSTATE_H

#include "cocos2d.h"

class PSDeviceInfo
{
public:
    /** @brief Checks whether a local wifi connection is available */
    static bool isLocalWiFiAvailable(void);
    
    /** @brief Checks whether the default route is available */
    static bool isInternetConnectionAvailable(void);    
    static std::string getMyUUID();
    static std::string getMD5String(std::string &str);
private:
    static bool saveToFile(std::string &filePath, std::string &uuid);    
};
#endif

