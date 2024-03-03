local clonePed
local modelo

RegisterNetEvent("CreateClonePed")
AddEventHandler("CreateClonePed",function(custom,data,tatto)
	if data.modelhash == 1885233650 then
		model = "mp_m_freemode_01"
	else
		model = "mp_f_freemode_01"
	end

    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end
    clonePed = CreatePed(4,model,data.position.x,data.position.y,data.position.z-1.0, false, false)
	
    SetPedHeadBlendData(clonePed,custom.fathersID,custom.mothersID,0,custom.skinColor,0,0,f(custom.shapeMix),0,0,false)

	SetPedHeadOverlay(clonePed,6,custom.complexionModel,1.0)
	-- Sardas
	if custom.frecklesModel == 0 then
		SetPedHeadOverlay(clonePed,9,custom.frecklesModel,0.0)
	else
		SetPedHeadOverlay(clonePed,9,custom.frecklesModel,1.0)
	end
	-- Pelo Corporal
	SetPedHeadOverlay(clonePed,10,custom.chestModel,0.99)
	SetPedHeadOverlayColor(clonePed,10,1,custom.chestColor,custom.chestColor)
	-- Envelhecimento
	SetPedHeadOverlay(clonePed,3,custom.ageingModel,0.99)
	-- Cabelo
	SetPedComponentVariation(clonePed,2,custom.hairModel,0,1)
	SetPedHairColor(clonePed,custom.firstHairColor,custom.secondHairColor)
	-- Maquiagem
	SetPedHeadOverlay(clonePed,4,custom.makeupModel,custom.makeupintensity )
	SetPedHeadOverlayColor(clonePed,4,1,custom.makeupColor,custom.makeupColor)
	-- Battom
	SetPedHeadOverlay(clonePed,8,custom.lipstickModel,custom.lipstickintensity )
	SetPedHeadOverlayColor(clonePed,8,1,custom.lipstickColor,custom.lipstickColor)
	-- Sobrancelha
	SetPedHeadOverlay(clonePed,2,custom.eyebrowsModel,custom.eyebrowintensity )
	SetPedHeadOverlayColor(clonePed,2,1,custom.eyebrowColor,custom.eyebrowColor)
	-- Barba
	SetPedHeadOverlay(clonePed,1,custom.beardModel,custom.beardintentisy )
	SetPedHeadOverlayColor(clonePed,1,1,custom.beardColor,custom.beardColor)
	--acne
	if custom.blemishesModel == 0 then
		SetPedHeadOverlay(clonePed,0,custom.blemishesModel,0.0)
	else
		SetPedHeadOverlay(clonePed,0,custom.blemishesModel,1.0)
	end
	-- Blush
	SetPedHeadOverlay(clonePed,5,custom.blushModel,custom.blushintentisy )
	SetPedHeadOverlayColor(clonePed,5,1,custom.blushColor,custom.blushColor)
    -- Olhos
	SetPedEyeColor(clonePed,custom.eyesColor)
	-- Sobrancelha
	SetPedFaceFeature(clonePed,6,custom.eyebrowsHeight)
	SetPedFaceFeature(clonePed,7,custom.eyebrowsWidth)
	-- Nariz
	SetPedFaceFeature(clonePed,0,custom.noseWidth)
	SetPedFaceFeature(clonePed,1,custom.noseHeight)
	SetPedFaceFeature(clonePed,2,custom.noseLength)
	SetPedFaceFeature(clonePed,3,custom.noseBridge)
	SetPedFaceFeature(clonePed,4,custom.noseTip)
	SetPedFaceFeature(clonePed,5,custom.noseShift)
	-- Bochechas
	SetPedFaceFeature(clonePed,8,custom.cheekboneHeight)
	SetPedFaceFeature(clonePed,9,custom.cheekboneWidth)
	SetPedFaceFeature(clonePed,10,custom.cheeksWidth)
	-- Boca/Mandibula
	SetPedFaceFeature(clonePed,12,custom.lips)
	SetPedFaceFeature(clonePed,13,custom.jawWidth)
	SetPedFaceFeature(clonePed,14,custom.jawHeight)
	-- Queixo
	SetPedFaceFeature(clonePed,15,custom.chinLength)
	SetPedFaceFeature(clonePed,16,custom.chinPosition)
	SetPedFaceFeature(clonePed,17,custom.chinWidth)
	SetPedFaceFeature(clonePed,18,custom.chinShape)
	-- Pescoço
	SetPedFaceFeature(clonePed,19,custom.neckWidth)

    for k,v in pairs(data.customization) do
        if k ~= "model" and k ~= "modelhash" then
            local isprop, index = parse_part(k)
            if isprop then
                if v[1] < 0 then
                    ClearPedProp(clonePed,index)
                else
                    SetPedPropIndex(clonePed,index,v[1],v[2],v[3] or 2)
                end
            else
                SetPedComponentVariation(clonePed,index,v[1],v[2],v[3] or 2)
            end
        end
    end
	--tatto
	if tatto ~= nil and tatto ~= "" then
		ClearPedDecorations(clonePed)
		for k,v in pairs(tatto) do
			AddPedDecorationFromHashes(clonePed,GetHashKey(v[1]),GetHashKey(k))
		end
	end

	SetEntityAsNoLongerNeeded(clonePed)
end)

function f(n)
	if n == nil then
		n = 0.0
	end
	n = n + 0.00000
	return n
end

function parse_part(key)
	if type(key) == "string" and string.sub(key,1,1) == "p" then
		return true,tonumber(string.sub(key,2))
	else
		return false,tonumber(key)
	end
end
    