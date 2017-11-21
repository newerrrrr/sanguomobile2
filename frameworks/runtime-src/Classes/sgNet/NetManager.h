
#ifndef _NET_MANAGER_H_
#define _NET_MANAGER_H_

#include "cocos2d.h"
#include "Singleton.h"
#include <queue>
#include <vector>
#include <thread>
#include "NetCommon.h"
#include "NetConnetionInterface.h"



NS_SANGUO_MOBILE_GAME_BEGIN;

//typedef Singleton<NetManager> sNetManager;

typedef std::queue<NetNotify*> NetNotifyQueueType;
typedef std::queue<PtrUserReq> UserReqQueueType;

class NetManager
{
public:
    NetManager();
    virtual ~NetManager();

    static NetManager* Instance();

    void start();
    void stop();
    

    bool setupLoginServer(const std::string& ip,int port);
    bool setupGameServer(const std::string& ip,int port);
    const NetAddr& getLoginServerAddr() const { return m_loginServerAddr; }
    const NetAddr& getGameServerAddr() const { return m_gameServerAddr; }
  
    void changeNetState(int state);
    int getNetState() const { return m_netState;}

    NetNotify* pickNotify();
    void appendNotify(const NetNotifyEnum notify);
    void appendNotify(NetNotify* notify);

    PtrUserReq pickUserReq();
    void appendUserReq(PtrUserReq req);
    
private:
    int m_netState;
    NetAddr m_loginServerAddr;
    NetAddr m_gameServerAddr;
    
    NetNotifyQueueType m_netNotify;
    UserReqQueueType m_userReq;
    NetConnetionInterface* pConnection;

    bool checkNetState(NetStateEnum state);

    std::mutex sNetStateLock;
    std::mutex sNetNotifyLock;
    std::mutex sUserReqLock;
};



NS_SANGUO_MOBILE_GAME_END;

#endif //_NET_MANAGER_H_