
local MasterMode = class("MasterMode")

function MasterMode:ctor()

end

--获取主公宝物
function MasterMode:getMasterEquipment( )
    
    if g_MasterEquipMode.RequestData() then
        return g_MasterEquipMode.GetData()
    end

	return g_MasterEquipMode.GetData()

end

--获取主公天赋
function MasterMode:getTalent()
    
    --if g_MasterTalentMode.RequestData() then
        return g_MasterTalentMode.GetData()
    --end

end

--升级主公天赋
function MasterMode:upgradeTalent( talent_type_id )
	--print("talent_type_id",talent_type_id)
	local resultdata = nil
	local tb1 = 
	{
		["talentTypeId"] = talent_type_id,
        ["steps"] = g_guideManager.getToSaveStepId()
	}

	local function callback( result , data )
		if true == result then
			resultdata = data
		end
	end
	g_sgHttp.postData("Player/talentAdd", tb1, callback)
    return resultdata

end

--穿装备或者替换装备
function MasterMode:equipMasterOn( new_equip_id,old_equip_id,pos )
	local resultdata = nil
    --steps = g_guideManager.getToSaveStepId()

	local tb1 = 
	{	
		["new_id"] = new_equip_id or 0,
		["old_id"] = old_equip_id or 0,
        ["position"] = pos or -1,
        --新手引导
        ["steps"] = g_guideManager.getToSaveStepId(),
	}

	local function callback( result , data )
		if true == result then
			resultdata = data
		end
	end

	g_sgHttp.postData("player/equipMasterOn",tb1, callback)
	return resultdata
end

--脱装备
function MasterMode:equipMasterOffAction( offid )
	local resultdata = nil
	local tb1 = 
	{	
		["id"] = offid or 0
	}

	local function callback( result , data )
		if true == result then
			resultdata = data
		end
	end

	g_sgHttp.postData("player/equipMasterOff",tb1, callback)
	return resultdata
end

--主公修改昵称
function MasterMode:masterRenameAction( nick )

    if nick == nil then
        print("nick is nil")
        return 
    end
    
    local resultdata = nil
    local tb1 = 
    {
        ["type"] = 1,
        ["nick"] = nick or "",
    }

    local function callback( result , data )
		if true == result then
			resultdata = data
		end
	end

    g_sgHttp.postData("player/alterPlayer",tb1, callback)
    return resultdata
end

--主公修改头像
function MasterMode:masterReheadAction( avatar_id )
    
    if avatar_id == nil then
        print("avatar_id is nil")
        return
    end

    local resultdata = nil
    local tb1 = 
    {
        ["type"] = 2,
        ["avatar_id"] = avatar_id,
    }

    local function callback( result , data )
		if true == result then
			resultdata = data
		end
	end

    g_sgHttp.postData("player/alterPlayer",tb1, callback)
    return resultdata
end

function MasterMode:getMasterInfo(  )
	return g_PlayerMode.GetData()
end

function MasterMode.createCircleHead(res,scale)
    --print("1111111111111111111111111111111")
    scale = scale or 0.9
    local stencil = cc.Sprite:create("freeImage/headmask.png")
    local clipper = cc.ClippingNode:create()
    clipper:setStencil(stencil)
    clipper:setInverted(true)
    clipper:setAlphaThreshold(0.5)
    --icon:addChild(clipper)
    
    local icon = ccui.ImageView:create(res)
    icon:setScale(scale)
    clipper:addChild(icon)

    return clipper
end


return MasterMode
