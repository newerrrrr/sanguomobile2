local AllianceManageLayer = class("AllianceManageLayer",function()
	return cc.Layer:create()
end)

local baseNode = nil
function AllianceManageLayer:ctor()
local node = g_gameTools.LoadCocosUI("alliance_manage_index.csb",5)
	self:addChild(node)
	baseNode = node:getChildByName("scale_node")
	
	 --关闭本页
	local btnClose = baseNode:getChildByName("close_btn")
	btnClose:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			self:removeFromParent()
		end
	end)
	
	baseNode:getChildByName("Text_1"):setString(g_tr("allianceManage")) --联盟管理
	
	local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
	
	local rank5 = {
		{g_tr("modifyAllianceName"),4},--"修改联盟名称"
		{g_tr("modifyAllianceShortName"),5},--"修改联盟简称"
		{g_tr("modifyAllianceIcon"),6},--"修改联盟图标"
		{g_tr("modifyAllianceRankName"),7},--"修改阶段名称"
		{g_tr("allianceDissolve"),9},--"解散联盟"
	}
	
	local rank4 = {
		{g_tr("modifyAllianceDesc"),1},--"修改联盟宣言"
		{g_tr("modifyAllianceNotice"),2},--"修改联盟公告"
		{g_tr("modifyAllianceRecruitCondition"),3},--"修改招募条件"
		{g_tr("modifyAllianceCamp"),11},--"修改联盟阵营"
	}
	
	local rankBase = {
		{g_tr("allianceRankList"),8},--"捐献排行榜"
	}
	
	--[[local menusTexts = {
		g_tr("modifyAllianceDesc"),--"修改联盟宣言"
		g_tr("modifyAllianceNotice"),--"修改联盟公告"
		g_tr("modifyAllianceRecruitCondition"),--"修改招募条件"
		g_tr("modifyAllianceName"),--"修改联盟名称"
		g_tr("modifyAllianceShortName"),--"修改联盟简称"
		g_tr("modifyAllianceIcon"),--"修改联盟图标"
		g_tr("modifyAllianceRankName"),--"修改阶段名称"
		g_tr("allianceRankList"),--"捐献排行榜"
		g_tr("allianceDissolve"),--"解散联盟"
	}]]
	
	local menusTexts = {}
	
	local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
	local rank = myInfo.rank
	
	for key, var in ipairs(rankBase) do
		table.insert(menusTexts,var)
	end
	
	if rank >= 4 then --r4 r5 权限
		for key, var in ipairs(rank4) do
			table.insert(menusTexts,var)
		end
	end
	
	if rank > 4 then --r5 权限
		for key, var in ipairs(rank5) do
			table.insert(menusTexts,var)
		end
	end
	
	if rank < 5 then
		local var = {g_tr("exitAlliance"),10} --"退出联盟"
		table.insert(menusTexts,var)
	end

	local leftListView = baseNode:getChildByName("ListView_left")
	self._leftListView = leftListView
	local itemModel = cc.CSLoader:createNode("alliance_manage_left_menu.csb")
	itemModel:setContentSize(itemModel:getChildByName("pic_select"):getContentSize())
	itemModel:getChildByName("pic_selected"):setVisible(true)
	leftListView:setItemModel(itemModel)
	--leftListView:setItemsMargin(1.0)
	
	for key, text in pairs(menusTexts) do
		leftListView:pushBackDefaultItem()
	end
	
	local items = leftListView:getItems()
	for i =1, #items do
		local str = menusTexts[i][1]
		local item = leftListView:getItem(i - 1)
		if item then
			item:getChildByName("text"):setString(str)
		end
	end
	
	local function listViewEvent(sender, eventType)
		if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			print("touched:",sender:getCurSelectedIndex())
			self:changePage(sender:getCurSelectedIndex() + 1,menusTexts[sender:getCurSelectedIndex() + 1][2])
		end
	end
	
	leftListView:addEventListener(listViewEvent)
	
	self._menusTexts = menusTexts
	self:changePage(1,menusTexts[1][2])
end

function AllianceManageLayer:gotoLogicIdx(logicIdx)
	for key, var in ipairs(self._menusTexts) do
		if var[2] == logicIdx then
			self:changePage(key,self._menusTexts[key][2])
			break
		end
	end
end


function AllianceManageLayer:changePage(idx,logicIdx)
	if self._changePageIdx == idx then
		return 
	end

	local page = nil
	if logicIdx == 1 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageAdsLayer"):create()
	elseif logicIdx == 2 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageAdsLayer"):create(true)
	elseif logicIdx == 3 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageRecruitLayer"):create()
	elseif logicIdx == 4 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageNameLayer"):create()
	elseif logicIdx == 5 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageNameLayer"):create(true)
	elseif logicIdx == 6 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageIconLayer"):create()
	elseif logicIdx == 7 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageRankNameLayer"):create()
	elseif logicIdx == 8 then
		page = require("game.uilayer.alliance.AllianceRankingListLayer"):create()
	elseif logicIdx == 9 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageDissolutionLayer"):create(function()
			self:removeFromParent()
			g_airBox.show(g_tr("allianceDissolutionSuccess"))
		end)
	elseif logicIdx == 10 then
		g_msgBox.show(g_tr("makeSureExitAlliance"),nil,nil,function(event)
			if event == 0 then
				print("make sure")
				local resultHandler = function(result, msgData)
					if result then
						print("exit success")
						self:removeFromParent()
						g_airBox.show(g_tr("exitAllianceSuccess"))
						g_AllianceMode.reqAllAllianceData()
						g_AllianceMode.notifyUpdateView()
						g_AllianceMode.updateWorldMap()
					end
				end
				local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
				g_sgHttp.postData("guild/expelPlayer",{targetPlayerId = myInfo.player_id},resultHandler)
			end
		end,1)
		
		return
	elseif logicIdx == 11 then
		page = require("game.uilayer.alliance.managelayer.AllianceManageCamp"):create()
		g_sceneManager.addNodeForUI(page)
		return
	end
	
	self._changePageIdx = idx
	
	local container = baseNode:getChildByName("container")
	container:removeAllChildren()
	
	if self._lastMenu then
		self._lastMenu:getChildByName("pic_selected"):setVisible(true)
	end
	
	self._lastMenu = self._leftListView:getItem(idx - 1)
	self._lastMenu:getChildByName("pic_selected"):setVisible(false)
	
	if page then
		print("page added")
		container:addChild(page)
	end
end

return AllianceManageLayer