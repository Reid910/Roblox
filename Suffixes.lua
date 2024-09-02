local Suffixes = {"K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No", "Dc", "Uc"}

function FormatDecimals(Num:number, Decimals:number) -- sets the decimals for the text
	return string.format("%." .. Decimals .. "f",Num)
end

function C:FormatCommas(Number: number)
	local Formatted = tostring(Number)
	local Updated, Count = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	if Count == 0 then
		return Updated
	else
		return C:FormatCommas(Updated)
	end
end

function C:Number(Num:number, Decimals:number, ForceENotation:BoolValue)
	if Num < 1e9 then return C:FormatCommas( Num == math.floor(Num) and FormatDecimals(Num,0) or FormatDecimals(Num,2)) end
	
	local Notation = math.floor(math.log(Num,10))
	
	local kNotation = math.floor(math.log(Num,1000))
	
	local Front = Num / math.pow(1000,kNotation)
	
	Decimals = (math.floor(Front) == Front) and 0 or (Decimals or 2)
	
	if (kNotation <= #Suffixes and not ForceENotation) then
		return string.format("%." .. Decimals .. "f",Num / math.pow(1000,kNotation)) .. ((kNotation > 0 and Suffixes[kNotation]) or "")
	else
		return string.format("%." .. Decimals .. "f",Num / math.pow(10,Notation)) .. (kNotation > 0 and "e+" .. Notation or "")
	end
end
