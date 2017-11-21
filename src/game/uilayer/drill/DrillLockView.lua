local DrillLockView = class("DrillLockView", function() 
	return cc.Layer:create()
end)

function DrillLockView:ctor()
	self.layer = cc.CSLoader:createNode("xiaochangxinx_lock.csb")

	self:addChild(self.layer)
end

return DrillLockView