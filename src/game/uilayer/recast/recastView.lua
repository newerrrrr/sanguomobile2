local recastView = {}
setmetatable(recastView,{__index = _G})
setfenv(1,recastView)

local m_CurrentShowList = {}

local function _show()
	if #m_CurrentShowList > 0 then
		return --同一时刻只能打开一个
	end
	
	local widget = g_gameTools.LoadCocosUI("system_tips_Recast.csb", 5)
	
	local function update(dt)
		if (#m_CurrentShowList) > 1 then --同一时刻只能打开一个
			for k , v in ipairs(m_CurrentShowList) do
				if k > 1 and v == widget then
					widget:removeFromParent()
					break
				end
			end
		end
	end
	
	local function nodeEventHandler(eventType)
		if eventType == "enter" then
			m_CurrentShowList[(#m_CurrentShowList) + 1] = widget
			widget:scheduleUpdateWithPriorityLua(update, 0)
		elseif eventType == "exit" then
			for k , v in ipairs(m_CurrentShowList) do
				if v == widget then
					table.remove(m_CurrentShowList,k)
					break
				end
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
		end
	end
	widget:registerScriptHandler(nodeEventHandler)
	
	local scale_node = widget:getChildByName("scale_node")
	
	local function onButtonRecast(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if g_PlayerMode.GetData().is_in_map and g_PlayerMode.GetData().is_in_map == 0 then
				local function onRecv(result, msgData)
					if result == true then
						--发送成功关闭
						widget:removeFromParent()
						local function onChangeEnd()
							require("game.maplayer.worldMapLayer_bigMap").playRebuild()
						end
						require("game.maplayer.changeMapScene").changeToWorld(false, onChangeEnd)
					end
				end
				--type : 1指定 2随机
				g_sgHttp.postData("map/changeCastleLocation", { type = 2 , x = 0 , y = 0 }, onRecv)
			else
				widget:removeFromParent()
			end
		end
	end
	scale_node:getChildByName("Button_1"):addTouchEventListener(onButtonRecast)
	
	scale_node:getChildByName("Text_1"):setString(g_tr("msgBox_escape_text"))
	
	scale_node:getChildByName("Button_1"):getChildByName("Text_2"):setString(g_tr("msgBox_escape_button"))
	
	g_sceneManager.addNodeForMsgBox(widget)
end


function checkShowForPlayerDataChange()
	--玩家数据改变时
	if g_sceneManager.getCurrentSceneMode() ~= g_sceneManager.sceneMode.game then
		return
	end
	if g_PlayerMode.GetData().is_in_map and g_PlayerMode.GetData().is_in_map == 0 then
		if g_guideManager.getLastShowStep() then
			--有引导
			local function onRecv(result, msgData)
				if result == true then
					g_airBox.show(g_tr("msgBox_escape_auto"), 2)
				end
			end
			g_sgHttp.postData("map/changeCastleLocation", { type = 2 , x = 0 , y = 0 }, onRecv)
		else
			--无引导
			local function onChnageEnd()
				_show()
			end
			require("game.maplayer.changeMapScene").changeToHome(false, onChnageEnd)
		end
	end
end


function checkShowForInGame_haveGuide()
	--进入游戏并且有引导时
	if g_PlayerMode.GetData().is_in_map and g_PlayerMode.GetData().is_in_map == 0 then
		local function onRecv(result, msgData)
			if result == true then
				g_airBox.show(g_tr("msgBox_escape_auto"), 2)
			end
		end
		g_sgHttp.postData("map/changeCastleLocation", { type = 2 , x = 0 , y = 0 }, onRecv)
	end
end


function checkShowForInGame_notGuide()
	--进入游戏并且无引导时
	if g_PlayerMode.GetData().is_in_map and g_PlayerMode.GetData().is_in_map == 0 then
		_show()
	end
end


return recastView