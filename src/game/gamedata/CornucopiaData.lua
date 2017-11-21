local CornucopiaData = {}
setmetatable(CornucopiaData,{__index = _G})
setfenv(1,CornucopiaData)

local baseData = nil

local baseCombineView = nil

local baseContentView = nil

function SetData(value)
	baseData = value
end

function SetCombineView(value)
	baseCombineView = value
end

function SetContentView(value)
	baseContentView = value
end

function NotifyCombineUpdateShow(data)
	if baseCombineView ~= nil then
		baseCombineView:show(data)
	end
end

function CombineGodArmor(callback)
	local function onRecv(result, msgData)
        if(result==true)then
            NotifyCombineUpdateShow(msgData)
            g_gameCommon.dispatchEvent(g_Consts.CustomEvent.DrawCardUpdateTip,{})
        end
        
        if callback then
            callback()
        end
    end
    g_sgHttp.postData("Pub/combineGodArmor",{},onRecv,true)
end

--multi_flag 当前抽卡的类型 0 单抽 1 十连
--type 活动类型 1 占星 2 天陨
--free_flag 当前是否免费，0 不免费 1 免费
--use_item_flag 0 不使用 1使用
function TreasureBowl(multi_flag, type, free_flag, use_item_flag,callback)
	local tbl = {
		["multi_flag"] = multi_flag,
		["type"] = type,
		["free_flag"] = free_flag,
		["use_item_flag"] = use_item_flag,
		["steps"] = g_guideManager.getToSaveStepId(),
	}

	local function onRecv(result, msgData)
        if(result==true)then
            if callback then
            	callback(msgData)
        	end
        end
    end
    g_sgHttp.postData("Player/treasureBowl",tbl,onRecv)
end

function sacrificeToHeaven(multi_flag, free_flag, camp_id, use_item_flag, callback)
    local tbl = {
        ["multi_flag"] = multi_flag,
        ["free_flag"] = free_flag,
        ["use_item_flag"] = use_item_flag,
        ["camp_id"] = camp_id,
        ["steps"] = g_guideManager.getToSaveStepId(),
    }

    local function onRecv(result, msgData)
        if(result==true)then
            if callback then
                callback(msgData)
                g_gameCommon.dispatchEvent(g_Consts.CustomEvent.DrawCardUpdateTip,{})
            end
        end
    end
    
    g_sgHttp.postData("player/sacrificeToHeaven",tbl,onRecv)
end

function ShowPop()
    local playerInfo = g_playerInfoData.GetData()

    local conditionBuildConfigId = tonumber(g_data.starting[95].data)
    local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(conditionBuildConfigId)
    if enoughCount > 0 then

        local startingData = tonumber(g_data.starting[90].data)

        if g_clock.getCurServerTime() - playerInfo.bowl_type1_last_time >= startingData then
            return true
        end

        if g_BagMode.findItemNumberById(52001) > 0 then
            return true
        end

        startingData = tonumber(g_data.starting[92].data)

        if g_clock.getCurServerTime() - playerInfo.bowl_type2_last_time >= startingData then
            return true
        end

        if g_BagMode.findItemNumberById(52002) > 0 then
            return true
        end

        if g_PlayerBuildMode.getMainCityBuilding_lv() >= tonumber(g_data.starting[106].data) then
            if playerInfo.sacrifice_free_flag == 1 then
                return true
            else
                local num = g_BagMode.findItemNumberById(52005)
                if num > 0 then
                    return true
                end
            end
        end
    end

    return false
end

return CornucopiaData