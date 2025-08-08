local function RequireModule(ModuleScript: ModuleScript)
	if ModuleScript == script then
		return -- Prevent requiring the loader itself
	end

	local Success, Result = pcall(require, ModuleScript)

	if Success then
		local Init, Start = Result.Initialize or Result.Init, Result.Start
		print(Init, Start)
		return Result, Init, Start
	end

	warn("Failed to require:", ModuleScript.Name, "|", Result)
end

local function CollectModules(Root: Instance, Registry: table)
	local InitCache, StartCache = {}, {}

	for _, Child: Folder | ModuleScript in Root:GetChildren() do
		local Name = Child.Name

		if not Name:sub(1, 1):match("%a") then
			warn(Name)
			continue
		end

		if Child:IsA("ModuleScript") then
			local Module, Init, Start = RequireModule(Child)

			if not Module then
				continue
			end

			Registry[Name] = Module

			InitCache[Name], StartCache[Name] = Init, Start
		else
			Registry[Name] = {}

			local SubInitCache, SubStartCache = CollectModules(Child, Registry[Name])
		end
	end

	return Registry, InitCache, StartCache
end

-- Requires all modules in the provided root and stores them in an object styled interface
-- Depedancy hell begone!

local Loader = {}
Loader.__index = Loader

function Loader.GetRegistry(Root: Instance)
	local self = setmetatable({}, Loader)

	local Registry, InitQueue, StartQueue = CollectModules(Root, {})

	self.Registry = Registry
	self.InitQueue = InitQueue
	self.StartQueue = StartQueue

	self.UnSorted, self.Sorted = {}, {}

	task.spawn(function()
		while true do
			task.wait(1)
			print(self)
		end
	end)

	return self
end

function Loader:Schedule(Name: string, Config: table | nil)
	if not Config or not Config.Dependencies or #Config.Dependencies == 0 then
		table.insert(self.Sorted, 1, { Name = Name })
		return
	end

	local InsertIndex = #self.Sorted + 1

	for Index, ScheduleData in self.Sorted do
		for _, Depedancy in Config.Dependencies do
			if ScheduleData.Name == Depedancy then
				InsertIndex = math.max(InsertIndex, Index + 1)
			end
		end
	end

	table.insert(self.Sorted, InsertIndex, { Name = Name })
end

function Loader:Initialize()
	for Name, Init in self.InitQueue do
		local Success, Output = pcall(Init)

		if Success then
			self:Schedule(Name, Output)
			continue
		end
		warn("Failed to initialize:", Name, Output)
	end
end

function Loader:Start() end

return Loader
