function GetPV(Vector) -- power of vector
	return Vector.x*Vector.x + Vector.y*Vector.y + Vector.z*Vector.z
end

function CheckInRange(a,b,Dist)
	local d = b-a
	local sqrd = GetPV(d)
	if sqrd <= Dist*Dist then
		return true
	else
		return false
	end
end

function RangeCheck(A,B,Range)
	local Diff = B-A
	local POW = Diff*Diff
	return (POW.X+POW.Z) <= Range*Range
end
