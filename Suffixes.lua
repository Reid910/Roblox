-- you can consider using this

local abbreviations = {"", "K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No", "Dc", "Uc",}

return function(value,decimals)
	
	if not value or value == 0 then
		return 0
	end
	
	decimals = decimals or value >= 1000 and 2 or 0
	
	local suffix = math.floor(math.log(value,1000))
	
	local normal = value / math.pow(1000,suffix)
	
	return string.format("%." .. decimals .. "f",normal) .. abbreviations[suffix + 1] or ("e+"..(suffix*3)) -- 5.4 K | 8.92 T
	
end

-- this is how i would layout the module
