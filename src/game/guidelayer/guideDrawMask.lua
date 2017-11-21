local guideDrawMask = {}
setmetatable(guideDrawMask,{__index = _G})
setfenv(1,guideDrawMask)

--引导的渲染基础辅助

local c_default_alpha = 0.5
local c_default_radius = 50.0
local c_default_position = cc.p(g_display.center.x, g_display.center.y)
local c_default_rect = cc.rect(g_display.center.x - 50.0, g_display.center.y - 50.0 , 100.0, 100.0)

local c_origin_mask_circle_radius = 50.0
local c_origin_mask_circle_alpha = 1.0

local c_tag_playTips_action = 99874441

local function _createDrawMask_basic( alpha )
	
	local origin_alpha = alpha and alpha or c_default_alpha
	
	local ret = cc.DrawNode:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	ret:setPosition(g_display.center)
	ret:setContentSize(g_display.size)
	ret:drawSolidRect( cc.p(0.0,0.0) , cc.p(g_display.size.width,g_display.size.height) , cc.c4f(0.0,0.0,0.0, origin_alpha ) )
	
	ret.lua_update_show = function(self, vAlpha)
		local new_alpha = vAlpha and vAlpha or origin_alpha
		
		if origin_alpha ~= new_alpha then
			ret:drawSolidRect( cc.p(0.0,0.0) , cc.p(g_display.size.width,g_display.size.height) , cc.c4f(0.0,0.0,0.0, math.clampf(new_alpha, 0.0, 1.0) ) )
		end
	end
	
	return ret
end


function createDrawMask_circle( position , radius , alpha )
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	ret:setPosition(g_display.center)
	ret:setContentSize(g_display.size)
	
	local origin_radius = radius and radius or c_default_radius
	local origin_alpha = alpha and alpha or c_default_alpha
	local origin_position = position and position or cc.p(c_default_position.x, c_default_position.y)
	
	local mHide = false
	
	local clip = cc.ClippingNode:create()
	clip:ignoreAnchorPointForPosition(false)
	clip:setAnchorPoint(cc.p(0.5,0.5))
	clip:setPosition(g_display.center)
	clip:setContentSize(g_display.size)
	clip:setInverted(true)
	ret:addChild(clip)
	
	local base = _createDrawMask_basic( alpha )
	clip:addChild(base)
	
	local stencil = cc.Node:create()
	stencil:ignoreAnchorPointForPosition(false)
	stencil:setAnchorPoint(cc.p(0.5,0.5))
	stencil:setContentSize(cc.size(0.0,0.0))
	clip:setStencil(stencil)
	
	local stencil_show = cc.Sprite:create("freeImage/mask.png")
	stencil:addChild(stencil_show)
	
	local mask_show_bottom = cc.Node:create()
	mask_show_bottom:ignoreAnchorPointForPosition(false)
	mask_show_bottom:setAnchorPoint(cc.p(0.5,0.5))
	mask_show_bottom:setContentSize(cc.size(0.0,0.0))
	ret:addChild(mask_show_bottom)
	
	local mask_show_top = cc.Sprite:create("freeImage/mask.png")
	mask_show_bottom:addChild(mask_show_top)
	
	
	ret.lua_palyTips = function(self)
		local bChange = false
		if stencil:getActionByTag(c_tag_playTips_action) == nil then
			stencil:setScale(10.0)
			local action = cc.ScaleTo:create(0.5,1.0)
			action:setTag(c_tag_playTips_action)
			stencil:runAction(action)
			bChange = true
		end
		if mask_show_bottom:getActionByTag(c_tag_playTips_action) == nil then
			mask_show_bottom:setScale(10.0)
			local action = cc.ScaleTo:create(0.5,1.0)
			action:setTag(c_tag_playTips_action)
			mask_show_bottom:runAction(action)
			bChange = true
		end
		if bChange then
			ret:stopActionByTag(c_tag_playTips_action)
			local function onEnd()
				ret:setVisible(not mHide)
			end
			local action = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(1.0), cc.CallFunc:create(onEnd))
			action:setTag(c_tag_playTips_action)
			ret:runAction(action)
		end
	end
	
	
	ret.lua_setHide = function (self , v)
		mHide = v
		ret:setVisible(not mHide)
	end
	
	
	ret.lua_update_show = function(self, vPos, vRadius, vAlpha)
		local new_radius = vRadius and vRadius or origin_radius
		local new_alpha = vAlpha and vAlpha or origin_alpha
		local new_position = vPos and vPos or origin_position
		
		base:lua_update_show(new_alpha)
		
		stencil:setPosition(new_position)
		mask_show_bottom:setPosition(new_position)
		
		mask_show_top:setOpacity( math.clampf(255 * (new_alpha / c_origin_mask_circle_alpha), 0, 255) )
		stencil_show:setScale(new_radius / c_origin_mask_circle_radius)
		mask_show_top:setScale(new_radius / c_origin_mask_circle_radius)
	end
	
	ret:lua_update_show(origin_position, origin_radius, origin_alpha)
	
	return ret
end


function createDrawMask_rect(rect , alpha )
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	ret:setPosition(g_display.center)
	ret:setContentSize(g_display.size)
	
	local origin_rect = rect and rect or cc.rect(c_default_rect.x, c_default_rect.y, c_default_rect.width, c_default_rect.height)
	local origin_alpha = alpha and alpha or c_default_alpha
	
	local mHide = false
	
	local clip = cc.ClippingNode:create()
	clip:ignoreAnchorPointForPosition(false)
	clip:setAnchorPoint(cc.p(0.5,0.5))
	clip:setPosition(g_display.center)
	clip:setContentSize(g_display.size)
	clip:setInverted(true)
	ret:addChild(clip)
	
	local base = _createDrawMask_basic( alpha )
	clip:addChild(base)
	
	local stencil = cc.DrawNode:create()
	stencil:ignoreAnchorPointForPosition(false)
	stencil:setAnchorPoint(cc.p(0.5,0.5))
	stencil:setContentSize(cc.size(0.0,0.0))
	clip:setStencil(stencil)
	
	ret.lua_palyTips = function(self)
		local bChange = false
		if stencil:getActionByTag(c_tag_playTips_action) == nil then
			stencil:setScale(12.0)
			local action = cc.ScaleTo:create(0.5,1.0)
			action:setTag(c_tag_playTips_action)
			stencil:runAction(action)
			bChange = true
		end
		if bChange then
			ret:stopActionByTag(c_tag_playTips_action)
			local function onEnd()
				ret:setVisible(not mHide)
			end
			local action = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(1.0), cc.CallFunc:create(onEnd))
			action:setTag(c_tag_playTips_action)
			ret:runAction(action)
		end
	end
	
	ret.lua_setHide = function (self , v)
		mHide = v
		ret:setVisible(not mHide)
	end
	
	ret.lua_update_show = function(self, vRect, vAlpha)
		local new_rect = vRect and vRect or origin_rect
		local new_alpha = vAlpha and vAlpha or origin_alpha
		
		base:lua_update_show(new_alpha)
		
		stencil:setPosition(cc.p(new_rect.x + new_rect.width / 2, new_rect.y + new_rect.height / 2))
		stencil:clear()
		stencil:drawSolidRect(cc.p(new_rect.width / -2, new_rect.height / -2), cc.p(new_rect.width / 2, new_rect.height / 2), cc.c4f(0.0,0.0,0.0,1.0))
	end
	
	ret:lua_update_show(origin_rect, origin_alpha)
	
	return ret
end




return guideDrawMask