local guildWarEnterEffect = {}
setmetatable(guildWarEnterEffect,{__index = _G})
setfenv(1,guildWarEnterEffect)

local nameList = nil

--变换地图的过场特效
--
--local c_name_close = "ZhenChaGuoChangDongHuaKai"
--
--local c_name_open = "ZhenChaGuoChangDongHuaGuan"
--
--
--m_EnevtEnum = {
--	close_start = 1,
--	close_complete = 2,
--	open_start = 3,
--	open_complete = 4,
--}

local m_isLoading = false

local round1Played = false
local round2Played = false

playBattleRondAnimation = function()
	
	if m_isLoading then
		return
	end
	
	if round1Played and round2Played then
		return
	end
	
	local battleStatus = g_guildWarBattleInfoData.GetData().status
	
	if battleStatus > 3 and round2Played then
		return
	elseif battleStatus <= 3 and round1Played then
		return 
	end
	
	if battleStatus ~= g_guildWarBattleInfoData.StatusType.STATUS_FINISH 
	then
		local ret = cc.Node:create()
		ret:ignoreAnchorPointForPosition(false)
		ret:setContentSize(cc.size(0.0,0.0))
		ret:setAnchorPoint(cc.p(0.0,0.0))
		ret:setPosition(g_display.center)
		
		local animPath = "anime/Effect_KuaFuZhanChangHuiHe/Effect_KuaFuZhanChangHuiHe.ExportJson"
		local armature , animation = nil,nil
		local isPlayRound = true
		
		local function onMovementEventCallFunc(armature , eventType , name)
			
			if ccs.MovementEventType.complete == eventType then
--				playArea()
--				armature:removeFromParent()
				if isPlayRound then
						isPlayRound = false
						if g_guildWarBattleInfoData.IsAttacker() then
							animation:play("JingGong")
						else
							animation:play("FangShou")
						end
				else
					ret:removeFromParent()
					g_autoCallback.addCocosList(function () 
              ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath) 
          end , 0.01 )
				end
			end
		end
	
		armature , animation = g_gameTools.LoadCocosAni(
		animPath
		, "Effect_KuaFuZhanChangHuiHe"
		, onMovementEventCallFunc
		--, onFrameEventCallFunc
		)
		ret:addChild(armature)
		if battleStatus > 3 then
			animation:play("HuiHe_2")
			round2Played = true
			round1Played = true
		else
			animation:play("HuiHe_1")
			round1Played = true
		end
		g_sceneManager.addNodeForTopEffect(ret)
	end 
	
end

function create(callback)
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setContentSize(cc.size(0.0,0.0))
	ret:setAnchorPoint(cc.p(0.0,0.0))
	ret:setPosition(g_display.center)
	
	do--阻止触摸
		local function onTouchBegan(touch, event)
			return true
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(true)
		touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, ret)
	end
		
	local animPath = "anime/Effect_KuaFuZhanChangKaiChangXunHuan/Effect_KuaFuZhanChangKaiChangXunHuan.ExportJson"
	local armature , animation = nil , nil
	local uiLayer = nil
	
	m_isLoading = false
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
		
--			local lastTime = os.time()
--			ret:runAction(cc.Sequence:create(
--				cc.DelayTime:create(4)
--				, cc.CallFunc:create(function() 
--					
--				end)
--			))

			local lastTime = os.time()
			
			if callback then
				callback(ret,armature)
			end
			
			local removeEffectHandler = function()
				ret:removeFromParent()
				m_isLoading = false
				g_autoCallback.addCocosList(function () 
	          ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath) 
	      end , 0.01 )
				playBattleRondAnimation()
			end
			
			local expectDelay = 1
			
			local nowTime = os.time()
			if nowTime - lastTime >= expectDelay then
				removeEffectHandler()
			else
				g_autoCallback.addCocosList(function () 
					removeEffectHandler()
				end,math.max(expectDelay - (nowTime - lastTime),0.01))
			end
		end
	end
	
	--local function onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
	--end
	
	armature , animation = g_gameTools.LoadCocosAni(
		animPath
		, "Effect_KuaFuZhanChangKaiChangXunHuan"
		, onMovementEventCallFunc
		--, onFrameEventCallFunc
		)
	ret:addChild(armature)
	
	local container = cc.Node:create()
	container:setCascadeOpacityEnabled(true)
  uiLayer = cc.CSLoader:createNode("guildwar_main2.csb")
  uiLayer:setPosition(cc.p(-1280/2,-720/2))
  container:addChild(uiLayer)
	armature:getBone("JuanZhou"):addDisplay(container,0)
	uiLayer:getChildByName("scale_node"):setVisible(false)
	uiLayer:getChildByName("scale_node"):setScale(g_display.scale)
	uiLayer:getChildByName("scale_node"):getChildByName("Text_1"):setString(g_tr("guild_war_loading_map"))
	
	local showNameList = function()
		uiLayer:getChildByName("scale_node"):setVisible(true)
		
		local battleInfo = g_guildWarBattleInfoData.GetData()
		if battleInfo then
			uiLayer:getChildByName("scale_node"):setVisible(true)
			
			local server1 = require("game.mapguildwar.worldMapLayer_uiLayer").getServerPreName(tostring(battleInfo.guild_1_id))
			local server2 = require("game.mapguildwar.worldMapLayer_uiLayer").getServerPreName(tostring(battleInfo.guild_2_id))
			
			uiLayer:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Text_mc2"):setString(server1..battleInfo.guild_1_name)
			uiLayer:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Text_mc2"):setString(server2..battleInfo.guild_2_name)
			uiLayer:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Image_lianmtb"):loadTexture(g_resManager.getResPath(g_data.alliance_flag[battleInfo.guild_1_avatar].res_flag))
			uiLayer:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Image_lianmtb"):loadTexture(g_resManager.getResPath(g_data.alliance_flag[battleInfo.guild_2_avatar].res_flag))
		end
		
		local idx = 1
		if nameList then
			for key, slist in pairs(nameList) do
				local listView = uiLayer:getChildByName("scale_node"):getChildByName("Panel_"..idx):getChildByName("ListView_1")
				listView:setScrollBarEnabled(false)
				local rowMax = math.ceil(table.nums(slist)/2)
				local cnt = 0
				for i=1, rowMax do
					local item = cc.CSLoader:createNode("guildwar_main2_list1.csb")
					item:getChildByName("Panel_1"):setVisible(false)
					item:getChildByName("Panel_2"):setVisible(false)
					for _i=1, 2 do
						cnt = cnt + 1
						local var = slist[cnt]
						if var then
							local parentPanel = item:getChildByName("Panel_".._i)
							parentPanel:setVisible(true)
							parentPanel:getChildByName("Image_9_0"):loadTexture(g_resManager.getResPath(g_data.res_head[tonumber(var.avatar_id)].head_icon))
							if tonumber(var.guild_id) == tonumber(g_guildWarPlayerData.getGuildId()) then
								parentPanel:getChildByName("Text_5"):setString("Lv."..var.level)
							else
								parentPanel:getChildByName("Text_5"):setString("")
							end
							parentPanel:getChildByName("Text_1"):setString(var.nick)
							parentPanel:getChildByName("Text_2"):setString("")
						end
					end
					listView:pushBackCustomItem(item)
				end
				idx = idx + 1
			end
		end
		
	end
	
	local playAnima = function()
		showNameList()
		animation:play("Animation1")
		cc.Director:getInstance():setNextDeltaTimeZero(true)
	end
	
	m_isLoading = true
	if nameList == nil then
		local function onRecv(result,msgData)
			g_busyTip.hide_1()
			if result then
				nameList = msgData
			end
			playAnima()
		end
		g_busyTip.show_1()
		g_sgHttp.postData("Cross/getAllPlayerList", {}, onRecv,true)
	else
		playAnima()
	end
	
	
	return ret
	
end


return guildWarEnterEffect