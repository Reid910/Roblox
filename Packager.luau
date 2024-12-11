local Packager = {}
local Modules = {}

function Packager.Add(Module)
	if Module:IsA("ModuleScript") then
		local Required = require(Module)
		local Name = Required.Name or Module.Name
		if not Modules[Name] then
			Modules[Name] = Required
		else
			warn(`{Name} is Already a Package.`)
		end
	end
end

function Packager.AddDeep(Object)
	Packager.Add(Object)
	for _,Module in Object:GetDescendants() do
		Packager.Add(Module)
	end
end

function Packager.Start()
	
	table.freeze(Modules)
	
	for _,Module in Modules do
		if Module.Init then
			Module.Init()
			Module.Init = nil
		end
	end
	
	for _,Module in Modules do
		if Module.Start then
			Module.Start()
			Module.Start = nil
		end
	end
	
	print("Started all Packages.")
	
end

function Packager.Get(ModuleName)
	local Module = Modules[ModuleName]
	if not Module then
		warn(`No Package Named "{ModuleName}" {debug.traceback(nil, 2)}.`)
	else
		return Module
	end
end

table.freeze(Packager)

return Packager
