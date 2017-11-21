local homeMapFire = {}
setmetatable(homeMapFire,{__index = _G})
setfenv(1,homeMapFire)

local c_Positions = {
	[1] = {pos = cc.p(934,1055), scale = 1.0},
	[2] = {pos = cc.p(1071,1028), scale = 1.0},
	[3] = {pos = cc.p(950,980), scale = 1.0},
	[4] = {pos = cc.p(1091,1026), scale = 1.0},
	[5] = {pos = cc.p(994,1063), scale = 1.0},
	[6] = {pos = cc.p(862,563), scale = 1.0},
	[7] = {pos = cc.p(2370,680), scale = 1.0},
	[8] = {pos = cc.p(2937,700), scale = 1.0},
	[9] = {pos = cc.p(2462,845), scale = 1.0},
	[10] = {pos = cc.p(1686,843), scale = 1.0},
	[11] = {pos = cc.p(1206,505), scale = 1.0},
	[12] = {pos = cc.p(1924,604), scale = 1.0},
	[13] = {pos = cc.p(180,548), scale = 1.0},
}


function create()
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setPosition(cc.p(0,0))
	ret:setContentSize(cc.size(0,0))
	for k , v in ipairs(c_Positions) do
		local armature , animation = g_gameTools.LoadCocosAni("anime/TongYongChengNeiHuo/TongYongChengNeiHuo.ExportJson", "TongYongChengNeiHuo")
		armature:setPosition(v.pos)
		armature:setScale(v.scale)
		ret:addChild(armature)
		animation:play("ChengQiangHuo")
	end
	return ret
end



return homeMapFire