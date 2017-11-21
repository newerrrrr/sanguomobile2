local SelGeneralView = class("SelGeneralView", require("game.uilayer.base.BaseLayer"))

local sel = 0

function SelGeneralView:ctor(data, updateUI)
	SelGeneralView.super.ctor(self)

    self.uiList = {}

	self.data = data

    sel = 0

    self.updateUI = updateUI

	self.layer = self:loadUI("activity3_Members01_01.csb")

	self.root = self.layer:getChildByName("scale_node")

	self.close_btn = self.root:getChildByName("close_btn")
	self.Text_1 = self.root:getChildByName("Text_1")
	self.Button_1 = self.root:getChildByName("Button_1")
	self.txtButton_1 = self.Button_1:getChildByName("Text_12")
    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.Text_2_0 = self.root:getChildByName("Text_2_0")
    self.Text_2_0:setString("")
    self.Text_ss1 = self.root:getChildByName("Text_ss1")
    self.Text_ss1:setString("")

    self.txtButton_1:setString(g_tr("sendFomation"))
    self.Text_1:setString(g_tr("selectGeneralTitle"))

    self:initFun()
    self:setData()
    self:addEvent()
end

function SelGeneralView:initFun()
    self.clickCallback = function(data, fun)
        if data[2] == true then
            sel = sel - 1
            data[2] = false
            fun(data)
            for i=1, #self.data do
                if data[1] == self.data[i][1] then
                    self.data[i][2] = false
                    break 
                end
            end
        else
            if sel < 6 then
                sel = sel + 1
                data[2] = true
                fun(data)
                for i=1, #self.data do
                    if data[1] == self.data[i][1] then
                        self.data[i][2]  = true
                        fun(data)
                        break 
                    end
                end
            end
        end

        self.Text_2_0:setString(g_tr("hasSelectedGeneral",{num = sel.."/6"}))
    end
end

function SelGeneralView:setData()
	self.ListView_1:removeAllItems()
	local len = 0
	if (#self.data)%2 == 1 then
		len = ((#self.data) + 1)/2
	else
		len = (#self.data)/2
	end

    local idx_s = 1 
    local idx_e = len
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
            item = require("game.uilayer.activity.crossServer.SelGeneralItemView").new(self.clickCallback)
            self.ListView_1:pushBackCustomItem(item)

			item:show(self.data[idx_s*2-1], self.data[idx_s*2])

			if self.data[idx_s*2-1] and self.data[idx_s*2-1][2] == true then
				sel = sel + 1
			end

			if self.data[idx_s*2] and self.data[idx_s*2][2] == true then
				sel = sel + 1
			end

            idx_s = idx_s + 1 

            table.insert(self.uiList, item)
        else
        	self.Text_2_0:setString(g_tr("hasSelectedGeneral",{num = sel.."/6"}))
            --加载完成
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

function SelGeneralView:schedule(callback, delay)
      local delay = cc.DelayTime:create(delay)
      local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
      local action = cc.RepeatForever:create(sequence)
      self:runAction(action)
      return action
end 

function SelGeneralView:unschedule(action)
    self:stopAction(action)
end

function SelGeneralView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.close_btn == sender then
				self:close()
            elseif sender == self.Button_1 then
                local result = {}

                for i=1, #self.uiList do
                    local data = self.uiList[i]:getData1()
                    if data and data[2] == true then
                        table.insert(result, data[1])
                    end
                    
                    data = self.uiList[i]:getData2()
                    if data and data[2] == true then
                        table.insert(result, data[1])
                    end

                    if #result >= 6 then
                        break
                    end
                end
                
                if self.updateUI ~= nil then
                    self.updateUI(result)
                end
                
                self:close()
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
    self.Button_1:addTouchEventListener(proClick)
end

return SelGeneralView