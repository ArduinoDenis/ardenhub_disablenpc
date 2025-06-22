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
        DisableDispatchService(1) -- Police
        DisableDispatchService(2) -- Firefighters
        DisableDispatchService(3) -- Ambulances
    end

    if Config.DisableNPC.garbageTrucks then
        DisableDispatchService(11) -- Garbage truck
    end
end

-- Loop main
Citizen.CreateThread(function()
    while true do
        DisableNPCs()
        Citizen.Wait(0)
    end
end)