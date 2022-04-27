local plrs = {}

local _s = require(script.Save)
_s.plrs = plrs

local phys = game:GetService("PhysicsService")
phys:CreateCollisionGroup("Players")
phys:CollisionGroupSetCollidable("Players","Players",false)

local function setpartcollision(p)
	if p:IsA("BasePart") then
		phys:SetPartCollisionGroup(p,"Players")
	end
end

game.Players.PlayerAdded:Connect(function(plr)

	-- This function is better for loading when character respawns
	plr.CharacterAppearanceLoaded:Connect(function(c)
		c.Archivable = true
		wait()
	end)

	plr.CharacterAdded:Connect(function(c)

		c.DescendantAdded:Connect(setpartcollision) -- maybe remove Connect later?
		for i,v in pairs(c:GetDescendants()) do
			setpartcollision(v)
		end -- collision groups

	end)

	local Data = _s.Load(plr) -- loads leaderstats

end)

game.Players.PlayerRemoving:Connect(function(plr)
	_s.Save(plr)
end)

return plrs