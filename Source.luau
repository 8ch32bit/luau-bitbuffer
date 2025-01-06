--// Author: 8ch99
--// A basic BitBuffer OOP module that utilizes roblox's buffer objects, supports many built in roblox types

--!native
--!optimize 2

--// Localsss

local buffer_create = buffer.create
local buffer_fromstring = buffer.fromstring
local buffer_tostring = buffer.tostring
local buffer_len = buffer.len

local buffer_readi16 = buffer.readi16
local buffer_readi32 = buffer.readi32
local buffer_writei16 = buffer.writei16
local buffer_writei32 = buffer.writei32

local buffer_readu8 = buffer.readu8
local buffer_readu16 = buffer.readu16
local buffer_readu32 = buffer.readu32
local buffer_readf32 = buffer.readf32
local buffer_readf64 = buffer.readf64
local buffer_writeu8 = buffer.writeu8
local buffer_writeu16 = buffer.writeu16
local buffer_writeu32 = buffer.writeu32
local buffer_writef32 = buffer.writef32
local buffer_writef64 = buffer.writef64

local buffer_readstring = buffer.readstring
local buffer_writestring = buffer.writestring

local table_insert = table.insert
local table_unpack = table.unpack
local table_clear = table.clear

local string_sub = string.sub
local string_upper = string.upper

local Signatures = {
	null = 0,
	--// supported lua types
	string = 1,
	number = 2,
	boolean = 3,
	--// supported luau types
	Color3 = 4,
	Vector2 = 5,
	Vector2int16 = 6,
	Vector3 = 7,
	Vector3int16 = 8,
	CFrame = 9,
	Region3 = 10,
	Region3int16 = 11,
	BrickColor = 12,
	Ray = 13,
	UDim = 14,
	UDim2 = 15,
}

local ReverseSignatures = {
	[0] = "null",
	--// supported lua types
	"string",
	"number",
	"boolean",
	--// supported luau types
	"Color3",
	"Vector2",
	"Vector2int16",
	"Vector3",
	"Vector3int16",
	"CFrame",
	"Region3",
	"Region3int16",
	"BrickColor",
	"Ray",
	"UDim",
	"UDim2",
}

--// @class BitBuffer

local BitBuffer = {}
BitBuffer.__index = BitBuffer

--// CONSTRUCTORS

function BitBuffer.new(Size: number?)
	Size = Size or 65536
	local self = setmetatable({}, BitBuffer)
	self.Size = 0
	self.Buffer = buffer_create(Size)
	return self
end

function BitBuffer.fromBuffer(Buffer: buffer)
	local self = setmetatable({}, BitBuffer)
	self.Buffer = Buffer
	self.Size = buffer_len(Buffer)
	return self
end

function BitBuffer.fromString(String: String)
	local self = setmetatable({}, BitBuffer)
	self.Buffer = buffer_fromstring(String)
	self.Size = buffer_len(self.Buffer)
	return self
end

--// object functions

function BitBuffer:Clone()
	local Clone = BitBuffer.new()
	Clone:WriteString(self:ToString())
	return Clone
end

function BitBuffer:Destroy()
	table_clear(self)
	setmetatable(self, nil)
end

function BitBuffer:Clear()
	self.Size = 0
	self.Buffer = buffer_create(65536)
end

function BitBuffer:GetBuffer()
	return self.Buffer
end

function BitBuffer:GetPosition()
	return self.Position
end

function BitBuffer:GetSize()
	return self.Size
end

function BitBuffer:ToString()
	return string_sub(buffer_tostring(self.Buffer), 1, self.Size)
end

--// RAW READ FUNCTIONS

--// Roblox doesnt have readu64.
function BitBuffer:ReadUINT64(Position: number): (number, number)
	local Buffer = self.Buffer
	return (buffer_readu32(Buffer, Position) * (2 ^ 32)) + buffer_readu32(Buffer, Position + 4)
end

--// RAW WRITE FUNCTIONS

--// Roblox doesnt have writeu64.
function BitBuffer:WriteUINT64(Value: number): number
	local Buffer = self.Buffer
	local Size = self.Size
	buffer_writeu32(Buffer, Size, Value // (2 ^ 32))
	buffer_writeu32(Buffer, Size + 4, Value % (2 ^ 32))
	return Size
end

function BitBuffer:WriteNil(): number
	local Buffer = self.Buffer
	local Size = self.Size
	buffer_writeu8(Buffer, Size, Signatures.null)
	return Size
end

--// READ FUNCTIONS
--// Read functions return the extracted value found, and the offset (which is used in the Deserialize function)

function BitBuffer:ReadString(Position: number): (string, number)
	local Buffer = self.Buffer
	local Length = buffer_readu32(Buffer, Position)
	return buffer_readstring(Buffer, Position + 4, Length), Length + 4
end

function BitBuffer:ReadNumber(Position: number): (number, number)
	return buffer_readf64(self.Buffer, Position), 8
end

--// booleans unfortunately cant be stored as 1 bit, so its stored as an uint8 instead
function BitBuffer:ReadBoolean(Position: number): (boolean, number)
	return buffer_readu8(self.Buffer, Position) ~= 0, 1
end

function BitBuffer:ReadColor3(Position: number): (Color3, number)
	local Buffer = self.Buffer
	local R = buffer_readf64(Buffer, Position)
	local G = buffer_readf64(Buffer, Position + 8)
	local B = buffer_readf64(Buffer, Position + 16)
	return Color3.new(R, G, B), 24
end

function BitBuffer:ReadVector2(Position: number): (Vector2, number)
	local Buffer = self.Buffer
	local X = buffer_readf64(Buffer, Position)
	local Y = buffer_readf64(Buffer, Position + 8)
	return Vector2.new(X, Y), 16
end

function BitBuffer:ReadVector2int16(Position: number): (Vector2int16, number)
	local Buffer = self.Buffer
	local X = buffer_readi16(Buffer, Position)
	local Y = buffer_readi16(Buffer, Position + 2)
	return Vector2int16.new(X, Y), 4
end

function BitBuffer:ReadVector3(Position: number): (Vector3, number)
	local Buffer = self.Buffer
	local X = buffer_readf64(Buffer, Position)
	local Y = buffer_readf64(Buffer, Position + 8)
	local Z = buffer_readf64(Buffer, Position + 16)
	return Vector3.new(X, Y, Z), 24
end

function BitBuffer:ReadVector3int16(Position: number): (Vector3int16, number)
	local Buffer = self.Buffer
	local X = buffer_readi16(Buffer, Position)
	local Y = buffer_readi16(Buffer, Position + 2)
	local Z = buffer_readi16(Buffer, Position + 4)
	return Vector3int16.new(X, Y, Z), 6
end

function BitBuffer:ReadCFrame(Position: number): (CFrame, number)
	local Buffer = self.Buffer
	local CFPosition = self:ReadVector3(Position)
	local XVector = self:ReadVector3(Position + 24)
	local YVector = self:ReadVector3(Position + 48)
	local ZVector = self:ReadVector3(Position + 72)
	return CFrame.fromMatrix(CFPosition, XVector, YVector, ZVector), 96
end

function BitBuffer:ReadRegion3(Position: number): (Region3, number)
	local Buffer = self.Buffer
	local Min = self:ReadVector3(Position)
	local Max = self:ReadVector3(Position + 24)
	return Region3.new(Min, Max), 48
end

function BitBuffer:ReadRegion3int16(Position: number): (Region3int16, number)
	local Buffer = self.Buffer
	local Min = self:ReadVector3int16(Position)
	local Max = self:ReadVector3int16(Position + 6)
	return Region3int16.new(Min, Max), 12
end

function BitBuffer:ReadBrickColor(Position: number): (BrickColor, number)
	return BrickColor.new(buffer_readu16(self.Buffer, Position)), 2
end

function BitBuffer:ReadRay(Position: number): (Ray, number)
	local Origin = self:ReadVector3(Position)
	local Direction = self:ReadVector3(Position + 24)
	return Ray.new(Origin, Direction), 48
end

function BitBuffer:ReadUDim(Position: number): (UDim, number)
	local Buffer = self.Buffer
	local Scale = buffer_readf32(Buffer, Position)
	local Offset = buffer_readi32(Buffer, Position + 4)
	return UDim.new(Scale, Offset), 8
end

function BitBuffer:ReadUDim2(Position: number): (UDim2, number)
	local Buffer = self.Buffer
	local XScale = buffer_readf32(Buffer, Position)
	local XOffset = buffer_readi32(Buffer, Position + 4)
	local YScale = buffer_readf32(Buffer, Position + 8)
	local YOffset = buffer_readi32(Buffer, Position + 12)
	return UDim2.new(XScale, XOffset, YScale, YOffset), 16
end

--// WRITE FUNCTIONS
--// Write functions return the position they were written at
--// the ExcludeSignature arg should only be used internally within this module

function BitBuffer:WriteString(String: String, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	local Length = #String
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.string)
		Size += 1
	end
	buffer_writeu32(Buffer, Size, Length)
	buffer_writestring(Buffer, Size + 4, String)
	self.Size = Size + 4 + Length
	return Size
end

function BitBuffer:WriteNumber(Number: number, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.number)
		Size += 1
	end
	buffer_writef64(Buffer, Size, Number)
	self.Size = Size + 8
	return Size
end

--// booleans unfortunately cant be stored as 1 bit, so its stored as an uint8 instead
function BitBuffer:WriteBoolean(Boolean: boolean, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.boolean)
		Size += 1
	end
	buffer_writeu8(Buffer, Size, if Boolean == false then 0 else 1)
	self.Size = Size + 1
	return Size
end

function BitBuffer:WriteColor3(Color: Color3, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.Color3)
		Size += 1
	end
	buffer_writef64(Buffer, Size, Color.R)
	buffer_writef64(Buffer, Size + 8, Color.G)
	buffer_writef64(Buffer, Size + 16, Color.B)
	self.Size = Size + 24
	return Size
end

function BitBuffer:WriteVector2(Vector: Vector2, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.Vector2)
		Size += 1
	end
	buffer_writef64(Buffer, Size, Vector.X)
	buffer_writef64(Buffer, Size + 8, Vector.Y)
	self.Size = Size + 16
	return Size
end

function BitBuffer:WriteVector2int16(Vector: Vector2int16, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.Vector2int16)
		Size += 1
	end
	buffer_writei16(Buffer, Size , Vector.X)
	buffer_writei16(Buffer, Size + 2, Vector.Y)
	self.Size = Size + 4
	return Size
end

function BitBuffer:WriteVector3(Vector: Vector3, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.Vector3)
		Size += 1
	end
	buffer_writef64(Buffer, Size, Vector.X)
	buffer_writef64(Buffer, Size + 8, Vector.Y)
	buffer_writef64(Buffer, Size + 16, Vector.Z)
	self.Size = Size + 24
	return Size
end

function BitBuffer:WriteVector3int16(Vector: Vector3int16, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.Vector3int16)
		Size += 1
	end
	buffer_writei16(Buffer, Size, Vector.X)
	buffer_writei16(Buffer, Size + 2, Vector.Y)
	buffer_writei16(Buffer, Size + 4, Vector.Z)
	self.Size = Size + 6
	return Size
end

function BitBuffer:WriteCFrame(CoordinateFrame: CFrame, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.CFrame)
		Size += 1
		self.Size += 1
	end
	self:WriteVector3(CoordinateFrame.Position, true)
	self:WriteVector3(CoordinateFrame.XVector, true)
	self:WriteVector3(CoordinateFrame.YVector, true)
	self:WriteVector3(CoordinateFrame.ZVector, true)
	return Size
end

function BitBuffer:WriteRegion3(Region: Region3, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.Region3)
		Size += 1
		self.Size += 1
	end
	local CFrame = Region.CFrame
	local HalfSize = Region.Size / 2
	self:WriteVector3(CFrame.Position - HalfSize, true)
	self:WriteVector3(CFrame.Position + HalfSize, true)
	return Size
end

function BitBuffer:WriteRegion3int16(Region: Region3int16, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.Region3int16)
		Size += 1
		self.Size += 1
	end
	self:WriteVector3int16(Region.Min, true)
	self:WriteVector3int16(Region.Max, true)
	return Size
end

function BitBuffer:WriteBrickColor(BrickColor: BrickColor, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.BrickColor)
		Size += 1
	end
	buffer_writeu16(Buffer, Size, BrickColor.Number)
	self.Size = Size + 2
	return Size
end

function BitBuffer:WriteRay(Ray: Ray, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.Ray)
		Size += 1
		self.Size += 1
	end
	self:WriteVector3(Ray.Origin, true)
	self:WriteVector3(Ray.Direction, true)
	return Size
end

function BitBuffer:WriteUDim(UDim: UDim, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.UDim)
		Size += 1
	end
	buffer_writef32(Buffer, Size, UDim.Scale)
	buffer_writei32(Buffer, Size + 4, UDim.Offset)
	self.Size = Size + 8
	return Size
end

function BitBuffer:WriteUDim2(UDim2: UDim2, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	if not ExcludeSignature then
		buffer_writeu8(Buffer, Size, Signatures.UDim2)
		Size += 1
	end
	buffer_writef32(Buffer, Size, UDim2.X.Scale)
	buffer_writei32(Buffer, Size + 4, UDim2.X.Offset)
	buffer_writef32(Buffer, Size + 8, UDim2.Y.Scale)
	buffer_writei32(Buffer, Size + 12, UDim2.Y.Offset)
	self.Size = Size + 16
	return Size
end

--// FULL-SCALE SERIALIZE/DESERIALIZE FUNCTIONS

--// TODO: Serializes an array of items and adds them in order to the bitbuffer
function BitBuffer:Serialize(Data: { any })
	for _, v in ipairs(Data) do
		local Type = typeof(v)
		if Signatures[Type] then
			self[`Write{string.upper(string.sub(Type, 1, 1))}{string.sub(Type, 2, #Type)}`](self, v)
		end
	end
end

--// TODO: Deserializes every value in the bitbuffer
function BitBuffer:Deserialize()
	local Data = {}
	local Position = -1
	local Size = self.Size
	local Buffer = self.Buffer
	while Position <= Size do
		Position += 1
		local Type = buffer_readu8(Buffer, Position)
		if Type == 0 then
			continue
		end
		local TypeValue = Type
		Type = ReverseSignatures[Type]
		if Type then
			local Value, Offset = self[`Read{string.upper(string.sub(Type, 1, 1))}{string.sub(Type, 2, #Type)}`](self, Position + 1)
			Position += Offset
			table_insert(Data, Value)
		else
			warn(`BitBuffer:Serialize(): Unknown type '{TypeValue}'! Canceling deserialization...`)
			return nil
		end
	end
	if #Data > 255 then
		warn("BitBuffer: Data set too large to be localized, returning table instead")
		return Data
	end
	return table_unpack(Data)
end

return BitBuffer
