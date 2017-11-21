local spriteWave = {}
setmetatable(spriteWave,{__index = _G})
setfenv(1,spriteWave)

local HomeScreenEffectMD = require "game.maplayer.homeScreenEffect"

--浪

local c_tag_color_trans = 55412128

function create()
	local ret = lhs.LHSCustomShaderSprite:create("freeImage/wave.png")
	
	local m_Attribute = {
		timeLocation = -1,
		timeVar = 0,
		lightColorLocation = -1,
		currentWeather = HomeScreenEffectMD.getCurrentWeather(),
		rainColor = cc.vec3(0.615,0.817,0.615),
		sunColor = cc.vec3(0.835,0.78,0.58),
	}
	
	local function vec3_to_c3b(f)
		return cc.c3b(f.x * 255, f.y * 255, f.z * 255)
	end
	
	local function c3b_to_vec3(b)
		return cc.vec3(b.r / 255, b.g / 255, b.b / 255)
	end
	
	local sp_1 = cc.Sprite:create("freeImage/mask_1.jpg")
	sp_1:setColor(m_Attribute.currentWeather == "sunshine" and vec3_to_c3b(m_Attribute.sunColor) or vec3_to_c3b(m_Attribute.rainColor))
	sp_1:setVisible(false)
	ret:addChild(sp_1)
	
	local sp_2 = cc.Sprite:create("freeImage/mask_2.jpg")
	sp_2:setVisible(false)
	ret:addChild(sp_2)
	
	local texture_1 = sp_1:getTexture()
	local texture_2 = sp_2:getTexture()
	
	local glProgramState = cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_Wave )
	local glProgram = glProgramState:getGLProgram()
	glProgram:use()
	
	m_Attribute.timeLocation = glProgram:getUniformLocation("u_time")
	m_Attribute.lightColorLocation = glProgram:getUniformLocation("u_lightColor")
	
	ret:setGLProgramState( glProgramState )
	
	local function onBeforeDraw(glProgramState)
		glProgramState:setUniformTexture("u_texture1", texture_1:getName())
		glProgramState:setUniformTexture("u_texture2", texture_2:getName())
		glProgramState:setUniformFloat(m_Attribute.timeLocation, m_Attribute.timeVar)
		glProgramState:setUniformVec3(m_Attribute.lightColorLocation, c3b_to_vec3(sp_1:getColor()))
	end
	ret:registerScriptBeforeDrawHandler(cToolsForLua:pushHandlerForlua(onBeforeDraw))
	
	local function uptate_time(dt)
		m_Attribute.timeVar = math.mod(m_Attribute.timeVar + dt, 100)
		if HomeScreenEffectMD.getCurrentWeather() ~= m_Attribute.currentWeather then
			m_Attribute.currentWeather = HomeScreenEffectMD.getCurrentWeather()
			sp_1:stopActionByTag(c_tag_color_trans)
			local action = cc.TintTo:create(1.0, m_Attribute.currentWeather == "sunshine" and vec3_to_c3b(m_Attribute.sunColor) or vec3_to_c3b(m_Attribute.rainColor))
			action:setTag(c_tag_color_trans)
			sp_1:runAction(action)
		end
	end
	
	local schedulers = {}
	local function nodeEventHandler(eventType)
        if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(uptate_time, 0 , false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    ret:registerScriptHandler(nodeEventHandler)
	
	return ret
end



return spriteWave