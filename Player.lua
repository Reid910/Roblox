local SS = game:GetService("ServerStorage")

local _N = require(SS.NumConstructor)

local plr = {}
plr.__index = plr
plr.Players = {} -- stores all the players in the game

local phys = game:GetService("PhysicsService")
phys:CreateCollisionGroup("Players")
phys:CollisionGroupSetCollidable("Players","Players",false)

local function setpartcollision(p)
	if p:IsA("BasePart") then
		phys:SetPartCollisionGroup(p,"Players")
	end
end

function NewStat(T,N)
	local s = Instance.new(T)
	s.name = N
	return s
end

function plr.New(player)
	
	if not player or not player.UserId then
		return -- no player
	end
	
	local newplr = {}
	setmetatable(newplr,plr)
	
	local StatsF = Instance.new("Folder")
	StatsF.Name = "Stats"
	StatsF.Parent = player
	
	newplr.Cash = _N.New("Cash",StatsF)
	
	return newplr
	
end

function plr:Raycast() -- check for raycast and buy button or sumthin
	
end

game.Players.PlayerAdded:Connect(function(player)
	
	player.CharacterAdded:Connect(function(c)
		c.DescendantAdded:Connect(setpartcollision) -- maybe remove Connect later?
		for i,v in pairs(c:GetDescendants()) do
			setpartcollision(v)
		end -- collision groups
	end)
	
	local p = plr.New(player)
	plr.Players[player.UserId] = p
end)

game.Players.PlayerRemoving:Connect(function(player)
	-- save here
	plr.Players[player.UserId] = nil -- clear
end)

return plr