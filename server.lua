local Config = Config or {}
local ESX = nil
local QBCore = nil

local function log(message)
    print(("[ardenhub_disablenpc] %s"):format(message))
end

local function getAllowedGroupsSet()
    local set = {}
    local groups = Config.command and Config.command.allowedGroups or {}

    if type(groups) ~= "table" then
        return set
    end

    for i = 1, #groups do
        local group = groups[i]
        if type(group) == "string" and group ~= "" then
            set[string.lower(group)] = true
        end
    end

    return set
end

local function getConfiguredFramework()
    local framework = "auto"

    if type(Config.command) == "table" and type(Config.command.framework) == "string" then
        framework = string.lower(Config.command.framework)
    end

    if framework == "esx" or framework == "qbcore" then
        return framework
    end

    return "auto"
end

local function fetchESX()
    if ESX then
        return ESX
    end

    if GetResourceState("es_extended") ~= "started" then
        return nil
    end

    local ok, sharedObject = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)

    if ok and sharedObject then
        ESX = sharedObject
        return ESX
    end

    TriggerEvent("esx:getSharedObject", function(obj)
        ESX = obj
    end)

    return ESX
end

local function fetchQBCore()
    if QBCore then
        return QBCore
    end

    if GetResourceState("qb-core") ~= "started" then
        return nil
    end

    local ok, coreObject = pcall(function()
        return exports["qb-core"]:GetCoreObject()
    end)

    if ok and coreObject then
        QBCore = coreObject
    end

    return QBCore
end

local function hasESXGroup(source, allowedGroups)
    local esx = fetchESX()
    if not esx then
        return false
    end

    local xPlayer = esx.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end

    local group = nil
    if type(xPlayer.getGroup) == "function" then
        group = xPlayer.getGroup()
    elseif type(xPlayer.group) == "string" then
        group = xPlayer.group
    end

    if type(group) ~= "string" or group == "" then
        return false
    end

    return allowedGroups[string.lower(group)] == true
end

local function hasQBCorePermission(source, allowedGroups)
    local qb = fetchQBCore()
    if not qb or type(qb.Functions) ~= "table" then
        return false
    end

    if type(qb.Functions.HasPermission) ~= "function" then
        return false
    end

    for groupName, _ in pairs(allowedGroups) do
        if qb.Functions.HasPermission(source, groupName) then
            return true
        end
    end

    return false
end

local function isAllowed(source)
    local commandConfig = Config.command or {}
    if commandConfig.useFrameworkPermissions == false then
        return true
    end

    local allowedGroups = getAllowedGroupsSet()
    if next(allowedGroups) == nil then
        log("allowedGroups is empty, denying command usage by default.")
        return false
    end

    local framework = getConfiguredFramework()
    if framework == "esx" then
        return hasESXGroup(source, allowedGroups)
    end

    if framework == "qbcore" then
        return hasQBCorePermission(source, allowedGroups)
    end

    if GetResourceState("es_extended") == "started" and hasESXGroup(source, allowedGroups) then
        return true
    end

    if GetResourceState("qb-core") == "started" and hasQBCorePermission(source, allowedGroups) then
        return true
    end

    return false
end

RegisterNetEvent("ardenhub_disablenpc:requestCommandPermission", function(requestId)
    local src = source

    if type(requestId) ~= "number" then
        return
    end

    local allowed = isAllowed(src)
    local deniedMessage = "Non hai i permessi per usare questo comando."

    if type(Config.command) == "table" and type(Config.command.deniedMessage) == "string" and Config.command.deniedMessage ~= "" then
        deniedMessage = Config.command.deniedMessage
    end

    TriggerClientEvent("ardenhub_disablenpc:permissionResult", src, requestId, allowed, allowed and nil or deniedMessage)
end)
