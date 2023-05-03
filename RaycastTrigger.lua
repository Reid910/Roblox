
local SH = require(game:GetService("ServerStorage").Serverheart)

local oldpositions = {}

local RaylookFor = game.Workspace.RayLookFor
local rayparam = RaycastParams.new()
rayparam.FilterType = Enum.RaycastFilterType.Whitelist
rayparam.FilterDescendantsInstances = {RaylookFor}

SH(function(Delta)
	for _,plr in pairs(game.Players:GetPlayers()) do
		local pos = oldpositions[plr.UserId]
		if pos then
			local r = game.Workspace:Raycast(pos,plr.Character.PrimaryPart.Position-pos,rayparam)
			if r then
				if r.Instance == RaylookFor.Trigger then
					-- play wheelchair
				end
			end
		end
	end
end,true)
