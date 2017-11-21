local UseActions = class("UseActions")

--消耗道具的方法
function UseActions:useItem(useitemid,useitemcount)
    
    local res
    local function callback(result , data)
        if result == true then
            res = data
        end
    end
    g_sgHttp.postData("item/use",{ itemId = useitemid , itemNum = useitemcount }, callback)

    return res
end

--使用行军加速道具
function UseActions:useQuickItem(queueServerDataID,itemID)
    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()

    local res = false
    local function onRecv(result, msgData)
		if(result==true)then
            res = result
            if mapStatus == changeMapScene.m_MapEnum.guildwar then
			   			 	require "game.mapguildwar.worldMapLayer_bigMap".requestMapAllData_Manual()
			   		elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
			   			 	require "game.mapcitybattle.worldMapLayer_bigMap".requestMapAllData_Manual()
            else
                require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
            end
		end
	end
    if mapStatus == changeMapScene.m_MapEnum.guildwar then
        g_sgHttp.postData("cross/acceQueue",{ queueId = queueServerDataID , itemId = itemID },onRecv)
    elseif mapStatus == changeMapScene.m_MapEnum.guildwar then
        g_sgHttp.postData("City_Battle/acceQueue",{ queueId = queueServerDataID , itemId = itemID },onRecv)
    else
        g_sgHttp.postData("map/acceQueue",{ queueId = queueServerDataID , itemId = itemID },onRecv)
    end
    return res
end

--使用医疗加速道具
function UseActions:useHealthItem(itemtb)
    local res
    local function callback(result , msgData)
        if result == true then
            res = msgData
        end
    end
    g_sgHttp.postData("soldier/doCureInjuredSoldierWithGemOrItem",{ itemList = itemtb }, callback)

    return res
end

--[[* ```php
	 * /build/accelerate/
     * postData: json={"position":"","type":"1-金币加速 2-免费加速 3-道具加速","itemId":"加速道具id","num":"道具数量"}
     * return: json{}
	 * ```
]]

--建筑升级道具
function UseActions:useBuildItem(itemtb,pos)
    
    local res = false

    local function callback(result , msgData)
        res = result
        if result == true then
            g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
			require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
        end
    end
    
    g_sgHttp.postData("build/accelerate",{ position = pos,type = 3, itemList = itemtb }, callback)

    return res
end

    --[[
    * ```php
    * /soldier/accelerateRecruit/
    * postData: json={"position":"","type":"1-金币加速 2-道具加速","itemId":"加速道具id","num":"道具数量"}
    * return: json{"PlayerSoldier":""}
    * ```]]

--造兵加速
function UseActions:useSoldierItem(itemtb,pos)
    
    local res
    local function callback(result , msgData)
        if result == true then
            res = msgData
        end
    end

    g_sgHttp.postData("soldier/accelerateRecruit",{ position = pos,type = 2, itemList = itemtb }, callback)

    return res
end
--陷阱加速
function UseActions:useTrapItem(itemtb,pos)
    local res
    local function callback(result , msgData)
        if result == true then
            res = msgData
            --dump(res)
        end
    end

    g_sgHttp.postData("trap/accelerateProduce",{ position = pos,type = 2, itemList = itemtb }, callback)

    return res
end

--scienceTypeId,type:3,itemId,itemNum
--研究加速
function UseActions:useStudyItem(itemtb,typeid)
    local res
    local function callback(result , msgData)
        if result == true then
            res = msgData
            dump(res)
        end
    end

    g_sgHttp.postData("science/accelerate",{ scienceTypeId = typeid, type = 3, itemList = itemtb }, callback)
    return res
end

--从商店购买道具
function UseActions:shopBuy(shopId,itemNum)
    local res
    local function onResult(result , msgData)
        if result == true then
            res = result
            dump(msgData)
        end
    end

    g_sgHttp.postData("Player/shopBuy",{shopId = shopId ,itemNum = itemNum},onResult)

    return res
end

return UseActions