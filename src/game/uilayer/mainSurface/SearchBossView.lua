local SearchBossView = class("SearchBossView")

function SearchBossView:ctor(mc, toPos)
	self.gotoPos = toPos
	self.layer = mc

	self.Panel_soug = self.layer:getChildByName("Panel_soug")
	self.Text_1 = self.Panel_soug:getChildByName("Text_1")
	self.Text_2 = self.Panel_soug:getChildByName("Text_2")
	self.Text_3 = self.Panel_soug:getChildByName("Text_3")
	self.Image_dubiao = self.Panel_soug:getChildByName("Image_dubiao")
	self.Image_tou = self.Panel_soug:getChildByName("Image_tou")

	self.Image_yb = self.layer:getChildByName("Image_yb")
	self.Image_bt = self.layer:getChildByName("Image_bt")

	self.Button_qw = self.Panel_soug:getChildByName("Button_qw")
	self.btnText_2 = self.Button_qw:getChildByName("Text_2")
	self.btnText_2:setString(g_tr("gotoPathBtn"))
	self.LoadingBar_1 = self.Panel_soug:getChildByName("LoadingBar_1")
	self.Text_zb = self.Panel_soug:getChildByName("Text_zb")
	self.Text_jul = self.Panel_soug:getChildByName("Text_jul")

	self.Panel_soug:setVisible(false)

	self:addEvent()
end

function SearchBossView:show(data)
	if g_MapCollectMode.GetBossData() == nil then
		self.data = data
	else
		self.data = g_MapCollectMode.GetBossData()
	end

	if self.data == nil then
		self.Panel_soug:setVisible(false)
		self.Image_yb:setVisible(true)
		self.Image_bt:setVisible(true)
		return
	end

	self.player = g_PlayerMode.GetData()
	
	self.Image_yb:setVisible(false)
	self.Image_bt:setVisible(false)
	self.Panel_soug:setVisible(true)

	local node = g_gameTools.getWorldMapElementDisplay(self.data.element_id)
	node:setPosition(self.Image_dubiao:getContentSize().width/2, self.Image_dubiao:getContentSize().height/2)
    self.Image_dubiao:addChild(node)

	local mapData = g_data.map_element[tonumber(self.data.element_id)]
	self.Text_1:setString(g_tr(mapData.name))
	self.Text_2:setString("lv: "..g_tr(mapData.level))
	self.Text_3:setString("x:"..self.data.x.." y:"..self.data.y)

	local npcData = g_data.npc[40000 + tonumber(mapData.level)]

	local value = self.data.durability * 100 / npcData.life
	value = value - value%1
	self.LoadingBar_1:setPercent(value)

	self.Image_tou:loadTexture(g_resManager.getResPath(mapData.img_boss_head))
	local npc = g_data.npc[mapData.npc_id]
	self.Text_zb:setString(g_tr("searchCommondPower", {power=npc.recommand_power}))

	local runLength = cc.pGetDistance(cc.p(self.player.x, self.player.y),cc.p(tonumber(self.data.x), tonumber(self.data.y)))
    runLength = runLength - runLength%1
    self.Text_jul:setString(g_tr("menu_distance")..": "..runLength..g_tr("worldmap_KM"))
end

function SearchBossView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_qw then
				local player = g_PlayerMode.GetData()
				if (player.gift_gem + player.rmb_gem) < 10 then
					g_gameTools.tipGotoPayLayer()
					return
				end
	
				if self.gotoPos ~= nil and self.data ~= nil then
					self.gotoPos(self.data)
				end
			end
		end
	end

	self.Button_qw:addTouchEventListener(proClick)
end

return SearchBossView