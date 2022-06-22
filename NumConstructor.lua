local MathLib = require(game:GetService("ServerStorage").MathLib)

local num = {}
num.__index = num

function NewStat(T,N)
	local S = Instance.new(T)
	S.Name = N
	return S
end

function num.New(StatName,Parent)
	
	local NewNumber = {}
	setmetatable(NewNumber,num)
	
	NewNumber.N = 0
	NewNumber.Notation = 0
	
	if StatName then
		local NumbValue = NewStat("NumberValue",StatName or "") -- creating a numbervalue
		NumbValue.Value = NewNumber.N
		NumbValue:SetAttribute("Not",NewNumber.Notation)
		NumbValue.Parent = Parent
	end
	
	return NewNumber
	
end

function num.Temp(a,b)
	
	local a,b = MathLib.format(a,b)
	
	return {N=a,Notation=b}
end

function num:Update(a,b)
	self.N,self.Notation = a,b
	if self.NValue then
		self.NValue.Value = a
		self.NValue:SetAttribute("Not",b)
	end
end

function num:Set(a,b)
	
	self.N = a
	self.Notation = b
	
	return self
end

function num:Add(onum,Setvalue) -- other number
	local a,b = MathLib.AddNumbers(self.N,self.Notation,onum.N,onum.Notation)
	if Setvalue then
		self:Update(a,b)
	else
		return a,b
	end
end

function num:Sub(onum,Setvalue)
	local a,b = MathLib.SubNumbers(self.N,self.Notation,onum.N,onum.Notation)
	if Setvalue then
		self:Update(a,b)
	else
		return a,b
	end
end

function num:Multiply(onum,Setvalue)
	local a,b = MathLib.MultiplyNumbers(self.N,self.Notation,onum.N,onum.Notation)
	if Setvalue then
		self:Update(a,b)
	else
		return a,b
	end
end

function num:Divide(onum,Setvalue)
	local a,b = MathLib.DivideNumbers(self.N,self.Notation,onum.N,onum.Notation)
	if Setvalue then
		self:Update(a,b)
	else
		return a,b
	end
end

function num:Exp(onum,Setvalue)
	local a,b = MathLib.Pow(self.N,self.Notation,onum.N,onum.Notation)
	if Setvalue then
		self:Update(a,b)
	else
		return a,b
	end
end

return num
