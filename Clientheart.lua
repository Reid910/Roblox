local RunService = game:GetService("RunService")
local Testservice,funcs,render_funcs = game:GetService("TestService"),{},{}
function Err(Error)
	Testservice:Message(debug.traceback("		| ServerHeart |\nError: "..Error.."\n",2))
end

function RunTable(Table,Delta)
	for i = #Table,1,-1 do local self = Table[i]
		local s,r = xpcall(self._function,Err,Delta)
		if not s and not self.Permanent then
			if self.C >= self.ErrorBreakCount then
				if self.Errorcall then pcall(self.Errorcall) end
				table.remove(Table,i)
			else
				self.C += 1
			end
		elseif s and r and self.TrueBreak then
			table.remove(Table,i)
		end
	end
end

RunService.Heartbeat:Connect(function(Delta)
	debug.profilebegin("HeartbeatProfile")
	RunTable(funcs,Delta)
	debug.profileend()
end)

RunService.RenderStepped:Connect(function(Delta)
	debug.profilebegin("RenderheartProfile")
	RunTable(render_funcs,Delta)
	debug.profileend()
end)

_G.ServerHeart = function(_function,Renderstepped,Permanent,TrueBreak,Errorcall,ErrorBreakCount)
	local t = {_function = _function, Permanent = Permanent, TrueBreak = TrueBreak,
		Errorcall = Errorcall, ErrorBreakCount = ErrorBreakCount or 5, C = 0}
	if Renderstepped then
		table.insert(render_funcs,t)
	else
		table.insert(funcs,t)
	end
end

return _G.ServerHeart
-- Errorcall is a callback function that is run when the function 
-- ErrorBreakCount is a NUMBER that tells the code when to call Errorcall and remove from the serverheart
