
-- Connection Logic

local function AwaitContext()
    while GetResourceState("esx_context") ~= "started" do
        Wait(100)
    end
    return true
end

local function DisableSpawnManager()
    if GetResourceState("spawnmanager") == "started" then
        exports.spawnmanager:setAutoSpawn(false)
    end
end

CreateThread(function()

    while not ESX.PlayerLoaded do
        Wait(100)

        if NetworkIsPlayerActive(ESX.PlayerData.playerId) then
            DisableSpawnManager()
            DoScreenFadeOut(0)

            local ready = AwaitContext()
            if ready then

                Multicharacter:SetupCharacters()
                break
            end
        end
    end
end)

-- Events

RegisterNetEvent("esx_multicharacter:SetupUI", function(data, slots)
    Multicharacter:SetupUI(data, slots)
end)

RegisterNetEvent('esx:playerLoaded', function(playerData, isNew, skin)
    Multicharacter:PlayerLoaded(playerData, isNew, skin)
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    DoScreenFadeOut(500)
    Wait(5000)

    Multicharacter.spawned = false

    Multicharacter:SetupCharacters()
    TriggerEvent("esx_skin:resetFirstSpawn")
end)

-- Relog

if Config.Relog then
    RegisterCommand("relog", function()
        if Multicharacter.canRelog then
            Multicharacter.canRelog = false
            TriggerServerEvent("esx_multicharacter:relog")

            ESX.SetTimeout(10000, function()
                Multicharacter.canRelog = true
            end)

        end
    end,false)
end