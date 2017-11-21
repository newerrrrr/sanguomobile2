local BattleRecordProperty = class("BattleRecordProperty", require("game.uilayer.base.BaseWidget"))

function BattleRecordProperty:ctor(data1, data2)
	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_3.csb")

	self.root = self.layer:getChildByName("panel_content")
	self.label_attack = self.root:getChildByName("label_attack")
	self.label_defense = self.root:getChildByName("label_defense")

	self.label_attack:setString(g_tr("mailAttackPro"))
	self.label_defense:setString(g_tr("mailDefendPro"))

	local attrLeft = self.root:getChildByName("statistics_left") 
  	local attrRight = self.root:getChildByName("statistics_right") 

  	local kindName = {"infantry", "cavalry", "archer", "vehicles"}
  	local attrName = {"%{name}attack", "%{name}defense", "%{name}Hp", "%{name}damageReduce"}

  	local bufData1 = data1 
  	local bufData2 = data2
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
    	for j=1, 3 do 
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
end

return BattleRecordProperty