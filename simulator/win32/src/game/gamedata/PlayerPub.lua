--g_PlayerPubMode
local PlayerPub = {}
local baseData = nil
local updateViews = {}
setmetatable(PlayerPub,{__index = _G})
setfenv(1,PlayerPub)

local isHaveStarReward = false

local itemPieceMap = nil
--根据普通武将信物获取对应的武将信息
function PlayerPub.getGeneralInfoByPieceItemId(itemId)
	if itemPieceMap == nil then
		itemPieceMap = {}
		for key, generalInfo in pairs(g_data.general) do
			itemPieceMap[generalInfo.piece_item_id] = generalInfo
		end
	end
	
	return itemPieceMap[itemId]
end

--将魂和武将对应 ，仅支持武将升星条件只配将魂道具
local soulList = {}
local generalList = {}

--仅初始化一次
do
	for key, var in pairs(g_data.general_star) do
	if soulList[var.general_original_id] == nil and #var.consume > 0 then
		local itemId = var.consume[1][2]
		soulList[var.general_original_id] = itemId
		generalList[itemId] = var.general_original_id
	end
	end
end

local itemSoulMap = nil
--根据神武将将魂Id获取对应的武将数据
function PlayerPub.getGodGeneralOriginalIdBySoulItemId(itemId)
	return generalList[itemId]
end

function PlayerPub.setData(data)
	baseData = data.PlayerPub
end

function PlayerPub.getData()
	if(baseData == nil)then
	PlayerPub.requestData()
	end
	return baseData
end
function PlayerPub.requestData()
	local ret = false
	local function onRecv(result, msgData)
	if(result==true)then
		ret = true
		PlayerPub.setData(msgData)
	end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerPub",}},onRecv)
	return ret
end

--武将可招募数量上限
function PlayerPub.getMaxGeneralToRecruit()
	local buildInfo = nil
	local data = g_PlayerBuildMode.GetData()
	for key , var in pairs(data) do
		local config = g_data.build[tonumber(var.build_id)]
		if(config.origin_build_id == 14 )then
			buildInfo = config
			break
		end
	end
	
	local max = 0
	local originalMax = 0
	local output = buildInfo.output
	for key, var in pairs(output) do
		if var [1] == 33 then --武将招募上限
		max = var[2]
		originalMax = var[2]
		break
		end
	end
	
	--buff 效果
	local buffId = 442
	local buffKeyName = g_data.buff[buffId].name
	assert( buffKeyName == "recruit_general_limit_plus" ,"recruit_general_limit_plus")--武将招募上限增加
	
	local pubBuildServerData =	g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.bar)
	local position = pubBuildServerData.position
	local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,position)
	if buffType == 1 then --万分比
	max = math.ceil(max * (10000 + buffValue)/10000)
	elseif buffType == 2 then --固定值
	max = max + buffValue
	end
	
--	local allbuffs = g_BuffMode.GetData()
--	local buffValue = 0
--	local buffId = 442
--	local buffKeyName = g_data.buff[buffId].name
--	assert( buffKeyName == "recruit_general_limit_plus" ,"recruit_general_limit_plus")--武将招募上限增加
--	if allbuffs and allbuffs[buffKeyName] then
--		if tonumber(allbuffs[buffKeyName].v) > 0 then
--		buffValue = allbuffs[buffKeyName].v
--		end
--		
--		local buffType = g_data.buff[buffId].buff_type
--		if buffType == 1 then --万分比
--		max = math.ceil(max * (10000 + buffValue)/10000)
--		elseif buffType == 2 then --固定值
--		max = max + buffValue
--		end
--	end
	
	return max,originalMax
end


function PlayerPub.reqBuyPrisoner(generalId)
	local resultHandler = function(result, msgData)
		if result then
		end
	end
	g_sgHttp.postData("Pub/buyPrisoner",{generalId = generalId },resultHandler)
end


function PlayerPub.reqBuyGeneral(generalId)
	local resultHandler = function(result, msgData)
		if result then
			--g_GeneralMode.RequestData()
			
		end
	end
	g_sgHttp.postData("Pub/buy",{generalId = generalId },resultHandler)
end

function PlayerPub.reqRefresh(refreshType,callback)
	assert(refreshType)
	local ret = false
	local function onRecv(result, msgData)
	if(result==true)then
	
	end
	end
	g_sgHttp.postData("Pub/reload",{type = refreshType},callback)
	return ret
end


function PlayerPub.addUpdateView(layer)
	for key, view in pairs(updateViews) do
		if view == layer then
			return
		end
	end
	table.insert(updateViews,layer)
end

function PlayerPub.removeUpdateView(layer)
	for key, view in pairs(updateViews) do
		if view == layer then
			table.remove(updateViews,key)
			break
		end
	end
end

function PlayerPub.removeAllUpdateView()
	updateViews = {}
end

function PlayerPub.notificationUpdateShow()
	for key, view in pairs(updateViews) do
		assert(view.updateView)
		view:updateView()
	end
end

function PlayerPub.isHaveGeneralToRecuite()
	
	local isHave = false
	
	local pubBuildServerData = g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.bar) 
	local keyOwnGenerals = g_GeneralMode.getOwnedGenerals()
	for key, generalInfo in pairs(g_data.general) do 
		if keyOwnGenerals[generalInfo.general_original_id] == nil and generalInfo.avaiable_level > 0 and pubBuildServerData.build_level >= generalInfo.avaiable_level	then
			--是否已经化神
			local hasGod = false
			local godGeneralConfig = g_GeneralMode.getGodGeneralConfigByRootId(generalInfo.root_id)
			if godGeneralConfig then
				if keyOwnGenerals[godGeneralConfig.general_original_id] then
				hasGod = true
				end
			end
			
			if not hasGod then
				local haveNum = 0
				local bagData = g_BagMode.FindItemByID(generalInfo.piece_item_id)
				if bagData and bagData.num then
				haveNum = bagData.num
				end
				
				if haveNum >= generalInfo.piece_required then
					isHave = true
					break
				end
			end
			
		end
	end
	
	return isHave
end

function PlayerPub.getCurrentTotalStar()
	local currentStar = 0
	local keyOwnGenerals = g_GeneralMode.getOwnedGenerals()
	for key, var in pairs(keyOwnGenerals) do
		currentStar = currentStar + math.floor(tonumber(var.star_lv)/5) + 1
	end
	return currentStar
end

function PlayerPub.isHaveStarReward()
	return isHaveStarReward
end

function PlayerPub.checkHaveStarReward()
	
	local currentStar = PlayerPub.getCurrentTotalStar()
	local getedAwardList = {}
	do
		for key, var in pairs(g_playerInfoData.GetData().general_star_reward) do
			getedAwardList[tonumber(var)] = var
		end
	end
	
	isHaveStarReward = false
	do
		for key, var in pairs(g_data.general_total_stars) do
			if getedAwardList[var.id] == nil then 
				if currentStar >= var.total_stars then
					isHaveStarReward = true
					break
				end
			end
		end
	end
	
end

return PlayerPub