local Config = Config or {}

local State = {
    enabled = Config.enabled ~= false
}

local PermissionRequests = {
    nextId = 0,
    pending = {}
}

local function log(message)
    print(("[ardenhub_disablenpc] %s"):format(message))
end

local function notify(message)
    if type(message) ~= "string" or message == "" then
        return
    end

    if lib and lib.notify then
        lib.notify({
            title = "ArDenHub NPC",
            description = message,
            type = "error"
        })
        return
    end

    log(message)
end

local function clamp01(value)
    if type(value) ~= "number" then
        return 0.0
    end

    if value < 0.0 then
        return 0.0
    end

    if value > 1.0 then
        return 1.0
    end

    return value + 0.0
end

local function sanitizeConfig()
    if type(Config.densities) ~= "table" then
        Config.densities = {}
    end

    if type(Config.features) ~= "table" then
        Config.features = {}
    end

    if type(Config.resmon) ~= "table" then
        Config.resmon = {}
    end

    if type(Config.cleanup) ~= "table" then
        Config.cleanup = {}
    end

    if type(Config.command) ~= "table" then
        Config.command = {}
    end

    if type(Config.enabled) ~= "boolean" then
        Config.enabled = true
    end

    Config.densities.peds = clamp01(Config.densities.peds)
    Config.densities.scenarioPeds = clamp01(Config.densities.scenarioPeds)
    Config.densities.vehicles = clamp01(Config.densities.vehicles)
    Config.densities.randomVehicles = clamp01(Config.densities.randomVehicles)
    Config.densities.parkedVehicles = clamp01(Config.densities.parkedVehicles)

    if type(Config.features.disableCops) ~= "boolean" then
        Config.features.disableCops = true
    end

    if type(Config.features.disableDispatch) ~= "boolean" then
        Config.features.disableDispatch = true
    end

    if type(Config.features.disableWantedLevel) ~= "boolean" then
        Config.features.disableWantedLevel = true
    end

    if type(Config.features.disableRandomBoats) ~= "boolean" then
        Config.features.disableRandomBoats = true
    end

    if type(Config.features.disableGarbageTrucks) ~= "boolean" then
        Config.features.disableGarbageTrucks = true
    end

    if type(Config.resmon.frameWait) ~= "number" or Config.resmon.frameWait < 0 then
        Config.resmon.frameWait = 0
    end

    if type(Config.resmon.idleWait) ~= "number" or Config.resmon.idleWait < 250 then
        Config.resmon.idleWait = 1000
    end

    if type(Config.cleanup.enabled) ~= "boolean" then
        Config.cleanup.enabled = false
    end

    if type(Config.cleanup.interval) ~= "number" or Config.cleanup.interval < 1000 then
        Config.cleanup.interval = 15000
    end

    if type(Config.cleanup.radius) ~= "number" or Config.cleanup.radius <= 0.0 then
        Config.cleanup.radius = 250.0
    end

    if type(Config.cleanup.removePeds) ~= "boolean" then
        Config.cleanup.removePeds = true
    end

    if type(Config.cleanup.removeVehicles) ~= "boolean" then
        Config.cleanup.removeVehicles = false
    end

    if type(Config.cleanup.ignoreNetworked) ~= "boolean" then
        Config.cleanup.ignoreNetworked = true
    end

    if type(Config.command.enabled) ~= "boolean" then
        Config.command.enabled = true
    end

    if type(Config.command.name) ~= "string" or Config.command.name == "" then
        Config.command.name = "npc"
    end

    if type(Config.command.restricted) ~= "boolean" then
        Config.command.restricted = false
    end

    if type(Config.command.useFrameworkPermissions) ~= "boolean" then
        Config.command.useFrameworkPermissions = true
    end

    if type(Config.command.framework) ~= "string" then
        Config.command.framework = "auto"
    else
        Config.command.framework = string.lower(Config.command.framework)
        if Config.command.framework ~= "auto" and Config.command.framework ~= "esx" and Config.command.framework ~= "qbcore" then
            Config.command.framework = "auto"
        end
    end

    if type(Config.command.allowedGroups) ~= "table" or #Config.command.allowedGroups == 0 then
        Config.command.allowedGroups = {"admin", "superadmin", "god"}
    end

    if type(Config.command.deniedMessage) ~= "string" or Config.command.deniedMessage == "" then
        Config.command.deniedMessage = "Non hai i permessi per usare questo comando."
    end
end

sanitizeConfig()
State.enabled = Config.enabled

local function applyPersistentSettings()
    local playerId = PlayerId()

    if Config.features.disableDispatch then
        SetDispatchCopsForPlayer(playerId, false)
    end

    if Config.features.disableWantedLevel then
        SetMaxWantedLevel(0)
        ClearPlayerWantedLevel(playerId)
    end
end

local function applyPerFrameSettings()
    local d = Config.densities

    SetPedDensityMultiplierThisFrame(d.peds)
    SetScenarioPedDensityMultiplierThisFrame(d.scenarioPeds, d.scenarioPeds)
    SetVehicleDensityMultiplierThisFrame(d.vehicles)
    SetRandomVehicleDensityMultiplierThisFrame(d.randomVehicles)
    SetParkedVehicleDensityMultiplierThisFrame(d.parkedVehicles)

    if Config.features.disableRandomBoats then
        SetRandomBoats(false)
    end

    if Config.features.disableGarbageTrucks then
        SetGarbageTrucks(false)
    end

    if Config.features.disableCops then
        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(false)
        SetCreateRandomCopsOnScenarios(false)
    end

    if Config.features.disableDispatch then
        SetDispatchCopsForPlayer(PlayerId(), false)
    end
end

local function shouldSkipEntity(entity)
    if not DoesEntityExist(entity) then
        return true
    end

    if Config.cleanup.ignoreNetworked and NetworkGetEntityIsNetworked(entity) then
        return true
    end

    return false
end

local function removeNearbyPeds(origin, playerPed, radius)
    local peds = GetGamePool("CPed")

    for i = 1, #peds do
        local ped = peds[i]

        if ped ~= playerPed and not IsPedAPlayer(ped) and not shouldSkipEntity(ped) then
            if #(GetEntityCoords(ped) - origin) <= radius then
                SetEntityAsMissionEntity(ped, true, true)
                DeleteEntity(ped)
            end
        end
    end
end

local function removeNearbyVehicles(origin, playerPed, radius)
    local vehicles = GetGamePool("CVehicle")

    for i = 1, #vehicles do
        local veh = vehicles[i]

        if not shouldSkipEntity(veh) and #(GetEntityCoords(veh) - origin) <= radius then
            local driver = GetPedInVehicleSeat(veh, -1)
            if driver ~= playerPed and not IsPedAPlayer(driver) then
                SetEntityAsMissionEntity(veh, true, true)
                DeleteVehicle(veh)
            end
        end
    end
end

local function setEnabled(value)
    local nextState = value == true
    if State.enabled == nextState then
        return
    end

    State.enabled = nextState
    if State.enabled then
        applyPersistentSettings()
    end

    log(("NPC blocker %s"):format(State.enabled and "ON" or "OFF"))
end

local function requestCommandPermission(callback)
    if type(callback) ~= "function" then
        return
    end

    if not Config.command.useFrameworkPermissions then
        callback(true)
        return
    end

    PermissionRequests.nextId = PermissionRequests.nextId + 1
    local requestId = PermissionRequests.nextId
    PermissionRequests.pending[requestId] = callback

    TriggerServerEvent("ardenhub_disablenpc:requestCommandPermission", requestId)

    SetTimeout(5000, function()
        local pending = PermissionRequests.pending[requestId]
        if pending then
            PermissionRequests.pending[requestId] = nil
            pending(false, Config.command.deniedMessage)
        end
    end)
end

RegisterNetEvent("ardenhub_disablenpc:permissionResult", function(requestId, isAllowed, message)
    local callback = PermissionRequests.pending[requestId]
    if not callback then
        return
    end

    PermissionRequests.pending[requestId] = nil
    callback(isAllowed == true, message)
end)

RegisterNetEvent("ardenhub_disablenpc:setEnabled", function(value)
    if type(value) == "boolean" then
        setEnabled(value)
    end
end)

exports("SetEnabled", function(value)
    setEnabled(value)
end)

exports("IsEnabled", function()
    return State.enabled
end)

if Config.command.enabled then
    RegisterCommand(Config.command.name, function(_, args)
        local action = args[1] and string.lower(args[1]) or "toggle"

        requestCommandPermission(function(isAllowed, message)
            if not isAllowed then
                local deniedMessage = message or Config.command.deniedMessage
                log(deniedMessage)
                notify(deniedMessage)
                return
            end

            if action == "on" then
                setEnabled(true)
                return
            end

            if action == "off" then
                setEnabled(false)
                return
            end

            setEnabled(not State.enabled)
        end)
    end, Config.command.restricted)
end

applyPersistentSettings()

CreateThread(function()
    while true do
        if State.enabled then
            applyPerFrameSettings()
            Wait(Config.resmon.frameWait)
        else
            Wait(Config.resmon.idleWait)
        end
    end
end)

if Config.cleanup.enabled then
    CreateThread(function()
        while true do
            Wait(Config.cleanup.interval)

            if State.enabled then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local radius = Config.cleanup.radius

                if Config.cleanup.removePeds then
                    removeNearbyPeds(playerCoords, playerPed, radius)
                end

                if Config.cleanup.removeVehicles then
                    removeNearbyVehicles(playerCoords, playerPed, radius)
                end
            end
        end
    end)
end