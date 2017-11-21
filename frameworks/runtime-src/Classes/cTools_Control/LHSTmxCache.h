#ifndef __LHSTMXCACHE_H__
#define __LHSTMXCACHE_H__

#include "cocos2d.h"
#include "LHSTmxData.h"


class LHSTmxCache
{
private:
	LHSTmxCache();
	~LHSTmxCache();

public:

	static LHSTmxCache * getInstance();
	static void destroyInstance();


	LHSTmxData * loadTmxFile(const char * filename);

	void removeTmxFileWithName(const char * filename);

	void removeAllTmxFile();

private:
	std::map<std::string, LHSTmxData*> _cache;
};



#endif //__LHSTMXCACHE_H__