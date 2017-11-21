local FightReward = class("FightReward",function()
    return cc.Layer:create()
end)

local function _getRankByScore(score)
    return g_expeditionData.getRankByScore(score)
end

function FightReward:ctor()
    
    local uiLayer =  g_gameTools.LoadCocosUI("ArenaRanking_reward1.csb",5)
    self:addChild(uiLayer)
    --g_resourcesInterface.installResources(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent()
          end
    end)
    
    baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("peripheral_reward_title")) --奖励
    
    
    local dailyBtn = baseNode:getChildByName("Button_j1") --每日奖励
    local rankBtn = baseNode:getChildByName("Button_j1_0") --段位奖励
    local seasonBtn = baseNode:getChildByName("Button_j2") --赛季奖励
    dailyBtn:getChildByName("Text_1"):setString(g_tr("peripheral_reward_btntxt1"))
    dailyBtn:getChildByName("Image_2"):setVisible(false)
    rankBtn:getChildByName("Text_1"):setString(g_tr("peripheral_reward_btntxt2"))
    rankBtn:getChildByName("Image_2"):setVisible(false)
    seasonBtn:getChildByName("Text_1"):setString(g_tr("peripheral_reward_btntxt4"))
    seasonBtn:getChildByName("Image_2"):setVisible(false)
    
    local btnArr = {dailyBtn,rankBtn,seasonBtn}
    
    local selectBtn = function(currentBtn)
        for key, btn in pairs(btnArr) do
        	btn:setEnabled(true)
        	if key == 1 then
        	   btn:getChildByName("Image_2"):setVisible(g_expeditionData.IsHaveDailyTimesReward())
        	end
        	if key == 2 then
        	   btn:getChildByName("Image_2"):setVisible(g_expeditionData.IsHaveDailyRankReward())
        	end
        end
        currentBtn:setEnabled(false)
        currentBtn:getChildByName("Image_2"):setVisible(false)
    end
    
    local daliyListView = baseNode:getChildByName("ListView_1")
    local rankRewardCon = baseNode:getChildByName("Panel_1")
    local seasonRewardCon = baseNode:getChildByName("Panel_2")
    
    rankRewardCon:getChildByName("Text_10"):setString(g_tr("peripheral_reward_rankdesc"))
    seasonRewardCon:getChildByName("Text_10"):setString(g_tr("peripheral_reward_seasondesc"))
    
    daliyListView:setVisible(false)
    rankRewardCon:setVisible(false)
    seasonRewardCon:setVisible(false)
    
    dailyBtn:addClickEventListener(function()
        selectBtn(dailyBtn)
        baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("peripheral_reward_title"))
        rankRewardCon:setVisible(false)
        daliyListView:setVisible(true)
        seasonRewardCon:setVisible(false)
        
    end)
    rankBtn:addClickEventListener(function()
        selectBtn(rankBtn)
        baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("peripheral_reward_title"))
        rankRewardCon:setVisible(true)
        daliyListView:setVisible(false)
        seasonRewardCon:setVisible(false)
    end)
    
    seasonBtn:addClickEventListener(function()
        selectBtn(seasonBtn)
        baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("peripheral_reward_season_title"))
        rankRewardCon:setVisible(false)
        daliyListView:setVisible(false)
        seasonRewardCon:setVisible(true)
    end)
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          --async
--          g_busyTip.show_1()
--          g_busyTip.hide_1()
            dailyBtn:setEnabled(false)
            daliyListView:setVisible(true)
            rankRewardCon:setVisible(false)
            
            local exditionData = g_expeditionData.GetData()
            local awardExecTime = exditionData.award_exec_date
            local nextAwardExecTime = awardExecTime + 60 * 60 * 24
            local awardNeedUpdate = awardExecTime > 0 and nextAwardExecTime < g_clock.getCurServerTime()
            
            local dailyResetTime = exditionData.daily_reset_exec_date
            local nextDailyResetTime = dailyResetTime + 60 * 60 * 24
            local dailyResetNeedUpdate = dailyResetTime > 0 and nextDailyResetTime < g_clock.getCurServerTime()
            
            if awardNeedUpdate or dailyResetNeedUpdate then
                g_busyTip.show_1()
                g_expeditionData.RequestDataAsync(function(result, msgData)
                    g_busyTip.hide_1()
                    if result == true then
                        self:updateView()
                        selectBtn(dailyBtn)
                    else
                        self:removeFromParent()
                    end
                end)
            else
                self:updateView()
                selectBtn(dailyBtn)
            end
      elseif eventType == "exit" then

      end
      
    end )

end

function FightReward:updateView()
    local baseNode = self._baseNode
    local daliyListView = baseNode:getChildByName("ListView_1")
    daliyListView:removeAllChildren()
    local rankRewardCon = baseNode:getChildByName("Panel_1")
    local seasonRewardCon = baseNode:getChildByName("Panel_2")
    
    local exditionData = g_expeditionData.GetData()
    local todayMatchTimes = exditionData.current_day_match_times
    local currentDayGainId = exditionData.current_day_gain_id
    
    local rank = exditionData.duel_rank_id
    if rank < 1 then
      rank = 1
    end
    
    --每日
    do
        for key, var in pairs(g_data.duel_times_bonus) do
           local item = cc.CSLoader:createNode("ArenaRanking_reward_list1.csb") 
           local dropGroups = g_gameTools.getDropGroupByDropIdArray(var.drops)
           local listView = item:getChildByName("ListView_1")
           item:getChildByName("Text_q2"):setString(var.times.."")
           item:getChildByName("Text_q1"):setString(g_tr("peripheral_reward_joined"))
           item:getChildByName("Text_q3"):setString(g_tr("peripheral_reward_joined_unit"))
           
           local enoughTimes = todayMatchTimes >= var.times
           item:getChildByName("Text_cs"):setVisible(not enoughTimes)
           item:getChildByName("Button_2"):setVisible(enoughTimes)
           item:getChildByName("Button_2"):setEnabled(true)
           local btnStr = g_tr("peripheral_reward_get")
           if key <= currentDayGainId then
              btnStr = g_tr("peripheral_reward_geted")
              item:getChildByName("Button_2"):setEnabled(false)
           end
           item:getChildByName("Button_2"):getChildByName("Text_7"):setString(btnStr)
           
           item:getChildByName("Text_cs"):setString(g_tr("peripheral_reward_progress")..todayMatchTimes.."/"..var.times)
           
           item:getChildByName("Button_2"):addClickEventListener(function()
                
                if key ~= currentDayGainId + 1 then
                    g_airBox.show(g_tr("peripheral_reward_tip_err"))
                    return
                end
                
                local function onRecv(result, msgData)
                    g_busyTip.hide_1()
                    if result == true then 
                        btnStr = g_tr("peripheral_reward_geted")
                        item:getChildByName("Button_2"):setEnabled(false)
                        item:getChildByName("Button_2"):getChildByName("Text_7"):setString(btnStr)
                        require("game.uilayer.task.AwardsToast").show(dropGroups)
                        local exditionData = g_expeditionData.GetData()
                        todayMatchTimes = exditionData.current_day_match_times
                        currentDayGainId = exditionData.current_day_gain_id
                    end
                end
                g_busyTip.show_1()
                g_sgHttp.postData("pk/getTimesBonus",{},onRecv,true)
           end)
           

           listView:setTouchEnabled(#dropGroups > 6)
           for key, dropgroup in ipairs(dropGroups) do
                local itemView = require("game.uilayer.common.DropItemView"):create(dropgroup[1],dropgroup[2],dropgroup[3])
                itemView:enableTip()
                itemView:setScale(0.8)
                listView:pushBackCustomItem(itemView)
           end
           daliyListView:pushBackCustomItem(item)
        end
    end
    
    --当前段位每日奖励
    do
        local dailyScore = exditionData.daily_score
        local gainDailyAwardTime = exditionData.gain_daily_award_date
        local awardExecTime = exditionData.award_exec_date
        
        local btnStr = g_tr("peripheral_reward_get")
        local btn = rankRewardCon:getChildByName("Panel_f1"):getChildByName("Button_llq")
        btn:getChildByName("Text_7"):setString(btnStr)
        
        if exditionData.daily_award_status == 1 then
            btnStr = g_tr("peripheral_reward_geted")
            btn:setEnabled(false)
            if not g_clock.isSameDay(awardExecTime,tonumber(g_clock.getCurServerTime())) then
               btnStr = g_tr("peripheral_reward_btntxt3")
               dailyScore = exditionData.score
            end
            btn:getChildByName("Text_7"):setString(btnStr)
        else
            if awardExecTime == 0 then --没有结算过
               btnStr = g_tr("peripheral_reward_btntxt3")
               dailyScore = exditionData.score
               btn:getChildByName("Text_7"):setString(btnStr)
            end
        end

        rank = _getRankByScore(dailyScore)
    
        local rankConfig = g_data.duel_rank[rank]
        rankRewardCon:getChildByName("Panel_f1"):getChildByName("Image_21"):loadTexture(g_resManager.getResPath(rankConfig.rank_pic))
        rankRewardCon:getChildByName("Panel_f1"):getChildByName("Image_21_0"):loadTexture(g_resManager.getResPath(rankConfig.rank_number)) 
    
        --奖励列表
        local mlistView = rankRewardCon:getChildByName("Panel_f1"):getChildByName("ListView_2")
        mlistView:removeAllChildren()
        local dropGroups = g_gameTools.getDropGroupByDropIdArray(rankConfig.daily_drop)
        
        rankRewardCon:getChildByName("Panel_f1"):getChildByName("Image_j1"):setVisible(#dropGroups > 3)
        rankRewardCon:getChildByName("Panel_f1"):getChildByName("Image_j2"):setVisible(#dropGroups > 3)

        for key, dropgroup in ipairs(dropGroups) do
        	  local itemView = require("game.uilayer.common.DropItemView"):create(dropgroup[1],dropgroup[2],dropgroup[3])
            itemView:enableTip()
            mlistView:pushBackCustomItem(itemView)
        end
        
        btn:addClickEventListener(function()
           local function onRecv(result, msgData)
                g_busyTip.hide_1()
                if result == true then 
                    btnStr = g_tr("peripheral_reward_geted")
                    btn:setEnabled(false)
                    btn:getChildByName("Text_7"):setString(btnStr)
                    require("game.uilayer.task.AwardsToast").show(dropGroups)
                end
            end
            g_busyTip.show_1()
            g_sgHttp.postData("pk/getDailyAward",{},onRecv,true)
        end)
    end
    
    --下一段位
    do
        local rankConfig = g_data.duel_rank[rank + 1]
        rankRewardCon:getChildByName("Panel_f2"):setVisible(true)
        if rankConfig then
            --奖励列表
            local mlistView = rankRewardCon:getChildByName("Panel_f2"):getChildByName("ListView_2")
            mlistView:removeAllChildren()
            local dropGroups = g_gameTools.getDropGroupByDropIdArray(rankConfig.daily_drop)
            
            rankRewardCon:getChildByName("Panel_f2"):getChildByName("Image_j1"):setVisible(#dropGroups > 3)
            rankRewardCon:getChildByName("Panel_f2"):getChildByName("Image_j2"):setVisible(#dropGroups > 3)
        
            for key, dropgroup in ipairs(dropGroups) do
                local itemView = require("game.uilayer.common.DropItemView"):create(dropgroup[1],dropgroup[2],dropgroup[3])
                itemView:enableTip()
                mlistView:pushBackCustomItem(itemView)
            end
            rankRewardCon:getChildByName("Panel_f2"):getChildByName("Image_21"):loadTexture(g_resManager.getResPath(rankConfig.rank_pic))
            rankRewardCon:getChildByName("Panel_f2"):getChildByName("Image_21_0"):loadTexture(g_resManager.getResPath(rankConfig.rank_number)) 
            
            rankRewardCon:getChildByName("Panel_f2"):getChildByName("Text_9"):setString(rankConfig.min_point.."")
        
        else
            rankRewardCon:getChildByName("Panel_f2"):setVisible(false)
        end
    end
    
    --赛季奖励
    do
        local score = exditionData.score
        local btnStr = g_tr("peripheral_reward_get")
        local btn = seasonRewardCon:getChildByName("Panel_f1"):getChildByName("Button_llq")
        btn:getChildByName("Text_7"):setString(btnStr)
        btn:setVisible(false)
        
        rank = _getRankByScore(score)
    
        local rankConfig = g_data.duel_rank[rank]
        seasonRewardCon:getChildByName("Panel_f1"):getChildByName("Image_21"):loadTexture(g_resManager.getResPath(rankConfig.rank_pic))
        seasonRewardCon:getChildByName("Panel_f1"):getChildByName("Image_21_0"):loadTexture(g_resManager.getResPath(rankConfig.rank_number)) 
    
        --奖励列表
        local mlistView = seasonRewardCon:getChildByName("Panel_f1"):getChildByName("ListView_2")
        mlistView:removeAllChildren()
        local dropGroups = g_gameTools.getDropGroupByDropIdArray(rankConfig.drop)
        
        seasonRewardCon:getChildByName("Panel_f1"):getChildByName("Image_j1"):setVisible(#dropGroups > 3)
        seasonRewardCon:getChildByName("Panel_f1"):getChildByName("Image_j2"):setVisible(#dropGroups > 3)

        for key, dropgroup in ipairs(dropGroups) do
            local itemView = require("game.uilayer.common.DropItemView"):create(dropgroup[1],dropgroup[2],dropgroup[3])
            itemView:enableTip()
            mlistView:pushBackCustomItem(itemView)
        end
        
    end
    
    --下一段位
    do
        local rankConfig = g_data.duel_rank[rank + 1]
        seasonRewardCon:getChildByName("Panel_f2"):setVisible(true)
        if rankConfig then
            --奖励列表
            local mlistView = seasonRewardCon:getChildByName("Panel_f2"):getChildByName("ListView_2")
            mlistView:removeAllChildren()
            local dropGroups = g_gameTools.getDropGroupByDropIdArray(rankConfig.drop)
            
            seasonRewardCon:getChildByName("Panel_f2"):getChildByName("Image_j1"):setVisible(#dropGroups > 3)
            seasonRewardCon:getChildByName("Panel_f2"):getChildByName("Image_j2"):setVisible(#dropGroups > 3)
        
            for key, dropgroup in ipairs(dropGroups) do
                local itemView = require("game.uilayer.common.DropItemView"):create(dropgroup[1],dropgroup[2],dropgroup[3])
                itemView:enableTip()
                mlistView:pushBackCustomItem(itemView)
            end
            seasonRewardCon:getChildByName("Panel_f2"):getChildByName("Image_21"):loadTexture(g_resManager.getResPath(rankConfig.rank_pic))
            seasonRewardCon:getChildByName("Panel_f2"):getChildByName("Image_21_0"):loadTexture(g_resManager.getResPath(rankConfig.rank_number)) 
            
            seasonRewardCon:getChildByName("Panel_f2"):getChildByName("Text_9"):setString(rankConfig.min_point.."")
        
        else
            seasonRewardCon:getChildByName("Panel_f2"):setVisible(false)
        end
    end

end

return FightReward