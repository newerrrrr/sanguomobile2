local DropItemView = class("DropItemView",function()
	return ccui.Widget:create()
end)

function DropItemView:ctor(type,configId,count)
	self:setName("")
	self:setOriginalName("")
	self:setCountEnabled(true)
	local color = cc.c3b(255, 255, 255)
	self:setNameColor(color)
	self:updateInfo(type,configId,count)
end

function DropItemView:clone()
	assert(false,'pls use  "DropItemView.new()" or "DropItemView:create()" instead')
end

function DropItemView:enableTip()
	g_itemTips.tip(self,self:getType(),self:getConfigId())
end

------
--  Getter & Setter for
--	  DropItemView._CountEnabled
-----
function DropItemView:setCountEnabled(CountEnabled)
	self._CountEnabled = CountEnabled
	if self._text then
		self._text:setVisible(CountEnabled)
	end
end

function DropItemView:getCountEnabled()
	return self._CountEnabled
end

------
--  Getter & Setter for
--	  DropItemView._NameVisible
-----
function DropItemView:setNameVisible(NameVisible)
	self._NameVisible = NameVisible

	if NameVisible == true then
		if self._nameLabel == nil then
			local size = self:getContentSize()
			local str = self:getName()
			local fontSize = 24
			local text = ccui.Text:create(str, "cocos/cocostudio_res/simhei.ttf", fontSize)
			text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			text:setAnchorPoint(cc.p(0.5, 0.5))
			text:setPosition(cc.p(0, -size.height/2 - fontSize/2 - 5))
			text:setTextColor(self._NameColor)
			text:enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,1),2)
			self._boaderAndFrame:addChild(text)
			self._nameLabel = text
		end
	  
		self._nameLabel:setString(self:getName())
		local contentSize = cc.size(math.max(self:getContentSize().width,self._nameLabel:getContentSize().width),self:getContentSize().height)
		self:updateContentSize(contentSize)
	end
	
	if self._nameLabel then
		self._nameLabel:setVisible(NameVisible)
	end
end

function DropItemView:getNameVisible()
	return self._NameVisible
end

------
--  Getter & Setter for
--	  DropItemView._NameColor
-----
function DropItemView:setNameColor(NameColor)
	self._NameColor = NameColor
	if self._nameLabel and NameColor then
		self._nameLabel:setTextColor(NameColor)
	end
end

function DropItemView:getNameColor()
	return self._NameColor
end

function DropItemView:updateContentSize(contentSize)
	self:setContentSize(contentSize)
	self._boaderAndFrame:setPosition(cc.p(contentSize.width/2,contentSize.height/2))
end

function DropItemView:updateInfo(type,configId,count)
	
	if self._boaderAndFrame == nil then
		self._boaderAndFrame = ccui.Widget:create()
		self:addChild(self._boaderAndFrame)
	end
	self._boaderAndFrame:removeAllChildren()
	self._nameLabel = nil
	self._text = nil
	
	local icon = nil
	local name = ""
	local originalName = ""
	local desc = ""
	local iconId = 0
	local rank = 1
	local chipIconId = 0
	local extraNumStr = ""
	if type == g_Consts.DropType.Resource 
	or type == g_Consts.DropType.Props
	then
	  local itemInfo = g_data.item[configId]
	  if itemInfo then 
		iconId = itemInfo.res_icon
		name = g_tr(itemInfo.item_name)
		originalName = g_tr_original(itemInfo.item_name)
		desc = g_tr(itemInfo.item_introduction)
		rank = itemInfo.rank
		if itemInfo.item_type == 4 then --武将信物
			chipIconId = 1018015
			if rank == 6 then
			   chipIconId = 1018043
			end
		elseif itemInfo.item_type == 5 then --武将将魂
			chipIconId = 1018051
		elseif itemInfo.item_type == 6 then --武器碎片
			chipIconId = 1018015
		end
		
		if tonumber(itemInfo.item_num_show) > 0 then
			local drops = g_gameTools.getDropGroupByDropIdArray(itemInfo.drop)
			assert(#drops == 1,"found drops > 1")--找到了多個符合條件的drop
			
			local num = drops[1][3]
			extraNumStr = string.formatnumberlogogram(num)
			desc = g_tr(itemInfo.item_introduction,{num = string.formatnumberthousands(num)})
		end

	  end 
	elseif type == g_Consts.DropType.General then
	  self:setCountEnabled(false)
	  local generalInfo  = g_data.general[configId]
	  if generalInfo then 
		iconId = generalInfo.general_icon
		name = g_tr(generalInfo.general_name)
		originalName = g_tr_original(generalInfo.general_name)
		desc = g_tr(generalInfo.description)
		rank = generalInfo.general_quality
		if rank == 6 and count and count > 0 then --神武将的count 用于等级
			self:setCountEnabled(true)
		end
	  end 
	elseif type == g_Consts.DropType.Equipment then
		local equipmentInfo = g_data.equipment[configId]
		if equipmentInfo then
		  iconId = equipmentInfo.equip_icon
		  name = g_tr(equipmentInfo.equip_name) 
		  originalName = g_tr_original(equipmentInfo.equip_name)
		  desc = g_tr(equipmentInfo.description)
		  rank = equipmentInfo.quality_id
		end
	elseif type == g_Consts.DropType.MasterEquipment then
		local equipmentInfo = g_data.equip_master[configId]
		if equipmentInfo then
		  iconId = equipmentInfo.equip_icon
		  name = g_tr(equipmentInfo.equip_name) 
		  originalName = g_tr_original(equipmentInfo.equip_name)
		  desc = g_tr(equipmentInfo.description)
		  rank = equipmentInfo.quality_id
		end

	elseif type == g_Consts.DropType.Soldier then
		local soldier = g_data.soldier[configId]
		if soldier then 
			iconId = soldier.img_head 
			name = g_tr(soldier.soldier_name)
			originalName = g_tr_original(soldier.soldier_name)
			desc = g_tr(soldier.soldier_introduction)
			rank = 1 
			
			local imgLv = g_resManager.getRes(soldier.img_level)
			if imgLv then
				self._boaderAndFrame:addChild(imgLv,999)
				imgLv:setPositionY(-103/2 + imgLv:getContentSize().height/2)
			end
		end 
	elseif type == g_Consts.DropType.Trap then
		local config = g_data.trap[configId]
		if config then
			iconId = config.img_head 
			name = g_tr(config.trap_name)
			originalName = g_tr_original(config.trap_name)
			desc = g_tr(config.description)
			rank = 1 
			
			local imgLv = g_resManager.getRes(config.img_level)
			if imgLv then
				self._boaderAndFrame:addChild(imgLv,999)
				imgLv:setPositionY(-103/2 + imgLv:getContentSize().height/2)
			end
		end
	else
		if type == nil then
			assert(false,"invaild drop type")
		else
			assert(false,"unknow drop type:"..type)
		end
	end
	
	icon = g_resManager.getRes(iconId) 
	local contentSize = cc.size(103,103)
	
	--背景
	if rank > 0 then
		local background = g_resManager.getRes(1011000 + rank)
		if background then
			self._boaderAndFrame:addChild(background)
			contentSize = background:getContentSize()
		end
		self:setRank(rank)
	else
		self:setRank(1)
	end
	
	local iconPath = g_resManager.getResPath(iconId)
	self:setIconPath(iconPath)
	self:setName(name)
	self:setOriginalName(originalName)
	self:setDesc(desc)
	self:setCount(count)
	self:setType(type)
	self:setConfigId(configId)
	
	--图标
	if icon then
		self._boaderAndFrame:addChild(icon)
		contentSize = icon:getContentSize()
	end
	self:setIconRender(icon)
	
	--碎片角标
	if chipIconId > 0 then
		local chipIcon = g_resManager.getRes(chipIconId)
		if chipIcon then
			self._boaderAndFrame:addChild(chipIcon)
			chipIcon:setPosition(cc.p(33,33))
			if rank == 6 then
				chipIcon:setPosition(cc.p(15,37))
			end
		end
	end
	
	--数量信息（一般是资源道具类型，比如一个20K粮食的道具）
	if extraNumStr and extraNumStr ~= "" then
		local bg = g_resManager.getRes(1018016)
		self._boaderAndFrame:addChild(bg)
		bg:setPosition(cc.p(0,12))
		
		local txt = cc.Label:createWithBMFont("cocostudio_res/fnt/mission_num.fnt", extraNumStr, cc.TEXT_ALIGNMENT_CENTER)
		txt:setAnchorPoint(cc.p(0.5, 0.5))
		txt:setPosition(cc.p(bg:getContentSize().width/2 + 7, bg:getContentSize().height/2))
		txt:setScale(0.75)
		bg:addChild(txt)
	end
	
	--边框
	local frameId = 1011200 + rank
	
	--将魂使用单独的边框Id
	if type == g_Consts.DropType.Props then
	  local itemInfo = g_data.item[configId]
	  if itemInfo.item_type == 5 then --武将将魂
		frameId = 1010137
	  end
	end
	
	local frame = g_resManager.getRes(frameId)
	if frame then
		self._boaderAndFrame:addChild(frame)
		contentSize = frame:getContentSize()
		
		local str = string.formatnumberlogogram(count)
		local color = cc.c3b(255, 255, 255)
		--local text = ccui.Text:create(str, "cocos/cocostudio_res/simhei.ttf", 24)
		local text = g_gameTools.createLabelDefaultFont()
		text:setSystemFontSize(24)
		text:setAnchorPoint(cc.p(1.0, 0.0))
		text:setPosition(cc.p(contentSize.width-10, 8))
		if rank == 6 then
			text:setPosition(cc.p(contentSize.width-27, 5))
			if type == g_Consts.DropType.General then --神武将等级
				text:setAnchorPoint(cc.p(0.5, 0.0))
				text:setPosition(cc.p(contentSize.width/2, 5))
				str = "Lv"..count
			end
		end
		text:setTextColor(color)
		--text:enableGlow(cc.c4b(0, 0, 0,255))
		--text:enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,1),2)
		text:enableOutline(cc.c4b(0, 0, 0,255),1)
		text:setString(str)
		frame:addChild(text)
		self._text = text
		self._text:setVisible(self._CountEnabled)
	end
	self:updateContentSize(contentSize)
		
end

function DropItemView:showGeneralServerStarLv(lv)
	local clientStar = math.floor(lv/5) + 1
	self:showGeneralStarLv(clientStar)
end

local starUIName = "staruiname"
function DropItemView:showGeneralStarLv(lv)
  assert(lv > 0 and lv <= 4)
	
  if self._boaderAndFrame:getChildByName(starUIName) then
	self._boaderAndFrame:removeChildByName(starUIName)
  end
  --武将星级
  local type = self:getType()
  local rank = self:getRank()
  local configId = self:getConfigId()
  if type == g_Consts.DropType.General then
	local generalInfo  = g_data.general[configId]
	if generalInfo then 
	  local layer = cc.CSLoader:createNode("wujiang_xingxing.csb")
	  layer:setName(starUIName)
	  self._boaderAndFrame:addChild(layer)
	  if rank == 6 then --神武将
		  layer:getChildByName("Panel_1"):setVisible(true)
		  layer:getChildByName("Panel_xi5"):setVisible(false)
		  for i=1, 4 do
			 local isLighted = lv >= i
			 layer:getChildByName("Panel_1"):getChildByName("Panel_xi"..i):getChildByName("Image_2"):setVisible(isLighted)
			 layer:getChildByName("Panel_1"):getChildByName("Panel_xi"..i):getChildByName("Image_1"):setVisible(not isLighted)
		  end
	  else
		  layer:getChildByName("Panel_1"):setVisible(false)
		  layer:getChildByName("Panel_xi5"):setVisible(false) --暂时不显示普通武将的星级
	  end
	end 
  end
end


------
--  Getter & Setter for
--	  DropItemView._IconRender
-----
function DropItemView:setIconRender(IconRender)
	self._IconRender = IconRender
end

function DropItemView:getIconRender()
	return self._IconRender
end

------
--  Getter & Setter for
--	  DropItemView._Name
-----
function DropItemView:setName(Name)
	self._Name = Name
	if self._nameLabel then
		self._nameLabel:setString(Name)
	end
end

function DropItemView:getName()
	return self._Name
end

------
--  Getter & Setter for
--	  DropItemView._OriginalName
-----
function DropItemView:setOriginalName(OriginalName)
	self._OriginalName = OriginalName
end

function DropItemView:getOriginalName()
	return self._OriginalName
end

------
--  Getter & Setter for
--	  DropItemView._Desc
-----
function DropItemView:setDesc(Desc)
	self._Desc = Desc
end

function DropItemView:getDesc()
	return self._Desc
end

------
--  Getter & Setter for
--	  DropItemView._Count
-----
function DropItemView:setCount(Count)
	self._Count = Count
	if self._text then
		self._text:setString(tostring(self._Count))
	end
end

function DropItemView:getCount()
	return self._Count
end

function DropItemView:setCountColor(color)
	if self._text then
		self._text:setTextColor(color)
	end
end

function DropItemView:getCountColor()
	if self._text then
		return self._text:getTextColor()
	end
end

------
--  Getter & Setter for
--	  DropItemView._IconPath
-----
function DropItemView:setIconPath(IconPath)
	self._IconPath = IconPath
end

function DropItemView:getIconPath()
	return self._IconPath
end

------
--  Getter & Setter for
--	  DropItemView._type
-----
function DropItemView:setType(type)
	self._type = type
end

function DropItemView:getType()
	return self._type
end

------
--  Getter & Setter for
--	  DropItemView._ConfigId
-----
function DropItemView:setConfigId(ConfigId)
	self._ConfigId = ConfigId
end

function DropItemView:getConfigId()
	return self._ConfigId
end

------
--  Getter & Setter for
--	  DropItemView._Rank
-----
function DropItemView:setRank(Rank)
	self._Rank = Rank
end

function DropItemView:getRank()
	return self._Rank
end

function DropItemView:setIconIsGray(isGray)
	local function updateBrightState(node) 
		for k, v in pairs(node:getChildren()) do 
			if v.loadTexture then --只针对图片 
				if isGray then 
					v:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.shaderMode.shader_gray))
				else 
					v:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.originMode))
				end 
			end 
			if v:getChildrenCount() > 0 then 
				updateBrightState(v) 
			end 
		end 
	end 

	updateBrightState(self) 
end 



return DropItemView