

#ifndef _H_NETCOMMON_H_  
#define _H_NETCOMMON_H_  

//#include "PassiveSocket.h"
#include <string>
#include <memory>
#include <cassert>


#include "cocos2d.h"
#define LOG CCLOG


/*
#define NS_SANGUO_MOBILE_GAME_BEGIN namespace HlbGame {
#define NS_SANGUO_MOBILE_GAME_END };
#define USING_NS_HLB_GAME using namespace HlbGame;
*/

#define NS_SANGUO_MOBILE_GAME_BEGIN
#define NS_SANGUO_MOBILE_GAME_END


NS_SANGUO_MOBILE_GAME_BEGIN;


enum {
    MAX_BUFF_SIZE = 256 * 1024,
    MAX_RECV_BUFF_SIZE = 1024
};

typedef enum {
    kNetStateNone,
    kNetStateConnectingLoginServer,
    kNetStateConnectedLoginServer,
    kNetStateConnectingGameServer,
    kNetStateConnectedGameServer,
    kNetStateDisconnectingFromGameServer,
    kNetStateDisconnectedFromGameServer,
}NetStateEnum;


typedef enum {
    kNetReqNone = 100001,
    kNetReqConnectLoginServer,
    kNetReqConnectGameServer,
    kNetReqSendData,
    kNetReqDisconnect    
} UserReqEnum;

    
typedef enum {
    kNetNotifyNone = 200001,
    kNetNotifyConnectingLoginServerFail,
    kNetNotifyConnectedLoginServer,
    kNetNotifyConnectingGameServerFail,
    kNetNotifyConnectedGameServer, 
    kNetNotifyDisconnectGameServer,
    kNetNotifyOnResponse, // for data send/recv
} NetNotifyEnum;


enum {
    kHeaderSize = 12
};

//pkg header
#pragma pack(1)
typedef struct NetHeaderData
{
    NetHeaderData() :msgId(0),szBody(0){ memset(strTag, 0, sizeof(strTag)); };
    char strTag[4];
    int msgId;
    int szBody;
    
} NetHeaderData;
#pragma pack()



typedef struct
{
    std::string serverAddr;
    short int port;
} NetAddr;


// NetNotify: server response --> client 
class NetNotify
{
public:
    NetNotifyEnum _notify;
    int _msgId;
    std::string _data;

    NetNotify():_notify(kNetNotifyNone), _msgId(0){}

    NetNotify(NetNotifyEnum notify):_notify(notify), _msgId(0){}

    NetNotify(NetNotifyEnum notify, int msgId, const char* pData):_notify(notify), _msgId(msgId),  _data(pData){}

    NetNotify(NetNotifyEnum notify, int msgId, const std::string& data):_notify(notify), _msgId(msgId),  _data(data){}
};



//UserReq:  client req --> server ,   format: pkg_header + json_data 
class UserReq
{
public:
    UserReqEnum _req;
    char* _pData;
    int _szBody;
    int _szPkg;

    UserReq(UserReqEnum req):_req(req), _pData(nullptr), _szBody(0),_szPkg(0){}

    UserReq(UserReqEnum req, int msgId, const char* pBody,int szBody):_req(req), _pData(nullptr),_szBody(szBody)
    {
        
        _szPkg = _szBody + kHeaderSize;
        _pData = new char[_szPkg + 1];
        
        // pack header
        NetHeaderData header;
        memcpy(header.strTag, "SGMB", 4);
        header.msgId = msgId;
        header.szBody = _szBody;
        
        memcpy(_pData,&header,kHeaderSize);
        memcpy(_pData + kHeaderSize,  pBody, _szBody);
        _pData[_szPkg] = 0;
    }

    ~UserReq(){ delete[] _pData;}
};


typedef std::shared_ptr<NetNotify> PtrNetNotify;
typedef std::shared_ptr<UserReq> PtrUserReq;


class NetRingBuff
{
private:
    char m_buff[MAX_BUFF_SIZE];
    size_t m_begin;
    size_t m_end;
    size_t m_size;

    // for parsing
    NetHeaderData m_tempHeader;
    bool m_pickedHeader;

public:

	NetRingBuff() :m_begin(0), m_end(0), m_size(0), m_pickedHeader(false)
    {
		memset(m_buff, 0, sizeof(char) * MAX_BUFF_SIZE);
    }

    void fill(char* pSrc,size_t len)
    {
        assert(len != 0);
        assert(MAX_BUFF_SIZE - m_size >= len);

        if(m_end + len > MAX_BUFF_SIZE)
        {
            assert(m_end < MAX_BUFF_SIZE);
            size_t count = MAX_BUFF_SIZE - m_end;
            memcpy(m_buff + m_end,pSrc,count);
            assert(len > count);
            memcpy(m_buff,pSrc + count,len - count);
        }
        else
        {
            memcpy(m_buff + m_end,pSrc,len);
        }
        m_size += len;
        m_end = m_begin + m_size;
        m_end = (m_end >= MAX_BUFF_SIZE ? m_end - MAX_BUFF_SIZE : m_end);
    }

    void read(char* pDst, size_t len)
    {
        assert(len != 0);
        assert(m_size >= len);
        if(m_begin + len > MAX_BUFF_SIZE)
        {
            size_t count = MAX_BUFF_SIZE - m_begin;
            memcpy(pDst,m_buff + m_begin,count);
            assert(len > count);
            memcpy(pDst + count,m_buff,len - count);
        }
        else
        {
            memcpy(pDst,m_buff + m_begin,len);
        }
        assert(m_size >= len);
        m_size -= len;
        m_begin += len;
        m_begin = (m_begin >= MAX_BUFF_SIZE ? m_begin - MAX_BUFF_SIZE : m_begin);
    }

    bool hasHeader() const
    {
        if(m_size < kHeaderSize) 
        {
            return false;
        }
        return true;
    }

    void pickHeader() 
    {
        read((char*)&m_tempHeader,kHeaderSize);
        m_pickedHeader = true;
    }

    bool hasResponse()
    {
        if(!m_pickedHeader)
        {
            if(!hasHeader()) 
            {
                return false;
            }
            pickHeader();
        }

        //has error while  buff size < except body size
        if(m_size < m_tempHeader.szBody) return false;
        return true;
    }

    void pickResponse(NetNotifyEnum type, NetNotify* pNotify)
    {
        assert(m_pickedHeader);
        pNotify->_notify = type;
        pNotify->_msgId = m_tempHeader.msgId;
        if(m_tempHeader.szBody != 0)
        {
            // pkg body has data
            char* buff = new char[m_tempHeader.szBody + 1];
            read(buff,m_tempHeader.szBody);
            buff[m_tempHeader.szBody] = 0;    //EOF
            pNotify->_data.assign(buff, m_tempHeader.szBody);
        }
        m_pickedHeader = false;
    }

};


NS_SANGUO_MOBILE_GAME_END; //namespace


#endif //_H_NETCOMMON_H_  

