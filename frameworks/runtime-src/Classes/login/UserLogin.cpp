//#include <sstream>
//#include <time.h>
#include "UserLogin.h"
#include "cocos2d.h"
#include "../common/Crypto.h"
#include "../common/Sha1.h"


#include "CCLuaEngine.h"

USING_NS_CC;

  UserLogin::~UserLogin() {
  }


  std::vector<int> UserLogin::transKey(const std::string &key) {
    std::vector<int> result;
    size_t i = 0;
    size_t len = key.length();
    while (i < len) {
      result.push_back(key[i]);
      i++;
    }
    return result;
  }

  std::string UserLogin::encode(const std::string &text, const std::string &key) {
    size_t len = key.length();
    std::vector<int> transkey = transKey(key);
    size_t i = 0;
    size_t textLen = text.length();
    std::string sink("");
    while (i < textLen) {
      char c=text[i];
      int temp=((int)c) + transkey[i % len];
      if(temp<=127){
         sink += (char)temp;
         sink += (char)0;
      }
	  else {
         sink += (char)127;
         sink +=(char)(temp-127);
      }
      i++;
    }
	char * buffer = nullptr;
	int size = base64Encode((const unsigned char *)sink.c_str(), sink.length(), &buffer);
	std::string str = buffer;
	if (buffer)
	{
		free(buffer);
	}
	return str;
  }

  std::string UserLogin::decode(const std::string &text, const std::string &key) {
	unsigned char * buffer = nullptr;
	int size = base64Decode((const unsigned char *)text.c_str(), text.length(), &buffer);
	std::string txt = (char*)buffer;
	if (buffer)
	{
		free(buffer);
	}
    size_t textLen = txt.length();
    size_t keyLen = key.length();
    std::vector<int> transkey = transKey(key);
    size_t i = 0;
    std::string sink("");
    while (i < textLen) {
      int ch = ((int) text[i]) - transkey[i % keyLen];
      sink += (char) ch;
      i++;
    }
    return sink;
  }

  std::string UserLogin::sha1(char* input)
  {
	  std::string str = Crypto::MD5String(input, (int)strlen(input));
	  std::string skey = CSHA1::sha1(str);
	  return skey;
  }