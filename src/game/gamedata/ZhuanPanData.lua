--region NewFile_1.lua
--Author : admin
--Date   : 2016/7/4
--此文件由[BabeLua]插件自动生成

local ZhuanPanData = {}
setmetatable(ZhuanPanData,{__index = _G})
setfenv(1, ZhuanPanData)

local baseZhuanPanData = nil
local baseFanPaiData = nil

function NotificationUpdateShow()
    
end

function SetZhuanPanData(data)
    baseZhuanPanData = data
end

function SetFanPaiData(data)
    baseFanPaiData = data
end

function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
            --{"PlayerLotteryInfo":{"id":1,"player_id":100993,"free_times":0,"current_position":8,"last_date":0,"coin_num":134999,"jade_num":26,"draw_card_id":238,"create_time":1466229503},"PlayerDrawCard":{"id":238,"player_id":100993,"chest_type_id":12,"card_order":"[101,102,107,100,108,103,104,105,106]","open_order":96312457,"status":1,"is_start":1,"create_time":1467618519}
            --dump(msgData)
			--SetData(msgData)
			SetZhuanPanData(msgData.PlayerLotteryInfo)
            SetFanPaiData(msgData.PlayerDrawCard)

            NotificationUpdateShow()
		end
	end

	g_sgHttp.postData("Lottery/checkPlayerLotteryInfo",nil,onRecv)
	
    return ret
end

function RequestAsyData(callbcak)
    local function onRecv(result, msgData)
		if(result==true)then
			SetZhuanPanData(msgData.PlayerLotteryInfo)
            SetFanPaiData(msgData.PlayerDrawCard)
		end

        if callbcak then
            callbcak(result, msgData)
        end
	end
	g_sgHttp.postData("Lottery/checkPlayerLotteryInfo",nil,onRecv,true)
end


function GetZhuanPanData()
	if baseZhuanPanData == nil then
		RequestData()
	end
	return baseZhuanPanData
end

function GetFanPaiData()
    if baseFanPaiData == nil then
		RequestData()
	end
	return baseFanPaiData
end


return ZhuanPanData
--endregion
