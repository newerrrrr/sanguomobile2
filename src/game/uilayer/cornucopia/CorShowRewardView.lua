local CorShowRewardView = class("CorShowRewardView", require("game.uilayer.base.BaseLayer"))

function CorShowRewardView:ctor(tab)
	CorShowRewardView.super.ctor(self)

	self.curTab = tab

	self.layer = self:loadUI("TheObservatory_Panel_list1.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.close_btn = self.root:getChildByName("close_btn")
	self.text = self.root:getChildByName("bg_goods_name"):getChildByName("text")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	self.data = {}
	self:processData()
	self:setUI()
	self:addEvent()
end

function CorShowRewardView:processData()
	print(#self.data, "@@@@@@@@@@@@@@@@@@@1")
	if self.curTab == 1 then
		for key, value in pairs(g_data.drop[230001].drop_data) do
			table.insert(self.data, value)
		end

		for key, value in pairs(g_data.drop[230002].drop_data) do
			table.insert(self.data, value)
		end
		print(#self.data, "@@@@@@@@@@@@@@@@@@@3")
	else
		for key, value in pairs(g_data.drop[230006].drop_data) do
			table.insert(self.data, value)
		end
		for key, value in pairs(g_data.drop[230004].drop_data) do
			table.insert(self.data, value)
		end
		for key, value in pairs(g_data.drop[230005].drop_data) do
			table.insert(self.data, value)
		end
	end
end

function CorShowRewardView:setUI()
	local len = 0
	if (#self.data)%6 == 0 then
		len = #self.data/6
	else
		len = math.ceil((#self.data)/6)
	end

	self:loadItem(len)
end

function CorShowRewardView:loadItem(len)
    local idx_s = 1 
    local idx_e = len
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
            item = require("game.uilayer.cornucopia.CowShowItemView").new()
            self.ListView_1:pushBackCustomItem(item)
            item:show(self.data[idx_s*6-5], self.data[idx_s*6-4], self.data[idx_s*6-3], self.data[idx_s*6-2], self.data[idx_s*6-1], self.data[idx_s*6])
            idx_s = idx_s + 1
            print(idx_s, len, "@@@@@@@@@@@@@@@@@@")
        else
            if self.frameLoadTimer then 
                self:unschedule(self.frameLoadTimer) 
                self.frameLoadTimer = nil  
            end 
        end
    end

    --分侦加载
    if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
    end 
    self.frameLoadTimer = self:schedule(loadItem, 0) 
end

function CorShowRewardView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
end

return CorShowRewardView