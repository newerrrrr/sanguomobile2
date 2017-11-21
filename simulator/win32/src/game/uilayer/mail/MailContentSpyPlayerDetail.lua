

--显示侦查报告援军的武将列表
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailContentSpyPlayerDetail = class("MailContentSpy",require("game.uilayer.base.BaseLayer"))


function MailContentSpyPlayerDetail:ctor(army, towerLevel)
  MailContentSpyPlayerDetail.super.ctor(self)
  self.army = army 
  self.towerLevel = towerLevel 
end 

function MailContentSpyPlayerDetail:onEnter()
  print("MailContentSpyPlayerDetail:onEnter")
  local layer = g_gameTools.LoadCocosUI("mail_battle_content_pop.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showInfo()
  end 
end 

function MailContentSpyPlayerDetail:onExit() 
  print("MailContentSpyPlayerDetail:onExit") 
end 


function MailContentSpyPlayerDetail:initBinding(rootNode)
  rootNode:getChildByName("text"):setString(g_tr_original("assistTroop"))
  rootNode:getChildByName("btn_close"):addClickEventListener(handler(self, self.close))
  self.listView = rootNode:getChildByName("ListView_1")
end 


function MailContentSpyPlayerDetail:showInfo()
  print("=== MailContentSpyPlayerDetail:showInfo ")

  if nil == self.listView then return end 

  self.listView:removeAllChildren()
  self.listView:setItemsMargin(10)
  self.listView:setScrollBarEnabled(false)


  if nil == self.army then return end 


  --部队详情 
  local troopItem = self:getTroopInfoItem() 
  if troopItem then 
    self.listView:pushBackCustomItem(troopItem) 
  end 
end 


--武将详情
function MailContentSpyPlayerDetail:getTroopInfoItem()

  local itemNew, pic_solider, name_soldier, lbCount 
  local pos_y = 0 
  local nodeTroops = ccui.Widget:create()
  local troopItem = cc.CSLoader:createNode("mail_spy_content_2.csb")

  local genItem  
  for k, v in pairs(self.army) do 
    itemNew = (i==1) and troopItem or troopItem:clone()
    print("general original id:", v.general_id)
    genItem = g_data.general[v.general_id*100+1]
    local pic_gen = itemNew:getChildByName("img_general")
    MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, v.general_id*100+1, v.general_star)
    itemNew:getChildByName("name_general"):setString(g_tr(genItem.general_name))
    pic_solider = itemNew:getChildByName("img_soldier")
    name_soldier = itemNew:getChildByName("name_soldier")
    lbCount = itemNew:getChildByName("num")
    print("self.towerLevel", self.towerLevel)

    lbCount:setVisible(false)
    if self.towerLevel >= 39 then --援军兵种类型和准确数量
      MailHelper:loadGeneralSoldierIcon(pic_solider, g_Consts.DropType.Soldier, v.soldier_id)
      name_soldier:setString(g_tr(g_data.soldier[v.soldier_id].soldier_name))
      lbCount:setString(""..v.soldier_num)
      lbCount:setVisible(true)
      
    elseif self.towerLevel >= 23 then --援军兵种类型 
      MailHelper:loadGeneralSoldierIcon(pic_solider, g_Consts.DropType.Soldier, v.soldier_id)
      name_soldier:setString(g_tr(g_data.soldier[v.soldier_id].soldier_name))

    elseif self.towerLevel >= 19 then --援军武将信息
      pic_solider:setVisible(false)
      name_soldier:setVisible(false)
    end 

    pos_y = pos_y - itemNew:getContentSize().height 
    itemNew:setPosition(cc.p(0, pos_y))
    nodeTroops:addChild(itemNew)
  end 

  local tmp = ccui.Widget:create()
  tmp:setContentSize(cc.size(troopItem:getContentSize().width, -pos_y))
  nodeTroops:setPosition(cc.p(0, -pos_y))
  tmp:addChild(nodeTroops) 
  
  return tmp 
end 


return MailContentSpyPlayerDetail 
