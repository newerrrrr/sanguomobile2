
local HelpInfoBox = class("HelpInfoBox", require("game.uilayer.base.BaseLayer"))

-- function HelpInfoBox:ctor()
--   HelpInfoBox.super.ctor(self)
-- end

-- function HelpInfoBox:onEnter()
-- end 

-- function HelpInfoBox:onExit() 
-- end 

function HelpInfoBox:show(helpId)
  local layer = g_gameTools.LoadCocosUI("turntable_resources_main.csb", 5)
  g_sceneManager.addNodeForUI(layer)

  local mask = layer:getChildByName("mask")
  mask:setTouchEnabled(true)
  self:regBtnCallback(mask, function() layer:removeFromParent() end) 

  local root = layer:getChildByName("scale_node")
  root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))

  local lbTitle = root:getChildByName("Text_c2")
  local listView = root:getChildByName("ListView_1")
  listView:setScrollBarEnabled(false)
  local data = g_data.help_type[helpId]
  if data then 
    -- dump(data, "====data")
    lbTitle:setString(g_tr(data.title))
    
    local offset = 60
    local size = listView:getContentSize()
    local text = ccui.Text:create(" ", "cocos/cocostudio_res/simhei.TTF", 24)
    text:setTextAreaSize(cc.size(size.width - 10 - offset*0.5, 0))
    text:ignoreContentAdaptWithSize(false)
    text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    text:setAnchorPoint(cc.p(0.5, 1.0))

    local node = ccui.Widget:create() 
    node:addChild(text) 
    local richText = g_gameTools.createRichText(text, g_tr(data.description))
    local size = richText:getRichSize()
    node:setContentSize(size)
    richText:setPosition(cc.p(size.width/2 + offset*0.5, size.height))
    listView:pushBackCustomItem(node)
  else 
    lbTitle:setString(g_tr("titleTip"))
  end 
end

function HelpInfoBox:showForStr(str,title)
    local layer = g_gameTools.LoadCocosUI("turntable_resources_main.csb", 5)
    g_sceneManager.addNodeForUI(layer)

    local mask = layer:getChildByName("mask")
    mask:setTouchEnabled(true)
    self:regBtnCallback(mask, function() layer:removeFromParent() end) 

    local root = layer:getChildByName("scale_node")
    root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))

    local lbTitle = root:getChildByName("Text_c2")
    local listView = root:getChildByName("ListView_1")
    listView:setScrollBarEnabled(false)
    if title == nil then
        lbTitle:setString(g_tr("titleTip"))
    else
        lbTitle:setString(title)
    end
    
    local offset = 60
    local size = listView:getContentSize()
    local text = ccui.Text:create(" ", "cocos/cocostudio_res/simhei.TTF", 24)
    text:setTextAreaSize(cc.size(size.width - 10 - offset*0.5, 0))
    text:ignoreContentAdaptWithSize(false)
    text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    text:setAnchorPoint(cc.p(0.5, 1.0))

    local node = ccui.Widget:create() 
    node:addChild(text) 
    local richText = g_gameTools.createRichText(text, str)
    local size = richText:getRichSize()
    node:setContentSize(size)
    richText:setPosition(cc.p(size.width/2 + offset*0.5, size.height))
    listView:pushBackCustomItem(node)
end 

return HelpInfoBox
