
#ifndef UUIDINFO_H
#define UUIDINFO_H

#include "cocos2d.h"

class UUIDInfo
{
public:
    static std::string getMyUUID();
private:
    static bool saveToFile(std::string &filePath, std::string &uuid);
};

#endif //UUIDINFO_H