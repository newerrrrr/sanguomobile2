local GuildWarSettingsLayer = class("GuildWarSettingsLayer",function()
	return cc.Layer:create()
end)

function GuildWarSettingsLayer:ctor()
	local uiLayer =  g_gameTools.LoadCocosUI("guild_war_message_xintanc1.csb",5)
	self:addChild(uiLayer)
	
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	
	self._baseNode:getChildByName("content_popup"):getChildByName("bg_title"):getChildByName("Text_2"):setString(g_tr("guild_war_settings_title"))
	self._baseNode:getChildByName("content_popup"):getChildByName("Text_1"):setString(g_tr("citybttle_settings_item1"))
	self._baseNode:getChildByName("content_popup"):getChildByName("btn_confirm"):getChildByName("Text_1"):setString(g_tr("guild_war_settings_btn_item1"))
	
	local btnClose = self._baseNode:getChildByName("close_btn")
	btnClose:addClickEventListener(function()
		self:removeFromParent()
	end)
	
	local btn1 = self._baseNode:getChildByName("content_popup"):getChildByName("btn_confirm")
	btn1:addClickEventListener(function()
		local alertCallBack =  function(event)
      if event == 0 then
      	self:removeFromParent()
      	require("game.maplayer.changeMapScene").changeToHome()
      end
    end
    g_msgBox.show(g_tr("citybttle_exit_tip"),nil,nil,alertCallBack,1)
	end)
	
end

return GuildWarSettingsLayer