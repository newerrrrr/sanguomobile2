

local SelectGuildPlayerItem = class("SelectGuildPlayerItem", function() return ccui.Widget:create() end )

function SelectGuildPlayerItem:ctor()
  self._isEditable = true 
end 

function SelectGuildPlayerItem:create(playerInfo)
  local widget = cc.CSLoader:createNode("mail_select_player.csb")
  local item = SelectGuildPlayerItem.new()
  item:initBinding(widget, playerInfo)
  return item 
end 

function SelectGuildPlayerItem:clone(playerInfo)
  local widget = self._uiWidget:clone()
  local item = SelectGuildPlayerItem.new()
  item:initBinding(widget, playerInfo)
  return item 
end 

function SelectGuildPlayerItem:initBinding(uiWidget, playerInfo)
  self._uiWidget = uiWidget 

  if uiWidget then 
    self:setContentSize(uiWidget:getContentSize())
    self:addChild(uiWidget) 

    self.btnSelect = uiWidget:getChildByName("img_select_bg")
    self.imgSelected = uiWidget:getChildByName("img_select")
    local imgHeader = uiWidget:getChildByName("pic")
    local lbName = uiWidget:getChildByName("Text_from")
    local lbPrePower = uiWidget:getChildByName("Text_battle") 
    local lbPower = uiWidget:getChildByName("Text_battle_0") 
    local lbOnline = uiWidget:getChildByName("Text_state") 
    local lbOffline = uiWidget:getChildByName("Text_state_0") 

    lbPrePower:setString(g_tr_original("battlePower"))
    lbPower:setPositionX(lbPrePower:getPositionX()+lbPrePower:getContentSize().width+3)

    if playerInfo then 
      self:setSelected(playerInfo.isSelected)
      self:setIsEditable(playerInfo.isEditable)
      lbName:setString(g_tr(playerInfo.Player.nick))
      lbPower:setString(""..playerInfo.Player.power)
      require("game.uilayer.mail.MailHelper"):instance():loadPlayerIcon(imgHeader, tonumber(playerInfo.Player.avatar_id))

      if require("game.gametools.online").operateIsOnline(g_clock.getCurServerTime(), playerInfo.Player.last_online_time) then
        lbOnline:setVisible(true)
        lbOffline:setVisible(false)
      else 
        lbOnline:setVisible(false)
        lbOffline:setVisible(true)
      end 
    else 
      lbName:setString("")
      lbPower:setString("")
      lbOnline:setVisible(false)
      lbOffline:setVisible(false)
      self:setSelected(false)
    end 

    local function onTouchSelected() 
      local state = not self:getIsSelected()
      self:setSelected(state) 
    end 

    self.btnSelect:addClickEventListener(onTouchSelected)
  end 
end 

function SelectGuildPlayerItem:setSelected(isSelected)
  if self._isEditable then 
    self.imgSelected:setVisible(isSelected) 
  end 
end 

function SelectGuildPlayerItem:getIsSelected()
  return self.imgSelected:isVisible()
end 

function SelectGuildPlayerItem:setIsEditable(isEditable)
  self._isEditable = isEditable 
  self.btnSelect:setTouchEnabled(isEditable)
end 

function SelectGuildPlayerItem:setIdx(idx)
  self._idx = idx 
end 

function SelectGuildPlayerItem:getIdx()
  return self._idx
end 

return  SelectGuildPlayerItem 
