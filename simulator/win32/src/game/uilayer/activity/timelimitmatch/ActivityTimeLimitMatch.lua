--限时比赛
local ActivityTimeLimitMatch = class("ActivityTimeLimitMatch",function()
    return cc.Layer:create()
end)

function ActivityTimeLimitMatch:ctor()
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").SetView(self)
          self:reloadDataAndView()
      elseif eventType == "exit" then
          require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").SetView(nil)
      end 
    end )
end

function ActivityTimeLimitMatch:reloadDataAndView()
    local doUpdateView = function(result)
        g_busyTip.hide_1()
        --updateView 会自动调用
    end
    
    g_busyTip.show_1()
    require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").RequestDataAsync(doUpdateView)
end

function ActivityTimeLimitMatch:updateView()
    --[[
    
    {
    "code": 0,
    "data": {
        'next_match_time' => int 1462291200,
        "config_match": {
            "id": 12,
            "status": 0,
            "start_time": 1461081600,
            "end_time": 1461686400,
            "create_time": 1461132393
        },
        "list_match": [
            {
                "id": 176,
                "time_limit_match_config_id": 12,
                "time_limit_match_id": 2,
                "match_type": 2,
                "match_date_start": 1461081600,
                "match_date_end": 1461168000,
                "award_status": 0
            },
            {
                "id": 177,
                "time_limit_match_config_id": 12,
                "time_limit_match_id": 2,
                "match_type": 4,
                "match_date_start": 1461168000,
                "match_date_end": 1461254400,
                "award_status": 0
            },
            {
                "id": 178,
                "time_limit_match_config_id": 12,
                "time_limit_match_id": 2,
                "match_type": 1,
                "match_date_start": 1461254400,
                "match_date_end": 1461340800,
                "award_status": 0
            },
            {
                "id": 179,
                "time_limit_match_config_id": 12,
                "time_limit_match_id": 2,
                "match_type": 5,
                "match_date_start": 1461340800,
                "match_date_end": 1461427200,
                "award_status": 0
            },
            {
                "id": 180,
                "time_limit_match_config_id": 12,
                "time_limit_match_id": 2,
                "match_type": 9,
                "match_date_start": 1461427200,
                "match_date_end": 1461686400,
                "award_status": 0
            }
        ],
        "today_match": {
            "id": 176,
            "time_limit_match_config_id": 12,
            "time_limit_match_id": 2,
            "match_type": 2,
            "match_date_start": 1461081600,
            "match_date_end": 1461168000,
            "award_status": 0
            
        },
        "player_today_match": {
            "id": 8,
            "player_id": 100652,
            "time_limit_match_list_id": 176,
            "match_type": 2,
            "score": 0,
            "update_time": 1461141649,
            "create_time": 1461141649
        },
        "player_total_match": {
            "id": 3,
            "player_id": 100652,
            "time_limit_match_config_id": 12,
            "time_limit_match_id": 2,
            "score": 0,
            "update_time": 1461141649,
            "create_time": 1461141649
        }
    },
    "basic": [],
    "step": 0,
    "exec_time": 0.03618597984314
}]]

    self:removeAllChildren()
    local matchData = require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").GetData()
    self._matchData = matchData
    dump(matchData)
    
    local matchInfo = require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").GetCustomMatchInfo()
    self._matchInfo = matchInfo
    dump(matchInfo)
    
    if matchInfo.status == 0 then 
        self:initUnOpen()
        
    else
        self:initOpened()
    end
end

function ActivityTimeLimitMatch:initUnOpen()
    if not self._matchData then
        return
    end
    
    local uilayer = cc.CSLoader:createNode("TimeLimitActivity_main1.csb")
    self:addChild(uilayer)
    
    uilayer:getChildByName("Panel_renwu"):loadTexture(g_resManager.getResPath(1030127))

    local timeLabel = uilayer:getChildByName("Text_2")
    local updateTimeStr = function()
      
          local targetTime = self._matchData.next_match_time
          local currentTime = g_clock.getCurServerTime()
          local secondsLeft = targetTime - currentTime
    
          if secondsLeft < 0 then
              secondsLeft = 0
              self:stopAllActions()
              timeLabel:setString("")
              self:reloadDataAndView()
          else
              timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft))
          end
    end
      
    local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
    local action = cc.RepeatForever:create(seq)
    self:runAction(action)
    
    updateTimeStr()
    
    local dropGroups = {}
    for key, var in pairs(g_data.time_limit_match_point_drop) do
        if var.type == 3 --总排名
        and var.max_point == 1 then --第一
           --dropGroups = g_gameTools.getDropGroupByDropIdArray({var.drop},1)
           
            --特殊处理 这里的掉落是个宝箱 策划说要把宝箱里的东西显示出来
            do
                for key, var in pairs(g_gameTools.getDropGroupByDropIdArray({var.drop},1)) do
                    local type = var[1]
                    local id = var[2]
                    local count = var[3]
                    assert(type == g_Consts.DropType.Props)--确定是个道具类型（宝箱）
                    local itemInfo = g_data.item[id]
                    local _dropsgroups = g_gameTools.getDropGroupByDropIdArray(itemInfo.drop,1)
                    for _, dropGroup in pairs(_dropsgroups) do
                        table.insert(dropGroups,dropGroup)
                    end
                end
            end
            --特殊处理end
            
        end
    end
    
    local listView = uilayer:getChildByName("ListView_1")
    listView:setItemsMargin(10)
    for key, var in pairs(dropGroups) do
        local type = var[1]
        local id = var[2]
        local count = var[3]
        local item = require("game.uilayer.common.DropItemView"):create(type,id,count)
        --item:setNameVisible(true)
        g_itemTips.tip(item,type,id)
        listView:pushBackCustomItem(item)
    end
    
    uilayer:getChildByName("Text_mc"):setString(g_tr("limitedMatchFirstAward")) --第一名奖励
    uilayer:getChildByName("Text_4"):setString(g_tr("limitedMatchBestPlayer")) --历史最强主公
    
    g_gameTools.createRichText(uilayer:getChildByName("Text_3"),g_tr("limitedMatchRule")) --规则

    uilayer:getChildByName("Button_1"):addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              g_sceneManager.addNodeForUI(require("game.uilayer.activity.timelimitmatch.LimitTimeMatchHistoryRankList"):create())
          end
    end)
    
end

function ActivityTimeLimitMatch:initOpened()
    local uilayer = cc.CSLoader:createNode("TimeLimitActivity_main2.csb")
    self:addChild(uilayer)
    
    --uilayer:getChildByName("Text_1"):setString(g_tr("limitedMatchMatchType")) --阶段
    uilayer:getChildByName("Text_2"):setString(g_tr("limitedMatchCloseTime")) --结束时间
    uilayer:getChildByName("Text_3"):setString(g_tr("limitedMatchTotalScore")) --总积分
    uilayer:getChildByName("Text_4"):setString(g_tr("limitedMatchNowRank")) --阶段排名
    uilayer:getChildByName("Text_5"):setString(g_tr("limitedMatchTotalRank")) --总排名
    uilayer:getChildByName("Text_6"):setString(g_tr("limitedMatchNowScore")) --阶段积分
    --uilayer:getChildByName("Text_jf"):setString(g_tr("limitedMatchTotalScoreRule")) --积分规则
    
    uilayer:getChildByName("Button_zq"):getChildByName("Text_zq"):setString(g_tr("limitedMatchTotalRank")) --总排名
    uilayer:getChildByName("Button_z"):getChildByName("Text_z"):setString(g_tr("limitedMatchCurrentRank")) --当前排名
    uilayer:getChildByName("Button_l"):getChildByName("Text_l"):setString(g_tr("limitedMatchMyScore")) --我的积分
    
    --阶段目标特效
    local projName = "Effect_FaZhanKeJiZaoJianZhuLiZiTuoWei"
    local animPath = "anime/"..projName.."/"..projName..".ExportJson"
    local animCon = uilayer:getChildByName("Image_jd")
    local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
    animCon:addChild(armature)
    armature:setPosition(cc.p(animCon:getContentSize().width*0.5,animCon:getContentSize().height*0.5))
    animation:play("Animation1")
    
    
    uilayer:getChildByName("Image_24"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            
            local helpId = 0
            --find help type
            do
                for key, var in pairs(g_data.time_limit_match_type) do
                	if var.type == self._matchInfo.match_type then
                	   helpId = var.help_type
                	   break
                	end
                end
            end
            
            if helpId > 0 then
                require("game.uilayer.common.HelpInfoBox"):show(helpId) 
            end
        end 
    end)
    
    --重置标记
    local activityCacheTag = require("game.uilayer.activity.ActivityMainLayer").getActivityCacheTag(1002)
    if g_saveCache[activityCacheTag] ~= self._matchInfo.match_type then
        g_saveCache[activityCacheTag] = self._matchInfo.match_type
    end
    
    --uilayer:getChildByName("Button_l"):setVisible(false)
    
    uilayer:getChildByName("Text_4_0"):setString(self._matchData.rankall.."")
    uilayer:getChildByName("Text_5_0"):setString(self._matchData.rank.."")
    
    --阶段名称
    local typeName = g_tr("limitedMatchTypeName"..self._matchInfo.match_type)
    uilayer:getChildByName("Text_1_0"):setString(typeName)
    
    local matchConfig = g_data.time_limit_match[self._matchInfo.match_id]
    local drops = matchConfig.drop_id
    
    
    --背景图片
    local matchShowId = 0
    do
        for key, var in pairs(g_data.time_limit_match_type) do
          if var.type == self._matchInfo.match_type then
             matchShowId = var.match_show
             break
          end
        end
    end
    
    if matchShowId > 0 then
        uilayer:getChildByName("Image_tupian"):loadTexture(g_resManager.getResPath(matchShowId))
    end
    
    local percent = 0
    
    local a = 0
    local b = 9
    local c = 19
    local d = 54
    local e = 66 
    local f = 100
    
    --0-21 a-b
    --33 -61 c-d
    --71 -100 -e-f
    
    for key, id in ipairs(drops) do
        local dropConfig = g_data.time_limit_match_point_drop[id]
        local isEnoughScore = false
        if self._matchData.player_today_match.score >= dropConfig.min_point
        --and self._matchData.player_today_match.score <= dropConfig.max_point then
        then
            isEnoughScore = true
            uilayer:getChildByName("Image_jiantou"..key.."_0"):setVisible(false)
        end
        
        local dropGroups = {}
        --local dropGroups = g_gameTools.getDropGroupByDropIdArray({var.drop},1)
        --特殊处理 这里的掉落是个宝箱 把宝箱里的东西显示出来
        do
            for key, var in pairs(g_gameTools.getDropGroupByDropIdArray({dropConfig.drop},1)) do
                local type = var[1]
                local id = var[2]
                local count = var[3]
                assert(type == g_Consts.DropType.Props)--确定是个道具类型（宝箱）
                local itemInfo = g_data.item[id]
                local _dropsgroups = g_gameTools.getDropGroupByDropIdArray(itemInfo.drop,1)
                for _, dropGroup in pairs(_dropsgroups) do
                    table.insert(dropGroups,dropGroup)
                end
            end
        end
        
        local type = dropGroups[1][1]
        local id = dropGroups[1][2]
        local count = dropGroups[1][3]
        local container = uilayer:getChildByName("Panel_k"..key)
        local size = container:getContentSize()
        local itemView = require("game.uilayer.common.DropItemView"):create(type,id,count)
        container:addChild(itemView)
        itemView:setPosition(cc.p(size.width*0.5,size.height*0.5))
        itemView:setScale(size.width/itemView:getContentSize().width)
        uilayer:getChildByName("Text_name"..key):setString(itemView:getName())
        
        if key == 1 then
            
            if isEnoughScore then
                percent = b
            else
                local scale = self._matchData.player_today_match.score/dropConfig.min_point
                percent = b * scale
            end
            uilayer:getChildByName("Text_26"):setString(string.formatnumberthousands(dropConfig.min_point))
            uilayer:getChildByName("Image_26"):setVisible(not isEnoughScore)
            uilayer:getChildByName("Image_26_0"):setVisible(isEnoughScore)
            uilayer:getChildByName("Image_26").point = dropConfig.min_point
            uilayer:getChildByName("Image_26_0").point = dropConfig.min_point
        elseif key == 2 then
        
            if isEnoughScore then
                percent = d
            else
                if uilayer:getChildByName("Image_26_0"):isVisible() then
                    local scale = self._matchData.player_today_match.score/dropConfig.min_point
                    percent = (d - c) * scale + c
                end
            end
        
            uilayer:getChildByName("Text_27"):setString(string.formatnumberthousands(dropConfig.min_point))
            uilayer:getChildByName("Image_27"):setVisible(not isEnoughScore)
            uilayer:getChildByName("Image_27_0"):setVisible(isEnoughScore)
            uilayer:getChildByName("Image_27").point = dropConfig.min_point
            uilayer:getChildByName("Image_27_0").point = dropConfig.min_point
        elseif key == 3 then
        
            if isEnoughScore then
                percent = f
            else
                if uilayer:getChildByName("Image_27_0"):isVisible() then
                    local scale = self._matchData.player_today_match.score/dropConfig.min_point
                    percent = (f - e) * scale + e
                end
            end
            
            uilayer:getChildByName("Text_28"):setString(string.formatnumberthousands(dropConfig.min_point))
            uilayer:getChildByName("Image_28"):setVisible(not isEnoughScore)
            uilayer:getChildByName("Image_28_0"):setVisible(isEnoughScore)
            uilayer:getChildByName("Image_28").point = dropConfig.min_point
            uilayer:getChildByName("Image_28_0").point = dropConfig.min_point
        end
        
    end
    
    --进度条
    --uilayer:getChildByName("LoadingBar_2"):setMaxPercent(100)
    print("percent:",percent)
    uilayer:getChildByName("LoadingBar_2"):setPercent(percent)

    local showAwardList = function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              g_sceneManager.addNodeForUI(require("game.uilayer.activity.timelimitmatch.LimitTimeMatchAwardList"):create(self._matchInfo.match_id,2,sender.point))
          end
    end
    
    uilayer:getChildByName("Image_26"):setTouchEnabled(true)
    uilayer:getChildByName("Image_26"):addTouchEventListener(showAwardList)
    
    uilayer:getChildByName("Image_26_0"):setTouchEnabled(true)
    uilayer:getChildByName("Image_26_0"):addTouchEventListener(showAwardList)
    
    uilayer:getChildByName("Image_27"):setTouchEnabled(true)
    uilayer:getChildByName("Image_27"):addTouchEventListener(showAwardList)
    
    uilayer:getChildByName("Image_27_0"):setTouchEnabled(true)
    uilayer:getChildByName("Image_27_0"):addTouchEventListener(showAwardList)
    
    uilayer:getChildByName("Image_28"):setTouchEnabled(true)
    uilayer:getChildByName("Image_28"):addTouchEventListener(showAwardList)
    
    uilayer:getChildByName("Image_28_0"):setTouchEnabled(true)
    uilayer:getChildByName("Image_28_0"):addTouchEventListener(showAwardList)
    
    --结束时间
    local timeLabel = uilayer:getChildByName("Text_2_0")
    timeLabel:setString("")  --废弃不用了
    local updateTimeStr = function()
          
          local isOpend = false
          local targetTime = self._matchInfo.close_time
          local currentTime = g_clock.getCurServerTime()
          
          if currentTime > self._matchInfo.open_time then
             isOpend = true
          else
             targetTime = self._matchInfo.open_time
          end
          
          local secondsLeft = targetTime - currentTime
          if secondsLeft < 0 then
              secondsLeft = 0
              self:stopAllActions()
              if not isOpend then
                 self:reloadDataAndView()
              else
                 --直接显示活动
                 uilayer:getChildByName("Text_2"):setString(g_tr("limitedMatchClosedToday"))
              end
          else
              if isOpend then
                  uilayer:getChildByName("Text_2"):setString(g_tr("limitedMatchCloseTime").." "..g_gameTools.convertSecondToString(secondsLeft)) --结束时间
              else
                  local str = g_tr("limitedMatchNoRanked")
                  uilayer:getChildByName("Text_5_0"):setString(str)
                  
                  local timeTable = g_clock.getCurServerTimeWithTimezone(self._matchInfo.open_time,true)
                  local timeStr = timeTable.hour..":"..string.format("%02d",timeTable.min)
                  uilayer:getChildByName("Text_2"):setString(g_tr("limitedMatchOpenTime",{time = timeStr})) --开始时间
              end
          end
    end
      
    local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
    local action = cc.RepeatForever:create(seq)
    self:runAction(action)
    
    updateTimeStr()
    
   
    --[[
     "player_today_match": {
            "id": 8,
            "player_id": 100652,
            "time_limit_match_list_id": 176,
            "match_type": 2,
            "score": 0,
            "update_time": 1461141649,
            "create_time": 1461141649
        },
        "player_total_match": {
            "id": 3,
            "player_id": 100652,
            "time_limit_match_config_id": 12,
            "score": 0,
            "update_time": 1461141649,
            "create_time": 1461141649
        }]]
        
    --总积分
    uilayer:getChildByName("Text_6_0"):setString(string.formatnumberthousands(self._matchData.player_total_match.score))
    --总排名
    --TODO:
    --uilayer:getChildByName("Text_5_0"):setString(self._matchInfo.player_total_match.score)
    
    --我的积分
    uilayer:getChildByName("Text_3_0"):setString(string.formatnumberthousands(self._matchData.player_today_match.score))
    --阶段排名
    --TODO:
    --uilayer:getChildByName("Text_5_0"):setString(self._matchInfo.player_today_match.score)
    
    --积分规则
    --[[local listView = uilayer:getChildByName("ListView_1")
    local listData = {}
    for key, var in pairs(g_data.time_limit_match_type) do
    	if var.type == self._matchInfo.match_type then
    	   table.insert(listData,var)
    	end
    end
    
    --sort
    --donothing
    
    
    local itemOrginal = cc.CSLoader:createNode("TimeLimitActivity_main2_list.csb")
    --display
    for key, var in ipairs(listData) do
    	local item = itemOrginal:clone()
    	item:getChildByName("Text_zi1"):setString(g_tr(var.language_id,{num = var.point}))
    	listView:pushBackCustomItem(item)
    end
    ]]
    
    --阶段排名奖励  总排名
    local allRankListBtnAward = uilayer:getChildByName("Button_zq")
    allRankListBtnAward:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              g_sceneManager.addNodeForUI(require("game.uilayer.activity.timelimitmatch.LimitTimeMatchTabList"):create(self._matchInfo.match_id,2,scoreNum))
          end
    end)
    
    --当前排名
    local cRankListBtnAward = uilayer:getChildByName("Button_z")
    cRankListBtnAward:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              g_sceneManager.addNodeForUI(require("game.uilayer.activity.timelimitmatch.LimitTimeMatchTabList"):create(self._matchInfo.match_id,1))
          end
    end)
    
    --阶段排名 我的积分
     local cRankListBtn = uilayer:getChildByName("Button_l")
     --[[cRankListBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              g_sceneManager.addNodeForUI(require("game.uilayer.activity.timelimitmatch.LimitTimeMatchRankList"):create(1))
          end
     end)]]
    
end

return ActivityTimeLimitMatch