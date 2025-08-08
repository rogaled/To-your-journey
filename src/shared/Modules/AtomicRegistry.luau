local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

return {
	Components = require(Modules.Components),
	Packages = require(Modules.Packages),
}

