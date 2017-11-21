local LimitTimeMatchAwardList = class("LimitTimeMatchAwardList",function()
    return cc.Layer:create()
end)

function LimitTimeMatchAwardList:ctor(matchId,rankOrScoreType,scoreNum)
    
    local uiLayer =  g_gameTools.LoadCocosUI("turntable_resources_main.csb",5)
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
    
    baseNode:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
    
    
    local titleStr = g_tr("limitedMatchNowScoreAward")
    if rankOrScoreType == 1 then --rank
    elseif rankOrScoreType == 2 then --score
        titleStr = g_tr("limitedMatchScoreTargetAward")
    elseif rankOrScoreType == 3 then
        titleStr = g_tr("limitedMatchTotalScoreAward")
    end
    baseNode:getChildByName("Text_c2"):setString(titleStr)
    
    
    local awards = {}
    if rankOrScoreType == 1 then --rank
        for key, rank_drop_id in ipairs(g_data.time_limit_match[matchId].rank_drop_id) do
        	table.insert(awards,g_data.time_limit_match_point_drop[rank_drop_id])
        end
        
        table.sort(awards,function(a,b)
            return a.max_point < b.max_point 
        end)
    elseif rankOrScoreType == 2 then --score
        for key, rank_drop_id in ipairs(g_data.time_limit_match[matchId].drop_id) do
            local dropInfo = g_data.time_limit_match_point_drop[rank_drop_id]
            if scoreNum >= dropInfo.min_point and scoreNum<= dropInfo.max_point then
                table.insert(awards,g_data.time_limit_match_point_drop[rank_drop_id])
            end
        end
        
        table.sort(awards,function(a,b)
            return a.max_point > b.max_point 
        end)
    elseif rankOrScoreType == 3 then --总排名
        for key, var in pairs(g_data.time_limit_match_point_drop) do
        	if var.type == 3 then
        	   table.insert(awards,var)
        	end
        end
        
        table.sort(awards,function(a,b)
            return a.max_point < b.max_point 
        end)
    end
    
    local listView = baseNode:getChildByName("ListView_1")
    
    local rankTitleItemModel = cc.CSLoader:createNode("activity_integral_list2.csb")
    local rankAwardtemModel = cc.CSLoader:createNode("activity_integral_list1.csb")
    for key, var in ipairs(awards) do
        
        if rankOrScoreType == 1 or rankOrScoreType == 3 then
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

return LimitTimeMatchAwardList