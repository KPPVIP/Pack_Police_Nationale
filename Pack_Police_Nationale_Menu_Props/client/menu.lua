ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(5000)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RMenu.Add('Police', 'main', RageUI.CreateMenu("Menu Props", " "))
RMenu:Get('Police', 'main'):SetSubtitle("Intéraction")
RMenu:Get('Police', 'main').EnableMouse = false
RMenu:Get('Police', 'main').Closed = function()
    -- TODO Perform action
end;


RMenu.Add('Police', 'object4', RageUI.CreateSubMenu(RMenu:Get('Police', 'main'), "Props", "Intéraction"))
RMenu.Add('Police', 'objectlist', RageUI.CreateSubMenu(RMenu:Get('Police', 'main'), "Suppression d'objets", "Intéraction"))

object = {}
OtherItems = {}local inventaire = false
local status = true

RageUI.CreateWhile(1.0, function()

    if RageUI.Visible(RMenu:Get('Police', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()

            RageUI.Button("Props", "Appuyer sur [~g~E~w~] pour poser les objets", { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('Police', 'object4'))

            RageUI.Button("Suppression", "Supprimer des objets", { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('Police', 'objectlist'))

        end, function()
            ---Panels
        end)
    end

-- Police
    if RageUI.Visible(RMenu:Get('Police', 'object4')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()

            RageUI.Button("Balisage", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_num_0")
                end
            end)
            RageUI.Button("Panneau Droit", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_num_1")
                end
            end)
            RageUI.Button("Cone", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_roadcone02b")
                end
            end)
            RageUI.Button("Panneau Gauche", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_num_2")
                end
            end)

            RageUI.Button("Panneau Gendarme", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_num_3")
                end
            end)

            RageUI.Button("Panneau Stop", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_num_4")
                end
            end)

            RageUI.Button("Panneau innondation", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_num_5")
                end
            end)

            RageUI.Button("Route barré", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_num_6")
                end
            end)

            RageUI.Button("Barrieres simple", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_barrier_02b")
                end
            end)

            RageUI.Button("Barriere route barré", "Appuyer sur [~g~E~w~] pour poser les objets", {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_mp_barrier_02")
                end
            end)

        end, function()
            ---Panels
        end)
    end

    if RageUI.Visible(RMenu:Get('Police', 'objectlist')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()

            for k,v in pairs(object) do
                if GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v))) == 0 then table.remove(object, k) end
                RageUI.Button("Object: "..GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v))).." ["..v.."]", nil, {}, true, function(Hovered, Active, Selected)
                    if Active then
                        local entity = NetworkGetEntityFromNetworkId(v)
                        local ObjCoords = GetEntityCoords(entity)
                        DrawMarker(0, ObjCoords.x, ObjCoords.y, ObjCoords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 170, 1, 0, 2, 1, nil, nil, 0)
                    end
                    if Selected then
                        RemoveObj(v, k)
                    end
                end)
            end
            
        end, function()
            ---Panels
        end)
    end

end, 1)

RegisterCommand('props', function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' or ESX.PlayerData.job.name == 'gn' or ESX.PlayerData.job.name == 'pm' or ESX.PlayerData.job.name == 'sp' or ESX.PlayerData.job.name == 'samu' then
    RageUI.Visible(RMenu:Get('Police', 'main'), true)
else
    ESX.ShowNotification("Vous n'êtes pas policier pour utiliser cette commande")
end
end, false)
