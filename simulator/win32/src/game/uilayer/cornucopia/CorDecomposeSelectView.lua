
--神武将盔甲选择
local CorDecomposeSelectView = class("CorDecomposeSelectView",require("game.uilayer.base.BaseLayer"))

-- matData  传入的神武将盔甲信息，包含如下信息
-- matData.id 
-- matData.ownNum 
-- matData.selectedNum 
function CorDecomposeSelectView:ctor(matData, callback)
  CorDecomposeSelectView.super.ctor(self)
  print("CorDecomposeSelectView:ctor") 
  self.matData = matData 
  self.callback = callback 
  self.listItems = {} 
  self.textInput = {}
end 

function CorDecomposeSelectView:onEnter()
  print("CorDecomposeSelectView:onEnter")
  local layer = g_gameTools.LoadCocosUI("GodGenerals_Smithrecast_Synthesis1_popup.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node"))
    self:showList() 
  end 
end 

function CorDecomposeSelectView:initBinding(scaleNode)
  self.listView = scaleNode:getChildByName("ListView_1")
  local btnClose = scaleNode:getChildByName("close_btn")
  local lbTitle = scaleNode:getChildByName("bg_goods_name"):getChildByName("text") 
  local btnConform = scaleNode:getChildByName("btn_buy") 

  lbTitle:setString(g_tr("corGodArmyList"))
  btnConform:getChildByName("Text_3"):setString(g_tr("confirm"))
  self:regBtnCallback(btnClose, handler(self, self.close)) 
  self:regBtnCallback(btnConform, handler(self, self.onConform)) 
end 


function CorDecomposeSelectView:onExit() 
  print("CorDecomposeSelectView:onExit") 
end 

function CorDecomposeSelectView:showList() 
  for k, v in pairs(self.matData) do 
    local item = cc.CSLoader:createNode("GodGenerals_Smithrecast_Synthesis1_popup_list1.csb") 
    self:initListItem(item, k)
    self.listView:pushBackCustomItem(item) 
  end 
end 


function CorDecomposeSelectView:initListItem(listItem, idx)

  local slider = listItem:getChildByName("Slider_1") 
  local textField = listItem:getChildByName("TextField_1") 
  local lbSilve = listItem:getChildByName("Text_1_0") 
  local btnAdd = listItem:getChildByName("btn_add") 
  local btnReduce = listItem:getChildByName("btn_reduce")   
  local textInput = g_gameTools.convertTextFieldToEditBox(textField)
  textInput:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
  slider:setTag(100+idx) 
  textInput:setTag(200+idx) 
  btnAdd:setTag(300+idx) 
  btnReduce:setTag(400+idx) 
  self.listItems[idx] = listItem 
  self.textInput[idx] = textInput 

  --初始化数量 
  self:updateSelectedNum(slider, textInput, lbSilve, self.matData[idx])


  --显示图标
  local iconNode = listItem:getChildByName("Panel_l1")
  local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, self.matData[idx].id, 0) 
  if icon then 
    icon:setNameVisible(false)
    icon:setCountEnabled(false)
    icon:setPosition(cc.p(iconNode:getContentSize().width/2, iconNode:getContentSize().height/2)) 
    iconNode:addChild(icon)
  end 

  --滑动条
  local function sliderEvent(sender, eventType)
    if eventType == ccui.SliderEventType.percentChanged then 
      local index = sender:getTag() - 100 
      if self.matData[index].ownNum == 0 then 
        sender:setPercent(0)
      else 
        local maxNum = math.min(99, self.matData[index].ownNum)
        self.matData[index].selectedNum = math.floor(maxNum * sender:getPercent()/100) 

        local lbSilve = self.listItems[index]:getChildByName("Text_1_0") 
        self:updateSelectedNum(nil, self.textInput[index], lbSilve, self.matData[index]) 
      end 

    elseif eventType == ccui.SliderEventType.slideBallUp then
    end 
  end 
  
  slider:addEventListener(sliderEvent)

  --输入框
  local function textFieldEvent(eventType, sender) 

    if eventType == "customEnd" then 
      if nil == sender then return end 

      local index = sender:getTag() - 200 
      local maxNum = math.min(99, self.matData[index].ownNum) 
      local editnum = math.round(tonumber(sender:getString()) or 0)
      if editnum >= maxNum then
        editnum = maxNum
      end
      if editnum < 0 then
        editnum = 0
      end
      self.matData[index].selectedNum = editnum 
      local slider = self.listItems[index]:getChildByName("Slider_1")
      local lbSilve = self.listItems[index]:getChildByName("Text_1_0") 
      self:updateSelectedNum(slider, sender, lbSilve, self.matData[index]) 
    end 
  end  
  textInput:setPlaceHolder("")
  textInput:setMaxLength(4)
  textInput:registerScriptEditBoxHandler(textFieldEvent)  
  listItem:getChildByName("Text_sz"):setString("/"..self.matData[idx].ownNum)

  --加减号
  self:regBtnCallback(btnAdd, handler(self, self.onTouchAdd)) 
  self:regBtnCallback(btnReduce, handler(self, self.onTouchReduce)) 

  --玄铁图标
  local _, path = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.XuanTie)
  listItem:getChildByName("Image_tb"):loadTexture(path)
end 


function CorDecomposeSelectView:updateSelectedNum(slider, textInput, lbSilve, dataInfo) 

  if slider then 
    local percent = dataInfo.selectedNum > 0 and (100*dataInfo.selectedNum/dataInfo.ownNum) or 0 
    slider:setPercent(percent)
  end 

  if textInput then 
    textInput:setString(tostring(dataInfo.selectedNum))
  end 

  if lbSilve then 
    local count = self:getGainedMat(dataInfo.id, dataInfo.selectedNum)
    lbSilve:setString(""..count) 
  end 
end 

function CorDecomposeSelectView:getGainedMat(id, multiple)
  local item = g_data.item[id]
  if item and item.decomposition and item.decomposition > 0 then 
    local drop = g_data.drop[item.decomposition] 
    if drop then 
      local dropMat = drop.drop_data[1]
      if dropMat then 
        return dropMat[3] * multiple 
      end 
    end 
  end   

  return 0 
end 

function CorDecomposeSelectView:onConform() 
  if self.callback then 
    self.callback(self.matData)
  end 

  self:close()
end 


function CorDecomposeSelectView:onTouchAdd(sender)
  if nil == sender then return end 

  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local index = sender:getTag() - 300 
  local maxNum = math.min(99, self.matData[index].ownNum)
  if self.matData[index].selectedNum < maxNum then 
    self.matData[index].selectedNum = self.matData[index].selectedNum + 1 

    local slider = self.listItems[index]:getChildByName("Slider_1")
    local lbSilve = self.listItems[index]:getChildByName("Text_1_0") 
    self:updateSelectedNum(slider, self.textInput[index], lbSilve, self.matData[index])
  end 
end

function CorDecomposeSelectView:onTouchReduce(sender)
  if nil == sender then return end 

  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local index = sender:getTag() - 400 

  if self.matData[index].selectedNum > 0 then 
    self.matData[index].selectedNum = self.matData[index].selectedNum - 1 

    local slider = self.listItems[index]:getChildByName("Slider_1")
    local lbSilve = self.listItems[index]:getChildByName("Text_1_0") 
    self:updateSelectedNum(slider, self.textInput[index], lbSilve, self.matData[index])
  end 
end

return CorDecomposeSelectView 
