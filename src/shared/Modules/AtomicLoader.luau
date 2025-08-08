--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = ReplicatedStorage.Modules.Types
local MiscTypes = require(Types.MiscTypes)

local function RequireModule(ModuleScript: ModuleScript): Module?
	if ModuleScript == script then
		return nil -- Prevent requiring the loader itself
	end

	local Success, Result = pcall(require, ModuleScript)

	if Success then
		return Result
	end

	warn("Failed to require:", ModuleScript.Name, "|", Result)
	return nil
end

local Loader = {} :: Loader
Loader.__index = Loader

function Loader.new()
	local self = setmetatable({}, Loader) :: any
	self.Registry = {}
	return self
end

function Loader:Collect(ModuleScript: ModuleScript | nil)
	if ModuleScript == nil or not ModuleScript:IsA("ModuleScript") then
		error("Expected ModuleScript, got: " .. typeof(ModuleScript))
	end

	local Module: Module? = RequireModule(ModuleScript)

	if not Module then
		return
	end

	local Entry: ModuleEntry = {
		Name = ModuleScript.Name,
		Module = Module,
	}

	self.Registry[ModuleScript.Name] = Entry
end

function Loader:Initialize()
	for _, Entry: ModuleEntry in self.Registry do
		if Entry.Initialized then
			continue -- Skip if already initialized
		end

		local Module: Module = Entry.Module
		local Init = Module.Initialize or Module.Init

		if Init then
			Init()
		end

		Entry.Initialized = true
	end
end

function Loader:Start()
	for _, Entry: ModuleEntry in self.Registry do
		if not Entry.Initialized then
			warn("Module not initialized:", Entry.Name)
			continue -- Skip if not initialized
		end

		if Entry.Started then
			continue -- Skip if already started
		end

		local Module: Module = Entry.Module
		local Start = Module.Start

		if Start then
			Start()
		end

		Entry.Started = true
	end
end

type Module = MiscTypes.Module

type Loader = {
	__index: Loader,
	new: () -> Loader,
	Registry: { [any]: ModuleEntry },
	Collect: (self: Loader) -> (),
	Initialize: (self: Loader) -> (),
	Start: (self: Loader) -> (),
}

type ModuleEntry = {
	Name: string,
	Initialized: boolean?,
	Started: boolean?,
	Module: Module,
	Tags: { string }?,
}

return Loader
