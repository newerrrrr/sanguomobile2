local homeBlurLayer = {}
setmetatable(homeBlurLayer,{__index = _G})
setfenv(1,homeBlurLayer)

local m_RenderTextureBlur = cc.RenderTexture:create(g_display.size.width, g_display.size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
if m_RenderTextureBlur then
	m_RenderTextureBlur:retain()
	m_RenderTextureBlur:getSprite():getTexture():setAntiAliasTexParameters()
end


function releaseRenderTexture()
	if m_RenderTextureBlur then
		m_RenderTextureBlur:release()
	end
end

local c_var_blurVar = 2.0
if g_gameTools.isHighIosDevice() then
	c_var_blurVar = 3.0
end
local c_var_alpha = 0.35


function create( renderFunc , openCallback , closeCallback )
	if m_RenderTextureBlur == nil then
		local ret = cc.Node:create()
		--打开模糊 小菜单模式
		function ret:lua_open_blur_for_smallMenu()
		end
		--关闭模糊 小菜单模式
		function ret:lua_close_blur_for_smallMenu()
		end
		--打开模糊 建造界面
		function ret:lua_open_blur_for_buildInterface(dt, offset_y, scale)
		end
		
		--关闭模糊 建造界面
		function ret:lua_close_blur_for_buildInterface(dt)
		end
		
		--关闭模糊 强制
		function ret:lua_close_blur()
		end
		
		--更新位置 菜单模式下
		function ret:lua_update_blur_position(smallMenu, scale)
		end
		return ret
	end

	local ret = require("game.gametools.renderTextureToScreen_Blur").create( m_RenderTextureBlur )
	ret:setVisible(false)
	if closeCallback then
		closeCallback()
	end
	ret:setFlippedY(true)
	
	local function update(dt)
		if ret:isVisible() then
			m_RenderTextureBlur:beginWithClear(0.0, 0.0, 0.0, 1.0)
			renderFunc(ret)
			m_RenderTextureBlur:endToLua()
			cToolsForLua:immediatelyDraw()
		end
	end
	ret:scheduleUpdateWithPriorityLua(update,0)
	
	
	local mode = 0
	
	
	--打开模糊 小菜单模式
	function ret:lua_open_blur_for_smallMenu()
		mode = 1
		self:setVisible(true)
		if openCallback then
			openCallback()
		end
		self:setBlurStepAndAlpha(c_var_blurVar, c_var_alpha)
	end
	
	
	--关闭模糊 小菜单模式
	function ret:lua_close_blur_for_smallMenu()
		if mode == 1 then
			mode = 0
			self:setVisible(false)
			if closeCallback then
				closeCallback()
			end
			self:setBlurStepAndAlpha(0, 0)
		end
	end
	
	
	--打开模糊 建造界面
	function ret:lua_open_blur_for_buildInterface(dt, offset_y, scale)
		mode = 2
		self:setVisible(true)
		if openCallback then
			openCallback()
		end
		self:setBlurStepAndAlpha(0, 0)
		self:setBlurStepAndAlphaInDuration(c_var_blurVar, c_var_alpha, dt)
		self:setClippingCenterAndRadius(cc.p(g_display.size.width * 0.5, g_display.size.height * 0.5 + offset_y * g_display.scale), 220)
		self:setScaleVar(scale)
	end
	
	
	--关闭模糊 建造界面
	function ret:lua_close_blur_for_buildInterface(dt)
		if mode == 2 then
			mode = 0
			self:setBlurStepAndAlphaInDuration(0.0, 0.0, dt,true)
			if closeCallback then
				closeCallback()
			end
		end
	end
	
	
	--关闭模糊 强制
	function ret:lua_close_blur()
		mode = 0
		self:setVisible(false)
		if closeCallback then
			closeCallback()
		end
		self:setBlurStepAndAlpha(0, 0)
	end
	
	
	--更新位置 菜单模式下
	function ret:lua_update_blur_position(smallMenu, scale)
		if smallMenu and mode == 1 and self:isVisible() then
			self:setClippingCenterAndRadius(smallMenu:convertToWorldSpaceAR(cc.p(0.0, 0.0)), 220)
			self:setScaleVar(scale)
		end
	end
	
	
	return ret
end



return homeBlurLayer