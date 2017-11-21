--region NewFile_1.lua
--Author : luqingqing
--Date   : 2015/11/24
--此文件由[BabeLua]插件自动生成

local BagMode = class("BagMode")

function BagMode:ctor()

end

function BagMode:setNew(fun,isAsync)
    local tbl = {}
    
    if isAsync == nil then
        isAsync = false
    end
    
    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("Item/setNew", tbl, callback, isAsync)
end

function BagMode:itemUse(itemId, itemNum, fun)
    local itemInfo = g_data.item[itemId]
    if itemInfo then  --新手保护期间，不能使用战胜保护道具
       if itemInfo.item_original_id == 218 then 
           if g_PlayerMode.hasNewPlayerAvoid() then
               g_airBox.show(g_tr("battleAvoidUseCondition"))
               return
           end
       end
    end
    
    local function doUseItem()
        local tbl = 
        {
            ["itemId"] = itemId,
            ["itemNum"] = itemNum,
        }
    
        local function callback(result, data)
            if result == true then
                if fun ~= nil then
                    fun(data)
                end
            end
        end
    
        g_netCommand.send("Item/use", tbl, callback, false)
    end
    
    local needTip = g_playerShop.IsShouldNoticeToBuyOrUse(itemId)
    if needTip then
        g_msgBox.show(g_tr("bagUseResourceTip"), nil, 2, function(event)
            if event == 0 then
                doUseItem()
            end
        end,1)
    else
        doUseItem()
    end
end

function BagMode:shopBuy(shopId, fun)
    local tbl = 
    {
        ["shopId"] = shopId,
        ["itemNum"]= 1,
        ["use"] = 1,
    }

    local function onResult(result, msgData)
        if result == true then
            if fun then
                fun()
            end
        end
    end

    g_netCommand.send("Player/shopBuy", tbl, onResult, false)
end

function BagMode:changePosition(fun)
    local function onRecv(result, msgData)
			if(result==true)then
				require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                local data = g_PlayerMode.GetData()
				local function onChnageEnd()
					require("game.maplayer.worldMapLayer_bigMap").playRebuild()
				end
                require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex(cc.p(data.x, data.y), onChnageEnd)
                if fun ~= nil then
                    fun()
                end
			end
		end
		g_sgHttp.postData("map/changeCastleLocation",{ type = 2 , x = 0 , y = 0 },onRecv, false)
end

function BagMode:saleItem(id,fun)

    local tbl = 
    {
        ["id"] = id,
    }

    local function onResult(result, msgData)
        if result == true then
            if fun then
                fun()
            end
        end
    end

    g_netCommand.send("Player/sellEquipMaster", tbl, onResult, false)
end

return BagMode

--endregion
