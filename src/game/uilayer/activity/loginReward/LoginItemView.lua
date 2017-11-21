local LoginItemView = class("LoginItemView", require("game.uilayer.base.BaseWidget"))

function LoginItemView:ctor(title, value, type, gem, isCharge, clickCallback)
	self.layer = self:LoadUI("Cumulative_main1_list1.csb")

	self.title = title
	self.gem = gem
	self.data = value
	self.clickCallback = clickCallback

	self.ListView_1 = self.layer:getChildByName("ListView_1")
	self.Image_j1 = self.layer:getChildByName("Image_j1")
	self.Image_j2 = self.layer:getChildByName("Image_j2")
	self.ListView_1 = self.layer:getChildByName("ListView_1")
	self.Text_lj1 = self.layer:getChildByName("Text_lj1")
	self.Text_lj2 = self.layer:getChildByName("Text_lj2")
	self.Text_lj3 = self.layer:getChildByName("Text_lj3")
	self.Text_lj4 = self.layer:getChildByName("Text_lj4")

	--使用状态
	self.Button_1 = self.layer:getChildByName("Button_1")
	self.bt1Txt = self.Button_1:getChildByName("Text_6")
	
	--已领取
	self.Button_2 = self.layer:getChildByName("Button_2")
	self.bt2Txt = self.Button_2:getChildByName("Text_6")
	
	--禁用状态
	self.Button_3 = self.layer:getChildByName("Button_3")
	self.bt3Txt = self.Button_3:getChildByName("Text_6")

	self.bt1Txt:setString(g_tr("commonAwardGet"))
	self.bt2Txt:setString(g_tr("commonAwardGeted"))
	self.bt3Txt:setString(g_tr("commonAwardGet"))

	self.ListView_1:setItemsMargin(-10)

	if type == 1 then
		self.Text_lj1:setString(g_tr("actLogin"))
		self.Text_lj2:setString(title..g_tr("day"))
	elseif type == 2 then
		self.Text_lj1:setString(g_tr("actCharge"))
		self.Text_lj2:setString(title..g_tr("gold"))
	elseif type == 3 then
		self.Text_lj1:setString(g_tr("actConsume"))
		self.Text_lj2:setString(title..g_tr("gold"))
	end

	self.Text_lj3:setString("")
	if tonumber(gem) > tonumber(title) then
		self.Text_lj4:setString(title.."/"..title)
	else
		self.Text_lj4:setString(gem.."/"..title)
	end

	if isCharge == false then
		if tonumber(gem) >= tonumber(title) then
			self.Button_1:setVisible(true)
			self.Button_2:setVisible(false)
			self.Button_3:setVisible(false)
		else
			self.Button_1:setVisible(false)
			self.Button_2:setVisible(false)
			self.Button_3:setVisible(true)
			
		end
	else
		self.Button_1:setVisible(false)
		self.Button_2:setVisible(true)
		self.Button_3:setVisible(false)
	end

	self:showData()
	self:addEvent()
end

function LoginItemView:showData()
	for i=1, #self.data do
		local item = require("game.uilayer.activity.loginReward.RewardItemView").new(self.data[i])
		self.ListView_1:pushBackCustomItem(item)
	end
	
	self.ListView_1:setTouchEnabled(false)
	self.Image_j1:setVisible(false)
	self.Image_j2:setVisible(false)
	if #self.data > 5 then
	   self.Image_j1:setVisible(true)
       self.Image_j2:setVisible(true)
       self.ListView_1:setTouchEnabled(true)
	end
end

function LoginItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
				if self.clickCallback ~= nil then
					self.clickCallback(tonumber(self.title))
				end
			end
		end
	end

	self.Button_1:addTouchEventListener(proClick)
end

return LoginItemView