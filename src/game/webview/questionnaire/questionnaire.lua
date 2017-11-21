local questionnaire = {}
setmetatable(questionnaire,{__index = _G})
setfenv(1,questionnaire)

--问卷调查，封测版之后弃用

local function create()
	
	local ret = cc.Node:create()
	
	do
		local function onTouchBegan(touch, event)
			return true
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(true)
		touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, ret)
	end
	
	local webView = ccexp.WebView:create()
	ret:addChild(webView)
	
	local menuWidget = cc.CSLoader:createNode("return_account_manager.csb")
	ret:addChild(menuWidget)
	
	local menuSize = menuWidget:getContentSize()
	menuWidget:setAnchorPoint(cc.p(1.0, 1.0))
	menuWidget:setPosition(g_display.right_top)
	
	webView:setPosition(cc.p(g_display.center.x, g_display.center.y - menuSize.height + 25.0))
	webView:setContentSize(g_display.visibleSize.width - 50.0, g_display.visibleSize.height - menuSize.height - 50.0)
	
	local url = g_Account.getServerHost().."/question/list?p="..tostring(g_PlayerMode.GetData().id)
	
	webView:loadURL(url)
	webView:setScalesPageToFit(true)
	
	local function onWebViewShouldStartLoading(sender, url)
		return true
	end
	local function onWebViewDidFinishLoading(sender, url)
		
	end
	local function onWebViewDidFailLoading(sender, url)
		
	end
	webView:setOnShouldStartLoading(onWebViewShouldStartLoading)
	webView:setOnDidFinishLoading(onWebViewDidFinishLoading)
	webView:setOnDidFailLoading(onWebViewDidFailLoading)
	
	local function onGoBack(sender)
		webView:goBack()
	end
	local function onGoForward(sender)
		webView:goForward()
	end
	local function onReload(sender)
		webView:reload()
	end
	local function onClose(sender)
		ret:removeFromParent()
	end
	menuWidget:getChildByName("Button_1"):addClickEventListener(onGoBack)
	menuWidget:getChildByName("Button_2"):addClickEventListener(onGoForward)
	menuWidget:getChildByName("Button_3"):addClickEventListener(onReload)
	menuWidget:getChildByName("Button_4"):addClickEventListener(onClose)
	
	return ret
end


function checkShow()
	local platform = cc.Application:getInstance():getTargetPlatform()
	if platform == cc.PLATFORM_OS_ANDROID
		or platform == cc.PLATFORM_OS_IPHONE
		or platform == cc.PLATFORM_OS_IPAD
			then
		if g_PlayerBuildMode.getMainCityBuilding_lv() >= 10 then
			local function onRecv(result, msgData)
				if result == true then
					if msgData.questionnaire == 0 then
						g_sceneManager.addNodeForWebView(create())
					end
				end
			end
			g_sgHttp.postData("common/getPlayerQuestion", {}, onRecv)
		end
	end
end



return questionnaire