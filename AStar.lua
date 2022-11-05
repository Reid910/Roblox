
function Get_Cost(from,to,goal) -- mix of greed and a heuristic
	
	local To_Goal = ( Vector3.new(to.x,0,to.z) - Vector3.new(goal.x,0,goal.z) ).Magnitude -- magnitude just works better right now
	
	local Length = ( Vector3.new(to.x,0,to.z) - Vector3.new(from.x,0,from.z) ).Magnitude -- needs magnitude to work
	
	return Length,To_Goal
	
end

return function(node_a,node_b,team_id) -- a = start , b = finish
	
	if node_a == node_b then
		return {}
	end
	
	for node,_ in pairs(node_a.C) do
		if node == node_b then
			return {node_a,node_b}
		end
	end
	
	local Visited = {} -- dont use an array
	
	local Priority = {{n = node_a, Length_cost = 0, cost = 0}}
	-- assigning nodes costs then sorting them to find the lowest costs in the first position
	
	local Checked = {[node_a] = Priority[1]} -- checked is references to prio ( needs a default to first prio )
	
	local goal = false
	
	local function Expand(Highest_priority)
		
		for node,_ in pairs(Highest_priority.n.C) do
			
			if node == Highest_priority.p_node then
				continue -- dont want to make back and fourth
			end
			
			if node == node_b then
				goal = true
			end
			
			local l,g = Get_Cost(Highest_priority.n,node,node_b)
			
			-- i had if Visited[node] ( it was checking if the connection was faster, but it skips nodes )
			
			if not Checked[node] then
				
				local Priority_table = {
					n = node,
					Length_cost = Highest_priority.Length_cost+l,
					cost = Highest_priority.Length_cost+l+g,
					p_node = Highest_priority.n,
				}
				
				table.insert(Priority,Priority_table)
				
				Checked[node] = Priority_table
				
			end
			
		end
		
		Visited[Highest_priority.n] = { -- after adding all connections to priority and comparing other nodes add this node to visited
			cost = Highest_priority.cost,
			p_node = Highest_priority.p_node,
		} -- last length
		
	end
	
	while not goal do
		
		table.sort(Priority,function(a,b)
			return a.cost < b.cost
		end)
		
		for i = 1,5 do -- do the top 3 lowest priority ( sorted by lowest )
			
			if #Priority == 0 then
				
				-- there were no paths to explore ( no path possible )
				
				return {}
				
			end
			
			Expand(Priority[1])
			
			table.remove(Priority,1) -- remove from the table
			
		end
		
	end
	
	Expand(Priority[1])
	
	local Reverse_path = {}
	
	if Visited[node_b] then
		warn("NODE_B WAS VISITED")
	end
	
	local Last_pnode = Visited[node_b] or Checked[node_b]
	
	Last_pnode = Last_pnode.p_node -- cant use the table
	
	table.insert(Reverse_path,node_b)
	
	local copy_list = {}
	
	repeat -- create reverse path
		
		Last_pnode = Visited[Last_pnode].p_node
		
		table.insert(Reverse_path,Last_pnode)
		
	until Last_pnode == node_a -- i think this means it doesnt inclue node_a
	
	local Path = {}
	
	for i = #Reverse_path,1,-1 do
		table.insert(Path,Reverse_path[i])
	end
	
	return Path
	
end