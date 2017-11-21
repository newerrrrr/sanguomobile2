local gameTools = {}
setmetatable(gameTools,{__index = _G})
setfenv(1,gameTools)


--重置UI坐标(只针对直接addChild在sceneManager各个节点的UI使用,因为相对位置是设计坐标）
--参数 ：UI基准位置（打印的排版排序1-9）
function ResetUIPlace(widget,place)
	if(place)then
		if(place==1)then
			widget:setAnchorPoint(cc.p(0.0,1.0))
			widget:setPosition(g_display.left_top)
		elseif(place==2)then
			widget:setAnchorPoint(cc.p(0.5,1.0))
			widget:setPosition(g_display.top_center)
		elseif(place==3)then
			widget:setAnchorPoint(cc.p(1.0,1.0))
			widget:setPosition(g_display.right_top)
		elseif(place==4)then
			widget:setAnchorPoint(cc.p(0.0,0.5))
			widget:setPosition(g_display.left_center)
		elseif(place==5)then
			widget:setAnchorPoint(cc.p(0.5,0.5))
			widget:setPosition(g_display.center)
		elseif(place==6)then
			widget:setAnchorPoint(cc.p(1.0,0.5))
			widget:setPosition(g_display.right_center)
		elseif(place==7)then
			widget:setAnchorPoint(cc.p(0.0,0.0))
			widget:setPosition(g_display.left_bottom)
		elseif(place==8)then
			widget:setAnchorPoint(cc.p(0.5,0.0))
			widget:setPosition(g_display.bottom_center)
		elseif(place==9)then
			widget:setAnchorPoint(cc.p(1.0,0.0))
			widget:setPosition(g_display.right_bottom)
		end
	else
		print("warning : not found \"place\" parameter in filename : "..filename)
	end
end



--加载cocosUI的统一方法（只针对直接addChild在sceneManager各个节点的UI使用,因为相对位置是设计坐标）。
--参数 ：csb名字 , UI基准位置（打印的排版排序1-9）。位置可以传空，那就需要自己设置了
--函数中主要设置了基准 坐标 锚点 适配缩放比例
function LoadCocosUI(filename,place)
	local widget = cc.CSLoader:createNode(filename)
	if(widget)then
		local scale_node = widget:getChildByName("scale_node")
		if(scale_node)then
			scale_node:setScale(g_display.scale)
		else
			print("warning : not found \"scale_node\" node in filename : "..filename)
			cToolsForLua:MessageBox("warning : not found \"scale_node\" node in filename : "..filename,"lua warning")
		end
		ResetUIPlace(widget,place)
	end
	return widget
end


--创建一个默认Labbel
function createLabelDefaultFont(text,fontSize)
	if fontSize == nil then
		fontSize = 22
	end
	if text == nil then
		text = ""
	end
	local label = cc.Label:createWithTTF(text,"cocostudio_res/simhei.ttf",fontSize)
	if label == nil then
		cToolsForLua:MessageBox("font file not found","warning")
		label = cc.Label:createWithSystemFont(text,"default",fontSize)
	end
	return label
end


--按层级关系返回所有子节点信息, 供函数 getOrderChild() 使用
function getChildrenInfo(rootNode)
	local nodesTbl = {}

	local function initNodeInfo(node, tbl) 
		if node:getChildrenCount() > 0 then 
			for k, v in pairs(node:getChildren()) do 
				assert(nil==tbl[v:getName()], " has same node name : "..v:getName()) 
				tbl[v:getName()] = {myself=v, children = {}}
				if v:getChildrenCount() > 0 then 
					initNodeInfo(v, tbl[v:getName()].children) 
				end 
			end 
		end 
	end 

	initNodeInfo(rootNode, nodesTbl)  

	return nodesTbl 
end 

--nodeArray：由 getChildrenInfo() 返回
--传入层级节点名字，返回最后一个名字对应的节点对象
--example: getOrderChild(nodeArray, "Panel_1", "Image_20", "Text_wujiangshu_0")
function getOrderChild(nodeArray, ...)
	local info
	local str = ""  
	for k, name in ipairs({...}) do 
		str = str.."[".. name.."]" 
		if nil == info then 
			info = nodeArray[name]
		else 
			info = info.children[name]
			assert(info, "cannot find "..str)
		end 
	end 

	assert(info, str)

	if info then 
		return info.myself 
	end 
end 

function enum(tbl, index) 
	local enumtbl = {} 
	local enumindex = index or 0 
	for i, v in pairs(tbl) do 
		enumtbl[v] = enumindex + i - 1
	end 
	return enumtbl 
end 

--根据地图位置信息,返回匹配位置所需要的地基图
function getFoundationImagePathWithPlace(place)
	local c = g_data.build_position[tonumber(place)]
	if(c)then
		if(c.build_type == g_PlayerBuildMode.m_BuildType.cityIn)then
			return g_data.sprite[1001020].path
		elseif(c.build_type == g_PlayerBuildMode.m_BuildType.cityOut)then
			return g_data.sprite[1001026].path
		end
	end
	return nil
end

--将秒数转为指定格式的字符串
ClockType = enum({"AUTO","AUTOMAXTYPE","AUTODAYORTIME","NODAY","ONLYDAY","ONLYHOURS","ONLYMINS","ONLYSECONDS","MINSSCONDS"})
function convertSecondToString(seconds,type)
		
		if seconds <= 0 and type == nil then
        return "00:00:00"
    end
    
    if (type == nil) then
      type = ClockType.AUTO
    end
    
    local clockTypeAuto = function()
        local min = math.floor(seconds/60)
        seconds = seconds - min*60
        local hour = math.floor(min/60)
        min = min- hour*60
        local day = math.floor(hour/24)
        hour = hour - day*24
  
        local ret
        if (day == 0) then
          return string.format("%02d:%02d:%02d",hour,min,seconds)
        end
        return string.format("%dd %02d:%02d:%02d",day,hour,min,seconds)
    end
    
    local clockTypeNoDay = function()
        local min = math.floor(seconds/60)
        seconds =seconds- min*60
        local hour = math.floor(min/60)
        min =min- hour*60
        return string.format("%02d:%02d:%02d",hour,min,seconds)
    end
    
    local clockTypeOnlyDay = function()
      local day = math.ceil(seconds/(60*60*24))
      return string.format("%dday",day)
    end
    
    local clockTypeOnlyHours = function()
      local hours = math.ceil(seconds/(60*60))
      return string.format("%dhour",hours)
    end
    
    local clockTypeOnlyMins = function()
      local mins = math.ceil(seconds/60)
      return string.format("%dmin",mins)
    end
    
    local clockTypeOnlySeconds = function()
      return string.format("%dsec",seconds)
    end 
    
    local clockTypeMinssconds = function()
      local mins = math.floor(seconds/60)
      local seconds = seconds - mins*60
  
      return string.format("%02d:%02d",mins,seconds)
    end 
    
    local clockTypeAutoMaxType = function()
        local min = math.floor(seconds/60)
        seconds =seconds- min*60
        local hour = math.floor(min/60)
        min =min- hour*60
        local day = math.floor(hour/24)
        hour =hour- day*24
  
        if(day>0) then
          return clockTypeOnlyDay()
        elseif(hour>0) then
          return clockTypeOnlyHours()
        elseif(min>0) then
          return clockTypeOnlyMins()
        end
        return clockTypeOnlySeconds()
    end
    
    local clockTypeAutoDayOrTime = function()
      local day = math.floor(seconds/(60*60*24))
      if(day>0) then
        return clockTypeOnlyDay()
      end
      return clockTypeNoDay()
    end
    
    local cfg = {
      [ClockType.AUTO] = clockTypeAuto,
      [ClockType.AUTOMAXTYPE] = clockTypeAutoMaxType,
      [ClockType.AUTODAYORTIME] = clockTypeAutoDayOrTime,
      [ClockType.NODAY] = clockTypeNoDay,
      [ClockType.ONLYDAY] = clockTypeOnlyDay,
      [ClockType.ONLYHOURS] = clockTypeOnlyHours,
      [ClockType.ONLYMINS] = clockTypeOnlyMins,
      [ClockType.ONLYSECONDS] = clockTypeOnlySeconds,
      [ClockType.MINSSCONDS] = clockTypeMinssconds
    }
  
    return cfg[type]()
end


--比较两段缓存数据是否有变化,相同返回false,不同返回true
function compareTableForMsgData(tab1,tab2)
	if tab1 == nil and tab2 == nil then
		return false
	end
	if ( (tab1 == nil) ~= (tab2 == nil) )  or  ( type(tab1) ~= type(tab2) ) then
		return true
	end
	if type(tab1) == "table" then
		for k , v in pairs(tab1) do
			if compareTableForMsgData(v,tab2[k]) == true then
				return true
			end
		end
		for k , v in pairs(tab2) do
			if compareTableForMsgData(v,tab1[k]) == true then
				return true
			end
		end
		return false
	else
		return (tab1 ~= tab2)
	end
end


--根据货币类型获取货币数量
function getPlayerCurrencyCount(t)
  local currencyType = tonumber(t)
  local playerData = g_PlayerMode.GetData()
  local count = 0
  if currencyType == g_Consts.AllCurrencyType.Gold then 
    count = playerData.gold
  elseif currencyType == g_Consts.AllCurrencyType.Food then 
    count = playerData.food
  elseif currencyType == g_Consts.AllCurrencyType.Wood then 
    count = playerData.wood
  elseif currencyType == g_Consts.AllCurrencyType.Stone then 
    count = playerData.stone
  elseif currencyType == g_Consts.AllCurrencyType.Iron then 
    count = playerData.iron
  elseif currencyType == g_Consts.AllCurrencyType.Silver then 
    count = playerData.silver
  elseif currencyType == g_Consts.AllCurrencyType.Gem then
    count = g_PlayerMode.getDiamonds()
  elseif currencyType == g_Consts.AllCurrencyType.PlayerHonor then
    count = playerData.guild_coin
  elseif currencyType == g_Consts.AllCurrencyType.Move then
    count = playerData.move
  elseif currencyType == g_Consts.AllCurrencyType.PlayerExp then
    count = playerData.current_exp
  elseif currencyType == g_Consts.AllCurrencyType.AllianceTechExp then
    --暂时没用
  elseif currencyType == g_Consts.AllCurrencyType.AllianceHonor then
    count = g_AllianceMode.getBaseData().coin
  elseif currencyType == g_Consts.AllCurrencyType.JinNang then
    count = playerData.point
  elseif currencyType == g_Consts.AllCurrencyType.Coin then
    count = 0
    if g_zhuanPanData.GetZhuanPanData() then
        count = g_zhuanPanData.GetZhuanPanData().coin_num
    end
  elseif currencyType == g_Consts.AllCurrencyType.Gouyu then
    count = 0
    if g_zhuanPanData.GetZhuanPanData() then
        count = g_zhuanPanData.GetZhuanPanData().jade_num
    end
  elseif currencyType == g_Consts.AllCurrencyType.ZhanXun then
    count = playerData.feats

  elseif currencyType == g_Consts.AllCurrencyType.XuanTie then
    count = playerData.xuantie 

  elseif currencyType == g_Consts.AllCurrencyType.JiangYin then
    count = playerData.jiangyin 
  elseif currencyType == g_Consts.AllCurrencyType.JunZi then
    count = playerData.junzi 
  else
    assert(false,"invaild currency type "..currencyType)
  end 
  
  local iconPath = g_resManager.getResPath(g_Consts.CurrencyDefaultId + currencyType)
  return count,iconPath
end

--创建富文本控件 modLabel是label模版，其作用在于拷贝其一些属性
--richstr格式:用 "|"分割字符串 用<# R,B,G #>变色文本
--比如："这里是不变色的文字|<#225,225,255#>这里是变色的文字|这里不变色的文字。"

--如需特殊字符按照上述规则进行转意
--1.回车换行|<#\n#>| 如需要连续两个回车换行 |<#\n#>|空格|<#\n#>|

--pro:参数为无模版情况下的 控件的默认 参数
--pro.fontSize
--pro.width
--pro.height

--color:参数为 强制修改默认颜色 参数 cc.c3b(255,255,255)

function createNoModeRichText(richstr,pro,color,isUseSystemFontName)
    return createRichText(nil,richstr,pro,color,isUseSystemFontName)
end

function createRichText(modLabel,richstr,pro,color,isUseSystemFontName)
    
    local rich = nil
    local cutStr = {}
    local defColor = color
    
    print(richstr)

    if modLabel == nil and pro == nil then
        return
    end

    --modLabel and modLabel

    --pro.fontSize
    --pro.width
    --pro.height

    --static Text* create(const std::string& textContent,
    --const std::string& fontName,
    --float fontSize);

    --[[if modLabel == nil then
        --print("this modlabel is null")
        --return
        modLabel = ccui.Text:create(richstr,pro.fontNa)
        

    end]]

    local function formatRichStr(fstr)
        --print("FormatRichStr：",fstr)
        local ttb = {}
        if type(fstr) == "string" then
            local st = string.split( fstr,"|" )

            for key, var in ipairs(st) do
                --print("var",var)
                local c = nil   --文本颜色（或者特殊符号）
                for w in string.gmatch(var, "<#.-#>") do
                    local cstr = string.split( string.gsub( string.gsub(w, "<#", ""), "#>",""),"," )
                    if cstr[1] and cstr[2] and cstr[3] then
                        c = cc.c3b(tonumber(cstr[1]),tonumber(cstr[2]),tonumber(cstr[3]) )
                    else
                        --特殊符号处理
                        --回车换行
                        if cstr[1] == "\n" then
                            c = cstr[1]
                        end

                    end
                end

                cutStr = cutStr or {}
                table.insert(cutStr,var)
               
                local s = string.gsub(var, "<#.-#>","" )   --文本内容
                
                --特殊字符判断
                if c == "\n" then
                    --print("回车")
                    table.insert(ttb, { str = c } )
                else
                    table.insert(ttb, { color = c, str = s } )
                end

            end
        end

        return ttb
    end

    rich = ccui.RichText:create()
    rich.mode = modLabel
    rich.nodes = {}
    rich:ignoreContentAdaptWithSize(false)
    
    if rich.mode then
        rich:setAnchorPoint( rich.mode:getAnchorPoint() )
        rich:setPosition(rich.mode:getPosition())
        rich.mode:getParent():addChild(rich)
        rich.mode:setVisible(false)
    end
    
    rich.setRichText = function (rself,richstr_new)
        --if rself.mode then
        
        		richstr = richstr_new
            local ttb = formatRichStr(richstr_new)

            rself:removeAllProtectedChildren()
            for i, re in ipairs(rself.nodes) do
                rself:removeElement(re)
            end

            rself.nodes = {}
                
            for i, txt in ipairs(ttb) do
                
                local defultColor = defColor
                
                if defultColor == nil then
                    defultColor = rself.mode and rself.mode:getTextColor() or cc.c3b(255,255,255)
                end
                
                local color = txt.color or defultColor

                --print("txt.str",txt.str )
                local re = nil
                if txt.str == "\n" then
                    --print("push回车")
                    re = ccui.RichElementNewLine:create(i)
                else
                    local fontName = rself.mode and rself.mode:getFontName() or "cocostudio_res/simhei.ttf"
                    if isUseSystemFontName then
                        local target = cc.Application:getInstance():getTargetPlatform()
                        if target == cc.PLATFORM_OS_IPAD or target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_MAC then 
                            fontName = "Heiti SC"
                        end
                    end

                    -- print("show font name",fontName)

                    --[[
                    local target = cc.Application:getInstance():getTargetPlatform()
                    if target ~= cc.PLATFORM_OS_ANDROID and target ~= cc.PLATFORM_OS_WINDOWS then 
                        fontName = "Heiti SC"
                    end
                    ]]

                    local fontSize = rself.mode and rself.mode:getFontSize() or pro.fontSize
                    re = ccui.RichElementText:create( i ,color,255,tostring(txt.str),fontName,fontSize)
                end

                --ignoreContentAdaptWithSize

                --local re = ccui.RichElementText:create( i ,color,255,tostring(txt.str),rself.mode:getFontName(),rself.mode:getFontSize())
                rself.nodes[i] = re
                rself:pushBackElement( re )
            end

            rself:setRichSize()
        --end
    end

    rich.setRichSize = function (rself,w,h)
        if rself.mode then
            if w == nil then
                --去掉格式话字符长度计算rich的真实长度，防止位置偏移
                local modetemp = rself.mode:clone()
                local s = string.gsub(modetemp:getString(), "<#.-#>","" )
                s = string.gsub(s, "|","" )
                modetemp:setString( s )
                w = modetemp:getContentSize().width
            end

            if h == nil then
                h = rself.mode:getContentSize().height
            end

            rich:setContentSize( cc.size( w + 5 , h ))

        else
            rich:setContentSize( cc.size(pro.width,pro.height or 0 ))
        end
    end

    rich.getRichSize = function (rself)
        rself:formatText()
        return rself:getRenderSize()
    end

    rich.getRealSize = function (rself)
        local s = string.gsub(richstr, "<#.-#>","" )
        s = string.gsub(s, "|","" )

        local fontSize = rself.mode and rself.mode:getFontSize() or pro.fontSize
        local fontName = rself.mode and rself.mode:getFontName() or "cocostudio_res/simhei.ttf"
        local mode = ccui.Text:create(s,fontName,fontSize or 24 )
        if mode:getContentSize().width > rself:getContentSize().width then 
          mode:setTextAreaSize(cc.size(rself:getContentSize().width, 0))
        end 

        return mode:getContentSize()
    end

    rich.getCutStr = function (rself)

        local temptb = {}
        for key, var in ipairs(cutStr) do
            if string.find( var, "<#.-#>") then
                var = "|".. var .. "|"
            end
            table.insert( temptb,var )
        end
        return temptb
    end

    rich:setRichText( richstr )
    rich:setRichSize()
    
    return rich
end

--根据cost id重组数据结构
local costConfigTables = {}
for key, var in pairs(g_data.cost) do
    if costConfigTables[var.cost_id] == nil then
        costConfigTables[var.cost_id] = {}
    end
    table.insert(costConfigTables[var.cost_id],var)
end 
--通过costId 获取cost表信息
function getCostsByCostId(costId,assertCount)
--    local tables = {}
--    for key, var in pairs(g_data.cost) do
--       if var.cost_id == costId then
--      	   tables[#tables + 1] = var
--       end
--    end 
    
    local tables = costConfigTables[costId]
    if assertCount ~= nil then
    	print("costId:",costId)
      assert(#tables == assertCount)
    end
    
    return tables
end

function getCostInfoByCostIdAndCount(costId,count)
    local tables = costConfigTables[costId]
    local costInfo = nil
    for key, var in pairs(tables) do
    	if count >= var.min_count and count <= var.max_count then
    	   costInfo = var 
    	   break
    	end
    end
    return costInfo
end


--根据一组dropId返回符合条件的drop group
function getDropGroupByDropIdArray(dropIdArray,matchLevel)
    local groups = {}
    local level = matchLevel or g_PlayerBuildMode.getMainCityBuilding_lv() --等级条件由主公等级改为府衙等级了 --g_PlayerMode.GetData().level
    for key, dropId in pairs(dropIdArray) do
        local dropInfo = g_data.drop[dropId]
        assert(dropInfo,"cannot found dropid:"..dropId)
        if level >= dropInfo.min_level and level <= dropInfo.max_level  then
            local group = dropInfo.drop_data
            for key, var in pairs(group) do
                table.insert(groups,var)
            end
        end
    end
    return groups
end


--根据Map_Element ID 返回一个建筑样子的node (为UI准备的函数)
function getWorldMapElementDisplay(map_element_id)
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	local configData = g_data.map_element[tonumber(map_element_id)]
	if configData then
		local textureCache = cc.Director:getInstance():getTextureCache()
		local spriteFrameCache = cc.SpriteFrameCache:getInstance()
		for index = 1, 99, 1  do
			local textureName = string.format("worldmap/map_build_%d.png",index)
			if textureCache:addImage(textureName) then
				local plistName = string.format("worldmap/map_build_%d.plist",index)
				spriteFrameCache:addSpriteFrames(plistName,textureName)
			else
				break
			end
		end
		local helperMD = require "game.maplayer.worldMapLayer_helper"
		local function bti_2_pos(bti, contentSize, tileTotalCount)
			return cc.p( math.floor( bti.x * helperMD.m_SingleSizeHalf.width + (tileTotalCount.height - (bti.y + 1)) * helperMD.m_SingleSizeHalf.width )
				, math.floor( contentSize.height - (helperMD.m_SingleSize.height + bti.y * helperMD.m_SingleSizeHalf.height + bti.x * helperMD.m_SingleSizeHalf.height) ) )	
		end
		local count = #(configData.x_y) --此版本建筑物只有占1,4,9,16格的而已
		local contentSize = nil
		local originIndex = nil
		local tileTotalCount = nil
		if count == 4 then
			contentSize = cc.size(helperMD.m_SingleSize.width * 2, helperMD.m_SingleSize.height * 2)
			originIndex = cc.p(1, 1)
			tileTotalCount = cc.size(2, 2)
		elseif count == 9 then
			contentSize = cc.size(helperMD.m_SingleSize.width * 3, helperMD.m_SingleSize.height * 3)
			originIndex = cc.p(2, 2)
			tileTotalCount = cc.size(3, 3)
		elseif count == 16 then
			contentSize = cc.size(helperMD.m_SingleSize.width * 4, helperMD.m_SingleSize.height * 4)
			originIndex = cc.p(3, 3)
			tileTotalCount = cc.size(4, 4)
		else
			contentSize = cc.size(helperMD.m_SingleSize.width, helperMD.m_SingleSize.height)
			originIndex = cc.p(0, 0)
			tileTotalCount = cc.size(1, 1)
		end
		ret:setContentSize(contentSize)
		for k , v in ipairs(configData.x_y) do
			local imageName = g_data.sprite[configData.img[k]].path
			if configData.origin_id == helperMD.m_MapOriginType.monster_small 
				or configData.origin_id == helperMD.m_MapOriginType.monster_boss
				or configData.origin_id == helperMD.m_MapOriginType.heshibi
					then
				--动态类型
				imageName = imageName.."1.png"
			end
			local sprite = cc.Sprite:createWithSpriteFrameName(imageName)
			sprite:setAnchorPoint(cc.p(0.0,0.0))
			sprite:setPosition(bti_2_pos(cc.p(originIndex.x + v[1], originIndex.y + v[2]), contentSize, tileTotalCount))
			ret:addChild(sprite)
		end
	end
	return ret
end


local m_CocosAniexportJsonNameList = {}
--创建cocos动画
--[[onMovementEventCallFunc(armature , eventType , name)
	if ccs.MovementEventType.start == eventType then
	elseif ccs.MovementEventType.complete == eventType then
	elseif ccs.MovementEventType.loopComplete == eventType then
	end
end--]]
--[[onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
end--]]
function LoadCocosAni(exportJsonName , projectName , onMovementEventCallFunc , onFrameEventCallFunc)
	if ccs.ArmatureDataManager.removeAllArmatureFileInfo == nil then
		m_CocosAniexportJsonNameList[exportJsonName] = true
	end
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(exportJsonName)
	local armature = lhs.LHSArmature:create(projectName)
	local animation = armature:getLHSAnimation()
	if onMovementEventCallFunc and type(onMovementEventCallFunc) == "function" then
		animation:registerScriptMovementHandler(cToolsForLua:pushHandlerForlua(onMovementEventCallFunc))
	end
	if onFrameEventCallFunc and type(onFrameEventCallFunc) == "function" then
		animation:registerScriptFrameHandler(cToolsForLua:pushHandlerForlua(onFrameEventCallFunc))
	end
	return armature , animation
end

function preLoadCocosAni(exportJsonName)
	if ccs.ArmatureDataManager.removeAllArmatureFileInfo == nil then
		m_CocosAniexportJsonNameList[exportJsonName] = true
	end
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(exportJsonName)
end

function removeAllCocosAniFileInfo()
	for k , v in pairs(m_CocosAniexportJsonNameList) do
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(k)
	end
	m_CocosAniexportJsonNameList = {}
end

--创建帧动画
--prefixionName 前缀名 例如 abc_1.png 其中的 abc_ 。编号ID从1开始
--fps 帧率 默认是每秒15帧
--isOriginalFrame 是否返回原始帧 默认为true
--out_table是一个table，你可以创建一个空table传进去，也可以不传，一般情况下都不用传
--如果传了out_table，那么执行完成之后out_table里面就存放了对应的动画信息数据{totalFrameNum 总帧数, totalTime 播放总时间, fps 帧率}
function LoadFPSAni(prefixionName, fps, isOriginalFrame, out_table)
	local ret = nil
	local fp = fps and fps or 0.0666666666666667
	local isOriginal = isOriginalFrame and true or false
	if out_table and type(out_table) == "table" then
		local out_user_data = lhs.LHSAnimationReturn:create()
		ret = lhs.LHSAnimation:createFrameAnimationWithIdOrder(prefixionName, fp, isOriginal, out_user_data)
		out_table.totalFrameNum = out_user_data:GetTotalFrameNum()
		out_table.totalTime = out_user_data:GetTotalTime()
		out_table.fps = out_user_data:GetFps()
	else
		ret = lhs.LHSAnimation:createFrameAnimationWithIdOrder(prefixionName, fp, isOriginal)
	end	
	return ret
end


--悄悄改掉editBox
local m_editBox_origin_create = ccui.EditBox.create
ccui.EditBox.create = function (self, ...)
	local editBox = m_editBox_origin_create(self, ...)
	do --添加新事件
		local userEventCallback = nil
		local c_event_action_tag = 45612874
		local function editboxEventHandler(eventType, sender)
			if userEventCallback then
				userEventCallback(eventType, sender)
			end
			if eventType == "return" then
				local function onInputEnd()
					if userEventCallback then
						userEventCallback("customEnd", sender)
					end
				end
				editBox:stopActionByTag(c_event_action_tag)
				local action = cc.Sequence:create(cc.DelayTime:create(0.0167),cc.CallFunc:create(onInputEnd))
				action:setTag(c_event_action_tag)
				editBox:runAction(action)
			end
		end
		editBox:registerScriptEditBoxHandler(editboxEventHandler)
		function editBox:registerScriptEditBoxHandler(eventCallback)
			userEventCallback = eventCallback
		end
	end
	if editBox.setImplContentSizeScale and (cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE) then
		editBox:setImplContentSizeScale(g_display.scale, g_display.scale)
	end
	return editBox
end


function convertTextFieldToEditBox(textField)
  assert(textField)
  local editBox = ccui.EditBox:create(textField:getContentSize(),ccui.Scale9Sprite:create())
  editBox:setContentSize(textField:getContentSize())
  editBox:setAnchorPoint(textField:getAnchorPoint())
  editBox:setPosition(textField:getPosition())

  textField:getParent():addChild(editBox,textField:getLocalZOrder())
  textField:setVisible(false)

  editBox:setFontSize(textField:getFontSize())
  editBox:setPlaceholderFontSize(textField:getFontSize())
  
  editBox:setFontName(textField:getFontName())
  editBox:setPlaceholderFontName(textField:getFontName())
  
  editBox:setFontColor(textField:getTextColor())
  editBox:setPlaceholderFontColor(textField:getPlaceHolderColor())
  
  --editBox:setPlaceHolder(textField:getPlaceHolder())
  editBox:setPlaceHolder("")
  editBox:setText(textField:getString())
  
  --這裡去掉 輸入限制全都自行判斷字符串
  --[[if textField:isMaxLengthEnabled() then
      editBox:setMaxLength(textField:getMaxLength())
  end]]
  
  function editBox:getString()
      return self:getText()
  end
  
  function editBox:setString(str)
      self:setText(str)
  end
  
  editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
  editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
  
  if textField:isPasswordEnabled() then
      editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
      editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
  end
	
  return editBox
end


--是否为高端IOS设备
function isHighIosDevice()
	local c_ios_device = cToolsForLua:getIOSDeviceModel()
	if c_ios_device then
		local b , e = string.find(c_ios_device,"iphone")
		if b then
			local t = tonumber(string.sub(c_ios_device,e+1,e+1))
			return t and t >= 7
		end
		b , e = string.find(c_ios_device,"iPad")
		if b then
			local t = tonumber(string.sub(c_ios_device,e+1,e+1))
			return t and t >= 5
		end
		b , e = string.find(c_ios_device,"iPod")
		if b then
			return false
		end
	end
	return false
end

--添加小红点
function addRedPoint(node,num)

    if node == nil then
        return
    end

    num = num or 0

    --[[if num > 99 then
        num = 99
    end]]

    local prompt = cc.CSLoader:createNode("prompt.csb")
    
    prompt:setAnchorPoint(cc.p(0.75,0.75))

    prompt:setPosition(cc.p(node:getContentSize().width,node:getContentSize().height))

    node:addChild(prompt)
    
    prompt.setString = function (p,num)
        if num <= 0 then
            print("this number is 0")
            p:setVisible(false)
        else
            p:setVisible(true)
        end

        p:getChildByName("Text_1"):setString( tostring(num) )
    end

    prompt:setString(num)

    return prompt

end

--获取设备名称和系统版本(异步)
function reqDeviceNameAndSystemVersion(callback)
     
     assert(callback)
     
     local deviceName = "unknow"
     local systemVersion = "unknow"
     local platformName = "unknow"
     
     local target = cc.Application:getInstance():getTargetPlatform()
    
     if target == cc.PLATFORM_OS_ANDROID then
        platformName = "ANDROID"
        local jcallback = function(str)
            local params = string.split(str, ",")
            if params[1] then
                deviceName = params[1]
            end
            
            if params[2] then
                systemVersion = params[2]
            end
            
            if callback then
                callback(deviceName,systemVersion,platformName)
            end
        end
        local luaj = require "cocos.cocos2d.luaj"
        local className="org/cocos2dx/lib/Cocos2dxHelper"
        
        local params = {jcallback}
        luaj.callStaticMethod(className, "getPhoneInfo", params)
        return
     elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
        platformName = "IOS"
        if cToolsForLua:getIOSDeviceModel() then
            deviceName = cToolsForLua:getIOSDeviceModel()
        end
        
        if cToolsForLua:getIOSSystemVersion() then
            systemVersion = cToolsForLua:getIOSSystemVersion()
        end
     elseif target == cc.PLATFORM_OS_WINDOWS then
        platformName = "WINDOWS"
        deviceName = "windows simulator"
     end
     
     if callback then
        callback(deviceName,systemVersion,platformName)
     end
     
end

--根据秒数计算加速所需的元宝数
function getGemCostBySeconds(second)
    local cost = math.ceil(second^0.911*0.085)
    return cost
end

--提示弹出充值界面
function tipGotoPayLayer()
    g_msgBox.show( g_tr("gotoPayTip"),nil,nil,
        function ( eventtype )
            --确定
            if eventtype == 0 then 
                g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyView").new())
            end
        end , 1)
end

--根据costType提示资源不足的情况,根据需求自行修改
function tipCostLimit(costType)
  local currencyLimitTip = function()
      g_airBox.show(g_tr("currencyNameLimit",{currency_name = g_tr("assets"..costType)}))
  end

  local currencyType = tonumber(costType)
  
  if currencyType == g_Consts.AllCurrencyType.Gold  
  or currencyType == g_Consts.AllCurrencyType.Food  
  or currencyType == g_Consts.AllCurrencyType.Wood  
  or currencyType == g_Consts.AllCurrencyType.Stone  
  or currencyType == g_Consts.AllCurrencyType.Iron then
      require("game.uilayer.shop.UseResourceView").show(currencyType)--打开快速购买界面
  elseif currencyType == g_Consts.AllCurrencyType.Silver then 
      currencyLimitTip()
  elseif currencyType == g_Consts.AllCurrencyType.Gem then
      tipGotoPayLayer() --提示弹出充值界面
  elseif currencyType == g_Consts.AllCurrencyType.PlayerHonor then
      currencyLimitTip()
  elseif currencyType == g_Consts.AllCurrencyType.Move then
      currencyLimitTip()
  elseif currencyType == g_Consts.AllCurrencyType.PlayerExp then
      currencyLimitTip()
  elseif currencyType == g_Consts.AllCurrencyType.AllianceTechExp then
      currencyLimitTip()
  elseif currencyType == g_Consts.AllCurrencyType.AllianceHonor then
      currencyLimitTip()
  elseif currencyType == g_Consts.AllCurrencyType.Coin then
      currencyLimitTip()
  elseif currencyType == g_Consts.AllCurrencyType.Gouyu then
      currencyLimitTip()
  else
      currencyLimitTip()
  end 
end

function convertScrollView(orginalScrollview)
    local scrollview = orginalScrollview:clone()
    local box=scrollview:getBoundingBox() 
    local myScrollView=cc.ClippingRectangleNode:create(box) --使用cc.ClippingRectangleNode创建一个新裁切节点
    scrollview:setClippingEnabled(false) --取消原来的裁切
    orginalScrollview:getParent():addChild(myScrollView) --原来scrollview的parent
    myScrollView:addChild(scrollview)
    orginalScrollview:setVisible(false)
    return scrollview
end

function canUseUnionMoveCity(target)
	local doNotUseUnion = ((g_clock.getCurServerTime() - tonumber(g_PlayerMode.GetData().attack_time)) <= (tonumber(g_data.starting[100].data) * 3600))
	if doNotUseUnion then
		return false
	end
	if g_AllianceMode.getGuildId() ~= 0 and g_BagMode.findItemNumberById(21400) > 0 then
		local data = g_AllianceMode.getLeaderInfo()
		if data then
			local vx = target.x - data.Player.x
			local vy = target.y - data.Player.y
			if math.sqrt(vx * vx + vy * vy) <= 50 then
				return true
			end
		end
	end
	return false
end

--阿拉伯数字转化成中文数字
--例如传入 29 返回 二十九，传入101 返回一百零一
function SectionToChinese(section)
	
	local chnNumChar = {"零","一","二","三","四","五","六","七","八","九"}
	local chnUnitSection = {"","万","亿","万亿","亿亿"}
	local chnUnitChar = {"","十","百","千"}

	if section == 0 then
		return chnNumChar[1]
	end

  local strIns = ""
	local chnStr = ""
  local unitPos = 1
  local zero = true
  while (section > 0) do
    local v = section % 10
    if v == 0 then
      if not zero then
        zero = true
        chnStr = chnNumChar[v + 1]..chnStr
      end
    else 
      zero = false
      strIns = chnNumChar[v + 1]
      strIns = strIns..chnUnitChar[unitPos]
      chnStr = strIns..chnStr
    end
    unitPos = unitPos + 1
    section = math.floor(section / 10)
  end
  return chnStr
end

return gameTools