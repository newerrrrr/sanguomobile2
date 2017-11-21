local LimitTimeMatchHistoryRankList = class("LimitTimeMatchHistoryRankList",function()
    return cc.Layer:create()
end)

function LimitTimeMatchHistoryRankList:ctor()

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
    
    local titleStr = g_tr("limitedMatchBestPlayer")
    baseNode:getChildByName("Text_c2"):setString(titleStr)
    
    local listView = baseNode:getChildByName("ListView_1")
    
    local rankItemModel = cc.CSLoader:createNode("activity_integral_list4.csb")
    
    local players = {}
    
    local function onRecv(result, msgData)
        if(result==true)then
            players = msgData.historyTopInfo or {}
        end
    end
    g_sgHttp.postData("limit_match/historyTop",{},onRecv)
    
    
    for key, var in ipairs(players) do
       
       local playerName = var.nick
       local playerScore = var.score
       local item = rankItemModel:clone()
       
       item:getChildByName("Text_3"):setString(g_tr("limitedMatchCnt",{cnt = key}))
       item:getChildByName("Text_2"):setString(playerName)
       item:getChildByName("Text_5_0"):setString(string.formatnumberthousands(playerScore))
       
       local iconId = g_data.res_head[var.avatar].head_icon
       item:getChildByName("Image_q3_0"):loadTexture(g_resManager.getResPath(iconId))
       
       listView:pushBackCustomItem(item)

    end
    
    listView:jumpToBottom()
end

return LimitTimeMatchHistoryRankList