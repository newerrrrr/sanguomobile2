--强化lua的工具

if table then
	
	if table.total == nil then
		table.total = function (t)
			local ret = 0
			if t and type(t) == "table" then
				for k , v in pairs(t) do
					ret = ret + 1
				end
			end
			return ret
		end
	end

end


if math then
	
	if math.clampf == nil then
		math.clampf = function ( value , min_inclusive , max_inclusive)
			local min_v = min_inclusive
			local max_v = max_inclusive
			if(min_inclusive > max_inclusive)then
				min_v = max_inclusive
				max_v = min_inclusive
			end
			if( value < min_inclusive )then
				return min_inclusive
			elseif( value > max_inclusive )then
				return max_inclusive
			else
				return value
			end
		end
	end
	
	
end



if string then
	
	if string.split == nil then
		string.split = function(input, delimiter)
			input = tostring(input)
			delimiter = tostring(delimiter)
			if (delimiter=='') then return false end
			local pos,arr = 0, {}
			-- for each divider found
			for st,sp in function() return string.find(input, delimiter, pos, true) end do
				table.insert(arr, string.sub(input, pos, st - 1))
				pos = sp + 1
			end
			table.insert(arr, string.sub(input, pos))
			return arr
		end
	end
	
	
end