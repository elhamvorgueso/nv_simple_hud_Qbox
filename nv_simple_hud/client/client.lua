local inCar = false
local before = {}
local isReady = nil

local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local health = GetEntityHealth(player) - 100
        local armour = GetPedArmour(player)
        local PlayerData = QBCore.Functions.GetPlayerData()

        local hunger = 100
        local thirst = 100
        local money = 0
        local bank = 0
        local jobName = ''
        local jobLabel = ''
        local jobGrade = ''
        local onlinePlayers = #GetActivePlayers()

        -- Verificar si PlayerData y metadata están listos
        if PlayerData and PlayerData.metadata then
            hunger = PlayerData.metadata["hunger"] or 100
            thirst = PlayerData.metadata["thirst"] or 100
            money = PlayerData.money and PlayerData.money.cash or 0
            bank = PlayerData.money and PlayerData.money.bank or 0
            jobName = PlayerData.job and PlayerData.job.name or ''
            jobLabel = PlayerData.job and PlayerData.job.label or ''
            jobGrade = PlayerData.job and PlayerData.job.grade and PlayerData.job.grade.name or ''
        else
            -- Si no están listos, espera y vuelve a pasar
            Citizen.Wait(500)
            goto continue
        end

        if not (hunger and thirst) then
            SendNUIMessage({status = 'visible', data = false})
            goto continue
        end

        if not isReady then
            isReady = true
        end

        if health < 0 then health = 0 end

        SendNUIMessage({
            status = 'info',
            data = {
                health = health,
                armour = armour,
                food = hunger / 100,
                water = thirst / 100,
                money = money,
                bank = bank,
                job = jobLabel,
                jobGrade = jobGrade,
                onlinePlayers = onlinePlayers,
                playerID = GetPlayerServerId(PlayerId())
            }
        })

        ::continue::
        Citizen.Wait(3000)
    end
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(PlayerData)
end)

local wait = 1000
Citizen.CreateThread(function()
    while true do
        if before.ready ~= isReady then
            before.ready = true
            SendNUIMessage({status = 'visible', data = true})
            wait = 1000
            goto endLoop
        end
        
        do
            local pause = IsPauseMenuActive()
            if pause ~= before.pause then
                if pause then
                    SendNUIMessage({status = 'visible', data = false})
                else
                    SendNUIMessage({status = 'visible', data = true})
                end
                before.pause = pause
            end
            
            local player = PlayerPedId()
            local isPedInVehicle = IsPedInAnyVehicle(player)
            
            if isPedInVehicle then
                local vehicle = GetVehiclePedIsIn(player)
                if GetPedInVehicleSeat(vehicle, -1) == player then
                    wait = 200
                    inCar = true
                    local fuel = Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
                    local speed = GetEntitySpeed(vehicle)
                    local is_mph = GetResourceState('qb-vehiclekeys') ~= 'missing'
                    if not is_mph then
                        speed = speed * 3.6
                    else
                        speed = speed * 2.236936
                    end
                    local engine = GetVehicleEngineHealth(vehicle) / 10
                    if fuel ~= before.fuel then
                        before.fuel = fuel
                    end
                    if speed ~= before.speed then
                        before.speed = speed
                    end
                    if engine ~= before.engine then
                        before.engine = engine
                    end
                end
                before.speedometer_visible = true
                SendNUIMessage({status = 'speedometer', data = {visible = true, speed = before.speed, engine = before.engine, fuel = before.fuel, mph = is_mph}})
            else
                if before.speedometer_visible then 
                    before.speedometer_visible = false
                    SendNUIMessage({status = 'speedometer', data = {visible = false}})
                end
                inCar = false
                wait = 1000
            end
    
            local isPedArmed = IsPedArmed(player, 4)
            if isPedArmed then
                wait = 200
                local weaponHash = GetSelectedPedWeapon(player)
                local ammoInClip = GetAmmoInClip(player, weaponHash)
                local maxAmmo = GetMaxAmmoInClip(player, weaponHash, true)
                local totalAmmo = GetAmmoInPedWeapon(player, weaponHash)
                
                before.weapon_visible = true
                SendNUIMessage({
                    status = 'weapon',
                    data = {
                        visible = true,
                        ammoInClip = ammoInClip,
                        maxAmmo = maxAmmo,
                        totalAmmo = (totalAmmo - ammoInClip)
                    }
                })
            else
                if before.weapon_visible then
                    before.weapon_visible = false
                    SendNUIMessage({
                        status = 'weapon',
                        data = {visible = false}
                    })
                end
            end
        end
        
        ::endLoop::
        Citizen.Wait(wait)
    end
end)

function GetAmmoInClip(ped, weaponHash)
    local ammoClip = Citizen.InvokeNative(0x2E1202248937775C, ped, weaponHash, Citizen.PointerValueInt())
    return ammoClip
end

-- Función para mostrar el HUD
local function ShowHUD()
    SendNUIMessage({status = 'visible', data = true})
end

-- Función para ocultar el HUD
local function HideHUD()
    SendNUIMessage({status = 'visible', data = false})
end

-- Exportarlas para que puedan ser llamadas desde otros recursos
exports('ShowHUD', ShowHUD)
exports('HideHUD', HideHUD)

--exports['nv_simple_hud']:ShowHUD()
--TriggerEvent('nv_simple_hud:ShowHUD')

--TriggerEvent('nv_simple_hud:HideHUD')
--exports['nv_simple_hud']:HideHUD()
