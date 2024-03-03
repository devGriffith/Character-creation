local stats_data = LoadResourceFile(GetCurrentResourceName(),'config/config.json')
local config = {}
local otherLocates = {}

Citizen.CreateThread(function()
    if stats_data then
        config = json.decode(stats_data)
    end
	
	for k,v in pairs(config.locals) do 
		if v.coord then
			otherLocates[v.id] = v.coord
		end
	end
end)

local spawnLocates = {}
local brokenCamera = false
local characterCamera = nil
local ENTROU = false

Citizen.CreateThread(function()
	while true do 
		wait = 1000
		local ped = PlayerPedId()
		local x,y,z = config.trocaPersonagem[1],config.trocaPersonagem[2],config.trocaPersonagem[3]
		local distance = #(GetEntityCoords(ped) - vec3(x,y,z))
		if distance <= 10 then
			wait = 5
			DrawMarker(27,x,y,z-0.97,0,0,0,0,0,0,1.0,1.0,0.5,0, 202, 209,500,0,0,0,1)
			if distance < 1.5 then
				DrawText3D(x,y,z-0.2,"~b~[ E ] ~w~ MUDAR PERSONAGEM")
				if IsControlJustPressed(0,38) then
					TriggerServerEvent('spawn:setPlayerSpawn')
				end
			end
		end
		Citizen.Wait(wait)
	end
end)

RegisterNetEvent("spawn:generateJoin")
AddEventHandler("spawn:generateJoin",function()
	TriggerEvent('spawn:setupChars')
end)

RegisterNetEvent("spawn:setupChars")
AddEventHandler("spawn:setupChars",function()
	DoScreenFadeOut(1000)
	TransitionToBlurred(1000)
	local ped = PlayerPedId()
	characterCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",667.43,1025.9,378.87,340.0,0.0,342.0,60.0,false,0)
	SetCamActive(characterCamera,true)
	RenderScriptCams(true,false,1,true,true)
	ShutdownLoadingScreenNui()
	SendNUIMessage({ action = "open", type = "select" })
	SetEntityVisible(ped,false,false)
	FreezeEntityPosition(ped,true)
	SetEntityInvincible(ped,true)
	SetNuiFocus(true,true)
	Citizen.Wait(2000)
	DoScreenFadeIn(0)
end)

RegisterNUICallback("generateDisplay",function(data,cb)
	cb({ result = vRPSend.initSystem() })
end)

RegisterNUICallback("characterChosen",function(data)
	vRPSend.characterChosen(data["id"])
end)

RegisterNUICallback("newCharacter",function(data)
	DoScreenFadeOut(1000)
	local ped = PlayerPedId()
	SetEntityVisible(ped,true,true)
	FreezeEntityPosition(ped,false)
	SetEntityInvincible(ped,false)
	SetNuiFocus(false,false)
	RenderScriptCams(false,false,0,true,true)
	SetCamActive(characterCamera,false)
	DestroyCam(characterCamera,true)
	characterCamera = nil
	vRPSend.newCharacter(data["name"],data["name2"],data["sex"],data["idade"])
	changeGender(data["sex"])
	SendNUIMessage({ action = "close" })
	Citizen.Wait(5000)
	DoScreenFadeIn(1000)
	TransitionFromBlurred(1000)
end)

function changeGender(sex)
	local model = "mp_m_freemode_01"
	if sex == "homem" then
		model = "mp_m_freemode_01"
	else
		model = "mp_f_freemode_01"
	end
	
	local mhash = GetHashKey(model)
	while not HasModelLoaded(mhash) do
		RequestModel(mhash)
		Citizen.Wait(10)
	end
	if HasModelLoaded(mhash) then
		SetPlayerModel(PlayerId(),mhash)
		SetEntityHealth(PlayerPedId(),400)
		SetModelAsNoLongerNeeded(mhash)
	end
end

RegisterNUICallback("checkNewCharacter",function(data,cb)
	cb({ result = vRPSend.checkNewCharacter() })
end)

RegisterNUICallback("generateSpawn",function(data,cb)
	cb({ result = spawnLocates })
end)

RegisterNetEvent("spawn:justSpawn")
AddEventHandler("spawn:justSpawn",function(spawnType)
	DoScreenFadeOut(1000)
	Citizen.Wait(2000)
	spawnLocates = {}
	local ped = PlayerPedId()
	RenderScriptCams(false,false,0,true,true)
	SetCamActive(characterCamera,false)
	DestroyCam(characterCamera,true)
	characterCamera = nil

	if spawnType then
		SetEntityVisible(ped,false,false)
		FreezeEntityPosition(ped,true)
		SetEntityInvincible(ped,true)

		local numberLine = 0
		for k,v in pairs(otherLocates) do
			numberLine = numberLine + 1
			spawnLocates[numberLine] = { x = v[1], y = v[2], z = v[3], name = v[4], hash = numberLine }
		end

		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		characterCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",coords["x"],coords["y"],coords["z"] + 200.0,270.00,0.0,0.0,80.0,0,0)
		SetCamActive(characterCamera,true)
		RenderScriptCams(true,false,1,true,true)
		TransitionToBlurred(1000)
		SendNUIMessage({ action = "open",type = "spawn" })
		DoScreenFadeIn(1000)
	else
		SetEntityVisible(ped,true,true)
		FreezeEntityPosition(ped,false)
		SetEntityInvincible(ped,false)
		TriggerEvent("hudActived",true)
		SetNuiFocus(false,false)
		brokenCamera = false

		Citizen.Wait(2000)
		DoScreenFadeIn(1000)
		TransitionFromBlurred(1000)
	end
end)

function vRPReceiver.closeNew()
	SendNUIMessage({ action = "close" })
end

RegisterNUICallback("spawnChosen",function(data)
	local ped = PlayerPedId()
	
	if data["id"] == 4 then
		DoScreenFadeOut(1000)

		SendNUIMessage({ action = "close" })
		TriggerEvent("hudActived",true)
		SetNuiFocus(false,false)

		RenderScriptCams(false,false,0,true,true)
		SetCamActive(characterCamera,false)
		DestroyCam(characterCamera,true)
		SetEntityVisible(ped,true,false)
		SetEntityInvincible(ped,false)
		FreezeEntityPosition(ped,false)
		characterCamera = nil
		brokenCamera = false
		Citizen.Wait(2000)
		DoScreenFadeIn(1000)
		TransitionFromBlurred(1000)
		if ENTROU then
			TriggerEvent("setupChar",true)
		end

	else
		brokenCamera = false
		SendNUIMessage({ action = "close" })
		TriggerEvent("hudActived",true)
		SetNuiFocus(false,false)
		TransitionFromBlurred(1000)
		SetCamRot(characterCamera,270.0)
		SetCamActive(characterCamera,true)
		brokenCamera = true
		local speed = 0.7
		weight = 270.0
		SetEntityCoords(ped,spawnLocates[data["id"]]["x"],spawnLocates[data["id"]]["y"],spawnLocates[data["id"]]["z"],1,0,0,0)
		local coords = GetEntityCoords(ped)

		SetCamCoord(characterCamera,coords["x"],coords["y"],coords["z"] + 200.0)
		local i = coords["z"] + 200.0

		while i > spawnLocates[data["id"]]["z"] + 1.5 do
			i = i - speed
			SetCamCoord(characterCamera,coords["x"],coords["y"],i)

			if i <= spawnLocates[data["id"]]["z"] + 35.0 and weight < 360.0 then
				if speed - 0.0078 >= 0.05 then
					speed = speed - 0.0078
				end

				weight = weight + 0.75
				SetCamRot(characterCamera,weight)
			end

			if not brokenCamera then
				break
			end
			Citizen.Wait(0)
		end
		DoScreenFadeOut(1000)
		Citizen.Wait(2000)
		RenderScriptCams(false,false,0,true,true)
		SetCamActive(characterCamera,false)
		DestroyCam(characterCamera,true)
		SetEntityVisible(ped,true,false)
		SetEntityInvincible(ped,false)
		FreezeEntityPosition(ped,false)
		characterCamera = nil
		brokenCamera = false
		TriggerEvent("hudActived",true)
		DoScreenFadeIn(1000)
		TransitionFromBlurred(1000)	
		if ENTROU then
			TriggerEvent("setupChar",true)
		end
	end
end)

RegisterNetEvent("ENTROU")
AddEventHandler("ENTROU",function(status)
	ENTROU = status
end)

RegisterNUICallback("DeleteCharacter",function(data,cb)
	local chars = vRPSend.deleteChar(tonumber(data.id))
	cb(chars)
end)

function DrawText3D(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(0)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,255)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 400
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,255,255,255,0)
end