local guideBasicEffect = {}
setmetatable(guideBasicEffect,{__index = _G})
setfenv(1,guideBasicEffect)

--引导的特效基础辅助

local c_default_radius = 50.0
local c_default_position = cc.p(g_display.center.x, g_display.center.y)

local c_origin_mask_circle_radius = 50.0

function createBasicEffect_circle(position , radius)
	local retArmature , animation = g_gameTools.LoadCocosAni("anime/Effect_XinShouDianJiTiShi/Effect_XinShouDianJiTiShi.ExportJson", "Effect_XinShouDianJiTiShi")
	animation:play("Animation1")
	
	local origin_radius = radius and radius or c_default_radius
	local origin_position = position and position or cc.p(c_default_position.x, c_default_position.y)
	
	retArmature.lua_update_show = function(self, vPos, vRadius)
		local new_radius = vRadius and vRadius or origin_radius
		local new_position = vPos and vPos or origin_position
		
		retArmature:setPosition(new_position)
		retArmature:setScale(new_radius / c_origin_mask_circle_radius)
	end
	
	retArmature:lua_update_show(origin_position, origin_radius)
	
	return retArmature
end


--创建手指
function createGuideHandEffect(position, angle)
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.0,0.0))
	ret:setContentSize(cc.size(1.0,1.0))
	
	local origin_position = position and position or cc.p(c_default_position.x, c_default_position.y)
	local origin_angle = angle and angle or 0
	
	local retHandImage = cc.Sprite:createWithSpriteFrameName("homeImage_guide_finger.png")
	retHandImage:setPosition(cc.p(0.0,0.0))
	local act_up = cc.Spawn:create(cc.MoveBy:create(0.6, cc.p(30.0,-25.0)), cc.ScaleTo:create(0.6,1.15))
	local act_down = cc.Spawn:create(cc.MoveBy:create(0.6, cc.p(-30.0,25.0)), cc.ScaleTo:create(0.6,0.95))
	retHandImage:runAction(cc.RepeatForever:create(cc.Sequence:create( act_up , act_down )))
	ret:addChild(retHandImage)
	
	ret.lua_update_show = function(self, vPos, vAngle)
		local new_position = vPos and vPos or origin_position
		local new_angle = vAngle and vAngle or origin_angle
		ret:setPosition(new_position)
		ret:setRotation(new_angle)
	end
	ret:lua_update_show(position and position or cc.p(c_default_position.x, c_default_position.y))
	
	return ret
end



return guideBasicEffect