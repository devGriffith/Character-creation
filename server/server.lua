local userlogin = {}
local spawnLogin = {}

function vRPReceiver.initSystem()
	local source = source
	local steam = vRP.getSteam(source)

	Citizen.Wait(1000)

	return vRPReceiver.getPlayerCharacters(steam)
end

function vRPReceiver.deleteChar(id)
	local source = source
	local steam = vRP.getSteam(source)

	vRP.execute("vRP/remove_characters",{ id = parseInt(id) })
  
	Citizen.Wait(1000)

	return getPlayerCharacters(steam)
end

function vRPReceiver.characterChosen(id)
	local source = source
	vRPSend.closeNew(source)
	TriggerClientEvent("hudActived",source,true)
	TriggerEvent("baseModule:idLoaded",source,id,nil)
	TriggerEvent("CharacterSpawn",source,id)
	if spawnLogin[parseInt(id)] then
		TriggerClientEvent("spawn:spawnChar",source,false)
   else
	   spawnLogin[parseInt(id)] = true
		TriggerClientEvent("spawn:spawnChar",source,true)
   end
   vRPclient.playerReady(source)
end

function vRPReceiver.checkNewCharacter()
	local source = source
	local steam = vRP.getSteam(source)
	local persons = vRPReceiver.getPlayerCharacters(steam)

	if parseInt(#persons) >= vRP.getPremium2(steam) then
		TriggerClientEvent("Notify",source,"importante","Você atingiu o limite de personagens.",5000)
		return false
	end
	return true
end

function vRPReceiver.newCharacter(name,firstname,sex,idade)
	local source = source
	local steam = vRP.getSteam(source)

	vRPSend.closeNew(source)

	vRP.execute("vRP/create_characters",{ steam = steam, name = name, firstname = firstname, loc = "Norte", age = idade })

	local newId = 0
	local chars = vRPReceiver.getPlayerCharacters(steam)
	for k,v in pairs(chars) do
		if v.id > newId then
			newId = tonumber(v.id)
		end
	end

	Citizen.Wait(1000)

	spawnLogin[parseInt(newId)] = true

	if sex == "homem" then
		sex = "mp_m_freemode_01"
	else
		sex = "mp_f_freemode_01"
	end

	TriggerClientEvent("hudActived",source,true)
	TriggerEvent("baseModule:idLoaded",source,newId,sex)
	TriggerEvent("characterSpawn", source, newId)
	Citizen.Wait(1000)
	--TriggerClientEvent("spawn:justSpawn",source,true)
	TriggerClientEvent("ENTROU",source,true)
	vRPReceiver.deCode(newId,sex)
end

function vRPReceiver.deCode(user_id,sex)
	if user_id then
		vRP.setUData(user_id,"currentCharacterMode",json.encode(sex))
		vRP.setUData(user_id,"spawnController",json.encode(2))
	end
end

function vRPReceiver.getPlayerCharacters(steam)
	return vRP.query("vRP/get_characters",{ steam = steam })
end

RegisterServerEvent("CharacterSpawn")
AddEventHandler("CharacterSpawn", function(source,user_id)
	if user_id then
		local data = vRP.getUData(user_id,"spawnController")
		local sdata = json.decode(data) or 0
		if sdata then
			Citizen.Wait(1000)
			vRPReceiver.processSpawnController(source,sdata,user_id)
		end
	end
end)

function vRPReceiver.processSpawnController(source,statusSent,user_id)
	if statusSent == 2 then
		if not userlogin[user_id] then
			userlogin[user_id] = true
			vRPReceiver.doSpawnPlayer(source,user_id,true)
		else
			vRPReceiver.doSpawnPlayer(source,user_id,false)
		end
	end
end

function vRPReceiver.doSpawnPlayer(source,user_id,spawnType)
	local identity = vRP.getUserIdentity(user_id)
    local player = vRP.getUserSource(user_id)

	TriggerClientEvent("spawn:justSpawn",source,spawnType)
	TriggerClientEvent("vrp:playerActive",source,user_id,identity)
	TriggerEvent("barbershop:init",user_id)

    if player then
        local value = vRP.getUData(user_id, "currentCharacterMode")
        if value ~= "" then
            local custom = json.decode(value) or {}
            TriggerClientEvent("barbershop:apply",player,custom)
        end
    end
end

RegisterServerEvent("spawn:setPlayerSpawn")
AddEventHandler("spawn:setPlayerSpawn", function()
	local source = source
	local user_id = vRP.getUserId(source)
    if user_id then
		local steam = vRP.getSteam(source)
		if steam then 
			local chars = vRPReceiver.getPlayerCharacters(steam)
			if #chars <= 1 then
				TriggerClientEvent("Notify",source,"negado","Você não possui Personagem extra.",5000)
				return 
			end
			spawnPlayer(source,true)
		else
			TriggerClientEvent("Notify",source,"negado","Erro ao obter steam.",5000)
		end
	end
end)

RegisterCommand("spawn",function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if user_id then
		if vRP.hasPermission(user_id,"admin.permissao") then
			if args[1] then
				local nplayer = vRP.getUserSource(parseInt(args[1]))
				if nplayer then
        			spawnPlayer(nplayer)
					TriggerClientEvent("Notify",source,"sucesso","Player foi enviado para a seleção de personagem.",5000)
				else
					TriggerClientEvent("Notify",source,"aviso","Player não está online.",5000)
				end
			else
				spawnPlayer(source)
			end
		end
	end
end)

RegisterCommand("setchar",function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if user_id then
		if vRP.hasPermission(user_id,"admin.permissao") then
			if args[1] and args[2] then
				local nplayer = vRP.getUserSource(parseInt(args[1]))
				if nplayer then
        			vRP.setPlayerChars(nplayer,parseInt(args[2]))
					TriggerClientEvent("Notify",source,"sucesso","Numero de Personagem do Player foi alterado para "..args[2]..".",5000)
				else
					TriggerClientEvent("Notify",source,"aviso","Player não está online.",5000)
				end
			else
				TriggerClientEvent("Notify",source,"negado","Argumento incorreto /setchar ID QTD.",5000)
			end
		end
	end
end)

RegisterCommand("clone",function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if user_id then
		if vRP.hasPermission(user_id,"admin.permissao") then
			createClone(source)
		end
	end
end)

function createClone(source)
    local user_id = vRP.getUserId(source)
    if user_id then
        local value = vRP.getUData(user_id, "currentCharacterMode")
        local datatatto = vRP.getUData(user_id,"vRP:tattoos")
        local data = vRP.getUserDataTable(user_id)
        if value ~= "" and data then
            local custom = json.decode(value) or {}
            local tatto = json.decode(datatatto) or {}
            TriggerClientEvent("CreateClonePed",source,custom,data,tatto)
        end
    end
end

function spawnPlayer(source,createPed)
	if createPed then
		createClone(source)
	end
	TriggerClientEvent("Notify",source,"aviso","Carregando Personagens.",5000)
	Citizen.Wait(1000)
	vRP.dropPlayer(source)
	TriggerClientEvent("spawn:generateJoin",source)
end