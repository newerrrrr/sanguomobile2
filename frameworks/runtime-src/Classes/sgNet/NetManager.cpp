
#include "NetManager.h"
#include "CAutoLock.h"
#include "NetConnectionImpl.h"

NS_SANGUO_MOBILE_GAME_BEGIN;

static NetManager *_pInstance = nullptr;
NetManager::NetManager()
{
    m_netState = kNetStateNone;

    pConnection = new NetConnectionImpl;
}

NetManager::~NetManager()
{
    delete pConnection;
}

NetManager* NetManager::Instance()
{
    if (!_pInstance)
    {
        _pInstance = new NetManager();
    }
    return _pInstance;
}

// server --> client
NetNotify* NetManager::pickNotify()
{
    CAutoLock lock(&sNetNotifyLock);
    if(!m_netNotify.empty())
    {
        NetNotify* notify = m_netNotify.front();
        m_netNotify.pop();
        return notify;
    }

    return nullptr;
}

void NetManager::appendNotify(const NetNotifyEnum notify)
{
    CAutoLock lock(&sNetNotifyLock);
    m_netNotify.push(new NetNotify(notify));
}

void NetManager::appendNotify(NetNotify* notify)
{
    CAutoLock lock(&sNetNotifyLock);
    m_netNotify.push(notify);
}


// client --> server
PtrUserReq NetManager::pickUserReq()
{
    CAutoLock lock(&sUserReqLock);

    if(!m_userReq.empty())
    {
        const PtrUserReq req = m_userReq.front();
        m_userReq.pop();

        return req;
    }

    //return PtrUserReq();
	return nullptr;
}

void NetManager::appendUserReq(PtrUserReq req)
{
    switch (req->_req)
    {
        case kNetReqConnectLoginServer:
            m_netState = kNetStateConnectingLoginServer;
            pConnection->connectToLoginServer(m_loginServerAddr.serverAddr,m_loginServerAddr.port, this);
            break;
            
        case kNetReqConnectGameServer:
            m_netState = kNetStateConnectingGameServer;
            pConnection->connectToGameServer(m_gameServerAddr.serverAddr,m_gameServerAddr.port, this);
            break;
            
        case kNetReqSendData:
            if (checkNetState(kNetStateConnectedGameServer))
            {
                CAutoLock lock(&sUserReqLock);
                m_userReq.push(req);  
            }
            break;
            
        case kNetReqDisconnect:
            if( checkNetState(kNetStateConnectedGameServer))
            {
                changeNetState(kNetStateDisconnectingFromGameServer);			
            }            
            break;
            
        default:
            LOG("no handler for net req: %d", req->_req);
            break;
    }



}


bool NetManager::setupLoginServer(const std::string& ip,int port)
{
    m_loginServerAddr.serverAddr = ip;
    m_loginServerAddr.port = port;
    return true;
}

bool NetManager::setupGameServer(const std::string& ip,int port)
{
    m_gameServerAddr.serverAddr = ip;
    m_gameServerAddr.port = port;
    return true;
}

// here just used for check whether has push events or not, no need to login, so just connect to game server.
void NetManager::start()
{
    LOG("start the network");
    //pConnection->connectToGameServer(m_loginServerAddr.serverAddr, m_loginServerAddr.port, this);
    pConnection->connectToGameServer(m_gameServerAddr.serverAddr, m_gameServerAddr.port, this);
}

void NetManager::stop()
{
    LOG("stop the network");
    pConnection->purge(this);  
}


bool NetManager::checkNetState(NetStateEnum state)
{
    CAutoLock lock(&sNetStateLock);

    if( m_netState == state )
    {
        return true;
    }
    else
    {
        LOG("State not match,current state:[%d],expect state:[%d]", m_netState, state);
    }
    
    return false;
}


void NetManager::changeNetState(int state)
{
    CAutoLock lock(&sNetStateLock);

    LOG("change net state from [%d] to [%d]", m_netState, state);
    m_netState = state;
}




NS_SANGUO_MOBILE_GAME_END;
