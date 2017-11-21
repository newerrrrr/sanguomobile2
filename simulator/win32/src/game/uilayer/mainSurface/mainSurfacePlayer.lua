local mainSurfacePlayer = {}
setmetatable(mainSurfacePlayer,{__index = _G})
setfenv(1,mainSurfacePlayer)


local c_tag_icon_play_harvest_action = 5541214
local c_tag_icon_play_power_up = 5541215
local c_tag_icon_play_exp_up = 5541216
local c_tag_icon_play_power_animation = 5541217
local c_tag_icon_play_exp_animation = 5541218

local m_Root = nil
local m_Widget = nil
local m_BtnList = {}

local powerAction = false;
local expAction = false;

local vipTipsTouchFlag = false

local actMoneyNum = 0

local function clearGlobal()
	m_Root = nil
	m_Widget = nil
    m_BtnList = {}
    powerAction = false
    expAction = false
    actMoneyNum = 0
end


--计算资源显示位置编号
local function _getResourcesPlace(btp)
	local s = string.split(g_data.starting[37].name, ",")
	for k , v in ipairs(s) do
		if tonumber(v) == btp then
			return k
		end
	end
	assert(false,"error : resources place")
end


--根据资源位置编号找到对应节点
local function _getResourcesNodeWithPlace(place)
	return m_Widget:getChildByName("scale_node"):getChildByName("Image_xinxban"):getChildByName(string.format("Panel_m%d",place))
end


--控制资源显示
local function _consoleResourcesShow(rtp, visible)
	local place = _getResourcesPlace(rtp)
	local resNode = _getResourcesNodeWithPlace(place)
	resNode:setVisible(visible)
	if visible == true then
		local image = resNode:getChildByName("Image_1")
        local text = resNode:getChildByName("Text_7")
        local count, icon = g_gameTools.getPlayerCurrencyCount( rtp )
        text:setString( string.formatnumberlogogram( tonumber(count) ) )
        image:loadTexture(icon)
	end
end


function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
            schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_visible, 0, false)
            schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(viewChangeShow, 10, false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	
	m_Widget = g_gameTools.LoadCocosUI("zhuchengjiemian_01.csb",1)
	rootLayer:addChild(m_Widget)

	local playerIcon = m_Widget:getChildByName("scale_node"):getChildByName("Image_3")
	playerIcon:addTouchEventListener(onBottonPlayer)
    --新手引导
    g_guideManager.registComponent(9999993,m_Widget:getChildByName("scale_node"):getChildByName("Panel_9"))

    
    --商城
    local mainShopBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_huodong")
    local mainShopStr = mainShopBtn:getChildByName("Text_2")
    mainShopStr:setLocalZOrder(1)
    --zhcn
    mainShopStr:setString(g_tr("shop"))
    mainShopBtn:addTouchEventListener(onBottonShop)
    mainShopBtn.openPlayerLv = tonumber(g_data.starting[71].data)
    
	--在线奖励
    local mainLimitGiftBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_time")
    local mainLimitGiftStr = mainLimitGiftBtn:getChildByName("Text_2")
    mainLimitGiftStr:setLocalZOrder(1)
    --zhcn
    mainLimitGiftStr:setString(g_tr("LimitedRewardTitle"))
    mainLimitGiftBtn:addTouchEventListener(onButtonLimitGift)
    mainLimitGiftBtn.openPlayerLv = tonumber(g_data.starting[72].data)

    --签到
    local mainSignBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_Sign")
    local mainSignStr = mainSignBtn:getChildByName("Text_2")
    mainSignStr:setLocalZOrder(1)
    mainSignBtn.openPlayerLv = tonumber(g_data.starting[76].data)
    --zhcn
    mainSignStr:setString(g_tr("sign"))
    mainSignBtn:addTouchEventListener(onButtonSign)

    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZaiXianJiangLiTuBiao/Effect_ZaiXianJiangLiTuBiao.ExportJson", "Effect_ZaiXianJiangLiTuBiao")
    armature:setPosition(cc.p( mainSignBtn:getContentSize().width/2,mainSignBtn:getContentSize().height/2 ))
    mainSignBtn:addChild(armature)
    animation:play("Animation1")
    
    --排行榜
    local mainRankBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_Ranking")
    mainRankBtn.openPlayerLv = tonumber(g_data.starting[77].data)
    local mainRankStr = mainRankBtn:getChildByName("Text_2")
    mainRankStr:setLocalZOrder(1)
    --zhcn
    mainRankStr:setString(g_tr("rankTitleStr"))
    mainRankBtn:addTouchEventListener(onButtonRank)
    
    --活动
    local activityBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_Ranking_0")
    local activityStr = activityBtn:getChildByName("Text_2")
    activityStr:setLocalZOrder(1)
    activityStr:setString(g_tr("activityTitleStr"))
    activityBtn:addTouchEventListener(onButtonActivity)
    activityBtn.openPlayerLv = tonumber(g_data.starting[70].data)
    g_activityData.InitData()

    local crossBattleBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_kf1")
    local crossBattleStr = crossBattleBtn:getChildByName("Text_2")
    crossBattleStr:setLocalZOrder(1)
    crossBattleStr:setString(g_tr("crossBattleInfo"))
    crossBattleBtn:addTouchEventListener(onButtonCross)

    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZaiXianJiangLiTuBiao/Effect_ZaiXianJiangLiTuBiao.ExportJson", "Effect_ZaiXianJiangLiTuBiao")
    armature:setPosition(cc.p( crossBattleBtn:getContentSize().width/2,crossBattleBtn:getContentSize().height/2 ))
    crossBattleBtn:addChild(armature)
    animation:play("Animation1")

    local newbieBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_cz1")
    local newbieStr = newbieBtn:getChildByName("Text_2")
    newbieStr:setLocalZOrder(1)
    newbieStr:setString(g_tr("newbieBtnTxt"))
    newbieBtn:addTouchEventListener(onButtonNewbie)
    newbieBtn.openPlayerLv = tonumber(g_data.starting[103].data)
    --新手
    g_activityData.ShowEffect()

    --战斗力提升tips
    local tips = m_Widget:getChildByName("scale_node"):getChildByName("Image_xinxban"):getChildByName("Panel_1"):getChildByName("Image_zdl")
    local txtTips = tips:getChildByName("Text_nr"):setString(g_tr("mainPowerUp"))

    local act1 = cc.Sequence:create(cc.FadeTo:create(1.0, 0),cc.CallFunc:create(function()
                          tips:setVisible(false) 
                        end))
            local action = cc.Sequence:create(cc.DelayTime:create(8.0),act1)
            tips:runAction(action)

    --充值礼包
    local giftBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_libao")
    local giftStr = giftBtn:getChildByName("Text_2")
    giftStr:setLocalZOrder(1)
    giftStr:setString(g_tr("gift"))
    giftBtn:addTouchEventListener(onButtonGift)
    giftBtn.openPlayerLv = tonumber(g_data.starting[73].data)

    local data = g_activityData.GetGiftData()
    if data == nil or data.list == nil or #data.list == 0 then
    else
        local d = activityProcessData(data)
        dump(d)
        actMoneyNum = math.random(1, #d)
        local gift = g_data.activity_commodity[tonumber(d[actMoneyNum][1].aci)]
        m_Widget:getChildByName("scale_node"):getChildByName("Image_libao"):loadTexture(g_resManager.getResPath(gift.gift_show_icon))
    end

    local projName = "Effect_ShangChengTuBiaoBianKuangXunHuan"
    local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName,onMovementEventCallFunc)
    armature:setPosition(cc.p( giftBtn:getContentSize().width/2,giftBtn:getContentSize().height/2 ))
    giftBtn:addChild(armature)
    animation:play("Animation1")
   

    --和氏璧活动
    --m_Widget:getChildByName("scale_node"):getChildByName("Image_hsb")
    local hsbActBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_hsb")
    hsbActBtn.openPlayerLv = tonumber(g_data.starting[80].data)
    local hsbActStr = hsbActBtn:getChildByName("Text_2")
    hsbActStr:setLocalZOrder(1)
    hsbActStr:setString(g_tr("HSBName"))
    hsbActBtn:addTouchEventListener(onButtonHSBAct)
    
    --成长任务活动
    local targetActivityBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_xs")
    --targetActivityBtn:setVisible(true)
    local targetActivityStr = targetActivityBtn:getChildByName("Text_2")
    targetActivityStr:setLocalZOrder(1)
    targetActivityStr:setString(g_tr("activitySevenTargetTitleStr"))
    targetActivityBtn:addTouchEventListener(onButtonXSAct)
    targetActivityBtn.openPlayerLv = tonumber(g_data.starting[74].data)
    
    g_guideManager.registComponent(9999501,targetActivityBtn)

    --黄巾起义
    local huangjinActivityBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_hj1")
    huangjinActivityBtn:getChildByName("Text_2"):setLocalZOrder(1)
    huangjinActivityBtn:getChildByName("Text_2"):setString(g_tr("huangjinqiyiTitle"))
    huangjinActivityBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local guildHuangjinData = require("game.uilayer.activity.huangjinqiyi.huangjinNpcData").GetData()
            if guildHuangjinData then
                if not guildHuangjinData.hasBase then
                    g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.ACTIVITY,{activity_id = 1003,params = 3}) --去联盟任务活动的和黄巾起义标签
                elseif guildHuangjinData.guildHuangjin and guildHuangjinData.guildHuangjin.status == 2 then --活动不在进行中（失败或者没激活）
                    g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.ACTIVITY,{activity_id = 1003,params = 3}) --去联盟任务活动的和黄巾起义标签
                else
                    require("game.uilayer.activity.huangjinqiyi.ActivityHuangJinQiYi").show()
                end
            end
        end
    end)
    huangjinActivityBtn.openPlayerLv = tonumber(g_data.starting[81].data)

    local juDianActivityBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_hj1_0")
    juDianActivityBtn:getChildByName("Text_2"):setLocalZOrder(1)
    juDianActivityBtn:getChildByName("Text_2"):setString(g_tr("sholdTitle"))
    juDianActivityBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local strongholdFindLayer = require("game.uilayer.activity.strongholdBattle.strongholdFindView"):create()
            g_sceneManager.addNodeForUI(strongholdFindLayer)
        end
    end)
    juDianActivityBtn.openPlayerLv = tonumber(g_data.starting[81].data)

    --皇城战
    local huangChengZhanBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_guowangz")
    huangChengZhanBtn:getChildByName("Text_2"):setLocalZOrder(1)
    huangChengZhanBtn:getChildByName("Text_2"):setString(g_tr("kworld_title_1"))
    huangChengZhanBtn:addTouchEventListener(onButtonHuangCheng)

    local citiBattleBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_cz")
    citiBattleBtn:getChildByName("Text_2"):setLocalZOrder(1)
    citiBattleBtn:getChildByName("Text_2"):setString(g_tr("city_battle_name"))
    citiBattleBtn:addTouchEventListener(onButtonCityBattle)

    --添加主界面按钮时候 将文字层设置高一层 以免被特效挡住按钮标题

    --这个按钮位置不能改变也不能修改作为对齐参照物坐标
    table.insert( m_BtnList,mainShopBtn)
    table.insert( m_BtnList,mainSignBtn)
    table.insert( m_BtnList,mainRankBtn)
    table.insert( m_BtnList,activityBtn)
    table.insert( m_BtnList,hsbActBtn)
    table.insert( m_BtnList,targetActivityBtn)
    table.insert( m_BtnList,giftBtn)
    table.insert( m_BtnList,newbieBtn)
    table.insert( m_BtnList,crossBattleBtn)
    
    table.insert( m_BtnList,mainLimitGiftBtn)
    table.insert( m_BtnList,huangjinActivityBtn)
    table.insert( m_BtnList,juDianActivityBtn)
    table.insert( m_BtnList,huangChengZhanBtn)
    table.insert( m_BtnList,citiBattleBtn)

    --战斗力
    m_Widget:getChildByName("scale_node"):getChildByName("Image_xinxban"):getChildByName("Panel_gongji"):addTouchEventListener(onButtonPower)
    local panel = m_Widget:getChildByName("scale_node"):getChildByName("Image_xinxban"):getChildByName("Panel_gongji"):getChildByName("Panel_texiao")
    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZhuYeZhanDouLiAnNiu/Effect_ZhuYeZhanDouLiAnNiu.ExportJson", "Effect_ZhuYeZhanDouLiAnNiu")
    armature:setPosition(cc.p( panel:getContentSize().width/2,panel:getContentSize().height/2 ))
    panel:addChild(armature)
    animation:play("Effect_ZhuYeZhanDouLiAnNiuXunHuan")
    --充值按钮
    local payBtn = m_Widget:getChildByName("scale_node"):getChildByName("Panel_6"):getChildByName("Image_15")
    payBtn:addTouchEventListener(onButtonMoney)

    --充值按钮特效
    if payBtn.fx == nil then
        local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ChuZhiAnNiuSaoGuang/Effect_ChuZhiAnNiuSaoGuang.ExportJson","Effect_ChuZhiAnNiuSaoGuang")
        armature:setPosition( cc.p(payBtn:getContentSize().width/2,payBtn:getContentSize().height/2) )
        payBtn:addChild(armature)
        animation:play("Animation1")
        payBtn.fx = armature
    end

	--商城按钮动画
    local projName = "Effect_ShangChengTuBiaoBianKuangXunHuan"
    local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName,onMovementEventCallFunc)
    m_Widget:getChildByName("scale_node"):getChildByName("Image_huodong"):addChild(armature)
    animation:play("Animation1")
    
    local btnSize = m_Widget:getChildByName("scale_node"):getChildByName("Image_huodong"):getContentSize()
    armature:setPosition(cc.p(btnSize.width * 0.5,btnSize.height * 0.5))
	
	function onBuild_Food(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			onClick_Food()
		end
	end
	_getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Food)):addTouchEventListener(onBuild_Food)
	
	function onBuild_Wood(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			onClick_Wood()
		end
	end
	_getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Wood)):addTouchEventListener(onBuild_Wood)
	
	function onBuild_Stone(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			onClick_Stone()
		end
	end
	_getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Stone)):addTouchEventListener(onBuild_Stone)
	
	function onBuild_Iron(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			onClick_Iron()
		end
	end
	_getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Iron)):addTouchEventListener(onBuild_Iron)
	
	function onBuild_Gold(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			onClick_Gold()
		end
	end
	_getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Gold)):addTouchEventListener(onBuild_Gold)
	
	g_resourcesInterface.getResInterfaceShowCount()
	
	updateShowWithData_All()
    showUiAddTouchListener()
    updateShowWithData_LimitGift()
    updatePower()
    viewChangeShow()
    addEvent()

	return rootLayer
end

function addEvent()
    local function custom()
        g_actSevenDayTarget.NotificationUpdateShow()
    end

    g_gameCommon.addEventHandler(g_Consts.CustomEvent.PlayerTarget, custom)
    
    g_gameCommon.addEventHandler(g_Consts.CustomEvent.GuildAccept, function(_,data)
        g_AllianceMode.reqAllAllianceDataAsync()
        if data then
            --g_airBox.show(g_tr("guildAcceptTip",{guild_name = data.guild_name,player_name = data.nick}))
            g_msgBox.show(g_tr("guildAcceptTip",{guild_name = data.guild_name,player_name = data.nick}),g_tr("guildAcceptTipTitle"),nil)
        end
    end)
    
    g_gameCommon.addEventHandler(g_Consts.CustomEvent.GuildApply, function(_,data)
        g_AllianceMode.setRequestNum(tonumber(data.request_number))
        local haveTip = g_battleHallData.showTip()
        if not haveTip and g_AllianceMode.isAllianceManager() then
            haveTip = g_AllianceMode.getRequestNum() > 0  
        end
        require("game.uilayer.mainSurface.mainSurfaceMenu").doGuildTipUpdate(haveTip)
    end)
    
end

function update_visible(dt)
	if m_Root == nil then
		return
	end
	if g_resourcesInterface.getResInterfaceShowCount() > 0 then
		m_Widget:setVisible(false)
	else
		m_Widget:setVisible(true)
	end


end

function updateShowWithData_Res()
    -- print("updateShowWithData_Res")
	if m_Root == nil then
		return
	end

	local playerData = g_PlayerMode.GetData()
	if(playerData == nil)then
		return
	end
	
	
	if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.gold) then
		_consoleResourcesShow(g_Consts.AllCurrencyType.Gold, true)
	else
		_consoleResourcesShow(g_Consts.AllCurrencyType.Gold, false)
	end
	
	if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.wood) then
		_consoleResourcesShow(g_Consts.AllCurrencyType.Wood, true)
	else
		_consoleResourcesShow(g_Consts.AllCurrencyType.Wood, false)
	end
	
	if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.food) then
		_consoleResourcesShow(g_Consts.AllCurrencyType.Food, true)
	else
		_consoleResourcesShow(g_Consts.AllCurrencyType.Food, false)
	end
	
	if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.stone) then
		_consoleResourcesShow(g_Consts.AllCurrencyType.Stone, true)
	else
		_consoleResourcesShow(g_Consts.AllCurrencyType.Stone, false)
	end
	
	if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.iron) then
		_consoleResourcesShow(g_Consts.AllCurrencyType.Iron, true)
	else
		_consoleResourcesShow(g_Consts.AllCurrencyType.Iron, false)
	end
    
	--元宝
    m_Widget:getChildByName("scale_node"):getChildByName("Panel_6"):getChildByName("Text_3"):setString(  tostring(g_PlayerMode.getDiamonds() or 0) --[[string.formatnumberthousands( g_PlayerMode.getDiamonds() or 0 )]]  )
    local gemCount, gemIcon = g_gameTools.getPlayerCurrencyCount( g_Consts.AllCurrencyType.Gem )
    --元宝ICON
    m_Widget:getChildByName("scale_node"):getChildByName("Panel_6"):getChildByName("Image_13"):loadTexture(gemIcon)
end

function updateShowWithData_LimitGift()
    if m_Root == nil or m_Widget == nil then
        return
    end
    
    local limitGiftBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_time")
    
    if limitGiftBtn.fx == nil then
        local fxPath = "anime/Effect_ZaiXianJiangLiTuBiao/Effect_ZaiXianJiangLiTuBiao.ExportJson"
        local fxName = "Effect_ZaiXianJiangLiTuBiao"
        local armature , animation = g_gameTools.LoadCocosAni(fxPath, fxName)
        armature:setPosition(cc.p( limitGiftBtn:getContentSize().width/2,limitGiftBtn:getContentSize().height/2 ))
        limitGiftBtn:addChild(armature)
        animation:play("Animation1")
        limitGiftBtn.fx = armature
    end

    --防止第二天重新获取新数据后，停在城市外面界面显示出来
    local showData = require("game.uilayer.activity.ActivityMode"):getNowShowData()
    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()    
    
    limitGiftBtn:setVisible(false)
    limitGiftBtn.fx:setVisible(false)
    limitGiftBtn:getChildByName("Text_3"):setTextColor( cc.c3b( 255,255,255 ) )
    if limitGiftBtn.as then
        limitGiftBtn:stopAction(limitGiftBtn.as)
        limitGiftBtn.as = nil
    end
    
    if showData and mapStatus == changeMapScene.m_MapEnum.home then
        limitGiftBtn:setVisible(true)
        if limitGiftBtn.as == nil then
            local endTime = showData.time_start + showData.online_award_duration
            local overTime = endTime - g_clock.getCurServerTime()
            --不可以领取
            if overTime > 0 then
                limitGiftBtn:getChildByName("Text_3"):setString(g_gameTools.convertSecondToString(overTime))
                local function callback()
                    overTime = endTime - g_clock.getCurServerTime()
                    if overTime > 0 then
                        limitGiftBtn:getChildByName("Text_3"):setString(g_gameTools.convertSecondToString(overTime))
                    else
                        if limitGiftBtn.as then
                            limitGiftBtn:stopAction(limitGiftBtn.as)
                            limitGiftBtn.as = nil
                        end
                        limitGiftBtn.fx:setVisible(true)
                        limitGiftBtn:getChildByName("Text_3"):setTextColor( cc.c3b( 30,230,30 ) )
                        limitGiftBtn:getChildByName("Text_3"):setString( g_tr("taskReceive") )
                    end
                end

                local delay = cc.DelayTime:create(1)
                local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
                local action = cc.RepeatForever:create(sequence)
                limitGiftBtn.as = action
                limitGiftBtn:runAction(limitGiftBtn.as)
            else
                --可以领取
                limitGiftBtn.fx:setVisible(true)
                limitGiftBtn:getChildByName("Text_3"):setTextColor( cc.c3b( 30,230,30 ) )
                limitGiftBtn:getChildByName("Text_3"):setString( g_tr("taskReceive") )
            end
        end
    end
end

function showSevenTargetEffect(isShow)
    if m_Root == nil or m_Widget == nil then
        return
    end
    
    local sevenDayTarget = m_Widget:getChildByName("scale_node"):getChildByName("Image_xs")

    if isShow == false then
        if sevenDayTarget.fx ~= nil then
            sevenDayTarget:removeChild(sevenDayTarget.fx)
            sevenDayTarget.fx = nil
        end
    else
        if sevenDayTarget.fx == nil then
            local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZaiXianJiangLiTuBiao/Effect_ZaiXianJiangLiTuBiao.ExportJson", "Effect_ZaiXianJiangLiTuBiao")
            armature:setPosition(cc.p( sevenDayTarget:getContentSize().width/2,sevenDayTarget:getContentSize().height/2 ))
            sevenDayTarget:addChild(armature)
            animation:play("Animation1")
            sevenDayTarget.fx = armature
        end
    end
end

function showSignEffect(isShow)
    if m_Root == nil or m_Widget == nil then
        return
    end
    
    local mainSignBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_Sign")
    if isShow == false then
        if mainSignBtn.fx ~= nil then
            mainSignBtn:removeChild(mainSignBtn.fx)
            mainSignBtn.fx = nil
        end
    else
        if mainSignBtn.fx == nil then
            local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZaiXianJiangLiTuBiao/Effect_ZaiXianJiangLiTuBiao.ExportJson", "Effect_ZaiXianJiangLiTuBiao")
            armature:setPosition(cc.p( mainSignBtn:getContentSize().width/2,mainSignBtn:getContentSize().height/2 ))
            mainSignBtn:addChild(armature)
            animation:play("Animation1")
            mainSignBtn.fx = armature
        end
    end
end

function showNewbieEffect(isShow)
    if m_Root == nil or m_Widget == nil then
        return
    end

    local btn = m_Widget:getChildByName("scale_node"):getChildByName("Image_cz1")
    if isShow == false then
        if btn.fx ~= nil then
            btn.fx:removeFromParent()
            btn.fx = nil
        end
    else
        if btn.fx == nil then
            local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZaiXianJiangLiTuBiao/Effect_ZaiXianJiangLiTuBiao.ExportJson", "Effect_ZaiXianJiangLiTuBiao")
            armature:setPosition(cc.p( btn:getContentSize().width/2,btn:getContentSize().height/2 ))
            btn:addChild(armature)
            animation:play("Animation1")
            btn.fx = armature
        end
    end
end

function showActivityBtnEffect(isShow)
    if m_Root == nil or m_Widget == nil then
        return
    end
    
    local btn = m_Widget:getChildByName("scale_node"):getChildByName("Image_Ranking_0")
    if isShow == false then
        if btn.fx ~= nil then
            btn.fx:removeFromParent()
            btn.fx = nil
        end
    else
        if btn.fx == nil then
            local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZaiXianJiangLiTuBiao/Effect_ZaiXianJiangLiTuBiao.ExportJson", "Effect_ZaiXianJiangLiTuBiao")
            armature:setPosition(cc.p( btn:getContentSize().width/2,btn:getContentSize().height/2 ))
            btn:addChild(armature)
            animation:play("Animation1")
            btn.fx = armature
        end
    end
end

function updateShowWithData_Lv()
    -- print("updateShowWithData_Lv")
	if m_Root == nil then
		return
	end
	local playerData = g_PlayerMode.GetData()
	if(playerData == nil)then
		return
	end
	
	m_Widget:getChildByName("scale_node"):getChildByName("Panel_dengji"):getChildByName("Panel_1"):getChildByName("AtlasLabel_1"):setString(tostring(playerData.level))
    local exp_bar = m_Widget:getChildByName("scale_node"):getChildByName("Panel_dengji"):getChildByName("Panel_1"):getChildByName("LoadingBar_1")
    local move_bar = m_Widget:getChildByName("scale_node"):getChildByName("Panel_dengji"):getChildByName("Panel_2"):getChildByName("LoadingBar_1")
    local move_label = m_Widget:getChildByName("scale_node"):getChildByName("Panel_dengji"):getChildByName("Panel_2"):getChildByName("Text_xingdl")
    move_label:setString(g_tr("MasterMove")..g_PlayerMode.getMove().."/"..g_PlayerMode.getLimitMove())
    move_bar:setPercent( g_PlayerMode.getMove() / g_PlayerMode.getLimitMove() * 100 )

    local cur_exp = ( playerData.current_exp or 0 ) - g_data.master[ playerData.level ].exp
    local n_exp = ( playerData.next_exp or 0 ) - g_data.master[ playerData.level ].exp

    exp_bar:setPercent( ( cur_exp / n_exp ) * 100  )
end


function updateShowWithData_HeadIcon()
    -- print("updateShowWithData_HeadIcon")
	if m_Root == nil then
		return
	end
	local playerData = g_PlayerMode.GetData()
	if(playerData == nil)then
		return
	end
	
    local resConfig = g_data.res_head[ playerData.avatar_id ]
    
    if resConfig == nil then
        playerData.avatar_id = 1
    end

    local iconid = g_data.res_head[ playerData.avatar_id ].head_icon
    local icon = m_Widget:getChildByName("scale_node"):getChildByName("Image_3")
    
    icon:removeAllChildren()

    --创建圆形头像
    local clipper = require("game.uilayer.master.MasterMode").createCircleHead(g_resManager.getResPath( iconid))
    clipper:setPosition( cc.p( icon:getContentSize().width/2,icon:getContentSize().height/2 ) )
    icon:addChild(clipper)
    
    --天赋点特效
    if icon.fx == nil then
        local armature , animation
        armature , animation = g_gameTools.LoadCocosAni(
            "anime/Effect_ZhuGongTouXiangBianKuangJiHuo/Effect_ZhuGongTouXiangBianKuangJiHuo.ExportJson"
            , "Effect_ZhuGongTouXiangBianKuangJiHuo"
        )
        animation:play("Animation1")
        armature:setPosition( cc.p(icon:getPositionX()-5,icon:getPositionY()+ 2))
        icon:getParent():addChild(armature)
        icon.fx = armature
    end

    if playerData.talent_num_remain > 0 then
        icon.fx:setVisible(true)
    else
        icon.fx:setVisible(false)
    end

end

function updateShowWithData_Vip()
    -- print("updateShowWithData_Vip")
    if m_Root == nil then
        return
    end

    local playerData = g_PlayerMode.GetData()
    if nil == playerData then return end

    local vip_panel = m_Widget:getChildByName("scale_node"):getChildByName("Image_xinxban"):getChildByName("Panel_1")
    local lbLevel = vip_panel:getChildByName("Text_7")

    lbLevel:setString(""..playerData.vip_level)
    local function setVipIconGray(isGray)
        -- print("setVipIconGray", isGray)
        local icon = vip_panel:getChildByName("Image_1")
        local icon2 = vip_panel:getChildByName("Image_5")
        if isGray then 
            lbLevel:setTextColor(cc.c3b(193, 193, 193))
            icon:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.shaderMode.shader_gray))
            icon2:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.shaderMode.shader_gray))
        else 
            icon:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
            icon2:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
            lbLevel:setTextColor(cc.c3b(253, 208, 110))
        end 
    end 

    local imgInactive = vip_panel:getChildByName("Image_8")
    local VIPMode = require("game.uilayer.vip.VIPMode")
    local leftSec = VIPMode.getVipLeftTime()
    if leftSec > 0 then 
      vipTipsTouchFlag = false 
      imgInactive:setVisible(false) 
      setVipIconGray(false)
    else 
        if not vipTipsTouchFlag then --防止点击隐藏后,在每次刷新界面都显示
            imgInactive:setVisible(true)
            local act1 = cc.Sequence:create(cc.FadeTo:create(1.0, 0),cc.CallFunc:create(function()
                          vipTipsTouchFlag = false 
                          imgInactive:setVisible(false) 
                        end))
            local action = cc.Sequence:create(cc.DelayTime:create(4.0),act1)
            imgInactive:runAction(action)
        end  
        setVipIconGray(true)      
    end 
end

--更新整个显示,根据缓存数据
function updateShowWithData_All()
	updateShowWithData_Res()
	updateShowWithData_Lv()
	updateShowWithData_HeadIcon()
    updateShowWithData_Vip()
end

--单独更新战斗力
function updatePower()
    if m_Root == nil then
		return
	end

	local playerData = g_PlayerMode.GetData()
	if(playerData == nil)then
		return
	end

    local mainPanel = m_Widget:getChildByName("scale_node"):getChildByName("Image_xinxban")
    --战斗力
	mainPanel:getChildByName("Panel_gongji"):getChildByName("Text_7"):setString( string.formatnumberthousands( tonumber(playerData.power) or 0 ) )
end

--点击商城图标
function onBottonShop(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.shop.ShopLayer"):create(g_Consts.ShopType.NORMAL))
    end
end

--点击限时活动
function onButtonLimitGift(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.activity.ActivityLimitedReward"):createLayer()
        --updateShowWithData_LimitGift()
    end
end

--点击战斗力
function onButtonPower(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.power.PowerView").new())
        --g_sceneManager.addNodeForUI(require("game.uilayer.power.FaqView").new())
        --g_sceneManager.addNodeForUI(require("game.uilayer.activity.activityMoney.ActivityMoneyView").new())
    end
end

--点击充值按钮
function onButtonMoney(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyView").new())
    end
end

--点击签到
function onButtonSign(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.activity.activitySign.activity_signAward").new())
    end
end

--点击排行榜
function onButtonRank(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.rank.RankView").new())
    end
end

--点击活动
function onButtonActivity(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.activity.ActivityMainLayer").new(g_activityData.ActivityType.Normal))
    end
end

--点击新手礼包
function onButtonNewbie(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.activity.ActivityMainLayer").new(g_activityData.ActivityType.openService))
    end
end

function onButtonCross(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.activity.ActivityMainLayer").show(1025)
    end
end

--点击礼包
function onButtonGift(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local view  = require("game.uilayer.activity.activityMoney.ActivityMoneyView").new(actMoneyNum)
        g_sceneManager.addNodeForUI(view)
    end
end

function onButtonXSAct(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.activity.ActivityMainLayer").show(1007)
    end
end

--和氏璧活动
function onButtonHSBAct(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local ActivityJadeLayer = require("game.uilayer.activity.activityJade.ActivityJadeMainLayer"):create()
        g_sceneManager.addNodeForUI(ActivityJadeLayer)
    end
end

function onButtonHuangCheng(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingActivityLayer"):create())
    end
end

function onButtonCityBattle(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local view = require("game.uilayer.cityBattle.CityMap"):create()
        g_sceneManager.addNodeForUI(view)
    end
end


--点击主公头像
function onBottonPlayer(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--判断加载UI数据是否完全获取
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        
        local MasterView = require("game.uilayer.master.MasterView")
        MasterView:createLayer()
        
        --[[local function onRecv(r,d)
            if r == true then
                dump(d)
            end
        end

        g_sgHttp.postData("city_battle/getFirstCityBattleDate",{},onRecv)
        ]]

        --local view = require("game.uilayer.cityBattle.CityTechnologyLayer"):create()
        --local view = require("game.uilayer.cityBattle.CityMap"):create()
        --local view = require("game.uilayer.cityBattle.CityDoorReport").Show()

	end
end


--点食物跳转
function onClick_Food()
	require("game.uilayer.shop.UseResourceView").show(g_Consts.AllCurrencyType.Food)
end

--点木头跳转
function onClick_Wood()
	require("game.uilayer.shop.UseResourceView").show(g_Consts.AllCurrencyType.Wood)
end

--点石头跳转
function onClick_Stone()
	require("game.uilayer.shop.UseResourceView").show(g_Consts.AllCurrencyType.Stone)
end

--点铁跳转
function onClick_Iron()
	require("game.uilayer.shop.UseResourceView").show(g_Consts.AllCurrencyType.Iron)
end

--点金跳转
function onClick_Gold()
	require("game.uilayer.shop.UseResourceView").show(g_Consts.AllCurrencyType.Gold)
end



function getPositionWorldSpace_Food()
	if m_Root == nil then
		return nil
	end
	if m_Food_Position_WorldSpace == nil then --故意的模块中全局变量
		local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Food)):getChildByName("Image_1")
		local size = node:getContentSize()
		m_Food_Position_WorldSpace = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
	end
	return cc.p(m_Food_Position_WorldSpace.x, m_Food_Position_WorldSpace.y)
end

function getPositionWorldSpace_Wood()
	if m_Root == nil then
		return nil
	end
	if m_Wood_Position_WorldSpace == nil then --故意的模块中全局变量
		local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Wood)):getChildByName("Image_1")
		local size = node:getContentSize()
		m_Wood_Position_WorldSpace = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
	end
	return cc.p(m_Wood_Position_WorldSpace.x, m_Wood_Position_WorldSpace.y)
end

function getPositionWorldSpace_Stone()
	if m_Root == nil then
		return nil
	end
	if m_Stone_Position_WorldSpace == nil then --故意的模块中全局变量
		local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Stone)):getChildByName("Image_1")
		local size = node:getContentSize()
		m_Stone_Position_WorldSpace = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
	end
	return cc.p(m_Stone_Position_WorldSpace.x, m_Stone_Position_WorldSpace.y)
end

function getPositionWorldSpace_Iron()
	if m_Root == nil then
		return nil
	end
	if m_Iron_Position_WorldSpace == nil then --故意的模块中全局变量
		local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Iron)):getChildByName("Image_1")
		local size = node:getContentSize()
		m_Iron_Position_WorldSpace = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
	end
	return cc.p(m_Iron_Position_WorldSpace.x, m_Iron_Position_WorldSpace.y)
end

function getPositionWorldSpace_Gold()
	if m_Root == nil then
		return nil
	end
	if m_Gold_Position_WorldSpace == nil then --故意的模块中全局变量
		local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Gold)):getChildByName("Image_1")
		local size = node:getContentSize()
		m_Gold_Position_WorldSpace = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
	end
	return cc.p(m_Gold_Position_WorldSpace.x, m_Gold_Position_WorldSpace.y)
end



local function _createHarvestAction()
	return cc.Sequence:create(
			cc.ScaleTo:create(0.1,1.2)
			,cc.ScaleTo:create(0.2,0.8)
			,cc.ScaleTo:create(0.2,1.2)
			,cc.ScaleTo:create(0.2,0.8)
			,cc.ScaleTo:create(0.2,1.2)
			,cc.ScaleTo:create(0.15,0.9)
			,cc.ScaleTo:create(0.1,1.0)
			)
end


function playHarvest_Food()
	if m_Root == nil then
		return nil
	end
	local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Food)):getChildByName("Image_1")
	if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
		local action = _createHarvestAction()
		action:setTag(c_tag_icon_play_harvest_action)
		node:runAction(action)
	end
end

function playHarvest_Wood()
	if m_Root == nil then
		return nil
	end
	local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Wood)):getChildByName("Image_1")
	if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
		local action = _createHarvestAction()
		action:setTag(c_tag_icon_play_harvest_action)
		node:runAction(action)
	end
end

function playHarvest_Stone()
	if m_Root == nil then
		return nil
	end
	local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Stone)):getChildByName("Image_1")
	if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
		local action = _createHarvestAction()
		action:setTag(c_tag_icon_play_harvest_action)
		node:runAction(action)
	end
end

function playHarvest_Iron()
	if m_Root == nil then
		return nil
	end
	local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Iron)):getChildByName("Image_1")
	if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
		local action = _createHarvestAction()
		action:setTag(c_tag_icon_play_harvest_action)
		node:runAction(action)
	end
end

function playHarvest_Gold()
	if m_Root == nil then
		return nil
	end
	local node = _getResourcesNodeWithPlace(_getResourcesPlace(g_Consts.AllCurrencyType.Gold)):getChildByName("Image_1")
	if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
		local action = _createHarvestAction()
		action:setTag(c_tag_icon_play_harvest_action)
		node:runAction(action)
	end
end

function updatePowerAnimation()
    if m_Root == nil then
		return nil
	end

    if powerAction == true then
        return
    end

    powerAction = true

    local node = m_Widget:getChildByName("scale_node"):getChildByName("Image_xinxban"):getChildByName("Panel_gongji")
    local size = node:getContentSize()
    power_Position_WorldSpace = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))

    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_StarTuoWei/Effect_StarTuoWei.ExportJson", "Effect_StarTuoWei")
    m_Root:addChild(armature)
	armature:setPosition(cc.p(m_Root:getContentSize().width * 0.5, m_Root:getContentSize().height * 0.5))
	animation:play("RedTuoWei")

    local function callBack()
        m_Root:removeChild(armature)
        powerAction = false
        if node:getActionByTag(c_tag_icon_play_power_up) == nil then
            local actionBy = cc.ScaleBy:create(0.15, 2, 2)
            local callFun=cc.CallFunc:create(updatePower)
            local sequence = cc.Sequence:create(actionBy, actionBy:reverse(), callFun)
            sequence:setTag(c_tag_icon_play_power_up)
            node:runAction(sequence)
        end
    end

    local action = cc.MoveTo:create(1, power_Position_WorldSpace)
    local callFunc=cc.CallFunc:create(callBack)
    local seq=cc.Sequence:create(action, callFunc)
    armature:runAction(seq)
end

function showPowerUpView(value)
    if m_Root == nil then
        return
    end

    local view = require("game.uilayer.mainSurface.PowerUpView").new(value, updatePowerAnimation)
    m_Root:addChild(view)
    view:setPosition(cc.p(m_Root:getContentSize().width * 0.5, m_Root:getContentSize().height * 0.5))

    if view:getActionByTag(c_tag_icon_play_power_animation) == nil then
        local actionBy = cc.ScaleBy:create(0.15, 2, 2)
        local seq = cc.Sequence:create(actionBy, actionBy:reverse())
        seq:setTag(c_tag_icon_play_power_animation)
        view:runAction(seq)
    end
end

function updateExpAnimation()
   if m_Root == nil then
		return nil
	end

    if expAction == true then
        return
    end

    expAction = true

    local node = m_Widget:getChildByName("scale_node"):getChildByName("Panel_dengji"):getChildByName("Panel_1")
    local size = node:getContentSize()
    exp_Position_WorldSpace = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))

    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_StarTuoWei/Effect_StarTuoWei.ExportJson", "Effect_StarTuoWei")
    m_Root:addChild(armature)
	armature:setPosition(cc.p(m_Root:getContentSize().width * 0.5, m_Root:getContentSize().height * 0.5))
	animation:play("BlueTuoWei")

    local function callBack()
        expAction = false
        m_Root:removeChild(armature)
    end

    if armature:getActionByTag(c_tag_icon_play_exp_up) == nil then
        local action = cc.MoveTo:create(1, exp_Position_WorldSpace)
        local callFunc=cc.CallFunc:create(callBack)
        local seq=cc.Sequence:create(action, callFunc)
        seq:setTag(c_tag_icon_play_exp_up)
        armature:runAction(seq)
    end
end

function showExpUpView(value)
    if m_Root == nil then
        return
    end

    local view = require("game.uilayer.mainSurface.ExpUpView").new(value, updateExpAnimation)
    m_Root:addChild(view)
    view:setPosition(cc.p(m_Root:getContentSize().width * 0.5, m_Root:getContentSize().height * 0.5 + 100))

    if view:getActionByTag(c_tag_icon_play_exp_animation) == nil then
        local actionBy = cc.ScaleBy:create(0.15, 2, 2)
        local seq = cc.Sequence:create(actionBy, actionBy:reverse())
        seq:setTag(c_tag_icon_play_exp_animation)
        view:runAction(seq)
    end
end

local _checkBtnOpenCondition = function()
    local playerLevel = g_PlayerMode.GetData().level
    for key, btn in ipairs(m_BtnList) do
        if btn:isVisible() then
            if not g_homeBtnForceOpen then
                if btn.openPlayerLv and playerLevel < btn.openPlayerLv then
                    btn:setVisible(false)
                end
            end
        end
    end
end

--检查时效性的buff是否有更新
function updateBuffData()
    g_BuffMode.updateTimeBaseBuffs()
end

function updateCrossIcon()
    if g_activityData.GetCrossState() == true then
        m_Widget:getChildByName("scale_node"):getChildByName("Image_kf1"):setVisible(true)
    else
        m_Widget:getChildByName("scale_node"):getChildByName("Image_kf1"):setVisible(false)
    end
end

function viewChangeShow()

  -- print("update show")
  
  updateBuffData()

	if m_Root == nil then
		return nil
    else
        local changeMapScene = require("game.maplayer.changeMapScene")
        local mapStatus = changeMapScene.getCurrentMapStatus()
        
        if m_Root then
            m_Root:setVisible(true)
        end
        
        if mapStatus == changeMapScene.m_MapEnum.home then --城内
            
            for key, btn in ipairs(m_BtnList) do
                btn:setVisible(true)
            end

            --控制按钮是否显示的逻辑写在这里
            --todo

            local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()
            local cbBtn = m_Widget:getChildByName("scale_node"):getChildByName("Image_cz")
            CityBattleMode.isOpen(cbBtn)

            --在线奖励有特殊处理逻辑当天如果领取完成也不显示
            local showData = require("game.uilayer.activity.ActivityMode"):getNowShowData()
            m_Widget:getChildByName("scale_node"):getChildByName("Image_time"):setVisible(false)
            if showData then
                m_Widget:getChildByName("scale_node"):getChildByName("Image_time"):setVisible(true)
            end
            
            if g_playerInfoData.IsOpen() == false then
                m_Widget:getChildByName("scale_node"):getChildByName("Image_xs"):setVisible(false)
            end

            if showSign() == false then
                m_Widget:getChildByName("scale_node"):getChildByName("Image_Sign"):setVisible(false)
            else
                m_Widget:getChildByName("scale_node"):getChildByName("Image_Sign"):setVisible(true)
            end

            --皇城按钮
            m_Widget:getChildByName("scale_node"):getChildByName("Image_guowangz"):setVisible(g_kingInfo.isKingBtnShow())

            if g_activityData.RefreshData() then
                g_sceneManager.addNodeForUI(require("game.uilayer.activity.activityBanner.ActBannerView").new())
            end

            if g_activityData.ShowNewbieIcon() then
                m_Widget:getChildByName("scale_node"):getChildByName("Image_cz1"):setVisible(true)
            else
                m_Widget:getChildByName("scale_node"):getChildByName("Image_cz1"):setVisible(false)
            end

            if g_activityData.GetCrossState() then
                m_Widget:getChildByName("scale_node"):getChildByName("Image_kf1"):setVisible(true)
            else
                m_Widget:getChildByName("scale_node"):getChildByName("Image_kf1"):setVisible(false)
            end

        elseif mapStatus == changeMapScene.m_MapEnum.world then --城外

            for key, btn in ipairs(m_BtnList) do
                btn:setVisible(false)
            end
            
            m_Widget:getChildByName("scale_node"):getChildByName("Image_Sign"):setVisible(false)

            local isHuangWeiShow = g_kingInfo.isKingBtnShow() and not g_kingInfo.isKingBattleStarted()
            --皇城按钮显示规则 皇位战没有开始但是当天是皇位战
            m_Widget:getChildByName("scale_node"):getChildByName("Image_guowangz"):setVisible(g_kingInfo.isKingBtnShow() and not g_kingInfo.isKingBattleStarted())
            --礼包按钮显示规则 皇位战正在进行不显示
            m_Widget:getChildByName("scale_node"):getChildByName("Image_libao"):setVisible(not g_kingInfo.isKingBattleStarted())
        
        elseif mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then --联盟战城战
            if m_Root then
                m_Root:setVisible(false)
            end
        end

        --这里逻辑是不受城内外的控制的图标
        --黄巾起义
        local huangjinShow = require("game.uilayer.activity.allianceMission.AllianceMissionMode").isYellowTurbansValid()
        m_Widget:getChildByName("scale_node"):getChildByName("Image_hj1"):setVisible(huangjinShow)
        
        --据点战
        local judianShow = require("game.uilayer.activity.allianceMission.AllianceMissionMode"):isJuDianFightValid()
        m_Widget:getChildByName("scale_node"):getChildByName("Image_hj1_0"):setVisible(judianShow)

        --和氏璧
        local isHSBOpen = require("game.uilayer.activity.allianceMission.AllianceMissionMode"):isTreasureFightValid()
        m_Widget:getChildByName("scale_node"):getChildByName("Image_hsb"):setVisible(isHSBOpen)

        _checkBtnOpenCondition()
        --按钮对齐
        btnSort()
        
        
	end
	
	--如果要控制这个UI的显示与隐藏请注意:
	--上面每一帧都在监听g_resourcesInterface.getResInterfaceShowCount()函数返回的数据
	--新的显示逻辑务必与原有逻辑并存
	
end

--VIP监听事件
function vipPanelRegListener()
    if m_Root == nil then
        return
    end
    local vip_panel = m_Widget:getChildByName("scale_node"):getChildByName("Image_xinxban"):getChildByName("Panel_1")
    local btnClick = vip_panel:getChildByName("Panel_click") 
    btnClick:setTouchEnabled(true)
    btnClick:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local VIPMainLayer = require("game.uilayer.vip.VIPMainLayer").new()
            g_sceneManager.addNodeForUI(VIPMainLayer)
        end
    end)

    --失效tips
    local imgInactive = vip_panel:getChildByName("Image_8")
    imgInactive:getChildByName("Text_nr"):setString(g_tr("vip_is_inactive")) 
    imgInactive:setTouchEnabled(true)
    imgInactive:addClickEventListener(function() 
        imgInactive:setVisible(false) 
        vipTipsTouchFlag = true 
        end) 
    updateShowWithData_Vip()
end

function showUiAddTouchListener()
    vipPanelRegListener()
end


function addVisibleCount()
	if m_Root == nil then
		return nil
	end
end


function subVisibleCount()
	if m_Root == nil then
		return nil
	end
end

--自适应按钮排序
function btnSort()

    
    local posX,posY = m_BtnList[1]:getPosition()
    local index_X = 0
    local index_Y = 0
    for key, btn in ipairs(m_BtnList) do
        if btn:isVisible() then
            btn:setPosition( cc.p( posX - (btn:getContentSize().width + 23) * index_X ,posY - (btn:getContentSize().height + 10) * index_Y ) )
            index_X = index_X + 1

            if index_X % 5 == 0 then
                index_Y = index_Y + 1
                index_X = 0
            end

        end
    end

end

--当前签到按钮是否显示
function showSign()
    if m_Root == nil or m_Widget == nil then
        return false
    end

    local player = g_PlayerMode.GetData()

    if player.sign_date == 0 then
        return true
    else
        if (g_clock.getCurServerTime() - player.sign_date) < 24*3600  then
            return false
        else
            return true
        end
    end

    return false
end

function hideSign()
    m_Widget:getChildByName("scale_node"):getChildByName("Image_Sign"):setVisible(false)
    btnSort()
end

function getWidget()
    return m_Widget
end

function activityProcessData(data)

        local aciList = {}
        for i=1, #data.list do
            local sGift = g_data.activity_commodity[tonumber(data.list[i].aci)]

            if sGift.act_same_index > 0 then
            local tag = false
            for k, v in pairs(aciList) do
                if #v > 0 then
                    local sg = g_data.activity_commodity[tonumber(v[1].aci)]
                    if sg.act_same_index == sGift.act_same_index then
                        table.insert(aciList[sGift.act_same_index], data.list[i])
                        tag = true
                        break
                    end
                end
            end

            if tag == false then
                if aciList[sGift.act_same_index] == nil then
                    aciList[sGift.act_same_index] = {}
                end
                table.insert(aciList[sGift.act_same_index], data.list[i])
            end
            end
        end

        local  dataList = {}
        for k, v in pairs(aciList) do
            table.insert(dataList, v)
        end

        return dataList
end

return mainSurfacePlayer