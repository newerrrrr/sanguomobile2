local localization = {}
local i18n = require("public.i18n.init")
local i18nLang = {}

--[[localization.languagelist = {
  ["zhtw"] = "zhtw",
  [cc.LANGUAGE_ENGLISH] = "en",-- 英文
  [cc.LANGUAGE_CHINESE] = "zhcn",-- 中文
  [cc.LANGUAGE_FRENCH] = "fr",-- 法文
  [cc.LANGUAGE_GERMAN] = "ge",-- 德语
  [cc.LANGUAGE_ITALIAN] = "it",-- 意大利
  [cc.LANGUAGE_RUSSIAN] = "ru",-- 俄罗斯
  [cc.LANGUAGE_SPANISH] = "sp",-- 西班牙语
  [cc.LANGUAGE_KOREAN] = "ko",-- 韩语
  [cc.LANGUAGE_JAPANESE] = "ja", -- 日语
  [cc.LANGUAGE_HUNGARIAN] = "hu",--  匈牙利语
  [cc.LANGUAGE_PORTUGUESE] = "po", -- 葡萄牙
  [cc.LANGUAGE_ARABIC] = "ar", -- 阿拉伯语
  }
  

local _language = "en"
-- 获取系统应用程序的当前语言环境
local currentLanguageType = cc.Application:getInstance():getCurrentLanguage()
_language = localization.languagelist[currentLanguageType]

]]

local langConfig = require("localization.langConfig") 
localization.languagelist = langConfig.getLanguageList()
localization.countryKey = langConfig.getCountryCode()
localization.language = localization.languagelist[localization.countryKey] or "zhcn" 

-- load language file
i18n.setLocale(localization.language)
local i18nPath = "localization."..localization.language
i18nLang = require(i18nPath)

function localization.loadDataLang(config)
  --加载数据表导出的数据
  for key, var in pairs(config) do
    local targetKey = tostring(var.id)
    assert(i18nLang[targetKey] == nil,"conflicted key name:"..targetKey)
    i18nLang[targetKey] = var.desc
  end
end

function localization.init()
  local i18nData = {}
  i18nData[localization.language] = i18nLang
  i18n.load(i18nData)
end

function localization.originalStr(key)
  return i18nLang[tostring(key)]
end

function localization.translate(key, data)
  local word = i18n(tostring(key), data)
  if nil == word then
    word = key
    word = string.gsub(word, "%%", " ") 
    printf("Can not found word for key:%s",key)
  end
  return word
end

return localization
