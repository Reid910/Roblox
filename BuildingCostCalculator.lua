local m = require(game:GetService("ReplicatedStorage").Data)

local levelmilestones = {25,35,50} -- {25,35,50,75,100,115,130,150}

local List_of_milestone_values = {} -- it is much faster to print 1 time and see all of the values
-- ( or just faster to add to a table instead of printing each loop )
-- if this doesnt work for you un comment the function at the bottom

for i,v in pairs(m.UpgradeData) do -- 9 loops
	
	List_of_milestone_values[v[1]] = {}
	
	local Type_data = List_of_milestone_values[v[1]]
	
	for _,level in pairs(levelmilestones) do -- 8 loops
		
		-- 9 * 8 = 72 ( we need this to run faster because it is very very slow...)
		-- 72 * 25 at minimum is 1800 ( we are looping through this 1800+ times ( THERES A LOT MORE FOR 150!!) )
		-- i meant 25 loops for the first milestone ( they all do it right here )
		local sum = 0
		for i = 1,level do
			sum += math.floor(1.15 ^ (i-1) * v[2])
		end
		
		print(level,sum,v[1])
		
		-- v[2] * ( 1 + 1.15 ) ^ level
		
		-- v[2] * (1.15 ^ 1 + 2) -- this is me trying to figure out how to calculate the max cost with a one line math problem lmao
		
		-- n * ( n + 1 ) / 2
		
		--local sum = math.floor( v[2] * ( math.pow( 1.15 , sum_to_lvl ) ) )
		
		local sum = 0
		for i = 1,level do -- still using a loop ( trying to calculate out of it )
			sum += math.pow(1.15,i-1)
		end
		sum *= v[2] -- 35 or base for clickers
		
		warn(level,sum,v[1])
		
		-- trying a different thing
		
		-- SUM OF NUMBERS TO LEVEL = level * ( level + 1 ) / 2
		
		local sum_to_lvl = level * ( level + 1 ) / 2
		
		local highest_pow = math.pow(1.15,level-1)
		
		--local sum =  v[2] * math.pow( 1 + 1.15 , sum_to_lvl / math.pow(level,2) )
		
		local sum =  v[2] * highest_pow * (highest_pow + 1) / 2 -- this is the closest ive gotten
		
		warn(level,sum,v[1])
		
		-- instead of looping to find e ( use log base 10 ) -- loops cause lag math causes speed and efficency
		
		local e = math.floor( math.log10(sum) )
		sum /= math.pow(10,e)
		--while sum > 10 do
		--	sum /= 10
		--	e += 1
		--end -- remove this commented area after reading everything
		sum = math.floor(sum*10)/10
		
		--print("Level: " .. level .." ".. v[1] .. ", Costs: " .. sum .. "e" .. e) -- in other words dont do this ( if you can prevent it )
		
		-- instead we can add our data to list of milestones and print it from there
		
		table.insert(Type_data, " - " .. level .. " = " .. sum .. "e" .. e)
		
	end
	
end

-- printing out all at once is pretty nice
for Name,Upgrade in pairs(List_of_milestone_values) do
	
	local Str = "\n"
	
	for __,level in pairs(Upgrade) do
		
		Str ..= Name .. level .. "\n" -- \n is next line
		
	end
	
	print(Str) -- one print per upgrade type ( much better than 72 ) -- but it is a lot more code to do so
	
end

--print(List_of_milestone_values)