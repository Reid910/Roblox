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

function Map.Get_All_Nodes()
	
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

function Check_max_connections(node)
	
end

local Nodes_folder = game.Workspace.Nodes

function CreateNode(x,z,color)
	local Node = Instance.new("Part")
	Node.Anchored = true
	Node.Locked = true
	Node.CanCollide = false
	Node.TopSurface = Enum.SurfaceType.Smooth
	Node.BottomSurface = Enum.SurfaceType.Smooth
	Node.LeftSurface = Enum.SurfaceType.Smooth
	Node.RightSurface = Enum.SurfaceType.Smooth
	Node.FrontSurface = Enum.SurfaceType.Smooth
	Node.BackSurface = Enum.SurfaceType.Smooth
	Node.Color = color or Color3.fromHSV(0, 0, 1)
	Node.Material = Enum.Material.Plastic
	Node.Shape = Enum.PartType.Cylinder
	Node.Position = Vector3.new(x * Map.ExpndMulti,0.1,z * Map.ExpndMulti)
	Node.Size = Vector3.new(0.3,1.25,1.25)
	Node.Orientation = Vector3.new(0,0,90)
	Node.Parent = Nodes_folder
	local Chunk = GetChunk(x,z)
	table.insert(Chunk.Nodes,{ obj=Node , x=x , z=z , CH = Chunk, C = {} }) -- C = Connections, CH = Chunk
	Map.Node_count += 1
	return Node
end

local Baseplate_ui = game.Workspace.Baseplate.SurfaceGui

function CreateRoad(from,to) -- just a display ( from and two are node's data )
	
	local Road = script.Road:Clone()
	
	local mul = Map.ExpndMulti * 15
	
	local D = Vector3.new(to.x-from.x,0,to.z-from.z)
	
	Road.Size = UDim2.new( 0 , D.Magnitude * mul - 15 , 0 , 5 )
	
	Road.Position = UDim2.new( 0.5 , (from.x + D.X / 2 ) * mul , 0.5 , (from.z + D.Z / 2) * mul )
	
	Road.Rotation = math.deg(math.atan2(D.Z,D.X))
	
	Road.Parent = Baseplate_ui
	
	return Road
	
end

function Map.Get_Area(start_node)
	-- use the start node and build a table that contains the area found by connections
	
	local Area = {}
	
	local function Get_All_Connected(node)
		
		for other_node,_ in pairs(node.C) do
			
			if not Area[other_node] then
				
				Area[other_node] = 0
				
				Get_All_Connected(other_node)
				
			end
			
		end
		
	end
	
	Area[start_node] = 0
	
	Get_All_Connected(start_node)
	
	return Area
	
end

function Delete_node(node)
	
	for con_node,_ in pairs(node.C) do
		
		con_node.C[node] = nil
		
	end
	
	for i,n in pairs(node.CH.Nodes) do
		
		if n == node then
			
			table.remove(node.CH.Nodes,i)
			
			node.obj:Destroy()
			
		end
		
	end
	
end

function Getmax_connection_count(node)
	
	local other_connections = Get_all_Close(node.x,node.z)
	
	local max_other_con = 0
	
	for i,v in pairs(other_connections) do
		max_other_con += 1
	end
	
	--print(max_other_con)
	
	-- i detect legit ALL possible connections that it will have
	-- or i ... go and create a new node for each single that connects to others ( search around for a spot that connects two more than one node and add it )
	
	return max_other_con
	
end

function remove_singles(start_node)
	
	if Getmax_connection_count(start_node) < Map.MinConnections - 1 then
		
		local nt = table.clone(start_node.C)
		
		Delete_node(start_node) -- instead of deleting add another node nearby
		
	end
	
end

function Map.ClearMap()
	
	Map.isgenerated = false
	
	Nodes_folder:ClearAllChildren()
	
	Baseplate_ui:ClearAllChildren()
	
	table.clear(Map.Data)
	
	Map.Node_count = 0
	
end

function Map.Generate(Size)
	
	Baseplate_ui.Enabled = false
	
	Map.Seed = Map.R:NextNumber(11111,99999)
	
	--Map.Seed = 0
	
	script:SetAttribute("Seed",Map.Seed)
	
	Map.Seed = math.log(Map.Seed,2) * 100
	
	--Map.Seed = 0
	
	Map.ClearMap()
	
	--local BaseLayCK = os.clock() -- testing
	
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
				CreateNode(node.x,node.z,Color)
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
				
				Map.Seed += 100
				
				Set = New_nodes_set(Set)
				
				--Set = New_nodes_set(Set,Color3.fromHSV(i/testloop_color_count,1,1))
				
			end
			
		end
	end
	
	--warn(" -- BASE LAYOUT TIME -- : " .. os.clock() - BaseLayCK)
	
	--local MapSetCK = os.clock()
	
	for i = 1,6 do
		
		New_nodes_set(Map.Get_All_Nodes())
		
		Map.Seed += 250
		
	end
	
	--warn(" -- SIX SET TIME -- : " .. os.clock() - MapSetCK)
	
	--local RoadsCK = os.clock()
	
	for _,chunk in pairs(Map.Data) do
		-- taking care of each leftover node
		for __,node in pairs(chunk.Nodes) do
			
			remove_singles(node)
			
		end
		
	end
	
	-- add roads here
	for _,chunk in pairs(Map.Data) do
		
		for __,node in pairs(chunk.Nodes) do
			
			local connection = node.C
			
			local Total_connections = 0
			
			for i,v in pairs(connection) do
				Total_connections += 1
			end
			
			local Close_Nodes = Get_all_Close(node.x,node.z)
			
			table.sort(Close_Nodes,function(a,b)
				return a.sq < b.sq
			end)
			
			-- could use the seed for max connections of each node ( to make it varry )
			
			--if Getmax_connection_count(node) < Map.MinConnections then
			--	continue
			--end
			
			local noise = math.clamp( math.noise(node.x*1000,Map.Seed,node.z*1000) + 0.5, 0, 1 ) -- between 0 and 1 now
			
			local Target_con = math.floor( ( Map.MaxConnections - Map.MinConnections ) * noise ) + Map.MinConnections
			
			for ___,other_node in pairs(Close_Nodes) do
				
				if Total_connections >= Target_con then -- limits the # of connections
					break
				else
					local _count = 0
					for i,v in pairs(other_node.o.C) do
						_count += 1
					end
					if _count >= Target_con then
						continue
					end
				end
				
				if node == other_node.o then
					continue
				end
				
				if connection[other_node.o] then
					continue
				end
				
				--if Getmax_connection_count(other_node.o) < Map.MinConnections then
				--	continue
				--end
				
				node.C[other_node.o] = 0
				
				other_node.o.C[node] = 0
				
				Total_connections += 1
				
				CreateRoad(node,other_node.o)
				
				--table.insert(Roads,r)
				
			end
			
			if Total_connections <= 0 then
				warn(Total_connections .. " delete")
				Delete_node(node)
				continue
			end
			
			if Total_connections < Map.MinConnections - 1 then
				
				-- solution is to instead add a new node next to it
				
			end
			
		end
		
	end
	
	--warn(" -- ROADS TIME -- : " .. os.clock() - RoadsCK)
	
	-- Verify everything is connected
	
	--local AreaCK = os.clock()
	
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
	
	--warn(" -- AREA CHECK TIME -- : " .. os.clock() - AreaCK)
	
	--print(Main_area,Other_areas)
	
	
	
	-- maybe we can set a table of each possbile spawn here ( do a min distance for spawns )
	
	-- hoping the chunks make picking spawns better
	
	
	
	local Final_data = {}
	
	for _,chunk in pairs(Map.Data) do
		
		for __,node in pairs(chunk.Nodes) do
			
			Final_data[node.obj] = node
			
		end
		
	end
	
	Map.Data = Final_data
	
	-- sets data to a dictionary instead of chunks ( makes lookups so much faster and easier )
	
	Map.Other_areas = Other_areas
	
	Baseplate_ui.Enabled = true
	
	Map.isgenerated = true
	
end

return Map