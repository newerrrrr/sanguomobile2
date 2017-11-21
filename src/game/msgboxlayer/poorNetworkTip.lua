local poorNetworkTip = {}
setmetatable(poorNetworkTip,{__index = _G})
setfenv(1,poorNetworkTip)

local m_poor_tip = nil

function show() 
	if m_poor_tip then return end 

	m_poor_tip = cc.LayerColor:create(cc.c4b(0,0,0,30))
	m_poor_tip:retain()

  local armature, animation = g_gameTools.LoadCocosAni(
		"anime/WiFi/WiFi.ExportJson"
		, "WiFi"
		-- , onMovementEventCallFunc
		--, onFrameEventCallFunc
		)
  armature:setPosition(g_display.center)
  m_poor_tip:addChild(armature)
  animation:play("Animation1")  

	g_sceneManager.addNodeForMsgBox(m_poor_tip)
end


function hide()
	if m_poor_tip then
		m_poor_tip:removeFromParent()
		m_poor_tip:release()
		m_poor_tip = nil
	end
end



return poorNetworkTip