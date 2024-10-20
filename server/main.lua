-- ████████╗██╗███████╗██╗ ██████╗ ██╗   ██╗███████╗███████╗
-- ╚══██╔══╝██║██╔════╝██║██╔═══██╗██║   ██║██╔════╝██╔════╝
--    ██║   ██║█████╗  ██║██║   ██║██║   ██║███████╗█████╗  
--    ██║   ██║██╔══╝  ██║██║   ██║██║   ██║╚════██║██╔══╝  
--    ██║   ██║██║     ██║╚██████╔╝╚██████╔╝███████║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
$
Warehouses = {}

Citizen.CreateThread(function()
    local database = MySQL.Sync.fetchAll('SELECT * FROM tfs_crypto')
    for k, v in pairs(database) do
        local coords = json.decode(v.coords)
        local vec = vec3(coords.x, coords.y, coords.z)
        Warehouses[v.id] = {
            id = v.id,
            owner = v.owner,
            coords = vec,
            data = json.decode(v.data),
            state = json.decode(v.state),
            finance = json.decode(v.finance)
        }
    end

    Citizen.Wait(100)

    updateWarehouse()

    Citizen.Wait(50)

    for k, v in pairs(Warehouses) do
        if v.state.players then
            local xPlayer = ESX.GetPlayerFromIdentifier(v.owner)
            if xPlayer then
                TriggerClientEvent("TFS_crypto:setPlayerInWarehouse", xPlayer.source, v.id)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local database = MySQL.Sync.fetchAll('SELECT * FROM tfs_crypto')
        for k, v in pairs(database) do
            local data = json.decode(v.data)
            local finance = json.decode(v.finance)
            local loss = (finance.bills - finance.revenue)
            if loss > Config.LossLimit then
                for c, z in pairs(Warehouses[v.id].data) do
                    z.status = 0
                end
            end
            for l,b in pairs(data) do
                if b.stage >= 0 and b.status == 1 then
                    Warehouses[v.id].finance.revenue = Warehouses[v.id].finance.revenue + math.random(Config.Profit[tostring(b.stage)].min, Config.Profit[tostring(b.stage)].max)
                    Warehouses[v.id].finance.bills = Warehouses[v.id].finance.bills + Config.Electricity[tostring(b.stage)]
                end
            end
            MySQL.Async.execute('UPDATE tfs_crypto SET finance = @finance, data = @data WHERE id = @id',
            { ['finance'] = json.encode(Warehouses[v.id].finance), ['data'] = json.encode(Warehouses[v.id].data), ['id'] = v.id },
            function(insertId) end)
        end

        Citizen.Wait(100)

        updateWarehouse()
    Citizen.Wait(59000)
    end
end)

RegisterCommand(Config.Command, function(source, args)
    if (source < 1) then return end

    if #args ~= 1 or not tonumber(args[1]) then return end

    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() ~= Config.Admin then return end

    local coords = xPlayer.getCoords(true)

    local state = {
        players = false,
        forsale = true,
        saleprice = tonumber(args[1])
    }

    local data = {
        ["1"] = {stage = 0, status = 0},
        ["2"] = {stage = 0, status = 0},
        ["3"] = {stage = 0, status = 0},
        ["4"] = {stage = 0, status = 0},
        ["5"] = {stage = 0, status = 0},
        ["6"] = {stage = 0, status = 0}
    }

    local finance = {
        revenue = 0,
        bills = 0
    }

    MySQL.Async.insert('INSERT INTO tfs_crypto (coords, data, state, finance) VALUES (@coords, @data, @state, @finance)',
        { ['coords'] = json.encode(coords), ['data'] = json.encode(data), ['state'] = json.encode(state), ['finance'] = json.encode(finance)  },
    function(insertId) 
        Warehouses[insertId] = {
            id = insertId,
            owner = nil,
            coords = coords,
            data = data,
            state = state,
            finance = finance
        }
        updateWarehouse()
    end)
end)

Citizen.CreateThread(function()
    TriggerClientEvent('chat:addSuggestion', -1, '/'..Config.Command, 'Crée un entrepôt de crypto', {
        { name = "prix", help = "Un prix auquel il sera vendu" }
    })
end)

function updateWarehouse()
    TriggerClientEvent("TFS_crypto:updateClientData", -1, _G["Warehouses"])
end

RegisterNetEvent("esx:playerLoaded", function(source, xPlayer)
    TriggerClientEvent("TFS_crypto:updateClientData", source, _G["Warehouses"])

    Citizen.Wait(50)

    for k, v in pairs(Warehouses) do
        if v.state.players and v.owner == xPlayer.getIdentifier() then
            TriggerClientEvent("TFS_crypto:setPlayerInWarehouse", source, v.id)
        end
    end
end)

RegisterNetEvent("TFS_crypto:enterWarehouse", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    if Warehouses[id].owner ~= identifier then return end
    Warehouses[id].state.players = true
    MySQL.Async.execute('UPDATE tfs_crypto SET state = @state WHERE id = @id',
        { ['state'] = json.encode(Warehouses[id].state), ['id'] = id },
    function(insertId) end)
    updateWarehouse()
end)

RegisterNetEvent("TFS_crypto:exitWarehouse", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    if Warehouses[id].owner ~= identifier then return end
    Warehouses[id].state.players = false
    MySQL.Async.execute('UPDATE tfs_crypto SET state = @state WHERE id = @id',
        { ['state'] = json.encode(Warehouses[id].state), ['id'] = id },
    function(insertId) end)
    updateWarehouse()
end)

RegisterNetEvent("TFS_crypto:buyWarehouse", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    if Warehouses[id].owner == identifier then return end

    local valid =  true
    for k,v in pairs(Warehouses) do
        if v.owner == identifier then 
            for r,t in pairs(v.data) do
                if t.stage ~= 3 then valid = false end
            end
        end
    end
    if not valid then return end

    if xPlayer.getMoney() >= tonumber(Warehouses[id].state.saleprice) then
        xPlayer.removeMoney(tonumber(Warehouses[id].state.saleprice))
        if Warehouses[id].owner ~= nil then
            if Config.OldESX then
                MySQL.Async.fetchAll('SELECT bank FROM users WHERE identifier = @identifier', { ["@identifier"] = Warehouses[id].owner }, function(result)
                    if result[1]["bank"] ~= nil then
                        MySQL.Async.execute("UPDATE users SET bank = @newBank WHERE identifier = @identifier",
                            {
                                ["@identifier"] = Warehouses[id].owner,
                                ["@newBank"] = result[1]["bank"] + Warehouses[id].state.saleprice
                            }
                        )
                    end
                end)
            else
                MySQL.Async.fetchAll('SELECT accounts FROM users WHERE identifier = @identifier', 
                { ['identifier'] = Warehouses[id].owner }, function(result)

                    local accounts = {}
                    for k,v in pairs(result) do 
                        accounts = json.decode(v.accounts)
                    end
        
                    accounts.bank = accounts.bank + Warehouses[id].state.saleprice
                    
                    MySQL.Async.execute('UPDATE users SET accounts = @accounts WHERE identifier = @identifier',
                    { ['accounts'] = json.encode(accounts), ['identifier'] = Warehouses[id].owner },
                    function(insertId) end)
                end)
            end
        end
        Warehouses[id].state.forsale = false
        Warehouses[id].owner = identifier
        MySQL.Async.execute('UPDATE tfs_crypto SET owner = @owner, state = @state WHERE id = @id',
            { ['owner'] = identifier, ['state'] = json.encode(Warehouses[id].state), ['id'] = id },
        function(insertId) end)
        updateWarehouse()
    end
end)

RegisterNetEvent("TFS_crypto:upgradeRig", function(id, rigId, upgrade)
    local xPlayer = ESX.GetPlayerFromId(source)
    if upgrade - Warehouses[id].data[tostring(rigId)].stage ~= 1 or not tonumber(Config.Upgrades[tostring(upgrade)]) or upgrade >= 4 or Warehouses[id].owner ~= xPlayer.getIdentifier() then return end
    if xPlayer.getMoney() >= Config.Upgrades[tostring(upgrade)] then
        xPlayer.removeMoney(Config.Upgrades[tostring(upgrade)])
        Warehouses[id].data[tostring(rigId)].stage = tonumber(upgrade)
        MySQL.Async.execute('UPDATE tfs_crypto SET data = @data WHERE id = @id',
            { ['data'] = json.encode(Warehouses[id].data), ['id'] = id },
        function(insertId) end)
        TriggerClientEvent("TFS_crypto:upgradeRig", xPlayer.source, rigId, upgrade)
        updateWarehouse()
    end
end)
RegisterNetEvent("TFS_crypto:rigStatus", function(id, rigId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Warehouses[id].owner ~= xPlayer.getIdentifier() then return end
    if Warehouses[id].data[tostring(rigId)].status == 0 then 
        if (Warehouses[id].finance.bills - Warehouses[id].finance.revenue) <= Config.LossLimit then
            Warehouses[id].data[tostring(rigId)].status = 1
        end
    else
        Warehouses[id].data[tostring(rigId)].status = 0 
    end
    MySQL.Async.execute('UPDATE tfs_crypto SET data = @data WHERE id = @id',
        { ['data'] = json.encode(Warehouses[id].data), ['id'] = id },
    function(insertId) end)
    updateWarehouse()
end)

RegisterNetEvent("TFS_crypto:sellWarehouse", function(id, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Warehouses[id].owner ~= xPlayer.getIdentifier() or not tonumber(price) then return end
    Warehouses[id].state.forsale = true
    Warehouses[id].state.saleprice = tonumber(price)
    MySQL.Async.execute('UPDATE tfs_crypto SET state = @state WHERE id = @id',
        { ['state'] = json.encode(Warehouses[id].state), ['id'] = id },
    function(insertId) end)
    updateWarehouse()
end)

RegisterNetEvent("TFS_crypto:removeSell", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Warehouses[id].owner ~= xPlayer.getIdentifier() then return end
    Warehouses[id].state.forsale = false
    Warehouses[id].state.saleprice = 0
    MySQL.Async.execute('UPDATE tfs_crypto SET state = @state WHERE id = @id',
        { ['state'] = json.encode(Warehouses[id].state), ['id'] = id },
    function(insertId) end)
    updateWarehouse()
end)

RegisterNetEvent("TFS_crypto:revenueControl", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Warehouses[id].owner ~= xPlayer.getIdentifier() then return end
    local profit = (Warehouses[id].finance.revenue - Warehouses[id].finance.bills)
    if profit > 0 then
        xPlayer.addAccountMoney('bank', profit)
    elseif profit < 0 then 
        xPlayer.removeAccountMoney('bank', profit*-1)
    end
    Warehouses[id].finance.revenue = 0
    Warehouses[id].finance.bills = 0
    MySQL.Async.execute('UPDATE tfs_crypto SET finance = @finance WHERE id = @id',
        { ['finance'] = json.encode(Warehouses[id].finance), ['id'] = id },
    function(insertId) end)
    updateWarehouse()
end)

-- ████████╗██╗███████╗██╗ ██████╗ ██╗   ██╗███████╗███████╗
-- ╚══██╔══╝██║██╔════╝██║██╔═══██╗██║   ██║██╔════╝██╔════╝
--    ██║   ██║█████╗  ██║██║   ██║██║   ██║███████╗█████╗  
--    ██║   ██║██╔══╝  ██║██║   ██║██║   ██║╚════██║██╔══╝  
--    ██║   ██║██║     ██║╚██████╔╝╚██████╔╝███████║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝

