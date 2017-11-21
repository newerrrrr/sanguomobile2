
#include "NetManager.h"
#include "NetConnectionImpl.h"
#include "NetCommon.h"
#include "SimpleSocket/SimpleSocket.h" 


#ifdef WIN32
#pragma comment(lib,"Wsock32.lib") //at windows system driver
#endif

NS_SANGUO_MOBILE_GAME_BEGIN;



NetConnectionImpl::NetConnectionImpl()
{

}

NetConnectionImpl::~NetConnectionImpl()
{
    CC_SAFE_DELETE(pLoginServerThread);
    CC_SAFE_DELETE(pGameServerThread);
}

bool NetConnectionImpl::isValidState(const int error)
{
    if(error != CSimpleSocket::SocketSuccess 
    && error != CSimpleSocket::SocketEwouldblock )
    {
        LOG("Socket error,errroCode:%d",error);
        return false;
    }

    return true;
}


void NetConnectionImpl:: loginServerThreadMain(NetManager* pInstance)
{
    const NetAddr& config = pInstance->getLoginServerAddr();
    
    CSimpleSocket client; //init one socket begin
    client.Initialize();
    client.SetIsBlocking(false);
    client.SetConnectTimeout(8);
    client.SetReceiveTimeout(8);
    client.SetSendTimeout(8);


    LOG("[ConnectToLoginServer] Prepare to connect login server[ip:%s,port:%d].",config.serverAddr.c_str(),config.port);
    int error = CSimpleSocket::SocketSuccess;

    if (client.Open(config.serverAddr.c_str(), config.port))
    {
        LOG("[ConnectToLoginServer] Connected login server,waiting for response.");

        NetRingBuff *buff = new NetRingBuff();
        bool active = true;
        
        while (active) 
        {
            if(client.Select(0,30))
            {
                // read data
                while(client.Receive(MAX_RECV_BUFF_SIZE) > 0)
                {
                    buff->fill((char*)client.GetData(), client.GetBytesReceived());
                }
                
                if(buff->hasResponse())
                {
                    LOG("[ConnectToLoginServer] Received game server information.");
                    pInstance->changeNetState(kNetStateConnectedLoginServer);
                    NetNotify* notify(new NetNotify());
                    buff->pickResponse(kNetNotifyConnectedLoginServer, notify);
                    pInstance->appendNotify(notify); //pick by Lua in net loop(Timer) 
                    active = false;                             //when login successful, then close login socket. and then open game server socket.
                }
                
                error = client.GetSocketError();
                if( !isValidState(error) )
                {
                    break;
                }
            }
        }

        delete buff;
    }
    else
    {
        error = client.GetSocketError();
    }

    if( !isValidState(error))
    {
        LOG("[ConnectToLoginServer] Connect to login server failed. Reason:%d",error); //CSocketError
        pInstance->changeNetState(kNetStateNone);
        pInstance->appendNotify(kNetNotifyConnectingLoginServerFail);
    }

    client.Close();

}


void NetConnectionImpl::gameServerThreadMain(NetManager* pInstance)
{

    const NetAddr& config = pInstance->getGameServerAddr(); 
  
    CSimpleSocket client;
    client.Initialize();
    client.SetIsBlocking(false);
    client.SetConnectTimeout(8);
    client.SetReceiveTimeout(8);
    client.SetSendTimeout(8);
    

    LOG("[ConnectToServer] Prepare to connect server. [ip:%s, port:%d].", config.serverAddr.c_str(), config.port);
    int error = CSimpleSocket::SocketSuccess;
    bool isOpened = false;
    
    if (client.Open(config.serverAddr.c_str(), config.port))
    {
        LOG("[ConnectToServer] Connected server, start read & write thread.");
        pInstance->changeNetState(kNetStateConnectedGameServer);
        pInstance->appendNotify(kNetNotifyConnectedGameServer);
        isOpened = true;

        NetRingBuff *buff = new NetRingBuff();

        while (pInstance->getNetState() != kNetStateDisconnectingFromGameServer) 
        {
            error = client.GetSocketError();
            if( !isValidState(error) )
            {
                LOG("[ConnectToServer] Reading or writing server failed. Reason:%d",error);
                break;
            }
            
            if(client.Select(0, 30))
            {
                // recv data from server
                while(client.Receive(MAX_RECV_BUFF_SIZE) > 0)
                {
                    buff->fill((char*)client.GetData(), client.GetBytesReceived());
                }
                
                while(buff->hasResponse())
                {
                    NetNotify* notify(new NetNotify());
                    buff->pickResponse(kNetNotifyOnResponse, notify);
                    pInstance->appendNotify(notify);
                }
                
                error = client.GetSocketError();
                if( !isValidState(error) )
                {
                    break;
                }
                
                // send user req
                PtrUserReq req = pInstance->pickUserReq();
                while(req && isValidState(error))
                {
                    const int total = req->_szPkg;
                    _csassert(total != 0);
                    int szSent = 0;
                    while(szSent != total)
                    {
                        _csassert(szSent <= total);
                        int size = client.Send((const uint8*)req->_pData + szSent,total - szSent);
                        if(size > 0)
                        {
                            szSent += size;
                        }
                        else
                        {
                            error = client.GetSocketError();
                            break;
                        }
                    }
                    LOG("socke send success, size=%d, %d", total, szSent);
                    req = pInstance->pickUserReq();
                }
                
                if (!req)
                {
                #ifdef WIN32
                    Sleep(30);
                #else
                    usleep(50000); //50 Millisecond == 50000 microsecond
                #endif
                }

                if( !isValidState(error) )
                {
                    LOG("[ConnectToServer] --Reading or writing server failed. Reason:%d", error);
                    break;
                }
            }            
        } 

        delete buff;
    }
    else
    {
        // Open failed
        error = client.GetSocketError();
    }

    client.Close();
    
    if(isOpened)
    {
         LOG("[ConnectToServer] disconnect to server !!!"); 
        pInstance->changeNetState(kNetStateDisconnectedFromGameServer);
        pInstance->appendNotify(kNetNotifyDisconnectGameServer);
    }
    else
    {
        if(error != CSimpleSocket::SocketSuccess)
        {
            LOG("[ConnectToServer] Connect to server failed.Reason:%d",error);
            pInstance->changeNetState(kNetStateDisconnectingFromGameServer);
            pInstance->appendNotify(kNetNotifyConnectingGameServerFail);
        }
    }

}

void NetConnectionImpl::connectToLoginServer(const std::string& ip, int port, NetManager* pInstance)
{
    pLoginServerThread = new std::thread(&NetConnectionImpl::loginServerThreadMain, this, pInstance);
}

void NetConnectionImpl::connectToGameServer(const std::string& ip, int port, NetManager* pInstance)
{
    pGameServerThread = new std::thread(&NetConnectionImpl::gameServerThreadMain, this, pInstance);
}

bool NetConnectionImpl::purge(NetManager* pInstance)
{
    if(pInstance->getNetState() == kNetStateConnectingLoginServer)
    {
        pLoginServerThread->join();
    }
    else if(pInstance->getNetState() == kNetStateConnectedGameServer)
    {
        pInstance->changeNetState(kNetStateDisconnectingFromGameServer);
        pGameServerThread->join();
    }
    
    return true;
}

NS_SANGUO_MOBILE_GAME_END; //namespace

