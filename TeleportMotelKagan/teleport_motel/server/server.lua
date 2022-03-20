local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local motels = {}
RegisterServerEvent('gastor:motel:server:enterMotelRoom')
AddEventHandler('gastor:motel:server:enterMotelRoom', function()
    local src = source

    local bucket = getFirstBucket()
    if bucket < 64 then
        motels[src] = bucket
        SetPlayerRoutingBucket(src, motels[src])
        TriggerClientEvent('gastor:motel:client:enterMotelRoom', src)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = "inform", text = "Motel odası dolu!"})
    end
end)

function getFirstBucket()
    local i = 1
    repeat
        local founded = false
        for k, v in pairs(motels) do
            if motels[k] == i then
                founded = true
                i=i+1
                break
            end
        end
    until not founded
    return i
end

RegisterServerEvent('gastor:motel:server:exitMotelRoom')
AddEventHandler('gastor:motel:server:exitMotelRoom', function()
    local src = source
    motels[src] = nil
    SetPlayerRoutingBucket(src, 0)
    TriggerClientEvent('gastor:motel:client:exitMotelRoom', src)
end)

RegisterServerEvent('gastor:motel:server:removeOutfit')
AddEventHandler('gastor:motel:server:removeOutfit', function(label)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
        local dressing = store.get('dressing')
        if dressing == nil then
            dressing = {}
        end
        label = label
        table.remove(dressing, label)
        store.set('dressing', dressing)
    end)
end)

ESX.RegisterServerCallback('gastor:motel:server:getPlayerDressing', function(source, cb)
	local xPlayer  = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local count  = store.count('dressing')
		local labels = {}

		for i=1, count, 1 do
			local entry = store.get('dressing', i)
			table.insert(labels, entry.label)
		end

		cb(labels)
	end)
end)

ESX.RegisterServerCallback('gastor:motel:server:getPlayerOutfit', function(source, cb, num)
	local xPlayer  = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local outfit = store.get('dressing', num)
		cb(outfit.skin)
	end)
end)

ESX.RegisterServerCallback('gastor:motel:server:getIdentifier', function(source, cb, num)
	cb(GetPlayerIdentifiers(source)[1])
end)

AddEventHandler('playerDropped', function(_)
    motels[source] = nil
end)