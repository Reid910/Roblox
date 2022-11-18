
local Suffixes = {"", "K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No", "Dc", "Uc",}

return function(value,DV)
	
	if not value or value < 1 then
		return 0
	end
	
	DV = DV or value >= 1000 and 2 or 0
	
	local SN = math.floor(math.log(value,1000))
	
	local Front = value / math.pow(1000,SN)
	
	if math.floor(Front) == Front then
		DV = 0
	end
	
	return string.format("%." .. DV .. "f",Front) .. Suffixes[SN + 1] or ("e+"..(SN*3)) -- 5.4 K | 8.92 T
	
end
