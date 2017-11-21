

#ifndef _NETCONNECTIONIMPL_H_  
#define _NETCONNECTIONIMPL_H_  

#include "NetCommon.h"
#include "NetConnetionInterface.h"
#include <thread>

NS_SANGUO_MOBILE_GAME_BEGIN;

class NetConnectionImpl : public NetConnetionInterface
{
public:
    NetConnectionImpl();
    ~NetConnectionImpl();
    void loginServerThreadMain(NetManager* pInstance);
    void gameServerThreadMain(NetManager* pInstance);
    void connectToLoginServer(const std::string& ip, int port, NetManager* pInstance);
    void connectToGameServer(const std::string& ip, int port, NetManager* pInstance);
    virtual bool purge(NetManager* pInstance);
protected:
    bool isValidState(const int error);
private:
    std::thread *pLoginServerThread;
    std::thread *pGameServerThread;
};

NS_SANGUO_MOBILE_GAME_END; //namespace


#endif //_NETCONNECTIONIMPL_H_  