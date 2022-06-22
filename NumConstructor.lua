local MathLib = require(game:GetService("ServerStorage").MathLib)

local num = {}
num.__index = num

function num.New()
	
	local NewNumber = {}
	setmetatable(NewNumber,num)
	
	NewNumber.N = 0
	NewNumber.Notation = 0
	
	return NewNumber
	
end

function num.Temp(a,b)
	
	local a,b = MathLib.format(a,b)
	
	return {N=a,Notation=b}
end

function num:Set(a,b)
	
	self.N = a
	self.Notation = b
	
	return self
end

function num:Add(onum) -- other number
	return MathLib.AddNumbers(self.N,self.Notation,onum.N,onum.Notation)
end

function num:Sub(onum) -- other number
	return MathLib.SubNumbers(self.N,self.Notation,onum.N,onum.Notation)
end

function num:Multiply(onum) -- other number
	return MathLib.MultiplyNumbers(self.N,self.Notation,onum.N,onum.Notation)
end

function num:Divide(onum) -- other number
	return MathLib.DivideNumbers(self.N,self.Notation,onum.N,onum.Notation)
end

function num:Exp(onum) -- other number
	return MathLib.Pow(self.N,self.Notation,onum.N,onum.Notation)
end

return num