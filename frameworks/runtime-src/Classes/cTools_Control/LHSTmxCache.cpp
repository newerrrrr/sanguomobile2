#include "LHSTmxCache.h"

USING_NS_CC;

static LHSTmxCache *s_LHSTmxCache = nullptr;

LHSTmxCache * LHSTmxCache::getInstance()
{
	if (!s_LHSTmxCache)
		s_LHSTmxCache = new (std::nothrow) LHSTmxCache();
	return s_LHSTmxCache;
}

void LHSTmxCache::destroyInstance()
{
	if (s_LHSTmxCache)
	{
		delete s_LHSTmxCache;
		s_LHSTmxCache = nullptr;
	}
}

LHSTmxCache::LHSTmxCache()
{
}

LHSTmxCache::~LHSTmxCache()
{
	this->removeAllTmxFile();
}

LHSTmxData * LHSTmxCache::loadTmxFile(const char * filename)
{
	std::string fullpath = FileUtils::getInstance()->fullPathForFilename(filename);
	if (fullpath.size() == 0)
		return nullptr;

	auto it = _cache.find(fullpath);
	if (it != _cache.end())
		return it->second;

	Data data = FileUtils::getInstance()->getDataFromFile(fullpath);
	if (data.isNull())
		return nullptr;

	LHSTmxData * tmxData = new (std::nothrow) LHSTmxData();
	if (!tmxData || !tmxData->_initWithTmxFileName(data, fullpath, filename))
	{
		CC_SAFE_DELETE(tmxData);
		return nullptr;
	}
	_cache.insert(std::pair<std::string, LHSTmxData*>(fullpath, tmxData));
	return tmxData;
}

void LHSTmxCache::removeTmxFileWithName(const char * filename)
{
	std::string fullpath = FileUtils::getInstance()->fullPathForFilename(filename);
	auto it = _cache.find(fullpath);
	if (it != _cache.end())
	{
		delete it->second;
		_cache.erase(it);
	}
}

void LHSTmxCache::removeAllTmxFile()
{
	for (auto it = _cache.begin(); it != _cache.end(); it++)
		delete it->second;
	_cache.clear();
}
