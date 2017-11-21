

#ifndef _NETCONNETIONINTERFACE_H_  
#define _NETCONNETIONINTERFACE_H_  
#include "NetCommon.h"
#include <string>

NS_SANGUO_MOBILE_GAME_BEGIN;

class NetManager;

class NetConnetionInterface
{
public:
    virtual ~NetConnetionInterface(){}
    virtual void connectToLoginServer(const std::string& ip,int port, NetManager* pInstance) = 0;
    virtual void connectToGameServer(const std::string& ip,int port, NetManager* pInstance) = 0;
    virtual bool purge(NetManager* pInstance) = 0;
};

NS_SANGUO_MOBILE_GAME_END; //namespace


#endif //_NETCONNETIONINTERFACE_H_  