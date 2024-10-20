-- ████████╗██╗███████╗██╗ ██████╗ ██╗   ██╗███████╗███████╗
-- ╚══██╔══╝██║██╔════╝██║██╔═══██╗██║   ██║██╔════╝██╔════╝
--    ██║   ██║█████╗  ██║██║   ██║██║   ██║███████╗█████╗  
--    ██║   ██║██╔══╝  ██║██║   ██║██║   ██║╚════██║██╔══╝  
--    ██║   ██║██║     ██║╚██████╔╝╚██████╔╝███████║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝

Warehouses = {}
PlayerInWarehouse = nil
Rigs = {}
Slots = {
    {coords = vec3(1088.68, -3096.89, -40.0)},
    {coords = vec3(1091.36, -3096.89, -40.0)},
    {coords = vec3(1095.02, -3096.89, -40.0)},
    {coords = vec3(1097.44, -3096.89, -40.0)},
    {coords = vec3(1101.29, -3096.89, -40.0)},
    {coords = vec3(1103.94, -3096.89, -40.0)},
}

RegisterNetEvent("TFS_crypto:updateClientData", function(warehouses)
    Warehouses = warehouses
    if Config.UseBlips then updateBlip() end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local closestWarehouse = getClosestWarehouse()
        
        if closestWarehouse then
            wait = 3
            local text = "Loading..."
            if closestWarehouse.owner == ESX.PlayerData.identifier and not closestWarehouse.state.forsale then
                text = Config.Translations.your_warehouse
            elseif closestWarehouse.owner == ESX.PlayerData.identifier and closestWarehouse.state.forsale then
                text = (Config.Translations.your_warehouse_for_sale):format(closestWarehouse.state.saleprice)
            else
                if closestWarehouse.state.forsale then
                    text = (Config.Translations.warehouse_for_sale):format(closestWarehouse.state.saleprice)
                else
                    text = Config.Translations.owned_warehouse
                end
            end
            DrawText3D(closestWarehouse.coords.x, closestWarehouse.coords.y, closestWarehouse.coords.z, text)
            if IsControlJustPressed(0, Config.Controls.enter_buy_delist_warehouse) then
                if closestWarehouse.owner == ESX.PlayerData.identifier and not closestWarehouse.state.forsale then
                    TriggerServerEvent("TFS_crypto:enterWarehouse", closestWarehouse.id)
                    SetPlayerInWarehouse(closestWarehouse.id)
                elseif closestWarehouse.owner == ESX.PlayerData.identifier and closestWarehouse.state.forsale then
                    TriggerServerEvent("TFS_crypto:removeSell", closestWarehouse.id)
                else
                    if closestWarehouse.state.forsale then
                        local valid =  true
                        for k,v in pairs(Warehouses) do
                            if v.owner == ESX.PlayerData.identifier then 
                                for r,t in pairs(v.data) do
                                    if t.stage ~= 3 then valid = false end
                                end
                            end
                        end
                        if not valid then 
                            notification(Config.Translations.not_maxed) 
                        elseif valid then
                            TriggerServerEvent("TFS_crypto:buyWarehouse", closestWarehouse.id)
                        end
                    end
                end
            end
            if IsControlJustPressed(0, Config.Controls.check_warehouse_info) then
                if closestWarehouse.state.forsale then
                    local slot = {}
                    for k,v in pairs(closestWarehouse.data) do
                        if v.stage == 0 then
                            slot[k] = Config.Translations.no_rig
                        elseif v.stage == 3 then
                            slot[k] = Config.Translations.max_rig
                        else
                            slot[k] = (Config.Translations.rig_stage):format(v.stage)
                        end
                    end
                    notification(Config.Translations.warehouse_info)
                    notification(Config.Translations.first_rig..""..slot["1"].."~n~"..Config.Translations.second_rig..""..slot["2"].."~n~"..Config.Translations.third_rig..""..slot["3"])
                    notification(Config.Translations.fourth_rig..""..slot["4"].."~n~"..Config.Translations.fifth_rig..""..slot["5"].."~n~"..Config.Translations.sixth_rig..""..slot["6"])
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local closestRig = getClosestRig()
        
        if closestRig then
            wait = 3
            local text = "["..closestRig.id.."]"
            if PlayerInWarehouse then
                local status = Warehouses[PlayerInWarehouse]["data"][tostring(closestRig.id)]
                local power = "N/A"
                if status.status == 0 then power = Config.Translations.off elseif status.status == 1 then power = Config.Translations.on end
                if status.stage == 0 then 
                    text = (Config.Translations.buy_rig):format(tostring(Config.Upgrades[tostring(status.stage + 1)]))
                elseif status.stage == 1 or status.stage == 2 then
                    text = (Config.Translations.rig_status):format(status.stage, power, tostring(Config.Upgrades[tostring(status.stage + 1)]))
                elseif status.stage == 3 then
                    text = (Config.Translations.max_rig_status):format(power)
                end
                if IsControlJustPressed(0, Config.Controls.upgrade_rig) then
                    if status.stage ~= 3 then
                        TriggerServerEvent("TFS_crypto:upgradeRig", PlayerInWarehouse, closestRig.id, status.stage+1)
                    end
                end
                if IsControlJustPressed(0, Config.Controls.toggle_rig) then
                    if status.stage ~= 0 then
                        TriggerServerEvent("TFS_crypto:rigStatus", PlayerInWarehouse, closestRig.id)
                    end
                end
                if IsControlJustPressed(0, Config.Controls.rig_info) then
                    if status.stage == 0 then 
                        notification(Config.Translations.no_rig_info)
                    else
                        notification((Config.Translations.rig_info):format(Config.Profit[tostring(status.stage)].min, Config.Profit[tostring(status.stage)].max, Config.Electricity[tostring(status.stage)]))
                    end
                    if status.stage ~= 3 then
                        notification((Config.Translations.upgrade_rig_info):format(Config.Profit[tostring(status.stage + 1)].min, Config.Profit[tostring(status.stage + 1)].max, Config.Electricity[tostring(status.stage + 1)]))
                    end
                end
            end
            DrawText3D(closestRig.coords.x, closestRig.coords.y, closestRig.coords.z, text)
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local distance = #(playerCoords - vec3(1087.44, -3099.57, -39.0))

        if distance < 1.0 then
            wait = 3
            DrawText3D(1087.44, -3099.57, -39.0, Config.Translations.exit)
            if IsControlJustPressed(0, Config.Controls.exit) then
                local coords = vec3(797.17, -2988.56, 6.02)
                for k, v in pairs(Warehouses) do
                    if tonumber(PlayerInWarehouse) and Warehouses[PlayerInWarehouse].coords then
                        coords = vec3(Warehouses[PlayerInWarehouse].coords.x, Warehouses[PlayerInWarehouse].coords.y, Warehouses[PlayerInWarehouse].coords.z)
                        TriggerServerEvent("TFS_crypto:exitWarehouse", PlayerInWarehouse)
                        local players = GetActivePlayers()
                        for k, v in pairs(players) do
                            local playerPed = GetPlayerPed(v)  
                            if player ~= playerPed then     
                                NetworkConcealPlayer(v, false, false)
                            end
                        end
                    end
                    for k, v in pairs(Rigs) do
                        DeleteEntity(v.prop)
                        Rigs[k] = nil
                    end
                end
                DoScreenFadeOut(500)
                Citizen.Wait(550)
                SetEntityCoords(player, coords.x, coords.y, coords.z, 1, 0, 0, 1)
                DoScreenFadeIn(500)
            end
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local distance = #(playerCoords - vec3(1087.94, -3101.32, -39.0))

        if PlayerInWarehouse then
            if distance < 1.0 then
                wait = 3
                local profit = Warehouses[PlayerInWarehouse].finance.revenue - Warehouses[PlayerInWarehouse].finance.bills
                local control = ""
                if profit > 0 then control = (Config.Translations.take_profit):format(profit)
                elseif profit < 0 then control = (Config.Translations.pay_bills):format(profit) end

                DrawText3D(1087.94, -3101.32, -39.0, (Config.Translations.warehouse_stats):format(Warehouses[PlayerInWarehouse].finance.bills, Warehouses[PlayerInWarehouse].finance.revenue, control))
                if IsControlJustPressed(0, Config.Controls.sell_warehouse) then
                    local on = false
                    for k,v in pairs(Warehouses[PlayerInWarehouse].data) do
                        if v.status ~= 0 then on = true end
                    end
                    if on then 
                        notification(Config.Translations.turn_off_rigs)
                    else
                        if profit ~= 0 then
                            notification(Config.Translations.pay_or_take)
                        else
                            local price = KeyboardInput(Config.Translations.keyboard_header, "", 7)
                            if tonumber(price) then
                                TriggerServerEvent("TFS_crypto:sellWarehouse", PlayerInWarehouse, price)
                                local coords = vec3(Warehouses[PlayerInWarehouse].coords.x, Warehouses[PlayerInWarehouse].coords.y, Warehouses[PlayerInWarehouse].coords.z)
                                DoScreenFadeOut(500)
                                Citizen.Wait(550)
                                TriggerServerEvent("TFS_crypto:exitWarehouse", PlayerInWarehouse)
                                SetEntityCoords(player, coords.x, coords.y, coords.z, 1, 0, 0, 1)
                                local players = GetActivePlayers()
                                for k, v in pairs(players) do
                                    local playerPed = GetPlayerPed(v)  
                                    if player ~= playerPed then     
                                        NetworkConcealPlayer(v, false, false)
                                    end
                                end
                                DoScreenFadeIn(500)
                            end
                        end
                    end
                end
                if IsControlJustPressed(0, Config.Controls.pay_bills_take_profits) then
                    TriggerServerEvent("TFS_crypto:revenueControl", PlayerInWarehouse)
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

RegisterNetEvent("TFS_crypto:setPlayerInWarehouse", function(id)
    SetPlayerInWarehouse(id)
end)

RegisterNetEvent("TFS_crypto:upgradeRig", function(rigId, upgrade)
    local player = PlayerPedId()
    local coords = Slots[rigId].coords
    SetEntityCoords(player, coords.x, coords.y-1.2, coords.z, 1, 0, 0, 1)
    SetEntityHeading(player, 0.0)  
    FreezeEntityPosition(player, true)

    SetEntityCollision(Rigs[rigId].prop, true, false)
    SetEntityAlpha(Rigs[rigId].prop, 200, false)

    TaskStartScenarioInPlace(player, 'PROP_HUMAN_BUM_BIN', 0, true)
    Wait(5000)
    ClearPedTasks(player)
    FreezeEntityPosition(player, false)

    SetEntityCollision(Rigs[rigId].prop, true, false)
    SetEntityAlpha(Rigs[rigId].prop, 255, false)
end)

function SetPlayerInWarehouse(id)
    local player = PlayerPedId()
    PlayerInWarehouse = id
    DoScreenFadeOut(500)
    Citizen.Wait(550)
    SetEntityCoords(player, 1088.5, -3099.4, -40.0, 1, 0, 0, 1)
    SetEntityHeading(player, 270.0)
    Citizen.Wait(500)
    local hash = GetHashKey("v_corp_servercln2")
    for i = 1, 6 do
        if Rigs[i] == nil then
            Rigs[i] = {}
            Rigs[i].prop = CreateObject(hash, Slots[i].coords.x, Slots[i].coords.y, Slots[i].coords.z, false, false, false)
            Rigs[i].coords = vec3(Slots[i].coords.x, Slots[i].coords.y, Slots[i].coords.z+1)
            Rigs[i].id = i
            PlaceObjectOnGroundProperly(Rigs[i].prop)
            FreezeEntityPosition(Rigs[i].prop, true)
            while Warehouses == nil do Citizen.Wait(100) end
            if Warehouses[id].data[tostring(i)].stage == 0 then
                SetEntityCollision(Rigs[i].prop, false, false)
                SetEntityAlpha(Rigs[i].prop, 140, false)
            end
        end
    end

    local players = GetActivePlayers()
    for k, v in pairs(players) do
        local playerPed = GetPlayerPed(v)  
        local localPlayer = GetPlayerPed(-1)
        if localPlayer ~= playerPed then    
            NetworkConcealPlayer(v, true, false)
        end
    end
    DoScreenFadeIn(500)
end

function getClosestWarehouse()
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local closest = nil
    local closestDist = 3
    for k, v in pairs(Warehouses) do
        local distance = #(playerCoords - v.coords)
        if distance < closestDist then
            closest = v
            closestDist = distance
        end
    end
    return closest
end

function getClosestRig()
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local closest = nil
    local closestDist = 1.5
    for k, v in pairs(Rigs) do
        local distance = #(playerCoords - v.coords)
        if distance < closestDist then
            closest = v
            closestDist = distance
        end
    end
    return closest
end

function DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z)
    local _, count = string.gsub(text, "\n", "")
    SetTextScale(0.25, 0.25)
    SetTextFont(0)
    SetTextEntry('STRING')
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(0.0, 0.0 - 0.01 * count)
    ClearDrawOrigin()
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        for k, v in pairs(Rigs) do
            DeleteEntity(v.prop)
        end
    end
end)

blip = {}

function updateBlip()
    for k, v in pairs(Warehouses) do
        if blip[k] then
            RemoveBlip(blip[k])
        end
        local color = 1
        local text = Config.Translations.blip_owned
        if v.owner == ESX.PlayerData.identifier then 
            color = 5
            text = Config.Translations.blip_my
        elseif v.owner ~= ESX.PlayerData.identifier and v.state.forsale then
            color = 0
            text = Config.Translations.blip_for_sale
        end
        blip[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip[k], 369)
        SetBlipDisplay(blip[k], 4)
        SetBlipScale(blip[k], 0.75)
        SetBlipColour(blip[k], color)
        SetBlipAsShortRange(blip[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(text)
        EndTextCommandSetBlipName(blip[k])
    end
end

-- ████████╗██╗███████╗██╗ ██████╗ ██╗   ██╗███████╗███████╗
-- ╚══██╔══╝██║██╔════╝██║██╔═══██╗██║   ██║██╔════╝██╔════╝
--    ██║   ██║█████╗  ██║██║   ██║██║   ██║███████╗█████╗  
--    ██║   ██║██╔══╝  ██║██║   ██║██║   ██║╚════██║██╔══╝  
--    ██║   ██║██║     ██║╚██████╔╝╚██████╔╝███████║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
