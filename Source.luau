--// Author: 8ch99
--// A basic BitBuffer OOP module that utilizes roblox's buffer objects, supports many built in roblox types

--[[

MIT License

Copyright (c) 2025 8ch99

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]

--!native
--!optimize 2

--// Dependencies

local buffer_create = buffer.create
local buffer_copy = buffer.copy
local buffer_fromstring = buffer.fromstring
local buffer_tostring = buffer.tostring
local buffer_len = buffer.len

local buffer_readbits = buffer.readbits
local buffer_writebits = buffer.writebits

local buffer_readf32 = buffer.readf32
local buffer_readf64 = buffer.readf64
local buffer_writef32 = buffer.writef32
local buffer_writef64 = buffer.writef64

local buffer_readi8 = buffer.readi8
local buffer_readi16 = buffer.readi16
local buffer_readi32 = buffer.readi32
local buffer_writei8 = buffer.writei8
local buffer_writei16 = buffer.writei16
local buffer_writei32 = buffer.writei32

local buffer_readstring = buffer.readstring
local buffer_writestring = buffer.writestring

local table_insert = table.insert
local table_unpack = table.unpack
local table_clear = table.clear

local string_sub = string.sub
local string_upper = string.upper
local string_char = string.char
local string_byte = string.byte

--// @module Bitsets
--// Because we are working with bits completely, we have to improvise some functions
--// writef64 as an example, already exists for us, but uses bytes for the index
--// We create a new buffer with the read bits, and read an f64 from that new buffer
--// Most integer stuff (unsigned) can just be done with readbits directly up to 32 bits
--// This allows for more easy bit reading/writing

local Bitsets = {}

--// Read functions

function Bitsets.ReadBit(Buffer: buffer, BitOffset: number)
	return buffer_readbits(Buffer, BitOffset, 1)
end

function Bitsets.ReadUInt4(Buffer: buffer, BitOffset: number)
	return buffer_readbits(Buffer, BitOffset, 4)
end

function Bitsets.ReadUInt8(Buffer: buffer, BitOffset: number)
	return buffer_readbits(Buffer, BitOffset, 8)
end

function Bitsets.ReadUInt16(Buffer: buffer, BitOffset: number)
	return buffer_readbits(Buffer, BitOffset, 16)
end

function Bitsets.ReadUInt32(Buffer: buffer, BitOffset: number)
	return buffer_readbits(Buffer, BitOffset, 32)
end

function Bitsets.ReadInt8(Buffer: buffer, BitOffset: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		return buffer_readi8(Buffer, BitOffset // 8)
	end
	
	local IntBuffer = buffer_create(1)
	
	buffer_writebits(IntBuffer, 0, 8, buffer_readbits(Buffer, BitOffset, 8))
	
	IntBuffer = nil
	
	return buffer_readi8(IntBuffer, 0)
end

function Bitsets.ReadInt16(Buffer: buffer, BitOffset: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		return buffer_readi16(Buffer, BitOffset // 8)
	end
	
	local IntBuffer = buffer_create(2)
	
	buffer_writebits(IntBuffer, 0, 16, buffer_readbits(Buffer, BitOffset, 16))
	
	IntBuffer = nil
	
	return buffer_readi16(IntBuffer, 0)
end

function Bitsets.ReadInt32(Buffer: buffer, BitOffset: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		return buffer_readi32(Buffer, BitOffset // 8)
	end
	
	local IntBuffer = buffer_create(4)
	
	buffer_writebits(IntBuffer, 0, 32, buffer_readbits(Buffer, BitOffset, 32))
	
	IntBuffer = nil
	
	return buffer_readi32(IntBuffer, 0)
end

function Bitsets.ReadFloat(Buffer: buffer, BitOffset: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		return buffer_readf32(Buffer, BitOffset // 8)
	end
	
	local FloatBuffer = buffer_create(4)
	
	buffer_writebits(FloatBuffer, 0, 32, buffer_readbits(Buffer, BitOffset, 32))
	
	FloatBuffer = nil
	
	return buffer_readf32(FloatBuffer, 0)
end

function Bitsets.ReadDouble(Buffer: buffer, BitOffset: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		return buffer_readf64(Buffer, BitOffset // 8)
	end
	
	local FloatBuffer = buffer_create(8)
	
	buffer_writebits(FloatBuffer, 0, 32, buffer_readbits(Buffer, BitOffset, 32))
	buffer_writebits(FloatBuffer, 32, 32, buffer_readbits(Buffer, BitOffset + 32, 32))
	
	FloatBuffer = nil
	
	return buffer_readf64(FloatBuffer, 0)
end

function Bitsets.ReadBoolean(Buffer, BitOffset: number)
	return buffer_readbits(Buffer, BitOffset, 1) ~= 0
end

function Bitsets.ReadString(Buffer: buffer, BitOffset: number, Length: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		return buffer_readstring(Buffer, BitOffset // 8, Length)
	end
	
	local Characters = {}

	for i = 0, Length - 1 do
		table_insert(Characters, buffer_readbits(Buffer, BitOffset + (i * 8), 8))
	end

	return string_char(table_unpack(Characters))
end

--// Write functions

function Bitsets.WriteBit(Buffer: buffer, BitOffset: number, Value: number)
	buffer_writebits(Buffer, BitOffset, 1, Value)
	return BitOffset
end

function Bitsets.WriteUInt4(Buffer: buffer, BitOffset: number, Value: number)
	buffer_writebits(Buffer, BitOffset, 4, Value)
	return BitOffset
end

function Bitsets.WriteUInt8(Buffer: buffer, BitOffset: number, Value: number)
	buffer_writebits(Buffer, BitOffset, 8, Value)
	return BitOffset
end

function Bitsets.WriteUInt16(Buffer: buffer, BitOffset: number, Value: number)
	buffer_writebits(Buffer, BitOffset, 16, Value)
	return BitOffset
end

function Bitsets.WriteUInt32(Buffer: buffer, BitOffset: number, Value: number)
	buffer_writebits(Buffer, BitOffset, 32, Value)
	return BitOffset
end

function Bitsets.WriteInt8(Buffer: buffer, BitOffset: number, Value: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		buffer_writei8(Buffer, BitOffset // 8, Value)
		return BitOffset
	end
	
	local IntBuffer = buffer_create(1)
	
	buffer_writei8(IntBuffer, 0, Value)
	buffer_writebits(Buffer, BitOffset, 8, buffer_readbits(IntBuffer, 0, 8))
	
	IntBuffer = nil
	
	return BitOffset
end

function Bitsets.WriteInt16(Buffer: buffer, BitOffset: number, Value: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		buffer_writei16(Buffer, BitOffset // 8, Value)
		return BitOffset
	end
	
	local IntBuffer = buffer_create(2)
	
	buffer_writei16(IntBuffer, 0, Value)
	buffer_writebits(Buffer, BitOffset, 16, buffer_readbits(IntBuffer, 0, 16))
	
	IntBuffer = nil
	
	return BitOffset
end

function Bitsets.WriteInt32(Buffer: buffer, BitOffset: number, Value: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		buffer_writei32(Buffer, BitOffset // 8, Value)
		return BitOffset
	end
	
	local IntBuffer = buffer_create(4)
	
	buffer_writei16(IntBuffer, 0, Value)
	buffer_writebits(Buffer, BitOffset, 32, buffer_readbits(IntBuffer, 0, 32))
	
	IntBuffer = nil
	
	return BitOffset
end

function Bitsets.WriteFloat(Buffer: buffer, BitOffset: number, Value: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		buffer_writef32(Buffer, BitOffset // 8, Value)
		return BitOffset
	end
	
	local FloatBuffer = buffer_create(4)
	
	buffer_writef32(FloatBuffer, 0, Value)
	buffer_writebits(Buffer, BitOffset, 32, buffer_readbits(FloatBuffer, 0, 32))
	
	FloatBuffer = nil
	
	return BitOffset
end

function Bitsets.WriteDouble(Buffer: buffer, BitOffset: number, Value: number)
	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		buffer_writef64(Buffer, BitOffset // 8, Value)
		return BitOffset
	end
	
	local FloatBuffer = buffer_create(8)
	
	buffer_writef64(FloatBuffer, 0, Value)
	buffer_writebits(Buffer, BitOffset, 32, buffer_readbits(FloatBuffer, 0, 32))
	buffer_writebits(Buffer, BitOffset + 32, 32, buffer_readbits(FloatBuffer, 32, 32))
	
	FloatBuffer = nil
	
	return BitOffset
end

function Bitsets.WriteBoolean(Buffer: buffer, BitOffset: number, Value: boolean)
	buffer_writebits(Buffer, BitOffset, 1, if Value then 1 else 0)
	return BitOffset
end

function Bitsets.WriteString(Buffer: buffer, BitOffset: number, Value: string)
	local Length = #Value

	if BitOffset % 8 == 0 then --// Should hopefully save a bit of performance
		buffer_writestring(Buffer, BitOffset // 8, Value, Length)
		return BitOffset, Length * 8
	end

	--// unfortunately, sometimes we just gotta resort to this
	for i = 1, Length do
		buffer_writebits(Buffer, BitOffset + ((i - 1) * 8), 8, string_byte(Value, i, i))
	end

	return BitOffset, Length * 8
end

local ReverseSignatures = {
	[0] = "null",
	--// supported standard lua/luau types
	"string",
	"number",
	"boolean",
	"vector",
	--// supported luau types
	"Color3",
	"Vector2",
	"Vector2int16",
	--// no Vector3, because "vector" is redundant to Vector3
	"Vector3int16",
	"CFrame",
	"Region3",
	"Region3int16",
	"BrickColor",
	"Ray",
	"UDim",
	"UDim2",
	"TweenInfo",
	"Axes",
}

--// Setup Signatures and PascalCasedSignatures
--// PascalCasedSignatures is for some CPU benefit from deserializing/serializing at the expense of a tiny bit of memory

local Signatures = {}
local PascalCasedSignatures = {}

for Index, Signature in ReverseSignatures do
	Signatures[Signature] = Index
	PascalCasedSignatures[Index] = `{string_upper(string_sub(Signature, 1, 1))}{string_sub(Signature, 2, #Signature)}`
end

--// @class BitBuffer

local BitBuffer = {}
BitBuffer.__index = BitBuffer
BitBuffer.Size = 0

function BitBuffer.new(Bytes: number?)
	return setmetatable({ Buffer = buffer_create(Bytes) }, BitBuffer)
end

function BitBuffer.fromBuffer(Buffer: buffer, Size: number?)
	local self = setmetatable({}, BitBuffer)
	self.Buffer = Buffer
	self.Size = Size or (buffer_len(Buffer) * 8)
	return self
end

function BitBuffer.fromString(String: String)
	return BitBuffer.fromBuffer(buffer_fromstring(String), #String * 8)
end

function BitBuffer.fromDataSet(Data: { any }, Size: number?)
	local Buffer = BitBuffer.new(Size)
	Buffer:Serialize(Data)
	return Buffer
end

function BitBuffer:Destroy()
	table_clear(self)
	setmetatable(self, nil)
end

function BitBuffer:Clone()
	local Size = self.Size
	local Buffer = buffer_create(Size)
	
	buffer_copy(Buffer, 0, self.Buffer)
	
	return BitBuffer.fromBuffer(Buffer, Size)
end

function BitBuffer:GetBuffer()
	return self.Buffer
end

function BitBuffer:GetSize()
	return self.Size
end

function BitBuffer:GetSizeInBytes()
	return math.ceil(self.Size) --// if theres 1 extra bit written, theres always 1 extra byte allocated for it, thats why we use ceil
end

function BitBuffer:ToString()
	return string_sub(buffer_tostring(self.Buffer), 1, self.Size // 8)
end

--// TODO: Serializes an array of items and adds them in order to the bitbuffer
function BitBuffer:Serialize(Data: { any })
	for _, v in ipairs(Data) do
		local Type = typeof(v)
		local Index = Signatures[Type]
		
		if Index then
			self[`Write{PascalCasedSignatures[Index]}`](self, v)
		end
	end
end

--// TODO: Serializes an array of items, all of the same and adds them in order to the bitbuffer
--// This should be used over :Serialize() if you are only serializing one type and need more performance
function BitBuffer:SerializeType(Type: string, Data: { any })
	local Index = Signatures[Type]
	
	if Index then
		local Function = self[`Write{PascalCasedSignatures[Index]}`]
		
		for _, v in ipairs(Data) do
			Function(self, v)
		end
	end
end

--// TODO: Deserializes every value in the bitbuffer and returns them
function BitBuffer:Deserialize(NoUnpack: boolean?, Function: (number) -> boolean?)
	local Data = {}
	local Position = -8
	
	local Size = self.Size
	local Buffer = self.Buffer
	
	while Position <= Size do
		Position += 8
		
		if Function and not Function(Position) then
			break
		end
		
		local Type = Bitsets.ReadUInt8(Buffer, Position)
		
		if Type == 0 then
			--continue
			break
		end
		
		local TypeValue = Type
		Type = ReverseSignatures[Type]
		
		if Type then
			local Value, Offset = self[`Read{PascalCasedSignatures[TypeValue]}`](self, Position + 8)
			table_insert(Data, Value)
			
			Position += Offset
		else
			warn(`BitBuffer:Serialize(): Unknown type '{TypeValue}'! Canceling deserialization...`)
			return
		end
	end
	
	if NoUnpack == true then
		return Data
	end
	
	return table_unpack(Data)
end

--// READ FUNCTIONS
--// Read functions return the extracted value found, and the offset (which is used in the Deserialize function)

function BitBuffer:ReadBit(Position: number)
	return buffer_readbits(self.Buffer, Position, 1)
end

function BitBuffer:ReadBits(Position: number, Amount: number)
	return buffer_readbits(self.Buffer, Position, Amount)
end

function BitBuffer:ReadBitsFromStartAndEnd(Start: number, End: number)
	return buffer_readbits(self.Buffer, Start, End - Start)
end

function BitBuffer:ReadString(Position: number): (string, number)
	local Buffer = self.Buffer
	local Length = Bitsets.ReadUInt32(Buffer, Position)
	
	return Bitsets.ReadString(Buffer, Position + 32, Length), 32 + (Length * 8)
end

function BitBuffer:ReadNumber(Position: number): (number, number)
	return Bitsets.ReadDouble(self.Buffer, Position), 64
end

function BitBuffer:ReadBoolean(Position: number): (boolean, number)
	return Bitsets.ReadBit(self.Buffer, Position) ~= 0, 1
end

function BitBuffer:ReadVector(Position: number): (vector, number)
	local Buffer = self.Buffer
	
	local X = Bitsets.ReadDouble(Buffer, Position)
	local Y = Bitsets.ReadDouble(Buffer, Position + 64)
	local Z = Bitsets.ReadDouble(Buffer, Position + 128)
	
	return vector.create(X, Y, Z), 192
end

function BitBuffer:ReadColor3(Position: number): (Color3, number)
	local Buffer = self.Buffer
	
	local R = Bitsets.ReadDouble(Buffer, Position)
	local G = Bitsets.ReadDouble(Buffer, Position + 64)
	local B = Bitsets.ReadDouble(Buffer, Position + 128)
	
	return Color3.new(R, G, B), 192
end

function BitBuffer:ReadVector2(Position: number): (Vector2, number)
	local Buffer = self.Buffer
	
	local X = Bitsets.ReadDouble(Buffer, Position)
	local Y = Bitsets.ReadDouble(Buffer, Position + 64)
	
	return Vector2.new(X, Y), 128
end

function BitBuffer:ReadVector2int16(Position: number): (Vector2int16, number)
	local Buffer = self.Buffer
	
	local X = Bitsets.ReadInt16(Buffer, Position)
	local Y = Bitsets.ReadInt16(Buffer, Position + 16)
	
	return Vector2int16.new(X, Y), 32
end

function BitBuffer:ReadVector3(Position: number): (Vector3, number)
	return self:ReadVector(Position)
end

function BitBuffer:ReadVector3int16(Position: number): (Vector3int16, number)
	local Buffer = self.Buffer
	
	local X = Bitsets.ReadInt16(Buffer, Position)
	local Y = Bitsets.ReadInt16(Buffer, Position + 16)
	local Z = Bitsets.ReadInt16(Buffer, Position + 32)
	
	return Vector3int16.new(X, Y, Z), 48
end

--[[
function BitBuffer:ReadCFrame(Position: number): (CFrame, number)
	local Buffer = self.Buffer
	
	local CFPosition = self:ReadVector(Position)
	local XVector = self:ReadVector(Position + 192)
	local YVector = self:ReadVector(Position + 384)
	local ZVector = self:ReadVector(Position + 576)
	
	return CFrame.fromMatrix(CFPosition, XVector, YVector, ZVector), 768
end
]]

function BitBuffer:ReadCFrame(Position: number): (CFrame, number)
	local Buffer = self.Buffer
	
	--// Position
	local PositionX = Bitsets.ReadFloat(Buffer, Position)
	local PositionY = Bitsets.ReadFloat(Buffer, Position + 32)
	local PositionZ = Bitsets.ReadFloat(Buffer, Position + 64)

	--// Rotation
	local EulerAngleX = Bitsets.ReadFloat(Buffer, Position + 96)
	local EulerAngleY = Bitsets.ReadFloat(Buffer, Position + 128)
	local EulerAngleZ = Bitsets.ReadFloat(Buffer, Position + 160)
	
	return CFrame.new(PositionX, PositionY, PositionZ) * CFrame.fromEulerAnglesXYZ(EulerAngleX, EulerAngleY, EulerAngleZ), 192
end

function BitBuffer:ReadRegion3(Position: number): (Region3, number)
	local Buffer = self.Buffer
	
	local Min = self:ReadVector(Position)
	local Max = self:ReadVector(Position + 192)
	
	return Region3.new(Min, Max), 384
end

function BitBuffer:ReadRegion3int16(Position: number): (Region3int16, number)
	local Buffer = self.Buffer
	
	local Min = self:ReadVector3int16(Position)
	local Max = self:ReadVector3int16(Position + 48)
	
	return Region3int16.new(Min, Max), 96
end

function BitBuffer:ReadBrickColor(Position: number): (BrickColor, number)
	return BrickColor.new(Bitsets.ReadUInt16(self.Buffer, Position)), 16
end

function BitBuffer:ReadUDim(Position: number): (UDim, number)
	local Buffer = self.Buffer
	
	local Scale = Bitsets.ReadFloat(Buffer, Position)
	local Offset = Bitsets.ReadInt32(Buffer, Position + 32)
	
	return UDim.new(Scale, Offset), 64
end

function BitBuffer:ReadUDim2(Position: number): (UDim2, number)
	local Buffer = self.Buffer
	
	local XScale = Bitsets.ReadFloat(Buffer, Position)
	local XOffset = Bitsets.ReadInt32(Buffer, Position + 32)
	local YScale = Bitsets.ReadFloat(Buffer, Position + 64)
	local YOffset = Bitsets.ReadInt32(Buffer, Position + 96)
	
	return UDim2.new(XScale, XOffset, YScale, YOffset), 128
end

function BitBuffer:ReadTweenInfo(Position: number): (UDim2, number)
	local Buffer = self.Buffer
	
	local Time = Bitsets.ReadDouble(Buffer, Position)
	local EasingStyle = buffer_readbits(Buffer, Position + 64, 5)
	local EasingDirection = buffer_readbits(Buffer, Position + 69, 5)
	local RepeatCount = Bitsets.ReadUInt32(Buffer, Position + 74)
	local Reverses = Bitsets.ReadBoolean(Buffer, Position + 106)
	local DelayTime = Bitsets.ReadDouble(Buffer, Position + 107)
	
	return TweenInfo.new(Time, Enum.EasingStyle:FromValue(EasingStyle), Enum.EasingDirection:FromValue(EasingDirection), RepeatCount, Reverses, DelayTime), 171
end

function BitBuffer:ReadAxes(Position: number): (Axes, number)
	local Buffer = self.Buffer
	
	local X = Bitsets.ReadBoolean(Buffer, Position)
	local Y = Bitsets.ReadBoolean(Buffer, Position + 1)
	local Z = Bitsets.ReadBoolean(Buffer, Position + 2)
	local Top = Bitsets.ReadBoolean(Buffer, Position + 3)
	local Bottom = Bitsets.ReadBoolean(Buffer, Position + 4)
	local Left = Bitsets.ReadBoolean(Buffer, Position + 5)
	local Right = Bitsets.ReadBoolean(Buffer, Position + 6)
	local Back = Bitsets.ReadBoolean(Buffer, Position + 7)
	local Front = Bitsets.ReadBoolean(Buffer, Position + 8)
	
	return Axes.new(X, Y, Z, Top, Bottom, Left. Right, Back, Front), 9
end

function BitBuffer:ReadUInt8(Position: number): (number, number)
	return Bitsets.ReadUInt8(self.Buffer, Position), 8
end

function BitBuffer:ReadUInt16(Position: number): (number, number)
	return Bitsets.ReadUInt16(self.Buffer, Position), 16
end

function BitBuffer:ReadUInt32(Position: number): (number, number)
	return Bitsets.ReadUInt32(self.Buffer, Position), 32
end

function BitBuffer:ReadInt8(Position: number): (number, number)
	return Bitsets.ReadInt8(self.Buffer, Position), 8
end

function BitBuffer:ReadInt16(Position: number): (number, number)
	return Bitsets.ReadInt16(self.Buffer, Position), 16
end

function BitBuffer:ReadInt32(Position: number): (number, number)
	return Bitsets.ReadInt32(self.Buffer, Position), 32
end

function BitBuffer:ReadFloat(Position: number): (number, number)
	return Bitsets.ReadFloat(self.Buffer, Position), 32
end

--// WRITE FUNCTIONS
--// Write functions return the position they were written at
--// the ExcludeSignature arg should only be used internally within this module

function BitBuffer:WriteString(String: String, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	local Length = #String
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.string)
		Size += 8
	end
	
	Bitsets.WriteUInt32(Buffer, Size, Length)
	Bitsets.WriteString(Buffer, Size + 32, String)
	
	self.Size = Size + 32 + (Length * 8)
	
	return Size
end

function BitBuffer:WriteNumber(Number: number, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.number)
		Size += 8
	end
	
	Bitsets.WriteDouble(Buffer, Size, Number)
	
	self.Size = Size + 64
	
	return Size
end

function BitBuffer:WriteBoolean(Boolean: boolean, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.boolean)
		Size += 8
	end
	
	Bitsets.WriteBoolean(Buffer, Size, Boolean)
	
	self.Size = Size + 1
	
	return Size
end

function BitBuffer:WriteVector(Vector: vector, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.vector)
		Size += 8
	end
	
	Bitsets.WriteDouble(Buffer, Size, Vector.x)
	Bitsets.WriteDouble(Buffer, Size + 64, Vector.y)
	Bitsets.WriteDouble(Buffer, Size + 128, Vector.z)
	
	self.Size = Size + 192
	
	return Size
end

function BitBuffer:WriteColor3(Color: Color3, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.Color3)
		Size += 8
	end
	
	Bitsets.WriteDouble(Buffer, Size, Color.R)
	Bitsets.WriteDouble(Buffer, Size + 64, Color.G)
	Bitsets.WriteDouble(Buffer, Size + 128, Color.B)
	
	self.Size = Size + 192
	
	return Size
end

function BitBuffer:WriteVector2(Vector: Vector2, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.Vector2)
		Size += 8
	end
	
	Bitsets.WriteDouble(Buffer, Size, Vector.X)
	Bitsets.WriteDouble(Buffer, Size + 64, Vector.Y)
	
	self.Size = Size + 128
	
	return Size
end

function BitBuffer:WriteVector2int16(Vector: Vector2int16, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.Vector2int16)
		Size += 8
	end
	
	Bitsets.WriteInt16(Buffer, Size, Vector.X)
	Bitsets.WriteInt16(Buffer, Size + 16, Vector.Y)
	
	self.Size = Size + 32
	
	return Size
end

function BitBuffer:WriteVector3(Vector: Vector3, ExcludeSignature: boolean?): number
	return self:WriteVector(Vector, ExcludeSignature)
end

function BitBuffer:WriteVector3int16(Vector: Vector3int16, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.Vector3int16)
		Size += 8
	end
	
	Bitsets.WriteInt16(Buffer, Size, Vector.X)
	Bitsets.WriteInt16(Buffer, Size + 16, Vector.Y)
	Bitsets.WriteInt16(Buffer, Size + 32, Vector.Z)
	
	self.Size = Size + 48
	
	return Size
end

--[[
function BitBuffer:WriteCFrame(CoordinateFrame: CFrame, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.CFrame)
		Size += 8
		self.Size += 8
	end
	
	self:WriteVector(CoordinateFrame.Position, true)
	self:WriteVector(CoordinateFrame.XVector, true)
	self:WriteVector(CoordinateFrame.YVector, true)
	self:WriteVector(CoordinateFrame.ZVector, true)
	
	return Size
end
]]

function BitBuffer:WriteCFrame(CoordinateFrame: CFrame, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size

	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.CFrame)
		Size += 8
		self.Size += 8
	end
	
	--// Position
	Bitsets.WriteFloat(Buffer, Size, CoordinateFrame.X)
	Bitsets.WriteFloat(Buffer, Size + 32, CoordinateFrame.Y)
	Bitsets.WriteFloat(Buffer, Size + 64, CoordinateFrame.Z)
	
	--// Rotation
	local X, Y, Z = CoordinateFrame:ToEulerAnglesXYZ()
	Bitsets.WriteFloat(Buffer, Size + 96, X)
	Bitsets.WriteFloat(Buffer, Size + 128, Y)
	Bitsets.WriteFloat(Buffer, Size + 160, Z)

	return Size, 192
end

function BitBuffer:WriteRegion3(Region: Region3, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.Region3)
		Size += 8
		self.Size += 8
	end
	
	local Position = Region.CFrame.Position
	local HalfSize = Region.Size / 2
	
	self:WriteVector(Position - HalfSize, true)
	self:WriteVector(Position + HalfSize, true)
	
	return Size
end

function BitBuffer:WriteRegion3int16(Region: Region3int16, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.Region3int16)
		Size += 8
		self.Size += 8
	end
	
	self:WriteVector3int16(Region.Min, true)
	self:WriteVector3int16(Region.Max, true)
	
	return Size
end

function BitBuffer:WriteBrickColor(BrickColor: BrickColor, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.BrickColor)
		Size += 8
	end
	
	Bitsets.WriteUInt16(Buffer, Size, BrickColor.Number)
	self.Size = Size + 16
	
	return Size
end

function BitBuffer:WriteUDim(UDim: UDim, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.UDim)
		Size += 8
	end
	
	Bitsets.WriteFloat(Buffer, Size, UDim.Scale)
	Bitsets.WriteInt32(Buffer, Size + 32, UDim.Offset)
	
	self.Size = Size + 64
	
	return Size
end

function BitBuffer:WriteUDim2(UDim2: UDim2, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.UDim2)
		Size += 8
	end
	
	Bitsets.WriteFloat(Buffer, Size, UDim2.X.Scale)
	Bitsets.WriteInt32(Buffer, Size + 32, UDim2.X.Offset)
	Bitsets.WriteFloat(Buffer, Size + 64, UDim2.Y.Scale)
	Bitsets.WriteInt32(Buffer, Size + 96, UDim2.Y.Offset)
	
	self.Size = Size + 128
	
	return Size
end

function BitBuffer:WriteTweenInfo(TweenInfo: TweenInfo, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size
	
	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.TweenInfo)
		Size += 8
	end
	
	Bitsets.WriteDouble(Buffer, Size, TweenInfo.Time)
	buffer_writebits(Buffer, Size + 64, 5, TweenInfo.EasingStyle.Value)
	buffer_writebits(Buffer, Size + 69, 5, TweenInfo.EasingDirection.Value)
	Bitsets.WriteUInt32(Buffer, Size + 74, TweenInfo.RepeatCount)
	Bitsets.WriteBoolean(Buffer, Size + 106, TweenInfo.Reverses)
	Bitsets.WriteDouble(Buffer, Size + 107, TweenInfo.DelayTime)
	
	self.Size = Size + 171
	
	return Size
end

function BitBuffer:WriteAxes(Axes: Axes, ExcludeSignature: boolean?): number
	local Buffer = self.Buffer
	local Size = self.Size

	if not ExcludeSignature then
		Bitsets.WriteUInt8(Buffer, Size, Signatures.Axes)
		Size += 8
	end

	Bitsets.WriteBoolean(Buffer, Size, Axes.X)
	Bitsets.WriteBoolean(Buffer, Size + 1, Axes.Y)
	Bitsets.WriteBoolean(Buffer, Size + 2, Axes.Z)
	Bitsets.WriteBoolean(Buffer, Size + 3, Axes.Top)
	Bitsets.WriteBoolean(Buffer, Size + 4, Axes.Bottom)
	Bitsets.WriteBoolean(Buffer, Size + 5, Axes.Left)
	Bitsets.WriteBoolean(Buffer, Size + 6, Axes.Right)
	Bitsets.WriteBoolean(Buffer, Size + 7, Axes.Back)
	Bitsets.WriteBoolean(Buffer, Size + 8, Axes.Front)

	self.Size = Size + 9

	return Size
end

return BitBuffer
