Config = {
    enabled = true,

    -- 0.0 no spawn while 1.0 is default density
    densities = {
        peds = 0.1,
        scenarioPeds = 0.1,
        vehicles = 0.1,
        randomVehicles = 0.1,
        parkedVehicles = 0.0
    },

    features = {
        disableCops = false,
        disableDispatch = true,
        disableWantedLevel = true,
        disableRandomBoats = true,
        disableGarbageTrucks = true
    },

    resmon = {
        frameWait = 0,
        idleWait = 1000
    },

    cleanup = {
        enabled = true,
        interval = 15000,
        radius = 250.0,
        removePeds = true,
        removeVehicles = false,
        ignoreNetworked = true
    },

    command = {
        enabled = true,
        name = "npc",
        restricted = false, -- ACE permission passed to RegisterCommand
        useFrameworkPermissions = true,

        
        framework = "auto", -- "auto", "esx", "qbcore"

        allowedGroups = {
            "god",
            "owner",
            "superadmin",
            "admin",
            "dev",
            "mod",
        },

        deniedMessage = "Non hai i permessi per usare questo comando."
    }
}
