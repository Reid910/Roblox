local m = {
	Heartfunctions = {},
	Permanentfunctions = {},
	Erroredfunctions = {}
}

function m.AddToHeart(func,NeverBreak)
	if NeverBreak then
		table.insert(m.Permanentfunctions,func)
	else
		table.insert(m.Heartfunctions,func)
	end
end

game:GetService("RunService").Heartbeat:Connect(function(Delta)
	for i = 1,#m.Permanentfunctions do local f = m.Permanentfunctions[i]
		local s,e = pcall(f,Delta)
		if not s then
			warn(e.."\n-- -- | Serverheart Permanent |")
		end
	end
	for i = #m.Heartfunctions,1,-1 do local f = m.Heartfunctions[i]
		local s,e = pcall(f,Delta)
		if s and e then -- if success and returned true then del
			table.remove(m.Heartfunctions,i)
		elseif not s then
			table.insert(m.Erroredfunctions,{["f"]=f,["c"]=1})
			table.remove(m.Heartfunctions,i)
		end
	end
	for i = #m.Erroredfunctions,1,-1 do local f = m.Erroredfunctions[i]
		local s,e = pcall(f.f,Delta)
		if not s then -- if the function errored again
			f.c += 1
			if f.c > 5 then -- if the error count is greater then 5 then del
				warn(e.."\n-- -- | Serverheart Errorfunctions |")
				table.remove(m.Erroredfunctions,i)
			end
		elseif s and e then -- if success and returned true then del
			table.remove(m.Erroredfunctions,i)
		elseif s then -- It successfully ran add it back
			table.insert(m.Heartfunctions,f.f)
			table.remove(m.Erroredfunctions,i)
		end
	end
end)

return m
