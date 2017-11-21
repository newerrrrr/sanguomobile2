
--VIP失效弹框
local VIPInActivePop = class("VIPInActivePop", require("game.uilayer.base.BaseLayer"))


function VIPInActivePop:ctor()
  VIPInActivePop.super.ctor(self)
end 

function VIPInActivePop:onEnter()
  print("VIPInActivePop:onEnter")
  local layer = g_gameTools.LoadCocosUI("vip_activation.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initInfo(layer:getChildByName("scale_node"))
    self:showPrivilegeList()
  end 
end


function VIPInActivePop:onExit() 
end 

function VIPInActivePop:showPop()
  local pop = VIPInActivePop.new()
  g_sceneManager.addNodeForUI(pop)
end 

function VIPInActivePop:initInfo(rootNode)
  self.rootNode = rootNode 
  local btnClose = rootNode:getChildByName("close_btn")
  rootNode:getChildByName("text"):setString(g_tr("vip_inactive_tips"))
  local btnAct = rootNode:getChildByName("btn_buy")
  rootNode:getChildByName("Text_3"):setString(g_tr("vip_active"))

  self:regBtnCallback(btnClose, handler(self, self.close))
  self:regBtnCallback(btnAct, handler(self, self.onVIPActive)) 
end 


function VIPInActivePop:onVIPActive()
  print("onVIPActive")
  self:close() 
  require("game.uilayer.vip.VIPActiveExpUp"):showActivePop()
end 


function VIPInActivePop:showPrivilegeList()
  if nil == self.rootNode then return end 

  local playerData = g_PlayerMode.GetData()
  self.rootNode:getChildByName("Text_1"):setString("VIP"..playerData.vip_level)
  local listView = self.rootNode:getChildByName("ListView_1")
  listView:removeAllChildren()
  local size = listView:getContentSize()
  local item = cc.CSLoader:createNode("vip_activation_1.csb")
  local lbNum = item:getChildByName("Text_2")
  local imgUp = item:getChildByName("Image_5")
  lbNum:setPositionX(lbNum:getPositionX()-30)
  imgUp:setPositionX(imgUp:getPositionX()-30)
  item:retain() 
  item:setAnchorPoint(cc.p(0.5, 0.5))
  local data = require("game.uilayer.vip.VIPMode").getPrivalegeData(playerData.vip_level)
  local count = math.ceil(#data/2)
  for i=1, count do  
    local layout = ccui.Layout:create() 
    for j=1, 2 do 
      local idx = 2*(i-1)+j 
      if idx <= #data then 
        local item_new = item:clone()
        item_new:getChildByName("Image_4"):loadTexture(g_resManager.getResPath(data[idx].icon))
        item_new:getChildByName("Text_1"):setString(g_tr(data[idx].buff_desc))
        local strBuf1 = "" 
        if data[idx].num_type == 1 then --万分比
          strBuf1 = value and "+" .. (value.buff_num/100).."%" or "+0%"
        else 
          strBuf1 = value and "+" .. value.buff_num or "+0"
        end 
        item_new:getChildByName("Text_2"):setString(strBuf1)
        item_new:getChildByName("Text_2"):setTextColor(cc.c3b(72, 255, 98))
        -- item_new:getChildByName("Image_5"):setVisible(false)
        item_new:setPosition(cc.p(size.width*(2*j-1)/4, item:getContentSize().height/2))
        layout:addChild(item_new) 
      end 
    end 
    layout:setContentSize(cc.size(size.width, item:getContentSize().height))  
    listView:pushBackCustomItem(layout) 
  end 
  item:release() 
end 

function VIPInActivePop:checkVIPState(isFirstEntry)
  print("checkVIPState", isFirstEntry) 

  local allbuffs = g_BuffMode.GetData()
  if nil == allbuffs then return end 
  
  if true == isFirstEntry then --登录游戏时,剩余时间 >0 才倒计时
    if allbuffs.vip_active.v > 0 then --vip已激活
      local tmp = allbuffs.vip_active.tmp 
      if tmp and #tmp > 0 then 
        local dt = tmp[1].expire_time - g_clock.getCurServerTime()
        if dt > 0 then 
          print("vip left sec", dt)
          g_autoCallback.addCocosList(function()
              require("game.uilayer.vip.VIPInActivePop"):checkVIPState(false)
              end, 
            dt) 
        end 
      end  
    end 
  else 

    if allbuffs.vip_active.v > 0 then --vip已激活
      local tmp = allbuffs.vip_active.tmp 
      if tmp and #tmp > 0 then 
        local dt = tmp[1].expire_time - g_clock.getCurServerTime()
        if dt > 0 then 
          g_autoCallback.addCocosList(function()
              require("game.uilayer.vip.VIPInActivePop"):checkVIPState(false)
              end, 
            dt) 
        else 
          VIPInActivePop:showPop() 
        end 
      end 
    else 
      VIPInActivePop:showPop() 
    end 
  end 
end 


return VIPInActivePop 
