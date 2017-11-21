
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailContentSpy = class("MailContentSpy",require("game.uilayer.base.BaseLayer"))
local MailType = MailHelper:getMailTypeEnum() 
local SpyType = MailHelper:getSpyTypeEnum() 

local layerObj --当前layer对象
function MailContentSpy:ctor(listItem)
  MailContentSpy.super.ctor(self)

  self.listItem = listItem --关联的某一个邮件列表项
end 

function MailContentSpy:onEnter()
  print("MailContentSpy:onEnter")
  layerObj = self 
  local layer = cc.CSLoader:createNode("mail_spy.csb")
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer) 
    self:showInfo()
  end 
end 

function MailContentSpy:onExit() 
  print("MailContentSpy:onExit") 
  layerObj = nil 
end 

function MailContentSpy:initBinding(rootNode)
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

  self.btnShare:setVisible(g_AllianceMode.getSelfHaveAlliance() and self.listItem:getData().mail.type == MailType.Detect)
  MailHelper:setImgGray(self.btnMark, self.listItem:getData().mail.status==0)
end 

function MailContentSpy:showInfo()
  print("===show spy content ")

  self.listView:removeAllChildren()
  self.listView:setItemsMargin(10)
  self.listView:setScrollBarEnabled(false)

  if nil == self.listItem then return end 
  local mailData = self.listItem:getData().mail 

  local towerLevel = MailHelper:getTowerLevel() --哨塔等级
  if mailData.data.build_level then 
    towerLevel = tonumber(mailData.data.build_level)
  end 
  
  --标题
  self.lbTitle:setString(g_tr("spyReport")) --mailData.title
  if self.lbTitle:getContentSize().width > 100 then --调整标题背景长度
    self.imgTitleBg:setContentSize(cc.size(self.lbTitle:getContentSize().width+80, self.imgTitleBg:getContentSize().height))
    self.lbTitle:setPosition(cc.p(self.imgTitleBg:getPositionX()+self.imgTitleBg:getContentSize().width/2, self.imgTitleBg:getPositionY()))
  end  

  --时间
  local tt = os.date("*t", mailData.create_time)
  self.lbTime:setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))

  --1.头像信息
  local headerItem = self:getHeaderInfoItem(mailData, towerLevel, handler(self, self.close))
  if headerItem then 
    self.listView:pushBackCustomItem(headerItem)
  end 

  --2.资源
  local resInfoItem = self:getResourceInfoItem(mailData, towerLevel)
  if resInfoItem then 
    self.listView:pushBackCustomItem(resInfoItem)
  end   

  --3.城防值
  local wallDefenceItem = self:getWallDefenceItem(mailData, towerLevel)
  if wallDefenceItem then 
    self.listView:pushBackCustomItem(wallDefenceItem)
  end 

  --4.防御部队
  local defenceTroop = self:getDefenceTroopItem(mailData, towerLevel)
  if defenceTroop then 
    self.listView:pushBackCustomItem(defenceTroop)
  end   

  --5.陷阱
  local trapItem = self:getTrapInfoItem(mailData, towerLevel)
  if trapItem then 
    self.listView:pushBackCustomItem(trapItem)
  end  

  --6.援军部队
  local assistItem = self:getAssistTroopItem(mailData, towerLevel)
  if assistItem then 
    self.listView:pushBackCustomItem(assistItem)
  end 

  --7.属性
  -- local talentItem = self:getTalentScienceItem(mailData)
  local talentItem = self:getTalentScienceItemEx(mailData, towerLevel) 
  if talentItem then 
    self.listView:pushBackCustomItem(talentItem)
  end 

  --8.主动技
  local skillItem = self:getSkillInfoItem(mailData, towerLevel)
  if skillItem then 
    self.listView:pushBackCustomItem(skillItem)
  end 
end 

--头像信息
function MailContentSpy:getHeaderInfoItem(mailData, towerLevel, callback)
  local headerItem = cc.CSLoader:createNode("mail_spy_content_0.csb")
  local imgPic = headerItem:getChildByName("pic") 
  local lbDes = headerItem:getChildByName("des") 
  local lbDes1 = headerItem:getChildByName("des_0")
  local lbPos = headerItem:getChildByName("Text_pos")

  headerItem:getChildByName("pic_0"):loadTexture(g_resManager.getResPath(1010007))
  lbDes:setString("")
  lbDes1:setString("")
  lbPos:setString("")
  if mailData.type == MailType.Detect then --侦查其他玩家
    if mailData.data.type == SpyType.Normal then --侦查主城
      MailHelper:loadPlayerIcon(imgPic, mailData.data.target_player.avatar_id)
      lbDes:setString(g_tr("spyReport"))
      lbDes1:setString(g_tr("%{name}_info", {name = mailData.data.target_player.nick}))
      MailHelper:addUnderLineForLabel(lbPos, mailData.data.x, mailData.data.y) 
      lbPos:setPositionX(lbDes1:getPositionX() + lbDes1:getContentSize().width)

    elseif mailData.data.type == SpyType.Castle then --侦查联盟 
      local element = g_data.map_element[mailData.data.map_element_id]
      if element then 
        imgPic:loadTexture(g_resManager.getResPath(element.img_mail))
        lbDes:setString("("..mailData.data.guild_short_name..")"..g_tr(element.name))

        lbDes1:setTextColor(cc.c3b(0, 183, 255))
        MailHelper:addUnderLineForLabel(lbDes1, mailData.data.x, mailData.data.y) 
      end 

    elseif mailData.data.type == SpyType.Resource then --侦查资源点
      if mailData.data.map_element_id and mailData.data.map_element_id > 0 then 
        local item = g_data.map_element[mailData.data.map_element_id] 
        imgPic:loadTexture(g_resManager.getResPath(item.img_mail))
        lbDes:setString(g_tr("detectSuccess"))
        MailHelper:addUnderLineForLabel(lbDes1, mailData.data.x, mailData.data.y)
      end 

    elseif mailData.data.type == SpyType.KingFight then --侦查国王战
      if mailData.data.map_element_id and mailData.data.map_element_id > 0 then 
        local item = g_data.map_element[mailData.data.map_element_id] 
        imgPic:loadTexture(g_resManager.getResPath(item.img_mail))
        lbDes:setString(g_tr("detectSuccess"))
        MailHelper:addUnderLineForLabel(lbDes1, mailData.data.x, mailData.data.y)
      end       

    elseif mailData.data.type == SpyType.JuDian then --侦查据点
      if mailData.data.map_element_id and mailData.data.map_element_id > 0 then 
        local item = g_data.map_element[mailData.data.map_element_id] 
        imgPic:loadTexture(g_resManager.getResPath(item.img_mail))
        lbDes:setString(g_tr("detectSuccess"))
        MailHelper:addUnderLineForLabel(lbDes1, mailData.data.x, mailData.data.y)
      end 
    end 
    
  elseif mailData.type == MailType.Detected then  --被其他玩家侦查
    if mailData.data.type == SpyType.Normal then --侦查主城
      lbDes:setString(g_tr("castleWasDetected"))
      lbDes1:setString(g_tr("%{name}SpyYourCastle", {name = mailData.data.target_player.nick}))
      
    elseif mailData.data.type == SpyType.Resource then --侦查资源点
      lbDes:setString(g_tr("resourceWasDetected"))
      lbDes1:setString(g_tr("%{name}SpyYourResource", {name = mailData.data.target_player.nick})) 
      
    elseif mailData.data.type == SpyType.JuDian then --据点
      lbDes:setString(g_tr("juDidanWasDetected"))
      lbDes1:setString(g_tr("%{name}SpyYourJudian", {name = mailData.data.target_player.nick}))               
    end 
    MailHelper:loadPlayerIcon(imgPic, mailData.data.target_player.avatar_id)
  end 

  return headerItem  
end 

--侦查详情(资源)
function MailContentSpy:getResourceInfoItem(mailData, towerLevel) 
  if mailData.type ~= MailType.Detect then return end 

  if mailData.data.type == SpyType.Castle then return end --侦查联盟堡垒 无资源
  if mailData.data.type == SpyType.JuDian then return end --侦查据点 无资源
  if mailData.data.type == SpyType.KingFight then return end --侦查国王战 无资源

  if nil == mailData.data.resource then return end 


  local infoItem = cc.CSLoader:createNode("mail_spy_content_1.csb")
  local bg = infoItem:getChildByName("bg")
  local row_title = bg:getChildByName("row_title")

  local lbResource = row_title:getChildByName("Text_dt1")
  local lbOwnNum = row_title:getChildByName("Text_dt2") 
  local lbToHarvest = row_title:getChildByName("Text_dt3") 

  lbResource:setString(g_tr("Resources"))
  lbOwnNum:setString(g_tr("alreadyOwn"))
  lbToHarvest:setString(g_tr("toHarvest"))

  bg:getChildByName("row_1"):getChildByName("num_1"):setString(""..mailData.data.resource.owned.gold)
  bg:getChildByName("row_1"):getChildByName("num_2"):setString(""..mailData.data.resource.no_collection.gold)
  bg:getChildByName("row_2"):getChildByName("num_1"):setString(""..mailData.data.resource.owned.food)
  bg:getChildByName("row_2"):getChildByName("num_2"):setString(""..mailData.data.resource.no_collection.food)
  bg:getChildByName("row_3"):getChildByName("num_1"):setString(""..mailData.data.resource.owned.wood)
  bg:getChildByName("row_3"):getChildByName("num_2"):setString(""..mailData.data.resource.no_collection.wood)  
  bg:getChildByName("row_4"):getChildByName("num_1"):setString(""..mailData.data.resource.owned.stone)
  bg:getChildByName("row_4"):getChildByName("num_2"):setString(""..mailData.data.resource.no_collection.stone)
  bg:getChildByName("row_5"):getChildByName("num_1"):setString(""..mailData.data.resource.owned.iron)
  bg:getChildByName("row_5"):getChildByName("num_2"):setString(""..mailData.data.resource.no_collection.iron)

  return infoItem 
end 

--城防值
function MailContentSpy:getWallDefenceItem(mailData, towerLevel) 

  if mailData.type ~= MailType.Detect then return end 

  if mailData.data.type == SpyType.Resource then return end --侦查资源点时没有防御值
  if mailData.data.type == SpyType.JuDian then return end --侦查据点 没有防御值
  if mailData.data.type == SpyType.KingFight then return end --侦查国王战 没有防御值

  local item = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
  item:getChildByName("label_text"):setString(g_tr("defenseValue"))
  if mailData.data.type == SpyType.Normal then --侦查主城
    item:getChildByName("total_num"):setString(mailData.data.wall.current .. "/" .. mailData.data.wall.max)
  elseif mailData.data.type == SpyType.Castle then --侦查联盟 
    item:getChildByName("total_num"):setString(""..mailData.data.durability)
  end 

  return item 
end 


--侦查详情(防守部队)
function MailContentSpy:getDefenceTroopItem(mailData, towerLevel) 
  if mailData.type ~= MailType.Detect then return end 

  local troop = mailData.data.troop 

  if nil == troop then return end 
  if towerLevel < 4 then return end 

  local pos_y = 0 
  local nodeTroops = ccui.Widget:create()

  --城墙驻守武将
  if mailData.data.type == SpyType.Normal and towerLevel >= 31 then 
    local title0 = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
    title0:getChildByName("total_num"):setString("")
    title0:getChildByName("label_text"):setString(g_tr("garrisonGenerals"))
    pos_y = pos_y - title0:getContentSize().height 
    title0:setPosition(cc.p(0, pos_y))
    nodeTroops:addChild(title0)      

    if troop.wall_general_id and troop.wall_general_id > 0 then 
      local genId = troop.wall_general_id*100+1
      if g_data.general[genId] then 
        local item = cc.CSLoader:createNode("mail_spy_content_2.csb")
        local pic_gen = item:getChildByName("img_general") 
        MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, genId, troop.general_star)
        item:getChildByName("name_general"):setString(g_tr(g_data.general[genId].general_name))
        item:getChildByName("img_soldier"):setVisible(false)
        item:getChildByName("name_soldier"):setVisible(false)
        item:getChildByName("num"):setVisible(false)

        pos_y = pos_y - item:getContentSize().height 
        item:setPosition(cc.p(0, pos_y))
        nodeTroops:addChild(item) 
      else 
        print("invalid wall_general_id:", troop.wall_general_id)
      end 
    else 
      title0:getChildByName("total_num"):setString(g_tr("none"))
    end 
  end 

  --预备役部队
  if mailData.data.type == SpyType.Normal and troop.remain_army and type(troop.remain_army) == "table" then 
    local title1 = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
    local lbTotal = title1:getChildByName("total_num")
    title1:getChildByName("label_text"):setString(g_tr("remainTroop"))
    pos_y = pos_y - title1:getContentSize().height 
    title1:setPosition(cc.p(0, pos_y))
    nodeTroops:addChild(title1) 

    local totalNum = 0 
    local item_new, rootNode, idx, pic, base,num 
    local item = cc.CSLoader:createNode("mail_spy_troop_item_2.csb")
    local count = math.ceil(#troop.remain_army/3)
    item:retain()
    for i=1, count do 
      item_new = item:clone() 
      rootNode = item_new:getChildByName("scale_node") 
      for j=1, 3 do 
        idx = 3*(i-1) + j 
        if idx <= #troop.remain_army then 
          base = g_data.soldier[troop.remain_army[idx].soldier_id] 
          if base then 
            pic = rootNode:getChildByName(string.format("Image_%d", j))
            pic:loadTexture(g_resManager.getResPath(base.img_type))
            num = troop.remain_army[idx].num
            if troop.multi_number then 
              num = troop.remain_army[idx].num * troop.multi_number 
            end 
            rootNode:getChildByName(string.format("Text_%d", j)):setString(g_tr(base.soldier_name).."x"..num)
            totalNum = totalNum + num
          end 
        else 
          rootNode:getChildByName(string.format("Image_%d", j)):setVisible(false)
          rootNode:getChildByName(string.format("Text_%d", j)):setVisible(false)
        end 
      end 
      pos_y = pos_y - item_new:getContentSize().height 
      item_new:setPosition(cc.p(0, pos_y))
      nodeTroops:addChild(item_new)
    end 
    item:release() 
    lbTotal:setString(""..totalNum)
  end 


  --防守部队军团数
  if mailData.data.type == SpyType.Castle or mailData.data.type == SpyType.KingFight then 
    if towerLevel >= 16 then  
      local item = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
      item:getChildByName("label_text"):setString(g_tr("armyCounts"))
      item:getChildByName("total_num"):setString("" .. (troop.army_num or 0))
      pos_y = pos_y - item:getContentSize().height 
      item:setPosition(cc.p(0, pos_y))
      nodeTroops:addChild(item)

    elseif towerLevel >= 7 then 
      local item = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
      item:getChildByName("label_text"):setString(g_tr("armyCounts"))
      item:getChildByName("total_num"):setString("" .. (troop.army_num_fuzzy or 0))
      pos_y = pos_y - item:getContentSize().height 
      item:setPosition(cc.p(0, pos_y))
      nodeTroops:addChild(item)
    end 
  end 


  --防守部队
  local titleItem = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
  local lbTotal = titleItem:getChildByName("total_num")
  titleItem:getChildByName("label_text"):setString(g_tr("defenseTroop"))
  pos_y = pos_y - titleItem:getContentSize().height 
  titleItem:setPosition(cc.p(0, pos_y))
  nodeTroops:addChild(titleItem)

  print("towerLevel", towerLevel, troop.total_num)
  local totalNum = troop.total_num or 0 
  if troop.multi_number then --加buff的时候数量有可能翻倍
    totalNum = totalNum * troop.multi_number
  end 

  --防守部队武将信息,士兵大概数量
  if troop.army and troop.army.player_army and #troop.army.player_army > 0 then 
    local item_new
    local item = cc.CSLoader:createNode("mail_spy_content_2.csb")
    item:retain()
    
    for k, v in pairs(troop.army.player_army) do 
      local general = g_data.general[v.general_id*100+1] 
      local soldier = g_data.soldier[v.soldier_id] 
      print("v.soldier_id", v.soldier_id)
      item_new = item:clone() 
      if general then 
        local pic_gen = item_new:getChildByName("img_general") 
        MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, v.general_id*100+1, v.general_star)
        item_new:getChildByName("name_general"):setString(g_tr(general.general_name))
      end 

      local pic_soldier = item_new:getChildByName("img_soldier")
      local name_soldier = item_new:getChildByName("name_soldier")
      if soldier then 
        MailHelper:loadGeneralSoldierIcon(pic_soldier, g_Consts.DropType.Soldier, v.soldier_id)
        name_soldier:setString(g_tr(soldier.soldier_name))
      else 
        pic_soldier:setVisible(false)
        name_soldier:setString("")
      end 

      if troop.multi_number then 
        v.soldier_num = v.soldier_num * troop.multi_number
      end 

      if towerLevel >= 27 then 
        item_new:getChildByName("num"):setString(string.format("%d", v.soldier_num))
      else 
        item_new:getChildByName("num"):setVisible(false)
      end 
      pos_y = pos_y - item_new:getContentSize().height 
      item_new:setPosition(cc.p(0, pos_y))
      nodeTroops:addChild(item_new)    
    end 
    item:release()
  end 

  --防守部队类型
  if towerLevel >= 13 and troop.soldier then 
    local count = 0 
    local tbl = {} 
    for k, info in pairs(troop.soldier) do 
      if info.soldier_id > 0 then 
        table.insert(tbl, info)
        count = count + 1 
      end 
    end 

    if count > 0 then 
      local pageCount = math.ceil(count/3)
      local item_new, rootNode, index, pic, base
      local item = cc.CSLoader:createNode("mail_spy_troop_item_2.csb")
      item:retain()
      for i=1, pageCount do 
        item_new = item:clone() 
        rootNode = item_new:getChildByName("scale_node")      
        for j=1, 3 do 
          index = 3*(i-1) + j 
          if index <= count then 
            base = g_data.soldier[tbl[index].soldier_id] 
            pic = rootNode:getChildByName(string.format("Image_%d", j))
            if base then 
              pic:loadTexture(g_resManager.getResPath(base.img_type))
              rootNode:getChildByName(string.format("Text_%d", j)):setString(g_tr(base.soldier_name))
            else 
              pic:setVisible(false)
              rootNode:getChildByName(string.format("Text_%d", j)):setVisible(false)
            end 
          else 
            rootNode:getChildByName(string.format("Image_%d", j)):setVisible(false)
            rootNode:getChildByName(string.format("Text_%d", j)):setVisible(false)
          end 
        end 
        pos_y = pos_y - item_new:getContentSize().height 
        item_new:setPosition(cc.p(0, pos_y)) 
        nodeTroops:addChild(item_new) 
      end 
      item:release() 
    end 
  end 

  --防守部队数量
  if towerLevel >= 27 then 
    lbTotal:setString(string.format("%d", totalNum))
  elseif totalNum > 0 then 
    lbTotal:setString(g_tr("about%{count}", {count = totalNum}))
  else 
    lbTotal:setString("0")
  end 


  local tmp = ccui.Widget:create()
  tmp:setContentSize(cc.size(titleItem:getContentSize().width, -pos_y))
  nodeTroops:setPosition(cc.p(0, -pos_y))
  tmp:addChild(nodeTroops) 

  return tmp 
end

--侦查详情(陷阱)
function MailContentSpy:getTrapInfoItem(mailData, towerLevel)
  if mailData.type ~= MailType.Detect then return end 

  if mailData.data.type == SpyType.JuDian then return end --侦查据点无城防设施
  if mailData.data.type == SpyType.KingFight then return end

  local trap = mailData.data.trap 

  if nil == trap then return end 

  local pos_y = 0 
  local nodeTroops = ccui.Widget:create()
  --标题
  local titleItem = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
  local lbTotal = titleItem:getChildByName("total_num")
  titleItem:getChildByName("label_text"):setString(g_tr("trap"))
  pos_y = pos_y - titleItem:getContentSize().height 
  titleItem:setPosition(cc.p(0, pos_y))
  nodeTroops:addChild(titleItem)


  if towerLevel >= 35 then --精确显示数量

    lbTotal:setString(string.format("%d", trap.total_num))
    local item_new, rootNode, idx, pic, base
    local item = cc.CSLoader:createNode("mail_spy_troop_item_2.csb")
    local count = trap.detail and math.ceil(#trap.detail/3) or 0 
    item:retain()
    for i=1, count do 
      item_new = item:clone() --(i==1) and item or item:clone() 
      rootNode = item_new:getChildByName("scale_node") 
      for j=1, 3 do 
        idx = 3*(i-1) + j 
        if idx <= #trap.detail then 
          base = g_data.trap[trap.detail[idx].trap_id] 
          pic = rootNode:getChildByName(string.format("Image_%d", j))
          pic:loadTexture(g_resManager.getResPath(base.img_head))
          rootNode:getChildByName(string.format("Text_%d", j)):setString(g_tr(base.trap_name).."x"..trap.detail[idx].num)
        else 
          rootNode:getChildByName(string.format("Image_%d", j)):setVisible(false)
          rootNode:getChildByName(string.format("Text_%d", j)):setVisible(false)
        end 
      end 
      pos_y = pos_y - item_new:getContentSize().height 
      item_new:setPosition(cc.p(0, pos_y))
      nodeTroops:addChild(item_new)
    end 
    item:release()

  elseif towerLevel >= 7 then 
    lbTotal:setString(g_tr("about%{count}", {count=trap.total_num}))
  else 
    return 
  end 

  local tmp = ccui.Widget:create()
  tmp:setContentSize(cc.size(titleItem:getContentSize().width, -pos_y))
  nodeTroops:setPosition(cc.p(0, -pos_y))
  tmp:addChild(nodeTroops) 

  return tmp 
end 

--侦查详情(援军部队)
function MailContentSpy:getAssistTroopItem(mailData, towerLevel) 
  if mailData.type ~= MailType.Detect then return end 

  if mailData.data.type == SpyType.Castle then return end --侦查联盟时没有援军信息
  if mailData.data.type == SpyType.JuDian then return end --侦查据点 没有援军信息
  if mailData.data.type == SpyType.KingFight then return end

  local helper = mailData.data.help_army
  if nil == helper then return end 

  local pos_y = 0 
  local nodeTroops = ccui.Widget:create()

  --标题
  local titleItem = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
  local lbTotal = titleItem:getChildByName("total_num")
  lbTotal:setString("")
  titleItem:getChildByName("label_text"):setString(g_tr("assistTroop"))
  pos_y = pos_y - titleItem:getContentSize().height 
  titleItem:setPosition(cc.p(0, pos_y))
  nodeTroops:addChild(titleItem)


  --侦查资源点时只显示援军大致数量
  if mailData.data.type == SpyType.Resource and towerLevel >= 10 then 
    towerLevel = 10 
  end 
  
  if towerLevel < 10 then return end 
  
  --援军总数
  local helpNum = helper.total_num or 0
  if towerLevel >= 39 then
    lbTotal:setString(""..helpNum)

  elseif towerLevel >= 10 then --援军大致数量（士兵数量1000~2000）
    if helpNum > 0 then 
      lbTotal:setString(g_tr("about%{count}", {count = helpNum}))
    else 
      lbTotal:setString("0") 
    end 
  end 


  if towerLevel >= 16 then --援军领主的名称与等级
    dump(helper.detail, "===helper.detail")
    if nil == helper.detail then return end 

    local function showGeneralDetail(sender)
      print("showGeneralDetail", sender)
      g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

      local idx = sender:getTag()
      local army = helper.detail[idx].army 
      
      --show pop up  
      local pop = require("game.uilayer.mail.MailContentSpyPlayerDetail").new(army, towerLevel) 
      g_sceneManager.addNodeForUI(pop)       
    end 

    local playerItem = cc.CSLoader:createNode("mail_battle_content_8.csb")
    local item_new, rootNode, lbCount, btnDetail
    local count = math.ceil(#helper.detail) 
    playerItem:retain()
    for i=1, count do 
      item_new = playerItem:clone() --(i==1) and playerItem or playerItem:clone()
      rootNode = item_new:getChildByName("Panel_1") 
      --玩家肖像 
      MailHelper:loadPlayerIcon(rootNode:getChildByName("pic_general"), helper.detail[i].avatar_id)
      rootNode:getChildByName("name_1"):setString(string.format("Lv.%d", helper.detail[i].level))
      rootNode:getChildByName("name_general"):setString(helper.detail[i].nick) 
      lbCount = rootNode:getChildByName("name_general_1")
      btnDetail = rootNode:getChildByName("Image_17")
      btnDetail:getChildByName("Text_23"):setString(g_tr("tuoCheck"))
      btnDetail:setTag(i)
      btnDetail:addClickEventListener(showGeneralDetail)
      btnDetail:setVisible(towerLevel >= 19)

      --计算所有兵的总数量
      local num = 0 
      if helper.detail[i].army then 
        for k, v in pairs(helper.detail[i].army) do 
          num = num + v.soldier_num 
        end 
      end 
      lbCount:setString(""..num)
      lbCount:setVisible(towerLevel >= 39)

      pos_y = pos_y - item_new:getContentSize().height 
      item_new:setPosition(cc.p(0, pos_y))
      nodeTroops:addChild(item_new)
    end 
    playerItem:release()
  end 

  local tmp = ccui.Widget:create() 
  tmp:setContentSize(cc.size(titleItem:getContentSize().width, -pos_y)) 
  nodeTroops:setPosition(cc.p(0, -pos_y)) 
  tmp:addChild(nodeTroops) 

  return tmp 
end

--侦查详情(天赋科技)
function MailContentSpy:getTalentScienceItem(mailData, towerLevel)
  local buff = mailData.data.buff 

  if nil == buff  then return end 

  if towerLevel < 44 then return end 

  if nil == buff.infantry_atk_plus then return end --空数据则返回

  local bufValues = { buff.infantry_atk_plus, buff.infantry_def_plus, buff.infantry_life_plus, 0,
                      buff.cavalry_atk_plus, buff.cavalry_def_plus, buff.cavalry_life_plus, 0,
                      buff.archer_atk_plus, buff.archer_def_plus, buff.archer_life_plus, 0,
                      buff.siege_atk_plus, buff.siege_def_plus, buff.siege_life_plus, 0,
                    } 
  local kindName = {"infantry", "cavalry", "archer", "vehicles"}
  local attrName = {"%{name}attack", "%{name}defense", "%{name}Hp", "%{name}damageReduce"}
  local talentItem = cc.CSLoader:createNode("mail_spy_content_3.csb")
  talentItem:getChildByName("label_text"):setString(g_tr("attribute"))
  local tmp 
  for i=1, 4 do 
    for j=1, 4 do 
      tmp = talentItem:getChildByName(string.format("row_%d", (i-1)*4 + j))
      tmp:getChildByName("prop_name"):setString(g_tr(attrName[j], {name=g_tr(kindName[i])}))
      tmp:getChildByName("num"):setString(string.format("+%d%%", 100*(bufValues[(i-1)*4+j] or 0)))
    end 
  end 

  talentItem:getChildByName("row_17"):getChildByName("prop_name"):setString(g_tr("stoneDamageToInfantry"))
  talentItem:getChildByName("row_18"):getChildByName("prop_name"):setString(g_tr("woodDamageToCavalry"))
  talentItem:getChildByName("row_19"):getChildByName("prop_name"):setString(g_tr("knifeDamageToArcher"))
  talentItem:getChildByName("row_17"):getChildByName("num"):setString(string.format("+%d%%", 100*(buff.rockfall_damage_addition or 0)))
  talentItem:getChildByName("row_18"):getChildByName("num"):setString(string.format("+%d%%", 100*(buff.rolling_damage_addition or 0)))
  talentItem:getChildByName("row_19"):getChildByName("num"):setString(string.format("+%d%%", 100*(buff.fire_arrow_damage_addition or 0)))

  return talentItem 
end 

--侦查详情(天赋科技)
function MailContentSpy:getTalentScienceItemEx(mailData, towerLevel)
  
  if nil == mailData.data.buff  then return end 
  if towerLevel < 44 then return end 

  local buff = mailData.data.buff 
  if nil == buff.infantry_atk_plus then return end --空数据则返回

  local bufValues = { buff.infantry_atk_plus, buff.infantry_def_plus, buff.infantry_life_plus, 0,
                      buff.cavalry_atk_plus, buff.cavalry_def_plus, buff.cavalry_life_plus, 0,
                      buff.archer_atk_plus, buff.archer_def_plus, buff.archer_life_plus, 0,
                      buff.siege_atk_plus, buff.siege_def_plus, buff.siege_life_plus, 0,
                    } 
  local kindName = {"infantry", "cavalry", "archer", "vehicles"}
  local attrName = {"%{name}attack", "%{name}defense", "%{name}Hp", "%{name}damageReduce"}


  local pos_y = 0 
  local nodeAttr = ccui.Widget:create()
  --标题
  local titleItem = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
  titleItem:getChildByName("total_num"):setVisible(false)
  titleItem:getChildByName("label_text"):setString(g_tr("attribute"))
  pos_y = pos_y - titleItem:getContentSize().height 
  titleItem:setPosition(cc.p(0, pos_y))
  nodeAttr:addChild(titleItem)

  local talentItem = cc.CSLoader:createNode("mail_spy_content_4.csb")
  local val, itemNew 
  for i=1, 4 do 
    for j=1, 4 do 
      val = bufValues[(i-1)*4+j] or 0 
      if val > 0 then 
        itemNew = talentItem:clone()
        itemNew:getChildByName("prop_name"):setString(g_tr(attrName[j], {name=g_tr(kindName[i])}))
        itemNew:getChildByName("num"):setString(string.format("+%d%%", 100*val))

        pos_y = pos_y - itemNew:getContentSize().height 
        itemNew:setPosition(cc.p(0, pos_y))
        nodeAttr:addChild(itemNew)
      end 
    end 
  end 

  local bufValEx = {buff.rockfall_damage_addition, buff.rolling_damage_addition, buff.fire_arrow_damage_addition}
  local bufNameEx = {"stoneDamageToInfantry", "woodDamageToCavalry", "knifeDamageToArcher"}
  for i = 1, 3 do 
    if bufValEx[i] and bufValEx[i] > 0 then 

      itemNew = talentItem:clone()
      itemNew:getChildByName("prop_name"):setString(g_tr(bufNameEx[i]))
      itemNew:getChildByName("num"):setString(string.format("+%d%%", 100*bufValEx[i]))

      pos_y = pos_y - itemNew:getContentSize().height 
      itemNew:setPosition(cc.p(0, pos_y))
      nodeAttr:addChild(itemNew)
    end 
  end  

  local tmp = ccui.Widget:create() 
  tmp:setContentSize(cc.size(titleItem:getContentSize().width, -pos_y)) 
  nodeAttr:setPosition(cc.p(0, -pos_y)) 
  tmp:addChild(nodeAttr) 

  return tmp 
end 

function MailContentSpy:getSkillInfoItem(mailData, towerLevel)
  local skill = mailData.data.master_skill 
  if nil == skill or #skill == 0 then return end 

  if towerLevel < 50 then return end 

  local pos_y = 0 
  local nodeTroops = ccui.Widget:create()

  --标题
  local titleItem = cc.CSLoader:createNode("mail_spy_content_2_title.csb")
  titleItem:getChildByName("label_text"):setString(g_tr("talent"))
  titleItem:getChildByName("total_num"):setVisible(false)
  pos_y = pos_y - titleItem:getContentSize().height 
  titleItem:setPosition(cc.p(0, pos_y))
  nodeTroops:addChild(titleItem)


  local itemNew,rootNode, talent  
  local item = cc.CSLoader:createNode("mail_battle_content_9.csb")
  item:retain()
  for k, v in pairs(skill) do 
    if v.enable > 0 then 
      itemNew = item:clone() 
      rootNode = itemNew:getChildByName("Panel_1") 
      --天赋icon      
      if g_data.talent[v.talent_id] then 
        rootNode:getChildByName("pic_general"):loadTexture(g_resManager.getResPath(g_data.talent[v.talent_id].img))
        rootNode:getChildByName("name_general"):setString(g_tr(g_data.talent[v.talent_id].talent_name))
      else 
        print("invalid talent_id:", v.talent_id)
        rootNode:getChildByName("name_general"):setString("")
      end 
      rootNode:getChildByName("name_1"):setString(g_tr("CDtime"))
      local dt = v.next_time - mailData.create_time 
      if dt > 0 then  
        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)           
        rootNode:getChildByName("name_time"):setString(string.format("%02d:%02d:%02d", hour, min, sec))  
      else 
        rootNode:getChildByName("name_time"):setString("00:00:00")
      end 

      pos_y = pos_y - itemNew:getContentSize().height 
      itemNew:setPosition(cc.p(0, pos_y))
      nodeTroops:addChild(itemNew)  
    end   
  end 
  item:release()

  local tmp = ccui.Widget:create()
  tmp:setContentSize(cc.size(titleItem:getContentSize().width, -pos_y))
  nodeTroops:setPosition(cc.p(0, -pos_y))
  tmp:addChild(nodeTroops) 

  return tmp 
end 

function MailContentSpy:onShareMail()
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local mailData = self.listItem:getData().mail 
  if MailHelper:canMailShared(mailData.id) then 
    require("game.uilayer.chat.ChatMode").shareMailToGuild(mailData, false, function()
        MailHelper:setMailSharedTime(mailData.id, g_clock.getCurServerTime()) 
      end ) 
    
  end 
end 

function MailContentSpy:onMarkMail()
  print("onMarkMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self:getDelegate() then 
    local ret = self:getDelegate():doMarkMails({self.listItem})
    if ret then 
      MailHelper:setImgGray(self.btnMark, self.listItem:getData().mail.status==0)
    end 
  end 
end 

function MailContentSpy:onDeleteMail()
  print("onDeleteMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self:getDelegate() then 
    self:getDelegate():doDeleteMails({self.listItem})
  end 
end 

function MailContentSpy:onGoBack()
  if self:getDelegate() then 
    self:getDelegate():onGoBack()
  end 
end 

function MailContentSpy:close()
  if self:getDelegate() then 
    self:getDelegate():close()
  end 
end 

return MailContentSpy 
