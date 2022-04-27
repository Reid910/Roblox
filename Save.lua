local m = {
	plrs = nil
}

local function Newstat(T,N)
	local s = Instance.new(T)
	s.Name = N
	return s
end

function m.Load(plr)

	local DS = nil -- load datastore here

	local l = Newstat("Folder","leaderstats")

	local level = Newstat("NumberValue","Level")

	level.Value = 1

	level.Parent = l

	l.Parent = plr

	local Data = {
		L = l, -- leaderstats
	}

	m.plrs[plr.UserId] = Data

	return Data

end

function m.Save(plr) -- index is user id
	m.plrs[plr.UserId] = nil
end

return m