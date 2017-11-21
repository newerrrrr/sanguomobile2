local clearLayer = {}
setmetatable(clearLayer,{__index = _G})
setfenv(1,clearLayer)

--清理资源

local m_Root = nil

local function clearGlobal()
	m_Root = nil
end

function create(lase_scene_mode)
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	
	local function update(dt)
		if m_Root == nil then
			return
		end
		local function execute()
			if lase_scene_mode == g_sceneManager.sceneMode.cg then
				ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("anime/anim_cg/anim_cg.ExportJson")
				cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
				cc.Director:getInstance():getTextureCache():removeUnusedTextures()
				g_sceneManager.setScene(g_sceneManager.sceneMode.loading)
			end
		end
		g_autoCallback.addCocosList( execute , 0.01 )
		m_Root:unscheduleUpdate()
	end
	
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
			rootLayer:unscheduleUpdate()
		elseif eventType == "enterTransitionFinish" then
			rootLayer:scheduleUpdateWithPriorityLua(update, 0)
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	local background = cc.Sprite:create(g_data.sprite[1999999].path)
	background:setPosition(g_display.center)
	rootLayer:addChild(background)
	
	return rootLayer
end



return clearLayer