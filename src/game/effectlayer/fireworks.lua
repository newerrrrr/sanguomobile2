local fireworks = {}
setmetatable(fireworks,{__index = _G})
setfenv(1,fireworks)

function show()
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.start == eventType then
		elseif ccs.MovementEventType.complete == eventType then
			armature:removeFromParent()
		elseif ccs.MovementEventType.loopComplete == eventType then
			armature:removeFromParent()
		end
	end
	for i = 1 , math.random(1, 3) , 1 do
		g_autoCallback.addCocosList( function ()
			local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_YanHua/Effect_YanHua.ExportJson", "Effect_YanHua", onMovementEventCallFunc)
			local x = math.random(g_display.center.x + 10.0, g_display.right - 20.0)
			local y = math.random(g_display.center.y + 10.0, g_display.top - 20.0)
			armature:setPosition(cc.p(x, y))
			g_sceneManager.addNodeForSceneEffect(armature)
			animation:play((math.random(1, 2) == 1) and "Effect_YanHuaOne" or "Effect_YanHuaTwo")
		end, math.random(1, 30) * 0.1 )
	end
	for i = 1 , math.random(1, 3) , 1 do
		g_autoCallback.addCocosList( function ()
			local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_YanHua/Effect_YanHua.ExportJson", "Effect_YanHua", onMovementEventCallFunc)
			local x = math.random(g_display.center.x - 10.0, g_display.left + 20.0)
			local y = math.random(g_display.center.y + 10.0, g_display.top - 20.0)
			armature:setPosition(cc.p(x, y))
			g_sceneManager.addNodeForSceneEffect(armature)
			animation:play((math.random(1, 2) == 1) and "Effect_YanHuaOne" or "Effect_YanHuaTwo")
		end, math.random(1, 30) * 0.1 )
	end
	for i = 1 , math.random(1, 3) , 1 do
		g_autoCallback.addCocosList( function ()
			local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_YanHua/Effect_YanHua.ExportJson", "Effect_YanHua", onMovementEventCallFunc)
			local x = math.random(g_display.center.x - 10.0, g_display.left + 20.0)
			local y = math.random(g_display.center.y - 10.0, g_display.bottom + 20.0)
			armature:setPosition(cc.p(x, y))
			g_sceneManager.addNodeForSceneEffect(armature)
			animation:play((math.random(1, 2) == 1) and "Effect_YanHuaOne" or "Effect_YanHuaTwo")
		end, math.random(1, 30) * 0.1 )
	end
	for i = 1 , math.random(1, 3) , 1 do
		g_autoCallback.addCocosList( function ()
			local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_YanHua/Effect_YanHua.ExportJson", "Effect_YanHua", onMovementEventCallFunc)
			local x = math.random(g_display.center.x + 10.0, g_display.right - 20.0)
			local y = math.random(g_display.center.y - 10.0, g_display.bottom + 20.0)
			armature:setPosition(cc.p(x, y))
			g_sceneManager.addNodeForSceneEffect(armature)
			animation:play((math.random(1, 2) == 1) and "Effect_YanHuaOne" or "Effect_YanHuaTwo")
		end, math.random(1, 30) * 0.1 )
	end
	for i = 1 , math.random(1, 2) , 1 do
		g_autoCallback.addCocosList( function ()
			local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_YanHua/Effect_YanHua.ExportJson", "Effect_YanHua", onMovementEventCallFunc)
			local w = g_display.visibleSize.width * 0.35
			local h = g_display.visibleSize.height * 0.35
			local x = math.random(g_display.center.x - w, g_display.center.x + w)
			local y = math.random(g_display.center.y - h, g_display.center.y + h)
			armature:setPosition(cc.p(x, y))
			g_sceneManager.addNodeForSceneEffect(armature)
			animation:play((math.random(1, 2) == 1) and "Effect_YanHuaOne" or "Effect_YanHuaTwo")
		end, math.random(1, 30) * 0.1 )
	end
	cc.Director:getInstance():setNextDeltaTimeZero(true)
end

return fireworks