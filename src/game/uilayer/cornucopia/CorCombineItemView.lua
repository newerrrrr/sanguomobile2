local CorCombineItemView = class("CorCombineItemView", require("game.uilayer.base.BaseWidget"))

function CorCombineItemView:ctor(closeWin)
	self.closeWin = closeWin

	self.layer = self:LoadUI("GodGenerals_Smithrecast_Synthesis_list.csb")
	self.root = self.layer:getChildByName("scale_node")

	for i=1, 3 do
		self["scale_node_"..i] = self.root:getChildByName("Panel_"..i)
		self["scale_node_"..i.."_Image_4_0"] = self["scale_node_"..i]:getChildByName("Image_4_0")
		self["scale_node_"..i.."_Button_1"] = self["scale_node_"..i]:getChildByName("Button_1")
		self["scale_node_"..i.."_Text_1"] = self["scale_node_"..i]:getChildByName("Text_1")

		self["scale_node_"..i.."_Text_3"] = self["scale_node_"..i.."_Button_1"]:getChildByName("Text_3")
		self["scale_node_"..i.."_Text_3"]:setString(g_tr("viewGeneral"))
	end

	self:addEvent()
end

function CorCombineItemView:show(data1, data2, data3)
	self.data1 = data1
	self.data2 = data2
	self.data3 = data3

	self:processData("scale_node_1", self.data1)
	self:processData("scale_node_2", self.data2)
	self:processData("scale_node_3", self.data3)
end

function CorCombineItemView:processData(ui, data)
	if data == nil then
		self[ui]:setVisible(false)
		return
	end

	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self[ui.."_Image_4_0"] then
				local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, data.piece_item_id, self.closeWin)
				g_sceneManager.addNodeForUI(view)
			end
		end
	end

	local item = self:createHeroHead(data.id)
    item:setPosition(self[ui.."_Image_4_0"]:getContentSize().width/2, self[ui.."_Image_4_0"]:getContentSize().height/2)
    self[ui.."_Image_4_0"]:addChild(item)
	
	self[ui.."_Text_1"]:setString(g_tr(data.general_name))

	self[ui.."_Image_4_0"]:addTouchEventListener(proClick)
end

function CorCombineItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self["scale_node_1_Button_1"] then
				if self.data1 == nil then
					return
				end
				local GodGeneralEnhance = require("game.uilayer.godGeneral.GodGeneralEnhance"):create(self.data1.general_original_id)
        		g_sceneManager.addNodeForUI(GodGeneralEnhance)
        		if self.closeWin ~= nil then
        			self.closeWin()
        		end
			elseif sender == self["scale_node_2_Button_1"] then
				if self.data2 == nil then
					return
				end
				local GodGeneralEnhance = require("game.uilayer.godGeneral.GodGeneralEnhance"):create(self.data2.general_original_id)
        		g_sceneManager.addNodeForUI(GodGeneralEnhance)
        		if self.closeWin ~= nil then
        			self.closeWin()
        		end
			elseif sender == self["scale_node_3_Button_1"] then
				if self.data3 == nil then
					return
				end
				local GodGeneralEnhance = require("game.uilayer.godGeneral.GodGeneralEnhance"):create(self.data3.general_original_id)
        		g_sceneManager.addNodeForUI(GodGeneralEnhance)
        		if self.closeWin ~= nil then
        			self.closeWin()
        		end
			end
		end
	end

	self["scale_node_1_Button_1"]:addTouchEventListener(proClick)
	self["scale_node_2_Button_1"]:addTouchEventListener(proClick)
	self["scale_node_3_Button_1"]:addTouchEventListener(proClick)
end

function CorCombineItemView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

return CorCombineItemView