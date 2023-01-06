local run = game:GetService("RunService")
local perma,render_perma,r_true,render_r_true = {},{},{},{} -- permanent functions, functions that return true

function RunPerma(_table,Delta)
	local s,e,self
	for i = 1,#_table do self = _table[i]
		s,e = pcall(self._function,Delta)
		if not s then
			warn(e.."\n-- -- | Serverheart return-true |")
		end
	end
end

function RunReturn(_table,Delta)
	local s,e,self
	for i = #_table,1,-1 do self = _table[i]
		s,e = pcall(self._function,Delta)
		if e == true then
			table.remove(_table,i)
			continue
		end
		if not s then
			warn(e.."\n-- -- | Serverheart return-true |")
			_table[i].C += 1
			if _table[i].C > 5 then
				table.remove(_table,i)
			end
		else
			_table[i].C = 0
		end
	end
end

run.Heartbeat:Connect(function(Delta)
	RunPerma(perma,Delta)
	RunReturn(r_true,Delta)
end)

run.RenderStepped:Connect(function(Delta)
	RunPerma(render_perma,Delta)
	RunReturn(render_r_true,Delta)
end)

return function(_function,Renderstepped,Permanent)
	local self = {}
	self._function = _function
	if Permanent then
		table.insert(Renderstepped and render_perma or perma,self)
	else
		self.C = 0
		table.insert(Renderstepped and render_r_true or r_true,self)
	end
end