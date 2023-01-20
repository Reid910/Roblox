local m = {}

local Decimal_cap = 5

local Suffixes = {"K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No", "Dc", "Uc",}

function m.Suffix(N,Not,Decimals)
	
	if N == 0 or not N then
		--warn("nil or 0 - suffix - n_ml")
		return 0
	end
	
	local SN = math.floor(math.log(math.abs(N),1000))
	
	local Front = N / math.pow(1000,SN)
	
	if Not ~= 0 then
		Front *= math.pow( 10, Not % 3 )
		SN += math.floor( Not / 3 )
	end
	
	if math.floor(Front) == Front then
		Decimals = 0
	else
		Decimals = Decimals or N >= 1000 and 2 or 0
	end
	
	if SN >= 1 and SN <= #Suffixes then
		return string.format("%." .. Decimals .. "f",Front) .. Suffixes[SN] -- 5.4 K | 8.92 T
	else
		if Not > 0 then
			if Not < 3 then
				return string.format("%." .. Decimals .. "f",N * math.pow(10,Not))
			end
			return string.format("%." .. Decimals .. "f",N) .. "e+" .. Not -- 5.4 K | 8.92 T
		elseif Not < 0 then
			return string.format("%." .. Decimals .. "f",N) .. "e" .. Not
		else -- SN == 0
			return string.format("%." .. Decimals .. "f",N)
		end
		
	end
	
end

function NewStat(stat_name,parent,string_value)
	local S = Instance.new("StringValue")
	S.Name = stat_name
	S.Value = string_value
	S.Parent = parent
	return S
end

local meta = {}
meta.__index = meta

function m.new_stat(N,Not,StatName,Parent)
	
	local self = {
		N = N or 0,
		Not = Not or 0,
	}
	
	if StatName then
		self.stat = NewStat("Cash", Parent, m.Suffix(N,Not,1))
	end
	
	setmetatable(self, meta)
	
	return self
	
end

function shift_not(num)
	
	local a,b = num.N,num.Not
	if a == 0 then
		num.N,num.Not = 0,0
		return num
	end
	
	print(num,a,b)
	
	--a *= math.pow(10,b-math.floor(b)) -- this is some Notation float fix ( i dont remember how it happens )
	--b = math.floor(b)
	
	local exp = math.floor(math.log10(math.abs(a)))
	
	-- ( a = 0.05 ) exp = -2
	-- ( a = 5 ) exp = 0
	-- ( a = 50 ) exp = 1
	
	num.N,num.Not = a * math.pow(10, -exp), b + exp
	
	-- pow 10, -1 = 0.1
	-- pow 10, 1 = 10
	-- pow 10, 2 = 100
	
	warn(num)
	
	warn("----")
	
	return num
	
end

function meta:plus_equal(other) -- try this with all operators ( or just set_stat )
	
	self:set(self + other)
	
end

function meta:set(stat,new_value)
	
	new_value = shift_not(new_value)
	
	stat.N = new_value.N
	stat.Not = new_value.Not
	
	if stat.stat then
		stat.stat.Value = m.Suffix(new_value.N,new_value.Not,1)
	end
	
end

function GetDifference(a,b)
	
	local difference = a.Not-b.Not --|| 308-305 = 3 || 205-300 = -95 ||
	
	if math.abs(difference) > Decimal_cap then -- if it goes over the limit just return a or b ( over cap = return value | else return false )
		if difference > 0 then
			return a
		else
			return b
		end
	else
		return false,difference
	end
end

function GetValues(a,b)
	
	a,b = m.new_stat(a.N,a.Not),m.new_stat(b.N,b.Not)
	
	shift_not(a)
	shift_not(b)
	
	-- newstats to use and modify for calculations is needed it looks like modifying the perameters also modify the actual originals
	
	return a,b
	
end

meta.__add = function(...) -- add -- need to make this work 100% and optimize the code
	
	local a,b = GetValues(...) -- make sure the first number in the single digits
	
	if a.N == 0 then -- if one of the single digits is 0 just give the other number
		return b
	elseif b.N == 0 then
		return a
	end
	
	local difference = a.Not-b.Not --|| 308-305 = 3 || 205-300 = -95 ||
	
	if math.abs(difference) > Decimal_cap then -- if it goes over the limit just return a or b ( over cap = return value | else return false )
		if difference > 0 then
			return a
		else
			return b
		end
	end
	
	if difference == 0 then -- if there is no difference then just add the values together
		
		a.N += b.N
		
	else -- test: 1, 10 -- difference -1
		
		local abs_pow_diff = math.pow(10,math.abs(difference)) -- 10
		
		if difference > 0 then -- -1 so else
			a.N *= abs_pow_diff -- it has bigger notation
			a.N += b.N -- add the other value
			a.N /= abs_pow_diff -- return to original size w/ other's "num" added
		else
			a.N /= abs_pow_diff -- it has smaller notation
			a.Not = b.Not -- set the notation because its bigger
			a.N += b.N -- add the value onto result ( other is bigger and will be positive )
		end
		
	end
	
	return shift_not(a) -- make sure its all correct
end

meta.__sub = function(...) -- sub ( need to do this next ( finished doing add ) )
	
	local a,b = GetValues(...)
	
	if a.N == 0 then
		warn(a,b,"returned")
		return -b
	elseif b.N == 0 then
		return a
	end
	
	local difference = a.Not-b.Not --|| 308-305 = 3 || 205-300 = -95 ||
	
	if math.abs(difference) > Decimal_cap then -- if it goes over the limit just return a or b ( over cap = return value | else return false )
		if difference > 0 then
			return a
		else
			return -b
		end
	end
	
	if difference == 0 then
		
		a.N -= b.N
		
	else -- difference is 4 ( a = 5 , b = 1 ) notation ( a = 1.1 , b = 2 )
		
		local abs_pow_diff = math.pow(10,math.abs(difference))
		
		if difference > 0 then
			a.N *= abs_pow_diff
			a.N -= b.N
			a.N /= abs_pow_diff
		elseif difference < 0 then
			b.N *= abs_pow_diff
			a.N -= b.N
			--b.N /= abs_pow_diff
		end
		
	end
	
	return shift_not(a)
end

meta.__unm = function(a) -- "-"
	print(a,"... unm")
	a.N = a.N * -1
	print(a)
	return a
end

meta.__mul = function(...) -- multiply
	local a,b = GetValues(...)
	a.N *= b.N
	a.Not += b.Not
	return shift_not(a)
end

meta.__div = function(...) -- divide
	local a,b = GetValues(...)
	a.N /= b.N
	a.Not -= b.Not
	return shift_not(a)
end

--m.__mod = function(input,other) -- modulus
	
--end

meta.__pow = function(...) -- power
	local a,b = GetValues(...)
	-- try making a its own scientific notation with a notation
	local big_other = b.N*math.pow(10,b.Not) -- unravel b
	a.N ^= big_other
	a.Not *= big_other -- add 0's onto
	return shift_not(a)
end

meta.__eq = function(...) -- equals
	local a,b = GetValues(...)
	return (a.N == b.N and a.Not == b.Not)
end

meta.__lt = function(...) -- less than
	local a,b = GetValues(...)
	if a.Not < b.Not then
		if a.N <= b.N then
			return true
		end
	end
	return false
end

meta.__le = function(...) -- less than or equal
	local a,b = GetValues(...)
	if a.Not <= b.Not then
		if a.N <= b.N then
			return true
		end
	end
	return false
end

meta.__tostring = function(input)
	return m.Suffix(input.N,input.Not,1)
end

return m

