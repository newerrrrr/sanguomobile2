local saveCache = {}


--这里是初始化值(不能嵌套table)
local cacheData = {
	sound_music = 1,
    sound_sound = 1,
	power_save = 0,
	texture4_save = 0,
	textureFS_save = 0,
    banner_save = 0,
	tournament_count_save = 0,
	tournament_auto = 0,
    first_time_save = 0,          --秘书当天首次登录记录时间
    first_power_save = 0,         --秘书当天首次登录记录战力
    first_pj_save = 0,            --秘书当天首次登录记录评价
    voice_auto_play = 1,          --自动播放语音
    
    --rmb_charge_tip_once_{playerId} = 0,      --充值达到5000 tips提示一次
    --[[sloider_infantry = 0,
    sloider_cavalry = 0,
    sloider_archer = 0,
    sloider_catapults = 0,
    sloider_trap = 0,]]
}

local filePath = cc.FileUtils:getInstance():getWritablePath().."game_config.json"

local mt = {
        __index = cacheData,
        __newindex = function(t, k, v)
--			if cacheData[k] == nil then --注掉了，不指定key
--				assert(false)
--			end
			cacheData[k] = v
			
			--写入缓存
			local str = cjson.encode(cacheData)
	        require("game.gametools.saveTools").saveStringToFile(filePath,str)
        end
}

--读入缓存
local str = require("game.gametools.saveTools").getStringFromFile(filePath)
if str then
    local savedConfig = cjson.decode(str)
    for key, var in pairs(savedConfig) do
    	cacheData[key] = var
    end
end

setmetatable(saveCache, mt)

return saveCache
