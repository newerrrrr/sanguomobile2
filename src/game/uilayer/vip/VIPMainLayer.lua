
--VIP特权主界面
local VIPMainLayer = class("VIPMainLayer", require("game.uilayer.base.BaseLayer"))
local VIPMode = require("game.uilayer.vip.VIPMode")
local vipLevelMax = VIPMode:getVipLevelMax()

function VIPMainLayer:ctor()
  VIPMainLayer.super.ctor(self)

  local layer = g_gameTools.LoadCocosUI("vip_main.csb", 5) 
  if layer then 
    g_resourcesInterface.installResources(layer)
    self:addChild(layer) 
    self:initInfo(layer:getChildByName("scale_node"))
  end   
end 

function VIPMainLayer:onEnter()
  print("VIPMainLayer:onEnter")

  self:playVipAnim(true) 
end

function VIPMainLayer:onExit()

end

function VIPMainLayer:initInfo(rootNode)
  self.nodeRoot = rootNode
  if nil == self.nodeRoot then return end 

  local btnClose = self.nodeRoot:getChildByName("close_btn")
  self.btnEnhance = self.nodeRoot:getChildByName("Button_1")
  local btnArrowLeft = self.nodeRoot:getChildByName("Image_6")
  local btnArrowRight = self.nodeRoot:getChildByName("Image_6_0")

  local pic_act1 = self.nodeRoot:getChildByName("Image_1") 
  local pic_act2 = self.nodeRoot:getChildByName("Image_1_0") 

  self.nodeRoot:getChildByName("text_sw"):setString("VIP")
  self.nodeRoot:getChildByName("Text_4"):setString(g_tr("vip_enhance"))

  self.nodeRoot:getChildByName("Text_3"):setString(g_tr("vip_gain_tips"))

  self:regBtnCallback(btnClose, handler(self, self.close))
  self:regBtnCallback(self.btnEnhance, handler(self, self.onAdvance))
  self:regBtnCallback(btnArrowLeft, handler(self, self.onPrePage))
  self:regBtnCallback(btnArrowRight, handler(self, self.onNextPage))
  self:regBtnCallback(pic_act1, handler(self, self.onActiveVIP))
  self:regBtnCallback(pic_act2, handler(self, self.onActiveVIP))

  self:updateInfo()
end 


function VIPMainLayer:updateInfo()
  print("updateInfo")
  if nil == self.nodeRoot then return end 

  local playerData = g_PlayerMode.GetData()
  local allbuffs = g_BuffMode.GetData()
  print("vip_level, exp=", playerData.vip_level, playerData.vip_exp)

  --进度
  local id = math.min(vipLevelMax, playerData.vip_level+1)
  local nextExp = g_data.vip[id].vip_exp
  local curExp = playerData.vip_level >= vipLevelMax and nextExp or playerData.vip_exp 
  local percent = math.min(100, 100*curExp/nextExp)
  self.nodeRoot:getChildByName("Text_1"):setString("VIP"..playerData.vip_level)
  self.nodeRoot:getChildByName("Text_sz"):setString(curExp .. "/" .. nextExp)
  self.nodeRoot:getChildByName("LoadingBar_1"):setPercent(percent)

  self.btnEnhance:setEnabled(playerData.vip_level < vipLevelMax)

  --倒计时
  self.nodeRoot:getChildByName("Image_1"):setVisible(allbuffs and allbuffs.vip_active.v > 0)
  self.nodeRoot:getChildByName("Image_1_0"):setVisible(allbuffs and allbuffs.vip_active.v == 0)
  local lbTime = self.nodeRoot:getChildByName("Text_2")
  lbTime:setString("") 

  if allbuffs and allbuffs.vip_active.v > 0 then --vip已激活
    local tmp = allbuffs.vip_active.tmp 
    if tmp and #tmp > 0 then 
      local endTime = tmp[1].expire_time 
      self:showLeftTime(endTime, lbTime)
    end 
  else 
    lbTime:setString(g_tr("vip_active")) 
  end 

  self.curPage = playerData.vip_level

  self:showPrivilegeList(self.curPage)

  self:playVipAnim(false)

  --更新首页tips
  local mainSurface = require("game.uilayer.mainSurface.mainSurfacePlayer")
  mainSurface.updateShowWithData_Vip()
end 

function VIPMainLayer:showPrivilegeList(vipLevel)
  local data1, data2 = VIPMode.getPrivalegePageData(vipLevel)

  if nil == self.nodeRoot then return end 

  local node = self.nodeRoot:getChildByName("Panel_6")
  node:getChildByName("Text_1"):setString("VIP"..data1[1].vip_lv)
  node:getChildByName("Text_2"):setString("VIP"..data2[1].vip_lv)

  local listView = node:getChildByName("ListView_1")
  listView:removeAllChildren()
  local item = cc.CSLoader:createNode("vip_activation_1.csb")
  item:retain() 
  item:setAnchorPoint(cc.p(0.5, 0.5))
  local size = listView:getContentSize()
  for i=1, #data2 do 
    
    local value 
    for k, v in pairs(data1) do 
      if v.privilege_type == data2[i].privilege_type then 
        value = v 
        break 
      end 
    end 

    local layout = ccui.Layout:create() 
    --左边项
    local item_1 = item:clone() 
    item_1:getChildByName("Image_4"):loadTexture(g_resManager.getResPath(data2[i].icon))
    item_1:getChildByName("Text_1"):setString(g_tr(data2[i].buff_desc))
    local strBuf1 = "" 
    if data2[i].num_type == 1 then --万分比
      strBuf1 = value and "+" .. (value.buff_num/100).."%" or "+0%"
    else 
      strBuf1 = value and "+" .. value.buff_num or "+0"
    end 
    local color = value and cc.c3b(72, 255, 98) or cc.c3b(255, 40, 50)
    item_1:getChildByName("Text_2"):setString(strBuf1)
    item_1:getChildByName("Text_2"):setTextColor(color)
    item_1:getChildByName("Image_5"):setVisible(false)
    item_1:setPosition(cc.p(size.width*0.25, item:getContentSize().height/2))
    layout:addChild(item_1)

    --右边项
    local item_2 = item_1:clone() 
    if not value then 
      item_2:getChildByName("Image_5"):setVisible(true)
    end
    item_2:getChildByName("Text_1"):setString(g_tr(data2[i].buff_desc))
    local strBuf2 = ""
    if data2[i].num_type == 1 then --万分比
      strBuf2 = "+" .. (data2[i].buff_num/100).."%"
    else 
      strBuf2 = "+" .. data2[i].buff_num
    end 
    item_2:getChildByName("Text_2"):setString(strBuf2)
    item_2:getChildByName("Text_2"):setTextColor(cc.c3b(72, 255, 98))
    item_2:setPosition(cc.p(size.width*0.75, item:getContentSize().height/2))
    layout:addChild(item_2) 
    layout:setContentSize(cc.size(size.width, item:getContentSize().height))  
    listView:pushBackCustomItem(layout)
  end 
  item:release() 
end 

function VIPMainLayer:onPrePage()
  print("onPrePage")
  if self.curPage > 1 then 
    self.curPage = self.curPage - 1 
    self:showPrivilegeList(self.curPage) 
  end 
end 

function VIPMainLayer:onNextPage()
  print("onNextPage")
  if self.curPage < vipLevelMax then 
    self.curPage = self.curPage + 1 
    self:showPrivilegeList(self.curPage)
  end 
end 


--升级vip点数
function VIPMainLayer:onAdvance()
  print("onAdvance")
  require("game.uilayer.vip.VIPActiveExpUp"):showAdvancePop(handler(self, self.updateInfo))
end 

--激活vip
function VIPMainLayer:onActiveVIP()
  print("onActiveVIP")
  require("game.uilayer.vip.VIPActiveExpUp"):showActivePop(handler(self, self.updateInfo))
end 


function VIPMainLayer:showLeftTime(targetTime, label)
  print("showLeftTime")

  local function updateTime()
    local dt = targetTime - g_clock.getCurServerTime()
    if dt <= 0 then        
      dt = 0 
      self:unschedule(self.vipTimer)
      self.vipTimer = nil 

      --更新ui
      if self.nodeRoot then 
        self.nodeRoot:getChildByName("Image_1"):setVisible(false)
        self.nodeRoot:getChildByName("Image_1_0"):setVisible(true)
      end 
      label:setString(g_tr("vip_active")) 
      
      --更新首页tips
      local mainSurface = require("game.uilayer.mainSurface.mainSurfacePlayer")
      mainSurface.updateShowWithData_Vip()
    end 

    local day = math.floor(dt/(3600*24))
    dt = dt - day * 3600*24
    local hour = math.floor(dt/3600)
    local min = math.floor((dt%3600)/60)
    local sec = math.floor(dt%60)
    if day > 0 then 
      label:setString(string.format("%dD %02d:%02d:%02d", day, hour, min, sec)) 
    else 
      label:setString(string.format("%02d:%02d:%02d", hour, min, sec)) 
    end 
  end 

  if self.vipTimer then 
    self:unschedule(self.vipTimer)
    self.vipTimer = nil 
  end 

  if targetTime > g_clock.getCurServerTime() then    
    local dt = targetTime - g_clock.getCurServerTime()
    local day = math.floor(dt/(3600*24))
    dt = dt - day * 3600*24
    local hour = math.floor(dt/3600)
    local min = math.floor((dt%3600)/60)
    local sec = math.floor(dt%60)
    if day > 0 then 
      label:setString(string.format("%dD %02d:%02d:%02d", day, hour, min, sec)) 
    else 
      label:setString(string.format("%02d:%02d:%02d", hour, min, sec)) 
    end 

    self.vipTimer = self:schedule(updateTime, 1.0) 
  end
end 

function VIPMainLayer:loadHandAnim(node) 
  print("loadHandAnim", self.handImage)
  if self.animHand then 
    self:stopAction(self.animHand)
    self.animHand = nil 
  end 
  if self.handImage then 
    self.handImage:removeFromParent()
  end 
  self.handImage = cc.Sprite:createWithSpriteFrameName("homeImage_guide_finger.png")
  if self.handImage then 
    local size = node:getContentSize()
    self.handImage:setPosition(cc.p(size.width/2, size.height/2))
    self.handImage:setTag(100)
    node:addChild(self.handImage) 
    self.handImage:setRotation(180)
    self.handImage:setFlipX(true)
    self.handImage:runAction(cc.RepeatForever:create(cc.Sequence:create( cc.MoveBy:create(0.6, cc.p(0,30.0)) , cc.MoveBy:create(0.6, cc.p(0,-30.0)))))
    self.animHand = self:performWithDelay(function() 
        -- self.handImage:removeFromParent()
        local child = node:getChildByTag(100)
        print("===child", child)
        if child then 
          child:removeFromParent() 
        end 
        self.animHand = nil         
        self.handImage = nil 
      end, 
      3.0)
  end 
end 

function VIPMainLayer:playLevelupTips()
  if nil == self.btnEnhance then return end 

  self:loadHandAnim(self.btnEnhance)
end 

function VIPMainLayer:playVipAnim(isFirstEntry) 
  local node = self.nodeRoot:getChildByName("Panel_3") 
  node:removeAllChildren()

  if VIPMode.getVipLeftTime() > 0 then --已激活
    local armature, animation = g_gameTools.LoadCocosAni(
      "anime/Effect_VipTuBiaoJiHuo/Effect_VipTuBiaoJiHuo.ExportJson"
      , "Effect_VipTuBiaoJiHuo"
      -- , onMovementEventCallFunc
      --, onFrameEventCallFunc
      )
    armature:setPosition(cc.p(0, 0))
    node:addChild(armature) 
    animation:play("Animation1") 

  else --已失效
    if isFirstEntry and nil == self.animHand then 
      self:loadHandAnim(node)
    end 
  end 
end 


return VIPMainLayer
