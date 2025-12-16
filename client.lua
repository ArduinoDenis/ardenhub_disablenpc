local function DisableNPCs()
    -- Disable the generation of NPCs
    SetPedDensityMultiplierThisFrame(Config.DensityMultiplier.pedDensity)
    SetScenarioPedDensityMultiplierThisFrame(Config.DensityMultiplier.pedDensity, Config.DensityMultiplier.pedDensity)
    
    -- Disable vehicular traffic
    SetVehicleDensityMultiplierThisFrame(Config.DensityMultiplier.vehicleDensity)
    SetRandomVehicleDensityMultiplierThisFrame(Config.DensityMultiplier.vehicleDensity)
    SetParkedVehicleDensityMultiplierThisFrame(Config.DensityMultiplier.vehicleDensity)

    -- Disables various types of NPCs based on the config
    if Config.DisableNPC.peds then
        SetPedPopulationBudget(0)
    end
    
    if Config.DisableNPC.vehicles then
        SetVehiclePopulationBudget(0) 
    end

    if Config.DisableNPC.emergencyVehicles then
        -- Usa EnableDispatchService con false per disabilitare
        EnableDispatchService(1, false) -- Police
        EnableDispatchService(2, false) -- Firefighters
        EnableDispatchService(3, false) -- Ambulances
    end

    if Config.DisableNPC.garbageTrucks then
        EnableDispatchService(11, false) 
    end
end

-- Loop main
Citizen.CreateThread(function()
    while true do
        DisableNPCs()
        Citizen.Wait(0)
    end
end)
