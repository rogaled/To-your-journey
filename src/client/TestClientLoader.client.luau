local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedLoader = require(ReplicatedStorage.Modules.SharedLoader)

local Registery: foo = SharedLoader.GetRegistry(ReplicatedStorage.Modules)
print(Registery)

Registery:Initialize()

export type foo = {
	Foo: number,
	Bar: string,
	Baz: Enum,
}
