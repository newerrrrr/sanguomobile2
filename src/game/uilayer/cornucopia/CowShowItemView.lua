local CowShowItemView = class("CowShowItemView", require("game.uilayer.base.BaseWidget"))

function CowShowItemView:ctor()
	self.layer = self:LoadUI("TheObservatory_Panel_list2.csb")

	for i=1, 6 do
		self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Image_22"] = self["Panel_"..i]:getChildByName("Image_22")
		self["Panel_"..i.."_name"] = self["Panel_"..i]:getChildByName("name")
	end
end

function CowShowItemView:show(data1, data2, data3, data4, data5, data6)
	self:process("Panel_1", data1)
	self:process("Panel_2", data2)
	self:process("Panel_3", data3)
	self:process("Panel_4", data4)
	self:process("Panel_5", data5)
	self:process("Panel_6", data6)
end

function CowShowItemView:process(ui, data)
	if data == nil then
		self[ui]:setVisible(false)
		return
	end

	local icon = require("game.uilayer.common.DropItemView").new(data[1], data[2], data[3])
	icon:enableTip()
	self[ui.."_Image_22"]:addChild(icon)
	icon:setPosition(cc.p(self[ui.."_Image_22"]:getContentSize().width/2, self[ui.."_Image_22"]:getContentSize().height/2))
	self[ui.."_name"]:setString(icon:getName())

	if data[1] == 2 and data[2] >= 41001 and  data[2] <= 41111 then
		local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_ChouKaKaPai/Effect_ChouKaKaPai.ExportJson", "Effect_ChouKaKaPai")
		armature:setPosition(cc.p(self[ui.."_Image_22"]:getContentSize().width/2,self[ui.."_Image_22"]:getContentSize().height/2 ))
		self[ui.."_Image_22"]:addChild(armature)
		animation:play("Animation1")
	end
end

return CowShowItemView