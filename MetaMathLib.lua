local m = {}
m.__index = m

local Decimal_Limit = 5

function Limit(a)
	local limit_num = math.pow(10,Decimal_Limit)
	return math.floor(a*limit_num)/limit_num
end

function Notation_Shift(num) -- does this actually work 100% ? I mean it works to shift i should still double check though
	local a,b = num.N,num.Notation
	if a == 0 then
		num.N,num.Notation = 0,0
		return num
	end
	a *= math.pow(10,b-math.floor(b))
	b = math.floor(b)
	if a >= 1 then
		local exp = math.floor(math.log10(a)) -- number of zeros
		num.N,num.Notation = Limit(a / math.pow(10,exp)), b+exp
		return num
	else -- this works to keep numbers between 1 and below 10 - hope this works ( added negative capabilties )
		local exp = math.floor(math.abs(math.log10(math.abs(a)))+1) -- number of zeros below (1)
		num.N,num.Notation = Limit(a * math.pow(10,exp)), b-exp
		return num
	end
end

function NewStat(T,N)
	local S = Instance.new(T)
	S.Name = N
	return S
end

function m.NewNum(a,b,StatName,Parent)
	
	local NewNumber = {}
	setmetatable(NewNumber,m)
	
	if type(a) == "table" then
		NewNumber.N,NewNumber.Notation = a.N,a.Notation
	else
		NewNumber.N = a or 0
		NewNumber.Notation = b or 0
	end
	
	if StatName and Parent then -- creating a numbervalue
		local NumbValue = NewStat("NumberValue",StatName)
		NumbValue.Value = NewNumber.N
		NumbValue:SetAttribute("Not",NewNumber.Notation)
		NumbValue.Parent = Parent
		NewNumber.Stat = NumbValue
	end
	
	Notation_Shift(NewNumber)
	
	return NewNumber
	
end

function m.ConvertNumber(num)
	return Notation_Shift(m.NewNum():Set(num))
end

function ConvertInputs(a,b)
	if type(a ~= "table") then
		a = m.ConvertNumber(a)
	end
	if b then
		if type(b ~= "table") then
			b = m.ConvertNumber(b)
		end
	end
	return a,b
end

function m:Set(a,b) -- works with one parameter
	
	if type(a) == "table" then
		self.N,self.Notation = a.N,a.Notation
		
		if self.Stat then
			self.Stat.Value = self.N
			self.Stat:SetAttribute("Not",self.Notation)
		end
		
		return self
	end
	
	self.N = a or 0
	self.Notation = b or 0
	
	return self
end

m.__add = function(input,other)
	
	input,other = ConvertInputs(input,other)
	
	if input.N == 0 then
		return other
	elseif other.N == 0 then
		return input
	end
	
	local result = m.NewNum(input.N,input.Notation)
	
	local difference = input.Notation-other.Notation --|| 308-305 = 3 || 205-300 = -95 ||
	if math.abs(difference) > Decimal_Limit then -- if it goes over the limit just return a or b
		if difference > 0 then
			return result
		else
			return result:Set(other.N,other.Notation)
		end
	end
	
	local abs_pow_diff = math.pow(10,math.abs(difference))
	
	if difference > 0 then
		result.N *= abs_pow_diff
	elseif difference < 0 then
		result.N /= abs_pow_diff
	end
	
	result.N += other.N
	result.N /= abs_pow_diff
	result.Notation = result.Notation > other.Notation and result.Notation or other.Notation

	return Notation_Shift(result)
	
end

m.__sub = function(input,other)
	
	input,other = ConvertInputs(input,other)
	
	if input.N == 0 then
		return other
	elseif other.N == 0 then
		return input
	end
	
	local result = m.NewNum(input.N,input.Notation)
	
	local difference = input.Notation-other.Notation --|| 308-305 = 3 || 205-300 = -95 ||
	if math.abs(difference) > Decimal_Limit then
		if difference > 0 then -- I think this might need a rework
			return result
		else
			return result:Set(other.N,other.Notation) -- because we subtract b from a
		end
	end
	
	local abs_pow_diff = math.pow(10,math.abs(difference))
	
	if difference > 0 then
		result.N *= abs_pow_diff
	elseif difference < 0 then
		result.N /= abs_pow_diff
	end
	
	result.N -= other.N
	result.N /= abs_pow_diff
	result.Notation = result.Notation > other.Notation and result.Notation or other.Notation
	
	return Notation_Shift(result)
end

m.__unm = function(input)
	input = ConvertInputs(input)
	return m.NewNum(-input.N,input.Notation)
end

m.__mul = function(input,other)
	input,other = ConvertInputs(input,other)
	return Notation_Shift(m.NewNum(input.N*other.N,input.Notation+other.Notation))
end

m.__div = function(input,other)
	input,other = ConvertInputs(input,other)
	return Notation_Shift(m.NewNum(input.N/other.N,input.Notation-other.Notation))
end

--m.__mod = function(input,other) -- this wasnt implemented yet ( modulus )
--	input.N,input.Notation = input.N/other.N,input.Notation-other.Notation
--	return Notation_Shift(input)
--end

m.__pow = function(input,other) -- this requires a small "other" number so it doesnt go past 1e+308 ( also requires ^ to run )
	input,other = ConvertInputs(input,other)
	local big_other = other.N*math.pow(10,other.Notation)
	return Notation_Shift(m.NewNum(math.pow(input.N, big_other), input.Notation * big_other))
end

m.__eq = function(input,other) -- equals
	input,other = ConvertInputs(input,other)
	if input.Notation == other.Notation then
		if input.N == other.N then
			return true
		end
	end
	return false
end

m.__lt = function(input,other) -- less than
	input,other = ConvertInputs(input,other)
	if input.Notation < other.Notation then
		if input.N < other.N then
			return true
		end
	end
	return false
end

m.__le = function(input,other) -- less than equal to
	input,other = ConvertInputs(input,other)
	if input.Notation <= other.Notation then
		if input.N <= other.N then
			return true
		end
	end
	return false
end

m.__tostring = function(input) -- format the string
	input = ConvertInputs(input)
	if input.Notation == 0 then
		return input.N
	else
		return input.N .. "e+" .. input.Notation
	end
end

function m.Abs(input)
	return m.NewNum(math.abs(input.N),input.Notation)
end

return m
