local CorGodView = class("CorGodView", function()
	return cc.Layer:create()
end)

function CorGodView:ctor()
	self.layer = cc.CSLoader:createNode("jitian_Panel.csb")

	self:addChild(self.layer)

	self.root = self.layer:getChildByName("scale_node")
	self.ListView_2 = self.root:getChildByName("ListView_2")
	self.Text_c1 = self.root:getChildByName("Text_c1")
	self.Text_c1_0 = self.root:getChildByName("Text_c1_0")

	local playerInfo = g_playerInfoData.GetData()
	self.Text_c1:setString(g_tr("corGodFree", {times = playerInfo.sacrifice_free_flag}))

	self.Text_c1_0:setString(g_tr("corHalfChance"))

	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_JiTianBeiJingXunHuan/Effect_JiTianBeiJingXunHuan.ExportJson", "Effect_JiTianBeiJingXunHuan")
	armature:setPositionX(self.root:getContentSize().width/2)
    armature:setPositionY(self.root:getContentSize().height/2)
    self.root:addChild(armature)
    animation:play("Animation1")

	self:initData()
	
	g_guideManager.execute()
end

function CorGodView:initData()
	local function update()
		local playerInfo = g_playerInfoData.GetData()
		self.Text_c1:setString(g_tr("corGodFree", {times = playerInfo.sacrifice_free_flag}))
	end

	for i=1, 4 do
		local item = require("game.uilayer.cornucopia.CorGodItemView").new(i, update)
		
		if i == 3 then --3为吴国按钮
			 g_guideManager.registComponent(9999982,item)
		end
		
		self.ListView_2:pushBackCustomItem(item)
	end
end

function CorGodView:getInAni()
	return false
end

return CorGodView