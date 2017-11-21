local AllianceCommentContentLayer = class("AllianceCommentContentLayer",function()
    return cc.Layer:create()
end)

function AllianceCommentContentLayer:ctor(serverData)
    
    local uiLayer = g_gameTools.LoadCocosUI("MessageBoard_panel1.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    --关闭本页
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent()
        end
    end)
    
    self._baseNode:getChildByName("Text_1"):setString(g_tr("allianceTitle"))
    self._baseNode:getChildByName("Text_c2"):setString(g_tr("allianceCommentTitle"))
    
    
    local editBtn = self._baseNode:getChildByName("Button_1")
    editBtn:addClickEventListener(function()
        local editLayer = require("game.uilayer.alliance.chat.AllianceCommentInputLayer"):create(self:getData())
        editLayer:setContentView(self)
        g_sceneManager.addNodeForUI(editLayer)
    end)
    editBtn:setVisible(g_AllianceMode.isAllianceLeader())
    
    local deleteBtn = self._baseNode:getChildByName("Button_2")
    deleteBtn:addClickEventListener(function()
         g_msgBox.show(g_tr("allianceCommentDelTip"),nil,nil,function(event)
            if event == 0 then
               if g_allianceCommentData.changeComment(self:getData().order_id,"","",self:getData().update_time) then
                   self:removeFromParent()
               end
            end
        end,1)
    end)
    deleteBtn:setVisible(g_AllianceMode.isAllianceLeader())
    
    local viewPlayerBtn = self._baseNode:getChildByName("Button_4")
    viewPlayerBtn:getChildByName("Text_8"):setString(g_tr("allianceCommentPlayerView"))
    viewPlayerBtn:addClickEventListener(function()
        g_sceneManager.addNodeForUI(require("game.uilayer.map.mapPlayerInfoView"):create( self:getData().player_id ))
    end)
    viewPlayerBtn:setVisible(serverData.player_id ~= 0)
    
    self._baseNode:getChildByName("TextField_1"):setVisible(false)
    self._baseNode:getChildByName("Text_dingwei2"):setVisible(false)

    --self._baseNode:getChildByName("TextField_2"):setTouchEnabled(false)
    
    self:setData(serverData)
    self:updateView()

end

------
--  Getter & Setter for
--      AllianceCommentContentLayer._Data
-----
function AllianceCommentContentLayer:setData(Data)
    self._Data = Data
end

function AllianceCommentContentLayer:getData()
    return self._Data
end

function AllianceCommentContentLayer:updateView()

    --self._baseNode:getChildByName("TextField_2"):setString(tostring(self:getData().content))
    self._baseNode:getChildByName("Text_dingwei1"):setString(tostring(self:getData().title))
    
    local scrollView = self._baseNode:getChildByName("ListView_1")
    scrollView:jumpToTop()
    scrollView:removeAllChildren()

    local tmpUIText = self._baseNode:getChildByName("Text_dingwei2")
    tmpUIText:setVisible(false)
    
    local contentLabel = cc.Label:createWithTTF("",tmpUIText:getFontName(),tmpUIText:getFontSize(),
      cc.size(910,0))
    contentLabel:setAnchorPoint(cc.p(0,0))
    contentLabel:setString(tostring(self:getData().content))
    local container = ccui.Widget:create()
    container:addChild(contentLabel)
    container:setContentSize(contentLabel:getContentSize())
    scrollView:pushBackCustomItem(container)
    
    local avatarId = tonumber(self:getData().avatar_id)
    if avatarId < 1 then
        avatarId = 1
    end
    local iconId = g_data.res_head[avatarId].head_icon
    self._baseNode:getChildByName("Image_11"):loadTexture(g_resManager.getResPath(iconId))
    self._baseNode:getChildByName("Image_11_0"):loadTexture(g_resManager.getResPath(1010007)) --boader
    
    self._baseNode:getChildByName("Text_name"):setString(tostring(self:getData().nick))
    
    local timeStr = ""
    if self:getData().update_time and self:getData().update_time > 0 then
        local timeTable = os.date("!*t", self:getData().update_time)
        timeStr = timeTable.year.."/"..timeTable.month.."/"..timeTable.day.."  "..string.format("%02d:%02d:%02d",timeTable.hour,timeTable.min,timeTable.sec) 
    end
    self._baseNode:getChildByName("Text_6"):setString(timeStr)
    
end

return AllianceCommentContentLayer