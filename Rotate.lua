function m.RotatePoint(Pos,r)
	r = r % 360
	r = r * math.pi / 180
	return Vector3.new(
		Pos.X * math.cos(r) - Pos.Z * math.sin(r),
		Pos.Y,
		Pos.Z * math.cos(r) + Pos.X * math.sin(r)
	)
end