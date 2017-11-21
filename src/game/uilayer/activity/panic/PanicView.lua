local PanicView = class("PanicView", function()
	return cc.Layer:create()
end)

function PanicView:onExit()
	if self.time ~= nil then
		self:unschedule(self.time)
		self.time = nil
	end
end

function PanicView:ctor()
	self.layer = cc.CSLoader:createNode("activity4_mian2.csb")

	self:addChild(self.layer)

	self.Text_n1 = self.layer:getChildByName("Text_n1")
	self.Text_z1 = self.layer:getChildByName("Text_z1")
	self.Text_s1 = self.layer:getChildByName("Text_s1")
	self.Text_z2 = self.layer:getChildByName("Text_z2")
	self.Text_s2 = self.layer:getChildByName("Text_s2")
	self.Text_z3 = self.layer:getChildByName("Text_z3")

	self.Panel_5 = self.layer:getChildByName("Panel_5")
	self.Text_1 = self.Panel_5:getChildByName("Text_1")
	self.Text_2 = self.Panel_5:getChildByName("Text_2")
	self.Text_2_0 = self.Panel_5:getChildByName("Text_2_0")
	self.Text_3 = self.Panel_5:getChildByName("Text_3")
	self.Text_3_0 = self.Panel_5:getChildByName("Text_3_0")
	self.Text_4 = self.Panel_5:getChildByName("Text_4")
	self.Text_4_0 = self.Panel_5:getChildByName("Text_4_0")
	self.Text_2_0_0 = self.Panel_5:getChildByName("Text_2_0_0")

	self.ListView_1 = self.layer:getChildByName("ListView_1")

	--初始化
	self.Text_n1:setString("")
	self.Text_z1:setString("")
	self.Text_s1:setString("")
	self.Text_z2:setString("")
	self.Text_s2:setString("")
	self.Text_z3:setString("")

	self.Text_1:setString("")
	self.Text_2:setString("")
	self.Text_2_0:setString("")
	self.Text_3:setString("")
	self.Text_3_0:setString("")
	self.Text_4:setString("")
	self.Text_4_0:setString("")
	self.Text_2_0_0:setString("")

	if self.richTxt == nil then
		self.richTxt = g_gameTools.createRichText(self.Text_2_0, "")
	end

	if self.richTxt1 == nil then
		self.richTxt1 = g_gameTools.createRichText(self.Text_1, "")
	end

	if self.richTxt2 == nil then
		self.richTxt2 = g_gameTools.createRichText(self.Text_n1, "")
	end

	local function getData(data)
		self.data = data.activity

		if self.data == nil then
			return
		end

		if self.data.end_time < g_clock.getCurServerTime() then
			g_airBox.show(g_tr("actEndTIme"))
			return
		end

		self.Text_z1:setString(g_tr("panicTip1"))
		self.Text_z2:setString(g_tr("panicTip2"))
		self.Text_z3:setString(g_tr("minute"))

		self:processData()
	end

	g_activityData.RequestPanicShow(getData)
end

function PanicView:processData()
	self.result = {}

	self.oneData = nil

	self.curDay = nil

	--先循环天数
	for i=1, #self.data.activity_para.reward do
		
		local curData = self.data.activity_para.reward[i]

		for j=1, #curData.ar do
			
			local curTime = g_clock.getCurServerTime()

			if curTime >= curData.ar[j].beginTime and curTime <= curData.ar[j].endTime then
				
				curData.ar[j].round = j

				self.oneData = curData.ar[j]

				self.curDay = self.data.activity_para.reward[i]

				table.insert(self.result, curData.ar[j])

				if curData.ar[j+1] ~= nil then
					curData.ar[j+1].round = j+1
					table.insert(self.result, curData.ar[j+1])

					if curData.ar[j+2] ~= nil then
						curData.ar[j+2].round = j+2
						table.insert(self.result, curData.ar[j+2])
					end
				end
			
				break
			else
				if j == 1 then
					if curTime <= curData.ar[j].beginTime then
						curData.ar[j].round = j

						self.oneData = curData.ar[j]

						self.curDay = self.data.activity_para.reward[i]

						table.insert(self.result, curData.ar[j])

						if curData.ar[j+1] ~= nil then
							curData.ar[j+1].round = j+1
							table.insert(self.result, curData.ar[j+1])

							if curData.ar[j+2] ~= nil then
								curData.ar[j+2].round = j+2
								table.insert(self.result, curData.ar[j+2])
							end
						end
					
						break
					end
				else
					if curTime > curData.ar[j-1].endTime and curTime < curData.ar[j].beginTime then
						curData.ar[j].round = j

						self.oneData = curData.ar[j]

						self.curDay = self.data.activity_para.reward[i]

						table.insert(self.result, curData.ar[j])

						if curData.ar[j+1] ~= nil then
							curData.ar[j+1].round = j+1
							table.insert(self.result, curData.ar[j+1])

							if curData.ar[j+2] ~= nil then
								curData.ar[j+2].round = j+2
								table.insert(self.result, curData.ar[j+2])
							end
						end
					
						break
					end
				end
			end
		end

		if self.oneData ~= nil then
			break
		end
	end

	if self.oneData == nil then
		g_airBox.show(g_tr("actEndTIme"))
		return
	end

	self:showData()

	self:showTime()
end

function PanicView:showData()
	self.ListView_1:removeAllItems()

	self.richTxt2:setRichText(g_tr("panicInfo", {time = self.curDay.time}))
	self.Text_s1:setString((#self.curDay.ar).."")
	self.Text_s2:setString(math.floor((self.oneData.endTime - self.oneData.beginTime)/60).."")

	if self.curDay.gem <= 0 then
		self.richTxt1:setRichText(g_tr("cannotEnter"))
	else
		self.richTxt1:setRichText(g_tr("canEnter"))
	end

	if self.result[1] ~= nil then
		self.Text_2:setString(g_tr("panicRound", {round = self.result[1].round}))
	else
		self.Text_2:setString("")
		self.Text_2_0:setString("")
		self.Text_2_0_0:setString("")
	end
	
	if self.result[2] ~= nil then
		self.Text_3:setString(g_tr("panicRound", {round = self.result[2].round}))
	else
		self.Text_3:setString("")
		self.Text_3_0:setString("")
	end

	if self.result[3] ~= nil then
		self.Text_4:setString(g_tr("panicRound", {round = self.result[3].round}))
	else
		self.Text_4:setString("")
		self.Text_4_0:setString("")
	end
	
	for i=1, #self.oneData.items do
		local item = require("game.uilayer.activity.panic.PanicItemView").new(self.oneData.items[i], self.oneData.beginTime)

		self.ListView_1:pushBackCustomItem(item)
	end
end

function PanicView:showTime()

	local function update()
		local d1 = 0
		if g_clock.getCurServerTime() < self.result[1].beginTime then

			d1 = self.result[1].beginTime - g_clock.getCurServerTime()
			
			self.richTxt:setRichText("|<#253,247,106#>"..g_tr("backTime").."||<#253,208,110#>"..g_gameTools.convertSecondToString(d1).."|")

			self.Text_2_0_0:setString("")

		elseif g_clock.getCurServerTime() >= self.result[1].beginTime and g_clock.getCurServerTime() <= self.result[1].endTime then
			d1 = self.result[1].endTime - g_clock.getCurServerTime()
			
			self.richTxt:setRichText("|<#72,255,98#>"..g_tr("panicIng").."|")

			self.Text_2_0_0:setString(g_gameTools.convertSecondToString(d1))
		else
			self.richTxt:setRichText("")

			self.Text_2_0_0:setString("")

			self:updateUI()
		end

		if self.result[2] ~= nil then
			local d2 = self.result[2].beginTime - g_clock.getCurServerTime()
			self.Text_3_0:setString(g_tr("backTime")..g_gameTools.convertSecondToString(d2))
			if d2 <= 0 then
				self:updateUI()
			end
		else
			self.Text_3:setString("")
			self.Text_3_0:setString("")
		end
		
		if self.result[3] ~= nil then
			local d3 = self.result[3].beginTime - g_clock.getCurServerTime()
			self.Text_4_0:setString(g_tr("backTime")..g_gameTools.convertSecondToString(d3))
			if d3 <= 0 then
				self:updateUI()
			end
		else
			self.Text_4:setString("")
			self.Text_4_0:setString("")
		end
	end

	if self.time ~= nil then
		self:unschedule(self.time)
		self.time = nil
	end

	self.time = self:schedule(update, 1)
	update()
end

function PanicView:updateUI()
	local function getData(data)
		self.data = data.activity

		if self.data == nil then
			return
		end

		if self.data.end_time < g_clock.getCurServerTime() then
			g_airBox.show(g_tr("actEndTIme"))
			self:unschedule(self.time)
			self.time = nil
			return
		end

		self:processData()
	end

	g_activityData.RequestPanicShow(getData)
end

function PanicView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function PanicView:unschedule(action)
  self:stopAction(action)
end

return PanicView