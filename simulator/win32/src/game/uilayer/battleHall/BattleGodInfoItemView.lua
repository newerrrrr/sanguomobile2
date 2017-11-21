local BattleGodInfoItemView = class("BattleGodInfoItemView", require("game.uilayer.base.BaseWidget"))

function BattleGodInfoItemView:ctor(data, player1, player2)
	self.data = data

	self.player1 = player1
	self.player2 = player2

	self.layer = self:LoadUI("mail_battle_content_god_skill_item.csb")
	self.pic_gen = self.layer:getChildByName("item"):getChildByName("pic_gen")
	self.name_gen = self.layer:getChildByName("item"):getChildByName("name_gen")
	self.desc = self.layer:getChildByName("item"):getChildByName("desc")

	local item = self:createHeroHead(data.gid*100+1)
    item:setPosition(self.pic_gen:getContentSize().width/2, self.pic_gen:getContentSize().height/2)
    if data.star then  --显示星级
      item:showGeneralServerStarLv(data.star)
    end    
    self.pic_gen:addChild(item)
   	self.name_gen:setString(item:getName())

   	local txtRich = g_gameTools.createRichText(self.desc, "")

   	local force = nil

   	if g_data.combat_skill[data.gid].num_type == 2 then
   		force = tostring(data.para)
   	else
   		force = string.format("%.1f%%%%",data.para*100)
   	end

    if data.oppGeneralInfo then --神关羽单独处理
  		if data.oppGeneralInfo.gid then 
        local oppGenName = data.oppGeneralInfo.gid > 0 and g_tr(g_data.general[data.oppGeneralInfo.gid*100+1].general_name) or ""
        local nick1 = self:getGenName(self.player1, self.player2, data.pid)
        local nick2 = self:getGenName(self.player1, self.player2, data.oppGeneralInfo.pid)
        local skill = data.gid > 0 and g_data.combat_skill[g_data.general[data.gid*100+1].general_combat_skill] or nil 

        if data.gid == 10109 and not data.oppGeneralInfo.flag then --神黄忠失败时
          strDesc = g_tr("godGenHuangZhongTips", {player = nick1})

        elseif data.gid == 10072 then --荀彧成功/失败
          if not data.oppGeneralInfo.flag then 
            strDesc = g_tr("godGenXunYuTips", {player = nick1})
          else 
            local nick3 = self:getGenName(self.player1, self.player2, data.oppGeneralInfo.pid2)

            local oppGenName3 = g_data.general[data.oppGeneralInfo.gid2 > 0 and g_tr(g_data.general[data.oppGeneralInfo.gid2*100+1].general_name) or "" 
            strDesc = g_tr(skill.combat_info, {player=nick1, player1=nick2, name=oppGenName, player2=nick3,name1=oppGenName3, num=force, ifsuccess=g_tr("godGenWin")})
          end 

        elseif data.oppGeneralInfo.gid > 0 then --有武将时
          local batResult = data.oppGeneralInfo.flag and g_tr("godGenWin") or g_tr("godGenLost") 
          strDesc = g_tr(skill.combat_info, {player = nick1, player1 = nick2, name = oppGenName, num = force, ifsuccess = batResult})
        
        else --没有武将时
          local attrStr = data.gid == 10106 and "godGenTips" or "godGenTips2" --神关羽/神司马懿 对方没有武将
          strDesc = g_tr(attrStr, {player = nick1, num = force})              
        end 

      else --没有武将时
        local attrStr = data.gid == 10106 and "godGenTips" or "godGenTips2"  --神关羽/神司马懿 对方没有武将
        strDesc = g_tr(attrStr, {player = self.player1.nick, num = force})
      end 

    elseif data.gid == 10110 then --神诸葛亮
        local skill = g_data.combat_skill[g_data.general[data.gid*100+1].general_combat_skill]
        strDesc = g_tr(skill.combat_info, {player = self.player1.nick, num = string.format("%.1f%%%%", data.para*100), num1 = data.num})

    elseif data.gid == 10098 then --神周瑜
        local skill = g_data.combat_skill[g_data.general[data.gid*100+1].general_combat_skill]
        strDesc = g_tr(skill.combat_info, {player = self.player1.nick, num = string.format("%d", data.damage), num1 = data.num})

    elseif data.gid == 10089 then --神周泰
        local skill = g_data.combat_skill[g_data.general[data.gid*100+1].general_combat_skill]
        local str = data.allDead and g_tr("godGenSoldierAllDie") or g_tr("godGenSoldierSurvive") 
        strDesc = g_tr(skill.combat_info, {player = self.player1.nick, num = string.format("%.1f%%%%", data.para*100), desc = str})    

    elseif data.damage then --神孙策单独处理
    	strDesc = g_tr(g_data.combat_skill[data.gid].combat_info, {player = self.player1.nick, num = force, damage = string.format("%d", data.damage)})
    else
        strDesc = g_tr(g_data.combat_skill[data.gid].combat_info, {player = self.player1.nick, num = force})
    end

    txtRich:setRichText(strDesc)
end

function BattleGodInfoItemView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

function BattleGodInfoItemView:getGenName(player1, player2, genId)
  if player1 and player1.players then 
    for k, v in pairs(player1.players) do 
      if v.player_id == playerId then 
        return v.nick
      end 
    end 
  end 

  if player2 and player2.players then 
    for k, v in pairs(player2.players) do 
      if v.player_id == playerId then 
        return v.nick
      end 
    end 
  end 

  return ""
end 


return BattleGodInfoItemView