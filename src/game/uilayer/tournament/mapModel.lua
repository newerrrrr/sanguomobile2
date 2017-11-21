local mapModel = {}
setmetatable(mapModel,{__index = _G})
setfenv(1,mapModel)

local helpModelMD = require("game.uilayer.tournament.helpModel")

--武斗地图

local function calculate_determinant_2x3(X1,Y1,X2,Y2,X3,Y3)
	return (X1*Y2+X2*Y3+X3*Y1-Y1*X2-Y2*X3-Y3*X1)
end

local function calculate_d(X1,Y1,X2,Y2,X3,Y3)
	local a = Y2 - Y1
	local b = X1 - X2
	local c = X2 * Y1 - X1 * Y2
	if math.abs(a) < 0.0000001 and math.abs(b) < 0.0000001 then
		a = 0.0000001
	end
	return math.abs(a * X3 + b * Y3 + c) / math.sqrt(a * a + b * b)
end

local function calculate_t(X1,Y1,X2,Y2,X3,Y3)
	local x = X2 - X1
	local y = Y2 - Y1
	local xx = X3 - X1
	local yy = Y3 - Y1
	return xx * x + yy * y
end

function createBottom(id)
	local node = cc.Node:create()
	node:setAnchorPoint(cc.p(0.0, 0.0))
	node:setContentSize(cc.size(1.0, 1.0))
	node:setPosition(cc.p(0.0, 0.0))
	
	local configData = g_data.duel_map_para[id]
	
	local background = cc.Sprite:create(g_data.sprite[configData.map_res].path)
	background:setAnchorPoint(cc.p(0.0, 0.0))
	background:setPosition(cc.p(0.0, 0.0))
	node:addChild(background)
	
	local vertexs = {}
	for i = 1, #(configData.move_range), 2 do
		vertexs[(#(vertexs)) + 1] = cc.p(configData.move_range[i], configData.move_range[i + 1])
	end
	
	function node.lua_checkWorldPoint(worldPoint)
		return node.lua_checkNodePoint(cTools_worldToNodeSpace_position(background, worldPoint))
	end
	
	function node.lua_checkNodePoint(nodePoint)
		local count = #(vertexs)
		for i = 1, count, 1 do
			if i == count then
				if 0 > calculate_determinant_2x3(vertexs[i].x, vertexs[i].y, vertexs[1].x, vertexs[1].y, nodePoint.x, nodePoint.y) then
					return false
				end
			else
				if 0 > calculate_determinant_2x3(vertexs[i].x, vertexs[i].y, vertexs[i + 1].x, vertexs[i + 1].y, nodePoint.x, nodePoint.y) then
					return false
				end
			end
		end
		return true
	end
	
	function checkNodePoint2(nodePoint)
		local count = #(vertexs)
		for i = 1, count, 1 do
			if i == count then
				if 0 > calculate_determinant_2x3(vertexs[i].x, vertexs[i].y, vertexs[1].x, vertexs[1].y, nodePoint.x, nodePoint.y) then
					if calculate_d(vertexs[i].x, vertexs[i].y, vertexs[1].x, vertexs[1].y, nodePoint.x, nodePoint.y) >= 1 then
						if calculate_t(vertexs[i].x, vertexs[i].y, vertexs[1].x, vertexs[1].y, nodePoint.x, nodePoint.y) >= 0 then
							return false
						end
					end
				end
			else
				if 0 > calculate_determinant_2x3(vertexs[i].x, vertexs[i].y, vertexs[i + 1].x, vertexs[i + 1].y, nodePoint.x, nodePoint.y) then
					if calculate_d(vertexs[i].x, vertexs[i].y, vertexs[i + 1].x, vertexs[i + 1].y, nodePoint.x, nodePoint.y) >= 1 then
						if calculate_t(vertexs[i].x, vertexs[i].y, vertexs[i + 1].x, vertexs[i + 1].y, nodePoint.x, nodePoint.y) >= 0 then
							return false
						end
					end
				end
			end
		end
		return true
	end
	
	function node.lua_checkWantNodePoint(originPoint, wantNodePoint, rangeRadius)
		if node.lua_checkNodePoint(wantNodePoint) then
			return wantNodePoint
		end
		local canPoint = cc.p(wantNodePoint.x, wantNodePoint.y)
		local begin_1 = originPoint
		local end_1 = wantNodePoint
		local mdv = cc.pSub(end_1, begin_1)
		local mdvlen = math.sqrt(mdv.x * mdv.x + mdv.y * mdv.y)
		if mdvlen >= 1 then
			local max_Len , max_benin , max_end , insPos = nil , nil , nil , nil
			local count = #(vertexs)
			for i = 1, count, 1 do
				local begin_2 = nil
				local end_2 = nil
				if i == count then
					begin_2 = cc.p(vertexs[i].x, vertexs[i].y)
					end_2 = cc.p(vertexs[1].x, vertexs[1].y)
				else
					begin_2 = cc.p(vertexs[i].x, vertexs[i].y)
					end_2 = cc.p(vertexs[i + 1].x, vertexs[i + 1].y)
				end
				local a1 = end_1.y - begin_1.y
				local b1 = begin_1.x - end_1.x
				local c1 = end_1.x * begin_1.y - begin_1.x * end_1.y
				local a2 = end_2.y - begin_2.y
				local b2 = begin_2.x - end_2.x
				local c2 = end_2.x * begin_2.y - begin_2.x * end_2.y
				if math.abs(a1*b2 - a2*b1) >= 0.00001 then
					local ipos = cc.p((b1*c2 - b2*c1) / (a1*b2 - a2*b1), (a1*c2 - a2*c1) / (b1*a2 - b2*a1))
					local if1, if2, if3, if4 = false, false, false, false
					if (ipos.x >= begin_2.x - 0.001 and ipos.x <= end_2.x + 0.001) then
						if1 = true
						if ipos.x < begin_2.x then
							ipos.x = begin_2.x
						elseif ipos.x > end_2.x then
							ipos.x = end_2.x
						end
					elseif (ipos.x <= begin_2.x + 0.001 and ipos.x >= end_2.x - 0.001) then
						if1 = true
						if ipos.x > begin_2.x then
							ipos.x = begin_2.x
						elseif ipos.x < end_2.x then
							ipos.x = end_2.x
						end
					end
					if if1 then
						if (ipos.y >= begin_2.y - 0.001 and ipos.y <= end_2.y + 0.001) then
							if2 = true
							if ipos.y < begin_2.y then
								ipos.y = begin_2.y
							elseif ipos.y > end_2.y then
								ipos.y = end_2.y
							end
						elseif (ipos.y <= begin_2.y + 0.001 and ipos.y >= end_2.y - 0.001) then
							if2 = true
							if ipos.y > begin_2.y then
								ipos.y = begin_2.y
							elseif ipos.y < end_2.y then
								ipos.y = end_2.y
							end
						end
						if if2 then
							if (ipos.x >= begin_1.x - 0.001 and ipos.x <= end_1.x + 0.001) then
								if3 = true
								if ipos.x < begin_1.x then
									ipos.x = begin_1.x
								elseif ipos.x > end_1.x then
									ipos.x = end_1.x
								end
							elseif (ipos.x <= begin_1.x + 0.001 and ipos.x >= end_1.x - 0.001) then
								if3 = true
								if ipos.x > begin_1.x then
									ipos.x = begin_1.x
								elseif ipos.x < end_1.x then
									ipos.x = end_1.x
								end
							end
							if if3 then
								if (ipos.y >= begin_1.y - 0.001 and ipos.y <= end_1.y + 0.001) then
									if4 = true
									if ipos.y < begin_1.y then
										ipos.y = begin_1.y
									elseif ipos.y > end_1.y then
										ipos.y = end_1.y
									end
								elseif (ipos.y <= begin_1.y + 0.001 and ipos.y >= end_1.y - 0.001) then
									if4 = true
									if ipos.y > begin_1.y then
										ipos.y = begin_1.y
									elseif ipos.y < end_1.y then
										ipos.y = end_1.y
									end
								end
							end
						end
					end
					if if4 then
						local tp = cc.pSub(ipos,begin_1)
						local nl = math.sqrt(tp.x * tp.x + tp.y * tp.y)
						if max_Len == nil or max_Len < nl then
							max_Len = nl
							max_benin = cc.p(begin_2.x, begin_2.y)
							max_end = cc.p(end_2.x, end_2.y)
							insPos = cc.p(ipos.x, ipos.y)
						end
					end					
				end
			end
			if max_Len then
				local sv = cc.pSub(insPos, begin_1)
				local svlen = math.sqrt(sv.x * sv.x + sv.y * sv.y)
				if svlen < 1 then
					local pv_b = cc.pSub(max_benin, begin_1)
					local pvblen = math.sqrt(pv_b.x * pv_b.x + pv_b.y * pv_b.y)
					local pv_n = cc.pSub(max_end, begin_1)
					local pvnlen = math.sqrt(pv_n.x * pv_n.x + pv_n.y * pv_n.y)
					local pv , pvlen , isb
					if pvblen > pvnlen then
						isb = true
						pv = pv_b
						pvlen = pvblen
					else
						isb = false
						pv = pv_n
						pvlen = pvnlen
					end
					if pvlen >= 1 then
						local angle = cToolsForLua:calc2VecAngle(1.0, 0.0, pv.x, pv.y)
						local maxV = cc.p(math.cos(angle * math.pi / 180.0) * rangeRadius, math.sin(angle * math.pi / 180.0) * rangeRadius * helpModelMD.m_MoveSinDivCos)
						local maxLen = math.sqrt(maxV.x * maxV.x + maxV.y * maxV.y)
						local dt = (mdv.x * pv.x + mdv.y * pv.y) / pvlen
						if dt > maxLen then
							dt = maxLen
						elseif dt * -1 > maxLen then
							dt = maxLen * -1
						end
						if isb then
							if dt > 0 then
								if dt > pvblen then
									dt = pvblen
								end
							else
								if dt * -1 > pvnlen then
									dt = pvnlen * -1
								end
							end
						else
							if dt > 0 then
								if dt > pvnlen then
									dt = pvnlen
								end
							else
								if dt * -1 > pvblen then
									dt = pvblen * -1
								end
							end
						end
						canPoint = cc.p(begin_1.x + pv.x * dt / pvlen, begin_1.y + pv.y * dt / pvlen)
					else
						canPoint = insPos
					end
				else
					canPoint = insPos
				end
			end
		end
		if checkNodePoint2(canPoint) then
			return canPoint
		else
			return cc.p(originPoint.x, originPoint.y)
		end
	end
	
	function node.lua_getLeftStartPoint()
		return cc.p(configData.position_left[1], configData.position_left[2])
	end
	
	function node.lua_getRightStartPoint()
		return cc.p(configData.position_right[1], configData.position_right[2])
	end
	
	function node.lua_getLeftStartAngle()
		return 0
	end
	
	function node.lua_getRightStartAngle()
		return 180
	end
	
	return node
end


function createTop(id)
	local node = cc.Node:create()
	node:setAnchorPoint(cc.p(0.0, 0.0))
	node:setContentSize(cc.size(1.0, 1.0))
	node:setPosition(cc.p(0.0, 0.0))
	
	local configData = g_data.duel_map_para[id]
	
	local background = cc.Sprite:create(g_data.sprite[configData.map_res_layer].path)
	background:setAnchorPoint(cc.p(0.0, 0.0))
	background:setPosition(cc.p(0.0, 0.0))
	node:addChild(background)
	
	return node
end


function createDebug(id)
	local node = cc.Node:create()
	node:setAnchorPoint(cc.p(0.0, 0.0))
	node:setContentSize(cc.size(1.0, 1.0))
	node:setPosition(cc.p(0.0, 0.0))
	
	local drawNode = cc.DrawNode:create()
	drawNode:setContentSize(cc.size(1.0, 1.0))
	drawNode:setAnchorPoint(cc.p(0.0, 0.0))
	drawNode:setPosition(cc.p(0.0, 0.0))
	node:addChild(drawNode)
	
	local vertexs = {}
	local configData = g_data.duel_map_para[id]
	for i = 1, #(configData.move_range), 2 do
		vertexs[(#(vertexs)) + 1] = cc.p(configData.move_range[i], configData.move_range[i + 1])
	end
	drawNode:drawPoly(vertexs, #vertexs, true, cc.c4f(0.0, 1.0, 0.0, 1.0))
	
	return node
end



return mapModel