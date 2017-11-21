--g_guideManager
local guideManager = {}
setmetatable(guideManager,{__index = _G})
setfenv(1,guideManager)

local guideType = 
{
    HOME_MAP = 1,
    UI_NORMAL = 2,
    WORLD_MAP = 3,
    DIALOGUE = 4,
    ANIMA = 5,
    PICTURE = 6,
}

--添加后请参照下面例子的方式注册(添加新的模块后【务必注册！】【务必注册！】【务必注册！】)
--例：g_guideManager.registGameFeature(rootLayer,g_guideManager.gameFeatures.SHOP)
gameFeatures = 
{
    HOME_MAP         = 1, --主城地图
    DRILL_GROUND     = 2, --校场
    WORLD_MAP        = 3,--世界地图
    SMITHY           = 4,--铁匠铺
    SHOP             = 5,--商店
    MASTER_DETAIL    = 6,--主公详情页面
    ALLIANCE_SHOP    = 7,--联盟商店
    ACTIVITY         = 8,--活动
    MOFANG           = 9,--磨坊
    ALLIANCE         = 10,--联盟
    TOURNAMENT       = 11,--武斗
    
    --添加新的模块后务必在相关界面注册！【务必注册！】【务必注册！】【务必注册！】
    --TODO:继续添加用到的游戏模块
    
}

isHaveDialogueOnShow = false
isHaveAnimatureOnShow = false

local guideDebug = g_logicDebug
local isRunning = false
local lastAfterClickCallBack = nil
local worldMapPos = nil --大地图坐标
local m_lastShowStep = nil
local m_specialCallbacks = {}
local m_registedComponents = {}
local m_registedGameFeatures = {}
local currentGameFeatureInfo = nil


--判断是否符合执行条件
local function checkConditions(guideInfo)
    local meetCondition = true
    local configInfo = guideInfo:getConfig()
    
    --是否符合主公等级
    local playerLevel = g_PlayerMode.GetData().level
    meetCondition = playerLevel >= configInfo.need_level 
    
    --是否符合建筑等级
    if meetCondition and #configInfo.build_ids > 0 then
        for key, buildId in pairs(configInfo.build_ids) do
            local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(buildId)
            meetCondition = enoughCount > 0
            if not meetCondition then
               break
            end
        end
    end
    
    --是否符合科技等级
    if meetCondition and #configInfo.science_ids > 0 then
        for key, scienceId in pairs(configInfo.science_ids) do
            meetCondition = require("game.uilayer.science.Science"):instance():isLearned(scienceId)
            if not meetCondition then
               break
            end
        end
    end
    
    --是否符合活动开启
    if meetCondition and configInfo.activity_ids and #configInfo.activity_ids > 0 then
        for key, activityId in ipairs(configInfo.activity_ids) do
            meetCondition = require("game.uilayer.activity.ActivityMainLayer").checkIsVaildActivity(activityId)
            if not meetCondition then
               break
            end 
        end
    end
    
   --是否需要拥有道具
    if meetCondition and configInfo.item_ids and #configInfo.item_ids > 0 then 
        for key, itemId in ipairs(configInfo.item_ids) do
          local haveNum = 0
          local bagData = g_BagMode.FindItemByID(itemId)
          if bagData and bagData.num then
             haveNum = bagData.num
          end
          if haveNum == 0 then
             meetCondition = false
             break
          end
        end
    end
    
    --是否需要拥有武将
    if meetCondition and configInfo.general_ids and #configInfo.general_ids > 0 then --武将的general_original_id
      local ownedGenerals = g_GeneralMode.getOwnedGenerals()
      for key, generalId in ipairs(configInfo.general_ids) do
          if ownedGenerals[generalId] == nil then
              meetCondition = false
              break
          end
      end
    end
    
    --需要拥有的武将（和神武将）的数量
    if meetCondition and configInfo.need_general_num and configInfo.need_general_num > 0 then 
        local num = table.nums(g_GeneralMode.getOwnedGenerals())
        if num < configInfo.need_general_num then
             meetCondition = false
        end
    end
    
    --是否为创建联盟引导
    if meetCondition then
        if configInfo.creation_alliance and configInfo.creation_alliance == 1 then --自己为创建者
            meetCondition = false
            if g_AllianceMode.getSelfHaveAlliance() then
                if tonumber(g_PlayerMode.GetData().id) == tonumber(g_AllianceMode.getBaseData().founder) then
                    meetCondition = true
                end
            end 
        elseif configInfo.join_alliance and configInfo.join_alliance == 1 then --自己为加入者
            meetCondition = false
            if g_AllianceMode.getSelfHaveAlliance() then
                if tonumber(g_PlayerMode.GetData().id) ~= tonumber(g_AllianceMode.getBaseData().founder) then
                    meetCondition = true
                end
            end 
        end
    end
    
    --开服活动是否为开启状态
    if meetCondition then
        local allSteps = guideInfo:getGuideSteps()
        for key, currentStep in pairs(allSteps) do
            if currentStep:getConfig().guide_type == guideType.ANIMA then --动画
                local animateType = currentStep:getConfig().params[1]
                if animateType == 8 then --开服活动
                    meetCondition = g_activityData.ShowNewbieIcon()
                    break
                end
            end
        end
    end
    
    return meetCondition
end

--判断是否跳过该步
local function checkSkip(step)

    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    local isSkip = false
    if currentGameFeatureInfo then
        for key, var in pairs(step:getConfig().skip_game_features) do
            if mapStatus == changeMapScene.m_MapEnum.home then
                if var == gameFeatures.HOME_MAP then
                    isSkip = true
                end
            elseif mapStatus == changeMapScene.m_MapEnum.world or mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then
                if var == gameFeatures.WORLD_MAP then
                    isSkip = true
                end
            end
            
            if isSkip then
                break
            else
                if var == currentGameFeatureInfo.gameFeature then
                   isSkip = true
                   break
                end
            end
        end
    end
    return isSkip
end

local createTouchLayer = function()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0))
    local listener = cc.EventListenerTouchOneByOne:create()
    local onTouchBegan = function(touch,event)
        return true
    end
    
    local onTouchEnded = function(touch,event)
       
    end
    
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,layer)
    
    return layer
end

--狂点错后的回调
local madCallback = function()
    --clearGuideLayer()
    g_airBox.show(g_tr("guideErrorTip"))
end

local checkHaveMapElement = function(pos)
    local touchLayer = createTouchLayer()
    g_sceneManager.addNodeForGuideDisplay(touchLayer)

    local haveMapElement = require("game.maplayer.worldMapLayer_bigMap").hasMapElement_bigTileIndex(pos)
    
    if haveMapElement then
        isRunning = false
        touchLayer:removeFromParent()
        g_guideManager.execute()
    else
        local sche = nil
        local scheduler = cc.Director:getInstance():getScheduler()
        local cnt = 0
        local function callback()
            haveMapElement = require("game.maplayer.worldMapLayer_bigMap").hasMapElement_bigTileIndex(pos)
            if haveMapElement then
                scheduler:unscheduleScriptEntry(sche) 
                isRunning = false
                touchLayer:removeFromParent()
                g_guideManager.execute()
            end
        end
        --确保成功
        sche = scheduler:scheduleScriptFunc(callback, 0.25, false)
    end
end

--special_callback
--define 
--type 1
local gotoWorldMapResource = function()          
    
    if isRunning then
        return
    end
    
    isRunning = true
                         
    local pos = cc.p(g_PlayerMode.GetData().x,g_PlayerMode.GetData().y)
    
    local sche = nil
    local scheduler = cc.Director:getInstance():getScheduler()
    --获取xy最近的一个金矿资源
    local getPosFuc = function()
        local getPosResult = function(result, msgData)
          if result then
             scheduler:unscheduleScriptEntry(sche) 
             pos = cc.p(tonumber(msgData.x),tonumber(msgData.y))
             --pos = cc.p(g_PlayerMode.GetData().x,g_PlayerMode.GetData().y)
             worldMapPos = pos
             require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex(pos,function()
                checkHaveMapElement(pos)
             end)
          else
             print("fail ,wait for retry")
          end
        end
        
        print("get res pos")
        g_sgHttp.postData("Map/getResourcePosition",{type = 9},getPosResult)
    end
    --确保成功
    sche = scheduler:scheduleScriptFunc(getPosFuc, 0.25, false)
end
m_specialCallbacks[1] = gotoWorldMapResource

--define 
--type 2
--返回首页
local gohome = function(successCallback)
    g_sceneManager.clearInterfaceForGuide()
    require("game.maplayer.changeMapScene").changeToHome(false,successCallback)
end
m_specialCallbacks[2] = gohome

local findMonster = function()
    if isRunning then
        return
    end
    
    isRunning = true
    local pos = cc.p(g_PlayerMode.GetData().x,g_PlayerMode.GetData().y)
    
    local sche = nil
    local scheduler = cc.Director:getInstance():getScheduler()
    --搜索一个一级怪(新手引导用的怪)
      --获取xy最近的一个金矿资源
    local getPosFuc = function()
        local getPosResult = function(result, msgData)
          if result then
             scheduler:unscheduleScriptEntry(sche) 
             pos = cc.p(tonumber(msgData.x),tonumber(msgData.y))
             --pos = cc.p(g_PlayerMode.GetData().x,g_PlayerMode.GetData().y)
             worldMapPos = pos
             require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex(pos,function()
                checkHaveMapElement(pos)
             end)
          else
             print("fail ,wait for retry")
          end
        end
        
        print("get monster pos")
        g_sgHttp.postData("map/getNpcPosition",{},getPosResult)
    end
    --确保成功
    sche = scheduler:scheduleScriptFunc(getPosFuc, 0.25, false)

end
m_specialCallbacks[3] = findMonster

local serverCheckGuideConditions = function(type)
    g_sgHttp.postData("player/tutorialCheck",{type = type},function(result, msgData)
      if result then
         print("guide: check army success")
      end
    end)
end
--4=检测是否存在出征时的黄盖士兵数量 10001,10
--5=检测校场编组时第二个位置的士兵数量 30001,10
--6=检测黄盖与徐盛2个人出征时的士兵数量10001,10；30001,10
local checkArmy_1 = function()
    serverCheckGuideConditions(1)
end
m_specialCallbacks[4] = checkArmy_1

local checkArmy_2 = function()
    serverCheckGuideConditions(2)
end
m_specialCallbacks[5] = checkArmy_2

local checkArmy_3 = function()
    serverCheckGuideConditions(3)
end
m_specialCallbacks[6] = checkArmy_3

local function isEnableExecute()
    local enabled = true
    if not g_guideEnabled 
    or g_sceneManager.getCurrentSceneMode() ~= g_sceneManager.sceneMode.game
    or tonumber(g_playerInfoData.GetData().skip_newbie) > 0
    or require("game.uilayer.master.MasterLevelUpView").getViewIsOpen()
    or require("game.uilayer.pub.pubGeneralAnimation").isPubAnimOnShow()
    then
         enabled = false
    end
    return enabled
end

--执行一步符合条件的新手引导
--如果clickCallback填写，则点击该步引导仅执行clickCallback
function execute(clickCallback)
    if isHaveDialogueOnShow or isHaveAnimatureOnShow then
        return false
    end

    if isRunning then
        return false
    end
    isRunning = true
    
    clearGuideLayer()
    
    local isSuccessExecuted = false
    if not isEnableExecute() then
        isRunning = false
        return isSuccessExecuted
    end
    
    local currentGuideInfo = g_guideData.getCurrentGuideInfo()
    
    --查找非强制引导
    if currentGuideInfo == nil then
        for key, guideInfo in ipairs(g_guideData.getOutOfOrderGuides()) do
            local saved = false
            for key, var in pairs(g_guideData.getSavedOutOfOrderStepIds()) do
                if guideInfo:getGuideId() == var then
                   saved = true
                   break
                end
            end
            
            if (not saved or not guideInfo:getIsFinished()) then
               if checkConditions(guideInfo) then
                   currentGuideInfo = guideInfo
                   break
               end
            end
        end
    end
    
    if not currentGuideInfo then
        isRunning = false
        return isSuccessExecuted
    end
    
    --获取即将执行的步骤
    local currentStep = currentGuideInfo:getCurrentStep()
    if guideDebug then
        print("target step:")
        dump(currentStep)
    end
    
    --判断是否符合条件
    local meetCondition = checkConditions(currentGuideInfo)
    if meetCondition then
    
        --判断是否需要忽略这一步
        local isSkip = checkSkip(currentStep)
        if isSkip then
           currentGuideInfo:goNextStep()
           isRunning = false
           return g_guideManager.execute()
        end
    
        local needClickNode = nil
        local needClickNodeId = -1
        local isHideMask = currentStep:getConfig().black_bg == 0
        if currentStep:getConfig().guide_type == guideType.HOME_MAP then
            local place = currentStep:getConfig().homemap_position
            if place <= 0 then
                local buildData = g_PlayerBuildMode.FindBuild_high_OriginID(currentStep:getConfig().build_origin_id)
                if buildData then
                    place = buildData.position
                end
            end
            require("game.maplayer.changeMapScene").gotoHome_Place(place)
            needClickNodeId = place
        elseif currentStep:getConfig().guide_type == guideType.WORLD_MAP then
            --donothing
        elseif currentStep:getConfig().guide_type == guideType.UI_NORMAL then
            needClickNodeId = currentStep:getConfig().click_node_id
        elseif currentStep:getConfig().guide_type == guideType.DIALOGUE then
            --donothing
        end
        
        needClickNode = m_registedComponents[needClickNodeId]
        
        local haveTips = currentStep:getConfig().lightning_tip > 0
        
        --处理特殊步骤
        --special_callback_type: 1=跳过原有功能，执行special_callback功能,2=保留原有功能执行special_callback功能,3=引导触发时执行special_callback功能
        if not clickCallback and currentStep:getConfig().special_callback > 0 and currentStep:getConfig().special_callback_type == 1 then 
            clickCallback = m_specialCallbacks[currentStep:getConfig().special_callback]
        elseif currentStep:getConfig().special_callback > 0 and currentStep:getConfig().special_callback_type == 2 then
            lastAfterClickCallBack = m_specialCallbacks[currentStep:getConfig().special_callback]
        end
        
        local handAngle = currentStep:getConfig().finger_angle or 0
        local basicEffectCircleRadius = 50
        local hideBasicEffect = nil
            
        if needClickNode then
            local isCloseTouchMove = true
            local maskType = currentStep:getConfig().mask_type
            g_guideNodes.guideNodes_create_with_needClickNode(needClickNode , maskType , clickCallback , madCallback , haveTips , isCloseTouchMove , isHideMask, hideBasicEffect, basicEffectCircleRadius ,handAngle)
            isSuccessExecuted = true
        elseif currentStep:getConfig().guide_type == guideType.WORLD_MAP then
            g_guideNodes.guideNodes_create_with_bigTileIndex( worldMapPos , clickCallback , madCallback , haveTips , isHideMask ,hideBasicEffect , basicEffectCircleRadius , handAngle)
            isSuccessExecuted = true
        elseif currentStep:getConfig().guide_type == guideType.DIALOGUE then --对话
        
            
            local showDialogue = function()
                local str = g_tr(currentStep:getConfig().desc)
                local layer = require("game.uilayer.common.DialogueLayer"):create(str,clickCallback,currentStep:getConfig().img,currentStep:getConfig().desc_name,currentStep:getConfig().params[1],currentStep:getConfig().params[2],true)
                g_sceneManager.addNodeForGuideDisplay(layer)
            end
            
            if currentStep:getConfig().time_late > 0 then
                isHaveDialogueOnShow = true
                local touchLayer = createTouchLayer()
                g_sceneManager.addNodeForGuideDisplay(touchLayer)
                local action = cc.Sequence:create(cc.DelayTime:create(currentStep:getConfig().time_late),cc.CallFunc:create(function()
                    isHaveDialogueOnShow = false
                    showDialogue()
                    touchLayer:removeFromParent()
                end))
                touchLayer:runAction(action)
            else
                showDialogue()
            end
            
            isSuccessExecuted = true
        elseif currentStep:getConfig().guide_type == guideType.ANIMA then --动画
            isHaveAnimatureOnShow = true
            local layer = createTouchLayer()
            g_sceneManager.addNodeForGuideDisplay(layer)
            
            local function callback()
                isHaveAnimatureOnShow = false
                layer:removeFromParent()
                if isSuccessExecuted then
                    g_guideManager.execute()
                end
            end 
            
            --[[
            params=1 武将拜访动画
            params=2 多个功能开启
            params=3 成长任务飞入
            params=4 事件条加入
            params=5 主动技飞入
            params=6 联盟堡垒高亮
            ]]
            local animateType = currentStep:getConfig().params[1]
            if animateType == 1 then --拜访动画
                require("game.maplayer.homeMapLayer").playGuide_1(callback)
                isSuccessExecuted = true
            elseif animateType == 2 then --多个功能开启
                local widget = require("game.uilayer.mainSurface.mainSurfacePlayer").getWidget()
                if widget then
                    local gotoHomeSuccess = function()
                        local shopBtn = widget:getChildByName("scale_node"):getChildByName("Image_huodong")
                        local timeAwardBtn = widget:getChildByName("scale_node"):getChildByName("Image_time")
                        --local giftBtn = widget:getChildByName("scale_node"):getChildByName("Image_libao")
                        local targetIcons = {timeAwardBtn,shopBtn}
                        require("game.guidelayer.guideHelper").playIconOpenEffect(targetIcons,function()
                           callback()
                        end)
                    end
                    
                    gohome(gotoHomeSuccess) --回首页并清除所有打开的界面
                    
                    isSuccessExecuted = true
                else
                    callback()
                end
            elseif animateType == 3 then --活动和成长任务飞入
                local widget = require("game.uilayer.mainSurface.mainSurfacePlayer").getWidget()
                if widget then
                    local gotoHomeSuccess = function()
                        local activityBtn = widget:getChildByName("scale_node"):getChildByName("Image_Ranking_0")
                        local targetActivityBtn = widget:getChildByName("scale_node"):getChildByName("Image_xs")
                        
                        local targetIcons = {targetActivityBtn,activityBtn}
                        require("game.guidelayer.guideHelper").playIconOpenEffect(targetIcons,function()
                           callback()
                        end)
                    end
                    
                    gohome(gotoHomeSuccess) --回首页并清除所有打开的界面
                    
                    isSuccessExecuted = true
                else
                    callback()
                end
            elseif animateType == 4 then --事件条加入
                require("game.uilayer.mainSurface.mainSurfaceEventBar").setEventBarVisible(false)
                
                local gotoHomeSuccess = function()
                    require("game.uilayer.mainSurface.mainSurfaceEventBar").updateEventBarVisible(true)
                    local delay = 3
                    if currentStep:getConfig().time_late and currentStep:getConfig().time_late > 0 then
                        delay = currentStep:getConfig().time_late
                    end
                    g_autoCallback.addCocosList( callback , delay )
                end
                
                gohome(gotoHomeSuccess) --回首页并清除所有打开的界面
                
                isSuccessExecuted = true
                
            elseif animateType == 5 then --主动技飞入
                local btn = require("game.uilayer.mainSurface.mainSurfaceChat").getActiveSkillBtn()
                if btn then
                
                    g_sceneManager.clearInterfaceForGuide() --清除所有打开的界面
                    
                    local targetIcons = {btn}
                    require("game.guidelayer.guideHelper").playIconOpenEffect(targetIcons,function()
                       callback()
                    end)
                    isSuccessExecuted = true
                else
                    callback()
                end
            elseif animateType == 6 then --联盟堡垒高亮
                
                --playEffect
                local projName = "Effect_LianMengLingDiJieMianXunHuan"
                local animPath = "anime/"..projName.."/"..projName..".ExportJson"
                local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
                g_sceneManager.addNodeForGuideDisplay(armature)
                armature:setScale(g_display.scale)
                armature:setPositionX(g_display.cx)
                armature:setPositionY(g_display.cy)
                animation:play("Animation1")
                
                local removeAnima = function()
                    if armature then
                        armature:removeFromParent()
                        callback()
                    end
                end
                
                g_autoCallback.addCocosList( removeAnima , currentStep:getConfig().time_late or 1 )
                
                isSuccessExecuted = true
            elseif animateType == 7 then --化神界面提示动画
                layer:removeFromParent()
                layer = cc.LayerColor:create(cc.c4b(0,0,0,0))
                local listener = cc.EventListenerTouchOneByOne:create()
                local onTouchBegan = function(touch,event)
                    return true
                end
                
                local onTouchEnded = function(touch,event)
                    callback()
                end
                
                listener:setSwallowTouches(true)
                listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
                listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
                cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,layer)

                --playEffect
                local projName = "Effect_ShenWuJianHuaShenZhiYin"
                local animPath = "anime/"..projName.."/"..projName..".ExportJson"
                local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
                armature:setScale(g_display.scale)
                armature:setPositionX(g_display.cx)
                armature:setPositionY(g_display.cy)
                animation:play("Animation1")
                layer:addChild(armature)
                g_sceneManager.addNodeForGuideDisplay(layer)
                isSuccessExecuted = true
            elseif animateType == 8 then --开服活动入口按钮飞入动画
                local widget = require("game.uilayer.mainSurface.mainSurfacePlayer").getWidget()
                local btn = nil
                if widget then
                    btn = widget:getChildByName("scale_node"):getChildByName("Image_cz1")
                end
                if btn then
                    g_sceneManager.clearInterfaceForGuide() --清除所有打开的界面
                    
                    local targetIcons = {btn}
                    require("game.guidelayer.guideHelper").playIconOpenEffect(targetIcons,function()
                       callback()
                    end)
                end
                isSuccessExecuted = true
            else
                callback()
            end

        elseif currentStep:getConfig().guide_type == guideType.PICTURE then --图片
            local layer = cc.LayerColor:create(cc.c4b(0,0,0,190))
            local listener = cc.EventListenerTouchOneByOne:create()
            local onTouchBegan = function(touch,event)
                return true
            end
            
            local onTouchEnded = function(touch,event)
                layer:removeFromParent()
                if clickCallback then
                    clickCallback()
                end
                g_guideManager.execute()
            end
            
            listener:setSwallowTouches(true)
            listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
            listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
            cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,layer)
            
            local pic = g_resManager.getRes(currentStep:getConfig().desc)
            if pic then
                layer:addChild(pic)
            end
            g_sceneManager.addNodeForGuideDisplay(layer)
            
            isSuccessExecuted = true
        end
        
        --如果成功执行，引导往后走一步
        if isSuccessExecuted then
            if guideDebug then
                print("current step:")
                dump(currentStep:getConfig())
            end
            m_lastShowStep = currentStep
            g_guideData.saveIdOnStepShow(currentStep)
            
            --执行specialcallback_type 为3 的方法
            if currentStep:getConfig().special_callback > 0 and currentStep:getConfig().special_callback_type == 3 then 
                local callback = m_specialCallbacks[currentStep:getConfig().special_callback]
                if callback then
                    callback()
                end
            end
            
            currentGuideInfo:goNextStep()
        end
    end
    
    if isSuccessExecuted then
        require("game.uilayer.mainSurface.mainSurfaceChat").taskUpdate()
        g_gameCommon.dispatchEvent(g_Consts.CustomEvent.GiudeTrigged)
    end
    
    if guideDebug then
        print("isSuccessExecuted:",isSuccessExecuted) 
    end
    
    isRunning = false
    return isSuccessExecuted,currentStep
end

--清除新手引导层
function clearGuideLayer()
    if m_lastShowStep then
        --执行上部引导结束后指定的回调
        if lastAfterClickCallBack then
            lastAfterClickCallBack()
        end
        lastAfterClickCallBack = nil
    end
    
    g_guideData.saveIdOnStepClose(m_lastShowStep)
    m_lastShowStep = nil
    g_guideNodes.guideNodes_clear()
end

--当前显示的引导步骤 如果为nil则表示当前没有显示的引导
function getLastShowStep()
    return m_lastShowStep
end

function getToSaveStepId()
    local steps = nil
    if m_lastShowStep and m_lastShowStep:getGuideInfo() then
        --if m_lastShowStep:getId() > g_guideData.getCurrentServerStepId() then
        local guideInfo = m_lastShowStep:getGuideInfo()
        if guideInfo:getIsOutOfOrderType() then
            steps = {}
            steps.step_set =  guideInfo:getGuideId() 
        else
            if guideInfo:getGuideId() > g_guideData.getCurrentServerStepId() then
                steps = {}
                steps.step = guideInfo:getGuideId()
            end
        end
    end
    return steps
end

function unregistComponent(componentId)
    m_registedComponents[componentId] = nil
end

--注册需要操作的node 
function registComponent(componentId,needClickNode)
    m_registedComponents[componentId] = needClickNode
    
    local node = cc.Node:create()
    local function nodeEventHandler(eventType)
        if eventType == "enter" then
        elseif eventType == "exit" then
           m_registedComponents[componentId] = nil
        end
    end
    node:registerScriptHandler(nodeEventHandler)
    needClickNode:addChild(node)
end

local registGameFeatureChildNameDefine = "__registGameFeatureChildNameDefine__"


--注册一个ui属于哪个游戏功能,用于某些步骤在指定界面直接跳过（只需注册该功能主界面即可）
function registGameFeature(rootLayer,gameFeature)
    
    if rootLayer:getChildByName(registGameFeatureChildNameDefine) then --不能重复注册
        return
    end

    local featureInfo = {}
    local node = cc.Node:create()
    node:setName(registGameFeatureChildNameDefine)
    featureInfo.node = node
    featureInfo.rootLayer = rootLayer
    featureInfo.gameFeature = gameFeature
    
    local function nodeEventHandler(eventType)
        if eventType == "enter" then
           table.insert(m_registedGameFeatures,featureInfo)
           currentGameFeatureInfo = m_registedGameFeatures[#m_registedGameFeatures]
        elseif eventType == "exit" then
           table.remove(m_registedGameFeatures,#m_registedGameFeatures)
           currentGameFeatureInfo = m_registedGameFeatures[#m_registedGameFeatures]
        elseif eventType == "enterTransitionFinish" then
        elseif eventType == "exitTransitionStart" then
        elseif eventType == "cleanup" then
        end
    end
    node:registerScriptHandler(nodeEventHandler)
    rootLayer:addChild(node)
end

--界面快速跳转相关的接口
local function isGameFeatureOnShow(gameFeature)
    local isOnShow = false 
    local showLayer = nil
    for key, var in ipairs(m_registedGameFeatures) do
        if var.gameFeature == gameFeature then
           isOnShow = true 
           showLayer = var.rootLayer
        end
    end
    return isOnShow,showLayer
end

function removeGameFeature(gameFeature)
    if gameFeature == gameFeatures.HOME_MAP
    or gameFeature == gameFeatures.WORLD_MAP then
       return 
    end

    local _,oldLayer = isGameFeatureOnShow(gameFeature)
    if oldLayer then
        oldLayer:removeFromParent()
    end
end

--直接跳转到某个游戏UI界面
function gotoGameFeature(gameFeature, para)
    removeGameFeature(gameFeature)
    if gameFeature == gameFeatures.HOME_MAP then
        require("game.maplayer.changeMapScene").changeToHome()
    elseif gameFeature == gameFeatures.WORLD_MAP then
        require("game.maplayer.changeMapScene").changeToWorld()
    elseif gameFeature == gameFeatures.SMITHY then
        local SmithyData = require("game.uilayer.smithy.SmithyData")
        if nil == para then 
            para = {} 
        end 
        g_sceneManager.addNodeForUI(require("game.uilayer.smithy.SmithyBaseLayer").new(para.type, para.val))
    elseif gameFeature == gameFeatures.SHOP then
        local shopLayer = require("game.uilayer.shop.ShopLayer"):create(g_Consts.ShopType.NORMAL)
        if para then
            if para.tag then
                shopLayer:tabTags(para.tag)
            end
            
            if para.closeCallback then
                shopLayer:setCloseCallBack(para.closeCallback)
            end
        end
        g_sceneManager.addNodeForUI(shopLayer)
        
    elseif gameFeature == gameFeatures.ALLIANCE_SHOP then
        if g_AllianceMode.getSelfHaveAlliance() == false then
            g_airBox.show(g_tr("battleHallNoAlliance"))
            return
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.shop.ShopLayer"):create(g_Consts.ShopType.ALLIANCE_PLAYER))
    elseif gameFeature == gameFeatures.ACTIVITY then
        assert(para)
        local activityId = para.activity_id or 0
        require("game.uilayer.activity.ActivityMainLayer").show(activityId,para.params)
    elseif gameFeature == gameFeatures.MOFANG then
        g_sceneManager.addNodeForUI(require("game.uilayer.mill.MillLayer"):create())
    elseif gameFeature == gameFeatures.ALLIANCE then
        g_sceneManager.addNodeForUI(require("game.uilayer.alliance.AllianceMainLayer"):create())
    elseif gameFeature == gameFeatures.TOURNAMENT then
        require("game.uilayer.fightperipheral.FightPrepare").show()
    end
end

return guideManager