-- Reanimate using hats and loopkill --
-- Feel free to edit and use however you'd like --
-- Ever since RejectCharacterDeletions I miss the old Reanimate scripts, so hopefully this small project can help people make some new ones. --

-- Keep in mind, I don't make scripts, sooo this code might not be the best, so excuse any mistakes and etc.

-- You can stop the loopkill by destroying the fake character!

-- Hat Tables
local Hats = { -- Just using names to grab the hats so nothing fancy, feel free to change which hats are used, the ones I used are linked below, you may need to change the offsets depending on which hats you decide to use.
	["Head"] = "MeshPartAccessory", -- https://www.roblox.com/catalog/12723002425/white-head
	["Left Arm"] = "LARM", -- https://www.roblox.com/catalog/14768701869/White-Extended-Left-Arm
	["Right Arm"] = "RARM", -- https://www.roblox.com/catalog/14768693948/White-Extended-Right-Arm
	["Torso"] = "Black", -- https://www.roblox.com/catalog/14768678294/Torso-Extension
	["Left Leg"] = "Accessory (LARM)", -- https://www.roblox.com/catalog/17374851733/Extra-Left-Black-Arm
	["Right Leg"] = "Accessory (RARM)" -- https://www.roblox.com/catalog/17374846953/Extra-Right-Black-Arm
}

local HatOffsets = { -- Offset the attachments relative to the associated body part (for align orienation and align position)
	["Head"] = CFrame.new(0,0,0) * CFrame.Angles(0,0,0),
	["Left Arm"] = CFrame.new(0,0,0) * CFrame.Angles(0,0,math.rad(90)),
	["Right Arm"] = CFrame.new(0,0,0) * CFrame.Angles(0,0,math.rad(90)),
	["Torso"] = CFrame.new(0,0,0) * CFrame.Angles(0,0,0),
	["Left Leg"] = CFrame.new(0,0,0) * CFrame.Angles(0,0,math.rad(90)),
	["Right Leg"] = CFrame.new(0,0,0) * CFrame.Angles(0,0,math.rad(90))
}

local CurrentHats = {} -- Don't change this, this is used later in the code

-- Variables
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CurrentCharacter = Player.Character
local CurrentCamera = workspace.CurrentCamera
local FakeCharacter = nil
local LastCameraCFrame

local LoopConnection
local CharConnection
local LastHB

-- Functions
local function CreateAlign(Part1, Part2) 
	if Part1:FindFirstChild("Attachment") then
		Part1:FindFirstChild("Attachment"):Destroy()
	end

	local A0 = Instance.new("Attachment")
	A0.Parent = Part1

	if Part2:FindFirstChild("Attachment") then
		Part2:FindFirstChild("Attachment"):Destroy()
	end

	local A1 = Instance.new("Attachment")
	A1.Parent = Part2

	local AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Parent = Part1
	local AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.Parent = Part1

	AlignPosition.Attachment0 = A0
	AlignPosition.Attachment1 = A1
	AlignOrientation.Attachment0 = A0
	AlignOrientation.Attachment1 = A1

	AlignPosition.RigidityEnabled = false
	AlignPosition.ApplyAtCenterOfMass = false
	AlignPosition.MaxForce = 67752
	AlignPosition.MaxVelocity = math.huge/9e110
	AlignPosition.ReactionForceEnabled = false
	AlignPosition.Responsiveness = 200

	AlignOrientation.MaxTorque = 67752
	AlignOrientation.MaxAngularVelocity = math.huge/9e110
	AlignOrientation.PrimaryAxisOnly = false
	AlignOrientation.ReactionTorqueEnabled = false
	AlignOrientation.Responsiveness = 200
	AlignOrientation.RigidityEnabled = false

	Part2.Transparency = 0.8 -- So you can see the fake hats relative to the real ones incase they fall and etc
end

local function CreateFakeCharacter()
	CurrentCharacter.Archivable = true

	FakeCharacter = CurrentCharacter:Clone()
	FakeCharacter.Name = Player.Name .. "_Fake"
	FakeCharacter.Parent = workspace

	task.spawn(function()
		for i, LS in ipairs(FakeCharacter:GetChildren()) do
			if LS:IsA("LocalScript") then
				LS.Enabled = false
				task.wait(0.1)
				LS.Enabled = true
			end
		end
	end)

	for i, Part in ipairs(FakeCharacter:GetChildren()) do
		if Part:IsA("BasePart")then
			Part.Transparency = 1
		end
	end

	for i, Decal in ipairs(FakeCharacter:GetDescendants()) do
		if Decal:IsA("Decal")then
			Decal.Transparency = 1
		end
	end

	Player.Character = FakeCharacter
end

local function CFrameFakeHats()
	for Name, Hat in pairs(Hats) do
		if FakeCharacter:FindFirstChild(Name) then
			local FakeHat = FakeCharacter:FindFirstChild(Hat)
			local BodyPart = FakeCharacter:FindFirstChild(Name)
			if FakeHat.Handle:FindFirstChildWhichIsA("Weld") then
				FakeHat.Handle:FindFirstChildWhichIsA("Weld"):Destroy()
			end
			if BodyPart and FakeHat then
				FakeHat.Handle.CFrame = BodyPart.CFrame * HatOffsets[Name]
			end
		end
	end
	for i, Hat in ipairs(CurrentCharacter:GetChildren()) do
		if Hat:IsA("Accessory") then
			if Hats[Hat.Name] == nil then
				Hat.Handle.CFrame = FakeCharacter:FindFirstChild(Hat.Name).Handle.CFrame
			end
		end
	end
end

local function LoopKill()
	CurrentCharacter:BreakJoints()
	CurrentCharacter.Humanoid.Health = 0

	LastHB = game:GetService("RunService").Heartbeat:Connect(function()
		for i,v in next, CurrentCharacter:GetChildren() do
			if v:IsA("Accessory")  then 
				v.Handle.Velocity = Vector3.new(15,-15,-15)
			end
		end
	end)

	for Name, Hat in pairs(Hats) do
		if CurrentCharacter:FindFirstChild(Name) then
			local FakeHat = FakeCharacter:FindFirstChild(Hat)
			local RealHat = CurrentCharacter:FindFirstChild(Hat)
			local BodyPart = FakeCharacter:FindFirstChild(Name)
			if BodyPart and RealHat and FakeHat then
				CreateAlign(RealHat.Handle, FakeHat.Handle)
			end
		end
	end
	for i, Hat in ipairs(CurrentCharacter:GetChildren()) do
		if Hat:IsA("Accessory") then
			if Hats[Hat.Name] == nil then
				CreateAlign(Hat.Handle, FakeCharacter:FindFirstChild(Hat.Name).Handle)
			end
		end
	end

	CharConnection = Player.CharacterAdded:Connect(function(NewCharacter)
		LastCameraCFrame = CurrentCamera.CFrame
		Player.Character = FakeCharacter
		NewCharacter.Archivable = true

		if LastHB then
			LastHB:Disconnect()
			LastHB = nil
		end

		LastHB = game:GetService("RunService").Heartbeat:Connect(function()
			for i,v in next, CurrentCharacter:GetChildren() do
				if v:IsA("Accessory")  then 
					v.Handle.Velocity = Vector3.new(15,-15,-15)
				end
			end
		end)

		local OldCF
		local LastC = CurrentCamera.CFrame
		OldCF = CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
			CurrentCamera.CFrame = LastC
			LastC = CurrentCamera.CFrame
			OldCF:Disconnect()
		end)

		CurrentCharacter = NewCharacter
		repeat task.wait() until CurrentCharacter:FindFirstChild("Humanoid")
		CurrentCharacter:BreakJoints()
		CurrentCharacter.Humanoid.Health = 0
		CurrentCamera.CFrame = LastCameraCFrame

		if CurrentCharacter:FindFirstChild("HumanoidRootPart") then
			CurrentCharacter.HumanoidRootPart.Died.Volume = 0
		end

		for Name, Hat in pairs(Hats) do
			if CurrentCharacter:FindFirstChild(Name) then
				local FakeHat = FakeCharacter:FindFirstChild(Hat)
				local RealHat = CurrentCharacter:FindFirstChild(Hat)
				local BodyPart = FakeCharacter:FindFirstChild(Name)
				if BodyPart and RealHat and FakeHat then
					CreateAlign(RealHat.Handle, FakeHat.Handle)
				end
			end
		end
		for i, Hat in ipairs(CurrentCharacter:GetChildren()) do
			if Hat:IsA("Accessory") then
				if Hats[Hat.Name] == nil then
					CreateAlign(Hat.Handle, FakeCharacter:FindFirstChild(Hat.Name).Handle)
				end
			end
		end
		--CurrentCharacter:PivotTo(CFrame.new(0,10000,0))
	end)
end

local function Start()
	CreateFakeCharacter()
	LoopKill()

	LoopConnection = game:GetService("RunService").Heartbeat:Connect(function()
		task.spawn(CFrameFakeHats)

		for Name, Hat in pairs(Hats) do
			if CurrentCharacter:FindFirstChild(Name) then
				local FakeHat = FakeCharacter:FindFirstChild(Hat)
				local RealHat = CurrentCharacter:FindFirstChild(Hat)
				local BodyPart = FakeCharacter:FindFirstChild(Name)
				if BodyPart and RealHat and FakeHat then
					RealHat.Handle.CFrame = BodyPart.CFrame * HatOffsets[Name]
				end
			end
		end

		if FakeCharacter:FindFirstChild("Humanoid") then
			CurrentCamera.CameraSubject = FakeCharacter.Humanoid
		end

		if FakeCharacter == nil or FakeCharacter.Parent == nil then
			LoopConnection:Disconnect()
			CharConnection:Disconnect()
			if LastHB then
				LastHB:Disconnect()
				LastHB = nil
			end
		end
	end)
end

Start()
