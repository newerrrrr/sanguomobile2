local DrillPowerUpView = class("DrillPowerUpView", require("game.uilayer.base.BaseLayer"))

function DrillPowerUpView:ctor(value)
	DrillPowerUpView.super.ctor(self)

	self.layer = self:loadUI("zhandouli01.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.BitmapFontLabel_1 = self.root:getChildByName("BitmapFontLabel_1")
	self.BitmapFontLabel_1:setString("+"..value)

	self:play()
end

function DrillPowerUpView:play()
	local function closeWin()
		local function update()
			self:unschedule(self.time)
			self.time = nil
			self:close()
		end
		self.time = self:schedule(update, 2)
	end

	self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 2), cc.ScaleTo:create(0.2, 1), cc.CallFunc:create(closeWin)))
end

return DrillPowerUpView