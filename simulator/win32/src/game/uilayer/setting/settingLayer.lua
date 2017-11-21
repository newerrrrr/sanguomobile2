local settingLayer = {}
setmetatable(settingLayer,{__index = _G})
setfenv(1,settingLayer)


function create()
	local widget = g_gameTools.LoadCocosUI("setThe_main.csb", 5)
	
	local function onButtonClose(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			widget:removeFromParent()
		end
	end
	widget:getChildByName("mask"):addTouchEventListener(onButtonClose)
	
	
	local scale_node = widget:getChildByName("scale_node")
	scale_node:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
	scale_node:getChildByName("Text_c2"):setString(g_tr("setting_title"))
	scale_node:getChildByName("Text_06"):setString(g_tr("setting_music"))
	scale_node:getChildByName("Text_07"):setString(g_tr("setting_sound"))
	scale_node:getChildByName("Text_08"):setString(g_tr("setting_powerSave"))
	scale_node:getChildByName("Text_ts"):setString(g_tr("setting_touchChange"))
	
	local imageX_music = scale_node:getChildByName("Image_6quex")	--音乐
	local imageX_sound = scale_node:getChildByName("Image_7quex")	--音效
	local imageX_powerSave = scale_node:getChildByName("Image_8quex")	--省电
	
	imageX_music:setVisible(g_saveCache.sound_music ~= 1 and true or false)
	imageX_sound:setVisible(g_saveCache.sound_sound ~= 1 and true or false)
	imageX_powerSave:setVisible(g_saveCache.power_save == 0 and true or false)
	
	local function onButtonMusic(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			if g_saveCache.sound_music ~= 1 then
				g_saveCache.sound_music = 1
				imageX_music:setVisible(false)
				g_musicManager.openMusic()
			else
				g_saveCache.sound_music = 0
				imageX_music:setVisible(true)
				g_musicManager.closeMusic()
			end
		end
	end
	scale_node:getChildByName("Image_6"):addTouchEventListener(onButtonMusic)
	
	
	local function onButtonSound(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			if g_saveCache.sound_sound ~= 1 then
				g_saveCache.sound_sound = 1
				imageX_sound:setVisible(false)
				g_musicManager.openEffects()
			else
				g_saveCache.sound_sound = 0
				imageX_sound:setVisible(true)
				g_musicManager.closeEffects()
			end
		end
	end
	scale_node:getChildByName("Image_7"):addTouchEventListener(onButtonSound)
	
	
	local function onButtonPowerSave(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			if g_saveCache.power_save ~= 0 then
				g_saveCache.power_save = 0
				imageX_powerSave:setVisible(true)
				g_musicManager.setMusicVolume(1.0)
				g_musicManager.setEffectsVolume(1.0)
				if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
					cc.Director:getInstance():setAnimationInterval(1.0 / 60.0)
					cc.Application:getInstance():setAnimationInterval(1.0 / 60.0)
				else
					cc.Director:getInstance():setAnimationInterval(1.0 / 60.0)
					cc.Application:getInstance():setAnimationInterval(1.0 / 60.0)
				end
				onNotificationPowerSaveClose()
			else
				g_saveCache.power_save = 1
				imageX_powerSave:setVisible(false)
				g_musicManager.setMusicVolume(0.1)
				g_musicManager.setEffectsVolume(0.1)
				if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
					cc.Director:getInstance():setAnimationInterval(1.0 / 30.0)
					cc.Application:getInstance():setAnimationInterval(1.0 / 30.0)
				else
					cc.Director:getInstance():setAnimationInterval(1.0 / 30.0)
					cc.Application:getInstance():setAnimationInterval(1.0 / 30.0)
				end
				onNotificationPowerSaveOpen()
			end
		end
	end
	scale_node:getChildByName("Image_8"):addTouchEventListener(onButtonPowerSave)
	
	
	--自动播放语音
  local function onVoiceSelectEvent(sender,eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			g_saveCache.voice_auto_play = 1 
		elseif eventType == ccui.CheckBoxEventType.unselected then 
			g_saveCache.voice_auto_play = 0 
		end 
  end 
  scale_node:getChildByName("Text_zdbf"):setString(g_tr("setting_auto_voice"))
	scale_node:getChildByName("CheckBox_1"):addEventListenerCheckBox(onVoiceSelectEvent) 

	local function onButtonProclamation(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--公告
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			g_sceneManager.addNodeForWebView(require("game.webview.notice.NoticeLayer").new())
		end
	end
	scale_node:getChildByName("Button_1"):addTouchEventListener(onButtonProclamation)
	scale_node:getChildByName("Button_1"):getChildByName("Text_2"):setString(g_tr("setting_proclamation"))
	
	local function onButtonNotice(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--通知
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			g_sceneManager.addNodeForUI(require "game.uilayer.setting.settingNoticeLayer".create())
		end
	end
	scale_node:getChildByName("Button_2"):addTouchEventListener(onButtonNotice)
	scale_node:getChildByName("Button_2"):getChildByName("Text_2"):setString(g_tr("setting_notice"))
	
	local function onButtonArea(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--选区
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			local function requestServerList(successHandler)
				 local function onRecv(result, msgData)
					g_busyTip.hide_1()
					if result then
						print(msgData)
						local gameServerList = cjson.decode(msgData)
						local list = gameServerList.server_list
						g_Account.isTestUser = gameServerList.whitelist_flag
						if successHandler then
							successHandler(list)
						end
					else
						g_airBox.show(g_tr("getServerListFail"))
					end
				end
				g_busyTip.show_1()
				local data = ""
				httpNet:getInstance():Post(g_configHost.."/login_server/getServerList",data,string.len(data),onRecv,10,10,true,false)
			end
			
			requestServerList(function(gameServerList)
				local selectLayer = require("game.uilayer.regist.AreaSelectLayer"):create(nil,gameServerList)
				g_sceneManager.addNodeForUI(selectLayer)
			end)
		end
	end
	scale_node:getChildByName("Button_3"):addTouchEventListener(onButtonArea)
	scale_node:getChildByName("Button_3"):getChildByName("Text_2"):setString(g_tr("setting_area"))
	
	local function onButtonRedeemCode(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--兑换码
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			local layer = require("game.uilayer.redeemcode.RedeemCodeLayer"):create()
			g_sceneManager.addNodeForUI(layer)
		end
	end
	scale_node:getChildByName("Button_4"):addTouchEventListener(onButtonRedeemCode)
	scale_node:getChildByName("Button_4"):getChildByName("Text_2"):setString(g_tr("setting_redeemcode"))
	
	local enabledSwitchAccount = false
	local download_channel = g_Account.getDownloadChannel()
	if download_channel == g_sdkManager.SdkDownLoadChannel.anysdk then
			local pluginChannel = require("anysdk.PluginChannel"):getInstance()
			if pluginChannel and pluginChannel:getCurrentChannelId() == "160136" then --ysdk
				enabledSwitchAccount = true
			end
	end
	
	local function onButtonLogout(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--通知
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			g_msgBox.show("您将退出当前账号并返回登录界面，是否继续？",nil,nil,function(event)
				if event == 0 then
					local pluginChannel = require("anysdk.PluginChannel"):getInstance()
					if pluginChannel then
						pluginChannel:logout()
					end
				end
		  end,1)
				  
		end
	end
	scale_node:getChildByName("Button_5"):addTouchEventListener(onButtonLogout)
	scale_node:getChildByName("Button_5"):setVisible(enabledSwitchAccount)
	
	
	do
		local count_4444_half = 50
		local count_4444 = 0
		local node_4444 = cc.Node:create()
		local function onTouchBegan_4444(touch, event)
			local p = touch:getLocation()
			if count_4444 < count_4444_half then
				if p.x <= g_display.center.x then
					count_4444 = count_4444 + 1
					if count_4444 == count_4444_half then
						g_airBox.show("left completed")
					end
				else
					count_4444 = 0
				end
			else
				if p.x > g_display.center.x then
					count_4444 = count_4444 + 1
					if count_4444 == count_4444_half * 2 then
						count_4444 = 0
						if g_saveCache.texture4_save == 0 then
							local function callback1(event1)
								if event1 == 0 then
									g_saveCache.texture4_save = 1
									local function callback2(event2)
										if event2 == 0 then
											g_saveCache.textureFS_save = 1
										else
											g_saveCache.textureFS_save = 0
										end
									end
									g_msgBox.show("will use floyd steinberg ?", nil, nil, callback2, 1)
								end
							end
							g_msgBox.show("will use 4444 565 ?", nil, nil, callback1, 1)
						elseif g_saveCache.texture4_save == 1 then
							local function callback1(event1)
								if event1 == 0 then
									g_saveCache.texture4_save = 0
									g_saveCache.textureFS_save = 0
								end
							end
							g_msgBox.show("will use 8888 ?", nil, nil, callback1, 1)
						end
					end
				else
					count_4444 = 0
					g_airBox.show("change failed")
				end
			end
			return true
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(false)
		touchListener:registerScriptHandler(onTouchBegan_4444,cc.Handler.EVENT_TOUCH_BEGAN )
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, node_4444)
		widget:addChild(node_4444, 2147483647)
	end
	
	
	return widget
end


function initSettingForMain()
	if g_saveCache.power_save == 0 then
		g_musicManager.setMusicVolume(1.0)
		g_musicManager.setEffectsVolume(1.0)
		if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
			cc.Director:getInstance():setAnimationInterval(1.0 / 60.0)
			cc.Application:getInstance():setAnimationInterval(1.0 / 60.0)
		else
			cc.Director:getInstance():setAnimationInterval(1.0 / 60.0)
			cc.Application:getInstance():setAnimationInterval(1.0 / 60.0)
		end
	else
		g_musicManager.setMusicVolume(0.1)
		g_musicManager.setEffectsVolume(0.1)
		cc.Director:getInstance():setAnimationInterval(1.0 / 30.0)
		cc.Application:getInstance():setAnimationInterval(1.0 / 30.0)
	end
	
	if g_saveCache.sound_music == 1 then
		g_musicManager.openMusic()
	else
		g_musicManager.closeMusic()
	end
	
	if g_saveCache.sound_sound == 1 then
		g_musicManager.openEffects()
	else
		g_musicManager.closeEffects()
	end
	
	do
		if cc.TextureCache.setBitmapRGBA8888Mode and cc.TextureCache.setBitmapRGB888Mode then
			if g_saveCache.texture4_save == 1 then
				local textureCache = cc.Director:getInstance():getTextureCache()
				local isFS = (g_saveCache.textureFS_save == 1)
				textureCache:setBitmapRGBA8888Mode(true, isFS, true)
				textureCache:setBitmapRGB888Mode(true, isFS)
			end
		end
	end
	
end


function onNotificationPowerSaveOpen()
	require("game.maplayer.homeMapLayer").onPowerSaveOpen()
	require("game.maplayer.homeScreenEffect").onPowerSaveOpen()
end


function onNotificationPowerSaveClose()
	require("game.maplayer.homeMapLayer").onPowerSaveClose()
	require("game.maplayer.homeScreenEffect").onPowerSaveClose()
end






return settingLayer