ESX = exports.es_extended:getSharedObject()

local currentmotel = nil
local inroom = false
local pinkcagecoord = vector3(505.109, 213.451, 104.039)

local roomCoord = vector3(-1232.2, 3874.42, 154.114)
local roomHeading = 67.57
local stashCoord = vector3(-1231.6, 3878.42, 154.114)
local clotheCoord = vector3(-1236.0, 3880.17, 154.114)

local pinkcage = {
    [1] = vector3(522.539, 199.494, 104.744),
    [2] = vector3(522.539, 199.494, 104.744),
    [3] = vector3(522.539, 199.494, 104.744),
    [4] = vector3(522.539, 199.494, 104.744),
    [5] = vector3(522.539, 199.494, 104.744),
    [6] = vector3(522.539, 199.494, 104.744),
    [7] = vector3(522.539, 199.494, 104.744),
    [8] = vector3(485.212, 212.576, 104.740),
    [9] = vector3(485.212, 212.576, 104.740),
    [10] = vector3(485.212, 212.576, 104.740),
    [11] = vector3(485.212, 212.576, 104.740),
    [12] = vector3(485.212, 212.576, 104.740),
    [13] = vector3(485.212, 212.576, 104.740),
    [14] = vector3(485.212, 212.576, 104.740),
}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    currentmotel = math.random(1, #pinkcage)
    notify('inform', 'Yeni motel odası verildi! Oda numaran: '..currentmotel)
end)

RegisterCommand('yenimotelodasi', function()
    currentmotel = math.random(1, #pinkcage)
    notify('inform', 'Yeni motel odası verildi! Oda numaran: '..currentmotel)
end)

Citizen.CreateThread(function()
    local gblip = AddBlipForCoord(pinkcagecoord)
    SetBlipSprite(gblip, 475)
    SetBlipDisplay(gblip, 4)
    SetBlipScale (gblip, 0.6)
    SetBlipColour(gblip, 27)
    SetBlipAsShortRange(gblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(" Motel")
    EndTextCommandSetBlipName(gblip)
end)

Citizen.CreateThread(function()
    while true do
        local delay = false
        if currentmotel ~= nil then
            local player = PlayerPedId()
            local playercoords = GetEntityCoords(player)
            -- local stashdistance = #(playercoords - pinkcage[currentmotel].stash)
            -- local clothedistance = #(playercoords - pinkcage[currentmotel].clothe)
            local doordistance = GetDistanceBetweenCoords(playercoords, pinkcage[currentmotel], true)
            local moteldistance = GetDistanceBetweenCoords(playercoords, pinkcagecoord, true)

            if moteldistance <= 60.0 then
                if doordistance <= 30.0 then
                    DrawMarker(22, pinkcage[currentmotel].x, pinkcage[currentmotel].y, pinkcage[currentmotel].z - 0.3, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 32, 236, 54, 255, 0, 0, 0, 1, 0, 0, 0)
                end
                if doordistance <= 2.0 then
                    DrawText3D(pinkcage[currentmotel], "[~g~E~w~] - Motel odana gir")
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('gastor:motel:server:enterMotelRoom')
                    end
                end
            elseif inroom then
                local stashdistance = GetDistanceBetweenCoords(playercoords, stashCoord, true)
                local clothedistance = GetDistanceBetweenCoords(playercoords, clotheCoord, true)
                local exitdistance = GetDistanceBetweenCoords(playercoords, roomCoord, true)
                if stashdistance <= 1.5 then
                    DrawText3D(stashCoord, '[~g~E~w~] - Sandık')
                    if IsControlJustReleased(0, 38) then
                        OpenMotelInventory()
                    end
                end
                if clothedistance <= 1.5 then
                    DrawText3D(clotheCoord, '[~g~E~w~] - Gardrop')
                    if IsControlJustReleased(0, 38) then
                        OpenMotelWardrobe()
                    end
                end
                if exitdistance <= 1.5 then
                    DrawText3D(roomCoord, '[~g~E~w~] - Ayrıl')
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('gastor:motel:server:exitMotelRoom')
                    end
                end
            else
                delay = true
            end
        else
            delay = true
        end

        if delay then
            Citizen.Wait(500)
        end
        Citizen.Wait(5)
    end
end)

RegisterNetEvent('gastor:motel:client:enterMotelRoom')
AddEventHandler('gastor:motel:client:enterMotelRoom', function()
    local player = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(600)
    FreezeEntityPosition(player, true)
    SetEntityCoords(player, roomCoord.x, roomCoord.y, roomCoord.z-1.0)
    SetEntityHeading(player, roomHeading)
    Wait(1400)
    inroom = true
    DoScreenFadeIn(1000)
    repeat
        Citizen.Wait(10)
	until (IsControlJustPressed(0, 32) or IsControlJustPressed(0, 33) or IsControlJustPressed(0, 34) or IsControlJustPressed(0, 35))

    FreezeEntityPosition(player, false)
end)

RegisterNetEvent('gastor:motel:client:exitMotelRoom')
AddEventHandler('gastor:motel:client:exitMotelRoom', function()
    local player = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(1500)
    SetEntityCoords(player, pinkcage[currentmotel].x, pinkcage[currentmotel].y, pinkcage[currentmotel].z-1)
    Wait(500)
    inroom = false
    DoScreenFadeIn(1000)
end)

function OpenMotelWardrobe()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room',{
		title    = 'Gardrop',
		align    = 'right',
		elements = {
            {label = 'Kıyafetler', value = 'player_dressing'},
	        {label = 'Kıyafet Sil', value = 'remove_cloth'}
        }
	}, function(data, menu)

		if data.current.value == 'player_dressing' then 
            menu.close()
			ESX.TriggerServerCallback('gastor:motel:server:getPlayerDressing', function(dressing)
				elements = {}

				for i=1, #dressing, 1 do
					table.insert(elements, {
						label = dressing[i],
						value = i
					})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing',
				{
					title    = 'Kıyafetler',
					align    = 'right',
					elements = elements
				}, function(data2, menu2)

					TriggerEvent('skinchanger:getSkin', function(skin)
						ESX.TriggerServerCallback('gastor:motel:server:getPlayerOutfit', function(clothes)
							TriggerEvent('skinchanger:loadClothes', skin, clothes)
							TriggerEvent('esx_skin:setLastSkin', skin)

							TriggerEvent('skinchanger:getSkin', function(skin)
								TriggerServerEvent('esx_skin:save', skin)
							end)
						end, data2.current.value)
					end)

				end, function(data2, menu2)
					menu2.close()
				end)
			end)

		elseif data.current.value == 'remove_cloth' then
            menu.close()
			ESX.TriggerServerCallback('gastor:motel:server:getPlayerDressing', function(dressing)
				elements = {}

				for i=1, #dressing, 1 do
					table.insert(elements, {
						label = dressing[i],
						value = i
					})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'remove_cloth', {
					title    = 'Kıyafet Sil',
					align    = 'right',
					elements = elements
				}, function(data2, menu2)
					menu2.close()
					TriggerServerEvent('gastor:motel:server:removeOutfit', data2.current.value)
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'inform', text = 'Kıyafet silindi!'})
				end, function(data2, menu2)
					menu2.close()
				end)
			end)
		end
	end, function(data, menu)
        menu.close()
	end)
end

function OpenMotelInventory()
    TriggerEvent('m3:inventoryhud:client:openStash', 'Pinkcage Motel', 'all')
end

function notify(type, text, time)
    if length == nil then length = 5000 end 
    TriggerEvent('mythic_notify:client:SendAlert', { type = type, text = text, length = length})
end

function DrawText3D(coord, text)
	local onScreen,_x,_y=GetScreenCoordFromWorldCoord(coord.x, coord.y, coord.z)
	local px,py,pz=table.unpack(GetGameplayCamCoords()) 
	local scale = 0.3
	if onScreen then
		SetTextScale(scale, scale)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextDropshadow(0)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 380
        DrawRect(_x, _y + 0.0120, 0.0 + factor, 0.025, 41, 11, 41, 100)
	end
end