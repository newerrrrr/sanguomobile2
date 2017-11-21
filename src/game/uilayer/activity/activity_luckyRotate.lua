local activity_luckyRotate = {}
setmetatable(activity_luckyRotate,{__index = _G})
setfenv(1,activity_luckyRotate)

--幸运转盘

local m_Root = nil
local m_Widget = nil

local function clearGlobal()
	m_Root = nil
	m_Widget = nil
end


function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	--local widget = cc.CSLoader:createNode("zhuchengjiemian_02.csb")
    --m_Widget = widget
	
	return rootLayer
end



return activity_luckyRotate