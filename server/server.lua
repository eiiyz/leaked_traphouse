ESX = nil
cachedData = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('advancedlockpick', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('cfx_traphouse:LockpickTrapHouse', source, 'advanced_lockpick')
    TriggerEvent('cfx_truckrob:Start', source)
end)

ESX.RegisterServerCallback('cfx_traphouse:getTrapHousePin', function(source, cb, trapId, isLocked)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT pin FROM trap_houses WHERE trapId = @trapId', {
        ['@trapId'] = trapId
      }, function (result)
        if result ~= nil then
            pin = result[1].pin
            cb(pin)
        end
    end)
end)

ESX.RegisterServerCallback('cfx_traphouse:getLastRobbed', function(source, cb , currentTrap)
	local _source = source
	local xPlayers = ESX.GetPlayers()

	if Config.TrapHouses[currentTrap] then
		local trapId = Config.TrapHouses[currentTrap]
		if trapId.lastrobbed and (os.time() - trapId.lastrobbed) < (Config.TimeBeforeNewRob * 60) then
            cb(false)
            print('^3TRAPID ^0^2#'..currentTrap..'^0 ^3COOLDOWN ACTIVE FOR^0^2 ['..(Config.TimeBeforeNewRob * 60 / 3600)..' HOUR/S]^0 ^3 TIME LASTED: ^0 ^2['..(os.time() - trapId.lastrobbed)..' SECONDS]^0')
		else
			cb(true)
		end
	end
end)

ESX.RegisterServerCallback('cfx_traphouse:isAllowed', function(source, cb, trapId)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT owner FROM trap_houses WHERE trapId = @trapId', {
        ['@trapId'] = tonumber(trapId)
      }, function (result)
        if result ~= nil then
            owner = result[1].owner
            if result[1].owner == xPlayer.identifier then
                cb(true)
            else
                cb(false)
            end
        end
    end)
end)

RegisterServerEvent('cfx_traphouse:removeItem')
AddEventHandler('cfx_traphouse:removeItem', function(name, amount)
	local xPlayer  = ESX.GetPlayerFromId(source)
	if name == 'money' then
		xPlayer.removeMoney(amount)
	else 
		xPlayer.removeInventoryItem(name, amount)
	end
end)

RegisterServerEvent('cfx_traphouse:receiveItem')
AddEventHandler('cfx_traphouse:receiveItem', function(name, amount)
	local xPlayer  = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(name)
	if xItem.limit ~= -1 and (xItem.count) > xItem.limit then
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "You can't carry more"})
    else
		if name == 'money' then
			xPlayer.addMoney(amount)
		else 
			xPlayer.addInventoryItem(name, amount)
		end
	end
end)

RegisterServerEvent('cfx_traphouse:resetTrapHouseRobbery')
AddEventHandler('cfx_traphouse:resetTrapHouseRobbery', function()
	if Config.TrapHouses[currentTrap] then
		Config.TrapHouses[currentTrap].lastrobbed = 0
	end
end)

RegisterServerEvent('cfx_traphouse:notifyAll')
AddEventHandler('cfx_traphouse:notifyAll', function()
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name ~= 'police' then
            TriggerClientEvent('cfx_traphouse:TraphouseNotification', xPlayers[i])
        end
    end
end)

RegisterServerEvent("cfx_traphouse:robTrapHouse")
AddEventHandler("cfx_traphouse:robTrapHouse",function(currentTrap)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xPlayers = ESX.GetPlayers()
    if Config.TrapHouses[currentTrap] then
        local trapId = Config.TrapHouses[currentTrap]
        trapId.lastrobbed = os.time()
        
        GiveReward(currentTrap)
    end
end)

function GiveReward(currentTrap)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local trapId = Config.TrapHouses[currentTrap]
    local item = trapId.items[math.random(1, #trapId.items)]
    local amount = math.random(1,4)
    print("^3REWARD ITEM/WEAPON:^0 ^4"..item.label..'^0 ^3AMOUNT:^0 ^3'..amount..'^0')
    xPlayer.addInventoryItem(item.name, amount)
    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'You got '..amount..'x '..item.label..'!', length = 4500})

    local item2 = trapId.items[math.random(1, #trapId.items)]
    local amount2 = math.random(1,4)
    print("^3REWARD ITEM/WEAPON:^0 ^4"..item2.label..'^0 ^3AMOUNT:^0 ^3'..amount2..'^0')
    xPlayer.addInventoryItem(item2.name, amount)
    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'You got '..amount2..'x '..item2.label..'!', length = 4500})

    local chance = math.random(1,50)
    local qty = math.random(5000,10000)
    if chance >= 25 then
        xPlayer.addAccountMoney('black_money',qty)
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'You got '..ESX.Math.GroupDigits(qty)..'$ dirty money!', length = 4500})
    end
end

RegisterServerEvent('cfx_traphouse:buyTrapHouseItem')
AddEventHandler('cfx_traphouse:buyTrapHouseItem', function(item, price, amount, trapId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local stocksleft = GetStock(item, trapId)
    local money = xPlayer.getAccount('black_money').money
    local sourceItem = xPlayer.getInventoryItem(item)
    local totalPrice = price * amount
    local itemLabel
    if money >= totalPrice then
        if stocksleft >= amount then
            if sourceItem.count >= sourceItem.limit then
                TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You cant carry anymore!', length = 4500})
            else
                xPlayer.addInventoryItem(item, amount)
                xPlayer.removeAccountMoney('black_money', tonumber(totalPrice))
                
                local data = {
                    items = Config.TrapHouses[trapId].items,
                }
                for i = 1, #data.items, 1 do
                    if data.items[i].name == item then
                        itemLabel = data.items[i].label
                    end
                end

                TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'You bought '..amount..'x '..itemLabel..' for '..ESX.Math.GroupDigits(totalPrice)..'$!', length = 4500})
                MySQL.Async.execute('UPDATE trap_house_items SET stock = stock - 1 WHERE item = @item AND trapId = @trapId', {
                    ['@item'] = item,
                    ['@trapId'] = trapId
                }, nil)
            end
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'Theres no more stocks foo!', length = 4500})
        end
    else
        local missingMoney = totalPrice - money
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You\'re missing '..ESX.Math.GroupDigits(missingMoney)..'$ of dirty money!', length = 4500})
    end
end)

-- Reset Pin
RegisterServerEvent('cfx_traphouse:ResetPin')
AddEventHandler('cfx_traphouse:ResetPin', function(pin, trapId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.fetchAll('SELECT owner FROM trap_houses WHERE trapId = @trapId', {
        ['@trapId'] = tonumber(trapId)
      }, function (result)
        if result ~= nil then
            owner = result[1].owner
            if result[1].owner == xPlayer.identifier then
                MySQL.Async.execute('UPDATE trap_houses SET pin = @pin WHERE trapId = @trapId', {
                    ['@trapId'] = tonumber(trapId),
                    ['@pin'] = tonumber(pin),
                })
                TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Pin '..pin..' is now set for House iD #'..trapId, length = 4500})
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You\'re not the owner of this house', length = 4500})
                print('^2NAME :^3'..xPlayer.name..' | ^2STEAMHEX: ^3'..xPlayer.identifier..' | ^3Tried to change [^1cfx_traphouse:ResetPin^3] what a dum fuc.^3')
                print('^2NAME :^3'..xPlayer.name..' | ^2STEAMHEX: ^3'..xPlayer.identifier..' | ^3Tried to change [^1cfx_traphouse:ResetPin^3] what a dum fuc.^3')
            end
        end
    end)
end)

RegisterServerEvent('cfx_traphouse:restockOnRestart')
AddEventHandler('cfx_traphouse:restockOnRestart', function(trapId)
    local item, restocknum
    local data = {
        items = Config.TrapHouses[trapId].items,
    }
    for i = 1, #data.items, 1 do
        item = data.items[i].name
        restocknum = data.items[i].stocks  
        MySQL.Async.execute('UPDATE trap_house_items SET stock = @stock WHERE item = @item AND trapId = @trapId', {
            ['@item'] = item,
            ['@stock'] = restocknum,
            ['@trapId'] = trapId
        }, nil)
    end
end)

-- COMMANDS
RegisterCommand('restock', function(source, args)
    if isAllowed(src) then
        if args[1] and args[2] == nil then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Invalid use! /restock [trapId] [item]', length = 4500}) 
        else
            restocks(tonumber(args[1]), args[2])
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Item : '.. args[2] .. ' succesfully restocked !', length = 4500}) 
            Citizen.Wait(3000)
            local stocksleft = GetStock(args[2], tonumber(args[1]))
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = args[2] .. ' current stock :'..stocksleft, length = 4500}) 
        end
    else
        print('^4[cfx_traphouse]^0 ^3SOMONETRIED TO RESTOCK ITEMS IN THE DB AND NOT AN ADMIN^0\n^4[cfx_traphouse]^0 ^3NAME:^0 ^1'..xPlayer.name..' ^3STEAM:^0 ^1'..xPlayer.identifier..'^0')
    end
end)

RegisterCommand('installDB', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if isAllowed(src) then
        MySQL.Async.execute('DELETE FROM `trap_house_items`', nil)
        print('^3CLEARING ITEMS IN THE DATABASE^0')
        Citizen.Wait(3500)
        for trapId = 1, #Config.TrapHouses do
            print('^3TRAP HOUSE ID:^0 ^4['..trapId..']^0 ^3 ITEMS SUCCESFULLY INSTALLED IN DATABSE!^0')
            installDB(trapId)
            Citizen.Wait(3000)
        end
        print('[^4cfx_traphouse^0] ^3TRAP HOUSES FULLY CONFIGURED^0')
    else
        print('^4[cfx_traphouse]^0 ^3SOMONETRIED TO INSTALL ITEMS IN THE DB AND NOT AN ADMIN^0\n^4[cfx_traphouse]^0 ^3NAME:^0 ^1'..xPlayer.name..' ^3STEAM:^0 ^1'..xPlayer.identifier..'^0')
    end
end)

RegisterCommand('setownertrap', function(source,args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetxPlayer = ESX.GetPlayerFromId(args[1])
    local trapId = tonumber(args[2])
    if isAllowed(src) then
        if args[1] and args[2] == nil then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Invalid use! /setTrapOwner [Player ID] [Trap House ID]', length = 4500}) 
        elseif not targetxPlayer then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Player not online', length = 4500}) 
        else
            MySQL.Async.execute('UPDATE trap_houses SET owner = @owner WHERE trapId = @trapId', {
                ['@owner'] = targetxPlayer.identifier,
                ['@trapId'] = trapId
            }, nil)
            TriggerClientEvent('mythic_notify:client:SendAlert', args[1], { type = 'inform', text = 'You are now the owner of Trap House #'..trapId, length = 4500}) 
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = string.upper(targetxPlayer.name)..' is now the owner of Trap House #'..trapId, length = 4500}) 
        end
    else
        print('^4[cfx_traphouse]^0 ^3SOMONETRIED TO SET TRAP HOUSE OWNER AND NOT AN ADMIN^0\n^4[cfx_traphouse]^0 ^3NAME:^0 ^1'..xPlayer.name..' ^3STEAM:^0 ^1'..xPlayer.identifier..'^0')
    end
end)

RegisterCommand('getpintrap', function(source,args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local trapId = tonumber(args[1])
    if args[1] == nil then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Invalid use! /getpintrap [Trap House ID]', length = 4500}) 
    else
        MySQL.Async.fetchAll('SELECT * FROM trap_houses WHERE trapId = @trapId', {
            ['@trapId'] = trapId
          }, function (result)
            if result ~= nil then
                owner = result[1].owner
                if xPlayer.identifier == owner then
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Your trap house pin is '..result[1].pin, length = 4500}) 
                else
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'You don\'t own this trap house', length = 4500}) 
                end
            end
        end)
    end
end)  

-- FUNCTIONS
function GetStock(itemName, trapId)
	local stock = MySQL.Sync.fetchScalar('SELECT stock FROM trap_house_items WHERE trapId = @trapId AND item = @item', {
		['@trapId'] = trapId,
		['@item'] = itemName
	})

	if stock then
		return stock
	else
		return 0
	end
end

function restocks(trapId,restock_item)
    local item, restocknum
    local data = {
        items = Config.TrapHouses[trapId].items,
    }
    for i = 1, #data.items, 1 do
        if data.items[i].name == restock_item then
            item = data.items[i].name
            restocknum = data.items[i].stocks  
        end
    end
    MySQL.Async.execute('UPDATE trap_house_items SET stock = @stock WHERE item = @item AND trapId = @trapId', {
        ['@item'] = item,
        ['@stock'] = restocknum,
        ['@trapId'] = trapId
    }, nil)
end

function installDB(trapId)
    local item, restocknum
    local data = {
        items = Config.TrapHouses[trapId].items,
    }
    for i = 1, #data.items, 1 do
        item = data.items[i].name
        restocknum = data.items[i].stocks  
        print('^3ITEM:^0 ^4'..item..'^0 ^3STOCKS:^0 ^4'..restocknum..'^0 ^2RESTOCKED!^0')
        MySQL.Async.execute('INSERT INTO trap_house_items (item, stock, trapId) VALUES (@item, @stock, @trapId)', {
            ['@item'] = item,
            ['@stock'] = restocknum,
            ['@trapId'] = trapId
        }, nil)
    end
end

function isAllowed(player)
    local allowed = false
    for i,id in ipairs(Config.admins) do
        for x,pid in ipairs(GetPlayerIdentifiers(player)) do
            if debugprint then print('admin id: ' .. id .. '\nplayer id:' .. pid) end
            if string.lower(pid) == string.lower(id) then
                allowed = true
            end
        end
    end
    return allowed
end