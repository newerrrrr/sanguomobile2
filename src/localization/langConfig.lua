
local langConfig = {}
setmetatable(langConfig,{__index = _G})
setfenv(1,langConfig)

--多语言配置
local countryKey = "zhtw"

--key 为地区,
--var 为对应的语言文件名称
local languagelist = {
    ["zhcn"] = "zhcn",-- 中文简体
    ["zhtw"] = "zhtw",--台湾繁体
    ["zhhk"] = "zhtw",--香港繁体（暂时和台湾同一个）
    ["zhmacau"] = "zhcn",
    ["ja"] = "ja",
}

--手机注册的地区号码
--key 为地区,
--var 为对应的手机区号
-- 如果地区没有配置，该地区将会禁用手机注册功能
local countryCodes = {
    ["zhcn"] = 86,
    ["zhtw"] = 886,
    ["zhhk"] = 852,
    ["zhmacau"] = 853,
}

function langConfig.getCountryCode()
  return countryKey 
end 

function langConfig.getCountryCodeList()
  return countryCodes 
end 

function langConfig.getLanguage()
  return languagelist[countryKey]
end

function langConfig.getLanguageList()
  return languagelist 
end 

return langConfig
