
#ifndef sgHttp_h
#define sgHttp_h 

#include "cocos2d.h"
#include "network/HttpClient.h"

#include <thread>
#include "CAutoLock.h"

typedef std::function<void(bool result, std::string &rspData)> sgHttpCallFunc;

class userReq
{
public:
    int _sectionId;
    sgHttpCallFunc _callback; 
    userReq(){};
    userReq(int sectionId, sgHttpCallFunc callfunc):_sectionId(sectionId), _callback(callfunc) {};
};


typedef std::vector<userReq *> userReqArray;
 
class sgHttp
{
public:
    sgHttp();
    static sgHttp* instance();
    
    void getData(const char *url, sgHttpCallFunc callback);
    
    void postData(const char *url, const char* data, int dataLen, sgHttpCallFunc callback);
    
private:
    void onResponseCallback(cocos2d::network::HttpClient *sender, cocos2d::network::HttpResponse *response);
    userReqArray m_userReq;
    int m_sectionId;

    std::mutex sUserReqLock;
};






#endif //sgHttp_h
