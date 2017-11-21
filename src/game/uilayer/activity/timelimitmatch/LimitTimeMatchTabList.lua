local LimitTimeMatchTabList = class("LimitTimeMatchTabList",function()
    return cc.Layer:create()
end)

function LimitTimeMatchTabList:ctor(matchId,currentOrTotal,scoreNum)
    
    local uiLayer =  g_gameTools.LoadCocosUI("turntable_resources_main1.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    local closeBtn = uiLayer:getChildByName("mask")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent()
          end
    end)
    self._matchId = matchId 
    
    baseNode:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
    
    if currentOrTotal == 1 then
        baseNode:getChildByName("Button_1"):getChildByName("Text_1"):setString(g_tr("limitedMatchNowRank"))
        baseNode:getChildByName("Button_2"):getChildByName("Text_1"):setString(g_tr("limitedMatchNowRankAward"))
    else
        baseNode:getChildByName("Button_1"):getChildByName("Text_1"):setString(g_tr("limitedMatchTotalRank"))
        baseNode:getChildByName("Button_2"):getChildByName("Text_1"):setString(g_tr("limitedMatchTotalRankAward"))
    end
    
    baseNode:getChildByName("Button_1"):addClickEventListener(function(sender)
        self:tabMenu(2,currentOrTotal,scoreNum)
        baseNode:getChildByName("Button_1"):setEnabled(false)
        baseNode:getChildByName("Button_2"):setEnabled(true)
    end)
    
    baseNode:getChildByName("Button_2"):addClickEventListener(function(sender)
        self:tabMenu(1,currentOrTotal,scoreNum)
        baseNode:getChildByName("Button_1"):setEnabled(true)
        baseNode:getChildByName("Button_2"):setEnabled(false)
    end)
    
    self:tabMenu(2,currentOrTotal,scoreNum)
    baseNode:getChildByName("Button_1"):setEnabled(false)
end

function LimitTimeMatchTabList:tabMenu(rankListOrAward,currentOrTotal,scoreNum)
   
   if rankListOrAward == 1 then --奖励
        local titleStr = g_tr("limitedMatchNowScoreAward")
        if currentOrTotal == 1 then --current
        elseif currentOrTotal == 2 then --total
            titleStr = g_tr("limitedMatchTotalScoreAward")
        elseif currentOrTotal == 3 then --target
            titleStr = g_tr("limitedMatchScoreTargetAward")
        end
        self._baseNode:getChildByName("Text_c2"):setString(titleStr)
        
        local awards = {}
        if currentOrTotal == 1 then --rank current
            for key, rank_drop_id in ipairs(g_data.time_limit_match[self._matchId].rank_drop_id) do
                table.insert(awards,g_data.time_limit_match_point_drop[rank_drop_id])
            end
            
            table.sort(awards,function(a,b)
                return a.max_point < b.max_point 
            end)
       
        elseif currentOrTotal == 2 then --总排名
            for key, var in pairs(g_data.time_limit_match_point_drop) do
                if var.type == 3 then
                   table.insert(awards,var)
                end
            end
            
            table.sort(awards,function(a,b)
                return a.max_point < b.max_point 
            end)
        elseif currentOrTotal == 3 then --score
            for key, rank_drop_id in ipairs(g_data.time_limit_match[self._matchId].drop_id) do
                local dropInfo = g_data.time_limit_match_point_drop[rank_drop_id]
                if scoreNum >= dropInfo.min_point and scoreNum<= dropInfo.max_point then
                    table.insert(awards,g_data.time_limit_match_point_drop[rank_drop_id])
                end
            end
            
            table.sort(awards,function(a,b)
                return a.max_point > b.max_point 
            end)
        end
        
        local listView = self._baseNode:getChildByName("ListView_1")
        listView:jumpToTop()
        listView:removeAllChildren()
        
        local rankTitleItemModel = cc.CSLoader:createNode("activity_integral_list2.csb")
        local rankAwardtemModel = cc.CSLoader:createNode("activity_integral_list1.csb")
        for key, var in ipairs(awards) do
            
            if currentOrTotal == 1 or currentOrTotal == 2 then
               local item = rankTitleItemModel:clone()
               item:getChildByName("Text_2"):setString(g_tr("limitedMatchRankFormat",{rank = key}))
               listView:pushBackCustomItem(item)
            end
            local dropGroups = {}
            --local dropGroups = g_gameTools.getDropGroupByDropIdArray({var.drop},1)
            
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
            
            do
                for key, var in pairs(dropGroups) do
                    local type = var[1]
                    local id = var[2]
                    local count = var[3]
                    local itemData = require("game.uilayer.common.DropItemView"):create(type,id,count)
                    itemData:setCountEnabled(false)
                    local item = rankAwardtemModel:clone()
                    --item:getChildByName("Image_4"):loadTexture(itemData:getIconPath())
                    item:getChildByName("Image_4"):addChild(itemData)
                    local size = item:getChildByName("Image_4"):getContentSize()
                    itemData:setPosition(cc.p(size.width*0.5,size.height*0.5))
                    local scale = size.width/itemData:getContentSize().width
                    itemData:setScale(scale)
                    item:getChildByName("Text_2"):setString(itemData:getName())
                    item:getChildByName("Text_5_0"):setString(string.formatnumberthousands(count))
                    listView:pushBackCustomItem(item)
                end
            end
        end
   else --排行版
        
        local titleStr = ""
        if currentOrTotal == 1 then --阶段排行榜
            titleStr = g_tr("limitedMatchListRankNow")
        elseif currentOrTotal == 2 then --总排行榜
            titleStr = g_tr("limitedMatchListRankAll")
        end
        self._baseNode:getChildByName("Text_c2"):setString(titleStr)

        local buildRankList = function(players)

            local listView = self._baseNode:getChildByName("ListView_1")
            listView:jumpToTop()
            listView:removeAllChildren()
            
            local rankItemModel = cc.CSLoader:createNode("activity_integral_list3.csb")
            
            local updateRankItem = function(item,key,var)
               local playerName = var.nick
               local playerScore = var.score
               item:getChildByName("Image_1_0"):setVisible(key > 0 and key <= 3)
               item:getChildByName("Text_q1"):setString(key.."")
               item:getChildByName("Text_2"):setString(playerName)
               item:getChildByName("Text_5_0"):setString(string.formatnumberthousands(playerScore))
               
               if  key ~= 1 then
                   item:getChildByName("Image_q1"):setVisible(false)
               end
               
               if  key ~= 2 then
                   item:getChildByName("Image_q2"):setVisible(false)
               end
               
               if  key ~= 3 then
                   item:getChildByName("Image_q3"):setVisible(false)
               end
            end
            
            for key, var in ipairs(players) do
               local item = rankItemModel:clone()
               updateRankItem(item,key,var)
               listView:pushBackCustomItem(item)
            end
            
            local myData = {}
            local rankPos = 0
            local matchData = require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").GetData()
            if currentOrTotal == 1 then --阶段排行榜
                myData = { nick = g_tr("myRank"),score = matchData.player_today_match.score}
                rankPos = matchData.rank
                
            elseif currentOrTotal == 2 then --总排行榜
                myData = { nick = g_tr("myRank"),score = matchData.player_total_match.score}
                rankPos = matchData.rankall
            end
            
            --我的排名
            local myItem = rankItemModel:clone()
            updateRankItem(myItem,rankPos,myData)
            listView:insertCustomItem(myItem,0)
        end
            
        local players = {}
        local function onRecv(result, msgData)
            g_busyTip.hide_1()
            if(result==true)then
                players = msgData.rank or {}
                buildRankList(players)
            end
        end
        g_busyTip.show_1()
        g_sgHttp.postData("limit_match/rank",{type = currentOrTotal},onRecv,true)
      
   end
    
end

return LimitTimeMatchTabList