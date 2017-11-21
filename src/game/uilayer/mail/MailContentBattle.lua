
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailContentBattle = class("MailContentSpy",require("game.uilayer.base.BaseLayer"))
local BattleSubType = MailHelper:getBattleSubTypeEnum() 
local layerObj


local timerCallbacks = {}
local function stopTimer(callback) 
  for k, v in pairs(timerCallbacks) do 
    if nil == callback or v == callback then 
      g_autoCallback.removeCocosList(v)
      timerCallbacks[k] = nil 
    end 
  end 
end 

local function startTimer(callback, delay)
  stopTimer(callback)
  table.insert(timerCallbacks, callback)
  g_autoCallback.addCocosList(callback , delay)
end 

function MailContentBattle:ctor(listItem)
  MailContentBattle.super.ctor(self)
  self.listItem = listItem --关联的某一个邮件列表项
  layerObj = self 
end 

function MailContentBattle:onEnter()
  print("MailContentBattle:onEnter")
  local layer = cc.CSLoader:createNode("mail_spy.csb")
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer) 
    self:showInfo()
  end 
end 

function MailContentBattle:onExit() 
  print("MailContentBattle:onExit") 
  layerObj = nil  
  stopTimer()
end 

function MailContentBattle:setLayerObj(obj)
  layerObj = obj 
end 


function MailContentBattle:initBinding(rootNode)
  local top_panel = rootNode:getChildByName("top_panel")
  self.imgTitleBg = top_panel:getChildByName("img_title_bg")
  self.lbTitle = top_panel:getChildByName("Text_title")  
  self.btnShare = top_panel:getChildByName("img_fenxiang")
  self.btnMark = top_panel:getChildByName("img_label")
  local btnDelete = top_panel:getChildByName("img_delete")
  local btnBack = top_panel:getChildByName("btn_back")
  self.lbTime = top_panel:getChildByName("text_time")
  self.listView = rootNode:getChildByName("ListView_1")

  self:regBtnCallback(self.btnShare, handler(self, self.onShareMail))
  self:regBtnCallback(self.btnMark, handler(self, self.onMarkMail))
  self:regBtnCallback(btnDelete, handler(self, self.onDeleteMail))
  self:regBtnCallback(btnBack, handler(self, self.onGoBack))

  local mail = self.listItem:getData().mail 
  MailHelper:setImgGray(self.btnMark, mail.status == 0)

  --允许分享的情况: 攻城战,资源战,联盟堡垒战,并且非全军覆没 
  if g_AllianceMode.getSelfHaveAlliance() and not mail.data.all_dead then 
    if mail.data.type == BattleSubType.Normal or mail.data.type == BattleSubType.Resource or mail.data.type == BattleSubType.Castle then 
      self.btnShare:setVisible(true)
    else 
      self.btnShare:setVisible(false)
    end 
  else 
    self.btnShare:setVisible(false)
  end 
end 

function MailContentBattle:showInfo()
  print("=== MailContentBattle:showInfo ")

  self.listView:removeAllChildren()
  -- self.listView:setItemsMargin(10)
  self.listView:setScrollBarEnabled(false)

  if nil == self.listItem then return end 
  local mailData = self.listItem:getData().mail 

  --标题
  local strTitle = MailHelper:isKindOfAtk(mailData.type) and g_tr("attack") or g_tr("defense")
  self.lbTitle:setString(strTitle)
  if self.lbTitle:getContentSize().width > 100 then --调整标题背景长度
    self.imgTitleBg:setContentSize(cc.size(self.lbTitle:getContentSize().width+80, self.imgTitleBg:getContentSize().height))
    self.lbTitle:setPosition(cc.p(self.imgTitleBg:getPositionX()+self.imgTitleBg:getContentSize().width/2, self.imgTitleBg:getPositionY()))
  end  

  --时间
  local tt = os.date("*t", mailData.create_time)
  self.lbTime:setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))

  --如果全军覆没,则没有其他战报详情
  if mailData.data.all_dead then 
    local killedItem = self:getAllKilledInfo(mailData)
    if killedItem then 
      self.listView:pushBackCustomItem(killedItem)
    end 
    return 
  end 

  --先加载一部分,其他分帧加载
  --1.头像信息
  self.funcQueue = {}
  table.insert(self.funcQueue, handler(self, self.getHeaderInfoItem)) --头像信息
  table.insert(self.funcQueue, handler(self, self.getDurabilityItem)) --(跨服战)城防血量
  table.insert(self.funcQueue, handler(self, self.getResourceInfoItem))  --资源
  table.insert(self.funcQueue, handler(self, self.getDropItem))       --获得道具
  table.insert(self.funcQueue, handler(self, self.getPowerLostItem))  --战力损失
  table.insert(self.funcQueue, handler(self, self.getGodSkillItem))   --神武将技能伤害
  table.insert(self.funcQueue, handler(self, self.getTroopInfoItem))  --部队详情 
  table.insert(self.funcQueue, handler(self, self.getDamageInfoItem)) --损害信息 
  table.insert(self.funcQueue, handler(self, self.getTroopAttrItem))  --部队属性

  function loadQueueContent() 
    if #self.funcQueue == 0 then return end 

    local function loadCallback()
      if nil == layerObj then return end 

      table.remove(self.funcQueue, 1) 

      if #self.funcQueue > 0 then 
        self:performWithDelay(handler(self, loadQueueContent), 0.1)
      end     
    end 

    local func = self.funcQueue[1] 
    func(self.listItem:getData().mail, self.listView, loadCallback) 
  end 

  loadQueueContent()
end 


--获得全军覆没信息
function MailContentBattle:getAllKilledInfo(mailData) 
  local item = cc.CSLoader:createNode("mail_battle_content_0.csb") 
  local lbPos = item:getChildByName("Text_pos")
  local lbPos1 = item:getChildByName("Text_pos_1")
  local lbDesc = item:getChildByName("Text_desc")
  lbPos:setString(g_tr("battlePos2"))
  lbDesc:setString(g_tr("allMyArmyKilled"))

  --加下划线
  MailHelper:addUnderLineForLabel(lbPos1, mailData.data.x, mailData.data.y)
  lbPos1:setPositionX(lbPos:getPositionX() + lbPos:getContentSize().width)

  return item 
end 

--头像信息
function MailContentBattle:getHeaderInfoItem(mailData, listView, callback)
  print("getHeaderInfoItem")

  local headerItem = cc.CSLoader:createNode("mail_battle_content.csb")
  local nodeContent = headerItem:getChildByName("panel_content")
  local lbPrePos = nodeContent:getChildByName("Text_pos")
  lbPrePos:setString(g_tr("battlePos2"))

  local disableJump = MailHelper:isCrossFight(mailData) 
  local lbPos = nodeContent:getChildByName("Text_pos_0")
  MailHelper:addUnderLineForLabel(lbPos, mailData.data.x, mailData.data.y, disableJump)
  lbPos:setPositionX(lbPrePos:getPositionX()+lbPrePos:getContentSize().width)

  local imgWin = nodeContent:getChildByName("pic_win")
  local imgLost = nodeContent:getChildByName("pic_lose")
  if MailHelper:isWin(mailData) then 
    imgWin:setVisible(true)
    imgLost:setVisible(false)
  else 
    imgWin:setVisible(false)
    imgLost:setVisible(true)
  end 

  --玩家自己
  local playerLeft = nodeContent:getChildByName("player_left")
  playerLeft:getChildByName("name"):setString(mailData.data.player1.nick)
  playerLeft:getChildByName("label_1"):setString(g_tr("Power"))
  playerLeft:getChildByName("label_2"):setString(g_tr("soldierCounts")..":")
  playerLeft:getChildByName("num_1"):setString(""..math.floor(mailData.data.player1.power/10000))
  playerLeft:getChildByName("num_2"):setString(""..mailData.data.player1.soldier_num) 

  local avatar_1 = mailData.data.player1.avatar and tonumber(mailData.data.player1.avatar) or nil 
  
  if avatar_1 and avatar_1 > 0 then 
    local imgPic = playerLeft:getChildByName("pic")
    if mailData.data.type == BattleSubType.Castle and not MailHelper:isKindOfAtk(mailData.type) then --攻打联盟堡垒时, 我是防守方则显示堡垒图片
      imgPic:loadTexture(g_resManager.getResPath(g_data.map_element[101].img_mail))

    elseif g_data.res_head[avatar_1] then --BattleSubType.King_NPC 是怪物攻击人, avatar 暂时不处理
      MailHelper:loadPlayerIcon(imgPic, avatar_1)
    end 
    playerLeft:getChildByName("pic_0"):loadTexture(g_resManager.getResPath(1010007))
  end 
  local lbPos1 = playerLeft:getChildByName("name_0")
  MailHelper:addUnderLineForLabel(lbPos1, mailData.data.player1.x, mailData.data.player1.y, disableJump)

  --对方
  local playerRight = nodeContent:getChildByName("player_right")
  local player2 = playerRight:getChildByName("Panel_player")
  local alliance = playerRight:getChildByName("Panel_alliance")
  local pic = playerRight:getChildByName("pic")
  playerRight:getChildByName("pic_0"):loadTexture(g_resManager.getResPath(1010007))
  player2:getChildByName("label_1"):setString(g_tr("Power"))
  player2:getChildByName("label_2"):setString(g_tr("soldierCounts")..":")
  player2:setVisible(false) 
  alliance:setVisible(false)  

  local lbPos2 = player2:getChildByName("name_0")
  MailHelper:addUnderLineForLabel(lbPos2, mailData.data.player2.x, mailData.data.player2.y, disableJump)

  local avatar_2 = mailData.data.player2.avatar and tonumber(mailData.data.player2.avatar) or nil 

  if mailData.data.type == BattleSubType.Normal or mailData.data.type == BattleSubType.Resource --攻城/攻打资源点 
    or mailData.data.type == BattleSubType.AtkCity or mailData.data.type == BattleSubType.AtkArmy then --跨服战攻击城门/投石车(人)
    player2:setVisible(true)
    if avatar_2 and avatar_2 > 0 then 
      MailHelper:loadPlayerIcon(pic, avatar_2)
    end 
    player2:getChildByName("name"):setString(mailData.data.player2.nick)            
    player2:getChildByName("num_1"):setString(""..math.floor(mailData.data.player2.power/10000))            
    player2:getChildByName("num_2"):setString(""..mailData.data.player2.soldier_num)

  elseif mailData.data.type == BattleSubType.Castle then --攻打联盟堡垒
    alliance:setVisible(true) 
    alliance:getChildByName("name"):setString(mailData.data.player2.nick or "") 
    if MailHelper:isKindOfAtk(mailData.type) then --攻打联盟堡垒时, 被攻打的则显示堡垒图片
      pic:loadTexture(g_resManager.getResPath(g_data.map_element[101].img_mail))
    else 
      MailHelper:loadPlayerIcon(pic, avatar_2)
    end 

  elseif mailData.data.type == BattleSubType.King_PVP or mailData.data.type == BattleSubType.King_PVE or mailData.data.type == BattleSubType.King_NPC then
    player2:setVisible(true)
    print("mail id, avatar:", mailData.id, avatar_2)
    if avatar_2 and avatar_2 > 0 then
      if mailData.data.type == BattleSubType.King_PVP and g_data.res_head[avatar_2] then 
        MailHelper:loadPlayerIcon(pic, avatar_2)

      elseif g_data.map_element[avatar_2] then  
        pic:loadTexture(g_resManager.getResPath(g_data.map_element[avatar_2].img_mail))
      elseif g_data.npc[avatar_2] then  
        pic:loadTexture(g_resManager.getResPath(g_data.npc[avatar_2].img_mail)) 
      end 
    else 
      print("invalid avatar !!!!", avatar_2)
    end 
    player2:getChildByName("name"):setString(mailData.data.player2.nick or "")
    player2:getChildByName("num_1"):setString(""..math.ceil(mailData.data.player2.power/10000))
    player2:getChildByName("num_2"):setString(""..mailData.data.player2.soldier_num)

    if mailData.data.type == BattleSubType.King_PVE or mailData.data.type == BattleSubType.King_NPC then --国王战怪物不显示战斗力
      player2:getChildByName("label_1"):setVisible(false) 
      player2:getChildByName("num_1"):setVisible(false)
    end 

  elseif mailData.data.type == BattleSubType.AtkDoor or mailData.data.type == BattleSubType.AtkBase then --跨服战攻击城门/大本营
    if g_data.map_element[avatar_2] then  
      MailHelper:loadResIcon(pic, g_data.map_element[avatar_2].img_mail)

      player2:setVisible(true) 
      if mailData.data.type == BattleSubType.AtkDoor then 
        if mailData.data.player2.guild_name then --跨服战
          player2:getChildByName("name"):setString(g_tr("crossCityDoor", {name = mailData.data.player2.guild_name}))  
        else --城战,城门可能无归属
          if mailData.data.player2.camp_id and tonumber(mailData.data.player2.camp_id) > 0 then 
            player2:getChildByName("name"):setString(g_tr("crossCityDoor", {name = g_tr("city_battle_camp"..mailData.data.player2.camp_id)}))              
          else 
            player2:getChildByName("name"):setString(g_tr("guild_war_build_desc7")) --只显示城门
          end 
        end 
      else 
        player2:getChildByName("name"):setString(g_tr("crossCityBase", {name = mailData.data.player2.guild_name})) 
      end 
      player2:getChildByName("label_1"):setVisible(false)
      player2:getChildByName("num_1"):setVisible(false)
      player2:getChildByName("label_2"):setString(g_tr("life").."：")
      player2:getChildByName("num_2"):setString(""..(mailData.data.player2.newDurability or 0))
    end 
  end 

  local pos_y = 0 
  local nodeHeader = ccui.Widget:create()  
  pos_y = pos_y - headerItem:getContentSize().height 
  headerItem:setPosition(cc.p(0, pos_y))
  nodeHeader:addChild(headerItem)



  --拼接属性
  local item = cc.CSLoader:createNode("mail_battle_content_16.csb") 
  local itemInfos = {}
  local isCrossFight = false 
  if mailData.data.type == BattleSubType.AtkCity or mailData.data.type == BattleSubType.AtkArmy then --城池/投石车
    itemInfos = {
                  {g_tr("killEnemy")..":", ""..mailData.data.player1.kill_num, ""..mailData.data.player2.kill_num},
                  {g_tr("lostTroops")..":", ""..mailData.data.player1.killed_num, ""..mailData.data.player2.killed_num},
                  {g_tr("surviveTroops")..":", ""..mailData.data.player1.live_num, ""..mailData.data.player2.live_num}
                }
                
  elseif mailData.data.type == BattleSubType.AtkDoor or mailData.data.type == BattleSubType.AtkBase then 
    itemInfos = {} 

  else 
    --收拢残兵
    local function getRecallNum(players)
      local num = 0 
      for k, player in pairs(players) do 
        if player.unit then 
          for m, v in pairs(player.unit) do 
            if v.revive_num then 
              num = num + v.revive_num 
            end 
          end 
        end 
      end 
      return num 
    end 

    itemInfos = {
        {g_tr("killEnemy")..":", ""..mailData.data.player1.kill_num, ""..mailData.data.player2.kill_num},
        {g_tr("lostTroops")..":", ""..mailData.data.player1.killed_num, ""..mailData.data.player2.killed_num},
        {g_tr("woundedTroops")..":", ""..mailData.data.player1.injure_num, ""..mailData.data.player2.injure_num},
        {g_tr("surviveTroops")..":", ""..mailData.data.player1.live_num, ""..mailData.data.player2.live_num},
        {g_tr("lostTraps")..":", ""..mailData.data.player1.trap_lost, ""..mailData.data.player2.trap_lost},
        {g_tr("recallSoldiers")..":", ""..getRecallNum(mailData.data.player1.players), ""..getRecallNum(mailData.data.player2.players)}
      }
  end 

  for k, v in pairs(itemInfos) do 
    local item_new = item:clone()
    local panel_1 = item_new:getChildByName("Panel_1")
    local panel_2 = item_new:getChildByName("Panel_2")
    panel_1:setVisible(true)
    panel_2:setVisible(false)
    panel_1:getChildByName("label_1"):setString(v[1])
    panel_1:getChildByName("label_2"):setString(v[1])
    panel_1:getChildByName("num_1"):setString(v[2])    
    panel_1:getChildByName("num_2"):setString(v[3])

    pos_y = pos_y - item_new:getContentSize().height 
    item_new:setPosition(cc.p(0, pos_y)) 
    nodeHeader:addChild(item_new)       
  end 

  --城防值
  if mailData.data.type == BattleSubType.Castle then --攻打联盟堡垒
    if mailData.data.player1.oldDurability or mailData.data.player2.oldDurability then 

      local panel_1 = item:getChildByName("Panel_1")
      local panel_2 = item:getChildByName("Panel_2")
      panel_1:setVisible(false)
      panel_2:setVisible(true)

      local lbPreDefend1 = panel_2:getChildByName("label_3")
      local lbPreDefend2 = panel_2:getChildByName("label_4")
      local lbDefend1 = panel_2:getChildByName("num_3")
      local lbDefend2 = panel_2:getChildByName("num_33")
      local lbDefend3 = panel_2:getChildByName("num_4")
      local lbDefend4 = panel_2:getChildByName("num_44")
      lbPreDefend1:setString(g_tr("towerDefendVal"))
      lbPreDefend2:setString(g_tr("towerDefendVal"))
      if mailData.data.player1.oldDurability then 
        lbDefend1:setString(""..mailData.data.player1.oldDurability)
        lbDefend2:setString("- "..mailData.data.player1.oldDurability-mailData.data.player1.newDurability)
        lbDefend2:setPositionX(lbDefend1:getPositionX()+lbDefend1:getContentSize().width+8)
        lbDefend2:setVisible(mailData.data.player1.oldDurability ~= mailData.data.player1.newDurability)
      else 
        lbPreDefend1:setVisible(false)
        lbDefend1:setVisible(false)
        lbDefend2:setVisible(false)          
      end 

      if mailData.data.player2.oldDurability then 
        lbDefend3:setString(""..mailData.data.player2.oldDurability)
        lbDefend4:setString("- "..mailData.data.player2.oldDurability-mailData.data.player2.newDurability)
        lbDefend4:setPositionX(lbDefend3:getPositionX()+lbDefend3:getContentSize().width+8)
        lbDefend4:setVisible(mailData.data.player2.oldDurability ~= mailData.data.player2.newDurability)
      else 
        lbPreDefend2:setVisible(false)
        lbDefend3:setVisible(false)
        lbDefend4:setVisible(false)
      end  

      pos_y = pos_y - item:getContentSize().height 
      item:setPosition(cc.p(0, pos_y)) 
      nodeHeader:addChild(item)         
    end    
  end 


  --顽强buff提示
  if mailData.data.player1.noobProtect or mailData.data.player2.noobProtect then 
    local item_buf = cc.CSLoader:createNode("mail_battle_content_17.csb") 
    local lbBufInc1 = item_buf:getChildByName("label_1")
    local lbBufInc2 = item_buf:getChildByName("label_2")
    lbBufInc1:setString(g_tr("hasStrongBuf"))
    lbBufInc2:setString(g_tr("hasStrongBuf"))
    lbBufInc1:setVisible(nil ~= mailData.data.player1.noobProtect)
    lbBufInc2:setVisible(nil ~= mailData.data.player2.noobProtect)
    pos_y = pos_y - item_buf:getContentSize().height 
    item_buf:setPosition(cc.p(0, pos_y)) 
    nodeHeader:addChild(item_buf)   
  end 

  --加保护罩提示
  if mailData.data.player1.protectOpen or mailData.data.player2.protectOpen then 
    local item_prot = cc.CSLoader:createNode("mail_battle_content_17.csb") 
    local lbBufInc1 = item_prot:getChildByName("label_1")
    local lbBufInc2 = item_prot:getChildByName("label_2")
    lbBufInc1:setString(g_tr("hasProtection", {name=mailData.data.player1.nick}))
    lbBufInc2:setString(g_tr("hasProtection", {name=mailData.data.player2.nick}))
    lbBufInc1:setVisible(mailData.data.player1.noobProtect and mailData.data.player1.noobProtect > 0)
    lbBufInc2:setVisible(mailData.data.player2.noobProtect and mailData.data.player2.noobProtect > 0)
    pos_y = pos_y - item_prot:getContentSize().height 
    item_prot:setPosition(cc.p(0, pos_y)) 
    nodeHeader:addChild(item_prot)   
  end 


  local tmp = ccui.Widget:create()
  tmp:setContentSize(cc.size(item:getContentSize().width, -pos_y))
  nodeHeader:setPosition(cc.p(0, -pos_y))
  tmp:addChild(nodeHeader) 


  listView:pushBackCustomItem(tmp) 
  if callback then 
    callback() 
  end 
end 

--城防伤害
function MailContentBattle:getDurabilityItem(mailData, listView, callback) 

  local player1 = mailData.data.player1
  local player2 = mailData.data.player2
  local item
  local titleStr = ""

  if mailData.data.type == BattleSubType.AtkCity --攻打主城
    or mailData.data.type == BattleSubType.AtkDoor --攻打城门
    or mailData.data.type == BattleSubType.AtkBase then --攻打大本营

    item = cc.CSLoader:createNode("mail_battle_content_15.csb") 
    local lbPreLeft = item:getChildByName("Text_2")
    local lbLeft = item:getChildByName("Text_3")
    local lbPreDamage = item:getChildByName("Text_4")
    local lbDamage = item:getChildByName("Text_5")
    local LoadingBar = item:getChildByName("LoadingBar_1")
    lbPreLeft:setString(g_tr("durabilityLeft"))
    lbPreDamage:setString(g_tr("sufferDamageOfCity"))
    lbLeft:setString("")
    lbDamage:setString("")
    LoadingBar:setPercent(0)

    local strName = ""
    if mailData.data.type == BattleSubType.AtkCity then 
      titleStr = g_tr("titleCityLife")
      strName = g_tr("crossCity", {name = player2.nick})

    elseif mailData.data.type == BattleSubType.AtkDoor then 
      titleStr = g_tr("titleCityDoorLife")
      
      if player2.guild_name then --跨服战
        strName = g_tr("crossCityDoor", {name = player2.guild_name}) 
      else --城战,城门可能无归属
        if player2.camp_id and tonumber(player2.camp_id) > 0 then 
          strName = g_tr("crossCityDoor", {name = g_tr("city_battle_camp"..player2.camp_id)})             
        else 
          strName = g_tr("guild_war_build_desc7") --只显示城门
        end 
      end 
    elseif mailData.data.type == BattleSubType.AtkBase then 
      titleStr = g_tr("titleBaseLife")
      strName = g_tr("crossCityBase", {name = player2.guild_name})
    end 

    item:getChildByName("Image_city"):setVisible(mailData.data.type == BattleSubType.AtkCity)
    item:getChildByName("Image_door"):setVisible(mailData.data.type == BattleSubType.AtkDoor)
    item:getChildByName("Image_base"):setVisible(mailData.data.type == BattleSubType.AtkBase)

    local dura_max, dura_new, dura_old
    if MailHelper:isKindOfAtk(mailData.type) then 
      item:getChildByName("Text_1"):setString(strName)
      if player2.oldDurability and player2.newDurability then 
        dura_max = player2.durabilityMax
        dura_new = player2.newDurability
        dura_old = player2.oldDurability
      end 
    else 
      item:getChildByName("Text_1"):setString(g_tr("myCity"))
      if player1.oldDurability and player1.newDurability then 
        dura_max = player1.durabilityMax
        dura_new = player1.newDurability
        dura_old = player1.oldDurability
      end     
    end 

    if dura_new and dura_max > 0 then 
      lbDamage:setString(""..(dura_old-dura_new))
      lbLeft:setString(""..dura_new.."/"..dura_max)
      LoadingBar:setPercent(100*dura_new/dura_max)
    end 

  elseif mailData.data.type == BattleSubType.AtkArmy then --攻打投石车
    titleStr = g_tr("titleCatapult")
    item = cc.CSLoader:createNode("mail_battle_content_18.csb") 
    local lbDoor = item:getChildByName("Text_1")
    local isAtk = MailHelper:isKindOfAtk(mailData.type)
    local isWin = MailHelper:isWin(mailData)
    item:getChildByName("Image_1"):setVisible(isWin)
    item:getChildByName("Image_2"):setVisible(not isWin)     
    local desc = ""
    local ownerName = ""
    if isAtk then 
      desc = isWin and g_tr("atkArmyAndWin") or g_tr("atkArmyAndLost") 
      ownerName = g_tr("catapultOwner", {name = player2.nick})
    else 
      desc = isWin and g_tr("defArmyAndWin") or g_tr("defArmyAndLost") 
      ownerName = g_tr("myCatapult")
    end      
    item:getChildByName("Text_4"):setString(desc) 
    lbDoor:setString(ownerName)
  end 

  if item then 
    local pos_y = 0 
    local nodeDura = ccui.Widget:create() 
       
    --标题
    local titleItem = cc.CSLoader:createNode("mail_battle_content_2_1.csb")
    titleItem:getChildByName("label_attack"):setString(titleStr)
    titleItem:getChildByName("label_defense"):setString("")
    pos_y = pos_y - titleItem:getContentSize().height 
    titleItem:setPosition(cc.p(0, pos_y))
    nodeDura:addChild(titleItem)

    --内容
    pos_y = pos_y - item:getContentSize().height 
    item:setPosition(cc.p(0, pos_y))
    nodeDura:addChild(item)

    local tmp = ccui.Widget:create()
    tmp:setContentSize(cc.size(titleItem:getContentSize().width, -pos_y))
    nodeDura:setPosition(cc.p(0, -pos_y))
    tmp:addChild(nodeDura) 

    listView:pushBackCustomItem(tmp) 
  end 

  if callback then 
    callback()
  end   
end 

--获得/损耗资源信息
function MailContentBattle:getResourceInfoItem(mailData, listView, callback)
  print("getResourceInfoItem")

  local resInfo = mailData.data.resource
  if nil == resInfo or MailHelper:isCrossFight(mailData) then 
    if callback then 
      callback()
    end     
    return 
  end 

  local total = 0
  for k, v in pairs(resInfo) do 
    total = total + v 
  end 

  if total == 0 then 
    if callback then 
      callback()
    end     
    return 
  end 
  
  local function getMatStr(val)
    local str 
    val = val or 0 
    if val == 0 then 
      str = "0"
    elseif val > 0 then 
      str = "+"..val
    else 
      str = ""..val 
    end 

    return str 
  end 

  local resItem = cc.CSLoader:createNode("mail_battle_content_1.csb")
  local rootNode = resItem:getChildByName("rewards")
  rootNode:getChildByName("text_01"):setString(g_tr("Resources"))
  rootNode:getChildByName("text_01_0"):setString(""..total)
  rootNode:getChildByName("num_1"):setString(getMatStr(resInfo.gold))
  rootNode:getChildByName("num_2"):setString(getMatStr(resInfo.food))
  rootNode:getChildByName("num_3"):setString(getMatStr(resInfo.wood))
  rootNode:getChildByName("num_4"):setString(getMatStr(resInfo.stone)) 
  rootNode:getChildByName("num_5"):setString(getMatStr(resInfo.iron))

  listView:pushBackCustomItem(resItem) 
  if callback then 
    callback()
  end 
end 

--掉落道具
function MailContentBattle:getDropItem(mail, listView, callback)
  print("getDropItem")
  if nil == mail.data.item or #mail.data.item == 0 then 
    if callback then 
      callback()
    end 
    return 
  end 

  local pos_y = 0 
  local nodeAward = ccui.Widget:create()

  --标题
  local titleItem = cc.CSLoader:createNode("mail_battle_content_2_1.csb")
  titleItem:getChildByName("label_attack"):setString(g_tr("gainAwards"))
  titleItem:getChildByName("label_defense"):setString("")
  pos_y = pos_y - titleItem:getContentSize().height 
  titleItem:setPosition(cc.p(0, pos_y))
  nodeAward:addChild(titleItem)

  local len = #mail.data.item
  local pageCount = math.ceil(len/6)
  if pageCount > 0 then 
    local widget2 = cc.CSLoader:createNode("mail_system_content_gift.csb")
    local newWidget, pic, idx, icon, itype, id, count  
    for i=1, pageCount do 
      newWidget = widget2:clone()
      for j=1, 6 do  
        pic = newWidget:getChildByName(string.format("pic_%d", j))
        idx = (i-1)*6 + j
        if idx <= len then 
          itype = mail.data.item[idx][1]
          id = mail.data.item[idx][2]
          count = mail.data.item[idx][3] or 1 
          icon = require("game.uilayer.common.DropItemView").new(itype, id, count)
          if icon then 
            icon:setScale(pic:getContentSize().width/icon:getContentSize().width)
            icon:setPosition(cc.p(pic:getContentSize().width/2, pic:getContentSize().height/2))
            icon:setNameVisible(true)
            pic:addChild(icon)
          end 
        else 
          pic:setVisible(false) 
        end 
      end 

      pos_y = pos_y - newWidget:getContentSize().height 
      newWidget:setPosition(cc.p(0, pos_y))
      nodeAward:addChild(newWidget) 
    end 
  end 

  local tmp = ccui.Widget:create()
  tmp:setContentSize(cc.size(item_w, -pos_y))
  nodeAward:setPosition(cc.p(0, -pos_y))
  tmp:addChild(nodeAward) 
  listView:pushBackCustomItem(tmp) 
  if callback then 
    callback()
  end 
end 

--战力损失
function MailContentBattle:getPowerLostItem(mailData, listView, callback)
  print("getPowerLostItem")

  if MailHelper:isAtkDoorAndBase(mailData) then 
    if callback then 
      callback()
    end     
    return 
  end 

  local pos_y = 0 
  local nodePower = ccui.Widget:create() 
  --标题
  local titleItem = cc.CSLoader:createNode("mail_battle_content_2_1.csb")
  titleItem:getChildByName("label_attack"):setString(g_tr("powerReport"))
  titleItem:getChildByName("label_defense"):setString("")
  pos_y = pos_y - titleItem:getContentSize().height 
  titleItem:setPosition(cc.p(0, pos_y))
  nodePower:addChild(titleItem)


  local item = cc.CSLoader:createNode("mail_battle_content_10.csb") 
  item:getChildByName("Text_1"):setString(g_tr("powerLost"))
  item:getChildByName("Text_3"):setString(g_tr("powerLost"))
  local panel_1 = item:getChildByName("Panel_1")
  panel_1:getChildByName("Text_5"):setString(g_tr("trapLost"))
  panel_1:getChildByName("Text_7"):setString(g_tr("trapLost"))
  local lbLost = {item:getChildByName("Text_2"), item:getChildByName("Text_4"), 
                    panel_1:getChildByName("Text_6"), panel_1:getChildByName("Text_8")}
  local imgArrow = {item:getChildByName("Image_j1"), item:getChildByName("Imagej2"), 
                    panel_1:getChildByName("Image_j3"), panel_1:getChildByName("Imagej4")}
  local valLost = { mailData.data.player1.power_lost, mailData.data.player2.power_lost, 
                    mailData.data.player1.trap_lost or 0, mailData.data.player2.trap_lost or 0}

  local isCrossFight = MailHelper:isCrossFight(mailData)
  panel_1:setVisible(not isCrossFight)

  for i = 1, 4 do 
    lbLost[i]:setString(""..valLost[i])
    if valLost[i] == 0 then 
      lbLost[i]:setTextColor(cc.c3b(255, 255, 255))
    end 
    imgArrow[i]:setVisible(valLost[i] > 0)
    imgArrow[i]:setPositionX(lbLost[i]:getPositionX() + lbLost[i]:getContentSize().width + 5)
  end 

  pos_y = pos_y - item:getContentSize().height 
  item:setPosition(cc.p(0, pos_y)) 
  nodePower:addChild(item) 

  local tmp = ccui.Widget:create()
  tmp:setContentSize(cc.size(item:getContentSize().width, -pos_y))
  nodePower:setPosition(cc.p(0, -pos_y))
  tmp:addChild(nodePower) 

  listView:pushBackCustomItem(tmp) 
  if callback then 
    callback()
  end  
end 

--神武将技能
function MailContentBattle:getGodSkillItem(mailData, listView, callback)
  print("getGodSkillItem")

  if MailHelper:isAtkDoorAndBase(mailData) then 
    if callback then 
      callback()
    end     
    return 
  end 

  local skillAttr1 = mailData.data.player1.godGeneralSkillArr 
  local skillAttr2 = mailData.data.player2.godGeneralSkillArr 
  local num1 = skillAttr1 and #skillAttr1 or 0 
  local num2 = skillAttr2 and #skillAttr2 or 0 
  if num1 == 0 and num2 == 0 then
    if callback then 
      callback()
    end      
    return 
  end 

  --标题
  local titleItem = cc.CSLoader:createNode("mail_battle_content_2_1.csb")
  titleItem:getChildByName("label_attack"):setString(g_tr("godGenSkill"))
  titleItem:getChildByName("label_defense"):setString("")
  listView:pushBackCustomItem(titleItem) 

  --玩家为单位统计各个神武将技能信息
  local function getPlayerSkill(player)
    local result = {}
    local skillAttr = player.godGeneralSkillArr 
    if nil == skillAttr then 
      return result 
    end 

    local tmp = {}
    for k, v in pairs(skillAttr) do 
      if nil == tmp[v.pid] then 
        tmp[v.pid] = {}
      end 
      table.insert(tmp[v.pid], v)
    end 

    for i, p in pairs(tmp) do 
      table.insert(result, p)
    end     
    return result 
  end 

  local function initOneSkill(node, info, mailData) 
    local title = node:getChildByName("Panel_title") 
    if not title:isVisible() then 
      node:getChildByName("Panel_info"):setPositionY(15)
    end 

    local panel = node:getChildByName("Panel_info") 
    local pic = panel:getChildByName("pic") 
    local lbName = panel:getChildByName("Text_name") 
    local lbDesc = panel:getChildByName("Text_desc") 
    lbName:setString("") 
    lbDesc:setString("") 

    if nil == info then return end 

    if info.gid then       
      MailHelper:loadGeneralSoldierIcon(pic, g_Consts.DropType.General, info.gid*100+1, info.star) 
      local data = MailHelper:getGodGeneralSkilDesc(info, mailData)
      lbName:setString(data.genName) 

      lbDesc:setTextAreaSize(cc.size(260, 0)) 
      lbDesc:setString(data.desc)
      g_gameTools.createRichText(lbDesc, data.desc)
    end 
  end 

  local attrTbl_1 = getPlayerSkill(mailData.data.player1) 
  local attrTbl_2 = getPlayerSkill(mailData.data.player2) 
  local playerCount = math.max(#attrTbl_1, #attrTbl_2)

  if playerCount == 1 then --单个玩家
    local item = cc.CSLoader:createNode("mail_battle_content_7.csb")
    local count1 = attrTbl_1[1] and #attrTbl_1[1] or 0 
    local count2 = attrTbl_2[1] and #attrTbl_2[1] or 0 
    local itemCount = math.max(count1, count2)

    for i = 1, itemCount do 
      local itemNew = item:clone()
      local node1 = itemNew:getChildByName("Panel_1")
      node1:setVisible(i <= count1)
      node1:getChildByName("Panel_title"):setVisible(i == 1)
      if node1:isVisible() then 
        initOneSkill(node1, attrTbl_1[1][i], mailData) 
      end 

      if i <= count2 then 
        local node2 = node1:clone() 
        node2:setVisible(true) 
        node2:setPosition(cc.p(node1:getPositionX()+node1:getContentSize().width, node1:getPositionY()))
        itemNew:addChild(node2) 
        initOneSkill(node2, attrTbl_2[1][i], mailData) 
      end 
      listView:pushBackCustomItem(itemNew)     
    end 

  elseif playerCount > 1 then --多个玩家
    local myPlayerId = g_PlayerMode.GetData().id 
    local item = cc.CSLoader:createNode("mail_battle_content_14.csb") 
    local function onTouchDetail(sender)
      if nil == sender then return end 

      local tag = sender:getTag() 
      local playerInfo 
      if tag >= 200 then --player2
        playerInfo = attrTbl_2[tag-200]
      else  
        playerInfo = attrTbl_1[tag-100]
      end 
      --show pop up  
      local pop = require("game.uilayer.mail.MailContentBattleGodSkillDetail").new(playerInfo, mailData) 
      g_sceneManager.addNodeForUI(pop) 
    end 

    local function initOnePlayer(panel, player, tagId, isAtk)
      if nil == panel then return end 

      panel:setVisible(nil ~= player and nil ~= player[1])
      if panel:isVisible() then 
        --进攻/防守
        local title = panel:getChildByName("Panel_title")
        if title:isVisible() then 
          local str1 = isAtk and "attack" or "defense"
          title:getChildByName("Text_title"):setString(g_tr(str1)) 
        end 

        local Panel_info = panel:getChildByName("Panel_info") 
        local nick, avatar = MailHelper:getPlayerNickAvatar(mailData, player[1].pid)
        MailHelper:loadPlayerIcon(Panel_info:getChildByName("pic_general"), avatar or 1)
        Panel_info:getChildByName("Text_name"):setString(nick)
        lbIsMe = Panel_info:getChildByName("img_tip")
        lbIsMe:setVisible(player[1].pid == myPlayerId)
        if lbIsMe:isVisible() then 
          lbIsMe:enableOutline(cc.c4b(0, 0, 0,255),2)
          lbIsMe:setString(g_tr("MasterTitle"))
        end 

        --显示玩家包含的多个武将名字
        local lbDesc = Panel_info:getChildByName("Text_desc")
        local str = ""
        for i=1, #player do 
          local genBase = g_data.general[player[i].gid*100+1]
          if genBase then 
            if i <= 6 then 
              str = str == "" and g_tr(genBase.general_name) or str..("、"..g_tr(genBase.general_name))
            else 
              str = str .. "..."
              break 
            end 
          end 
        end 
        if str ~= "" then 
          str = "|<#253,208,110#>" .. str .. "|" .. g_tr("useGodSkill")
        end 
        lbDesc:setTextAreaSize(cc.size(400, 0)) 
        lbDesc:setString(str)
        g_gameTools.createRichText(lbDesc, str)

        --查看详情按钮
        Panel_info:getChildByName("Text_22"):setString(g_tr("seeDetail"))
        local btnDetail = Panel_info:getChildByName("Button_1") 
        btnDetail:setTag(tagId)
        btnDetail:addClickEventListener(onTouchDetail)        
      end 
    end 

    local isAtk = MailHelper:isKindOfAtk(mailData.type)
    for i = 1, playerCount do 
      local itemNew = item:clone()
      local panel_1 = itemNew:getChildByName("Panel_1")
      local panel_2       
      if attrTbl_2[i] then 
        local x, y = panel_1:getPosition()
        panel_2 = panel_1:clone()
        panel_2:setPosition(cc.p(x + panel_1:getContentSize().width, y))
        panel_1:getParent():addChild(panel_2)
      end 
      --显示进攻防守
      panel_1:getChildByName("Panel_title"):setVisible(i == 1)
      if panel_2 then 
        panel_2:getChildByName("Panel_title"):setVisible(i == 1)
      end 
      initOnePlayer(panel_1, attrTbl_1[i], 100 + i, isAtk) 
      initOnePlayer(panel_2, attrTbl_2[i], 200 + i, not isAtk)
      listView:pushBackCustomItem(itemNew) 
    end 
  end 

  if callback then 
    callback() 
  end 
end 


--武将详情
local function getUnitInfo(unit1, unit2)

  local tbl1 = {}
  local tbl2 = {}

  if unit1 then 
    for key, item in pairs(unit1) do 
      if key == "tower" then --箭塔
        item.type = "tower"
        table.insert(tbl1, item)

      elseif key == "trap" then --陷阱
        for k, v in pairs(item) do 
          v.type = "trap"
          table.insert(tbl1, v)
        end 
      else 
        item.type = "general"
        item.gen_id = 100*tonumber(item.general_id)+1
        item.gen_starlv = item.general_star 
        table.insert(tbl1, 1, item)
      end 
    end 
  end 

  if unit2 then 
    for key, item in pairs(unit2) do 
      if key == "tower" then --箭塔
        item.type = "tower"
        table.insert(tbl2, item)

      elseif key == "trap" then --陷阱
        for k, v in pairs(item) do 
          v.type = "trap"
          table.insert(tbl2, v)
        end 
      else 
        item.type = "general"
        item.gen_id = 100*tonumber(item.general_id)+1
        item.gen_starlv = item.general_star 
        table.insert(tbl2, 1, item)
      end 
    end 
  end 


  local itemNew, node1, node2 
  local pos_y = 0 
  local unitCount = math.max(#tbl1, #tbl2) 
  local troopItem = cc.CSLoader:createNode("mail_battle_content_5.csb")
  troopItem:retain()
  local itemSize = troopItem:getContentSize() 

  local node = ccui.Widget:create()
  for i=1, unitCount do 
    itemNew = troopItem:clone()
    node1 = itemNew:getChildByName("army_1")
    node2 = itemNew:getChildByName("army_2") 

    if i <= #tbl1 then 
      local pic_gen = node1:getChildByName("pic_general_1")
      local name_gen = node1:getChildByName("name_general")
      local pic_soldier = node1:getChildByName("pic_general_2")
      local pic_level = node1:getChildByName("Image_2")
      local name_soldier = node1:getChildByName("name_general_0")
      local lbRecall = node1:getChildByName("name_x1")
      node1:getChildByName("label_1"):setString(g_tr("survive%{val}", {val=tbl1[i].live_num}))
      node1:getChildByName("label_2"):setString(g_tr("damage%{val}", {val=tbl1[i].injure_num}))
      node1:getChildByName("label_3"):setString(g_tr("kill%{val}", {val=tbl1[i].kill_num}))
      node1:getChildByName("label_4"):setString(g_tr("killed%{val}", {val=tbl1[i].killed_num}))
      name_gen:setString("")
      name_soldier:setString("")
      lbRecall:setString("")

      pic_level:setVisible(false) 

      if tbl1[i].type == "general" then 
        print("tbl1[i].gen_id, soldier_id", tbl1[i].gen_id, tbl1[i].soldier_id)
        MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, tbl1[i].gen_id, tbl1[i].gen_starlv)
        local item_gen = g_data.general[tbl1[i].gen_id]
        if item_gen then 
          name_gen:setString(g_tr(item_gen.general_name))
        end 

        local item_soldier = g_data.soldier[tbl1[i].soldier_id]
        if item_soldier then 
          MailHelper:loadGeneralSoldierIcon(pic_soldier, g_Consts.DropType.Soldier, tbl1[i].soldier_id) 
          name_soldier:setString(g_tr(item_soldier.soldier_name))          
        end 
        MailHelper:showSoldierAttrTips(pic_soldier, tbl1[i].soldier_id, tbl1[i].attack, tbl1[i].defend, tbl1[i].life)
        
        if tbl1[i].revive_num and tonumber(tbl1[i].revive_num) > 0 then 
          lbRecall:setString(g_tr("recallNum", {num=tbl1[i].revive_num}))
        end         
      else 
        pic_soldier:setVisible(false) 
        name_soldier:setVisible(false)

        if tbl1[i].type == "trap" and g_data.trap[tbl1[i].soldier_id] then 
          MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.Trap, tbl1[i].soldier_id)
          name_gen:setString(g_tr(g_data.trap[tbl1[i].soldier_id].trap_name))

        elseif tbl1[i].type == "tower" and g_data.map_element[201] then 
          MailHelper:loadResIcon(pic_gen, g_data.map_element[201].img_mail)
          name_gen:setString(g_tr(g_data.map_element[201].name))          
        end 
      end 

    else 
      node1:setVisible(false)
    end 

    if i <= #tbl2 then 
      local pic_gen = node2:getChildByName("pic_general_1")
      local name_gen = node2:getChildByName("name_general")
      local pic_soldier = node2:getChildByName("pic_general_2")
      local pic_level = node2:getChildByName("Image_2")
      local name_soldier = node2:getChildByName("name_general_0")
      local lbRecall = node2:getChildByName("name_x1")

      node2:getChildByName("label_1"):setString(g_tr("survive%{val}", {val=tbl2[i].live_num}))
      node2:getChildByName("label_2"):setString(g_tr("damage%{val}", {val=tbl2[i].injure_num}))
      node2:getChildByName("label_3"):setString(g_tr("kill%{val}", {val=tbl2[i].kill_num}))
      node2:getChildByName("label_4"):setString(g_tr("killed%{val}", {val=tbl2[i].killed_num}))
      name_gen:setString("")
      name_soldier:setString("")
      lbRecall:setString("")

      pic_level:setVisible(false) 
      if tbl2[i].type == "general" then 
        print("tbl2[i].gen_id", tbl2[i].gen_id)
        MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, tbl2[i].gen_id, tbl2[i].gen_starlv)
        local item_gen = g_data.general[tbl2[i].gen_id]
        if item_gen then 
          name_gen:setString(g_tr(item_gen.general_name))
        end 
        
        local item_soldier = g_data.soldier[tbl2[i].soldier_id]
        if item_soldier then 
          MailHelper:loadGeneralSoldierIcon(pic_soldier, g_Consts.DropType.Soldier, tbl2[i].soldier_id)   
          name_soldier:setString(g_tr(item_soldier.soldier_name))
        else 
          pic_soldier:setVisible(false)
          name_soldier:setVisible(false)
        end 
        MailHelper:showSoldierAttrTips(pic_soldier, tbl2[i].soldier_id, tbl2[i].attack, tbl2[i].defend, tbl2[i].life)

        if tbl2[i].revive_num and tonumber(tbl2[i].revive_num) > 0 then 
          lbRecall:setString(g_tr("recallNum", {num=tbl2[i].revive_num}))
        end 
      else 
        pic_soldier:setVisible(false)
        name_soldier:setVisible(false)

        if tbl2[i].type == "trap" and g_data.trap[tbl2[i].soldier_id] then 
          MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.Trap, tbl2[i].soldier_id) 
          name_gen:setString(g_tr(g_data.trap[tbl2[i].soldier_id].trap_name))          

        elseif tbl2[i].type == "tower" and g_data.map_element[201] then 
          MailHelper:loadResIcon(pic_gen, g_data.map_element[201].img_mail)
          name_gen:setString(g_tr(g_data.map_element[201].name))    
        end 
      end 

    else 
      node2:setVisible(false)
    end 

    pos_y = pos_y - itemSize.height
    itemNew:setPosition(cc.p(0, pos_y))
    node:addChild(itemNew)
  end 
  troopItem:release()

  return node, itemSize.width, -pos_y  
end 

function MailContentBattle:getTroopInfoItem(mailData, listView, callback)
  print("getTroopInfoItem")

  if MailHelper:isAtkDoorAndBase(mailData) then 
    if callback then 
      callback()
    end     
    return 
  end

  --标题
  local titleItem = cc.CSLoader:createNode("mail_battle_content_2_1.csb")
  local isAtk = MailHelper:isKindOfAtk(mailData.type)
  local str1 = isAtk and "attack" or "defense"
  local str2 = isAtk and "defense" or "attack"
  titleItem:getChildByName("label_attack"):setString(g_tr(str1))
  titleItem:getChildByName("label_defense"):setString(g_tr(str2))

  listView:pushBackCustomItem(titleItem) 
  --任何一方包含多个玩家时则显示玩家大概信息, 否则直接罗列玩家列表
  local function onTouchDetail(sender)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

    if nil == sender then return end 

    local tag = sender:getTag() 
    local playerInfo 
    if tag >= 200 then 
      playerInfo = mailData.data.player2.players[tag-200]
    else  
      playerInfo = mailData.data.player1.players[tag-100]
    end 

    --show pop up  
    local pop = require("game.uilayer.mail.MailContentBattlePlayerDetail").new(mailData.data.type, playerInfo) 
    g_sceneManager.addNodeForUI(pop) 
  end 

  local myPlayers = mailData.data.player1.players
  local hisPlayer = mailData.data.player2.players
  local itemCount = math.max(#myPlayers, #hisPlayer)

  if itemCount == 1 then --双方都是单个玩家
    local unit1 = myPlayers[1] and myPlayers[1].unit or nil 
    local unit2 = hisPlayer[1] and hisPlayer[1].unit or nil 
    local item, w, h = getUnitInfo(unit1, unit2)

    local tmp = ccui.Widget:create()
    tmp:setContentSize(cc.size(w, h))
    item:setPosition(cc.p(0, h))
    tmp:addChild(item) 
    listView:pushBackCustomItem(tmp) 

    if callback then 
      callback()
    end 
    return 
  end 


  --分帧加载
  local index = 1 
  local function loadOnePlayer()
    if nil == layerObj then return end 

    local myPlayerId = g_PlayerMode.GetData().id 
    local itemNew = cc.CSLoader:createNode("mail_battle_content_4.csb")
    local node1 = itemNew:getChildByName("army_1")
    local node2 = itemNew:getChildByName("army_2")
    if index <= #myPlayers then 
      MailHelper:loadPlayerIcon(node1:getChildByName("pic_general"), myPlayers[index].avatar)
      node1:getChildByName("name_general"):setString(myPlayers[index].nick)
      lbIsMe = node1:getChildByName("img_tip")
      lbIsMe:setVisible(myPlayers[index].player_id == myPlayerId)
      if lbIsMe:isVisible() then 
        lbIsMe:enableOutline(cc.c4b(0, 0, 0,255),2)
        lbIsMe:setString(g_tr("MasterTitle"))
      end 
      --分别汇总相应属性
      local attrVal = {0, 0, 0, 0}
      for k, v in pairs(myPlayers[index].unit) do 
        if v.live_num then 
          attrVal[1] = attrVal[1] + v.live_num --存活
        end 
        if v.injure_num then 
          attrVal[2] = attrVal[2] + v.injure_num --受伤
        end 
        if v.kill_num then 
          attrVal[3] = attrVal[3] + v.kill_num  --击杀
        end 
        if v.killed_num then 
          attrVal[4] = attrVal[4] + v.killed_num  --死亡
        end 

        if k == "trap" then --陷阱击杀要考虑进去
          for m, tmp in pairs(v) do 
            if tmp.kill_num then 
              attrVal[3] = attrVal[3] + tmp.kill_num  --击杀
            end             
          end 
        end         
      end 
      node1:getChildByName("label_1"):setString(g_tr("survive%{val}", {val = attrVal[1]}))
      node1:getChildByName("label_2"):setString(g_tr("damage%{val}", {val = attrVal[2]}))
      node1:getChildByName("label_3"):setString(g_tr("kill%{val}", {val = attrVal[3]}))
      node1:getChildByName("label_4"):setString(g_tr("killed%{val}", {val = attrVal[4]}))
      node1:getChildByName("Text_22"):setString(g_tr("seeDetail"))
      local btn = node1:getChildByName("Button_1")
      btn:setTag(100 + index)
      btn:addClickEventListener(onTouchDetail)
    else 
      node1:setVisible(false)
    end 

    if index <= #hisPlayer then 
      MailHelper:loadPlayerIcon(node2:getChildByName("pic_general"), hisPlayer[index].avatar)
      node2:getChildByName("name_general"):setString(hisPlayer[index].nick)
      local lbIsMe = node2:getChildByName("img_tip")
      lbIsMe:setVisible(hisPlayer[index].player_id == myPlayerId)
      if lbIsMe:isVisible() then 
        lbIsMe:enableOutline(cc.c4b(0, 0, 0,255),2)
        lbIsMe:setString(g_tr("MasterTitle"))
      end 

      --分别汇总相应属性
      local attrVal = {0, 0, 0, 0}
      for k, v in pairs(hisPlayer[index].unit) do 
        if v.live_num then 
          attrVal[1] = attrVal[1] + v.live_num --存活
        end 
        if v.injure_num then 
          attrVal[2] = attrVal[2] + v.injure_num --受伤
        end 
        if v.kill_num then 
          attrVal[3] = attrVal[3] + v.kill_num  --击杀
        end 
        if v.killed_num then 
          attrVal[4] = attrVal[4] + v.killed_num  --死亡
        end 

        if k == "trap" then --陷阱击杀要考虑进去
          for m, tmp in pairs(v) do 
            if tmp.kill_num then 
              attrVal[3] = attrVal[3] + tmp.kill_num  --击杀
            end             
          end 
        end 
      end 
      node2:getChildByName("label_1"):setString(g_tr("survive%{val}", {val = attrVal[1]}))
      node2:getChildByName("label_2"):setString(g_tr("damage%{val}", {val = attrVal[2]}))
      node2:getChildByName("label_3"):setString(g_tr("kill%{val}", {val = attrVal[3]}))
      node2:getChildByName("label_4"):setString(g_tr("killed%{val}", {val = attrVal[4]}))
      node2:getChildByName("Text_22"):setString(g_tr("seeDetail"))
      local btn = node2:getChildByName("Button_1")
      btn:setTag(200 + index)
      btn:addClickEventListener(onTouchDetail)

    else 
      node2:setVisible(false)
    end 
    listView:pushBackCustomItem(itemNew) 
  end 

  local function frameLoadItems()
    loadOnePlayer()
    index = index + 1 

    if index <= itemCount then 
      -- self:performWithDelay(frameLoadItems, 0)
      -- g_autoCallback.addCocosList(frameLoadItems , 0.15)
      startTimer(frameLoadItems , 0.15)
    else 
      if callback then 
        callback()
      end       
    end 
  end 
  -- self:performWithDelay(frameLoadItems, 0)
  -- g_autoCallback.addCocosList(frameLoadItems , 0.15)
  startTimer(frameLoadItems , 0.15)
end 


--损害信息 
function MailContentBattle:getDamageInfoItem(mailData, listView, callback)
  print("getDamageInfoItem")
  if nil == layerObj then return end 

  if MailHelper:isAtkDoorAndBase(mailData) then 
    if callback then 
      callback()
    end     
    return 
  end

  local myPlayers = mailData.data.player1.players
  local hisPlayer = mailData.data.player2.players
  if nil == myPlayers or nil == hisPlayer or (#myPlayers == 0 and #hisPlayer == 0) then 
    if callback then 
      callback()
    end 
    return 
  end 

  local maxPlayerDoDamage = 0.1 --单个玩家造成伤害上限
  local maxPlayerSufferDamage = 0.1 --单个玩家承受伤害上限
  local maxSoldierDoDamage = 0.1 --单个士兵造成伤害上限
  local maxSoldierSufferDamage = 0.1 --单个士兵承受伤害上限

  local tmp = {myPlayers, hisPlayer}
  for t, pp in pairs(tmp) do 
    for m, player in pairs(pp) do 
      local totalDoDamage = 0 
      local totalSufferDamage = 0 
      local unit = MailHelper:getDamageUnit(player.unit) 
      for k, v in pairs(unit) do 
        totalDoDamage = totalDoDamage + v.doDamage 
        totalSufferDamage = totalSufferDamage + v.takeDamage 

        if v.doDamage > maxSoldierDoDamage then 
          maxSoldierDoDamage = v.doDamage 
        end 

        if v.takeDamage > maxSoldierSufferDamage then 
          maxSoldierSufferDamage = v.takeDamage 
        end 
      end 
      if totalDoDamage > maxPlayerDoDamage then 
        maxPlayerDoDamage = totalDoDamage 
      end 
      if totalSufferDamage > maxPlayerSufferDamage then 
        maxPlayerSufferDamage = totalSufferDamage 
      end 
    end 
  end 

  --标题
  local titleItem = cc.CSLoader:createNode("mail_battle_content_11.csb")
  local isAtk = MailHelper:isKindOfAtk(mailData.type)
  local str1 = isAtk and "attack" or "defense"
  local str2 = isAtk and "defense" or "attack"
  titleItem:getChildByName("text_01"):setString(g_tr(str1))
  titleItem:getChildByName("text_04"):setString(g_tr(str2))
  titleItem:getChildByName("text_02"):setString(g_tr("makeDamage"))
  titleItem:getChildByName("text_05"):setString(g_tr("makeDamage"))
  titleItem:getChildByName("text_03"):setString(g_tr("sufferDamage"))
  titleItem:getChildByName("text_06"):setString(g_tr("sufferDamage"))  
  listView:pushBackCustomItem(titleItem) 

  local playerCount = math.max(#myPlayers, #hisPlayer) 
  if playerCount == 1 then --单个玩家时

    local function initOneItem(node, info, idx)
      if nil == info then 
        node:setVisible(false)
        return 
      end 
      --国王战NPC时对方显示默认士兵头像
      local soldierId = info.soldier_id
      if idx == 2 and (mailData.data.type == BattleSubType.King_PVE or mailData.data.type == BattleSubType.King_NPC) then 
        soldierId = 20019 
      end 
      local item = g_data.soldier[soldierId]
      if item then 
        local pic_soldier = node:getChildByName("Image_2")
        MailHelper:loadGeneralSoldierIcon(pic_soldier, g_Consts.DropType.Soldier, soldierId)
        local gen = g_data.general[info.general_id*100+1]
        local str = gen and g_tr(gen.general_name) or ""
        node:getChildByName("Text_name1"):setString(str .. g_tr(item.type_name))  
        node:getChildByName("Image_3"):setVisible(false)
      else 
        node:getChildByName("Text_name1"):setString("")
      end 
      node:getChildByName("Text_1"):setString(""..math.floor(info.doDamage))
      node:getChildByName("Text_2"):setString(""..math.floor(info.takeDamage))
      node:getChildByName("LoadingBar_1"):setPercent(math.min(100, 100*info.doDamage/maxSoldierDoDamage))
      node:getChildByName("LoadingBar_2"):setPercent(math.min(100, 100*info.takeDamage/maxSoldierSufferDamage))
    end 

    local unit1 = {}
    local unit2 = {}
    if myPlayers[1] and myPlayers[1].unit then 
      unit1 = MailHelper:getDamageUnit(myPlayers[1].unit)  
    end 
    if hisPlayer[1] and hisPlayer[1].unit then 
      unit2 = MailHelper:getDamageUnit(hisPlayer[1].unit)  
    end  

    local unitItemCount = math.max(#unit1, #unit2)
    local item = cc.CSLoader:createNode("mail_battle_content_12.csb") 
    for i = 1, unitItemCount do 
      local itemNew = item:clone()
      local node1 = itemNew:getChildByName("Panel_1")
      local node2 = itemNew:getChildByName("Panel_2")
      initOneItem(node1, unit1[i], 1) 
      initOneItem(node2, unit2[i], 2) 

      listView:pushBackCustomItem(itemNew) 
    end 

  elseif playerCount > 1 then  
    local myPlayerId = g_PlayerMode.GetData().id 
    local item = cc.CSLoader:createNode("mail_battle_content_13.csb") 
    local function onTouchDetail(sender)
      if nil == sender then return end 

      local tag = sender:getTag() 
      local playerInfo 
      if tag >= 200 then --player2
        playerInfo = mailData.data.player2.players[tag-200]
      else  
        playerInfo = mailData.data.player1.players[tag-100]
      end 

      --show pop up  
      local pop = require("game.uilayer.mail.MailContentBattleDamageDetail").new(mailData.data.type, playerInfo, maxSoldierDoDamage, maxSoldierSufferDamage) 
      g_sceneManager.addNodeForUI(pop) 
    end 

    local function initOnePlayer(panel, player, tagId)
      if nil == panel then return end 

      panel:setVisible(nil ~= player)
      if panel:isVisible() then 
        local Panel_info = panel:getChildByName("Panel_info") 
        MailHelper:loadPlayerIcon(Panel_info:getChildByName("pic_general"), player.avatar)
        Panel_info:getChildByName("Text_name"):setString(player.nick)
        lbIsMe = Panel_info:getChildByName("img_tip")
        lbIsMe:setVisible(player.player_id == myPlayerId)
        if lbIsMe:isVisible() then 
          lbIsMe:enableOutline(cc.c4b(0, 0, 0,255),2)
          lbIsMe:setString(g_tr("MasterTitle"))
        end 

        local totalDoDamage = 0 
        local totalSufferDamage = 0
        if player.unit then
          local unit = MailHelper:getDamageUnit(player.unit) 
          for k, v in pairs(unit) do 
            totalDoDamage = totalDoDamage + v.doDamage
            totalSufferDamage = totalSufferDamage + v.takeDamage 
          end 
        end 
        Panel_info:getChildByName("Text_4"):setString(""..math.floor(totalDoDamage))
        Panel_info:getChildByName("Text_5"):setString(""..math.floor(totalSufferDamage))
        Panel_info:getChildByName("LoadingBar_1"):setPercent(math.min(100, 100*totalDoDamage/maxPlayerDoDamage))
        Panel_info:getChildByName("LoadingBar_2"):setPercent(math.min(100, 100*totalSufferDamage/maxPlayerSufferDamage))        

        Panel_info:getChildByName("Text_22"):setString(g_tr("seeDetail"))
        local btnDetail = Panel_info:getChildByName("Button_1") 
        btnDetail:setTag(tagId)
        btnDetail:addClickEventListener(onTouchDetail)        
      end 
    end 

    for i = 1, playerCount do 
      local itemNew = item:clone()
      local panel_1 = itemNew:getChildByName("Panel_1")
      local panel_2       
      if hisPlayer[i] then 
        local x, y = panel_1:getPosition()
        panel_2 = panel_1:clone()
        panel_2:setPosition(cc.p(x + panel_1:getContentSize().width, y))
        panel_1:getParent():addChild(panel_2)
      end 
      initOnePlayer(panel_1, myPlayers[i], 100 + i) 
      initOnePlayer(panel_2, hisPlayer[i], 200 + i)
      listView:pushBackCustomItem(itemNew) 
    end 
  end 

  if callback then 
    callback()
  end   
end 

--部队属性
function MailContentBattle:getTroopAttrItem(mailData, listView, callback)

  if MailHelper:isCrossFight(mailData) then --跨服战不显示部队属性
    if callback then 
      callback()
    end     
    return 
  end 

  local isAtk = MailHelper:isKindOfAtk(mailData.type)
  local str1 = isAtk and "mailAttackPro" or "mailDefendPro"
  local str2 = isAtk and "mailDefendPro" or "mailAttackPro"
  
  local attrItem = cc.CSLoader:createNode("mail_battle_content_3.csb")
  local rootNode = attrItem:getChildByName("panel_content")
  local kindName = {"infantry", "cavalry", "archer", "vehicles"}
  local attrName = {"%{name}attack", "%{name}defense", "%{name}Hp", "%{name}damageReduce"}
  rootNode:getChildByName("label_attack"):setString(g_tr(str1))
  rootNode:getChildByName("label_defense"):setString(g_tr(str2))
  local attrLeft = rootNode:getChildByName("statistics_left") 
  local attrRight = rootNode:getChildByName("statistics_right") 
  local bufData1 = mailData.data.player1.buff 
  local bufData2 = mailData.data.player2.buff 
  local buf1 = {  bufData1.infantry_atk_plus, bufData1.infantry_def_plus, bufData1.infantry_life_plus, 0,
                  bufData1.cavalry_atk_plus, bufData1.cavalry_def_plus, bufData1.cavalry_life_plus, 0,
                  bufData1.archer_atk_plus, bufData1.archer_def_plus, bufData1.archer_life_plus, 0,
                  bufData1.siege_atk_plus, bufData1.siege_def_plus, bufData1.siege_life_plus, 0,
                }
  local buf2 = {  bufData2.infantry_atk_plus, bufData2.infantry_def_plus, bufData2.infantry_life_plus, 0,
                  bufData2.cavalry_atk_plus, bufData2.cavalry_def_plus, bufData2.cavalry_life_plus, 0,
                  bufData2.archer_atk_plus, bufData2.archer_def_plus, bufData2.archer_life_plus, 0,
                  bufData2.siege_atk_plus, bufData2.siege_def_plus, bufData2.siege_life_plus, 0,
                }
  local str
  for i=1, 4 do 
    for j=1, 3 do --减伤不显示
      str = g_tr(attrName[j], {name=g_tr(kindName[i])})
      attrLeft:getChildByName(string.format("label_%d", (i-1)*4 + j)):setString(str)
      attrRight:getChildByName(string.format("label_%d", (i-1)*4 + j)):setString(str)
      attrLeft:getChildByName(string.format("num_%d", (i-1)*4 + j)):setString(string.format("+%d%%", 100*(buf1[(i-1)*4+j] or 0)))
      attrRight:getChildByName(string.format("num_%d", (i-1)*4 + j)):setString(string.format("+%d%%", 100*(buf2[(i-1)*4+j] or 0)))
    end 
  end 

  attrLeft:getChildByName("label_17"):setString(g_tr("stoneDamageToInfantry"))
  attrRight:getChildByName("label_17"):setString(g_tr("stoneDamageToInfantry"))
  attrLeft:getChildByName("label_18"):setString(g_tr("woodDamageToCavalry"))
  attrRight:getChildByName("label_18"):setString(g_tr("woodDamageToCavalry"))
  attrLeft:getChildByName("label_19"):setString(g_tr("knifeDamageToArcher"))
  attrRight:getChildByName("label_19"):setString(g_tr("knifeDamageToArcher"))
  attrLeft:getChildByName("num_17"):setString(string.format("+%d%%", 100*(bufData1.rock_atk_plus or 0)))
  attrRight:getChildByName("num_17"):setString(string.format("+%d%%", 100*(bufData2.rock_atk_plus or 0)))
  attrLeft:getChildByName("num_18"):setString(string.format("+%d%%", 100*(bufData1.wood_atk_plus or 0)))
  attrRight:getChildByName("num_18"):setString(string.format("+%d%%", 100*(bufData2.wood_atk_plus or 0)))
  attrLeft:getChildByName("num_19"):setString(string.format("+%d%%", 100*(bufData1.arrow_atk_plus or 0)))
  attrRight:getChildByName("num_19"):setString(string.format("+%d%%", 100*(bufData2.arrow_atk_plus or 0)))

  --资源战/城战buff加成
  local buf3 = {bufData1.citybattle_infantry_atk_plus, bufData1.citybattle_infantry_def_plus, bufData1.citybattle_infantry_life_plus,
                bufData1.citybattle_cavalry_atk_plus, bufData1.citybattle_cavalry_def_plus, bufData1.citybattle_cavalry_life_plus, 
                bufData1.citybattle_archer_atk_plus, bufData1.citybattle_archer_def_plus, bufData1.citybattle_archer_life_plus, 
                bufData1.citybattle_siege_atk_plus, bufData1.citybattle_siege_def_plus, bufData1.citybattle_siege_life_plus}

  local buf4 = {bufData2.citybattle_infantry_atk_plus, bufData2.citybattle_infantry_def_plus, bufData2.citybattle_infantry_life_plus,
                bufData2.citybattle_cavalry_atk_plus,  bufData2.citybattle_cavalry_def_plus,  bufData2.citybattle_cavalry_life_plus, 
                bufData2.citybattle_archer_atk_plus,   bufData2.citybattle_archer_def_plus,   bufData2.citybattle_archer_life_plus, 
                bufData2.citybattle_siege_atk_plus,    bufData2.citybattle_siege_def_plus,    bufData2.citybattle_siege_life_plus}
  for i=1, 4 do 
    for j=1, 3 do 
      str = g_tr("cityBattle") .. g_tr(attrName[j], {name=g_tr(kindName[i])})
      attrLeft:getChildByName(string.format("label_%d", 19+(i-1)*3 + j)):setString(str)
      attrRight:getChildByName(string.format("label_%d", 19+(i-1)*3 + j)):setString(str)
      attrLeft:getChildByName(string.format("num_%d", 19+(i-1)*3 + j)):setString(string.format("+%d%%", 100*(buf3[(i-1)*3+j] or 0)))
      attrRight:getChildByName(string.format("num_%d", 19+(i-1)*3 + j)):setString(string.format("+%d%%", 100*(buf4[(i-1)*3+j] or 0)))
    end 
  end 

  local buf5 = {bufData1.fieldbattle_infantry_atk_plus, bufData1.fieldbattle_infantry_def_plus, bufData1.fieldbattle_infantry_life_plus,
                bufData1.fieldbattle_cavalry_atk_plus,  bufData1.fieldbattle_cavalry_def_plus,  bufData1.fieldbattle_cavalry_life_plus, 
                bufData1.fieldbattle_archer_atk_plus,   bufData1.fieldbattle_archer_def_plus,   bufData1.fieldbattle_archer_life_plus, 
                bufData1.fieldbattle_siege_atk_plus,    bufData1.fieldbattle_siege_def_plus,    bufData1.fieldbattle_siege_life_plus}

  local buf6 = {bufData2.fieldbattle_infantry_atk_plus, bufData2.fieldbattle_infantry_def_plus, bufData2.fieldbattle_infantry_life_plus,
                bufData2.fieldbattle_cavalry_atk_plus,  bufData2.fieldbattle_cavalry_def_plus,  bufData2.fieldbattle_cavalry_life_plus, 
                bufData2.fieldbattle_archer_atk_plus,   bufData2.fieldbattle_archer_def_plus,   bufData2.fieldbattle_archer_life_plus, 
                bufData2.fieldbattle_siege_atk_plus,    bufData2.fieldbattle_siege_def_plus,    bufData2.fieldbattle_siege_life_plus}
              
  for i=1, 4 do 
    for j=1, 3 do 
      str = g_tr("fieldbattle") .. g_tr(attrName[j], {name=g_tr(kindName[i])})
      attrLeft:getChildByName(string.format("label_%d", 31+(i-1)*3 + j)):setString(str)
      attrRight:getChildByName(string.format("label_%d", 31+(i-1)*3 + j)):setString(str)
      attrLeft:getChildByName(string.format("num_%d", 31+(i-1)*3 + j)):setString(string.format("+%d%%", 100*(buf5[(i-1)*3+j] or 0)))
      attrRight:getChildByName(string.format("num_%d", 31+(i-1)*3 + j)):setString(string.format("+%d%%", 100*(buf6[(i-1)*3+j] or 0)))
    end 
  end 
  listView:pushBackCustomItem(attrItem)
  if callback then 
    callback()
  end 
end 

function MailContentBattle:onShareMail()
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local mailData = self.listItem:getData().mail 
  if MailHelper:canMailShared(mailData.id) then 
    require("game.uilayer.chat.ChatMode").shareMailToGuild(mailData, false, function() 
        MailHelper:setMailSharedTime(mailData.id, g_clock.getCurServerTime()) 
      end) 
  end 
end 

function MailContentBattle:onMarkMail()
  print("onMarkMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self:getDelegate() then 
    local ret = self:getDelegate():doMarkMails({self.listItem})
    if ret then 
      MailHelper:setImgGray(self.btnMark, self.listItem:getData().mail.status==0)
    end 
  end 
end 

function MailContentBattle:onDeleteMail()
  print("onDeleteMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self:getDelegate() then 
    self:getDelegate():doDeleteMails({self.listItem})
  end 
end 

function MailContentBattle:onGoBack()
  if self:getDelegate() then 
    self:getDelegate():onGoBack()
  end 
end 

return MailContentBattle 
