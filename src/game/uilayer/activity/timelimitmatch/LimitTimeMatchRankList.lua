local LimitTimeMatchRankList = class("LimitTimeMatchRankList",function()
    return cc.Layer:create()
end)

function LimitTimeMatchRankList:ctor(type)
    assert(type == 1 or type == 2)
    
    self:registerScriptHandler(function(eventType)
        if eventType == "enter" then
            local players = {}
            local function onRecv(result, msgData)
                g_busyTip.hide_1()
                if(result==true)then
                    players = msgData.rank or {}
                    self:loadList(type,players)
                else
                    self:removeFromParent()
                end
            end
            g_busyTip.show_1()
            g_sgHttp.postData("limit_match/rank",{type = type},onRecv,true)
        elseif eventType == "exit" then
        end 
    end )
end

function LimitTimeMatchRankList:loadList(type,players)

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
    
    local titleStr = ""
    if type == 1 then --阶段排行榜
        titleStr = g_tr("limitedMatchListRankNow")
    elseif type == 2 then --总排行榜
        titleStr = g_tr("limitedMatchListRankAll")
    end
    baseNode:getChildByName("Text_c2"):setString(titleStr)
    
    local listView = baseNode:getChildByName("ListView_1")
    
    local rankItemModel = cc.CSLoader:createNode("activity_integral_list3.csb")
    for key, var in ipairs(players) do
       
       local playerName = var.nick
       local playerScore = var.score
       local item = rankItemModel:clone()
       
       if  key ~= 1 then
           item:getChildByName("Image_q1"):setVisible(false)
       end
       
       if  key ~= 2 then
           item:getChildByName("Image_q2"):setVisible(false)
       end
       
       if  key ~= 3 then
           item:getChildByName("Image_q3"):setVisible(false)
       end
       
       item:getChildByName("Image_1_0"):setVisible(key <= 3)
       
       item:getChildByName("Text_q1"):setString(key.."")
       item:getChildByName("Text_2"):setString(playerName)
       item:getChildByName("Text_5_0"):setString(string.formatnumberthousands(playerScore))
       
       listView:pushBackCustomItem(item)

    end
end

return LimitTimeMatchRankList