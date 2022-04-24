function m.CheckInRange(a,b,Dist)
	Dist = Dist or m.UEminDistance
	local d = b-a
	local sqrd = d.x*d.x + d.y*d.y + d.z*d.z
	if sqrd <= Dist*Dist then
		return true
	else
		return false
	end
end