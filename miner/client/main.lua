local InWork = false
local showsBlip = false
local gathered = false
local showUI = false

local proximityRange = 3.0

local OutOfRange = 200.0

local actionKey = 38 -- E


function SpawnPedAtCoords(coords, heading)
    for i, worker in pairs(Config.Worker) do
        local pedHash = GetHashKey(worker.Hash)
        RequestModel(pedHash)

        while not HasModelLoaded(pedHash) do
            Citizen.Wait(0)
        end

        local ped = CreatePed(4, pedHash, coords.x, coords.y, coords.z, heading, false, false)
        SetEntityAsMissionEntity(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
    end
end

local blips = {}
local markers = {}
local playerCoords = nil

Citizen.CreateThread(function()
    for i, blipInfo in pairs(Config.Worker) do
        local targetCoords = blipInfo.Wcoords
        local heading = blipInfo.Wheading

        SpawnPedAtCoords(targetCoords, heading)

        local Workerblips = AddBlipForCoord(targetCoords.x, targetCoords.y, targetCoords.z)
        SetBlipSprite(Workerblips, blipInfo.WspriteID)
        SetBlipDisplay(Workerblips, blipInfo.WdisplayMode)
        SetBlipScale(Workerblips, blipInfo.Wscale)
        SetBlipColour(Workerblips, blipInfo.Wcolor)
        SetBlipAsShortRange(Workerblips, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipInfo.Wlabel)
        EndTextCommandSetBlipName(Workerblips)

        while true do
            Citizen.Wait(0)

            playerCoords = GetEntityCoords(PlayerPedId())
            local distance = GetDistanceBetweenCoords(playerCoords, targetCoords)

            if distance <= proximityRange then
                if IsControlJustReleased(0, actionKey) then
                    TriggerServerEvent("requestPlayerData")
                    showUI = true
                end

            end
            if distance >= OutOfRange then
                InWork = false
                showsBlip = false
                gathered = false
                working()
            end
        end
    end
end)

function working()
    for i, blipInfo in pairs(Config.Blips) do
        local blipCoords = blipInfo.coords

        if showsBlip and InWork then
            if not blips[i] then
                blips[i] = AddBlipForCoord(blipCoords.x, blipCoords.y, blipCoords.z)
                SetBlipSprite(blips[i], blipInfo.spriteID)
                SetBlipDisplay(blips[i], blipInfo.displayMode)
                SetBlipScale(blips[i], blipInfo.scale)
                SetBlipColour(blips[i], blipInfo.color)
                SetBlipAsShortRange(blips[i], true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(blipInfo.label)
                EndTextCommandSetBlipName(blips[i])
            end
        elseif not showsBlip then
            if blips[i] then
                RemoveBlip(blips[i]) 
                blips[i] = nil 
            end
        end
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for i, markerInfo in pairs(Config.Blips) do
            local markerCoords = markerInfo.coords
            local markercolor = markerInfo.markerscolor
            local markerscale = markerInfo.markersscale
            local PpPlayer = PlayerPedId()
            local playerCoordsM = GetEntityCoords(PpPlayer)
            local markerDistance = GetDistanceBetweenCoords(playerCoordsM, markerCoords)

            if markerDistance <= proximityRange then
                if showsBlip then
                    if IsControlJustReleased(0, actionKey) then
                        if not gathered then
                            gathered = true
                            Workiing()
                        end
                        
                    end
                end
            end

            if showsBlip and InWork then
                if not markers[i] then
                    DrawMarker(2, markerCoords.x, markerCoords.y, markerCoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, markerscale,markerscale,markerscale, markercolor.r, markercolor.g, markercolor.b, 50, false, true, 2, nil, nil, false)
                end
            elseif showsBlip then
                if markers[i] then
                    RemoveMarker(markers[i])
                    markers[i] = nil
                end
            end
        end
    end
end)


function Workiing()
    if gathered then
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(5000)
        TriggerServerEvent("addxp")
        gathered = false
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

local progresnumber = 0
local level = 0
Citizen.CreateThread(function()
    local playerid = PlayerPedId()
    while true do
        Citizen.Wait(0)
        SendNUIMessage({
            showUi = showUI,
            progresnumberS = progresnumber,
            InWorks = InWork,
            levell = level
        })
        if showUI then
            SetNuiFocus(true, true)
        else
            SetNuiFocus(false, false)
        end
    end
end)



RegisterNuiCallback("exit", function(data, cb)
    showUI = data.showUI
    cb({})
end)

RegisterNuiCallback("workui", function()
    if InWork then
        showsBlip = false
        InWork = false
        working()
    else
        showsBlip = true
        InWork = true
        working()
    end
end)


RegisterNetEvent("receivePlayerData")
AddEventHandler("receivePlayerData", function(playerData)
    if playerData.xp then
        progresnumber = playerData.xp.value  
    end
    if playerData.rank then
        level = playerData.rank.value
    end
end)












RegisterCommand("spawncar", function(source, args, rawCommand)
    local vehicleName = args[1] or "adder"
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)

    if IsModelInCdimage(vehicleName) and IsModelAVehicle(vehicleName) then
        RequestModel(vehicleName)

        while not HasModelLoaded(vehicleName) do
            Citizen.Wait(0)
        end

        local vehicle = CreateVehicle(vehicleName, playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(playerPed), true, false)

        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    end
end, false)