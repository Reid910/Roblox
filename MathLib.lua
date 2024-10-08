local m = {
	LIMIT = 5
}

function Limit(a)
	local limit_num = math.pow(10,m.LIMIT)
	return math.floor(a*limit_num)/limit_num
end

function DoNotationShift(a,b) -- used to be the check 1-10
	if a == 0 then
		return 0,0
	end
	local leftover_not = b-math.floor(b)
	a *= math.pow(10,leftover_not)
	b = math.floor(b)
	if a >= 1 then
		local exp = math.floor(math.log10(a)) -- number of zeros
		return Limit(a / math.pow(10,exp)), b+exp
	else -- this works to keep numbers between 1 and below 10 - hope this works ( added negative capabilties )
		local exp = math.floor(math.abs(math.log10(math.abs(a)))+1) -- number of zeros below (1)
		return Limit(a * math.pow(10,exp)), b-exp
	end
end

function m.format(a,b)
	return DoNotationShift(a,b or 0)
end

function m.UnformatSmallN(a,b)
	return a * math.pow(10,b)
end

function m.IsLarger(a,aNot,b,bNot)
	if aNot > bNot then
		return true
	elseif aNot == bNot and a > b then
		return true
	end
	return false
end

function m.AddNumbers(aNum,aNot,bNum,bNot)
	local difference = aNot-bNot --|| 308-305 = 3 || 205-300 = -95 ||
	if math.abs(difference) > m.LIMIT then -- if it goes over the limit just return a or b
		if aNot > bNot then
			return aNum,aNot -- a
		else
			return bNum,bNot -- b
		end
	end
	
	local abs_pow_diff = math.pow(10,math.abs(difference))
	
	if difference > 0 then
		aNum *= abs_pow_diff
	elseif difference < 0 then
		bNum *= abs_pow_diff
	end
	
	local New = aNum + bNum
	New /= abs_pow_diff
	aNot = aNot > bNot and aNot or bNot
	
	return DoNotationShift(New,aNot)
end

function m.SubNumbers(aNum,aNot,bNum,bNot)
	local difference = aNot-bNot --|| 308-305 = 3 || 205-300 = -95 || 2 - - 5 = 7 ||
	
	if math.abs(difference) > m.LIMIT then
		if aNot > bNot then
			return aNum,aNot
		else
			return -bNum,bNot -- because we subtract b from a
		end
	end
	
	local abs_pow_diff = math.pow(10,math.abs(difference))

	if difference > 0 then
		aNum *= abs_pow_diff
	elseif difference < 0 then
		bNum *= abs_pow_diff -- why was this divide?
	end

	local New = aNum - bNum
	New /= abs_pow_diff
	
	return DoNotationShift(New,aNot)
end

function m.MultiplyNumbers(aNum,aNot,bNum,bNot)
	return DoNotationShift(aNum*bNum,aNot+bNot)
end

function m.DivideNumbers(aNum,aNot,bNum,bNot)
	return DoNotationShift(aNum/bNum,aNot-bNot)
end

function m.Pow(aNum,aNot,bNum,bNot)
	return DoNotationShift(math.pow(aNum,bNum*math.pow(10,bNot)),aNot*bNum*math.pow(10,bNot))
end

return m
