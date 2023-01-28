ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local PlayerData = {}
local Itbosspolicenationale = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then

		ESX.PlayerData = ESX.GetPlayerData()

    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


function Itbossypolicenationale()
    local policenationale = RageUI.CreateMenu("Police Nationale", "Menu Intéraction..")
      RageUI.Visible(policenationale, not RageUI.Visible(policenationale))
  
              while policenationale do
                  Citizen.Wait(0)
                      RageUI.IsVisible(policenationale, true, true, true, function()
  
            if Itbosspolicenationale ~= nil then
                RageUI.ButtonWithStyle("Argent société :", nil, {RightLabel = "$" .. Itbosspolicenationale}, true, function()
                end)
            end

            RageUI.ButtonWithStyle("Retirer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if Selected then
                    local amount = KeyboardInput("Montant", "", 10)
                    amount = tonumber(amount)
                    if amount == nil then
                        RageUI.Popup({message = "Montant invalide"})
                    else
                        TriggerServerEvent('esx_society:withdrawMoney', 'pn', amount)
                        RefreshItbosspolicenationale()
                    end
                end
            end)

            RageUI.ButtonWithStyle("Déposer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if Selected then
                    local amount = KeyboardInput("Montant", "", 10)
                    amount = tonumber(amount)
                    if amount == nil then
                        RageUI.Popup({message = "Montant invalide"})
                    else
                        TriggerServerEvent('esx_society:depositMoney', 'pn', amount)
                        RefreshItbosspolicenationale()
                    end
                end
            end) 

      --     RageUI.ButtonWithStyle("Accéder aux actions de Management",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
         --       if Selected then
         --           aboss()
          --          RageUI.CloseAll()
          --      end
          --  end)


        end, function()
        end)
        if not RageUI.Visible(policenationale) then
            policenationale = RMenu:DeleteType("policenationale", true)
    end
end
end


local position = {

    {x = 456.95, y = -994.11, z = 30.72}

}

Citizen.CreateThread(function()
    while true do

      local wait = 750

        for k in pairs(position) do
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' and ESX.PlayerData.job.grade_name == 'boss' then 
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, position[k].x, position[k].y, position[k].z)
            DrawMarker(22,  456.95, -994.11, 30.72, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.3, 0.3, 0.3, 255, 0, 0 , 255, true, true, p19, true)

            if dist <= 5.0 then
            wait = 0
        
            if dist <= 1.0 then
               wait = 0
			   RageUI.Text({

				message = "Appuyez sur [~r~E~w~] pour accéder au panel administratif",
	
				time_display = 1
	
			})
                if IsControlJustPressed(1,51) then
                    RefreshItbosspolicenationale()           
                    Itbossypolicenationale()
            end
        end
    end
    end
    Citizen.Wait(wait)
    end
end
end)

function RefreshItbosspolicenationale()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            UpdateItbosspolicenationale(money)
        end, ESX.PlayerData.job.name)
    end
end

function UpdateItbosspolicenationale(money)
    Itbosspolicenationale = ESX.Math.GroupDigits(money)
end

function aboss()
    TriggerEvent('esx_society:openBossMenu', 'pn', function(data, menu)
        menu.close()
    end, {wash = false})
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

