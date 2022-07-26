local RunService = game:GetService("RunService")

local list_of_tests = {}

local function test_obj(Name) -- 
	local p = Instance.new("Part")
	p.Name = Name
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Size = Vector3.new(5,5,5)
	p.Parent = game.Workspace
	return p
end

local Player = game.Players.LocalPlayer -- you could probaly leave this out if you are on server

-- you can just edit the pets with these numbers below lol

local Number_of_objects = 100

local distance_to_player = 3

local space_between_rows = 7

local space_between_pets = 6

local objects_per_row = 8

for i = 1,Number_of_objects do -- creates 5 test parts ( we can use these to test the rows math )
	table.insert(list_of_tests,test_obj(i))
end

RunService.RenderStepped:Connect(function(Delta)

	local char = Player.Character

	if not char then
		return
	end

	local lookvector = char.PrimaryPart.CFrame.LookVector

	local Charlocation = char.PrimaryPart.CFrame.Position

	local behind_player = -lookvector

	-- lets get a left and a right vector ( so we can move the pets left and right )

	local right_vector = char.PrimaryPart.CFrame.RightVector

	-- I also learned a thing... I dont need to do any of the tricky math LOL

	-- i usually set the base position ( behind player ) to the ground and you can increase the distance to the player:

	local base_petlocation = Charlocation
	base_petlocation += Vector3.new(behind_player.X * distance_to_player, behind_player.Y + 1, behind_player.Z * distance_to_player)
	-- still ~0.5y above the ground ( you can move the y value up / down by adding or subtracting from behind_player.Y )

	local Row_offset = objects_per_row % 2 == 0 and -right_vector * space_between_pets / 2 or Vector3.new(0,0,0)
	-- only add offset if Even ( otherwise its 0 )

	local Complete_left = (-right_vector * objects_per_row / 2 * space_between_pets) + base_petlocation + Row_offset

	local rows = math.floor(#list_of_tests/objects_per_row+0.5) -- 2 in this case 5/3 = 1.66 or something 1.66+0.5 = 2.1 -- floored = 2

	for i,obj in pairs(list_of_tests) do -- if you really wanted to you could make this math change based on how many are equipped
		-- so it looks good when you only have 1, 2, 3, 4 pets ( i mean it looks okay right now, but it looks odd with one tbh )

		local row = i % objects_per_row == 0 and i/objects_per_row or math.floor(i/objects_per_row)+1

		local object_number = i % objects_per_row
		object_number = object_number == 0 and objects_per_row or object_number

		local pet_position = Complete_left + (behind_player * row * space_between_rows) + (right_vector * space_between_pets * object_number)
		-- ( complete left + row vector + the position in the row)

		--obj.CFrame = obj.CFrame:Lerp( CFrame.new(pet_position,pet_position+lookvector), 0.9*Delta*5 )

		-- or you can use obj:SetPrimaryPartCFrame() for models ( you dont need tweens or anything :P )
		
		
		
		-- check if we are the last row
		
		local pets_left = object_number + (#list_of_tests - i) -- we are going to get the item we are in the row ( 2 for example )
		
		-- 2 + the remaining items in the pet system = items_left
		
		if pets_left <= objects_per_row then
			-- this is the last row
			
			-- the number of objects in the last row is pets_left
			
			pet_position += right_vector * space_between_pets * (objects_per_row - pets_left) / 2
			
			-- we divide by 2 because it would just move to the right instead of shifting to the middle
			
		end
		
		obj.CFrame = obj.CFrame:Lerp( CFrame.new(pet_position,pet_position+lookvector), 0.9*Delta*5 )
		
	end
end)
