local allConfig = {}
setmetatable(allConfig,{__index = _G})
setfenv(1,allConfig)

local localization = require("public.localization")
local gobalDefine = require("data.data._GGobalDefine")
local list = gobalDefine.TableList
for key, var in pairs(list) do
  local k = string.lower(var)
  
  --加载相应的国际化语言
  local needLoad = true
  local isLanguageData = false
  for l_key, lang in pairs(localization.languagelist) do
    if lang == k then
       isLanguageData = true
       if k ~= localization.language then
          needLoad = false
          break
       end
    end
  end
  
  if needLoad then
    local config = require("data.data."..var)
    if isLanguageData then
      localization.loadDataLang(config)
    else
    	allConfig[k] = {}
    	for key, var in pairs(config) do
    		assert(var.id,"init data error:invaild id @allConfig."..k)
    		allConfig[k][var.id] = var
    	end
    	
    end
    config = nil
  end
end

--在这个时机初始化localization
localization.init()

return allConfig