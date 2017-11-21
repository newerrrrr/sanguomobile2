local worldMapLayer_mapArray = {}
setmetatable(worldMapLayer_mapArray,{__index = _G})
setfenv(1,worldMapLayer_mapArray)
map = {
	[1] = { 10,15,15,15,15,15,11},
	[2] = { 14,23,24,25,26,27,16},
	[3] = { 14,18,19,20,21,22,16},
	[4] = { 14,5,6,7,8,9,16},
	[5] = { 14,1,2,3,4,32,16},
	[6] = { 14,33,28,29,30,31,16},
	[7] = { 12,17,17,17,17,17,13},
	}
return worldMapLayer_mapArray