local Testservice,funcs = game:GetService("TestService"),{}
function Err(Error)
	Testservice:Message(debug.traceback("		| ServerHeart |\nError: "..Error.."\n",2))
end

game:GetService("RunService").Heartbeat:Connect(function(Delta)
	debug.profilebegin("HeartbeatProfile")
	local self
	for i = #funcs,1,-1 do self = funcs[i]
		local s,r = xpcall(self._function,Err,Delta)
		if not s and not self.Permanent then
			if self.C >= self.ErrorBreakCount then
				if self.Errorcall then pcall(self.Errorcall) end
				table.remove(funcs,i)
			else
				self.C += 1
			end
		elseif s and r and self.TrueBreak then
			table.remove(funcs,i)
		end
	end
	debug.profileend()
end)

_G.ServerHeart = function(_function,Permanent,TrueBreak,Errorcall,ErrorBreakCount)
	table.insert(funcs,{_function = _function, Permanent = Permanent, TrueBreak = TrueBreak,
		Errorcall = Errorcall, ErrorBreakCount = ErrorBreakCount, C = 0})
end

return _G.ServerHeart
-- Errorcall is a callback function that is run when the function 
-- ErrorBreakCount is a NUMBER that tells the code when to call Errorcall and remove from the serverheart
