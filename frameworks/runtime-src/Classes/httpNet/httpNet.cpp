#include "httpNet.h"
#include "CCLuaEngine.h"
#include "../forLua/cToolsForLua.h"

#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
#include <unistd.h>
#endif // CC_TARGET_PLATFORM != CC_PLATFORM_WIN32


USING_NS_CC;

#define DEF_MIN_TIME	(3L)

static httpNet * s_httpNet = NULL;
std::mutex s_ObjectMutex;

httpNet * httpNet::getInstance()
{
	if (!s_httpNet)
	{
		s_ObjectMutex.lock();
		s_httpNet = new httpNet();
		s_ObjectMutex.unlock();
		s_httpNet->_inithttpNet();
	}
	return s_httpNet;
}


void httpNet::destroyInstance()
{
	if (s_httpNet)
	{
		httpNet * temp = s_httpNet;
		s_ObjectMutex.lock();
		s_httpNet = nullptr;
		s_ObjectMutex.unlock();
		temp->_clearhttpNet();
		delete temp;
	}
}


httpNet::httpNet()
	:_failedThing(true)
{
	
}


httpNet::~httpNet()
{
	
}


bool httpNet::_inithttpNet()
{
	bool Ret = false;
	do 
	{
		CC_BREAK_IF(CURLE_OK!=curl_global_init(CURL_GLOBAL_ALL));

		//curl_version_info_data * curlinfodata = curl_version_info(CURLVERSION_NOW);

		std::thread(&g_heepNet_thread_callback).detach();

		Ret = true;
	} while (false);
	return Ret;
}


void httpNet::_clearhttpNet()
{
	curl_global_cleanup();
}


static size_t download_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
	size_t sizes = size * nmemb;
	if (sizes > 0)
	{
		std::vector<char> * buffer = (std::vector<char>*)stream;
		buffer->insert(buffer->end(), (char*)ptr, (char*)ptr + sizes);
	}
	return sizes;
}


static int s_ITERATE_ID = 0;
void httpNet::Post(const char * urlString, const char * jsonString, int jsonSize, int luaCallbackFunc, int connectTime, int totalTime, bool useAsync, bool usePack, const char * headString /*= nullptr*/, const char * headSplitFlag /*= nullptr*/, const char * ssl_path /*= nullptr*/)
{
	int id = ++s_ITERATE_ID;
	msgThreadData * pTd = new msgThreadData();
	pTd->_id = id;
	pTd->_url = urlString;
	if (headString)
	{
		pTd->_head = headString;
		if (headSplitFlag)
			pTd->_headSplitFlag = headSplitFlag;
	}
	if (ssl_path)
	{
		pTd->_sslPath = ssl_path;
	}
	pTd->selectPack2 = false;
	pTd->_luaFunc = luaCallbackFunc;
	pTd->_ct = connectTime;
	pTd->_tt = totalTime;
	pTd->usePack = usePack;
	pTd->_postData.append(jsonString, (std::string::size_type)jsonSize);
	_msgQueueMutex.lock();
	_msgQueue.push_back(pTd);
	_msgQueueMutex.unlock();

	if (useAsync)
		return;
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	Sleep(35);
#else
	usleep(35000);
#endif
	while (this->_has(id))
	{
		this->updateLoop();
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
		Sleep(15);
#else
		usleep(15000);
#endif
	}
}

void httpNet::Post2(const char * urlString, const char * jsonString, int jsonSize, int luaCallbackFunc, int connectTime, int totalTime, bool useAsync, bool usePack, const char * headString /*= nullptr*/, const char * headSplitFlag /*= nullptr*/, const char * ssl_path /*= nullptr*/)
{
	int id = ++s_ITERATE_ID;
	msgThreadData * pTd = new msgThreadData();
	pTd->_id = id;
	pTd->_url = urlString;
	if (headString)
	{
		pTd->_head = headString;
		if (headSplitFlag)
			pTd->_headSplitFlag = headSplitFlag;
	}
	if (ssl_path)
	{
		pTd->_sslPath = ssl_path;
	}
	pTd->selectPack2 = true;
	pTd->_luaFunc = luaCallbackFunc;
	pTd->_ct = connectTime;
	pTd->_tt = totalTime;
	pTd->usePack = usePack;
	pTd->_postData.append(jsonString, (std::string::size_type)jsonSize);
	_msgQueueMutex.lock();
	_msgQueue.push_back(pTd);
	_msgQueueMutex.unlock();

	if (useAsync)
		return;
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	Sleep(35);
#else
	usleep(35000);
#endif
	while (this->_has(id))
	{
		this->updateLoop();
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
		Sleep(15);
#else
		usleep(15000);
#endif
	}
}

void httpNet::updateLoop()
{
	msgThreadData * pMtd = this->_pop_received();
	while (pMtd)
	{
		this->_process(pMtd);
		delete pMtd;
		pMtd = this->_pop_received();
	}
}


static std::vector<std::string> s_splitString(const std::string & src, const std::string & separate_character)
{
	std::vector<std::string> strs;
	int separate_characterLen = separate_character.size();
	int lastPosition = 0, index = std::string::npos;
	while (std::string::npos != (index = src.find(separate_character, lastPosition)))
	{
		strs.push_back(src.substr(lastPosition, index - lastPosition));
		lastPosition = index + separate_characterLen;
	}
	std::string lastString = src.substr(lastPosition);
	if (!lastString.empty())
		strs.push_back(lastString);
	return strs;
}


void g_heepNet_thread_callback()
{
	while (true)
	{
		s_ObjectMutex.lock();
		if (!s_httpNet)
		{
			s_ObjectMutex.unlock();
			break;
		}
		httpNet::msgThreadData * pMtd = nullptr;
		s_httpNet->_msgQueueMutex.lock();
		if (s_httpNet->_msgQueue.size() > 0)
			pMtd = s_httpNet->_msgQueue.front();
		s_httpNet->_msgQueueMutex.unlock();
		s_ObjectMutex.unlock();

		if (!pMtd)
		{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
			Sleep(50);
#else
			usleep(50000);
#endif
		}
		else
		{
			bool isComplete = false;
			pMtd->_statusMutex.lock();
			if (pMtd->_isGiveUp && !pMtd->_complete)
				pMtd->_complete = true;
			isComplete = pMtd->_complete;
			pMtd->_statusMutex.unlock();

			if (isComplete)
			{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
				Sleep(30);
#else
				usleep(30000);
#endif
			}
			else
			{
				time_t currentTime = time(nullptr);
				long subTime = (long)(currentTime - pMtd->_createTime);
				if (subTime > 0L)
				{
					if (pMtd->_tt > DEF_MIN_TIME)
					{
						pMtd->_tt -= subTime;
						if (pMtd->_tt < DEF_MIN_TIME)
							pMtd->_tt = DEF_MIN_TIME;
					}
					if (pMtd->_ct > DEF_MIN_TIME)
					{
						pMtd->_ct -= subTime;
						if (pMtd->_ct < DEF_MIN_TIME)
							pMtd->_ct = DEF_MIN_TIME;
					}
				}

				bool isSucceed = false;
				CURL * easy_handle = NULL;
				curl_slist * slist = nullptr;
				std::string msg_data = "";
				do
				{
					easy_handle = curl_easy_init();
					CC_BREAK_IF(!easy_handle);
					if (!pMtd->_sslPath.empty())
					{
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYPEER, 1L));
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYHOST, 2L));
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_CAINFO, pMtd->_sslPath.c_str()));
					}
					else
					{
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYPEER, 0L));
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYHOST, 0L));
					}
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_NOSIGNAL, 1L));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_ACCEPT_ENCODING, ""));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_TIMEOUT, (long)(pMtd->_tt)));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_CONNECTTIMEOUT, (long)(pMtd->_ct)));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_RESUME_FROM, 0L));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_POST, 1L));
					long post_size = 0L;
					if (pMtd->usePack)
					{
						if (pMtd->selectPack2)
						{
							msg_data = cToolsForLua::msg_pack2(pMtd->_postData);
						}
						else
						{
							msg_data = cToolsForLua::msg_pack(pMtd->_postData);
						}
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_POSTFIELDS, msg_data.c_str()));
						post_size = (long)msg_data.size();
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_POSTFIELDSIZE, post_size));
					}
					else
					{
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_POSTFIELDS, pMtd->_postData.c_str()));
						post_size = (long)(pMtd->_postData.size());
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_POSTFIELDSIZE, post_size));
					}
					if (post_size > 1024)
					{
						slist = curl_slist_append(slist, "Expect:");
					}
					if (!pMtd->_head.empty())
					{
						if (!pMtd->_headSplitFlag.empty())
						{
							std::vector<std::string> head_vector = s_splitString(pMtd->_head, pMtd->_headSplitFlag);
							for (std::vector<std::string>::iterator it = head_vector.begin(); it != head_vector.end(); it++)
							{
								if (!(*it).empty())
									slist = curl_slist_append(slist, (*it).c_str());
							}
						}
						else
						{
							slist = curl_slist_append(slist, pMtd->_head.c_str());
						}	
					}
					if (slist)
					{
						CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_HTTPHEADER, slist));
					}
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_HEADER, 0L));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_NOBODY, 0L));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_URL, pMtd->_url.c_str()));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_WRITEFUNCTION, &download_callback));
					pMtd->_responseData.reserve(16384);
					pMtd->_responseData.clear();
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_WRITEDATA, &(pMtd->_responseData)));
					CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_NOPROGRESS, 1L));
					pMtd->_performCode = curl_easy_perform(easy_handle);
					if (pMtd->_performCode == CURLE_OK)
						CC_BREAK_IF(CURLE_OK != curl_easy_getinfo(easy_handle, CURLINFO_RESPONSE_CODE, &(pMtd->_responseCode)));
					CC_BREAK_IF(pMtd->_responseCode != 200);
					isSucceed = true;
				} while (false);
				if (easy_handle)
					curl_easy_cleanup(easy_handle);
				if (slist)
					curl_slist_free_all(slist);
				if (!isSucceed)
				{
					s_ObjectMutex.lock();
					if (s_httpNet && s_httpNet->_failedThing)
						s_httpNet->_giveUpAllPost(pMtd);
					s_ObjectMutex.unlock();
				}
				pMtd->_statusMutex.lock();
				pMtd->_succeed = isSucceed;
				pMtd->_complete = true;
				pMtd->_statusMutex.unlock();
			}
		}
	}
}


httpNet::msgThreadData * httpNet::_pop_received()
{
	msgThreadData * ret = nullptr;
	_msgQueueMutex.lock();
	if (_msgQueue.size() > 0)
	{
		ret = _msgQueue.front();
		ret->_statusMutex.lock();
		bool isComplete = ret->_complete;
		ret->_statusMutex.unlock();
		if (isComplete)
			_msgQueue.pop_front();
		else
			ret = nullptr;
	}
	_msgQueueMutex.unlock();
	return ret;
}


void httpNet::_process(msgThreadData * pMtd)
{
	if (pMtd->_isDiscard == false)
	{
		std::string dataString = "";
		std::stringstream s;
		s.str("");
		for (unsigned int i = 0; i < pMtd->_responseData.size(); i++)
			s << (pMtd->_responseData)[i];
		dataString = s.str();
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->pushBoolean(pMtd->_succeed);
		if (pMtd->_succeed && pMtd->usePack)
		{
			if (pMtd->selectPack2)
			{
				int sss = 0;
				dataString = cToolsForLua::msg_unpack2_new(dataString, &sss);
			}
			else
			{
				dataString = cToolsForLua::msg_unpack(dataString);
			}
		}
		pStack->pushString(dataString.c_str(), dataString.size());
		pStack->pushInt(pMtd->_performCode);
		pStack->pushLong(pMtd->_responseCode);
		pStack->executeFunctionByHandler(pMtd->_luaFunc, 4);
		pStack->clean();
	}
	cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(pMtd->_luaFunc);
}


bool httpNet::_has(int id)
{
	bool ret = false;
	_msgQueueMutex.lock();
	for (auto it = _msgQueue.begin(); it != _msgQueue.end(); it++)
	{
		if ((*it)->_id == id)
		{
			ret = true;
			break;
		}
	}
	_msgQueueMutex.unlock();
	return ret;
}

void httpNet::DiscardAllPost()
{
	_msgQueueMutex.lock();
	for (auto it = _msgQueue.begin(); it != _msgQueue.end();it++)
	{
		(*it)->_statusMutex.lock();
		(*it)->_isDiscard = true;
		(*it)->_statusMutex.unlock();
	}
	_msgQueueMutex.unlock();
}

void httpNet::SetFailedThing(bool var)
{
	_failedThing = var;
}

void httpNet::_giveUpAllPost(msgThreadData * p)
{
	_msgQueueMutex.lock();
	for (auto it = _msgQueue.begin(); it != _msgQueue.end(); it++)
	{
		if ((*it) != p)
		{
			(*it)->_statusMutex.lock();
			(*it)->_isGiveUp = true;
			(*it)->_statusMutex.unlock();
		}
	}
	_msgQueueMutex.unlock();
}


void httpNet::Get(const char * urlString, int luaCallbackFunc, int connectTime /*= 7*/, int totalTime /*= 7*/, const char * headString /*= nullptr*/, const char * headSplitFlag /*= nullptr*/, const char * ssl_path /*= nullptr*/)
{
	bool isSucceed = false;
	std::vector<char> getDataBuffer;
	CURL * easy_handle = NULL;
	curl_slist * slist = nullptr;
	do
	{
		easy_handle = curl_easy_init();
		CC_BREAK_IF(!easy_handle);
		if (ssl_path && strcmp(ssl_path,""))
		{
			CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYPEER, 1L));
			CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYHOST, 2L));
			CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_CAINFO, ssl_path));
		}
		else 
		{
			CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYPEER, 0L));
			CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYHOST, 0L));
		}
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_NOSIGNAL, 1L));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_ACCEPT_ENCODING, ""));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_TIMEOUT, (long)(totalTime)));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_CONNECTTIMEOUT, (long)(connectTime)));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_RESUME_FROM, 0L));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_PORT, 0L));
		std::string headStr = ((headString) ? (headString) : (""));
		std::string headSplitFlagStr = ((headSplitFlag) ? (headSplitFlag) : (""));
		if (!headStr.empty())
		{
			if (!headSplitFlagStr.empty())
			{
				std::vector<std::string> head_vector = s_splitString(headStr, headSplitFlagStr);
				for (std::vector<std::string>::iterator it = head_vector.begin(); it != head_vector.end(); it++)
				{
					if (!(*it).empty())
						slist = curl_slist_append(slist, (*it).c_str());
				}
			}
			else
			{
				slist = curl_slist_append(slist, headStr.c_str());
			}
		}
		if (slist)
		{
			CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_HTTPHEADER, slist));
		}
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_HEADER, 0L));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_NOBODY, 0L));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_URL, urlString));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_WRITEFUNCTION, &download_callback));
		getDataBuffer.reserve(4096);
		getDataBuffer.clear();
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_WRITEDATA, &getDataBuffer));
		CC_BREAK_IF(CURLE_OK != curl_easy_setopt(easy_handle, CURLOPT_NOPROGRESS, 1L));
		long responseCode = 0;
		if (CURLE_OK == curl_easy_perform(easy_handle))
			CC_BREAK_IF(CURLE_OK != curl_easy_getinfo(easy_handle, CURLINFO_RESPONSE_CODE, &(responseCode)));
		CC_BREAK_IF(responseCode != 200);
		isSucceed = true;
	} while (false);
	if (easy_handle)
		curl_easy_cleanup(easy_handle);
	if (slist)
		curl_slist_free_all(slist);
	std::string dataString = "";
	std::stringstream s;
	s.str("");
	for (unsigned int i = 0; i < getDataBuffer.size(); i++)
		s << (getDataBuffer)[i];
	dataString = s.str();
	auto engine = LuaEngine::getInstance();
	auto pStack = engine->getLuaStack();
	pStack->pushBoolean(isSucceed);
	pStack->pushString(dataString.c_str(), dataString.size());
	pStack->executeFunctionByHandler(luaCallbackFunc, 2);
	pStack->clean();
	cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(luaCallbackFunc);
}