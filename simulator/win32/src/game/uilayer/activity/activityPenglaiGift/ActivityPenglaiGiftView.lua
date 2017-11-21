
--蓬莱礼包(超级礼包)

local ActivityPenglaiGiftView = class("ActivityPenglaiGiftView",require("game.uilayer.base.BaseLayer"))

local tabIndex = 1 
local viewObj


function ActivityPenglaiGiftView:ctor()
  ActivityPenglaiGiftView.super.ctor(self)

  viewObj = self
  self.curChannel = g_channelManager.GetPayWayList()[1] 

  local layer = cc.CSLoader:createNode("activity4_mian9.csb")
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    self:highlightTab(tabIndex) 
    self:onReqData() 
  end 
end 

function ActivityPenglaiGiftView:onEnter()
  print("ActivityPenglaiGiftView:onEnter")

end 

function ActivityPenglaiGiftView:onExit() 
  print("ActivityPenglaiGiftView:onExit") 
  viewObj = nil 
end 


function ActivityPenglaiGiftView:initBinging(layer)
  self.nodeTime = layer:getChildByName("Panel_djs")
  self.nodeTime:getChildByName("Text_s1"):setString(g_tr("actLeftTime"))
  self.nodeTime:getChildByName("Text_s2"):setString("")

  layer:getChildByName("Text_g1"):setString(g_tr("penglai_upto"))
  layer:getChildByName("Text_g2"):setString(g_tr("penglai_fanli"))
  local Panel = layer:getChildByName("Panel_nr1") 
  local btn1 = Panel:getChildByName("Button_y1") 
  local btn2 = Panel:getChildByName("Button_y2") 
  local btn3 = Panel:getChildByName("Button_y3") 
  btn1:getChildByName("Text_3"):setString("")
  btn2:getChildByName("Text_3"):setString("")
  btn3:getChildByName("Text_3"):setString("")
  self:regBtnCallback(btn1, handler(self, self.onTab1))
  self:regBtnCallback(btn2, handler(self, self.onTab2))
  self:regBtnCallback(btn3, handler(self, self.onTab3))

  self.tabs = {btn1, btn2, btn3}
  self.listView1 = Panel:getChildByName("ListView_1") 
  self.listView2 = Panel:getChildByName("ListView_2") 
  self.lbRatio = layer:getChildByName("BitmapFontLabel_1") 
  self.lbRatio:setString("0")

  self.lbSellOut = Panel:getChildByName("Text_sellout")
  self.lbSellOut:setString(g_tr("penglai_sell_out"))
  self.lbSellOut:setVisible(false)

  local txtRich1 = g_gameTools.createRichText(Panel:getChildByName("Text_b1"), "")
  local txtRich2 = g_gameTools.createRichText(Panel:getChildByName("Text_b2"), "")
  txtRich1:setRichText(g_tr("penglai_tip1"))
  txtRich2:setRichText(g_tr("penglai_tip2"))

  self.lbLimit = layer:getChildByName("Text_4")
  self.lbLimit:setString("")

  local Panel_2 = layer:getChildByName("Panel_andz1") 
  self.btnBuy = Panel_2:getChildByName("Button_5") 
  self.btnBuy:getChildByName("Text_1"):setString("")
  self.btnBuy:getChildByName("Text_2"):setString("")
  self:regBtnCallback(self.btnBuy, handler(self, self.onBuy))
end 


function ActivityPenglaiGiftView:updateUI()

  if nil == viewObj then return end 

  if nil == self.data or nil == self.data.gift then return end 


  local function getPriceItem(channel, gifType)
    for k, v in pairs(g_data.pricing) do 
      if v.channel == channel and v.gift_type == tonumber(gifType) then 
        return v 
      end 
    end 
  end 

  --tab 按钮价格
  for i = 1, 3 do 
    if self.data.gift[i] then 
      self.tabs[i]:setVisible(true)
      local item = getPriceItem(self.curChannel, self.data.gift[i].gift_type)
      self.tabs[i]:getChildByName("Text_3"):setString(g_channelManager.GetMoneyType(item.type)..item.price.."")
    else 
      self.tabs[i]:setVisible(false)
    end 
  end 

  self.btnBuy:getChildByName("Text_1"):setString("")
  self.btnBuy:getChildByName("Text_2"):setString("")

  if nil == self.data.gift[tabIndex] then 
    self:highlightTab(1)
  end 

  local awardMoney = 0 --赠送元宝数
  local tmpdata = self.data.gift[tabIndex] 
  if tmpdata then 
    local item = getPriceItem(self.curChannel, tmpdata.gift_type)
    awardMoney = item.count 
    self.btnBuy:getChildByName("Text_1"):setString(""..g_channelManager.GetMoneyType(item.type)..tmpdata.show_price)
    self.btnBuy:getChildByName("Text_2"):setString(""..g_channelManager.GetMoneyType(item.type)..item.price)

    local str = tonumber(tmpdata.activity_id) == 1020 and g_tr("onlyOneBuy") or ""
    self.lbLimit:setString(str)

    self.lbRatio:setString(tmpdata.ratio.."%")
  end 

  self:showItemList(tmpdata, awardMoney) 
end 

function ActivityPenglaiGiftView:showItemList(data, awardMoney)

  self.listView1:removeAllChildren()
  self.listView2:removeAllChildren()

  self.lbSellOut:setVisible(nil == data)

  if nil == data then return end 

  local idx_s
  local idx_e 
  local listItem = cc.CSLoader:createNode("activity4_mian9_list2.csb")
  local itemSize = listItem:getContentSize()
  local function insertOneLine(listView, data)
    local numPerLine = 3 

    local layout = ccui.Layout:create()  
    layout:setContentSize(cc.size(itemSize.width*3, itemSize.height)) 

    for k = 1, numPerLine do 
      if idx_s > idx_e then break end 

      local v = data[idx_s]
      local icon = require("game.uilayer.common.DropItemView").new(v[1], v[2], v[3])
      if icon then 
        icon:setNameVisible(false) 
        icon:setCountEnabled(false)
        icon:enableTip()
        local item_new = listItem:clone() 
        item_new:getChildByName("Text_1"):setString(icon:getName())
        if v[3] > 1 then 
          item_new:getChildByName("Panel_1"):setVisible(true) 
          item_new:getChildByName("Image_0"):setVisible(false) 
          local node = item_new:getChildByName("Panel_1"):getChildByName("Image_3")
          icon:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
          node:addChild(icon) 
          item_new:getChildByName("Panel_1"):getChildByName("Text_2"):setString(""..v[3]) 
        else 
          item_new:getChildByName("Panel_1"):setVisible(false) 
          item_new:getChildByName("Image_0"):setVisible(true) 
          local node = item_new:getChildByName("Image_0")
          icon:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
          node:addChild(icon) 
        end 
        item_new:setPosition(cc.p((k-1)*itemSize.width, 0))
        layout:addChild(item_new) 
      end 

      idx_s = idx_s + 1 
    end 
    listView:pushBackCustomItem(layout)
  end 

  if type(data.drop_id) == "table" then 
    local tmp = clone(data.drop_id)
    if awardMoney > 0 then 
      table.insert(tmp, {2, 10700, awardMoney})
    end 

    idx_s = 1
    idx_e = #tmp 
    local rows = math.ceil(idx_e/3)
    for i = 1, rows do 
      insertOneLine(self.listView1, tmp) 
    end 
  end 

  if type(data.guild_drop_id) == "table" then 
    idx_s = 1
    idx_e = #data.guild_drop_id 
    local rows = math.ceil(idx_e/3)
    for i = 1, rows do 
      insertOneLine(self.listView2, data.guild_drop_id)
    end 
  end 
end 

function ActivityPenglaiGiftView:onReqData()
  local function onRecv(result, data)
    g_busyTip.hide_1()
    if result then 
      self.data = data 
      dump(data, "=====data")
      self:updateUI()
      self:showLeftTime()
    end 
  end 

  g_sgHttp.postData("activity/getPayGift", {channel = self.curChannel}, onRecv, true) 
  g_busyTip.show_1()  
end 

function ActivityPenglaiGiftView:highlightTab(index)
  for k, v in pairs(self.tabs) do 
    v:setHighlighted(k == index)
  end 
  tabIndex = index 
end 

function ActivityPenglaiGiftView:onTab1()
  self:highlightTab(1)
  self:updateUI()
end 

function ActivityPenglaiGiftView:onTab2()
  self:highlightTab(2)
  self:updateUI()
end 

function ActivityPenglaiGiftView:onTab3()
  self:highlightTab(3)
  self:updateUI()
end 

function ActivityPenglaiGiftView:onBuy()
  if nil == self.data or nil == self.data.gift then return end 

  local tmpdata = self.data.gift[tabIndex] 
  if nil == tmpdata then return end 

  if #g_channelManager.GetPayWayList() == 1 then
    g_moneyData.RequestData(tmpdata.id, tmpdata.aci, self.curChannel)
  else
    g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyTypeView").new(tmpdata.id, tmpdata.aci))
  end

  if tmpdata.activity_id == 1020 then --限购一次时需要重新更新数据
    self:onReqData() 
  end 
end 

function ActivityPenglaiGiftView:showLeftTime()
  if nil == self.data then return end 

  local targetTime = self.data.activity.end_time 
  local lbPreTime = self.nodeTime:getChildByName("Text_s1")
  local lbTime = self.nodeTime:getChildByName("Text_s2") 

  local function updateTime()
    if nil == viewObj then return end 

    local leftTime = math.max(0, targetTime - g_clock.getCurServerTime()) 

    if leftTime < 1 then 
      self:unschedule(self.timer)
      self.timer = nil 

      lbPreTime:setString(g_tr("actIsClosed"))
      lbTime:setString("")
    else 
      lbTime:setString(g_gameTools.convertSecondToString(leftTime)) 
    end 
  end 

  if self.timer then 
    self:unschedule(self.timer)
    self.timer = nil 
  end 

  local leftTime = math.max(0, targetTime - g_clock.getCurServerTime()) 
  if leftTime > 0 then 
    lbTime:setString(g_gameTools.convertSecondToString(leftTime))
    self.timer = self:schedule(updateTime, 1.0) 
  else 
    lbPreTime:setString(g_tr("actIsClosed"))
    lbTime:setString("")
  end 
end 

return ActivityPenglaiGiftView 

