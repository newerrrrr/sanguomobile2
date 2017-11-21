local homeAir = {}
setmetatable(homeAir,{__index = _G})
setfenv(1,homeAir)


local HomeAirClickMD = require "game.maplayer.homeAirClick"


local c_tag_playClickHide_action = 88554656


m_AirClickMode = {
	buildingFull = 1,	--建筑强制点击
	airIn = 2,			--气泡内点击
}


local function _playClickHide( node )

end



--创建

function create_basic(filename)
	local ret = cc.Sprite:createWithSpriteFrameName(filename)
	ret:setPosition(cc.p(0,30))
	ret:setAnchorPoint(cc.p(0.5,0))
	local size = ret:getContentSize()
	
	local act = cc.Sequence:create(cc.DelayTime:create(3.0)
		,cc.RotateTo:create(0.045,-30)
		,cc.RotateTo:create(0.09,30)
		,cc.RotateTo:create(0.045,-20)
		,cc.RotateTo:create(0.09,20)
		,cc.RotateTo:create(0.045,-10)
		,cc.RotateTo:create(0.09,10)
		,cc.RotateTo:create(0.04,0)
	)
	
	ret:runAction( cc.RepeatForever:create( act ) )
	
	ret.lua_clickMode = m_AirClickMode.buildingFull	--默认为建筑强制点击
	
	--播放触发隐藏(播放时间绝对不能超过轮询检测时间,目前是3.25秒)
	function ret:lua_playClickHide()
		if self:isVisible() and self:getActionByTag(c_tag_playClickHide_action) == nil then
			local action = cc.Sequence:create( 
				cc.DelayTime:create(0.65) 
				, cc.Hide:create()
				)
			action:setTag(c_tag_playClickHide_action)
			self:runAction(action)
			do--点击特效
				local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_AnNiuXunHuanOneDianJi/Effect_AnNiuXunHuanOneDianJi.ExportJson", "Effect_AnNiuXunHuanOneDianJi")
				self:addChild(armature)
				armature:setPosition(cc.p(size.width / 2, size.height * 0.5))
				animation:play("Animation1")
			end
		end
	end
	
	--是否可以点击触发
	function ret:isCanClick()
		return (self:isVisible() and self:getActionByTag(c_tag_playClickHide_action) == nil)
	end
	
	
	return ret
end


--收获 金
function create_harvest_Gold()
	local ret = create_basic( "homeImage_air_Gold.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Gold
	return ret
end

--收获 粮
function create_harvest_Food()
	local ret = create_basic( "homeImage_air_Food.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Food
	return ret
end

--收获 木
function create_harvest_Wood()
	local ret = create_basic( "homeImage_air_Wood.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Wood
	return ret
end

--收获 石
function create_harvest_Stone()
	local ret = create_basic( "homeImage_air_Stone.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Stone
	return ret
end

--收获 铁
function create_harvest_Iron()
	local ret = create_basic( "homeImage_air_Iron.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Iron
	return ret
end

--收获 陷阱
function create_harvest_Workshop()
	local ret = create_basic( "homeImage_air_Workshop.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Workshop
	return ret
end

--收获 步兵
function create_harvest_Infantry()
	local ret = create_basic( "homeImage_air_Barracks.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Infantry
	return ret
end

--收获 工兵
function create_harvest_Archers()
	local ret = create_basic( "homeImage_air_Barracks.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Archers
	return ret
end

--收获 骑兵
function create_harvest_Cavalry()
	local ret = create_basic( "homeImage_air_Barracks.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Cavalry
	return ret
end

--收获 车兵
function create_harvest_Car()
	local ret = create_basic( "homeImage_air_Barracks.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Car
	return ret
end

--收获 医院
function create_harvest_Hospital()
	local ret = create_basic( "homeImage_air_Hospital.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Hospital
	return ret
end

--升级请求帮助
function create_levelUp_Help()
	local ret = create_basic( "homeImage_air_Help.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_LevelUp_Help
	return ret
end

--升级秒掉
function create_levelUp_Free()
	local ret = create_basic( "homeImage_air_Free.png" )
	local size = ret:getContentSize()
	
	do
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_AnNiuXunHuanOne/Effect_AnNiuXunHuanOne.ExportJson", "Effect_AnNiuXunHuanOne")
		ret:addChild(armature)
		armature:setPosition(cc.p(size.width / 2,size.height * 0.56))
		animation:play("Animation1")
	end
	
	do
		local text = g_gameTools.createLabelDefaultFont(g_tr("air_free"),26)
		text:setTextColor(cc.c3b(255, 255, 0))
		text:setPosition(cc.p(size.width / 2,size.height * 0.55))
		ret:addChild(text)
	end
	
	ret.lua_OnClick = HomeAirClickMD.onClick_LevelUp_Free
	return ret
end

--屯所 帮助所有玩家
function create_helpAll_ThePlace()
	local ret = create_basic( "homeImage_air_HelpAll.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_helpAll_ThePlace
	return ret
end

--城墙修理
function create_repair_Rampart()
	local ret = create_basic( "homeImage_air_Repair.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_repair_Rampart
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end

--城墙着火
function create_fire_Rampart()
	local ret = create_basic( "homeImage_air_Fire.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_fire_Rampart
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end

--医院 请求帮助伤兵
function create_help_Hospital()
	local ret = create_basic( "homeImage_hospital_Help.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_help_Hospital
	return ret
end

--研究所 请求帮助研究
function create_help_Institute()
	local ret = create_basic( "homeImage_study_Help.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_help_Institute
	return ret
end

--酒馆 可以招募
function create_help_Bar()
	local ret = create_basic( "homeImage_general.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_recruit_Bar
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end

--收获 磨坊
function create_harvest_Grindery()
	local ret = create_basic( "homeImage_mill_Gain.png" )
	ret.lua_OnClick = HomeAirClickMD.onClick_harvest_Grindery
	return ret
end

--官府 可佩戴装备
function create_canWear_MainCity()
	local ret = create_basic( "homeImage_equip.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_canWear_MainCity
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end


--校场 空闲。。。。。
function create_sleep_Spectacular()
	local ret = create_basic("homeImage_army_leisure.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_sleep_Spectacular
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end


--神龛 能用
function create_canUse_god()
	local ret = create_basic("homeImage_huashen.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_canUse_god
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end


--观星台 免费
function create_free_stars()
	local ret = create_basic("homeImage_zhanxing.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_free_stars
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end


--城墙上的少死兵BUFF
function create_wanqiangdouzhi_Rampart()
	local ret = create_basic("homeImage_wanqiangbuff.png")
	ret:setPosition(cc.p(-330, -70))
	ret.lua_OnClick = HomeAirClickMD.onClick_wanqiangdouzhi_rampart
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end


function create_wudou()
	local ret = create_basic( "homeImage_dueldrop.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_wudou
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end

function create_star_reward_Bar()
	local ret = create_basic( "homeImage_jiuguanstar.png")
	ret.lua_OnClick = HomeAirClickMD.onClick_Bar
	ret.lua_clickMode = m_AirClickMode.airIn --气泡内点击
	return ret
end

return homeAir