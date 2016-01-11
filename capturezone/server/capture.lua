class("Capture")

function Capture:__init()
  local iZONES = 0
  capturetable = {}
  Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
  Network:Subscribe("CaptureSync", self, self.CaptureSync)
  Network:Subscribe("CaptureText", self, self.CaptureText)
end

function Capture:CaptureText(args)
  if(args.choice == 1) then
    Chat:Broadcast( args.name:GetValue("Team") .. " (" .. args.name:GetName() .. ")  has started to capture " .. args.zname, Color(160, 095, 200))
  elseif(args.choice == 2) then
    Chat:Broadcast( args.name:GetValue("Team") .. " (" .. args.name:GetName() .. ")  has captured " .. args.zname, Color(160, 095, 200))
    args.name:SetNetworkValue("Score", args.name:GetValue("Score") + 3)
    args.name:SetMoney(args.name:GetMoney() + 3000)
    Chat:Send(args.name, "You have gained 3 score and $3000 for capturing a zone", Color(255, 255, 120))
  elseif(args.choice == 3) then
    Chat:Broadcast( args.name:GetValue("Team") .. " (" .. args.name:GetName() .. ") has failed to capture " .. args.zname, Color(160, 095, 200))
  end
end

function Capture:PlayerJoin(args)
  if(capturetable[1] ~= nil) then
    SendIt = {
        [1] = capturetable[1],
        [2] = capturetable[2]
    }
    SendIt[1] = capturetable[1]
    SendIt[2] = capturetable[2]
    Network:Send(args.player, "PlayerSyncZone", SendIt)
  end
end

function Capture:SendEveryoneCap()
  if(capturetable[1] ~= nil) then
    SendIt = {
        [1] = capturetable[1],
        [2] = capturetable[2]
    }
    SendIt[1] = capturetable[1]
    SendIt[2] = capturetable[2]
    Network:Broadcast("PlayerSyncZone", SendIt)
  end
end

function Capture:CaptureSync(args)
  iZONES = args.iZONES
  local i = 1
  for i = 1, iZONES do
    capturetable[i] = {}
    capturetable[i].Color = args.Zone[i].Color
    capturetable[i].CappedTeam = args.Zone[i].CappedTeam
  end
  self:SendEveryoneCap()
end

capture = Capture()
