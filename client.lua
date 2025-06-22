local function DisableNPCs()
    -- Disabilita la generazione di NPC
    SetPedDensityMultiplierThisFrame(Config.DensityMultiplier.pedDensity)
    SetScenarioPedDensityMultiplierThisFrame(Config.DensityMultiplier.pedDensity, Config.DensityMultiplier.pedDensity)
    
    -- Disabilita il traffico veicolare
    SetVehicleDensityMultiplierThisFrame(Config.DensityMultiplier.vehicleDensity)
    SetRandomVehicleDensityMultiplierThisFrame(Config.DensityMultiplier.vehicleDensity)
    SetParkedVehicleDensityMultiplierThisFrame(Config.DensityMultiplier.vehicleDensity)

    -- Disabilita vari tipi di NPC in base al config
    if Config.DisableNPC.peds then
        SetPedPopulationBudget(0)
    end
    
    if Config.DisableNPC.vehicles then
        SetVehiclePopulationBudget(0) 
    end

    if Config.DisableNPC.emergencyVehicles then
        DisableDispatchService(1) -- Polizia
        DisableDispatchService(2) -- Pompieri
        DisableDispatchService(3) -- Ambulanze
    end

    if Config.DisableNPC.garbageTrucks then
        DisableDispatchService(11) -- Camion spazzatura
    end
end

-- Loop principale
Citizen.CreateThread(function()
    while true do
        DisableNPCs()
        Citizen.Wait(0)
    end
end)