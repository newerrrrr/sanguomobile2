
--公告
local NoticeLayer = class("NoticeLayer",require("game.uilayer.base.BaseLayer"))
local str 

function NoticeLayer:ctor()
	NoticeLayer.super.ctor(self) 
end 

function NoticeLayer:onEnter() 
	print("NoticeLayer:onEnter") 
	local layer = g_gameTools.LoadCocosUI("notice_main.csb",5) 
	if layer then 
		self:addChild(layer) 
		self:initBinding(layer:getChildByName("scale_node"))
		self:showContent()
	end 
end 

function NoticeLayer:onExit() 
	
end 

function NoticeLayer:initBinding(scaleNode)
	scaleNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("newestNotice"))

	local btnOk = scaleNode:getChildByName("btn_confirm")
	local btnClose = scaleNode:getChildByName("close_btn")
	self:regBtnCallback(btnOk, handler(self, self.close)) 
	self:regBtnCallback(btnClose, handler(self, self.close)) 
	btnOk:getChildByName("Text_3"):setString(g_tr("confirm"))
	self.container = scaleNode:getChildByName("container")
end 
	
function NoticeLayer:showContent()
	self.container:removeAllChildren()
	if cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS then 
		local size = self.container:getContentSize()
		local webView = ccexp.WebView:create()
		webView:setPosition(cc.p(size.width/2, size.height/2))
		webView:setContentSize(size)
		
		local currentGameChannel = ""
		local download_channel = g_Account.getDownloadChannel()
		if download_channel == g_sdkManager.SdkDownLoadChannel.huawei then
			currentGameChannel = "huawei"
		elseif download_channel == g_sdkManager.SdkDownLoadChannel.aligames then
			currentGameChannel = "aligames"
		elseif download_channel == g_sdkManager.SdkDownLoadChannel.anysdk then
	 		local pluginChannel = require("anysdk.PluginChannel"):getInstance()
			if pluginChannel then
				local channelName = pluginChannel:getCurrentChannelName()
				if channelName ~= nil then
					currentGameChannel = channelName
				end
			end
		end
		
		local noticeUrl = g_noticeURL
		if currentGameChannel ~= "" then
			noticeUrl = noticeUrl.."/"..currentGameChannel
		end
		
		webView:loadURL(noticeUrl)
		webView:setScalesPageToFit(true)
		self.container:addChild(webView)
	end 
end 

return NoticeLayer 
