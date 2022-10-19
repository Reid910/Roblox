local Map = {
	
	R = Random.new(),
	
	Seed = nil,
	
	ExpndMulti = 5, -- defualt is 10
	isgenerated = false,
	
	Data = {},
	
	Node_count = 0,
	
	UEminDistance = 0.65, -- 0.65
	UEmaxDistance = 2, -- 1.8
	
	MinConnections = 3,
	MaxConnections = 8,
	
	Chunk_size = 5,
}

local Meta = {
	__index = function(T,I)
		T[I] = {
			Nodes={}
		}
		return T[I]
	end,
}

setmetatable(Map.Data,Meta)

function CheckInRange(a,b,Dist)
	Dist = Dist or Map.UEminDistance
	local d = b-a
	local sqrd = d.x*d.x + d.y*d.y + d.z*d.z
	if sqrd <= Dist*Dist then
		return true
	else
		return false
	end
end

function GetChunk(x,z)
	return Map.Data[ math.floor(x/Map.Chunk_size) .. "_" .. math.floor(z/Map.Chunk_size) ]
end

function GetAreaChunks(x,z)
	local Area = {}
	for X = -1*Map.Chunk_size,1*Map.Chunk_size,Map.Chunk_size do
		for Z = -1*Map.Chunk_size,1*Map.Chunk_size,Map.Chunk_size do
			table.insert(Area,GetChunk(x+X,z+Z)) -- getting chunks in area
		end
	end
	return Area
end

function Get_All_Nodes()
	
	local nodes = {}
	
	for i,chunk in pairs(Map.Data) do
		for _,node in pairs(chunk.Nodes) do
			table.insert(nodes,node)
		end
	end
	
	return nodes
end

function No_Node_Close(x,z) -- if no node closeby then return true
	
	local Area = GetAreaChunks(x,z)
	
	for i = 1,#Area do local chunk = Area[i]
		for __,node in pairs(chunk.Nodes) do
			if CheckInRange(Vector3.new(x,0,z),Vector3.new(node.x,0,node.z)) then
				return false
			end
		end
	end
	
	return true
end

function Get_all_Close(x,z)
	
	local Close_nodes = {}
	
	local Area = GetAreaChunks(x,z)
	
	for i = 1,#Area do local chunk = Area[i]
		for __,node in pairs(chunk.Nodes) do
			local Dist = Map.UEmaxDistance
			local sqrd = math.pow(x-node.x,2) + math.pow(z-node.z,2)
			if sqrd <= Map.UEmaxDistance*Map.UEmaxDistance then
				table.insert(Close_nodes,{o=node,sq=sqrd})
			end
		end
	end
	
	return Close_nodes
end

function CreateNode(x,z,color)
	local Node = Instance.new("Part")
	Node.Anchored = true
	Node.Locked = true
	Node.CanCollide = false
	Node.Color = color or Color3.new(0.196078, 0.196078, 0.196078)
	Node.Material = Enum.Material.SmoothPlastic
	Node.Shape = Enum.PartType.Cylinder
	Node.Position = Vector3.new(x,0,z) * Map.ExpndMulti
	Node.Size = Vector3.new(0.3,1.25,1.25)
	Node.Orientation = Vector3.new(0,0,90)
	Node.Parent = game.Workspace.Nodes
	table.insert(GetChunk(x,z).Nodes,{ obj=Node , x=x , z=z , connections = {} }) -- adds node
	Map.Node_count += 1
	return Node
end

function CreateRoad(from,to) -- just a display ( from and two are node's data )
	
	local Road = script.Road:Clone()
	
	Road.Position = UDim2.new( 0.5 , from.x * Map.ExpndMulti * 50 , 0.5 , from.z * Map.ExpndMulti * 50 )
	
	local D = Vector3.new(to.x,0,to.z) - Vector3.new(from.x,0,from.z) -- difference
	
	local middle = Vector3.new(from.x,0,from.z):Lerp(Vector3.new(to.x,0,to.z),0.5)
	
	Road.Size = UDim2.new( 0 , D.Magnitude * Map.ExpndMulti * 50 , 0 , 20 )
	
	Road.Position = UDim2.new( 0.5 , (from.x + D.X * 0.5) * Map.ExpndMulti * 50 , 0.5 , (from.z + D.Z * 0.5) * Map.ExpndMulti * 50 )
	
	Road.Rotation = math.deg(math.atan2(D.Unit.Z,D.Unit.X))
	
	Road.Parent = game.Workspace.Baseplate.SurfaceGui
	
end



function Map.Get_Area(start_node)
	-- use the start node and build a table that contains the area found by connections
	
	local Area = {}
	
	local function Get_AllConnected(node)
		
		for other_node,_ in pairs(node.connections) do
			
			if not Area[other_node] then
				
				Area[other_node] = 0
				
				Get_AllConnected(other_node)
				
			end
			
		end
		
	end
	
	Get_AllConnected(start_node)
	
	return Area
	
end

function Map.ClearMap()
	Map.isgenerated = false
	
	game.Workspace.Nodes:ClearAllChildren()
	
	table.clear(Map.Data)
	
	Map.Node_count = 0
	
end

function Map.Generate(Size)
	
	Map.Seed = Map.R:NextNumber(11111,99999)
	
	--Map.Seed = 0
	
	script:SetAttribute("Seed",Map.Seed)
	
	Map.Seed = math.log(Map.Seed,2) * 100
	
	--Map.Seed = 0
	
	Map.ClearMap()
	
	for x = -Size,Size do
		for z = -Size,Size do -- create base nodes layout
			
			if not CheckInRange(Vector3.new(x,0,z),Vector3.new(0,0,0),Size) then
				continue
			end
			
			local noise = math.noise(x*100,Map.Seed*x/z,z*100)
			
			if noise > 0.3 then
				
				local offx,offz = math.noise(x*10,Map.Seed+5,z*10)/2,math.noise(x*10,Map.Seed-5,z*10)/2
				
				if No_Node_Close(x+offx,z-offz) then -- add a check here to verify no nearby nodes ( too close )
					CreateNode(x+offx,z-offz)
				end
				
			end
			
		end
	end
	
	
	-- get node count if ~ 0 then re generate map --
	if Map.Node_count == 0 then
		game:GetService("TestService"):Message("Re-gen - seed: " .. Map.Seed)
		wait(0.5)
		Map.Generate(Size)
	end
	
	
	local function New_nodes_set(T,Color)
		
		local New_Nodes = {}
		
		for i = 1,#T do
			local node = T[i]
			
			local noise = math.noise(node.x*1000,Map.Seed+1,node.z*1000) + 0.5 -- between 0 and 1 now
			
			-- use this noise to get rotation
			
			local Angles = CFrame.Angles(0,math.rad(360*noise),0)
			
			local noise2 = math.noise(node.x*100,Map.Seed-1,node.z*100) + 0.5 -- between 0 and 1 now
			
			-- get a "random" length with noise2 then check if placeable
			
			local length = (Map.UEmaxDistance-Map.UEminDistance) * noise2 / 2 + Map.UEminDistance -- ( min-max ) 1.5 - min
			
			local new_vector = Vector3.new(node.x,0,node.z) + Angles.LookVector * length -- ( mix-max ) 1.5
			
			table.insert(New_Nodes,{x=new_vector.X,z=new_vector.Z})
			
		end
		
		for i = #New_Nodes,1,-1 do
			local node = New_Nodes[i]
			
			-- if too close then remove from newnodes
			
			if No_Node_Close(node.x,node.z) then -- add a check here to verify no nearby nodes ( too close )
				CreateNode(node.x,node.z,Color or Color3.fromHSV(1,1,1))
			else
				table.remove(New_Nodes,i)
			end
			
		end
		
		return New_Nodes
		
	end
	
	for x = -Size,Size,Map.Chunk_size do
		for z = -Size,Size,Map.Chunk_size do -- create base nodes layout
			
			local Chunk = GetChunk(x,z)
			
			local Set = New_nodes_set(Chunk.Nodes)
			
			local testloop_color_count = 5
			
			for i = 1,testloop_color_count do
				
				--New_nodes_set(Get_All_Nodes(),Color3.fromHSV(i/testloop_color_count,1,1))
				
				Map.Seed += 100
				
				Set = New_nodes_set(Set,Color3.fromHSV(i/testloop_color_count,1,1))
				
			end
			
		end
	end
	
	for i = 1,6 do
		
		New_nodes_set(Get_All_Nodes(),Color3.new(.2,0,0.5))
		
		Map.Seed += 250
		
	end
	
	-- add roads here
	for _,chunk in pairs(Map.Data) do
		
		for __,node in pairs(chunk.Nodes) do
			
			local connect_count = 0
			
			local connection = node.connections
			
			local Close_Nodes = Get_all_Close(node.x,node.z)
			
			table.sort(Close_Nodes,function(a,b)
				return a.sq < b.sq
			end)
			
			for ___,other_node in pairs(Close_Nodes) do
				
				if connect_count >= Map.MaxConnections then
					break
				else
					local _count = 0
					for i,v in pairs(other_node.o.connections) do
						_count += 1
					end
					if _count >= Map.MaxConnections then
						break
					end
				end
				
				if node == other_node.o then
					continue
				end
				
				if connection[other_node.o] then
					continue
				end
				
				-- we need to make this not 100% connections but a limited count ( tbh doesnt look so bad rn )
				
				node.connections[other_node.o] = 0
				
				other_node.o.connections[node] = 0
				
				CreateRoad(node,other_node.o)
				
				connect_count += 1
				
			end
			
			local testcount = 0
			
			for i,v in pairs(connection) do
				testcount += 1
			end
			
		end
		
	end
	
	-- Verify everything is connected
	
	local Main_area,Other_areas = nil,{}
	
	for _,chunk in pairs(Map.Data) do
		
		for __,node in pairs(chunk.Nodes) do
			
			Main_area = Map.Get_Area(node)
			
			break
			
		end
		
	end
	
	local function Check_oareas(node)
		for i,oarea in pairs(Other_areas) do
			
			if oarea[node] then
				return
			end
			
		end
		
		-- didnt find this area yet ( so we have to create it )
		
		table.insert(Other_areas,Map.Get_Area(node))
		
		-- and thats how we check / create other areas
		
	end
	
	
	for _,chunk in pairs(Map.Data) do
		
		for __,node in pairs(chunk.Nodes) do
			
			-- making sure the main area is the only area
			
			if Main_area[node] then
				continue
			end
			
			Check_oareas(node)
			
		end
		
	end
	
	-- we have created a main area and other areas
	
	-- after this we want to find the centre of each area
	
	-- find the closest area next to each area and connect it with the closest nodes from both areas
	
	-- now we have a 100% guarantee they are connected
	
	print(Main_area,Other_areas)
	
	Map.isgenerated = true
end

return Map