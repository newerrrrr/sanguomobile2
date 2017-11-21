
local share_plugin = nil

local function onShareResult(code, msg)
    print("on share result listener.")
    print("code:"..code..",msg:"..msg)
    if code == ShareResultCode.kShareSuccess then
        --do
    elseif code == ShareResultCode.kShareFail then
        --do
    elseif code == ShareResultCode.kShareCancel then
        --do
    elseif code == ShareResultCode.kShareNetworkError then
        --do
    end
    
    g_autoCallback.addCocosList( function ()
		if g_logicDebug == true then
			g_airBox.show("code:"..code..",msg:"..msg)
		end
		local data = {}
		data.type = code
		--g_gameCommon.dispatchEvent(g_Consts.CustomEvent.AnySdkUserActionResult,data)
	end,0.1)
end

local Share = class("Share")
function Share:ctor()
	share_plugin = AgentManager:getInstance():getSharePlugin()
	if share_plugin ~= nil then
	    share_plugin:setResultListener(onShareResult)
	end
end

function Share:share()
	if share_plugin ~= nil then
        local info = {
            title = "ShareSDK是一个神奇的SDK",
            titleUrl = "http://sharesdk.cn",
            site = "ShareSDK",
            siteUrl = "http://sharesdk.cn",
            text = "ShareSDK集成了简单、支持如微信、新浪微博、腾讯微博等社交平台",
            comment = "无",
        }
        share_plugin:share(info)
	end
end

return Share