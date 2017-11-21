

#include "sgHttp.h"


USING_NS_CC;
using namespace cocos2d::network;

static sgHttp* _pInstance  = nullptr;

sgHttp::sgHttp():m_sectionId(0)
{

}

sgHttp* sgHttp::instance()
{
    if (!_pInstance)
    {
        _pInstance = new sgHttp();
    }
    return _pInstance;
}


void sgHttp::getData(const char *url, sgHttpCallFunc callback)
{
    CAutoLock lock(&sUserReqLock);
    
    m_sectionId += 1;
    std::string tag = StringUtils::format("%d", m_sectionId);

    HttpRequest* request = new (std::nothrow) HttpRequest();
    request->setUrl(url);
    request->setRequestType(HttpRequest::Type::GET);
    request->setResponseCallback(CC_CALLBACK_2(sgHttp::onResponseCallback, this));
    request->setTag(tag.c_str());
    HttpClient::getInstance()->send(request);
    request->release(); 

    m_userReq.push_back(new userReq(m_sectionId, callback));
}

void sgHttp::postData(const char *url, const char* data, int dataLen, sgHttpCallFunc callback)
{
    CAutoLock lock(&sUserReqLock);
    
    m_sectionId += 1;
    std::string tag = StringUtils::format("%d", m_sectionId);
    
    HttpRequest* request = new (std::nothrow) HttpRequest();
    request->setUrl(url);
    
//    std::vector<std::string> headers;
//    headers.push_back("Content-Type: application/x-www-form-urlencoded; charset=utf-8");
//    request->setHeaders(headers);
    
    request->setRequestType(HttpRequest::Type::POST);
    request->setResponseCallback(CC_CALLBACK_2(sgHttp::onResponseCallback, this));    
    request->setRequestData(data, dataLen);
    request->setTag(tag.c_str());
    HttpClient::getInstance()->send(request);
    request->release();

    m_userReq.push_back(new userReq(m_sectionId, callback));
}

void sgHttp::onResponseCallback(HttpClient *sender, HttpResponse *response)
{
    CAutoLock lock(&sUserReqLock);
    
    if (!response)
    {
        return;
    }

    int index = atoi(response->getHttpRequest()->getTag());
    userReq *req = nullptr;
    size_t len = m_userReq.size();
    for (size_t i =0; i < len; i ++) 
    {
        if (m_userReq[i]->_sectionId == index)
        {
            req = m_userReq[i];
            m_userReq.erase(m_userReq.begin()+i);
            break;
        }
    }
    
    if (req)
    {
        long statusCode = response->getResponseCode();
        CCLOG(" sgHttp resonse code: %d", statusCode);
        std::string data;
        if (response->isSucceed())
        {
            std::vector<char> *buffer = response->getResponseData();
           data = std::string(buffer->begin(), buffer->end());
           req->_callback(true, data);
        }
        else 
        {
            CCLOG("sgHttp resonse failed, error buffer: %s", response->getErrorBuffer());
            
            req->_callback(false, data);
        }
        
        delete req;
    }
    
}

