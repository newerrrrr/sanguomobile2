
--阵营选择
local CampSelecte = class("CampSelecte",require("game.uilayer.base.BaseLayer"))
function CampSelecte:ctor()
  CampSelecte.super.ctor(self)



  local layer = g_gameTools.LoadCocosUI("CityBattle_panel_02.csb", 5) 
  if layer then 
    self:addChild(layer) 

    self.scale_node = layer:getChildByName("scale_node")
    self.scale_node:getChildByName("Text_1"):setString(g_tr("allianceTechTitle"))
    self.scale_node:getChildByName("Text_title"):setString(g_tr("weekBattleTaskTitle"))

    local btnHelp = self.scale_node:getChildByName("Button_wenh1") 

    local nodePic = self.scale_node:getChildByName("Panel_renw"):getChildByName("Image_16") 
    nodePic:loadTexture(g_data.sprite[1031092].path) 

    local Panel_5 = self.scale_node:getChildByName("Panel_5")
    Panel_5:getChildByName("Text_ms1"):setString(g_tr("weekBattleTaskDesc"))
    Panel_5:getChildByName("Text_rw1"):setString(g_tr("weekBattleTaskProgress"))
    Panel_5:getChildByName("Text_award"):setString(g_tr("taskAward"))

    local btnGoto = Panel_5:getChildByName("btn_goto") 
    btnGoto:getChildByName("Text_2"):setString(g_tr("weekBattleTaskGoto")) 
    self:regBtnCallback(btnGoto, handler(self, self.onGoto))
    self:regBtnCallback(btnHelp, handler(self, self.onHelp))

    local lbTaskDesc = Panel_5:getChildByName("Text_desc")
    local lbProgress = Panel_5:getChildByName("Text_rw2")

    local dropId 
    local taskItem = g_data.alliance_quest[taskId] 
    if taskItem then
      lbTaskDesc:setString(g_tr(taskItem.name, {num = taskItem.num_value}))
      lbProgress:setString(string.format("%d/%d", 0, taskItem.num_value)) 
      dropId = 720001 --test 
    else 
      lbTaskDesc:setString("")
      lbProgress:setString("")
    end 
    self:showAwardList(dropId) 
  end 
end 

function CampSelecte:onEnter()
  print("CampSelecte:onEnter")
end 

function CampSelecte:onExit() 
  print("CampSelecte:onExit") 
end 


return CampSelecte 
