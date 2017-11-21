
--祭天单抽、10抽界面

local CorShowGeneralView = class("CorShowGeneralView", require("game.uilayer.base.BaseLayer"))

--[1 => 9040001, 2 => 9040002, 3 => 9040003, 4 => 9040004]
function CorShowGeneralView:ctor(type, updateData)
	self.type = type

	self.updateData = updateData

	g_playerInfoData.RequestData()

	self.layer = self:loadUI("jitian_Panel_1.csb")

	self.root = self.layer:getChildByName("scale_node")
	self.ListView_2 = self.root:getChildByName("ListView_2")
	self.Text_2 = self.root:getChildByName("Text_2")
	self.Text_3 = self.root:getChildByName("Text_3")
	self.Button_1 = self.root:getChildByName("Button_1")
	
	--新手注册抽一次按钮
	g_guideManager.registComponent(9999983,self.Button_1)
	
	self.Button_10 = self.root:getChildByName("Button_10")
	self.ImgCost = self.root:getChildByName("Image_y1") 
	self.Text_2_0 = self.root:getChildByName("Text_2_0")
	self.Text_3_0 = self.root:getChildByName("Text_3_0")
	self.Text_2_1 = self.root:getChildByName("Text_2_1")
	self.close_btn = self.root:getChildByName("close_btn")
	self.Panel_hong = self.root:getChildByName("Panel_hong")

	self.Text_3:setString(g_tr("toGodInfo"))
	self.Button_1:getChildByName("Text_2_2"):setString(g_tr("oneTimeToGod"))
	self.Button_10:getChildByName("Text_2_2"):setString(g_tr("tenTimeToGod"))
	self.Text_3_0:setString(g_data.cost[10024].cost_num.."")

	self:updateBtn()
	self:addEvent()

	if self.type == g_Consts.CountryType.wei then
		self.Text_2:setString(g_tr("country3")..g_tr("sendToGod"))
		self.data = g_data.drop[g_data.gamble_general_soul[1].drop_id]
	elseif self.type == g_Consts.CountryType.shu then
		self.Text_2:setString(g_tr("country2")..g_tr("sendToGod"))
		self.data = g_data.drop[g_data.gamble_general_soul[2].drop_id]
	elseif self.type == g_Consts.CountryType.wu then
		self.Text_2:setString(g_tr("country1")..g_tr("sendToGod"))
		self.data = g_data.drop[g_data.gamble_general_soul[3].drop_id]
	elseif self.type == g_Consts.CountryType.qun then
		self.Text_2:setString(g_tr("country4")..g_tr("sendToGod"))
		self.data = g_data.drop[g_data.gamble_general_soul[4].drop_id]
	end

	self:initFun()
	self:show()
	
	g_guideManager.execute()
end

function CorShowGeneralView:initFun()

	--抽卡回调
	self.showResult = function(data)
		local gem = 0
		if self.times == 1 then 
			self.playerInfo = g_playerInfoData.GetData()
			if self.playerInfo.sacrifice_flag == 1 then --半价
				gem = g_data.cost[10022].cost_num
			else
				gem = g_data.cost[10023].cost_num
			end
		elseif self.times == 10 then
			gem = g_data.cost[10024].cost_num
		end
		g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CorReward").new(data, self.times, 4, 1, self.nextTenTime, self.nextOntTime, nil, gem))
		self:updateBtn()
	end

	--再抽一次回调
	self.nextOntTime = function()
		self.times = 1
		self.playerInfo = g_playerInfoData.GetData()
		if self.playerInfo.sacrifice_free_flag == 1 then --免费
			g_corData.sacrificeToHeaven(0, 1, self.type, 0, self.showResult)
		else
			local num = g_BagMode.findItemNumberById(52005)
			if num > 0 then 
				g_corData.sacrificeToHeaven(0, 0, self.type, 1, self.showResult)
			else 
				--半价/全价
				g_corData.sacrificeToHeaven(0, 0, self.type, 0, self.showResult)
			end 
		end
	end

	--再抽十次回调
	self.nextTenTime = function()
		self.times = 10
		g_corData.sacrificeToHeaven(1, 0, self.type, 0, self.showResult)
	end
end

function CorShowGeneralView:show()
	local data = self.data.drop_data

	local len = 0
	if (#data)%8 == 0 then
		len = (#data)/8
	else
		len = math.ceil((#data)/8)
	end

	for i= 1, len do
		local item = require("game.uilayer.cornucopia.CorGeneralItemView").new()
		self.ListView_2:pushBackCustomItem(item)

		item:show(data, i*8 - 7)
	end
end

--更新按钮状态

--优先级: 免费 > 使用道具 > 半价 > 原价
function CorShowGeneralView:updateBtn()
	self.playerInfo = g_playerInfoData.GetData()

	print("free_flag, half_price_flag = ", self.playerInfo.sacrifice_free_flag, self.playerInfo.sacrifice_flag)

	if self.playerInfo.sacrifice_free_flag == 1 then --免费 1 次
		self.Text_2_0:setString(g_tr("godFreeTimes", {num = 1}))
		self.Text_2_1:setString("")
		self.Panel_hong:setVisible(false)
		self.ImgCost:setVisible(false) 
	else
		self.ImgCost:setVisible(true) 
		self.ImgCost:loadTexture(g_resManager.getResPath(1999007)) --默认元宝
		self.ImgCost:setScale(0.65)


		local num = g_BagMode.findItemNumberById(52005) --祭天券
		if num > 0 then 
			self.ImgCost:loadTexture(g_resManager.getResPath(g_data.item[52005].res_icon))
			self.ImgCost:setScale(0.85)
			self.Text_2_0:setString("x"..num)
			self.Panel_hong:setVisible(false)
			self.Text_2_1:setString("")
		else 
			if self.playerInfo.sacrifice_flag == 1 then --半价
				self.Text_2_0:setString(g_data.cost[10022].cost_num.."") --半价元宝
				self.Panel_hong:setVisible(true)
				self.Text_2_1:setString(g_tr("originGold")..g_data.cost[10023].cost_num.."") --原价元宝
			else 
				self.Text_2_0:setString(g_data.cost[10023].cost_num.."")
				self.Text_2_1:setString("")
				self.Panel_hong:setVisible(false)				
			end 
		end 
	end
end

function CorShowGeneralView:addEvent()
	local function proClick(sender , eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			elseif self.Button_1 == sender then --单抽
				self.times = 1
				self.playerInfo = g_playerInfoData.GetData()

				if self.playerInfo.sacrifice_free_flag == 1 then
					g_corData.sacrificeToHeaven(0, 1, self.type, 0, self.showResult)
					if self.updateData ~= nil then
						self.updateData()
					end
				else

					local num = g_BagMode.findItemNumberById(52005)
					if num > 0 then --使用道具
						g_corData.sacrificeToHeaven(0, 0, self.type, 1, self.showResult)
					else 
						--半价/全价
						g_corData.sacrificeToHeaven(0, 0, self.type, 0, self.showResult)
					end 
				end
			elseif self.Button_10 == sender then
				self.times = 10
				g_corData.sacrificeToHeaven(1, 0, self.type, 0, self.showResult)
			end
		end
	end
	self.close_btn:addTouchEventListener(proClick)
	self.Button_1:addTouchEventListener(proClick)
	self.Button_10:addTouchEventListener(proClick)
end

return CorShowGeneralView