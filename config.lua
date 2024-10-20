-- ████████╗██╗███████╗██╗ ██████╗ ██╗   ██╗███████╗███████╗
-- ╚══██╔══╝██║██╔════╝██║██╔═══██╗██║   ██║██╔════╝██╔════╝
--    ██║   ██║█████╗  ██║██║   ██║██║   ██║███████╗█████╗  
--    ██║   ██║██╔══╝  ██║██║   ██║██║   ██║╚════██║██╔══╝  
--    ██║   ██║██║     ██║╚██████╔╝╚██████╔╝███████║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝

Config = {}                                                                      
Config.OldESX = false -- utilisez true si vous utilisez ESX 1.1

Config.Admin = "admin" -- nom du groupe admin qui peut créer des entrepôts

Config.Upgrades = {
    ["1"] = 10000, -- acheter l'équipement
    ["2"] = 40000, -- deuxième niveau
    ["3"] = 80000, -- niveau max
}

Config.Profit = { -- profit par minute
    ["1"] = {min = 10, max = 50}, -- premier niveau
    ["2"] = {min = 60, max = 90}, -- deuxième niveau
    ["3"] = {min = 110, max = 180}, -- niveau max
}

Config.Electricity = { -- factures d'électricité par minute
    ["1"] = 15, -- premier niveau
    ["2"] = 25, -- deuxième niveau
    ["3"] = 45, -- niveau max
}

Config.Translations = { -- ne supprimez pas "%s" des traductions !
    your_warehouse = "[~g~Votre~w~] Entrepôt~w~\n[~y~E~w~] Entrer",
    your_warehouse_for_sale = "Entrepôt [~y~À vendre~w~]\nPrix : ~g~$~w~%s\nAppuyez sur [~b~X~w~] pour info\nAppuyez sur [~y~E~w~] pour retirer de la vente",
    warehouse_for_sale = "Entrepôt [~y~À vendre~w~]\nPrix : ~g~$~w~%s\nAppuyez sur [~b~X~w~] pour info\nAppuyez sur [~y~E~w~] pour acheter",
    owned_warehouse = "[~r~Propriétaire~w~] Entrepôt~w~",
    not_maxed = "Vous devez compléter ou vendre votre entrepôt actuel pour en acheter un autre",
    no_rig = "~c~Aucun~w~",
    max_rig = "~g~Niveau Max~w~",
    rig_stage = "~o~Niveau %s~w~",
    warehouse_info = "-- Informations sur l'entrepôt --",
    first_rig = "[~b~1~w~ Équipement]: ",
    second_rig = "[~b~2~w~ Équipement]: ",
    third_rig = "[~b~3~w~ Équipement]: ",
    fourth_rig = "[~b~4~w~ Équipement]: ",
    fifth_rig = "[~b~5~w~ Équipement]: ",
    sixth_rig = "[~b~6~w~ Équipement]: ",
    on = "~g~ACTIVÉ~w~",
    off = "~r~DÉSACTIVÉ~w~",
    buy_rig = "[~b~F~w~] Info\n[~y~E~w~] [~g~$~w~%s~w~]",
    rig_status = "[Niveau: ~p~%s~w~]\n[~b~F~w~] Info\n[~p~X~w~] [État: %s]\n[~y~E~w~] [~g~$~w~%s~w~]",
    max_rig_status = "[Niveau: ~o~MAX~w~]\n[~b~F~w~] Info\n[~p~X~w~] [État: %s]",
    no_rig_info = "Actuel [par min]: Profit[0]| Électricité [0]",
    rig_info = "Actuel [par min]: Profit[%s-%s]| Électricité [%s]",
    upgrade_rig_info = "Amélioration [par min]: Profit [%s-%s]| Électricité~w~ [%s]",
    exit = "[~r~E~w~] Sortir",
    take_profit = "[~g~E~w~] Prendre (~g~$%s~w~)\n",
    pay_bills = "[~r~E~w~] Payer (~r~$%s~w~)\n",
    warehouse_stats = "Factures : ~r~$%s~w~\nRevenu : ~g~$%s~w~\n%s[~o~B~w~] Vendre l'entrepôt",
    turn_off_rigs = "Éteignez d'abord tous les équipements !",
    pay_or_take = "Payer les factures ou prendre les bénéfices d'abord !",
    keyboard_header = "Prix :",
    blip_owned = "[Propriétaire] Entrepôt de crypto",
    blip_my = "[Mon] Entrepôt de crypto",
    blip_for_sale = "[À vendre] Entrepôt de crypto",
}

Config.UseBlips = true

Config.Command = "create_cryptohouse"

Config.LossLimit = 1000

Config.Controls = {
    enter_buy_delist_warehouse = 51,
    check_warehouse_info = 73,
    upgrade_rig = 51,
    toggle_rig = 73,
    rig_info = 49,
    exit = 51,
    sell_warehouse = 29,
    pay_bills_take_profits = 51
}

function notification(message)
    TriggerEvent('esx:showNotification', message, true) -- Ici tu peux mettre ta notif (perso, esx, etc...)
end

-- ████████╗██╗███████╗██╗ ██████╗ ██╗   ██╗███████╗███████╗
-- ╚══██╔══╝██║██╔════╝██║██╔═══██╗██║   ██║██╔════╝██╔════╝
--    ██║   ██║█████╗  ██║██║   ██║██║   ██║███████╗█████╗  
--    ██║   ██║██╔══╝  ██║██║   ██║██║   ██║╚════██║██╔══╝  
--    ██║   ██║██║     ██║╚██████╔╝╚██████╔╝███████║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝