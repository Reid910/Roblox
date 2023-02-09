local TestBlock = game.Workspace.TestBlock

local Mouse = game.Players.LocalPlayer:GetMouse()
Mouse.TargetFilter = game.Workspace

local CC = game.Workspace.CurrentCamera

local m = {
	Character = nil
}

function ZeroY(Vector,Y)
	return Vector3.new(Vector.X,Y or 0,Vector.Z)
end

function m.Update(Delta)
	
	if m.Character then
		
		-- gets the mouse position
		
		local MouseOffset = Mouse.Hit.Position
		
		CC.CameraType = Enum.CameraType.Scriptable -- need(s) this
		
		local plr_position = m.Character.PrimaryPart.Position
		
		local Target_Position = plr_position
		
		local Camera_position = Target_Position + Vector3.new(-15,35,-15)
		
		-- camera position is the offest + the player position
		
		MouseOffset -= Camera_position -- needs to be the vector from the camera
		-- ( was getting worse the further away from 0,0 i was )
		
		MouseOffset = MouseOffset.Unit -- make sure its .unit
		
		local UnitMultiplier = Camera_position.Y / MouseOffset.Y
		
		MouseOffset *= -UnitMultiplier -- Negative takes away from the total ( so we can add later ( setting y to 0 ) )
		
		local lp = 2/MouseOffset.Magnitude
		
		MouseOffset += Camera_position -- add to the negative offset to get 0y
		
		CC.CFrame = CC.CFrame:Lerp(CFrame.new(Camera_position,Target_Position:Lerp(MouseOffset,lp)),5*Delta)
		
		m.Character:PivotTo(
			m.Character.PrimaryPart.CFrame:Lerp(
				CFrame.new(plr_position,ZeroY(MouseOffset,plr_position.Y)),0.3
			)
		)
		
		TestBlock.Position = MouseOffset
		
	end
	
end

return m
