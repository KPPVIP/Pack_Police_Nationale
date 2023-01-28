ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local PlayerData = {}
local service = false
local bouclier = false

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

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    ESX.PlayerData.job2 = job2
end)

Citizen.CreateThread(function()
    local pnmap = AddBlipForCoord(zPN.pos.blips.position.x, zPN.pos.blips.position.y, zPN.pos.blips.position.z)
    SetBlipSprite(pnmap, 124)
    SetBlipColour(pnmap, 0)
    SetBlipScale(pnmap, 0.65)
    SetBlipAsShortRange(pnmap, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Police Nationale")
    EndTextCommandSetBlipName(pnmap)
end)

function Menuf6pn()
    local zPNf5 = RageUI.CreateMenu("Police Nationale", "Interactions")
    local zPNf5Renfort = RageUI.CreateSubMenu(zPNf5, "Police Nationale", "Renfort")
    --local zPNf5Soutien = RageUI.CreateSubMenu(zPNf5, "Police Nationale", "Soutien")
    local zPNf5Chien = RageUI.CreateSubMenu(zPNf5, "Police Nationale", "Chien")
    RageUI.Visible(zPNf5, not RageUI.Visible(zPNf5))
    while zPNf5 do
        Citizen.Wait(0)
            RageUI.IsVisible(zPNf5, true, true, true, function()

                RageUI.Checkbox("Prendre/Quitter son service",nil, service,{},function(Hovered,Ative,Selected,Checked)
                    if Selected then

                        service = Checked

                        if Checked then
                            etatservice = true
                            RageUI.Popup({message = "Vous avez pris votre service !"})
                            TriggerServerEvent('zPN:prisedeservice')
                        else
                            etatservice = false
                            RageUI.Popup({message = "Vous avez quitter votre service !"})
                            TriggerServerEvent('zPN:quitteleservice')
                        end
                    end
                end)

                if etatservice then

                RageUI.Separator("~r~"..ESX.PlayerData.job.grade_label.." - "..GetPlayerName(PlayerId()))


                RageUI.ButtonWithStyle("Facture / Amende",nil, {RightLabel = "→"}, true, function(_,_,s)
                    local player, distance = ESX.Game.GetClosestPlayer()
                    if s then
                        local raison = ""
                        local montant = 0
                        AddTextEntry("FMMC_MPM_NA", "Objet de la facture")
                        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Donnez le motif de la facture :", "", "", "", "", 30)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0)
                            Wait(0)
                        end
                        if (GetOnscreenKeyboardResult()) then
                            local result = GetOnscreenKeyboardResult()
                            if result then
                                raison = result
                                result = nil
                                AddTextEntry("FMMC_MPM_NA", "Montant de la facture")
                                DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Indiquez le montant de la facture :", "", "", "", "", 30)
                                while (UpdateOnscreenKeyboard() == 0) do
                                    DisableAllControlActions(0)
                                    Wait(0)
                                end
                                if (GetOnscreenKeyboardResult()) then
                                    result = GetOnscreenKeyboardResult()
                                    if result then
                                        montant = result
                                        result = nil
                                        if player ~= -1 and distance <= 3.0 then
                                            TriggerServerEvent('esx_billing:sendBill1', GetPlayerServerId(player), 'society_pn', ('Police Nationale'), montant)
                                            TriggerEvent('esx:showAdvancedNotification', 'Fl~g~ee~s~ca ~g~Bank', 'Facture envoyée : ', 'Vous avez envoyé une facture d\'un montant de : ~g~'..montant.. '$ ~s~pour cette raison : ~b~' ..raison.. '', 'CHAR_BANK_FLEECA', 9)
                                        else
                                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)

            RageUI.ButtonWithStyle("Interagir avec le citoyen",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then                
                    TriggerEvent('fellow:MenuFouille')
                end
            end)

    if ESX.PlayerData.job.grade_name == 'boss' then
        RageUI.ButtonWithStyle("Donner le PPA", "Pour donner le permis port d'arme à quelqu'un", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if (Selected) then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'weapon')
                    ESX.ShowNotification('Vous avez donner le ppa')
             else
                ESX.ShowNotification('Aucun joueurs à proximité')
            end
        end
        end)
    end
                  RageUI.Separator('~r~↓ Intéractions sur véhicules ↓')

            RageUI.ButtonWithStyle("Mettre véhicule en fourriere",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                        local playerPed = PlayerPedId()

                        if IsPedSittingInAnyVehicle(playerPed) then
                            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
                            if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                                ESX.ShowNotification('la voiture a été mis en fourrière')
                                ESX.Game.DeleteVehicle(vehicle)
                               
                            else
                                ESX.ShowNotification('Mais toi place conducteur, ou sortez de la voiture.')
                            end
                        else
                            local vehicle = ESX.Game.GetVehicleInDirection()
            
                            if DoesEntityExist(vehicle) then
                                TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CLIPBOARD', 0, true)
                                Citizen.Wait(5000)
                                ClearPedTasks(playerPed)
                                ESX.ShowNotification('La voiture à été placer en fourriere.')
                                ESX.Game.DeleteVehicle(vehicle)
            
                            else
                                ESX.ShowNotification('Aucune voitures autour')
                            end
                        end
                        end
                    end)



                RageUI.ButtonWithStyle("Poser/Prendre Radar",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        RageUI.CloseAll()       
                        TriggerEvent('pn:PN_radar')
                    end
                end)

                  RageUI.Separator('~r~↓ Autres ↓')

                  RageUI.Checkbox("Bouclier",nil, bouclier,{},function(Hovered,Ative,Selected,Checked)
                    if Selected then
    
                        bouclier = Checked
    
    
                        if Checked then
                            EnableShield()
                            
                        else
                            DisableShield()
                        end
                    end
                end)


                RageUI.ButtonWithStyle("Menu Chien", nil,  {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                end, zPNf5Chien)

                  RageUI.ButtonWithStyle("Menu Props",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ExecuteCommand('props')
                            RageUI.CloseAll()
                        end
                    end)
				
		          RageUI.ButtonWithStyle("Demande de renfort", nil,  {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                  end, zPNf5Renfort)
                  
                --  RageUI.ButtonWithStyle("Soutien Police Nationale", nil,  {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                --  end, zPNf5Soutien)
                end

                end, function() 
                end)

                RageUI.IsVisible(zPNf5Renfort, true, true, true, function()

                    RageUI.ButtonWithStyle("Petite demande",nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local raison = 'petit'
                            local elements  = {}
                            local playerPed = PlayerPedId()
                            local coords  = GetEntityCoords(playerPed)
                            local name = GetPlayerName(PlayerId())
                        TriggerServerEvent('renfort', coords, raison)
                    end
                end)
            
                RageUI.ButtonWithStyle("Moyenne demande",nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local raison = 'importante'
                        local elements  = {}
                        local playerPed = PlayerPedId()
                        local coords  = GetEntityCoords(playerPed)
                        local name = GetPlayerName(PlayerId())
                    TriggerServerEvent('renfort', coords, raison)
                end
            end)
            
            RageUI.ButtonWithStyle("Grosse demande",nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    local raison = 'omgad'
                    local elements  = {}
                    local playerPed = PlayerPedId()
                    local coords  = GetEntityCoords(playerPed)
                    local name = GetPlayerName(PlayerId())
                TriggerServerEvent('renfort', coords, raison)
            end
            end)
            
                end, function()
                end)

                RageUI.IsVisible(zPNf5Soutien, true, true, true, function()

                    RageUI.ButtonWithStyle("Émeute de sécurité",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            SpawnVehicle1()
                        end
                        end)
            
                    RageUI.ButtonWithStyle("Moto de sécurité",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            SpawnVehicle2()
                        end
                        end)
                    RageUI.ButtonWithStyle("Camion de sécurité",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            SpawnVehicle3()
                        end
                        end)
                    RageUI.ButtonWithStyle("Vélo de sécurité",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            SpawnVehicle4()
                        end
                        end)
            
                    RageUI.ButtonWithStyle("Sécurité Hélico",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        SpawnVehicle5()
                    end
                    end)
            
                    RageUI.ButtonWithStyle("Donne des armes",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                        GiveWeaponToPed(chasePed, zPN.weapon1, 250, false, true)
                        GiveWeaponToPed(chasePed2, zPN.weapon2, 250, false, true)
                        GiveWeaponToPed(chasePed3, zPN.weapon3, 250, false, true)
                        GiveWeaponToPed(chasePed4, zPN.weapon4, 250, false, true)
                    end
                end)
            
                RageUI.ButtonWithStyle("Attaque le joueur le plus proche",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        closestPlayer = ESX.Game.GetClosestPlayer()
                        target = GetPlayerPed(closestPlayer)
                        TaskShootAtEntity(chasePed, target, 60, 0xD6FF6D61);
                        TaskCombatPed(chasePed, target, 0, 16)
                        SetEntityAsMissionEntity(chasePed, true, true)
                        SetPedHearingRange(chasePed, 15.0)
                        SetPedSeeingRange(chasePed, 15.0)
                        SetPedAlertness(chasePed, 15.0)
                        SetPedFleeAttributes(chasePed, 0, 0)
                        SetPedCombatAttributes(chasePed, 46, true)
                        SetPedFleeAttributes(chasePed, 0, 0)
                        TaskShootAtEntity(chasePed2, target, 60, 0xD6FF6D61);
                        TaskCombatPed(chasePed2, target, 0, 16)
                        SetEntityAsMissionEntity(chasePed2, true, true)
                        SetPedHearingRange(chasePed2, 15.0)
                        SetPedSeeingRange(chasePed2, 15.0)
                        SetPedAlertness(chasePed2, 15.0)
                        SetPedFleeAttributes(chasePed2, 0, 0)
                        SetPedCombatAttributes(chasePed2, 46, true)
                        SetPedFleeAttributes(chasePed2, 0, 0) 
                        TaskShootAtEntity(chasePed3, target, 60, 0xD6FF6D61);
                        TaskCombatPed(chasePed3, target, 0, 16)
                        SetEntityAsMissionEntity(chasePed3, true, true)
                        SetPedHearingRange(chasePed3, 15.0)
                        SetPedSeeingRange(chasePed3, 15.0)
                        SetPedAlertness(chasePed3, 15.0)
                        SetPedFleeAttributes(chasePed3, 0, 0)
                        SetPedCombatAttributes(chasePed3, 46, true)
                        SetPedFleeAttributes(chasePed3, 0, 0)  
                        TaskShootAtEntity(chasePed4, target, 60, 0xD6FF6D61);
                        TaskCombatPed(chasePed4, target, 0, 16)
                        SetEntityAsMissionEntity(chasePed4, true, true)
                        SetPedHearingRange(chasePed4, 15.0)
                        SetPedSeeingRange(chasePed4, 15.0)
                        SetPedAlertness(chasePed4, 15.0)
                        SetPedFleeAttributes(chasePed4, 0, 0)
                        SetPedCombatAttributes(chasePed4, 46, true)
                        SetPedFleeAttributes(chasePed4, 0, 0)
                end
            end)
            
                RageUI.ButtonWithStyle("Suivez-moi",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        local playerPed = PlayerPedId()
                        TaskVehicleFollow(chasePed, chaseVehicle, playerPed, 50.0, 1, 5)
                        TaskVehicleFollow(chasePed2, chaseVehicle2, playerPed, 50.0, 1, 5)
                        TaskVehicleFollow(chasePed3, chaseVehicle3, playerPed, 50.0, 1, 5)
                        TaskVehicleFollow(chasePed4, chaseVehicle4, playerPed, 50.0, 1, 5)
                        TaskVehicleFollow(chasePed5, chaseVehicle5, playerPed, 50.0, 1, 5)
                        PlayAmbientSpeech1(chasePed, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
                        PlayAmbientSpeech1(chasePed2, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
                        PlayAmbientSpeech1(chasePed3, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
                        PlayAmbientSpeech1(chasePed4, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
                        PlayAmbientSpeech1(chasePed5, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
                end
            end)
            
                RageUI.ButtonWithStyle("Supprimer",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        local playerPed = PlayerPedId()
                        DeleteVehicle(chaseVehicle)
                        DeletePed(chasePed)
                        DeleteVehicle(chaseVehicle2)
                        DeletePed(chasePed2)
                        DeleteVehicle(chaseVehicle3)
                        DeletePed(chasePed3)
                        DeleteVehicle(chaseVehicle4)
                        DeletePed(chasePed4)
                        DeleteVehicle(chaseVehicle5)
                        DeletePed(chasePed5)
                end
            end)
            
            end, function()
            end)


            RageUI.IsVisible(zPNf5Chien, true, true, true, function()

                RageUI.ButtonWithStyle("Sortir/Rentrer le chien",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if not DoesEntityExist(PNDog) then
                            RequestModel(351016938)
                            while not HasModelLoaded(351016938) do Wait(0) end
                            PNDog = CreatePed(4, 351016938, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, -0.98), 0.0, true, false)
                            SetEntityAsMissionEntity(PNDog, true, true)
                            ESX.ShowNotification('~g~Chien Spawn')
                        else
                            ESX.ShowNotification('~r~Chien Rentrer')
                            DeleteEntity(PNDog)
                        end
                    end
                end)

              

            RageUI.ButtonWithStyle("Suis-moi",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local playerPed = PlayerPedId()
                    if DoesEntityExist(PNDog) then
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(PNDog), true) <= 5.0 then
                            TaskGoToEntity(PNDog, playerPed, -1, 1.0, 10.0, 1073741824, 1)
                        else
                            ESX.ShowNotification('~r~Le chien est trop loin de vous !')
                        end
                    else
                        ESX.ShowNotification('~r~Vous n\'avez pas de chien !')
                    end
                end
            end)
            end, function()
            end)
                if not RageUI.Visible(zPNf5) and not RageUI.Visible(zPNf5Renfort) and not RageUI.Visible(zPNf5Soutien) and not RageUI.Visible(zPNf5Chien) then
                    zPNf5 = RMenu:DeleteType("Police Nationale", true)
        end
    end
end


Keys.Register('F6', 'Police', 'Ouvrir le menu Police', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
    	Menuf6pn()
	end
end)

function Rechercherplaquevoiture(plaquerechercher)
    local PlaqueMenu = RageUI.CreateMenu("plaque d'immatriculation", "Informations")
    ESX.TriggerServerCallback('zPN:getVehicleInfos', function(retrivedInfo)
    RageUI.Visible(PlaqueMenu, not RageUI.Visible(PlaqueMenu))
        while PlaqueMenu do
            Citizen.Wait(0)
                RageUI.IsVisible(PlaqueMenu, true, true, true, function()
                    local hashvoiture = retrivedInfo.vehicle.model
                    local nomvoituremodele = GetDisplayNameFromVehicleModel(hashvoiture)
                    local nomvoituretexte  = GetLabelText(nomvoituremodele)
                            RageUI.ButtonWithStyle("Numéro de plaque : ", nil, {RightLabel = retrivedInfo.plate}, true, function(Hovered, Active, Selected)
                                if Selected then
                                end
                            end)

                            if not retrivedInfo.owner then
                                RageUI.ButtonWithStyle("Propriétaire : ", nil, {RightLabel = "Inconnu"}, true, function(Hovered, Active, Selected)
                                    if Selected then
                                    end
                                end)
                            else
                                RageUI.ButtonWithStyle("Propriétaire : ", nil, {RightLabel = retrivedInfo.owner}, true, function(Hovered, Active, Selected)
                                    if Selected then
                                    end
                                end)
                                
                                RageUI.ButtonWithStyle("Modèle du véhicule : ", nil, {RightLabel = nomvoituretexte}, true, function(Hovered, Active, Selected)
                                    if Selected then
                                    end
                                end)
                            end
                end, function()
                end)
            if not RageUI.Visible(PlaqueMenu) then
            PlaqueMenu = RMenu:DeleteType("plaque d'immatriculation", true)
        end
    end
end, plaquerechercher)
end

function OpenPrendreMenuPN()
    local PrendreMenu = RageUI.CreateMenu("Police Nationale", "Arsenal")
        RageUI.Visible(PrendreMenu, not RageUI.Visible(PrendreMenu))
    while PrendreMenu do
        Citizen.Wait(0)
            RageUI.IsVisible(PrendreMenu, true, true, true, function()

            RageUI.ButtonWithStyle("Déposer les armes",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                    TriggerServerEvent('zPN:arsenalvide')
                end
            end)

            RageUI.Separator('~r~↓ Voici les armes disponible ↓')

            for k,v in pairs(zPN.arsenal.arme) do
                RageUI.ButtonWithStyle(v.Label.. ' Prix: ' .. v.Price .. '€', nil, { RightBadge = RageUI.BadgeStyle.Gun }, true, function(Hovered, Active, Selected)
                  if (Selected) then
                      TriggerServerEvent('zPN:arsenal', v.Name, v.Price)
                    end
                end)
            end
                end, function() 
                end)
    
                if not RageUI.Visible(PrendreMenu) then
                    PrendreMenu = RMenu:DeleteType("Police", true)
        end
    end
end


Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.MenuPrendre.position.x, zPN.pos.MenuPrendre.position.y, zPN.pos.MenuPrendre.position.z)
        if dist3 <= 7.0 and zPN.jeveuxmarker then
            Timer = 0
            DrawMarker(20, zPN.pos.MenuPrendre.position.x, zPN.pos.MenuPrendre.position.y, zPN.pos.MenuPrendre.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
            end
            if dist3 <= 2.0 then
                Timer = 0   
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder à l'arsenal", time_display = 1 })
                        if IsControlJustPressed(1,51) then           
                            OpenPrendreMenuPN()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)

function Coffrepn()
    local Cpn = RageUI.CreateMenu("Coffre", "Police Nationale")
        RageUI.Visible(Cpn, not RageUI.Visible(Cpn))
            while Cpn do
            Citizen.Wait(0)
            RageUI.IsVisible(Cpn, true, true, true, function()

                RageUI.Separator("~y~↓ Objet ↓")

                    RageUI.ButtonWithStyle("Retirer",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            PNRetirerobjet()
                            RageUI.CloseAll()
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Déposer",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            PNDeposerobjet()
                            RageUI.CloseAll()
                        end
                    end)
                end, function()
                end)
            if not RageUI.Visible(Cpn) then
            Cpn = RMenu:DeleteType("Cpn", true)
        end
    end
end

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, zPN.pos.coffre.position.x, zPN.pos.coffre.position.y, zPN.pos.coffre.position.z)
            if jobdist <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.coffre.position.x, zPN.pos.coffre.position.y, zPN.pos.coffre.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au coffre", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                        Coffrepn()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)


--- vestiaire


function vestiairepn()
    local Vpn = RageUI.CreateMenu("Vestiaire", "Police Nationale")
        RageUI.Visible(Vpn, not RageUI.Visible(Vpn))
            while Vpn do
            Citizen.Wait(0)
            RageUI.IsVisible(Vpn, true, true, true, function()
                RageUI.Separator("~y~↓ Votre Tenue ↓")
                if ESX.PlayerData.job.name == 'pn' then
                    RageUI.ButtonWithStyle("Tenue Cérémonie",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_ceremoniepn()
                        end
                    end)
                end
                if ESX.PlayerData.job.name == 'pn' then
                    RageUI.ButtonWithStyle("Tenue Manche Courte",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_lspd()
                        end
                    end)
                end                
                if ESX.PlayerData.job.name == 'pn' then
                    RageUI.ButtonWithStyle("Tenue Manche Longue",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_long()
                        end
                    end)
                end
                if ESX.PlayerData.job.name == 'pn' then
                    RageUI.ButtonWithStyle("Tenue BMO",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_doag1()
                        end
                    end)
                end
                if ESX.PlayerData.job.name == 'pn' then
                    RageUI.ButtonWithStyle("Tenue CRS",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_hiv()
                        end
                    end)
                end
                RageUI.ButtonWithStyle("Tenu BRI",nil, {nil}, true, function(Hovered, Active, Selected)
                    if Selected then
                        tenu_bri()
                        SetPedArmour(GetPlayerPed(-1), 100)
                    end
                end)

                    RageUI.ButtonWithStyle("Remettre sa tenue",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            vcivil_pn()
                            RageUI.CloseAll()
                        end
                    end)

            RageUI.Separator("~g~↓ Gilet par balle ↓")

            RageUI.ButtonWithStyle("Gilet Leger",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    bullet_wear()
                    SetPedArmour(GetPlayerPed(-1), 50)
                end
            end)
            RageUI.ButtonWithStyle("Gilet Lourd Tenue Manche Courte",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    bullet5_wear()
                    SetPedArmour(GetPlayerPed(-1), 100)
                end
            end)
            RageUI.ButtonWithStyle("Gilet Lourd Tenue Manche Longue",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    bullet1_wear()
                    SetPedArmour(GetPlayerPed(-1), 100)
                end
            end)
            RageUI.ButtonWithStyle("Gilet Jaune",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    bullet2_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)
            RageUI.ButtonWithStyle("Enlever Votre GPB",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    enleverbullet_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)

            RageUI.Separator("~g~↓ Casque ↓")

            RageUI.ButtonWithStyle("Calot",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    helmet_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)
            RageUI.ButtonWithStyle("Enlever Votre Casque",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    enlevercasque()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)



                end, function()
                end)
            if not RageUI.Visible(Vpn) then
            Vpn = RMenu:DeleteType("Vestiaire", true)
        end
    end
end

function tenu_lspd()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_lspd.male
        else
            uniformObject = zPN.Uniforms.tenu_lspd.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function tenu_ceremoniepn()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_ceremoniepn.male
        else
            uniformObject = zPN.Uniforms.tenu_ceremoniepn.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function tenu_long()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_long.male
        else
            uniformObject = zPN.Uniforms.tenu_long.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function tenu_hiv()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_hiv.male
        else
            uniformObject = zPN.Uniforms.tenu_hiv.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function tenu_doag1()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_doag1.male
        else
            uniformObject = zPN.Uniforms.tenu_doag1.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function tenu_sahp()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_sahp.male
        else
            uniformObject = zPN.Uniforms.tenu_sahp.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function bullet_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.bullet_wear.male
        else
            uniformObject = zPN.Uniforms.bullet_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function bullet2_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.bullet2_wear.male
        else
            uniformObject = zPN.Uniforms.bullet2_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function bullet4_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.bullet4_wear.male
        else
            uniformObject = zPN.Uniforms.bullet4_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function bullet5_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.bullet5_wear.male
        else
            uniformObject = zPN.Uniforms.bullet5_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function bullet1_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.bullet1_wear.male
        else
            uniformObject = zPN.Uniforms.bullet1_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function enleverbullet_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.enleverbullet_wear.male
        else
            uniformObject = zPN.Uniforms.enleverbullet_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function enlevercasque()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.enlevercasque.male
        else
            uniformObject = zPN.Uniforms.enlevercasque.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end


function helmet_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.helmet_wear.male
        else
            uniformObject = zPN.Uniforms.helmet_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end


function tenu_bri()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_bri.male
        else
            uniformObject = zPN.Uniforms.tenu_bri.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function vcivil_pn()
ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
TriggerEvent('skinchanger:loadSkin', skin)
end)
end


Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, zPN.pos.vestiaire.position.x, zPN.pos.vestiaire.position.y, zPN.pos.vestiaire.position.z)
            if jobdist <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.vestiaire.position.x, zPN.pos.vestiaire.position.y, zPN.pos.vestiaire.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au vestiaire", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                        vestiairepn()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)


--- fin



-- Garage

function Garagepn()
  local Gpn = RageUI.CreateMenu("Garage", "Police Nationale")
    RageUI.Visible(Gpn, not RageUI.Visible(Gpn))
        while Gpn do
            Citizen.Wait(0)
                RageUI.IsVisible(Gpn, true, true, true, function()
                    RageUI.ButtonWithStyle("Ranger la voiture", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                        if (Selected) then   
                        local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                        if dist4 < 4 then
                            DeleteEntity(veh)
                            RageUI.CloseAll()
                            end 
                        end
                    end) 

                    for k,v in pairs(Gpnvoiture) do
                    RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                        if (Selected) then
                        Citizen.Wait(1)  
                            spawnuniCazPN(v.modele)
                            RageUI.CloseAll()
                            end
                        end)
                    end
                end, function()
                end)
            if not RageUI.Visible(Gpn) then
            Gpn = RMenu:DeleteType("Garage", true)
        end
    end
end

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
            local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
            local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.garage.position.x, zPN.pos.garage.position.y, zPN.pos.garage.position.z)
            if dist3 <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.garage.position.x, zPN.pos.garage.position.y, zPN.pos.garage.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if dist3 <= 3.0 then
                Timer = 0   
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au garage", time_display = 1 })
                    if IsControlJustPressed(1,51) then           
                        Garagepn()
                    end   
                end
            end 
        Citizen.Wait(Timer)
     end
end)

function spawnuniCazPN(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, zPN.pos.spawnvoiture.position.x, zPN.pos.spawnvoiture.position.y, zPN.pos.spawnvoiture.position.z, zPN.pos.spawnvoiture.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = "POLICE"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque) 
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
end

function Helipn()
    local Hpn = RageUI.CreateMenu("Garage", "Police Nationale")
      RageUI.Visible(Hpn, not RageUI.Visible(Hpn))
          while Hpn do
              Citizen.Wait(0)
                  RageUI.IsVisible(Hpn, true, true, true, function()
                      RageUI.ButtonWithStyle("Ranger le hélicoptère", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then   
                          local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                          if dist4 < 4 then
                              DeleteEntity(veh)
                              RageUI.CloseAll()
                              end 
                          end
                      end) 
  
                      for k,v in pairs(Hpnheli) do
                      RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then
                          Citizen.Wait(1)  
                            spawnuniCarheli(v.modele)
                              RageUI.CloseAll()
                              end
                          end)
                      end
                  end, function()
                  end)
              if not RageUI.Visible(Hpn) then
              Hpn = RMenu:DeleteType("Garage", true)
          end
      end
end
  
Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
            local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
            local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.garageheli.position.x, zPN.pos.garageheli.position.y, zPN.pos.garageheli.position.z)
            if dist3 <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.garageheli.position.x, zPN.pos.garageheli.position.y, zPN.pos.garageheli.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if dist3 <= 3.0 then
                Timer = 0   
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au garage des hélicoptères", time_display = 1 })
                    if IsControlJustPressed(1,51) then           
                        Helipn()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)
  
function spawnuniCarheli(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, zPN.pos.spawnheli.position.x, zPN.pos.spawnheli.position.y, zPN.pos.spawnheli.position.z, zPN.pos.spawnheli.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = "POLICE"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque) 
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
end

itemstock = {}
function PNRetirerobjet()
    local Stockpn = RageUI.CreateMenu("Coffre", "Police Nationale")
    ESX.TriggerServerCallback('zPN:getStockItems', function(items) 
    itemstock = items
   
    RageUI.Visible(Stockpn, not RageUI.Visible(Stockpn))
        while Stockpn do
            Citizen.Wait(0)
                RageUI.IsVisible(Stockpn, true, true, true, function()
                        for k,v in pairs(itemstock) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = KeyboardInput("Combien ?", "", 2)
                                    TriggerServerEvent('zPN:getStockItem', v.name, tonumber(count))
                                    PNRetirerobjet()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(Stockpn) then
            Stockpn = RMenu:DeleteType("Coffre", true)
        end
    end
     end)
end



function PNDeposerobjet()
    local StockPlayer = RageUI.CreateMenu("Coffre", "Police Nationale")
    ESX.TriggerServerCallback('zPN:getPlayerInventory', function(inventory)
        RageUI.Visible(StockPlayer, not RageUI.Visible(StockPlayer))
    while StockPlayer do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayer, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                        RageUI.ButtonWithStyle(item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                            if Selected then
                                            local count = KeyboardInput("Combien ?", '' , 8)
                                            TriggerServerEvent('zPN:putStockItems', item.name, tonumber(count))
                                            PNDeposerobjet()
                                        end
                                    end)
                            end
                    end
                end
                    end, function()
                    end)
                if not RageUI.Visible(StockPlayer) then
                StockPlayer = RMenu:DeleteType("Coffre", true)
            end
        end
    end)
end



function plaintepn()
    local Ppn = RageUI.CreateMenu("Plainte", "Police Nationale")
        RageUI.Visible(Ppn, not RageUI.Visible(Ppn))
            while Ppn do
            Citizen.Wait(0)
            RageUI.IsVisible(Ppn, true, true, true, function()

                    RageUI.ButtonWithStyle("Porter plainte",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Msg = KeyboardInput("Message", '' , 50)
                            TriggerServerEvent('gaming:plainte',Msg)
                            RageUI.CloseAll()
                        end
                    end)
                end, function()
                end)
            if not RageUI.Visible(Ppn) then
            Ppn = RMenu:DeleteType("Ppn", true)
        end
    end
end


Citizen.CreateThread(function()
        while true do
            local Timer = 500
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, zPN.pos.plainte.position.x, zPN.pos.plainte.position.y, zPN.pos.plainte.position.z)
            if jobdist <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.plainte.position.x, zPN.pos.plainte.position.y, zPN.pos.plainte.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour porter plainte", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                        plaintepn()   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)

RegisterNetEvent('renfort:setBlip')
AddEventHandler('renfort:setBlip', function(coords, raison)
	if raison == 'petit' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Demande de renfort', 'Demande de renfort demandé.\nRéponse: ~g~CODE-2\n~w~Importance: ~g~Légère.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
		color = 2
	elseif raison == 'importante' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Demande de renfort', 'Demande de renfort demandé.\nRéponse: ~g~CODE-3\n~w~Importance: ~o~Importante.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
		color = 47
	elseif raison == 'omgad' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
		PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Demande de renfort', 'Demande de renfort demandé.\nRéponse: ~g~CODE-99\n~w~Importance: ~r~URGENTE !\nDANGER IMPORTANT', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
		PlaySoundFrontend(-1, "FocusOut", "HintCamSounds", 1)
		color = 1
	end
	local blipId = AddBlipForCoord(coords)
	SetBlipSprite(blipId, 161)
	SetBlipScale(blipId, 1.2)
	SetBlipColour(blipId, color)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Demande renfort')
	EndTextCommandSetBlipName(blipId)
	Wait(80 * 1000)
	RemoveBlip(blipId)
end)

RegisterNetEvent('pn:InfoService')
AddEventHandler('pn:InfoService', function(service, nom)
	if service == 'prise' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Prise de service', 'Agent: ~g~'..nom..'\n~w~Code: ~g~10-8\n~w~Information: ~g~Prise de service.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'fin' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Fin de service', 'Agent: ~g~'..nom..'\n~w~Code: ~g~10-10\n~w~Information: ~g~Fin de service.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'pause' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Pause de service', 'Agent: ~g~'..nom..'\n~w~Code: ~g~10-6\n~w~Information: ~g~Pause de service.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'standby' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Mise en standby', 'Agent: ~g~'..nom..'\n~w~Code: ~g~10-12\n~w~Information: ~g~Standby, en attente de dispatch.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'control' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Control routier', 'Agent: ~g~'..nom..'\n~w~Code: ~g~10-48\n~w~Information: ~g~Control routier en cours.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'refus' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Refus d\'obtemperer', 'Agent: ~g~'..nom..'\n~w~Code: ~g~10-30\n~w~Information: ~g~Refus d\'obtemperer / Delit de fuite en cours.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'crime' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('POLICE INFORMATIONS', '~b~Crime en cours', 'Agent: ~g~'..nom..'\n~w~Code: ~g~10-31\n~w~Information: ~g~Crime en cours / poursuite en cours.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	end
end)

local shieldActive = false
local shieldEntity = nil

-- ANIM
local animDict = "combat@gestures@gang@pistol_1h@beckon"
local animName = "0"

local prop = "prop_ballistic_shield"

function EnableShield()
    shieldActive = true
    local ped = GetPlayerPed(-1)
    local pedPos = GetEntityCoords(ped, false)
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(250)
    end

    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

    RequestModel(GetHashKey(prop))
    while not HasModelLoaded(GetHashKey(prop)) do
        Citizen.Wait(250)
    end

    local shield = CreateObject(GetHashKey(prop), pedPos.x, pedPos.y, pedPos.z, 1, 1, 1)
    shieldEntity = shield
    AttachEntityToEntity(shieldEntity, ped, GetEntityBoneIndexByName(ped, "IK_L_Hand"), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
    SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))
    SetEnableHandcuffs(ped, true)
end

function DisableShield()
    local ped = GetPlayerPed(-1)
    DeleteEntity(shieldEntity)
    ClearPedTasksImmediately(ped)
    SetWeaponAnimationOverride(ped, GetHashKey("Default"))
    SetEnableHandcuffs(ped, false)
    shieldActive = false
end

Citizen.CreateThread(function()
    while true do
        if shieldActive then
            local ped = GetPlayerPed(-1)
            if not IsEntityPlayingAnim(ped, animDict, animName, 1) then
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end
        end
        Citizen.Wait(500)
    end
end)


--[[--- Soutien Police

function SpawnVehicle1()
	local playerPed = PlayerPedId()
	local PedPosition = GetEntityCoords(playerPed)
	hashKey = GetHashKey(zPN.ped1)
	pedType = GetPedType(hashKey)
	RequestModel(hashKey)
	while not HasModelLoaded(hashKey) do
	  RequestModel(hashKey)
	  Citizen.Wait(100)
	end
	chasePed = CreatePed(pedType, hashKey, PedPosition.x + 2,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
	ESX.Game.SpawnVehicle(zPN.vehicle1, {
	  x = PedPosition.x + 10 ,
	  y = PedPosition.y,
	  z = PedPosition.z
	},120, function(callback_vehicle)
	  chaseVehicle = callback_vehicle
	  local vehicle = GetVehiclePedIsIn(PlayerPed, true)
	  SetVehicleUndriveable(chaseVehicle, false)
	  SetVehicleEngineOn(chaseVehicle, true, true)
	  while not chasePed do Citizen.Wait(100) end;
	  PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
	  TaskWarpPedIntoVehicle(chasePed, chaseVehicle, -1)
	  TaskVehicleFollow(chasePed, chaseVehicle, playerPed, 50.0, 1, 5)
	  SetDriveTaskDrivingStyle(chasePed, 786468)
	  SetVehicleSiren(chaseVehicle, true)
	end)
end

function SpawnVehicle2()
local playerPed = PlayerPedId()
local PedPosition = GetEntityCoords(playerPed)
hashKey2 = GetHashKey(zPN.ped2)
pedType2 = GetPedType(hashKey)
RequestModel(hashKey2)
while not HasModelLoaded(hashKey2) do
    RequestModel(hashKey2)
    Citizen.Wait(100)
end
chasePed2 = CreatePed(pedType2, hashKey2, PedPosition.x + 4,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
ESX.Game.SpawnVehicle(zPN.vehicle2, {
    x = PedPosition.x + 15 ,
    y = PedPosition.y,
    z = PedPosition.z
},120, function(callback_vehicle2)
    chaseVehicle2 = callback_vehicle2
    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
    SetVehicleUndriveable(chaseVehicle2, false)
    SetVehicleEngineOn(chaseVehicle2, true, true)
    while not chasePed2 do Citizen.Wait(100) end;
    while not chaseVehicle2 do Citizen.Wait(100) end;
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    TaskWarpPedIntoVehicle(chasePed2, chaseVehicle2, -1)
    TaskVehicleFollow(chasePed2, chaseVehicle2, playerPed, 50.0, 1, 5)
    SetDriveTaskDrivingStyle(chasePed2, 786468)
    SetVehicleSiren(chaseVehicle2, true)
end)
end

function SpawnVehicle3()
local playerPed = PlayerPedId()
local PedPosition = GetEntityCoords(playerPed)
hashKey3 = GetHashKey(zPN.ped3)
pedType3 = GetPedType(hashKey)
RequestModel(hashKey3)
while not HasModelLoaded(hashKey3) do
    RequestModel(hashKey3)
    Citizen.Wait(100)
end
chasePed3 = CreatePed(pedType3, hashKey3, PedPosition.x + 2,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
ESX.Game.SpawnVehicle(zPN.vehicle3, {
    x = PedPosition.x + 10 ,
    y = PedPosition.y,
    z = PedPosition.z
},120, function(callback_vehicle3)
    chaseVehicle3 = callback_vehicle3
    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
    SetVehicleUndriveable(chaseVehicle3, false)
    SetVehicleEngineOn(chaseVehicle3, true, true)
    while not chasePed3 do Citizen.Wait(100) end;
    while not chaseVehicle3 do Citizen.Wait(100) end;
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    TaskWarpPedIntoVehicle(chasePed3, chaseVehicle3, -1)
    TaskVehicleFollow(chasePed3, chaseVehicle3, playerPed, 50.0, 1, 5)
    SetDriveTaskDrivingStyle(chasePed3, 786468)
    SetVehicleSiren(chaseVehicle3, true)
end)
end

function SpawnVehicle4()
local playerPed = PlayerPedId()
local PedPosition = GetEntityCoords(playerPed)
hashKey4 = GetHashKey(zPN.ped4)
pedType4 = GetPedType(hashKey)
RequestModel(hashKey4)
while not HasModelLoaded(hashKey4) do
    RequestModel(hashKey4)
    Citizen.Wait(100)
end
chasePed4 = CreatePed(pedType4, hashKey4, PedPosition.x + 2,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
ESX.Game.SpawnVehicle(zPN.vehicle4, {
    x = PedPosition.x + 10 ,
    y = PedPosition.y,
    z = PedPosition.z
},120, function(callback_vehicle4)
    chaseVehicle4 = callback_vehicle4
    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
    SetVehicleUndriveable(chaseVehicle4, false)
    SetVehicleEngineOn(chaseVehicle4, true, true)
    while not chasePed4 do Citizen.Wait(100) end;
    while not chaseVehicle4 do Citizen.Wait(100) end;
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    TaskWarpPedIntoVehicle(chasePed4, chaseVehicle4, -1)
    TaskVehicleFollow(chasePed4, chaseVehicle4, playerPed, 50.0, 1, 5)
    SetDriveTaskDrivingStyle(chasePed4, 786468)
    SetVehicleSiren(chaseVehicle4, true)
end)
end

function SpawnVehicle5()
local playerPed = PlayerPedId()
local PedPosition = GetEntityCoords(playerPed)
hashKey5 = GetHashKey(zPN.ped5)
pedType5 = GetPedType(hashKey)
RequestModel(hashKey5)
while not HasModelLoaded(hashKey5) do
    RequestModel(hashKey5)
    Citizen.Wait(100)
end
chasePed5 = CreatePed(pedType5, hashKey5, PedPosition.x + 2,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
ESX.Game.SpawnVehicle(zPN.vehicle5, {
    x = PedPosition.x + 10 ,
    y = PedPosition.y,
    z = PedPosition.z
},120, function(callback_vehicle5)
    chaseVehicle5 = callback_vehicle5
    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
    SetVehicleUndriveable(chaseVehicle5, false)
    SetVehicleEngineOn(chaseVehicle5, true, true)
    while not chasePed5 do Citizen.Wait(100) end;
    while not chaseVehicle5 do Citizen.Wait(100) end;
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    TaskWarpPedIntoVehicle(chasePed5, chaseVehicle5, freeSeat)
    TaskVehicleFollow(chasePed5, chaseVehicle5, playerPed, 50.0, 1, 5)
    SetDriveTaskDrivingStyle(chasePed5, 786468)
    SetVehicleSiren(chaseVehicle5, false)
end)
end


loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
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
end--]]


Citizen.CreateThread(function()
    local douanemap = AddBlipForCoord(zPN.pos.douaneblips.position.x, zPN.pos.douaneblips.position.y, zPN.pos.douaneblips.position.z)
    SetBlipSprite(douanemap, 124)
    SetBlipColour(douanemap, 0)
    SetBlipScale(douanemap, 0.65)
    SetBlipAsShortRange(douanemap, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Douane")
    EndTextCommandSetBlipName(douanemap)
end)


-------------------------------------------------------------DOUANE VESTIAIRE

function vestiairepnd()
    local Vpnd = RageUI.CreateMenu("Vestiaire", "DOUANE")
        RageUI.Visible(Vpnd, not RageUI.Visible(Vpnd))
            while Vpnd do
            Citizen.Wait(0)
            RageUI.IsVisible(Vpnd, true, true, true, function()
                RageUI.Separator("~y~↓ Votre Tenue ↓")
                RageUI.ButtonWithStyle("Remettre sa tenue",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if Selected then
                        vcivil_pn()
                        RageUI.CloseAll()
                    end
                end)
                RageUI.Separator("~y~↓Tenue Service↓")
                    RageUI.ButtonWithStyle("Tenue Manche Courte",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_douane()
                        end
                    end)
                                
            RageUI.ButtonWithStyle("Gilet Jaune",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    gpb_douane()
                    SetPedArmour(GetPlayerPed(-1), 100)
                end
            end)
            RageUI.ButtonWithStyle("Enlever Votre GPB",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    enleverbullet_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)

            RageUI.Separator("~g~↓ Casque ↓")

            RageUI.ButtonWithStyle("Calot",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    helmet_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)
            RageUI.ButtonWithStyle("Enlever Votre Casque",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    enlevercasque()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)



                end, function()
                end)
            if not RageUI.Visible(Vpnd) then
                Vpnd = RMenu:DeleteType("Vestiaire", true)
        end
    end
end



function tenu_douane()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_douane.male
        else
            uniformObject = zPN.Uniforms.tenu_douane.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function gpb_douane()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.gpb_douane.male
        else
            uniformObject = zPN.Uniforms.gpb_douane.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end



Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, zPN.pos.vestiairedouane.position.x, zPN.pos.vestiairedouane.position.y, zPN.pos.vestiairedouane.position.z)
            if jobdist <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.vestiairedouane.position.x, zPN.pos.vestiairedouane.position.y, zPN.pos.vestiairedouane.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au vestiaire", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                        vestiairepnd()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)


--- fin
function Garagepnd()
    local Gpnd = RageUI.CreateMenu("Garage", "DOUANE")
      RageUI.Visible(Gpnd, not RageUI.Visible(Gpnd))
          while Gpnd do
              Citizen.Wait(0)
                  RageUI.IsVisible(Gpnd, true, true, true, function()
                      RageUI.ButtonWithStyle("Ranger la voiture", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then   
                          local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                          if dist4 < 4 then
                              DeleteEntity(veh)
                              RageUI.CloseAll()
                              end 
                          end
                      end) 
  
                      for k,v in pairs(Gpndvoiture) do
                      RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then
                          Citizen.Wait(1)  
                          spawnuniCazPNd(v.modele)
                              RageUI.CloseAll()
                              end
                          end)
                      end
                  end, function()
                  end)
              if not RageUI.Visible(Gpnd) then
                Gpnd = RMenu:DeleteType("Garage", true)
          end
      end
  end
  
  Citizen.CreateThread(function()
          while true do
              local Timer = 500
              if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
              local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
              local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.garagedouane.position.x, zPN.pos.garagedouane.position.y, zPN.pos.garagedouane.position.z)
              if dist3 <= 10.0 and zPN.jeveuxmarker then
                  Timer = 0
                  DrawMarker(20, zPN.pos.garagedouane.position.x, zPN.pos.garagedouane.position.y, zPN.pos.garagedouane.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                  end
                  if dist3 <= 3.0 then
                  Timer = 0   
                      RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au garage", time_display = 1 })
                      if IsControlJustPressed(1,51) then           
                        Garagepnd()
                      end   
                  end
              end 
          Citizen.Wait(Timer)
       end
  end)
  
  function spawnuniCazPNd(car)
      local car = GetHashKey(car)
  
      RequestModel(car)
      while not HasModelLoaded(car) do
          RequestModel(car)
          Citizen.Wait(0)
      end
  
      local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
      local vehicle = CreateVehicle(car, zPN.pos.spawnvoituredouane.position.x, zPN.pos.spawnvoituredouane.position.y, zPN.pos.spawnvoituredouane.position.z, zPN.pos.spawnvoituredouane.position.h, true, false)
      SetEntityAsMissionEntity(vehicle, true, true)
      local plaque = "DOUANE"..math.random(1,9)
      SetVehicleNumberPlateText(vehicle, plaque) 
      SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
  end


  ----------------HELICO
  function Helidpn()
    local Hpnd = RageUI.CreateMenu("Garage", "DOUANE")
      RageUI.Visible(Hpnd, not RageUI.Visible(Hpnd))
          while Hpnd do
              Citizen.Wait(0)
                  RageUI.IsVisible(Hpnd, true, true, true, function()
                      RageUI.ButtonWithStyle("Ranger le hélicoptère", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then   
                          local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                          if dist4 < 4 then
                              DeleteEntity(veh)
                              RageUI.CloseAll()
                              end 
                          end
                      end) 
  
                      for k,v in pairs(Hpndheli) do
                      RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then
                          Citizen.Wait(1)  
                            spawnuniCarhelid(v.modele)
                              RageUI.CloseAll()
                              end
                          end)
                      end
                  end, function()
                  end)
              if not RageUI.Visible(Hpnd) then
                Hpnd = RMenu:DeleteType("Garage", true)
          end
      end
end
  
Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
            local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
            local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.garagehelidouane.position.x, zPN.pos.garagehelidouane.position.y, zPN.pos.garagehelidouane.position.z)
            if dist3 <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.garagehelidouane.position.x, zPN.pos.garagehelidouane.position.y, zPN.pos.garagehelidouane.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if dist3 <= 3.0 then
                Timer = 0   
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au garage des hélicoptères", time_display = 1 })
                    if IsControlJustPressed(1,51) then           
                        Helidpn()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)
  
function spawnuniCarhelid(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, zPN.pos.spawnhelidouane.position.x, zPN.pos.spawnhelidouane.position.y, zPN.pos.spawnhelidouane.position.z, zPN.pos.spawnhelidouane.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = "DOUANE"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque) 
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
end

----------------

function OpenPrendreMenuPNd()
    local PrendreMenud = RageUI.CreateMenu("Arsenal", "DOUANE")
        RageUI.Visible(PrendreMenud, not RageUI.Visible(PrendreMenud))
    while PrendreMenud do
        Citizen.Wait(0)
            RageUI.IsVisible(PrendreMenud, true, true, true, function()

            RageUI.ButtonWithStyle("Déposer les armes",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                    TriggerServerEvent('zPN:arsenaldvide')
                end
            end)

            RageUI.Separator('~r~↓ Voici les armes disponible ↓')

            for k,v in pairs(zPN.arsenal.douane) do
                RageUI.ButtonWithStyle(v.Label.. ' Prix: ' .. v.Price .. '€', nil, { RightBadge = RageUI.BadgeStyle.Gun }, true, function(Hovered, Active, Selected)
                  if (Selected) then
                      TriggerServerEvent('zPN:arsenald', v.Name, v.Price)
                    end
                end)
            end
                end, function() 
                end)
    
                if not RageUI.Visible(PrendreMenud) then
                    PrendreMenud = RMenu:DeleteType("Police", true)
        end
    end
end


Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.MenuPrendredouane.position.x, zPN.pos.MenuPrendredouane.position.y, zPN.pos.MenuPrendredouane.position.z)
        if dist3 <= 7.0 and zPN.jeveuxmarker then
            Timer = 0
            DrawMarker(20, zPN.pos.MenuPrendredouane.position.x, zPN.pos.MenuPrendredouane.position.y, zPN.pos.MenuPrendredouane.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
            end
            if dist3 <= 2.0 then
                Timer = 0   
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder à l'arsenal", time_display = 1 })
                        if IsControlJustPressed(1,51) then           
                            OpenPrendreMenuPNd()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)

----------------Coffre

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
        local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
        local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, zPN.pos.coffredouane.position.x, zPN.pos.coffredouane.position.y, zPN.pos.coffredouane.position.z)
        if jobdist <= 10.0 and zPN.jeveuxmarker then
            Timer = 0
            DrawMarker(20, zPN.pos.coffredouane.position.x, zPN.pos.coffredouane.position.y, zPN.pos.coffredouane.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
            end
            if jobdist <= 1.0 then
                Timer = 0
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au coffre", time_display = 1 })
                    if IsControlJustPressed(1,51) then
                    Coffrepn()
                end   
            end
        end 
    Citizen.Wait(Timer)   
end
end)

----------------------------------------------------------------------------------------------------
---------------------------------------MARINE GARAGE DOUANE-----------------------------------------
----------------------------------------------------------------------------------------------------

function Garagepnbateau()
    local Gpnbateau = RageUI.CreateMenu("Garage", "Police Nationale")
      RageUI.Visible(Gpnbateau, not RageUI.Visible(Gpnbateau))
          while Gpnbateau do
              Citizen.Wait(0)
                  RageUI.IsVisible(Gpnbateau, true, true, true, function()
                      RageUI.ButtonWithStyle("Ranger la voiture", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then   
                          local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                          if dist4 < 4 then
                              DeleteEntity(veh)
                              RageUI.CloseAll()
                              end 
                          end
                      end) 
  
                      for k,v in pairs(zPN.Gpnbateau) do
                      RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then
                          Citizen.Wait(1)  
                              spawnuniCazPNbateau(v.modele)
                              RageUI.CloseAll()
                              end
                          end)
                      end
                  end, function()
                  end)
              if not RageUI.Visible(Gpnbateau) then
                Gpnbateau = RMenu:DeleteType("Garage", true)
          end
      end
  end
  
  Citizen.CreateThread(function()
          while true do
              local Timer = 500
              if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
              local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
              local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.garagebateaudouane.position.x, zPN.pos.garagebateaudouane.position.y, zPN.pos.garagebateaudouane.position.z)
              if dist3 <= 10.0 and zPN.jeveuxmarker then
                  Timer = 0
                  DrawMarker(20, zPN.pos.garagebateaudouane.position.x, zPN.pos.garagebateaudouane.position.y, zPN.pos.garagebateaudouane.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                  end
                  if dist3 <= 3.0 then
                  Timer = 0   
                      RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au garage", time_display = 1 })
                      if IsControlJustPressed(1,51) then           
                          Garagepnbateau()
                      end   
                  end
              end 
          Citizen.Wait(Timer)
       end
  end)
  
  function spawnuniCazPNbateau(car)
      local car = GetHashKey(car)
  
      RequestModel(car)
      while not HasModelLoaded(car) do
          RequestModel(car)
          Citizen.Wait(0)
      end
  
      local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
      local vehicle = CreateVehicle(car, zPN.pos.spawnbateaudouane.position.x, zPN.pos.spawnbateaudouane.position.y, zPN.pos.spawnbateaudouane.position.z, zPN.pos.spawnbateaudouane.position.h, true, false)
      SetEntityAsMissionEntity(vehicle, true, true)
      local plaque = "pn"..math.random(1,9)
      SetVehicleNumberPlateText(vehicle, plaque) 
      SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
  end



  Citizen.CreateThread(function()
    local bacmap = AddBlipForCoord(zPN.pos.bacblips.position.x, zPN.pos.bacblips.position.y, zPN.pos.bacblips.position.z)
    SetBlipSprite(bacmap, 124)
    SetBlipColour(bacmap, 0)
    SetBlipScale(bacmap, 0.65)
    SetBlipAsShortRange(bacmap, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Bac")
    EndTextCommandSetBlipName(bacmap)
end)

-------------------------------------------------------------BAC VESTIAIRE

function vestiairepnb()
    local Vpnb = RageUI.CreateMenu("Vestiaire", "BAC")
        RageUI.Visible(Vpnb, not RageUI.Visible(Vpnb))
            while Vpnb do
            Citizen.Wait(0)
            RageUI.IsVisible(Vpnb, true, true, true, function()
                RageUI.Separator("~y~↓ Votre Tenue ↓")
                RageUI.ButtonWithStyle("Remettre sa tenue",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if Selected then
                        vcivil_pn()
                        RageUI.CloseAll()
                    end
                end)
                RageUI.Separator("~y~↓Tenue Service↓")
                    RageUI.ButtonWithStyle("Tenue Lacoste",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_bac()
                        end
                    end)
                    RageUI.ButtonWithStyle("Tenue Champion",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_bac1()
                        end
                    end)
                    RageUI.ButtonWithStyle("Tenue BAC",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            tenu_bac2()
                        end
                    end)
                    RageUI.Separator("~y~↓Gilet Par Balle↓")

                    RageUI.ButtonWithStyle("Gilet BAC",nil, {nil}, true, function(Hovered, Active, Selected)
                        if Selected then
                            bullet4_wear()
                            SetPedArmour(GetPlayerPed(-1), 100)
                        end
                    end)
            RageUI.ButtonWithStyle("Enlever Votre GPB",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    enleverbullet_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)

            RageUI.Separator("~g~↓ Casque ↓")

            RageUI.ButtonWithStyle("Calot",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    helmet_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)
            RageUI.ButtonWithStyle("Enlever Votre Casque",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    enlevercasque()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)
            RageUI.Separator("~g~↓ BAC ↓")

            RageUI.ButtonWithStyle("Brassard BAC",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    bulletbraceletbac_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)
            RageUI.ButtonWithStyle("Enlever Le Brassard",nil, {nil}, true, function(Hovered, Active, Selected)
                if Selected then
                    enleverbulletbraceletbac_wear()
                    SetPedArmour(GetPlayerPed(-1), 0)
                end
            end)



                end, function()
                end)
            if not RageUI.Visible(Vpnb) then
                Vpnb = RMenu:DeleteType("Vestiaire", true)
        end
    end
end



function tenu_bac()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_bac.male
        else
            uniformObject = zPN.Uniforms.tenu_bac.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function tenu_bac1()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_bac1.male
        else
            uniformObject = zPN.Uniforms.tenu_bac1.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function tenu_bac2()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.tenu_bac2.male
        else
            uniformObject = zPN.Uniforms.tenu_bac2.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function enleverbulletbraceletbac_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.enleverbulletbraceletbac_wear.male
        else
            uniformObject = zPN.Uniforms.enleverbulletbraceletbac_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function bulletbraceletbac_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.bulletbraceletbac_wear.male
        else
            uniformObject = zPN.Uniforms.bulletbraceletbac_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

function bulletbraceletbac_wear()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = zPN.Uniforms.bulletbraceletbac_wear.male
        else
            uniformObject = zPN.Uniforms.bulletbraceletbac_wear.female
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end




Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, zPN.pos.vestiairebac.position.x, zPN.pos.vestiairebac.position.y, zPN.pos.vestiairebac.position.z)
            if jobdist <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.vestiairebac.position.x, zPN.pos.vestiairebac.position.y, zPN.pos.vestiairebac.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au vestiaire", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                        vestiairepnb()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)


--- fin
function Garagepnb()
    local Gpnb = RageUI.CreateMenu("Garage", "BAC")
      RageUI.Visible(Gpnb, not RageUI.Visible(Gpnb))
          while Gpnb do
              Citizen.Wait(0)
                  RageUI.IsVisible(Gpnb, true, true, true, function()
                      RageUI.ButtonWithStyle("Ranger la voiture", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then   
                          local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                          if dist4 < 4 then
                              DeleteEntity(veh)
                              RageUI.CloseAll()
                              end 
                          end
                      end) 
  
                      for k,v in pairs(Gpnbvoiture) do
                      RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then
                          Citizen.Wait(1)  
                          spawnuniCazPNb(v.modele)
                              RageUI.CloseAll()
                              end
                          end)
                      end
                  end, function()
                  end)
              if not RageUI.Visible(Gpnb) then
                Gpnb = RMenu:DeleteType("Garage", true)
          end
      end
  end
  
  Citizen.CreateThread(function()
          while true do
              local Timer = 500
              if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
              local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
              local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.garagebac.position.x, zPN.pos.garagebac.position.y, zPN.pos.garagebac.position.z)
              if dist3 <= 10.0 and zPN.jeveuxmarker then
                  Timer = 0
                  DrawMarker(20, zPN.pos.garagebac.position.x, zPN.pos.garagebac.position.y, zPN.pos.garagebac.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                  end
                  if dist3 <= 3.0 then
                  Timer = 0   
                      RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au garage", time_display = 1 })
                      if IsControlJustPressed(1,51) then           
                        Garagepnb()
                      end   
                  end
              end 
          Citizen.Wait(Timer)
       end
  end)
  
  function spawnuniCazPNb(car)
      local car = GetHashKey(car)
  
      RequestModel(car)
      while not HasModelLoaded(car) do
          RequestModel(car)
          Citizen.Wait(0)
      end
  
      local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
      local vehicle = CreateVehicle(car, zPN.pos.spawnvoiturebac.position.x, zPN.pos.spawnvoiturebac.position.y, zPN.pos.spawnvoiturebac.position.z, zPN.pos.spawnvoiturebac.position.h, true, false)
      SetEntityAsMissionEntity(vehicle, true, true)
      local plaque = "BAC"..math.random(1,9)
      SetVehicleNumberPlateText(vehicle, plaque) 
      SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
  end


  ----------------HELICO
  function Helibpn()
    local Hpnb = RageUI.CreateMenu("Garage", "BAC")
      RageUI.Visible(Hpnb, not RageUI.Visible(Hpnb))
          while Hpnb do
              Citizen.Wait(0)
                  RageUI.IsVisible(Hpnb, true, true, true, function()
                      RageUI.ButtonWithStyle("Ranger le hélicoptère", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then   
                          local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                          if dist4 < 4 then
                              DeleteEntity(veh)
                              RageUI.CloseAll()
                              end 
                          end
                      end) 
  
                      for k,v in pairs(Hpnbheli) do
                      RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then
                          Citizen.Wait(1)  
                            spawnuniCarhelib(v.modele)
                              RageUI.CloseAll()
                              end
                          end)
                      end
                  end, function()
                  end)
              if not RageUI.Visible(Hpnb) then
                Hpnb = RMenu:DeleteType("Garage", true)
          end
      end
end
  
Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
            local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
            local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.garagehelibac.position.x, zPN.pos.garagehelibac.position.y, zPN.pos.garagehelibac.position.z)
            if dist3 <= 10.0 and zPN.jeveuxmarker then
                Timer = 0
                DrawMarker(20, zPN.pos.garagehelibac.position.x, zPN.pos.garagehelibac.position.y, zPN.pos.garagehelibac.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if dist3 <= 3.0 then
                Timer = 0   
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au garage des hélicoptères", time_display = 1 })
                    if IsControlJustPressed(1,51) then           
                        Helibpn()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)
  
function spawnuniCarhelib(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, zPN.pos.spawnhelibac.position.x, zPN.pos.spawnhelibac.position.y, zPN.pos.spawnhelibac.position.z, zPN.pos.spawnhelibac.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = "BAC"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque) 
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
end

----------------

function OpenPrendreMenuPNd()
    local PrendreMenud = RageUI.CreateMenu("Arsenal", "BAC")
        RageUI.Visible(PrendreMenud, not RageUI.Visible(PrendreMenud))
    while PrendreMenud do
        Citizen.Wait(0)
            RageUI.IsVisible(PrendreMenud, true, true, true, function()

            RageUI.ButtonWithStyle("Déposer les armes",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                    TriggerServerEvent('zPN:arsenaldvide')
                end
            end)

            RageUI.Separator('~r~↓ Voici les armes disponible ↓')

            for k,v in pairs(zPN.arsenal.bac) do
                RageUI.ButtonWithStyle(v.Label.. ' Prix: ' .. v.Price .. '€', nil, { RightBadge = RageUI.BadgeStyle.Gun }, true, function(Hovered, Active, Selected)
                  if (Selected) then
                      TriggerServerEvent('zPN:arsenald', v.Name, v.Price)
                    end
                end)
            end
                end, function() 
                end)
    
                if not RageUI.Visible(PrendreMenud) then
                    PrendreMenud = RMenu:DeleteType("Police", true)
        end
    end
end


Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, zPN.pos.MenuPrendrebac.position.x, zPN.pos.MenuPrendrebac.position.y, zPN.pos.MenuPrendrebac.position.z)
        if dist3 <= 7.0 and zPN.jeveuxmarker then
            Timer = 0
            DrawMarker(20, zPN.pos.MenuPrendrebac.position.x, zPN.pos.MenuPrendrebac.position.y, zPN.pos.MenuPrendrebac.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
            end
            if dist3 <= 2.0 then
                Timer = 0   
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder à l'arsenal", time_display = 1 })
                        if IsControlJustPressed(1,51) then           
                            OpenPrendreMenuPNd()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)

----------------Coffre

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pn' then
        local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
        local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, zPN.pos.coffrebac.position.x, zPN.pos.coffrebac.position.y, zPN.pos.coffrebac.position.z)
        if jobdist <= 10.0 and zPN.jeveuxmarker then
            Timer = 0
            DrawMarker(20, zPN.pos.coffrebac.position.x, zPN.pos.coffrebac.position.y, zPN.pos.coffrebac.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 255, 0, 1, 2, 0, nil, nil, 0)
            end
            if jobdist <= 1.0 then
                Timer = 0
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour accéder au coffre", time_display = 1 })
                    if IsControlJustPressed(1,51) then
                    Coffrepn()
                end   
            end
        end 
    Citizen.Wait(Timer)   
end
end)
