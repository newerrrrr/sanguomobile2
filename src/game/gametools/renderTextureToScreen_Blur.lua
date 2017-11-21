local renderTextureToScreen_Blur = {}
setmetatable(renderTextureToScreen_Blur,{__index = _G})
setfenv(1,renderTextureToScreen_Blur)

--模糊

local c_radius_min = 0.65

local c_precision = 0.0005

function create(renderTexture)
	
	local ret = lhs.LHSRenderTextureToScreenToLua:create(renderTexture)
	
	local m_Attribute = {
		centerLocation = -1,
		vec2oneLocation = -1,
		vec2twoLocation = -1,
		vec2threeLocation = -1,
		
		contentSize = ret:getContentSize(),
		
		center = cc.p(0,0),
		radius = 0,
		blurVar = 0,
		alpha = 0,
		scale = 1,
		
		wantToBlurStep = 0,
		subBlurStep = 0,
		wantToAlpha = 0,
		subAlpha = 0,
		totalTime = 0,
		currentTime = 0,
	
		isWillHide = false,
	}
	
	local shaderMode = ((g_gameTools.isHighIosDevice()) and (g_shaders.shaderMode.shader_ToScreenBlur_high) or (g_shaders.shaderMode.shader_ToScreenBlur_low))
	
	local glProgramState = cc.GLProgramState:getOrCreateWithGLProgramName( shaderMode )
	
	local glProgram = glProgramState:getGLProgram()

	glProgram:use()
	
	m_Attribute.centerLocation = glProgram:getUniformLocation("u_lhs_center")
	glProgram:setUniformLocationWith2f(m_Attribute.centerLocation, m_Attribute.center.x * c_precision, m_Attribute.center.y * c_precision)

	m_Attribute.vec2oneLocation = glProgram:getUniformLocation("u_lhs_vec2_1")
	glProgram:setUniformLocationWith2f(m_Attribute.vec2oneLocation, m_Attribute.radius * m_Attribute.scale * c_precision, m_Attribute.radius * c_radius_min * m_Attribute.scale * c_precision)

	m_Attribute.vec2twoLocation = glProgram:getUniformLocation("u_lhs_vec2_2")
	glProgram:setUniformLocationWith2f(m_Attribute.vec2twoLocation, 1.0 / m_Attribute.contentSize.width, 1.0 / m_Attribute.contentSize.height)

	m_Attribute.vec2threeLocation = glProgram:getUniformLocation("u_lhs_vec2_3")
	glProgram:setUniformLocationWith2f(m_Attribute.vec2threeLocation, m_Attribute.blurVar * m_Attribute.scale, m_Attribute.alpha)
	
	ret:setGLProgramState( glProgramState )
	
	local schedule_id = nil
	local function updateToBlurStepAndAlpha(dt)
		m_Attribute.currentTime = m_Attribute.currentTime + dt
		if m_Attribute.currentTime > m_Attribute.totalTime then
			m_Attribute.blurVar = m_Attribute.wantToBlurStep
			m_Attribute.alpha = m_Attribute.wantToAlpha
			if m_Attribute.isWillHide == true then
				ret:setVisible(false)
			end
			if schedule_id then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedule_id)
				schedule_id = nil
			end
		else
			m_Attribute.blurVar = m_Attribute.wantToBlurStep - m_Attribute.subBlurStep / m_Attribute.totalTime *  (m_Attribute.totalTime - m_Attribute.currentTime)
			m_Attribute.alpha = m_Attribute.wantToAlpha - m_Attribute.subAlpha / m_Attribute.totalTime *  (m_Attribute.totalTime - m_Attribute.currentTime)
		end
	end
	
	
	function ret:setClippingCenterAndRadius(center, radius)
		m_Attribute.center = center
		m_Attribute.radius = radius
	end


	function ret:setBlurStepAndAlpha(blurVar, alpha)
		if schedule_id then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedule_id)
			schedule_id = nil
		end
		m_Attribute.blurVar = blurVar
		m_Attribute.alpha = alpha
	end
	
	
	function ret:setScaleVar(scale)
		m_Attribute.scale = scale
	end


	function ret:setBlurStepAndAlphaInDuration(blurVar, alpha, dt, isHide)
		if dt <= 0.0 then
			self:setBlurStepAndAlpha(blurVar, alpha)
			if isHide == true then
				self:setVisible(false)
			end
			return
		end
		
		m_Attribute.wantToBlurStep = blurVar
		m_Attribute.subBlurStep = m_Attribute.wantToBlurStep - m_Attribute.blurVar
		m_Attribute.wantToAlpha = alpha
		m_Attribute.subAlpha = m_Attribute.wantToAlpha - m_Attribute.alpha
		m_Attribute.totalTime = dt
		m_Attribute.currentTime = 0
	
		m_Attribute.isWillHide = isHide
		
		if schedule_id == nil then
			schedule_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateToBlurStepAndAlpha, 0 , false)
		end
	end


	local function eventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
			if schedule_id then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedule_id)
				schedule_id = nil
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    ret:registerScriptHandler(eventHandler)


	local function Draw(mat4, flags)
		local glProgram = ret:getGLProgram()
		glProgram:use()
		glProgram:setUniformsForBuiltins(mat4)
		glProgram:setUniformLocationWith2f(m_Attribute.centerLocation, m_Attribute.center.x * c_precision, m_Attribute.center.y * c_precision)
		glProgram:setUniformLocationWith2f(m_Attribute.vec2oneLocation, m_Attribute.radius * m_Attribute.scale * c_precision, m_Attribute.radius * c_radius_min * m_Attribute.scale * c_precision)
		glProgram:setUniformLocationWith2f(m_Attribute.vec2twoLocation, 1.0 / m_Attribute.contentSize.width, 1.0 / m_Attribute.contentSize.height)
		glProgram:setUniformLocationWith2f(m_Attribute.vec2threeLocation, m_Attribute.blurVar * m_Attribute.scale, m_Attribute.alpha)
	end
	ret:registerScriptDrawHandler(cToolsForLua:pushHandlerForlua(Draw))
	
	
	return ret
end



return renderTextureToScreen_Blur