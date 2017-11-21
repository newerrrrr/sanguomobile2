local mainSurfaceChat = {}
setmetatable(mainSurfaceChat,{__index = _G})
setfenv(1,mainSurfaceChat)

local ChatMode = require("game.uilayer.chat.ChatMode") 

--主界面聊天

local m_Root = nil
local m_Widget = nil
local m_Rich = nil
local m_RichChat = nil 
local m_BtnSrot = {}
local m_lastTimeFlag = 0

local function clearGlobal()
	m_Root = nil
	m_Widget = nil
    m_Rich = nil
    m_RichChat = nil 
    m_BtnSrot = {}
end

function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_visible, 0 , false)
            --schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_tower, 15.0 , false)
			--update_tower(0.0167)
		elseif eventType == "exit" then
            for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	


	local widget = g_gameTools.LoadCocosUI("zhuchengjiemian_03.csb",7)
    m_Widget = widget
	rootLayer:addChild(widget)
	
	
    

    widget:getChildByName("scale_node"):getChildByName("Image_1"):addTouchEventListener(onButtonTask)
    g_guideManager.registComponent(9999999,widget:getChildByName("scale_node"):getChildByName("Image_1"))
    
    widget:getChildByName("scale_node"):getChildByName("Image_12"):addTouchEventListener(onButtonTask)
    
    widget:getChildByName("scale_node"):getChildByName("Image_13"):addTouchEventListener(onButtonChat)

    --小地图
    local map_btn = widget:getChildByName("scale_node"):getChildByName("Image_3")
    map_btn:addTouchEventListener(onButtonMap)
    map_btn:getChildByName("Text_8"):setString(g_tr("menu_world"))
    --技能
    local skills_btn = widget:getChildByName("scale_node"):getChildByName("Button_5")
	skills_btn:addTouchEventListener(onButtonSkill)
    skills_btn:getChildByName("Text_8"):setString(g_tr("menu_skills"))

    --收藏夹
    local favorites_btn = widget:getChildByName("scale_node"):getChildByName("Image_2")
    favorites_btn:addTouchEventListener(onBottonCollect)
    favorites_btn:getChildByName("Text_2"):setString( g_tr("menu_favorites") )

    --搜索敌人
    local search_npc = widget:getChildByName("scale_node"):getChildByName("Image_search")
    search_npc:addTouchEventListener(onButtonSearch)
    g_guideManager.registComponent(9999998,search_npc)
    search_npc:getChildByName("Text_2"):setString(g_tr("menu_searchNpc"))

    --新手秘书
    local secretary_btn = widget:getChildByName("scale_node"):getChildByName("Image_canmou")
    secretary_btn:getChildByName("Text_2"):setString(g_tr("menu_secretary"))
    secretary_btn:addTouchEventListener(onButtonSecretary)

    local projName = "Effect_ShangChengTuBiaoBianKuangXunHuan"
    local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName,onMovementEventCallFunc)
    armature:setPosition( secretary_btn:getContentSize().width/2,secretary_btn:getContentSize().height/2  )
    secretary_btn:addChild(armature)
    animation:play("Animation1")
    
    table.insert(m_BtnSrot,map_btn)
    table.insert(m_BtnSrot,skills_btn)
    table.insert(m_BtnSrot,favorites_btn)
    table.insert(m_BtnSrot,search_npc)
    table.insert(m_BtnSrot,secretary_btn)

    --[[
    --烽火台
    local lookout_btn = m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames")
    lookout_btn:getChildByName("Text_2"):setString(g_tr("menu_lookout"))

    lookout_btn:setVisible(false)

    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_FengHuoTai/Effect_FengHuoTai.ExportJson", "Effect_FengHuoTai")
    lookout_btn:addChild(armature)
	armature:setPosition(cc.p(lookout_btn:getContentSize().width / 2, lookout_btn:getContentSize().height * 0.5))
	animation:play("Animation1")

    lookout_btn:addTouchEventListener(onBottonTower)
]]--
    --初始化任务引导
    taskUpdate()

    --创建引导特效与动画
    taskGuideFx()

	--初始化当前场景显示和隐藏的UI
    viewChangeShow()

    updateChatComponent()
    --createFindMosterHand() 

    initVoiceChat() 

    return rootLayer
end



function update_visible(dt)
	if m_Root == nil or m_Widget == nil then
		return
	end
	if g_resourcesInterface.getResInterfaceShowCount() > 0 then
		m_Widget:setVisible(false)
	else
		m_Widget:setVisible(true)
	end
end

function update_tower(dt)
	local function onRecv(result, msgData)
		if result == true then
			if m_Root and m_Widget then
               local lookout_btn = m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames")
				if msgData == nil or #msgData == 0 then
                    lookout_btn:setVisible(false)
                else
                    lookout_btn:setVisible(true)
                end
			end
		end
	end
    g_netCommand.send("Player/viewAttackArmy", {}, onRecv, true)
end


function onButtonSecretary(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        if m_Root and m_Widget then
            local blevel = g_PlayerBuildMode.FindBuild_high_OriginID(1).build_level
            if blevel > 20 then
                viewChangeShow()
                return
            end
            local view = require("game.uilayer.raiders.RaidersMainView"):create()
            g_sceneManager.addNodeForUI(view)
        end
    end
end


function onButtonSearch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local view = require("game.uilayer.mainSurface.searchMasterView").new()
        g_sceneManager.addNodeForUI(view)

        if m_Root and m_Widget then
            local findMosterBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_search")
            if findMosterBtn.hand then
                findMosterBtn.hand:setVisible(false)
            end
        end

    end
end

function onBottonTower(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local view = require("game.uilayer.tower.TowerView").new()
        g_sceneManager.addNodeForUI(view)
    end
end

--技能
function onButtonSkill(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local mianSkillView = require("game.uilayer.mainSurface.mianSkillView")
        mianSkillView:createLayer()
	end
end
--小地图
function onButtonMap(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        --require("game.uilayer.map.collectLayer"):createLayer()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_busyTip.show_1()
        g_AllianceMode.reqAllAllianceDataAsync( function ( result,msgData )
             g_busyTip.hide_1()
            if result == true then
                g_sceneManager.addNodeForUI(require("game.uilayer.map.smallMapLayer").create())
            end
        end) 
    end
end

function onUpdateTaskGuideHand()
    if  m_Root and m_Widget then
        m_lastTimeFlag = g_clock.getCurServerTime()

        local task_tips = m_Widget:getChildByName("scale_node"):getChildByName("Panel_ti")

        if task_tips then
            task_tips:setVisible(false)
        end

        if task_tips.fx1 then
            task_tips.fx1:setVisible(false)
        end

        if task_tips.fx2 then
            task_tips.fx2:setVisible(false)
        end

        --local task_border = m_Widget:getChildByName("scale_node"):getChildByName("Image_1")
        --[[local task_tishi = m_Widget:getChildByName("scale_node"):getChildByName("Image_12")
        
        local task_GuideHand = task_tishi.hand
        if task_GuideHand then
            task_GuideHand:setVisible(false)
        end]]



    end
end

function checkTaskGuideHandShow()
    --print("checkTaskGuideHandShow")
    
    if m_Root == nil or m_Widget == nil then
        return
    end

    --控制手指动画显示
    --local task_border = m_Widget:getChildByName("scale_node"):getChildByName("Image_1")
    --local task_tishi = m_Widget:getChildByName("scale_node"):getChildByName("Image_12")
    --local task_GuideHand = task_tishi.hand

    local task_tips = m_Widget:getChildByName("scale_node"):getChildByName("Panel_ti")
    local isShow = false
    local plevel = g_PlayerMode.GetData().level
    local showendlevel = tonumber(g_data.starting[49].data or 0) --显示结束等级

    print("plevel,showendlevel",plevel,showendlevel)

    if plevel < showendlevel then
        if task_tips then

            isShow = not g_guideManager.getLastShowStep() and g_clock.getCurServerTime() > m_lastTimeFlag + 8 and m_lastTimeFlag > 0
            
            print("isShow",isShow,not task_tips:isVisible())

            if isShow and not task_tips:isVisible() then
                task_tips:setScale(0.5)
                task_tips:runAction( cc.ScaleTo:create(0.3,1) )
            end
        end
    end

    
    task_tips:setVisible(isShow)

    if task_tips.fx1 then
        task_tips.fx1:setVisible(isShow)
    end
    
    if task_tips.fx2 then
        task_tips.fx2:setVisible(isShow)
    end

end

--任务
function onButtonTask(sender, eventType)
    if eventType == ccui.TouchEventType.ended then

       local taskData = g_TaskMode.getGuideMainTask()
       
       if taskData and taskData:getServerData().status == g_TaskMode.TaskStatusType.COMPLETE then
           g_musicManager.playEffect(g_data.sounds[5000036].sounds_path)
       else
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
       end
       g_TaskMode.guideToMainTask(taskData)
       
       g_guideManager.execute()
    end
    
end

--任务UI更新
function taskUpdate()
    if m_Root and m_Widget then
        
        require("game.uilayer.mainSurface.mainSurfaceMenu").onTaskUpdate()
    
        local task_label = m_Widget:getChildByName("scale_node"):getChildByName("Text_5_0")
        local taskData = g_TaskMode.getGuideMainTask()
        if not taskData then
            task_label:setString("")
            if m_Rich then
                m_Rich:setRichText("")
            end
            m_Widget:getChildByName("scale_node"):getChildByName("Image_12"):setVisible(false)
            m_Widget:getChildByName("scale_node"):getChildByName("Image_1"):setVisible(false)
            return 
        end
        
        local progressStr = ""
        local extendStr = ""
        if taskData:getServerData().status == g_TaskMode.TaskStatusType.COMPLETE then
            extendStr = string.format("(|<#0,255,0#>%s|)",g_tr("taskGetReceive"))
        else
        	--任务进度
			    local currentNum = taskData:getServerData().current_mission_number
			    local maxNum = taskData:getServerData().max_mission_number
			    if maxNum > 0 then
			    	progressStr = "("..currentNum.."/"..maxNum..")"
			    end
        end
        
        task_label:setString(g_tr(taskData:getConfig().mission_objectives)..progressStr..extendStr)
        --task_label:setVisible(false)

        if m_Rich == nil then
            m_Rich = g_gameTools.createRichText(task_label,task_label:getString())
        else
            --m_Rich:setRichSize()
            m_Rich:setRichText(task_label:getString())
        end
        
        --[[
        --获取任务手型引导动画节点
        local task_border = m_Widget:getChildByName("scale_node"):getChildByName("Image_1")
        local task_GuideHand = task_border.hand
        if task_GuideHand then
            task_border:stopAllActions()
            local taskCompleteStatus = false
            local taskData = g_TaskMode.getGuideMainTask()
            if taskData and taskData:getServerData().status == g_TaskMode.TaskStatusType.COMPLETE then
                 taskCompleteStatus = true
            end
            task_GuideHand:setVisible(not g_guideManager.getLastShowStep() and not taskCompleteStatus)
        end
        ]]
        
    end
end

--创建任务引导特效
function taskGuideFx()

    if m_Root and m_Widget then

        local task_border = m_Widget:getChildByName("scale_node"):getChildByName("Image_1")
        local task_tips = m_Widget:getChildByName("scale_node"):getChildByName("Panel_ti")
        task_tips:getChildByName("Image_5"):getChildByName("Text_3"):setString(g_tr("chat_tips"))
        --local task_tishi = m_Widget:getChildByName("scale_node"):getChildByName("Image_12")
        --task_tishi:setLocalZOrder(1)
        local playerData = g_PlayerMode.GetData()

        if playerData == nil then
            return
        end

        local plevel = playerData.level
        local showendlevel = tonumber(g_data.starting[49].data or 0) --显示结束等级
        -- print("showendlevel",showendlevel)
        --引导还未结束
        if plevel < showendlevel then
            --不存在引导特效创建
            if task_border.fx == nil then
                local fx_path = "anime/Effect_ChangKuangShanGuang/Effect_ChangKuangShanGuang.ExportJson"
                local fx_name = "Effect_ChangKuangShanGuang"
                local armature , animation = g_gameTools.LoadCocosAni(fx_path, fx_name)
                task_border:addChild(armature)
                task_border.fx = armature
                armature:setPosition( cc.p(task_border:getContentSize().width/2,task_border:getContentSize().height/2) )
                animation:play("Animation1")
            end

            if task_tips.fx1 == nil then
                local fx_path = "anime/Effect_ChangKuangLiouGuang/Effect_ChangKuangLiouGuang.ExportJson"
                local fx_name = "Effect_ChangKuangLiouGuang"
                local armature , animation = g_gameTools.LoadCocosAni(fx_path, fx_name)
                task_border:addChild(armature)
                task_tips.fx1 = armature
                armature:setPosition( cc.p(task_border:getContentSize().width/2,task_border:getContentSize().height/2) )
                animation:play("Effect_ChangKuangLiouGuang")
            end

            if task_tips.fx2 == nil then
                local fx_path = "anime/Effect_MeiZiXunHuan/Effect_MeiZiXunHuan.ExportJson"
                local fx_name = "Effect_MeiZiXunHuan"
                local armature , animation = g_gameTools.LoadCocosAni(fx_path, fx_name)
                local picImg = task_tips:getChildByName("Image_4")
                picImg:addChild(armature,-1)
                task_tips.fx2 = armature
                armature:setPosition( cc.p(picImg:getContentSize().width/2,picImg:getContentSize().height/2) )
                animation:play("Animation1")
            end

            --if not task_tips:isVisible() and not g_guideManager.getLastShowStep() then
            --    task_tips:setVisible(true)
            --    task_tips.fx1:setVisible(true)
            --    task_tips.fx2:setVisible(true)
            --    task_tips:setScale(0.5)
            --    task_tips:runAction( cc.ScaleTo:create(0.3,1) )
            --else
            task_tips:setVisible(false)
            task_tips.fx1:setVisible(false)
            task_tips.fx2:setVisible(false)
            --end


        else
            --引导结束存在特效删除
            if task_border.fx then
                task_border.fx:setVisible(false)
                --task_border.fx = nil
            end

            --[[if task_tishi.hand then
                task_tishi.hand:setVisible(false)
                --task_border.hand = nil
            end]]

            if task_tips then
               task_tips:setVisible(false) 
            end

            if task_tips.fx1 then
                task_tips.fx1:setVisible(false)
            end

            if task_tips.fx2 then
                task_tips.fx2:setVisible(false)
            end

        end
    end
end

--寻找怪物按钮手型引导动画
function createFindMosterHand()
    if m_Root and m_Widget then
        local findMosterBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_search")
        if findMosterBtn.hand == nil then
            local handImage = cc.Sprite:createWithSpriteFrameName("homeImage_guide_finger.png")
            handImage:setRotation(180)
            handImage:setFlipX(true)
		    handImage:setPosition(cc.p(findMosterBtn:getContentSize().width/2,findMosterBtn:getContentSize().height/2 + 30))
            local moveBy_1 = cc.MoveBy:create(0.6, cc.p(0,30.0))
            local moveBy_2 = cc.MoveBy:create(0.6, cc.p(0,-30.0))
            local moveDelay = cc.DelayTime:create(10)
            local moveFun = cc.CallFunc:create(function ()
                handImage:setVisible(false)
            end)

            local forver = cc.RepeatForever:create( cc.Sequence:create(moveBy_1,moveBy_2) )
		    handImage:runAction(forver)

            local sAction = cc.Sequence:create(moveDelay,moveFun)
            sAction:setTag(1000)
            handImage:runAction(sAction)
		    findMosterBtn:addChild(handImage, 1)
            findMosterBtn.hand = handImage

        else
            local hand = findMosterBtn.hand

            local act1000 = hand:getActionByTag(1000)
            if act1000 then
                hand:stopAction(act1000)
            end

            hand:setVisible(true)
            local moveDelay = cc.DelayTime:create(10)
            local moveFun = cc.CallFunc:create(function ()
                hand:setVisible(false)
            end)
            local sAction = cc.Sequence:create(moveDelay,moveFun)
            sAction:setTag(1000)
            hand:runAction(sAction)
        end
    end
end

--收藏夹
function onBottonCollect(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.map.collectLayer"):createLayer()
    end
end


--聊天
function onButtonChat(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        print("Chat")        
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.chat.ChatLayer").new())
    end
end


function isVoiceEnable()
    if not require("game.audiorecord.audioRecorderHelper"):isAudioRecordSupport() then 
        return false 
    end 

    if not ChatMode.isInBattle() then 
        return false 
    end 
		
	local isEnabled = false
    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    if mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then 
        isEnabled = true
    end 

    return isEnabled 
end 

function initVoiceChat() 
    if m_Root and m_Widget then
        local iconVoice = m_Widget:getChildByName("scale_node"):getChildByName("Image_13"):getChildByName("Image_6")
        local node_anim = m_Widget:getChildByName("scale_node"):getChildByName("Image_13"):getChildByName("Panel_anim") 
        ChatMode.registePressSpeeking(iconVoice, node_anim, isVoiceEnable) 
    end 
end 

function updateChatNewTips(chatType)
    if m_Root and m_Widget then
        --联盟聊天新消息个数红点
        local nodeTips = m_Widget:getChildByName("scale_node"):getChildByName("Image_13"):getChildByName("Panel_hong") 
        local newNum = g_chatData.getNewCount() 
        nodeTips:setVisible(g_AllianceMode.getSelfHaveAlliance() and chatType == ChatMode.getChatTypeEnum().World and newNum > 0)
        if nodeTips:isVisible() then 
            nodeTips:getChildByName("Text_1"):setString(""..newNum)
        end 
    end 
end 

function updateVoiceChat()
    if m_Root and m_Widget then 
        --语音聊天icon
        local iconVoice = m_Widget:getChildByName("scale_node"):getChildByName("Image_13"):getChildByName("Image_6") 
        iconVoice:setVisible(isVoiceEnable())
    end 
end 

function updateChatComponent()  
    print("home:updateChatComponent")

    if m_Root and m_Widget then 
        --聊天内容提示
        local chatType = g_chatData.getChatType()
        updateChatNewTips(chatType) 
        updateVoiceChat()

        local function updateInfo(chatDataItem)             
            if chatDataItem then            
                if chatDataItem.type == chatType then --只更新上次操作记录的聊天
                    --如果在黑名单列表中,则不更新
                    if ChatMode.isInBlackList(chatDataItem.player_id) then 
                        return 
                    end 

                    local str = ""
                    local isSysInfo, desc = ChatMode.getSysInfo(chatDataItem) 
                    if not isSysInfo then 
                        if chatDataItem.paraData and chatDataItem.paraData.filename then --语音聊天
                            str = g_tr("recvVoiceChatTips", {player = chatDataItem.nick})
                        else 
                            desc = chatDataItem.content 
                            str = str .. "|<#255, 250, 145#>"..chatDataItem.nick.."：|"
                        end 
                    end 
                    
                    str = str .. desc
                    if m_RichChat == nil then
                        local listView = m_Widget:getChildByName("scale_node"):getChildByName("Image_13"):getChildByName("ListView_1") 
                        local size = listView:getContentSize()
                        m_RichChat = g_gameTools.createNoModeRichText(str, {fontSize = 24, width = 1000, height = 24},nil,true)
                        m_RichChat:setAnchorPoint(cc.p(0, 1))
                        m_RichChat:setPosition(cc.p(0, size.height))
                        listView:addChild(m_RichChat)
                    else
                        m_RichChat:setRichText(str)
                    end
                end 
            end 
        end 
        
        --第一次登录时显示
        local chatDataItem = g_chatData.getLastWorldChatItem()
        if g_chatData.hasData(chatType) then 
            local data = g_chatData.GetData(chatType, false) 
            if data then 
                chatDataItem = data[#data]
            end  
        end 

        updateInfo(chatDataItem)

        g_chatData.setLastWorldChatItem(nil)
    end 
end 


--控制主动技能图标的显示逻辑
local function isShowSkill( )
    
    if m_Root and m_Widget then
        if g_data.starting[75] and g_data.starting[75].data then
            local playerData = g_PlayerMode.GetData()
            local plevel = playerData.level
            local showendlevel = tonumber(g_data.starting[75].data or 0) --显示结束等级
            return plevel >= showendlevel
        end
        return false
    end

    return false
end


function isSkillBtnShow(  )
    if m_Root and m_Widget then
        local skillBtn = m_Widget:getChildByName("scale_node"):getChildByName("Button_5")
        if not skillBtn:isVisible() then
            viewChangeShow()
            print("skillBtn:isVisible",skillBtn:isVisible())
            return skillBtn:isVisible()
        end
    end
    return false
end

--秘书按钮显示
function isSecretaryBtnShow()
    if m_Root and m_Widget then
        local SecretaryBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_canmou")
        local blevel = g_PlayerBuildMode.FindBuild_high_OriginID(1).build_level
        local playerInfoData = g_playerInfoData.GetData()
        local secretaryStatus = playerInfoData.secretary_status or 3
        
        return ( blevel >= 9 and blevel <= 20 ) and ( secretaryStatus ~= 3 )
    end
end

--城内外切换UI变更
function viewChangeShow()
    if m_Root and m_Widget then

        updateChatComponent() 

        local changeMapScene = require("game.maplayer.changeMapScene")
        local mapStatus = changeMapScene.getCurrentMapStatus()

        local panel_2 = m_Widget:getChildByName("scale_node"):getChildByName("Panel_2")
        local panel_3 = m_Widget:getChildByName("scale_node"):getChildByName("Panel_3")
        
        if mapStatus == changeMapScene.m_MapEnum.home then--城内
            --隐藏小地图图标
            m_Widget:getChildByName("scale_node"):getChildByName("Image_3"):setVisible(false)
            --隐藏收藏夹
            m_Widget:getChildByName("scale_node"):getChildByName("Image_2"):setVisible(false)
            
            --m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames"):setVisible(false)

            --显示任务引导
            m_Widget:getChildByName("scale_node"):getChildByName("Image_12"):setVisible(true)

            m_Widget:getChildByName("scale_node"):getChildByName("Image_1"):setVisible(true)


            m_Widget:getChildByName("scale_node"):getChildByName("Button_5"):setVisible(isShowSkill())

            --任务引导富文本
            if m_Rich then
                m_Rich:setVisible(true)
            end

            m_Widget:getChildByName("scale_node"):getChildByName("Image_search"):setVisible(false)

            m_Widget:getChildByName("scale_node"):getChildByName("Image_canmou"):setVisible(isSecretaryBtnShow())

            vecBtnSort( false )
            
        elseif mapStatus == changeMapScene.m_MapEnum.world then--城外
            --显示小地图图标
            m_Widget:getChildByName("scale_node"):getChildByName("Image_3"):setVisible(true)
            --显示收藏夹
            m_Widget:getChildByName("scale_node"):getChildByName("Image_2"):setVisible(true)

            --m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames"):setVisible(false)

            --隐藏任务引导
            m_Widget:getChildByName("scale_node"):getChildByName("Image_12"):setVisible(false)

            m_Widget:getChildByName("scale_node"):getChildByName("Image_1"):setVisible(false)
            
            m_Widget:getChildByName("scale_node"):getChildByName("Button_5"):setVisible(isShowSkill())

            --任务引导富文本
            if m_Rich then
                m_Rich:setVisible(false)
            end
            --m_Widget:getChildByName("scale_node"):getChildByName("Text_5_0"):setVisible(false)
            --烽火台
            --m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames"):setVisible(false)
            
            m_Widget:getChildByName("scale_node"):getChildByName("Image_search"):setVisible(true)

            vecBtnSort( true )
        elseif mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then--联盟战
            --显示小地图图标
            m_Widget:getChildByName("scale_node"):getChildByName("Image_3"):setVisible(false)
            --显示收藏夹
            m_Widget:getChildByName("scale_node"):getChildByName("Image_2"):setVisible(false)

            --m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames"):setVisible(false)

            --隐藏任务引导
            m_Widget:getChildByName("scale_node"):getChildByName("Image_12"):setVisible(false)

            m_Widget:getChildByName("scale_node"):getChildByName("Image_1"):setVisible(false)
            
            m_Widget:getChildByName("scale_node"):getChildByName("Button_5"):setVisible(false)

            --任务引导富文本
            if m_Rich then
                m_Rich:setVisible(false)
            end
            --m_Widget:getChildByName("scale_node"):getChildByName("Text_5_0"):setVisible(false)
            --烽火台
            --m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames"):setVisible(false)
            
            m_Widget:getChildByName("scale_node"):getChildByName("Image_search"):setVisible(false)

            for idx, var in ipairs(m_BtnSrot) do
                var:setVisible(false)
            end
        end
    end
end

--isH 是否横着排列 城外横城内竖
function vecBtnSort( isH )
    if m_Widget then
        local locPaenl = m_Widget:getChildByName("scale_node"):getChildByName("Panel_dingwei")
        local stepSize = locPaenl:getContentSize().width * 1.25
        --因为城内有一个任务UI 所以会向上挪动一个单位
        local index = 0
        --isH and 0 or 1
        for idx, var in ipairs(m_BtnSrot) do
        
            if var:isVisible() then
                
                if isH then
                    var:setPosition( cc.p( locPaenl:getPositionX() + (stepSize * index ),locPaenl:getPositionY() ) ) 
                else
                    var:setPosition( cc.p( locPaenl:getPositionX() + (stepSize * index ),locPaenl:getPositionY() + stepSize ) ) 
                end 
                    
                    --if idx == 1 then
                        --var:setPosition( cc.p( locPaenl:getPositionX() , locPaenl:getPositionY() + (stepSize * index ) ) ) 
                    --end
                --end

                index = index + 1
            end 
        end
    end
end

function setChatBarVisible(isVisible)
	if m_Root and m_Widget then
		m_Widget:getChildByName("scale_node"):getChildByName("Image_13"):setVisible(isVisible)
	end
end

function getActiveSkillBtn()
    local btn = nil 
    if m_Widget then
        btn = m_Widget:getChildByName("scale_node"):getChildByName("Button_5")
    end
    return btn
end


return mainSurfaceChat