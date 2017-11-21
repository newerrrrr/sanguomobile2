
--公会成员选择
--


local SelectGuildPlayerView = class("SelectGuildPlayerView",require("game.uilayer.base.BaseLayer"))

--参数:isExcludeMyself: 是否将自己排除
function SelectGuildPlayerView:ctor(isExcludeMyself)
  print("SelectGuildPlayerView:ctor")
  SelectGuildPlayerView.super.ctor(self)
  
  self.isSelectedAll = false 
  
  g_AllianceMode.reqGuildPlayers()
  self.allGuildPlayers = g_AllianceMode.getGuildPlayers()

  if isExcludeMyself then 
    local myPlayerId = g_PlayerMode.GetData().id
    for k, v in pairs(self.allGuildPlayers) do 
      if v.player_id == myPlayerId then 
        table.remove(self.allGuildPlayers, k)
        break 
      end 
    end 
  end 

  --初始化选择状态
  for k, v in pairs(self.allGuildPlayers) do 
    v.idx = k 
    v.isSelected = false 
    v.isEditable = true --是否允许用户选择或取消选择(比如某些默认选择的数据不允许再被取消选择)
  end 
end 

function SelectGuildPlayerView:onEnter()
  print("SelectGuildPlayerView:onEnter")
  local layer = g_gameTools.LoadCocosUI("mail_selecet_player_popup.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showRankList()

    --是否显示退群按钮,并调整按钮位置 
    local pos_x = self.playerList:getPositionX() 
    local width = self.playerList:getContentSize().width 
    if self._userQuitCallback then 
      self.btnQuit:setVisible(true) 
      self.btnConfirm:setPositionX(pos_x + width/2 - self.btnConfirm:getContentSize().width/2 - 40)
      self.btnQuit:setPositionX(pos_x + width/2 + self.btnQuit:getContentSize().width/2 + 40)
    else 
      self.btnQuit:setVisible(false)
      self.btnConfirm:setPositionX(pos_x + width/2)
    end 
  end 
end 

function SelectGuildPlayerView:onExit() 
  print("SelectGuildPlayerView:onExit") 
end 

function SelectGuildPlayerView:initBinding(scaleNode)

  local content_popup = scaleNode:getChildByName("content_popup")
  local lbTitle = content_popup:getChildByName("bg_goods_name_0"):getChildByName("text") 
  self.rankList = content_popup:getChildByName("ListView_1")

  local btnSelectAll = content_popup:getChildByName("img_select_bg")
  self.imgSelectAll =  content_popup:getChildByName("img_select")
  local lbAll = content_popup:getChildByName("Text_select_all")
  self.playerList = content_popup:getChildByName("ListView_2")

  local btnClose = content_popup:getChildByName("close_btn")  
  self.btnConfirm = content_popup:getChildByName("btn_save")
  local lbConfirm = content_popup:getChildByName("btn_save"):getChildByName("Text")

  self.btnQuit = content_popup:getChildByName("btn_save_0")
  local lbQuit = content_popup:getChildByName("btn_save_0"):getChildByName("Text")

  lbTitle:setString(g_tr("allianceMembers"))
  lbAll:setString(g_tr("selectAll"))
  lbConfirm:setString(g_tr("msgBox_ok"))
  lbQuit:setString(g_tr("quitMulityChat"))

  self:regBtnCallback(btnSelectAll, handler(self, self.onSelectAll)) 
  self:regBtnCallback(btnClose, handler(self, self.close)) 
  self:regBtnCallback(self.btnConfirm, handler(self, self.onConfirm)) 
  self:regBtnCallback(self.btnQuit, handler(self, self.onQuitMulityChat)) 

  self.imgSelectAll:setVisible(self.isSelectedAll)
end 

--公会成员阶级列表 
function SelectGuildPlayerView:showRankList()
  local function onSelectItem(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then 
      local idx = sender:getCurSelectedIndex()
      self:hightlightRankIdx(idx)
    end 
  end 

  local item = cc.CSLoader:createNode("mail_left_menu_01.csb") 
  item:setTouchEnabled(true)
  self.rankList:setItemModel(item)
  self.rankList:setScrollBarEnabled(false)
  self.rankList:addEventListener(onSelectItem)

  --计算各联盟阶级成员个数
  local count = {0, 0, 0, 0, 0}
  for k, v in pairs(self.allGuildPlayers) do 
    count[v.rank] = count[v.rank] + 1 
  end 

  for i=1, 5 do 
    item:getChildByName("Text"):setString(g_AllianceMode.getRankNameByRank(i)) 
    item:getChildByName("Text_1"):setString(string.format("%d", count[i]))
    self.rankList:pushBackDefaultItem() 
  end 

  self:hightlightRankIdx(0)
end 

function SelectGuildPlayerView:hightlightRankIdx(idx)

  self.rankListIdx = idx 

  --highlight selected
  for k, v in pairs(self.rankList:getItems()) do 
    if self.rankList:getIndex(v) == idx then 
      v:getChildByName("Image_1"):setVisible(false)
      v:getChildByName("Image_2"):setVisible(true)
    else 
      v:getChildByName("Image_1"):setVisible(true)
      v:getChildByName("Image_2"):setVisible(false)
    end 
  end 

  self:showPlayerListByRank(idx+1)
end 

--指定阶级的成员列表
function SelectGuildPlayerView:showPlayerListByRank(rank) 

  --在显示新列表前,将先前列表中的选中状态保存
  for k, v in pairs(self.playerList:getItems()) do 
    self.allGuildPlayers[v:getIdx()].isSelected = v:getIsSelected()
  end 

  self.playerList:removeAllChildren()
  self.playerList:setScrollBarEnabled(false)
  self.playerList:setScrollBarEnabled(false)
  self.playerList:setItemsMargin(10)

  --筛选数据,并根据历史选择来调整全选按钮的显示状态
  self.isSelectedAll = true 
  local dataArray = {} 
  for k, v in pairs(self.allGuildPlayers) do 
    if v.rank == rank then 
      table.insert(dataArray, v)
      if not v.isSelected then 
        self.isSelectedAll = false 
      end 
    end 
  end 

  if #dataArray > 0 then 
    local item_new 
    local listItem = require("game.uilayer.common.SelectGuildPlayerItem"):create(dataArray[1]) 
    for i=1, #dataArray do 
      item_new = (i==1) and listItem or listItem:clone(dataArray[i])
      item_new:setIdx(dataArray[i].idx)
      self.playerList:pushBackCustomItem(item_new) 
    end 
  else 
    self.isSelectedAll = false 
  end 

  self.imgSelectAll:setVisible(self.isSelectedAll)
end 

function SelectGuildPlayerView:onSelectAll()
  print("onSelectAll")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if nil == self.playerList then return end 

  self.isSelectedAll = not self.isSelectedAll 
  self.imgSelectAll:setVisible(self.isSelectedAll)

  for k, v in pairs(self.playerList:getItems()) do 
    v:setSelected(self.isSelectedAll)
  end 
end 

function SelectGuildPlayerView:onConfirm()
  print("onConfirm")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  --先将当前列表选中状态同步到全局数据
  for k, v in pairs(self.playerList:getItems()) do 
    self.allGuildPlayers[v:getIdx()].isSelected = v:getIsSelected()
  end 

  local tbl = {}
  for k, v in pairs(self.allGuildPlayers) do 
    if v.isSelected then 
      table.insert(tbl, v)
    end 
  end 

  if self._userSaveCallback then 
    self._userSaveCallback(tbl)
  end

  self:close()
end 

--退出多人聊天(仅供邮件聊天里使用)
function SelectGuildPlayerView:onQuitMulityChat()
  print("onQuitMulityChat")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  if self._userQuitCallback then 
    self._userQuitCallback(tbl)
  end
  
  self:close()
end 

--默认选择的数据项,
--isEditable: true:用户可再次反选   false:禁止用户反选
function SelectGuildPlayerView:initSelectedState(names, isEditable)

  if names and #names > 0 then 
    for k, v in pairs(names) do 
      for idx, player in pairs(self.allGuildPlayers) do 
        if v == player.Player.nick then 
          self.allGuildPlayers[idx].isSelected = true 
          if false == isEditable then 
            self.allGuildPlayers[idx].isEditable = false  
          end 

          for key, item in pairs(self.playerList:getItems()) do 
            if item:getIdx() == idx then 
              item:setSelected(true) 
              if false == isEditable then 
                item:setIsEditable(false)
              end 
              break 
            end 
          end 
        end  
      end 
    end 
  end 
end 

--将选择的数据返回给用户
function SelectGuildPlayerView:setSaveCallback(callback)
  self._userSaveCallback = callback 
end 

--邮件聊天时退群回调给用户
function SelectGuildPlayerView:setQuitCallback(callback)
  self._userQuitCallback = callback 
end 

return SelectGuildPlayerView 
