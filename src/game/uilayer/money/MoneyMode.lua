--region MoneyMode.lua
--Author : luqingqing
--Date   : 2016/4/13
--此文件由[BabeLua]插件自动生成

local MoneyMode = class("MoneyMode")

function MoneyMode:ctor()

end

--接支付平台
function MoneyMode:sendRequest(orderId, productId)
    
    if orderId == nil or orderId == "" or productId == ni or productId == "" then
        assert(orderId,"orderId:"..orderId..",productId:"..productId)
        return
    end

    local luaj = require "cocos.cocos2d.luaj"
    local className="com/sthbig/manager/SDKManager"
    local params={orderId, productId}
    local arg="(Ljava/lang/String;Ljava/lang/String;)V"
    luaj.callStaticMethod(className, "sendMoneyRequest", params, arg)
end

function MoneyMode:RequestData(pid, aci)
    local tbl = 
    {
        ["id"] = pid,
        ["aci"] = aci,
    }

	local function onRecv(result, msgData)
		if(result==true)then
             self:sendRequest(msgData.order.orderId, msgData.order.productId)
		end
	end

	g_netCommand.send("order/createOrder", tbl, onRecv)
end

function MoneyMode:getGiftList(channel, fun)

    local tbl = 
    {
        ["channel"] = channel,
    }

	local function onRecv(result, data)
		if fun ~= nil then
            fun(data, result)
        end
	end

	g_netCommand.send("order/getGiftList", tbl, onRecv, true)
end

return MoneyMode

--endregion
