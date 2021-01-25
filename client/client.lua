local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
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

-- Trap Houses
function playAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
    RemoveAnimDict(animDict)
end

RegisterNetEvent('cfx_traphouse:LockpickTrapHouse')
AddEventHandler('cfx_traphouse:LockpickTrapHouse', function(itemtype)
    local closestTrapHouse = nil

    for k,v in pairs(Config.TrapHouses) do
        local pedCoords = GetEntityCoords(PlayerPedId())
        local blipCoords = v.pos
        local blip_dist = GetDistanceBetweenCoords(pedCoords, blipCoords)

        if blip_dist <= Config.ShowMarkerDistance then
            if blip_dist <= 2.0 then
                closestTrapHouse = k
                break
            end
        end
    end

    if closestTrapHouse ~= nil then
        RobTrapHouse(closestTrapHouse, itemtype)
    else
        return
    end
end)

RegisterNetEvent('cfx_traphouse:TraphouseNotification')
AddEventHandler('cfx_traphouse:TraphouseNotification', function()
    if ESX.PlayerData.job.name ~= 'police' and ESX.PlayerData.job.name ~= 'ambulance' and ESX.PlayerData.job.name ~= 'judge' and ESX.PlayerData.job.name ~= 'lawyer' and ESX.PlayerData.job.name ~= 'mayor' then
        TriggerEvent('InteractSound_CL:PlayOnOne', 'email', 1.0)
        TriggerEvent('chat:addMessage', {
            template = "<div class='chat-message advert'><div class='chat-message-header'>[^1EMAIL^0] Foo, I heard from our homie that one of the trap houses is getting robbed right now.</div></div>", 
            args = {}
        })
    end
end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local closestTrap = nil
        local isClose = false

        for k,v in pairs(Config.TrapHouses) do
            local pedCoords = GetEntityCoords(playerPed)
            local blipCoords = v.pos
            local blip_dist = GetDistanceBetweenCoords(pedCoords, blipCoords)


            if blip_dist <= Config.ShowMarkerDistance then
                closestTrap = k

                if blip_dist <= 2.0 then
                    isClose = true
                end
            end
        end


        if closestTrap ~= nil then

            if not isClose then
                DrawMarker(2, Config.TrapHouses[closestTrap].pos.x, Config.TrapHouses[closestTrap].pos.y, Config.TrapHouses[closestTrap].pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
            end

            if isClose then
                Draw3DText(Config.TrapHouses[closestTrap].pos.x, Config.TrapHouses[closestTrap].pos.y, Config.TrapHouses[closestTrap].pos.z, Config.TrapHouses[closestTrap].text)

                if IsControlJustReleased(0, 38) then
                    OpenTrapHouseMenu(closestTrap)
                    Citizen.Wait(5000)
                end
            end
        else
            Wait(5000)
        end
                  
    end
end)

function OpenTrapHouseMenu(trapId)
    local elements = {
        {label = 'Enter Pin', value = 'traphouse_buy'},
        {label = 'Reset Pin', value = 'reset_pin'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'open_traphouse_menu', {
        --title    = Config.TrapHouses[trapId].name..' | Trap ID#'..trapId,
        title = ('%s - <span style="color:red;">Trap ID# %s</span>'):format(Config.TrapHouses[trapId].name, trapId),
        align    = 'top-right',
        elements = elements
    }, function(data, menu)

        if data.current.value == "traphouse_buy" then
            OpenKeyPadUI(trapId)
            menu.close()
        elseif data.current.value == "reset_pin" then
            ESX.TriggerServerCallback('cfx_traphouse:isAllowed', function(isAllowed)
                if isAllowed then
                    ESX.UI.Menu.Open(
                        'dialog', GetCurrentResourceName(), 'reset_pin',
                        {
                          title = "Reset Pin"
                        },
                    function(data2, menu2)
                        local pin = math.floor(tonumber(data2.value))
                        if pin == nil then
                            exports['mythic_notify']:DoLongHudText('error', 'You need to put something here!')
                            return
                        end
                        
                        local pinLength = string.len(pin)
                        if pinLength >= 5 or pinLength <= 1 then
                            exports['mythic_notify']:DoLongHudText('error','pin is either too short or too long')
                            print('PIN :'..pin..' LENGTH :'..pinLength)
                            return
                        end
                    
                        TriggerServerEvent('cfx_traphouse:ResetPin', pin, trapId)
                    
                        menu2.close()
                    end, function(data2, menu2)
                        menu2.close()
                    end)
                else
                    exports['mythic_notify']:DoLongHudText('error', 'You\'re not the owner of this house!')
                end
            end, trapId)
        end
        if closestTrap == nil then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end) 
end


function OpenTrapHouseBuyMenu(trapId)

    local data = {
        items = Config.TrapHouses[trapId].items,
        shop_name = Config.TrapHouses[trapId].name,
        zone = nil,
        shop_type = "traphouse",
        trapid = trapId
    }

    local elements = {}
    ESX.UI.Menu.CloseAll()

    for i = 1, #data.items, 1 do
        table.insert(elements, {
            label      = ('%s - <span style="color:green;">%s</span>'):format(data.items[i].label, ESX.Math.GroupDigits(data.items[i].price)..'$'),
            item = data.items[i].name,
            price = data.items[i].price,

            value = 1,
            type = 'slider',
            min = 1,
            max = data.items[i].limit          
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'buy_traphouse_item', {
        title    = Config.TrapHouses[trapId].name,
        align    = 'center',
        elements = elements
    }, function(data, menu)
        -- menu.close()
        TriggerServerEvent('cfx_traphouse:buyTrapHouseItem', data.current.item, data.current.price, data.current.value, trapId)
    end, function(data, menu)
        menu.close()
    end)  
end

function RobTrapHouse(trapId, itemtype)


    ESX.TriggerServerCallback('cfx_traphouse:getLastRobbed', function(notRecentlyRobbed)

        if notRecentlyRobbed then

            local robbing = true

            Citizen.CreateThread(function()
                while robbing do
                    Citizen.Wait(0)

                    local pedCoords = GetEntityCoords(PlayerPedId())
                    local dist = GetDistanceBetweenCoords(pedCoords, Config.TrapHouses[trapId].pos.x, Config.TrapHouses[trapId].pos.y, Config.TrapHouses[trapId].pos.z, 1)

                    if dist >= 5.0 then
                        exports['mythic_notify']:DoCustomHudText('error', 'Too far from trap house.' , 5000) 

                        TriggerServerEvent('cfx_traphouse:resetTrapHouseRobbery')
                        robbing = false
                    elseif IsEntityPlayingAnim(GetPlayerPed(-1), 'dead', 'dead_a', 1) then
                        exports['mythic_notify']:DoCustomHudText('error', 'Failed to rob.' , 5000) 

                        TriggerServerEvent('cfx_traphouse:resetTrapHouseRobbery')  
                        robbing = false                  
                    end               

                end
            end)

            local times = 40

            if itemtype == "lockpick" then
                times = 25
            elseif itemtype == "advanced_lockpick" then
                times = 25
            end

            local success = exports['cfx_lockpick']:StartLockpickGame(times)    
            if not success then
                exports['mythic_notify']:DoCustomHudText('error', 'Lockpick bent out of shape.' , 5000) 
                robbing = false
                TriggerServerEvent('cfx_traphouse:removeItem', itemtype, 1)
                TriggerServerEvent('cfx_traphouse:resetTrapHouseRobbery')  

                local chance = math.random(Config.MinChance,Config.MaxChance)
                if chance >= 35 then
                    TriggerServerEvent('cfx_traphouse:notifyAll')
                    print('^1NOTIFIED ON ALL ATTEMP FAILED^0')
                end

                return
            end            
                     

            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('cfx_traphouse:robTrapHouse', trapId)
            TriggerServerEvent('cfx_traphouse:removeItem', itemtype, 1)
            robbing = false

        else
            exports['mythic_notify']:DoLongHudText('inform', 'This trap house has been robbed recently.')
        end

    end, trapId)
end

function Draw3DText(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.025, 0, 0, 0, 75)
end

-- KEYPAD
RegisterCommand('keykey', function(source)
    OpenKeyPadUI(1)
end)

function OpenKeyPadUI(trapId)
    SetNuiFocus(true,true)
    SendNUIMessage({
        open = true,
        id = trapId
    })
end


function CloseKeyPadUI()
    SetNuiFocus(false,false)
    SendNUIMessage({close = true})
end

RegisterNUICallback('close', function(data, cb)
  CloseKeyPadUI()
  cb('ok')
end)

RegisterNUICallback('complete', function(data, cb)
    if tonumber(data.id) < 10 then
        ESX.TriggerServerCallback('cfx_traphouse:getTrapHousePin', function(pin)
            local currentPin = tostring(pin)

            if currentPin == data.pin then
                CloseKeyPadUI()
                exports['mythic_notify']:DoLongHudText('inform', 'Success!')
                Citizen.Wait(1000)

                if tonumber(data.id) == 6 then
                    -- open
                elseif tonumber(data.id) == 7 then
                    --
                else
                    OpenTrapHouseBuyMenu(tonumber(data.id))
                end
            else
                TriggerServerEvent('cfx_traphouse:lockTrapHouse', data.id)
                exports['mythic_notify']:DoLongHudText('error', 'Invalid Pin!')
            end

        end, data.id)
    else
        CloseKeyPadUI()  
    end


    cb('ok')
end)

RegisterNetEvent('cfx_traphouse:openKeypad')
AddEventHandler('cfx_traphouse:openKeypad', function(id)
    OpenKeyPadUI(id)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if Config.AutoStock == true then
            for i=1, #Config.TrapHouses do
                print('^3TRAP HOUSE ID: ^4'..i..'^3 SUCCESFULLY RESTOCKED!^0')
                TriggerServerEvent('cfx_traphouse:restockOnRestart', i)
                Citizen.Wait(3000)
            end
            print('[^4'..GetCurrentResourceName()..'^0] ^3TRAP HOUSES FULLY CONFIGURED^0')
        else
            print('[^4'..GetCurrentResourceName()..'^0] ^3TRAP HOUSES FULLY CONFIGURED^0 [^3AUTO RESTOCK : OFF^0]')
        end
    end
end)