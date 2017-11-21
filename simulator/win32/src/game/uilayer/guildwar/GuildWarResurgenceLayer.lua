local GuildWarResurgenceLayer = class("GuildWarResurgenceLayer",function()
	return cc.Layer:create()
end)

function GuildWarResurgenceLayer:ctor(str)
	local uiLayer =  g_gameTools.LoadCocosUI("guild_war_message_popup1.csb",5)
	self:addChild(uiLayer)
	
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	
	baseNode:getChildByName("content_popup"):getChildByName("bg_title"):getChildByName("Text_2"):setString(g_tr("guild_war_fh_title"))
	
	self._str = str
	self._baseNode:getChildByName("content_popup"):getChildByName("Text_1"):setString(self._str)
	
	self._baseNode:getChildByName("content_popup"):getChildByName("btn_confirm"):getChildByName("Text_1"):setString(g_tr("guild_war_btn_fh"))
	self._baseNode:getChildByName("content_popup"):getChildByName("btn_confirm"):addClickEventListener(function()
		--TODO:使用元宝复活
		local function onRecv(result, msgData)
	  		g_busyTip.hide_1()
	      if(result==true)then
		       require "game.mapguildwar.worldMapLayer_bigMap".requestMapAllData_Manual()
		       require "game.mapguildwar.changeMapScene".gotoWorld_BigTileIndex(g_guildWarPlayerData.GetPosition(),function()
		       		 require "game.mapguildwar.worldMapLayer_uiLayer".tipMsg(g_tr("guild_war_fh_success"))
		       end)
		    end
		  end
			g_busyTip.show_1()
			g_sgHttp.postData("cross/revive",{},onRecv,true)
		end)
	
	self._baseNode:getChildByName("content_popup"):getChildByName("btn_cancle"):getChildByName("Text_1"):setString(g_tr("guild_war_btn_cancle"))
	self._baseNode:getChildByName("content_popup"):getChildByName("btn_cancle"):addClickEventListener(function()
		self:removeFromParent()
	end)
	
	
	self:registerScriptHandler(function(eventType)
    if eventType == "enter" then
			require("game.mapguildwar.worldMapLayer_uiLayer").addUpdateView(self)
			self:updateView()
    elseif eventType == "exit" then
			require("game.mapguildwar.worldMapLayer_uiLayer").removeUpdateView(self)
    end 
  end )
  
end

function GuildWarResurgenceLayer:updateView()
	
	if g_guildWarPlayerData.GetData().is_dead ~= 1 then 
		self:removeFromParent()
		return
	end

	self:stopAllActions()
	
	local labelCd = self._baseNode:getChildByName("content_popup"):getChildByName("Text_2")
	local labelCost = self._baseNode:getChildByName("content_popup"):getChildByName("Text_3")

	local currentTime = g_clock.getCurServerTime()
	
	local fhTime = g_guildWarPlayerData.GetData().dead_time + tonumber(g_data.warfare_service_config[25].data)
	local function updateTimeStr()
		currentTime = g_clock.getCurServerTime()
		local timeLeft = math.max(fhTime - currentTime,0)
		if timeLeft <= 0 then
			self:stopAllActions()
		end
		labelCd:setString(g_tr("guild_war_fh_cd",{sec = timeLeft}))
		
		local costPrice = tonumber(g_data.warfare_service_config[26].data)
		local costNum = timeLeft * costPrice / tonumber(g_data.warfare_service_config[25].data)
		labelCost:setString(g_tr("guild_war_fh_cost",{num = math.floor(costNum)}))
	end
	
	local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
  local action = cc.RepeatForever:create(seq)
  self:runAction(action)
  updateTimeStr() 
end

return GuildWarResurgenceLayer