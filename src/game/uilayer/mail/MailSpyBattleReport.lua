

local MailSpyBattleReport = class("MailSpyBattleReport",require("game.uilayer.base.BaseLayer"))
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailBattleContent = require("game.uilayer.mail.MailContentBattle")
local MailType = MailHelper:getMailTypeEnum() 
local SpyType = MailHelper:getSpyTypeEnum() 
local layerObj 

function MailSpyBattleReport:ctor(mailData)
  MailSpyBattleReport.super.ctor(self)
  self:setDelegate(self)
  self.mailData = mailData 
  layerObj = self 
end 

function MailSpyBattleReport:onEnter()
  print("MailSpyBattleReport:onEnter")
  MailBattleContent:setLayerObj(layerObj)
  
  local layer = g_gameTools.LoadCocosUI("mail_spy_report.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:init(layer) 
    if self.mailData then 
      if self.mailData.type == MailType.Detect then 
        self:showSypInfo(layer) 
      else 
        self:showBattleInfo(layer) 
      end 
    end 
  end 
end 

function MailSpyBattleReport:onExit() 
  print("MailSpyBattleReport:onExit") 
  layerObj = nil 
  MailBattleContent:setLayerObj(nil)
end 

function MailSpyBattleReport:init(root)
  local scaleNode = root:getChildByName("scale_node")
  scaleNode:getChildByName("text1"):setString("") 
  scaleNode:getChildByName("Text_3"):setString(g_tr("confirm")) 
  local mask = root:getChildByName("mask")
  local btnConfirm = scaleNode:getChildByName("Button_1") 
  local btnClose = scaleNode:getChildByName("close_btn") 
  self:regBtnCallback(mask, handler(self, self.close))
  self:regBtnCallback(btnConfirm, handler(self, self.close))
  self:regBtnCallback(btnClose, handler(self, self.close)) 
end 

function MailSpyBattleReport:onClose()
  self:close()
  if self:getDelegate() then 
    self:getDelegate():close()
  end 
end 

function MailSpyBattleReport:showSypInfo(root)
  print("===show spy content ")

  if nil == self.mailData then return end 

  
  local scaleNode = root:getChildByName("scale_node")
  local listView = scaleNode:getChildByName("ListView_1")
  scaleNode:getChildByName("text1"):setString(g_tr("spyReport")) 

  listView:removeAllChildren()
  listView:setItemsMargin(10)
  listView:setScrollBarEnabled(false)

  local towerLevel = MailHelper:getTowerLevel() --哨塔等级
  if self.mailData.data.build_level then 
    towerLevel = tonumber(self.mailData.data.build_level)
  end 

  local MailContent = require("game.uilayer.mail.MailContentSpy")

  --时间
  local tt = os.date("*t", self.mailData.create_time)
  scaleNode:getChildByName("text_time"):setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))

  --1.头像信息
  local headerItem = MailContent:getHeaderInfoItem(self.mailData, towerLevel, handler(self, self.onClose))
  if headerItem then 
    listView:pushBackCustomItem(headerItem)
  end 

  --2.资源
  local resInfoItem = MailContent:getResourceInfoItem(self.mailData, towerLevel)
  if resInfoItem then 
    listView:pushBackCustomItem(resInfoItem)
  end   

  --3.城防值
  local wallDefenceItem = MailContent:getWallDefenceItem(self.mailData, towerLevel)
  if wallDefenceItem then 
    listView:pushBackCustomItem(wallDefenceItem)
  end 

  --4.防御部队
  local defenceTroop = MailContent:getDefenceTroopItem(self.mailData, towerLevel)
  if defenceTroop then 
    listView:pushBackCustomItem(defenceTroop)
  end   

  --5.陷阱
  local trapItem = MailContent:getTrapInfoItem(self.mailData, towerLevel)
  if trapItem then 
    listView:pushBackCustomItem(trapItem)
  end  

  --6.援军部队
  local assistItem = MailContent:getAssistTroopItem(self.mailData, towerLevel)
  if assistItem then 
    listView:pushBackCustomItem(assistItem)
  end 

  --7.属性
  local talentItem = MailContent:getTalentScienceItemEx(self.mailData, towerLevel) 
  if talentItem then 
    listView:pushBackCustomItem(talentItem)
  end 

  --8.主动技
  local skillItem = MailContent:getSkillInfoItem(self.mailData, towerLevel)
  if skillItem then 
    listView:pushBackCustomItem(skillItem)
  end 
end 

function MailSpyBattleReport:showBattleInfo(root)
  if nil == self.mailData then return end 

  local scaleNode = root:getChildByName("scale_node")
  self.listView = scaleNode:getChildByName("ListView_1")
  scaleNode:getChildByName("text1"):setString(g_tr("battleReport")) 
  self.listView:removeAllChildren()
  self.listView:setItemsMargin(10)
  self.listView:setScrollBarEnabled(false)

  --时间
  local tt = os.date("*t", self.mailData.create_time)
  scaleNode:getChildByName("text_time"):setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))

  --如果全军覆没,则没有其他战报详情
  if self.mailData.data.all_dead then 
    local killedItem = MailBattleContent:getAllKilledInfo(self.mailData)
    if killedItem then 
      self.listView:pushBackCustomItem(killedItem)
    end 
    return 
  end 

  self.funcQueue = {}
  table.insert(self.funcQueue, MailBattleContent.getHeaderInfoItem)     --头像信息
  table.insert(self.funcQueue, MailBattleContent.getDurabilityItem)     --(跨服战)城防血量
  table.insert(self.funcQueue, MailBattleContent.getResourceInfoItem)   --资源
  table.insert(self.funcQueue, MailBattleContent.getDropItem)       --获得道具
  table.insert(self.funcQueue, MailBattleContent.getPowerLostItem)  --战力损失
  table.insert(self.funcQueue, MailBattleContent.getGodSkillItem)   --神武将技能伤害  
  table.insert(self.funcQueue, MailBattleContent.getTroopInfoItem)  --部队详情 
  table.insert(self.funcQueue, MailBattleContent.getDamageInfoItem) --损害信息 
  table.insert(self.funcQueue, MailBattleContent.getTroopAttrItem)  --部队属性

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
    func(obj, self.mailData, self.listView, loadCallback) 
  end 

  loadQueueContent()
end 

return MailSpyBattleReport 
