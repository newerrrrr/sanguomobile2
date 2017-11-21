local worldMapLayer_helper = {}
setmetatable(worldMapLayer_helper,{__index = _G})
setfenv(1,worldMapLayer_helper)

--区域5： 5
--区域4： 58
--区域3： 100
--区域2： 13
--区域1： 127

m_MapOriginType = {
	guild_fort = 1,		--联盟堡垒
	guild_tower = 2,	--联盟箭塔
	guild_gold = 3,		--联盟金矿
	guild_food = 4,		--联盟粮田
	guild_wood = 5,		--联盟伐木场
	guild_stone = 6,	--联盟石料场
	guild_iron = 7,		--联盟铁矿场
	guild_cache = 8,	--联盟仓库
	
	world_gold = 9,		--世界金矿
	world_food = 10,	--世界粮田
	world_wood = 11,	--世界伐木场
	world_stone = 12,	--世界石料场
	world_iron = 13,	--世界铁矿场
	
	monster_small = 14,	--小怪
	player_home = 15,	--玩家城堡
	king_castle = 16,	--王城
	monster_boss = 17,	--多人怪物(BOSS)
	
	camp_middle = 18,	--中级营寨
	camp_low = 19,		--低级营寨
	
	scenery = 20,		--景物(服务器用,客户端任何时候都忽略)
	
	heshibi = 21,		--和氏璧
	
	stronghold = 22,	--据点
	
	guild_war_gongchengchui = 301, --攻城锤
	
	guild_war_gate = 302,	--城门
	
	guild_war_chuangnu = 303,	--床弩
	
	guild_war_yunti = 304,	--云梯
	
	guild_war_toushiche = 305,	--投石车
	
	guild_war_base_camp = 306,	--大本营
	
	guild_war_wall = 307,	--城墙
	
	guild_war_fuhuodian = 308,	--复活点
}

m_MapBuildStatus = {
	build = 0,
	normal = 1,
}

--游戏中一切的通信逻辑都是以建筑原点坐标为准

--透视角度
m_Angle = 0

--视口偏移量
m_ViewOffset = cc.p(100,100)

--单个格子大小
m_SingleSize = cc.size(256,128)

--半个格子大小
m_SingleSizeHalf = cc.size(m_SingleSize.width / 2,m_SingleSize.height / 2)

--一个区域的格子数量
m_AreaSize = cc.size(12,12)

--一个区域的大小
m_AreaContentSize = cc.size(m_AreaSize.width * m_SingleSize.width,m_AreaSize.height * m_SingleSize.height)

--半个区域的大小
m_AreaContentSizeHalf = cc.size(m_AreaContentSize.width / 2,m_AreaContentSize.height / 2)

--区域的数量
m_AreaCount = cc.size(7,7)

--地图中格子总数量
m_TileTotalCount = cc.size(m_AreaSize.width * m_AreaCount.width, m_AreaSize.height * m_AreaCount.height)

--地图总大小
m_MapContentSize = cc.size(m_SingleSize.width * m_TileTotalCount.width , m_SingleSize.height * m_TileTotalCount.height)

--单个格子格子斜边长
m_SingleHypotenuseLength = math.sqrt(m_SingleSizeHalf.width * m_SingleSizeHalf.width + m_SingleSizeHalf.height * m_SingleSizeHalf.height)

--斜边角度
m_HypotenuseAngle = math.atan((m_SingleSize.height / 2) / (m_SingleSize.width / 2)) / math.pi * 180.0

--正弦值
m_SinVar = math.sin(m_HypotenuseAngle / 180 * math.pi)

--余弦值
m_CosVar = math.cos(m_HypotenuseAngle / 180 * math.pi)

--正切值
m_TanVar = math.tan(m_HypotenuseAngle / 180 * math.pi)


--地图平行四边形顶点
m_MpaParallelogram = {
	posT = cc.p(m_MapContentSize.width / 2, m_MapContentSize.height),
	posL = cc.p(0, m_MapContentSize.height / 2),
	posB = cc.p(m_MapContentSize.width / 2, 0),
	posR = cc.p(m_MapContentSize.width, m_MapContentSize.height / 2),
}


local function calculate_determinant_2x3(X1,Y1,X2,Y2,X3,Y3)
	return (X1*Y2+X2*Y3+X3*Y1-Y1*X2-Y2*X3-Y3*X1)
end
function parallelogramContainsPoint(posT, posL, posB, posR, pos)
	if 0 < calculate_determinant_2x3(posT.x, posT.y, posL.x, posL.y, pos.x, pos.y)
		and 0 < calculate_determinant_2x3(posL.x, posL.y, posB.x, posB.y, pos.x, pos.y)
		and 0 < calculate_determinant_2x3(posB.x, posB.y, posR.x, posR.y, pos.x, pos.y)
		and 0 < calculate_determinant_2x3(posR.x, posR.y, posT.x, posT.y, pos.x, pos.y) then
		return true
	else
		return false
	end
end


--大像素坐标是否在大地图平行四边形中
function mapParallelogram_Contains_Position(position)
	return parallelogramContainsPoint(m_MpaParallelogram.posT,m_MpaParallelogram.posL,m_MpaParallelogram.posB,m_MpaParallelogram.posR,position)
end


--检测移动引导极限索引 边缘有一个区域是不可移动的 side
function checkMove_bigTileIndex(bigTileIndex)
	local ret = cc.p(math.floor(bigTileIndex.x),math.floor(bigTileIndex.y))
	if ret.x >= 0 and ret.x < m_AreaSize.width then
		ret.x = m_AreaSize.width
	elseif ret.x >= m_TileTotalCount.width - m_AreaSize.width then
		ret.x = m_TileTotalCount.width - m_AreaSize.width - 1
	end
	if ret.y >= 0 and ret.y < m_AreaSize.height then
		ret.y = m_AreaSize.height
	elseif ret.y >= m_TileTotalCount.height - m_AreaSize.height then
		ret.y = m_TileTotalCount.height - m_AreaSize.height - 1
	end
	return ret
end


--检测移动引导极限索引 边缘有一个区域是不可移动的 side
function checkMove_areaIndex(areaIndex)
	local ret = cc.p(math.floor(areaIndex.x),math.floor(areaIndex.y))
	if ret.x == 0 then
		ret.x = 1
	elseif ret.x >= m_AreaCount.width - 1 then
		ret.x = m_AreaCount.width - 2
	end
	if ret.y == 0 then
		ret.y = 1
	elseif ret.y >= m_AreaCount.height - 1 then
		ret.y = m_AreaCount.height - 2
	end
	return ret
end


--区域索引 转换到 区域ID
function areaIndex_2_areaId(areaIndex)
	if ( areaIndex.x < 0 or areaIndex.x >= m_AreaCount.width or areaIndex.y < 0 or areaIndex.y >= m_AreaCount.height ) then
		return -1
	end
	return math.floor(areaIndex.y * m_AreaCount.width + areaIndex.x)
end


--区域ID 转换到 区域索引
function areaId_2_areaIndex(areaId)
	if areaId == nil or areaId == -1 then
		return cc.p(-1,-1)
	end
	local nid = math.floor(areaId)
	return cc.p( nid % math.floor(m_AreaCount.width) , math.floor(nid / m_AreaCount.width) )
end


--大瓦片索引 转换到 所在区域里的瓦片索引
function bigTileIndex_2_areaTileIndex(bigTileIndex)
	if ( bigTileIndex.x < 0 or bigTileIndex.x >= m_TileTotalCount.width or bigTileIndex.y < 0 or bigTileIndex.y >= m_TileTotalCount.height ) then
		return cc.p(-1,-1)
	end
	return cc.p( bigTileIndex.x % math.floor(m_AreaSize.width) , bigTileIndex.y % math.floor(m_AreaSize.height) )
end


--大瓦片索引 转换到 所在区域的索引信息
function bigTileIndex_2_areaIndex(bigTileIndex)
	if ( bigTileIndex.x < 0 or bigTileIndex.x >= m_TileTotalCount.width or bigTileIndex.y < 0 or bigTileIndex.y >= m_TileTotalCount.height ) then
		return cc.p(-1,-1)
	end
	return cc.p( math.floor(bigTileIndex.x / m_AreaSize.width) , math.floor(bigTileIndex.y / m_AreaSize.height) )
end


--所在区域里的瓦片索引 转换到 大瓦片索引
function areaTileIndex_2_bigTileIndex(areaIndex , areaTileIndex )
	if ( areaIndex.x < 0 or areaIndex.x >= m_AreaCount.width or areaIndex.y < 0 or areaIndex.y >= m_AreaCount.height ) then
		return cc.p(-1,-1)
	end
	if ( areaTileIndex.x < 0 or areaTileIndex.x >= m_AreaSize.width or areaTileIndex.y < 0 or areaTileIndex.y >= m_AreaSize.height ) then
		return cc.p(-1,-1)
	end
	return cc.p( math.floor( areaIndex.x * m_AreaSize.width + areaTileIndex.x ) , math.floor( areaIndex.y * m_AreaSize.height + areaTileIndex.y ) )
end


--大像素坐标 转换到 大瓦片索引
function position_2_bigTileIndex(position)
	if true == mapParallelogram_Contains_Position(position) then
		local x = position.x - m_SingleSizeHalf.width
		local y = position.y - m_SingleSize.height
		local p = cc.p( math.floor( (m_MapContentSize.height - m_SingleSize.height - y) / m_SingleSize.height + (x + m_SingleSizeHalf.width - m_TileTotalCount.height * m_SingleSizeHalf.width) / m_SingleSize.width )
		 , math.floor( (m_MapContentSize.height - m_SingleSize.height - y) / m_SingleSize.height - (x + m_SingleSizeHalf.width - m_TileTotalCount.height * m_SingleSizeHalf.width) / m_SingleSize.width ) )
		if ( p.x < 0 or p.x >= m_TileTotalCount.width or p.y < 0 or p.y >= m_TileTotalCount.height ) then
			return cc.p(-1,-1)
		else
			return p
		end
	else
		return cc.p(-1,-1)
	end
end


--大瓦片索引 转换到 大像素坐标
function bigTileIndex_2_position(bigTileIndex)
	if ( bigTileIndex.x < 0 or bigTileIndex.x >= m_TileTotalCount.width or bigTileIndex.y < 0 or bigTileIndex.y >= m_TileTotalCount.height ) then
		return cc.p(-1,-1)
	end
	return cc.p( math.floor( bigTileIndex.x * m_SingleSizeHalf.width + (m_TileTotalCount.height - (bigTileIndex.y + 1)) * m_SingleSizeHalf.width )
		, math.floor( m_MapContentSize.height - (m_SingleSize.height + bigTileIndex.y * m_SingleSizeHalf.height + bigTileIndex.x * m_SingleSizeHalf.height) ) )	
end


--大瓦片索引 转换到 大像素中心坐标
function bigTileIndex_2_positionCenter(bigTileIndex)
	local ret = bigTileIndex_2_position(bigTileIndex)
	if ret.x ~= -1 and ret.y ~= -1 then
		ret.x = ret.x + m_SingleSizeHalf.width
		ret.y = ret.y + m_SingleSizeHalf.height
	end
	return ret
end


--区域索引 转换到 大像素坐标
function areaIndex_2_position(areaIndex)
	if ( areaIndex.x < 0 or areaIndex.x >= m_AreaCount.width or areaIndex.y < 0 or areaIndex.y >= m_AreaCount.height ) then
		return cc.p(-1,-1)
	end
	return cc.p( math.floor( areaIndex.x * m_AreaContentSizeHalf.width + (m_AreaCount.height - (areaIndex.y + 1)) * m_AreaContentSizeHalf.width )
		, math.floor( m_MapContentSize.height - (m_AreaContentSize.height + areaIndex.y * m_AreaContentSizeHalf.height + areaIndex.x * m_AreaContentSizeHalf.height) ) )	
end


--区域索引 转换到 大像中心素坐标
function areaIndex_2_positionCenter(areaIndex)
	local ret = areaIndex_2_position(areaIndex)
	if ret.x ~= -1 and ret.y ~= -1 then
		ret.x = ret.x + m_AreaContentSizeHalf.width
		ret.y = ret.y + m_AreaContentSizeHalf.height
	end
	return ret
end


--区域索引 转换到 区域渲染Z序
function areaIndex_2_areaZOrder(areaIndex)
	if ( areaIndex.x < 0 or areaIndex.x >= m_AreaCount.width or areaIndex.y < 0 or areaIndex.y >= m_AreaCount.height ) then
		return -1
	end
	return math.floor( 1 + ((areaIndex.x + areaIndex.y) * m_AreaCount.width + areaIndex.x) * 2 )
end


--大瓦片索引 转换到 瓦片渲染Z序
function bigTileIndex_2_tileZOrder(bigTileIndex)
	if ( bigTileIndex.x < 0 or bigTileIndex.x >= m_TileTotalCount.width or bigTileIndex.y < 0 or bigTileIndex.y >= m_TileTotalCount.height ) then
		return -1
	end
	return math.floor( 1 + ((bigTileIndex.x + bigTileIndex.y) * m_TileTotalCount.width + bigTileIndex.x) * 2 )
end


--给定一个像素坐标,再获得以这个像素坐标为大像素索引原点的偏移像素
function oPosition_offsetBigTileIndex_2_nPosition(oPosition, offsetBigTileIndex)
	return cc.p(oPosition.x + offsetBigTileIndex.x * m_SingleSizeHalf.width - offsetBigTileIndex.y * m_SingleSizeHalf.width
			, oPosition.y - offsetBigTileIndex.y * m_SingleSizeHalf.height - offsetBigTileIndex.x * m_SingleSizeHalf.height)
end


--建筑物服务器数据 转换到 建筑物中心像素坐标
function buildServerData_2_buildCenterPosition( buildServerData )
	local configData = g_data.map_element[tonumber(buildServerData.map_element_id)]
	return bigTileIndex_2_buildCenterPosition(cc.p(buildServerData.x,buildServerData.y), configData)
end


--根据配置数据将 原点大瓦片索引 转换到 建筑物中心像素坐标
function bigTileIndex_2_buildCenterPosition(bigTileIndex, configData)
	local count = #(configData.x_y) --此版本建筑物只有占1,4,9,16格的而已
	if count == 4 then
		local position = bigTileIndex_2_position(cc.p(bigTileIndex.x,bigTileIndex.y))
		return cc.p(position.x + m_SingleSizeHalf.width, position.y + m_SingleSize.height)
	elseif count == 9 then
		local position = bigTileIndex_2_position(cc.p(bigTileIndex.x,bigTileIndex.y))
		return cc.p(position.x + m_SingleSizeHalf.width, position.y + m_SingleSize.height + m_SingleSizeHalf.height)
	elseif count == 16 then
		local position = bigTileIndex_2_position(cc.p(bigTileIndex.x,bigTileIndex.y))
		return cc.p(position.x + m_SingleSizeHalf.width, position.y + m_SingleSize.height * 2)
	else
		return bigTileIndex_2_positionCenter(cc.p(bigTileIndex.x,bigTileIndex.y))
	end
end


--大像素坐标 转换到 大瓦片索引 (对外(小地图),这个函数效率较低)
function out_position_2_bigTileIndex(position , contentSize , parallelogram)
	local singleSize = cc.size(contentSize.width / m_TileTotalCount.width, contentSize.height / m_TileTotalCount.height)
	local singleSizeHalf = cc.size(singleSize.width / 2, singleSize.height / 2)
	local parallelogram = {
		posT = cc.p(contentSize.width / 2, contentSize.height),
		posL = cc.p(0, contentSize.height / 2),
		posB = cc.p(contentSize.width / 2, 0),
		posR = cc.p(contentSize.width, contentSize.height / 2),
	}
	if true == parallelogramContainsPoint(parallelogram.posT, parallelogram.posL, parallelogram.posB, parallelogram.posR, position) then
		local x = position.x - singleSizeHalf.width
		local y = position.y - singleSize.height
		local p = cc.p( math.floor( (contentSize.height - singleSize.height - y) / singleSize.height + (x + singleSizeHalf.width - m_TileTotalCount.height * singleSizeHalf.width) / singleSize.width )
		 , math.floor( (contentSize.height - singleSize.height - y) / singleSize.height - (x + singleSizeHalf.width - m_TileTotalCount.height * singleSizeHalf.width) / singleSize.width ) )
		if ( p.x < 0 or p.x >= m_TileTotalCount.width or p.y < 0 or p.y >= m_TileTotalCount.height ) then
			return cc.p(-1,-1)
		else
			return p
		end
	else
		return cc.p(-1,-1)
	end
end


--大瓦片索引 转换到 大像素坐标 (对外(小地图))
function out_bigTileIndex_2_position(bigTileIndex , contentSize)
	if ( bigTileIndex.x < 0 or bigTileIndex.x >= m_TileTotalCount.width or bigTileIndex.y < 0 or bigTileIndex.y >= m_TileTotalCount.height ) then
		return cc.p(-1,-1)
	end
	local singleSize = cc.size(contentSize.width / m_TileTotalCount.width, contentSize.height / m_TileTotalCount.height)
	local singleSizeHalf = cc.size(singleSize.width / 2, singleSize.height / 2)
	return cc.p( math.floor( bigTileIndex.x * singleSizeHalf.width + (m_TileTotalCount.height - (bigTileIndex.y + 1)) * singleSizeHalf.width )
		, math.floor( contentSize.height - (singleSize.height + bigTileIndex.y * singleSizeHalf.height + bigTileIndex.x * singleSizeHalf.height) ) )	
end



--创建一个节点给Container使用
function createNodeInContainer(isAngle)
	local userMod = cc.Node
	local node = userMod:create()
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(cc.p(0.0,0.0))
	node:setPosition(cc.p(0.0,0.0))
	node:setContentSize(m_MapContentSize)
	if isAngle == true then
		node.addChild = function (n, c , z , ton)
			c:setRotation3D( cc.vec3(m_Angle * -1,0.0,0.0) )
			if z then
				if ton then
					userMod.addChild(n,c,z,ton)
				else
					userMod.addChild(n,c,z)
				end
			else
				userMod.addChild(n,c)
			end
		end
	end
	return node
end


--创建一个指向主城的距离标识
function createHomeDistanceArrow(center,radius_y,radius_x)
	local arrow = cc.Sprite:createWithSpriteFrameName("worldmap_image_arrow.png")
	--arrow:setPosition(center)
	local size = arrow:getContentSize()
	local rect = cc.rect(0,0,size.width,size.height)
	local label = g_gameTools.createLabelDefaultFont("",20)
	label:setAnchorPoint(cc.p(0.5,0.5))
	label:setPosition(cc.p(105, arrow:getContentSize().height / 2))
	arrow:addChild(label)
	arrow.lua_arrowUpdate = function( currentBigTileIndex , homeBigTileIndex , currentPositionCenter )
		local positionCenter = bigTileIndex_2_positionCenter(homeBigTileIndex)
		local world_position = require("game.mapguildwar.worldMapLayer_bigMap").position_2_worldPosition( cc.p(positionCenter.x, positionCenter.y + m_SingleSizeHalf.height) )
		local visibleRect = cc.rect(g_display.left, g_display.bottom, g_display.visibleSize.width, g_display.visibleSize.height)
		if world_position and cc.rectContainsPoint(visibleRect, world_position) == false and g_guildWarPlayerData.GetData().is_in_map == 1 then
			arrow:setVisible(true)
			local distanceVec = cc.p( homeBigTileIndex.x - currentBigTileIndex.x , homeBigTileIndex.y - currentBigTileIndex.y )
			local distance = math.floor( math.sqrt( distanceVec.x * distanceVec.x + distanceVec.y * distanceVec.y ) )
			label:setString( distance..g_tr("worldmap_KM") )
			local homePositionCenter = bigTileIndex_2_positionCenter( homeBigTileIndex)
			local posDistanceVec = cc.p( homePositionCenter.x - currentPositionCenter.x , homePositionCenter.y - currentPositionCenter.y )
			local angle = cToolsForLua:calc2VecAngle(1,0,posDistanceVec.x,posDistanceVec.y)
			arrow:setRotation( angle * -1 )
--			arrow:setPosition( cc.p(center.x + math.cos(angle * 0.01745329252) * radius_x , center.y + math.sin(angle * 0.01745329252) * radius_y) )
--			label:setRotation( (angle > 90 or angle < -90) and 180 or 0 )
		else
			arrow:setVisible(false)
		end
	end
	local function onTouchBegan(touch, event)
		return arrow:isVisible() and cc.rectContainsPoint(rect,arrow:convertToNodeSpace(touch:getLocation()))
	end
	local function onTouchEnded(touch, event)
		if arrow:isVisible() and cc.rectContainsPoint(rect,arrow:convertToNodeSpace(touch:getLocation())) == true then
			local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
			bigMap.closeSmallMenu()
			bigMap.closeInputMenu()
			bigMap.changeBigTileIndex_Manual(g_guildWarPlayerData.GetPosition(),true)
		end
	end
	local touchListener = cc.EventListenerTouchOneByOne:create()
	touchListener:setSwallowTouches(true)
	touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	touchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener,arrow)
	return arrow
end


--创建一个加载图标显示
function createLoadingImage()
	local loadingImage = cc.Sprite:createWithSpriteFrameName("worldmap_image_loading.png")
	loadingImage:setScale(g_display.scale)
	--loadingImage:setPosition(cc.p(g_display.left + (50 * g_display.scale), g_display.bottom + (250 * g_display.scale)))
	loadingImage:setPosition(g_display.center)
	loadingImage:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, 180)))
	function loadingImage:lua_show()
		self:setVisible(true)
	end
	function loadingImage:lua_Hide()
		self:setVisible(false)
	end
	return loadingImage
end


--得到自己主城map_element_id(通过城内官府等级计算出来)
function getMyHome_mapElementID()
	local lv = g_PlayerBuildMode.getMainCityBuilding_lv()
	for k , v in pairs(g_data.map_element) do
		if v.origin_id == m_MapOriginType.player_home and v.level == lv then
			return k
		end
	end
end


function createRangeData(configData, originBigTileIndex)
	
	--还差颜色数据
	
	local range_data = {
		--vertex = {},    --[1] = {ati = cc.p(x,y) , aid = id , tp = 1~8(从上顶点逆时针) } , ... < --[1]=t,[1]=b,[1]=l,[1]=r >
		areas = {},		--[areaId] = { [1] = {ati = cc.p(x,y) , aid = id , tp = 1~8(从上顶点逆时针) } , ... < --[1]=t,[1]=b,[1]=l,[1]=r > }
	}
	
	local areas = range_data.areas
	
	local insert = table.insert
	
	local cp = cc.p
	
	local t , b , l , r = nil , nil , nil , nil
	
	local count = #(configData.x_y) --此版本建筑物只有占1,4,9,16格的而已
	if count == 4 then
		t = cp(originBigTileIndex.x - (configData.range + 1), originBigTileIndex.y - (configData.range + 1))
		b = cp(originBigTileIndex.x + configData.range, originBigTileIndex.y + configData.range)
		l = cp(originBigTileIndex.x - (configData.range + 1), originBigTileIndex.y + configData.range)
		r = cp(originBigTileIndex.x + configData.range, originBigTileIndex.y - (configData.range + 1))
	elseif count == 9 then --add to check
		t = cp(originBigTileIndex.x - (configData.range + 2), originBigTileIndex.y - (configData.range + 2))
		b = cp(originBigTileIndex.x + configData.range, originBigTileIndex.y + configData.range)
		l = cp(originBigTileIndex.x - (configData.range + 2), originBigTileIndex.y + configData.range)
		r = cp(originBigTileIndex.x + configData.range, originBigTileIndex.y - (configData.range + 2))
	elseif count == 16 then
		t = cp(originBigTileIndex.x - (configData.range + 3), originBigTileIndex.y - (configData.range + 3))
		b = cp(originBigTileIndex.x + configData.range, originBigTileIndex.y + configData.range)
		l = cp(originBigTileIndex.x - (configData.range + 3), originBigTileIndex.y + configData.range)
		r = cp(originBigTileIndex.x + configData.range, originBigTileIndex.y - (configData.range + 3))
	else
		t = cp(originBigTileIndex.x - configData.range, originBigTileIndex.y - configData.range)
		b = cp(originBigTileIndex.x + configData.range, originBigTileIndex.y + configData.range)
		l = cp(originBigTileIndex.x - configData.range, originBigTileIndex.y + configData.range)
		r = cp(originBigTileIndex.x + configData.range, originBigTileIndex.y - configData.range)
	end
	
	do --上
		local id = areaIndex_2_areaId(bigTileIndex_2_areaIndex(t))
		local tab = areas[id]
		if tab == nil then
			tab = {}
			areas[id] = tab
		end
		local nt = {ati = bigTileIndex_2_areaTileIndex(t) , aid = id , tp = 1}
		insert(tab, nt)
		--range_data.vertex[1] = nt
	end
	
	do --左
		local id = areaIndex_2_areaId(bigTileIndex_2_areaIndex(l))
		local tab = areas[id]
		if tab == nil then
			tab = {}
			areas[id] = tab
		end
		local nt = {ati = bigTileIndex_2_areaTileIndex(l) , aid = id , tp = 3}
		insert(tab, nt)
		--range_data.vertex[2] = nt
	end
	
	do --下
		local id = areaIndex_2_areaId(bigTileIndex_2_areaIndex(b))
		local tab = areas[id]
		if tab == nil then
			tab = {}
			areas[id] = tab
		end
		local nt = {ati = bigTileIndex_2_areaTileIndex(b) , aid = id , tp = 5}
		insert(tab, nt)
		--range_data.vertex[3] = nt
	end
	
	do --右
		local id = areaIndex_2_areaId(bigTileIndex_2_areaIndex(r))
		local tab = areas[id]
		if tab == nil then
			tab = {}
			areas[id] = tab
		end
		local nt = {ati = bigTileIndex_2_areaTileIndex(r) , aid = id , tp = 7}
		insert(tab, nt)
		--range_data.vertex[4] = nt
	end
	
	do --左上边
		local x = t.x
		for y = t.y + 1 , l.y - 1 , 1 do
			local p = cp(x , y)
			local id = areaIndex_2_areaId(bigTileIndex_2_areaIndex(p))
			local tab = areas[id]
			if tab == nil then
				tab = {}
				areas[id] = tab
			end
			insert(tab, {ati = bigTileIndex_2_areaTileIndex(p) , aid = id , tp = 2})
		end
	end
	
	do --左下边
		local y = l.y
		for x = l.x + 1 , b.x - 1 , 1 do
			local p = cp(x , y)
			local id = areaIndex_2_areaId(bigTileIndex_2_areaIndex(p))
			local tab = areas[id]
			if tab == nil then
				tab = {}
				areas[id] = tab
			end
			insert(tab, {ati = bigTileIndex_2_areaTileIndex(p) , aid = id , tp = 4})
		end
	end
	
	do --右下边
		local x = b.x
		for y = b.y - 1 , r.y + 1 , -1 do
			local p = cp(x , y)
			local id = areaIndex_2_areaId(bigTileIndex_2_areaIndex(p))
			local tab = areas[id]
			if tab == nil then
				tab = {}
				areas[id] = tab
			end
			insert(tab, {ati = bigTileIndex_2_areaTileIndex(p) , aid = id , tp = 6})
		end
	end
	
	do --右上边
		local y = r.y
		for x = r.x - 1 , t.x + 1 , -1 do
			local p = cp(x , y)
			local id = areaIndex_2_areaId(bigTileIndex_2_areaIndex(p))
			local tab = areas[id]
			if tab == nil then
				tab = {}
				areas[id] = tab
			end
			insert(tab, {ati = bigTileIndex_2_areaTileIndex(p) , aid = id , tp = 8})
		end
	end
	
	return range_data
end


--get image name with side type
function getImageNmaeWithSideTypeSelf(tp)
	if tp == 1 then
		return "worldmap_image_r_1_T.png"
	elseif tp == 2 then
		return "worldmap_image_r_1_LT.png"
	elseif tp == 3 then
		return "worldmap_image_r_1_L.png"
	elseif tp == 4 then
		return "worldmap_image_r_1_LB.png"
	elseif tp == 5 then
		return "worldmap_image_r_1_B.png"
	elseif tp == 6 then
		return "worldmap_image_r_1_RB.png"
	elseif tp == 7 then
		return "worldmap_image_r_1_R.png"
	elseif tp == 8 then
		return "worldmap_image_r_1_RT.png"
	end
end


--get image name with side type
function getImageNmaeWithSideTypeOther(tp)
	if tp == 1 then
		return "worldmap_image_r_2_T.png"
	elseif tp == 2 then
		return "worldmap_image_r_2_LT.png"
	elseif tp == 3 then
		return "worldmap_image_r_2_L.png"
	elseif tp == 4 then
		return "worldmap_image_r_2_LB.png"
	elseif tp == 5 then
		return "worldmap_image_r_2_B.png"
	elseif tp == 6 then
		return "worldmap_image_r_2_RB.png"
	elseif tp == 7 then
		return "worldmap_image_r_2_R.png"
	elseif tp == 8 then
		return "worldmap_image_r_2_RT.png"
	end
end

return worldMapLayer_helper