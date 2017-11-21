
#ifndef CRYPTO_H
#define CRYPTO_H

#include "cocos2d.h"

using namespace std;


class Crypto
{
public:
    static const int MD5_BUFFER_LENGTH = 16;
  
    static void MD5(void* input, int inputLength,unsigned char* output);

    static void MD5File(const char* path, unsigned char* output);
        
    static std::string MD5String(void* input, int inputLength);

    static char* bin2hex(unsigned char* bin, int binLength);
};

#endif // CRYPTO_H