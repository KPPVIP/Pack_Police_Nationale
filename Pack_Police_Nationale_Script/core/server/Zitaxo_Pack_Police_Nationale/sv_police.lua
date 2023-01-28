ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--TriggerEvent('esx_phone:registerNumber', 'police', 'alerte police', true, true) --- Si vous avez un GCPHONE

TriggerEvent('esx_society:registerSociety', 'pn', 'pn', 'society_pn', 'society_pn', 'society_pn', {type = 'public'})

ESX.RegisterServerCallback('zPN:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pn', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('zPN:getStockItem')
AddEventHandler('zPN:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pn', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, 'Vous avez retiré ~r~'..inventoryItem.label.." x"..count)
		else
			TriggerClientEvent('esx:showNotification', _source, "Quantité invalide")
		end
	end)
end)

ESX.RegisterServerCallback('zPN:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

RegisterNetEvent('zPN:putStockItems')
AddEventHandler('zPN:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pn', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			xPlayer.showNotification('Vous avez déposé ~g~'..inventoryItem.label.." x"..count)
		else
			TriggerClientEvent('esx:showNotification', _source, "Quantité invalide")
		end
	end)
end)

RegisterNetEvent('zPN:arsenal')
AddEventHandler('zPN:arsenal', function(item,price)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xMoney = xPlayer.getMoney()

    if xMoney >= price then
        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem(item, 1)
        TriggerClientEvent('esx:showNotification', source, "~g~Achats~w~ effectué !")
    else
         TriggerClientEvent('esx:showNotification', source, "Vous n'avez assez ~r~d\'argent")
    end
end)

RegisterNetEvent('zPN:arsenalvide')
AddEventHandler('zPN:arsenalvide', function()

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
	for k,v in pairs(zPN.arsenal.arme) do
		xPlayer.removeWeapon(v.Name)
	end
	TriggerClientEvent('esx:showNotification', source, "Vous avez posé tous vos armes")
end)

RegisterServerEvent('pn:PriseEtFinservice')
AddEventHandler('pn:PriseEtFinservice', function(PriseOuFin)
	local _source = source
	local _raison = PriseOuFin
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()
	local name = xPlayer.getName(_source)

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'pn' then
			TriggerClientEvent('pn:InfoService', xPlayers[i], _raison, name)
		end
	end
end)

RegisterServerEvent('renfort')
AddEventHandler('renfort', function(coords, raison)
	local _source = source
	local _raison = raison
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'pn' then
			TriggerClientEvent('renfort:setBlip', xPlayers[i], coords, _raison)
		end
	end
end)


ESX.RegisterServerCallback('zPN:getVehicleInfos', function(source, cb, plate)

	MySQL.Async.fetchAll('SELECT owner, vehicle FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)

		local retrivedInfo = {
			plate = plate
		}

		if result[1] then
			MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier',  {
				['@identifier'] = result[1].owner
			}, function(result2)

				retrivedInfo.owner = result2[1].firstname .. ' ' .. result2[1].lastname

				retrivedInfo.vehicle = json.decode(result[1].vehicle)

				cb(retrivedInfo)

			end)
		else
			cb(retrivedInfo)
		end
	end)
end)


RegisterNetEvent('gaming:plainte')
AddEventHandler('gaming:plainte', function(msg)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	sendToDiscordWithSpecialURL("Plaintes en ligne","**Plainte reçue de: __"..xPlayer.getName().."__**:\n\n"..msg, 16744192, zPN.Webhookplainte)
	TriggerClientEvent('esx:showNotification', source, "Votre plainte à bien été envoyé !")
end)

RegisterNetEvent('zPN:prisedeservice')
AddEventHandler('zPN:prisedeservice', function()
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	sendToDiscordWithSpecialURL("Prise de service",xPlayer.getName().." à prise son service", 16744192, zPN.Webhookservice)
end)

RegisterNetEvent('zPN:quitteleservice')
AddEventHandler('zPN:quitteleservice', function()
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	sendToDiscordWithSpecialURL("Fin de service",xPlayer.getName().." à quitter son service", 16744192, zPN.Webhookservice)
end)

function sendToDiscordWithSpecialURL(name,message,color,url)
    local DiscordWebHook = url
	local embeds = {
		{
			["title"]=message,
			["type"]="rich",
			["color"] =color,
			["footer"]=  {
			["text"]= "Zitaxo",
			},
		}
	}
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end


--DOUANE

RegisterNetEvent('zPN:arsenald')
AddEventHandler('zPN:arsenald', function(item,price)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xMoney = xPlayer.getMoney()

    if xMoney >= price then
        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem(item, 1)
        TriggerClientEvent('esx:showNotification', source, "~g~Achats~w~ effectué !")
    else
         TriggerClientEvent('esx:showNotification', source, "Vous n'avez assez ~r~d\'argent")
    end
end)

RegisterNetEvent('zPN:arsenaldvide')
AddEventHandler('zPN:arsenaldvide', function()

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
	for k,v in pairs(zPN.arsenal.douane) do
		xPlayer.removeInventoryItem(v.Name)
	end
	TriggerClientEvent('esx:showNotification', source, "Vous avez posé tous vos armes")
end)


--BAC

RegisterNetEvent('zPN:arsenalb')
AddEventHandler('zPN:arsenalb', function(item,price)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xMoney = xPlayer.getMoney()

    if xMoney >= price then
        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem(item, 1)
        TriggerClientEvent('esx:showNotification', source, "~g~Achats~w~ effectué !")
    else
         TriggerClientEvent('esx:showNotification', source, "Vous n'avez assez ~r~d\'argent")
    end
end)

RegisterNetEvent('zPN:arsenalbvide')
AddEventHandler('zPN:arsenalbvide', function()

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
	for k,v in pairs(zPN.arsenal.vac) do
		xPlayer.removeInventoryItem(v.Name)
	end
	TriggerClientEvent('esx:showNotification', source, "Vous avez posé tous vos armes")
end)