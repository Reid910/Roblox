local Perma,r_true = {},{} -- permanent functions, functions that return true

game:GetService("RunService").Heartbeat:Connect(function(Delta)
	local s,e,self
	for i = 1,#Perma do self = Perma[i]
		s,e = pcall(self._function,Delta)
	end
	for i = #r_true,1,-1 do self = r_true[i]
		s,e = pcall(self._function,Delta)
		if e == true then
			table.remove(r_true,i)
			continue
		end
		if not s then
			warn(e.."\n-- -- | Serverheart return-true |")
			r_true[i].C += 1
			if r_true[i].C > 5 then
				table.remove(r_true,i)
			end
		else
			r_true[i].C = 0
		end
	end
end)

return function(_function,Permanent)
	local self = {}
	self._function = _function
	if Permanent then
		table.insert(Perma,self)
	else
		self.C = 0
		table.insert(r_true,self)
	end
end
