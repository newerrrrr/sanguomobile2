local buildSelect = {}
setmetatable(buildSelect,{__index = _G})
setfenv(1,buildSelect)



local m_Root = nil
local m_BuildArray = nil
local m_PageView = nil

local function clearGlobal()
	m_Root = nil
	m_BuildArray = nil
	m_PageView = nil
end


function create( nPlace , wantConfigId )
	
	clearGlobal()
	
	local place = tonumber(nPlace)
	
	--模拟建筑图片
	local buildImage = nil
	do
		local foundationImage = require("game.maplayer.homeMapLayer").getBuildImageViewWithPlace(place)
		buildImage = foundationImage:clone()
		buildImage:retain()
		foundationImage:getParent():addChild(buildImage,foundationImage:getLocalZOrder())
	end
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			require("game.maplayer.homeMapLayer").openBlurForBuildInterface()
			g_guideManager.execute()
		elseif eventType == "exit" then
			require("game.maplayer.homeMapLayer").closeBlurForBuildInterface()
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			buildImage:removeFromParent()
			buildImage:release()
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	
	--界面
	local widget = g_gameTools.LoadCocosUI("jianzhaojianzhao.csb",5)
	rootLayer:addChild(widget)
	
	
	local scale_node = widget:getChildByName("scale_node")
	
	--关闭界面
	local function onBottonClose(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			rootLayer:removeFromParent()
			require("game.maplayer.homeMapLayer").moveToOriginForBuildSelect()
		end
	end
	widget:getChildByName("Panel_1"):addTouchEventListener(onBottonClose)
	
	
	m_PageView = scale_node:getChildByName("ScrollView_3"):getChildByName("PageView_3")
	m_PageView:setIsContinuous(true)
	m_PageView:setIsTouchFull(true)
	
	
	
	m_BuildArray = {} --缓存数据对应滑动下标字符串
	local index = 0
	for k,v in pairs(g_data.build_position[place].build_id) do
		local configData = g_data.build[v]
		
		if(configData.build_type == g_PlayerBuildMode.m_BuildType.cityOut or g_PlayerBuildMode.FindBuild_origin_ConfigID(v)==nil)then --非城外建筑只能建造一个
		
			local build = cc.CSLoader:createNode("jianzhaomingcheng.csb")
			
			build:getChildByName("Image_1"):loadTexture(g_data.sprite[configData.choose_img].path)
			build:getChildByName("Image_6"):getChildByName("Text_3"):setString(g_tr(configData.build_name))
			
			m_PageView:addWidgetToPage(build,index,true)
			
			m_BuildArray[tostring(index)] = {
				config = configData,
				show = build,
			}
			
			local canBuild = true
			
			--前置建筑
			if configData.pre_build_id[1] and configData.pre_build_id[1]~=0 then
				if g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(configData.pre_build_id[1]) < 1 then
					canBuild = false
				end
			end
			
			--资源
			if canBuild and configData.cost then
				for k1,v1 in pairs(configData.cost) do
					dump(v1)
					if g_PlayerMode.EnoughResWithConfig(v1[1],v1[2]) ~= true then
						canBuild = false
						break
					end
				end
			end
			
			--道具
			if canBuild and configData.cost_item_id > 0 and configData.cost_item_num > 0 then
				local itemData = g_BagMode.FindItemByID(configData.cost_item_id)
				if itemData == nil or itemData.num < configData.cost_item_num then
					canBuild = false
				end
			end
			
			if(canBuild == false)then
				build:getChildByName("Image_1"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
				build:getChildByName("Image_6"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
				build:getChildByName("Image_6"):getChildByName("Text_3"):setTextColor(cc.c4b(150,150,150,255))
			end
			
			index = index + 1
		
		end
	end
	
	--建筑名字
	scale_node:getChildByName("Image_mingchen"):getChildByName("Text_1"):setString("")
	--建筑描述
	scale_node:getChildByName("Text_jieshao"):setString("")
	
	--变换拉动回调
	local function onChangeShowWithIndex(index)
		local configData = m_BuildArray[tostring(index)].config
		
		--建筑名字
		scale_node:getChildByName("Image_mingchen"):getChildByName("Text_1"):setString(g_tr(configData.build_name))
		
		--建筑描述
		scale_node:getChildByName("Text_jieshao"):setString(g_tr(configData.description))
		
		--模拟图
		buildImage:loadTexture(g_data.sprite[configData.img].path)
	end
	
	function pageViewEvent(sender,event)
		if(event == ccui.PageViewEventType.turning)then
			onChangeShowWithIndex(sender:getCurPageIndex())
		end
	end
	m_PageView:addEventListener(pageViewEvent)
	
	
	--默认位置
	setWantConfigID(wantConfigId and wantConfigId or g_TaskMode.getTargetCreateBuildId())
	
	
	--建造
	local function onButtonBuild(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			
			local cacheData = m_BuildArray[tostring(m_PageView:getCurPageIndex())]
			if cacheData == nil then
				g_airBox.show(g_tr("notHaveBuild"), 2)
				return
			end
			
			local configData = cacheData.config
			
			local function onBuild()
				--建造消息
				local function onRecv(result, msgData)
					if(result==true)then
					
						--升级成功特效,目前建造是不需要时间的，如果建造需要的话这里的特效就要去除
						local function levelUpSucceedCall()
							cc.Director:getInstance():setNextDeltaTimeZero(true)
							local function onEventCallFunc(armature , eventType , name)
								if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
									armature:removeFromParent()
								end
							end
							local armature , animation = g_gameTools.LoadCocosAni("anime/LingQuTiShiOne/LingQuTiShiOne.ExportJson", "LingQuTiShiOne", onEventCallFunc)
							require("game.maplayer.homeMapLayer").addAutoEffectTop(msgData.position, armature)
							animation:play("Animation1")
						end
						levelUpSucceedCall()
					
						g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
						require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
						
						--建造新的建筑时需要更新资源显示,因为可能加入了新的资源类型
						require("game.uilayer.mainSurface.mainSurfacePlayer").updateShowWithData_Res()
						g_resourcesInterface.updateAllResShow()
						
						g_guideManager.execute()
						
					end
					require("game.maplayer.homeMapLayer").moveToOriginForBuildSelect()
				end

				g_sgHttp.postData("build/construct",{ buildId = configData.id  , position = place ,steps = g_guideManager.getToSaveStepId()},onRecv)
				rootLayer:removeFromParent()
			end
      
			--local function onFastDone()
			--end
			
			local function onMoveCancle(build_id)
				local v = g_PlayerBuildMode.FindBuild_lv_less_ConfigID(build_id)
				if(v)then
					--require("game.maplayer.homeMapLayer").moveToCenterForGuide(v.position)
					require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(v.position)
				else
					local needBuildID = g_PlayerBuildMode.FindBuildConfig_firstBuilding_ConfigID(build_id)
					local canBuildPlace = require("game.maplayer.homeMapLayer").getClearingWithBuildID(needBuildID.id)
					if(canBuildPlace)then
						--require("game.maplayer.homeMapLayer").moveToCenterForGuide(canBuildPlace)
						require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(canBuildPlace)
					end
				end
				rootLayer:removeFromParent()
			end
      
			local function onClose()
				rootLayer:removeFromParent()
			end
	
			local function onCancle()
				--返回界面再打开模糊
				require("game.maplayer.homeMapLayer").openBlurForBuildInterface(true)
			end
			
			--去其他界面时先关一下模糊
			require("game.maplayer.homeMapLayer").closeBlurForBuildInterface(true)
			
			local params =  {}
			params.onStart = onBuild
			--params.onFastDone = onFastDone
			params.onClose = onClose
			params.onMoveCancle = onMoveCancle
			params.onCancle = onCancle
		  
			g_sceneManager.addNodeForUI(require("game.uilayer.buildupgrade.BuildingUpgradeLayer"):create(configData.id,params,false))
			
		end
	end
	
	--注册新手引导nodeId 建造按钮
    g_guideManager.registComponent(1000101,scale_node:getChildByName("Button_anniu"))
    
	scale_node:getChildByName("Button_anniu"):addTouchEventListener(onButtonBuild)

	
	return rootLayer
end


--设置希望的建筑ID
function setWantConfigID(wantConfigId)
	if m_Root == nil then
		return
	end
	local want_config_id = wantConfigId and tonumber(wantConfigId) or nil
	if want_config_id then
		local isHave = false
		for k , v in pairs(m_BuildArray) do
			if v.config.id == want_config_id then
				m_PageView:scrollToPage(tonumber(k))
				isHave = true
				break
			end
		end
		if isHave == false then
			m_PageView:scrollToPage(0)
		end
	else
		m_PageView:scrollToPage(0)
	end
end




return buildSelect