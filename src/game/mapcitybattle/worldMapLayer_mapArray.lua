local worldMapLayer_mapArray = {}
setmetatable(worldMapLayer_mapArray,{__index = _G})
setfenv(1,worldMapLayer_mapArray)
map = {
	[1] = { 1,1,1,1,1,1,1},
	[2] = { 1,1,1,1,1,1,1},
	[3] = { 1,1,1,1,1,1,1},
	[4] = { 1,1,1,1,1,1,1},
	[5] = { 1,1,1,1,1,1,1},
	[6] = { 1,1,1,1,1,1,1},
	[7] = { 1,1,1,1,1,1,1},
	}
return worldMapLayer_mapArray