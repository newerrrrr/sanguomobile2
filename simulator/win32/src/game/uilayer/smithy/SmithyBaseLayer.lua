
--铁匠铺
local SmithyData = require("game.uilayer.smithy.SmithyData")
local SmithyBaseLayer = class("SmithyBaseLayer",require("game.uilayer.base.BaseLayer"))


function SmithyBaseLayer:ctor(viewType, para)
  SmithyBaseLayer.super.ctor(self)
  print("SmithyBaseLayer:ctor")
  self.curViewType = viewType or SmithyData.viewType.Advance 
  self.para = para 
end 

function SmithyBaseLayer:onEnter()
  print("SmithyBaseLayer:onEnter")
  local layer = g_gameTools.LoadCocosUI("Smithrecast_Panel.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showView(self.curViewType, self.para)
  end 
  SmithyData:instance():setBaseView(self)
  SmithyData:instance():setDataIsDurty(false)
  if self.para and type(self.para) == "table" then 
    SmithyData:instance():setOnPreExit(self.para.onPreExit)
  else 
    SmithyData:instance():setOnPreExit(nil)
  end 
end 

function SmithyBaseLayer:onExit() 
  print("SmithyBaseLayer:onExit") 
  SmithyData:instance():setBaseView(nil)
  SmithyData:instance():setBackView(nil, nil)
end 

function SmithyBaseLayer:initBinding(scaleNode)
  local lbTitile = scaleNode:getChildByName("Text_2")
  self.btnAdvance = scaleNode:getChildByName("Button_01")
  self.btnRecast = scaleNode:getChildByName("Button_02")
  self.btnDecompose = scaleNode:getChildByName("Button_03")
  self.btnCompose = scaleNode:getChildByName("Button_04")
  self.container = scaleNode:getChildByName("container")  
  self.btnClose = scaleNode:getChildByName("Button_6")

  local lbAdvance = scaleNode:getChildByName("Button_01"):getChildByName("Text_1")
  local lbRecast = scaleNode:getChildByName("Button_02"):getChildByName("Text_1")
  local lbDecompose = scaleNode:getChildByName("Button_03"):getChildByName("Text_1")
  local lbCompose = scaleNode:getChildByName("Button_04"):getChildByName("Text_1")
  local imgBg = scaleNode:getChildByName("Image_5")
  lbTitile:setString(g_tr("smithrecastTitle"))
  lbAdvance:setString(g_tr("advance"))
  lbRecast:setString(g_tr("recast"))
  lbDecompose:setString(g_tr("decompose"))
  lbCompose:setString(g_tr("compose"))
  
  self:regBtnCallback(self.btnAdvance, handler(self, self.onAdvance))
  self:regBtnCallback(self.btnRecast, handler(self, self.onRecast))
  self:regBtnCallback(self.btnDecompose, handler(self, self.onDecompose))
  self:regBtnCallback(self.btnCompose, handler(self, self.onCompose))
  self:regBtnCallback(self.btnClose, handler(self, self.onClose))

  
  --玩家资源栏
  self.nodeTopRes = cc.CSLoader:createNode("Resources_2.csb")
  self.nodeTopRes:setPosition(cc.p(imgBg:getContentSize().width-self.nodeTopRes:getContentSize().width-100,imgBg:getContentSize().height+2))
  imgBg:addChild(self.nodeTopRes)
  self:updatePlayerResource()
end 

function SmithyBaseLayer:onAdvance()
  print("onAdvance:")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  self:showView(SmithyData.viewType.Advance)
end 

function SmithyBaseLayer:onRecast()
  print("onRecast")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  self:showView(SmithyData.viewType.Recast)
end 

function SmithyBaseLayer:onDecompose()
  print("onDecompose")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  self:showView(SmithyData.viewType.Decompose)
end 

function SmithyBaseLayer:onCompose()
  print("onCompose")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  self:showView(SmithyData.viewType.Compose)
end 

function SmithyBaseLayer:showView(viewType, para) 
  --highlight button 
  local btnArray = {self.btnAdvance, self.btnRecast, self.btnDecompose, self.btnCompose}
  for i=1, #btnArray do 
    btnArray[i]:setHighlighted(i==viewType) 
  end 

  local layer  
  if viewType == SmithyData.viewType.Advance then 
    layer = require("game.uilayer.smithy.SmithyAdvanceLayer").new(para)

  elseif viewType == SmithyData.viewType.Recast then 
    layer = require("game.uilayer.smithy.SmithyRecastLayer").new(para)

  elseif viewType == SmithyData.viewType.Decompose then
    layer = require("game.uilayer.smithy.SmithyDecomposeLayer").new(para)
    
  elseif viewType == SmithyData.viewType.Compose then
    layer = require("game.uilayer.smithy.SmithyComposeLayer").new(para)
  end 
  
  g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.SMITHY)
  
  if layer then 
    layer:setDelegate(self)
    self.container:removeAllChildren()
    self.container:addChild(layer)

    self.curView = layer 
    self.curViewType = viewType 
  end 
end 

--更新top菜单中玩家资源信息
function SmithyBaseLayer:updatePlayerResource()
  if nil == self.nodeTopRes then return end 

  local silver = g_PlayerMode.GetData().silver 
  local money = g_PlayerMode.getDiamonds() 
  print("updatePlayerResource:silver,money", silver,money)
  self.nodeTopRes:getChildByName("Text_1"):setString(silver.."")
  self.nodeTopRes:getChildByName("Text_2"):setString(money.."")
end 

function SmithyBaseLayer:onClose()
  local backView, para = SmithyData:instance():getBackView()
  if backView and backView ~= self.curViewType then 
    SmithyData:instance():setBackView(nil, nil)
    self:showView(backView, para) 
  else 
    self:close() 
    local onPreExit = SmithyData:instance():getOnPreExit()
    if onPreExit and SmithyData:instance():getDataIsDurty() then 
      print("onPreExit") 
      onPreExit() 
    end 
  end 
end 

return  SmithyBaseLayer
