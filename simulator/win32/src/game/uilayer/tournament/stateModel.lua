local state = {}
setmetatable(state,{__index = _G})
setfenv(1,state)

--武斗状态


m_OperateState = {
	readying = 1, 	--准备屏蔽
	move = 2,		--开始移动操作
	attack = 3,		--开始攻击操作
	skill = 4,		--开始技能操作
	waitPlay = 5,	--等待播放结果
}

function createOperateState()
	local ret = {}
	
	local operateState = m_OperateState.readying
	local operateStateChangeNoticeCallback = nil

	function ret.setOperateStateChangeNotice(f)
		operateStateChangeNoticeCallback = f
	end
	
	function ret.setOperateState(v)
		operateState = v
		if operateStateChangeNoticeCallback then
			operateStateChangeNoticeCallback(operateState)
		end
	end
	
	function ret.getOperateState()
		return operateState
	end
	
	return ret
end


function createGmaeState()
	local ret = {}
	
	local currentSeason = 0 	--当前对战是第几场(初始化必须0)
	local currentRound = 0		--当前是第几回合
	
	seasonStateChangeNoticeCallback = nil
	function ret.setSeasonStateChangeNotice(f)
		seasonStateChangeNoticeCallback = f
	end
	
	roundStateChangeNoticeCallback = nil
	function ret.setRoundStateChangeNotice(f)
		roundStateChangeNoticeCallback = f
	end
	
	function ret.addSeason()
		currentSeason = currentSeason + 1
		currentRound = 1
		if seasonStateChangeNoticeCallback then
			seasonStateChangeNoticeCallback(currentSeason)
		end
		if roundStateChangeNoticeCallback then
			roundStateChangeNoticeCallback(currentRound)
		end
	end
	
	function ret.addRound()
		currentRound = currentRound + 1
		if roundStateChangeNoticeCallback then
			roundStateChangeNoticeCallback(currentRound)
		end
	end
	
	function ret.getSeason()
		return currentSeason
	end
	
	function ret.getRound()
		return currentRound
	end
	
	
	local preLoad = {
		["1"] = {A = false, B = false},
		["2"] = {A = false, B = false},
		["3"] = {A = false, B = false},
	}
	
	function ret.preLoadRes(season, v)
		local b = preLoad[tostring(season)][v]
		if b == false then
			preLoad[tostring(season)][v] = true
		end
		return b
	end
	
	
	return ret
end




return state