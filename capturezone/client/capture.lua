class "CaptureZone"

function CaptureZone:__init()
	zoneicon = "R0lGODlhEAAQALMAAAAAAAgAAENDQ4MAAJgAALgAAMAAAAAAhsjIyP///wAAAAAAAAAAAAAAAAAAAAAAACH5BAkAAAkALAAAAAAQABAAAAhlAAEIFJigoMGDCQYSRIgQgAAEChU2fBix4kCKBAgUKGDAQIAAETFq5GhgQEcDFyFm3NjRZMeUAFaSdIlSIMUBNEuehInzpM6XNiH2PEkT5sejAYoGtWiRIoCDTCUyPHhA6tSCAQEAOw=="
	createdImage = Image.Create(AssetLocation.Base64, zoneicon)
	Events:Subscribe( "KeyUp", self, self.KeyUp)
	Events:Subscribe("Render", self, self.Render )
	self.Zones = {}
	iZONES = 0
	capturebar = {}

	self:AddZone(1, "Docks", Vector3(8134.127930, 200.091888, 14060.782227), Color(255, 255, 255, 80))
	self:AddZone(2, "Village", Vector3(5367.000977, 205.103806, 13337.748047), Color(255, 255, 255, 80))

	print("Loaded " .. iZONES .. " zones")

	Network:Subscribe("PlayerSyncZone", self, self.PlayerZoneSync)
end


function CaptureZone:PlayerZoneSync(args)
	local i = 1
	for i = 1, iZONES do
		self.Zones[i].Color = args[i].Color
		self.Zones[i].CappedTeam = args[i].CappedTeam
	end
end

function CaptureZone:KeyUp(args)
	if args.key == string.byte('M') then
		for k,v in pairs(self.Zones) do
			if(v.Pos:Distance2D( Camera:GetPosition())) <= 23 then
				if(v.CappedTeam == LocalPlayer:GetValue("Team")) then return end
				if(LocalPlayer:GetValue("AdminDuty") == 1) then return end
				if(v.Timer == nil) then
					v.Timer = Timer()
					v.Capturer = LocalPlayer
					self:SendText(LocalPlayer, v.Name, 1)
				else Chat:Print("There is someone already capturing this zone", Color(255, 255, 255)) end
			end
		end
	end
end

function CaptureZone:Render()
	for k,v in pairs (self.Zones) do		
		local pos, ok = Render:WorldToMinimap(v.Pos)
		if ok then
			Render:FillCircle(pos, 35, v.Color)
		end

		if(v.Pos:Distance2D( Camera:GetPosition())) <= 250 then
			self:DrawArea(k, v)
		end

		if(v.Pos:Distance2D( Camera:GetPosition())) <= 40 then
			self:DrawArea(k, v)
			if v.Timer ~= nil and v.Capturer == LocalPlayer then
				local text = "" .. tostring(v.Name) .. " || " .. tostring(v.CappedTeam) .. " || " .. tostring(math.floor(25 - v.Timer:GetSeconds()))
				Render:DrawText(Vector2(Render.Width/2 - Render:GetTextWidth(text), 10), text, Color(255, 255, 255), 34)
			else
				local text = "" .. tostring(v.Name) .. " || " .. tostring(v.CappedTeam)
				local text2 = "To capture this zone, go to the circle and press press the 'M' key"

				Render:DrawText(Vector2(Render.Width/2 - Render:GetTextWidth(text), 10), text, Color(255, 255, 255), 34)
				Render:DrawText(Vector2(Render.Width/2 - Render:GetTextWidth(text2)/2, 45), text2, Color(255, 120, 200), 16)
			end
		end

		createdImage:Draw(pos, Vector2(17, 17), Vector2(0,0),Vector2(1,1))
		if v.Timer ~= nil and v.Timer:GetSeconds() >= 25 then
			local playercolor = v.Capturer:GetColor()
			playercolor.a = 70
			v.Color = playercolor
			v.CappedTeam = v.Capturer:GetValue("Team")
			v.Timer = nil
			self:SendCapture()
			self:SendText(v.Capturer, v.Name, 2)
		end

		if v.Timer ~= nil and v.Timer:GetSeconds() < 25 and v.Capturer == LocalPlayer and v.Pos:Distance2D(Camera:GetPosition()) > 23 then
			v.Timer = nil
			Chat:Print("You have failed to capture this zone!", Color(255, 255, 255))
			self:SendText(v.Capturer, v.Name, 3)
		end
	end
end

function CaptureZone:SendText(id, zonename, number)
	args = {}
	args.name = id
	args.zname = zonename
	args.choice = number
	Network:Send("CaptureText", args)
end

function CaptureZone:SendCapture()
	local i = 1
	local args = {}
	args.Zone = {}
	for i = 1, iZONES do
		args.Zone[i] = self.Zones[i]
		i = i + 1
	end
	args.iZONES = iZONES
	Network:Send("CaptureSync", args)
end


function CaptureZone:IsPlayerInArea(MinX, MinY, MaxX, MaxY)
	local playerPos = LocalPlayer:GetPosition()
	if(playerPos.x >= MinX and playerPos.x <= MaxX and playerPos.y >= MinY and playerPos.y <= MaxY) then
		return true
	else
		return false
	end
end

function CaptureZone:AddZone(zoneid, zonename, pos, zColor)
	self.Zones[zoneid] = {}
	self.Zones[zoneid].Name = zonename
	self.Zones[zoneid].Pos = pos
	self.Zones[zoneid].Color = zColor
	self.Zones[zoneid].CappedTeam = "None"
	self.Zones[zoneid].Capturer = -1
	self.Zones[zoneid].Timer = nil
	iZONES = iZONES + 1
end

function CaptureZone:DrawArea(k, v)
	--circle
	t2 = Transform3()
	local upAngle = Angle(0, math.pi/2, 0)
	t2:Translate(v.Pos):Rotate(upAngle)
	Render:SetTransform(t2)
	Render:FillCircle( Vector3(0,0,0), 20, v.Color)
	--circle end

	--text above circle

	local text1 = tostring(v.Name)

	local text_size = Render:GetTextSize( text1, TextSize.Default )
	local angle = Angle( Camera:GetAngle().yaw, 0, math.pi ) * Angle( math.pi, 0, 0 )
	local t = Transform3()
	t:Translate( v.Pos + Vector3(0, 7, 0))
	t:Scale( 0.016 )
	t:Rotate( angle )

	Render:SetTransform( t )

	Render:DrawText(Vector3( 0, 0, 0 ), text1, Color(255, 255, 255), 160)

end

capturezone = CaptureZone()
