local settingNoticeLayer = {}
setmetatable(settingNoticeLayer,{__index = _G})
setfenv(1,settingNoticeLayer)

local c_col_gap = 5
local c_row_gap = 1


local function _checkPlayerPushTag(t)
	local ppt = g_PlayerMode.GetData().push_tag
	if ppt then
		local nt = tonumber(t)
		for k , v in pairs(ppt) do
			if tonumber(v) == nt then
				return true
			end
		end
	end
	return false
end

function create()
	local widget = g_gameTools.LoadCocosUI("setThe_main1.csb", 5)
	
	local scale_node = widget:getChildByName("scale_node")
	
	local cells = {}
	
	local function onButtonClose(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			local needUpdate = false
			for k , v in ipairs(cells) do
				if v.lua_noticeStatus ~= _checkPlayerPushTag(v.lua_noticeType) then
					needUpdate = true
					break
				end
			end
			if needUpdate then
				local status_array = {}
				for k , v in ipairs(cells) do
					if v.lua_noticeStatus then
						status_array[(#status_array + 1)] = v.lua_noticeType
					end
				end
				g_sgHttp.postData("player/updatePushTag", {pushTag = status_array}, nil)
			end
			widget:removeFromParent()
		end
	end
	scale_node:getChildByName("close_btn"):addTouchEventListener(onButtonClose)
	
	scale_node:getChildByName("text"):setString(g_tr("setting_noticeText"))
	
	local scroll = scale_node:getChildByName("ScrollView_1")
	
	do
		local function onButtonCell(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
				local cell = sender:getParent()
				if cell then
					cell.lua_noticeStatus = not cell.lua_noticeStatus
					cell:getChildByName("Image_3"):setVisible(cell.lua_noticeStatus)
				end
			end
		end
		local height = 0
		local count = 0		
		for k , v in pairs(g_data.push_notice_system) do
			count = count + 1
			local cell = cc.CSLoader:createNode("setThe_main1_0.csb")
			cell.lua_noticeType = k
			cell.lua_noticeStatus = _checkPlayerPushTag(cell.lua_noticeType)
			cell:getChildByName("Image_3"):setVisible(cell.lua_noticeStatus)
			cell:getChildByName("Text_c2"):setString(g_tr(v.title))
			cell:getChildByName("Text_2"):setString(g_tr(v.desc))
			if count % 2 ~= 0 then
				if count > 1 then
					height = height + cell:getContentSize().height + c_col_gap
				else
					height = height + cell:getContentSize().height
				end
			end
			cell:getChildByName("Image_1"):addTouchEventListener(onButtonCell)
			cells[count] = cell
		end
		local viewSize = scroll:getContentSize()
		scroll:setInnerContainerSize(cc.size(viewSize.width, viewSize.height < height and height or viewSize.height))
	end
	do
		local isLeft = true
		local size = scroll:getInnerContainerSize()
		local y = size.height
		for k , v in ipairs(cells) do
			local s = v:getContentSize()
			v:setAnchorPoint(cc.p(0.0, 0.0))
			v:setPosition(cc.p((isLeft and 0 or (s.width + c_row_gap)), y - s.height))
			scroll:addChild(v)
			if not isLeft then
				y = y - s.height - c_col_gap
			end
			isLeft = not isLeft
		end
	end
	
	
	return widget
end



return settingNoticeLayer